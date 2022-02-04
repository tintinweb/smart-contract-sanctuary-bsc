/**
 *Submitted for verification at BscScan.com on 2022-02-03
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Lottery {

    address payable[] public players;
    address payable public admin;
    address payable public winner;
    uint256 public totalPrize;

    constructor(){
        admin = payable(msg.sender);
    }

    receive() external payable {
    }

    event BuyTicket(address indexed addr);
    event Winner(address indexed addr,uint256 amount);

    function buyTicket() public payable returns(string memory) {
        require(msg.value == 10**16, "Ticket price is 0.1 ETH!");
        require(msg.sender != admin, "The admin cannot participate");
        admin.transfer(msg.value*1/10);
        players.push(payable(msg.sender));
        return("Bought the ticket");
    }

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    function getPlayerNumber() public view returns(uint){
        return players.length;
    }


    function getPlayers() public view returns(address payable[] memory){
        return players;
    }

    function random() internal view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    function pickWinner() public {
        require(msg.sender == admin, "You do not have access!");
        require(players.length >= 3, "Not enough players!");
        uint X;
        X = random() % players.length;
        winner = players[X];
        totalPrize = address(this).balance;
        emit Winner(winner,totalPrize);
        winner.transfer(getBalance());
        players = new address payable[](0);
    }

}