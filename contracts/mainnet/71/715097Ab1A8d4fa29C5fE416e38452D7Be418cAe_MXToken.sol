// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./ERC20.sol";
import "./Ownable.sol";


contract MXToken is ERC20 , Ownable {

    constructor(address masterWallet) ERC20() Ownable(masterWallet) {

        require(masterWallet != address(0),"MX Token: masterWallet is the zero address");
        _mint(masterWallet,1 * (10**9) * (10**18));            
    }
}