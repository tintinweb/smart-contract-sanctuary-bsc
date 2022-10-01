//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./IERC20.sol";

interface IToken {
    function getOwner() external view returns (address);
    function burn(uint256 amount) external returns (bool);
}

contract AutoCTaxReceiver {

    // Token
    address public immutable token;


    // Receiver Adresses
    address public treasuryAddress;
    address public devAddress;

    // Allocation Percentage
    uint256 public treasuryPercentage;
    uint256 public devPercentage;

    /**
        Minimum Amount Of Tokens In Contract To Trigger `trigger` Unless `approved`
        If Set To A Very High Number, Only Approved May Call Trigger Function
        If Set To A Very Low Number, Anybody May Call At Their Leasure
     */
    uint256 public minimumTokensRequiredToTrigger;

    // Address => Can Call Trigger
    mapping ( address => bool ) public approved;

    // Events
    event Approved(address caller, bool isApproved);

    modifier onlyOwner(){
        require(
            msg.sender == IToken(token).getOwner(),
            'Only Token Owner'
        );
        _;
    }

    constructor(address token_, address treasuryAddress_, address devAddress_) {
        require(
            token_ != address(0) &&
            treasuryAddress_ != address(0) &&
            devAddress_ != address(0),
            'Zero Address'
        );

        token = token_;
        treasuryAddress = treasuryAddress_;
        devAddress = devAddress_;

        approved[msg.sender] = true;

        treasuryPercentage = 30;
        devPercentage = 10;
    }

    function trigger() external {

        // Token Balance In Contract
        uint balance = IERC20(token).balanceOf(address(this));

        if (balance < minimumTokensRequiredToTrigger && !approved[msg.sender]) {
            return;
        }

        if (balance > 0) {
            uint treasuryBalance = balance * treasuryPercentage / 100;
            uint devBalance = balance * devPercentage / 100;
            uint burn = balance - treasuryBalance - devBalance;

            // send to destinations
            if (treasuryBalance > 0) {
                IERC20(token).transfer(treasuryAddress, treasuryBalance);
            }
            if (devBalance > 0) {
                IERC20(token).transfer(devAddress, devBalance);
            }
            if (burn > 0) {
                IToken(token).burn(burn);
            }
        }
    }

    function setTreasuryAddress(address treasuryAddress_) external onlyOwner {
        require(treasuryAddress_ != address(0));
        treasuryAddress = treasuryAddress_;
    }
    function setTreasuryPercentage(uint256 newTreasuryPercentage_) external onlyOwner {
        require((devPercentage + newTreasuryPercentage_) <= 100);
        treasuryPercentage = newTreasuryPercentage_;
    }

    function setDevAddress(address devAddress_) external onlyOwner {
        require(devAddress_ != address(0));
        devAddress = devAddress_;
    }
    function setDevPercentage(uint256 newDevPercentage_) external onlyOwner {
        require((treasuryPercentage + newDevPercentage_) <= 100);
        devPercentage = newDevPercentage_;
    }

    function setApproved(address caller, bool isApproved) external onlyOwner {
        approved[caller] = isApproved;
        emit Approved(caller, isApproved);
    }
    function setMinTriggerAmount(uint256 minTriggerAmount) external onlyOwner {
        minimumTokensRequiredToTrigger = minTriggerAmount;
    }

    function withdraw() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }
    function withdraw(address _token) external onlyOwner {
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }
}