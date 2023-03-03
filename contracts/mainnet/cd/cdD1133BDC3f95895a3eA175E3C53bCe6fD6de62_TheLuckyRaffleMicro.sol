/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// SPDX-License-Identifier: MIT
// DEV: SUB_ZERO
// TELEGRAM: https://t.me/Lucky_Portal

pragma solidity ^0.8.18;

contract TheLuckyRaffleMicro {
    address public Owner;
    address payable[] public players;
    address payable public devWallet;
    address payable public lp;
    uint public lotteryId;
    mapping (uint => address payable) public lotteryHistory;
    uint public ticketCount = 0;

    constructor() {
        Owner = msg.sender;
        lotteryId = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == Owner, "Only the Owner can perform this action");
        _;
    }

    function setLPWallet(address payable _LP) public onlyOwner {
        require(msg.sender == Owner, "Only owner can set Wallet address");
        lp = _LP;
    }

    function setDevWallet(address payable _devWallet) public onlyOwner {
        require(msg.sender == Owner, "Only owner can set Wallet address");
        devWallet = _devWallet;
    }

    function getWinnerByLottery(uint lottery) public view returns (address payable) {
        return lotteryHistory[lottery];
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    function getTickets() public view returns (uint) {
        return ticketCount;
    }

    //used only in the event of an attack where all tickets are contracts.
    function resetPlayers() public onlyOwner {
    players = new address payable[](0);
    ticketCount = 0;
    }

    function enter() public payable {
        require(msg.value == 0.02 ether, "The entry fee must be 0.02 ether");

        players.push(payable(msg.sender));
        ticketCount++;
    }

    function getRandomNumber() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender)));
    }

    function isContract(address addr) public view returns (bool) {
    uint size;
    assembly { size := extcodesize(addr) }
    return size > 0;
}

function payWinner() public onlyOwner {
    require(players.length >= 10, "Not enough players have entered the lottery yet");

    bool hasNonContractPlayer = false;
    for (uint i = 0; i < players.length; i++) {
        if (!isContract(players[i])) {
            hasNonContractPlayer = true;
            break;
        }
    }

    require(hasNonContractPlayer, "All players are contracts and cannot be selected as the winner");

    uint highestRandomNumber = 0;
    uint winningIndex = 0;
    for (uint i = 0; i < players.length; i++) {
        uint randomNumber = getRandomNumber();
        if (randomNumber > highestRandomNumber && !isContract(players[i])) {
            highestRandomNumber = randomNumber;
            winningIndex = i;
        }
    }

    address payable winner = players[winningIndex];

    winner.transfer(address(this).balance * 8 / 10);
    devWallet.transfer(address(this).balance * 4 / 10);
    lp.transfer(address(this).balance * 10 / 10);

    lotteryHistory[lotteryId] = winner;
    lotteryId++;

    players = new address payable[](0);
    ticketCount = 0;
}
}