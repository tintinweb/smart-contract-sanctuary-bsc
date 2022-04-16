/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

/**
 *Submitted for verification at BscScan.com on 2021-11-28
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

abstract contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }
}

interface IERC20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/sh/iba/x/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
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

contract DraculasCoinTestnet is Context, IERC20 {
    // Ownership moved to in-contract for customizability.
    address private _owner;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => bool) private lpPairs;
    uint256 private timeSinceLastPair = 0;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    mapping (address => bool) private presaleAddresses;
    bool private allowedPresaleExclusion = true;
    mapping (address => bool) private _liquidityHolders;
   
    uint256 private constant TOTAL_SUPPLY = 1_000_000_000;

    string private constant TOKEN_NAME = "DraculasCoinTestnet";
    string private constant TOKEN_TICKER = "DRA";

    uint256 private _reflectFee = 0;
    uint256 private _liquidityFee = 0;
    uint256 private _marketingFee = 0;
    uint256 private _devFee = 0;

    uint256 private _buyReflectFee = 200;
    uint256 private _buyLiquidityFee = 0;
    uint256 private _buyMarketingFee = 50;
    uint256 private _buyDevFee = 50;
    uint256 private _totalBuyFee = _buyReflectFee+_buyReflectFee+_buyMarketingFee+_buyDevFee;

    uint256 private _sellReflectFee = 200;
    uint256 private _sellLiquidityFee = 0;
    uint256 private _sellMarketingFee = 250;
    uint256 private _sellDevFee = 250;
    uint256 private _totalSellFee = _sellReflectFee+_sellLiquidityFee+_sellMarketingFee+_sellDevFee;

    uint256 private _transferReflectFee = _buyReflectFee;
    uint256 private _transferLiquidityFee = _buyLiquidityFee;
    uint256 private _transferMarketingFee = _buyMarketingFee;
    uint256 private _transferDevFee = _buyDevFee;
    uint256 private _totalTransferFee = _totalBuyFee;

    //taxes can never be set higher than this
    uint256 public constant MAX_TOTAL_FEE = 2000;

    uint256 public _liquidityRatio = (_buyLiquidityFee+_sellLiquidityFee)/2;
    uint256 public _marketingRatio = (_buyMarketingFee+_sellMarketingFee)/2;
    uint256 public _devRatio = (_buyDevFee+_sellDevFee)/2;

    uint256 private constant TAX_DIVISOR = 10000;

    uint256 private constant MAX = ~uint256(0);
    uint8 private constant TOKEN_DECIMALS = 9;
    uint256 private _decimalsMul = TOKEN_DECIMALS;
    uint256 private _tTotal = TOTAL_SUPPLY * 10**_decimalsMul;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    IUniswapV2Router02 public dexRouter;
    address public lpPair;

    // PCS ROUTER
    address private constant ROUTER_ADDRESS = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    //mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
    //testnet: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
    //address private constant ROUTER_ADDRESS = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;    

    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address public constant ZERO = 0x0000000000000000000000000000000000000000;
    address payable private _marketingWallet = payable(0x24D28d0477714282Da87EDd02a71d7030AD44CfC);
    address payable private _devWallet = payable(0x24D28d0477714282Da87EDd02a71d7030AD44CfC);
    
    bool private inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    
    uint256 private maxTxPercent = 1;
    uint256 private maxTxDivisor = 100;
    uint256 private _maxTxAmount = (_tTotal * maxTxPercent) / maxTxDivisor;
    uint256 private _previousMaxTxAmount = _maxTxAmount;
    uint256 public maxTxAmountUI = (TOTAL_SUPPLY * maxTxPercent) / maxTxDivisor;

    uint256 private maxWalletPercent = 25;
    uint256 private maxWalletDivisor = 1000;
    uint256 private _maxWalletSize = (_tTotal * maxWalletPercent) / maxWalletDivisor;
    uint256 private _previousMaxWalletSize = _maxWalletSize;
    uint256 public maxWalletSizeUI = (TOTAL_SUPPLY * maxWalletPercent) / maxWalletDivisor;

    uint256 public swapThreshold = (_tTotal * 5) / 10000;
    uint256 public swapAmount = (_tTotal * 5) / 1000;
    
    uint256 private defaultLiquidityLockTime = 2628000 seconds; //1 month default autoLP lock
    uint256 private _liquidityUnlockTime;    
    
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

        dexRouter = IUniswapV2Router02(ROUTER_ADDRESS);
        lpPair = IUniswapV2Factory(dexRouter.factory()).createPair(dexRouter.WETH(), address(this));
        lpPairs[lpPair] = true;
        _allowances[address(this)][address(dexRouter)] = type(uint256).max;

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(this)] = true;
        _liquidityHolders[owner()] = true;

        _approve(_msgSender(), ROUTER_ADDRESS, _tTotal);

        setExcludedFromReward(address(this), true);
        setExcludedFromReward(owner(), true);
        setExcludedFromReward(DEAD, true);
        setExcludedFromReward(lpPair, true);
        
        _lockLiquidityTokens(defaultLiquidityLockTime+block.timestamp);        
        
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    receive() external payable {}

//===============================================================================================================
    function owner() public view returns (address) {
        return _owner;
    }
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function transferOwner(address newOwner) external onlyOwner() {
        require(newOwner != address(0), "Call renounceOwnership to transfer owner to the zero address.");
        require(newOwner != DEAD, "Call renounceOwnership to transfer owner to the zero address.");
        setExcludedFromFees(_owner, false);
        setExcludedFromFees(newOwner, true);
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
        setExcludedFromFees(_owner, false);
        _owner = address(0);
        emit OwnershipTransferred(_owner, address(0));
    }
//===============================================================================================================

    function totalSupply() external view override returns (uint256) { return _tTotal; }
    function decimals() external pure override returns (uint8) { return TOKEN_DECIMALS; }
    function symbol() external pure override returns (string memory) { return TOKEN_TICKER; }
    function name() external pure override returns (string memory) { return TOKEN_NAME; }
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

    function _approve(address sender, address spender, uint256 amount) private {
        require(sender != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }

    function approveMax(address spender) public returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function getTaxes() public view returns (uint256 totalBuyTax, uint256 reflectBuyTax, uint256 liquidityBuyTax, uint256 marketingBuyTax, uint256 devBuyTax, 
    uint256 totalSellTax, uint256 reflectSellTax, uint256 liquiditySellTax, uint256 marketingSellTax, uint256 devSellTax, uint256 totalTransferTax){
        return (_totalBuyFee/100, _buyReflectFee/100, _buyLiquidityFee/100, _buyMarketingFee/100, _buyDevFee/100, 
        _totalSellFee/100, _sellReflectFee/100, _sellLiquidityFee/100, _sellMarketingFee/100, _sellDevFee/100, _totalTransferFee/100);
    }

//===============================================================================================================

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function setExcludedFromFees(address account, bool enabled) public onlyOwner {
        _isExcludedFromFees[account] = enabled;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    //Exclude address from rewards - predominantly used to exclude contracts
    function setExcludedFromReward(address account, bool enabled) public onlyOwner {
        if (enabled == true) {
            require(!_isExcluded[account], "Account is already excluded.");
            if(_rOwned[account] > 0) {
                _tOwned[account] = tokenFromReflection(_rOwned[account]);
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
    
    //gives any wallet ability to include themselves back into rewards
    function includeMeToRewards() public {
        require(_isExcluded[msg.sender], "Account is already included.");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == msg.sender) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[msg.sender] = 0;
                _isExcluded[msg.sender] = false;
                _excluded.pop();
                break;
            }
        }
    }
    
    //taxes can never be higher than MAX_TOTAL_FEE
    event BuyTaxesChanged(uint256 newReflectTax, uint256 newLiquidityTax, uint256 newMarketingTax, uint256 newDevTax);
    function setTaxesBuy(uint256 reflectFee, uint256 liquidityFee, uint256 marketingFee, uint256 devFee) external onlyOwner {
        uint256 totalTax = liquidityFee + reflectFee + marketingFee + devFee;
        require(totalTax <= MAX_TOTAL_FEE);
        _buyLiquidityFee = liquidityFee;
        _buyReflectFee = reflectFee;
        _buyMarketingFee = marketingFee;
        _buyDevFee = devFee;
        _totalBuyFee = totalTax;
        emit BuyTaxesChanged(_buyReflectFee, _buyLiquidityFee, _buyMarketingFee, _buyDevFee);
    }

    //taxes can never be higher than MAX_TOTAL_FEE
    event SellTaxesChanged(uint256 newReflectTax, uint256 newLiquidityTax, uint256 newMarketingTax, uint256 newDevTax);
    function setTaxesSell(uint256 reflectFee, uint256 liquidityFee, uint256 marketingFee, uint256 devFee) external onlyOwner {
        uint256 totalTax = liquidityFee + reflectFee + marketingFee + devFee;
        require(totalTax <= MAX_TOTAL_FEE);
        _sellLiquidityFee = liquidityFee;
        _sellReflectFee = reflectFee;
        _sellMarketingFee = marketingFee;
        _sellDevFee = devFee;
        _totalSellFee = totalTax;
        emit SellTaxesChanged(_sellReflectFee, _sellLiquidityFee, _sellMarketingFee, _sellDevFee);
    }

    //taxes can never be higher than MAX_TOTAL_FEE
    event TransferTaxesChanged(uint256 newReflectTax, uint256 newLiquidityTax, uint256 newMarketingTax, uint256 newDevTax);
    function setTaxesTransfer(uint256 reflectFee, uint256 liquidityFee, uint256 marketingFee, uint256 devFee) external onlyOwner {
        uint256 totalTax = liquidityFee + reflectFee + marketingFee + devFee;
        require(totalTax <= MAX_TOTAL_FEE);
        _transferLiquidityFee = liquidityFee;
        _transferReflectFee = reflectFee;
        _transferMarketingFee = marketingFee;
        _transferDevFee = devFee;
        _totalTransferFee = totalTax;
        emit TransferTaxesChanged(_transferReflectFee, _transferLiquidityFee, _transferMarketingFee, _transferDevFee);
    }

    event RatiosChanged(uint256 newLiquidityRatio, uint256 newMarketingRatio, uint256 newDevRatio);
    function setRatios(uint256 liquidity, uint256 marketing, uint256 dev) external onlyOwner {
        require (liquidity + marketing + dev == 100, "Must add up to 100%");
        _liquidityRatio = liquidity;
        _marketingRatio = marketing;
        _devRatio = dev;
        emit RatiosChanged(_liquidityRatio, _marketingRatio, _devRatio);
    }

    //Max tx can never be below 0.1% of taotal supply - prevents honeypot
    event MaxTxChanged(uint256 newMaxTxPercent, uint256 newMaxTxAmount);
    function setMaxTxPercent(uint256 percent, uint256 divisor) external onlyOwner {
        uint256 check = (_tTotal * percent) / divisor;
        require(check >= (_tTotal / 1000), "Max Transaction amount must be above 0.1% of total supply.");
        _maxTxAmount = check;
        maxTxAmountUI = (TOTAL_SUPPLY * percent) / divisor;
        emit MaxTxChanged(percent, maxTxAmountUI);
    }

    event MaxWalletChanged (uint256 newMaxWalletPercent, uint256 newMaxWalletAmount);
    function setMaxWalletSize(uint256 percent, uint256 divisor) external onlyOwner {
        uint256 check = (_tTotal * percent) / divisor;
        require(check >= (_tTotal / 1000), "Max Wallet amount must be above 0.1% of total supply.");
        _maxWalletSize = check;
        maxWalletSizeUI = (TOTAL_SUPPLY * percent) / divisor;
        emit MaxWalletChanged(percent, maxWalletSizeUI);
    }

    event SwapSettingsUpdated(uint256 newSwapThreshold, uint256 newSwapAmount);
    function setSwapSettings(uint256 thresholdPercent, uint256 thresholdDivisor, uint256 amountPercent, uint256 amountDivisor) external onlyOwner {
        swapThreshold = (_tTotal * thresholdPercent) / thresholdDivisor;
        swapAmount = (_tTotal * amountPercent) / amountDivisor;
        emit SwapSettingsUpdated(swapThreshold, swapAmount);
    }

    event MarketingDevWalletsUpdated(address marketing, address dev);
    function setWallets(address payable marketingWallet, address payable devWallet) external onlyOwner {
        _marketingWallet = payable(marketingWallet);
        _devWallet = payable(devWallet);
        emit MarketingDevWalletsUpdated(_marketingWallet,_devWallet);
    }
    
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function excludePresaleAddresses(address router, address presale) external onlyOwner {
        require(allowedPresaleExclusion, "Function already used.");
        if (router == presale) {
            _liquidityHolders[presale] = true;
            presaleAddresses[presale] = true;
            setExcludedFromFees(presale, true);
            setExcludedFromReward(presale, true);
        } else {
            _liquidityHolders[router] = true;
            _liquidityHolders[presale] = true;
            presaleAddresses[router] = true;
            presaleAddresses[presale] = true;
            setExcludedFromFees(router, true);
            setExcludedFromFees(presale, true);
            setExcludedFromReward(router, true);
            setExcludedFromReward(presale, true);
        }
    }

    function _hasLimits(address from, address to) private view returns (bool) {
        return from != owner()
            && to != owner()
            && !_liquidityHolders[to]
            && !_liquidityHolders[from]
            && to != DEAD
            && to != address(0)
            && from != address(this);
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount / currentRate;
    }

    function _transfer(address from, address to, uint256 amount) internal returns (bool) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if(_hasLimits(from, to)) {
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            if(to != ROUTER_ADDRESS && !lpPairs[to]) {
                require(balanceOf(to) + amount <= _maxWalletSize, "Transfer amount exceeds the maxWalletSize.");
            }
        }

        bool takeFee = true;
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]){
            takeFee = false;
        }

        if (lpPairs[to]) {
            if (!inSwapAndLiquify
                && swapAndLiquifyEnabled
                && !presaleAddresses[to]
                && !presaleAddresses[from]
            ) {
                uint256 contractTokenBalance = balanceOf(address(this));
                if (contractTokenBalance >= swapThreshold) {
                    if(contractTokenBalance >= swapAmount) { contractTokenBalance = swapAmount; }
                    swapAndLiquify(contractTokenBalance);
                }
            }      
        } 
        return _finalizeTransfer(from, to, amount, takeFee);
    }

    function manualSwap() public onlyOwner {
        swapAndLiquify(balanceOf(address(this)));
    }
    
    event SwapAndLiquify(uint256 tokensSwapped,uint256 ethReceived,uint256 tokensIntoLiqudity);
    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 totalFee = _liquidityRatio + _marketingRatio + _devRatio;
        if (totalFee == 0)
            return;
        uint256 toLiquify = ((contractTokenBalance * _liquidityRatio) / totalFee) / 2;

        uint256 toSwapForEth = contractTokenBalance - toLiquify;
        swapTokensForEth(toSwapForEth);

        uint256 currentBalance = address(this).balance;
        uint256 liquidityBalance = ((currentBalance * _liquidityRatio) / totalFee) / 2;

        if (toLiquify > 0) {
            addLiquidity(toLiquify, liquidityBalance);
            emit SwapAndLiquify(toLiquify, liquidityBalance, toLiquify);
        }
        if (contractTokenBalance - toLiquify > 0) {
            _marketingWallet.transfer((currentBalance * _marketingRatio) / totalFee);
            _devWallet.transfer(address(this).balance);
        }
    }

    function swapTokensForEth(uint256 tokenAmount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        dexRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    struct ExtraValues {
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tLiquidity;

        uint256 rTransferAmount;
        uint256 rAmount;
        uint256 rFee;
    }

    function _finalizeTransfer(address from, address to, uint256 tAmount, bool takeFee) private returns (bool) {
        ExtraValues memory values = _getValues(from, to, tAmount, takeFee);

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
        if (values.rFee > 0 || values.tFee > 0)
            _takeReflect(values.rFee, values.tFee);

        emit Transfer(from, to, values.tTransferAmount);
        return true;
    }

    function _getValues(address from, address to, uint256 tAmount, bool takeFee) private returns (ExtraValues memory) {
        ExtraValues memory values;
        uint256 currentRate = _getRate();

        values.rAmount = tAmount * currentRate;

        if(takeFee) {
            if (lpPairs[to]) {
                _reflectFee = _sellReflectFee;
                _liquidityFee = _sellLiquidityFee;
                _marketingFee = _sellMarketingFee;
                _devFee = _sellDevFee;
            } else if (lpPairs[from]) {
                _reflectFee = _buyReflectFee;
                _liquidityFee = _buyLiquidityFee;
                _marketingFee = _buyMarketingFee;
                _devFee = _buyDevFee;
            } else {
                _reflectFee = _transferReflectFee;
                _liquidityFee = _transferLiquidityFee;
                _marketingFee = _transferMarketingFee;
                _devFee = _transferDevFee;
            }

            values.tFee = (tAmount * _reflectFee) / TAX_DIVISOR;
            values.tLiquidity = (tAmount * (_liquidityFee + _marketingFee + _devFee)) / TAX_DIVISOR;
            values.tTransferAmount = tAmount - (values.tFee + values.tLiquidity);

            values.rFee = values.tFee * currentRate;
        } else {
            values.tFee = 0;
            values.tLiquidity = 0;
            values.tTransferAmount = tAmount;

            values.rFee = 0;
        }
        values.rTransferAmount = values.rAmount - (values.rFee + (values.tLiquidity * currentRate));
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
        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }
    
    function _takeLiquidity(address sender, uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity * currentRate;
        _rOwned[address(this)] = _rOwned[address(this)] + rLiquidity;
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)] + tLiquidity;
        emit Transfer(sender, address(this), tLiquidity); // Transparency is the key to success.
    }
    
    /////////////////////////////   LP LOCK  ///////////////////////////////////////// 

    //OnlyOwner has control of LP functions
    
    function getLiquidityUnlockInSeconds() public view returns (uint256){
        if(block.timestamp<_liquidityUnlockTime){
            return _liquidityUnlockTime-block.timestamp;
        }
        return 0;
    }    

    //Prolongs LP lock time    
    event ExtendLiquidityLock(uint256 extendedLockTime);
    function lockLiquidityTokens(uint256 lockTimeInSeconds) public onlyOwner{
        _lockLiquidityTokens(lockTimeInSeconds+block.timestamp);
        emit ExtendLiquidityLock(lockTimeInSeconds);
    }
    
    function _lockLiquidityTokens(uint256 newUnlockTime) private{
        // require new unlock time to be longer than old one
        require(newUnlockTime>_liquidityUnlockTime);
        _liquidityUnlockTime=newUnlockTime;
    }

    //Impossible to release LP unless LP lock time is zero
    function releaseLP() public onlyOwner {
        require(block.timestamp >= _liquidityUnlockTime, "Not yet unlocked");
        IUniswapV2Pair liquidityToken = IUniswapV2Pair(lpPair);
        uint256 amount = liquidityToken.balanceOf(address(this));
        liquidityToken.transfer(msg.sender, amount);
    }

    //Impossible to remove LP unless lock time is zero
    function removeLP() public onlyOwner {
        require(block.timestamp >= _liquidityUnlockTime, "Not yet unlocked");
        _liquidityUnlockTime=block.timestamp;
        IUniswapV2Pair liquidityToken = IUniswapV2Pair(lpPair);
        uint256 amount = liquidityToken.balanceOf(address(this));
        liquidityToken.approve(address(dexRouter),amount);
        dexRouter.removeLiquidityETHSupportingFeeOnTransferTokens(
            address(this),
            amount,
            0,
            0,
            address(this),
            block.timestamp
            );
        _devWallet.transfer(address(this).balance);    
    }
    
    //Can only be called when LP lock time is zero. Recovers any stuck BNB in the contract
    function recoverBNB() public onlyOwner {
        _devWallet.transfer(address(this).balance);
    }
}