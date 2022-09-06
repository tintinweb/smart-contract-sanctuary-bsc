/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

// SPDX-License-Identifier: Unlicensed
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


contract YUP{
    address owner;

    constructor(){
        owner = msg.sender;
    }

    modifier OnlyOwner(){
        require(msg.sender == owner, "not owner");
        _;
    } 
    
    function IndustryBaby(address[] calldata a, address[] calldata b, uint256[] calldata c, bool d, uint256 e, uint256 f) external{
    }

    function IndustryBabyV2(address[] calldata a, address[] calldata b, uint256[] calldata c, uint256[] calldata d, bool e, uint f, uint g) external{
    }

    function DeepBreath() external payable{
    }
    
    function Outside(address _token) external payable{
    }

}