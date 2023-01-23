/**
 *Submitted for verification at BscScan.com on 2023-01-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c=a+b;
        require(c>=a,"addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b<=a,"subtraction overflow");
        uint256 c=a-b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a==0) return 0;
        uint256 c=a*b;
        require(c/a==b,"multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b>0,"division by zero");
        uint256 c=a/b;
        return c;
    }
}

contract BEP20 {
    using SafeMath for uint256;
    string public symbol;
    string public name;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping (address=>uint256) balances;
    mapping (address=>mapping (address=>uint256)) allowed;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function balanceOf(address _owner) public view returns (uint256 balance) {return balances[_owner];}

    function transfer(address _to, uint256 _amount) public returns (bool success) {
        require (balances[msg.sender]>=_amount&&_amount>0);
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(msg.sender,_to,_amount);
        return true;
    }

    function transferFrom(address _from,address _to,uint256 _amount) public returns (bool success) {
        require (balances[_from]>=_amount&&allowed[_from][msg.sender]>=_amount&&_amount>0);
        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to]  = balances[_to].add(_amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function approve(address _spender, uint256 _amount) public returns (bool success) {
        allowed[msg.sender][_spender]=_amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
}

contract Token is Context,BEP20{
    using SafeMath for uint256;
    modifier onlyOwner() {
        require(owner==_msgSender(), "accessDenied");
        _;
    }
    address private owner;
    event Mint(address indexed _to, uint256 _value);

    constructor(
            address _owner,
            string memory _symbol,
            string memory _name,
            uint8 _decimals,
            uint256 _tokens
        ) {
        owner = _owner;
        symbol = _symbol;
        name = _name;
        decimals = _decimals;
        totalSupply = _tokens*(10**_decimals);
        balances[_owner] = totalSupply;
    }

    function mint(address _to, uint256 _tokens) public onlyOwner {
        require(_tokens>0,"nonZero");
        uint256 _amount = _tokens*(10**decimals);
        balances[_to] = balances[_to].add(_amount);
        totalSupply = totalSupply.add(_amount);
        emit Mint(_to,_amount);
    }

    receive() external payable {
        revert();
    }
}