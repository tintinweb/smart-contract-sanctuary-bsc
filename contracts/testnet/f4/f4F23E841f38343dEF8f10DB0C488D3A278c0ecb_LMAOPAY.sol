/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

// File: interfaces.sol

pragma solidity ^0.8.4;


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

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

    event Mint(address indexed sender, uint amount0, uint amount1);
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
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/utils/math/SignedSafeMath.sol


// OpenZeppelin Contracts v4.4.1 (utils/math/SignedSafeMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SignedSafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SignedSafeMath {
    /**
     * @dev Returns the multiplication of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two signed integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        return a / b;
    }

    /**
     * @dev Returns the subtraction of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        return a - b;
    }

    /**
     * @dev Returns the addition of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        return a + b;
    }
}

// File: LMAOToken.sol



pragma solidity ^0.8.14;





contract LMAOPAY is IERC20Metadata, Ownable {
    using SignedSafeMath for int256;

    string private _name;
    string private _symbol;

    bool public initialDistributionFinished = false;
    bool public swapEnabled = true;
    bool public buyBackEnabled = true;
    bool public walletToWalletEnabled = true;
    bool public autoRebase = false;
    bool public feesOnNormalTransfers = false;
    bool public isLiquidityInBNB = true;
    bool inSwap;

    address[] public _markerPairs;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address public LIFWallet;
    address public treasuryWallet;
    address public BUSDWallet;
    address public BNBWallet;
    address public uniswapV2Pair;
    address public BUSDToken;

    uint256 public rewardYield = 4252083;
    uint256 public rewardYieldDenominator = 10000000000;
    uint256 public maxSellTransactionAmount = 2_500_000 * 10 ** 18;
    uint256 public rebaseFrequency = 1800; // 30-minutes
    uint256 public nextRebase = block.timestamp + 604800; // 7-days
    uint256 public allowedSellPercent = 100;
    uint256 public cooldownPeriod = 600;  // 10-minutes

    uint256 private constant MAX_REBASE_FREQUENCY = 1800;   // 30-minutes
    uint256 private constant DECIMALS = 18;
    uint256 private constant MAX_UINT256 = type(uint256).max;
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 5 * 10**9 * 10**DECIMALS;
    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
    uint256 public constant MAX_SUPPLY = type(uint112).max;
    uint256 targetLiquidity = 5000;

    uint256 private _totalSupply;
    uint256 private _gonsPerFragment;
    uint256 private swapThreshold = 500_000 ether;
    uint256 private buyBackUpperLimit = 1 * 10**18;

    IUniswapV2Router02 public uniswapV2Router;

    struct feeRateStruct {
        uint256 liquidity;
        uint256 lif;
        uint256 treasury;
        uint256 busd;
        uint256 buyBack;
        uint256 bnb;
    }

    struct user {
        uint256 firstBuy;
        uint256 lastTradeTime;
        uint256 tradeAmount;
    }

    feeRateStruct public buyFeeRates = feeRateStruct(
        {
            liquidity: 200,
            lif: 400,
            treasury: 400,
            busd: 200,
            buyBack: 50,
            bnb: 50
        }
    );

    feeRateStruct public sellFeeRates = feeRateStruct(
        {
            liquidity: 200,
            lif: 500,
            treasury: 500,
            busd: 200,
            buyBack: 50,
            bnb: 50
        }
    );

    uint256 public pendingBuyFees;
    uint256 public pendingSellFees;

    uint256 totalBuyFees = buyFeeRates.liquidity
                + buyFeeRates.lif
                + buyFeeRates.treasury
                + buyFeeRates.busd
                + buyFeeRates.buyBack
                + buyFeeRates.bnb;

    uint256 totalSellFees = sellFeeRates.liquidity
                + sellFeeRates.lif
                + sellFeeRates.treasury
                + sellFeeRates.busd
                + sellFeeRates.buyBack
                + sellFeeRates.bnb;

    mapping(address => bool) public isWhitelisted;
    mapping(address => bool) _isExcludedFromFee;
    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => user) public tradeData;
    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;


    event SwapAndLiquify(uint256 tokensSwapped, uint256 BNBReceived, uint256 tokensIntoLiqudity);
    event SwapAndLiquifyBUSD(uint256 tokensSwapped, uint256 BUSDReceived, uint256 tokensIntoLiqudity);
    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event FeesChanged();


    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    constructor(
        string memory name_, 
        string memory symbol_,
        address router_,
        address busdToken_,
        address LIFWallet_,
        address treasuryWallet_,
        address BNBWallet_,
        address BUSDWallet_
    ) {
        require(router_ != address(0), "Zero Address");
        require(busdToken_ != address(0), "Zero Address");
        require(LIFWallet_ != address(0), "Zero Address");
        require(treasuryWallet_ != address(0), "Zero Address");
        require(BNBWallet_ != address(0), "Zero Address");
        require(BUSDWallet_ != address(0), "Zero Address");

        _name = name_;
        _symbol = symbol_;

        BUSDToken = busdToken_;
        LIFWallet = LIFWallet_;
        treasuryWallet = treasuryWallet_;
        BNBWallet = BNBWallet_;
        BUSDWallet = BUSDWallet_;

        uniswapV2Router = IUniswapV2Router02(router_);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        address uniswapV2PairBUSD = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), busdToken_);

        _allowedFragments[address(this)][address(uniswapV2Router)] = type(uint256).max;
        _allowedFragments[address(this)][uniswapV2Pair] = type(uint256).max;
        _allowedFragments[address(this)][address(this)] = type(uint256).max;
        _allowedFragments[address(this)][uniswapV2PairBUSD] = type(uint256).max;

        setAutomatedMarketMakerPair(uniswapV2Pair, true);
        setAutomatedMarketMakerPair(uniswapV2PairBUSD, true);

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[msg.sender] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS / _totalSupply;

        _isExcludedFromFee[LIFWallet] = true;
        _isExcludedFromFee[treasuryWallet] = true;
        _isExcludedFromFee[BNBWallet] = true;
        _isExcludedFromFee[BUSDWallet] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[msg.sender] = true;

        isWhitelisted[msg.sender] = true;

        IERC20(busdToken_).approve(address(uniswapV2Router), type(uint256).max);
        IERC20(busdToken_).approve(address(uniswapV2PairBUSD), type(uint256).max);
        IERC20(busdToken_).approve(address(this), type(uint256).max);

        emit Transfer(address(0x0), msg.sender, _totalSupply);
    }


    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return uint8(DECIMALS);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function allowance(address owner_, address spender) external view override returns (uint256){
        return _allowedFragments[owner_][spender];
    }

    function balanceOf(address who) public view override returns (uint256) {
        return _gonBalances[who] / _gonsPerFragment;
    }

    function transfer(address recipient, uint256 value) external override validRecipient(recipient) returns (bool){
        _transfer(_msgSender(), recipient, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        if (_allowedFragments[sender][msg.sender] != type(uint256).max) {
            require(_allowedFragments[sender][msg.sender] >= amount, "ERC20: transfer amount exceeds allowance");

            _allowedFragments[sender][msg.sender] = _allowedFragments[sender][msg.sender] - amount;
        }

        return true;
    }

    function approve(address spender, uint256 value) external override returns (bool) {
        _allowedFragments[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) { 
        uint256 oldValue = _allowedFragments[msg.sender][spender];

        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue - subtractedValue;
        }
        
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][spender] + addedValue;
        
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);

        return true;
    }



    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Custom Functions

    function getCirculatingSupply() public view returns (uint256) {
        return (TOTAL_GONS - _gonBalances[DEAD] - _gonBalances[ZERO]) / _gonsPerFragment;
    }

    function getLiquidityBacking() public view returns (uint256){
        uint256 liquidityBalance = 0;

        for(uint256 i = 0; i < _markerPairs.length; i++){
            liquidityBalance += (balanceOf(_markerPairs[i]) / 10 ** 9);
        }

        return (liquidityBalance * 10000) / (getCirculatingSupply() / 10 ** 9);
    }

    function isOverLiquified(uint256 target) public view returns (bool){
        return getLiquidityBacking() > target;
    }

    function manualSync() public {
        for(uint256 i = 0; i < _markerPairs.length; i++){
            IUniswapV2Pair(_markerPairs[i]).sync();
        }
    }

    function isExcludedFromFee(address account) external view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function checkSwapThreshold() public view returns (uint256) {
        return swapThreshold;
    }

    function shouldRebase() internal view returns (bool) {
        return nextRebase <= block.timestamp;
    }

    function shouldTakeFee(address from, address to) internal view returns (bool) {
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            return false;
        }else if (feesOnNormalTransfers){
            return true;
        }else{
            return (automatedMarketMakerPairs[from] || automatedMarketMakerPairs[to]);
        }
    }

    function shouldSwapBack() internal view returns (bool) {
        return
        !automatedMarketMakerPairs[msg.sender] &&
        !inSwap &&
        swapEnabled &&
        (totalBuyFees + totalSellFees) > 0 &&
        balanceOf(address(this)) >= swapThreshold;
    }

    function _basicTransfer(address from, address to, uint256 amount) internal returns (bool) {
        uint256 gonAmount = amount * _gonsPerFragment;
        _gonBalances[from] = _gonBalances[from] - gonAmount;
        _gonBalances[to] = _gonBalances[to] + gonAmount;

        emit Transfer(from, to, amount);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (!walletToWalletEnabled) {
            require(automatedMarketMakerPairs[sender] || automatedMarketMakerPairs[recipient], "Wallet to wallet is disabled");
        }

        bool isExcluded = _isExcludedFromFee[sender] || _isExcludedFromFee[recipient];

        require(initialDistributionFinished || isExcluded, "Trading not started");
        
        // cool down and sell percentage allowed check
        if (automatedMarketMakerPairs[recipient] && !isExcluded) { 
            require(amount <= maxSellTransactionAmount, "Error amount");

            uint256 blockTime = block.timestamp;
            uint256 onePercent = balanceOf(sender) * allowedSellPercent / 10000; //Should use variable
            require(amount <= onePercent, "ERR: Can't sell more than allowed %");
            
            if(blockTime > tradeData[sender].lastTradeTime + cooldownPeriod) {
                tradeData[sender].lastTradeTime = blockTime;
                tradeData[sender].tradeAmount = amount;
            } else if((blockTime < tradeData[sender].lastTradeTime + cooldownPeriod) && 
                     ((blockTime >= tradeData[sender].lastTradeTime))) {
                require(tradeData[sender].tradeAmount + amount <= onePercent, "ERR: Can't sell more than allowed % in Cooldown Period");
                tradeData[sender].tradeAmount = tradeData[sender].tradeAmount + amount;
            }
        }

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        uint256 gonAmount = amount * _gonsPerFragment;

        if (shouldSwapBack()) {
            uint256 balance = address(this).balance;
            
            if (buyBackEnabled && balance > uint256(1 * 10**18) && automatedMarketMakerPairs[recipient]) {
                if (balance > buyBackUpperLimit) balance = buyBackUpperLimit;
                buyBackTokens(balance / 100);
            }

            swapBack();
        }

        _gonBalances[sender] = _gonBalances[sender] - gonAmount;

        uint256 gonAmountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, gonAmount) : gonAmount;
        _gonBalances[recipient] = _gonBalances[recipient] + gonAmountReceived;

        emit Transfer(sender, recipient,gonAmountReceived / _gonsPerFragment);

        if(shouldRebase() && autoRebase) {
            _rebase();

            if(!automatedMarketMakerPairs[sender] && !automatedMarketMakerPairs[recipient]){
                manualSync();
            }
        }

        return true;
    }

    function _swapAndLiquify(uint256 contractTokenBalance) private {
        uint256 half = contractTokenBalance / 2;
        uint256 otherHalf = contractTokenBalance - half;

        if(isLiquidityInBNB){
            uint256 initialBalance = address(this).balance;

            _swapTokensForBNB(half, address(this));

            uint256 newBalance = address(this).balance - initialBalance;

            _addLiquidity(otherHalf, newBalance);

            emit SwapAndLiquify(half, newBalance, otherHalf);
        }else{
            uint256 initialBalance = IERC20(BUSDToken).balanceOf(address(this));

            _swapTokensForBUSD(half, address(this));

            uint256 newBalance = IERC20(BUSDToken).balanceOf(address(this)) - initialBalance;

            _addLiquidityBusd(otherHalf, newBalance);

            emit SwapAndLiquifyBUSD(half, newBalance, otherHalf);
        }
    }

    function _addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        uniswapV2Router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
    }
    function _addLiquidityBusd(uint256 tokenAmount, uint256 busdAmount) private {
        uniswapV2Router.addLiquidity(
            address(this),
            BUSDToken,
            tokenAmount,
            busdAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function _swapTokensForBNB(uint256 tokenAmount, address to) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );
    }

    function _swapTokensForBUSD(uint256 tokenAmount, address to) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = BUSDToken;

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );
    }
    
    function _swapBNBForTokens(uint256 amount, address to) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        // make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0, // accept any amount of Tokens
            path,
            to, // Burn address
            block.timestamp
        );
    }

    function buyBackTokens(uint256 amount) private swapping {
    	if (amount > 0) {
    	    _swapBNBForTokens(amount, DEAD);
	    }
    }

    function swapBack() internal swapping {
        uint256 totalFeesToSwap = checkSwapThreshold();

        uint256 liquidityFees = (totalFeesToSwap * (buyFeeRates.liquidity + sellFeeRates.liquidity)) / (totalBuyFees + totalSellFees);

        uint256 LIFFees = (totalFeesToSwap * (buyFeeRates.lif + sellFeeRates.lif)) / (totalBuyFees + totalSellFees);

        uint256 treasureFees = (totalFeesToSwap * (buyFeeRates.treasury + sellFeeRates.treasury)) / (totalBuyFees + totalSellFees);

        uint256 BUSDFees = (totalFeesToSwap * (buyFeeRates.busd + sellFeeRates.busd)) / (totalBuyFees + totalSellFees);

        uint256 buyBackFees = (totalFeesToSwap * (buyFeeRates.buyBack + sellFeeRates.buyBack)) / (totalBuyFees + totalSellFees);

        uint256 BNBFees = (totalFeesToSwap * (buyFeeRates.bnb + sellFeeRates.bnb)) / (totalBuyFees + totalSellFees);

        // Adding Liquidity Fees
        if(!isOverLiquified(targetLiquidity) && liquidityFees > 0) {
            _swapAndLiquify(liquidityFees);
        }

        // Paying LIF Fees
        _gonBalances[LIFWallet] = _gonBalances[LIFWallet] + (LIFFees * _gonsPerFragment);
        _gonBalances[address(this)] = _gonBalances[address(this)] - (LIFFees * _gonsPerFragment);

        // Paying Treasury Fees
        if (treasureFees > 0) {
            _swapTokensForBNB(treasureFees, treasuryWallet);
        }

        // Paying BUSD Fees
        if (BUSDFees > 0) {
            _swapTokensForBUSD(BUSDFees, BUSDWallet);
        }

        // Paying Buy Back Fees
        if (buyBackFees > 0) {
            _swapTokensForBNB(buyBackFees, address(this));
        }

        // Paying BNB Fees
        if (BNBFees > 0) {
            _swapTokensForBNB(BNBFees, BNBWallet);
        }

        pendingBuyFees = (balanceOf(address(this)) * totalBuyFees) / (totalBuyFees + totalSellFees);
        pendingSellFees = (balanceOf(address(this)) * totalSellFees) / (totalBuyFees + totalSellFees);
    }

    function takeFee(address sender, address recipient, uint256 gonAmount) internal returns (uint256) {
        uint256 feeAmount;

        if (automatedMarketMakerPairs[sender]) {
            feeAmount = percent(gonAmount, totalBuyFees);
            pendingBuyFees += feeAmount / _gonsPerFragment;

        } else if (automatedMarketMakerPairs[recipient]) {
            feeAmount = percent(gonAmount, totalSellFees);
            pendingSellFees += feeAmount / _gonsPerFragment;

        } else {
            feeAmount = percent(gonAmount, totalSellFees);
            pendingBuyFees += feeAmount / _gonsPerFragment;
        }


        _gonBalances[address(this)] = _gonBalances[address(this)] + feeAmount;

        emit Transfer(sender, address(this), feeAmount / _gonsPerFragment);

        return gonAmount - feeAmount;
    }

    function _rebase() private {
        if(!inSwap) {
            uint256 circulatingSupply = getCirculatingSupply();
            int256 supplyDelta = int256(circulatingSupply * rewardYield / rewardYieldDenominator);

            coreRebase(supplyDelta);
        }
    }

    function coreRebase(int256 supplyDelta) private returns (uint256) {
        uint256 epoch = block.timestamp;

        if (supplyDelta == 0) {
            emit LogRebase(epoch, _totalSupply);
            return _totalSupply;
        }

        if (supplyDelta < 0) {
            _totalSupply = _totalSupply - uint256(-supplyDelta);
        } else {
            _totalSupply = _totalSupply + uint256(supplyDelta);
        }

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        _gonsPerFragment = TOTAL_GONS / _totalSupply;

        nextRebase = epoch + rebaseFrequency;

        emit LogRebase(epoch, _totalSupply);

        return _totalSupply;
    }

    function manualRebase() external {
        require(!inSwap, "Try again");
        require(isWhitelisted[msg.sender], "Not Whitelisted");
        require(nextRebase <= block.timestamp, "Not in time");

        uint256 circulatingSupply = getCirculatingSupply();
        int256 supplyDelta = int256(circulatingSupply * rewardYield / rewardYieldDenominator);

        coreRebase(supplyDelta);
        manualSync();
    }

    function setAutomatedMarketMakerPair(address _pair, bool _value) public onlyOwner {
        require(automatedMarketMakerPairs[_pair] != _value, "Value already set");

        automatedMarketMakerPairs[_pair] = _value;

        if(_value){
            _markerPairs.push(_pair);
        } else {
            require(_markerPairs.length > 1, "Required 1 pair");
            for (uint256 i = 0; i < _markerPairs.length; i++) {
                if (_markerPairs[i] == _pair) {
                    _markerPairs[i] = _markerPairs[_markerPairs.length - 1];
                    _markerPairs.pop();
                    break;
                }
            }
        }

        emit SetAutomatedMarketMakerPair(_pair, _value);
    }

    function addToWhitelist(address[] memory account) external onlyOwner {
        for(uint256 i=0; i < account.length; i++) {
            isWhitelisted[account[i]] = true;
        }
    }

    function removeFromWhitelist(address[] memory account) external onlyOwner {
        for(uint256 i=0; i < account.length; i++) {
            isWhitelisted[account[i]] = false;
        }
    }

    function setWalletToWalletEnabled(bool _enabled) external onlyOwner {
        walletToWalletEnabled = _enabled;
    }

    function setInitialDistributionFinished(bool _value) external onlyOwner {
        require(initialDistributionFinished != _value, "Not changed");
        initialDistributionFinished = _value;
    }

    function excludeFromFee(address _addr, bool _value) external onlyOwner {
        require(_isExcludedFromFee[_addr] != _value, "Not changed");
        _isExcludedFromFee[_addr] = _value;
    }

    function setAllowedSellingPercent(uint256 _allowedSellPercent) external onlyOwner {
        allowedSellPercent = _allowedSellPercent;
    }

    function setCooldownPeriod(uint256 _cooldownPeriod) external onlyOwner {
        cooldownPeriod = _cooldownPeriod;
    }

    function setTargetLiquidity(uint256 target) external onlyOwner {
        targetLiquidity = target;
    }

    function setSwapBackSettings(bool _enabled) external onlyOwner {
        swapEnabled = _enabled;
    }

    function setSwapThreshold(uint256 _swapThreshold) external onlyOwner {
        swapThreshold = _swapThreshold;
    }

    function setBuyBackSettings(bool _enabled) external onlyOwner {
        buyBackEnabled = _enabled;
    }

    function setBuybackUpperLimit(uint256 buyBackLimit) external onlyOwner {
        buyBackUpperLimit = buyBackLimit;
    }

    function setFeeAddresses(
        address _LIFWallet, 
        address _treasuryWallet, 
        address _BUSDWallet,
        address _BNBWallet
    ) external onlyOwner {
        require(_LIFWallet != address(0), "Zero Address");
        require(_treasuryWallet != address(0), "Zero Address");
        require(_BUSDWallet != address(0), "Zero Address");
        require(_BNBWallet != address(0), "Zero Address");

        LIFWallet = _LIFWallet;
        treasuryWallet = _treasuryWallet;
        BUSDWallet = _BUSDWallet;
        BNBWallet = _BNBWallet;
    }

    function setFeeRates(feeRateStruct memory _buyFeeRates, feeRateStruct memory _sellFeeRates) external onlyOwner {
         uint256 _totalBuyFees = _buyFeeRates.liquidity
                + _buyFeeRates.lif
                + _buyFeeRates.treasury
                + _buyFeeRates.busd
                + _buyFeeRates.buyBack
                + _buyFeeRates.bnb;

        uint256 _totalSellFees = _sellFeeRates.liquidity
                + _sellFeeRates.lif
                + _sellFeeRates.treasury
                + _sellFeeRates.busd
                + _sellFeeRates.buyBack
                + _sellFeeRates.bnb;
        
        require(_totalBuyFees + _totalSellFees <= 3000, "Total Tax above 30%");
        
        buyFeeRates = _buyFeeRates;
        sellFeeRates = _sellFeeRates;
        totalBuyFees = _totalBuyFees;
        totalSellFees = _totalSellFees;

        emit FeesChanged();
    }

    function rescueToken(address tokenAddress, uint256 tokens) external onlyOwner returns (bool success){
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }

    function setAutoRebase(bool _autoRebase) external onlyOwner {
        require(autoRebase != _autoRebase, "Not changed");
        autoRebase = _autoRebase;
    }

    function setRebaseFrequency(uint256 _rebaseFrequency) external onlyOwner {
        require(_rebaseFrequency <= MAX_REBASE_FREQUENCY, "Too high");
        rebaseFrequency = _rebaseFrequency;
    }

    function setRewardYield(uint256 _rewardYield, uint256 _rewardYieldDenominator) external onlyOwner {
        rewardYield = _rewardYield;
        rewardYieldDenominator = _rewardYieldDenominator;
    }

    function setFeesOnNormalTransfers(bool _enabled) external onlyOwner {
        require(feesOnNormalTransfers != _enabled, "Not changed");
        feesOnNormalTransfers = _enabled;
    }

    function setIsLiquidityInBnb(bool _value) external onlyOwner {
        require(isLiquidityInBNB != _value, "Not changed");
        isLiquidityInBNB = _value;
    }

    function setNextRebase(uint256 _nextRebase) external onlyOwner {
        nextRebase = _nextRebase;
    }

    function setMaxSellTransaction(uint256 _maxTxn) external onlyOwner {
        maxSellTransactionAmount = _maxTxn;
    }

    function percent(uint256 amount, uint256 fraction) public virtual pure returns(uint256) {
        return ((amount * fraction) / 10000);
    }

    /**
     * @dev Update router address in case of pancakeswap migration
     */
    function setRouterAddress(address newRouter) external onlyOwner {
        require(newRouter != address(uniswapV2Router));
        IUniswapV2Router02 _newRouter = IUniswapV2Router02(newRouter);
        address get_pair = IUniswapV2Factory(_newRouter.factory()).getPair(address(this), _newRouter.WETH());
        if (get_pair == address(0)) {
            uniswapV2Pair = IUniswapV2Factory(_newRouter.factory()).createPair(address(this), _newRouter.WETH());
        }
        else {
            uniswapV2Pair = get_pair;
        }
        uniswapV2Router = _newRouter;
    }

    /**
     * @dev Withdraw BNB Dust
     */
    function withdrawDust(uint256 weiAmount, address to) external onlyOwner {
        require(address(this).balance >= weiAmount, "insufficient BNB balance");
        (bool sent, ) = payable(to).call{value: weiAmount}("");
        require(sent, "Failed to withdraw");
    }

    receive() external payable {}
}