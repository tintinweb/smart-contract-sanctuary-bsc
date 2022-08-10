/**
 *Submitted for verification at BscScan.com on 2022-08-09
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^ 0.8.7;

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
    //address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;// WBNB Mainnet
    address public WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;// WBNB Testnet
    //address public WBNB = 0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F;// WBNB PinkSale Testnet
    IUniswapV2Router02 public router;

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

    constructor(address _router, address rewardToken) {
        router = _router != address(0)
            ? IUniswapV2Router02(_router)
            //: IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); // PancakeSwap Mainnet Router
            : IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); // PancakeSwap Testnet Router
            //: IUniswapV2Router02(0xBBe737384C2A26B15E23a181BDfBd9Ec49E00248); // PinkSwap Testnet Router
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
			shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder]
                .totalRealised
                .add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(
                shares[shareholder].amount
            );
            REWARD.transfer(shareholder, amount);
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

contract TESTTOKEN is IERC20, Ownable {
    using SafeMath for uint256;

    //address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // WBNB Mainnet
    address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // WBNB Testnet
    //address WBNB = 0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F; // WBNB PinkSale Testnet

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
	
    // Swap and send fees ( Reward can change later)
    /* MainNet */
    //address public SWAPTOKEN = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // WBNB Mainnet
    //address public REWARD = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d; // USDC Mainnet
	
    /* TestNet */
    address public SWAPTOKEN = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // WBNB Testnet
    //address public SWAPTOKEN = 0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F; // WBNB PinkSale Testnet
    address public REWARD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; // BUSD Testnet

    IPinkAntiBot public pinkAntiBot;
    bool public antibotEnabled = true;
    bool public feeOnTransfer = true;

    bool _pinkAntiBotInstantiated = false;

    string constant _name = "TESTTOKEN";
    string constant _symbol = "TEST";
    uint8 constant _decimals = 18;

    uint8 constant _divisor = 1; // Divisor Mainnet
    //uint16 constant _divisor = 1000; // Divisor TestNet

    uint256 _totalSupply = (100000000000 / _divisor) * (10**_decimals);

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isDividendExempt;
    mapping(address => bool) public isMaxTxExempt;
    mapping(address => bool) public isMaxWalletExempt;
    //mapping(address => bool) isAuthorized;

    // Buy Fee
    uint256 public buyDividendRewardsFee = 5;
    uint256 public buyMarketingFee = 3;
    uint256 public buyLiquidityFee = 1;
    uint256 public buyDevFee = 1;
    uint256 public buyBurnFee = 0;
    uint256 public buyTotalFees = 10;
    // Sell Fee
    uint256 public sellDividendRewardsFee = 5;
    uint256 public sellMarketingFee = 3;
    uint256 public sellLiquidityFee = 1;
    uint256 public sellDevFee = 1;
    uint256 public sellBurnFee = 0;
    uint256 public sellTotalFees = 10;

    address public marketingFeeReceiver = 0x0000000000000000000000000000000000000000; //Marketing Wallet
    address public devFeeReceiver = 0x0000000000000000000000000000000000000000; //Dev Wallet
	
    address public STAKING = 0x0000000000000000000000000000000000000000; //Staking Contract

    address public TREASURY = 0x0000000000000000000000000000000000000000; //Treasury

    address public NFTMINT = 0x0000000000000000000000000000000000000000; //NFTMint Contract
    address public NFTSTAKING = 0x0000000000000000000000000000000000000000; //NFTStaking Contract

    address public PRIVATESALE = 0x0000000000000000000000000000000000000000; //PrivateSale Contract

    IUniswapV2Router02 public router;
    address public pair;
	
    //bool public tradingOpen = false;

    DividendDistributor public dividendDistributor;
    uint256 distributorGas = 500000;

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event SendFeesInToken(address wallet, uint256 amount);
    event ChangeRewardTracker(address token);
    event IncludeInReward(address holder);

    bool public swapEnabled = true;
    uint256 public swapThreshold = (_totalSupply * 10) / 10000; // 0.1% of supply
    uint256 public maxWalletTokens = (_totalSupply * 500) / 10000; // 5% of supply
    uint256 public maxTxAmount = (_totalSupply * 100) / 10000; // 1% of supply	
	
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        //router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); // PancakeSwap Mainnet Router
        router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); // PancakeSwap Testnet Router
        //router = IUniswapV2Router02(0xBBe737384C2A26B15E23a181BDfBd9Ec49E00248); // PinkSwap Testnet Router

        pair = IUniswapV2Factory(router.factory()).createPair(
            WBNB,
            address(this)
        );

        //address pinkAntiBotAddress = 0x8EFDb3b642eb2a20607ffe0A56CFefF6a95Df002; // PinkAntiBot Mainnet
        address pinkAntiBotAddress = 0xbb06F5C7689eA93d9DeACCf4aF8546C4Fe0Bf1E5; // PinkAntiBot Testnet
		
        pinkAntiBot = IPinkAntiBot(pinkAntiBotAddress);
        pinkAntiBot.setTokenOwner(_msgSender());
        _pinkAntiBotInstantiated = true;

        _allowances[address(this)][address(router)] = type(uint256).max;

        dividendDistributor = new DividendDistributor(address(router), REWARD);

        // isFeeExempt Preset
        isFeeExempt[msg.sender] = true;
        isFeeExempt[owner()] = true;
        isFeeExempt[STAKING] = true;
        isFeeExempt[NFTMINT] = true;
        isFeeExempt[NFTSTAKING] = true;
        isFeeExempt[PRIVATESALE] = true;
        isFeeExempt[TREASURY] = true;

        // isDividendExempt Preset
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[owner()] = true;
        isDividendExempt[STAKING] = false; //the Staking cannot be excluded from dividends because it has to distribute the dividends to the stakers
        isDividendExempt[NFTMINT] = true;
        isDividendExempt[NFTSTAKING] = true;
        isDividendExempt[PRIVATESALE] = true;
        isDividendExempt[TREASURY] = true;
		
        // isMaxTxExempt Preset
        isMaxTxExempt[pair] = true;
        isMaxTxExempt[address(this)] = true;
        isMaxTxExempt[DEAD] = true;
        isMaxTxExempt[owner()] = true;
        isMaxTxExempt[STAKING] = true;
        isMaxTxExempt[NFTMINT] = true;
        isMaxTxExempt[NFTSTAKING] = true;
        isMaxTxExempt[PRIVATESALE] = true;
        isMaxTxExempt[TREASURY] = true;

        // isMaxWalletExempt Preset
        isMaxWalletExempt[pair] = true;
        isMaxWalletExempt[address(this)] = true;
        isMaxWalletExempt[DEAD] = true;
        isMaxWalletExempt[owner()] = true;
        isMaxWalletExempt[STAKING] = true;
        isMaxWalletExempt[NFTMINT] = true;
        isMaxWalletExempt[NFTSTAKING] = true;
        isMaxWalletExempt[PRIVATESALE] = true;
        isMaxWalletExempt[TREASURY] = true;
		
        // isAuthorized Preset
        //isAuthorized[owner()] = true;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
	
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
	
    function getWBNBLPbalance() public view returns (uint256) {
        return IERC20(WBNB).balanceOf(address(pair));
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    // Tracker dashboard functions
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

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        /*_allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);*/
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
                .sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {

        if(antibotEnabled){
            pinkAntiBot.onPreTransferCheck(sender, recipient, amount);
        }
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }
        /*if (!isAuthorized[sender]) {
            require(tradingOpen, "Trading not open yet");
        }*/
        if (!isMaxTxExempt[sender]) {
            require(amount <= maxTxAmount, "Max Transaction Amount exceed");
        }
        if (!isMaxWalletExempt[recipient]) {
            uint256 balanceAfterTransfer = amount.add(_balances[recipient]);
            require(
                balanceAfterTransfer <= maxWalletTokens,
                "Max Wallet Amount exceed"
            );
        }

        if (shouldSwapBack()) {
            if (SWAPTOKEN == WBNB) {
                swapBackInBnb();
            } else {
                swapBackInTokens();
            }
        }

        // Exchange tokens
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );

        uint256 amountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, amount, recipient)
            : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        // Dividend tracker
        if (!isDividendExempt[sender]) {
            try
                dividendDistributor.setShare(sender, _balances[sender])
            {} catch {}
        }

        if (!isDividendExempt[recipient]) {
            try
                dividendDistributor.setShare(recipient, _balances[recipient])
            {} catch {}
        }

        try dividendDistributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        if (sender == STAKING || recipient == STAKING) { // No fees for STAKING transfers
            return false;
        }
        if (sender == NFTMINT || recipient == NFTMINT) { // No fees for NFTMINT transfers
            return false;
        }
        if (sender == NFTSTAKING || recipient == NFTSTAKING) { // No fees for NFTSTAKING transfers
            return false;
        }
        if (sender == PRIVATESALE || recipient == PRIVATESALE) { // No fees for PRIVATESALE transfers
            return false;
        }
        if (sender == TREASURY || recipient == TREASURY) { // No fees for TREASURY transfers
            return false;
        }

        if (sender == pair) { // Purchase from router, check if recipient should be taxed
            return !isFeeExempt[recipient];
        } else if (recipient == pair) { // Sell to router, check if sender should be taxed
            return !isFeeExempt[sender];
        } else if (!feeOnTransfer) { // Transfer between address: fee on transfer enabled?
            return false;
        }

        // Any other case, tax the sender
        return !isFeeExempt[sender];
    }

    function takeFee(
        address sender,
        uint256 amount,
        address to
    ) internal returns (uint256) {
        uint256 feeAmount = 0;
        uint256 burnFee = 0;
        if (to == pair) {
            feeAmount = amount.mul(sellTotalFees).div(100);

            if (sellBurnFee > 0) {
                burnFee = feeAmount.mul(sellBurnFee).div(sellTotalFees);
                _balances[DEAD] = _balances[DEAD].add(burnFee);
                emit Transfer(sender, DEAD, burnFee);
            }
        } else {
            feeAmount = amount.mul(buyTotalFees).div(100);

            if (buyBurnFee > 0) {
                burnFee = feeAmount.mul(buyBurnFee).div(buyTotalFees);
                _balances[DEAD] = _balances[DEAD].add(burnFee);
                emit Transfer(sender, DEAD, burnFee);
            }
        }
		
		// Fix for Gas Optimization
		if(feeAmount > 0){
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
			//tradingOpen &&
            _balances[address(this)] >= swapThreshold;
    }

    // Allows the owner to withdraw the bnb sent to the contract by mistake
    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer((amountBNB * amountPercentage) / 100);
    }

    function changeSwapToken(address token) external onlyOwner {
		require(token != address(this), "SwapToken can not be TESTTOKEN");
		require(token != address(0), "SwapToken can not be zero address");
        SWAPTOKEN = token;
    }

    function updateBuyFees(
        uint256 reward,
        uint256 marketing,
        uint256 liquidity,
        uint256 dev,
        uint256 burn
    ) public onlyOwner {
        buyDividendRewardsFee = reward;
        buyMarketingFee = marketing;
        buyLiquidityFee = liquidity;
        buyDevFee = dev;
        buyBurnFee = burn;
        buyTotalFees = reward.add(marketing).add(liquidity).add(dev).add(burn);
        require(buyTotalFees <= 25, "Total Fee must be less than 25%");
    }

    function updateSellFees(
        uint256 reward,
        uint256 marketing,
        uint256 liquidity,
        uint256 dev,
        uint256 burn
    ) public onlyOwner {
        sellDividendRewardsFee = reward;
        sellMarketingFee = marketing;
        sellLiquidityFee = liquidity;
        sellDevFee = dev;
        sellBurnFee = burn;
        sellTotalFees = reward.add(marketing).add(liquidity).add(dev).add(burn);
        require(sellTotalFees <= 25, "Total Fee must be less than 25%");
    }

    // Switch Trading Status
    /*function tradingStatus(bool _status) public onlyOwner {
        tradingOpen = _status;
    }*/

    function whitelistPresale(address _presale) public onlyOwner {
        isFeeExempt[_presale] = true;
        isDividendExempt[_presale] = true;
		//isAuthorized[_presale] = true;
        isMaxTxExempt[_presale] = true;
        isMaxWalletExempt[_presale] = true;
    }

    // New dividend tracker, clear balance
    function purgeBeforeSwitch() public onlyOwner {
        dividendDistributor.purge(msg.sender);
    }

    function includeMainRewards() public {
        require(
            !isDividendExempt[msg.sender],
            "You are not allowed to get rewards"
        );
        try
            dividendDistributor.setShare(msg.sender, _balances[msg.sender])
        {} catch {}

        emit IncludeInReward(msg.sender);
    }

    // New dividend tracker
    function switchToken(address rewardToken, bool isIncludeHolders)
        public
        onlyOwner
    {
        require(rewardToken != WBNB, "Can not reward BNB in this tracker");
        require(rewardToken != address(this), "Can not reward TESTTOKEN in this tracker");
        require(rewardToken != address(0), "rewardToken can not be zero address");
        REWARD = rewardToken;
		
        // Get current shareholders list
        address[] memory currentHolders = dividendDistributor
            .getShareHoldersList();
        dividendDistributor = new DividendDistributor(
            address(router),
            rewardToken
        );
        if (isIncludeHolders) {
            // Add old share holders to new tracker
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

    // Manual claim
    function ___claimRewards(bool tryAll) public {
        dividendDistributor.claimDividend();
        if (tryAll) {
            try dividendDistributor.process(distributorGas) {} catch {}
        }
    }

    // Manually clear the queue
    function claimProcess() public {
        try dividendDistributor.process(distributorGas) {} catch {}
    }

    function swapBackInBnb() internal swapping {
        uint256 contractTokenBalance = _balances[address(this)];
        uint256 buyTotalFeesMinusBuyBurnFee = buyTotalFees.sub(buyBurnFee);

        if (buyTotalFeesMinusBuyBurnFee <= 0) {
            // No swap back if no buy fees or only buy burn fee
            return;
        }

        uint256 tokensToLiquidity = contractTokenBalance
            .mul(buyLiquidityFee)
            .div(buyTotalFeesMinusBuyBurnFee);

        uint256 tokensToReward = contractTokenBalance
            .mul(buyDividendRewardsFee)
            .div(buyTotalFeesMinusBuyBurnFee);

        // Calculate tokens amount to swap
        uint256 tokensToSwap = contractTokenBalance
            .sub(tokensToLiquidity)
            .sub(tokensToReward);

        // Swap the tokens
        swapTokensForEth(tokensToSwap);

        // Get swapped bnb amount
        uint256 swappedBnbAmount = address(this).balance;

        uint256 totalSwapFee = buyMarketingFee.add(buyDevFee);
        uint256 marketingFeeBnb = swappedBnbAmount
            .mul(buyMarketingFee)
            .div(totalSwapFee);

        uint256 devFeeBnb = swappedBnbAmount.sub(marketingFeeBnb);
        // Calculate reward bnb amount
        if (tokensToReward > 0) {
            swapTokensForTokens(tokensToReward, REWARD);

            uint256 swappedTokensAmount = IERC20(REWARD).balanceOf(
                address(this)
            );
            // Send bnb to reward
            IERC20(REWARD).transfer(
                address(dividendDistributor),
                swappedTokensAmount
            );
            try dividendDistributor.deposit(swappedTokensAmount) {} catch {}
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

        if (tokensToLiquidity > 0) {
            // add liquidity
            swapAndLiquify(tokensToLiquidity);
        }
    }

    function swapBackInTokens() internal swapping {
        uint256 contractTokenBalance = _balances[address(this)];
        uint256 buyTotalFeesMinusBuyBurnFee = buyTotalFees.sub(buyBurnFee);

        if (buyTotalFeesMinusBuyBurnFee <= 0) {
            // No swap back if no buy fees or only buy burn fee
            return;
        }

        uint256 rewardTokens = contractTokenBalance
            .mul(buyDividendRewardsFee)
            .div(buyTotalFeesMinusBuyBurnFee);

        uint256 liquidityTokens = contractTokenBalance
            .mul(buyLiquidityFee)
            .div(buyTotalFeesMinusBuyBurnFee);

        uint256 tokensForFee = contractTokenBalance
            .sub(rewardTokens)
            .sub(liquidityTokens);

        if (rewardTokens > 0) {
            swapTokensForTokens(rewardTokens, REWARD);

            uint256 swappedTokensAmount = IERC20(REWARD).balanceOf(address(this));

            // Send bnb to reward
            IERC20(REWARD).transfer(
                address(dividendDistributor),
                swappedTokensAmount
            );
            try dividendDistributor.deposit(swappedTokensAmount) {} catch {}
        }
        if (liquidityTokens > 0) {
            swapAndLiquify(liquidityTokens);
        }
        if (tokensForFee > 0) {
            swapAndSendFees(tokensForFee);
        }
    }

    function swapAndSendFees(uint256 tokensForFee) private {
        uint256 totalSwapFee = buyMarketingFee.add(buyDevFee);
        // Swap tokens
        swapTokensForTokens(tokensForFee, SWAPTOKEN);

        uint256 currentTokenBalance = IERC20(SWAPTOKEN).balanceOf(
            address(this)
        );
        uint256 marketingToken = currentTokenBalance.mul(buyMarketingFee).div(
            totalSwapFee
        );
        uint256 devToken = currentTokenBalance.sub(marketingToken);

        // Send tokens to wallets
        if (marketingToken > 0) {
            //_approve(address(this), marketingFeeReceiver, marketingToken); // Useless Approval
            IERC20(SWAPTOKEN).transfer(marketingFeeReceiver, marketingToken);
            emit SendFeesInToken(marketingFeeReceiver, marketingToken);
        }
        if (devToken > 0) {
            //_approve(address(this), devFeeReceiver, devToken); // Useless Approval
            IERC20(SWAPTOKEN).transfer(devFeeReceiver, devToken);
            emit SendFeesInToken(devFeeReceiver, devToken);
        }
    }

    function swapAndLiquify(uint256 tokens) private {
        // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // Swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when Swap+Liquify is triggered

        // How much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // Add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit AutoLiquify(newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // Generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        // Make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForTokens(uint256 tokenAmount, address tokenToSwap)
        private
    {
        // Generate the uniswap pair path of token -> weth
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = router.WETH();
        path[2] = tokenToSwap;
        _approve(address(this), address(router), tokenAmount);
        // Make the swap
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of tokens
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        _approve(address(this), address(router), tokenAmount);

        // Add the liquidity
        router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    function setIsDividendExempt(address holder, bool exempt)
        external
        onlyOwner
    {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if (exempt) {
            dividendDistributor.setShare(holder, 0);
        } else {
            dividendDistributor.setShare(holder, _balances[holder]);
        }
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }
	
    function setIsMaxTxExempt(address holder, bool exempt) external onlyOwner {
        isMaxTxExempt[holder] = exempt;
    }
	
    function setIsMaxWalletExempt(address holder, bool exempt)
        external
        onlyOwner {
        isMaxWalletExempt[holder] = exempt;
    }

    function setFeeReceivers(address _marketingFeeReceiver, address _devFeeReceiver) external onlyOwner {
		require(_marketingFeeReceiver != address(0), "marketingFeeReceiver can not be zero address");
		require(_devFeeReceiver != address(0), "devFeeReceiver can not be zero address");
        marketingFeeReceiver = _marketingFeeReceiver;
        devFeeReceiver = _devFeeReceiver;
    }
	
    function setStakingContract(address _staking) external onlyOwner {
		require(_staking != address(this), "STAKING Contract can not be TESTTOKEN");
		require(_staking != address(0), "STAKING Contract can not be zero address");
        STAKING = _staking;
        isFeeExempt[STAKING] = true;
        isDividendExempt[STAKING] = false;
        isMaxTxExempt[STAKING] = true;
        isMaxWalletExempt[STAKING] = true;
	}
	
    function setNFTMintContract(address _nftmint) external onlyOwner {
		require(_nftmint != address(this), "NFTMINT Contract can not be TESTTOKEN");
		require(_nftmint != address(0), "NFTMINT Contract can not be zero address");
        NFTMINT = _nftmint;
        isFeeExempt[NFTMINT] = true;
        isDividendExempt[NFTMINT] = true;
        isMaxTxExempt[NFTMINT] = true;
        isMaxWalletExempt[NFTMINT] = true;
	}
	
    function setNFTStakingContract(address _nftstaking) external onlyOwner {
		require(_nftstaking != address(this), "NFTSTAKING Contract can not be TESTTOKEN");
		require(_nftstaking != address(0), "NFTSTAKING Contract can not be zero address");
        NFTSTAKING = _nftstaking;
        isFeeExempt[NFTSTAKING] = true;
        isDividendExempt[NFTSTAKING] = true;
        isMaxTxExempt[NFTSTAKING] = true;
        isMaxWalletExempt[NFTSTAKING] = true;
	}
	
    function setPrivateSaleContract(address _privatesale) external onlyOwner {
		require(_privatesale != address(this), "PRIVATESALE Contract can not be TESTTOKEN");
		require(_privatesale != address(0), "PRIVATESALE Contract can not be zero address");
        PRIVATESALE = _privatesale;
        isFeeExempt[PRIVATESALE] = true;
        isDividendExempt[PRIVATESALE] = true;
        isMaxTxExempt[PRIVATESALE] = true;
        isMaxWalletExempt[PRIVATESALE] = true;
	}
  
    function setTreasuryWallet(address _treasury) external onlyOwner {
		require(_treasury != address(this), "TREASURY Wallet can not be TESTTOKEN");
		require(_treasury != address(0), "TREASURY Wallet can not be zero address");
        TREASURY = _treasury;
        isFeeExempt[TREASURY] = true;
        isDividendExempt[TREASURY] = true;
        isMaxTxExempt[TREASURY] = true;
        isMaxWalletExempt[TREASURY] = true;
	}

	function setMaxTxAmount(uint256 amount) external onlyOwner {
        maxTxAmount = amount * (10**_decimals);
    }

    function setMaxWalletToken(uint256 amount) external onlyOwner {
        maxWalletTokens = amount * (10**_decimals);
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount)
        external
        onlyOwner
    {
        swapEnabled = _enabled;
        swapThreshold = _amount;
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

    function setDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 750000);
        distributorGas = gas;
    }

    // If the contract owner is transferred, the pinkAntiBot owner is automatically transferred
    function _transferOwnership(address newOwner) internal virtual override(Ownable) {
        if (_pinkAntiBotInstantiated) {
            pinkAntiBot.setTokenOwner(newOwner);
        }

        super._transferOwnership(newOwner);
    }

    // Allows the owner to withdraw tokens sent to the contract by mistake
    function rescueTokens(address token) external onlyOwner {
        require(token != address(this), "Cannot rescue own tokens"); // Owner cannot withdraw his own tokens from the contract

        uint256 _balance = IERC20(token).balanceOf(address(this));
        require(_balance > 0, "No tokens to rescue");

        IERC20(token).transfer(
            _msgSender(),
            _balance
        );
    }

    // Switch Antibot Status
    function enableAntibot(bool enable_) external onlyOwner {
        antibotEnabled = enable_;
    }

    function enableFeeOnTransfer(bool enable_) external onlyOwner {
        feeOnTransfer = enable_;
    }
    
    // Preset for [Tax,TxAmount,Wallet Size] before presale
    function prepareForPresale() external onlyOwner {
        updateBuyFees(0,0,0,0,0);
        updateSellFees(0,0,0,0,0);
        maxWalletTokens = (_totalSupply * 1) / 1; // 100% of supply
        maxTxAmount = (_totalSupply * 1) / 1; // 100% of supply
    }

    // Preset for [Tax,TxAmount,Wallet Size] before launch
    function prepareForLaunch() external onlyOwner {
        updateBuyFees(5,4,0,1,0); // 10%
        updateSellFees(6,7,0,1,0); // 14%
        maxWalletTokens = (_totalSupply * 100) / 10000; // 1% of supply
        maxTxAmount = (_totalSupply * 10) / 10000; // 0.10% of supply
    }

    // Preset for [Tax,TxAmount,Wallet Size] after launch
    function normalizeAfterLaunch() external onlyOwner {
        updateBuyFees(5,3,1,1,0); // 10%
        updateSellFees(5,3,1,1,0); // 10%
        maxWalletTokens = (_totalSupply * 500) / 10000; // 5% of supply
        maxTxAmount = (_totalSupply * 25) / 10000;  // 0.25% of supply
    }
}