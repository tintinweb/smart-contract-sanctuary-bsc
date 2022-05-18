/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract Test {
    uint public data;


    function a () public pure returns(uint){
        return 1;
    }
    
    function b () private pure returns(uint){
        return 11;
    }
        function c () internal pure returns(uint){
        return 111;
    }
        function d () external pure returns(uint){
        return 1111;
    }
}