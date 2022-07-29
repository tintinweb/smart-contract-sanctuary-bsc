/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

contract Event {
    address payable[] public players;
    address payable public mostRecent;
    address payable public contractOwner;
    address payable public walletOwner;
    uint256 public resultRandomness;
    uint256 public numberOfEntries;
    uint256 public maxEntries;
    uint256 public lastAmountPayout;
    uint256 private entryFee;

    enum EVENT_STATE {
        CLOSED,
        OPEN,
        CALCULATE
    }
    EVENT_STATE public state;

    constructor(
        uint256 entry,
        uint256 max,
        address wallet
    ) public {
        entryFee = entry;
        numberOfEntries = 0;
        maxEntries = max;
        state = EVENT_STATE.CLOSED;

        walletOwner = payable(wallet);
        contractOwner = payable(msg.sender);
    }

    modifier onlyWalletOwner() {
        require(msg.sender == walletOwner, "Not Wallet Owner");
        _;
    }

    modifier onlyContractOwner() {
        require(msg.sender == contractOwner, "Not Contract Owner");
        _;
    }

    function enter() public payable {
        require(
            msg.sender != walletOwner,
            "Wallet Collector Not allowed to enter"
        );
        require(
            msg.sender != contractOwner,
            "Contract Owner Not allowed to enter"
        );
        require(state == EVENT_STATE.OPEN);
        require(msg.value >= getFee(), "Not Enough Currency");
        require((numberOfEntries) < maxEntries, "Max Entries Already Met");
        players.push(payable(msg.sender));
        numberOfEntries++;
    }

    function getFee() public view returns (uint256) {
        return entryFee;
    }

    function changeWalletOwner(address payable newWallet)
        public
        onlyContractOwner
    {
        require(state == EVENT_STATE.CLOSED, "Event is Running");
        require(
            contractOwner != newWallet,
            "Contract owner cannot also be Wallet owner"
        );
        walletOwner = newWallet;
    }

    function changeFee(uint256 newAmount) public onlyContractOwner {
        require(state == EVENT_STATE.CLOSED, "Event is Running");
        entryFee = newAmount;
    }

    function changeMaxExtries(uint256 newAmount) public onlyContractOwner {
        require(state == EVENT_STATE.CLOSED, "Event is Running");
        maxEntries = newAmount;
    }

    function changeContractOwner(address payable newOwner)
        public
        onlyContractOwner
    {
        require(state == EVENT_STATE.CLOSED, "Event is Running");
        require(
            walletOwner != newOwner,
            "Wallet owner cannot also be Contract owner"
        );
        contractOwner = newOwner;
    }

    function startEvent() public onlyWalletOwner {
        require(state == EVENT_STATE.CLOSED, "Event already Started");
        state = EVENT_STATE.OPEN;
    }

    function endEvent() public onlyWalletOwner {
        require(state == EVENT_STATE.OPEN, "Event is NOT Started");
        state = EVENT_STATE.CALCULATE;
    }

    function cancelEvent() public onlyWalletOwner {
        require(state != EVENT_STATE.CLOSED, "Event is NOT Started");
        walletOwner.transfer(address(this).balance);
        players = new address payable[](0);
        state = EVENT_STATE.CLOSED;
    }

    function finalize(uint256 randomness) public onlyWalletOwner {
        require(state == EVENT_STATE.CALCULATE, "Not looking for a winner yet");
        require(randomness > 0, "random number not generated");
        require(
            randomness != resultRandomness,
            "random number has not changed"
        );
        uint256 indexOfWinner = randomness % (numberOfEntries);
        mostRecent = players[indexOfWinner];
        walletOwner.transfer(address(this).balance / 2);
        lastAmountPayout = address(this).balance;
        mostRecent.transfer(address(this).balance);
        players = new address payable[](0);
        numberOfEntries = 0;
        state = EVENT_STATE.CLOSED;
        resultRandomness = randomness;
    }
}