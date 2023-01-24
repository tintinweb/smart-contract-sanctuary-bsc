//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./Ownable.sol";

/**
    Truth Seekers Subscription Smart Contract
    Learn More At dappd.net/hosting
 */
contract TruthSeekersSubscriptionDatabase is Ownable {

    /** Client Structure */
    struct Client {
        uint256 amountPaid;
        uint256 paidUntil;
    }

    /** Client ID => Project */
    mapping ( address => Client ) public clients;

    /** Total Costs Accrued */
    uint256 public totalCollected;

    /** Updater Address */
    address public updater;

    ////////////////////////////////////
    /////     OWNER FUNCTIONS     //////
    ////////////////////////////////////

    function setUpdater(address newUpdater) external onlyOwner {
        require(
            newUpdater != address(0),
            'Zero Address'
        );
        updater = newUpdater;
    }

    function setPaidUntil(address client, uint256 blockNo) external onlyOwner {
        clients[client].paidUntil = blockNo;
    }

    function setPaidUntilBatch(address[] calldata clients_, uint256 blockNo) external onlyOwner {
        uint len = clients_.length;
        for (uint i = 0; i < len;) {
            clients[clients_[i]].paidUntil = blockNo;
            unchecked { ++i; }
        }
    }


    ////////////////////////////////////
    /////     PUBLIC FUNCTIONS    //////
    ////////////////////////////////////

    function setUserData(address user, uint256 amountPaid, uint256 newPaidUntil) external {
        require(msg.sender == updater, 'Only Updater');

        unchecked {
            clients[user].amountPaid += amountPaid;
            totalCollected += amountPaid;
        }

        clients[user].paidUntil = newPaidUntil;
    }

    ////////////////////////////////////
    /////      READ FUNCTIONS     //////
    ////////////////////////////////////

    function blocksAheadOnPayment(address user) public view returns (uint256) {
        return clients[user].paidUntil > block.number ? clients[user].paidUntil - block.number : 0;
    }

    function subscriptionValid(address user) public view returns (bool) {
        return blocksAheadOnPayment(user) > 0;
    }

    function userPaid(address user) external view returns (uint256) {
        return clients[user].amountPaid;
    }

    function userPaidUntil(address user) external view returns (uint256) {
        return clients[user].paidUntil;
    }

}