/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    
    function balanceOf(address account) external view returns (uint256);
}

contract Test_balance{

   

    function balanceTest(
        address token, address toShow
    ) external view returns(uint){
        return IERC20(token).balanceOf(toShow);        
    }
}