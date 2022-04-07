// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {SafeERC20, IERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

contract MultiVesting is Ownable {
    using SafeERC20 for IERC20;

    struct Vesting {
        uint256 startedAt; // Timestamp in seconds
        uint256 totalAmount; // Vested amount token
        uint256 releasedAmount; // Amount that beneficiary withdraw
        uint256 stepsAmount; // Duration of distribution measured in steps
    }

    MultiVesting public OLD;

    uint256 public constant STEPS_SIZE = 1 days;

    uint256 public totalVestedAmount;
    uint256 public totalReleasedAmount;
    IERC20 public token;

    event VestingAdded(address indexed beneficiary, bool indexed isOld, uint256 vestingId);
    event Withdrawn(address indexed beneficiary, uint256 amount);

    // Beneficiary address -> Array of Vesting params
    mapping(address => Vesting[]) _vestingMap;
    mapping(address => bool) public mapMigrated;

    constructor(IERC20 token_, MultiVesting oldContract_) {
        token = token_;
        OLD = oldContract_;
        totalVestedAmount = oldContract_.totalVestedAmount();
        totalReleasedAmount = oldContract_.totalReleasedAmount();
    }

    modifier assureMapSettled(address beneficiary) {
        if (!mapMigrated[beneficiary]) migrateOldMap(beneficiary);
        _;
    }

    // Anyone can volunteer to migrate data :)
    function migrateOldMap(address beneficiary) public {
        require(!mapMigrated[beneficiary], 'SETTLED');
        uint256 vestingsCount = OLD.getNextVestingId(beneficiary);
        for (uint256 vestingId = 0; vestingId < vestingsCount; vestingId++) {
            _vestingMap[beneficiary].push(_getOldVestingMapEntry(beneficiary, vestingId));
            emit VestingAdded(beneficiary, true, vestingId);
        }
        mapMigrated[beneficiary] = true;
    }

    function addVestingFromNow(
        address beneficiary,
        uint256 amount,
        uint256 stepsAmount
    ) external onlyOwner {
        addVesting(beneficiary, amount, block.timestamp, stepsAmount);
    }

    /// @notice Creates vesting for beneficiary, with a given amount of funds to allocate,
    /// and timestamp of the allocation.
    /// @param beneficiary - address of beneficiary.
    /// @param amount - amount of tokens to allocate
    /// @param startedAt - timestamp (in seconds) when the allocation should start
    /// @param stepsAmount - duration of distribution measured in steps
    function addVesting(
        address beneficiary,
        uint256 amount,
        uint256 startedAt,
        uint256 stepsAmount
    ) public onlyOwner assureMapSettled(beneficiary) {
        require(startedAt >= block.timestamp, 'TIMESTAMP_CANNOT_BE_IN_THE_PAST');
        require(amount >= stepsAmount, 'VESTING_AMOUNT_TO_LOW');
        require(getUnallocatedFundsAmount() >= amount, 'DON_T_HAVE_ENOUGH_TOKEN');

        _vestingMap[beneficiary].push(
            Vesting({startedAt: startedAt, totalAmount: amount, releasedAmount: 0, stepsAmount: stepsAmount})
        );
        totalVestedAmount += amount;
        emit VestingAdded(beneficiary, false, _vestingMap[beneficiary].length - 1);
    }

    /// @notice Method that allows a beneficiary to withdraw their allocated funds for a specific vesting ID.
    /// @param vestingId - The ID of the vesting the beneficiary can withdraw their funds for.
    function withdraw(uint256 vestingId) external assureMapSettled(msg.sender) {
        uint256 amount = getAvailableAmount(msg.sender, vestingId);
        require(amount > 0, 'DON_T_HAVE_RELEASED_TOKENS');

        // Increased released amount in in mapping
        _vestingMap[msg.sender][vestingId].releasedAmount += amount;
        // Increased total released in contract
        totalReleasedAmount += amount;
        token.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    /// @notice Method that allows a beneficiary to withdraw all their allocated funds.
    function withdrawAllAvailable() external assureMapSettled(msg.sender) {
        uint256 aggregatedAmount;

        uint256 vestingsLength = _vestingMap[msg.sender].length;
        for (uint256 vestingId = 0; vestingId < vestingsLength; vestingId++) {
            uint256 availableInSingleVesting = getAvailableAmount(msg.sender, vestingId);
            aggregatedAmount += availableInSingleVesting;

            // Update released amount in specific vesting
            _vestingMap[msg.sender][vestingId].releasedAmount += availableInSingleVesting;
        }

        // Increase released amount
        totalReleasedAmount += aggregatedAmount;

        // Transfer
        token.safeTransfer(msg.sender, aggregatedAmount);
        emit Withdrawn(msg.sender, aggregatedAmount);
    }

    /// @notice Method that allows the owner to withdraw unallocated funds to a specific address
    /// @param receiver - address where the funds will be send
    function withdrawUnallocatedFunds(address receiver) external onlyOwner {
        uint256 amount = getUnallocatedFundsAmount();
        require(amount > 0, 'DON_T_HAVE_UNALLOCATED_TOKENS');
        token.safeTransfer(receiver, amount);
    }

    // ===============================================================================================================
    // Getters
    // ===============================================================================================================

    /// @notice Returns smallest unused VestingId (unique per beneficiary).
    /// The next vesting ID can be used by the benficiary to see how many vestings / allocations has.
    /// @param beneficiary - address of the beneficiary to return the next vesting ID
    function getNextVestingId(address beneficiary) public view returns (uint256) {
        if (!mapMigrated[beneficiary]) return OLD.getNextVestingId(beneficiary);
        return _vestingMap[beneficiary].length;
    }

    /// @notice Returns amount of funds that beneficiary can withdraw using all vesting records of given beneficiary address
    /// @param beneficiary - address of the beneficiary
    function getAvailableAmountAggregated(address beneficiary) public view returns (uint256 available) {
        if (!mapMigrated[beneficiary]) return OLD.getAvailableAmountAggregated(beneficiary);
        uint256 maxId = _vestingMap[beneficiary].length;
        for (uint256 vestingId = 0; vestingId < maxId; vestingId++) {
            // Optimization for gas saving in case vesting were already released
            if (_vestingMap[beneficiary][vestingId].totalAmount == _vestingMap[beneficiary][vestingId].releasedAmount) {
                continue;
            }

            available += getAvailableAmount(beneficiary, vestingId);
        }
    }

    /// @notice Returns amount of funds that beneficiary can withdraw, vestingId should be specified (default is 0)
    /// @param beneficiary - address of the beneficiary
    /// @param vestingId - the ID of the vesting (default is 0)
    function getAvailableAmount(address beneficiary, uint256 vestingId) public view returns (uint256) {
        return getAvailableAmountAtTimestamp(beneficiary, vestingId, block.timestamp);
    }

    function getVesting(address beneficiary, uint256 vestingId) public view returns (Vesting memory) {
        if (!mapMigrated[beneficiary]) return _getOldVestingMapEntry(beneficiary, vestingId);
        else return _vestingMap[beneficiary][vestingId];
    }

    function getVestings(address beneficiary) public view returns (Vesting[] memory vestings) {
        if (mapMigrated[beneficiary]) return _vestingMap[beneficiary];
        uint256 vestingsCount = OLD.getNextVestingId(beneficiary);
        vestings = new Vesting[](vestingsCount);
        for (uint256 vestingId = 0; vestingId < vestingsCount; vestingId++) {
            vestings[vestingId] = _getOldVestingMapEntry(beneficiary, vestingId);
        }
    }

    function _getOldVestingMapEntry(address beneficiary, uint256 vestingId) internal view returns (Vesting memory) {
        uint256 startedAt = OLD.getStartDate(beneficiary, vestingId);
        uint256 totalAmount = OLD.getTotalAmount(beneficiary, vestingId);
        uint256 stepsAmount = OLD.getStepsAmount(beneficiary, vestingId);

        // Now the tricky part
        // Query the old contract about available amount at the END OF UNIVERSE for given vesting
        // It will be equal to [totalAmount - releasedAmount] (see getAvailableAmountAtTimestamp())
        uint256 totalUnreleased = OLD.getAvailableAmountAtTimestamp(beneficiary, vestingId, type(uint256).max);
        uint256 releasedAmount = totalAmount - totalUnreleased;
        return
            Vesting({
                startedAt: startedAt,
                totalAmount: totalAmount,
                releasedAmount: releasedAmount,
                stepsAmount: stepsAmount
            });
    }

    function getStartDate(address beneficiary, uint256 vestingId) public view returns (uint256) {
        if (!mapMigrated[beneficiary]) return OLD.getStartDate(beneficiary, vestingId);
        return _vestingMap[beneficiary][vestingId].startedAt;
    }

    function getTotalAmount(address beneficiary, uint256 vestingId) public view returns (uint256) {
        if (!mapMigrated[beneficiary]) return OLD.getTotalAmount(beneficiary, vestingId);
        return _vestingMap[beneficiary][vestingId].totalAmount;
    }

    function getStepsAmount(address beneficiary, uint256 vestingId) public view returns (uint256) {
        if (!mapMigrated[beneficiary]) return OLD.getStepsAmount(beneficiary, vestingId);
        return _vestingMap[beneficiary][vestingId].stepsAmount;
    }

    /// @notice Returns amount of funds that beneficiary will be able to withdraw at the given timestamp per vesting ID (default is 0).
    /// @param beneficiary - address of the beneficiary
    /// @param vestingId - the ID of the vesting (default is 0)
    /// @param timestamp - Timestamp (in seconds) on which the beneficiary wants to check the withdrawable amount.
    function getAvailableAmountAtTimestamp(
        address beneficiary,
        uint256 vestingId,
        uint256 timestamp
    ) public view returns (uint256) {
        if (!mapMigrated[beneficiary]) return OLD.getAvailableAmountAtTimestamp(beneficiary, vestingId, timestamp);
        if (vestingId >= _vestingMap[beneficiary].length) {
            return 0;
        }

        Vesting memory vesting = _vestingMap[beneficiary][vestingId];
        uint256 stepsAmount = vesting.stepsAmount;

        // The number of steps that have passed since the start. One step is equal to one day.
        uint256 stepsPassed = (timestamp - vesting.startedAt) / STEPS_SIZE;

        uint256 alreadyReleased = vesting.releasedAmount;

        // tokens is already released:
        if (stepsPassed >= stepsAmount) {
            return vesting.totalAmount - alreadyReleased;
        }

        uint256 rewardPerStep = vesting.totalAmount / stepsAmount;
        return (rewardPerStep * stepsPassed) - alreadyReleased;
    }

    /// @notice Returns amount of unallocated funds that contract owner can withdraw
    function getUnallocatedFundsAmount() public view returns (uint256) {
        uint256 debt = totalVestedAmount - totalReleasedAmount;
        uint256 available = token.balanceOf(address(this)) - debt;
        return available;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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