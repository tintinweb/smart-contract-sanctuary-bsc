/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

/**
 *Submitted for verification at Etherscan.io on 2022-11-04
*/

//SPDX-License-Identifier: MIT
// Sources flattened with hardhat v2.12.0 https://hardhat.org

// File contracts/constants.sol


pragma solidity ^0.8.17;

uint256 constant DAY_IN_SECONDS = 86_400;
uint16 constant DENOMINATOR = 10_000;
uint256 constant REWARD_DEBT_SCALE = 1e36;
uint256 constant REWARD_PER_SECOND_SCALE = 1e12;

uint256 constant BEFORE_30_DAYS_PENALTY = 5000; // 50%
uint256 constant BEFORE_90_DAYS_PENALTY = 4000; // 40%
uint256 constant BEFORE_180_DAYS_PENALTY = 2000; // 20%
uint256 constant BEFORE_250_DAYS_PENALTY = 1500; // 15%
uint256 constant BEFORE_360_DAYS_PENALTY = 1000; // 10%

uint256 constant BUSD_DECIMALS = 18;
uint256 constant USDT_DECIMALS = 18;


// File @openzeppelin/contracts/utils/[email protected]

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


// File @openzeppelin/contracts/access/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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


// File contracts/AccessControl.sol


pragma solidity ^0.8.17;


contract AccessControl is Ownable {
    mapping(address => bool) private admins;

    event AdminAdded(address indexed account, address indexed sender);
    event AdminRemoved(address indexed account, address indexed sender);

    constructor() {
        admins[_msgSender()] = true;
        emit AdminAdded(_msgSender(), _msgSender());
    }

    modifier onlyAdmin() {
        require(admins[_msgSender()], "AccessControl: caller is not an admin");
        _;
    }

    modifier onlyOwnerOrCaller(address caller) {
        require(
            owner() == _msgSender() || caller == _msgSender(),
            "AccessControl: caller is not the owner or caller"
        );
        _;
    }

    function isAdmin(address account) external view returns (bool) {
        return admins[account];
    }

    function addAdmin(address account) public onlyOwner {
        require(
            account != address(0),
            "AccessControl: account is the zero address"
        );
        require(!admins[account], "AccessControl: account is already an admin");

        admins[account] = true;
        emit AdminAdded(account, _msgSender());
    }

    function removeAdmin(address account) public onlyOwner {
        require(
            account != address(0),
            "AccessControl: account is the zero address"
        );
        require(admins[account], "AccessControl: account is not an admin");

        admins[account] = false;
        emit AdminRemoved(account, _msgSender());
    }

    function renounceAdmin() public {
        require(admins[_msgSender()], "AccessControl: caller is not an admin");

        admins[_msgSender()] = false;
        emit AdminRemoved(_msgSender(), _msgSender());
    }
}


// File contracts/FeeCollector.sol


pragma solidity ^0.8.17;

contract FeeCollector is AccessControl {
    address private feeCollector;

    constructor() {
        feeCollector = _msgSender();
    }

    function setFeeCollector(address _feeCollector) external onlyAdmin {
        feeCollector = _feeCollector;
    }

    function getFeeCollector() public view returns (address) {
        return feeCollector;
    }
}


// File @openzeppelin/contracts/token/ERC20/[email protected]

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}


// File @openzeppelin/contracts/utils/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
                /// @solidity memory-safe-assembly
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


// File @openzeppelin/contracts/token/ERC20/utils/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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


// File contracts/LinkBridgeLockedStaking.sol


pragma solidity ^0.8.17;





// each user deposit is saved in an object like this
struct DepositInfo {
    uint256 amount;
    uint256 depositTime;
    uint256 rewardDebt;
}

// Info of each pool.
struct PoolInfo {
    uint256 accERC20PerShare; // Accumulated ERC20s per share, times 1e36.
    uint256 stakedAmount; // Amount of @lpToken staked in this pool
    uint128 lockPeriod; // lock period in days
    uint128 lastRewardTime; // Last time where ERC20s distribution occurs.
}

contract LinkBridgeLockedStaking is AccessControl, FeeCollector {
    using SafeERC20 for IERC20;

    IERC20 public immutable wethLnkbLp;
    IERC20 public immutable lnkbToken;

    uint256 public immutable startTime;
    uint256 public rewardsPerSecond;
    uint256 public paidOut;

    // time when the last rewardPerSecond has changed
    uint128 public lastEmissionChange;
    uint128 public apy = 1800; // 18% APY

    // all pending rewards before last rewards per second change
    uint256 public rewardsAmountBeforeLastChange;

    PoolInfo public poolInfo = PoolInfo(0, 0, 365, 0);

    // index => userDeposit info
    mapping(uint256 => DepositInfo) public usersDeposits;
    uint256 private _depositsLength;

    // Info of each user that stakes LP tokens.
    // poolId => user => userInfoId's
    mapping(address => uint256[]) public userDepositsIndexes;

    event Deposit(
        address indexed user,
        uint256 indexed depositId,
        uint256 amount,
        uint256 depositTime
    );

    event Withdraw(
        address indexed user,
        uint256 indexed depositId,
        uint256 amount
    );

    event LockRemoved(
        address indexed user,
        uint256 indexed depositId,
        uint256 amount
    );

    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed depositId,
        uint256 amount
    );

    event WithdrawWithPenalty(
        address indexed user,
        uint256 indexed depositId,
        uint256 amount,
        uint256 leftAmount,
        uint256 penaltyManount
    );

    event RewardPaid(
        address indexed user,
        uint256 indexed depositId,
        uint256 reward
    );

    constructor(
        IERC20 _wethLnkbLp,
        IERC20 _lnkbToken,
        uint256 _startTime
    ) {
        require(address(_wethLnkbLp) != address(0), "ZERO");
        wethLnkbLp = _wethLnkbLp;
        require(address(_lnkbToken) != address(0), "ZERO");
        lnkbToken = _lnkbToken;
        startTime = _startTime;
    }

    modifier onlyWhenStarted() {
        require(block.timestamp >= startTime, "NOT_STARTED");
        _;
    }

    function setLockPeriod(uint128 _newLockPeriod) external onlyAdmin {
        require(_newLockPeriod > 0, "ZERO");
        poolInfo.lockPeriod = _newLockPeriod;
    }

    function setApy(uint128 _apy) external onlyAdmin {
        apy = _apy;
        updatePool();
        _updateRewardsPerSecond();
    }

    function updateRewardsPerSecond() external {
        _updateRewardsPerSecond();
        updatePool();
    }

    function getUserDeposits(address _user)
        external
        view
        returns (DepositInfo[] memory)
    {
        uint256[] memory deposits = userDepositsIndexes[_user];
        //DepositInfo[] memory _depositsInfo = new DepositInfo[](deposits.length);
        DepositInfo[] memory _userDeposits = new DepositInfo[](deposits.length);

        uint256 accERC20PerShare = poolInfo.accERC20PerShare;
        uint256 lpSupply = poolInfo.stakedAmount;
        if (block.timestamp > poolInfo.lastRewardTime && lpSupply != 0) {
            uint256 lastTime = block.timestamp;
            uint256 nrOfBlocks = lastTime - poolInfo.lastRewardTime;
            uint256 erc20Reward = (nrOfBlocks * rewardsPerSecond) /
                REWARD_PER_SECOND_SCALE;
            accERC20PerShare =
                accERC20PerShare +
                (erc20Reward * (REWARD_DEBT_SCALE)) /
                (lpSupply);
        }

        for (uint256 i = 0; i < deposits.length; i++) {
            _userDeposits[i] = usersDeposits[deposits[i]];
            _userDeposits[i].rewardDebt =
                (_userDeposits[i].amount * accERC20PerShare) /
                REWARD_DEBT_SCALE -
                _userDeposits[i].rewardDebt;
        }

        return _userDeposits;
    }

    /**
     * @dev Returns the total amount of tokens staked in the pool by @_user
     * @param _user The address of the user
     * @return totalDeposit The total amount of tokens staked in the pool by @_user
     */
    function getTotalUserDeposit(address _user)
        external
        view
        returns (uint256 totalDeposit)
    {
        uint256[] memory deposits = userDepositsIndexes[_user];

        for (uint256 i = 0; i < deposits.length; i++) {
            totalDeposit += usersDeposits[deposits[i]].amount;
        }
        return totalDeposit;
    }

    function getUserPendingRewards(address _user)
        external
        view
        returns (uint256 pending)
    {
        DepositInfo[] memory _userDeposits = _getUserDeposits(_user);
        uint256 accERC20PerShare = poolInfo.accERC20PerShare;
        uint256 lpSupply = poolInfo.stakedAmount;

        if (block.timestamp > poolInfo.lastRewardTime && lpSupply != 0) {
            uint256 lastTime = block.timestamp;
            uint256 nrOfBlocks = lastTime - poolInfo.lastRewardTime;
            uint256 erc20Reward = (nrOfBlocks * rewardsPerSecond) /
                REWARD_PER_SECOND_SCALE;
            accERC20PerShare =
                accERC20PerShare +
                (erc20Reward * (REWARD_DEBT_SCALE)) /
                (lpSupply);
        }
        for (uint256 i = 0; i < _userDeposits.length; i++) {
            pending +=
                ((_userDeposits[i].amount * accERC20PerShare) /
                    REWARD_DEBT_SCALE) -
                _userDeposits[i].rewardDebt;
        }
        return pending;
    }

    function recoverToken(address _token, uint256 _amount) external onlyOwner {
        require(_token != address(0), "ZERO");
        require(_amount > 0, "ZERO");

        IERC20 token = IERC20(_token);
        if (_token == address(wethLnkbLp)) {
            uint256 balance = token.balanceOf(address(this));
            require(balance - poolInfo.stakedAmount >= _amount, "INSUFFICIENT");
            token.safeTransfer(_msgSender(), _amount);
        } else {
            token.safeTransfer(_msgSender(), _amount);
        }
    }

    function unlockDeposit(address _user, uint256 _depositIndex)
        external
        onlyAdmin
    {
        uint256[] storage userDeposits = userDepositsIndexes[_user];
        uint256 depositId = userDeposits[_depositIndex];
        DepositInfo memory _deposit = usersDeposits[depositId];
        uint256 amount = _deposit.amount;
        poolInfo.stakedAmount -= _deposit.amount;
        delete usersDeposits[depositId];
        wethLnkbLp.safeTransfer(_user, amount);

        _removeDeposit(_user, _depositIndex);
        require(_deposit.amount > 0, "ZERO");
        emit LockRemoved(_user, depositId, _deposit.amount);
    }

    /**
        Withdraw without caring about rewards only if the deposit is unlocked. EMERGENCY ONLY.
     */
    function emergencyWithdraw(uint256 _index) external {
        uint256[] storage userDeposits = userDepositsIndexes[_msgSender()];
        uint256 depositId = userDeposits[_index];
        DepositInfo storage depositInfo = usersDeposits[depositId];

        require(depositInfo.amount > 0, "ZERO");
        require(
            depositInfo.depositTime + poolInfo.lockPeriod * DAY_IN_SECONDS <=
                block.timestamp,
            "LOCKED"
        );
        uint256 amount = depositInfo.amount;
        poolInfo.stakedAmount -= amount;
        delete usersDeposits[depositId];
        wethLnkbLp.safeTransfer(_msgSender(), amount);
        _removeDeposit(_msgSender(), _index);
        emit EmergencyWithdraw(_msgSender(), depositId, amount);
    }

    function deposit(uint256 _amount) external onlyWhenStarted {
        require(_amount > 0, "ZERO");
        uint256[] storage userDeposits = userDepositsIndexes[_msgSender()];

        wethLnkbLp.safeTransferFrom(_msgSender(), address(this), _amount);
        updatePool();
        poolInfo.stakedAmount += _amount;
        uint256 length = _depositsLength;
        userDeposits.push(length);
        usersDeposits[length] = DepositInfo(
            _amount,
            uint128(block.timestamp),
            (_amount * poolInfo.accERC20PerShare) / REWARD_DEBT_SCALE
        );
        _depositsLength++;
        _updateRewardsPerSecond();
        //updatePool();
        emit Deposit(_msgSender(), length, _amount, block.timestamp);
    }

    function unstakeUnlockedDeposit(uint256 _index) external {
        uint256[] storage userDeposits = userDepositsIndexes[_msgSender()];
        require(userDeposits.length > _index, "INVALID_INDEX");
        uint256 depositId = userDeposits[_index];

        DepositInfo storage depositInfo = usersDeposits[depositId];
        require(
            depositInfo.depositTime + poolInfo.lockPeriod * DAY_IN_SECONDS <=
                block.timestamp,
            "LOCKED"
        );

        uint256 amount = depositInfo.amount;
        require(amount > 0, "ZERO");
        updatePool();

        uint256 pending = ((depositInfo.amount * poolInfo.accERC20PerShare) /
            REWARD_DEBT_SCALE) - depositInfo.rewardDebt;
        if (pending > 0) {
            lnkbToken.safeTransfer(_msgSender(), pending);
            paidOut += pending;
            emit RewardPaid(_msgSender(), depositId, pending);
        }
        poolInfo.stakedAmount -= amount;

        delete usersDeposits[depositId];

        wethLnkbLp.safeTransfer(_msgSender(), amount);

        _removeDeposit(_msgSender(), _index);
        _updateRewardsPerSecond();
        emit Withdraw(_msgSender(), depositId, amount);
    }

    function unstakeWithPenalty(uint256 _index) external {
        uint256[] storage userDeposits = userDepositsIndexes[_msgSender()];
        require(userDeposits.length > _index, "INVALID_INDEX");
        uint256 depositId = userDeposits[_index];

        DepositInfo memory depositInfo = usersDeposits[depositId];
        require(
            depositInfo.depositTime + poolInfo.lockPeriod * DAY_IN_SECONDS >
                block.timestamp,
            "UNLOCKED"
        );

        uint256 amount = depositInfo.amount;
        require(amount > 0, "ZERO");
        updatePool();

        uint256 pending = ((depositInfo.amount * poolInfo.accERC20PerShare) /
            REWARD_DEBT_SCALE) - depositInfo.rewardDebt;
        if (pending > 0) {
            lnkbToken.safeTransfer(_msgSender(), pending);
            paidOut += pending;
            emit RewardPaid(_msgSender(), depositId, pending);
        }

        address feeCollector = getFeeCollector();
        uint256 penalty = getPenalty(depositInfo.depositTime);

        uint256 penaltyAmount = (amount * penalty) / DENOMINATOR;
        uint256 leftAmount = amount - penaltyAmount;

        delete usersDeposits[depositId];

        poolInfo.stakedAmount -= amount;

        wethLnkbLp.safeTransfer(feeCollector, penaltyAmount);
        wethLnkbLp.safeTransfer(_msgSender(), leftAmount);

        _removeDeposit(_msgSender(), _index);
        _updateRewardsPerSecond();
        emit WithdrawWithPenalty(
            _msgSender(),
            depositId,
            amount,
            leftAmount,
            penaltyAmount
        );
    }

    function updatePool() public {
        if (block.timestamp <= poolInfo.lastRewardTime) {
            return;
        }

        uint256 lpSupply = poolInfo.stakedAmount;
        if (lpSupply == 0) {
            poolInfo.lastRewardTime = uint128(block.timestamp);
            return;
        }

        uint256 nrOfSeconds = block.timestamp - poolInfo.lastRewardTime;
        uint256 bep20Reward = (nrOfSeconds * rewardsPerSecond) /
            REWARD_PER_SECOND_SCALE;

        poolInfo.accERC20PerShare =
            poolInfo.accERC20PerShare +
            ((bep20Reward * REWARD_DEBT_SCALE) / lpSupply);

        poolInfo.lastRewardTime = uint128(block.timestamp);
    }

    function getPenalty(uint256 timeDepositLock)
        public
        view
        returns (uint256 penalty)
    {
        uint256 timeSinceLock = (block.timestamp - timeDepositLock) /
            DAY_IN_SECONDS;
        if (timeSinceLock < 30) {
            penalty = BEFORE_30_DAYS_PENALTY;
        } else if (timeSinceLock < 90) {
            penalty = BEFORE_90_DAYS_PENALTY;
        } else if (timeSinceLock < 180) {
            penalty = BEFORE_180_DAYS_PENALTY;
        } else if (timeSinceLock < 250) {
            penalty = BEFORE_250_DAYS_PENALTY;
        } else if (timeSinceLock < 365) {
            penalty = BEFORE_360_DAYS_PENALTY;
        }
    }

    /**
       @dev View function for total reward the farm has yet to pay out.
    */
    function totalPending() public view returns (uint256) {
        if (block.timestamp <= startTime) {
            return 0;
        }
        return _totalPastRewards() - paidOut;
    }

    function _getLPStakeInRewardTokenValue() internal view returns (uint256) {
        uint256 lnkbBalanceOfLPToken = lnkbToken.balanceOf(address(wethLnkbLp));

        uint256 valueOfLp = lnkbBalanceOfLPToken * 2;

        uint256 totalLpSupply = wethLnkbLp.totalSupply();

        return ((valueOfLp) * poolInfo.stakedAmount) / totalLpSupply; // $RewardToken value of LP
    }

    // Change the rewardPerBlock
    function _updateRewardsPerSecond() internal {
        uint256 lpValue = _getLPStakeInRewardTokenValue();

        uint256 newRewardsPerSeconds = (lpValue *
            apy *
            REWARD_PER_SECOND_SCALE) /
            DENOMINATOR /
            365 /
            DAY_IN_SECONDS;

        uint256 totalRewardsTillNow = _totalPastRewards();
        //uint256 leftRewards = totalBEP20Rewards - totalRewardsTillNow;

        // push this change into history
        if (block.timestamp >= startTime) {
            lastEmissionChange = uint128(block.timestamp);
            rewardsAmountBeforeLastChange = totalRewardsTillNow;
        } else {
            lastEmissionChange = uint128(startTime);
            rewardsAmountBeforeLastChange = 0;
        }
        rewardsPerSecond = newRewardsPerSeconds;
    }

    function _removeDeposit(address _user, uint256 _index) internal {
        uint256[] storage userDeposits = userDepositsIndexes[_user];
        uint256 lastDepositIndex = userDeposits.length - 1;
        uint256 lastDepositId = userDeposits[lastDepositIndex];
        userDeposits[_index] = lastDepositId;
        userDeposits.pop();
    }

    function _getUserDeposits(address _user)
        internal
        view
        returns (DepositInfo[] memory)
    {
        uint256[] memory deposits = userDepositsIndexes[_user];
        DepositInfo[] memory _userDeposits = new DepositInfo[](deposits.length);
        for (uint256 i = 0; i < deposits.length; i++) {
            _userDeposits[i] = usersDeposits[deposits[i]];
        }
        return _userDeposits;
    }

    function _totalPastRewards() internal view returns (uint256) {
        if (block.timestamp < startTime) return 0;

        uint256 lastTime = block.timestamp;

        return
            rewardsAmountBeforeLastChange +
            (rewardsPerSecond * (lastTime - lastEmissionChange)) /
            REWARD_PER_SECOND_SCALE;
    }
}