/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

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


contract testtwo is Context, IERC20 {
    address private _owner;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcludedFromReward;
    mapping (address => bool) private _isExcludedFromLimits;
    address[] private _excluded;

    mapping (address => bool) private _isSniper;
    mapping (address => bool) private _liquidityHolders;

    uint256 private constant INITIAL_SUPPLY = 1_000_000_000;

    string public override name = "TestTwo";
    string public override symbol = "TWO";

    struct Fees {
        uint16 reflect;
        uint16 liquidity;
        uint16 marketing;
        uint16 burn;
        uint16 total;
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

    Fees private _current;

    Fees public _buyFees = Fees({
    reflect: 200,
    liquidity: 200,
    marketing: 500,
    burn: 200,
    total: 1100
    });

    Fees public _sellFees = _buyFees;

    Fees public _transferFees = _buyFees;

    uint256 constant public MAX_TAX = 2000;
    uint256 constant public TAX_DIVISOR = 10000;

    uint256 private constant MAX = ~uint256(0);
    uint8 public override decimals = 18;
    uint256 private _decimalsMul = decimals;
    uint256 private _tTotal = INITIAL_SUPPLY * 10**_decimalsMul;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    IUniswapV2Router02 public dexRouter;
    address public lpPair;

    // PCS ROUTER
    address private _routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    // CHANGE THESE PRIOR TO DEPLOYMENT
    address payable private _marketingWallet = payable(0x000000000000000000000000000000000000dEaD);
    address public rewardPool = 0x8F5D817223D6ffD99f4f088ec0CE0c6aB88b56cA;

    bool private inSwapAndLiquify;
    bool public swapAndLiquifyEnabled;

    uint256 private buyMaxTxPercent = 3;
    uint256 private buyMaxTxDivisor = 200;
    uint256 private _buyMaxTxAmount = (_tTotal * buyMaxTxPercent) / buyMaxTxDivisor;
    uint256 private _buyPreviousBuyMaxTxAmount = _buyMaxTxAmount;

    uint256 private sellMaxTxPercent = 3;
    uint256 private sellMaxTxDivisor = 200;
    uint256 private _sellMaxTxAmount = (_tTotal * sellMaxTxPercent) / sellMaxTxDivisor;
    uint256 private _sellPreviousMaxTxAmount = _sellMaxTxAmount;

    uint256 private maxWalletPercent = 27;
    uint256 private maxWalletDivisor = 1000;
    uint256 private _maxWalletSize = (_tTotal * maxWalletPercent) / maxWalletDivisor;

    uint256 public swapThresholdNumerator = 10;
    uint256 public swapThresholdDenominator = 10000;
    uint256 public swapAmountNumerator = 10;
    uint256 public swapAmountDenominator = 1000;

    bool public tradingEnabled;

    bool private sniperProtection = true;
    bool public _hasLiqBeenAdded;
    uint256 private _liqAddBlock;
    uint256 private snipeBlockAmt = 5;
    uint256 public snipersCaught;
    bool private sameBlockActive = true;
    mapping (address => uint256) private lastTrade;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    event NewRewardPoolSet(address previousRewardPool, address newRewardPool);
    event RewardsReplenished(uint256 tokens);

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
        _rOwned[_msgSender()] = _rTotal;
        _owner = msg.sender;

        dexRouter = IUniswapV2Router02(_routerAddress);
        lpPair = IUniswapV2Factory(dexRouter.factory()).createPair(dexRouter.WETH(), address(this));
        _allowances[address(this)][address(dexRouter)] = MAX;

        _isExcludedFromFee[_owner] = true;
        _isExcludedFromFee[address(this)] = true;

        _liquidityHolders[_owner] = true;

        // Approve the owner for PancakeSwap, timesaver.
        _approve(_msgSender(), _routerAddress, _tTotal);

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    receive() external payable {}

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transfer(_msgSender(), recipient, amount);
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        _approve(_msgSender(), spender, MAX);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function reflect(uint256 amount) external {
        address sender = _msgSender();
        require(!_isExcludedFromReward[sender], 'Excluded addresses cannot call this function');
        uint256 currentRate = _getRate();

        uint256 rAmount = amount * currentRate;
        _rOwned[sender] = _rOwned[sender] - rAmount;

        _takeReflect(rAmount, amount);
    }

    function transferBatch(address[] calldata recipients, uint256[] calldata amounts) external returns (bool) {
        require(recipients.length == amounts.length,
            "Must be matching argument lengths");

        uint256 length = recipients.length;

        for (uint i = 0; i < length; i++) {
            require(_transfer(_msgSender(), recipients[i], amounts[i]));
        }
        return true;
    }

    function transferOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Call renounceOwnership to transfer owner to the zero address.");
        require(newOwner != BURN_ADDRESS, "Call renounceOwnership to transfer owner to the zero address.");

        address oldOwner = _owner;

        setExcludeAll(newOwner, true);

        if (_marketingWallet == payable(oldOwner)) {
            _marketingWallet = payable(newOwner);
        }

        if(_balanceOf(oldOwner) > 0) {
            _transfer(oldOwner, newOwner, _balanceOf(oldOwner));
        }

        _owner = newOwner;

        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function setRewardPool(address newRewardPool, bool transferBalance) external onlyOwner {
        require(newRewardPool != BURN_ADDRESS, "Cannot set the rewardPool to the burn address");
        require(newRewardPool != address(0), "Cannot set the rewardPool to the zero address");

        setExcludeAll(newRewardPool, true);

        address oldRewardPool = rewardPool;
        rewardPool = newRewardPool;

        if (transferBalance) {
            _transfer(oldRewardPool, newRewardPool, _balanceOf(oldRewardPool));
        }

        emit NewRewardPoolSet(oldRewardPool, newRewardPool);
    }

    function replenishRewards(uint256 amount) external onlyOwner {
        require(amount <= _tTotal);

        uint256 currentRate = _getRate();

        _tTotal = _tTotal + amount;
        _rTotal = _tTotal * currentRate;

        _tOwned[rewardPool] = _tOwned[rewardPool] + amount;

        emit Transfer(address(0), rewardPool, amount);
        emit RewardsReplenished(amount);
    }

    function removeSniper(address account) external onlyOwner {
        require(_isSniper[account], "Account is not a recorded sniper.");
        _isSniper[account] = false;
    }

    function setProtectionSettings(bool antiSnipe, bool antiBlock) external onlyOwner {
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

    function setMaxTxPercents(uint16 buyPercent, uint16 buyDivisor, uint16 sellPercent, uint16 sellDivisor) external onlyOwner {
        _buyMaxTxAmount = (_tTotal * buyPercent) / buyDivisor;
        _sellMaxTxAmount = (_tTotal * sellPercent) / sellDivisor;
        require(_sellMaxTxAmount >= (_tTotal / 1000)
            && _buyMaxTxAmount >= (_tTotal / 1000),
            "Max Transaction amts must be above 0.1% of total supply."
        );
    }

    function setMaxWalletSize(uint256 percent, uint256 divisor) external onlyOwner {
        _maxWalletSize = (_tTotal * percent) / divisor;
        require(_maxWalletSize >= (_tTotal / 1000), "Max Wallet amt must be above 0.1% of total supply.");
    }

    function setSwapSettings(uint256 thresholdPercent, uint256 thresholdDivisor, uint256 amountPercent, uint256 amountDivisor) external onlyOwner {
        swapThresholdNumerator = thresholdPercent;
        swapThresholdDenominator = thresholdDivisor;

        swapAmountNumerator = amountPercent;
        swapAmountDenominator = amountDivisor;
    }

    function setMarketingWallet(address newMarketingWallet) external onlyOwner {
        _marketingWallet = payable(newMarketingWallet);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        _setSwapAndLiquifyEnabled(_enabled);
    }

    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "Trading already enabled!");

        setExcludedFromReward(address(this), true);
        setExcludedFromReward(_owner, true);
        setExcludedFromReward(BURN_ADDRESS, true);
        setExcludedFromReward(lpPair, true);
        setExcludedFromReward(rewardPool, true);

        _liqAddBlock = block.number;
        tradingEnabled = true;
    }

    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }

    function isExcludedFromReward(address account) external view returns (bool) {
        return _isExcludedFromReward[account];
    }

    function isExcludedFromFee(address account) external view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function isExcludedFromLimits(address account) external view returns (bool) {
        return _isExcludedFromLimits[account];
    }

    function isSniper(address account) external view returns (bool) {
        return _isSniper[account];
    }

    function getMaxLimits() external view returns (uint256 maxBuy, uint256 maxSell, uint256 maxWallet) {
        maxBuy = _buyMaxTxAmount;
        maxSell = _sellMaxTxAmount;
        maxWallet = _maxWalletSize;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function getOwner() external view override returns (address) {
        return _owner;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balanceOf(account);
    }

    function renounceOwnership() external onlyOwner {
        setExcludedFromFee(_owner, false);
        _owner = address(0);
        emit OwnershipTransferred(_owner, address(0));
    }

    function setExcludeAll(address account, bool enabled) public onlyOwner {
        setExcludedFromFee(account, enabled);
        setExcludedFromReward(account, enabled);
        setExcludedFromLimits(account, enabled);
    }

    function setExcludedFromLimits(address account, bool enabled) public onlyOwner {
        _isExcludedFromLimits[account] = enabled;
    }

    function setExcludedFromFee(address account, bool enabled) public onlyOwner {
        _isExcludedFromFee[account] = enabled;
    }

    function setExcludedFromReward(address account, bool enabled) public onlyOwner {
        if (enabled == true) {
            if (_isExcludedFromReward[account]) {
                return;
            }
            if(_rOwned[account] > 0) {
                _tOwned[account] = _tokensFromReflections(_rOwned[account]);
            }
            _isExcludedFromReward[account] = true;
            _excluded.push(account);
        } else if (enabled == false) {
            if (!_isExcludedFromReward[account]) {
                return;
            }
            for (uint256 i = 0; i < _excluded.length; i++) {
                if (_excluded[i] == account) {
                    _excluded[i] = _excluded[_excluded.length - 1];
                    _tOwned[account] = 0;
                    _isExcludedFromReward[account] = false;
                    _excluded.pop();
                    break;
                }
            }
        }
    }

    function _transfer(address from, address to, uint256 amount) private returns (bool) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

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
                require((_balanceOf(to) + amount <= _maxWalletSize) || _isExcludedFromLimits[to], "Transfer amount exceeds the maxWalletSize.");
            }
        }

        bool takeFee = true;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }

        if (to == lpPair) {
            if (
                !inSwapAndLiquify
            && swapAndLiquifyEnabled
            ) {
                uint256 contractTokenBalance = _balanceOf(address(this));
                if (contractTokenBalance >= _tTotal * swapThresholdNumerator / swapThresholdDenominator) {
                    if(contractTokenBalance >= _tTotal * swapAmountNumerator / swapAmountDenominator)
                        contractTokenBalance = _tTotal * swapAmountNumerator / swapAmountDenominator;
                    _swapAndLiquify(contractTokenBalance);
                }
            }
        }
        return _finalizeTransfer(from, to, amount, takeFee);
    }

    function _approve(address sender, address spender, uint256 amount) private {
        require(sender != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }

    function _setSwapAndLiquifyEnabled(bool _enabled) private {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function _setTransactionTaxes(address from, address to) private {
        if (from == lpPair) {
            _current = _buyFees;
        } else if (to == lpPair) {
            _current = _sellFees;
        } else {
            _current = _transferFees;
        }
    }

    function _swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 totalFee = _sellFees.liquidity + _sellFees.marketing;
        if (totalFee == 0) {
            return;
        }

        uint256 toLiquify = contractTokenBalance * _sellFees.liquidity / totalFee;
        uint256 bnbOut = contractTokenBalance - toLiquify;
        uint256 half = toLiquify / 2;
        uint256 otherHalf = toLiquify - half;
        uint256 initialBalance = address(this).balance;
        uint256 toSwapForEth = half + bnbOut;

        _swapTokensForEth(toSwapForEth);

        uint256 fromSwap = address(this).balance - initialBalance;
        uint256 liquidityBalance = (fromSwap * half) / toSwapForEth;

        if (toLiquify > 0) {
            _addLiquidity(otherHalf, liquidityBalance);
            emit SwapAndLiquify(half, liquidityBalance, otherHalf);
        }

        if (bnbOut > 0) {
            _marketingWallet.call{ value: address(this).balance }("");
        }
    }

    function _swapTokensForEth(uint256 tokenAmount) private {
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

    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
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

            _setSwapAndLiquifyEnabled(true);
        }
    }

    function _takeReflect(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    function _takeLiquidity(address sender, uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity * currentRate;

        _rOwned[address(this)] = _rOwned[address(this)] + rLiquidity;

        if (_isExcludedFromReward[address(this)]) {
            _tOwned[address(this)] = _tOwned[address(this)] + tLiquidity;
        }

        emit Transfer(sender, address(this), tLiquidity);
    }

    function _takeBurn(address sender, uint256 tBurn) private {
        uint256 currentRate =  _getRate();
        _tTotal = _tTotal - tBurn;
        _rTotal = _tTotal * currentRate;
        emit Transfer(sender, BURN_ADDRESS, tBurn);
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
                if (
                    _liqAddBlock > 0
                    && from == lpPair
                    && _hasLimits(from, to)
                    && block.number - _liqAddBlock < snipeBlockAmt
                ) {
                    _isSniper[to] = true;
                    snipersCaught ++;
                    emit SniperCaught(to);
                }
            }
        }
        _setTransactionTaxes(from, to);
        ExtraValues memory values = _getValues(to, tAmount, takeFee);

        _rOwned[from] = _rOwned[from] - values.rAmount;
        _rOwned[to] = _rOwned[to] + values.rTransferAmount;

        if (_isExcludedFromReward[from] && !_isExcludedFromReward[to]) {
            _tOwned[from] = _tOwned[from] - tAmount;

        } else if (!_isExcludedFromReward[from] && _isExcludedFromReward[to]) {
            _tOwned[to] = _tOwned[to] + values.tTransferAmount;

        } else if (_isExcludedFromReward[from] && _isExcludedFromReward[to]) {
            _tOwned[from] = _tOwned[from] - tAmount;
            _tOwned[to] = _tOwned[to] + values.tTransferAmount;
        }

        if (values.tLiquidity > 0) {
            _takeLiquidity(from, values.tLiquidity);
        }

        if (values.tBurn > 0) {
            _takeBurn(from, values.tBurn);
        }

        if (values.rFee > 0 || values.tFee > 0) {
            _takeReflect(values.rFee, values.tFee);
        }

        emit Transfer(from, to, values.tTransferAmount);
        return true;
    }

    function _balanceOf(address account) private view returns (uint256) {
        if (_isExcludedFromReward[account]) {
            return _tOwned[account];
        } else {
            return _tokensFromReflections(_rOwned[account]);
        }
    }

    function _tokensFromReflections(uint256 rAmount) private view returns (uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount / currentRate;
    }

    function _hasLimits(address from, address to) private view returns (bool) {
        return from != _owner
        && to != _owner
        && !_liquidityHolders[to]
        && !_liquidityHolders[from]
        && to != BURN_ADDRESS
        && from != address(this)
        && from != rewardPool
        && to != rewardPool;
    }

    function _getBNBFee() private view returns (uint256) {
        return _current.liquidity + _current.marketing;
    }

    function _getValues(address to, uint256 tAmount, bool takeFee) private view returns (ExtraValues memory) {
        ExtraValues memory values;
        uint256 currentRate = _getRate();

        values.rAmount = tAmount * currentRate;

        if (to == BURN_ADDRESS) {
            values.tFee = 0;
            values.tLiquidity = 0;
            values.tBurn = tAmount;
            values.tTransferAmount = 0;
            values.rFee = 0;
        } else if (takeFee) {
            values.tFee = (tAmount * _current.reflect) / TAX_DIVISOR;
            values.tLiquidity = (tAmount * (_getBNBFee())) / TAX_DIVISOR;
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

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
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
}