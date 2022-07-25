// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Soldier {
    uint public n;

    function callSetN(address _smc, uint _n) public {
        _smc.call(abi.encodeWithSignature("setN(uint256)", _n));
    }

    function delegatecallSetN(address _smc, uint _n) public {
        _smc.delegatecall(abi.encodeWithSignature("setN(uint256)", _n));
    }
}