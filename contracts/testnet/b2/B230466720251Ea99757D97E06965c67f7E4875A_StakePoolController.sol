/**
 *Submitted for verification at BscScan.com on 2021-03-27
*/

pragma abicoder v2;
pragma solidity 0.7.6;


// SPDX-License-Identifier: MIT
interface IStakePoolCreator {
    function version() external returns (uint);

    function create() external returns (address);
    function initialize(address poolAddress, address pair, address rewardToken, address timelock, address stakePoolRewardFund, bytes calldata data) external;
}


interface IStakePoolController {
    event MasterCreated(address indexed farm, address indexed stakeToken, uint version, address timelock, address stakePoolRewardFund, uint totalStakePool);
    event SetWhitelistStakingFor(address indexed contractAddress, bool value);
    event SetWhitelistStakePool(address indexed contractAddress, int8 value);
    event SetStakePoolCreator(address indexed contractAddress, uint verion);
    event SetWhitelistRewardRebaser(address indexed contractAddress, bool value);
    event SetWhitelistRewardMultiplier(address indexed contractAddress, bool value);
    event SetStakePoolVerifier(address indexed contractAddress, bool value);
    event ChangeGovernance(address indexed governance);
    event SetFeeCollector(address indexed feeCollector);
    event SetFeeToken(address indexed token);
    event SetFeeAmount(uint indexed amount);
    event SetExtraFeeRate(uint indexed amount);



    function allStakePools(uint) external view returns (address stakePool);

    function isStakePool(address contractAddress) external view returns (bool);
    function isStakePoolVerifier(address contractAddress) external view returns (bool);

    function isWhitelistStakingFor(address contractAddress) external view returns (bool);
    function isWhitelistStakePool(address contractAddress) external view returns (int8);
    function setStakePoolVerifier(address contractAddress, bool state) external;
    function setWhitelistStakingFor(address contractAddress, bool state) external;

    function setWhitelistStakePool(address contractAddress, int8 state) external;
    function addStakePoolCreator(address contractAddress) external;

    function isWhitelistRewardRebaser(address contractAddress) external view returns (bool);
    function isAllowEmergencyWithdrawStakePool(address _address) external view returns (bool);
    function setWhitelistRewardRebaser(address contractAddress, bool state) external;

    function isWhitelistRewardMultiplier(address contractAddress) external view returns (bool);
    function setAllowEmergencyWithdrawStakePool(address _address, bool state) external;
    function setWhitelistRewardMultiplier(address contractAddress, bool state) external;
    function setEnableWhitelistRewardRebaser(bool value) external;
    function setEnableWhitelistRewardMultiplier(bool value) external;
    function allStakePoolsLength() external view returns (uint);

    function create(uint version, address stakeToken, address rewardToken, uint rewardFundAmount, uint delayTimeLock, bytes calldata data) external returns (address);

    function setGovernance(address) external;

    function setFeeCollector(address _address) external;
    function setFeeToken(address _token) external;
    function setFeeAmount(uint _token) external;
    function setExtraFeeRate(uint _extraFeeRate) external;

}

interface IValueLiquidRouter {
    event Exchange(
        address pair,
        uint amountOut,
        address output
    );
    struct Swap {
        address pool;
        address tokenIn;
        address tokenOut;
        uint swapAmount; // tokenInAmount / tokenOutAmount
        uint limitReturnAmount; // minAmountOut / maxAmountIn
        uint maxPrice;
    }
    function factory() external view returns (address);
    function controller() external view returns (address);

    function formula() external view returns (address);

    function WETH() external view returns (address);

    function addLiquidity(
        address pair,
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
        address pair,
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);


    function swapExactTokensForTokens(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        address tokenIn,
        address tokenOut,
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(address tokenOut, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function swapTokensForExactETH(address tokenIn, uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapExactTokensForETH(address tokenIn, uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapETHForExactTokens(address tokenOut, uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        address tokenOut,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        address tokenIn,
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;


    function multihopBatchSwapExactIn(
        Swap[][] memory swapSequences,
        address tokenIn,
        address tokenOut,
        uint totalAmountIn,
        uint minTotalAmountOut,
        uint deadline
    )
    external payable returns (uint totalAmountOut);
    function multihopBatchSwapExactOut(
        Swap[][] memory swapSequences,
        address tokenIn,
        address tokenOut,
        uint maxTotalAmountIn,
        uint deadline
    ) external payable returns (uint totalAmountIn);

    function createPair( address tokenA, address tokenB,uint amountA,uint amountB, uint32 tokenWeightA, uint32 swapFee, address to) external returns (uint liquidity);
    function createPairETH( address token, uint amountToken, uint32 tokenWeight, uint32 swapFee, address to) external payable returns (uint liquidity);

    function removeLiquidity(
        address pair,
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address pair,
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address pair,
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
        address pair,
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);


    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address pair,
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address pair,
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);
}

interface IValueLiquidFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint32 tokenWeight0, uint32 swapFee, uint);
    function feeTo() external view returns (address);
    function formula() external view returns (address);
    function protocolFee() external view returns (uint);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB, uint32 tokenWeightA, uint32 swapFee) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function isPair(address) external view returns (bool);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB, uint32 tokenWeightA, uint32 swapFee) external returns (address pair);
    function getWeightsAndSwapFee(address pair) external view returns (uint32 tokenWeight0, uint32 tokenWeight1, uint32 swapFee);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function setProtocolFee(uint) external;
}


interface IStakePool {
    event Deposit(address indexed account, uint256 amount);
    event AddRewardPool(uint256 indexed poolId);
    event UpdateRewardPool(uint256 indexed poolId, uint256 endRewardBlock, uint256 rewardPerBlock);
    event PayRewardPool(uint256 indexed poolId, address indexed rewardToken, address indexed account, uint256 pendingReward, uint256 rebaseAmount, uint256 paidReward);
    event UpdateRewardRebaser(uint256 indexed poolId, address rewardRebaser);
    event UpdateRewardMultiplier(uint256 indexed poolId, address rewardMultiplier);
    event Withdraw(address indexed account, uint256 amount);
    function version() external view returns (uint);
    function stakeToken() external view returns (address);
    function initialize(address _stakeToken, uint _unstakingFrozenTime, address _rewardFund, address _timelock) external;

    function stake(uint) external;

    function stakeFor(address _account) external;

    function withdraw(uint) external;

    function getReward(uint8 _pid, address _account) external;

    function getAllRewards(address _account) external;
    function claimReward() external;
    function pendingReward(uint8 _pid, address _account) external view returns (uint);

    function allowRecoverRewardToken(address _token) external view returns (bool);
    function getRewardPerBlock(uint8 pid) external view returns (uint);
    function rewardPoolInfoLength() external view returns (uint);

    function unfrozenStakeTime(address _account) external view returns (uint);

    function emergencyWithdraw() external;

    function updateReward() external;

    function updateReward(uint8 _pid) external;

    function updateRewardPool(uint8 _pid, uint256 _endRewardBlock, uint256 _rewardPerBlock) external;

    function getRewardMultiplier(uint8 _pid, uint _from, uint _to, uint _rewardPerBlock) external view returns (uint);

    function getRewardRebase(uint8 _pid, address _rewardToken, uint _pendingReward) external view returns (uint);

    function updateRewardRebaser(uint8 _pid, address _rewardRebaser) external;

    function updateRewardMultiplier(uint8 _pid, address _rewardMultiplier) external;

    function getUserInfo(uint8 _pid, address _account) external view returns (uint amount, uint rewardDebt, uint accumulatedEarned, uint lockReward, uint lockRewardReleased);

    function addRewardPool(
        address _rewardToken,
        address _rewardRebaser,
        address _rewardMultiplier,
        uint256 _startBlock,
        uint256 _endRewardBlock,
        uint256 _rewardPerBlock,
        uint256 _lockRewardPercent,
        uint256 _startVestingBlock,
        uint256 _endVestingBlock
    ) external;
}

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

interface IValueLiquidPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
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


    event PaidProtocolFee(uint112 collectedFee0, uint112 collectedFee1);
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
    function getCollectedFees() external view returns (uint112 _collectedFee0, uint112 _collectedFee1);
    function getTokenWeights() external view returns (uint32 tokenWeight0, uint32 tokenWeight1);
    function getSwapFee() external view returns (uint32);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address, uint32, uint32) external;
}


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}


contract TimeLock {
    using SafeMath for uint256;
    event NewAdmin(address indexed newAdmin);
    event NewPendingAdmin(address indexed newPendingAdmin);
    event NewDelay(uint indexed newDelay);
    event CancelTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint eta);
    event ExecuteTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint eta);
    event QueueTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint eta);

    uint public constant GRACE_PERIOD = 14 days;
    uint public constant MINIMUM_DELAY = 1 days;
    uint public constant MAXIMUM_DELAY = 30 days;
    bool private _initialized;
    address public admin;
    address public pendingAdmin;
    uint public delay;
    bool public admin_initialized;
    mapping(bytes32 => bool) public queuedTransactions;

    constructor() public {
        admin_initialized = false;
        _initialized = false;
    }

    function initialize(address _admin, uint _delay) public {
        require(_initialized == false, "Timelock::constructor: Initialized must be false.");
        require(_delay >= MINIMUM_DELAY, "Timelock::setDelay: Delay must exceed minimum delay.");
        require(_delay <= MAXIMUM_DELAY, "Timelock::setDelay: Delay must not exceed maximum delay.");
        delay = _delay;
        admin = _admin;
        _initialized = true;
        emit NewAdmin(admin);
        emit NewDelay(delay);
    }

    receive() external payable {}

    function setDelay(uint _delay) public {
        require(msg.sender == address(this), "Timelock::setDelay: Call must come from Timelock.");
        require(_delay >= MINIMUM_DELAY, "Timelock::setDelay: Delay must exceed minimum delay.");
        require(_delay <= MAXIMUM_DELAY, "Timelock::setDelay: Delay must not exceed maximum delay.");
        delay = _delay;
        emit NewDelay(delay);
    }

    function acceptAdmin() public {
        require(msg.sender == pendingAdmin, "Timelock::acceptAdmin: Call must come from pendingAdmin.");
        admin = msg.sender;
        pendingAdmin = address(0);
        emit NewAdmin(admin);
    }

    function setPendingAdmin(address _pendingAdmin) public {
        // allows one time setting of admin for deployment purposes
        if (admin_initialized) {
            require(msg.sender == address(this), "Timelock::setPendingAdmin: Call must come from Timelock.");
        } else {
            require(msg.sender == admin, "Timelock::setPendingAdmin: First call must come from admin.");
            admin_initialized = true;
        }
        pendingAdmin = _pendingAdmin;

        emit NewPendingAdmin(pendingAdmin);
    }

    function queueTransaction(address target, uint value, string memory signature, bytes memory data, uint eta) public returns (bytes32) {
        require(msg.sender == admin, "Timelock::queueTransaction: Call must come from admin.");
        require(eta >= getBlockTimestamp().add(delay), "Timelock::queueTransaction: Estimated execution block must satisfy delay.");

        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = true;

        emit QueueTransaction(txHash, target, value, signature, data, eta);
        return txHash;
    }

    function cancelTransaction(address target, uint value, string memory signature, bytes memory data, uint eta) public {
        require(msg.sender == admin, "Timelock::cancelTransaction: Call must come from admin.");

        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = false;

        emit CancelTransaction(txHash, target, value, signature, data, eta);
    }

    function executeTransaction(address target, uint value, string memory signature, bytes memory data, uint eta) public payable returns (bytes memory) {
        require(msg.sender == admin, "Timelock::executeTransaction: Call must come from admin.");

        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        require(queuedTransactions[txHash], "Timelock::executeTransaction: Transaction hasn't been queued.");
        require(getBlockTimestamp() >= eta, "Timelock::executeTransaction: Transaction hasn't surpassed time lock.");
        require(getBlockTimestamp() <= eta.add(GRACE_PERIOD), "Timelock::executeTransaction: Transaction is stale.");

        queuedTransactions[txHash] = false;

        bytes memory callData;

        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        // solium-disable-next-line security/no-call-value
        (bool success, bytes memory returnData) = target.call{value : value}(callData);
        require(success, "Timelock::executeTransaction: Transaction execution reverted.");

        emit ExecuteTransaction(txHash, target, value, signature, data, eta);

        return returnData;
    }

    function getBlockTimestamp() internal view returns (uint) {
        return block.timestamp;
    }
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IStakePoolRewardFund {
    function initialize(address _stakePool, address _timelock) external;

    function safeTransfer(address _token, address _to, uint _value) external;
}

interface IStakePoolRewardRebaser {
    function getRebaseAmount(address rewardToken, uint baseAmount) external view returns (uint);
}

interface IStakePoolRewardMultiplier {
    function getRewardMultiplier(uint _start, uint _end, uint _from, uint _to, uint _rewardPerBlock) external view returns (uint);
}


contract StakePoolRewardFund is IStakePoolRewardFund {
    address public stakePool;
    address public timelock;
    bool private _initialized;

    function initialize(address _stakePool, address _timelock) external override {
        require(_initialized == false, "StakePoolRewardFund: already initialized");
        stakePool = _stakePool;
        timelock = _timelock;
        _initialized = true;
    }

    function safeTransfer(address _token, address _to, uint256 _value) external override {
        require(msg.sender == stakePool, "StakePoolRewardFund: !stakePool");
        TransferHelper.safeTransfer(_token, _to, _value);
    }

    function allowRecoverRewardToken(address _token) public view returns (bool){
        return IStakePool(stakePool).allowRecoverRewardToken(_token);
    }

    function recoverRewardToken(
        address _token,
        address _to,
        uint256 _amount
    ) external {
        require(msg.sender == timelock, "StakePoolRewardFund: !timelock");
        require(allowRecoverRewardToken(_token), "StakePoolRewardFund: not allow recover reward token");
        TransferHelper.safeTransfer(_token, _to, _amount);
    }
}

contract StakePoolController is IStakePoolController {
    IValueLiquidFactory public swapFactory;
    address public governance;

    address public feeCollector;
    address public feeToken;
    uint public  feeAmount;

    mapping(address => bool) private _stakePools;
    mapping(address => bool) private _whitelistStakingFor;
    mapping(address => bool) private _whitelistRewardRebaser;
    mapping(address => bool) private _whitelistRewardMultiplier;
    mapping(address => int8) private _whitelistStakePools;
    mapping(address => bool) public _stakePoolVerifiers;
    mapping(uint => address) public stakePoolCreators;
    address[] public override allStakePools;
    bool public enableWhitelistRewardRebaser;
    bool public enableWhitelistRewardMultiplier;
    bool private _initialized;

    mapping(address => bool) public allowEmergencyWithdrawStakePools;

    uint public extraFeeRate;

    function initialize(address _swapFactory) public {
        require(_initialized == false, "StakePoolController: initialized");
        governance = msg.sender;
        enableWhitelistRewardRebaser = true;
        enableWhitelistRewardMultiplier = true;
        swapFactory = IValueLiquidFactory(_swapFactory);
        _initialized = true;
    }

    function isStakePool(address b) external override view returns (bool){
        return _stakePools[b];
    }

    modifier onlyGovernance() {
        require(msg.sender == governance, "StakePoolController: !governance");
        _;
    }

    function setFeeCollector(address _address) external onlyGovernance override {
        require(_address != address(0), "StakePoolController: invalid address");
        feeCollector = _address;
        emit SetFeeCollector(_address);
    }
    function setEnableWhitelistRewardRebaser(bool value) external onlyGovernance override {
        enableWhitelistRewardRebaser = value;
    }
    function setEnableWhitelistRewardMultiplier(bool value) external onlyGovernance override {
        enableWhitelistRewardMultiplier = value;
    }
    function setFeeToken(address _token) external onlyGovernance override {
        require(_token != address(0), "StakePoolController: invalid _token");
        feeToken = _token;
        emit SetFeeToken(_token);
    }
    function getCreationFee(address token) public view returns (uint) {
        if (swapFactory.isPair(token)) {
            return feeAmount;
        }
        return feeAmount * extraFeeRate / 1000;
    }
    function setFeeAmount(uint _feeAmount) external onlyGovernance override {
        feeAmount = _feeAmount;
        emit SetFeeAmount(_feeAmount);
    }
    function setExtraFeeRate(uint _extraFeeRate) external onlyGovernance override {
        require(_extraFeeRate >= 1000 && _extraFeeRate <= 50000, "StakePoolController: invalid _extraFeeRate");
        extraFeeRate = _extraFeeRate;
        emit SetExtraFeeRate(_extraFeeRate);
    }
    function isWhitelistStakingFor(address _address) external override view returns (bool){
        return _whitelistStakingFor[_address];
    }

    function isWhitelistStakePool(address _address) external override view returns (int8){
        return _whitelistStakePools[_address];
    }
    function isStakePoolVerifier(address _address) external override view returns (bool){
        return _stakePoolVerifiers[_address];
    }
    function isAllowEmergencyWithdrawStakePool(address _address) external override view returns (bool){
        return allowEmergencyWithdrawStakePools[_address];
    }
    function setWhitelistStakingFor(address _address, bool state) external onlyGovernance override {
        require(_address != address(0), "StakePoolController: invalid address");
        _whitelistStakingFor[_address] = state;
        emit SetWhitelistStakingFor(_address, state);
    }
    function setAllowEmergencyWithdrawStakePool(address _address, bool state) external onlyGovernance override {
        require(_address != address(0), "StakePoolController: invalid address");
        allowEmergencyWithdrawStakePools[_address] = state;
    }

    function setStakePoolVerifier(address _address, bool state) external onlyGovernance override {
        require(_address != address(0), "StakePoolController: invalid address");
        _stakePoolVerifiers[_address] = state;
        emit SetStakePoolVerifier(_address, state);
    }

    function setWhitelistStakePool(address _address, int8 state) external override {
        require(_address != address(0), "StakePoolController: invalid address");
        require(_stakePoolVerifiers[msg.sender] == true, "StakePoolController: invalid stake pool verifier");
        _whitelistStakePools[_address] = state;
        emit SetWhitelistStakePool(_address, state);
    }

    function addStakePoolCreator(address _address) external onlyGovernance override {
        require(_address != address(0), "StakePoolController: invalid address");
        uint version = IStakePoolCreator(_address).version();
        require(version >= 1000, "Invalid stake pool creator version");
        stakePoolCreators[version] = _address;
        emit SetStakePoolCreator(_address, version);
    }

    function isWhitelistRewardRebaser(address _address) external override view returns (bool){
        if (!enableWhitelistRewardRebaser) return true;
        return _address == address(0) ? true : _whitelistRewardRebaser[_address];
    }

    function setWhitelistRewardRebaser(address _address, bool state) external onlyGovernance override {
        require(_address != address(0), "StakePoolController: invalid address");
        _whitelistRewardRebaser[_address] = state;
        emit SetWhitelistRewardRebaser(_address, state);
    }

    function isWhitelistRewardMultiplier(address _address) external override view returns (bool){
        if (!enableWhitelistRewardMultiplier) return true;
        return _address == address(0) ? true : _whitelistRewardMultiplier[_address];
    }

    function setWhitelistRewardMultiplier(address _address, bool state) external onlyGovernance override {
        require(_address != address(0), "StakePoolController: invalid address");
        _whitelistRewardMultiplier[_address] = state;
        emit SetWhitelistRewardMultiplier(_address, state);
    }

    function setGovernance(address _governance) external onlyGovernance override {
        require(_governance != address(0), "StakePoolController: invalid governance");
        governance = _governance;
        emit ChangeGovernance(_governance);
    }

    function allStakePoolsLength() external override view returns (uint) {
        return allStakePools.length;
    }
    function createInternal(address stakePoolCreator, address stakeToken, address stakePoolRewardFund, address rewardToken, uint delayTimeLock, bytes calldata data) internal returns (address) {
        TimeLock timelock = new TimeLock();
        IStakePool pool = IStakePool(IStakePoolCreator(stakePoolCreator).create());
        allStakePools.push(address(pool));
        _stakePools[address(pool)] = true;
        emit MasterCreated(address(pool), stakeToken, pool.version(), address(timelock), stakePoolRewardFund, allStakePools.length);
        IStakePoolCreator(stakePoolCreator).initialize(address(pool), stakeToken, rewardToken, address(timelock), address(stakePoolRewardFund), data);
        StakePoolRewardFund(stakePoolRewardFund).initialize(address(pool), address(timelock));
        timelock.initialize(msg.sender, delayTimeLock);
        return address(pool);
    }
    function create(uint version, address stakeToken, address rewardToken, uint rewardFundAmount, uint delayTimeLock, bytes calldata data) public override returns (address) {
        address stakePoolCreator = stakePoolCreators[version];
        require(stakePoolCreator != address(0), "StakePoolController: Invalid stake pool creator version");
        uint creationFee = getCreationFee(stakeToken);
        if (feeCollector != address(0) && feeToken != address(0) && creationFee > 0) {
            TransferHelper.safeTransferFrom(feeToken, msg.sender, feeCollector, creationFee);
        }

        StakePoolRewardFund stakePoolRewardFund = new StakePoolRewardFund();
        if (rewardFundAmount > 0) {
            require(IERC20(rewardToken).balanceOf(msg.sender) >= rewardFundAmount , "StakePoolController: Not enough rewardFundAmount");
            TransferHelper.safeTransferFrom(rewardToken, msg.sender, address(stakePoolRewardFund), rewardFundAmount);
        }
        return createInternal(stakePoolCreator, stakeToken, address(stakePoolRewardFund), rewardToken, delayTimeLock, data);
    }
}