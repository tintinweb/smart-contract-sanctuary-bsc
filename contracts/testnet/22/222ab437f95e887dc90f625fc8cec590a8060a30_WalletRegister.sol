/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

pragma solidity ^0.8.7;


contract WalletRegister {
    mapping (address => uint256) public addressToId;

    constructor() {}

    function registerWallet(uint256 id) public {
        addressToId[msg.sender] = id;
    }
}