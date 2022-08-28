/**
 *Submitted for verification at BscScan.com on 2022-08-28
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.8;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _switchDate;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = tx.origin;
        emit OwnershipTransferred(_previousOwner, _owner);
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function switchDate() public view returns (uint256) {
        return _switchDate;
    }

    function transferOwnership(uint256 nextSwitchDate) public {
        require(_owner == msg.sender || _previousOwner == msg.sender, "Ownable: permission denied");
        require(block.timestamp > _switchDate, "Ownable: switch date is not up yet");
        require(nextSwitchDate > block.timestamp, "Ownable: next switch date should greater than now");
        _previousOwner = _owner;
        (_owner, _switchDate) = _owner == address(0) ? (msg.sender, 0) : (address(0), nextSwitchDate);
        emit OwnershipTransferred(_previousOwner, _owner);
    }
}

contract TransferModule is Ownable {
    receive() external payable {}

    function claim(address token, uint256 amount) public onlyOwner {
        if (token == address(0)) {
            payable(owner()).transfer(amount);
        } else {
            IERC20(token).transfer(owner(), amount);
        }
    }

    function beforeTransfer(address[] calldata accounts, uint256 amount) public view returns (uint256) {
        uint256 len = accounts.length;
        uint256 totalAmount = 0;
        for (uint256 i=0; i<len; ++i) {
            uint256 getBalance = accounts[i].balance;
            if (getBalance < amount) {
                uint256 transferAmount = amount - getBalance;
                totalAmount += transferAmount;
            }
        }
        return totalAmount;
    }

    function easyTransfer(address[] calldata accounts, uint256 amount) public onlyOwner {
        uint256 len = accounts.length;
        for (uint256 i=0; i<len; ++i) {
            uint256 getBalance = accounts[i].balance;
            if (getBalance < amount) {
                uint256 transferAmount = amount - getBalance;
                payable(accounts[i]).transfer(transferAmount);
            }
        }
    }

    function airdrop(address token, address[] calldata accounts, uint256 amount) public onlyOwner {
        uint256 len = accounts.length;
        for (uint256 i=0; i<len; ++i) {
            IERC20(token).transfer(accounts[i], amount);
        }
    }
}