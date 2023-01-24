//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";

interface ISubscriptionDatabase {
    function setUserData(address user, uint256 amountPaid, uint256 newPaidUntil) external;
    function userPaidUntil(address user) external view returns (uint256);
    function getOwner() external view returns (address);
}

/**
    Truth Seekers Subscription Smart Contract
    Learn More At dappd.net/hosting
 */
contract TruthSeekersSubscription {

    /** Constants */
    uint256 public constant month = 864000;
    uint256 public constant year = month * 12;

    /** Subscription Database */
    ISubscriptionDatabase public immutable database;

    /** Token To Accept As Payment */
    address public payToken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    
    /** Payment Recipient */
    address public paymentRecipient = 0x664A3c02Bc8F3c90d843a5420E67cC1fBb2f62FB;

    /** Cost Per Month */
    uint256 public monthlyCost = 995 * 10**16;
    
    /** Cost Per Year */
    uint256 public yearlyCost = 89 * 10**18;

    /** Only Database Owner Can Modify */
    modifier onlyOwner() {
        require(msg.sender == database.getOwner(), 'Only Owner');
        _;
    }

    constructor(address db_) {
        database = ISubscriptionDatabase(db_);
    }

    ////////////////////////////////////
    /////     OWNER FUNCTIONS     //////
    ////////////////////////////////////

    function setPayRecipient(address newRecipient) external onlyOwner {
        require(
            newRecipient != address(0),
            'Zero Address'
        );
        paymentRecipient = newRecipient;
    }

    function setPayToken(address newToken) external onlyOwner {
        payToken = newToken;
    }

    function setMonthlyCost(uint newCost) external onlyOwner {
        monthlyCost = newCost;
    }

    function setYearlyCost(uint newCost) external onlyOwner {
        yearlyCost = newCost;
    }


    ////////////////////////////////////
    /////     PUBLIC FUNCTIONS    //////
    ////////////////////////////////////


    function paySubscription(bool monthly) external {

        // determine either monthly or yearly amount
        uint amount = monthly ? monthlyCost : yearlyCost;
        uint additionalBlocks = monthly ? month : year;

        // send payment to payment receiver
        require(
            IERC20(payToken).allowance(msg.sender, address(this)) >= amount,
            'Insufficient Allowance'
        );
        require(
            IERC20(payToken).transferFrom(
                msg.sender,
                paymentRecipient,
                amount
            ),
            'Failure Transfer From'
        );

        // fetch user paid until date
        uint paidUntilPrevious = database.userPaidUntil(msg.sender);

        // determine future paid until date
        uint paidUntilCurrent = paidUntilPrevious > block.number ? paidUntilPrevious + additionalBlocks : block.number + additionalBlocks;

        // set data in database
        database.setUserData(msg.sender, amount, paidUntilCurrent);
    }
}