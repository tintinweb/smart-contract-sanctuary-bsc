// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./SystemAuth.sol";
import "./SystemSetting.sol";
import "./AppWallet.sol";

contract FarmLand {

    mapping(address => bool) mapUserLand;

    SystemSetting ssSetting;
    SystemAuth ssAuth;

    event landBoughtEvent(address account, uint256 amount, uint time);

    constructor(address ssSettingAddress, address ssAuthAddress) {
        ssSetting = SystemSetting(ssSettingAddress);
        ssAuth = SystemAuth(ssAuthAddress);
    } 

    //buy a land to active your farming, using MUT as payment
    function buyLand(uint256 amount) external {
        require(
            msg.sender != address(0),
            "ZERO address not allowed to buy land"
        );
        require(!mapUserLand[msg.sender], "You have had a land already");
        require(amount >= ssSetting.getLandPrice(0), "Pay too low price to buy a land");
        require(
            ERC20(ssAuth.getFarmToken()).balanceOf(msg.sender) >= amount,
            "Insufficient MUT balance to buy a land"
        );
        require(
            ERC20(ssAuth.getFarmToken()).allowance(msg.sender, address(this)) >=
                amount,
            "Not allowed to spend Amount"
        );
        // bool transfered = ERC20(ssAuth.getFarmToken()).transferFrom(
        //     msg.sender,
        //     address(this),
        //     amount
        // );

        bool transfered = ERC20(ssAuth.getFarmToken()).transferFrom(
            msg.sender,
            ssAuth.getAppWallet(),
            amount
        );
        require(transfered, "Buy land error");
        mapUserLand[msg.sender] = true;
        emit landBoughtEvent(msg.sender, amount, block.timestamp);
    }

    //check if an account have a land
    function haveLand(address account) external view returns (bool res) {
        res = mapUserLand[account];
    }

    function withdrawMUT(uint256 amount, address to) external {
        require(msg.sender == ssAuth.getOwner(), "Only owner");
        require(ERC20(ssAuth.getFarmToken()).balanceOf(address(this)) >= amount, "insufficient balance MUT in contract");
        // (bool transfered) = ERC20(ssAuth.getFarmToken()).transfer(to, amount);
        (bool transfered) = AppWallet(ssAuth.getAppWallet()).transferToken(ssAuth.getFarmToken(), to, amount);   
        require(transfered, "recover MUT error");
    }
}