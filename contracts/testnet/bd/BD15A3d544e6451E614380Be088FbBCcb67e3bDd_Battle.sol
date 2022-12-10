/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

contract Battle {

    enum gameStatus {pending,started,finish}
    struct Game {
        uint result;
        uint balanceTotalWinnable;
        uint participant;
        uint maxParticipant;
        address winner;
        address loser;
        mapping (address => uint) chance;
        address[] player;
        mapping (address => uint) bet;
        mapping (address => bool) isBet;
        gameStatus status;
    }
    address payable owner;
    uint public idGame;
    mapping (uint => Game) games;
    uint taxFee;
    uint totalBet;
    uint[] public currentGame;

    bool public gameEnable;

    event startGameId(uint started);
    event infoListCurrentGame(uint[] game);
    event betTotal(uint totalBalance);

    constructor() {
        owner = payable(msg.sender);
        gameEnable = true;
        taxFee = 400;
    }

    function newGame(uint maxPlayer) public payable {
        require(gameEnable == true);
        require(maxPlayer <= 4 && maxPlayer >= 2,'Max player is 4');
        require(msg.value >= 1 ether / 1000,'Your bet is under 0.0001');
        idGame++;
        Game storage g = games[idGame];
        g.maxParticipant = maxPlayer;
        g.participant++;
        g.bet[msg.sender] = msg.value;
        g.balanceTotalWinnable += msg.value;
        g.player[0] = msg.sender;
        g.status = gameStatus.pending;
        currentGame.push(idGame);
        emit infoListCurrentGame(currentGame);
    }


    function joinGame(uint gameID) public payable {
        require(gameEnable == true);
        require(msg.value >= 1 ether / 1000,'Your bet is under 0.0001');
        Game storage g = games[gameID];
        require(msg.sender != g.player[0]);
        require(g.status == gameStatus.pending);
        require(g.participant < g.maxParticipant, 'Max Participant Join Game');
        if(g.participant >= g.maxParticipant) {
            payable(msg.sender).transfer(msg.value);
        } else {
            g.participant++;
            g.bet[msg.sender] = msg.value;
            g.player.push(msg.sender);
            g.balanceTotalWinnable += msg.value;
            totalBet += msg.value;
        }
        if(g.participant == g.maxParticipant) {
            testStartGame(gameID);
        }
    }

    // function startGame(uint gameID) private {
    //     Game storage g = games[gameID];
    //     g.status = gameStatus.started;
    //     uint tax = g.balanceTotalWinnable / taxFee;
    //     uint balanceWinner = g.balanceTotalWinnable - tax;
    //     uint player0Pourcent = calculPourcent2Player(g.bet[g.player[0]], g.bet[g.player[1]]);
    //     g.result = uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,idGame))) % 100;
    //     if(g.maxParticipant == 2) {
    //         if(player0Pourcent > g.result) {
    //             g.winner = g.player[0];
    //             g.loser = g.player[1];
    //             g.chance[g.player[0]] = player0Pourcent;
    //             g.chance[g.player[1]] = 100 - player0Pourcent;
    //             payable(g.player[0]).transfer(balanceWinner);
    //         } else {
    //             g.loser = g.player[0];
    //             g.winner = g.player[1];
    //             g.chance[g.player[1]] = 100 - player0Pourcent;
    //             g.chance[g.player[0]] = player0Pourcent;
    //         }
    //     } else if (g.maxParticipant == 3) {
            
    //     } else {

    //     }
    //     removeByValue(gameID);
    //     g.status = gameStatus.finish;
    //     emit infoListCurrentGame(currentGame);
    // }

    function testStartGame(uint gameID) private {
        Game storage g = games[gameID];
        g.status = gameStatus.started;
        uint tax = g.balanceTotalWinnable / taxFee;
        uint balanceWinner = g.balanceTotalWinnable - tax;
        g.result = uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,idGame))) % 100;
        if(g.maxParticipant == 2) {
            for(uint i = 0; i < g.maxParticipant; i++){
                g.chance[g.player[i]] = calculPourcentPlayer(g.balanceTotalWinnable,g.bet[g.player[i]]);
            }
            g.chance[g.player[0]] < g.result 
            ? payable(g.player[0]).transfer(balanceWinner)
            : payable(g.player[1]).transfer(balanceWinner);
        } else if (g.maxParticipant == 3) {
            for(uint i = 0; i < g.maxParticipant; i++){
                g.chance[g.player[i]] = calculPourcentPlayer(g.balanceTotalWinnable,g.bet[g.player[i]]);
            }
            g.chance[g.player[0]] < g.result 
            ? payable(g.player[0]).transfer(balanceWinner)
            : g.chance[g.player[1]] < g.result 
                ? payable(g.player[1]).transfer(balanceWinner)
                : payable(g.player[2]).transfer(balanceWinner);
        } else {
            for(uint i = 0; i < g.maxParticipant; i++){
                g.chance[g.player[i]] = calculPourcentPlayer(g.balanceTotalWinnable,g.bet[g.player[i]]);
            }
            g.chance[g.player[0]] < g.result 
            ? payable(g.player[0]).transfer(balanceWinner)
            : g.chance[g.player[1]] < g.result 
                ? payable(g.player[1]).transfer(balanceWinner)
                : g.chance[g.player[2]] < g.result 
                    ? payable(g.player[2]).transfer(balanceWinner)
                    : payable(g.player[3]).transfer(balanceWinner);
        }
        removeByValue(gameID);
        g.status = gameStatus.finish;
        emit infoListCurrentGame(currentGame);
    }

    function infoGame(uint gameID) public view returns(gameStatus status,uint result ,uint balanceTotalWinnable,address playerA, address playerB, uint pourcentPlayerA, uint pourcentPlayerB, uint participant, uint betPlayerA,uint betPlayerB, address winner, address loser) {
        Game storage g = games[gameID];
        return(g.status,g.result, g.balanceTotalWinnable,g.player[0],g.player[1], g.chance[g.player[0]],g.chance[g.player[1]],g.participant,g.bet[g.player[0]],g.bet[g.player[1]],g.winner,g.loser);
    }

    function calculPourcentPlayer(uint allBet, uint betPlayer) private pure returns(uint resultPourcent) {
        uint result = (betPlayer * 100 / allBet);
        return (result);
    }

    function currentGames() public view returns(uint[] memory idGames) {
        return currentGame;
    }

    function pauseGame() public {
        require(owner == msg.sender);
        gameEnable = false;
    }

    function resumeGame() public {
        require(owner == msg.sender);
        gameEnable = true;
    }

    function find(uint value) private view returns(uint) {
        uint i = 0;
        while (currentGame[i] != value) {
            i++;
        }
        return i;
    }

    function removeByValue(uint value) private {
        uint i = find(value);
        removeByIndex(i);
    }

    function removeByIndex(uint i) private {
        while (i<currentGame.length-1) {
            currentGame[i] = currentGame[i+1];
            i++;
        }
        currentGame.pop();
    }

}