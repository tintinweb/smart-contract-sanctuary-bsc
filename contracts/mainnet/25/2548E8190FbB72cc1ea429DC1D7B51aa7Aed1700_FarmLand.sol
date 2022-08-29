// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Lockable.sol";
import "./SystemSetting.sol";
import "./AppWallet.sol";
import "./ModuleBase.sol";

contract FarmLand is Lockable, ModuleBase {

    mapping(address => bool) mapUserLand;

    bool landFree;

    event landBoughtEvent(address account, uint256 amount, uint time);

    constructor(address _auth, address _mgr) ModuleBase(_auth, _mgr) {
    }

    function setLandFree(bool free) external onlyOwner lock {
        landFree = free;
    }

    function getLandFree() external view returns (bool res) {
        res = landFree;
    }

    //buy a land to active your farming, using MUT as payment
    function buyLand(uint256 amount) external lock {
        require(
            msg.sender != address(0),
            "ZERO address not allowed to buy land"
        );
        require(!mapUserLand[msg.sender], "You have had a land already");
        // require(amount >= ssSetting.getLandPrice(0), "Pay too low price to buy a land");
        require(amount >= SystemSetting(moduleMgr.getModuleSystemSetting()).getLandPrice(0), "Pay too low price to buy a land");
        require(
            ERC20(ssAuth.getFarmToken()).balanceOf(msg.sender) >= amount,
            "Insufficient MUT balance to buy a land"
        );
        require(
            ERC20(ssAuth.getFarmToken()).allowance(msg.sender, address(this)) >=
                amount,
            "Not allowed to spend Amount"
        );

        bool transfered = ERC20(ssAuth.getFarmToken()).transferFrom(
            msg.sender,
            moduleMgr.getModuleAppWallet(),
            amount
        );
        require(transfered, "Buy land error");
        mapUserLand[msg.sender] = true;
        emit landBoughtEvent(msg.sender, amount, block.timestamp);
    }

    //check if an account have a land
    function haveLand(address account) external view returns (bool res) {
        if(landFree){
            res = true;
        } else {
            res = mapUserLand[account];
        }
    }

    function withdrawMUT(uint256 amount, address to) external onlyOwner {
        require(ERC20(ssAuth.getFarmToken()).balanceOf(moduleMgr.getModuleAppWallet()) >= amount, "insufficient balance MUT in contract");
        AppWallet(moduleMgr.getModuleAppWallet()).transferToken(ssAuth.getFarmToken(), to, amount);   
    }
}