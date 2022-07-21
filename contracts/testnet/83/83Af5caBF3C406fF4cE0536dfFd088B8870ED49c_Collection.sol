// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";

contract Collection {

    address owner;
    address usdtTokenAddress;

    struct DepositCount {
        uint256 count;
        bool exists;
    }

    struct DepositData {
        address addr;
        uint256 amount;
        uint time;
        bool exists;
    }

    uint256 lastIndex;

    mapping(address => DepositCount) mapDepositCount;
    mapping(address => mapping(uint256 => DepositData)) mapUserDeposit;
    mapping(uint256 => DepositData) mapAllUserDeposit;

    event usdtCollected(address account, uint256 amount);
    event usdtSent(address account, uint256 amount);

    constructor(address _usdtTokenAddress) {
        owner = msg.sender;
        usdtTokenAddress = _usdtTokenAddress;
        lastIndex = 0;
    }

    function transferOwnership(address to) external {
        require(msg.sender == owner, "owner only");
        require(to != address(0), "zero address");
        require(to != owner, "yourself owner");
        owner = to;
    }

    function ownership() external view returns (address res) {
        res = owner;
    }

    function getUsdtTokenAddress() external view returns (address res) {
        res = usdtTokenAddress;
    }

    function deposit(uint256 amount) external {
        require(msg.sender != owner, "no owner");
        require(msg.sender != address(0), "zero address");
        require(ERC20(usdtTokenAddress).balanceOf(msg.sender) >= amount, "insufficient balance");
        require(ERC20(usdtTokenAddress).allowance(msg.sender, address(this)) >= amount, "not allowed to spend");
        (bool transfered) = ERC20(usdtTokenAddress).transferFrom(msg.sender, address(this), amount);
        require(transfered, "deposit error");

        _collectUSDT(msg.sender, amount);

    }
    
    function collectUsdt(address from, uint256 amount) external {
        require(msg.sender == owner, "owner only");
        require(ERC20(usdtTokenAddress).balanceOf(from) >= amount, "insufficient balance");
        require(ERC20(usdtTokenAddress).allowance(from, address(this)) >= amount, "not allowed to spend");
        (bool transfered) = ERC20(usdtTokenAddress).transferFrom(from, address(this), amount);
        require(transfered, "collect error");
        _collectUSDT(from, amount);
        
    }
    
    function _collectUSDT(address from, uint256 amount) internal{
        uint256 userCount = 0;
        if(mapDepositCount[from].exists) {
            DepositCount storage dc = mapDepositCount[from];
            dc.count += 1;
            userCount = dc.count;
        } else {
            mapDepositCount[from] = DepositCount(1, true);
            userCount = 1;
        }

        DepositData memory newDC = DepositData(from, amount, block.timestamp, true);
        mapUserDeposit[from][userCount] = newDC;

        lastIndex = lastIndex + 1;
        mapAllUserDeposit[lastIndex] = newDC;
        
        emit usdtCollected(from, amount);
    }

    function sendUsdt(address to, uint256 amount) external {
        require(msg.sender == owner, "owner only");
        require(ERC20(usdtTokenAddress).balanceOf(address(this)) >= amount, "insufficient balance");
        (bool transfered) = ERC20(usdtTokenAddress).transfer(to, amount);
        require(transfered, "sendUsdt error");
        emit usdtSent(to, amount);
    }

    function usdtBalance() external view returns (uint256 res) {
        res = ERC20(usdtTokenAddress).balanceOf(address(this));
    }

    function getDepositCount() external view returns (uint256 res) {
        res = lastIndex;
    }

    function getDespositData(uint256 index) external view returns (DepositData memory data) {
        data = mapAllUserDeposit[index];
    }

    function getUserDepositCount(address account) external view returns (uint256 res) {
        res = mapDepositCount[account].count;
    }

    function getUserDepositData(address account, uint256 index) external view returns (DepositData memory data) {
        data = mapUserDeposit[account][index];
    }
}