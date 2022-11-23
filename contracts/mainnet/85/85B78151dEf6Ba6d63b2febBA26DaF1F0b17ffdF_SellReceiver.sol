//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./IUniswapV2Router02.sol";

interface IMDB {
    function getOwner() external view returns (address);
}

interface IYieldFarm {
    function depositRewards(uint256 amount) external;
}

interface IAutoFarm {
    function compound() external;
}

contract SellReceiver {

    // router
    IUniswapV2Router02 router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    // MDB token
    address public constant token = 0x0557a288A93ed0DF218785F2787dac1cd077F8f3;

    // Recipients Of Fees
    address public constant trustFund = 0x45F8F3a7A91e302935eB644f371bdE63D0b1bAc6;
    address public constant marketing = 0x511DEaD182a47c60034FEdf36eA0714972625E85;
    address public constant yieldFarm = 0x08254Df4F9461f8Fc15235be5092862BfF4824d4;
    address public constant staking = 0xe8f699B68ddE8e59DBe8fdF20955931B25fe7dFa;
    address public constant MDBPFarm = 0x65545d6eBf5F4245Ca2f9c90468dE38fE88E3672;
    address public constant BNBAutoFarm = 0x805Cc5aA1EBeE725250084D2ECcD9473c8bE46A9;

    // Token -> BNB
    address[] path;

    /**
        Minimum Amount Of MDB In Contract To Trigger `trigger` Unless `approved`
            If Set To A Very High Number, Only Approved May Call Trigger Function
            If Set To A Very Low Number, Anybody May Call At Their Leasure
     */
    uint256 public minimumTokensRequiredToTrigger;

    // Trust Fund Allocation
    uint256 public marketingPercentage = 200;
    uint256 public trustFundPercentage = 536;

    // Address => Can Call Trigger
    mapping ( address => bool ) public approved;

    // Events
    event Approved(address caller, bool isApproved);

    modifier onlyOwner(){
        require(
            msg.sender == IMDB(token).getOwner(),
            'Only MDB Owner'
        );
        _;
    }

    constructor() {

        // Sell Path
        path = new address[](2);
        path[0] = token;
        path[1] = router.WETH();

        // set initial approved
        approved[msg.sender] = true;

        // only approved can trigger at the start
        minimumTokensRequiredToTrigger = 10**30;
    }

    function trigger() external {

        // MDB Balance In Contract
        uint balance = IERC20(token).balanceOf(address(this));

        if (balance < minimumTokensRequiredToTrigger && !approved[msg.sender]) {
            return;
        }

        uint toSell = balance * ( marketingPercentage + trustFundPercentage ) / 1000;
        uint toSend = balance - toSell;
        uint forFarms = toSend / 3;
        uint forStaking = toSend - ( 2 * forFarms );

        // Send to standard farm
        IERC20(token).approve(yieldFarm, forFarms);
        IYieldFarm(yieldFarm).depositRewards(forFarms);

        // send to auto farm
        IERC20(token).transfer(MDBPFarm, forFarms);

        // Send to staking
        IERC20(token).transfer(staking, forStaking);

        // compound auto yield farms
        IAutoFarm(MDBPFarm).compound();
        IAutoFarm(BNBAutoFarm).compound();
        
        // sell MDB in contract for BNB
        IERC20(token).approve(address(router), toSell);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(toSell, 0, path, address(this), block.timestamp + 300);

        if (address(this).balance > 0) {
            // fraction out bnb received
            uint part1 = address(this).balance * trustFundPercentage / ( marketingPercentage + trustFundPercentage );
            uint part2 = address(this).balance - part1;

            // send to destinations
            _send(trustFund, part1);
            _send(marketing, part2);
        }
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
        (bool s,) = payable(recipient).call{value: amount}("");
        require(s);
    }
}