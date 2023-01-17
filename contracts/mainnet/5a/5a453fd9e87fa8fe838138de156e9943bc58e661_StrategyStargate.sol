/**
 *Submitted for verification at BscScan.com on 2023-01-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IUniswapRouter {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

interface IStargateChef {
    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function emergencyWithdraw(uint256 _pid) external;

    function pendingStargate(uint256 _pid, address _user)
        external
        view
        returns (uint256);

    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of STGs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accStargatePerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accStargatePerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    function userInfo(uint256 _pid, address _userAddress)
        external
        view
        returns (UserInfo memory _userInfo);

    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. STGs to distribute per block.
        uint256 lastRewardBlock; // Last block number that STGs distribution occurs.
        uint256 accStargatePerShare; // Accumulated STGs per share, times 1e12. See below.
    }

    function poolInfo(uint256 _index)
        external
        view
        returns (PoolInfo memory _poolInfo);
}

interface IStargateRouter {
    function addLiquidity(
        uint256 _poolId,
        uint256 _amountLD,
        address _to
    ) external;

    function instantRedeemLocal(
        uint16 _srcPoolId,
        uint256 _amountLP,
        address _to
    ) external returns (uint256 amountSD);
}

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
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
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

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

// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

abstract contract BaseStrategy is Ownable, Pausable {
    address public immutable want;

    address public keeper;
    address public strategist;
    address public vault;
    address public govFeeRecipient;

    uint256 public strategistFee = 400; // default to 40% of perf fee
    uint256 public totalFee = 1000; // a.k.a total perf fee. default to 10%
    uint256 public govFee = 600;
    uint256 public constant MAX_FEE = 1000; // max 10%

    event KeeperChanged(address keeper);
    event StrategistChanged(address strategist);
    event VaultChanged(address vault);
    event GovFeeRecipientChanged(address govFeeRecipient);
    event TokenSweeped(address token, uint256 amount);
    event StrategyRetired(uint256 amount);
    event Emergency(bool emergencyMode);
    event FeesUpdated(uint256 totalFee, uint256 strategistFee, uint256 govFee);

    // those already in vault and zapper idk maybe delete??
    event Deposit(uint256 depositedAmount);
    event Withdraw(uint256 withdrawnAmount);

    event StrategyHarvested(
        address indexed caller,
        uint256 profit, // profit includes the fee aswell profit-fee is the real profit for users
        uint256 fee,
        uint256 lastHarvest
    );

    constructor(
        address _keeper,
        address _strategist,
        address _vault,
        address _want,
        address _govFeeRecipient
    ) {
        keeper = _keeper;
        strategist = _strategist;
        vault = _vault;
        want = _want;
        govFeeRecipient = _govFeeRecipient;
    }

    modifier onlyManager() {
        require(msg.sender == owner() || msg.sender == strategist, "!manager");
        _;
    }

    modifier onlyKeepers() {
        require(
            msg.sender == strategist || msg.sender == keeper,
            "keeper or strategist"
        );
        _;
    }

    modifier onlyVault() {
        require(msg.sender == vault, "!vault");
        _;
    }

    function setKeeper(address _keeper) external onlyManager {
        keeper = _keeper;
        emit KeeperChanged(keeper);
    }

    function setStrategist(address _strategist) external onlyManager {
        require(msg.sender == strategist, "!strategist");
        strategist = _strategist;
        emit StrategistChanged(strategist);
    }

    // also updates gov fee !!
    function setStrategistFee(uint256 _fee) external onlyOwner {
        require(_fee <= MAX_FEE && _fee <= totalFee, "MAX_FEE_CAP");
        strategistFee = _fee;
        govFee = totalFee - _fee;
        emit FeesUpdated(totalFee, _fee, govFee);
    }

    function setTotalFee(uint256 _fee) external onlyOwner {
        require(_fee <= MAX_FEE, "MAX_FEE_CAP");
        totalFee = _fee;
        strategistFee = (_fee * 4_000) / 10_000; // back to default
        govFee = totalFee - strategistFee; // back to default
        emit FeesUpdated(_fee, strategistFee, govFee);
    }

    function setVault(address _vault) external onlyOwner {
        vault = _vault;
        emit VaultChanged(vault);
    }

    function setGovFeeRecipient(address _govFeeRecipient) external onlyOwner {
        govFeeRecipient = _govFeeRecipient;
        emit GovFeeRecipientChanged(govFeeRecipient);
    }

    // it calculates how much 'want' this contract holds.
    function balanceOfWant() public view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    // return the name of strategy for clarity
    function name() external view virtual returns (string memory sm);

    /*
     *  total want that this Strategy is currently managing,
     *  denominated in terms of `want` tokens. */
    function totalAssets() public view virtual returns (uint256);

    function deposit() public whenNotPaused {
        uint256 _deposited = _deposit();
        require(_deposited != 0, "DEPOSIT_ZERO_AMOUNT");

        emit Deposit(_deposited);
    }

    // invest want tokens to strategy return the invested want
    function _deposit() internal virtual returns (uint256);

    // withdraw the "_amount" to the vault. Liquidate position to satisfy "_amount" return
    function withdraw(uint256 _amount)
        external
        onlyVault
        returns (uint256 wantWithdrawn)
    {
        wantWithdrawn = _withdraw(_amount);
        SafeERC20.safeTransfer(IERC20(want), msg.sender, wantWithdrawn);

        emit Withdraw(wantWithdrawn);
    }

    function _withdraw(uint256 _amount) internal virtual returns (uint256);

    // harvest the rewards/fees and reinvest
    function _harvest()
        internal
        virtual
        returns (uint256 wantHarvested, uint256 feeTaken);

    function harvest() external onlyKeepers {
        (uint256 _wantHarvested, uint256 _fee) = _harvest();

        emit StrategyHarvested(
            msg.sender,
            _wantHarvested,
            _fee,
            block.timestamp
        );
    }

    // return the fee taken from the harvested rewards in terms of 'wnative' token (wbnb, wavax, weth etc)
    function _chargeFees(uint256 _rewards)
        internal
        virtual
        returns (uint256 feeTaken);

    // free up as many want as you can for vault
    function _prepareRetirement() internal virtual;

    // return want to strategy idle wait for
    function panic() external onlyManager {
        _pause();
        _removeAllowances();
        _panic();
        emit Emergency(true);
    }

    function pause() public onlyManager {
        _pause();
        _removeAllowances();
        emit Emergency(true);
    }

    function unpause() external onlyManager {
        _unpause();
        _giveAllowances();
        _deposit();
        emit Emergency(false);
    }

    // give all allowances (chef, liq pool, router etc)
    function _giveAllowances() internal virtual;

    // remove all allowances (chef, liq pool, router etc)
    function _removeAllowances() internal virtual;

    // Emergency function
    // free up as many want as you can to strategy and pause all the deposits/actions
    function _panic() internal virtual;

    // to sweep any tokens except want
    // this could be used to sweep non-want tokens when strategy retires
    function sweep(address _token) external onlyManager {
        require(_token != address(want), "!want");
        uint256 toSweep = IERC20(_token).balanceOf(address(this));

        SafeERC20.safeTransfer(IERC20(_token), owner(), toSweep);
        emit TokenSweeped(_token, toSweep);
    }

    function retire() external onlyVault {
        _prepareRetirement();
        // transfer all want back to vault
        uint256 retiredAmount = IERC20(want).balanceOf(address(this));
        SafeERC20.safeTransfer(IERC20(want), address(vault), retiredAmount);
        emit StrategyRetired(retiredAmount);
    }
}

contract StrategyStargate is BaseStrategy {
    using SafeERC20 for IERC20;

    address public unirouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // default to pancake router
    // default constants
    address public constant rewardToken =
        0xB0D502E938ed5f4df2E681fE6E419ff29631d62b; // rewardToken
    address public constant NATIVE = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    IStargateRouter public constant stargateRouter =
        IStargateRouter(0x4a364f8c717cAAD9A442737Eb7b8A55cc6cf18D8);
    address public immutable stargateAsset;

    address public chef;
    uint256 public chefId;
    uint256 public poolId;

    // rewardToken ==> native
    address[] public rewardTokenRoute;

    // native ==> stargateAsset underlying
    address[] public nativeRoute;

    event RouterChanged(address router);

    constructor(
        address _want, // LP token of stargate
        address _stargateAsset, // the asset we will swap to for adding liquidity to get more want
        address _chef, // where we will stake our want
        uint256 _chefId, // chef chefId
        uint256 _poolId, // pool chefId
        address _vault,
        address _keeper,
        address _strategist,
        address _govFeeRecipient
    ) BaseStrategy(_keeper, _strategist, _vault, _want, _govFeeRecipient) {
        require(_checkForWant(_want, _chef, _chefId), "!WANT");
        stargateAsset = _stargateAsset;
        chefId = _chefId;
        poolId = _poolId;

        // default route
        rewardTokenRoute = [rewardToken, stargateAsset, NATIVE];
        nativeRoute = [NATIVE, stargateAsset];
        chef = _chef;
        _giveAllowances();
    }

    function name() external view override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "StrategyStargate",
                    IERC20Metadata(want).symbol()
                )
            );
    }

    function _panic() internal override {
        IStargateChef(chef).emergencyWithdraw(chefId);
    }

    function _giveAllowances() internal override {
        _giveAllowanceChef();
        _giveAllowanceRouter();
    }

    function _giveAllowanceChef() internal {
        IERC20(want).safeApprove(chef, type(uint256).max);
    }

    function _giveAllowanceRouter() internal {
        IERC20(stargateAsset).safeApprove(
            address(stargateRouter),
            type(uint256).max
        );
        IERC20(rewardToken).safeApprove(unirouter, type(uint256).max);
        IERC20(NATIVE).safeApprove(unirouter, type(uint256).max);
    }

    function _removeAllowances() internal override {
        _removeAllowanceChef();
        _removeAllowanceRouter();
    }

    function _removeAllowanceChef() internal {
        IERC20(want).safeApprove(chef, 0);
    }

    function _removeAllowanceRouter() internal {
        IERC20(stargateAsset).safeApprove(address(stargateRouter), 0);
        IERC20(rewardToken).safeApprove(unirouter, 0);
        IERC20(NATIVE).safeApprove(unirouter, 0);
    }

    function totalAssets() public view override returns (uint256) {
        return balanceOfWant() + balanceOfPool();
    }

    // it calculates how much 'want' the strategy has working in the farm.
    function balanceOfPool() public view returns (uint256) {
        IStargateChef.UserInfo memory user = IStargateChef(chef).userInfo(
            chefId,
            address(this)
        );
        return user.amount;
    }

    function pendingSTG() public view returns (uint256) {
        return IStargateChef(chef).pendingStargate(chefId, address(this));
    }

    function setRewardRoute(address[] memory _rewardTokenRoute)
        public
        onlyManager
    {
        _checkSwapPath(_rewardTokenRoute, rewardToken, NATIVE);
        rewardTokenRoute = _rewardTokenRoute;
    }

    function setNativeRoute(address[] memory _nativeRoute) public onlyManager {
        _checkSwapPath(_nativeRoute, NATIVE, stargateAsset);
        nativeRoute = _nativeRoute;
    }

    function setUniRouter(address _unirouter) public onlyManager {
        require(_unirouter != address(0), "ZERO_ADDRESS");

        _removeAllowanceRouter();
        unirouter = _unirouter;
        _giveAllowanceRouter();

        emit RouterChanged(_unirouter);
    }

    function _checkSwapPath(
        address[] memory _swapPath,
        address _fromToken,
        address _destinationToken
    ) internal pure {
        require(address(_fromToken) == _swapPath[0], "illegal path!");
        require(
            address(_destinationToken) == _swapPath[_swapPath.length - 1],
            "illegal path!"
        );
    }

    function _checkForWant(
        address _want,
        address _chef,
        uint256 _chefId
    ) internal view returns (bool) {
        IStargateChef.PoolInfo memory pool = IStargateChef(_chef).poolInfo(
            _chefId
        );
        if (address(pool.lpToken) == _want) return true;
    }

    function _deposit() internal override returns (uint256 wantBal) {
        wantBal = IERC20(want).balanceOf(address(this));

        if (wantBal > 0) {
            IStargateChef(chef).deposit(chefId, wantBal);
        }
    }

    function _withdraw(uint256 _amount) internal override returns (uint256) {
        uint256 wantBal = IERC20(want).balanceOf(address(this));

        if (wantBal >= _amount) {
            return _amount;
        }

        if (wantBal < _amount) {
            uint256 toWithdraw = _amount - wantBal;
            IStargateChef(chef).withdraw(chefId, toWithdraw);
            return Math.min(_amount, IERC20(want).balanceOf(address(this)));
        }
    }

    // compounds earnings and charges performance fee
    function _harvest() internal override returns (uint256, uint256) {
        require(pendingSTG() > 0, "no rewards to harvest");
        _claimRewards();
        uint256 outputBal = IERC20(rewardToken).balanceOf(address(this));
        if (outputBal > 0) {
            uint256 fee = _chargeFees(outputBal);
            addLiquidity();
            uint256 wantHarvested = _deposit();
            return (wantHarvested, fee);
        }
    }

    function _claimRewards() internal {
        IStargateChef(chef).deposit(chefId, 0);
    }

    function claimRewards() external onlyOwner {
        _claimRewards();
    }

    // performance fees
    function _chargeFees(uint256 _rewardToken)
        internal
        override
        returns (uint256)
    {
        IUniswapRouter(unirouter).swapExactTokensForTokens(
            _rewardToken,
            uint256(0),
            rewardTokenRoute,
            address(this),
            block.timestamp
        );

        uint256 nativeBal = (IERC20(NATIVE).balanceOf(address(this)) *
            totalFee) / 10_000;

        uint256 govFeeAmount = (nativeBal * govFee) / MAX_FEE;
        IERC20(NATIVE).safeTransfer(govFeeRecipient, govFeeAmount);

        uint256 strategistFee = nativeBal - govFeeAmount;
        IERC20(NATIVE).safeTransfer(strategist, strategistFee);
        return nativeBal; // total fees taken
    }

    // Adds liquidity to AMM and gets more LP tokens.
    function addLiquidity() internal {
        uint256 nativeBal = IERC20(NATIVE).balanceOf(address(this));

        IUniswapRouter(unirouter).swapExactTokensForTokens(
            nativeBal,
            uint256(0),
            nativeRoute,
            address(this),
            block.timestamp
        );
        stargateRouter.addLiquidity(
            poolId,
            IERC20(stargateAsset).balanceOf(address(this)),
            address(this)
        );
    }

    function _prepareRetirement() internal override {
        // unstake all LP and claim
        // manager can sweep the rewards and all the dust remaining
        if (balanceOfPool() != 0) {
            IStargateChef(chef).withdraw(chefId, balanceOfPool());
        }
    }
}