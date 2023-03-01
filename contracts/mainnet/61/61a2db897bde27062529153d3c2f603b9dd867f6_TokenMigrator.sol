/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBEP20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract TokenMigrator {
    address public oldTokenAddress;
    address public newTokenAddress;
    address public owner;
    bool public migrationFinished;

    mapping (address => bool) public isFeeExempt;

    event TokensMigrated(address indexed user, uint256 amount);

    constructor(address _oldTokenAddress, address _newTokenAddress) {
        oldTokenAddress = address(0x893535ED1b5C6969E62a10bABfED4F5fF8373278);
        newTokenAddress = address(0xf6A342881756c924aBcb6E8340813e4068a9181F);
        _oldTokenAddress = oldTokenAddress;
        _newTokenAddress = newTokenAddress;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    function setIsFeeExempt(address _user, bool _isFeeExempt) external onlyOwner {
        isFeeExempt[_user] = _isFeeExempt;
    }

    function migrateTokens(uint256 _amount) external {
        require(!migrationFinished, "Migration has already finished.");
        require(_amount > 0, "Amount should be greater than zero.");

        uint8 decimals = IBEP20(oldTokenAddress).decimals();
        uint256 oldTokenAmount = _amount * 10 ** uint256(decimals);

        IBEP20(oldTokenAddress).approve(address(this), oldTokenAmount);
        require(IBEP20(oldTokenAddress).transferFrom(msg.sender, address(this), oldTokenAmount), "Transfer failed.");

        require(IBEP20(newTokenAddress).transfer(msg.sender, oldTokenAmount), "Transfer failed.");

        emit TokensMigrated(msg.sender, _amount);
    }

    function withdrawOldTokens(address _to, uint256 _amount) external onlyOwner {
        require(IBEP20(oldTokenAddress).transfer(_to, _amount), "Transfer failed.");
    }

    function withdrawNewTokens(address _to, uint256 _amount) external onlyOwner {
        require(migrationFinished, "Migration has not finished yet.");
        require(IBEP20(newTokenAddress).transfer(_to, _amount), "Transfer failed.");
    }

    function startMigration() external onlyOwner {
        require(!migrationFinished, "Migration has already finished.");
        migrationFinished = true;
    }

    function changeOldTokenAddress(address _oldTokenAddress) external onlyOwner {
        oldTokenAddress = _oldTokenAddress;
    }

    function changeNewTokenAddress(address _newTokenAddress) external onlyOwner {
        newTokenAddress = _newTokenAddress;
    }
}