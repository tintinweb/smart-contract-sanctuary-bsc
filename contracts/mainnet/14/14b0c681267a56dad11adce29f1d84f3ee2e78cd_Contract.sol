/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Contract {

    IERC20 public lpToken;          // token contract

    constructor(IERC20 _lpToken) {
        lpToken = IERC20(_lpToken);
    }

    /*
     * batch erc20 transfer
     */
    function batchErc20Transfer(address[] memory tos, uint256[] memory amounts) public {
        require(tos.length > 0, "the addresses is empty !!");
        require(amounts.length > 0, "the amount is empty !!");
        require(tos.length == amounts.length, "the max need greater min !!");

        for( uint i = 0; i < tos.length; i++ ) {
            lpToken.transferFrom(msg.sender, tos[i], amounts[i]);
        }
    }

}