/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

// SPDX-License-Identifier: Unlicened
pragma solidity 0.8.17;



interface IERC20 
{
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Context 
{

  constructor () { }
  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }


  function _msgData() internal view returns (bytes memory) {
     this; 
    return msg.data;
  }
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

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) 
  {
    require(b > 0, errorMessage);
    uint256 c = a / b;
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


contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  constructor ()  {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }


  function owner() public view returns (address) {
    return _owner;
  }


  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }


  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }


  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}


interface IUniswapV2Factory 
{
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}


interface IUniswapV2Router02 
{
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}


contract ERC20Token is Context, IERC20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  mapping (address => bool) private _isExcludedFromFee;

  uint256 private _totalSupply;
  uint256 public _maxTxAmount;
  uint8 public _decimals;
  string public _symbol;
  string public _name;
  address public marketingWallet = 0x3A75BF936D01F46Cd1faCdBC07526dE16380805c;
  address public immutable uniswapV2Pair;
  IUniswapV2Router02 public immutable uniswapV2Router;

  uint256 public _buyFee = 4;
  uint256 public _sellFee = 3;



  constructor()
  {
    _name = "test";
    _symbol = "TST";
    _decimals = 12;
    _totalSupply = 100000 * 1e12;
    _balances[msg.sender] = _totalSupply;
    _maxTxAmount = 100000 * 1e12;
    emit Transfer(address(0), msg.sender, _totalSupply);

    _isExcludedFromFee[owner()] = true;
    _isExcludedFromFee[address(this)] = true;

    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
    uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
    .createPair(address(this), _uniswapV2Router.WETH());
    uniswapV2Router = _uniswapV2Router;

  }


  function updateFeeRate(uint256 buyFee, uint256 sellFee) external onlyOwner returns(bool)
  {
    require(buyFee<15, "Too Hight Fee");
    require(sellFee<20, "Too Hight Fee");
     _buyFee = buyFee;
     _sellFee = sellFee;
     return true;
  }


  function getOwner() external view returns (address) {
    return owner();
  }


  function decimals() external view returns (uint8) {
    return _decimals;
  }


  function symbol() external view returns (string memory) {
    return _symbol;
  }


  function name() external view returns (string memory) {
    return _name;
  }

  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }


  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }


  function transfer(address recipient, uint256 amount) external returns (bool) 
  {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }



  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }


  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
    return true;
  }


  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }


  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
    return true;
  }




  function _transfer(address sender, address recipient, uint256 amount) internal 
  {

    if(!_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient])
    {
        uint256 feeRate = _buyFee;
        if(recipient==uniswapV2Pair) { feeRate=_sellFee; }
        uint256 _fee = amount.mul(feeRate).div(100);
        amount = amount.sub(_fee);
        _transferTokens(sender, marketingWallet, _fee);        
    }

     _transferTokens(sender, recipient, amount);
  
  }


  function _transferTokens(address sender, address recipient, uint256 amount) internal
  {
      require(sender != address(0), "ERC20: transfer from the zero address");
      require(recipient != address(0), "ERC20: transfer to the zero address");
      if(sender != owner() && recipient != owner()) 
      {
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
      }
      _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
      _balances[recipient] = _balances[recipient].add(amount);
      emit Transfer(sender, recipient, amount);
  }


  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }


    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }


    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
        require(_totalSupply/1000>maxTxAmount, "Min 0.1% Max Tx Amount");
        _maxTxAmount = maxTxAmount;
    }


    receive() external payable {} 
        

}