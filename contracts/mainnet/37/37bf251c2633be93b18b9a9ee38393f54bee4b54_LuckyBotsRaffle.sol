/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

// SPDX-License-Identifier: MIT
// DEV: SUB_ZERO
// TELEGRAM: https://t.me/Lucky_Portal

pragma solidity ^0.8.18;

contract LuckyBotsRaffle {
    address public Owner;
    address payable[] public players;
    address payable devWallet;
    address payable lucky;
    address payable lp;
    uint public lotteryId;
    uint256 public poolBalance;
    mapping (uint => address payable) public lotteryHistory;
    uint public ticketCount = 0;
    uint public randomRange;

    constructor() {
        Owner = msg.sender;
        lotteryId = 1;
    }
        modifier onlyOwner() {
        _;
    }

        // Function to add ether to the pool balance
    function addToPool() public payable onlyOwner {
        require(msg.value > 0, "Value must be greater than 0");
        poolBalance += msg.value;
    }

    function getWinnerByLottery(uint lottery) public view returns (address payable) {
        return lotteryHistory[lottery];
    }

    function setLuckyWallet(address payable _lucky) public onlyOwner {
        require(msg.sender == Owner, "Only owner can set Wallet address");
        lucky = _lucky;
    }

    function setLPWallet(address payable _LP) public onlyOwner {
        require(msg.sender == Owner, "Only owner can set Wallet address");
        lp = _LP;
    }

    function setDevWallet(address payable _devWallet) public onlyOwner {
        require(msg.sender == Owner, "Only owner can set Wallet address");
        devWallet = _devWallet;
    }

    // Get balance of pool
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    // Get Player list
    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    // Get number of tickets purchased
    function getTickets() public view returns (uint) {
        return ticketCount;
    }

    // Set required balance to be less than 1.25 BNB
    function enter() public payable {
        require(msg.value == 0.05 ether);

        // address of player entering lottery
        players.push(payable(msg.sender));
        ticketCount++;
    }

    function getRandomNumber() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(Owner, block.timestamp)));
    }

    function payWinner() public onlyOwner {
        uint index = getRandomNumber() % players.length;
        // Pay the winner 8/10 BNB of the balance
    players[index].transfer(address(this).balance * 8 / 10);

        // Pay 4/10 BNB to the devWallet
    devWallet.transfer(address(this).balance * 4 / 10);

        // Pay 2/3 BNB to LP
     lp.transfer(address(this).balance * 2 / 3);

        // Pay 10/10 BNB to lucky owner
    lucky.transfer(address(this).balance * 10 / 10);

  lotteryHistory[lotteryId] = players[index];
  lotteryId++;

  // reset the state of the contract
  players = new address payable[](0);
}

}