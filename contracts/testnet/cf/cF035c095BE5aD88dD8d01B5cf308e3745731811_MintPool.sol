/**
 *Submitted for verification at BscScan.com on 2022-06-30
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


contract MintPool {
 
    IERC20 busd;
    IERC20 native;

    constructor () {
        busd = IERC20(0xB31e26356521296064E792618628cA1C834B7882);
        native = IERC20(0x18030F7E54ABA310bB31856AF6fe48f7bE1e9aF0);
        
    }
    function BuyNative(uint256 Amount)  external  {
    require(busd.balanceOf(msg.sender) >= Amount * 10**busd.decimals());
    require(native.balanceOf(address(this)) >= Amount * 10**native.decimals());
 
    busd.transferFrom(msg.sender, address(this), Amount  * 10**busd.decimals());
    native.transfer(msg.sender, Amount * 10**native.decimals());
    }  
    
    function SellNative(uint256 Amount) external {
    require(native.balanceOf(msg.sender) >= Amount * 10**native.decimals());
    require(busd.balanceOf(address(this)) >= Amount * 10**native.decimals());

    native.transferFrom(msg.sender, address(this), Amount * 10**native.decimals());
    busd.transfer(msg.sender, Amount * 10**busd.decimals());


  }
}