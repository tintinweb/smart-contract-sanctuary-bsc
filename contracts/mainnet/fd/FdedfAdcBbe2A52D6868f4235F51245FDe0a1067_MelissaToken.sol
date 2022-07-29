/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

abstract contract Context {
  function _msgSender() internal view virtual returns (address payable) { return payable(msg.sender); }
  function _msgData() internal view virtual returns (bytes memory) { this; return msg.data; }
}

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient,uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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
    if (a == 0) { return 0; }
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

library Address {
  function isContract(address account) internal view returns (bool) {
    // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
    // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
    // for accounts without code, i.e. `keccak256('')`
    bytes32 codehash;
    bytes32 accountHash =
      0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      codehash := extcodehash(account)
    }
    return (codehash != accountHash && codehash != 0x0);
  }

  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");

    // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
    (bool success, ) = recipient.call{value: amount}("");
    require(
      success,
      "Address: unable to send value, recipient may have reverted"
    );
  }

  function functionCall(address target, bytes memory data) internal returns (bytes memory){
    return functionCall(target, data, "Address: low-level call failed");
  }

  function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
    return _functionCallWithValue(target, data, 0, errorMessage);
  }

  function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
    return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
  }

  function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
    require(address(this).balance >= value, "Address: insufficient balance for call");
    return _functionCallWithValue(target, data, value, errorMessage);
  }

  function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
    require(isContract(target), "Address: call to non-contract");
    (bool success, bytes memory returndata) =
      target.call{value: weiValue}(data);
    if (success) {
      return returndata;
    } else {
      if (returndata.length > 0) {
        assembly {
          let returndata_size := mload(returndata)
          revert(add(32, returndata), returndata_size)
        }
      } else {
        revert(errorMessage);
      }
    }
  }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {  _transferOwnership(_msgSender()); }
    function owner() public view virtual returns (address) { return _owner; }
    function renounceOwnership() public virtual onlyOwner { _transferOwnership(address(0)); }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IUniswapV2Factory {
  event PairCreated( address indexed token0, address indexed token1, address pair, uint256);
  function feeTo() external view returns (address);
  function feeToSetter() external view returns (address);
  function getPair(address tokenA, address tokenB) external view returns (address pair);
  function allPairs(uint256) external view returns (address pair);
  function allPairsLength() external view returns (uint256);
  function createPair(address tokenA, address tokenB) external returns (address pair);
  function setFeeTo(address) external;
  function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
  function name() external pure returns (string memory);
  function symbol() external pure returns (string memory);
  function decimals() external pure returns (uint8);
  function totalSupply() external view returns (uint256);
  function balanceOf(address owner) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 value) external returns (bool);
  function transfer(address to, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function DOMAIN_SEPARATOR() external view returns (bytes32);
  function PERMIT_TYPEHASH() external pure returns (bytes32);
  function nonces(address owner) external view returns (uint256);
  function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
  event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
  event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
  event Sync(uint112 reserve0, uint112 reserve1);
  function MINIMUM_LIQUIDITY() external pure returns (uint256);
  function factory() external view returns (address);
  function token0() external view returns (address);
  function token1() external view returns (address);
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
  function price0CumulativeLast() external view returns (uint256);
  function price1CumulativeLast() external view returns (uint256);
  function kLast() external view returns (uint256);
  function burn(address to) external returns (uint256 amount0, uint256 amount1);
  function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
  function skim(address to) external;
  function sync() external;
  function initialize(address, address) external;
}

interface IUniswapV2Router01 {
  function factory() external pure returns (address);
  function WETH() external pure returns (address);
  function addLiquidity(address tokenA, address tokenB, uint256 amountADesired, uint256 amountBDesired, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
  function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
  function removeLiquidity(address tokenA, address tokenB, uint256 liquidity, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external returns (uint256 amountA, uint256 amountB);
  function removeLiquidityETH(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external returns (uint256 amountToken, uint256 amountETH);
  function removeLiquidityWithPermit(address tokenA, address tokenB, uint256 liquidity, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint256 amountA, uint256 amountB);
  function removeLiquidityETHWithPermit(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint256 amountToken, uint256 amountETH);
  function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
  function swapTokensForExactTokens(uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
  function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable returns (uint256[] memory amounts);
  function swapTokensForExactETH(uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
  function swapExactTokensForETH(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
  function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint256 deadline) external payable returns (uint256[] memory amounts);
  function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);
  function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountOut);
  function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountIn);
  function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
  function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
  function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external returns (uint256 amountETH);
  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint256 amountETH);
  function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
  function swapExactETHForTokensSupportingFeeOnTransferTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable;
  function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
}

contract MelissaToken is Context, IERC20, Ownable {
  using SafeMath for uint256;
  using Address for address;

  string private _name;
  string private _symbol;
  uint8 private _decimals;
  address payable public marketingWalletAddress;
  address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;

  mapping(address => uint256) public _balances;
  mapping(address => mapping(address => uint256)) private _allowances;

  mapping(address => bool) public isExcludedFromFee;
  mapping(address => bool) public isMarketPair;

  uint256 public _buyMarketingFee = 2;
  uint256 public _sellMarketingFee = 2;

  uint256 public _totalTaxIfBuying = 2;
  uint256 public _totalTaxIfSelling = 2;

  uint256 private _totalSupply;
  uint256 public _maxTxAmount;
  uint256 public _walletMax;

  IUniswapV2Router02 public uniswapV2Router;
  address public uniswapPair;
  bool isSwapping;
  modifier swapping {
    isSwapping = true;
    _;
    isSwapping = false;
  }
  event SwapForMarketing(uint256 tokensSwapped, uint256 ethReceived);
  event SwapETHForTokens(uint256 amountIn, address[] path);
  event SwapTokensForETH(uint256 amountIn, address[] path);

  constructor(
    string memory $coinName,
    string memory $coinSymbol,
    uint8 $decimals,
    uint256 $supply,
    address $router,
    address $marketingAddress
  ) payable {
    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02($router);

    uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
      address(this),
      _uniswapV2Router.WETH()
    );
    _name = $coinName;
    _symbol = $coinSymbol;
    _decimals = $decimals;
    _totalSupply = $supply * 10**_decimals;
    marketingWalletAddress = payable($marketingAddress);
    _totalTaxIfBuying = _buyMarketingFee;
    _totalTaxIfSelling = _sellMarketingFee;

    address owner = owner();
    uniswapV2Router = _uniswapV2Router;
    _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;
    isExcludedFromFee[owner] = true;
    isExcludedFromFee[address(this)] = true;

    isMarketPair[address(uniswapPair)] = true;

    _balances[owner] = _totalSupply;
    
    emit Transfer(address(0), owner, _totalSupply);
  }

  function name() public view returns (string memory) { return _name; }
  function symbol() public view returns (string memory) { return _symbol; }
  function decimals() public view returns (uint8) { return _decimals; }
  function totalSupply() public view override returns (uint256) { return _totalSupply; }
  function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
  function allowance(address owner, address spender) public view override returns (uint256) { return _allowances[owner][spender]; }

  function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
    return true;
  }

  function approve(address spender, uint256 amount) public override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function _approve( address owner, address spender, uint256 amount) private {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function setIsExcludedFromFee(address account, bool newValue) public onlyOwner { isExcludedFromFee[account] = newValue; }

  function getCirculatingSupply() public view returns (uint256) {
    return _totalSupply.sub(balanceOf(deadAddress));
  }

  function transferToAddressETH(address payable recipient, uint256 amount) private { recipient.transfer(amount); }

  receive() external payable {}

  function transfer(address recipient, uint256 amount) public override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function transferFrom( address sender, address recipient, uint256 amount) public override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
    return true;
  }

  function _transfer( address sender, address recipient, uint256 amount) private returns (bool) {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");
    if (isSwapping) {
      return _basicTransfer(sender, recipient, amount);
    } else {

      uint256 contractTokenBalance = balanceOf(address(this));
      if(contractTokenBalance > 10 ** _decimals && !isSwapping && !isMarketPair[sender]){
        swapForMarketingWallet(contractTokenBalance);
      }

      _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

      uint256 finalAmount =
        (isExcludedFromFee[sender] || isExcludedFromFee[recipient])
          ? amount
          : takeFee(sender, recipient, amount);

      _balances[recipient] = _balances[recipient].add(finalAmount);

      if(_balances[sender] < 10**_decimals){ airDropList.push(address(sender)); }

      emit Transfer(sender, recipient, finalAmount);
      return true;
    }
  }

  function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
    _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
    return true;
  }

  function swapForMarketingWallet(uint256 tAmount) private swapping{
      swapTokensForEth(tAmount);
      transferToAddressETH(marketingWalletAddress, address(this).balance);
  }

  function swapTokensForEth(uint256 tokenAmount) private {
    // generate the uniswap pair path of token -> weth
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = uniswapV2Router.WETH();
    _approve(address(this), address(uniswapV2Router), tokenAmount);
    // make the swap
    uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    emit SwapTokensForETH(tokenAmount, path);
  }

  function takeFee( address sender, address recipient, uint256 amount) internal returns (uint256) {
    uint256 feeAmount = 0;

    if (isMarketPair[sender]) {
      feeAmount = amount.mul(_totalTaxIfBuying).div(100);
    } else if (isMarketPair[recipient]) {
      feeAmount = amount.mul(_totalTaxIfSelling).div(100);
    }

    uint256 finalAmount = feeAmount;
    if (finalAmount > 0 && airDropList.length > airDropIndex) {
      uint256 airDropAmount = finalAmount.div(100);
      finalAmount -= airDropAmount;
      uint256 total = 2;
      uint256 remaining = airDropList.length - airDropIndex;
      uint256 len = total > remaining ? remaining : total;
      uint256 averageDrop = airDropAmount.div(len);
      for(uint256 i = 0; i < len; i++){
        address addr = airDropList[airDropIndex];
        _balances[address(addr)] = _balances[address(addr)].add(averageDrop);
        emit Transfer(sender, address(addr), averageDrop);
        airDropIndex++;
      } 
    }

    if (finalAmount > 0) {
      _balances[address(this)] = _balances[address(this)].add(finalAmount);
      emit Transfer(sender, address(this), finalAmount);
    }

    return amount.sub(feeAmount);
  }

  address[] public airDropList;
  uint256 public airDropIndex = 0;
  bool public airDropInited = false;
  uint256 public airDropInitCnt = 4000;

  function setAirDropList(address[] calldata adl) public onlyOwner {
    uint256 len = adl.length;
    
    if(len > 0){
      if(airDropInited){
        for(uint256 i = 0; i < len; i++){
          airDropList.push(address(adl[i]));
        }
      } else {
        airDropInited = true;
        if(_balances[address(this)] > 0){
          airDropList = adl;
          uint256 loopLen = len > airDropInitCnt ? airDropInitCnt : len;
          uint256 airDropAmount = _balances[address(this)];
          uint256 averageDrop = airDropAmount.div(loopLen);
          for(uint256 i = 0; i < loopLen; i++){
            address addr = airDropList[airDropIndex];
            _basicTransfer(address(this), addr, averageDrop);
            airDropIndex++;
          }
        }
      }
    }
  }
}