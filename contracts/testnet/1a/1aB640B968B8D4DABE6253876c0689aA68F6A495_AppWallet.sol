// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Callerable.sol";

contract AppWallet is Callerable {

    function transferToken(address erc20TokenAddress, address to, uint256 amount) external onlyCaller returns (bool res) {
        require(ERC20(erc20TokenAddress).balanceOf(address(this)) >= amount, "insufficient balance to withdraw token from AppWallet");
        (bool transfered) = ERC20(erc20TokenAddress).transfer(to, amount);
        require(transfered, "error while withdrawing token from AppWallet");
        res = true;
    }

}