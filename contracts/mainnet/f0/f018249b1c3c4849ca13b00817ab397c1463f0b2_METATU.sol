/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract METATU {

    string public constant name = "METATU";
    string public constant symbol = "TUTA";
    uint8 public constant decimal = 18;

    uint256 public totalSupply = 77000000 * (10 ** uint256(decimal));

    mapping (address => uint256) public balanceOf;

    uint256 public transferFee = 100;

    constructor() public {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public {
        require(balanceOf[msg.sender] >= _value + transferFee, "Insufficient balance");
        balanceOf[msg.sender] -= _value + transferFee;
        balanceOf[_to] += _value;
    }

    function excludeTransferFee(address _to, uint256 _value) public {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
    }
}