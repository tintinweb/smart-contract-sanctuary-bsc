// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

import "../../externalContract/openzeppelin/non-upgradeable/Ownable.sol";
import "../../externalContract/openzeppelin/non-upgradeable/IERC20.sol";
import "../../externalContract/openzeppelin/non-upgradeable/SafeERC20.sol";
import "../../externalContract/modify/non-upgradeable/SelectorPausable.sol";
import "../../externalContract/modify/non-upgradeable/Manager.sol";

import "./event/InterestVaultEvent.sol";

contract InterestVault is InterestVaultEvent, Ownable, SelectorPausable, Manager {
    using SafeERC20 for IERC20;

    // NOTE: manager is owner account, owner is pool
    uint256 public claimableTokenInterest;
    uint256 public heldTokenInterest;
    uint256 public actualTokenInterestProfit;
    uint256 public claimableForwInterest;
    uint256 public cumulativeTokenInterestProfit;

    address public tokenAddress;
    address public forwAddress;
    address public protocolAddress;

    modifier onlyProtocol() {
        require(msg.sender == protocolAddress, "InterestVault/permission-denied");
        _;
    }

    constructor(
        address _token,
        address _forw,
        address _protocol,
        address _manager
    ) {
        tokenAddress = _token;
        forwAddress = _forw;
        protocolAddress = _protocol;
        manager = _manager;
        _ownerApprove(msg.sender);

        emit SetTokenAddress(msg.sender, address(0), tokenAddress);
        emit SetForwAddress(msg.sender, address(0), forwAddress);
        emit SetProtocolAddress(msg.sender, address(0), protocolAddress);
        emit TransferManager(address(0), _manager);
    }

    // pause / unPause
    function pause(bytes4 _func) external onlyOwner {
        require(_func != bytes4(0), "InterestVault/msg.sig-func-is-zero");
        _pause(_func);
    }

    function unPause(bytes4 _func) external onlyOwner {
        require(_func != bytes4(0), "InterestVault/msg.sig-func-is-zero");
        _unpause(_func);
    }

    function setForwAddress(address _address) external onlyManager {
        address oldAddress = forwAddress;
        forwAddress = _address;

        emit SetForwAddress(msg.sender, oldAddress, forwAddress);
    }

    function setTokenAddress(address _address) external onlyManager {
        address oldAddress = tokenAddress;
        tokenAddress = _address;

        emit SetTokenAddress(msg.sender, oldAddress, tokenAddress);
    }

    function setProtocolAddress(address _address) external onlyManager {
        address oldAddress = protocolAddress;
        protocolAddress = _address;

        emit SetProtocolAddress(msg.sender, oldAddress, protocolAddress);
    }

    /**
      @dev Function call by owner (APHPool) for allowing it to transfer token from InterestVault
     */
    function ownerApprove(address _pool) external onlyOwner {
        _ownerApprove(_pool);
    }

    /**
      @dev Function to settle value of claimable token interest, held token interest
            and claimable forw interest
            Called by APHCore (proxy)
     */
    function settleInterest(
        uint256 _claimableTokenInterest,
        uint256 _heldTokenInterest,
        uint256 _claimableForwInterest
    ) external onlyProtocol {
        _settleInterest(_claimableTokenInterest, _heldTokenInterest, _claimableForwInterest);
    }

    /**
      @dev Function to subtract token interest value, calculated from APHPool, and add actual profit
            Called by APHPool (proxy)
     */
    function withdrawTokenInterest(
        uint256 claimable,
        uint256 bonus,
        uint256 profit
    ) external onlyOwner {
        _withdrawTokenInterest(claimable, bonus, profit);
    }

    /**
      @dev Function to subtract forw interest value, calculated from APHPool
            Called by APHPool (proxy)
     */
    function withdrawForwInterest(uint256 claimAmount) external onlyOwner {
        _withdrawForwInterest(claimAmount);
    }

    /**
      @dev Function to withdraw token actual profit. Called by owner account
     */
    function withdrawActualProfit() external onlyManager returns (uint256) {
        return _withdrawActualProfit();
    }

    function getTotalTokenInterest() external view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function getTotalForwInterest() external view returns (uint256) {
        return IERC20(forwAddress).balanceOf(address(this));
    }

    // Internal
    // `receiver` is for later use (event)
    function _ownerApprove(address _pool) internal {
        uint256 approveAmount = type(uint256).max;
        IERC20(tokenAddress).safeApprove(_pool, approveAmount);
        IERC20(forwAddress).safeApprove(_pool, approveAmount);

        emit OwnerApprove(msg.sender, tokenAddress, forwAddress, approveAmount);
    }

    function _settleInterest(
        uint256 _claimableTokenInterest,
        uint256 _heldTokenInterest,
        uint256 _claimableForwInterest
    ) internal {
        claimableTokenInterest += _claimableTokenInterest;
        heldTokenInterest += _heldTokenInterest;
        claimableForwInterest += _claimableForwInterest;

        emit SettleInterest(
            msg.sender,
            claimableTokenInterest,
            heldTokenInterest,
            claimableForwInterest
        );
    }

    function _withdrawTokenInterest(
        uint256 claimable,
        uint256 bonus,
        uint256 profit
    ) internal {
        claimableTokenInterest -= claimable;
        heldTokenInterest -= bonus + profit;
        actualTokenInterestProfit += profit;
        cumulativeTokenInterestProfit += profit;

        emit WithdrawTokenInterest(msg.sender, claimable, bonus, profit);
    }

    function _withdrawForwInterest(uint256 claimable) internal {
        claimableForwInterest -= claimable;

        emit WithdrawForwInterest(msg.sender, claimable);
    }

    function _withdrawActualProfit() internal returns (uint256) {
        uint256 tempInterestProfit = actualTokenInterestProfit;
        actualTokenInterestProfit = 0;

        IERC20(tokenAddress).safeTransfer(manager, tempInterestProfit);

        emit WithdrawActualProfit(msg.sender, tempInterestProfit);
        return tempInterestProfit;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "./Context.sol";

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

import "./IERC20.sol";
import "./Address.sol";

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
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
        );
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
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
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
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../../openzeppelin/non-upgradeable/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract SelectorPausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account` and `function selector`.
     */
    event Paused(address account, bytes4 functionSelector);

    /**
     * @dev Emitted when the pause is lifted by `account` and `function selector`.
     */
    event Unpaused(address account, bytes4 functionSelector);

    mapping(bytes4 => bool) private _isPaused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        //_isPaused = false;
    }

    /**
     * @dev Returns true if the function selected is paused, and false otherwise.
     */
    function isPaused(bytes4 _func) public view virtual returns (bool) {
        return _isPaused[_func];
    }

    /**
     * @dev Modifier to make a function callable only when the function selected is not paused.
     *
     * Requirements:
     *
     * - The function selected must not be paused.
     */
    modifier whenFuncNotPaused(bytes4 _func) {
        require(!_isPaused[_func], "Pausable/function-is-paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the function selected is paused.
     *
     * Requirements:
     *
     * - The function selected must be paused.
     */
    modifier whenFuncPaused(bytes4 _func) {
        require(_isPaused[_func], "Pausable/function-is-not-paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The function selected must not be paused.
     */
    function _pause(bytes4 _func) internal virtual whenFuncNotPaused(_func) {
        _isPaused[_func] = true;
        emit Paused(_msgSender(), _func);
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The function selected must be paused.
     */
    function _unpause(bytes4 _func) internal virtual whenFuncPaused(_func) {
        _isPaused[_func] = false;
        emit Unpaused(_msgSender(), _func);
    }
}

// SPDX-License-Identifier: GPL-3.0
import "../../openzeppelin/non-upgradeable/Context.sol";

pragma solidity 0.8.14;

contract Manager {
    address internal manager;

    event TransferManager(address, address);

    constructor() {}

    modifier onlyManager() {
        _onlyManager();
        _;
    }

    function getManager() external view returns (address) {
        return manager;
    }

    function _onlyManager() internal view {
        require(manager == msg.sender, "Manager/caller-is-not-the-manager");
    }

    function transferManager(address _address) public virtual onlyManager {
        require(_address != address(0), "Manager/new-manager-is-the-zero-address");
        _transferManager(_address);
    }

    function _transferManager(address _address) internal virtual {
        address oldManager = manager;
        manager = _address;
        emit TransferManager(oldManager, _address);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

contract InterestVaultEvent {
    event SetTokenAddress(address indexed sender, address oldValue, address newValue);
    event SetForwAddress(address indexed sender, address oldValue, address newValue);
    event SetProtocolAddress(address indexed sender, address oldValue, address newValue);

    event OwnerApprove(
        address indexed sender,
        address tokenAddress,
        address forwAddress,
        uint256 amount
    );

    event SettleInterest(
        address indexed sender,
        uint256 claimableTokenInterest,
        uint256 heldTokenInterest,
        uint256 claimableForwInterest
    );

    event WithdrawTokenInterest(
        address indexed sender,
        uint256 claimable,
        uint256 bonus,
        uint256 profit
    );

    event WithdrawForwInterest(address indexed sender, uint256 claimable);

    event WithdrawActualProfit(address indexed sender, uint256 profitWithdraw);
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
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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