/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

pragma solidity >=0.7.0 <0.9.0;

contract FirstContract {
    uint public saveData;

    function set(uint x) private{
        saveData = x;
    }

    function get() public view returns (uint x){
        return saveData;
    }
}