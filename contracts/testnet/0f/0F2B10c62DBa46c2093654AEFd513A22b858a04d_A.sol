/**
 *Submitted for verification at BscScan.com on 2022-02-24
*/

pragma solidity ^0.8.5;
contract A{
    uint256 value =0;
    function test( address sender , uint256 amount)external  returns (uint256)
    {
        return value - amount;
    }
}