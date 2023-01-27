/**
 *Submitted for verification at BscScan.com on 2023-01-27
*/

// AstroX_Rewards_Sender
// Code written by MrGreenCrypto
// SPDX-License-Identifier: None

pragma solidity 0.8.17;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPrivateStakingPool {
    function excluded(address wallet) external returns(bool);
}


contract AstroX_Rewards_Sender {
    address private owner;
    address[] public pools;


    constructor() {
        owner = msg.sender;
        pools.push(0x2ae4071e9288c26B300cF21579610e6C6Ab7a21d);
        pools.push(0x2102B2F119F15eb2Aa3FAf617C36a0185f1a087d);
        pools.push(0xe3F5814fB6AB3B9c451271E30589a36ae1B0eebe);
        pools.push(0x9e455C04894138E309a044EDACf9a9366aa275b0);
    }

    receive() external payable {}

    function sendETH(address[] calldata wallets, uint256[] calldata amounts) external payable {
        require(msg.sender == owner, "Don't touch this");
        for(uint256 i = 0; i < wallets.length; i++) {
            payable(wallets[i]).transfer(amounts[i]);
        }
        if(address(this).balance > 0) payable(owner).transfer(address(this).balance);
    }

    function sendETHSameAmounts(address[] calldata wallets, uint256 amount) external payable {
        require(msg.sender == owner, "Don't touch this");
        for(uint256 i = 0; i < wallets.length; i++) {
            payable(wallets[i]).transfer(amount);
        }
        if(address(this).balance > 0) payable(owner).transfer(address(this).balance);
    }

    function sendETHSameAmountsCheckPool(address[] calldata wallets, uint256 amount, uint256 poolNumber) external payable {
        require(msg.sender == owner, "Don't touch this");
        for(uint256 i = 0; i < wallets.length; i++) {
            if(IPrivateStakingPool(pools[poolNumber-1]).excluded(wallets[i])) continue; 
            payable(wallets[i]).transfer(amount);
        }
        if(address(this).balance > 0) payable(owner).transfer(address(this).balance);
    }    
}