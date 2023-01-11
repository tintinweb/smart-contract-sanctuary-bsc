/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

pragma solidity ^0.5.16;


contract TestX {
    uint number = 5;
}



contract Test is TestX {

    address admin;

    constructor() public {
        admin = msg.sender;

    }

    function mint() public {

    }

    function swap(uint amountIn,uint amountOutMin) public {

    }

    function swapETHForExactTokens(uint amountOutMin) public {

    }

    function swapExactTokensForTokens(uint amountIn,uint amountOutMin,address[] memory path,address to,uint deadline) public {

    }

    function swapExactTokensForTokens(uint amountIn,uint amountOutMin) public {
    }


    
}