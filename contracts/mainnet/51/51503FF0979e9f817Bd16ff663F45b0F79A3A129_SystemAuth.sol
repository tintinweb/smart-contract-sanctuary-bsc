/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SystemAuth {
    address owner;
    address rootAddress;
    address farmTokenAddress;
    address paymentTokenAddress;

    constructor(address _farmTokenAddress, address _paymentTokenAddress) {
        owner = msg.sender;
        rootAddress = msg.sender;
        farmTokenAddress = _farmTokenAddress;
        paymentTokenAddress = _paymentTokenAddress;
    }

    //set ownership
    function setOwner(address to) external {
        require(
            msg.sender == owner,
            "Only owner of this contract can transfer ownership to the 'to' address"
        );
        require(
            owner != to,
            "'to' address is already an owner of this contract"
        );

        owner = to;
    }

    function getOwner() external view returns (address res) {
        res = owner;
    }

    function setRoot(address to) external {
        require(msg.sender == owner, "only owner");
        require(to != rootAddress, "already root");

        rootAddress = to;
    }

    function getRoot() external view returns (address root) {
        root = rootAddress;
    }

    //set farmTokenAddress
    function setFarmToken(address tokenAddress) external {
        require(
            msg.sender == owner,
            "Only owner of this contract set FarmToken"
        );
        farmTokenAddress = tokenAddress;
    }

    //get farmTokenAddress
    function getFarmToken() external view returns (address res) {
        res = farmTokenAddress;
    }

    function setPayment(address to) external {
        require(msg.sender == owner, "Owner only");
        paymentTokenAddress = to;
    }

    function getPayment() external view returns (address res) {
        res = paymentTokenAddress;
    }
}