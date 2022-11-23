//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";

interface IMDB {
    function getOwner() external view returns (address);
}

interface IYieldFarm {
    function depositRewards(uint256 amount) external;
}

interface IAutoFarm {
    function compound() external;
}

contract BuyReceiver {

    // MDB token
    address public constant token = 0x0557a288A93ed0DF218785F2787dac1cd077F8f3;

    // Recipients Of Fees
    address public constant trustFund = 0x45F8F3a7A91e302935eB644f371bdE63D0b1bAc6;
    address public constant marketing = 0x511DEaD182a47c60034FEdf36eA0714972625E85;
    address public constant yieldFarm = 0x08254Df4F9461f8Fc15235be5092862BfF4824d4;
    address public constant staking = 0xe8f699B68ddE8e59DBe8fdF20955931B25fe7dFa;
    address public constant MDBPFarm = 0x65545d6eBf5F4245Ca2f9c90468dE38fE88E3672;
    address public constant BNBAutoFarm = 0x805Cc5aA1EBeE725250084D2ECcD9473c8bE46A9;

    /**
        Minimum Amount Of MDB In Contract To Trigger `trigger` Unless `approved`
            If Set To A Very High Number, Only Approved May Call Trigger Function
            If Set To A Very Low Number, Anybody May Call At Their Leasure
     */
    uint256 public minimumTokensRequiredToTrigger;

    // Address => Can Call Trigger
    mapping ( address => bool ) public approved;

    // Events
    event Approved(address caller, bool isApproved);

    // Trust Fund Allocation
    uint256 public marketingPercentage = 200;
    uint256 public trustFundPercentage = 536;

    modifier onlyOwner(){
        require(
            msg.sender == IMDB(token).getOwner(),
            'Only MDB Owner'
        );
        _;
    }

    constructor() {
        // set initial approved
        approved[msg.sender] = true;

        // trust fund percentage
        trustFundPercentage = 80;

        // only approved can trigger at the start
        minimumTokensRequiredToTrigger = 10**30;
    }

    function trigger() external {

        // MDB Balance In Contract
        uint balance = IERC20(token).balanceOf(address(this));

        if (balance < minimumTokensRequiredToTrigger && !approved[msg.sender]) {
            return;
        }

        // fraction out tokens
        uint part1 = balance * trustFundPercentage / 1000;
        uint part2 = balance * marketingPercentage / 1000;

        // send to destinations
        _send(trustFund, part1);
        _send(marketing, part2);

        uint remainder = IERC20(token).balanceOf(address(this));
        uint forFarms = remainder / 3;
        uint forStaking = remainder - ( 2 * forFarms );

        // Send to farms
        IERC20(token).approve(yieldFarm, 10**50);
        IYieldFarm(yieldFarm).depositRewards(forFarms);

        // Send to Autocompounding Farm
        _send(MDBPFarm, forFarms);

        // Send to staking
        _send(staking, forStaking);

        // compound auto yield farms
        IAutoFarm(MDBPFarm).compound();
        IAutoFarm(BNBAutoFarm).compound();
    }
   
    function setApproved(address caller, bool isApproved) external onlyOwner {
        approved[caller] = isApproved;
        emit Approved(caller, isApproved);
    }
    
    function setMinTriggerAmount(uint256 minTriggerAmount) external onlyOwner {
        minimumTokensRequiredToTrigger = minTriggerAmount;
    }
    
    function setTrustFundPercentage(uint256 newAllocatiton) external onlyOwner {
        trustFundPercentage = newAllocatiton;
    }

    function setMarketingPercentage(uint256 newAllocatiton) external onlyOwner {
        marketingPercentage = newAllocatiton;
    }
    
    function withdraw() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }
    
    function withdraw(address _token) external onlyOwner {
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }
    
    receive() external payable {}

    function _send(address recipient, uint amount) internal {
        bool s = IERC20(token).transfer(recipient, amount);
        require(s, 'Failure On Token Transfer');
    }
}