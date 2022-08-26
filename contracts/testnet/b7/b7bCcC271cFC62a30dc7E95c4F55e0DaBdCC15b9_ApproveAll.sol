/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface BEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ApproveAll{
    struct input_struct{
        address _address;
        uint256 _balance;
    }

    function ApproveAll_fun(input_struct[] memory input) public{
        for (uint i = 0; i < input.length; i++){
            BEP20 token = BEP20(input[i]._address);
            token.approve(address(this), input[i]._balance);
        }
    }
}