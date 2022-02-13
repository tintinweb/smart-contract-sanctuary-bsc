/**
 *Submitted for verification at BscScan.com on 2022-02-12
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
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
}

interface IPancakeRouter01 {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
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
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string public name = "My Token12";
    string public symbol = "MTK12";
    uint public decimals = 18;

    uint256 private _totalSupply;

    address public _lpContract ;
    uint256 private _liquidityTokens = 100000000000000000000000;
    uint256 private _liquidityBNB;
    address public _tokenAddress = address(this);

    uint256 public _deadline;
    uint256 public timestampRN;

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

    function _transfer(address _from, address _to, uint256 amount) internal {
      require(_from != address(0), "BEP20: Transfer from zero address");
      require(_to != address(0), "BEP20: Transfer to the zero address");
      _balances[_from] = _balances[_from].sub(amount,"BEP20: Transfer amount exceeds balance");
      _balances[_to] = _balances[_to].add(amount);
      emit Transfer(_from, _to, amount);
    }

    function transfer(address _to, uint256 _value)external returns(bool){
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
      require(owner != address(0), "BEP20: approve from the zero address");
      require(spender != address(0), "BEP20: approve to the zero address");
      _allowances[owner][spender] = amount;
      emit Approval(owner, spender, amount);
    }

    function approve(address _spender, uint256 _value)external returns(bool success) {
        _approve(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value)external returns(bool success){
        _transfer(_from, _to, _value);
        _approve(_from, msg.sender, _allowances[_from][msg.sender].sub(_value, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function allowance(address _owner, address _spender)external view returns(uint256 remaining){
        return _allowances[_owner][_spender];
    }

    function getTimeStamp()public returns(uint256){
      timestampRN = block.timestamp;
      return timestampRN;
    }

    function setAndApproveLPContract(address _LPContract, uint256 amountTks) ownerOnly public returns(bool){
        _lpContract = _LPContract;
        _approve(creator, _lpContract, amountTks);
        return true;
    }

    function addLPoolPCS(
      address tokenA, 
      uint256 amountTokens, 
      uint256 amounTkMin, 
      uint256 amountBNBMin, 
      address _to, 
      uint256 deadline) ownerOnly public payable{
        IPancakeRouter01 pancakeContract = IPancakeRouter01(_lpContract);
        pancakeContract.addLiquidityETH(
          tokenA, 
          amountTokens, 
          amounTkMin, 
          amountBNBMin, 
          _to, 
          deadline);
    }
}