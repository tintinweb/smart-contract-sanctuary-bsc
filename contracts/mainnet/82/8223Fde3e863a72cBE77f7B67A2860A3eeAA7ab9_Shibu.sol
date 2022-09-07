/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

/**

/**
/** gitbook: https://shibu-community.gitbook.io/shibu/
/** tg: https://t.me/shibubsc
/** website: https://shibu.community/
/** twitter: https://mobile.twitter.com/shibucommunity/we
/** Staking platform: https://shibunator.app/
*/ 

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
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

interface IPinkAntiBot {
  function setTokenOwner(address owner) external;

  function onPreTransferCheck(
    address from,
    address to,
    uint256 amount
  ) external;
}

interface IDividendDistributor {
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external;

    function setShare(address shareholder, uint256 amount) external;

    function deposit(uint256 amount) external;

    function process(uint256 gas) external;

    function purge(address receiver) external;
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address public _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IERC20 public REWARD;
    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

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
    uint256 public minDistribution = 1 * (10**9);

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

    constructor(address rewardToken) {
        _token = msg.sender;
        REWARD = IERC20(rewardToken);
    }

    receive() external payable {}

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function purge(address receiver) external override onlyToken {
        uint256 balance = REWARD.balanceOf(address(this));
        REWARD.transfer(receiver, balance);
    }

    function setShare(address shareholder, uint256 amount)
        external
        override
        onlyToken
    {
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

    function deposit(uint256 amount) external override onlyToken {
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(
            dividendsPerShareAccuracyFactor.mul(amount).div(totalShares)
        );
    }

    function process(uint256 gas) external override onlyToken {
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
            REWARD.transfer(shareholder, amount);
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

contract Shibu is IERC20, Ownable {
    using SafeMath for uint256;

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    // swap and send fees ( initially bnb can change later)
    address public SWAPTOKEN = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public REWARD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    IPinkAntiBot public pinkAntiBot;
    bool public antibotEnabled = false;

    string constant _name = "Shibu";
    string constant _symbol = "SHIBU";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 1000000000 * (10**_decimals);

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isDividendExempt;

    // buy fees
    uint256 public buyDividendRewardsFee = 0;
    uint256 public buyMarketingFee = 4;
    uint256 public buyDevFee = 4;
    uint256 public buyBurnFee = 0;
    uint256 public buyTotalFees = 8;
    // sell fees
    uint256 public sellDividendRewardsFee = 0;
    uint256 public sellMarketingFee = 10;
    uint256 public sellDevFee = 10;
    uint256 public sellBurnFee = 0;
    uint256 public sellTotalFees = 20;

    uint256 public transferFee = 10;

    address public marketingFeeReceiver = 0x5754BF0D7bbc2d8Be3744f758765B2EaA88F4Bbb;
    address public devFeeReceiver = 0xd857e02a0164Ee03148DfA455FF7C6E275663482;

    IUniswapV2Router02 public router;
    address public pair;

    DividendDistributor public dividendDistributor;
    uint256 distributorGas = 700000;

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event SendFeesInToken(address wallet, uint256 amount);
    event ChangeRewardTracker(address token);
    event IncludeInReward(address holder);

    bool public swapEnabled = true;
    uint256 public swapThreshold = (_totalSupply * 25) / 100000;//0.01%
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(address _antibot) {
        pinkAntiBot = IPinkAntiBot(_antibot) ;
        router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IUniswapV2Factory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
        dividendDistributor = new DividendDistributor(REWARD);
        isFeeExempt[msg.sender] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    // tracker dashboard functions
    function getHolderDetails(address holder) external view returns (uint256,uint256,uint256,uint256){
        return dividendDistributor.getHolderDetails(holder);
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return dividendDistributor.getLastProcessedIndex();
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return dividendDistributor.getNumberOfTokenHolders();
    }

    function totalDistributedRewards() external view returns (uint256) {
        return dividendDistributor.totalDistributedRewards();
    }

    function allowance(address holder, address spender) external view override returns (uint256){
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool){
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool){
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
                .sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(antibotEnabled){
            pinkAntiBot.onPreTransferCheck(sender, recipient, amount);
        }
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }
        if (shouldSwapBack()) {
            if (SWAPTOKEN == WBNB) {
                swapBackInBnb();
            } else {
                swapBackInTokens();
            }
        }
        //Exchange tokens
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );

        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, amount, recipient) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        // Dividend tracker
        if (!isDividendExempt[sender]) {
            dividendDistributor.setShare(sender, _balances[sender]);
        }
        if (!isDividendExempt[recipient]) {
            dividendDistributor.setShare(recipient, _balances[recipient]);
        }
        try dividendDistributor.process(distributorGas) {} catch {}
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return !isFeeExempt[sender] && !isFeeExempt[recipient];
    }

    function takeFee(address sender, uint256 amount, address to) internal returns (uint256) {
        uint256 feeAmount = 0;
        uint256 burnFee = 0;
        if (to == pair) {
            feeAmount = amount.mul(sellTotalFees).div(100);
            if (sellBurnFee > 0) {
                burnFee = feeAmount.mul(sellBurnFee).div(sellTotalFees);
                _balances[DEAD] = _balances[DEAD].add(burnFee);
                emit Transfer(sender, DEAD, burnFee);
            }
        } else if(sender == pair){
            feeAmount = amount.mul(buyTotalFees).div(100);
            if (buyBurnFee > 0) {
                burnFee = feeAmount.mul(buyBurnFee).div(buyTotalFees);
                _balances[DEAD] = _balances[DEAD].add(burnFee);
                emit Transfer(sender, DEAD, burnFee);
            }
        } else {
            feeAmount = amount.mul(transferFee).div(100);
        }
        if(feeAmount > 0) {
            uint256 feesToContract = feeAmount.sub(burnFee);
            _balances[address(this)] = _balances[address(this)].add(feesToContract);
            emit Transfer(sender, address(this), feesToContract);
        }
        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            msg.sender != pair &&
            !inSwap &&
            swapEnabled &&
            _balances[address(this)] >= swapThreshold;
    }

    event ClearStuckBalance(uint256 amountPercentage);
    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer((amountBNB * amountPercentage) / 100);
        emit ClearStuckBalance(amountPercentage);
    }

    event UpdateSwapToken(address indexed token);
    function changeSwapToken(address token) external onlyOwner {
        SWAPTOKEN = token;
        emit UpdateSwapToken(token);
    }

    event UpdateBuyFees(uint256 reward, uint256 marketing, uint256 dev, uint256 burn);
    function updateBuyFees(uint256 reward, uint256 marketing, uint256 dev, uint256 burn) external onlyOwner {
        buyDividendRewardsFee = reward;
        buyMarketingFee = marketing;
        buyDevFee = dev;
        buyBurnFee = burn;
        buyTotalFees = reward.add(marketing).add(dev).add(burn);
        require(buyTotalFees <= 20, "Total Fee must be less than 25%");
        emit UpdateBuyFees(reward, marketing, dev, dev);
    }

    event UpdateSellFees(uint256 reward, uint256 marketing, uint256 dev, uint256 burn);
    function updateSellFees(uint256 reward, uint256 marketing, uint256 dev, uint256 burn) external onlyOwner {
        sellDividendRewardsFee = reward;
        sellMarketingFee = marketing;
        sellDevFee = dev;
        sellBurnFee = burn;
        sellTotalFees = reward.add(marketing).add(dev).add(burn);
        require(sellTotalFees <= 20, "Total Fee must be less than 25%");
        emit UpdateSellFees(reward, marketing, dev, burn);
    }

    // new dividend tracker, clear balance
    function purgeBeforeSwitch() external onlyOwner {
        dividendDistributor.purge(msg.sender);
    }

    function includeMeinRewards() external {
        require(
            !isDividendExempt[msg.sender],
            "You are not allowed to get rewards"
        );
        try
            dividendDistributor.setShare(msg.sender, _balances[msg.sender])
        {} catch {}
        emit IncludeInReward(msg.sender);
    }

    function switchToken(address rewardToken, bool isIncludeHolders) external onlyOwner{
        require(rewardToken != WBNB, "Can not reward BNB in this tracker");
        require(rewardToken != address(0), "supplied address is zero address");
        REWARD = rewardToken;
        // get current shareholders list
        address[] memory currentHolders = dividendDistributor
            .getShareHoldersList();
        dividendDistributor = new DividendDistributor(rewardToken);
        if (isIncludeHolders) {
            // add old share holders to new tracker
            for (uint256 i = 0; i < currentHolders.length; i++) {
                try
                    dividendDistributor.setShare(
                        currentHolders[i],
                        _balances[currentHolders[i]]
                    )
                {} catch {}
            }
        }
        emit ChangeRewardTracker(rewardToken);
    }

    // manual claim for the greedy humans
    event UpdateRewardClaimed(address indexed account);
    function claimRewards(bool tryAll) external {
        dividendDistributor.claimDividend();
        if (tryAll) {
            try dividendDistributor.process(distributorGas) {} catch {}
        }

        emit UpdateRewardClaimed(msg.sender);
    }

    // manually clear the queue
    event UpdateClaimProcessed(address indexed by);
    function claimProcess() external {
        try dividendDistributor.process(distributorGas) {} catch {}
        emit UpdateClaimProcessed(msg.sender);
    }

    function swapBackInBnb() internal swapping {
        uint256 contractTokenBalance = _balances[address(this)];
        uint256 tokensToReward = contractTokenBalance.mul(sellDividendRewardsFee).div(sellTotalFees);
        // calculate tokens amount to swap
        uint256 tokensToSwap = contractTokenBalance.sub(tokensToReward);
        // swap the tokens
        if(tokensToSwap > 0) {
            swapTokensForEth(tokensToSwap);
        }
        // get swapped bnb amount
        uint256 swappedBnbAmount = address(this).balance;
        uint256 totalSwapFee = sellMarketingFee.add(sellDevFee);
        uint256 marketingFeeBnb = swappedBnbAmount.mul(sellMarketingFee).div(totalSwapFee);
        uint256 devFeeBnb = swappedBnbAmount.sub(marketingFeeBnb);
        // calculate reward bnb amount
        if (tokensToReward > 0) {
            swapTokensForTokens(tokensToReward, REWARD);
            uint256 swappedTokensAmount = IERC20(REWARD).balanceOf(address(this));
            // send bnb to reward
            IERC20(REWARD).transfer(address(dividendDistributor),swappedTokensAmount);
            dividendDistributor.deposit(swappedTokensAmount);
        }
        if (marketingFeeBnb > 0) {
            (bool marketingSuccess, ) = payable(marketingFeeReceiver).call{
                value: marketingFeeBnb,
                gas: 30000
            }("");
            marketingSuccess = false;
        }
        if (devFeeBnb > 0) {
            (bool devSuccess, ) = payable(devFeeReceiver).call{
                value: devFeeBnb,
                gas: 30000
            }("");
            // only to supress warning msg
            devSuccess = false;
        }
    }

    function swapBackInTokens() internal swapping {
        uint256 contractTokenBalance = _balances[address(this)];
        uint256 rewardTokens = contractTokenBalance.mul(sellDividendRewardsFee).div(buyTotalFees);
        uint256 tokensForFee = contractTokenBalance.sub(rewardTokens);
        if (rewardTokens > 0) {
            swapTokensForTokens(rewardTokens, REWARD);
            uint256 swappedTokensAmount = IERC20(REWARD).balanceOf(address(this));
            // send bnb to reward
            IERC20(REWARD).transfer(address(dividendDistributor),swappedTokensAmount);
            dividendDistributor.deposit(swappedTokensAmount);
        }
        if (tokensForFee > 0) {
            swapAndSendFees(tokensForFee);
        }
    }

    function swapAndSendFees(uint256 tokensForFee) private {
        uint256 totalSwapFee = buyMarketingFee.add(buyDevFee);
        // // swap tokens
        swapTokensForTokens(tokensForFee, SWAPTOKEN);
        uint256 currentTokenBalance = IERC20(SWAPTOKEN).balanceOf(address(this));
        uint256 marketingToken = currentTokenBalance.mul(buyMarketingFee).div(totalSwapFee);
        uint256 devToken = currentTokenBalance.sub(marketingToken);
        //send tokens to wallets
        if (marketingToken > 0) {
            IERC20(SWAPTOKEN).transfer(marketingFeeReceiver, marketingToken);
            emit SendFeesInToken(marketingFeeReceiver, marketingToken);
        }
        if (devToken > 0) {
            IERC20(SWAPTOKEN).transfer(devFeeReceiver, devToken);
            emit SendFeesInToken(devFeeReceiver, devToken);
        }
    }


    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForTokens(uint256 tokenAmount, address tokenToSwap) private{
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = router.WETH();
        path[2] = tokenToSwap;
        _approve(address(this), address(router), tokenAmount);
        // make the swap
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of tokens
            path,
            address(this),
            block.timestamp
        );
    }

    event SetDividendExempt(address indexed holder, bool exempt);
    function setIsDividendExempt(address holder, bool exempt) external onlyOwner{
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if (exempt) {
            dividendDistributor.setShare(holder, 0);
        } else {
            dividendDistributor.setShare(holder, _balances[holder]);
        }

        emit SetDividendExempt(holder, exempt);
    }

    event SetFeeExempt(address indexed holder, bool exempt);
    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
        emit SetFeeExempt(holder, exempt);
    }

    event UpdateFeeReceivers(address _marketingFeeReceiver, address _devFeeReceiver);
    function setFeeReceivers(address _marketingFeeReceiver, address _devFeeReceiver) external onlyOwner {
        marketingFeeReceiver = _marketingFeeReceiver;
        devFeeReceiver = _devFeeReceiver;
        emit UpdateFeeReceivers(_marketingFeeReceiver, _devFeeReceiver);
    }

    event UpdateSwapBackSettings(bool _enable, uint256 _amount);
    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner{
        swapEnabled = _enabled;
        swapThreshold = _amount;
        emit UpdateSwapBackSettings(_enabled, _amount);
    }

    event UpdateDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution);
    function setDistributionCriteria(uint256 _minPeriod,uint256 _minDistribution) external onlyOwner {
        dividendDistributor.setDistributionCriteria(_minPeriod, _minDistribution);
        emit UpdateDistributionCriteria(_minPeriod, _minDistribution);
    }

    event UpdateDistributorSettings(uint256 gas);
    function setDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 3000000);
        distributorGas = gas;
        emit UpdateDistributorSettings(gas);
    }

    event EnabledAntibot(bool enable_);
    function enableAntibot(bool enable_) external onlyOwner {
        antibotEnabled = enable_;
        emit EnabledAntibot(enable_);
    }

    event UpdatePinkbot(address indexed _antibot);
    function updatePinkbot(address _antibot) external onlyOwner {
        pinkAntiBot = IPinkAntiBot(_antibot);
        emit UpdatePinkbot(_antibot);
    }

    event UpdateTransferFee(uint256 _transferfee);
    function updateTransferFee(uint256 _transferfee) external onlyOwner {
        transferFee = _transferfee;
        require(_transferfee <= 20, "transfer fee limit");
        emit UpdateTransferFee(_transferfee);
    }
}