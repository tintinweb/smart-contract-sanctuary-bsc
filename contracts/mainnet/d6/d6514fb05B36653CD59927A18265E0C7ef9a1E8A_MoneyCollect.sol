// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./AppWallet.sol";
import "./ModuleBase.sol";

contract MoneyCollect is ModuleBase {

    constructor
    (
        address _systemAuthAddress, 
        address _moduleMgrAddress
    ) ModuleBase(_systemAuthAddress, _moduleMgrAddress) {
    }

    function collectToken(address tokenAddress, address to, uint256 amount) external {
        AppWallet(moduleMgr.getModuleAppWallet()).transferToken(tokenAddress, to, amount);
    }
}