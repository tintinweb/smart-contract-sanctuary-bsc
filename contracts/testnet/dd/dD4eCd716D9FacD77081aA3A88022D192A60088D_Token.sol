/**
 *Submitted for verification at BscScan.com on 2022-09-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Token {
    string public name = "my token";
    uint256 public totalSupply = 1000000000000000000000000; // 1 million tokens
    uint8 public decimals = 18;
    string public symbol = "MTK";

    event Transfer(address  _from, address _to, uint256 _value);

    event Approval(
        address _owner,
        address _spender,
        uint256 _value
    );

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor() {
        balances[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value)
        public
        returns (bool)
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowanced(address sender, address spender)public view returns(uint){
        return allowance[sender][spender];
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool) {
        require(_value <= balances[_from]);
        require(_value <= allowance[_from][_to]);
        balances[_from] -= _value;
        balances[_to] += _value;
        allowance[_from][_to] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }
}