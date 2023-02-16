/**
 *Submitted for verification at BscScan.com on 2023-02-16
*/

/** 
 *  SourceUnit: /home/ilad/Dropbox/code/tokenos-web3/contracts/Main.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
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




/** 
 *  SourceUnit: /home/ilad/Dropbox/code/tokenos-web3/contracts/Main.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: Unlicense
pragma solidity 0.8.7;

interface IConfig {
    event AdminChanged(address indexed _newAdmin);

    function pause() external;

    function isPaused() external view returns (bool);

    function unPause() external;

    /**
     * @dev change the contract owner using the recovery wallet address
     * 
     * @param _newAdmin the address of the new contract admin/owner
     * 
     * @notice Event emmited: {AdminChanged}
     */
    function changeAdmin(address _newAdmin) external;
}




/** 
 *  SourceUnit: /home/ilad/Dropbox/code/tokenos-web3/contracts/Main.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

////import "../utils/Context.sol";

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




/** 
 *  SourceUnit: /home/ilad/Dropbox/code/tokenos-web3/contracts/Main.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

////import "../utils/Context.sol";

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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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




/** 
 *  SourceUnit: /home/ilad/Dropbox/code/tokenos-web3/contracts/Main.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [////IMPORTANT]
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
     * ////IMPORTANT: because control is transferred to `recipient`, care must be
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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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




/** 
 *  SourceUnit: /home/ilad/Dropbox/code/tokenos-web3/contracts/Main.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
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
     * ////IMPORTANT: The same issues {IERC20-approve} has related to transaction
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




/** 
 *  SourceUnit: /home/ilad/Dropbox/code/tokenos-web3/contracts/Main.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
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
     * ////IMPORTANT: Beware that changing an allowance with this method brings the risk
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




/** 
 *  SourceUnit: /home/ilad/Dropbox/code/tokenos-web3/contracts/Main.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: Unlicense
pragma solidity 0.8.7;

contract Constants {
    uint256 constant PIP= 1e10;
    uint256 constant HUNDRED_PERCENT = 1 * PIP;
    uint256 constant NINETY9_PERCENT = 99e8; //0.99 * PIP or 9900000000

    constructor() {}
}




/** 
 *  SourceUnit: /home/ilad/Dropbox/code/tokenos-web3/contracts/Main.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: Unlicense
pragma solidity 0.8.7;
////import "@openzeppelin/contracts/security/Pausable.sol";
////import "@openzeppelin/contracts/access/Ownable.sol";
////import "../interfaces/IConfig.sol";

abstract contract Config is IConfig, Pausable, Ownable {
    address private immutable _recovery;
    error Disabled();

    constructor(address _recoveryIn){
        require(_recoveryIn != address(0), "Recovery address should not be Zero!");
        _recovery = _recoveryIn;
    }

    modifier onlyRecoveryWallet() {
        require(_recovery == _msgSender(), "You are not authorized!");
        _;
    }

    function pause() external override onlyOwner {
        _pause();
    }

    function isPaused() external view override returns (bool) {
        return paused();
    }

    function unPause() external override onlyOwner {
        _unpause();
    }

    function changeAdmin(address _newAdmin) external virtual override onlyRecoveryWallet {
        require(_newAdmin != address(0), "Config: New admin addres can not be Zero!");
        require(_newAdmin != owner(), "Config: New admin is the same!");
        _transferOwnership(_newAdmin);
        emit AdminChanged(_newAdmin);
    }

    // to limit ownership transfer to {changeAdmin} function only.
    function transferOwnership(address newOwner) public view override onlyOwner {
        revert Disabled();
    }

    function renounceOwnership() public view override onlyOwner {
        revert Disabled();
    }
}




/** 
 *  SourceUnit: /home/ilad/Dropbox/code/tokenos-web3/contracts/Main.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: Unlicense
pragma solidity 0.8.7;

interface IMain {
    /* ========== EVENTS ========== */

    event PlanCreated(uint256 _budget, bytes32 _merkleRootHash);
    event RootHashChanged(uint256 indexed _planIndex, bytes32 _newRootHash);
    event LogClaimed(address indexed _by, uint256 indexed _planIndex, uint256 _amount, uint256 _total);
    event WalletChanged(address indexed _previous, address indexed _new);
    event Withdrawn(uint256 _amount);
    event Cancelled(address _stakeholder);

    /* ========== DATA STRUCTURE ========== */

    struct PlanStruct {
        // plan index in the plans array
        uint256 index;
        uint256 budget;
        // % released at the beginning (startAt moment)
        uint256 tgeReleasePercentage;
        // Plan Timing
        uint256 startAt;
        uint256 lockupDuration;
        uint256 cliffDuration;
        uint256 vestingDuration; // {cliffDuration} + vesting duration
        // Vesting Schedule; only one type should be set, Linear or Custom.
        uint256 linearUnlockFrequency; //Linear
        CustomVestingStruct customSchedule; // Custom
        bytes32 merkleRootHash;
        bool isTrustless;
        // When a stakeholder's allocation is cancelled,
        // the already vested tokens would be kept until claimed; to helpe {_computeWithdrawable}
        uint256 reservedForCancelledStakeholders;
        // Keep track of claimed tokens for stakeholders to help with computations
        uint256 totalClaimedByActiveStakeholders; // for the active stakeholders
        uint256 totalClaimedByCancelledStakeholders; // for the Cancelled stakeholder
        uint256 cancelledAllocationPercentage; // keep track of total allocation percentages cancelled
        uint256 cancelledAt; // the moment the plan has been cancelled
    }

    struct StakeholderStruct {
        uint256 tokensClaimed; // keep track of the claimed tokens per plan
        uint256 cancelledAt; // keep cancellation date for the stakeholder
    }

    struct CustomVestingStruct {
        uint256[] timestamps;
        uint256[] percentages;
    }

    /* ========== VIEW ========== */

    function getPlanDetails(uint256 _index) external returns (PlanStruct memory);

    /**
     * @dev compute the necessary amount of tokens for the upcoming unlocks withing the {_timeframe} in the future
     * @param _timeframe the duration in the future to calculate upcoming unlocks
     *
     * @return an amount of token that is required for stakeholders to claim in future (_timeframe)
     */
    function computeTopUp(uint256 _timeframe) external view returns (uint256);

    /**
     * @dev returns how many token are already vested
     */
    function vested(uint256 _planIndex, address _stakeholder, uint256 _allocation) external view returns (uint256);

    /**
     * @dev computes the amount of token that are actually claimable by the stakeholder
     * Note: if the plan is not topped up, then claimable would be 0
     * also already claimed tokens are reduced.
     */
    function claimable(uint256 _planIndex, address _stakeholder, uint256 _allocation) external view returns (uint256);

    /**
     * Compute how much of the avaialbe tokens are claimable by the admin
     */
    function withdrawable() external view returns (uint256);

    /* ========== ADMIN ONLY ========== */

    // TODO emit plan created
    /**
     * @dev create a single or multiple new plans in batch
     * @param _budget an array of plans budget
     * @param _tgeReleasePercentage an array of plans tge release %
     * @param _startAt an array of plans start datetime
     * @param _durations an array of plans duration
     * @param _merkleRootHashes an array of The root hash of the Merkle Tree of the whitelist information:
     *  2D array of [Address, Allocation]
     * @param _linearUnlockFrequency an array of unlock frequency in case of a Linear vesting; else set to 0
     * @param  _customSchedule an array of timestamps and unlock percentage for custom vesting
     * @param  _isTrustless an array of boolean value indicating if the plan is trustless or not
     */
    function createNewPlansInBulk(
        uint256[] memory _budget,
        uint256[] memory _tgeReleasePercentage,
        uint256[] memory _startAt,
        uint256[3][] memory _durations,
        bytes32[] memory _merkleRootHashes,
        uint256[] memory _linearUnlockFrequency,
        uint256[][2][] memory _customSchedule,
        bool[] memory _isTrustless
    ) external;

    /**
     * @dev create a new plan [Gas Optimized]
     * @param _budget the amount of the budget
     * @param _tgeReleasePercentage % amount of the tge release
     * @param _startAt plan start datetime
     * @param _durations plan durations
     * @param _merkleRootHash The root hash of the Merkle Tree of the whitelist information:
     *  2D array of [Address, Allocation]
     * @param _linearUnlockFrequency unlock frequency in case of a Linear vesting; otherwise 0
     * @param  _customSchedule timestamps and unlock percentages for a custom vesting
     * @param  _isTrustless a boolean indicating if the plan is trustless
     */
    function createNewPlan(
        uint256 _budget,
        uint256 _tgeReleasePercentage,
        uint256 _startAt,
        uint256[3] memory _durations,
        bytes32 _merkleRootHash,
        uint256 _linearUnlockFrequency,
        uint256[][2] memory _customSchedule,
        bool _isTrustless
    ) external;

    /**
     * @dev Migrate whitelist (change stakeholders address and allocation in bulk)
     * @dev stakeholder allocation change is applied in the root hash
     * @dev stakeholder wallet address change must be provided in {_currentes} and {_newAddresses}
     * @param _planIndexes Indexes of plans to update their Merkle Tree Root Hash
     * @param _newRootHashes the new root hashes
     * @param _current the current wallet address to migrate from
     * @param _new the new wallet address to migrate to from the current address
     */
    function migrateWhitelist(
        uint256[] calldata _planIndexes,
        bytes32[] calldata _newRootHashes,
        address _current,
        address _new
    ) external;

    /**
     * @dev push (transfer) claimable tokens to stakeholder's wallet
     * @param _planIndex the index of the plan
     * @param _stakeholdersAddress an array of whiteilsted stakeholder's wallet address
     * NOTE will revert if anything goes wrong! all or nothing approach.
     */

    /**
     *  calculate the amount of claimable tokens for everyone in that plan
     */
    // function prepareToPush(uint256 _planIndex, address[] calldata _stakeholdersAddress) external;

    //TODO try to prevent sending the list again!
    // write into an array
    // always write from start! of the array!
    // arrays with a dynamic size
    // function push(uint256 _planIndex, address[] calldata _stakeholdersAddress) external;

    /**
     * Transfer withdrawable tokens from the Main smart contract
     * @param _amount The amount of tokens to withdraw from the Main
     */
    function withdraw(uint256 _amount) external;

    /**
     * @dev cancel stakeholder(s) allocation so no more tokens would be released for them
     * @dev the already vested or released tokens would be still claimable if topped up
     * @dev top up computer would calculate required tokens only until the cancellation date
     * @param _planIndex the plan that {_stakeholders} are part of
     * @param _stakeholders an array of the stakeholders address
     * @param _allocations an array of the allocations for each stakeholder
     */
    function cancelStakeholders(uint256 _planIndex, address[] calldata _stakeholders, uint256[] calldata _allocations) external;

    /**
     * @dev Cancel the whole distribution; no more tokens would be released
     * @dev the already vested or released tokens would be still claimable if topped up
     * @dev top up computer would calculate required tokens only until the cancellation date
     * @param _plansIndex an array of plan indexes to cancel
     */
    function cancelPlansInBulk(uint256[] calldata _plansIndex) external;

    /* ========== USER FUNCTION ========== */

    //TODO use this as push functionality as well, later.
    // function claim(uint256 _planIndex, address _address, uint256 _allocation, uint256 _amount) external;

    /**
     * @dev claim in bulk
     * @param _stakeholder whome tokens would be claimed
     * @param _planIds list all plans this stakeholder wants to claim from
     * @param _allocations array of allocations for the each equivalent plan
     * @param _proofs array of proofs required for each plan request;
     */
    function claimBulk(address _stakeholder, uint256[] calldata _planIds, uint256[] calldata _allocations, bytes32[][] calldata _proofs) external;
}




/** 
 *  SourceUnit: /home/ilad/Dropbox/code/tokenos-web3/contracts/Main.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Tree proofs.
 *
 * The tree and the proofs can be generated using our
 * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].
 * You will find a quickstart guide in the readme.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates merkle trees that are safe
 * against this attack out of the box.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     *
     * _Available since v4.7._
     */
    function verifyCalldata(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Calldata version of {processProof}
     *
     * _Available since v4.7._
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Calldata version of {multiProofVerify}
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * _Available since v4.7._
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}




/** 
 *  SourceUnit: /home/ilad/Dropbox/code/tokenos-web3/contracts/Main.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

////import "../IERC20.sol";
////import "../extensions/draft-IERC20Permit.sol";
////import "../../../utils/Address.sol";

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
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


/** 
 *  SourceUnit: /home/ilad/Dropbox/code/tokenos-web3/contracts/Main.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: Unlicense
pragma solidity 0.8.7;
////import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
////import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
////import "./interfaces/IMain.sol";
////import "./modules/Config.sol";
////import "./modules/Constants.sol";

contract Main is
    IMain,
    /* ========== CONSTANTS ========== */
    Constants,
    /* ========== Config ========== */
    Config
{
    /* ========== STATE VARIABLES - Per Project ========== */
    using SafeERC20 for IERC20;
    IERC20 public immutable projectToken;

    /* ========== STATE VARIABLES - Per Plan ========== */

    PlanStruct[] plans; // List of all the plans

    // planId => stakeholder address => stakeholder status
    mapping(uint256 => mapping(address => StakeholderStruct)) stakeholders;

    /* ========== CONSTRUCTOR ========== */
    constructor(address _token, address _recovery) Config(_recovery) {
        //TODO add tests
        require(_token != address(0), "Token address should not be Zero!");

        projectToken = IERC20(_token);
    }

    /* ========== VIEWS ========== */

    function verifyProofByHash(
        bytes32 _rootHash,
        uint256 _planIndex,
        address _stakeholder,
        uint256 _stakeholderAllocation,
        bytes32[] calldata _proof
    ) external pure returns (bool) {
        _verify(_rootHash, _planIndex, _stakeholder, _stakeholderAllocation, _proof);
        return true;
    }

    function verifyProofByPlanId(
        uint256 _planIndex,
        address _stakeholder,
        uint256 _stakeholderAllocation,
        bytes32[] calldata _proof
    ) external view returns (bool) {
        _verify(_getPlan(_planIndex).merkleRootHash, _planIndex, _stakeholder, _stakeholderAllocation, _proof);
        return true;
    }

    function getPlanDetails(uint256 _index) external view override returns (PlanStruct memory) {
        return plans[_index];
    }

    // @dev Computer
    function computeTopUp(uint256 _timeframe) external view override returns (uint256 _requiredTokens) {
        uint256 _until = block.timestamp + _timeframe;

        // iterate through all the plans
        uint256 _lengthOfPlans = plans.length;
        for (uint i = 0; i < _lengthOfPlans; i++) {
            // calculate vested until for the plan!
            if (plans[i].isTrustless) {
                _requiredTokens += plans[i].budget / PIP;
            } else {
                _requiredTokens += _computeVestedUntilForPlan(
                    plans[i],
                    HUNDRED_PERCENT - plans[i].cancelledAllocationPercentage,
                    plans[i].cancelledAt != 0 ? plans[i].cancelledAt : _until // RU-08
                );
            }

            // reduce total claimed tokens of the plan
            _requiredTokens = _subHelper(_requiredTokens, plans[i].totalClaimedByActiveStakeholders);
        }

        uint256 _existingTokens = projectToken.balanceOf(address(this));
        _requiredTokens = _subHelper(_requiredTokens, _existingTokens);

        return _requiredTokens;
    }

    function vested(uint256 _planIndex, address _stakeholder, uint256 _allocation) external view override returns (uint256) {
        PlanStruct storage _p = _getPlan(_planIndex);
        return _computeVestedForIndividual(_p, _stakeholder, _allocation);
    }

    function claimable(uint256 _planIndex, address _stakeholder, uint256 _allocation) external view override returns (uint256) {
        PlanStruct storage _p = _getPlan(_planIndex);
        return _claimable(_p, _stakeholder, _allocation);
    }

    function withdrawable() external view override returns (uint256) {
        return _computeWithdrawable();
    }

    function countOfPlans() external view returns (uint256) {
        return plans.length;
    }

    function getStakeholderStatus(uint256 _planIndex, address _stakeholder) public view returns (StakeholderStruct memory) {
        return stakeholders[_planIndex][_stakeholder];
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    //TODO possible to use as the push functionality
    //TODO get msg sender
    /**
     * @dev Transfer the {amount} of vested token to caller (stakeholder)'s wallet
     * Note: _amount must be <= vested
     */
    function claim(uint256 _planIndex, address _stakeholder, uint256 _allocation, uint256 _amount, bytes32[] calldata _proof) public {
        _verify(_getPlan(_planIndex).merkleRootHash, _planIndex, _stakeholder, _allocation, _proof);

        require(_amount != 0, "_amount is 0!");

        PlanStruct storage _p = _getPlan(_planIndex);

        bool _isStakeholderCancelled = getStakeholderStatus(_planIndex, _stakeholder).cancelledAt != 0;

        if (_isStakeholderCancelled) {
            // @dev the computations for Vested tokens relies on planDetails information.
            // @dev to keep the computation correct, when a cancelled stakeholder claims,
            //@dev we keep their claimed amount in a separate variable.
            _p.totalClaimedByCancelledStakeholders += _amount;
        } else {
            _p.totalClaimedByActiveStakeholders += _amount;
        }

        uint256 _availableTokens = projectToken.balanceOf(address(this));

        uint256 _trustlessPlansReservedTokens = _computeAmountOfReservedTokensForTrustlessPlans();

        if (_p.isTrustless) {
            require(_availableTokens >= _trustlessPlansReservedTokens, "Trustless plans must be topped up fully!");
        } else {
            // RE-11 trustless plans can not be paused!
            _requireNotPaused();

            // make sure to keep the reserved tokens for trustless plans intact
            // for their stakeholders to claim their tokens first (before other plan's stakeholders consume it)
            _availableTokens = _subHelper(_availableTokens, _trustlessPlansReservedTokens);
        }

        uint256 _claimableAmount = _claimable(_p, _stakeholder, _allocation);
        require(_claimableAmount != 0, "0 claimable tokens!");
        require(_amount <= _claimableAmount, "_amount > _claimable!");
        require(_amount <= _availableTokens, "needs top-up!");

        _appendStakeholderClaimedAmount(_planIndex, _stakeholder, _amount);

        emit LogClaimed(_stakeholder, _planIndex, _amount, getStakeholderStatus(_planIndex, _stakeholder).tokensClaimed);

        projectToken.safeTransfer(_stakeholder, _amount);
    }

    function claimBulk(
        address _stakeholder,
        uint256[] calldata _planIds,
        uint256[] calldata _allocations,
        bytes32[][] calldata _proofs
    ) external override {
        for (uint _i = 0; _i < _planIds.length; _i++) {
            uint256 _planId = _planIds[_i];
            uint256 _claimableAmount = _claimable(_getPlan(_planId), _stakeholder, _allocations[_i]);
            if (_claimableAmount > 0) claim(_planId, _stakeholder, _allocations[_i], _claimableAmount, _proofs[_i]);
        }
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function createNewPlansInBulk(
        uint256[] memory _budget,
        uint256[] memory _tgeReleasePercentage,
        uint256[] memory _startAt,
        uint256[3][] memory _durations,
        bytes32[] memory _merkleRootHashes,
        uint256[] memory _linearUnlockFrequency,
        uint256[][2][] memory _customSchedule,
        bool[] memory _isTrustless
    ) external override onlyOwner {
        for (uint i = 0; i < _budget.length; i++) {
            createNewPlan(
                _budget[i],
                _tgeReleasePercentage[i],
                _startAt[i],
                _durations[i],
                _merkleRootHashes[i],
                _linearUnlockFrequency[i],
                _customSchedule[i],
                _isTrustless[i]
            );
        }
    }

    function createNewPlan(
        uint256 _budget,
        uint256 _tgeReleasePercentage,
        uint256 _startAt,
        uint256[3] memory _durations,
        bytes32 _merkleRootHash, // merkle tree root hash
        uint256 _linearUnlockFrequency,
        uint256[][2] memory _customSchedule,
        bool _isTrustless
    ) public override onlyOwner {
        _requireNotPaused();

        require(_budget >= PIP, "Plan Budget too low!");
        require(_startAt >= block.timestamp, "Start time can not be in the past!");
        require(_tgeReleasePercentage <= HUNDRED_PERCENT, "TGE release must be <= 100%!");

        PlanStruct memory _p;

        _p.index = plans.length; // set the index of the plan
        _p.budget = _budget;
        _p.startAt = _startAt;
        _p.lockupDuration = _durations[0];
        _p.cliffDuration = _durations[1];
        _p.vestingDuration = _durations[2];

        uint256[] memory _timestamps = _customSchedule[0];
        uint256[] memory _unlockPercentage = _customSchedule[1];
        // Set the Vesting Schedule

        // Linear VS Custom
        if (_linearUnlockFrequency != 0) {
            // linear vesting

            // the following durations only apply for the linear vesting
            require(_durations[1] <= _durations[2], "Cliff duration can't be > vesting duration in Linear Vesting!");
            require(_durations[2] != 0, "Vesting duration can not be zero in Linear Vesting!");
            require(
                _durations[0] == 0 || // lockup
                    _durations[1] == 0, // cliff
                "Either Cliff or Lockup should be set in Linear Vesting!"
            );

            require(_linearUnlockFrequency <= _p.vestingDuration, "Unlock period should be less than total duration of Vesting!");
            _p.linearUnlockFrequency = _linearUnlockFrequency;
            _p.tgeReleasePercentage = _tgeReleasePercentage; // Only a Linear vesting can have a TGE;
        } else if (_timestamps.length != 0) {
            // custom vesting
            require(_timestamps.length == _unlockPercentage.length, "custom vesting input not the same length!");

            uint256 _totalAmounts = 0;
            for (uint256 j = 0; j < _timestamps.length; j++) {
                if (j != 0) {
                    require(_timestamps[j] > _timestamps[j - 1], "timestamps should be in ascending order!");
                }
                _totalAmounts += _unlockPercentage[j];
            }
            require(
                _totalAmounts + _tgeReleasePercentage >= NINETY9_PERCENT && _totalAmounts + _tgeReleasePercentage <= HUNDRED_PERCENT,
                "Custom vesting schedule + tge should be >= 99% and <= 100%"
            ); //RU-011
            _p.customSchedule = CustomVestingStruct(_timestamps, _unlockPercentage);
        } else {
            revert("VestingScheduleNotSet");
        }

        _p.isTrustless = _isTrustless;

        // Whitelist stakeholders
        _p.merkleRootHash = _merkleRootHash;
        plans.push(_p);

        emit PlanCreated(_budget, _merkleRootHash);
    }

    function migrateWhitelist(
        uint256[] calldata _planIndexes,
        bytes32[] calldata _newRootHashes,
        address _currentAddress,
        address _newAddress
    ) external override onlyOwner {
        // only change the root hash!?
        for (uint i = 0; i < _planIndexes.length; i++) {
            require(_newRootHashes[i].length != 0, "Merkle Root Hash is empty!");

            uint256 _planIndex = _planIndexes[i];
            PlanStruct storage _p = _getPlan(_planIndex);
            require(!_p.isTrustless, "Forbidden!");

            _p.merkleRootHash = _newRootHashes[i];

            emit RootHashChanged(_planIndex, _newRootHashes[i]);

            _migrateWalletAddress(_planIndex, _currentAddress, _newAddress);
        }
    }

    // function push(uint256 _planIndex, address[] calldata _stakeholdersAddress) external override onlyOwner {
    // first calculate
    // then actually transfer tokens in another call ?

    //     require(_stakeholdersAddress.length > 0, "Input array lenght = 0!");
    //     // if the plan is not trustless: _requireNotPaused();
    //     // iterate through stakeholders
    //     // calculate claimable
    //     // check if claimable is available?
    //     // payable(_stakeholdersAddress[0]).transfer(_claimable);
    // }

    function withdraw(uint256 _amount) external override onlyOwner {
        _requireNotPaused();
        if (_computeWithdrawable() >= _amount) {
            emit Withdrawn(_amount);
            projectToken.safeTransfer(_msgSender(), _amount);
        } else {
            revert("Not enough available tokens!");
        }
    }

    /**
     * @dev [+] Cancel stakeholder:
     *      [+] set Cancelled = currently Vested tokens
     *      [+] remove the stakeholder from the plan calculations
     *          [+] adjust calculations with the removed %
     *      [+] adjust withdrawable
     *          [+] unvested tokens should be added to the withdrawable
     *      [+] adjust claimable
     */
    function cancelStakeholders(
        uint256 _planIndex,
        address[] calldata _stakeholdersAddress,
        uint256[] calldata _allocations
    ) external override onlyOwner {
        PlanStruct storage _p = _getPlan(_planIndex);

        require(!_p.isTrustless, "Forbidden!");

        for (uint i = 0; i < _stakeholdersAddress.length; i++) {
            //TODO possible revert!
            if (getStakeholderStatus(_planIndex, _stakeholdersAddress[i]).cancelledAt != 0) continue;

            // keep already vested tokens to help compute withdrawable tokens
            uint256 _alreadyVestedTokens = _computeVestedForIndividual(_p, _stakeholdersAddress[i], _allocations[i]);
            _p.reservedForCancelledStakeholders += _alreadyVestedTokens;

            _p.cancelledAllocationPercentage += _allocations[i];

            _setStakeholderCancelledAt(_planIndex, _stakeholdersAddress[i], block.timestamp);

            // @dev computing unlock amounts are happening in lazy mode, meaning they are calculated on the fly
            // @dev we remove the claimed tokens by the cancelled stakeholder to keep the top-up computer correct.
            _p.totalClaimedByActiveStakeholders = _subHelper(
                _p.totalClaimedByActiveStakeholders,
                getStakeholderStatus(_p.index, _stakeholdersAddress[i]).tokensClaimed
            );
            emit Cancelled(_stakeholdersAddress[i]);
        }
    }

    function cancelPlansInBulk(uint256[] calldata _plansIndex) external override onlyOwner {
        for (uint i = 0; i < plans.length; i++) {
            PlanStruct storage _p = _getPlan(_plansIndex[i]);
            require(!_p.isTrustless, "Forbidden!");
            _p.cancelledAt = block.timestamp;
        }
    }

    /* ========== PRIVATE FUNCTIONS ========== */

    /**
     * @dev verify if the proof is valid using merkle root hash of the plan.
     * @param _rootHash the root hash set in the plan details
     * @param _planIndex the index of the plan
     * @param _addr  stakeholder address
     * @param _allocation stakeholder allocation
     * @param _proof the proof bytes
     */
    function _verify(bytes32 _rootHash, uint256 _planIndex, address _addr, uint256 _allocation, bytes32[] calldata _proof) private pure {
        bytes32 _leaf = keccak256(bytes.concat(keccak256(abi.encode(_planIndex, _addr, _allocation))));
        require(MerkleProof.verify(_proof, _rootHash, _leaf), "Invalid proof");
    }

    /**
     * add up to the claimed amount
     * @param _planIndex The index of the plan
     * @param _stakeholder the address of the stakeholder
     * @param _claimedAmount the amount to append to the currently claimed amount
     */
    function _appendStakeholderClaimedAmount(uint256 _planIndex, address _stakeholder, uint256 _claimedAmount) private {
        stakeholders[_planIndex][_stakeholder].tokensClaimed += _claimedAmount;
    }

    function _setStakeholderCancelledAt(uint256 _planIndex, address _stakeholder, uint256 _cancelledAt) private {
        stakeholders[_planIndex][_stakeholder].cancelledAt = _cancelledAt;
    }

    // @dev undo whitelist of the {_currentAddress} and replace it with the {_newAddress}
    // reset the allocation (undo the whitelist) but keep the amount of claimed token;
    // no particular usecase for now, but lets keep if for now.
    function _migrateWalletAddress(uint256 _planIndex, address _current, address _new) private {
        StakeholderStruct memory _currentAddressStatus = getStakeholderStatus(_planIndex, _current);
        require(_currentAddressStatus.cancelledAt == 0, "The Stakeholder is cancelled!");

        _appendStakeholderClaimedAmount(_planIndex, _new, _currentAddressStatus.tokensClaimed);

        emit WalletChanged(_current, _new);
    }

    function _getPlan(uint256 _planId) internal view virtual returns (PlanStruct storage) {
        PlanStruct storage _p = plans[_planId];
        return _p;
    }

    /**
     * @dev computer
     * @dev the amount of token that is unlocked and can be claimed;
     * Note: the amount of claimed tokens are reduced.
     */
    function _claimable(PlanStruct storage _p, address _stakeholder, uint256 _allocation) internal view virtual returns (uint256) {
        return _subHelper(_computeVestedForIndividual(_p, _stakeholder, _allocation), getStakeholderStatus(_p.index, _stakeholder).tokensClaimed);
    }

    /**
     * @dev computer
     * @dev compute the amount of token that are already vested for the stakeholder
     * @param _p the plan that the stakeholder belongs to
     * @param _stakeholder the stakeholder address
     * @param _allocationPercentage the stakeholder allocation percentage
     */
    //TODO make it public or external?
    function _computeVestedForIndividual(PlanStruct storage _p, address _stakeholder, uint256 _allocationPercentage) private view returns (uint256) {
        uint256 _planCancelledAt = _p.cancelledAt;
        uint256 _stakeholderCancelledAt = getStakeholderStatus(_p.index, _stakeholder).cancelledAt;

        return
            _computeVestedUntilForPlan(
                _p,
                _allocationPercentage,
                // compute until the moment the plan was cancelled
                _planCancelledAt != 0 ? _planCancelledAt : (_stakeholderCancelledAt != 0 ? _stakeholderCancelledAt : block.timestamp)
            );
    }

    function _computeVestedUntilForPlan(PlanStruct storage _p, uint256 _allocationPercentage, uint256 _until) private view returns (uint256) {
        return
            _p.linearUnlockFrequency > 0 // Vesting type is Linear
                ? _computeLinearVestedUntil(_p, _allocationPercentage, _until)
                : _computeCustomVestedUntil(_p, _allocationPercentage, _until);
    }

    /**
     * @dev computer
     * @dev compute how much token should be reserved and how much is already claimed for trustless plans
     */
    function _computeAmountOfReservedTokensForTrustlessPlans() private view returns (uint256 _reservedTokens) {
        // loop through plans
        uint256 _lengthOfPlans = plans.length;
        for (uint i = 0; i < _lengthOfPlans; i++) {
            if (plans[i].isTrustless) _reservedTokens += ((plans[i].budget / PIP) - plans[i].totalClaimedByActiveStakeholders);
        }
    }

    // @dev computer
    function _computeWithdrawable() private view returns (uint256) {
        uint256 _reservedTokens = _computeAmountOfReservedTokensForTrustlessPlans();
        uint256 _length = plans.length;
        for (uint i = 0; i < _length; i++) {
            // trustless plans are already computed.
            if (plans[i].isTrustless) continue;
            _reservedTokens += _subHelper(
                _computeVestedUntilForPlan(
                    plans[i],
                    HUNDRED_PERCENT - plans[i].cancelledAllocationPercentage,
                    // RU-08
                    plans[i].cancelledAt != 0 ? plans[i].cancelledAt : block.timestamp
                ),
                plans[i].totalClaimedByActiveStakeholders
            );

            //@dev if there are any cancelled stakeholders
            if (plans[i].cancelledAllocationPercentage > 0)
                _reservedTokens += _subHelper(plans[i].reservedForCancelledStakeholders, plans[i].totalClaimedByCancelledStakeholders);
        }

        return _subHelper(projectToken.balanceOf(address(this)), _reservedTokens);
    }

    /**
     * @dev computer
     * @dev compute the amount of tokens unlocked until {_until} moment for a linear schedule
     * @param _p the storage pointer to the plan that the stakeholder belongs to
     * @param _allocationPercentage the allocation percentage of the stakeholder
     * @param _until a moment in time (now or future) to compute unlocks until then
     * @return _res the amount of vested tokens
     */
    function _computeLinearVestedUntil(PlanStruct storage _p, uint256 _allocationPercentage, uint256 _until) private view returns (uint256 _res) {
        uint256 _vestedMoment = _p.startAt + _p.lockupDuration + _p.vestingDuration;
        uint256 _vestingStartsAt = _p.startAt + _p.lockupDuration + _p.cliffDuration;
        bool _isLocked = _until >= _p.startAt && _until <= _vestingStartsAt;
        bool _isVesting = _until >= _vestingStartsAt;
        bool _isVested = _until >= _vestedMoment;

        if (_isVested) {
            _res = (_allocationPercentage * _getPlanBudget(_p.budget)) / PIP;
        } else if (_isLocked) {
            _res = _computeTGEByAllocation(_p, _allocationPercentage);
        } else if (_isVesting) {
            uint256 vestedAmount = _linearVestingComputeHelper(_p, _allocationPercentage, _until);
            _res = vestedAmount + _computeTGEByAllocation(_p, _allocationPercentage);
        }
    }

    /**
     * @dev computer
     * @dev Computes the amount of vested tokens for a Custom vesting schedule.
     * @param _p the storage pointer to the plan to calculate unlocked tokens
     * @param _allocationPercentage the allocation percentage of the stakeholder
     * @param _until a moment in time (now or future) to compute unlocks until then
     * @return _res the amount of vested tokens until the desired moment in time
     */
    function _computeCustomVestedUntil(PlanStruct storage _p, uint256 _allocationPercentage, uint256 _until) private view returns (uint256 _res) {
        CustomVestingStruct storage _customVesting = _p.customSchedule;

        if (_p.startAt > _until) return 0;
        uint256 _allocationsReleased = 0;
        uint256 _length = _customVesting.timestamps.length;
        uint256 _lastUnlock = _length - 1;
        for (uint i = 0; i < _length; i++) {
            if (_until >= _customVesting.timestamps[i]) {
                if (i == _lastUnlock) _allocationsReleased = HUNDRED_PERCENT - _p.cancelledAllocationPercentage;
                else _allocationsReleased += _customVesting.percentages[i];
            }
        }
        uint256 _planTotalBudget = _getPlanBudget(_p.budget);
        _res = (_allocationPercentage * (_planTotalBudget * _allocationsReleased)) / PIP / PIP;
    }

    /**
     * @dev get the real budget amount
     * Note: the budget might be a fractional point decimal
     * @param _budget the amount of budget multiplied by PIP
     * @return the real amount of budget (_budget / PIP)
     */
    function _getPlanBudget(uint256 _budget) private pure returns (uint256) {
        return _budget / PIP;
    }

    /**
     * @dev compute the amount of tokens unlocked at TGE (based on an allocation %)
     */
    function _computeTGEByAllocation(PlanStruct storage _p, uint256 _allocationPercentage) private view returns (uint256) {
        return ((_p.tgeReleasePercentage * _getPlanBudget(_p.budget)) * _allocationPercentage) / PIP / PIP;
    }

    /**
     * @dev computer
     * @dev helper function to compute the amount of vested token with a Linear Vesting schedule
     * NOTE: does not consider tokens unlocked at TGE.
     */
    function _linearVestingComputeHelper(PlanStruct storage _p, uint256 _allocationPercentage, uint256 _until) private view returns (uint256) {
        uint256 eachUnlockDuration = _p.linearUnlockFrequency;

        uint256 _totalNOfUnlocks = _p.vestingDuration / eachUnlockDuration;

        uint256 _tokenPerUnlock = _subHelper(
            _computeStakeholderAllocationAmount(_p.budget, _allocationPercentage),
            _computeTGEByAllocation(_p, _allocationPercentage)
        ) / _totalNOfUnlocks;

        uint256 _numberOfUnlocksUntilNow = _computePlanTimeFromStart(_p, _until) / eachUnlockDuration;
        return _tokenPerUnlock * _numberOfUnlocksUntilNow;
    }

    /**
     * @dev do the sub without complaining that {_a} is 0
     * Note: the order is ////important!
     */
    function _subHelper(uint256 _a, uint256 _b) private pure returns (uint256 _res) {
        return (_a >= _b) ? _a - _b : 0;
    }

    /**
     * @dev convert the % into N of tokens allocated to the stakeholder
     * NOTE: use the return value in a formula directly.
     */
    function _computeStakeholderAllocationAmount(uint256 _budget, uint256 _allocationPercentage) private pure returns (uint256) {
        return (_allocationPercentage * _budget) / PIP / PIP;
    }

    /**
     * @dev compute the time difference between now and the start time of the plan
     * this duration will help to calculate the N of unlocks happened until now
     */
    function _computePlanTimeFromStart(PlanStruct storage _p, uint256 _until) private view returns (uint256) {
        return _subHelper(_subHelper(_until, _p.lockupDuration), _p.startAt);
    }
}