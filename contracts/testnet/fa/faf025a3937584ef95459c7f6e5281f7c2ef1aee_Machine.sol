/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract Base {
    uint public num;
    uint public resultNum;    // sum of 1 to num
    address public sender;

    function setVar(uint _num) public {
        num = _num;
        for(uint i=1;i<num;i++) {
            resultNum += i;
        }
    }
}

contract Machine {
    uint public num;
    address public sender;
    uint public resultNum;

    function calValue(address _base, uint _num) public {
        (bool success, bytes memory data) = _base.delegatecall(abi.encodeWithSignature("setVar(uint256)", _num));
    }
}