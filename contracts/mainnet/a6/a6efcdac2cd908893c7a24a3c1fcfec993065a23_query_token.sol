/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;


interface IERC20 {
    function decimals() external view returns (uint8);
}

//专门用来查代币精度的小合约
contract query_token{
    function queryDecimals(address token0 , address token1)external view returns(uint8 , uint8){
        uint8 token0Decimals = IERC20(token0).decimals();
        uint8 token1Decimals = IERC20(token1).decimals();
        return  (token0Decimals , token1Decimals);
    }
}