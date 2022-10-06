/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

/**

██╗░░░░░░█████╗░██████╗░██╗░█████╗░░█████╗░██╗███╗░░██╗
██║░░░░░██╔══██╗██╔══██╗██║██╔══██╗██╔══██╗██║████╗░██║
██║░░░░░██║░░██║██║░░██║██║██║░░╚═╝██║░░██║██║██╔██╗██║
██║░░░░░██║░░██║██║░░██║██║██║░░██╗██║░░██║██║██║╚████║
███████╗╚█████╔╝██████╔╝██║╚█████╔╝╚█████╔╝██║██║░╚███║
╚══════╝░╚════╝░╚═════╝░╚═╝░╚════╝░░╚════╝░╚═╝╚═╝░░╚══╝

*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.7.4;

// import "./DividendDistributor.sol";

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

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
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
//pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// File: contracts\interfaces\IPancakeRouter01.sol

//pragma solidity >=0.6.2;

interface IPancakeRouter01 {
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

// File: contracts\interfaces\IPancakeRouter02.sol

//pragma solidity >=0.6.2;

interface IPancakeRouter02 is IPancakeRouter01 {
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

// File: contracts\interfaces\IPancakeFactory.sol

//pragma solidity >=0.5.0;

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
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

contract DividendDistributor {
    using SafeMath for uint256;

    address public _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    address[] shareholders;
    mapping(address => uint256) shareholderIndexes;
    mapping(address => uint256) shareholderClaims;

    mapping(address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10**36;

    uint256 public minPeriod = 30 * 60;
    uint256 public minDistribution = 1 * (10**5);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token);
        _;
    }

    constructor() {
        _token = msg.sender;
    }

    receive() external payable {}

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount) external onlyToken {
        if (shares[shareholder].amount > 0) {
            distributeDividend(shareholder);
        }

        if (amount > 0 && shares[shareholder].amount == 0) {
            addShareholder(shareholder);
        } else if (amount == 0 && shares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(
            shares[shareholder].amount
        );
    }

    function deposit(uint256 amount) external onlyToken {
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(
            dividendsPerShareAccuracyFactor.mul(amount).div(totalShares)
        );
    }

    function process(uint256 gas) external onlyToken {
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) {
            return;
        }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            if (shouldDistribute(shareholders[currentIndex])) {
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder)
        internal
        view
        returns (bool)
    {
        return
            shareholderClaims[shareholder] + minPeriod < block.timestamp &&
            getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) {
            return;
        }

        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0) {
            totalDistributed = totalDistributed.add(amount);

            payable(shareholder).transfer(amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder]
                .totalRealised
                .add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(
                shares[shareholder].amount
            );
        }
    }

    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder)
        public
        view
        returns (uint256)
    {
        if (shares[shareholder].amount == 0) {
            return 0;
        }

        uint256 shareholderTotalDividends = getCumulativeDividends(
            shares[shareholder].amount
        );
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if (shareholderTotalDividends <= shareholderTotalExcluded) {
            return 0;
        }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getHolderDetails(address holder)
        public
        view
        returns (
            uint256 lastClaim,
            uint256 unpaidEarning,
            uint256 totalReward,
            uint256 holderIndex
        )
    {
        lastClaim = shareholderClaims[holder];
        unpaidEarning = getUnpaidEarnings(holder);
        totalReward = shares[holder].totalRealised;
        holderIndex = shareholderIndexes[holder];
    }

    function getCumulativeDividends(uint256 share)
        internal
        view
        returns (uint256)
    {
        return
            share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return currentIndex;
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return shareholders.length;
    }

    function getShareHoldersList() external view returns (address[] memory) {
        return shareholders;
    }

    function totalDistributedRewards() external view returns (uint256) {
        return totalDistributed;
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[
            shareholders.length - 1
        ];
        shareholderIndexes[
            shareholders[shareholders.length - 1]
        ] = shareholderIndexes[shareholder];
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

contract LodicoinToken is ERC20Detailed, Ownable {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event ExcludedMaxTransactionAmount(address indexed account, bool isExcluded);


    string public constant _name = "LODICOIN";
    string public constant _symbol = "LODI";
    uint8 public constant _decimals = 9;

    mapping(address => bool) _isFeeExempt;
    mapping(address => bool) isDividendExempt;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    uint256 public constant DECIMALS = 9;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint8 public constant RATE_DECIMALS = 9;

    uint256 public constant INITIAL_FRAGMENTS_SUPPLY =
        22 * 10**6 * 10**DECIMALS;

    uint256 public buyLiquidityFee = 20;
    uint256 public buyDevelopmentGuardFee = 20;
    uint256 public buyInsuranceGuardFee = 30;
    uint256 public buyRewardFee= 30;
    uint256 public buyBurnFee = 20;
    uint256 public buyLCBRFee = 40;

    uint256 public sellLiquidityFee = 40;
    uint256 public sellDevelopmentGuardFee = 30;
    uint256 public sellInsuranceGuardFee = 30;
    uint256 public sellRewardFee= 30;
    uint256 public sellBurnFee = 20;
    uint256 public sellLCBRFee = 50;

    uint256 public LCBR_TOKEN_AMOUNT = 0;

    uint256 currentAPY = 300;
    uint256 public constant feeDenominator = 1000;
    uint256 public vestingPeriod = 30;

    address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;//0x2859e4544C4bB03966803b044A93563Bd2D0DD4D; 0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;

    address public autoLiquidityReceiver;
    address public developmentGuardReciever;
    address public insuranceGuardFeeReceiver;
    address public LCBRFeeReceiver;
    address public firePit;

    bool public tradingActive = false;
    DividendDistributor public dividendDistributor;
    uint256 distributorGas = 500000;
    uint256 minAmountForReward;

    IPancakeRouter02 public router;
    address[] public _markerPairs;
    uint256 public _markerPairCount;
    mapping(address => bool) public automatedMarketMakerPairs;

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    bool public swapEnabled = true;
    uint256 public swapThreshold = (_totalSupply * 10) / 10000; // 1% of supply

    uint256 private constant TOTAL_GONS =
        MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    uint256 public constant MAX_SUPPLY = 100 * 10**6 * 10**DECIMALS;

    bool public _autoRebase;
    bool public _autoAddLiquidity;
    uint256 public _initRebaseStartTime;
    uint256 public _lastRebasedTime;
    uint256 public _lastAddLiquidityTime;
    uint256 public _totalSupply;
    uint256 private _gonsPerFragment;
    uint256 public maxTransactionAmount;


    mapping(address => uint256) public _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blacklist;
    mapping (address => bool) public _isExcludedMaxTransactionAmount;

    uint256 public totalStakers = 0;
    uint256 public totalPoolAmount = 0;
    struct Invest{
    uint256 amountLock;  
    uint256 amountEarned;
    uint256 lockTime;
    uint256 unLockTime;
    bool releaseStatus;
    }

    mapping(address => Invest) public stakes;
    address[] public allStakers;

    constructor() ERC20Detailed("LODICOIN", "LODI", uint8(DECIMALS)) Ownable() {
        router = IPancakeRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);//0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D 0xD99D1c33F9fC3444f8101754aBC46c52416550D1//0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); //0x10ED43C718714eb63d5aA57B78B54704E256024E
        address _pair = IPancakeFactory(router.factory()).createPair(
            WBNB,
            address(this)
        );
        dividendDistributor = new DividendDistributor();
        address _owner = msg.sender;
        
        autoLiquidityReceiver = DEAD;
        developmentGuardReciever = 0x26d621C620a27C6AAa5B3176A8D479a047a0439f; 
        insuranceGuardFeeReceiver = 0xE9C5378B3005a83038Db5c1cEBbd999c2333Af16;
        LCBRFeeReceiver = 0xD9Aec88578990CC30F39B9a6149dab95A007df8B;
        firePit = DEAD;

        _allowedFragments[address(this)][address(router)] = uint256(-1);
        setAutomatedMarketMakerPair(_pair, true);

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[_owner] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        isDividendExempt[_pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        
        _isFeeExempt[_owner] = true;
        _isFeeExempt[developmentGuardReciever] = true;
        _isFeeExempt[insuranceGuardFeeReceiver] = true;
        _isFeeExempt[LCBRFeeReceiver] = true;
        _isFeeExempt[address(this)] = true;

        maxTransactionAmount = _totalSupply * 10 / 1000; // 1% maxTransactionAmountTxn

        excludeFromMaxTransaction(_owner, true);
        excludeFromMaxTransaction(address(this), true);
        excludeFromMaxTransaction(address(dividendDistributor), true);
        excludeFromMaxTransaction(address(_pair), true);
        excludeFromMaxTransaction(address(DEAD), true);

        _transferOwnership(_owner);
        emit Transfer(address(0x0), _owner, _totalSupply);
    }
    function getRebaseRate(uint256 _amount, uint256 _percentage) public pure returns(uint256){
        return (  (((_percentage * _amount) / 10000) / 365) / 24);
    }
    function rebase() public {
        
        if (MAX_SUPPLY > _totalSupply ) {
        uint256 rebaseRate;
        uint256 deltaTimeFromInit = block.timestamp - _initRebaseStartTime;
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(2 minutes);
        uint256 epoch = times.mul(2);
        
        uint256 totalAvailable = _totalSupply ;
        uint256 fRebaseAmount = 25500000 * 10 ** DECIMALS;
        uint256 sRebaseAmount =  33000000 * 10 ** DECIMALS;
        uint256 tRebaseAmount =  50000000 * 10 ** DECIMALS;
        uint256 foRebaseAmount = 65000000* 10 ** DECIMALS;
        uint256 lRebaseAmount = 75000000 * 10 ** DECIMALS;


        
        if (_totalSupply < fRebaseAmount) {
            rebaseRate = getRebaseRate(totalAvailable, 30000).div(10**RATE_DECIMALS);
            currentAPY = 30000;
        } else if (deltaTimeFromInit < sRebaseAmount) {
            rebaseRate = getRebaseRate(totalAvailable, 15000).div(10**RATE_DECIMALS);
            currentAPY = 15000;
        } else if (deltaTimeFromInit < tRebaseAmount) {
            rebaseRate = getRebaseRate(totalAvailable, 7500).div(10**RATE_DECIMALS);
            currentAPY = 7500;
        } else if (deltaTimeFromInit < foRebaseAmount) {
            rebaseRate = getRebaseRate(totalAvailable, 3750).div(10**RATE_DECIMALS);
            currentAPY = 3750;
        } else{
        rebaseRate = getRebaseRate(lRebaseAmount, 1875).div(10**RATE_DECIMALS);
            currentAPY = 1875;
        }

        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply
                .mul((10**RATE_DECIMALS).add(rebaseRate))
                .div(10**RATE_DECIMALS);
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(2 minutes));

        manualSync();

        emit LogRebase(epoch, _totalSupply);
        }
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

        if(!tradingActive){
            require(_isFeeExempt[sender] || _isFeeExempt[recipient], "Trading is not active.");
        }

        require(!blacklist[sender] && !blacklist[recipient], "in_blacklist");

            if(inSwap){ return _basicTransfer(sender, recipient, amount);}
        if (sender == _markerPairs[0] || recipient == _markerPairs[0]) {
        
        if (shouldRebase()) {
           rebase();
        }

        if (shouldAddLiquidity()) {
            addLiquidity();
        }

        if (shouldSwapBack()) {
            swapBack();
        }
        }
        if (!_isFeeExempt[sender] && !_isFeeExempt[recipient]) {
            //when buy
            if (automatedMarketMakerPairs[sender] && !_isExcludedMaxTransactionAmount[recipient]) {
                require(amount <= maxTransactionAmount, "Buy transfer amount exceeds the maxTransactionAmount.");
            } 
            //when sell
            else if (automatedMarketMakerPairs[recipient] && !_isExcludedMaxTransactionAmount[sender]) {
                require(amount <= maxTransactionAmount, "Sell transfer amount exceeds the maxTransactionAmount.");
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

        // Dividend tracker
        if (!isDividendExempt[sender]) {
            uint256 _balance = balanceOf(sender).mul(INITIAL_FRAGMENTS_SUPPLY).div(_totalSupply);
            if (_balance >= minAmountForReward){
                try
                    dividendDistributor.setShare(sender, _balance)
                {} catch {}
            }
        }

        if (!isDividendExempt[recipient]) {
            uint256 _balance = balanceOf(recipient).mul(INITIAL_FRAGMENTS_SUPPLY).div(_totalSupply);
            if (_balance >= minAmountForReward){
                try
                    dividendDistributor.setShare(recipient, _balance)
                {} catch {}
            }
        }

        try dividendDistributor.process(distributorGas) {} catch {}

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
        uint256 _liquidityFee;
        uint256 _developmentGuardFee;
        uint256 _insuranceGuardFee;
        uint256 _rewardFee;
        uint256 _burnFee;
        uint256 _LCBRFee;
        uint256 _totalFee;

        if (automatedMarketMakerPairs[recipient]) {
            _liquidityFee = sellLiquidityFee;
            _developmentGuardFee = sellDevelopmentGuardFee;
            _insuranceGuardFee = sellInsuranceGuardFee;
            _rewardFee = sellRewardFee;
            _burnFee = sellBurnFee;
            _LCBRFee = sellLCBRFee;
        }else if (automatedMarketMakerPairs[sender]){
            _liquidityFee = buyLiquidityFee;
            _developmentGuardFee = buyDevelopmentGuardFee;
            _insuranceGuardFee = buyInsuranceGuardFee;
            _rewardFee = buyRewardFee;
            _burnFee = buyBurnFee;
            _LCBRFee = buyLCBRFee;
        }
        _totalFee = _liquidityFee.add(_developmentGuardFee).add(_insuranceGuardFee).add(_rewardFee).add(_burnFee);
        _totalFee = _totalFee.add(_LCBRFee);

        uint256 feeAmount = gonAmount.div(feeDenominator).mul(_totalFee);
       
        LCBR_TOKEN_AMOUNT = LCBR_TOKEN_AMOUNT.add(
            gonAmount.div(feeDenominator).mul(_LCBRFee)
            );
        LCBR_TOKEN_AMOUNT = LCBR_TOKEN_AMOUNT.div(_gonsPerFragment);

        _gonBalances[firePit] = _gonBalances[firePit].add(
            gonAmount.div(feeDenominator).mul(_burnFee)
        );
        
        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            gonAmount.div(feeDenominator).mul(_developmentGuardFee.add(_insuranceGuardFee).add(_rewardFee).add(_LCBRFee))
        );
        _gonBalances[autoLiquidityReceiver] = _gonBalances[autoLiquidityReceiver].add(
            gonAmount.div(feeDenominator).mul(_liquidityFee)
        );
        
        emit Transfer(sender, address(this), feeAmount.div(_gonsPerFragment));
        return gonAmount.sub(feeAmount);
    }

    function addLiquidity() internal swapping {
        uint256 autoLiquidityAmount = _gonBalances[autoLiquidityReceiver].div(
            _gonsPerFragment
        );
        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            _gonBalances[autoLiquidityReceiver]
        );
        _gonBalances[autoLiquidityReceiver] = 0;
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
                autoLiquidityReceiver,
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

        uint256 amountETHToTransfer = address(this).balance.sub(
            balanceBefore
        );

        uint256 _totalFee = buyDevelopmentGuardFee.add(buyInsuranceGuardFee).add(buyRewardFee).add(buyLCBRFee)
            .add(sellDevelopmentGuardFee).add(sellInsuranceGuardFee).add(sellRewardFee).add(sellLCBRFee);

        (bool success, ) = payable(LCBRFeeReceiver).call{
            value: amountETHToTransfer.mul(buyLCBRFee.add(sellLCBRFee)).div(
                _totalFee
            ),
            gas: 30000
        }("");

        (success, ) = payable(insuranceGuardFeeReceiver).call{
            value: amountETHToTransfer.mul(buyInsuranceGuardFee.add(sellInsuranceGuardFee)).div(
                _totalFee
            ),
            gas: 30000
        }("");

        uint256 _tokenToReward = amountETHToTransfer.mul(buyRewardFee.add(sellRewardFee)).div(_totalFee);
        (success, ) = payable(address(dividendDistributor)).call{
            value: _tokenToReward,
            gas: 30000
        }("");
        try dividendDistributor.deposit(_tokenToReward) {} catch {}
        (success, ) = payable(developmentGuardReciever).call{
            value: (address(this).balance),
            gas: 30000
        }("");
    }

    function updateMaxAmount(uint256 newNum) external onlyOwner {
        require(newNum > (_totalSupply * 5 / 10000)/1e9, "Cannot set maxTransactionAmount lower than 0.05%");
        maxTransactionAmount = newNum * (10**9);
    }

    function excludeFromMaxTransaction(address updAds, bool isEx) public onlyOwner {
        _isExcludedMaxTransactionAmount[updAds] = isEx;
        emit ExcludedMaxTransactionAmount(updAds, isEx);
    }

    function shouldTakeFee(address from, address to)
        internal
        view
        returns (bool)
    {
        return 
            (automatedMarketMakerPairs[from] || automatedMarketMakerPairs[to]) &&
            !_isFeeExempt[from] && !_isFeeExempt[to];
    }

    function shouldRebase() internal view returns (bool) {
        return
            _autoRebase &&
            //(_totalSupply < MAX_SUPPLY) &&
            //!automatedMarketMakerPairs[msg.sender]  &&
            //!inSwap &&
            block.timestamp >= (_lastRebasedTime + 2 minutes);
    }

    function shouldAddLiquidity() internal view returns (bool) {
        return
            _autoAddLiquidity && 
            !inSwap && 
            !automatedMarketMakerPairs[msg.sender] &&
            block.timestamp >= (_lastAddLiquidityTime);
    }

    function shouldSwapBack() internal view returns (bool) {
        return 
            swapEnabled &&
            !inSwap &&
            !automatedMarketMakerPairs[msg.sender]  ; 
    }

    function setAutoRebase(bool _flag) external onlyOwner {
        if (_flag) {
            _autoRebase = _flag;
            _lastRebasedTime = block.timestamp;
            _initRebaseStartTime = block.timestamp;
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

    function getCirculatingSupply() public view returns (uint256) {
        return
            (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(
                _gonsPerFragment
            );
    }

    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }

    function manualSync() public {
        for (uint256 i = 0; i < _markerPairs.length; i++) {
            IPancakeRouter02(_markerPairs[i]).sync();
        }
    }

    function setAutomatedMarketMakerPair(address _pair, bool _value) public onlyOwner {
        require(
            automatedMarketMakerPairs[_pair] != _value,
            'Value already set'
        );

        automatedMarketMakerPairs[_pair] = _value;
        excludeFromMaxTransaction(_pair, _value);

        if (_value) {
            _markerPairs.push(_pair);
            _markerPairCount++;
        } else {
            require(_markerPairs.length > 1, 'Required 1 pair');
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

    function setFeeReceivers(
        address _developmentGuardFeeReceiver,
        address _insuranceGuardFeeReceiver,
        address _LCBRFeeReceiver
    ) external onlyOwner {
        developmentGuardReciever = _developmentGuardFeeReceiver;
        insuranceGuardFeeReceiver = _insuranceGuardFeeReceiver;
        LCBRFeeReceiver = _LCBRFeeReceiver;
    }

    function getLiquidityBacking(uint256 accuracy)
        public
        view
        returns (uint256)
    {
        uint256 liquidityBalance = 0;
        for (uint256 i = 0; i < _markerPairs.length; i++) {
            liquidityBalance.add(balanceOf(_markerPairs[i]));
        }

        return accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }

    function setWhitelist(address _addr, bool _flag) external onlyOwner {
        _isFeeExempt[_addr] = _flag;
    }

    function setIsDividendExempt(address holder, bool exempt)
        external
        onlyOwner
    {
        require(holder != address(this) && !automatedMarketMakerPairs[holder]);
        isDividendExempt[holder] = exempt;
        if (exempt) {
            dividendDistributor.setShare(holder, 0);
        } else {
            uint256 _balance = balanceOf(holder).mul(INITIAL_FRAGMENTS_SUPPLY).div(_totalSupply);
            dividendDistributor.setShare(holder, _balance);
        }
    }

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external onlyOwner {
        dividendDistributor.setDistributionCriteria(
            _minPeriod,
            _minDistribution
        );
    }

    function setBotBlacklist(address _botAddress, bool _flag) external onlyOwner {
        require(isContract(_botAddress), "only contract address, not allowed exteranlly owned account");
        blacklist[_botAddress] = _flag;    
    }

    function setSwapEnabled (bool _flag) external onlyOwner {
        swapEnabled = _flag;
    }
    
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
   
    function balanceOf(address who) public view override returns (uint256) {
        return _gonBalances[who].div(_gonsPerFragment);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    // tracker dashboard functions
    function getHolderDetails(address holder)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return dividendDistributor.getHolderDetails(holder);
    }

    function getLastProcessedIndex() public view returns (uint256) {
        return dividendDistributor.getLastProcessedIndex();
    }

    function getNumberOfTokenHolders() public view returns (uint256) {
        return dividendDistributor.getNumberOfTokenHolders();
    }

    function totalDistributedRewards() public view returns (uint256) {
        return dividendDistributor.totalDistributedRewards();
    }

    function setMinAmountForReward (uint256 _minAmountForReward) external onlyOwner {
        minAmountForReward = _minAmountForReward;
    }

    // manual claim for the greedy humans
    function ___claimRewards(bool tryAll) public {
        dividendDistributor.claimDividend();
        if (tryAll) {
            try dividendDistributor.process(distributorGas) {} catch {}
        }
    }

    // manually clear the queue
    function claimProcess() public {
        try dividendDistributor.process(distributorGas) {} catch {}
    }

    function enableTrading() external onlyOwner {
        require (tradingActive== false, "Trading is already enabled");
        _initRebaseStartTime = block.timestamp;
        _lastRebasedTime = block.timestamp;
        _autoRebase = true;
        _autoAddLiquidity = true;
        tradingActive= true;
        swapEnabled= true;
    }

    function setBuyFees (uint256 _liquidityFee, uint256 _developmentGuardFee, 
        uint256 _insuranceGuardFee, uint256 _rewardFee, uint256 _burnFee, uint256 _LCBRFee) external onlyOwner{
        
        require (_liquidityFee.add(_developmentGuardFee).add(_insuranceGuardFee).add(_rewardFee).add(_burnFee) <= 150, "You cannot set high fees");
        
        buyLiquidityFee = _liquidityFee;
        buyDevelopmentGuardFee = _developmentGuardFee;
        buyInsuranceGuardFee = _insuranceGuardFee;
        buyRewardFee = _rewardFee;
        buyBurnFee = _burnFee;
        buyLCBRFee = _LCBRFee;
    }

    function setSellFees (uint256 _liquidityFee, uint256 _developmentGuardFee, 
        uint256 _insuranceGuardFee, uint256 _rewardFee, uint256 _burnFee, uint256 _LCBRFee) external onlyOwner{
        
        require (_liquidityFee.add(_developmentGuardFee).add(_insuranceGuardFee).add(_rewardFee).add(_burnFee) <= 200, "You cannot set high fees");
        
        sellLiquidityFee = _liquidityFee;
        sellDevelopmentGuardFee = _developmentGuardFee;
        sellInsuranceGuardFee = _insuranceGuardFee;
        sellRewardFee = _rewardFee;
        sellBurnFee = _burnFee;
        sellLCBRFee = _LCBRFee;
    }


    function airdropToWallets(address[] memory airdropWallets, uint256[] memory amounts) external onlyOwner returns (bool){
        require(airdropWallets.length == amounts.length, "arrays must be the same length");
        require(airdropWallets.length < 200, "Can only airdrop 200 wallets per txn due to gas limits"); // allows for airdrop + launch at the same exact time, reducing delays and reducing sniper input.
        for(uint256 i = 0; i < airdropWallets.length; i++){
            address wallet = airdropWallets[i];
            uint256 amount = amounts[i];
            _basicTransfer(msg.sender, wallet, amount);
        }
        return true;
    }
     //staking pool functions
    function calculateProfit(uint256 _stakeAmount) public view returns (uint256){    
        return(
            (((_stakeAmount * 100 / totalPoolAmount)) * LCBR_TOKEN_AMOUNT) / 100
        );
    }

    function getCurrentProfit() public view returns (uint256){
        
        return(
            stakes[msg.sender].amountEarned
        );
    }

    function stake(uint256 _amount, uint256 _period) public {
    
    address investor = msg.sender;
    uint256 investingStartingTime = block.timestamp;
    uint256 period = _period * vestingPeriod * 60;
    uint256 investingEndingTime = investingStartingTime.add(period);
    
    require(balanceOf(investor) >= _amount, "insuffient amount to stake!");
    shareProfit();
    if(stakes[investor].lockTime < 1){
    stakes[investor] = Invest(_amount,0,  investingStartingTime, investingEndingTime, false);
    allStakers.push(investor);
    totalStakers++;
    }
    else{
        stakes[investor].amountLock += _amount;
        stakes[investor].unLockTime = period;
    }
    _transferFrom(investor,address(this),_amount);
    totalPoolAmount += _amount;
    emit investmentReport(_amount, investingStartingTime, investingEndingTime, _period, false);
    }

    function unstake() public {
        address investor = msg.sender;
        uint256 ctime = block.timestamp;
        Invest memory invest = stakes[investor];
        uint unlockTime = invest.unLockTime;
        uint amountStaked = invest.amountLock;
        uint256 totalProfit = invest.amountEarned; //calculateProfit(amountStaked).div(10**RATE_DECIMALS);
        bool cstatus = invest.releaseStatus;
        
        require(cstatus==false, "You have already claim your investment.");
        require(ctime >= unlockTime, "You can't claim investment now, until investment period end.");
        
        uint256 totalEarned = amountStaked + totalProfit;
        require(balanceOf(address(this)) >= totalEarned, "insuffient amount to withdraw!");
        
        shareProfit();
        _transferFrom(address(this),investor,totalEarned);
        stakes[investor].amountLock = 0;
        stakes[investor].amountEarned = 0;
        stakes[investor].releaseStatus = true;
        totalStakers--;
        totalPoolAmount -= amountStaked;
        LCBR_TOKEN_AMOUNT -= totalProfit;
        emit investReleased(address(this), investor, totalEarned, ctime);
    }

     function claimReward() public {
        address investor = msg.sender;
        Invest memory invest = stakes[investor];
        uint256 totalProfit = invest.amountEarned; //calculateProfit(amountStaked).div(10**RATE_DECIMALS);
        require(balanceOf(address(this)) >= totalProfit, "insuffient amount to withdraw!");
        
        shareProfit();
        _transferFrom(address(this),investor,totalProfit);
        stakes[investor].amountEarned = 0;
        LCBR_TOKEN_AMOUNT -= totalProfit;
        emit rewardClaimed(address(this), investor, totalProfit, block.timestamp);
    }

    function getInvestmentRecord(address addr) public view returns(uint256, uint256, uint256,uint256, bool){
        return (stakes[addr].amountLock, stakes[addr].amountEarned, stakes[addr].lockTime, stakes[addr].unLockTime, stakes[addr].releaseStatus);
    }

    function getAllInvestmentRecord() public view returns(address[] memory){
        return allStakers;
    }

    function shareProfit() public {
        uint256 numberOfStakers = allStakers.length;
     //   Invest memory invest;
        if(LCBR_TOKEN_AMOUNT > 0 && numberOfStakers > 0){
        //for(uint256 i = numberOfStakers; i > 0; i--){
        for(uint256 i = 0; i < numberOfStakers; i++){
          //  invest = stakes[allStakers[i]];
            uint256 stakerAmount = stakes[allStakers[i]].amountLock;
            if(stakerAmount > 0 ){
               uint reward = calculateProfit(stakerAmount);
               if(LCBR_TOKEN_AMOUNT > reward){
               stakes[allStakers[i]].amountEarned += reward;
               LCBR_TOKEN_AMOUNT -= reward;
               }
               else{
                stakes[allStakers[i]].amountEarned += LCBR_TOKEN_AMOUNT;
                LCBR_TOKEN_AMOUNT -= LCBR_TOKEN_AMOUNT;
                break;
               }
               
            }
        }
        }
    }

    function updateLCBR(uint _amt) public onlyOwner{
        LCBR_TOKEN_AMOUNT = _amt;
    }
    //staking pool functions end here


    //public sales with referer starts here
    uint256 softCap = 50 ether;
    uint256 hardCap = 1000 ether;
    uint256 tokenPricePerBnb = 1000000;
    uint256 minBuy = 0.01 ether;
    uint256 maxBuy = 10 ether;
    uint256 startTime = block.timestamp;
    uint256 endTime = block.timestamp.add(30 days);
    uint256 listingPrice = 1200000;
    bool buyStatus = true;

    function updateToken(uint256 _softCap,uint256 _hardCap, uint256 _tokenPricePerBnb, uint256 _listingPrice, uint256 _minBuy, uint256 _maxBuy, uint256 _startTime, uint256 _endTime) public onlyOwner{
        softCap = _softCap;
        hardCap = _hardCap;
        tokenPricePerBnb = _tokenPricePerBnb;
        minBuy = _minBuy;
        maxBuy = _maxBuy;
        startTime = _startTime;
        endTime = _endTime;
        listingPrice = _listingPrice;
    }

    function getPresaleInfo() public view returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, bool, address){
        return(softCap, hardCap, tokenPricePerBnb, listingPrice, minBuy, maxBuy, startTime, endTime, buyStatus, owner());
    }
    function setBuyStatus(bool _flag) public onlyOwner{
        buyStatus = _flag;
    }
    struct Buy{
    uint256 id;
    address staker;
    uint256 bnbPaid;
    uint256 tokenToCollect;
    address refererAddress;
    bool releaseStatus;
    uint256 date;
    }

    mapping (address=>address) public referer;
    mapping (address=>uint256) public refererBalance;
    mapping (address=>uint256) public buyerBalance;

    Buy[] public allBuys;
    uint256 _buysCount = 0;

    function convertToken(uint256 _tokenPerBNB, uint256 _amountBought) public pure returns (uint256){
        return (_tokenPerBNB * _amountBought) / (1 * 10**18);
    }

    function buyToken(address referBy) public payable{
    require(buyStatus, "You can't buy this token again public sales has ended!");
    require(msg.value >= minBuy && msg.value <= maxBuy, "Pls, buy between minimum and maximum price of the token");
    uint256 totalToCollect = convertToken(tokenPricePerBnb, msg.value);
    uint256 totalRefererShare = 0;

    if(referer[msg.sender] != address(0)){

    }
    else{
        referer[msg.sender] = referBy;
    }
     
    uint refererShare = (msg.value * 5) / 100;
    uint deliverShare =  0; //msg.value - refererShare;
    totalRefererShare = refererShare;
    if(referBy != address(0) && msg.value >= 0.0025 ether){
    
    payable(referBy).transfer(refererShare);
    refererBalance[referBy] += refererShare;
    emit logRefererShares('Level 1 share: 5%', msg.value, referBy, refererShare);
    address secondReferer = referer[referBy];
    if(msg.value >= 0.005 ether && secondReferer != address(0)){
    uint256 sRefererShare = (msg.value * 3) / 100;
    //deliverShare = deliversRefererShare;
    payable(secondReferer).transfer(sRefererShare);
    refererBalance[secondReferer] += sRefererShare;
    totalRefererShare += sRefererShare; 
    emit logRefererShares('Level 2 share: 3%', msg.value, secondReferer, sRefererShare);

    address thirdReferer = referer[secondReferer];
    if(msg.value >= 0.0075 ether && thirdReferer != address(0)){
    uint256 tRefererShare = (msg.value * 2) / 100;
    totalRefererShare += tRefererShare;
    payable(thirdReferer).transfer(tRefererShare);
    refererBalance[thirdReferer] += tRefererShare;
    emit logRefererShares('Level 3 share: 2%', msg.value, thirdReferer, tRefererShare);

    address fourthReferer = referer[thirdReferer];
    if(msg.value >= 0.01 ether && fourthReferer != address(0)){
    uint256 fourthRefererShare = (msg.value * 1) / 100;
    totalRefererShare += fourthRefererShare;
    payable(fourthReferer).transfer(fourthRefererShare);
    refererBalance[fourthReferer] += fourthRefererShare;
    emit logRefererShares('Level 4 share: 1%', msg.value, fourthReferer, fourthRefererShare);

    address fifthReferer = referer[fourthReferer];
    if(msg.value >= 0.0125 ether && fifthReferer != address(0)){
    uint256 fifthRefererShare = (msg.value * 1) / 100;
    totalRefererShare += fifthRefererShare;
    payable(fifthReferer).transfer(fifthRefererShare);
    refererBalance[fifthReferer] += fifthRefererShare;
    emit logRefererShares('Level 5 share: 1%', msg.value, fifthReferer, fifthRefererShare);

    }

    }

    }

    }
    deliverShare = msg.value - totalRefererShare;
    payable(owner()).transfer(deliverShare);
    }
    else{
    payable(owner()).transfer(msg.value);
    }
    totalToCollect = totalToCollect * 10 ** DECIMALS;
    _transferFrom(address(this),msg.sender, (totalToCollect));
    allBuys.push(Buy(_buysCount, msg.sender, msg.value, totalToCollect, referBy, true, block.timestamp ));
    buyerBalance[msg.sender] += totalToCollect;
    _buysCount++;
    emit buysReport(msg.sender, msg.value, totalToCollect, referBy, block.timestamp);
    
    }

    function getStakerInfo(uint _id)public view returns(uint, address,uint,bool) {
        Buy storage stakerbuys = allBuys[_id];
        require(stakerbuys.staker==msg.sender || stakerbuys.staker==owner(),"You are not permitted to get the staker info");
        return(stakerbuys.id,stakerbuys.staker,stakerbuys.bnbPaid,stakerbuys.releaseStatus);

    }

    function getRefererBalance(address addr) public view returns(uint256){
        return refererBalance[addr];
    }

    function getMyReferral(address addr) public view returns(address){
        return referer[addr];
    }
    
    function getAllNumberStake() public view returns(uint256){
        return _buysCount;
    }
    //public sale with refer ends here

    receive() external payable {}
    event investmentReport(uint256 amount, uint256 lockTime, uint256 unlockTime, uint256 period, bool status);
    event investReleased(address from, address to, uint256 totalEarned, uint256 ctime); 
    event rewardClaimed(address from, address to, uint256 totalEarned, uint256 ctime); 
    event buysReport(address buyer, uint256 bnbSent, uint256 totalTokenRecieved, address referer, uint256 ctime); 
    event logRefererShares(string level, uint256 amountBought, address shareReciever, uint256 amountRecieved);

}