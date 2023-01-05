/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract Token {
    uint256 public TotalSuply;
    
    modifier OnlyOwner {
        require(msg.sender == owner);
        _;
    }

    mapping(address => mapping(address => uint)) public allowance;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value );
    event Unapproval(address indexed _owner, address indexed _spender, uint256 _value );

    function TransferFrom(address _from, address _to, uint _value) public returns(bool success){
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

    address public owner;

    string public name = "Meu Token";
    string public symbol = "MTK";
    uint8 public decimals = 8;
    
    mapping(address => uint)  balanceOf;
    

    function transfer(address _to, uint256 _value) public returns(bool success){
        require(balanceOf[msg.sender] >= _value);
        require(_to != address(0));
        balanceOf[msg.sender] -= _value;

        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }


    function unapprove(address _spender, uint256 _value) public returns(bool success){
        require(_spender != address(0));
        allowance[msg.sender][_spender] -= _value;
        emit Unapproval(msg.sender, _spender, _value);
        return true;
    }

    function myBalance() public view returns (uint256){
        return balanceOf[msg.sender];
    }

    function approve(address _spender, uint256 _value) public returns(bool success){
        require(_spender != address(0));
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }



    constructor() {
        TotalSuply = 1_000_000_000;
        owner = msg.sender;
        balanceOf[owner] = TotalSuply;
    }
}