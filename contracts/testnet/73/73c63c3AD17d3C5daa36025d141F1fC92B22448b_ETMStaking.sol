/**
 *Submitted for verification at BscScan.com on 2022-03-07
*/

// File: @openzeppelin/contracts/utils/math/Math.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;



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

// File: ETMStaking.sol


pragma solidity 0.8.12;





/**
* @title Roles
* @dev Library for managing addresses assigned to a Role.
*/
library Roles {
   struct Role {
       mapping (address => bool) bearer;
   }
 
   /**
    * @dev give an account access to this role
    */
   function add(Role storage role, address account) internal {
       require(account != address(0));
       require(!has(role, account));
 
       role.bearer[account] = true;
   }
 
   /**
    * @dev remove an account's access to this role
    */
   function remove(Role storage role, address account) internal {
       require(account != address(0));
       require(has(role, account));
 
       role.bearer[account] = false;
   }
 
   /**
    * @dev check if an account has this role
    * @return bool
    */
   function has(Role storage role, address account) internal view returns (bool) {
       require(account != address(0));
       return role.bearer[account];
   }
}
 
/**
* @title WhitelistAdminRole
* @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.
*/
contract WhitelistAdminRole {
   using Roles for Roles.Role;
 
   event WhitelistAdminAdded(address indexed account);
   event WhitelistAdminRemoved(address indexed account);
 
   Roles.Role private _whitelistAdmins;
 
   constructor () {
       _addWhitelistAdmin(msg.sender);
   }
 
   modifier onlyWhitelistAdmin() {
       require(isWhitelistAdmin(msg.sender));
       _;
   }
 
   function isWhitelistAdmin(address account) public view returns (bool) {
       return _whitelistAdmins.has(account);
   }
 
   function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
       _addWhitelistAdmin(account);
   }
 
   function renounceWhitelistAdmin() public {
       _removeWhitelistAdmin(msg.sender);
   }
 
   function _addWhitelistAdmin(address account) internal {
       _whitelistAdmins.add(account);
       emit WhitelistAdminAdded(account);
   }
 
   function _removeWhitelistAdmin(address account) internal {
       _whitelistAdmins.remove(account);
       emit WhitelistAdminRemoved(account);
   }
}
 
/**
* @title WhitelistedRole
* @dev Whitelisted accounts have been approved by a WhitelistAdmin to perform certain actions (e.g. participate in a
* crowdsale). This role is special in that the only accounts that can add it are WhitelistAdmins (who can also remove
* it), and not Whitelisteds themselves.
*/
contract WhitelistedRole is WhitelistAdminRole {
   using Roles for Roles.Role;
 
   event WhitelistedAdded(address indexed account);
   event WhitelistedRemoved(address indexed account);
 
   Roles.Role private _whitelisteds;
 
   modifier onlyWhitelisted() {
       require(isWhitelisted(msg.sender));
       _;
   }
 
   function isWhitelisted(address account) public view returns (bool) {
       return _whitelisteds.has(account);
   }
 
   function addWhitelisted(address account) internal onlyWhitelistAdmin {
       _addWhitelisted(account);
   }
 
   function removeWhitelisted(address account) internal onlyWhitelistAdmin {
       _removeWhitelisted(account);
   }
 
   function renounceWhitelisted() internal virtual {
       _removeWhitelisted(msg.sender);
   }
 
   function _addWhitelisted(address account) internal {
       _whitelisteds.add(account);
       emit WhitelistedAdded(account);
   }
 
   function _removeWhitelisted(address account) internal {
       _whitelisteds.remove(account);
       emit WhitelistedRemoved(account);
   }
}

abstract contract LockStaking is Context {
 
   event StakingLocked(address account);
 
   event StakingUnLocked(address account);
 
   bool private _locked;
 
   constructor() {
       _locked = false;
   }
 
   function stakingLocked() public view virtual returns (bool) {
       return _locked;
   }
 
   modifier whenNotStakingLocked() {
       require(!stakingLocked(), "LockStaking: locked");
       _;
   }
 
   modifier whenStakingLocked() {
       require(stakingLocked(), "LockStaking: not locked");
       _;
   }
 
   function _lockStaking() internal virtual whenNotStakingLocked {
       _locked = true;
       emit StakingLocked(_msgSender());
   }
 
   function _unlockstaking() internal virtual whenStakingLocked {
       _locked = false;
       emit StakingUnLocked(_msgSender());
   }
}

abstract contract EnableTokensClaimable is Context {
 
   event TokensClaimableEnabled(address account);
 
   event TokensClaimableNotEnabled(address account);
 
   bool private _enabled;
 
   constructor() {
       _enabled = false;
   }
 
   function tokensClaimableNotEnabled() public view virtual returns (bool) {
       return _enabled;
   }
 
   modifier whenTokensClaimableNotEnabled() {
       require(tokensClaimableNotEnabled(), "EnableTokensClaimable: enabled");
       _;
   }
 
   modifier whenTokensClaimableEnabled() {
       require(!tokensClaimableNotEnabled(), "EnableTokensClaimable: not enabled");
       _;
   }
 
   function _enableTokensClaimable() internal virtual whenTokensClaimableNotEnabled {
       _enabled = true;
       emit TokensClaimableEnabled(_msgSender());
   }
 
   function _unEnableTokensClaimable() internal virtual whenTokensClaimableEnabled {
       _enabled = false;
       emit TokensClaimableNotEnabled(_msgSender());
   }
}

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
 
abstract contract ReentrancyGuard {
   // Booleans are more expensive than uint256 or any type that takes up a full
   // word because each write operation emits an extra SLOAD to first read the
   // slot's contents, replace the bits taken up by the boolean, and then write
   // back. This is the compiler's defense against contract upgrades and
   // pointer aliasing, and it cannot be disabled.
 
   // The values being non-zero value makes deployment a bit more expensive,
   // but in exchange the refund on every call to nonReentrant will be lower in
   // amount. Since refunds are capped to a percentage of the total
   // transaction's gas, it is best to keep them low in cases like this one, to
   // increase the likelihood of the full refund coming into effect.
   uint256 private constant _NOT_ENTERED = 1;
   uint256 private constant _ENTERED = 2;
 
   uint256 private _status;
 
   constructor() {
       _status = _NOT_ENTERED;
   }
 
   /**
    * @dev Prevents a contract from calling itself, directly or indirectly.
    * Calling a `nonReentrant` function from another `nonReentrant`
    * function is not supported. It is possible to prevent this from happening
    * by making the `nonReentrant` function external, and making it call a
    * `private` function that does the actual work.
    */
   modifier nonReentrant() {
       // On the first call to nonReentrant, _notEntered will be true
       require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
 
       // Any calls to nonReentrant after this point will fail
       _status = _ENTERED;
 
       _;
 
       // By storing the original value once again, a refund is triggered (see
       // https://eips.ethereum.org/EIPS/eip-2200)
       _status = _NOT_ENTERED;
   }
}

contract ETMStaking is WhitelistedRole, Pausable, EnableTokensClaimable, LockStaking, ReentrancyGuard {

    event StakingBegin(address admin, uint256 stakingFunds);
    event Deposit(address indexed from, address indexed to, uint64 indexed stakeIndex, uint256 amount);
    event Withdraw(address indexed from, address indexed withdrawer, uint256 fund, uint256 reward, uint64 indexed stakeIndex);
    event WithdrawAll(address indexed from, address indexed withdrawer, uint256 fund, uint256 reward, uint8 totalStake);
    event RewardAdded(address admin, uint256 quantity);
    event RewardRevoked(address revoker, uint256 quantity);
    event PoolLimitChanged(address admin, uint256 newValue);
    event StakingThresholdChanged(address admin, uint8 newValue);
    event MaxQuantityChanged(address admin, uint256 newValue);
    event MinQuantityChanged(address admin, uint256 newValue);

    address public etmToken;

    uint64 constant DAY_IN_SECONDS = 86400;
    uint64 constant YEAR_IN_SECONDS = 31536000;
    uint8 constant APR_DAY15_MULTIPLIER = 40;
    uint8 constant APR_DAY30_MULTIPLIER = 60;
    uint8 constant APR_DAY60_MULTIPLIER = 90;

    uint256 public rewardPool; 
    uint256 public poolLimit; 
    uint8 public stakingThreshold; 
    uint256 public maxQuantity; 
    uint256 public minQuantity; 

    struct userDeposit {
        uint256 amount;
        uint256 depositTime;
    }
    mapping(address => uint256) private _userDepositTotal;
    mapping(address => uint8) private _numUserDeposits;
    mapping(address => userDeposit[]) private _userDeposits;

    uint256 public totalDeposited;
    uint256 public userFunds;
    uint256 public stakingFunds;

    constructor (
        address etmToken_,
        uint256 rewardPool_,
        uint256 poolLimit_,
        uint8 stakingThreshold_,
        uint256 maxQuantity_,
        uint256 minQuantity_
    ) {
        etmToken = etmToken_;
        rewardPool = rewardPool_;
        poolLimit = poolLimit_;
        stakingThreshold = stakingThreshold_;
        maxQuantity = maxQuantity_;
        minQuantity = minQuantity_;
        _lockStaking();
    }

    function startStaking() public whenNotPaused whenStakingLocked onlyWhitelistAdmin {
        require(IERC20(etmToken).balanceOf(address(this)) >= rewardPool, "ETMStaking: not enough staking rewards");
        stakingFunds = rewardPool;
        _unlockstaking();
        emit StakingBegin(_msgSender(), stakingFunds);
    }

    function stake(uint256 depositAmount) public whenNotPaused whenNotStakingLocked {
        require(IERC20(etmToken).balanceOf(_msgSender()) >= depositAmount, "ETMStaking: Not enough ETM tokens");
        require(_userDepositTotal[_msgSender()] + depositAmount >= minQuantity, "ETMStaking: DepositAmount too low");
        require(_userDepositTotal[_msgSender()] + depositAmount <= maxQuantity, "ETMStaking: DepositAmount too high");
        require(_numUserDeposits[_msgSender()] < stakingThreshold, "ETMStaking: You can't stake more");
        require(totalDeposited + depositAmount <= poolLimit, "ETMStaking: Contract staking capacity exceeded");

        _userDepositTotal[_msgSender()] += depositAmount;
        _numUserDeposits[_msgSender()] += 1;
        _userDeposits[_msgSender()].push(userDeposit({
            amount: depositAmount,
            depositTime: block.timestamp
        }));

        totalDeposited += depositAmount;
        userFunds += depositAmount;

        SafeERC20.safeTransferFrom(IERC20(etmToken), _msgSender(), address(this), depositAmount);
        emit Deposit(_msgSender(), address(this), uint64(_userDeposits[_msgSender()].length - 1), depositAmount);
    }

    function unStakeAll() public whenNotPaused whenTokensClaimableEnabled nonReentrant {
        uint256 withdrawalAmount = _userDepositTotal[_msgSender()];
        require(withdrawalAmount > 0, "ETMStaking: Nothing to withdraw");
        uint256 totalReward = getAllReward(_msgSender(), block.timestamp);
        uint8 totalStake = _numUserDeposits[_msgSender()];
        _userDepositTotal[_msgSender()] = 0;
        _numUserDeposits[_msgSender()] = 0;
        userFunds -= withdrawalAmount;
        stakingFunds -= totalReward;
        for (uint64 i = 0; i < uint64(_userDeposits[_msgSender()].length); i++) {
            delete _userDeposits[_msgSender()][i];
        }
        SafeERC20.safeTransfer(IERC20(etmToken), _msgSender(), withdrawalAmount);
        SafeERC20.safeTransfer(IERC20(etmToken), _msgSender(), totalReward);
        emit WithdrawAll(address(this), _msgSender(), withdrawalAmount, totalReward, totalStake);
    }

    function unStakes(uint64[] memory indexes) public whenNotPaused whenTokensClaimableEnabled nonReentrant {
        for (uint8 i = 0; i < indexes.length; i++) {
            uint256 withdrawalAmount = _userDeposits[_msgSender()][indexes[i]].amount;
            require(withdrawalAmount > 0, "ETMStaking: Nothing to withdraw at this index");
            uint256 reward = getReward(_msgSender(), block.timestamp, indexes[i]);
            _userDepositTotal[_msgSender()] -= withdrawalAmount;
            _numUserDeposits[_msgSender()] -= 1;
            userFunds -= withdrawalAmount;
            stakingFunds -= reward;
            delete _userDeposits[_msgSender()][indexes[i]];
            SafeERC20.safeTransfer(IERC20(etmToken), _msgSender(), withdrawalAmount);
            SafeERC20.safeTransfer(IERC20(etmToken), _msgSender(), reward);
            emit Withdraw(address(this), _msgSender(), withdrawalAmount, reward, indexes[i]);
        }
    }

    // function unStake(uint64 index) public whenNotPaused whenTokensClaimableEnabled nonReentrant {
    //     uint256 withdrawalAmount = _userDeposits[_msgSender()][index].amount;
    //     require(withdrawalAmount > 0, "ETMStaking: Nothing to withdraw at this index");
    //     uint256 reward = getReward(_msgSender(), block.timestamp, index);
    //     _userDepositTotal[_msgSender()] -= withdrawalAmount;
    //     _numUserDeposits[_msgSender()] -= 1;
    //     userFunds -= withdrawalAmount;
    //     stakingFunds -= reward;
    //     delete _userDeposits[_msgSender()][index];
    //     SafeERC20.safeTransfer(IERC20(etmToken), _msgSender(), withdrawalAmount);
    //     SafeERC20.safeTransfer(IERC20(etmToken), _msgSender(), reward);
    //     emit Withdraw(address(this), _msgSender(), withdrawalAmount, reward, index);
    // }

    function addReward() public whenNotPaused whenNotStakingLocked onlyWhitelistAdmin {
        uint256 rewardAdded = IERC20(etmToken).balanceOf(address(this)) - (userFunds + stakingFunds);
        require(rewardAdded > 0, "ETMStaking: no rewards added");
        stakingFunds += rewardAdded;
        rewardPool += rewardAdded;
        emit RewardAdded(_msgSender(), rewardAdded);
    }

    function revokeReward(uint256 amount) public whenNotPaused whenNotStakingLocked onlyWhitelistAdmin nonReentrant {
        require(IERC20(etmToken).balanceOf(address(this)) >= amount, "ETMStaking: Amount too high");
        rewardPool -= amount;
        stakingFunds -= amount;
        SafeERC20.safeTransfer(IERC20(etmToken), _msgSender(), amount);
        emit RewardRevoked(_msgSender(), amount);
    }

    function getAllReward(address account, uint256 timestamp) public view returns(uint256) {
        uint256 totalReward;
        for (uint64 i = 0; i < uint64(_userDeposits[_msgSender()].length); i++) {
            if (_userDeposits[_msgSender()][i].amount > 0) totalReward += getReward(account, timestamp, i);
        }
        return totalReward;
    }

    function getReward(address account, uint256 timestamp, uint64 index) public view returns(uint256) {
        (uint256 depositAmount, uint256 userDepositTime) = getUserDepositAtIndex(account, index);
        uint256 period = timestamp - userDepositTime;
        if (period >= 60*DAY_IN_SECONDS) {
            return depositAmount*APR_DAY60_MULTIPLIER*60*DAY_IN_SECONDS/(YEAR_IN_SECONDS*100);
        } else if (period >= 30*DAY_IN_SECONDS && period < 60*DAY_IN_SECONDS) {
            return depositAmount*APR_DAY30_MULTIPLIER*30*DAY_IN_SECONDS/(YEAR_IN_SECONDS*100);
        } else if (period >= 15*DAY_IN_SECONDS && period < 30*DAY_IN_SECONDS) {
            return depositAmount*APR_DAY15_MULTIPLIER*15*DAY_IN_SECONDS/(YEAR_IN_SECONDS*100);
        } else return 0;
    }

    function updatePoolLimit(uint256 value) public whenNotPaused onlyWhitelistAdmin {
        poolLimit = value;
        emit PoolLimitChanged(_msgSender(), value);
    }

    function updateStakingThreshold(uint8 value) public whenNotPaused onlyWhitelistAdmin {
        stakingThreshold = value;
        emit StakingThresholdChanged(_msgSender(), value);
    }

    function updateMaxQuantity(uint256 value) public whenNotPaused onlyWhitelistAdmin {
        maxQuantity = value;
        emit MaxQuantityChanged(_msgSender(), value);
    }

    function updateMinQuantity(uint256 value) public whenNotPaused onlyWhitelistAdmin {
        minQuantity = value;
        emit MinQuantityChanged(_msgSender(), value);
    }

    function stopStaking() public whenNotPaused whenNotStakingLocked onlyWhitelistAdmin {
        _lockStaking();
    }

    function unlockstaking() public whenNotPaused whenStakingLocked onlyWhitelistAdmin {
        _unlockstaking();
    }

    function enableWithdraw() public whenNotPaused whenTokensClaimableNotEnabled onlyWhitelistAdmin {
        _enableTokensClaimable();
    }

    function stopWithdraw() public whenNotPaused whenTokensClaimableEnabled onlyWhitelistAdmin {
        _unEnableTokensClaimable();
    }

    function pause() public whenNotPaused onlyWhitelistAdmin {
        _pause();
    }

    function unpause() public whenPaused onlyWhitelistAdmin {
        _unpause();
    }

    function getUserTotalDeposited(address account) public view returns(uint256) {
        return _userDepositTotal[account];
    }

    function getNumUserDeposits(address account) public view returns(uint256) {
        return _numUserDeposits[account];
    }

    function getUserDeposits(address account) public view returns(userDeposit[] memory) {
        return _userDeposits[account];
    }

    function getUserDepositAtIndex(address account, uint64 index) public view returns(uint256 amount, uint256 depositTime) {
        return (_userDeposits[account][index].amount, _userDeposits[account][index].depositTime);
    }
}