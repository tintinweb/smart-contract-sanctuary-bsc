/**
 *Submitted for verification at BscScan.com on 2022-08-09
*/

// File: contracts/openzeppelin/token/IERC20.sol

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

// File: contracts/openzeppelin/token/extensions/IERC20Metadata.sol

pragma solidity ^0.8.0;

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

// File: contracts/openzeppelin/utils/Address.sol

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

// File: contracts/openzeppelin/token/utils/SafeERC20.sol

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

// File: contracts/flavours/Context.sol

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

// File: contracts/flavours/Ownable.sol

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
    address private _pendingOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Throws if called by any account other than the pending owner.
     */
    modifier onlyPendingOwner() {
        require(_pendingOwner == _msgSender(), "Ownable: caller is not the pending owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Prepare ownership transfer of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _pendingOwner = newOwner;
    }

    /**
     * @dev Allows the pending owner to finalize the transfer.
     */
    function claimOwnership() public onlyPendingOwner {
        _transferOwnership(_pendingOwner);
        _pendingOwner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/GlobalsAndUtility.sol

pragma solidity ^0.8.0;


abstract contract GlobalsAndUtility is Ownable {
    event APRCoefficientUpdate(
        address indexed updaterAddr,
        uint40 timestamp,
        uint16 stakedDays,
        uint256 coefficient
    );

    event StakeStart(
        address indexed stakerAddr,
        uint40 indexed stakeId,
        uint40 timestamp,
        uint128 stakedAmount,
        uint16 stakedDays,
        uint16 startIndexAPR
    );

    event StakeEnd(
        address indexed stakerAddr,
        uint40 indexed stakeId,
        uint40 timestamp,
        uint128 stakedAmount,
        uint128 stakeReward,
        uint16 servedDays,
        uint16 startIndexAPR
    );

    event RewardsFund(
        uint128 amount
    );

    IERC20 public stakingToken;
    uint256 public launchTime;

    uint256 internal constant TOKEN_DECIMALS = 18;
    uint256 internal constant ONE_TOKEN = 1e18;

    uint256 internal constant APR_BASIS = 3;
    uint256 internal constant APR_MULTIPLIER = 1e5;

    uint16[] public stakePeriods;

    struct APR {
        uint256 changeDay;
        uint256 coefficient;
    }

    mapping(uint16 => APR[]) public aprCoefficient;
    mapping(uint16 => uint256) public aprDivider;
    mapping(uint16 => uint40) public activeStakes;

    /* Globals expanded for memory (except _latestStakeId) and compact for storage */
    struct GlobalsCache {
        uint256 _rewardTotal;
        uint256 _lockedStakeTotal;
        uint40 _latestStakeId;
        uint256 _currentDay;
        uint40 _activeStakesTotal;
        uint40 _averageLockPeriod;
    }

    struct GlobalsStore {
        uint128 rewardTotal;
        uint128 lockedStakeTotal;
        uint40 latestStakeId;
        uint40 activeStakesTotal;
    }

    GlobalsStore public globals;

    /* Stake expanded for memory (except _stakeId) and compact for storage */
    struct StakeCache {
        uint256 _stakedAmount;
        uint40 _stakeId;
        uint256 _lockedDay;
        uint16 _stakedDays;
        uint16 _startIndexAPR;
    }

    struct StakeStore {
        uint128 stakedAmount;
        uint40 stakeId;
        uint16 lockedDay;
        uint16 stakedDays;
        uint16 startIndexAPR;
    }

    mapping(address => StakeStore[]) public stakeLists;

    /**
     * @dev PUBLIC FACING: Updates coefficient for specified stake period.
     * @param stakeDays - period of stake
     * @param coefficientWithMultiplier - value of percent should be multiplied by 1e5
     */
    function updateAPRCoefficient(uint16 stakeDays, uint256 coefficientWithMultiplier) external onlyOwner {
        require(aprDivider[stakeDays] != 0, "New stake period is not allowed");
        // 1000 minimum (1e5/100)
        require(coefficientWithMultiplier * 100 >= APR_MULTIPLIER, "Coefficient is too small");

        uint256 coefficient = coefficientWithMultiplier * APR_BASIS;
        _changeAPR(stakeDays, _currentDay(), coefficient);

        emit APRCoefficientUpdate(
            msg.sender,
            uint40(block.timestamp),
            uint16(stakeDays),
            coefficient
        );
    }

    function _changeAPR(uint16 stakeDays, uint256 changeDay, uint256 coefficient) internal {
        aprCoefficient[stakeDays].push(
            APR(
                uint256(changeDay),
                uint256(coefficient)
            )
        );
    }

    function _loadAPR(APR[] storage aprRef, uint256 aprIndex, APR memory apr) internal view {
        apr.coefficient = aprRef[aprIndex].coefficient;
        apr.changeDay = aprRef[aprIndex].changeDay;
    }

    /**
     * @dev PUBLIC FACING: Returns the count of stake periods
     */
    function stakePeriodsCount() external view returns (uint256) {
        return stakePeriods.length;
    }

    /**
     * @dev PUBLIC FACING: Returns the current aprCoefficient count for a stakeDays
     * @param stakeDays stake duration
     */
    function aprCoefficientCount(uint16 stakeDays) external view returns (uint256) {
        return aprCoefficient[stakeDays].length;
    }

    /**
     * @dev PUBLIC FACING: External helper to return most global info with a single call.
     * @return global variables
     */
    function globalInfo() external view returns (GlobalsCache memory) {
        GlobalsCache memory g;
        _globalsLoad(g);

        return g;
    }

    /**
     * @dev PUBLIC FACING: External helper for the current day number since launch time
     * @return Current day number (zero-based)
     */
    function currentDay() external view returns (uint256) {
        return _currentDay();
    }

    function _currentDay() internal view returns (uint256) {
        return (block.timestamp - launchTime) / 1 days;
    }

    function _globalsLoad(GlobalsCache memory g) internal view {
        g._rewardTotal = globals.rewardTotal;
        g._lockedStakeTotal = globals.lockedStakeTotal;
        g._latestStakeId = globals.latestStakeId;
        g._currentDay = _currentDay();
        g._activeStakesTotal = globals.activeStakesTotal;

        if (globals.activeStakesTotal != 0) {
            g._averageLockPeriod = (activeStakes[30] * 30 + activeStakes[60] * 60 + activeStakes[90] * 90
            + activeStakes[180] * 180 + activeStakes[365] * 365 + activeStakes[700] * 700) / globals.activeStakesTotal;
        } else {
            g._averageLockPeriod = 0;
        }
    }

    function _globalsSync(GlobalsCache memory g) internal {
        globals.rewardTotal = uint128(g._rewardTotal);
        globals.lockedStakeTotal = uint128(g._lockedStakeTotal);
        globals.latestStakeId = g._latestStakeId;
        globals.activeStakesTotal = g._activeStakesTotal;
    }

    function _stakeLoad(StakeStore storage stRef, uint40 stakeIdParam, StakeCache memory st) internal view {
        /* Ensure caller's stakeIndex is still current */
        require(stakeIdParam == stRef.stakeId, "STAKING: stakeIdParam not in stake");

        st._stakedAmount = stRef.stakedAmount;
        st._stakeId = stRef.stakeId;
        st._lockedDay = stRef.lockedDay;
        st._stakedDays = stRef.stakedDays;
        st._startIndexAPR = stRef.startIndexAPR;
    }

    function _stakeAdd(
        StakeStore[] storage stakeListRef,
        uint40 newStakeId,
        uint256 newStakedAmount,
        uint256 newLockedDay,
        uint16 newStakedDays,
        uint16 startIndexAPR
    ) internal {
        stakeListRef.push(
            StakeStore(
                uint128(newStakedAmount),
                newStakeId,
                uint16(newLockedDay),
                uint16(newStakedDays),
                uint16(startIndexAPR)
            )
        );
    }

    /**
     * @dev Efficiently delete from an unordered array by moving the last element
     * to the "hole" and reducing the array length. Can change the order of the list
     * and invalidate previously held indexes.
     * @notice stakeListRef length and stakeIndex are already ensured valid in stakeEnd()
     * @param stakeListRef Reference to stakeLists[stakerAddr] array in storage
     * @param stakeIndex Index of the element to delete
     */
    function _stakeRemove(StakeStore[] storage stakeListRef, uint256 stakeIndex) internal {
        uint256 lastIndex = stakeListRef.length - 1;

        /* Skip the copy if element to be removed is already the last element */
        if (stakeIndex != lastIndex) {
            /* Copy last element to the requested element's "hole" */
            stakeListRef[stakeIndex] = stakeListRef[lastIndex];
        }

        stakeListRef.pop();
    }

}

// File: contracts/flavours/Withdrawal.sol

pragma solidity ^0.8.0;


/**
 * @title Withdrawal
 * @dev The Withdrawal contract has an owner address, and provides method for withdraw funds and tokens, if any
 */
contract Withdrawal is Ownable {

    address private _restrictedToken;

    function setRestrictedToken(address restrictedToken) internal {
        require(restrictedToken != address(0), "Restricted token cannot be zero");
        require(_restrictedToken == address(0), "Restricted token is unchangeable");
        _restrictedToken = restrictedToken;
    }

    // withdraw funds, if any, only for owner
    function withdraw() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    // withdraw stuck tokens, if any, only for owner
    function withdrawTokens(address _someToken) public onlyOwner {
        require(_restrictedToken != _someToken, "Restricted token is forbidden to withdraw");
        IERC20 someToken = IERC20(_someToken);
        uint balance = someToken.balanceOf(address(this));
        someToken.transfer(owner(), balance);
    }

}

// File: contracts/flavours/SelfDestructible.sol

pragma solidity ^0.8.0;

/**
 * @title SelfDestructible
 * @dev The SelfDestructible contract has an owner address, and provides selfDestruct method
 * in case of deployment error.
 */
contract SelfDestructible is Ownable {

    function selfDestruct(uint8 v, bytes32 r, bytes32 s) public onlyOwner {
        if (ecrecover(prefixedHash(), v, r, s) != owner()) {
            revert();
        }
        selfdestruct(payable(owner()));
    }

    function originalHash() internal view returns (bytes32) {
        return keccak256(abi.encodePacked(
                "Signed for SelfDestruct",
                address(this),
                msg.sender
            ));
    }

    function prefixedHash() internal view returns (bytes32) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        return keccak256(abi.encodePacked(prefix, originalHash()));
    }
}

// File: contracts/flavours/Stoppable.sol

pragma solidity ^0.8.0;

contract Stoppable is Ownable {

    event StakeDisabled(
        address indexed updaterAddr,
        uint40 timestamp
    );

    bool public active;

    constructor() {
        active = true;
    }

    function disable() public onlyOwner onlyActive {
        active = false;

        emit StakeDisabled(
            msg.sender,
            uint40(block.timestamp)
        );
    }

    modifier onlyActive() {
        require(active, "Staking not available anymore");
        _;
    }

    modifier onlyDisabled() {
        require(!active, "Staking is active");
        _;
    }

}

// File: contracts/Staking.sol

pragma solidity ^0.8.0;







contract Staking is GlobalsAndUtility, Withdrawal, SelfDestructible, Stoppable {
    using SafeERC20 for IERC20;

    constructor(IERC20 _stakingToken) {
        require(IERC20Metadata(address(_stakingToken)).decimals() == TOKEN_DECIMALS, "STAKING: incompatible token decimals");

        setRestrictedToken(address(_stakingToken));
        stakingToken = _stakingToken;
        launchTime = block.timestamp;

        // 3 * 1% 1/12
        _changeAPR(30, 0, APR_BASIS * 1 * 1e5);
        aprDivider[30] = 12 * 1e5;
        stakePeriods.push(30);
        // 3 * 1.5% 1/6
        _changeAPR(60, 0, APR_BASIS * 15e4);
        aprDivider[60] = 6 * 1e5;
        stakePeriods.push(60);
        // 3 * 1.9% 1/4
        _changeAPR(90, 0, APR_BASIS * 19e4);
        aprDivider[90] = 4 * 1e5;
        stakePeriods.push(90);
        // 3 * 3% 1/2
        _changeAPR(180, 0, APR_BASIS * 3 * 1e5);
        aprDivider[180] = 2 * 1e5;
        stakePeriods.push(180);
        // 3 * 5% 1
        _changeAPR(365, 0, APR_BASIS * 5 * 1e5);
        aprDivider[365] = 1 * 1e5;
        stakePeriods.push(365);
        // 3 * 12% 2
        _changeAPR(700, 0, APR_BASIS * 12 * 1e5);
        aprDivider[700] = 1 * 5e4;
        stakePeriods.push(700);
    }

    /**
     * @dev PUBLIC FACING: Open a stake.
     * Requires allowance of specified amount (at least) on token contract for staking contract.
     * @param newStakedAmount Amount of staking token to stake
     * @param newStakedDays Number of days to stake
     * @return stakeId id of created stake
     */
    function stakeStart(uint256 newStakedAmount, uint16 newStakedDays) external onlyActive returns (uint40 stakeId) {
        /* Enforce the fixed stake time */
        require(aprDivider[newStakedDays] != 0, "STAKING: newStakedDays value is not allowed");

        GlobalsCache memory g;
        _globalsLoad(g);

        stakeId = _stakeStart(g, newStakedAmount, newStakedDays);

        /* Remove staked amount from balance of staker */
        stakingToken.safeTransferFrom(msg.sender, address(this), newStakedAmount);

        _globalsSync(g);
    }

    /**
     * @dev PUBLIC FACING: Closes a stake. The order of the stake list can change so
     * a stake id is used to reject stale indexes.
     * @param stakeIndex Index of stake within stake list
     * @param stakeIdParam The stake's id
     * @return stakeReturn payout
     */
    function stakeEnd(uint256 stakeIndex, uint40 stakeIdParam) external returns (uint256 stakeReturn, uint256 payout) {
        return _stakeEnd(stakeIndex, stakeIdParam, false);
    }

    /**
     * @dev PUBLIC FACING: Closes a unfinished stake. The order of the stake list can change so
     * a stake id is used to reject stale indexes.
     * @param stakeIndex Index of stake within stake list
     * @param stakeIdParam The stake's id
     * @return stakeReturn payout
     */
    function stakeEarlyEnd(uint256 stakeIndex, uint40 stakeIdParam) external returns (uint256 stakeReturn, uint256 payout) {
        return _stakeEnd(stakeIndex, stakeIdParam, true);
    }

    function _stakeEnd(uint256 stakeIndex, uint40 stakeIdParam, bool early) internal returns (uint256 stakeReturn, uint256 payout) {
        GlobalsCache memory g;
        StakeCache memory st;
        _globalsLoad(g);

        StakeStore[] storage stakeListRef = stakeLists[msg.sender];

        uint16 servedDays;
        if (early) {
            require(stakeListRef.length != 0, "STAKING: Empty stake list");
            require(stakeIndex < stakeListRef.length, "STAKING: stakeIndex invalid");

            StakeStore storage stRef = stakeListRef[stakeIndex];

            /* Get stake copy */
            _stakeLoad(stRef, stakeIdParam, st);

            stakeReturn = st._stakedAmount;
            payout = 0;
            servedDays = 0;
        } else {
            (stakeReturn, payout) = _getStakeStatus(stakeIndex, stakeIdParam, stakeListRef, true, g, st);
            servedDays = uint16(st._stakedDays);
        }

        emit StakeEnd(
            msg.sender,
            stakeIdParam,
            uint40(block.timestamp),
            uint128(st._stakedAmount),
            uint128(payout),
            servedDays,
            uint16(st._startIndexAPR)
        );

        /* Pay the stake return to the staker */
        stakingToken.safeTransfer(msg.sender, stakeReturn);

        g._rewardTotal -= payout;
        g._lockedStakeTotal -= st._stakedAmount;
        g._activeStakesTotal -= 1;
        activeStakes[st._stakedDays] -= 1;

        _stakeRemove(stakeListRef, stakeIndex);

        _globalsSync(g);

        return (stakeReturn, payout);
    }

    /**
     * @dev PUBLIC FACING: Funds reward tokens to staking contract.
     * Requires allowance of specified amount (at least) on token contract for staking contract.
     * @param amount value of tokens to fund
     */
    function fundRewards(uint128 amount) external {
        GlobalsCache memory g;
        _globalsLoad(g);

        stakingToken.safeTransferFrom(msg.sender, address(this), amount);

        g._rewardTotal += amount;
        _globalsSync(g);

        emit RewardsFund(amount);
    }

    /**
     * @dev PUBLIC FACING: Withdraws specified amount of reward tokens to owner. Only for owner.
     */
    function fundsWithdraw(uint256 amount) external onlyOwner {
        GlobalsCache memory g;
        _globalsLoad(g);

        require(g._rewardTotal >= amount, "Amount exceeds balance");
        stakingToken.transfer(owner(), amount);

        g._rewardTotal -= amount;
        _globalsSync(g);
    }

    /**
     * @dev PUBLIC FACING: Withdraws all unused reward tokens to owner. Only for owner and only after staking is stopped.
     */
    function fundsWithdrawFull() external onlyOwner onlyDisabled {
        GlobalsCache memory g;
        _globalsLoad(g);
        require(g._activeStakesTotal == 0, "Not all stakes closed");
        uint256 balance = stakingToken.balanceOf(address(this));
        require(balance > 0, "Nothing to withdraw");
        stakingToken.transfer(owner(), balance);

        // it's possible to withdraw more than _rewardTotal,
        // if someone send tokens directly to contract, not via fundRewards
        g._rewardTotal = 0;
        _globalsSync(g);
    }

    /**
     * @dev PUBLIC FACING: Returns the current stake count for a staker address
     * @param stakerAddr Address of staker
     */
    function stakeCount(address stakerAddr) external view returns (uint256) {
        return stakeLists[stakerAddr].length;
    }

    /**
     * @dev Open a stake.
     * @param g Cache of stored globals
     * @param newStakedAmount Amount of staking token to stake
     * @param newStakedDays Number of days to stake
     * @return newStakeId id of created stake
     */
    function _stakeStart(GlobalsCache memory g, uint256 newStakedAmount, uint16 newStakedDays) internal returns (uint40 newStakeId) {
        APR[] storage aprArr = aprCoefficient[newStakedDays];
        APR memory apr;
        uint16 startIndexAPR = uint16(aprArr.length) - 1;
        _loadAPR(aprArr, startIndexAPR, apr);

        uint256 newStakeReward = newStakedAmount * apr.coefficient / (100 * aprDivider[newStakedDays]);

        /* Ensure newStakedAmount is enough for at least one reward token */
        require(newStakeReward >= ONE_TOKEN, "STAKING: newStakedAmount must be enough to get one reward token");

        /*
            The stakeStart timestamp will always be part-way through the current
            day, so it needs to be rounded-up to the next day to ensure all
            stakes align with the same fixed calendar days. The current day is
            already rounded-down, so rounded-up is current day + 1.
        */
        uint256 newLockedDay = g._currentDay + 1;

        /* Create Stake */
        newStakeId = ++g._latestStakeId;
        _stakeAdd(
            stakeLists[msg.sender],
            newStakeId,
            newStakedAmount,
            newLockedDay,
            newStakedDays,
            startIndexAPR
        );

        emit StakeStart(
            msg.sender,
            newStakeId,
            uint40(block.timestamp),
            uint128(newStakedAmount),
            uint16(newStakedDays),
            uint16(startIndexAPR)
        );

        /* Track total staked amount */
        g._lockedStakeTotal += newStakedAmount;

        g._activeStakesTotal += 1;
        activeStakes[newStakedDays] += 1;
    }

    /*
    Returns the same values as function stakeEnd. However, this function makes
    it possible to anyone view the stakeReturn etc. for any staker.
    */
    function getStakeStatus(address staker, uint256 stakeIndex, uint40 stakeIdParam) external view
    returns (uint256 stakeReturn, uint256 payout)
    {
        GlobalsCache memory g;
        StakeCache memory st;
        _globalsLoad(g);

        StakeStore[] storage stakeListRef = stakeLists[staker];

        (stakeReturn, payout) = _getStakeStatus(stakeIndex, stakeIdParam, stakeListRef, false, g, st);
    }

    function _getStakeStatus(uint256 stakeIndex, uint40 stakeIdParam, StakeStore[] storage stakeListRef,
        bool failOnUnfinished, GlobalsCache memory g, StakeCache memory st)
    internal view returns (uint256 stakeReturn, uint256 payout) {
        require(stakeListRef.length != 0, "STAKING: Empty stake list");
        require(stakeIndex < stakeListRef.length, "STAKING: stakeIndex invalid");

        StakeStore storage stRef = stakeListRef[stakeIndex];

        /* Get stake copy */
        _stakeLoad(stRef, stakeIdParam, st);

        /* Stake must have served full term */
        require(g._currentDay >= st._lockedDay + st._stakedDays || !failOnUnfinished, "STAKING: Stake not fully served");

        payout = 0;
        stakeReturn = st._stakedAmount;
        if (g._currentDay < st._lockedDay) {
            return (stakeReturn, payout);
        }

        uint16 stakedDays = st._stakedDays;
        APR[] storage aprArr = aprCoefficient[stakedDays];
        APR memory apr;
        APR memory aprPrev;
        for (uint16 i = st._startIndexAPR; i <= aprArr.length - 1; i++) {
            _loadAPR(aprArr, i, apr);
            if (apr.changeDay <= st._lockedDay) {
                // rewind to first apr, that have affect on stake
                aprPrev.changeDay = apr.changeDay;
                aprPrev.coefficient = apr.coefficient;
                continue;
            }
            if (apr.changeDay > st._lockedDay + st._stakedDays || apr.changeDay > g._currentDay) {
                // stop after last related apr
                break;
            }

            payout += st._stakedAmount * aprPrev.coefficient
            * (apr.changeDay - (aprPrev.changeDay <= st._lockedDay ? st._lockedDay : aprPrev.changeDay));
            aprPrev.changeDay = apr.changeDay;
            aprPrev.coefficient = apr.coefficient;
        }

        // add part after last APR change
        uint256 startDay = aprPrev.changeDay <= st._lockedDay ? st._lockedDay : aprPrev.changeDay;
        uint256 endDay = g._currentDay >= st._lockedDay + stakedDays ? st._lockedDay + stakedDays : g._currentDay;
        payout += st._stakedAmount * aprPrev.coefficient * (endDay - startDay);

        payout = payout / (100 * aprDivider[stakedDays] * stakedDays);

        stakeReturn += payout;
    }
}