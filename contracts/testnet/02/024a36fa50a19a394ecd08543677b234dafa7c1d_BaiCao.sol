/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract BaiCao {
    
    address payable private owner;
    uint public gameId;
    
    struct Player {
        uint played;
        uint cWin;
    }
    mapping (address => Player) public players;
    
    struct Game {
        address[] listPlayer;
        mapping (address => bool) player;
        uint totalBet;
        bool endGame;
    }
    mapping (uint => Game) public games;
    
    
    constructor() {
        owner = payable(msg.sender);
        gameId = 0;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function newGame() public onlyOwner {
        gameId++;
    }
    
    modifier ruleBet() {
        require(msg.value == 1 ether);
        _;
    }
    
    function playGame() public payable ruleBet {
        require(!games[gameId].endGame);
        require(!games[gameId].player[msg.sender]);
        games[gameId].listPlayer.push(msg.sender);
        games[gameId].totalBet = games[gameId].totalBet + msg.value;
        games[gameId].player[msg.sender] = true;
        players[msg.sender].played = players[msg.sender].played++;
    }
    
    function xoSo() public onlyOwner {
        require(!games[gameId].endGame);
        uint cPlayerInGame = games[gameId].listPlayer.length;
        uint biggest = 0;
        address winner;
        for (uint i = 0; i < cPlayerInGame; i++) {
            uint rand = getRandom(gameId);
            if(rand > biggest) {
                biggest = rand;
                winner = games[gameId].listPlayer[i];
            }
        }
        players[winner].cWin = players[winner].cWin++;
        payable(winner).transfer(games[gameId].totalBet);
        games[gameId].endGame = true;
        newGame();
    }
    
    function getRandom(uint256 seed) private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp +
                            block.difficulty +
                            uint256(
                                keccak256(abi.encodePacked(block.coinbase))
                            ) +
                            seed
                    )
                )
            ) % 10000;
    }
    
    
}