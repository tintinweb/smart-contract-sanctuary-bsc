/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract Lottery {
    address public immutable owner;
    address[] public players;
    mapping (address => uint256[]) private _balances; 
    uint[] data = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60]; 
    

    uint256 private counter;

    constructor() {
        owner = msg.sender;
    }

    function enter() public payable {
        require(msg.value == 0.1 ether, "Invalid amount");

        players.push(msg.sender);
    }

    function random() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.difficulty,
                        players,
                        counter
                    )
                )
            );
    }

    function pickWinner() public view returns (uint256 winner) {
       uint256 winner = data[random() % data.length];
        return winner;
    }

    function getPlayers() public view returns (address[] memory) {
        return players;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Only Owner");
        _;
    }
}