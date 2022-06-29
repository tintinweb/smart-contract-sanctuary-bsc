/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

// SPDX-License-Identifier: MIT
pragma solidity^0.8.0;

contract addresstest{
    address public account = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    function changeIt() view public returns(uint160){
        return uint160(account);
    }
    function changeIt2() pure public returns(address){
        return address(520786028573371803640530888255888666801131675076);
    }
}