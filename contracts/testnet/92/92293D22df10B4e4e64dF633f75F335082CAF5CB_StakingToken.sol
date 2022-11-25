// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.17;

contract StakingToken {
    string public name = "SalchiCoin";
    string public symbol = "SC";
    uint256 public totalSupply = 1000000000000000000000000;
    uint256 public decimals = 18;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval (
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    function approve(address _spender, uint256 _amount) public returns (bool success) {
        allowance[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function transfer(address _to, uint256 _amount) public returns (bool success) {
        require(balanceOf[msg.sender] >= _amount, "Bastard");
        balanceOf[msg.sender] -= _amount;
        balanceOf[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
        require(_amount <= balanceOf[_from], "Bastard");
        require(_amount <= allowance[_from][msg.sender], "Bastard");
        balanceOf[_from] -= _amount;
        balanceOf[_to] += _amount;
        allowance[_from][msg.sender] -= _amount;
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function allowances(address owner, address spender) public view returns (uint256) {
        return allowance[owner][spender];
    }
}