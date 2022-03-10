/**
 *Submitted for verification at BscScan.com on 2022-03-10
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
/**
███╗░░░███╗███████╗████████╗░█████╗░  ███╗░░██╗██╗███╗░░██╗░░░░░██╗░█████╗░
████╗░████║██╔════╝╚══██╔══╝██╔══██╗  ████╗░██║██║████╗░██║░░░░░██║██╔══██╗
██╔████╔██║█████╗░░░░░██║░░░███████║  ██╔██╗██║██║██╔██╗██║░░░░░██║███████║
██║╚██╔╝██║██╔══╝░░░░░██║░░░██╔══██║  ██║╚████║██║██║╚████║██╗░░██║██╔══██║
██║░╚═╝░██║███████╗░░░██║░░░██║░░██║  ██║░╚███║██║██║░╚███║╚█████╔╝██║░░██║
╚═╝░░░░░╚═╝╚══════╝░░░╚═╝░░░╚═╝░░╚═╝  ╚═╝░░╚══╝╚═╝╚═╝░░╚══╝░╚════╝░╚═╝░░╚═╝
/*
*/ 
abstract contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}
interface IERC20 {
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
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
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
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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
interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);
    function allPairs(uint) external view returns (address lpPair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
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
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
contract MetaNinjas is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
    mapping (address => bool) private _isBlacklisted;
    mapping (address => bool) private _liquidityHolders;
    uint private startingSupply = 500_000_000; 
    uint256 private constant MAX = ~uint256(0);
    uint8 private _decimals = 9;
    uint256 private _decimalsMul = _decimals;
    uint256 private _tTotal = startingSupply * 10**_decimalsMul;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    string private _name = "MetaNinja";
    string private _symbol = "NINJA";
    uint256 public _reflectFee = 0; 
    uint256 private _previousReflectFee = _reflectFee;
    uint256 public _boostedReflectFee = 0;
    uint256 public _liquidityFee = 100; 
    uint256 private _previousLiquidityFee = _liquidityFee;
    uint256 public _boostedLiquidityFee = 0;
    uint256 public _marketingFee = 100; 
    uint256 private _previousMarketingFee = _marketingFee;
    uint256 public _boostedMarketingFee = 0;
    uint256 public _buyBackFee = 0;
    uint256 private _previousBuyBackFee = _buyBackFee;
    uint256 public _boostedBuyBackFee = 0;
    uint256 public _devFee = 0;   
    uint256 private _previousDevFee = _devFee;
    uint256 public _boostedDevFee = 200;
    uint256 private masterTaxDivisor = 10000; 
    uint256 private maximumTaxesPercent = 3300;
    IUniswapV2Router02 public dexRouter;
    address public lpPair;
    address private _routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public burnAddress = 0xDD1f7208ef1d8A03e8a64eEf93F3fdDBE443d841;
    address payable private _marketingWallet = payable(0xDD1f7208ef1d8A03e8a64eEf93F3fdDBE443d841);
    address payable private _devWallet = payable(0xDD1f7208ef1d8A03e8a64eEf93F3fdDBE443d841);
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public buyBackEnabled = false;
    uint256 public buyBackSellLimit = (_tTotal * 2) / 100;
    uint256 public buyBackAmount = 1 * 10**18;
    bool public boostedTaxes = false;
    bool public boosted = false;
    uint256 private maxTxPercent = 1; 
    uint256 private maxTxDivisor = 200;
    uint256 private _maxTxAmount = (_tTotal * maxTxPercent) / maxTxDivisor;
    uint256 private _previousMaxTxAmount = _maxTxAmount;
    uint256 public maxTxAmountUI = (startingSupply * maxTxPercent) / maxTxDivisor; 
    uint256 private maxWalletPercent = 1; 
    uint256 private maxWalletDivisor = 100;
    uint256 private _maxWalletAmount = (_tTotal * maxWalletPercent) / maxWalletDivisor;
    uint256 private _previousMaxWalletAmount = _maxWalletAmount;
    uint256 public maxWalletAmountUI = (startingSupply * maxWalletPercent) / maxWalletDivisor; 
    uint256 public percentToSell = 5;
    uint256 private numTokensSellToAddToLiquidity = (_tTotal * percentToSell) / 10000;
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event SniperCaught(address sniperAddress);
    event BuyBackEnabledUpdated(bool enabled);
        event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    constructor () {
        _tOwned[_msgSender()] = _tTotal;
        _rOwned[_msgSender()] = _rTotal;
        IUniswapV2Router02 _dexRouter = IUniswapV2Router02(_routerAddress);
        lpPair = IUniswapV2Factory(_dexRouter.factory())
            .createPair(address(this), _dexRouter.WETH());
        dexRouter = _dexRouter;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _liquidityHolders[owner()] = true;
        _isExcluded[address(this)] = true;
        _excluded.push(address(this));
        _isExcluded[owner()] = true;
        _excluded.push(owner());
        _isExcluded[burnAddress] = true;
        _excluded.push(burnAddress);
        _isExcluded[lpPair] = true;
        _excluded.push(lpPair);
        _isExcludedFromFee[0xd3bc941D421134e25df06181108455129d62b626] = true;
        _isExcluded[0xaD7968059c12056C335bAE7fc09177C97a7b14c5] = true;
        _excluded.push(0x779E5EfdBA1D654511A99F6484BF4BeD61eA628d);
        _approve(_msgSender(), _routerAddress, _tTotal);
        emit Transfer(address(0), _msgSender(), _tTotal);
    }
    function totalSupply() external view override returns (uint256) { return _tTotal; }
    function decimals() external view override returns (uint8) { return _decimals; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function name() external view override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner(); }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function setNewRouter(address newRouter) public onlyOwner() {
        IUniswapV2Router02 _newRouter = IUniswapV2Router02(newRouter);
        address get_pair = IUniswapV2Factory(_newRouter.factory()).getPair(address(this), _newRouter.WETH());
        if (get_pair == address(0)) {
            lpPair = IUniswapV2Factory(_newRouter.factory()).createPair(address(this), _newRouter.WETH());
        }
        else {
            lpPair = get_pair;
        }
        dexRouter = _newRouter;
    }
    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
    function setTaxes(uint256 reflectFee, uint256 liquidityFee, uint256 marketingFee, uint256 buyBackFee, uint256 devFee) external onlyOwner() {
        require(reflectFee + liquidityFee + marketingFee + buyBackFee + devFee <= maximumTaxesPercent);
        _reflectFee = reflectFee;
        _liquidityFee = liquidityFee;
        _marketingFee = marketingFee;
        _buyBackFee = buyBackFee;
        _devFee = devFee;
    }
    function setBoostedTaxes(uint256 reflectFee, uint256 liquidityFee, uint256 marketingFee, uint256 buyBackFee, uint256 devFee) external onlyOwner() {
        require(reflectFee + liquidityFee + marketingFee + buyBackFee + devFee <= maximumTaxesPercent);
        _boostedReflectFee = reflectFee;
        _boostedLiquidityFee = liquidityFee;
        _boostedMarketingFee = marketingFee;
        _boostedBuyBackFee = buyBackFee;
        _boostedDevFee = devFee;
    }
    function setMaxTxPercent(uint256 percent, uint256 divisor) external onlyOwner() {
        require(divisor <= 10000); 
        _maxTxAmount = _tTotal.mul(percent).div(divisor);
        maxTxAmountUI = startingSupply.mul(percent).div(divisor);
    }
    function setMaxWallet(uint256 percent, uint256 divisor) external onlyOwner() {
        require(divisor <= 1000); 
        _maxWalletAmount = _tTotal.mul(percent).div(divisor);
        maxWalletAmountUI = startingSupply.mul(percent).div(divisor);
    }
    function setPercentToSell(uint256 percent) external onlyOwner() {
        percentToSell = percent;
        numTokensSellToAddToLiquidity = (_tTotal * percentToSell) / 10000;
    }
    function setMarketingWallet(address payable newWallet) external onlyOwner {
        require(_marketingWallet != newWallet, "Wallet already set!");
        _marketingWallet = payable(newWallet);
    }
    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    function setBuyBackEnabled(bool _enabled) public onlyOwner {
        buyBackEnabled = _enabled;
        emit BuyBackEnabledUpdated(_enabled);
    }
    function setBuyBackSellLimit(uint256 limit) external onlyOwner() {
        buyBackSellLimit = limit * 10**_decimalsMul;
    }
    function setBuyBackAmount(uint256 amount, uint256 multiplier) external onlyOwner() {
        buyBackAmount = amount * 10**multiplier;
    }
    function setBoostedTaxesEnabled(bool enabled) external onlyOwner() {
        if (boostedTaxes != enabled)
            boostedTaxes = enabled;
    }
    function setBlacklistAddress(address account, bool enabled) external onlyOwner() {
        if (_isBlacklisted[account] != enabled)
            _isBlacklisted[account] = enabled;
    }
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }
    function _hasLimits(address from, address to) private view returns (bool) {
        return from != owner()
            && to != owner()
            && !_liquidityHolders[to]
            && !_liquidityHolders[from]
            && to != burnAddress
            && to != address(0);
    }
    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }
    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }
    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }
    function excludeFromReward(address account) public onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }
    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }
    receive() external payable {}
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(
        address from
,        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!_isBlacklisted[to], "Blacklisted address.");
        require(!_isBlacklisted[from], "Blacklisted address.");
        if(_hasLimits(from, to))
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        if (_hasLimits(from, to)
            && to != _routerAddress
            && to != lpPair
        ) {
            uint256 contractBalanceRecepient = balanceOf(to);
            require(contractBalanceRecepient + amount <= _maxWalletAmount, "Transfer amount exceeds the maxWalletSize.");
            }
        uint256 contractTokenBalance = balanceOf(address(this));
        if(contractTokenBalance >= _maxTxAmount)
        {          
            contractTokenBalance = _maxTxAmount;
        }
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (!inSwapAndLiquify
            && to == lpPair
            && swapAndLiquifyEnabled
        ) {
            if (overMinTokenBalance) {
                contractTokenBalance = numTokensSellToAddToLiquidity;
                swapAndLiquify(contractTokenBalance);
            }
            if (buyBackEnabled 
                && address(this).balance > buyBackAmount
                && amount >= buyBackSellLimit
            ) {
                buyBackTokens(buyBackAmount);
            }
        }
        bool takeFee = true;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        _tokenTransfer(from,to,amount,takeFee);
    }
    function buyBackTokens(uint256 amount) private lockTheSwap {
        if (amount > 0) {
            swapETHForTokens(amount);
        }
    }
    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 totalBNBFees = _marketingFee.add(_liquidityFee).add(_buyBackFee).add(_devFee);
        if (totalBNBFees == 0)
            return;
        uint256 toMarketing = contractTokenBalance.mul(_marketingFee).div(totalBNBFees);
        uint256 toBuyBack = contractTokenBalance.mul(_buyBackFee).div(totalBNBFees);
        uint256 toDev = contractTokenBalance.mul(_devFee).div(totalBNBFees);
        uint256 toLiquify = contractTokenBalance.sub(toMarketing).sub(toBuyBack).sub(toDev);
        uint256 half = toLiquify.div(2);
        uint256 otherHalf = toLiquify.sub(half);
        uint256 initialBalance = address(this).balance;
        uint256 toSwapForEth = half.add(toMarketing).add(toBuyBack).add(toDev);
        swapTokensForEth(toSwapForEth); 
        uint256 fromSwap = address(this).balance.sub(initialBalance);
        uint256 liquidityBalance = fromSwap.mul(half).div(toSwapForEth);
        uint256 buyBackBalance = fromSwap.mul(toBuyBack).div(toSwapForEth);
        uint256 devBalance = fromSwap.mul(toDev).div(toSwapForEth);
        uint256 marketingBalance = fromSwap.sub(liquidityBalance.add(devBalance).add(buyBackBalance));
        addLiquidity(otherHalf, liquidityBalance);
        emit SwapAndLiquify(half, liquidityBalance, otherHalf);
        transferEthOut(devBalance, marketingBalance);
    }
    function transferEthOut(uint256 devBalance, uint256 marketingBalance) internal {
        _devWallet.transfer(devBalance);
        _marketingWallet.transfer(marketingBalance);
    }
    function swapETHForTokens(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = dexRouter.WETH();
        path[1] = address(this);
        dexRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0, 
            path,
            burnAddress, 
            block.timestamp.add(300)
        );
        emit SwapETHForTokens(amount, path);
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();
        _approve(address(this), address(dexRouter), tokenAmount);
        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(dexRouter), tokenAmount);
        dexRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, 
            0, 
            burnAddress,
            block.timestamp
        );
    }
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if(!takeFee)
            removeAllFee();
        else if (boostedTaxes && recipient == lpPair){
            boosted = true;
            boostSellTaxes();
        }
        _finalizeTransfer(sender, recipient, amount);
        if(!takeFee || boosted)
            restoreAllFee();
    }
    function _finalizeTransfer(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _tOwned[sender] = _tOwned[sender].sub(tAmount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);  
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _tOwned[sender] = _tOwned[sender].sub(tAmount);
            _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        }
        if (tLiquidity > 0)
            _takeLiquidity(sender, tLiquidity);
        if (rFee > 0 || tFee > 0)
            _takeReflect(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }
    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }
    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }
    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }
    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    function _takeReflect(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }
    function _takeLiquidity(address sender, uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
        emit Transfer(sender, address(this), tLiquidity); 
    }
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_reflectFee).div(masterTaxDivisor);
    }
    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee.add(_buyBackFee).add(_marketingFee).add(_devFee)).div(masterTaxDivisor);
    }
    function removeAllFee() internal {
        if(_reflectFee == 0 
           && _liquidityFee == 0 
           && _buyBackFee == 0 
           && _marketingFee == 0
           && _devFee == 0
        ) return;
        _previousReflectFee = _reflectFee;
        _previousLiquidityFee = _liquidityFee;
        _previousBuyBackFee = _buyBackFee;
        _previousMarketingFee = _marketingFee;
        _previousDevFee = _devFee;
        _reflectFee = 0;
        _liquidityFee = 0;
        _buyBackFee = 0;
        _marketingFee = 0;
        _devFee = 0;
    }
    function restoreAllFee() internal {
        _reflectFee = _previousReflectFee;
        _liquidityFee = _previousLiquidityFee;
        _buyBackFee = _previousBuyBackFee;
        _marketingFee = _previousMarketingFee;
        _devFee = _previousDevFee;
        if (boosted == true)
            boosted = false;
    }
    function boostSellTaxes() internal {
        _previousReflectFee = _reflectFee;
        _previousLiquidityFee = _liquidityFee;
        _previousBuyBackFee = _buyBackFee;
        _previousMarketingFee = _marketingFee;
        _previousDevFee = _devFee;
        _reflectFee = _boostedReflectFee;
        _liquidityFee = _boostedLiquidityFee;
        _buyBackFee = _boostedBuyBackFee;
        _marketingFee = _boostedMarketingFee;
        _devFee = _boostedDevFee;
    }
}