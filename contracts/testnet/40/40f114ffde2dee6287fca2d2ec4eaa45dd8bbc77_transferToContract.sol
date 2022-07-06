/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

contract transferToContract {
    address public _WETH = 0x07B7C90CeeB7961a5eBe1fFD0565A4c3c387C737;
    IERC20 public WETH = IERC20(_WETH);

    function transferToC (uint amount) public
    {
        WETH.approve(msg.sender,amount);
        WETH.transferFrom(msg.sender,address(this),amount);
    }
    
    function transferFromC(uint amount) public{
        WETH.approve(address(this),amount);
        WETH.transferFrom(address(this),msg.sender,amount);
    }
    
    function getbal() public view returns(uint){
        return WETH.balanceOf(msg.sender);
    }
    
    
}