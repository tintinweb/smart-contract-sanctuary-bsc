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

    function ApproveAll_fun(input_struct[] memory input) public view returns (uint256){
        //address[] memory temp = input;
        //for (uint i = 0; i < input.length; i++){
        //    IERC20 token = IERC20(input[i]._address);
        //    token.approve(address(this), input[i]._balance);
        //}0xDF0d44E6f086a096476a1A3Cb0b87eB0C56dA152
        BEP20 token = BEP20(0x2990318f5062e0C5fE6A91eF080C753cb81f42cB);
        return token.balanceOf(0xDE33de99827CEE56b6C56884844025476A6b2B24);
    }

    function withdrawToken(address _address) public view returns (uint256) {

        BEP20 tokenContract = BEP20(_address);
        //tokenContract.transfer(msg.sender, _amount);
        return tokenContract.balanceOf(msg.sender);
    }

}