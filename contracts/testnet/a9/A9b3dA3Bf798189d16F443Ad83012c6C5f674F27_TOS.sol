/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

interface FR {

    function register() external view returns (bool);

}

contract TOS {
   
   //from constant private  BUSD = from(0x1CFeB1BBD980a0f0Fb733Ad1f0A1A0524357a2cF);
    FR public contractadd;    
    function chk(address _con) public returns (bool){
        contractadd = FR(_con);
        contractadd.register();
        return true;
    }
}