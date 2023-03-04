/**
 *Submitted for verification at BscScan.com on 2023-03-04
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

// File: contracts/strategies/BUSDStrategyDforceV3.sol

pragma solidity =0.6.6;

interface StabilizeStakingPool {
    function notifyRewardAmount(uint256) external;
    function getTotalSTBB() external view returns (uint256);
    function getCurrentStrategy() external view returns (address);
}

interface TradeRouter {
    function swapExactETHForTokens(uint, address[] calldata, address, uint) external payable returns (uint[] memory);
    function swapExactTokensForTokens(uint, uint, address[] calldata, address, uint) external returns (uint[] memory);
    function getAmountsOut(uint, address[] calldata) external view returns (uint[] memory); // For a value in, it calculates value out
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface DodoRouter{
    function dodoSwapV2TokenToToken(
        address fromToken,
        address toToken,
        uint256 fromTokenAmount,
        uint256 minReturnAmount,
        address[] calldata dodoPairs,
        uint256 directions,
        bool isIncentive,
        uint256 deadLine
    ) external returns (uint256 returnAmount);
    function _DODO_APPROVE_PROXY_() external view returns (address);
}

interface DodoLiquidityRouter{
    function addDSPLiquidity(
        address dspAddress,
        uint256 baseInAmount,
        uint256 quoteInAmount,
        uint256 baseMinAmount,
        uint256 quoteMinAmount,
        uint8 flag, // 0 - ERC20, 1 - baseInETH, 2 - quoteInETH
        uint256 deadLine
    )
        external
        returns (
            uint256 shares,
            uint256 baseAdjustedInAmount,
            uint256 quoteAdjustedInAmount
        );
}

interface DodoPool{
    function getVaultReserve() external view returns (uint256 baseReserve, uint256 quoteReserve);
    function totalSupply() external view returns (uint256);
    function sellShares(
        uint256 shareAmount,
        address to,
        uint256 baseMinAmount,
        uint256 quoteMinAmount,
        bytes calldata data,
        uint256 deadline
    ) external returns (uint256 baseAmount, uint256 quoteAmount);
    function _BASE_TOKEN_() external view returns (address);
}

interface DodoApproveProxy{
    function _DODO_APPROVE_() external view returns (address);
}

interface DForceController{
    function hasEnteredMarket(address _account, address _iToken) external view returns (bool);
    function enterMarkets(address[] calldata _iTokens) external returns (bool[] memory _results);
    function claimRewards(address[] calldata _holders, address[] calldata _suppliediTokens, address[] calldata _borrowediTokens) external;
    function updateReward(address _iToken, address account, bool isBorrow) external;
    function reward(address _account) external view returns (uint256);
    function calcAccountEquity(address _account) external view returns (uint256, uint256 short, uint256 collat, uint256 borrowed);
    function priceOracle() external view returns (address);
}

interface DForceOracle{
    function getUnderlyingPriceAndStatus(address iToken) external returns (uint256 _price, bool _valid);
}

interface DForceLPFarm{
    function balanceOf(address account) external view returns (uint256); // LP token staked
    function earned(address _account) external view returns (uint256); // Of DF token
    function getReward() external;
    function exit() external;
    function stake(uint256 _amount) external;
    function withdraw(uint256 _amount) external; // This does not autoclaim reward
}

interface DforceToken{
    function exchangeRateCurrent() external returns (uint256);
    function borrowBalanceCurrent(address _account) external returns (uint256);
    function mint(address _recipient, uint256 _mintAmount) external; // Used for depositing
    function redeem(address _from, uint256 _redeemiToken) external; // Used for withdraws
    function borrow(uint256 _borrowAmount) external; // Used to borrow
    function repayBorrow(uint256 _repayAmount) external; // Used to repay
    function getCash() external view returns (uint256);
}

interface StabilizeUtilities{
    function calculateDodoReturn(address dodoAddress, address inputAddress, address outputAddress, uint256 _amount) external view returns (uint256);
    function checkLendRatio(address _contract) external view returns (uint256);
    function calculateRewards(address _contract) external returns (uint256);
    function getUSXInBUSDUnits(address _contract, uint256 _amount) external view returns (uint256);
    function getBUSDInUSXUnits(address _contract, uint256 _amount) external view returns (uint256);
    function getNormalizedTotalBalance(address _contract) external returns (uint256);
    function acceptableMinOutput(address _contract, address inputAddress, uint256 _amount) external view returns (uint256);
    function busdLendingPoolBalance(address _contract) external returns (uint256);
}

// This strategy does the following:
// BUSD is deposited into the strategy. Some of it is lent out to DForce and USX is borrowed. USX is then paired with the remaining BUSD and farmed for rewards
// DF rewards are earned from lending/borrowing and from farming. DF is sold for BUSD (plus a little WBNB)

// If Health ratio is too low, strategy is forced rebalanced
// If lending liquidity starts to dry up, strat attempts to exit from pools for safety measure
//

contract BUSDStrategyDforceV3 is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    
    address public treasuryAddress; // Address of the treasury
    address public zsbTokenAddress; // The address of the controlling zsb-Token
    address public strategyUtilitiesAddress; // Contract that contains calculations

    uint256 constant DIVISION_FACTOR = 100000;
    uint256 public gasPrice = 6e9; // Gas price in wei, changes sometimes on BSC

    uint256 public lastTradeTime;
    uint256 public lastActionBalance; // Balance before last deposit, withdraw or trade
    uint256 public percentStakeDepositor = 90000; // depositors earn 90% of all stake gains
    uint256 public percentExecutor = 50000; // 10000 = 10% of WBNB goes to executor
    uint256 public percentStakers = 50000; // 50000 = 50% of WBNB goes to strat stakers
    uint256 public rebalanceGasStipend = 4000000; // This is the gas units that are covered by executing a rebalance from the WBNB profit  

    bool public emergencyWithdrawMode = false; // Activated in case tokens get stuck in strategy after timelock


    // Token information
    struct TokenInfo {
        IERC20 token; // Reference of token
        uint256 decimals; // Decimals of token
    }
    
    TokenInfo[] private tokenList; // An array of tokens accepted as deposits

    // Strategy specific variables
    address constant WBNB_ADDRESS = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); // WBNB address
    address constant DF_ADDRESS = address(0x4A9A2b2b04549C3927dd2c9668A5eF3fCA473623);
    address constant USX_ADDRESS = address(0xB5102CeE1528Ce2C760893034A4603663495fD72);
    address constant PANCAKE_ROUTER = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address constant DODO_ROUTER = address(0x8F8Dd7DB1bDA5eD3da8C9daf3bfa471c12d58486); // Dodo v2 router
    address constant DODO_LIQUIDITY_PROXY = address(0x2442A8B5cdf1E659F3F949A7E454Caa554D4E65a);

    // Pools
    address constant DODO_DF_USX_POOL = address(0xB69fdC6531e08B366616aB30b8481bf4148786cB);
    address constant DODO_USX_BUSD_POOL = address(0xb19265426ce5bC1E015C0c503dFe6EF7c407a406);
    address constant DFORCE_LP_FARM = address(0x8d61b71958dD9Df6eAA670c0476CcE7e25e98707);
    address constant DFORCE_IBUSD_POOL = address(0x5511b64Ae77452C7130670C79298DEC978204a47);
    address constant DFORCE_IUSX_POOL = address(0x7B933e1c1F44bE9Fb111d87501bAADA7C8518aBe);
    address constant DFORCE_LENDING_MARKETS = address(0x0b53E608bD058Bb54748C35148484fD627E6dc0A);
    address constant DFORCE_INCENTIVE_CONTRACT = address(0x6fC21a5a767212E8d366B3325bAc2511bDeF0Ef4);

    // Strategy restrictions
    uint256 public usxMaxBorrowAmount = 200000e18;
    uint256 public usxBorrowPercent = 75000; // Borrows up to 75% of lent BUSD (Max threshold is 80%)
    uint256 public liquidityBuffer = 20000; // Strategy will exit if liquidity becomes less than this buffer
    uint256 public minHealthRatio = 103000; // If ratio gets below this, close the position and rebalance
    uint256 public usxSlippage = 1000; // Adjusted based on swap fees
    uint256 public maxUSXSwapAmount = 25000e18; // The max amount that will be swapped once on deposit
    uint256 public minBUSDDeposit = 200e18; // Minimum amount user can deposit before strat adds it
    uint256 public usxSetPrice = 1e18;
    
    constructor(
        address _treasury,
        address _zsbToken,
        address _utils
    ) public {
        treasuryAddress = _treasury;
        zsbTokenAddress = _zsbToken;
        strategyUtilitiesAddress = _utils;
        setupWithdrawTokens();
    }

    // Initialization functions
    
    function setupWithdrawTokens() internal {
        // Start with BUSD
        IERC20 _token = IERC20(address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56));
        tokenList.push(
            TokenInfo({
                token: _token,
                decimals: _token.decimals()
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
    
    function balance() public returns (uint256) {
        updateUSXPrice();
        return StabilizeUtilities(strategyUtilitiesAddress).getNormalizedTotalBalance(address(this));
    }
    
    function withdrawTokenReserves() public returns (address, uint256) {
        updateUSXPrice();
        // This function will return the address and amount of the token with the highest balance
        return (address(tokenList[0].token), balance());
    }

    function withdrawAvailable(uint256 _share, uint256 _total) public returns (bool) {
        // Will always be true as strategy uses user BUSD to pay off excess debt
        updateUSXPrice();
        if(_share == _total){}
        return true;
    }
    
    // Write functions
    
    function enter() external onlyZSBToken {
        deposit(false);
    }
    
    function exit() external onlyZSBToken {
        // The ZS token vault is removing all tokens from this strategy
        withdraw(_msgSender(),1,1, false);
    }
    
    function deposit(bool nonContract) public onlyZSBToken {
        // Only the ZS token can call the function
        updateUSXPrice();

        // Free BUSD balance is greater than a certain number, stake more
        if(nonContract == true){
            checkAndSwapToken(address(0), true);
            // Add to the borrow position if it exists
            expandPositionAndStake();
        }

        lastActionBalance = balance(); // This action balance represents pool post stablecoin deposit
    }
    
    function withdraw(address _depositor, uint256 _share, uint256 _total, bool nonContract) public onlyZSBToken returns (uint256) {
        require(balance() > 0, "There are no tokens in this strategy");
        updateUSXPrice();
        if(nonContract == true || _depositor == zsbTokenAddress){
            checkAndSwapToken(address(0), true);
        }

        uint256 _busdBal = tokenList[0].token.balanceOf(address(this));
        uint256 withdrawAmount = 0;
        uint256 _balance = balance();
        if(_share < _total){
            uint256 _myBalance = _balance.mul(_share).div(_total);
            if(_myBalance > _busdBal){
                uint256 overage = _myBalance.sub(_busdBal);
                // We need to unstake to get more BUSD as free tokens are not enough
                unstakeAndReducePosition(false, overage);
            }
            withdrawOne(_depositor, _myBalance, false); // This will withdraw based on token balance
            withdrawAmount = _myBalance;
            if(_myBalance > _busdBal){
                expandPositionAndStake(); // Restake everything
            }
        }else{
            // We are all shares, transfer all, no need to restake
            unstakeAndReducePosition(true, 0);
            withdrawOne(_depositor, _balance, true);
            withdrawAmount = _balance;
        }
        lastActionBalance = balance();
        
        return withdrawAmount;
    }
    
    // This will withdraw the token from the contract
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
    function testDeposit(bool toUSX) external payable {
        // Must interface: function swapExactETHForTokens(uint, address[] calldata, address, uint) external payable returns (uint[] memory);
        address[] memory path;
        TradeRouter router = TradeRouter(PANCAKE_ROUTER);
        path = new address[](2);
        path[0] = WBNB_ADDRESS;
        path[1] = address(tokenList[0].token); // First get BUSD
        uint256 _bal = tokenList[0].token.balanceOf(address(this));
        router.swapExactETHForTokens{value: msg.value}(1, path, address(this), now.add(60));
        _bal = tokenList[0].token.balanceOf(address(this)).sub(_bal);
        if(toUSX == true){
            swapViaDodoV2(DODO_USX_BUSD_POOL, address(tokenList[0].token), USX_ADDRESS, _bal, 1);
        }
    }
    */

    function claimRewards(bool _nopayout) internal {
        if(usxMaxBorrowAmount == 0){return;} // Prevent further claims as well

        // This will convert rewards (DF) to BUSD and some to WBNB (via DF -> USX -> BUSD -> WBNB)
        DForceLPFarm farm = DForceLPFarm(DFORCE_LP_FARM);
        uint256 _earned = farm.earned(address(this));
        if(_earned > 0){
            farm.getReward();
        }

        // Now claim DF from the markets
        {
            // Activate market
            DForceController controller = DForceController(DFORCE_INCENTIVE_CONTRACT);
            address[] memory myaddress = new address[](1);
            myaddress[0] = address(this);
            address[] memory isuppliedtokens = new address[](1);
            isuppliedtokens[0] = DFORCE_IBUSD_POOL;
            address[] memory iborrowedtokens = new address[](1);
            iborrowedtokens[0] = DFORCE_IUSX_POOL;
            controller.claimRewards(myaddress, isuppliedtokens, iborrowedtokens);
        }

        uint256 _bal = IERC20(DF_ADDRESS).balanceOf(address(this));
        uint256 _newBUSD;
        if(_bal > 0){
            // Convert all DF to BUSD via USX
            _newBUSD = swapViaDodoV2(DODO_DF_USX_POOL, DF_ADDRESS, USX_ADDRESS, _bal, 1);
            _newBUSD = swapViaDodoV2(DODO_USX_BUSD_POOL, USX_ADDRESS, address(tokenList[0].token), _newBUSD, 1);
        }

        if(_newBUSD > 0 && _nopayout == false){
            // Convert a percentage to WBNB
            _newBUSD = _newBUSD.mul(DIVISION_FACTOR.sub(percentStakeDepositor)).div(DIVISION_FACTOR);
            address[] memory path;
            path = new address[](2);
            path[0] = address(tokenList[0].token);
            path[1] = WBNB_ADDRESS;
            TradeRouter router = TradeRouter(PANCAKE_ROUTER);
            IERC20(path[0]).safeApprove(address(router), 0);
            IERC20(path[0]).safeApprove(address(router), _newBUSD);
            router.swapExactTokensForTokens(_newBUSD, 1, path, address(this), now.add(60)); // Get WBNB
        }
    }

    function unstakeAndReducePosition(bool total, uint256 _amountBUSD) internal {
        // If we do not need the total amount removed, we can remove a certain amount of BUSD instead

        uint256 proportionNeeded = 0; // Denominated in 1e18 decimals
        if(total == false){
            require(_amountBUSD > 0, "No BUSD amount");
            // Get total BUSD supplied
            uint256 _supplied = StabilizeUtilities(strategyUtilitiesAddress).busdLendingPoolBalance(address(this)); // Check the token balance
            if(_supplied > 0){
                proportionNeeded = _amountBUSD.mul(1e18).div(_supplied); // This is the amount we need to remove
                if(proportionNeeded >= 1e18){
                    total = true; // Remove it all
                }
            }else{
                return;
            }
        }
        
        uint256 posBUSD = tokenList[0].token.balanceOf(address(this));
        uint256 posUSX = IERC20(USX_ADDRESS).balanceOf(address(this));
        {
            // Remove the DodoLP from the farm and liquidate it
            DForceLPFarm farm = DForceLPFarm(DFORCE_LP_FARM);
            uint256 _bal = farm.balanceOf(address(this));
            if(total == false){
                _bal = _bal.mul(proportionNeeded).div(1e18);
            }
            if(_bal > 0){
                farm.withdraw(_bal); // This will pull the tokens
            }

            // Then unwrap back to native tokens
            IERC20 lpToken = IERC20(DODO_USX_BUSD_POOL);
            if(lpToken.balanceOf(address(this)) > 0) {
                DodoPool lpPool = DodoPool(DODO_USX_BUSD_POOL);
                bytes memory nulldata;
                lpPool.sellShares(lpToken.balanceOf(address(this)), address(this), 1, 1, nulldata, now.add(60));
            }
        }
        posUSX = IERC20(USX_ADDRESS).balanceOf(address(this)).sub(posUSX); // USX gained from removing liquidity
        posBUSD = tokenList[0].token.balanceOf(address(this)).sub(posBUSD); // This BUSD will be sold for USX
        uint256 borrowAmount = DforceToken(DFORCE_IUSX_POOL).borrowBalanceCurrent(address(this));

        if(borrowAmount > 0) {
            // Now payback the loan by first selling unstaked BUSD for USX
            if(posBUSD > 0){
                uint256 minReturn = StabilizeUtilities(strategyUtilitiesAddress).acceptableMinOutput(address(this), address(tokenList[0].token), posBUSD);
                swapViaDodoV2(DODO_USX_BUSD_POOL, address(tokenList[0].token), USX_ADDRESS, posBUSD, minReturn);
            }

            // Repay the loan with whatever USX is available
            uint256 repayAmount = IERC20(USX_ADDRESS).balanceOf(address(this));
            if(repayAmount > borrowAmount){
                repayAmount = borrowAmount;
            }else if(total == false){
                // All users are expected to pay a minimum amount from the borrow amount
                borrowAmount = borrowAmount.mul(proportionNeeded).div(1e18);
            }

            if(borrowAmount > repayAmount){
                // We don't have enough USX to pay off our portion of the loan, so buy some from what we supplied in BUSD
                uint256 extraBUSDNeeded = StabilizeUtilities(strategyUtilitiesAddress).getUSXInBUSDUnits(address(this), borrowAmount.sub(repayAmount)).mul(DIVISION_FACTOR.add(usxSlippage)).div(DIVISION_FACTOR);
                posBUSD = tokenList[0].token.balanceOf(address(this));
                DforceToken(DFORCE_IBUSD_POOL).redeem(address(this), extraBUSDNeeded.mul(1e18).div(DforceToken(DFORCE_IBUSD_POOL).exchangeRateCurrent()));
                posBUSD = tokenList[0].token.balanceOf(address(this)).sub(posBUSD);
                swapViaDodoV2(DODO_USX_BUSD_POOL, address(tokenList[0].token), USX_ADDRESS, posBUSD, 1);
                repayAmount = IERC20(USX_ADDRESS).balanceOf(address(this));
                if(repayAmount > borrowAmount){
                    repayAmount = borrowAmount;
                }
                require(borrowAmount <= repayAmount, "Not enough USX to fully repay loan");
            }

            // Now repay some/all of the loan
            DforceToken pool = DforceToken(DFORCE_IUSX_POOL);
            IERC20(USX_ADDRESS).safeApprove(address(pool), 0);
            IERC20(USX_ADDRESS).safeApprove(address(pool), repayAmount);
            pool.repayBorrow(repayAmount);
        }

        {
            // Remove some of the BUSD from the markets
            DforceToken pool = DforceToken(DFORCE_IBUSD_POOL);
            uint256 _bal = IERC20(DFORCE_IBUSD_POOL).balanceOf(address(this));
            if(total == false){
                _bal = _bal.mul(proportionNeeded).div(1e18);
            }
            if(_bal > 0){
                posBUSD = tokenList[0].token.balanceOf(address(this));
                pool.redeem(address(this), _bal);
                require(tokenList[0].token.balanceOf(address(this)) > posBUSD, "Failed to redeem");
            }
        }

        {
            // Convert all USX into BUSD
            posUSX = IERC20(USX_ADDRESS).balanceOf(address(this));
            if(posUSX > 0){
                swapViaDodoV2(DODO_USX_BUSD_POOL, USX_ADDRESS, address(tokenList[0].token), posUSX, 1);
            }
        }

        if(total == false){
            expandPositionAndStake();
            // Make sure the lend ratio is still healthy
            if(StabilizeUtilities(strategyUtilitiesAddress).checkLendRatio(address(this)) < minHealthRatio){
                revert("Withdrawal caused a bad lend ratio");
            }
        }
    }

    function expandPositionAndStake() internal {
        uint256 _amount = tokenList[0].token.balanceOf(address(this));
        if(_amount == 0){return;} // No BUSD token in contract
        if(_amount < minBUSDDeposit && lastActionBalance > 0){return;} // Do not add it yet
        if(usxMaxBorrowAmount == 0){return;} // Prevent further positions from being opened 
        uint256 currentBorrow = DforceToken(DFORCE_IUSX_POOL).borrowBalanceCurrent(address(this));
        
        {
            // Activate market
            DForceController controller = DForceController(DFORCE_LENDING_MARKETS);
            address[] memory itokens = new address[](1);
            itokens[0] = DFORCE_IBUSD_POOL;
            if(controller.hasEnteredMarket(address(this), itokens[0]) == false){
                // Activate this pool to be used as collateral
                controller.enterMarkets(itokens);
            }
        }

        // Supply all BUSD into Dforce
        {
            // Check to make sure there is enough liquidity already in the pool
            DforceToken pool = DforceToken(DFORCE_IBUSD_POOL);
            if(pool.getCash() < _amount.mul(liquidityBuffer.add(10000)).div(DIVISION_FACTOR).add(StabilizeUtilities(strategyUtilitiesAddress).busdLendingPoolBalance(address(this))) ) {
                return; // Not enough present external liquidity, do not supply to pool
            }
            tokenList[0].token.safeApprove(address(pool), 0);
            tokenList[0].token.safeApprove(address(pool), _amount);
            pool.mint(address(this), _amount);
            require(IERC20(DFORCE_IBUSD_POOL).balanceOf(address(this)) > 0, "Failed to supply tokens");
        }

        if(currentBorrow >= usxMaxBorrowAmount){return;} // Already too much borrowed

        // Now borrow USX
        // Convert amount to USX units
        _amount = StabilizeUtilities(strategyUtilitiesAddress).getBUSDInUSXUnits(address(this), _amount);
        uint256 borrowAmount = _amount.mul(usxBorrowPercent).div(DIVISION_FACTOR);
        {
            if(borrowAmount.add(currentBorrow) > usxMaxBorrowAmount){
                borrowAmount = usxMaxBorrowAmount.sub(currentBorrow);
            }
            DforceToken pool = DforceToken(DFORCE_IUSX_POOL);
            pool.borrow(borrowAmount);
            require(IERC20(USX_ADDRESS).balanceOf(address(this)) > 0, "Failed to supply tokens");
        }

        do {
            // We will swap a certain amount of USX for BUSD (pegged assets)
            uint256 usxAmount = borrowAmount;
            if(usxAmount > maxUSXSwapAmount){
                usxAmount = maxUSXSwapAmount;
            }
            
            DodoPool pool = DodoPool(DODO_USX_BUSD_POOL); // USX is the base token, BUSD is the quote
            (uint256 baseAmount, uint256 quoteAmount) = pool.getVaultReserve();
            require(baseAmount > 0, "No pool balance exists");
            uint256 ratio = baseAmount.mul(DIVISION_FACTOR).div(quoteAmount.add(baseAmount));
            ratio = DIVISION_FACTOR.sub(ratio);
            uint256 sellAmount = usxAmount.mul(ratio).div(DIVISION_FACTOR);
            uint256 minReturn = StabilizeUtilities(strategyUtilitiesAddress).acceptableMinOutput(address(this), USX_ADDRESS, sellAmount);
            uint256 busdAmount = swapViaDodoV2(DODO_USX_BUSD_POOL, USX_ADDRESS, address(tokenList[0].token), sellAmount, minReturn);
            usxAmount = usxAmount.sub(sellAmount);
            // Add to liquidity and stake it in Dforce
            {
                // This function will add up liquidity to pool
                require(busdAmount > 0, "No BUSD available");

                DodoLiquidityRouter router = DodoLiquidityRouter(DODO_LIQUIDITY_PROXY);
                address approver = DodoApproveProxy(DodoRouter(DODO_ROUTER)._DODO_APPROVE_PROXY_())._DODO_APPROVE_();
                IERC20(USX_ADDRESS).safeApprove(approver, 0);
                IERC20(USX_ADDRESS).safeApprove(approver, usxAmount);
                tokenList[0].token.safeApprove(approver, 0);
                tokenList[0].token.safeApprove(approver, busdAmount);
                // Add liquidity up to the smaller balance
                router.addDSPLiquidity(DODO_USX_BUSD_POOL, usxAmount, busdAmount, 1, 1, 0, now.add(60));
            }

            if(borrowAmount > maxUSXSwapAmount){
                borrowAmount = borrowAmount.sub(maxUSXSwapAmount);
            }else{
                borrowAmount = 0;
            }
        } while ( borrowAmount > 0);

        {
            // Now we have LP tokens, deposit 
            DForceLPFarm farm = DForceLPFarm(DFORCE_LP_FARM);
            IERC20 lpToken = IERC20(DODO_USX_BUSD_POOL);
            uint256 _bal = lpToken.balanceOf(address(this));
            if(_bal > 0){
                lpToken.safeApprove(address(farm), 0);
                lpToken.safeApprove(address(farm), _bal);
                farm.stake(_bal);
            }
        }

        {
            // If there is any USX left over, convert it to BUSD
            uint256 usxAmount = IERC20(USX_ADDRESS).balanceOf(address(this));
            if(usxAmount > 0){
                swapViaDodoV2(DODO_USX_BUSD_POOL, USX_ADDRESS, address(tokenList[0].token), usxAmount, 1);
            }
        }
    }

    // Dodo specific functions
    function swapViaDodoV2(address dodoAddress, address inputAddress, address outputAddress, uint256 _amount, uint256 _minOut) internal returns (uint256) {
        uint256 direction = 0; // Selling base
        if(DodoPool(dodoAddress)._BASE_TOKEN_() != inputAddress){
            direction = 1; // We are selling quote token
        }        
        address[] memory path = new address[](1);
        address approver = DodoApproveProxy(DodoRouter(DODO_ROUTER)._DODO_APPROVE_PROXY_())._DODO_APPROVE_();
        path[0] = dodoAddress;
        IERC20(inputAddress).safeApprove(approver, 0);
        IERC20(inputAddress).safeApprove(approver, _amount);
        uint256 _bal = IERC20(outputAddress).balanceOf(address(this));
        DodoRouter(DODO_ROUTER).dodoSwapV2TokenToToken(inputAddress, outputAddress, _amount, _minOut, path, direction, false, now.add(60));
        return IERC20(outputAddress).balanceOf(address(this)).sub(_bal);
    }

    function checkAndSwapToken(address _executor, bool skipHealthCheck) internal {
        updateUSXPrice();
        lastTradeTime = now;

        // Check first to see whether the lending ratio is bad
        if(skipHealthCheck == false){
            bool liquidate = false;
            uint256 ratio = StabilizeUtilities(strategyUtilitiesAddress).checkLendRatio(address(this));
            
            // Pool may need to be rebalanced (Shouldn't normally happen)
            if(ratio > 0 && ratio < minHealthRatio){
                claimRewards(true); // Convert all rewards to only BUSD
                liquidate = true;
            }

            if(DforceToken(DFORCE_IBUSD_POOL).getCash() < StabilizeUtilities(strategyUtilitiesAddress).busdLendingPoolBalance(address(this)).mul(DIVISION_FACTOR.add(liquidityBuffer)).div(DIVISION_FACTOR) ){
                // Liquidity in the lending protocol for the BUSD pool is too low
                claimRewards(true); // Convert all rewards to only BUSD
                liquidate = true;
            }

            if(liquidate == true){
                usxMaxBorrowAmount = 0; // No more lending until governance changes it
                unstakeAndReducePosition(true, 0); // Reset the entire position

                if(_executor != address(0)){
                    // Calculate BUSD needed to fulfill stipend
                    TradeRouter router = TradeRouter(PANCAKE_ROUTER);
                    address[] memory path = new address[](2);
                    path[0] = address(tokenList[0].token);
                    path[1] = WBNB_ADDRESS;
                    uint256[] memory estimates;
                    estimates = router.getAmountsIn(rebalanceGasStipend.mul(gasPrice), path);
                    uint256 busdSellAmount = estimates[0];

                    if(busdSellAmount < tokenList[0].token.balanceOf(address(this))){
                        // We have enough, send it!
                        tokenList[0].token.safeApprove(address(router), 0);
                        tokenList[0].token.safeApprove(address(router), busdSellAmount);
                        router.swapExactTokensForTokens(busdSellAmount, 1, path, address(this), now.add(60)); // Get WBNB
                        IERC20(WBNB_ADDRESS).safeTransfer(_executor, IERC20(WBNB_ADDRESS).balanceOf(address(this)));
                    }
                }

                lastActionBalance = balance();
                return;
            }else{
                claimRewards(false);
            }
        }else{
            claimRewards(false);
        }

        lastActionBalance = balance();
        
        // Now take some gained bnb and distribute it to executor, stakers and treasury
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
    
    // Accepts 1) address for the executor, 2) random seed number
    // Returns 1) uint256 profit as wei units BNB for executor
    // Returns 2) uint256 blocknumber of data returned
    // Returns 3) bytes32 codehash
    function expectedProfit(address _executor, uint256 seed) external returns (uint256,uint256,bytes32) {
        bytes32 executorCode = generateExecutorCode(_executor, seed);

        // Check first to see whether the lending ratio is bad
        uint256 wbnbGain = IERC20(WBNB_ADDRESS).balanceOf(address(this));
        uint256 ratio = StabilizeUtilities(strategyUtilitiesAddress).checkLendRatio(address(this));
        if(ratio > 0 && ratio < minHealthRatio) {
            // We are at risk for liquidation, payout the stipend
            return (rebalanceGasStipend.mul(gasPrice), block.number, executorCode);
        }else if(DforceToken(DFORCE_IBUSD_POOL).getCash() < StabilizeUtilities(strategyUtilitiesAddress).busdLendingPoolBalance(address(this)).mul(DIVISION_FACTOR.add(liquidityBuffer)).div(DIVISION_FACTOR)){
            // Liquidity is drying up, payout the stipend to exit
            return (rebalanceGasStipend.mul(gasPrice), block.number, executorCode);   
        }else{
            wbnbGain = wbnbGain.add(StabilizeUtilities(strategyUtilitiesAddress).calculateRewards(address(this)));
            // Now calculate the amount going to the executor
            return (wbnbGain.mul(percentExecutor).div(DIVISION_FACTOR), block.number, executorCode);
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
    
    // Accepts 1) address that profit will go to, 2) random seed, used with expectedprofit, 3) random code 4) uint256 minimum amount of seconds required between this swap and last
    // 5) uint256 blocknumber that trade will expire after
    // 6) uint256 tokenID for token we want to sell, 7) uint256 tokenID of the token we want to buy, 8) uint256 exchange that we want to use to sell
    function executorSwapTokens(address _executor, uint256 _seed, bytes32 code, uint256 _minSecSinceLastTrade, uint256 _deadlineBlock) external {
        checkExecutorCode(_executor, _seed, code);
        require(block.number <= _deadlineBlock, "Deadline has expired, aborting trade");
        // Function designed to promote trading with incentive. Users get percentage of WBNB from profitable trades
        require(now.sub(lastTradeTime) >= _minSecSinceLastTrade, "The last trade was too recent");
        require(_msgSender() == tx.origin, "Contracts cannot interact with this function");
        checkAndSwapToken(_executor, false);
    }
    
    // Governance functions
    function governanceSwapTokens(bool _doRebalance) external onlyGovernance {
        // This is function that force trade tokens at anytime. It can only be called by governance
        checkAndSwapToken(_msgSender(), _doRebalance);
        if(_doRebalance == true){
            unstakeAndReducePosition(true, 0);
            expandPositionAndStake();
        }
    }

    // Change the trading conditions used by the strategy without timelock
    // --------------------
    function changeStrategyConditions(uint256 _minDeposit, 
                                    uint256 _rGasStipend, 
                                    uint256 _gasPrice,
                                    uint256 _maxBorrow,
                                    uint256 _BorrowPercent,
                                    uint256 _minHealth,
                                    uint256 _usxSlip,
                                    uint256 _maxUSwap,
                                    uint256 _liquidBuffer) external onlyGovernance {
        // Changes a lot of strategy parameters in one call
        minBUSDDeposit = _minDeposit;
        rebalanceGasStipend = _rGasStipend;
        gasPrice = _gasPrice;
        usxMaxBorrowAmount = _maxBorrow;
        usxBorrowPercent = _BorrowPercent;
        minHealthRatio = _minHealth;
        usxSlippage = _usxSlip;
        maxUSXSwapAmount = _maxUSwap;
        liquidityBuffer = _liquidBuffer;
    }

    // Prices are now updated by Dforce protocol itself
    function updateUSXPrice() internal {
        (uint256 _newPrice, bool _status) = DForceOracle(DForceController(DFORCE_LENDING_MARKETS).priceOracle()).getUnderlyingPriceAndStatus(DFORCE_IUSX_POOL);
        if(_status == true){
            // Update the price (decimals of 10^18)
            usxSetPrice = _newPrice;
        }
    }
    // --------------------

    // Used to update Strategy Utilities

    function updateStrategyUtilities(address _util) external onlyGovernance {
        strategyUtilitiesAddress = _util;
    }
    // --------------------

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
    uint256[3] private _timelock_data;
    
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
    
    function startChangeStrategyAllocations(uint256 _pStakeDepositors, uint256 _pStakers, uint256 _pExecutor) external onlyGovernance {
        // Changes strategy allocations in one call
        require(_pStakeDepositors <= 100000 && _pExecutor <= 100000 && _pStakers <= 100000,"Percent cannot be greater than 100%");
        _timelockStart = now;
        _timelockType = 4;
        _timelock_data[0] = _pStakeDepositors;
        _timelock_data[1] = _pExecutor;
        _timelock_data[2] = _pStakers;
    }
    
    function finishChangeStrategyAllocations() external onlyGovernance timelockConditionsMet(4) {
        percentStakeDepositor = _timelock_data[0];
        percentExecutor = _timelock_data[1];
        percentStakers = _timelock_data[2];
    }
    // --------------------

    // Going into emergency withdraw mode
    // --------------------
    function startActivateEmergencyWithdrawMode() external onlyGovernance {
        _timelockStart = now;
        _timelockType = 5;
    }
    
    function finishActivateEmergencyWithdrawMode() external onlyGovernance timelockConditionsMet(5) {
        unstakeAndReducePosition(true, 0);
        emergencyWithdrawMode = true;
    }
    // --------------------
}