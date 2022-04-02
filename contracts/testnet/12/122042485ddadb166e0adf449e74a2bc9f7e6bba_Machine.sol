/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;
contract Storage {
    uint public val;
    constructor(uint v) {
        val = v;
    }
    function setValue(uint v) public {
        val = v;
    }
}

contract Calculator {
    uint public calculateResult;
    address public user;
    event Add(uint a, uint b);

    function add(uint a, uint b) public returns(uint) {
        calculateResult = a + b;
        assert(calculateResult >= a);
        emit Add(a, b);
        user = msg.sender;
        return calculateResult;
    }
}

contract Machine {
    Storage public s;
    uint256 public calculateResult;
    address public user;

    event AddedValuesByDelegateCall(uint a, uint b, bool success);
    event AddedValuesByCall(uint a, uint b, bool success);

    constructor(Storage _s) {
        s = _s;
        calculateResult = 0;
    }

    function saveValue(uint x) public returns (bool) {
        s.setValue(x);
        return true;
    }
    function getValue() public view returns (uint) {
        return s.val();
    }

    function addValuesWithDelegateCall(address calculator, uint a, uint b) public returns (uint) {
        (bool success, bytes memory result) = calculator.delegatecall(abi.encodeWithSignature("add(uint, uint)", a, b));
        emit AddedValuesByDelegateCall(a, b, success);
        return abi.decode(result, (uint));
    }

    function addValuesWithCall(address calculator, uint a, uint b) public returns (uint) {
        (bool success, bytes memory result) = calculator.call(abi.encodeWithSignature("add(uint, uint", a, b));
        emit AddedValuesByDelegateCall(a, b, success);
        return abi.decode(result, (uint));
    }
}