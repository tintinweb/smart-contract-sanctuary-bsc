/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Kalkulator{

    function Jumlahkan(uint8 a , uint8 b ) public pure returns(uint8){
        require(a+b>=a ,"Entahlah aku tak tau jawabannya");
        return a+b;
    }
}