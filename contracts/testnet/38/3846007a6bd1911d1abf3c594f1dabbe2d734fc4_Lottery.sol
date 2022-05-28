/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Lottery{

    address payable[] public players;
    address public manager;

    constructor(){
        manager = msg.sender;
    }

    receive() external payable{
        require(msg.value == 100000000000000000);
        players.push(payable(msg.sender));
    }

    function getBalance() public view returns(uint){
        require(msg.sender == manager);
        return address(this).balance;
    }

    function random() internal view returns(uint){
        require(msg.sender == manager);
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));


    }


    function pickWinner() public view returns(address){
        require(msg.sender == manager);
        require(players.length >= 5);

        uint r = random();
        address payable winner;

        uint index = r % players.length;
        winner = players[index];
        return winner;

    }
}