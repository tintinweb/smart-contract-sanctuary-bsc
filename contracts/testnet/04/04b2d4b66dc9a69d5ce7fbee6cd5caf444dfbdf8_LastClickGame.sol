/**
 *Submitted for verification at BscScan.com on 2022-06-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract LastClickGame {
    address public owner;
    Game[] public games;
    mapping(address => uint) public winners;
    uint public bid;
    uint public totalGames;
    bool public isActive;
    uint constant duration = 3;

    constructor() {
        owner = msg.sender;
    }

    struct Game {
        address _address;
        uint prize;
        uint timestamp;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "ETO ONLY FOR OWNER PRIDUROK");
        _;
    }

    function changeOwner(address addr) public onlyOwner {
        owner = addr;
    }

    function startGame(uint _bid) public onlyOwner {
        require(isActive == false, "the game has already started");
        bid = _bid;
        isActive = true;
        games.push();
        totalGames++;
        games[totalGames-1].timestamp = block.number + 100;
    }

    modifier onlyWhenActiveGame() {
        require(isActive == true, "Game hasn't started yet");
        _;
    }

    function click() public payable onlyWhenActiveGame {
        if (block.number < games[totalGames-1].timestamp + duration) {
            require(msg.value == bid, "Incorrect amount!");
            games[totalGames-1].prize += msg.value;
            games[totalGames-1].timestamp = block.number;
            games[totalGames-1]._address = msg.sender;
        } else {
            winners[games[totalGames-1]._address] = games[totalGames-1].prize;
            isActive = false;
            winners[msg.sender] += msg.value;
        }
    }

    function getLastParticipant() public view returns(address) {
        if (totalGames == 0) {
            return address(0);
        }
        return games[totalGames-1]._address;
    }

    function claim() public {
        uint amount = winners[msg.sender];
        require(amount > 0, "You haven't any prize");
        winners[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function withdrawAll() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}