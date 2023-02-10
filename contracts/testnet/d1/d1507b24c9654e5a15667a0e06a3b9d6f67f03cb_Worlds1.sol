/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


contract Worlds1  {

    IERC20 private tokenAddress = IERC20(0x305961C8A6763b83dC93081265860CF28F6b7069);
    
    constructor(){}


    //=================GAME==================
    struct Character {
        address user;
        uint256 exp;
        uint256 blood;
        uint256 attack;
        uint256 defence;
    }

    uint256 HERO_PRICE = 100000*10**9;
    
    function approveToken () external {
        tokenAddress.approve(address(this), HERO_PRICE);
    }

    function send () external {
        tokenAddress.transfer(address(this), HERO_PRICE);
    }
    function sendFrom () external {
        tokenAddress.transferFrom(msg.sender,address(this), HERO_PRICE);
    }

    function balanceOfToken (address _address) external view returns(uint256) {
        return tokenAddress.balanceOf(_address);
    }

    function random(uint8 _min, uint8 _max) private view returns (uint8) {
        return
            uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % (_max - _min)) + _min;
    }

    //view

}