/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract SimpleCoin {
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    address public owner;

    string public name = "Meu token";
    string public symbol = "MTK";
    uint8 public decimals = 8;

    // Um endereço permite que o outro endereço meche em seu saldo (gastar);
    mapping(address => mapping(address => uint)) public allowance;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);


    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor() {

        owner = msg.sender;
        totalSupply = 1_000_000_000 * 10 ** decimals;
        balanceOf[owner] = totalSupply;

    }

    function transferFrom(address _from, address _to, uint _value) public returns(bool success){
        require(allowance[_from][msg.sender] >= _value);
        require(balanceOf[_from] >= _value);
        require(_from != address(0));
        require(_to != address(0));

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success){
        //require(balanceOf[msg.sender] >= _value);
        require(_spender != address(0));
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    

    function changeOwner(address _newOwner) public onlyOwner {
    // require(msg.sender == owner);
        owner = _newOwner;
    }

    function transfer(address _to, uint256 _value) public returns (bool success){
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

}