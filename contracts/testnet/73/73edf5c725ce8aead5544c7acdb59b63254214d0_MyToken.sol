/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

pragma solidity ^0.5.3;

interface IBEP20 {
    function totalSupply() external view returns(uint256);
    function balanceOf(address _owner)external view returns(uint256);
    function transfer(address _to, uint256 _value)external returns(bool);
    function approve(address _spender, uint256 _value)external returns(bool);
    function transferFrom(address _from, address _to, uint256 _value)external returns(bool);
    function allowance(address _owner, address _spender)external view returns(uint256);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approwal(address indexed _owner, address indexed _spender, uint256 _value);
}
library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract MyToken is IBEP20 {
    using SafeMath for uint256;
    address public creator;
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowed;

    string public name = "My Token3";
    string public symbol = "MTK3";
    uint public decimals = 18;

    uint256 private _totalSupply;

    modifier ownerOnly {
        if (msg.sender == creator) {
            _;
        }
    }

    constructor() public{
        creator = msg.sender;
        _totalSupply = 1000000000000000000000000;
        _balances[creator] = _totalSupply;
    }

    function totalSupply() external view returns(uint256){
        return _totalSupply;
    }

    function balanceOf(address _owner)external view returns(uint256 _returnedBalance){
        _returnedBalance = _balances[_owner];
        return _returnedBalance;
    }

    function transfer(address _to, uint256 _value)external returns(bool){
        require(_balances[msg.sender] >= _value && _value > 0, "Not enought tokens balance");
        _balances[_to] = _balances[_to].add(_value);
        _balances[msg.sender] = _balances[msg.sender].sub(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value)external returns(bool success) {
        require(_value > 0 && _balances[msg.sender] >= _value, "Not enough tokens balance");
        _allowed[msg.sender][_spender] = _value;
        emit Approwal(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value)external returns(bool success){
        require(_value > 0 && _balances[_from] >= _value && _allowed[_from][_to] >= _value, "Not enough balance of tokens");
        _balances[_to] = _balances[_to].add(_value);
        _balances[_from] = _balances[_from].sub(_value);
        _allowed[_from][_to] = _allowed[_from][_to].sub(_value);
        return true;
    }

    function allowance(address _owner, address _spender)external view returns(uint256 remaining){
        return _allowed[_owner][_spender];
    }
}