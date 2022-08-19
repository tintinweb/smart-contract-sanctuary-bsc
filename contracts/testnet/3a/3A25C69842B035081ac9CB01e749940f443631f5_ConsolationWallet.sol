// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./ERC20.sol";
import "./SystemAuth.sol";
import "./ModuleMgr.sol";

contract ConsolationWallet is SafeMath {

    address owner;

    struct CallerData{
        address caller;
        bool isCaller;
    }
    uint32 callerCount;
    mapping(address => bool) mapCaller;
    mapping(uint32 => CallerData) mapCallerList;

    SystemAuth ssAuth;

    mapping(address => mapping(uint256 => bool)) mapPrizeClaimed;

    constructor() {
        owner = msg.sender;
    }

    function setAuther(address ssAuthAddress) external {
        require(msg.sender == owner, "owner only 1");
        ssAuth = SystemAuth(ssAuthAddress);
    }

    function getAuther() external view returns (address res) {
        res = address(ssAuth);
    }

    function addCaller(address _caller) external {
        require(msg.sender == ssAuth.getOwner(), "Owner only 3");
        require(!mapCaller[_caller], "caller exists");
        mapCaller[_caller] = true;
        mapCallerList[++callerCount] = CallerData(_caller, true);
    }

    function isCaller(address addr) external view returns (bool res) {
        res = _isCaller(addr);
    }

    function _isCaller(address addr) internal view returns (bool res) {
        res = mapCaller[addr];
    }

    function getCallerCount() external view returns (uint32 res) {
        res = callerCount;
    }

    function removeCaller(address addr) external {
        require(msg.sender == ssAuth.getOwner(), "Owner only 2004");
        if(mapCaller[addr]) {
            delete mapCaller[addr];
            for(uint32 i = 1; i <= callerCount; ++i) {
                if(mapCallerList[i].caller == addr) {
                    CallerData storage cd = mapCallerList[i];
                    cd.isCaller = false;
                    break;
                }
            }
        }
    }

    function getCaller(uint32 index) external view returns (bool res, address addr) {
        addr = mapCallerList[index].caller;
        res = mapCaller[addr];
    }

    function transferToken(address erc20TokenAddress, address to, uint256 amount) external returns (bool res) {
        require(mapCaller[msg.sender], "caller only 2005");
        require(ERC20(erc20TokenAddress).balanceOf(address(this)) >= amount, "insufficient balance to withdraw token from ConsolationWallet");
        (bool transfered) = ERC20(erc20TokenAddress).transfer(to, amount);
        require(transfered, "error while withdrawing token from ConsolationWallet");
        res = true;
    }

    function transferCoin(address to, uint256 amount) external returns (bool res) {
        require(mapCaller[msg.sender], "caller only 2006");
        require(address(this).balance >= amount, "insufficient balance to withdraw coin from ConsolationWallet");
        (bool sent, ) = to.call{value: amount}("");
        require(sent, "error while withdrawing coind from ConsolationWallet");
        res = true;
    }

    function withdrawToken(address erc20TokenAddress, address to, uint256 amount) external returns (bool res) {
        require(ssAuth.getOwner() == msg.sender, "owner only 2007");
        require(ssAuth.getPayment() != erc20TokenAddress, "payment base fundation can not be withdrawed");
        require(ERC20(erc20TokenAddress).balanceOf(address(this)) >= amount, "insufficient balance in app wallet");
        (bool transfered) = ERC20(erc20TokenAddress).transfer(to, amount);
        require(transfered, "withdrawToken error");
        res = true;
    }

    function setClaimed(address account, uint256 roundNumber) external {
        require(mapCaller[msg.sender], "caller only 3001");
        mapPrizeClaimed[account][roundNumber] = true;
    }

    function prizeClaimed(address account, uint256 roundNumber) external view returns (bool res) {
        res = _prizeClaimed(account, roundNumber);
    }

    function _prizeClaimed(address account, uint256 roundNumber) internal view returns (bool res) {
        res = mapPrizeClaimed[account][roundNumber];
    }
}