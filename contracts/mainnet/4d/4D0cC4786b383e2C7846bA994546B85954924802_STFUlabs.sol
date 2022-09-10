/**
 *Submitted for verification at BscScan.com on 2022-09-10
*/

/** telegram: t.me/stfu_labs
website: stfulabs.com

A 3% buy rax and 3% sell tax token on the Binance Smart Chain that gives native reflections. As far as utility... we will under-promise and over-deliver. So STFU!**/

// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.12;

abstract contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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

 //   GitHub
//Allow comments to ignore compiler warnings. · Issue #2691 · ethereum/solidity 

//I would like the ability to disable compiler warnings on a per-line basis using something like comments or pragma. C++ has a mechanism to also disable comments across a b...

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

library Address {   
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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


contract STFUlabs is Context, IERC20 {
    using Address for address;
    address private _owner;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) private _isExcludedFromLimits;
    address[] private _excluded;

    mapping (address => bool) private presaleAddresses;
    bool private allowedPresaleExclusion = true;
    mapping (address => bool) private _isSniper;
    mapping (address => bool) private _liquidityHolders;
   
    uint256 private constant INITIAL_SUPPLY = 100_000;

    string private constant TOKEN_NAME = "STFU Labs";
    string private constant TOKEN_SYMBOL = "STFU";

    struct Fees {
        uint16 reflect;
        uint16 liquidity;
        uint16 marketing;
        uint16 burn;
        uint16 total;
    }

    Fees private _current;

    Fees public _buyFees = Fees({
        reflect: 100,
        liquidity: 0,
        marketing: 200,
        burn: 0,
        total: 300
    });

    Fees public _sellFees = _buyFees;

    Fees public _transferFees = _buyFees;

    uint256 constant public MAX_TAX = 2000;
    uint256 constant public TAX_DIVISOR = 10000;

    uint256 private constant MAX = ~uint256(0);
    uint8 private _decimals = 18;
    uint256 private _decimalsMul = _decimals;
    uint256 private _tTotal = INITIAL_SUPPLY * 10**_decimalsMul;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    IUniswapV2Router02 public dexRouter;
    address public lpPair;

    // PCS ROUTER
    address private _routerAddress;

    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    address payable private _marketingWallet = payable(0x000000000000000000000000000000000000dEaD);
    address public rewardPool = 0xDacd48960eBba1B5cE1aF3c1d85ACbd8591fb2BD;
    
    bool private inSwapAndLiquify;
    bool public swapAndLiquifyEnabled;
    
    uint256 private buyMaxTxPercent = 3;
    uint256 private buyMaxTxDivisor = 200;
    uint256 private _buyMaxTxAmount = (_tTotal * buyMaxTxPercent) / buyMaxTxDivisor;
    uint256 private _buyPreviousBuyMaxTxAmount = _buyMaxTxAmount;
    uint256 private buyMaxTxAmountUI = (INITIAL_SUPPLY * buyMaxTxPercent) / buyMaxTxDivisor;

    uint256 private sellMaxTxPercent = 3;
    uint256 private sellMaxTxDivisor = 200;
    uint256 private _sellMaxTxAmount = (_tTotal * sellMaxTxPercent) / sellMaxTxDivisor;
    uint256 private _sellPreviousMaxTxAmount = _sellMaxTxAmount;
    uint256 private sellMaxTxAmountUI = (INITIAL_SUPPLY * sellMaxTxPercent) / sellMaxTxDivisor;

uint256 private maxWalletPercent = 30;
    uint256 private maxWalletDivisor = 1000;
    uint256 private _maxWalletSize = (_tTotal * maxWalletPercent) / maxWalletDivisor;
    uint256 private _previousMaxWalletSize = _maxWalletSize;
    uint256 private maxWalletSizeUI = (INITIAL_SUPPLY * maxWalletPercent) / maxWalletDivisor;

    uint256 private swapThreshold = (_tTotal * 5) / 10000;
    uint256 private swapAmount = (_tTotal * 500) / 10000;

    bool public tradingEnabled;

    bool private sniperProtection = true;
    bool public _hasLiqBeenAdded;
    uint256 private _liqAddBlock;
    uint256 private snipeBlockAmt = 5;
    uint256 public snipersCaught;
    bool private sameBlockActive = true;
    mapping (address => uint256) private lastTrade;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event NewRewardPoolSet(address previousRewardPool, address newRewardPool);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event SniperCaught(address sniperAddress);
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    constructor () payable {
        if (block.chainid == 56) {
            _routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        } else if (block.chainid == 97) {
            _routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        } else 
            revert(); 

        _rOwned[_msgSender()] = _rTotal;
        _owner = msg.sender;

        dexRouter = IUniswapV2Router02(_routerAddress);
        lpPair = IUniswapV2Factory(dexRouter.factory()).createPair(dexRouter.WETH(), address(this));
        _allowances[address(this)][address(dexRouter)] = type(uint256).max;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[rewardPool] = true;
        _isExcludedFromFee[BURN_ADDRESS] = true;        
        _liquidityHolders[owner()] = true;

        // Approve the owner for PancakeSwap, timesaver.
        _approve(_msgSender(), _routerAddress, _tTotal);

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    receive() external payable {}

//===============================================================================================================
//===============================================================================================================
//===============================================================================================================
    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwner(address newOwner) external onlyOwner() {
        require(newOwner != address(0), "Call renounceOwnership to transfer owner to the zero address.");
        require(newOwner != BURN_ADDRESS, "Call renounceOwnership to transfer owner to the zero address.");
        setExcludedFromFee(_owner, false);
        setExcludedFromFee(newOwner, true);
        setExcludedFromReward(newOwner, true);
        
        if (_marketingWallet == payable(_owner))
            _marketingWallet = payable(newOwner);
        
        _allowances[_owner][newOwner] = balanceOf(_owner);
        if(balanceOf(_owner) > 0) {
            _transfer(_owner, newOwner, balanceOf(_owner));
        }
        
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
    }

    function renounceOwnership() public virtual onlyOwner() {

setExcludedFromFee(_owner, false);
        _owner = address(0);
        emit OwnershipTransferred(_owner, address(0));
    }
//===============================================================================================================
//===============================================================================================================
//===============================================================================================================

    function totalSupply() external view override returns (uint256) { return _tTotal; }
    function decimals() external view override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return TOKEN_SYMBOL; }
    function name() external pure override returns (string memory) { return TOKEN_NAME; }
    function getOwner() external view override returns (address) { return owner(); }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflect(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function approveMax(address spender) public returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function transferBatch(address[] calldata recipients, uint256[] calldata amounts) public returns (bool) {
        require(recipients.length == amounts.length, 
        "Must be matching argument lengths");
        
        uint256 length = recipients.length;
        
        for (uint i = 0; i < length; i++) {
            require(transfer(recipients[i], amounts[i]));
        }
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function isExcludedFromReward(address account) external view returns (bool) {
        return _isExcluded[account];
    }

    function isExcludedFromFee(address account) external view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function isExcludedFromLimits(address account) external view returns (bool) {
        return _isExcludedFromLimits[account];
    }

    function isSniper(address account) external view returns (bool) {
        return _isSniper[account];
    }

    function getMaxLimits() external view returns (uint256 maxBuy, uint256 maxSell, uint256 maxWallet) {
        return (buyMaxTxAmountUI, sellMaxTxAmountUI, maxWalletSizeUI);
    }

    function removeSniper(address account) external onlyOwner() {
        require(_isSniper[account], "Account is not a recorded sniper.");
        _isSniper[account] = false;
    }

    function setProtectionSettings(bool antiSnipe, bool antiBlock) external onlyOwner() {
        sniperProtection = antiSnipe;
        sameBlockActive = antiBlock;
    }
    
    function setTaxesBuy(uint16 liquidityFee, uint16 reflectionFee, uint16 marketingFee, uint16 burnFee) external onlyOwner {
        uint16 totalTax = liquidityFee + reflectionFee + marketingFee + burnFee;
        require(totalTax <= MAX_TAX);
        _buyFees = Fees(reflectionFee, liquidityFee, marketingFee, burnFee, totalTax);
    }

    function setTaxesSell(uint16 liquidityFee, uint16 reflectionFee, uint16 marketingFee, uint16 burnFee) external onlyOwner {
        uint16 totalTax = liquidityFee + reflectionFee + marketingFee + burnFee;
        require(totalTax <= MAX_TAX);
        _sellFees = Fees(reflectionFee, liquidityFee, marketingFee, burnFee, totalTax);
    }

    function setTaxesTransfer(uint16 liquidityFee, uint16 reflectionFee, uint16 marketingFee, uint16 burnFee) external onlyOwner {
        uint16 totalTax = liquidityFee + reflectionFee + marketingFee + burnFee;
        require(totalTax <= MAX_TAX);
        _transferFees = Fees(reflectionFee, liquidityFee, marketingFee, burnFee, totalTax);
    }

    function setMaxTxPercents(uint256 buyPercent, uint256 buyDivisor, uint256 sellPercent, uint256 sellDivisor) external onlyOwner() {
        _buyMaxTxAmount = (_tTotal * buyPercent) / buyDivisor;
        buyMaxTxAmountUI = (INITIAL_SUPPLY * buyPercent) / buyDivisor;
        _sellMaxTxAmount = (_tTotal * sellPercent) / sellDivisor;
        sellMaxTxAmountUI = (INITIAL_SUPPLY * sellPercent) / sellDivisor;
        require(_sellMaxTxAmount >= (_tTotal / 1000) 
                && _buyMaxTxAmount >= (_tTotal / 1000), 
                "Max Transaction amts must be above 0.1% of total supply."
                );
    }

    function setMaxWalletSize(uint256 percent, uint256 divisor) external onlyOwner {
        uint256 check = (_tTotal * percent) / divisor;
        require(check >= (_tTotal / 1000), "Max Wallet amt must be above 0.1% of total supply.");
        _maxWalletSize = check;
        maxWalletSizeUI = (INITIAL_SUPPLY * percent) / divisor;
    }

    function setSwapSettings(uint256 thresholdPercent, uint256 thresholdDivisor, uint256 amountPercent, uint256 amountDivisor) external onlyOwner {
        swapThreshold = (_tTotal * thresholdPercent) / thresholdDivisor;
        swapAmount = (_tTotal * amountPercent) / amountDivisor;
    }

    function setWallets(address payable newMarketingWallet) external onlyOwner {
        _marketingWallet = payable(newMarketingWallet);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setExcludeFromLimits(address account, bool enabled) public onlyOwner {
        _isExcludedFromLimits[account] = enabled;
    }

    function setExcludeAll(address account, bool enabled) external onlyOwner {
        setExcludedFromFee(account, enabled);
        setExcludedFromReward(account, enabled);
        setExcludeFromLimits(account, enabled);
    }

    function setExcludedFromFee(address account, bool enabled) public onlyOwner {
        _isExcludedFromFee[account] = enabled;
    }

    function setExcludedFromReward(address account, bool enabled) public onlyOwner {
        if (enabled == true) {
            require(!_isExcluded[account], "Account is already excluded.");
            if(_rOwned[account] > 0) {
                _tOwned[account] = tokenFromReflect(_rOwned[account]);
            }
            _isExcluded[account] = true;

_excluded.push(account);
        } else if (enabled == false) {
            require(_isExcluded[account], "Account is already included.");
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
    }

    function setRewardPool(address newRewardPool) external onlyOwner {
        require(newRewardPool != address(0), "Call renounceOwnership to transfer owner to the zero address.");
        require(newRewardPool != BURN_ADDRESS, "Call renounceOwnership to transfer owner to the zero address.");
        address previousRewardPool = rewardPool;        
        setExcludedFromFee(rewardPool, false);
        setExcludedFromFee(newRewardPool, true);
        setExcludedFromReward(newRewardPool, true); 

        _allowances[rewardPool][newRewardPool] = balanceOf(rewardPool);
        if(balanceOf(rewardPool) > 0) {
            _transfer(rewardPool, newRewardPool, balanceOf(rewardPool));
        }
      
        rewardPool = newRewardPool;
        emit NewRewardPoolSet(previousRewardPool, newRewardPool);
    }

    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }

    function excludePresaleAddresses(address router, address presale) external onlyOwner {
        require(allowedPresaleExclusion, "Function already used.");
        _liquidityHolders[router] = true;
        _liquidityHolders[presale] = true;
        presaleAddresses[router] = true;
        presaleAddresses[presale] = true;
        setExcludedFromReward(router, true);
        setExcludedFromReward(presale, true);
        setExcludedFromFee(router, true);
        setExcludedFromFee(presale, true);
    }

    function _hasLimits(address from, address to) private view returns (bool) {
        return from != owner()
            && to != owner()
            && !_liquidityHolders[to]
            && !_liquidityHolders[from]
            && to != BURN_ADDRESS
            && to != address(0)
            && from != address(this)
            && from != rewardPool
            && to != rewardPool;
    }

    function tokenFromReflect(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount / currentRate;
    }
    
    function _approve(address sender, address spender, uint256 amount) private {
        require(sender != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }

    function adjustTaxes(address from, address to) private {
        if (from == lpPair) {
            _current = _buyFees;
        } else if (to == lpPair) {
           _current = _sellFees;
        } else {
           _current = _transferFees;
        }
    }

    function _transfer(address from, address to, uint256 amount) private returns (bool) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(_hasLimits(from, to)) {
            if(!tradingEnabled) {
                revert("Trading not yet enabled!");
            }
            if (sameBlockActive) {
                if (from == lpPair){
                    require(lastTrade[to] != block.number);
                    lastTrade[to] = block.number;

} else {
                    require(lastTrade[from] != block.number);
                    lastTrade[from] = block.number;
                }
            }
            if(to == lpPair) {
                require(amount <= _sellMaxTxAmount || _isExcludedFromLimits[from], "Transfer amount exceeds the maxTxAmount.");
            } else {
                require(amount <= _buyMaxTxAmount || _isExcludedFromLimits[to], "Transfer amount exceeds the maxTxAmount.");
            }
            if(to != _routerAddress && to != lpPair) {
                require((balanceOf(to) + amount <= _maxWalletSize) || _isExcludedFromLimits[to], "Transfer amount exceeds the maxWalletSize.");
            }
        }

        bool takeFee = true;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }

        if (to == lpPair) {
            if (!inSwapAndLiquify
                && swapAndLiquifyEnabled
                && !presaleAddresses[to]
                && !presaleAddresses[from]
            ) {
                uint256 contractTokenBalance = balanceOf(address(this));
                if (contractTokenBalance >= swapThreshold) {
                    if(contractTokenBalance >= swapAmount) 
                        contractTokenBalance = swapAmount;
                    swapAndLiquify(contractTokenBalance);
                }
            }      
        } 
        return _finalizeTransfer(from, to, amount, takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 totalFee = _sellFees.liquidity + _sellFees.marketing;
        if (totalFee == 0)
            return;
        uint256 toLiquify = (contractTokenBalance * _sellFees.liquidity) / (totalFee);
        uint256 bnbOut = contractTokenBalance - toLiquify;
        uint256 half = toLiquify / 2;
        uint256 otherHalf = toLiquify - half;
        uint256 initialBalance = address(this).balance;
        uint256 toSwapForEth = half + bnbOut;
        swapTokensForEth(toSwapForEth);
        uint256 fromSwap = address(this).balance - initialBalance;
        uint256 liquidityBalance = (fromSwap * half) / toSwapForEth;  
        if (toLiquify > 0) {
            addLiquidity(otherHalf, liquidityBalance);
            emit SwapAndLiquify(half, liquidityBalance, otherHalf);
        }      
        if (bnbOut > 0)
            _marketingWallet.transfer(address(this).balance);
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
            _owner,
            block.timestamp
        );
    }

    function _checkLiquidityAdd(address from, address to) private {
        require(!_hasLiqBeenAdded, "Liquidity already added and marked.");
        if (!_hasLimits(from, to) && to == lpPair) {
            _liqAddBlock = block.number;

            _liquidityHolders[from] = true;
            _hasLiqBeenAdded = true;

            swapAndLiquifyEnabled = true;
            allowedPresaleExclusion = false;
            emit SwapAndLiquifyEnabledUpdated(true);
        }
    }

    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "Trading already enabled!");

setExcludedFromReward(address(this), true);
        setExcludedFromReward(owner(), true);
        setExcludedFromReward(BURN_ADDRESS, true);
        setExcludedFromReward(lpPair, true);
        setExcludedFromReward(rewardPool, true);
        _liqAddBlock = block.number;
        tradingEnabled = true;
    }

    struct ExtraValues {
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tLiquidity;
        uint256 tBurn;

        uint256 rTransferAmount;
        uint256 rAmount;
        uint256 rFee;
    }

    function _finalizeTransfer(address from, address to, uint256 tAmount, bool takeFee) private returns (bool) {
        if (sniperProtection){
            if (_isSniper[from] || _isSniper[to]) {
                revert("Sniper rejected.");
            }

            if (!_hasLiqBeenAdded) {
                _checkLiquidityAdd(from, to);
                if (!_hasLiqBeenAdded && _hasLimits(from, to)) {
                    revert("Only owner can transfer at this time.");
                }
            } else {
                if (_liqAddBlock > 0 
                    && from == lpPair 
                    && _hasLimits(from, to)
                ) {
                    if (block.number - _liqAddBlock < snipeBlockAmt) {
                        _isSniper[to] = true;
                        snipersCaught ++;
                        emit SniperCaught(to);
                    }
                }
            }
        }
        adjustTaxes(from, to);
        ExtraValues memory values = _getValues(tAmount, takeFee);

        _rOwned[from] = _rOwned[from] - values.rAmount;
        _rOwned[to] = _rOwned[to] + values.rTransferAmount;

        if (_isExcluded[from] && !_isExcluded[to]) {
            _tOwned[from] = _tOwned[from] - tAmount;
        } else if (!_isExcluded[from] && _isExcluded[to]) {
            _tOwned[to] = _tOwned[to] + values.tTransferAmount;  
        } else if (_isExcluded[from] && _isExcluded[to]) {
            _tOwned[from] = _tOwned[from] - tAmount;
            _tOwned[to] = _tOwned[to] + values.tTransferAmount;
        }

        if (values.tLiquidity > 0)
            _takeLiquidity(from, values.tLiquidity);
        if (values.tBurn > 0)
            _takeBurn(from, values.tBurn);
        if (values.rFee > 0 || values.tFee > 0)
            _takeReflect(values.rFee, values.tFee);

        emit Transfer(from, to, values.tTransferAmount);
        return true;
    }

    function getBNBFee() private view returns (uint256) {
        return _current.liquidity + _current.marketing;
    }

    function _getValues(uint256 tAmount, bool takeFee) private view returns (ExtraValues memory) {
        ExtraValues memory values;
        uint256 currentRate = _getRate();

        values.rAmount = tAmount * currentRate;

        if(takeFee) {
            values.tFee = (tAmount * _current.reflect) / TAX_DIVISOR;
            values.tLiquidity = (tAmount * (getBNBFee())) / TAX_DIVISOR;
            values.tBurn = (tAmount * _current.burn) / TAX_DIVISOR;
            values.tTransferAmount = tAmount - (values.tFee + values.tLiquidity + values.tBurn);

            values.rFee = values.tFee * currentRate;
        } else {
            values.tFee = 0;
            values.tLiquidity = 0;
            values.tBurn = 0;
            values.tTransferAmount = tAmount;

            values.rFee = 0;
        }
        values.rTransferAmount = values.rAmount - (values.rFee + (values.tLiquidity * currentRate) + (values.tBurn * currentRate));
        return values;
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;

uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeReflect(uint256 rFee, uint256 tFee) private {
        _rTotal -= rFee;
        _tFeeTotal += tFee;
    }
    
    function _takeLiquidity(address sender, uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity * currentRate;
        _rOwned[address(this)] = _rOwned[address(this)] + rLiquidity;
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)] + tLiquidity;
        emit Transfer(sender, address(this), tLiquidity); 
    }

    function _takeBurn(address sender, uint256 tBurn) private {
        uint256 currentRate =  _getRate();
        uint256 rBurn = tBurn * currentRate;
        _rOwned[BURN_ADDRESS] += rBurn;
        if(_isExcluded[BURN_ADDRESS])
            _tOwned[BURN_ADDRESS] += tBurn;
        emit Transfer(sender, BURN_ADDRESS, tBurn);
    }
}