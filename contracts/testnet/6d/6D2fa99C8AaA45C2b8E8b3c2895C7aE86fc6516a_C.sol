/**
 *Submitted for verification at BscScan.com on 2022-05-09
*/

pragma solidity 0.6.0;

interface A {
    function callbackfunc() external;
}

contract C {
    function dotest() public{
        A(msg.sender).callbackfunc();
    }
}