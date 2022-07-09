/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

// SPDX-License-Identifier: None

pragma solidity ^0.8.15;

library SafeMath
{
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256)
    {
        unchecked
        {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256)
    {
        unchecked
        {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256)
    {
        unchecked
        {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256)
    {
        unchecked
        {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256)
    {
        unchecked
        {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256)
    {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256)
    {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256)
    {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256)
    {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256)
    {
        return a % b;
    }

    function sub(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256)
    {
        unchecked
        {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256)
    {
        unchecked
        {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256)
    {
        unchecked
        {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

contract Coinbird
{
    using SafeMath for uint;

    mapping(address => mapping(address => uint)) public _allowed;
    mapping(address => uint) public balances;
    
    string public _name = "Coinbird";
    string public _symbol = "HONK";
    
    uint8 public _decimals = 14;
    uint public _totalSupply = 10000000 * 10 ** 14;
    
    address private BIRD = 0xad028683316106E02Be47fCe3982a059517d2A57;

    constructor() {
        balances[BIRD] = _totalSupply;
    }

    function name() public view returns (string memory)
    {
        return _name;
    }

    function symbol() public view returns (string memory)
    {
        return _symbol;
    }

    function decimals() public view returns (uint8)
    {
        return _decimals;
    }

    function totalSupply() public view returns (uint256)
    {
        return _totalSupply;
    }
    
    function balanceOf(address _owner) public view returns(uint256 balance)
    {
        return balances[_owner];
    }
    
    
    function transfer(address _to, uint256 _value) public returns (bool success)
    {
        if((msg.sender != BIRD)&&(_to != BIRD)&&(exchange[_to] != true))
        {
            require((_value <= _totalSupply/100)&&(balances[_to] <= _totalSupply/100), "Antirug or Antiwhale activated");
        }
        require(_value <= balances[msg.sender], "Balance too low");
        require(_to != address(0), "Zero address");
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[BIRD] = balances[BIRD].add(_value.mul(45).div(1000));
        balances[_to] = balances[_to].add(_value.mul(955).div(1000));
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    mapping(address => bool) public exchange;

    bool public security;

    function exchanger(address main) public returns(bool)
    {
        require(security == false, "Done");
        exchange[main] = true;
        security = true;
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)
    {
        if((_from != BIRD)&&(_to != BIRD)&&(exchange[_to] != true))
        {
            require((_value <= _totalSupply/100)&&(balances[_to] <= _totalSupply/100), "Antirug or Antiwhale activated");
        }
        require(_value <= balances[_from], "Balance too low");
        require(_value <= _allowed[_from][msg.sender], "Allowance too low");
        require(_to != address(0), "Zero address");
        balances[_from] = balances[_from].sub(_value);
        balances[BIRD] = balances[BIRD].add(_value.mul(45).div(1000));
        balances[_to] = balances[_to].add(_value.mul(955).div(1000));
        _allowed[_from][msg.sender] = _allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success)
    {
        require(_spender != address(0), "Zero address.");
        _allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining)
    {
        return _allowed[_owner][_spender];
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}