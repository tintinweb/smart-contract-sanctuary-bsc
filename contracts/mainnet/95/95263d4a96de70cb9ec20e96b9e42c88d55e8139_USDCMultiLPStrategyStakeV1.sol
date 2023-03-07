/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);
    
    function decimals() external view returns (uint8);

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

// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity ^0.6.0;

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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: @openzeppelin/contracts/utils/Address.sol

pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol

pragma solidity ^0.6.0;

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: @openzeppelin/contracts/GSN/Context.sol

pragma solidity ^0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

pragma solidity ^0.6.0;

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
contract Ownable is Context {
    address private _governance;

    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _governance = msgSender;
        emit GovernanceTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function governance() public view returns (address) {
        return _governance;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyGovernance() {
        require(_governance == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferGovernance(address newOwner) internal virtual onlyGovernance {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit GovernanceTransferred(_governance, newOwner);
        _governance = newOwner;
    }
}

// File: contracts/strategies/USDCMultiLPStrategyStakeV1.sol

pragma solidity =0.6.6;
pragma experimental ABIEncoderV2;

interface StabilizeStakingPool {
    function notifyRewardAmount(uint256) external;
    function getTotalSTBB() external view returns (uint256);
    function getCurrentStrategy() external view returns (address);
}

interface ThenaStaker {
    function getReward() external;
    function claimFees() external returns (uint claimed0, uint claimed1);
    function withdraw(uint256 amount) external;
    function depositAll() external;
    function earned(address account) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

interface TradeRouter {
    function swapExactETHForTokens(uint, address[] calldata, address, uint) external payable returns (uint[] memory); // Pancake
    function swapExactTokensForTokens(uint, uint, address[] calldata, address, uint) external returns (uint[] memory);
    function getAmountsOut(uint, address[] calldata) external view returns (uint[] memory); // For a value in, it calculates value out
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface CurveLikeExchange{
    function get_dy(uint256, uint256, uint256) external view returns (uint256);
    function exchange(uint256, uint256, uint256, uint256) external; // Exchange tokens
    function coins(uint256) external view returns (address);
}

interface SolidlyRouter{
    struct route {
        address from;
        address to;
        bool stable;
    }
    function getAmountsOut(uint256 amountIn, SolidlyRouter.route[] calldata routes) external view returns (uint256[] memory amounts);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        SolidlyRouter.route[] calldata routes,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function addLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
}

contract USDCMultiLPStrategyStakeV1 is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    
    address public treasuryAddress; // Address of the treasury
    address public zsbTokenAddress; // The address of the controlling zsb-Token

    uint256 constant DIVISION_FACTOR = 100000;
    
    uint256 public lastTradeTime;
    uint256 public lastActionBalance; // Balance before last deposit, withdraw or trade
    uint256 public percentStakeDepositor = 90000; // depositors earn 90% of all stake gains
    uint256 public percentExecutor = 50000; // 50000 = 50% of WBNB goes to executor on top of gas stipend
    uint256 public percentStakers = 50000; // 50000 = 50% of remaining WBNB goes to strat stakers 

    bool public emergencyWithdrawMode = false; // Activated in case tokens get stuck in strategy after timelock

    // Token information
    struct PoolInfo {
        IERC20 token0; // Reference of token0
        IERC20 token1; // Reference of token1
        address pancakeStableRouterAddress;
        uint256 usdcIndex;
        uint256 stableIndex;
        address stableAddress;
        IERC20 lpToken;
        address rewardPoolAddress;
    }
    
    PoolInfo[] private poolList; // An array of tokens accepted as deposits

    // Token information
    struct TokenInfo {
        IERC20 token; // Reference of token
        uint256 decimals; // Decimals of token
    }
    
    TokenInfo[] private tokenList; // An array of tokens accepted as deposits
    
    // Strategy specific variables
    uint256 public twapToken0Price = 1e18; // Price is relative to USDC
    uint256 public twapToken1Price = 1e18; // Price is relative to USDC
    uint256 public lastTokenPriceUpdateTime = block.timestamp;

    // Router And Address Information
    address constant WBNB_ADDRESS = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); // WBNB address
    address constant THENA_ADDRESS = address(0xF4C8E32EaDEC4BFe97E0F595AdD0f4450a863a11); // Thena address
    // Ideal cash out route - THENA -> BNB (via Thena swap) -> USDC (via Normal Pancake)
    address constant THENA_ROUTER = address(0xd4ae6eCA985340Dd434D38F470aCCce4DC78D109);
    address constant PANCAKE_ROUTER = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    // Configurables
    uint256 public currentPool = 0; // Governance selected Thena pool to go into
    uint256 public minTokenPriceUpdateTime = 60 * 10; // At least 10 minutes must be present since last update
    uint256 public percentSpotPriceWeight = 2000; // Spot price can only move current price by 2% at most
    uint256 public tokenSlippageAllowed = 1000; // Max price slip allowed
    uint256 public minTWAPPriceAllowed = 95e16; // 0.95 then the strategy will exit
    uint256 public gasStipend = 600000; // This is the gas units that are covered by executing a trade taken from the WBNB profit 
    uint256 public gasPrice = 6e9; // Gas price in wei, not constant  

    constructor(
        address _treasury,
        address _zsbToken
    ) public {
        treasuryAddress = _treasury;
        zsbTokenAddress = _zsbToken;
        setupTokens();
        (twapToken0Price, twapToken1Price) = calculateSpotPrices(0,0, currentPool);
    }

    // Initialization functions
    
    function setupTokens() internal {
        // USDC
        IERC20 _token = IERC20(address(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d));
        tokenList.push(
            TokenInfo({
                token: _token,
                decimals: _token.decimals()
            })
        ); 

        // Now load pools
        // All tokens have the same decimals - 18
        // For USDC -> USDT/DEI LP
        poolList.push(
            PoolInfo({
                token0: IERC20(address(0x55d398326f99059fF775485246999027B3197955)), // USDT
                token1: IERC20(address(0xDE1E704dae0B4051e80DAbB26ab6ad6c12262DA0)), // DEI
                pancakeStableRouterAddress: address(0x3EFebC418efB585248A0D2140cfb87aFcc2C63DD), // USDC <> USDT Pancake StableSwap
                usdcIndex: 1,
                stableIndex: 0,
                stableAddress: address(0x55d398326f99059fF775485246999027B3197955), // Also USDT
                lpToken: IERC20(address(0x5929dbBc11711D2B9e9ca0752393C70De74261F5)),
                rewardPoolAddress: address(0x1520D103D8B366C87A0b273E68a56B5f804c1947) // Gauge/Reward pool for LP
            })
        );

        // For USDC -> BUSD/HAY LP
        poolList.push(
            PoolInfo({
                token0: IERC20(address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56)), // BUSD
                token1: IERC20(address(0x0782b6d8c4551B9760e74c0545a9bCD90bdc41E5)), // HAY
                pancakeStableRouterAddress: address(0xc2F5B9a3d9138ab2B74d581fC11346219eBf43Fe), // USDC <> BUSD Pancake StableSwap
                usdcIndex: 0,
                stableIndex: 1,
                stableAddress: address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56), // Also BUSD
                lpToken: IERC20(address(0x93B32a8dfE10e9196403dd111974E325219aec24)),
                rewardPoolAddress: address(0xE43317c1f037CBbaF33F33C386f2cAF2B6b25C9C) // Gauge/Reward pool for LP
            })
        );

        // For USDC -> USDT -> FRAX/MAI LP
        poolList.push(
            PoolInfo({
                token0: IERC20(address(0x90C97F71E18723b0Cf0dfa30ee176Ab653E89F40)), // FRAX
                token1: IERC20(address(0x3F56e0c36d275367b8C502090EDF38289b3dEa0d)), // MAI
                pancakeStableRouterAddress: address(0x3EFebC418efB585248A0D2140cfb87aFcc2C63DD), // USDC <> USDT Pancake StableSwap
                usdcIndex: 1,
                stableIndex: 0,
                stableAddress: address(0x55d398326f99059fF775485246999027B3197955), // USDT
                lpToken: IERC20(address(0x49ad051F4263517BD7204f75123b7C11aF9Fd31C)),
                rewardPoolAddress: address(0x556B0b722CC72369CEA0Ea9c4726a71Fb2D1772d) // Gauge/Reward pool for LP
            })
        );
    }
    
    // Modifier
    modifier onlyZSBToken() {
        require(zsbTokenAddress == _msgSender(), "Call not sent from the zsb-Token");
        _;
    }
    
    // Read functions
    
    function rewardTokensCount() external view returns (uint256) {
        return tokenList.length;
    }
    
    function rewardTokenAddress(uint256 _pos) external view returns (address) {
        require(_pos < tokenList.length,"No token at that position");
        return address(tokenList[_pos].token);
    }
    
    function balance() public view returns (uint256) {
        return getNormalizedTotalBalance();
    }
    
    function getNormalizedTotalBalance() public view returns (uint256) {
        // Get the balance of the tokens at this address
        uint256 _balance = 0; // This is of USDC balance and equivalanet
        _balance = tokenList[0].token.balanceOf(address(this));
        _balance = _balance.add(calculateUSDCEquivalent(currentPool));
        return _balance;
    }

    function calculateTokenStaked(uint256 pool) internal view returns (uint256, uint256) {
        ThenaStaker staker = ThenaStaker(poolList[pool].rewardPoolAddress);
        uint256 _bal = staker.balanceOf(address(this));
        if(_bal == 0){ return (0, 0); }
        uint256 token0Amount = _bal.mul(poolList[pool].token0.balanceOf(address(poolList[pool].lpToken))).div(poolList[pool].lpToken.totalSupply());
        uint256 token1Amount = _bal.mul(poolList[pool].token1.balanceOf(address(poolList[pool].lpToken))).div(poolList[pool].lpToken.totalSupply());
        return (token0Amount, token1Amount);
    }

    function estimatedFutureTWAP(uint256 token0Amount, uint256 token1Amount, uint256 pool) internal view returns (uint256, uint256) {
        (uint256 price0, uint256 price1) = calculateSpotPrices(token0Amount, token1Amount, pool);
        if(block.timestamp > lastTokenPriceUpdateTime.add(minTokenPriceUpdateTime)){
            // Fake update the twap
            price0 = twapToken0Price.mul(DIVISION_FACTOR.sub(percentSpotPriceWeight)).div(DIVISION_FACTOR) + price0.mul(percentSpotPriceWeight).div(DIVISION_FACTOR);
            price1 = twapToken1Price.mul(DIVISION_FACTOR.sub(percentSpotPriceWeight)).div(DIVISION_FACTOR) + price1.mul(percentSpotPriceWeight).div(DIVISION_FACTOR);
        }else{
            // Use only the twap price
            price0 = twapToken0Price;
            price1 = twapToken1Price;
        }
        return (price0, price1);
    }

    function calculateUSDCEquivalent(uint256 pool) internal view returns (uint256) {
        (uint256 token0Amount, uint256 token1Amount) = calculateTokenStaked(pool);
        token0Amount = token0Amount.add(poolList[pool].token0.balanceOf(address(this))); // Incase there are loose token here
        token1Amount = token1Amount.add(poolList[pool].token1.balanceOf(address(this))); // Incase there are loose token here
        (uint256 price0, uint256 price1) = estimatedFutureTWAP(token0Amount, token1Amount, pool);
        uint256 _bal = token0Amount.mul(price0).div(1e18);
        _bal = _bal.add(token1Amount.mul(price1).div(1e18));
        return _bal;
    }

    function calculateCurveReturn(uint256 pool, uint256 startIndex, uint256 endIndex, uint256 amount) internal view returns (uint256) {
        CurveLikeExchange curve = CurveLikeExchange(poolList[pool].pancakeStableRouterAddress);
        return curve.get_dy(startIndex, endIndex, amount);
    }

    function calculateSingleSolidlyReturn(address inputAddress, address outputAddress, bool stable, uint256 _amount) internal view returns (uint256) {
        SolidlyRouter router = SolidlyRouter(THENA_ROUTER);
        SolidlyRouter.route[] memory spath;
        spath = new SolidlyRouter.route[](1);
        spath[0].from = inputAddress; // FRAX
        spath[0].to = outputAddress; // USDT
        spath[0].stable = stable;
        uint256[] memory estimates = router.getAmountsOut(_amount, spath);
        return estimates[estimates.length - 1];
    }

    function calculateSpotPrices(uint256 token0Amount, uint256 token1Amount, uint256 pool) public view returns (uint256, uint256) {
        if(token0Amount == 0){
            // In case we don't have a pool size to use
            token0Amount = 1000e18;
            token1Amount = 1000e18;
        }
        if(pool != 2){
            // Calculate swap Token 0 to USDC
            uint256 amount = calculateCurveReturn(pool, poolList[pool].stableIndex, poolList[pool].usdcIndex, token0Amount); // USDC output
            uint256 spot0 = amount.mul(1e18).div(token0Amount);

            // Calculate swap Token 1 to USDC
            amount = calculateSingleSolidlyReturn(address(poolList[pool].token1), address(poolList[pool].token0), true, token1Amount);
            amount = calculateCurveReturn(pool, poolList[pool].stableIndex, poolList[pool].usdcIndex, amount); // USDC output
            uint256 spot1 = amount.mul(1e18).div(token1Amount);
            return (spot0, spot1);
        }else{
            // This pool has an extra step
            // Calculate swap Token 0 to USDC
            uint256 amount = calculateSingleSolidlyReturn(address(poolList[pool].token0), address(poolList[pool].stableAddress), true, token0Amount);

            amount = calculateCurveReturn(pool, poolList[pool].stableIndex, poolList[pool].usdcIndex, amount); // USDT -> USDC output
            uint256 spot0 = amount.mul(1e18).div(token0Amount);

            // Calculate swap Token 1 to USDC
            amount = calculateSingleSolidlyReturn(address(poolList[pool].token1), address(poolList[pool].token0), true, token1Amount);
            amount = calculateSingleSolidlyReturn(address(poolList[pool].token0), address(poolList[pool].stableAddress), true, amount);

            amount = calculateCurveReturn(pool, poolList[pool].stableIndex, poolList[pool].usdcIndex, amount); // USDT -> USDC output
            uint256 spot1 = amount.mul(1e18).div(token1Amount);
            return (spot0, spot1);
        }
    }
    
    function withdrawTokenReserves() public view returns (address, uint256) {
        // This function will return the address and amount of the token with the highest balance
        uint256 _bal = balance();
        if(_bal == 0){
            return (address(0), _bal);
        }else{
            return (address(tokenList[0].token), _bal);
        }
    }
    
    // Write functions
    
    function enter() external onlyZSBToken {
        deposit(false);
    }
    
    function exit() external onlyZSBToken {
        // The ZS token vault is removing all tokens from this strategy
        withdraw(_msgSender(),1,1, false);
    }

    function updateTWAPPrice() internal {
        ThenaStaker staker = ThenaStaker(poolList[currentPool].rewardPoolAddress);
        uint256 _bal = staker.balanceOf(address(this));
        uint256 token0Amount = 0;
        uint256 token1Amount = 0;
        if(_bal > 0){
            token0Amount = _bal.mul(poolList[currentPool].token0.balanceOf(address(poolList[currentPool].lpToken))).div(poolList[currentPool].lpToken.totalSupply());
            token1Amount = _bal.mul(poolList[currentPool].token1.balanceOf(address(poolList[currentPool].lpToken))).div(poolList[currentPool].lpToken.totalSupply());
        }
        (uint256 price0, uint256 price1) = calculateSpotPrices(token0Amount, token1Amount, currentPool);
        if(block.timestamp > lastTokenPriceUpdateTime.add(minTokenPriceUpdateTime)){
            // Update the twap
            twapToken0Price = twapToken0Price.mul(DIVISION_FACTOR.sub(percentSpotPriceWeight)).div(DIVISION_FACTOR) + price0.mul(percentSpotPriceWeight).div(DIVISION_FACTOR);
            twapToken1Price = twapToken1Price.mul(DIVISION_FACTOR.sub(percentSpotPriceWeight)).div(DIVISION_FACTOR) + price1.mul(percentSpotPriceWeight).div(DIVISION_FACTOR);
            lastTokenPriceUpdateTime = block.timestamp;
        }
    }
    
    function deposit(bool nonContract) public onlyZSBToken {
        require(emergencyWithdrawMode == false, "Cannot deposit in emergency mode");
        updateTWAPPrice();
        // Only the ZS token can call the function
        
        // No trading is performed on deposit
        if(nonContract == true){
            wrapUSDC(); // Whatever USDC is deposited will be added to the LP pool and staked
        }
        lastActionBalance = balance(); // This action balance represents pool post deposit
    }
    
    function withdraw(address _depositor, uint256 _share, uint256 _total, bool nonContract) public onlyZSBToken returns (uint256) {
        require(balance() > 0, "There are no tokens in this strategy");
        updateTWAPPrice();
        if(nonContract == true){
            harvestRewards(); // This will claim rewards then sell THENA for USDC and some for WBNB
        }

        uint256 _usdcBal = tokenList[0].token.balanceOf(address(this));
        uint256 withdrawAmount = 0;
        uint256 _balance = balance();
        if(_share < _total){
            uint256 _myBalance = _balance.mul(_share).div(_total);
            if(_myBalance > _usdcBal){
                uint256 overage = _myBalance.sub(_usdcBal);
                // We need to unstake to get more USDC as free tokens are not enough
                unwrapUSDC(false, overage);
            }
            withdrawOne(_depositor, _myBalance, false); // This will withdraw based on token balance
            withdrawAmount = _myBalance;
            if(_myBalance > _usdcBal){
                wrapUSDC(); // Whatever USDC is deposited will be added to the LP pool and staked
            }
        }else{
            // We are all shares, transfer all, no need to restake
            unwrapUSDC(true, 0);
            withdrawOne(_depositor, _balance, true);
            withdrawAmount = _balance;
        }
        lastActionBalance = balance();
        
        return withdrawAmount;
    }
    
    // This will withdraw the tokens from the contract based on their balance, from highest balance to lowest
    function withdrawOne(address _receiver, uint256 _withdrawAmount, bool _takeAll) internal {
        if(_takeAll == true){
            // Send the entire balance
            uint256 _bal = tokenList[0].token.balanceOf(address(this));
            if(_bal > 0){
                tokenList[0].token.safeTransfer(_receiver, _bal);
            }
            return;
        }

        // Determine the balance left
        uint256 _normalizedBalance = tokenList[0].token.balanceOf(address(this)).mul(1e18).div(10**tokenList[0].decimals);
        if(_normalizedBalance <= _withdrawAmount){
            // Withdraw the entire balance of this token
            if(_normalizedBalance > 0){
                _withdrawAmount = _withdrawAmount.sub(_normalizedBalance);
                tokenList[0].token.safeTransfer(_receiver, tokenList[0].token.balanceOf(address(this)));                    
            }
        }else{
            // Withdraw a partial amount of this token
            if(_withdrawAmount > 0){
                // Convert the withdraw amount to the token's decimal amount
                uint256 _balance = _withdrawAmount.mul(10**tokenList[0].decimals).div(1e18);
                _withdrawAmount = 0;
                tokenList[0].token.safeTransfer(_receiver, _balance);
            }
        }
    }
    
    // Test functions
    /*
    function testDeposit() external payable {
        // Must interface: function swapExactETHForTokens(uint, address[] calldata, address, uint) external payable returns (uint[] memory);
        address[] memory path;
        TradeRouter router = TradeRouter(PANCAKE_ROUTER);
        path = new address[](2);
        path[0] = WBNB_ADDRESS;
        path[1] = address(tokenList[0].token);
        router.swapExactETHForTokens{value: msg.value}(1, path, address(this), now.add(60));
        harvestRewards();
    }
    */

    function wrapUSDC() internal {
        // Takes USDC and adds it to the pools
        uint256 _bal = tokenList[0].token.balanceOf(address(this));
        if(_bal == 0){ return; } // Nothing to do
        if(twapToken0Price < minTWAPPriceAllowed || twapToken1Price < minTWAPPriceAllowed) { return; }
        if(currentPool != 2){
            // Swap USDC to token0
            uint256 expectedOutput = _bal.mul(1e18).div(twapToken0Price).mul(DIVISION_FACTOR.sub(tokenSlippageAllowed)).div(DIVISION_FACTOR);
            swapViaCurveLike(poolList[currentPool].usdcIndex, poolList[currentPool].stableIndex, _bal, expectedOutput);
        }else{
            // Swap USDC to USDT then token0
            uint256 expectedOutput = _bal.mul(DIVISION_FACTOR.sub(tokenSlippageAllowed)).div(DIVISION_FACTOR);
            swapViaCurveLike(poolList[currentPool].usdcIndex, poolList[currentPool].stableIndex, _bal, expectedOutput);
            _bal = IERC20(address(poolList[currentPool].stableAddress)).balanceOf(address(this));

            expectedOutput = _bal.mul(1e18).div(twapToken0Price).mul(DIVISION_FACTOR.sub(tokenSlippageAllowed)).div(DIVISION_FACTOR);
            swapSingleViaSolidly(address(poolList[currentPool].stableAddress), address(poolList[currentPool].token0), true, _bal, expectedOutput);
        }

        // Now we have token0 only, convert some of it to token 1
        {
            uint256 amount = poolList[currentPool].token0.balanceOf(address(this));
            address lpPoolAddress = address(poolList[currentPool].lpToken);
            // Get pool ratios
            uint256 ratio = poolList[currentPool].token0.balanceOf(lpPoolAddress).mul(DIVISION_FACTOR).div(poolList[currentPool].token1.balanceOf(lpPoolAddress).add(poolList[currentPool].token0.balanceOf(lpPoolAddress)));
            ratio = DIVISION_FACTOR.sub(ratio); // This helps keep amount of tokens added as liquidity high
            uint256 sellAmount = amount.mul(ratio).div(DIVISION_FACTOR);

            // This is the amount of token0 we will sell to make even
            uint256 expectedOutput = sellAmount.mul(1e18).div(twapToken1Price).mul(DIVISION_FACTOR.sub(tokenSlippageAllowed)).div(DIVISION_FACTOR);
            swapSingleViaSolidly(address(poolList[currentPool].token0), address(poolList[currentPool].token1), true, sellAmount, expectedOutput);
        }

        {
            // Now add liquidity
            SolidlyRouter thenaRouter = SolidlyRouter(THENA_ROUTER);
            poolList[currentPool].token0.safeApprove(address(thenaRouter), 0);
            poolList[currentPool].token0.safeApprove(address(thenaRouter), poolList[currentPool].token0.balanceOf(address(this)));
            poolList[currentPool].token1.safeApprove(address(thenaRouter), 0);
            poolList[currentPool].token1.safeApprove(address(thenaRouter), poolList[currentPool].token1.balanceOf(address(this)));
            thenaRouter.addLiquidity(address(poolList[currentPool].token0), address(poolList[currentPool].token1), true, poolList[currentPool].token0.balanceOf(address(this)), poolList[currentPool].token1.balanceOf(address(this)), 1, 1, address(this), block.timestamp.add(60));
        }

        {
            // Now stake the LP, and leave the leftover tokens in the contract
            ThenaStaker staker = ThenaStaker(poolList[currentPool].rewardPoolAddress);
            _bal = poolList[currentPool].lpToken.balanceOf(address(this));
            if(_bal > 0){
                poolList[currentPool].lpToken.safeApprove(address(staker), 0);
                poolList[currentPool].lpToken.safeApprove(address(staker), _bal);
                staker.depositAll();
            }
        }
    }

    function unwrapUSDC(bool takeAll, uint256 _amountUSDCNeeded) internal {
        uint256 sellAmountLooseToken0 = 0;
        uint256 sellAmountLooseToken1 = 0;
        uint256 sellProportionStaked = 0;
        if(takeAll == false){
            uint256 usdcAmount = _amountUSDCNeeded;
            // Strat will attempt to sell only what would be the lowest fee, loose token0, then loose token1, then a proportion of staked tokens
            if(usdcAmount > poolList[currentPool].token0.balanceOf(address(this)).mul(twapToken0Price).div(1e18)){
                // First sell token0
                sellAmountLooseToken0 = poolList[currentPool].token0.balanceOf(address(this));
                usdcAmount = usdcAmount.sub(poolList[currentPool].token0.balanceOf(address(this)).mul(twapToken0Price).div(1e18));
                if(usdcAmount > poolList[currentPool].token1.balanceOf(address(this)).mul(twapToken1Price).div(1e18)){
                    // Then sell token1
                    sellAmountLooseToken1 = poolList[currentPool].token1.balanceOf(address(this));
                    usdcAmount = usdcAmount.sub(poolList[currentPool].token1.balanceOf(address(this)).mul(twapToken1Price).div(1e18));

                    // Get the USDC amount staked, we will sell a proportion of it
                    (uint256 token0AmountStaked, uint256 token1AmountStaked) = calculateTokenStaked(currentPool);
                    uint256 stakedUSDC = token0AmountStaked.mul(twapToken0Price).div(1e18);
                    stakedUSDC = stakedUSDC.add(token1AmountStaked.mul(twapToken1Price).div(1e18));
                    require(stakedUSDC > 0, "This shouldn't happen");
                    sellProportionStaked = usdcAmount.mul(DIVISION_FACTOR).div(stakedUSDC);

                }else{
                    sellAmountLooseToken1 = usdcAmount.mul(1e18).div(twapToken1Price);
                }
            }else{
                sellAmountLooseToken0 = usdcAmount.mul(1e18).div(twapToken0Price);
                // We only need to sell this
            }
        }else{
            sellProportionStaked = DIVISION_FACTOR;
        }

        if(sellProportionStaked > 0){
            // Remove some LP and sell it for USDC
            ThenaStaker staker = ThenaStaker(poolList[currentPool].rewardPoolAddress);
            uint256 _bal = staker.balanceOf(address(this));
            if(_bal > 0){
                if(sellProportionStaked < DIVISION_FACTOR){
                    _bal = _bal.mul(sellProportionStaked).div(DIVISION_FACTOR);
                }
                staker.withdraw(_bal);

                // Now remove liquidity with router
                SolidlyRouter thenaRouter = SolidlyRouter(THENA_ROUTER);
                poolList[currentPool].lpToken.safeApprove(address(thenaRouter), 0);
                poolList[currentPool].lpToken.safeApprove(address(thenaRouter), _bal);
                thenaRouter.removeLiquidity(address(poolList[currentPool].token0), address(poolList[currentPool].token1), true, _bal, 1, 1, address(this), block.timestamp.add(60));
                // Will return token0 and token 1
            }
        }

        if(sellAmountLooseToken1 > 0 || sellProportionStaked > 0){
            // Sell token1 for token0
            if(sellProportionStaked > 0){
                sellAmountLooseToken1 = poolList[currentPool].token1.balanceOf(address(this)); // Sell the entire balance
            }
            if(sellAmountLooseToken1 > poolList[currentPool].token1.balanceOf(address(this))){
                sellAmountLooseToken1 = poolList[currentPool].token1.balanceOf(address(this)); // For any weird rounding issues
            }
            if(sellAmountLooseToken1 > 0){
                uint256 expectedOutput = sellAmountLooseToken1.mul(1e18).div(twapToken1Price).mul(DIVISION_FACTOR.sub(tokenSlippageAllowed)).div(DIVISION_FACTOR);
                swapSingleViaSolidly(address(poolList[currentPool].token1), address(poolList[currentPool].token0), true, sellAmountLooseToken1, expectedOutput);
            }
        }

        if(sellAmountLooseToken0 > 0 || sellProportionStaked > 0 || sellAmountLooseToken1 > 0){
            // Sell token0 for USDC
            if(sellProportionStaked > 0 || sellAmountLooseToken1 > 0){
                sellAmountLooseToken0 = poolList[currentPool].token0.balanceOf(address(this)); // Sell the entire balance
            }
            if(sellAmountLooseToken0 > poolList[currentPool].token0.balanceOf(address(this))){
                sellAmountLooseToken0 = poolList[currentPool].token0.balanceOf(address(this)); // For any weird rounding issues
            }
            if(sellAmountLooseToken0 > 0){
                if(currentPool != 2){
                    uint256 expectedOutput = sellAmountLooseToken0.mul(1e18).div(twapToken0Price).mul(DIVISION_FACTOR.sub(tokenSlippageAllowed)).div(DIVISION_FACTOR);
                    swapViaCurveLike(poolList[currentPool].stableIndex, poolList[currentPool].usdcIndex, sellAmountLooseToken0, expectedOutput);
                }else{
                    uint256 expectedOutput = sellAmountLooseToken0.mul(1e18).div(twapToken0Price).mul(DIVISION_FACTOR.sub(tokenSlippageAllowed)).div(DIVISION_FACTOR);
                    swapSingleViaSolidly(address(poolList[currentPool].token0), address(poolList[currentPool].stableAddress), true, sellAmountLooseToken0, expectedOutput);
                    uint256 _bal = IERC20(poolList[currentPool].stableAddress).balanceOf(address(this));
                
                    expectedOutput = _bal.mul(DIVISION_FACTOR.sub(tokenSlippageAllowed)).div(DIVISION_FACTOR);
                    swapViaCurveLike(poolList[currentPool].stableIndex, poolList[currentPool].usdcIndex, _bal, expectedOutput);
                }
            }
        }
    }

    function swapSingleViaSolidly(address inputAddress, address outputAddress, bool stable, uint256 _amount, uint256 _minAmount) internal returns (uint256){
        SolidlyRouter router = SolidlyRouter(THENA_ROUTER);
        SolidlyRouter.route[] memory spath;
        spath = new SolidlyRouter.route[](1);
        spath[0].from = inputAddress;
        spath[0].to = outputAddress;
        spath[0].stable = stable;
        IERC20(inputAddress).safeApprove(address(router), 0);
        IERC20(inputAddress).safeApprove(address(router), _amount);
        uint256 _bal = IERC20(outputAddress).balanceOf(address(this));
        router.swapExactTokensForTokens(_amount, _minAmount, spath, address(this), block.timestamp.add(60));
        return IERC20(outputAddress).balanceOf(address(this)).sub(_bal);
    }

    function swapViaCurveLike(uint256 startIndex, uint256 endIndex, uint256 amount, uint256 minAmount) internal returns (uint256){
        CurveLikeExchange curve = CurveLikeExchange(address(poolList[currentPool].pancakeStableRouterAddress));
        address startToken = curve.coins(startIndex);
        address endToken = curve.coins(endIndex);
        IERC20(startToken).safeApprove(address(curve), 0);
        IERC20(startToken).safeApprove(address(curve), amount);
        uint256 _bal = IERC20(endToken).balanceOf(address(this));
        curve.exchange(startIndex, endIndex, amount, minAmount);
        return IERC20(endToken).balanceOf(address(this)).sub(_bal);
    }

    function checkHarvestWBNB() internal view returns (uint256) {
        // Returns the amount of WBNB returned from liquidating the rewards
        IERC20 the = IERC20(THENA_ADDRESS);
        uint256 rewards = the.balanceOf(address(this)); // Get any stored THENA
        ThenaStaker staker = ThenaStaker(poolList[currentPool].rewardPoolAddress);
        rewards = rewards.add(staker.earned(address(this)));

        rewards = rewards.mul(DIVISION_FACTOR.sub(percentStakeDepositor)).div(DIVISION_FACTOR); // Only a certain part goes to executors/treasury/STBB
        if(rewards == 0){return 0;}

        // THE -> BNB
        return calculateSingleSolidlyReturn(THENA_ADDRESS, WBNB_ADDRESS, false, rewards);
    }

    function harvestRewards() internal {
        // This will liquidate rewards to WBNB, and convert some WBNB to USDC
        ThenaStaker staker = ThenaStaker(poolList[currentPool].rewardPoolAddress);
        if(staker.earned(address(this)) > 0){
            staker.claimFees();
            staker.getReward();
        }
        
        // Convert THENA to WBNB
        uint256 _bal = IERC20(THENA_ADDRESS).balanceOf(address(this));
        if(_bal > 0){
            _bal = swapSingleViaSolidly(THENA_ADDRESS, WBNB_ADDRESS, false, _bal, 1);

            if(_bal > 0){
                // Convert some WBNB to USDC via pancake
                TradeRouter router = TradeRouter(PANCAKE_ROUTER);
                _bal = _bal.mul(percentStakeDepositor).div(DIVISION_FACTOR);
                address[] memory path = new address[](2);
                path[0] = WBNB_ADDRESS;
                path[1] = address(tokenList[0].token);
                IERC20(path[0]).safeApprove(address(router), 0);
                IERC20(path[0]).safeApprove(address(router), _bal);
                router.swapExactTokensForTokens(_bal, 1, path, address(this), block.timestamp.add(60));
            }
        }
    }
    
    function checkAndSwapToken(address _executor) internal {
        updateTWAPPrice();
        lastTradeTime = now;

        harvestRewards(); // Will generate more USDC and WBNB

        if(twapToken0Price < minTWAPPriceAllowed || twapToken1Price < minTWAPPriceAllowed){
            // Token price has dropped too far
            unwrapUSDC(true, 0);
            if(_executor != address(0)){
                // Calculate USDC needed to fulfill stipend
                TradeRouter router = TradeRouter(PANCAKE_ROUTER);
                address[] memory path = new address[](2);
                path[0] = address(tokenList[0].token);
                path[1] = WBNB_ADDRESS;
                uint256[] memory estimates;
                estimates = router.getAmountsIn(gasStipend.mul(gasPrice), path);
                uint256 usdcSellAmount = estimates[0];

                if(usdcSellAmount < tokenList[0].token.balanceOf(address(this))){
                    // We have enough, send it!
                    tokenList[0].token.safeApprove(address(router), 0);
                    tokenList[0].token.safeApprove(address(router), usdcSellAmount);
                    router.swapExactTokensForTokens(usdcSellAmount, 1, path, address(this), now.add(60)); // Get WBNB
                    IERC20(WBNB_ADDRESS).safeTransfer(_executor, IERC20(WBNB_ADDRESS).balanceOf(address(this)));
                }
            }
            minTWAPPriceAllowed = 1e18; // Prevent redeposits
            return;
        }

        uint256 _bal = tokenList[0].token.balanceOf(address(this));
        if(_bal > 0){
            // Restake the USDC
            wrapUSDC();
        }
        
        // Now take some gain wbnb and distribute it to executor, stakers and treasury
        IERC20 bnb = IERC20(WBNB_ADDRESS);
        uint256 bnbBalance = bnb.balanceOf(address(this));
        if(bnbBalance > 0){
            // This is pure profit, figure out allocation
            // Split the amount sent to the treasury, stakers and executor if one exists
            if(_executor != address(0)){
                uint256 executorAmount = bnbBalance.mul(percentExecutor).div(DIVISION_FACTOR);
                if(executorAmount > 0){
                    bnb.safeTransfer(_executor, executorAmount);
                    bnbBalance = bnb.balanceOf(address(this)); // Recalculate BNB in contract           
                }
            }
            if(bnbBalance > 0){
                uint256 stakersAmount = bnbBalance.mul(percentStakers).div(DIVISION_FACTOR);
                uint256 treasuryAmount = bnbBalance.sub(stakersAmount);
                if(treasuryAmount > 0){
                    bnb.safeTransfer(treasuryAddress, treasuryAmount);
                }
                if(stakersAmount > 0){
                    bool sendToStaking = true;
                    if(zsbTokenAddress == address(0)){
                        // No staking pool exists
                        sendToStaking = false;
                    }else{
                        // Staking pool exists
                        if(StabilizeStakingPool(zsbTokenAddress).getTotalSTBB() == 0 || StabilizeStakingPool(zsbTokenAddress).getCurrentStrategy() != address(this)){
                            // There are no tokens at the staking pool or this strategy cannot send tokens to the token vault
                            sendToStaking = false;
                        }
                    }
                    if(sendToStaking == true){
                        bnb.safeTransfer(zsbTokenAddress, stakersAmount);
                        StabilizeStakingPool(zsbTokenAddress).notifyRewardAmount(stakersAmount);                                
                    }else{
                        bnb.safeTransfer(treasuryAddress, stakersAmount);
                    }
                }
            }
        }
    }
    
    function expectedProfit(
        address _executor, // User's address
        uint256 seed // Seed number
        ) external view returns (
        uint256, // Profit in WBNB
        uint256, // Block with profit
        bytes32 // Encoded executor code
        ) {
        
        uint256 wbnbGain = IERC20(WBNB_ADDRESS).balanceOf(address(this));
        wbnbGain = wbnbGain.add(checkHarvestWBNB());

        bytes32 code = generateExecutorCode(_executor, seed);

        // Now calculate the amount going to the executor
        (uint256 token0Amount, uint256 token1Amount) = calculateTokenStaked(currentPool);
        (uint256 price0, uint256 price1) = estimatedFutureTWAP(token0Amount, token1Amount, currentPool);
        if(price0 < minTWAPPriceAllowed || price1 < minTWAPPriceAllowed){
            // Emergency exit
            return (gasStipend.mul(gasPrice), block.number, code);
        }else{
            return (wbnbGain.mul(percentExecutor).div(DIVISION_FACTOR), block.number, code);
        }
    }

    // Frontrun deterrants
    function generateExecutorCode(address _executor, uint256 seed) internal pure returns (bytes32) {
        bytes memory data = abi.encode(_executor, seed);
        return keccak256(data);
    }

    function checkExecutorCode(address _executor, uint256 seed, bytes32 code) internal pure {
        bytes32 genCode = generateExecutorCode(_executor, seed);
        require(genCode == code, "Executor code is invalid");
    }
    
    function executorSwapTokens(
        address _executor, // User receiving the profit
        uint256 _seed, // Seed used to generate code
        bytes32 code, // Code
        uint256 _minSecSinceLastTrade, // Cancel if within some other transaction block
        uint256 _deadlineBlock
        ) external {
        checkExecutorCode(_executor, _seed, code);
        require(block.number <= _deadlineBlock, "Deadline has expired, aborting trade");
        // Function designed to promote trading with incentive. Users get percentage of WBNB from profitable trades
        require(now.sub(lastTradeTime) >= _minSecSinceLastTrade, "The last trade was too recent");
        require(_msgSender() == tx.origin, "Contracts cannot interact with this function");
        checkAndSwapToken(_executor);
    }
    
    // Governance functions
    function governanceSwapTokens() external onlyGovernance {
        // This is function that force trade tokens at anytime. It can only be called by governance
        checkAndSwapToken(_msgSender());
    }
    
    // Change the trading conditions used by the strategy without timelock
    // --------------------
    function changeStrategyConditions(
        uint256 _minPriceUpdateTime,
        uint256 _percentSpot,
        uint256 _SlipAllowed,
        uint256 _minTWAP,
        uint256 _stipend,
        uint256 _gasPrice
        ) external onlyGovernance {
        // Changes a lot of trading parameters in one call
        minTokenPriceUpdateTime = _minPriceUpdateTime;
        percentSpotPriceWeight = _percentSpot;
        tokenSlippageAllowed = _SlipAllowed;
        minTWAPPriceAllowed = _minTWAP;
        gasStipend = _stipend;
        gasPrice = _gasPrice;
    }

    function changeCurrentPool(uint256 _pool, uint256 spot0Price, uint256 spot1Price) external onlyGovernance {
        updateTWAPPrice();
        unwrapUSDC(true, 0);
        twapToken0Price = spot0Price;
        twapToken1Price = spot1Price;
        lastTokenPriceUpdateTime = block.timestamp;
        currentPool = _pool;
        wrapUSDC();
    }

    // This function is used in case tokens get stuck in strategy, it is used for experimental strategies to prevent any-cause loss of funds
    function governanceEmergencyWithdrawToken(address _token, uint256 _amount) external onlyGovernance {
        require(emergencyWithdrawMode == true, "Cannot withdraw in normal mode");
        IERC20(_token).safeTransfer(governance(), _amount);
    }
    
    // Timelock variables
    
    uint256 private _timelockStart; // The start of the timelock to change governance variables
    uint256 private _timelockType; // The function that needs to be changed
    uint256 constant TIMELOCK_DURATION = 86400; // Timelock is 24 hours
    
    // Reusable timelock variables
    address private _timelock_address;
    uint256[4] private _timelock_data;
    
    modifier timelockConditionsMet(uint256 _type) {
        require(_timelockType == _type, "Timelock not acquired for this function");
        _timelockType = 0; // Reset the type once the timelock is used
        if(balance() > 0){ // Timelock only applies when balance exists
            require(now >= _timelockStart + TIMELOCK_DURATION, "Timelock time not met");
        }
        _;
    }
    
    // Change the owner of the token contract
    // --------------------
    function startGovernanceChange(address _address) external onlyGovernance {
        _timelockStart = now;
        _timelockType = 1;
        _timelock_address = _address;       
    }
    
    function finishGovernanceChange() external onlyGovernance timelockConditionsMet(1) {
        transferGovernance(_timelock_address);
    }
    // --------------------
    
    // Change the treasury address
    // --------------------
    function startChangeTreasury(address _address) external onlyGovernance {
        _timelockStart = now;
        _timelockType = 2;
        _timelock_address = _address;
    }
    
    function finishChangeTreasury() external onlyGovernance timelockConditionsMet(2) {
        treasuryAddress = _timelock_address;
    }
    // --------------------
    
    // Change the zsbToken address
    // --------------------
    function startChangeZSBToken(address _address) external onlyGovernance {
        _timelockStart = now;
        _timelockType = 3;
        _timelock_address = _address;
    }
    
    function finishChangeZSBToken() external onlyGovernance timelockConditionsMet(3) {
        zsbTokenAddress = _timelock_address;
    }
    // --------------------
    
    // Change the strategy allocations between the parties
    // --------------------
    
    function startChangeStrategyAllocations(uint256 _pSDepositors, uint256 _pStakers, uint256 _pExecutor) external onlyGovernance {
        // Changes strategy allocations in one call
        _timelockStart = now;
        _timelockType = 4;
        _timelock_data[0] = _pSDepositors;
        _timelock_data[1] = _pExecutor;
        _timelock_data[2] = _pStakers;
    }
    
    function finishChangeStrategyAllocations() external onlyGovernance timelockConditionsMet(4) {
        percentExecutor = _timelock_data[1];
        percentStakers = _timelock_data[2];
        percentStakeDepositor = _timelock_data[0];
    }
    // --------------------
    
    // Going into emergency withdraw mode
    // --------------------
    function startActivateEmergencyWithdrawMode() external onlyGovernance {
        _timelockStart = now;
        _timelockType = 5;
    }
    
    function finishActivateEmergencyWithdrawMode() external onlyGovernance timelockConditionsMet(5) {
        unwrapUSDC(true, 0);
        emergencyWithdrawMode = true;
    }
    // --------------------
    
}