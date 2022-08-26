// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./ERC20.sol";
import "./ModuleBase.sol";

contract ConsolationWallet is SafeMath, ModuleBase {

    mapping(address => mapping(uint256 => bool)) mapPrizeClaimed;

    constructor(address _auth, address _mgr) ModuleBase(_auth, _mgr) {
    }

    function transferToken(address erc20TokenAddress, address to, uint256 amount) external onlyCaller returns (bool res) {
        require(ERC20(erc20TokenAddress).balanceOf(address(this)) >= amount, "insufficient balance to withdraw token from ConsolationWallet");
        (bool transfered) = ERC20(erc20TokenAddress).transfer(to, amount);
        require(transfered, "error while withdrawing token from ConsolationWallet");
        res = true;
    }

    function transferCoin(address to, uint256 amount) external onlyCaller returns (bool res) {
        require(address(this).balance >= amount, "insufficient balance to withdraw coin from ConsolationWallet");
        (bool sent, ) = to.call{value: amount}("");
        require(sent, "error while withdrawing coind from ConsolationWallet");
        res = true;
    }

    function withdrawToken(address erc20TokenAddress, address to, uint256 amount) external onlyOwner returns (bool res) {
        require(ssAuth.getPayment() != erc20TokenAddress, "payment base fundation can not be withdrawed");
        require(ERC20(erc20TokenAddress).balanceOf(address(this)) >= amount, "insufficient balance in app wallet");
        (bool transfered) = ERC20(erc20TokenAddress).transfer(to, amount);
        require(transfered, "withdrawToken error");
        res = true;
    }

    function setClaimed(address account, uint256 roundNumber) external onlyCaller {
        mapPrizeClaimed[account][roundNumber] = true;
    }

    function prizeClaimed(address account, uint256 roundNumber) external view returns (bool res) {
        res = _prizeClaimed(account, roundNumber);
    }

    function _prizeClaimed(address account, uint256 roundNumber) internal view returns (bool res) {
        res = mapPrizeClaimed[account][roundNumber];
    }
}