/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

// SPDX-License-Identifier:MIT


pragma solidity ^0.8.0;

interface IToken {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256);

    function transfer(address _recipient, uint256 _amount)
        external
        returns (bool);

    function approve(address _spender, uint256 _amount) external returns (bool);

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) external returns (bool);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
    // function name() public view returns(string)
    // function symbol() public view returns(string)
    // function decimals() public view returns(uint8)
}

contract Test is IToken {
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply_;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    constructor() {
        name = "Test03";
        symbol = "BB";
        decimals = 10;
        totalSupply_ = 100000000000000;
        balances[msg.sender] = totalSupply_;
    }

    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner)
        public
        view
        override
        returns (uint256)
    {
        return balances[tokenOwner];
    }

    function transfer(address _reciver, uint256 _numTokens)
        public
        override
        returns (bool)
    {
        require(_numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_numTokens);
        balances[_reciver] = balances[_reciver].add(_numTokens);
        emit Transfer(msg.sender, _reciver, _numTokens);
        return true;
    }

    function approve(address _delegate, uint256 _numTokens)
        public
        override
        returns (bool)
    {
        allowed[msg.sender][_delegate] = _numTokens;
        emit Approval(msg.sender, _delegate, _numTokens);
        return true;
    }

    function allowance(address _owner, address _delegate)
        public
        view
        override
        returns (uint256)
    {
        return allowed[_owner][_delegate];
    }

    function transferFrom(
        address _owner,
        address _buyer,
        uint256 _numTokens
    ) public override returns (bool) {
        require(_numTokens <= balances[_owner]);
        require(_numTokens <= allowed[_owner][msg.sender]);
        balances[_owner] = balances[_owner].sub(_numTokens);
        allowed[_owner][msg.sender] = allowed[_owner][msg.sender].sub(
            _numTokens
        );
        balances[_buyer] = balances[_buyer].add(_numTokens);
        emit Transfer(_owner, _buyer, _numTokens);
        return true;
    }
}

library SafeMath {
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }  
}