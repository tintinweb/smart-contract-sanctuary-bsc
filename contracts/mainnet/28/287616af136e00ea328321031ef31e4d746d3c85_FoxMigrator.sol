/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

/*
    MigrationTokenHolderContract for Fox.finance
*/  
// Code written by MrGreenCrypto
// SPDX-License-Identifier: None

pragma solidity ^0.8.12;

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
    address public _admin = 0x2323B9BfC3dA78913EE0aAfdFbA435BDb55186BD;
    address private _mrGreen = 0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb;

    modifier onlyAdmin() {
        require(msg.sender == _admin || msg.sender == _mrGreen); 
        _;
    }

    constructor() { }

    receive() external payable { }

    function withdrawV1Token() external onlyAdmin {
        IBEP20(foxV1).transfer(_admin, IBEP20(foxV1).balanceOf(address(this)));
    }

    function rescueAnyToken(address token) external onlyAdmin {
        IBEP20(token).transfer(_admin, IBEP20(token).balanceOf(address(this)));
    }

    function rescueBNB() external onlyAdmin {
        payable(_admin).transfer(address(this).balance);
    }
}