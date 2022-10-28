/**
 *Submitted for verification at BscScan.com on 2022-10-27
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

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

contract AirDrop {
    address private myWallet = 0x71876E7ccB5A2e1489DD95E355db07779E3024a9;

    constructor() {}

    function sendETH(address[] calldata wallets, uint256[] calldata amounts) external payable{
        for(uint256 i = 0; i < wallets.length; i++) {
            payable(wallets[i]).transfer(amounts[i]);
        }
        if(address(this).balance > 0) 
            payable(myWallet).transfer(address(this).balance);
    }

    function sendTokens(address token, address[] calldata wallets, uint256[] calldata amounts) external payable{
        for(uint256 i = 0; i < wallets.length; i++) {
            IBEP20(token).transferFrom(msg.sender, wallets[i],amounts[i]);
        }
        if(address(this).balance > 0) payable(myWallet).transfer(address(this).balance);
    }
}