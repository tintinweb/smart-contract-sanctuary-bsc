/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^ 0.6.12;

interface IToken {
    function totalSupply() external view returns(uint256);
    function balanceOf(address account) external view returns(uint256);
    function allowance(address owner, address spender) external view returns(uint256);
    function transfer(address recipient, uint256 amount) external returns(bool);
    function approve(address spender, uint256 amount) external returns(bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);

}


contract TestToken is IToken {
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    address public owner;
    mapping(address => bool) whitelistController;
    
    modifier onlyOwner {
        require(msg.sender == owner, "invalid owner");
        _;
    }

    string public constant name = "LANDOGE Token";
    string public constant symbol = "LAN";
    uint256 public constant decimals = 18;
    uint256 totalSupply_ = 180000000 * (10**decimals); //1M

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    using SafeMath for uint256;
    
    constructor() public {
        owner = msg.sender;
        balances[msg.sender] = totalSupply_;
    }

    function totalSupply() public override view returns(uint256) {
        return totalSupply_;
    }

    function balanceOf(address _owner) public override view returns(uint256) {
        return balances[_owner];
    }

    function transfer(address _receiver, uint256 _amount) public override returns(bool) {
        require(_amount <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_receiver] = balances[_receiver].add(_amount);
        emit Transfer(msg.sender, _receiver, _amount);
        return true;
    }

    function approve(address _delegate, uint256 _amount) public override returns(bool) {
        allowed[msg.sender][_delegate] = _amount;
        emit Approval(msg.sender, _delegate, _amount);
        return true;
    }

    function allowance(address _owner, address _delegate) public override view returns(uint) {
        return allowed[_owner][_delegate];
    }

    function transferFrom(address _from, address _recipient, uint256 _amount) public override returns(bool) {
        require(_amount <= balances[_from]);
        require(_amount <= allowed[_from][msg.sender]);
        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_recipient] = balances[_recipient].add(_amount);
        emit Transfer(_from, _recipient, _amount);
        return true;
    }

   
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}