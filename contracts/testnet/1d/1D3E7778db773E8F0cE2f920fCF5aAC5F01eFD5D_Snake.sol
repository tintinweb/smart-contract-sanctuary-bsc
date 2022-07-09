/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;


contract Snake {
    
    uint ID = 0; // PRIMARY KEY
    struct Player {
        uint id;
        address playersAddress;
        uint score;
    }

    Player[] players;

    function addPlayer(uint _score) public   {
        Player memory player = Player({
            id:ID,
            playersAddress: msg.sender,
            score:_score
        });
        players.push(player);
        ID++;

    }

    function getAllPlayers() public view returns(Player[] memory) {
        return players;
    }

    function updatePlayerScore(uint _id,uint _score) public {
        Player memory p = players[_id];
        require(p.playersAddress==msg.sender,"You can update your score only");
        players[_id].score = _score;
    } 

    function getCurrentTime() public view returns(uint){
        return block.timestamp + 24 hours ; // seconds, minutes, hours, days, years
    }
     
}