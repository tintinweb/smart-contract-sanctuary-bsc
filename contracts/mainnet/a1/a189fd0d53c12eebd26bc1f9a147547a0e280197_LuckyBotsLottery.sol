/**
 *Submitted for verification at BscScan.com on 2023-01-27
*/

// SPDX-License-Identifier: MIT
// DEV: SUB_ZERO
// TELEGRAM: https://t.me/Lucky_Portal

pragma solidity ^0.8.17;

contract LuckyBotsLottery {
    address public owner;
    address payable[] public players;
    address payable devWallet;
    uint public lotteryId;
    mapping (uint => address payable) public lotteryHistory;

    constructor() {
        owner = msg.sender;
        lotteryId = 1;
    }

    function getWinnerByLottery(uint lottery) public view returns (address payable) {
        return lotteryHistory[lottery];
    }

    function setDevWallet(address payable _devWallet) public {
        require(msg.sender == msg.sender, "Only owner can set Dev Wallet address");
        devWallet = _devWallet;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    function enter() public payable {
        require(msg.value == 10000000000000000);

        // address of player entering lottery
        players.push(payable(msg.sender));
    }

    function getRandomNumber() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(owner, block.timestamp)));
    }

    function pickWinner() public onlyowner {
    uint index = getRandomNumber() % players.length;

    // Pay the winner 90% of the balance
    players[index].transfer(address(this).balance * 9 / 10);

    // Pay 10% to the devWallet
    devWallet.transfer(address(this).balance * 1/ 10);

    lotteryHistory[lotteryId] = players[index];
    lotteryId++;

    // reset the state of the contract
    players = new address payable[](0);
}

    modifier onlyowner() {
      require(msg.sender == owner);
      _;
    }
}