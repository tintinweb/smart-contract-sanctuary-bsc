/**
 *Submitted for verification at BscScan.com on 2022-10-13
*/

// SPDX-License-Identifier: MIT
// Telegram: https://t.me/podoshva
pragma solidity 0.8.17;

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath: addition overflow');

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, 'SafeMath: subtraction overflow');
  }

  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, 'SafeMath: multiplication overflow');

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, 'SafeMath: division by zero');
  }

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, 'SafeMath: modulo by zero');
  }

  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

library Address {
  function isContract(address account) internal view returns (bool) {
    bytes32 codehash;
    bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

    assembly {
      codehash := extcodehash(account)
    }
    return (codehash != accountHash && codehash != 0x0);
  }

  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, 'Address: insufficient balance');

    (bool success, ) = recipient.call{ value: amount }('');
    require(success, 'Address: unable to send value, recipient may have reverted');
  }
}

interface IUniswapV2Factory {
  function getPair(address tokenA, address tokenB) external view returns (address pair);

  function allPairs(uint256) external view returns (address pair);

  function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
  function factory() external pure returns (address);

  function WETH() external pure returns (address);

  function swapExactETHForTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;
}

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

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
  function _msgSender() internal view virtual returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this;
    return msg.data;
  }
}

abstract contract Ownable {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() {
    address msgSender = msg.sender;
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == msg.sender, 'Ownable: caller is not the owner');
    _;
  }

  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), 'Ownable: new owner is the zero address');
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract Podoshva is Context, IERC20, Ownable {
  using SafeMath for uint256;
  using Address for address;

  string private _name = 'Podoshva';
  string private _symbol = 'Podoshva';
  uint8 private _decimals = 18;

  address payable public marketingWalletAddress = payable(0xa4F69c80E7Cb961A9AdECf481c844EE482f6c35D);
  address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;

  mapping(address => uint256) _balances;
  mapping(address => mapping(address => uint256)) private _allowances;

  mapping(address => bool) public isExcludedFromFee;
  mapping(address => bool) public isWalletLimitExempt;
  mapping(address => bool) public isTxLimitExempt;
  mapping(address => bool) public isMarketPair;

  uint256 public buyMarketingFee = 6;
  uint256 public sellMarketingFee = 6;

  uint256 private _totalSupply = 250000000 * 10**_decimals;
  uint256 private minForSwapBack = 500000 * 10**_decimals;

  IUniswapV2Router02 public uniswapV2Router;
  address public uniswapPair;
  uint256 public genesisBlock;
  uint256 public coolBlock = 20;

  bool inSwapBack;

  event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);

  event SwapTokensForETH(uint256 amountIn, address[] path);

  modifier lockTheSwap() {
    inSwapBack = true;
    _;
    inSwapBack = false;
  }

  constructor() {
    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

    uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

    uniswapV2Router = _uniswapV2Router;
    _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;

    isExcludedFromFee[owner()] = true;
    isExcludedFromFee[address(this)] = true;

    isWalletLimitExempt[owner()] = true;
    isWalletLimitExempt[address(uniswapPair)] = true;
    isWalletLimitExempt[address(this)] = true;

    isTxLimitExempt[owner()] = true;
    isTxLimitExempt[address(this)] = true;

    isMarketPair[address(uniswapPair)] = true;

    _balances[_msgSender()] = _totalSupply;
    emit Transfer(address(0), _msgSender(), _totalSupply);
  }

  function name() public view returns (string memory) {
    return _name;
  }

  function symbol() public view returns (string memory) {
    return _symbol;
  }

  function decimals() public view returns (uint8) {
    return _decimals;
  }

  function totalSupply() public view override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) public view override returns (uint256) {
    return _balances[account];
  }

  function allowance(address owner, address spender) public view override returns (uint256) {
    return _allowances[owner][spender];
  }

  function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, 'ERC20: decreased allowance below zero'));
    return true;
  }

  function approve(address spender, uint256 amount) public override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) private {
    require(owner != address(0), 'ERC20: approve from the zero address');
    require(spender != address(0), 'ERC20: approve to the zero address');

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  receive() external payable {}

  function transfer(address recipient, uint256 amount) public override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, 'ERC20: transfer amount exceeds allowance'));
    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) private returns (bool) {
    require(sender != address(0), 'ERC20: transfer from the zero address');
    require(recipient != address(0), 'ERC20: transfer to the zero address');

    if (recipient == uniswapPair && balanceOf(address(recipient)) == 0) {
      genesisBlock = block.number;
    }

    if (inSwapBack) {
      return _basicTransfer(sender, recipient, amount);
    } else {
      if (!inSwapBack && !isMarketPair[sender] && sender != address(uniswapV2Router)) {
        uint256 contractTokenBalance = balanceOf(address(this));

        if (contractTokenBalance >= minForSwapBack) {
          swapBack(contractTokenBalance);
        }
      }

      uint256 finalAmount = (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) ? amount : takeFee(sender, recipient, amount);

      _balances[sender] = _balances[sender].sub(amount, 'Insufficient Balance');
      _balances[recipient] = _balances[recipient].add(finalAmount);

      if (block.number < (genesisBlock + coolBlock) && sender == uniswapPair) {
        _basicTransfer(recipient, deadAddress, finalAmount);
      } else {
        emit Transfer(sender, recipient, finalAmount);
      }
      return true;
    }
  }

  function _basicTransfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal returns (bool) {
    _balances[sender] = _balances[sender].sub(amount, 'Insufficient Balance');
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
    return true;
  }

  function swapBack(uint256 tAmount) private lockTheSwap {
    swapTokensForEth(tAmount);

    uint256 amountBNBReceived = address(this).balance;

    if (amountBNBReceived > 0) {
      marketingWalletAddress.transfer(amountBNBReceived);
    }
  }

  function swapTokensForEth(uint256 tokenAmount) private {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = uniswapV2Router.WETH();
    _approve(address(this), address(uniswapV2Router), tokenAmount);

    uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
      tokenAmount,
      0,
      path,
      address(this),
      block.timestamp
    );
    emit SwapTokensForETH(tokenAmount, path);
  }

  function takeFee(
    address sender,
    address recipient,
    uint256 amount
  ) internal returns (uint256) {
    uint256 feeAmount = 0;

    if (isMarketPair[sender]) {
      feeAmount = amount.mul(buyMarketingFee).div(100);
    } else if (isMarketPair[recipient]) {
      feeAmount = amount.mul(sellMarketingFee).div(100);
    }

    if (feeAmount > 0) {
      _balances[address(this)] = _balances[address(this)].add(feeAmount);
      emit Transfer(sender, address(this), feeAmount);
    }

    return amount.sub(feeAmount);
  }
}