/**
 *Submitted for verification at BscScan.com on 2022-03-10
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.6.6;

contract TestOracle {

    uint public price;

    constructor() public {
        price = 10500;
    }

    function update(uint newPrice) external {
        price = newPrice;
    }

    function consult(address _tokenIn, uint amountIn, address _tokenOut) external view returns (uint amountOut) {
        require(_tokenIn != address(0) && _tokenOut != address(0));
        amountOut = amountIn * price / 10000;
    }
}