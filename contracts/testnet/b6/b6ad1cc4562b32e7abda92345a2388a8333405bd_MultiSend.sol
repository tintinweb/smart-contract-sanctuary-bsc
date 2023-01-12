/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract MultiSend {

    address public owner = payable(msg.sender);
    address[]  wallets=[0xbAbE950842EDEFC02AD929A2690751AC8bb75bBe,0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db];

    function sendFund(uint amount) public payable {
        for(uint i=0;i<wallets.length;i++){
           payable(wallets[i]).transfer(amount);
        }
    }

    
}