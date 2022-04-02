/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract Machine {
    uint public num;
    uint public resultNum;    // sum of 1 to num
    address public sender;

    function setVar(address _base, uint _num) public {
        (bool success, bytes memory data) = _base.delegatecall(abi.encodeWithSignature("setVar(uint256)", _num));
    }
}