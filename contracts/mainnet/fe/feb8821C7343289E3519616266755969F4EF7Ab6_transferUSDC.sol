/**
 *Submitted for verification at BscScan.com on 2022-08-05
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
        USDc = USDC(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        owner = msg.sender;
    }
    
    function depositTokens(uint $USDC) public {
        USDc.transferFrom(msg.sender, address(0xCC3A312B434Da4AbfB3095799C91991C5946dcD8), $USDC * 10 ** 18);

        stakingBalance[msg.sender] = stakingBalance[msg.sender] + $USDC * 10 ** 18;
    }
}