/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Coinminter{
    
    string name;

    string symbol;

    address public owner;

    mapping (address => uint) public balances;

    event Sent(address _from, address _to, uint _amount);

    error InsufficientBalance(uint _requested, uint _available);

    constructor(string memory _name, string memory _symbol){
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
    }


    function mint(address _receiver, uint _amount) public {
        require(msg.sender == owner);
        balances[_receiver] += _amount;
    }


    function send(address _receiver, uint _amount) public {
        if(_amount > balances[msg.sender])
            revert InsufficientBalance({
                _requested: _amount,
                _available: balances[msg.sender]
            });

        balances[msg.sender] -= _amount;
        balances[_receiver] += _amount;
        emit Sent(msg.sender, _receiver, _amount);
    }


    function getBalance(address _account) external view returns(uint) {
        return balances[_account];
    }
}