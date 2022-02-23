/**
 *Submitted for verification at BscScan.com on 2022-02-23
*/

pragma solidity ^0.5.3;

contract A {
    uint256 summAB;
    function setVariables(uint256 _numberA, uint256 _numberB) public returns(uint256){
        summAB = _numberA + _numberB;
        return summAB;
    }
}