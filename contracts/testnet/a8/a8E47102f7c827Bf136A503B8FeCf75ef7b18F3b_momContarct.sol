//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract lockContract {
    
    function calim() view public returns(bool) {
        return true;
    }
}

contract momContarct {
    function creatlockContarc() public {
        new lockContract();
    }
}