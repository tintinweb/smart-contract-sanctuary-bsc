/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

/*
    
Ryz3 is the first Binary Tokens powering web3 speculation – think online betting merged with defi investing.

“Messi v Ronaldo: Top Goal Scorer” is the first official Ryz3 event – an alpha launch of the first Binary Tokens. Players can participate by purchasing either the Messi or Ronaldo token from PancakeSwap. 

A percentage of all transactions will be added to a prize pool that gets distributed as BUSD to the holders of the current winning token, that is the current Top Goal Scorer + Assists in the 2022 FIFA World Cup between Lionel Messi and Cristiano Ronaldo. At regular intervals, the leader is determined externally by a data feed provider.

https://ryz3.com/

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
    address public _binaryTokenA;
    address public _binaryTokenB;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IERC20 public REWARD;
    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

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

    modifier onlyControllerOrToken() {
        require(msg.sender == _token || msg.sender == _binaryTokenA || msg.sender == _binaryTokenB);
        _;
    }

    constructor(address _router, address rewardToken) {
        router = _router != address(0)
            ? IUniswapV2Router02(_router)
            : IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        _token = msg.sender;
        _binaryTokenA = msg.sender;
        _binaryTokenB = msg.sender;

        REWARD = IERC20(rewardToken);
    }

    receive() external payable {}

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external override onlyControllerOrToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function purge(address receiver) external override onlyControllerOrToken {
        uint256 balance = REWARD.balanceOf(address(this));
        REWARD.transfer(receiver, balance);
    }

    function setShare(address shareholder, uint256 amount)
        external
        override
        onlyControllerOrToken
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

    function deposit(uint256 amount) external override onlyControllerOrToken {
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(
            dividendsPerShareAccuracyFactor.mul(amount).div(totalShares)
        );
    }

    function process(uint256 gas) external override onlyControllerOrToken {
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

    function setBinaryTokens(address binaryTokenA, address binaryTokenB) external onlyToken {
        _binaryTokenA = binaryTokenA;
        _binaryTokenB = binaryTokenB;
    }
}

contract BinaryTokenController is Ownable {

    BinaryTokenInstance public binaryA;
    BinaryTokenInstance public binaryB;

    DividendDistributor public dividendDistributorA;
    DividendDistributor public dividendDistributorB;

    uint8 constant _decimals = 18;
    uint256 _totalSupply = 1000000000 * (10**_decimals);

    uint8 public binaryA_Id = 1;
    string constant public binaryA_Name = "Ryz3 Ronaldo";
    string constant public binaryA_Symbol = "GORONALDO";

    uint8 public binaryB_Id = 2;
    string constant public binaryB_Name = "Ryz3 Messi";
    string constant public binaryB_Symbol = "GOMESSI";

    uint8 constant public DRAW_UNKNOWN_VALUE = 0;

    // buy fees
    uint256 public buyDividendRewardsFee = 2;
    uint256 public buyMarketingDevFee = 2;
    uint256 public buyLiquidityFee = 0;
    uint256 public buyCommunityFee = 0;
    uint256 public buyBurnFee = 0;
    uint256 public buyTotalFees = 4;
    // sell fees
    uint256 public sellDividendRewardsFee = 6;
    uint256 public sellMarketingDevFee = 6;
    uint256 public sellLiquidityFee = 0;
    uint256 public sellCommunityFee = 0;
    uint256 public sellBurnFee = 0;
    uint256 public sellTotalFees = 12;

    uint256 public binaryA_Score;
    uint256 public binaryB_Score;

    address public _scoreController;

    modifier onlyScoreController() {
        require(msg.sender == _scoreController);
        _;
    }

    address public REWARD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //BUSD

    event ScoresChanged(uint256 scoreA, uint256 scoreB);
    event ScoreControllerUpdated(address controller);

    constructor() {
        address router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

        //Whitelisted Score Controller Address
        _scoreController = msg.sender;

        //Init
        dividendDistributorA = new DividendDistributor(address(router), REWARD);
        dividendDistributorB = new DividendDistributor(address(router), REWARD);

        //Init Binary Tokens
        binaryA = new BinaryTokenInstance(
            binaryA_Id, 
            binaryA_Name, 
            binaryA_Symbol, 
            _decimals, 
            _totalSupply, 
            address(this), 
            router, 
            _msgSender(),
            dividendDistributorA, 
            dividendDistributorB
        );
        
        binaryB = new BinaryTokenInstance(
            binaryB_Id, 
            binaryB_Name, 
            binaryB_Symbol, 
            _decimals, 
            _totalSupply, 
            address(this), 
            router,
            _msgSender(),
            dividendDistributorB, 
            dividendDistributorA
        );

        dividendDistributorA.setBinaryTokens(address(binaryA), address(binaryB));
        dividendDistributorB.setBinaryTokens(address(binaryA), address(binaryB));

        //Set each as Paired Tokens
        binaryA.setPairedToken(address(binaryB));
        binaryB.setPairedToken(address(binaryA));

        //Exclude each from fees
        binaryA.setIsFeeExempt(address(this), true);
        binaryA.setIsFeeExempt(address(binaryB), true);
        binaryB.setIsFeeExempt(address(this), true);
        binaryB.setIsFeeExempt(address(binaryA), true);

        //Init Scores
        binaryA_Score = 0;
        binaryB_Score = 0;

        setAllBuyFees(
            buyDividendRewardsFee, 
            buyMarketingDevFee, 
            buyLiquidityFee, 
            buyCommunityFee, 
            buyBurnFee
        );

        setAllSellFees(
            sellDividendRewardsFee, 
            sellMarketingDevFee, 
            sellLiquidityFee, 
            sellCommunityFee, 
            sellBurnFee
        );
    }

    function getCurrentWinnerId() public view returns (uint8) {
        if(binaryA_Score > binaryB_Score) {
            return binaryA_Id;
        } 
        if (binaryA_Score < binaryB_Score) {
            return binaryB_Id;
        } else {
            return DRAW_UNKNOWN_VALUE;
        }
    }

    function updateScores(uint256 scoreA, uint256 scoreB) public onlyScoreController {
        require(scoreA >= 0 && scoreB >= 0);
        binaryA_Score = scoreA;
        binaryB_Score = scoreB;
        emit ScoresChanged(scoreA, scoreB);
    }

    function setScoreController(address controller) public onlyOwner {
        _scoreController = controller;
        emit ScoreControllerUpdated(controller);
    }

    function setAllBuyFees (
        uint256 allReward, 
        uint256 allmarketingDev, 
        uint256 allLiquidity, 
        uint256 allCommunity, 
        uint256 allBurn
    ) public onlyOwner {
        binaryA.updateBuyFees(allReward, allmarketingDev, allLiquidity, allCommunity, allBurn);
        binaryB.updateBuyFees(allReward, allmarketingDev, allLiquidity, allCommunity, allBurn);
    }

    function setAllSellFees (
        uint256 allReward, 
        uint256 allmarketingDev, 
        uint256 allLiquidity, 
        uint256 allCommunity, 
        uint256 allBurn
    ) public onlyOwner {
        binaryA.updateSellFees(allReward, allmarketingDev, allLiquidity, allCommunity, allBurn);
        binaryB.updateSellFees(allReward, allmarketingDev, allLiquidity, allCommunity, allBurn);
    }

    function clearAllFees() public onlyOwner {
        setAllBuyFees(0, 0, 0, 0, 0);
        setAllSellFees(0, 0, 0, 0, 0);
    }

    function totalDistributedRewards() external view returns (uint256) {
        uint256 totalA = dividendDistributorA.totalDistributedRewards();
        uint256 totalB = dividendDistributorB.totalDistributedRewards();
        return totalA + totalB;
    }

    function disperseRemainingRewards() public onlyOwner {
        binaryA.disperseRemaining();
        binaryB.disperseRemaining();
    }

    function processAllDistributions(uint256 gas) public onlyOwner {
        try dividendDistributorA.process(gas) {} catch {}
        try dividendDistributorB.process(gas) {} catch {}           
    }

    function setIsDividendExemptForAll(address holder, bool exempt) public onlyOwner {
        binaryA.setIsDividendExempt(holder, exempt);
        binaryB.setIsDividendExempt(holder, exempt);
    }

    function setIsFeeExemptForAll(address holder, bool exempt) public onlyOwner {
        binaryA.setIsFeeExempt(holder, exempt);
        binaryB.setIsFeeExempt(holder, exempt);
    }

}

contract BinaryTokenInstance is IERC20, Ownable {
    using SafeMath for uint256;

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    // swap and send fees ( initially bnb can change later)
    address public SWAPTOKEN = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; //WBNB

    address public REWARD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //BUSD

    uint8 _id;
    string _name;
    string _symbol;
    uint8 _decimals;

    uint256 _totalSupply;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isDividendExempt;

    //Set on initialisation
    // buy fees
    uint256 public buyDividendRewardsFee;
    uint256 public buyMarketingDevFee;
    uint256 public buyLiquidityFee;
    uint256 public buyCommunityFee;
    uint256 public buyBurnFee;
    uint256 public buyTotalFees;
    // sell fees
    uint256 public sellDividendRewardsFee;
    uint256 public sellMarketingDevFee;
    uint256 public sellLiquidityFee;
    uint256 public sellCommunityFee;
    uint256 public sellBurnFee;
    uint256 public sellTotalFees;

    address public marketingDevFeeReceiver = 0x498af46B48706449B6E66EdfD2C85beFa4a500Da;
    address public communityFeeReceiver = 0x498af46B48706449B6E66EdfD2C85beFa4a500Da;

    IUniswapV2Router02 public router;
    address public pair;

    BinaryTokenController public parentController;

    //Restricts to calls by Parent Contract, or Parent Contract Owner
    modifier onlyParentOwner() {
        require(msg.sender == owner() || msg.sender == parentController.owner());
        _;
    }

    address public pairedToken;

    DividendDistributor public dividendDistributorSelf;
    DividendDistributor public dividendDistributorPair;

    uint256 distributorGas = 600000;

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event SendFeesInToken(address wallet, uint256 amount);
    event ChangeRewardTracker(address token);
    event IncludeInReward(address holder);

    bool public swapEnabled = true;
    uint256 public swapThreshold;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
        uint8 tokenId,
        string memory tokenName,
        string memory tokenSymbol,
        uint8 tokenDecimals,
        uint256 tokenTotalSupply,
        address controller,
        address routerAddress,
        address owningAddress,
        DividendDistributor distributorSelf, 
        DividendDistributor distributorPair
    ) {
        _id = tokenId;
        _name = tokenName;
        _symbol = tokenSymbol;
        _decimals = tokenDecimals;

        _totalSupply = tokenTotalSupply;
        swapThreshold  = (_totalSupply * 10) / 10000; // 0.01% of supply

        router = IUniswapV2Router02(routerAddress);
        pair = IUniswapV2Factory(router.factory()).createPair(
            WBNB,
            address(this)
        );

        parentController = BinaryTokenController(controller);

        _allowances[address(this)][address(router)] = type(uint256).max;

        dividendDistributorSelf = distributorSelf; //Set Dividend Distributor for Self
        dividendDistributorPair = distributorPair; //Set Dividend Distributor for Paired Token

        isFeeExempt[msg.sender] = true;
        isFeeExempt[owningAddress] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        _balances[owningAddress] = _totalSupply;
        emit Transfer(address(0), owningAddress, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
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
        return dividendDistributorSelf.getHolderDetails(holder);
    }

    function getLastProcessedIndex() public view returns (uint256) {
        return dividendDistributorSelf.getLastProcessedIndex();
    }

    function getNumberOfTokenHolders() public view returns (uint256) {
        return dividendDistributorSelf.getNumberOfTokenHolders();
    }

    function totalDistributedRewards() public view returns (uint256) {
        return dividendDistributorSelf.totalDistributedRewards();
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
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
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

        uint256 amountReceived = shouldTakeFee(sender)
            ? takeFee(sender, amount, recipient)
            : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        // Dividend tracker
        if (!isDividendExempt[sender]) {
            try
                dividendDistributorSelf.setShare(sender, _balances[sender])
            {} catch {}
        }

        if (!isDividendExempt[recipient]) {
            try
                dividendDistributorSelf.setShare(recipient, _balances[recipient])
            {} catch {}
        }

        // Get Winning Token Id
        uint8 currentWinner = parentController.getCurrentWinnerId();

        //Process Dividends for Winning Token
        if(currentWinner != parentController.DRAW_UNKNOWN_VALUE()) {
            if(currentWinner == _id) {
                try dividendDistributorSelf.process(distributorGas) {} catch {}

            } else {
                try dividendDistributorPair.process(distributorGas) {} catch {}
            }
        } else {
            try dividendDistributorSelf.process(distributorGas) {} catch {}
        }

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

    function shouldTakeFee(address sender) internal view returns (bool) {
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
        uint256 feesToContract = feeAmount.sub(burnFee);
        _balances[address(this)] = _balances[address(this)].add(feesToContract);
        emit Transfer(sender, address(this), feesToContract);

        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            msg.sender != pair &&
            !inSwap &&
            swapEnabled &&
            _balances[address(this)] >= swapThreshold;
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyParentOwner {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer((amountBNB * amountPercentage) / 100);
    }

    function changeSwapToken(address token) external onlyParentOwner {
        SWAPTOKEN = token;
    }

    function updateBuyFees(
        uint256 reward,
        uint256 marketingdev,
        uint256 liquidity,
        uint256 community,
        uint256 burn
    ) public onlyParentOwner {
        buyDividendRewardsFee = reward;
        buyMarketingDevFee = marketingdev;
        buyLiquidityFee = liquidity;
        buyCommunityFee = community;
        buyBurnFee = burn;
        buyTotalFees = reward.add(marketingdev).add(liquidity).add(community).add(burn);
        require(buyTotalFees <= 25, "Total Fee must be less than 25%");
    }

    function updateSellFees(
        uint256 reward,
        uint256 marketingdev,
        uint256 liquidity,
        uint256 community,
        uint256 burn
    ) public onlyParentOwner {
        sellDividendRewardsFee = reward;
        sellMarketingDevFee = marketingdev;
        sellLiquidityFee = liquidity;
        sellCommunityFee = community;
        sellBurnFee = burn;
        sellTotalFees = reward.add(marketingdev).add(liquidity).add(community).add(burn);
        require(sellTotalFees <= 25, "Total Fee must be less than 25%");
    }

    // new dividend tracker, clear balance
    function purgeBeforeSwitch() public onlyParentOwner {
        dividendDistributorSelf.purge(msg.sender);
    }

    function includeMyRewards() public {
        require(
            !isDividendExempt[msg.sender],
            "You are not allowed to get rewards"
        );
        try
            dividendDistributorSelf.setShare(msg.sender, _balances[msg.sender])
        {} catch {}

        emit IncludeInReward(msg.sender);
    }

    // new dividend tracker
    function switchToken(address rewardToken, bool isIncludeHolders)
        public
        onlyParentOwner
    {
        require(rewardToken != WBNB, "Can not reward BNB in this tracker");
        REWARD = rewardToken;
        // get current shareholders list
        address[] memory currentHolders = dividendDistributorSelf
            .getShareHoldersList();
        dividendDistributorSelf = new DividendDistributor(
            address(router),
            rewardToken
        );
        if (isIncludeHolders) {
            // add old share holders to new tracker
            for (uint256 i = 0; i < currentHolders.length; i++) {
                try
                    dividendDistributorSelf.setShare(
                        currentHolders[i],
                        _balances[currentHolders[i]]
                    )
                {} catch {}
            }
        }

        emit ChangeRewardTracker(rewardToken);
    }

    // manual claim for the greedy humans
    function ___claimRewards(bool tryAll) public {
        dividendDistributorSelf.claimDividend();
        if (tryAll) {
            try dividendDistributorSelf.process(distributorGas) {} catch {}
        }
    }

    // manually clear the queue
    function claimProcess() public {
        try dividendDistributorSelf.process(distributorGas) {} catch {}
    }

    function swapBackInBnb() internal swapping {
        uint256 contractTokenBalance = _balances[address(this)];
        uint256 tokensToLiquidity = contractTokenBalance
            .mul(buyLiquidityFee)
            .div(buyTotalFees);

        uint256 tokensToReward = contractTokenBalance
            .mul(buyDividendRewardsFee)
            .div(buyTotalFees);
        // calculate tokens amount to swap
        uint256 tokensToSwap = contractTokenBalance.sub(tokensToLiquidity).sub(
            tokensToReward
        );
        // swap the tokens
        swapTokensForEth(tokensToSwap);
        // get swapped bnb amount
        uint256 swappedBnbAmount = address(this).balance;

        uint256 totalSwapFee = buyMarketingDevFee.add(buyCommunityFee);
        uint256 marketingDevFeeBnb = swappedBnbAmount.mul(buyMarketingDevFee).div(
            totalSwapFee
        );
        uint256 communityFeeBnb = swappedBnbAmount.sub(marketingDevFeeBnb);
        // calculate reward bnb amount
        if (tokensToReward > 0) {
            swapTokensForTokens(tokensToReward, REWARD);

            uint256 swappedTokensAmount = IERC20(REWARD).balanceOf(
                address(this)
            );

            // Get Winning Token Id
            uint8 currentWinner = parentController.getCurrentWinnerId();

            //Note: If Draw or Invalid, hold rewards in contract
            if(currentWinner != parentController.DRAW_UNKNOWN_VALUE()) {
                if(currentWinner == _id) {
                    // Send reward to this instance distributor
                    IERC20(REWARD).transfer(
                        address(dividendDistributorSelf),
                        swappedTokensAmount
                    );
                    try dividendDistributorSelf.deposit(swappedTokensAmount) {} catch {}

                } else {
                    // Send reward to paired token instance distributor
                    IERC20(REWARD).transfer(
                        address(dividendDistributorPair),
                        swappedTokensAmount
                    );
                    try dividendDistributorPair.deposit(swappedTokensAmount) {} catch {}
                }
            }

        }
        if (marketingDevFeeBnb > 0) {
            (bool marketingDevSuccess, ) = payable(marketingDevFeeReceiver).call{
                value: marketingDevFeeBnb,
                gas: 30000
            }("");
            marketingDevSuccess = false;
        }

        if (communityFeeBnb > 0) {
            (bool communitySuccess, ) = payable(communityFeeReceiver).call{
                value: communityFeeBnb,
                gas: 30000
            }("");
            // only to supress warning msg
            communitySuccess = false;
        }

        if (tokensToLiquidity > 0) {
            // add liquidity
            swapAndLiquify(tokensToLiquidity);
        }
    }

    function swapBackInTokens() internal swapping {
        uint256 contractTokenBalance = _balances[address(this)];
        uint256 rewardTokens = contractTokenBalance
            .mul(buyDividendRewardsFee)
            .div(buyTotalFees);
        uint256 liquidityTokens = contractTokenBalance.mul(buyLiquidityFee).div(
            buyTotalFees
        );
        uint256 tokensForFee = contractTokenBalance.sub(rewardTokens).sub(
            liquidityTokens
        );

        if (rewardTokens > 0) {
            swapTokensForTokens(rewardTokens, REWARD);

            uint256 swappedTokensAmount = IERC20(REWARD).balanceOf(
                address(this)
            );

            // Get Winning Token Id
            uint8 currentWinner = parentController.getCurrentWinnerId();

            //Note: If Draw or Invalid, hold rewards in contract
            if(currentWinner != parentController.DRAW_UNKNOWN_VALUE()) {
                if(currentWinner == _id) {
                    // Send reward to this instance distributor
                    IERC20(REWARD).transfer(
                        address(dividendDistributorSelf),
                        swappedTokensAmount
                    );
                    try dividendDistributorSelf.deposit(swappedTokensAmount) {} catch {}

                } else {
                    // Send reward to paired token instance distributor
                    IERC20(REWARD).transfer(
                        address(dividendDistributorPair),
                        swappedTokensAmount
                    );
                    try dividendDistributorPair.deposit(swappedTokensAmount) {} catch {}
                }
            }
        }
        if (liquidityTokens > 0) {
            swapAndLiquify(liquidityTokens);
        }
        if (tokensForFee > 0) {
            swapAndSendFees(tokensForFee);
        }
    }

    function disperseRemaining() public onlyParentOwner {
        //Get Rewards Balance
        uint256 swappedTokensAmount = IERC20(REWARD).balanceOf(
            address(this)
        );

        // Send any remaining reward to this instance distributor
        if(swappedTokensAmount > 0) {
            IERC20(REWARD).transfer(
                address(dividendDistributorSelf),
                swappedTokensAmount
            );

            try dividendDistributorSelf.deposit(swappedTokensAmount) {} catch {}
            try dividendDistributorSelf.process(distributorGas) {} catch {}
        }

    }

    function swapAndSendFees(uint256 tokensForFee) private {
        uint256 totalSwapFee = buyMarketingDevFee.add(buyCommunityFee);
        // // swap tokens
        swapTokensForTokens(tokensForFee, SWAPTOKEN);

        uint256 currentTokenBalance = IERC20(SWAPTOKEN).balanceOf(
            address(this)
        );
        uint256 marketingDevToken = currentTokenBalance.mul(buyMarketingDevFee).div(
            totalSwapFee
        );
        uint256 communityToken = currentTokenBalance.sub(marketingDevToken);

        //send tokens to wallets
        if (marketingDevToken > 0) {
            _approve(address(this), marketingDevFeeReceiver, marketingDevToken);
            IERC20(SWAPTOKEN).transfer(marketingDevFeeReceiver, marketingDevToken);
            emit SendFeesInToken(marketingDevFeeReceiver, marketingDevToken);
        }
        if (communityToken > 0) {
            _approve(address(this), communityFeeReceiver, communityToken);
            IERC20(SWAPTOKEN).transfer(communityFeeReceiver, communityToken);
            emit SendFeesInToken(communityFeeReceiver, communityToken);
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

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit AutoLiquify(newBalance, otherHalf);
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

    function swapTokensForTokens(uint256 tokenAmount, address tokenToSwap)
        private
    {
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

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        _approve(address(this), address(router), tokenAmount);

        // add the liquidity
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
        onlyParentOwner
    {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if (exempt) {
            dividendDistributorSelf.setShare(holder, 0);
        } else {
            dividendDistributorSelf.setShare(holder, _balances[holder]);
        }
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyParentOwner {
        isFeeExempt[holder] = exempt;
    }

    function setFeeReceivers(address _marketingDevFeeReceiver, address _communityFeeReceiver) external onlyParentOwner {
        marketingDevFeeReceiver = _marketingDevFeeReceiver;
        communityFeeReceiver = _communityFeeReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount)
        external
        onlyParentOwner
    {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external onlyParentOwner {
        dividendDistributorSelf.setDistributionCriteria(
            _minPeriod,
            _minDistribution
        );
    }

    function setDistributorSettings(uint256 gas) external onlyParentOwner {
        require(gas < 750000);
        distributorGas = gas;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return isFeeExempt[account];
    }

    function isExcludedFromDividends(address account) public view returns(bool) {
        return isDividendExempt[account];
    }

    function setRouterAddress(address newRouter) external onlyParentOwner {
        IUniswapV2Router02 _newPancakeRouter = IUniswapV2Router02(newRouter);
        pair = IUniswapV2Factory(router.factory()).createPair(
            WBNB,
            address(this)
        );
        router = _newPancakeRouter;
    }

    function setPairedToken(address pairAddress) public onlyParentOwner {
        pairedToken = pairAddress;
    }
}