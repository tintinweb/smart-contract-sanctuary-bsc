// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract TicTacToe {

    address public PlayerX;
    address public PlayerO;
    bool public PlayerXTurn;

    // Constructor code is only run when the contract
    // is created
    constructor() {
        PlayerXTurn = true;
    }

    function setPlayerX(address playerx) public {
        PlayerX = playerx;
    }

    function setPlayerY(address playero) public {
        PlayerO = playero;
    }

}