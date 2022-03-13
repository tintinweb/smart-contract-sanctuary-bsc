/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

pragma solidity >=0.8.0;
// SPDX-License-Identifier: MIT

abstract contract ERC20Token{
    function name() virtual public view returns (string memory);
    function symbol() virtual public view returns (string memory);
    function decimals() virtual public view returns (uint8);
    function totalSupply() virtual public view returns (uint256);
    function balanceOf(address _owner) virtual public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) virtual public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) virtual public returns (bool success);
    function approve(address _spender, uint256 _value) virtual public returns (bool success);
    function allowance(address _owner, address _spender) virtual public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Owned{
    address public owner;
    address public newOwner;

    event OwnershipTransfer(address indexed _from, address indexed _to);

    constructor(){
        owner = msg.sender;
    }

    function transferOwnership(address _to) public{
        require(msg.sender == owner);
        newOwner = _to;
    }

}

contract token is ERC20Token, Owned{
    string public _name;
    string public _symbol;
    uint8 public _decimals;
    uint public _totalSupply;
    address public _minter;

    mapping(address =>uint) balances;

    constructor(){
        _symbol = "TK";
        _name = "Token";
        _decimals = 0;
        _totalSupply = 100;
        _minter = 0x7EF09DE5bCCf865Dd92b486804B5C37a1016B64F;

        balances[_minter] = _totalSupply;
        
        emit Transfer(address(0), _minter, _totalSupply);
    }

    function name() public override view returns(string memory){
        return _name;
    }
    function symbol() public override view returns (string memory){
        return _symbol;
    }
    function decimals() public override view returns (uint8){
        return _decimals;
    }
    function totalSupply() public override view returns (uint256){
        return _totalSupply;
    }
    function balanceOf(address _owner) public override view returns (uint256 balance){
        return balances[_owner];
    }
    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success){
        require(balances[_from] >= _value);
        balances[_from] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
    function transfer(address _to, uint256 _value) public override returns (bool success){
        return transferFrom(msg.sender, _to, _value);
    }
    function approve(address _spender, uint256 _value) public override view returns (bool success){
        _spender = msg.sender;
        _value = 0;
        return true;
    }
    function allowance(address _owner, address _spender) public override view returns (uint256 remaining){
        _owner = msg.sender;
        _spender = msg.sender;
        return 0;
    }


    function mint(uint amount) public returns(bool){
        require(msg.sender == owner);
        balances[_minter] += amount;
        _totalSupply += amount;
        return true;
    }
}