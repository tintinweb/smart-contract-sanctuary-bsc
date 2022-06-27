/**
 *Submitted for verification at BscScan.com on 2022-06-27
*/

// Sources flattened with hardhat v2.9.2 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]

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

// File @openzeppelin/contracts/access/[email protected]

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

// File @openzeppelin/contracts/token/ERC20/[email protected]

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
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

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
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

// File contracts/vestingEvai.sol

pragma solidity 0.8.10;

/**
 * @title VestingEvai
 */
contract VestingEvai is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct VestingSchedule {
        // unique id for each beneficiary
        uint256 vestingId;
        // wallet address of beneficiary
        address recipient;
        // duration of the vesting period in seconds
        uint256 vestingPeriod;
        // duration in seconds until vesting is started
        uint256 vestingStart;
        // total amount of tokens to be vested to the beneficiary
        uint256 allocatedAmount;
        // amount of tokens released to be claimed
        uint256 vestedAmount;
        // vesting is ended
        bool isEnded;
    }

    // address of the ERC20 token
    IERC20 private immutable _token;

    // mapping from address to VestingSchedule
    mapping(address => uint256) private vestingScheduleIdsByAddress;

    // mapping from id to VestingSchedule
    mapping(uint256 => VestingSchedule) private vestingSchedulesById;

    // mapping from index to accounts to be took part in vesting
    mapping(uint256 => address) public vestingAccounts;

    // total amount not allocated to vesting schedules
    uint256 notAllocatedAmount;

    uint256 public vestingScheduleCounter = 0;

    uint256 public globalStartTime;

    // value for minutes in a day
    uint32 private MINUTES_IN_DAY;

    event TokenVested(address indexed account, uint256 amount);

    event DepositTokenToContract(address indexed account, uint256 amount);

    event WithdrawTokenToContract(uint256 amount);

    event AddedVestingSchedules(address sender, uint256 amount);

    event CreatedVestingSchedule(
        address sender,
        address account,
        uint256 startTime,
        uint256 vestingPeriod,
        uint256 vestingStart,
        uint256 amount
    );

    /**
     * @dev Creates a vesting contract.
     * @param token_ address of the ERC20 token contract
     */
    constructor(address token_) {
        require(token_ != address(0x0));
        _token = IERC20(token_);

        globalStartTime = 1654041601; //1 June 2022 00:00:01

        MINUTES_IN_DAY = 24 * 60; // 24 * 60 for mainnet, 1 for testnet
    }

    /**
     * @notice Add bulk of vesting schedules
     * @param listOfRecipient address of beneficiary
     * @param listOfVestingPeriod total linear vesting duration in days
     * @param listOfVestingStart duration in days of the period until vesting is started
     * @param listOfAmount total amount of tokens to be released till the end of the vesting
     */
    function addVestingSchedules(
        address[] memory listOfRecipient,
        uint256[] memory listOfVestingPeriod,
        uint256[] memory listOfVestingStart,
        uint256[] memory listOfAmount
    ) public onlyOwner {
        require(
            listOfRecipient.length == listOfVestingPeriod.length &&
                listOfRecipient.length == listOfVestingStart.length &&
                listOfRecipient.length == listOfAmount.length,
            "Data for Vesting Schedules is invalid."
        );

        uint256 _totalAmount = 0;
        for (uint8 i = 0; i < listOfRecipient.length; i++) {
            createVestingSchedule(
                listOfRecipient[i],
                listOfVestingPeriod[i],
                listOfVestingStart[i],
                listOfAmount[i]
            );
            _totalAmount += listOfAmount[i];
        }

        emit AddedVestingSchedules(msg.sender, _totalAmount);
    }

    /**
     * @notice Creates a new vesting schedule for a beneficiary.
     * @param _recipient address of beneficiary
     * @param _vestingPeriod total linear vesting duration in days
     * @param _vestingStart duration in days of the period until vesting is started
     * @param _amount total amount of tokens to be released till the end of the vesting
     */
    function createVestingSchedule(
        address _recipient,
        uint256 _vestingPeriod,
        uint256 _vestingStart,
        uint256 _amount
    ) public onlyOwner {
        require(_vestingPeriod > 0, "Vesting period must be > 0");
        require(_amount > 0, "Vesting amount must be > 0");
        require(
            vestingScheduleIdsByAddress[_recipient] == 0,
            "Vesting is already existing for this recipient"
        );
        require(
            notAllocatedAmount >= _amount,
            "Not enough amount to create a vesting."
        );

        vestingScheduleCounter++;
        vestingAccounts[vestingScheduleCounter] = _recipient;

        VestingSchedule memory vestingSchedule = VestingSchedule(
            vestingScheduleCounter,
            _recipient,
            _vestingPeriod * MINUTES_IN_DAY * 60,
            _vestingStart * MINUTES_IN_DAY * 60,
            _amount,
            0,
            false
        );

        vestingScheduleIdsByAddress[_recipient] = vestingScheduleCounter;
        vestingSchedulesById[vestingScheduleCounter] = vestingSchedule;
        notAllocatedAmount -= _amount;

        emit CreatedVestingSchedule(
            msg.sender,
            _recipient,
            globalStartTime,
            _vestingPeriod,
            _vestingStart,
            _amount
        );
    }

    /**
     * @notice Claim vested tokens that have vested as of now
     * @param to redirected address of recipient
     */
    function _claimTo(address to) internal {
        require(
            vestingScheduleIdsByAddress[msg.sender] != 0,
            "No existing vesting."
        );

        uint256 id = vestingScheduleIdsByAddress[msg.sender];

        require(!vestingSchedulesById[id].isEnded, "Vesting is ended.");

        require(
            block.timestamp >
                globalStartTime + vestingSchedulesById[id].vestingStart,
            "Vesting is not started"
        );

        uint256 _amount = computeClaimableAmount(id);

        require(
            _token.balanceOf(address(this)) > _amount,
            "Not enough remained token on contract"
        );

        if (
            block.timestamp >=
            globalStartTime +
                vestingSchedulesById[id].vestingStart +
                vestingSchedulesById[id].vestingPeriod
        ) {
            vestingSchedulesById[id].isEnded = true;
        }

        _token.transfer(to, _amount);

        vestingSchedulesById[id].vestedAmount += _amount;

        emit TokenVested(to, _amount);
    }

    /**
     * @notice Claim vested amount of tokens.
     */
    function claimVestedTokens() external {
        _claimTo(msg.sender);
    }

    /**
     * @notice Claim vested amount of tokens.
     * @param to address of recipient
     */
    function claimVestedTokensTo(address to) external {
        _claimTo(to);
    }

    /**
     * @notice Release vested amount of tokens.
     */
    function transferVestedTokens() public onlyOwner nonReentrant {
        transferVestedTokensByIds(1, vestingScheduleCounter);
    }

    /**
     * @notice Release vested amount of tokens.
     */
    function transferVestedTokensByIds(uint256 from, uint256 to)
        public
        onlyOwner
    {
        require(block.timestamp > globalStartTime, "Vesting is not started.");

        bool isFinalEnded = true;
        for (uint256 i = from; i <= to; i++) {
            if (!vestingSchedulesById[i].isEnded) {
                isFinalEnded = false;
                break;
            }
        }

        require(!isFinalEnded, "Vesting is ended.");

        for (uint256 i = from; i <= to; i++) {
            transferVestedTokenById(i);
        }
    }

    /**
     * @notice Release vested amount of tokens.
     * @param id unique id of vesting
     */
    function transferVestedTokenById(uint256 id) internal onlyOwner {
        uint256 _amount = computeClaimableAmount(id);
        require(
            _token.balanceOf(address(this)) > _amount,
            "Not enough remained token on contract"
        );

        _token.transfer(vestingSchedulesById[id].recipient, _amount);

        vestingSchedulesById[id].vestedAmount += _amount;

        if (
            block.timestamp >=
            globalStartTime +
                vestingSchedulesById[id].vestingStart +
                vestingSchedulesById[id].vestingPeriod
        ) {
            vestingSchedulesById[id].isEnded = true;
        }

        emit TokenVested(vestingSchedulesById[id].recipient, _amount);
    }

    /**
     * @dev Computes the vested amount of tokens at this moment since last vesting
     * @param id vesting id
     * @return _amount of new tokens vested at this moment since last vesting
     */
    function computeClaimableAmount(uint256 id)
        public
        view
        returns (uint256 _amount)
    {
        if (vestingSchedulesById[id].isEnded) {
            _amount = 0;
        } else {
            if (block.timestamp < globalStartTime) {
                _amount = 0;
            } else if (
                block.timestamp >=
                globalStartTime +
                    vestingSchedulesById[id].vestingStart +
                    vestingSchedulesById[id].vestingPeriod
            ) {
                _amount =
                    vestingSchedulesById[id].allocatedAmount -
                    vestingSchedulesById[id].vestedAmount;
            } else {
                if (
                    block.timestamp >=
                    globalStartTime + vestingSchedulesById[id].vestingStart
                ) {
                    _amount =
                        (vestingSchedulesById[id].allocatedAmount *
                            (block.timestamp -
                                globalStartTime -
                                vestingSchedulesById[id].vestingStart)) /
                        vestingSchedulesById[id].vestingPeriod -
                        vestingSchedulesById[id].vestedAmount;
                } else {
                    _amount = 0;
                }
            }
        }
    }

    /**
     * @notice Owner deposit depositVestingAmount to contract.
     * @param _amount amount of tokens which Owner deposit to contract
     */
    function depositVestingAmount(uint256 _amount)
        public
        onlyOwner
        nonReentrant
    {
        _token.transferFrom(msg.sender, address(this), _amount);

        notAllocatedAmount = notAllocatedAmount + _amount;

        emit DepositTokenToContract(msg.sender, _amount);
    }

    function getGlobalStartTime() public view returns (uint256) {
        return globalStartTime;
    }

    /**
     * @dev Returns the vesting account address at the given id.
     * @return the vesting account address
     */
    function getVestingAccountById(uint256 id) public view returns (address) {
        require(id <= vestingScheduleCounter, "vesting: index out of bounds");
        return vestingSchedulesById[id].recipient;
    }

    /**
     * @notice Returns the vesting schedule struct for a given address.
     * @return the vesting schedule structure information
     */
    function getVestingScheduleByAddress(address account)
        public
        view
        returns (VestingSchedule memory)
    {
        return vestingSchedulesById[vestingScheduleIdsByAddress[account]];
    }

    /**
     * @notice Returns the vesting schedule struct for a given id.
     * @return the vesting schedule structure information
     */
    function getVestingScheduleById(uint256 id)
        public
        view
        returns (VestingSchedule memory)
    {
        return vestingSchedulesById[id];
    }

    /**
     * @notice Returns the total amount of vesting schedules.
     * @return the total amount of vesting schedules
     */
    function getNotAllocatedAmount() external view returns (uint256) {
        return notAllocatedAmount;
    }

    /**
     * @dev Returns the address of the ERC20 token managed by the vesting contract.
     */
    function getToken() external view returns (address) {
        return address(_token);
    }

    /**
     * @dev Returns the number of vesting accounts managed by this contract.
     * @return the number of vesting accounts
     */
    function getVestingAccountsCount() public view returns (uint256) {
        return vestingScheduleCounter;
    }

    /**
     * @dev Returns the number of vesting accounts managed by this contract.
     * @param account address of vesting
     * @return the claimable token amount
     */
    function getClaimable(address account) public view returns (uint256) {
        return computeClaimableAmount(vestingScheduleIdsByAddress[account]);
    }
}