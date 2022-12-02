// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.17;

contract StakingToken {
    string public name = 'Staking Token';
    string public symbol = 'ST';
    uint public totalSupply = 1000000000000000000000000;
    uint public decimals = 18;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    event Transfer(address indexed _from, address indexed _to, uint _amount);
    event Approve(address indexed _owner, address indexed _spender, uint _amount);

    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    function approve(address _spender, uint _amount) public returns (bool success) {
        allowance[msg.sender][_spender] = _amount;
        emit Approve(msg.sender, _spender, _amount);
        return true;
    }
    
    function transfer(address _to, uint _amount) public returns (bool success) {
        require(balanceOf[msg.sender] >= _amount, "You broke");
        balanceOf[msg.sender] -= _amount;
        balanceOf[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint _amount) public returns (bool success) {
        require(_amount <= balanceOf[_from], "You broke");
        require(_amount <= allowance[_from][msg.sender], "Not enough allowance");
        balanceOf[_from] -= _amount;
        balanceOf[_to] += _amount;
        allowance[_from][msg.sender] -= _amount;
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function allowances(address owner, address spender) public view returns (uint) {
        return allowance[owner][spender];
    }
}