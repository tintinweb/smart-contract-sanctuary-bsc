/**
 *Submitted for verification at BscScan.com on 2022-12-12
*/

//SPDX-License-Identifier:MIT

pragma solidity ^0.6.0;
contract Testaddress{
    function getBalance(address _address)public view returns(uint){
        return _address.balance;
    }
}