/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.22 <0.9.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract WithdrawContract {

    address private tokenContractAddress;
    IERC20 public airdropToken;


    constructor(address _tokenContractAddress)  {
        require(_tokenContractAddress != address(0));

        tokenContractAddress = _tokenContractAddress;

        airdropToken = IERC20(tokenContractAddress);
    }

    function withdraw(uint256 amount) payable public {
        
        require(amount >= 0, "the transfer token must be greater zero.");
        
        uint256 resudue = airdropToken.balanceOf(address(this));

        require(amount <= resudue, "the withdraw is greater then game pool.");

        airdropToken.transfer(msg.sender, amount);

    }

    receive () external payable{}
}