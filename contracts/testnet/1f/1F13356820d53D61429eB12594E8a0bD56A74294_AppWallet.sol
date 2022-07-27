// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./SystemAuth.sol";

contract AppWallet {

    address owner;
    address caller;

    SystemAuth ssAuth;

    constructor() {
        owner = msg.sender;
    }

    function setAuther(address ssAuthAddress) external {
        require(msg.sender == owner, "owner only");
        ssAuth = SystemAuth(ssAuthAddress);
    }

    function getAuther() external view returns (address res) {
        res = address(ssAuth);
    }

    function setCaller(address _caller) external {
        require(msg.sender != address(0), "zero address error");
        require(msg.sender == ssAuth.getOwner(), "Owner only");
        caller = _caller;
    }

    function getCaller() external view returns (address res) {
        res = caller;
    }

    function transferToken(address erc20TokenAddress, address to, uint256 amount) external returns (bool res) {
        require(msg.sender == caller, "caller only");
        require(ERC20(erc20TokenAddress).balanceOf(address(this)) >= amount, "insufficient balance to withdraw token from AppWallet");
        (bool transfered) = ERC20(erc20TokenAddress).transfer(to, amount);
        require(transfered, "error while withdrawing token from AppWallet");
        res = true;
    }

    function transferCoin(address to, uint256 amount) external returns (bool res) {
        require(msg.sender == caller, "caller only");
        require(address(this).balance >= amount, "insufficient balance to withdraw coin from AppWallet");
        (bool sent, ) = to.call{value: amount}("");
        require(sent, "error while withdrawing coind from AppWallet");
        res = true;
    }

    function withdrawToken(address erc20TokenAddress, address to, uint256 amount) external returns (bool res) {
        require(ssAuth.getOwner() == msg.sender, "owner only");
        require(ssAuth.getPayment() != erc20TokenAddress, "payment base fundation can not be withdrawed");
        require(ERC20(erc20TokenAddress).balanceOf(address(this)) >= amount, "insufficient balance in app wallet");
        (bool transfered) = ERC20(erc20TokenAddress).transfer(to, amount);
        require(transfered, "withdrawToken error");
        res = true;
    }
}