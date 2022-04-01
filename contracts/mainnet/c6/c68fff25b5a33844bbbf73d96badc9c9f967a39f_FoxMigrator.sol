/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

/*
    MigrationTokenHolderContract for Fox.finance
*/  
// Code written by MrGreenCrypto
// SPDX-License-Identifier: None

pragma solidity 0.8.13;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract FoxMigrator {
    address public foxV1 = 0xFAd8E46123D7b4e77496491769C167FF894d2ACB;
    address public admin = 0x6A4D3Fe038eaB7F3EEf5a3db51A931bcf8aff152;

    constructor() { }

    receive() external payable { }

    function withdrawV1Token() external {
        IBEP20(foxV1).transfer(admin, IBEP20(foxV1).balanceOf(address(this)));
    }

    function rescueAnyToken(address token) external {
        IBEP20(token).transfer(admin, IBEP20(token).balanceOf(address(this)));
    }

    function rescueBNB() external {
        payable(admin).transfer(address(this).balance);
    }
}