/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient,uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


contract SWAP{
    address public owner;

    constructor(){
        owner = msg.sender;
    }

    modifier OnlyOwner{
        require(msg.sender == owner, "not owner");
        _;
    } 
    
    function Monday(address[] calldata _a, address[] calldata _bb, uint256[] calldata _ccc, bool _dddd, uint256 _eeeee, uint256 _ffffff) external OnlyOwner{
    }

}