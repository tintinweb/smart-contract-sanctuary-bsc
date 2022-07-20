/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

// Sources flattened with hardhat v2.9.6 https://hardhat.org

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


// File @openzeppelin/contracts/utils/[email protected]

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


// File @openzeppelin/contracts/token/ERC20/utils/[email protected]

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


// File @openzeppelin/contracts/security/[email protected]

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
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


// File @openzeppelin/contracts/proxy/utils/[email protected]

// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !Address.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}


// File contracts/KalmarLpStaking.sol


pragma solidity 0.8.12;




interface IRewardVault {
  function getReward(address _to, uint256 _amount) external ;
}

interface ITokenLocker {
    function userWeight(address _user) external returns (uint256);
    function totalWeight() external view returns (uint256);
}

// based on the Sushi MasterChef
// https://github.com/sushiswap/sushiswap/blob/master/contracts/MasterChef.sol
contract KalmarLpStaking is ReentrancyGuard, Initializable {
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 depositAmount;  // The amount of tokens deposited into the contract.
        uint256 adjustedAmount; // The user's effective balance after boosting, used to calculate emission rates.
        uint256 rewardDebt;
        uint256 claimable;
    }
    // Info of each pool.
    struct PoolInfo {
        uint256 adjustedSupply;
        uint256 rewardsPerSecond;
        uint256 lastRewardTime; // Last second that reward distribution occurs.
        uint256 accRewardPerShare; // Accumulated rewards per share, times 1e12. See below.
    }

    IRewardVault public rewardVault;
    ITokenLocker public tokenLocker;

    // Info of each pool.
    address[] public registeredTokens;
    mapping(address => PoolInfo) public poolInfo;

    // token => user => Info of each user that stakes LP tokens.
    mapping(address => mapping(address => UserInfo)) public userInfo;
    // The timestamp when reward mining starts.
    uint256 public startTime;

    // account earning rewards => receiver of rewards for this account
    // if receiver is set to address(0), rewards are paid to the earner
    // this is used to aid 3rd party contract integrations
    mapping (address => address) public claimReceiver;

    // when set to true, other accounts cannot call
    // `deposit` or `claim` on behalf of an account
    mapping(address => bool) public blockThirdPartyActions;
    mapping(address => bool) public Admins;
    mapping(address => bool) public whitelisted;

    event Deposit(
        address indexed user,
        address indexed token,
        uint256 amount
    );
    event Withdraw(
        address indexed user,
        address indexed token,
        uint256 amount
    );
    event EmergencyWithdraw(
        address indexed token,
        address indexed user,
        uint256 amount
    );
    event ClaimedReward(
        address indexed caller,
        address indexed claimer,
        address indexed receiver,
        uint256 amount
    );
    event FeeClaimSuccess(address pool);
    event FeeClaimRevert(address pool);
    event AddWhiteListAddress(address indexed whitelistAddress);
    event RemoveWhiteListAddress(address indexed whitelistAddress);

    /* ========== CONSTRUCTOR ========== */

    constructor() { }
    
    function initialize(
        ITokenLocker _tokenLocker,
        uint256 _startTime,
        IRewardVault _rewardVault
    ) public initializer {
        startTime = _startTime;
        tokenLocker = _tokenLocker;
        rewardVault = _rewardVault;
        Admins[msg.sender] = true;
    }

    modifier onlyAdmin() {
        require(Admins[msg.sender], "admin: wut?");
        _;
    }

    modifier onlyWhitelistStake() {
        require(whitelisted[msg.sender] , "Caller is not whitelisted contract");
        _;
    }

    /**
        @notice The current number of stakeable LP tokens
     */
    function poolLength() external view returns (uint256) {
        return registeredTokens.length;
    }

    /**
        @notice Add a new token that may be staked within this contract
     */
    function addPool(address _token, uint256 _getRewardsPerSecond) external onlyAdmin returns (bool) {
        require(poolInfo[_token].lastRewardTime == 0);
        registeredTokens.push(_token);
        poolInfo[_token].lastRewardTime = block.timestamp;
        poolInfo[_token].rewardsPerSecond = _getRewardsPerSecond;
        return true;
    }

    function updatePool(address _token, uint256 _getRewardsPerSecond) external onlyAdmin returns (bool) {
        poolInfo[_token].lastRewardTime = block.timestamp;
        poolInfo[_token].rewardsPerSecond = _getRewardsPerSecond;
        return true;
    }

    /**
        @notice Set the claim receiver address for the caller
        @dev When the claim receiver is not == address(0), all
             emission claims are transferred to this address
        @param _receiver Claim receiver address
     */
    function setClaimReceiver(address _receiver) external {
        claimReceiver[msg.sender] = _receiver;
    }

    /**
        @notice Allow or block third-party calls to deposit, withdraw
                or claim rewards on behalf of the caller
     */
    function setBlockThirdPartyActions(bool _block) external onlyAdmin {
        blockThirdPartyActions[msg.sender] = _block;
    }

    /**
        @notice Get the current number of unclaimed rewards for a user on one or more tokens
        @param _user User to query pending rewards for
        @param _tokens Array of token addresses to query
        @return uint256[] Unclaimed rewards
     */
    function claimableReward(address _user, address[] calldata _tokens)
        external
        view
        returns (uint256[] memory)
    {
        uint256[] memory claimable = new uint256[](_tokens.length);
        for (uint256 i = 0; i < _tokens.length; i++) {
            address token = _tokens[i];
            PoolInfo storage pool = poolInfo[token];
            UserInfo storage user = userInfo[token][_user];
            (uint256 accRewardPerShare,) = _getRewardData(token);
            accRewardPerShare += pool.accRewardPerShare;
            claimable[i] = user.claimable + user.adjustedAmount * accRewardPerShare / 1e12 - user.rewardDebt;
        }
        return claimable;
    }

    // Get updated reward data for the given token
    function _getRewardData(address _token) internal view returns (uint256 accRewardPerShare, uint256 rewardsPerSecond) {
        PoolInfo storage pool = poolInfo[_token];
        uint256 lpSupply = pool.adjustedSupply;
        uint256 start = startTime;
        uint256 currentWeek = (block.timestamp - start) / 604800;

        if (lpSupply == 0) {
            return (0, pool.rewardsPerSecond);
        }

        uint256 lastRewardTime = pool.lastRewardTime;
        uint256 rewardWeek = (lastRewardTime - start) / 604800;
        rewardsPerSecond = pool.rewardsPerSecond;
        uint256 reward;
        uint256 duration;
        if (rewardWeek < currentWeek) {
            while (rewardWeek < currentWeek) {
                uint256 nextRewardTime = (rewardWeek + 1) * 604800 + start;
                duration = nextRewardTime - lastRewardTime;
                reward = reward + duration * rewardsPerSecond;
                rewardWeek += 1;
                lastRewardTime = nextRewardTime;
            }
        }

        duration = block.timestamp - lastRewardTime;
        reward = reward + duration * rewardsPerSecond;
        return (reward * 1e12 / lpSupply, rewardsPerSecond);
    }

    // Update reward variables of the given pool to be up-to-date.
    function _updatePool(address _token) internal returns (uint256 accRewardPerShare) {
        PoolInfo storage pool = poolInfo[_token];
        uint256 lastRewardTime = pool.lastRewardTime;
        require(lastRewardTime > 0, "Invalid pool");
        if (block.timestamp <= lastRewardTime) {
            return pool.accRewardPerShare;
        }
        (accRewardPerShare, pool.rewardsPerSecond) = _getRewardData(_token);
        pool.lastRewardTime = block.timestamp;
        if (accRewardPerShare == 0) return pool.accRewardPerShare;
        accRewardPerShare = accRewardPerShare + pool.accRewardPerShare;
        pool.accRewardPerShare = accRewardPerShare;
        return accRewardPerShare;
    }

    // calculate adjusted balance and total supply, used for boost
    // boost calculations are modeled after veCRV, with a max boost of 2.5x
    function _updateLiquidityLimits(address _user, address _token, uint256 _depositAmount, uint256 _accRewardPerShare) internal {
        uint256 userWeight = tokenLocker.userWeight(_user);
        uint256 adjustedAmount = _depositAmount * 40 / 100;
        if (userWeight > 0) {
            uint256 lpSupply = IERC20(_token).balanceOf(address(this));
            uint256 totalWeight = tokenLocker.totalWeight();
            uint256 boost = lpSupply * userWeight / totalWeight * 60 / 100;
            adjustedAmount += boost;
            if (adjustedAmount > _depositAmount) {
                adjustedAmount = _depositAmount;
            }
        }
        UserInfo storage user = userInfo[_token][_user];
        uint256 newAdjustedSupply = poolInfo[_token].adjustedSupply - user.adjustedAmount;
        user.adjustedAmount = adjustedAmount;
        poolInfo[_token].adjustedSupply = newAdjustedSupply + adjustedAmount;
        user.rewardDebt = adjustedAmount * _accRewardPerShare / 1e12;
    }

    /**
        @notice Deposit LP tokens into the contract
        @dev Also updates the receiver's current boost
        @param _token LP token address to deposit.
        @param _amount Amount of tokens to deposit.
        @param _claimRewards If true, also claim rewards earned on the token.
        @return uint256 Claimed reward amount
     */
    function deposit(
        address _token,
        uint256 _amount,
        bool _claimRewards
    ) external nonReentrant returns (uint256) {
        require(_amount > 0, "Cannot deposit zero");
        uint256 accRewardPerShare = _updatePool(_token);
        UserInfo storage user = userInfo[_token][msg.sender];
        uint256 pending;
        if (user.adjustedAmount > 0) {
            pending = user.adjustedAmount * accRewardPerShare / 1e12 - user.rewardDebt;
            if (_claimRewards) {
                pending += user.claimable;
                user.claimable = 0;
                pending = _mintRewards(msg.sender, pending);
            } else if (pending > 0) {
                user.claimable += pending;
                pending = 0;
            }
        }
        IERC20(_token).safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        uint256 depositAmount = user.depositAmount + _amount;
        user.depositAmount = depositAmount;
        _updateLiquidityLimits(msg.sender, _token, depositAmount, accRewardPerShare);
        emit Deposit(msg.sender, _token, _amount);
        return pending;
    }

    function depositWhitelist(
        address _token,
        address _for,
        uint256 _amount,
        bool _claimRewards
    ) onlyWhitelistStake external nonReentrant returns (uint256) {
        require(_amount > 0, "Cannot deposit zero");
        uint256 accRewardPerShare = _updatePool(_token);
        UserInfo storage user = userInfo[_token][_for];
        uint256 pending;
        if (user.adjustedAmount > 0) {
            pending = user.adjustedAmount * accRewardPerShare / 1e12 - user.rewardDebt;
            if (_claimRewards) {
                pending += user.claimable;
                user.claimable = 0;
                pending = _mintRewards(_for, pending);
            } else if (pending > 0) {
                user.claimable += pending;
                pending = 0;
            }
        }
        IERC20(_token).safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        uint256 depositAmount = user.depositAmount + _amount;
        user.depositAmount = depositAmount;
        _updateLiquidityLimits(_for, _token, depositAmount, accRewardPerShare);
        emit Deposit(_for, _token, _amount);
        return pending;
    }

    /**
        @notice Withdraw LP tokens from the contract
        @dev Also updates the caller's current boost
        @param _token LP token address to withdraw.
        @param _amount Amount of tokens to withdraw.
        @param _claimRewards If true, also claim rewards earned on the token.
        @return uint256 Claimed reward amount
     */
    function withdraw(
        address _token,
        uint256 _amount,
        bool _claimRewards
    ) external nonReentrant returns (uint256) {
        require(_amount > 0, "Cannot withdraw zero");
        uint256 accRewardPerShare = _updatePool(_token);
        UserInfo storage user = userInfo[_token][msg.sender];
        uint256 depositAmount = user.depositAmount;
        require(depositAmount >= _amount, "withdraw: not good");

        uint256 pending = user.adjustedAmount * accRewardPerShare / 1e12 - user.rewardDebt;
        if (_claimRewards) {
            pending += user.claimable;
            user.claimable = 0;
            pending = _mintRewards(msg.sender, pending);
        } else if (pending > 0) {
            user.claimable += pending;
            pending = 0;
        }

        depositAmount -= _amount;
        user.depositAmount = depositAmount;
        _updateLiquidityLimits(msg.sender, _token, depositAmount, accRewardPerShare);
        IERC20(_token).safeTransfer(msg.sender, _amount);
        emit Withdraw(msg.sender, _token, _amount);
        return pending;
    }

    /**
        @notice Withdraw a user's complete deposited balance of an LP token
                without updating rewards calculations.
        @dev Should be used only in an emergency when there is an error in
             the reward math that prevents a normal withdrawal.
        @param _token LP token address to withdraw.
     */
    function emergencyWithdraw(address _token) external nonReentrant {
        UserInfo storage user = userInfo[_token][msg.sender];
        poolInfo[_token].adjustedSupply -= user.adjustedAmount;

        uint256 amount = user.depositAmount;
        delete userInfo[_token][msg.sender];
        IERC20(_token).safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(_token, msg.sender, amount);
    }

    /**
        @notice Claim pending rewards for one or more tokens for a user.
        @dev Also updates the claimer's boost.
        @param _user Address to claim rewards for. Reverts if the caller is not the
                     claimer and the claimer has blocked third-party actions.
        @param _tokens Array of LP token addresses to claim for.
        @return uint256 Claimed reward amount
     */
    function claim(address _user, address[] calldata _tokens) external returns (uint256) {
        if (msg.sender != _user) {
            require(!blockThirdPartyActions[_user], "Cannot claim on behalf of this account");
        }

        // calculate claimable amount
        uint256 pending;
        for (uint i = 0; i < _tokens.length; i++) {
            address token = _tokens[i];
            uint256 accRewardPerShare = _updatePool(token);
            UserInfo storage user = userInfo[token][_user];
            uint256 rewardDebt = user.adjustedAmount * accRewardPerShare / 1e12;
            pending += user.claimable + rewardDebt - user.rewardDebt;
            user.claimable = 0;
            _updateLiquidityLimits(_user, token, user.depositAmount, accRewardPerShare);
        }
        return _mintRewards(_user, pending);
    }

    function _mintRewards(address _user, uint256 _amount) internal returns (uint256) {
        if (_amount > 0) {
            address receiver = claimReceiver[_user];
            if (receiver == address(0)) receiver = _user;
            rewardVault.getReward(receiver, _amount);
            emit ClaimedReward(msg.sender, _user, receiver, _amount);
        }
        return _amount;
    }

    /**
        @notice Update a user's boost for one or more deposited tokens
        @param _user Address of the user to update boosts for
     */
    function updateUserBoosts(address _user) external {
        for (uint i = 0; i < registeredTokens.length; i++) {
            address token = registeredTokens[i];
            uint256 accRewardPerShare = _updatePool(token);
            UserInfo storage user = userInfo[token][_user];
            if (user.adjustedAmount > 0) {
                uint256 pending = user.adjustedAmount * accRewardPerShare / 1e12 - user.rewardDebt;
                if (pending > 0) {
                    user.claimable += pending;
                }
            }
            _updateLiquidityLimits(_user, token, user.depositAmount, accRewardPerShare);
        }
    }

    function addWhiteList(address _whitelistAddress) public onlyAdmin
    {
        whitelisted[_whitelistAddress] = true;
        emit AddWhiteListAddress(_whitelistAddress);
    }

    function removeWhiteList(address _whitelistAddress) public onlyAdmin
    {
        whitelisted[_whitelistAddress] = false;
        emit RemoveWhiteListAddress(_whitelistAddress);
    }

    function updateAdmin(address _admin, bool _status) external onlyAdmin {
        Admins[_admin] = _status;
    }

}