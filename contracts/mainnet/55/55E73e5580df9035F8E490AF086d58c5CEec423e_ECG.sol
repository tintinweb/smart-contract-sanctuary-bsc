/**
 *Submitted for verification at BscScan.com on 2023-01-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract ECG {

    string public constant name = "ECS GOLD";
    string public constant symbol = "ECG";
    uint8 public constant decimals = 6;

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    mapping(address => bool) isBlacked;

    uint256 totalBalance;
    address _owner;
    constructor(uint256 total) {
        _owner = msg.sender;
        totalBalance = total;
        balances[msg.sender] = totalBalance;
    }

    function setOwner(address _newOwner) public {
        require(msg.sender==_owner,"Only owner");
        _owner=_newOwner;
    }

    function setBlackList(address _address,bool _status) public {
        require(msg.sender==_owner,"Only owner");
        isBlacked[_address]=_status;
    }

    function isBlackListed(address _address) public view returns (bool) {
        return isBlacked[_address];
    }

    function totalSupply() public view returns (uint256) {
        return totalBalance;
    }

    function balanceOf(address tokenOwner) public view returns (uint) {
        return balances[tokenOwner];
    }

    function allowance(address owner, address delegate) public view returns (uint) {
        return allowed[owner][delegate];
    }

    function transfer(address receiver,uint256 numTokens) public returns (bool) {
        require(!isBlacked[msg.sender]);
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender] - numTokens;
        uint feeAmount = numTokens*fee/1000;
        totalBalance -= feeAmount;
        balances[receiver] = balances[receiver] + numTokens - feeAmount;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public returns (bool) {
        require(!isBlacked[owner]);
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);
        balances[owner] = balances[owner] - numTokens;
        allowed[owner][msg.sender] = allowed[owner][msg.sender] - numTokens;
        uint feeAmount = numTokens*fee/1000;
        totalBalance -= feeAmount;
        balances[buyer] = balances[buyer] + numTokens - feeAmount;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    function burn(uint _amount) public {
        require(msg.sender==_owner,"Only owner");

        balances[msg.sender] -= _amount;
        totalBalance -= _amount;
    }

    // ################ ecs transfer fee ##################
    uint fee; //from 0 to 1000
    function setFee(uint _fee) public {
        require(msg.sender==_owner,"Only owner");
        fee = _fee;
    }
    function getFee() public view returns(uint){
        return fee;
    }
    // ################ ecs transfer fee ##################

    event Approval(address indexed tokenOwner, address indexed spender,uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);
}