// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
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
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./libraries/StakingLibrary.sol";
import "./interfaces/IStaking.sol";
import "./interfaces/IAdmin.sol";

/**
 * @title Staking.
 * @dev contract for staking tokens.
 *
 */
contract Staking is IStaking, Initializable, Context {
    using SafeERC20 for IERC20;
    using StakingLibrary for StakingLibrary.StakingDetails;

    bytes32 public constant OPERATOR = keccak256("OPERATOR");

    IERC20 public _CFLUToken;
    IAdmin public _admin;

    uint256 public _stakingLockPeriod;

    mapping(address => StakingLibrary.StakingDetails) public _stakingState;

    modifier onlyInstances() {
        require(
            _admin.tokenSalesM(_msgSender()),
            "Staking: Sender is not instance"
        );
        _;
    }

    modifier canUnstake() {
        StakingLibrary.StakingDetails storage self = _stakingState[
            _msgSender()
        ];
        require(
            block.timestamp > self.poolsEndTime &&
                block.timestamp > self.canUnstakeAt,
            "Staking: Not time yet"
        );
        _;
    }

    modifier validation(address address_) {
        require(address_ != address(0), "Staking: Zero address");
        _;
    }

    modifier onlyOperator() {
        require(
            _admin.containsRole(OPERATOR, _msgSender()),
            "Staking: Sender not operator"
        );
        _;
    }


    function initialize(address cfluToken_, address adminContract_)
        public
        initializer
        validation(cfluToken_)
        validation(adminContract_)
    {
        // require(condition); // for _stakingLockPeriod
        _CFLUToken = IERC20(cfluToken_);
        _admin = IAdmin(adminContract_);

        _stakingLockPeriod = 300;// change it to n days and take it is an argument
    }

    function stake(uint256 amount_) external override {
        require(amount_ > 0, "Staking: Non-zero");

        _CFLUToken.safeTransferFrom(_msgSender(), address(this), amount_);

        StakingLibrary.StakingDetails storage self = _stakingState[
            _msgSender()
        ];

        uint256 reference_ = block.timestamp > self.canUnstakeAt
            ? block.timestamp
            : self.canUnstakeAt;

        _stakingState[_msgSender()]._setState(
            amount_,
            (reference_ + _stakingLockPeriod)
        );
    }

    function unstake(uint256 amount_) external override canUnstake {
        require(
            _stakingState[_msgSender()].amount >= amount_,
            "Staking: Insufficient Stakes"
        );
        _withdraw(_msgSender(), amount_);
    }

    function amountStakedBy(address address_)
        external
        view
        override
        returns (uint256)
    {
        return uint256(_stakingState[address_].amount);
    }

    function setAdmin(address address_)
        external
        validation(address_)
        onlyOperator
    {
        _admin = IAdmin(address_);
    }

    function setToken(address address_)
        external
        validation(address_)
        onlyOperator
    {
        _CFLUToken = IERC20(address_);
    }

    function setPoolsEndTime(address address_, uint32 time_)
        external
        override
        onlyInstances
    {
        if (_stakingState[address_].poolsEndTime < time_) {
            _stakingState[address_].poolsEndTime = time_;
        }
    }

    function setLockingPeriod(uint256 period_)
        external
        onlyOperator
    {
        require(
            period_ > 0,
            "Staking: Non-zero"
        );

        _stakingLockPeriod = period_;
    }

    function _withdraw(address user_, uint256 amount_) private {
        _stakingState[_msgSender()]._updateStakeAmount(amount_, false);
        _CFLUToken.safeTransfer(user_, amount_);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./ITokenSale.sol";

interface IAdmin {
    event TokenSaleCreated(address indexed tokenSale_);
    event AirdropChanged(address indexed, address indexed);
    event WalletChanged(address indexed, address indexed);

    function createPool(
        ITokenSale.Address memory,
        ITokenSale.Timing memory,
        ITokenSale.Limit memory,
        bool,
        bool
    ) external;

    function changeWallet(address) external;

    function changeAirdropAddress(address) external;

    function setStakingContract(address) external;

    function changeOracleContract(address) external;

    function tokenSalesM(address) external view returns (bool);

    function getTokenSales() external view returns (address[] memory);

    function containsRole(bytes32, address) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IStaking {
    function unstake(uint256) external;

    function stake(uint256) external;

    function setPoolsEndTime(address, uint32) external;

    function amountStakedBy(address) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface ITokenSale {
    // ----------------------------------------------------------------------------
    // ------------------------- STRUCTS & ENUMS ----------------------------------
    // ----------------------------------------------------------------------------

    enum LiveSaleType {
        PVT,
        PUB,
        NIL
    }

    struct Address {
        address owner;
        address saleToken;
        address stableCoin;
        address beneficiary;
        address stakingContract;
    }

    struct Timing {
        uint256 pubStart;
        uint256 pvtStart;
        uint256 pubDuration;
        uint256 pvtDuration;
    }

    // token sale limits
    struct Limit {
        uint256 pvtN; // # of sale tokens per CFLU in pvt sale
        uint256 pubN; // # of sale tokens per CFLU in pub sale
        uint256 hardcap; // amount of BUSD to to be raised at the most
        uint256 softcap; // amount of BUSD to be raised at the least (if say we couldn't sell all the tokens----means low demand for the tokens!), in order to say IDO is success and the project needs this much at least!
        uint256 totalSupply; // total sale tokens available for sale
        uint256 maxAllocationShare; // to prevent single sided loading i.e single participant shouldn't get most of the tokens!
        uint16 profitPercentage; // part of IDO funds raised which goto admin contract. use 2000 for 20% eg
    }

    struct IdoProject {
        bool initialized; // initialized?
        bool pubSaleEnabled; // is pub sale enabled?
        bool whitelistingNeeded; // is whitelisting needed for participants?
        uint256 collected; // total BUSD collected
        uint256 pubTokenPrice; // will be calc when pvt sale ends and if there are any tokens left
        uint256 pvtTokenPrice; // hardcap / totalSupply
        uint256 participantCount; // keep track of # of participants
        LiveSaleType liveSaleType; // current sale type
        mapping(address => bool) whitelisted;
        mapping(address => uint256) balances; // account balance in BUSD
        mapping(address => bool) participants; // participants in the ido project (subset of stakers)
    }

    // ----------------------------------------------------------------------------
    // -------------------------- EVENTS ------------------------------------------
    // ----------------------------------------------------------------------------

    event PublicSaleEnabled(bool);
    event NeedOfWhitelistingChanged(bool);
    event PublicSaleEnded(address indexed);
    event PrivateSaleEnded(address indexed);
    event PublicSaleStarted(address indexed);
    event WhitelistedSingle(address indexed);
    event Purchased(address indexed, uint256);
    event BeneficiaryChanged(address indexed);
    event PrivateSaleStarted(address indexed);
    event AllocationAmountChanged(uint256, bool);
    event WhitelistedMany(uint256, address[] indexed);
    event Initialized(address indexed, address indexed);
    event FundsWithdrawn(address indexed, uint256, address indexed, uint256);

    // ----------------------------------------------------------------------------
    // ------------------------- IMMutable Functions ------------------------------
    // ----------------------------------------------------------------------------
    function init(
        Address memory,
        Timing memory,
        Limit memory,
        bool,
        bool
    ) external returns (bool);

    function isLive() external view returns (bool);

    function pubEndTime() external view returns (uint256);

    function pvtEndTime() external view returns (uint256);

    function getTokenPrice() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function isWhitelisted(address) external view returns (bool);

    function getRemainingAmount() external view returns (uint256);

    function getParticipantCount() external view returns (uint256);

    function willHardcapExceedWith(uint256) external view returns (bool);

    function getNormalizedAmount(uint256) external view returns (uint256);

    function getMaxAllocationPerParticipant() external view returns (uint256);

    // ----------------------------------------------------------------------------
    // ------------------------- Mutable Functions --------------------------------
    // ----------------------------------------------------------------------------

    function withdrawFunds() external;

    function endPublicSale() external;

    function endPrivateSale() external;

    function startPublicSale() external;

    function startPrivateSale() external;

    function burnLeftoverTokens() external;

    function addToWhitelist(address) external;

    function setNewBeneficiary(address) external;

    function setPublicSaleAbility(bool) external;

    function setWhitelistingAbility(bool) external;

    function changeProfitPercentageTo(uint16) external;

    function addManyToWhitelist(address[] memory) external;

    function setNewAllocationAmount(uint256, bool) external;

    function destroyTokenSaleContract(address payable) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

library StakingLibrary {
    struct StakingDetails {
        uint128 amount;
        uint64 poolsEndTime;
        uint64 canUnstakeAt;
    }

    function _setState(
        StakingDetails storage self,
        uint256 _amount,
        uint256 _canUnstakeAt
    ) internal {
        self.canUnstakeAt = uint64(_canUnstakeAt);
        self.amount += uint128(_amount);
    }

    function _updateStakeAmount(
        StakingDetails storage self,
        uint256 _amount,
        bool isStake
    ) internal {
        if (isStake) {
            self.amount += uint128(_amount);
        } else {
            self.amount -= uint128(_amount);
        }
    }

    function _setPoolsEndTime(StakingDetails storage self, uint256 _endTime)
        internal
    {
        self.poolsEndTime = uint64(_endTime);
    }
}