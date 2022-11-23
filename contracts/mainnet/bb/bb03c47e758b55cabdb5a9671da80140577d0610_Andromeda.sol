/**
 *Submitted for verification at BscScan.com on 2022-11-22
*/

// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.14;

contract Andromeda{
    // Arrays for maintaining the token's state
    address[10] admin;
    mapping (address => uint) public balances;
    mapping (address => mapping(address => uint)) public allowance;
    // Token Details
    uint public totalSupply;
    string public name = "Andromeda";
    string public symbol = "AND";
    uint public decimals;

    // Events to be emitted on actions
    event Transfer (address indexed from, address indexed to, uint value);
    event Approve (address indexed owner, address indexed spender, uint value);

    // total supply goes to the contract itself
    constructor(uint _totalSupply, uint _decimals) {
        totalSupply = _totalSupply * 10 ** _decimals;
        decimals = _decimals;
        balances[address(this)] = totalSupply;
        admin[0] = msg.sender;
    }

    
    function balanceOf(address _owner) public view returns(uint) {
        return balances[_owner];
    }

    // Mint tokens (only-admins)
    function mint(address _to, uint _value) public returns(bool) {
        for (uint i = 0; i < admin.length; i++) {
            if (admin[i] == msg.sender) {
                totalSupply = totalSupply + _value;
                balances[_to] = balances[_to] + _value;
                emit Transfer(address(0), _to, _value);
                return true;
            }
        }
        return false;
    }

    // Burn tokens (only-admins) (check is inside giveAway)
    function burn(uint _value) public returns(bool) {
        return giveAway(address(0), _value);
    }

    // Give away tokens (only-admins)
    function giveAway(address _to, uint _value) public returns(bool) {
        require(balanceOf(address(this)) >= _value, "Balance of the contract is too low");
        for (uint i = 0; i < admin.length; i++) {
            if (admin[i] == msg.sender) {
                balances[address(this)] = balances[address(this)] - _value;
                balances[_to] = balances[_to] + _value;
                totalSupply = totalSupply - _value;
                emit Transfer(address(this), _to, _value);
                return true;
            }
        }
        return false;
    }

    // add admin (only-admins)
    function addAdmin(address _newAdmin) public returns(bool) {
        for (uint i = 0; i < admin.length; i++) {
            if (admin[i] == msg.sender) {
                for (uint j = 0; i < admin.length; j++) {
                    if (admin[j] == address(0)) {
                        admin[j] = _newAdmin;
                        return true;
                    }
                }
            }
        }
        return false;
    }


    // Transfers from sender to another address
    function transfer(address _to, uint _value) public returns(bool) {
        require(balanceOf(msg.sender) >= _value, "Balance too low");
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // Allow someone to transfer on behlaf of someone else
    function transferFROM(address _from, address _to, uint _value) public returns(bool) {
        require(balanceOf(_from) >= _value, "Balance too low");
        require(allowance[_from][msg.sender] >= _value, "Allowance too low");
        balances[_from] = balances[_from] - _value;
        balances[_to] = balances[_to] + _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    // Let someone transfer on my behalf
    function approve(address spender, uint amount) public returns(bool) {
        allowance[msg.sender][spender] = amount;
        emit Approve(msg.sender, spender, amount);
        return true; 
    }
}