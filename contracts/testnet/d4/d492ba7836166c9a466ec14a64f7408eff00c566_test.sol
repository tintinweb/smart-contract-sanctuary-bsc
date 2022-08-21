/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

pragma solidity 0.8.0;

contract test {
    uint256[] private t;
    function testa(uint256 _t) public returns(bool){
            t.push(_t);
            return true;
    }

    function v(uint256 number)view public returns(uint256){
        return t[number];
    }
}