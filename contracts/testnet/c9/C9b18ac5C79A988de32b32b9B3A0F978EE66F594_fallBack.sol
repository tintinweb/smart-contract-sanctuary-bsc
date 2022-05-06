/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract storageContract {
    uint256 public decimal;
    address public fallbackContract;

    constructor () {
        decimal = 18;
    }

    function setDecimal(uint256 newD) public {
        decimal = newD;
    }

    function setFallback(address newContract) public {
        fallbackContract = newContract;
    }
}

contract fallBack {
    uint256 public number;
    mapping(address => uint256) public store; 


    fallback() external payable {
        callBack();
    }

    function callBack() internal {
        store[msg.sender] += 1;
        number++;
    }

    receive() external payable {
        callBack();
    }
}