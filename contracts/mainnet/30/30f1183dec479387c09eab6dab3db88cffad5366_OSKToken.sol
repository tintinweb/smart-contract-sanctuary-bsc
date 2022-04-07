// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./ERC20.sol";
import "./Ownable.sol";


contract OSKToken is ERC20 , Ownable {

    constructor(address masterWallet) ERC20("OSK Token", "OSK") Ownable(masterWallet) {

        require(masterWallet != address(0),"OSKToken: masterWallet is the zero address");
        _mint(masterWallet,2*10**26);            
    }
}