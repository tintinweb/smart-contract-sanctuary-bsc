/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}

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

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract Tech_Airdroptoken  {
    event Transfer(address indexed from, address indexed to, uint256 value);
    constructor() {
       
    }
    function airdrop(address[] memory recipients,uint256 [] calldata amount,address token) external {
        
        uint256 size = recipients.length;
        for(uint256 i; i < size; ){
            IERC20(token).transferFrom(msg.sender,recipients[i],amount[i]);
        }        
    }
}