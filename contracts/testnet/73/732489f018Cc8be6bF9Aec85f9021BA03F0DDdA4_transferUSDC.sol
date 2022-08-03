/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface USDC {

    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed from, address indexed to, uint256 value);

}

contract transferUSDC {
    USDC public USDc;
    address owner;
    mapping(address => uint) public stakingBalance;

    constructor() public {
        USDc = USDC(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
        owner = msg.sender;
    }
    function depositTokens(uint $USDC) public {

        // amount should be > 0

        // transfer USDC to this contract
        USDc.transferFrom(msg.sender, address(this), $USDC * 10 ** 6);
        
        // update staking balance
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + $USDC * 10 ** 6;
    }
}