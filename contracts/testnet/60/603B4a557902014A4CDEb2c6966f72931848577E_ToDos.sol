/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ToDos {
    string[] public todos;
    uint numberofTodos;

    function getNum() public view returns (uint256) {
        return numberofTodos;
    }
    
    constructor() {
        numberofTodos = 0;
      
    }

    function getTodos() public view returns (string[] memory) {

        return todos;
    }

    function pushToTodos(string memory newValue) public {
        todos.push(newValue);
        numberofTodos++;
    }

    function remfromTodos(uint256 index) public {
        todos[index] = todos[todos.length-1];
        todos.pop;
    }



}