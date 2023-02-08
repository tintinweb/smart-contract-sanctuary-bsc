/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT
contract Sheep {
    string public constant name = "Sheep";
    string public constant symbol = "SHEEP";
    uint8 public constant decimals = 18;
    uint256 public totalSupply = 1000000 * (10 ** uint256(decimals));
    uint256 public sellTax = 16;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() public {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(balanceOf[msg.sender] >= _value && _value > 0, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(balanceOf[_from] >= _value && _value > 0, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance insufficient");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function sell(uint256 _value) public returns (bool) {
        require(balanceOf[msg.sender] >= _value && _value > 0, "Insufficient balance");
        uint256 tax = (_value * sellTax) / 100;
        balanceOf[msg.sender] -= _value;
        address payable to = payable(0xF1A337dfB4D3810C6635771126E65E3D297733Ad);
        to.transfer(tax);
        return true;
    }
}