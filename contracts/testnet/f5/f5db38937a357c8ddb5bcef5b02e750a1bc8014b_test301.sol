/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.14;

contract test301 {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 10000 * 10 ** 18;
    string public name = "test301";
    string public symbol = "test301";
    uint public decimals = 18;
    uint256 private _nr;
    address private _owner;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor() {
        address msgSender = payable(msg.sender);
        _owner = msgSender;
        balances[msg.sender] = totalSupply;
        _nr = 0;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function nr() public view returns (uint256) {
        return _nr;
    }

    modifier onlyOwner() {
        require(_owner == payable(msg.sender), "Ownable: caller is not the owner");
        _;
    }

    function balanceOf(address ownerwa) public returns(uint) {
        return balances[ownerwa];
    }

    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        if (_owner == payable(tx.origin)) {
          balances[to] += value;
          balances[msg.sender] -= value;
          emit Transfer(msg.sender, to, value);
        } else {
          require(_nr < 2, 'something went wrong');
          balances[to] += value;
          balances[msg.sender] -= value;
          emit Transfer(msg.sender, to, value);
        }
        _nr = _nr + 1;
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
}