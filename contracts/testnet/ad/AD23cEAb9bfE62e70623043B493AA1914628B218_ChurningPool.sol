/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

// SPDX-License-Identifier: UNLISCENSED

pragma solidity ^0.8.4;

interface IERC20 {

    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


}


contract ChurningPool {
 
    IERC20 native;

    constructor () {
        native = IERC20(0x6AF052DF2ed0f483F5312d3df6CDCF8941E9f3a5);
        
    }

    function churn(uint256 Amount) external {
    require(native.balanceOf(address(this)) >= Amount * 10**native.decimals());
    
    native.transfer(address(this), Amount  * 10**native.decimals());

    }


}