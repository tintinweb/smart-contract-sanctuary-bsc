/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

interface FR {

    function register() external view returns (bool);

}

contract TOS {
   
    FR public contractadd = FR(0x1CFeB1BBD980a0f0Fb733Ad1f0A1A0524357a2cF);
    //FR public contractadd;    
    function chk() public view returns (bool){        
        contractadd.register();
        return true;
    }
}