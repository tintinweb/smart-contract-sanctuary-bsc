/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract NewToken {

    address contractOwner;

    mapping (address => uint) public balances;
    mapping (address => mapping(address => uint)) public allowance;
    mapping (address => Player) public players;
    mapping (uint => PrizePool) public prizePools;

    uint public prizePoolIndex = 1;
    uint public totalSupply = 10000 * 10 ** 18;
    string public name = "New Token";
    string public symbol = "NTKN";
    uint public decimals = 18;


    struct PrizePool {
        mapping (address => Player) playerList;
        uint totalPrize;
    }

    struct Player {
        address walletAddress;
        string playerName;
        uint balance;
        uint highestScore;
        bool isActive;
    }

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor() {
        balances[msg.sender] = totalSupply;
        contractOwner = msg.sender;
    }

    function beginAttempt() public {
        require(players[msg.sender].balance >= 250, "balance too low");
        require(players[msg.sender].isActive != true, "You're already playing");
        prizePools[prizePoolIndex].totalPrize += 250;
        prizePools[prizePoolIndex].playerList[msg.sender] = players[msg.sender];
        transfer(contractOwner, 250);
        players[msg.sender].isActive = true;
    }

    function endAttempt(uint score) public {
        require(players[msg.sender].isActive == false, "You're not currently playing");

        if(players[msg.sender].highestScore < score) {
            players[msg.sender].highestScore = score;
        }
        
        players[msg.sender].isActive = false;
    }

    function isPlayerActive() public view returns(bool){
        return players[msg.sender].isActive;
    }

    function getPlayerName() public view returns(string memory){
        return players[msg.sender].playerName;
    }

    function createPlayer(string memory playerName) public {
        players[msg.sender] = Player(msg.sender, playerName, 0, 0, false);
    }

    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }

    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint value) public returns(bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
}