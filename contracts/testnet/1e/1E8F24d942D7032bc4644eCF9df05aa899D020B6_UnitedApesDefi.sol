/**
 *Submitted for verification at BscScan.com on 2022-05-22
*/

// SPDX-License-Identifier: Unlicensed
/**
* United Apes Defi Token
* @developer: yummyDAO, @Discord: yummy#3220
**/

pragma solidity ^0.7.6;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
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
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
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
        require(b != 0);
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IPancakeSwapPair {
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

interface IPancakeSwapRouter{
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

interface IPancakeSwapFactory {
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

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IERC20 BUSD = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
    //address testnet BUSD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
    //address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    IPancakeSwapRouter router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public currentIndex;

    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;
    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * (10 ** 18);

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _router) {
        router = _router != address(0)
        ? IPancakeSwapRouter(_router)
        : IPancakeSwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        _token = msg.sender;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = BUSD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(BUSD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = BUSD.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            BUSD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
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
}

contract UnitedApesDefi is ERC20Detailed, Ownable {

    using SafeMath for uint256;
    using SafeMathInt for int256;

       //Last Ape variables
    // 100%
    uint256 private constant MAX_PCT = 10000;
    uint256 private constant BNB_DECIMALS = 18;
    uint256 private constant USDT_DECIMALS = 18;
    address private constant USDT = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    uint256 private constant ROUTER_FEE = 25;

    // Jackpot hard limits
    uint256 private constant JACKPOT_TIMESPAN_LIMIT_MIN = 30;
    uint256 private constant JACKPOT_TIMESPAN_LIMIT_MAX = 1200;

    uint256 private constant JACKPOT_BIGBANG_MIN = 30 * 10**USDT_DECIMALS;
    uint256 private constant JACKPOT_BIGBANG_MAX = 250000 * 10**USDT_DECIMALS;

    uint256 private constant JACKPOT_BUYER_SHARE_MIN = 3000;
    uint256 private constant JACKPOT_BUYER_SHARE_MAX = 10000;

    uint256 private constant JACKPOT_MINBUY_MIN = 5 * 10**(BNB_DECIMALS - 2);
    uint256 private constant JACKPOT_MINBUY_MAX = 1 * 10**(BNB_DECIMALS);

    uint256 private constant JACKPOT_CASHOUT_MIN = 4000;
    uint256 private constant JACKPOT_CASHOUT_MAX = 7000;

    uint256 private constant JACKPOT_BIGBANG_BUYBACK_MIN = 3000;
    uint256 private constant JACKPOT_BIGBANG_BUYBACK_MAX = 7000;

    uint256 private _jackpotTokens = 0;

    uint256 public jackpotCashout = 5000;
    uint256 public jackpotBuyerShare = 9000;
    // Buys > 0.1 BNB will be eligible for the jackpot
    uint256 public jackpotMinBuy = 1 * 10**(BNB_DECIMALS - 1);
    // Jackpot time span is initially set to 10 mins
    uint256 public jackpotTimespan = 10 * 60;
    // Jackpot hard limit, BNB value
    uint256 public jackpotHardLimit = 250 * 10**(BNB_DECIMALS);
    // Jackpot hard limit buyback share
    uint256 public jackpotHardBuyback = 5000;

    address payable private _lastBuyer = payable(address(this));
    uint256 private _lastBuyTimestamp = 0;

    address private _lastAwarded = address(0);
    uint256 private _lastAwardedCash = 0;
    uint256 private _lastAwardedTokens = 0;
    uint256 private _lastAwardedTimestamp = 0;

    uint256 private _lastBigBangCash = 0;
    uint256 private _lastBigBangTokens = 0;
    uint256 private _lastBigBangTimestamp = 0;
    uint256 private _pendingJackpotBalance = 0;
    uint256 public _totalJackpotCashedOut = 0;
    uint256 private _totalJackpotTokensOut = 0;
    uint256 private _totalJackpotBuyer = 0;
    uint256 private _totalJackpotBuyback = 0;
    uint256 private _totalJackpotBuyerTokens = 0;
    uint256 private _totalJackpotBuybackTokens = 0;



    string public _name = "United Apes Defi";
    string public _symbol = "UAD";
    uint8 public _decimals = 5;

    IPancakeSwapPair public pairContract;
    mapping(address => bool) _isFeeExempt;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    uint256 public constant DECIMALS = 5;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint8 public constant RATE_DECIMALS = 7;

    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 5 * 10**6 * 10**DECIMALS;

    uint256 public UnitedApesLiquidity = 20;
    uint256 public treasuryFee = 40;
    uint256 public BusdDividend = 20;
    uint256 public SellBusdDividend = 40;
    uint256 public BurnFee = 10;
    uint256 public JackpotFee = 40;
    uint256 public SelljackpotFee = 60;
    uint256 private rewardunit = 30;
    uint256 private liquidityunit = 40;
    uint256 private buybackunit = 30;

    uint256 public totalFee = UnitedApesLiquidity.add(treasuryFee).add(BusdDividend).add(BurnFee).add(JackpotFee);
    uint256 public totalsellFee = 0;
    uint256 public feeDenominator = 1000;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address payable public BuybackWallet;
    address public deployer;
    address public lpReceiver;
    address public treasuryReceiver;
    address public DividendReceiver;
    address public firePit;
    address public pairAddress;
    DividendDistributor distributor;
    uint256 distributorGas = 500000;
    bool public swapEnabled = true;
    IPancakeSwapRouter public router;
    address public pair;
    bool inSwap = false;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
    uint256 private constant MAX_SUPPLY = 50 * 10**9 * 10**DECIMALS;

    // BOOL Variables
    bool public _autoRebase = true;
    bool public _autoAddLiquidity = true;

    // INT Variables
    uint256 public _initRebaseStartTime;
    uint256 public _lastRebasedTime;
    uint256 public _lastAddLiquidityTime;
    uint256 public _totalSupply;
    uint256 private _gonsPerFragment;
    // MAPPING
    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blacklist;
    mapping(address => bool) public isDividendExempt;

    // EVENT
    event Rebased(uint256 indexed epoch, uint256 totalSupply);

    constructor() ERC20Detailed("United Apes Defi", "UAD", uint8(DECIMALS)) Ownable() {

        router = IPancakeSwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        pair = IPancakeSwapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        lpReceiver = 0x9B4946e98Af75DF5425Df7811B549FDDCE4b301f;
        treasuryReceiver = 0xd52C0377D4422d0DF35eA17FDfe9f3fa83b85660;
        distributor = new DividendDistributor(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        DividendReceiver = address(distributor);
        BuybackWallet = payable(0x5bF338f5352a4d38e0a00837A4D953B92E7c1B4E);
        firePit = 0x0000000000000000000000000000000000000000;

        _allowedFragments[address(this)][address(router)] = uint256(-1);
        _allowedFragments[address(this)][pair] = uint256(-1);
        pairAddress = pair;
        pairContract = IPancakeSwapPair(pair);

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[owner()] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _initRebaseStartTime = block.timestamp;
        _lastRebasedTime = block.number;

        _isFeeExempt[owner()] = true;
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[treasuryReceiver] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        _lastBuyTimestamp = block.timestamp;
        deployer = msg.sender;

        emit Transfer(address(0x0),  owner(), _totalSupply);
    }

    function setZeroFees() external onlyOwner {
        UnitedApesLiquidity = 0;
        treasuryFee = 0;
        BusdDividend = 0;
        SellBusdDividend = 0;
        BurnFee = 0;
        JackpotFee = 0;
        SelljackpotFee = 0;

        totalsellFee = 0;
        totalFee = 0;
    }

    function setNormalFees() external onlyOwner {
        UnitedApesLiquidity = 20;
        treasuryFee = 40;
        BusdDividend = 20;
        SellBusdDividend = 40;
        BurnFee = 10;
        JackpotFee = 40;
        SelljackpotFee = 60;
        totalFee = UnitedApesLiquidity.add(treasuryFee).add(BusdDividend).add(BurnFee).add(JackpotFee);
        totalsellFee = UnitedApesLiquidity.add(treasuryFee).add(SellBusdDividend).add(BurnFee).add(SelljackpotFee);
    }

    function manualRebase() external onlyOwner {
        rebase();
    }

    function rebase() internal {

        if ( inSwap ) return;

        uint deno = 10**7 * 10**18;
        uint rebaseRate = 199 * 10**18;
        uint minuteRebaseRate = 3980 * 10**18;
        uint hourRebaseRate = 238800 * 10**18;
        uint dayRebaseRate = 5731200 * 10**18;

        uint blockCount = block.number.sub(_lastRebasedTime);
        uint tmp = _totalSupply;
        for (uint idx = 0; idx < blockCount.mod(20); idx++) { // 3 sec rebase
            // S' = S(1+p)^r
            tmp = tmp.mul(deno.mul(100).add(rebaseRate)).div(deno.mul(100));
        }

        for (uint idx = 0; idx < blockCount.div(20).mod(60); idx++) { // 1 min rebase
            // S' = S(1+p)^r
            tmp = tmp.mul(deno.mul(100).add(minuteRebaseRate)).div(deno.mul(100));
        }

        for (uint idx = 0; idx < blockCount.div(20 * 60).mod(24); idx++) { // 1 hour rebase
            // S' = S(1+p)^r
            tmp = tmp.mul(deno.mul(100).add(hourRebaseRate)).div(deno.mul(100));
        }

        for (uint idx = 0; idx < blockCount.div(20 * 60 * 24); idx++) { // 1 day rebase
            // S' = S(1+p)^r
            tmp = tmp.mul(deno.mul(100).add(dayRebaseRate)).div(deno.mul(100));
        }

        _totalSupply = tmp;
        _gonsPerFragment = TOTAL_GONS.div(tmp);
        _lastRebasedTime = block.number;

        pairContract.sync();

        emit Rebased(block.timestamp, _totalSupply);
    }

    function transfer(address to, uint256 value)
    external
    override
    validRecipient(to)
    returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override validRecipient(to) returns (bool) {

        if (_allowedFragments[from][msg.sender] != uint256(-1)) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][
            msg.sender
            ].sub(value, "Insufficient Allowance");
        }
        _transferFrom(from, to, value);
        return true;
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        _gonBalances[to] = _gonBalances[to].add(gonAmount);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {

        require(!blacklist[sender] && !blacklist[recipient], "in_blacklist");

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }
        if (shouldRebase()) {
            rebase();
        }

        if (shouldAddLiquidity()) {
            addLiquidity();
        }

        if (shouldSwapBack()) {
            swapBack();
        }

        if (_pendingJackpotBalance >= jackpotHardLimit){
            processBigBang();
        } else if (
            _lastBuyer != address(0) &&
            _lastBuyer != address(this) &&
            block.timestamp.sub(_lastBuyTimestamp) >= jackpotTimespan
        ){
            awardJackpot();
        }

        if (sender != deployer){
            if (isJackpotEligible(amount)){
                _lastBuyTimestamp = block.timestamp;
                _lastBuyer = payable(recipient);
            }
        }

        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
        uint256 gonAmountReceived = shouldTakeFee(sender, recipient)
        ? takeFee(sender, recipient, gonAmount)
        : gonAmount;
        _gonBalances[recipient] = _gonBalances[recipient].add(
            gonAmountReceived
        );

        if(!isDividendExempt[sender]){ try distributor.setShare(sender, balanceOf(sender)) {} catch {} }
        if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, balanceOf(recipient)) {} catch {} }

        try distributor.process(distributorGas) {} catch {}


        emit Transfer(
            sender,
            recipient,
            gonAmountReceived.div(_gonsPerFragment)
        );
        return true;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 gonAmount
    ) internal  returns (uint256) {
        uint256 _totalFee = totalFee;
        BurnFee = BurnFee; //change this to just burnfee

        if (recipient == pair) {
            uint256 timefromlaunch = block.timestamp - _initRebaseStartTime;
            if (timefromlaunch < (_initRebaseStartTime + 43200)){
                    UnitedApesLiquidity = 20 + 60;
                    treasuryFee = 40 + 20;
                    SellBusdDividend = 40 + 40;
                    BurnFee = 10 + 20;
                    SelljackpotFee = 60 +60;
                    totalsellFee = UnitedApesLiquidity.add(treasuryFee).add(SellBusdDividend).add(BurnFee).add(SelljackpotFee);
                    _totalFee = totalsellFee;
            }else if(timefromlaunch > (_initRebaseStartTime + 86400)){
                    UnitedApesLiquidity = 20 + 40;
                    treasuryFee = 40 + 20;
                    SellBusdDividend = 40 + 40;
                    BurnFee = 10 + 20;
                    SelljackpotFee = 60 +50;
                    totalsellFee = UnitedApesLiquidity.add(treasuryFee).add(SellBusdDividend).add(BurnFee).add(SelljackpotFee);
                    _totalFee = totalsellFee;
            }else if(timefromlaunch > (_initRebaseStartTime + 129600)){
                    UnitedApesLiquidity = 20 + 30;
                    treasuryFee = 40 + 20;
                    SellBusdDividend = 40 + 30;
                    BurnFee = 10 + 20;
                    SelljackpotFee = 60 +40;
                    totalsellFee = UnitedApesLiquidity.add(treasuryFee).add(SellBusdDividend).add(BurnFee).add(SelljackpotFee);
                    _totalFee = totalsellFee;
            }else if(timefromlaunch > (_initRebaseStartTime + 156100)){
                    UnitedApesLiquidity = 20 + 20;
                    treasuryFee = 40 + 20;
                    SellBusdDividend = 40 + 30;
                    BurnFee = 10 + 10;
                    SelljackpotFee = 60 +30;
                    totalsellFee = UnitedApesLiquidity.add(treasuryFee).add(SellBusdDividend).add(BurnFee).add(SelljackpotFee);
                    _totalFee = totalsellFee;
            }else if(timefromlaunch > (_initRebaseStartTime + 199300)){
                    UnitedApesLiquidity = 20 + 20;
                    treasuryFee = 40 + 20;
                    SellBusdDividend = 40 + 20;
                    BurnFee = 10;
                    SelljackpotFee = 60 + 20;
                    totalsellFee = UnitedApesLiquidity.add(treasuryFee).add(SellBusdDividend).add(BurnFee).add(SelljackpotFee);
                    _totalFee = totalsellFee;
            }else if(timefromlaunch > (_initRebaseStartTime + 242500)){
                    UnitedApesLiquidity = 20;
                    treasuryFee = 40;
                    SellBusdDividend = 40;
                    BurnFee = 10;
                    SelljackpotFee = 60;
                    totalsellFee = UnitedApesLiquidity.add(treasuryFee).add(SellBusdDividend).add(BurnFee).add(SelljackpotFee);
                    _totalFee = totalsellFee;
            }
            BurnFee = BurnFee;
        }

        uint256 feeAmount = gonAmount.div(feeDenominator).mul(_totalFee);

        _gonBalances[firePit] = _gonBalances[firePit].add(
            gonAmount.div(feeDenominator).mul(BurnFee)
        );
        uint256 maintainFee = _totalFee - BurnFee - UnitedApesLiquidity;

        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            gonAmount.div(feeDenominator).mul(maintainFee)
        );
        _gonBalances[lpReceiver] = _gonBalances[lpReceiver].add(
            gonAmount.div(feeDenominator).mul(UnitedApesLiquidity)
        );
        

        emit Transfer(sender, address(this), feeAmount.div(_gonsPerFragment));
        return gonAmount.sub(feeAmount);
    }

    function addLiquidity() internal swapping {
        uint256 autoLiquidityAmount = _gonBalances[lpReceiver].div(
            _gonsPerFragment
        );
        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            _gonBalances[lpReceiver]
        );
        _gonBalances[lpReceiver] = 0;
        uint256 amountToLiquify = autoLiquidityAmount.div(2);
        uint256 amountToSwap = autoLiquidityAmount.sub(amountToLiquify);

        if( amountToSwap == 0 ) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        uint256 balanceBefore = address(this).balance;


        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETHLiquidity = address(this).balance.sub(balanceBefore);

        if (amountToLiquify > 0&&amountETHLiquidity > 0) {
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                owner(),
                block.timestamp
            );
        }
        _lastAddLiquidityTime = block.timestamp;
    }

    function swapBack() internal swapping {

        uint256 amountToSwap = _gonBalances[address(this)].div(_gonsPerFragment);

        if( amountToSwap == 0) {
            return;
        }

        uint256 balanceBefore = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();


        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 currentBalance = address(this).balance.sub(
            balanceBefore
        );

        uint256 _currentFee = treasuryFee.add(BusdDividend).add(JackpotFee);

        (bool success, ) = payable(treasuryReceiver).call{
        value: currentBalance.mul(treasuryFee).div(
            _currentFee
        ),
        gas: 30000
        }("");
        require(success,'Not sent');

        try distributor.deposit {
            value: currentBalance.mul(BusdDividend).div(treasuryFee.add(BusdDividend))
        } () {} catch {}

        uint256 yummypot = currentBalance.mul(JackpotFee).div(
            _currentFee);
        _pendingJackpotBalance += yummypot;

    }

    function withdrawAllToTreasury() external swapping onlyOwner {

        uint256 amountToSwap = _gonBalances[address(this)].div(_gonsPerFragment);
        require( amountToSwap > 0,"There is no token deposited in token contract");
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            treasuryReceiver,
            block.timestamp
        );
    }

    function shouldTakeFee(address from, address to)
    internal
    view
    returns (bool)
    {
        return
        (pair == from || pair == to) &&
        !_isFeeExempt[from];
    }

    function shouldRebase() internal view returns (bool) {
        return
        _autoRebase &&
        (_totalSupply < MAX_SUPPLY) &&
        msg.sender != pair  &&
        !inSwap &&
        block.number >= (_lastRebasedTime + 1);
    }

    function shouldAddLiquidity() internal view returns (bool) {
        return
        _autoAddLiquidity &&
        !inSwap &&
        msg.sender != pair &&
        block.timestamp >= (_lastAddLiquidityTime + 2 days);
    }

    function shouldSwapBack() internal view returns (bool) {
        return
        !inSwap &&
        msg.sender != pair  ;
    }

    function setAutoRebase(bool _flag) external onlyOwner {
        if (_flag) {
            _autoRebase = _flag;
            _lastRebasedTime = block.number;
        } else {
            _autoRebase = _flag;
        }
    }

    function setAutoAddLiquidity(bool _flag) external onlyOwner {
        if(_flag) {
            _autoAddLiquidity = _flag;
            _lastAddLiquidityTime = block.timestamp;
        } else {
            _autoAddLiquidity = _flag;
        }
    }

    function allowance(address owner_, address spender)
    external
    view
    override
    returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    returns (bool)
    {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
    external
    returns (bool)
    {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][
        spender
        ].add(addedValue);
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function approve(address spender, uint256 value)
    external
    override
    returns (bool)
    {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function setDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 750000, "Gas must be lower than 750000");
        distributorGas = gas;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function balanceOf(address holder) public view override returns (uint256) {
        return _gonBalances[holder].div(_gonsPerFragment);
    }

    function setIsDividendExempt(address holder, bool exempt) external onlyOwner {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;

        if (exempt) {
            distributor.setShare(holder, 0);
        } else {
            distributor.setShare(holder, balanceOf(holder));
        }
    }

    function getCirculatingSupply() public view returns (uint256) {
        return
        (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(
            _gonsPerFragment
        );
    }

    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }

    function manualSync() external {
        IPancakeSwapPair(pair).sync();
    }


    function setFeeReceivers(
        address _lpReceiver,
        address _treasuryReceiver,
        address _DividendReceiver,
        address payable _BuybackWallet
    ) external onlyOwner {
        treasuryReceiver = _treasuryReceiver;
        DividendReceiver = _DividendReceiver;
        BuybackWallet = _BuybackWallet;
        lpReceiver = _lpReceiver;
    }

    function getLiquidityBacking(uint256 accuracy)
    public
    view
    returns (uint256)
    {
        uint256 liquidityBalance = _gonBalances[pair].div(_gonsPerFragment);
        return
        accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }

    function setWhitelist(address _addr) external onlyOwner {
        _isFeeExempt[_addr] = true;
    }

    function setBotBlacklist(address _botAddress, bool _flag) external onlyOwner {
        require(isContract(_botAddress), "only contract address, not allowed exteranlly owned account");
        blacklist[_botAddress] = _flag;
    }

    function setPairAddress(address _pairAddress) public onlyOwner {
        pairAddress = _pairAddress;
    }

    function setLP(address _address) external onlyOwner {
        pairContract = IPancakeSwapPair(_address);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function recoverToken(address tokenAddress, uint256 tokens)
    external
    onlyOwner
    returns (bool success)
    {
        return ERC20Detailed(tokenAddress).transfer(msg.sender, tokens);
    }

    function checksellfee() public view returns (uint256){
        return totalsellFee;
    }

    function isJackpotEligible(uint256 tokenAmount) public view returns (bool) {
        if (jackpotMinBuy == 0) {
            return true;
        }
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(this);

        uint256 tokensOut = router.getAmountsOut(jackpotMinBuy, path)[1].mul(MAX_PCT.sub(ROUTER_FEE)).div(
                MAX_PCT
            );
        return tokenAmount >= tokensOut;
    }

    /*function getAmountsOut(uint256 tokenAmount) public view returns (bool) {
        if (jackpotMinBuy == 0) {
            return true;
        }
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = USDT;

        uint256 token = router.getAmountsOut(jackpotMinBuy, path)[1];
        uint256 tokensOut = token.mul(MAX_PCT.sub(ROUTER_FEE)).div(
                // We don't subtract the buy fee since the tokenAmount is pre-tax
                MAX_PCT
        );

        return tokenAmount >= tokensOut;

        //uint256 tokens = router.getAmountsOut(amountIn, path);
        //return tokens;
        //return UniswapV2Library.getAmountsOut(factory, amountIn, path);
    }*/

    function awardJackpot() private swapping {
        require(
            _lastBuyer != address(0) && _lastBuyer != address(this),
            "No last buyer detected"
        );
        uint256 cashedOut = _pendingJackpotBalance.mul(jackpotCashout).div(
            MAX_PCT
        );
        uint256 tokensOut = _jackpotTokens.mul(jackpotCashout).div(MAX_PCT);
        uint256 buyerShare = cashedOut.mul(jackpotBuyerShare).div(MAX_PCT);
        uint256 tokensToBuyer = tokensOut.mul(jackpotBuyerShare).div(MAX_PCT);
        uint256 toBuyback = cashedOut - buyerShare;
        uint256 tokensToBuyback = tokensOut - tokensToBuyer;
        _lastBuyer.transfer(buyerShare);
        _basicTransfer(address(this), _lastBuyer, tokensToBuyer);
        BuybackWallet.transfer(toBuyback);
        _basicTransfer(address(this), treasuryReceiver, tokensToBuyback);

        _pendingJackpotBalance = _pendingJackpotBalance.sub(cashedOut);
        _jackpotTokens = _jackpotTokens.sub(tokensOut);

        _lastAwarded = _lastBuyer;
        _lastAwardedTimestamp = block.timestamp;
        _lastAwardedCash = buyerShare;
        _lastAwardedTokens = tokensToBuyer;

        _lastBuyer = payable(address(this));
        _lastBuyTimestamp = 0;

        _totalJackpotCashedOut = _totalJackpotCashedOut.add(cashedOut);
        _totalJackpotTokensOut = _totalJackpotTokensOut.add(tokensOut);
        _totalJackpotBuyer = _totalJackpotBuyer.add(buyerShare);
        _totalJackpotBuyerTokens = _totalJackpotBuyerTokens.add(tokensToBuyer);
        _totalJackpotBuyback = _totalJackpotBuyback.add(toBuyback);
        _totalJackpotBuybackTokens = _totalJackpotBuybackTokens.add(
            tokensToBuyback
        );
    }

    function processBigBang() private swapping {
        uint256 cashedOut = _pendingJackpotBalance.mul(jackpotHardBuyback).div(
            MAX_PCT
        );  
        uint256 tokensOut = _jackpotTokens.mul(jackpotHardBuyback).div(MAX_PCT);

        uint buyamount = cashedOut.mul(30).div(100);//buyunit
        uint rewardsamount = cashedOut.mul(30).div(100);//rewardunit
        uint liquidityamount = cashedOut.mul(40).div(100);//liquidityunit

        BuybackWallet.transfer(buyamount);

        swapethforUAD(liquidityamount);

        try distributor.deposit {
            value: rewardsamount
        } () {} catch {}

        _basicTransfer(address(this), treasuryReceiver, tokensOut);

        _lastBigBangCash = cashedOut;
        _lastBigBangTokens = tokensOut;
        _lastBigBangTimestamp = block.timestamp;

        _pendingJackpotBalance = _pendingJackpotBalance.sub(cashedOut);
        _jackpotTokens = _jackpotTokens.sub(tokensOut);

        _totalJackpotCashedOut = _totalJackpotCashedOut.add(cashedOut);
        _totalJackpotBuyback = _totalJackpotBuyback.add(cashedOut);
        _totalJackpotTokensOut = _totalJackpotTokensOut.add(tokensOut);
        _totalJackpotBuybackTokens = _totalJackpotBuybackTokens.add(tokensOut);
    }

    function swapethforUAD(uint amount) internal swapping{
        uint amountout;
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(this);

        router.swapExactETHForTokens{value: amount}(
            amountout,
            path,
            lpReceiver,
            block.timestamp
        );
    }

    function jackpotbalance() external view returns(uint256){
        return _pendingJackpotBalance;
    }

    function lastbuyer() external view returns(address){
        return _lastBuyer;
    }

    function lasttime() public view returns(uint256){
        return _lastBuyTimestamp;
    }

    function setjackpotcashout(uint amount) external onlyOwner{
        require(amount >= JACKPOT_CASHOUT_MIN);
        require(amount <= JACKPOT_CASHOUT_MAX);
        jackpotCashout = amount;
    }

    function setjackpothardlimit(uint amount) external onlyOwner{
        require(amount >= JACKPOT_BIGBANG_MIN);
        require(amount <= JACKPOT_BIGBANG_MAX);
        jackpotHardLimit = amount;
    }

    function setjackpotHardBuyback(uint amount) external onlyOwner{
        require(amount >= JACKPOT_BIGBANG_BUYBACK_MIN);
        require(amount <= JACKPOT_BIGBANG_BUYBACK_MAX);
        jackpotHardBuyback = amount;
    }

    function setjackpotTimespan(uint amount) external onlyOwner{
        require(amount >= JACKPOT_TIMESPAN_LIMIT_MIN);
        require(amount <= JACKPOT_CASHOUT_MAX);
        jackpotTimespan = amount; 
    }

    function setjackpotBuyerShare(uint amount) external onlyOwner{
        require(amount >= JACKPOT_BUYER_SHARE_MIN);
        require(amount <= JACKPOT_BUYER_SHARE_MAX);
        jackpotBuyerShare = amount;
    }

    function setjackpotbuylimit(uint amount) external onlyOwner{
        require(amount >= JACKPOT_BUYER_SHARE_MIN);
        require(amount <= JACKPOT_BUYER_SHARE_MAX);
        jackpotMinBuy = amount;
    }

    function sethardlimitfees(uint buyback, uint reward, uint liquidity) external onlyOwner{
        rewardunit = reward;
        buybackunit = buyback;
        liquidityunit = liquidity;
    }

    receive() external payable {}
}