// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "./IPancakeFactory.sol";
import "./IPancakeRouter.sol";
import "./IPancakePair.sol";

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

/* interface PancakeContract {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
} */

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
    address payable public creator;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string public name = "My Token20";
    string public symbol = "MTK20";
    uint public decimals = 18;

    uint256 private _totalSupply;

    address payable public _lpContract = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    uint256 public _liquidityTokens = 1000000000000000000000000;
    uint256 public _liquidityBNB;
    address public _tokenAddress = address(this);

    uint256 public _deadline;
    uint256 public timestampRN;

    // PancakeContract pancakeContract;
    uint public amountTokenLP;
    uint public amountETHLP; 
    uint public liquidityLP;

    IPancakeRouter02 public pancakeRouter;
    address public pancakePair;
    modifier ownerOnly {
        if (msg.sender == creator) {
            _;
        }
    }

    constructor() public{
        creator = msg.sender;
        _totalSupply = 1000000000000000000000000;
        _balances[creator] = _totalSupply;
        // pancakeContract = PancakeContract(_lpContract);
        IPancakeRouter02 _pancakeRouter = IPancakeRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        address _pancakePair = IPancakeFactory(_pancakeRouter.factory()).createPair(address(this), _pancakeRouter.WETH());
        pancakeRouter = _pancakeRouter;
        pancakePair = _pancakePair;
    }

    receive() external payable {

    }

    function totalSupply() external override view returns(uint256){
        return _totalSupply;
    }

    function balanceOf(address _owner)external override view returns(uint256 _returnedBalance){
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

    function transfer(address _to, uint256 _value)external override returns(bool){
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
      require(owner != address(0), "BEP20: approve from the zero address");
      require(spender != address(0), "BEP20: approve to the zero address");
      _allowances[owner][spender] = amount;
      emit Approval(owner, spender, amount);
    }

    function approve(address _spender, uint256 _value)external override returns(bool success) {
        _approve(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value)external override returns(bool success){
        _transfer(_from, _to, _value);
        _approve(_from, msg.sender, _allowances[_from][msg.sender].sub(_value, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function allowance(address _owner, address _spender)external override view returns(uint256 remaining){
        return _allowances[_owner][_spender];
    }

    function getTimeStamp()public returns(uint256){
      timestampRN = block.timestamp;
      return timestampRN;
    }

    function setAndApproveLPContract(address payable _LPContract, uint256 amountTks) ownerOnly public returns(bool){
        _lpContract = _LPContract;
        _approve(creator, _lpContract, amountTks);
        return true;
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) public {
      _approve(address(this), address(pancakeRouter), tokenAmount);
      pancakeRouter.addLiquidityETH{value: ethAmount} (
        address(this),
        tokenAmount,
        0,
        0,
        msg.sender,
        block.timestamp
      );
    }

    /* function addLPoolPCS(address tokenA, uint256 _amount) external payable{
        pancakeContract.addLiquidityETH{value: msg.value}(
          tokenA, 
          _amount, 
          0, 
          0, 
          creator, 
          1654633362);
    } */

    /*function AddLPCallMethod(
      uint _amountTokens, 
      uint _amounTKMin, 
      uint _amountBNBMin, 
      uint _deadLine) public payable returns(bool){
       if (!_lpContract.call(bytes4(keccak256("addLiquidityETH(address, uint, uint, uint, address, uint)")),_lpContract, _amountTokens,_amounTKMin, _amountBNBMin, msg.sender, _deadLine)) {
         return true;
       }
    } */
}