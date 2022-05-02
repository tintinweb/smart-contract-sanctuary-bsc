/**
 *Submitted for verification at BscScan.com on 2022-05-02
*/

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
contract map{
    mapping(address=>uint) public balances;
    mapping(address=>bool) public inserted;
    address[] public keys;
    function set(address _key, uint _val) external {
        balances[_key] = _val;
        if(!inserted[_key]) {
            inserted[_key] = true;
            keys.push(_key);
        }
    }
    function get(uint _i) public view returns(uint) {
        return balances[keys[_i]];
    }
}