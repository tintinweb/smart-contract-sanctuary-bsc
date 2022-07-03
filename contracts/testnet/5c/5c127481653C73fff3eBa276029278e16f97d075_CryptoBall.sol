/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract CryptoBall {

    address contractOwner;

    mapping (address => uint) public balances;
    mapping (address => mapping(address => uint)) public allowance;
    mapping (address => Player) public players;
    mapping (uint => PrizePool) public prizePools;

    uint public prizePoolIndex = 1;
    uint public totalSupply = 10000000 * 10 ** 18;
    string public name = "Crypto Ball";
    string public symbol = "CTBL";
    uint public decimals = 18;


    struct PrizePool {
        Player[] playerList;
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

    function createPlayer(string memory playerName) public {
        require(bytes(players[msg.sender].playerName).length == 0, "You are already registered");
        players[msg.sender] = Player(msg.sender, playerName, 0, 0, false);
    }

    function getPlayerName() public view returns(string memory){
        return players[msg.sender].playerName;
    }

    function getPrizePool() public view returns(PrizePool memory){
        return prizePools[prizePoolIndex];
    }

    function beginAttempt() public payable {
        require(bytes(players[msg.sender].playerName).length != 0, "You must register before you can play");
        require(balanceOf(msg.sender) >= 250 * 10 ** 18, "balance too low");
        require(players[msg.sender].isActive != true, "You're already playing");
        prizePools[prizePoolIndex].totalPrize += 250 * 10 ** 18;
        
        transfer(contractOwner, 250 * 10 ** 18);
        players[msg.sender].isActive = true;
    }


    // TODO Players can currently add multiple scores if they score higher than a previous logged score
    function endAttempt(uint score) public {
        require(players[msg.sender].isActive == true, "You're not currently playing");

        // Player high score should be reset after payouts occurr so that they can be eligible for winning the following week
        if(players[msg.sender].highestScore < score) {
            players[msg.sender].highestScore = score;
            prizePools[prizePoolIndex].playerList.push(players[msg.sender]);

            uint n = prizePools[prizePoolIndex].playerList.length;
            uint i;
            uint j;
            Player memory temp;
            bool swapped;

            for(i = 0; i < n - 1; i++){
                swapped = false;
                for(j = 0; j < n-i-1; j++){
                    if(prizePools[prizePoolIndex].playerList[j].highestScore < prizePools[prizePoolIndex].playerList[j + 1].highestScore){
                        temp = prizePools[prizePoolIndex].playerList[j];
                        prizePools[prizePoolIndex].playerList[j] = prizePools[prizePoolIndex].playerList[j + 1];
                        prizePools[prizePoolIndex].playerList[j + 1] = temp;
                        swapped = true;
                    }
                }
                if(swapped == false){
                    break;
                }
            }
        }

        players[msg.sender].isActive = false;
    }

    function isPlayerActive() public view returns(bool){
        return players[msg.sender].isActive;
    }

    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }

    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, "balance too low");
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, "balance too low");
        require(allowance[from][msg.sender] >= value, "allowance too low");
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

    function payoutPlayers() public payable {
        require(msg.sender == contractOwner, "You are uneligible to call this function");

        uint n = prizePools[prizePoolIndex].playerList.length;
        uint winnerPoolSize = 10;

        for(uint i = 0; i < n; i++){
            if(i <= winnerPoolSize){
                 transfer(prizePools[prizePoolIndex].playerList[i].walletAddress, prizePools[prizePoolIndex].totalPrize / winnerPoolSize);
            }
            players[prizePools[prizePoolIndex].playerList[i].walletAddress].highestScore = 0;
        }

        prizePoolIndex = prizePoolIndex + 1;
    }
}