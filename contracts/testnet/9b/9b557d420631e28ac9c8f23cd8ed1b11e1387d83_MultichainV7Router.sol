/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

// SPDX-License-Identifier: GPL-3.0-or-later
// Sources flattened with hardhat v2.9.1 https://hardhat.org

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


// File contracts/access/MPCManageable.sol


pragma solidity ^0.8.10;

abstract contract MPCManageable {
    using Address for address;

    address public mpc;
    address public pendingMPC;

    uint256 public constant delay = 2 days;
    uint256 public delayMPC;

    modifier onlyMPC() {
        require(msg.sender == mpc, "MPC: only mpc");
        _;
    }

    event LogChangeMPC(address indexed oldMPC, address indexed newMPC, uint256 effectiveTime);
    event LogApplyMPC(address indexed oldMPC, address indexed newMPC, uint256 applyTime);

    constructor(address _mpc) {
        require(_mpc != address(0), "MPC: mpc is the zero address");
        mpc = _mpc;
        emit LogChangeMPC(address(0), mpc, block.timestamp);
    }

    function changeMPC(address _mpc) external onlyMPC {
        require(_mpc != address(0), "MPC: mpc is the zero address");
        pendingMPC = _mpc;
        delayMPC = block.timestamp + delay;
        emit LogChangeMPC(mpc, pendingMPC, delayMPC);
    }

    function applyMPC() external {
        require(
            msg.sender == pendingMPC ||
            (msg.sender == mpc && address(pendingMPC).isContract()),
            "MPC: only pending mpc"
        );
        require(delayMPC > 0 && block.timestamp >= delayMPC, "MPC: time before delayMPC");
        emit LogApplyMPC(mpc, pendingMPC, block.timestamp);
        mpc = pendingMPC;
        pendingMPC = address(0);
        delayMPC = 0;
    }
}


// File contracts/access/PausableControl.sol


pragma solidity ^0.8.10;

abstract contract PausableControl {
    mapping(bytes32 => bool) private _pausedRoles;

    bytes32 public constant PAUSE_ALL_ROLE = 0x00;

    event Paused(bytes32 role);
    event Unpaused(bytes32 role);

    modifier whenNotPaused(bytes32 role) {
        require(
            !paused(role) && !paused(PAUSE_ALL_ROLE),
            "PausableControl: paused"
        );
        _;
    }

    modifier whenPaused(bytes32 role) {
        require(
            paused(role) || paused(PAUSE_ALL_ROLE),
            "PausableControl: not paused"
        );
        _;
    }

    function paused(bytes32 role) public view virtual returns (bool) {
        return _pausedRoles[role];
    }

    function _pause(bytes32 role) internal virtual whenNotPaused(role) {
        _pausedRoles[role] = true;
        emit Paused(role);
    }

    function _unpause(bytes32 role) internal virtual whenPaused(role) {
        _pausedRoles[role] = false;
        emit Unpaused(role);
    }
}


// File contracts/access/AdminControl.sol


pragma solidity ^0.8.10;

abstract contract AdminControl {
    address public admin;
    address public pendingAdmin;

    event ChangeAdmin(address indexed _old, address indexed _new);
    event ApplyAdmin(address indexed _old, address indexed _new);

    constructor(address _admin) {
        require(_admin != address(0), "AdminControl: address(0)");
        admin = _admin;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "AdminControl: not admin");
        _;
    }

    function changeAdmin(address _admin) external onlyAdmin {
        require(_admin != address(0), "AdminControl: address(0)");
        pendingAdmin = _admin;
        emit ChangeAdmin(admin, _admin);
    }

    function applyAdmin() external {
        require(msg.sender == pendingAdmin, "AdminControl: Forbidden");
        emit ApplyAdmin(admin, pendingAdmin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }
}


// File contracts/access/PausableControlWithAdmin.sol



pragma solidity ^0.8.10;

abstract contract PausableControlWithAdmin is PausableControl, AdminControl {
    constructor(address _admin) AdminControl(_admin) {
    }

    function pause(bytes32 role) external onlyAdmin {
        _pause(role);
    }

    function unpause(bytes32 role) external onlyAdmin {
        _unpause(role);
    }
}


// File contracts/router/interfaces/IAnycallExecutor.sol

pragma solidity ^0.8.6;

/// IAnycallExecutor interface of the anycall executor
interface IAnycallExecutor {
    function execute(
        address _anycallProxy,
        address _token,
        uint256 _amount,
        bytes calldata _data
    ) external returns (bool success, bytes memory result);
}


// File contracts/router/interfaces/SwapInfo.sol

pragma solidity ^0.8.6;

struct SwapInfo {
    bytes32 swapoutID;
    address token;
    address receiver;
    uint256 amount;
    uint256 fromChainID;
}


// File contracts/router/interfaces/IRouterSecurity.sol

pragma solidity ^0.8.10;

interface IRouterSecurity {
    function registerSwapin(string calldata swapID, SwapInfo calldata swapInfo)
        external;

    function registerSwapout(
        address token,
        address from,
        string calldata to,
        uint256 amount,
        uint256 toChainID,
        string calldata anycallProxy,
        bytes calldata data
    ) external returns (bytes32 swapoutID);

    function isSwapCompleted(
        string calldata swapID,
        bytes32 swapoutID,
        uint256 fromChainID
    ) external view returns (bool);
}


// File contracts/router/interfaces/IRetrySwapinAndExec.sol

pragma solidity ^0.8.10;

interface IRetrySwapinAndExec {
    function retrySwapinAndExec(
        string calldata swapID,
        SwapInfo calldata swapInfo,
        address anycallProxy,
        bytes calldata data,
        bool dontExec
    ) external;
}


// File contracts/router/interfaces/IUnderlying.sol


pragma solidity ^0.8.10;

interface IUnderlying {
    function underlying() external view returns (address);

    function deposit(uint256 amount, address to) external returns (uint256);

    function withdraw(uint256 amount, address to) external returns (uint256);
}


// File contracts/router/interfaces/IwNATIVE.sol

pragma solidity ^0.8.10;

interface IwNATIVE {
    function deposit() external payable;

    function withdraw(uint256) external;
}


// File contracts/router/interfaces/IAnyswapERC20Auth.sol

pragma solidity ^0.8.10;

interface IAnyswapERC20Auth {
    function changeVault(address newVault) external returns (bool);
}


// File contracts/router/interfaces/IRouterMintBurn.sol

pragma solidity ^0.8.10;

interface IRouterMintBurn {
    function mint(address to, uint256 amount) external returns (bool);

    function burn(address from, uint256 amount) external returns (bool);
}


// File contracts/router/MultichainV7Router.sol


pragma solidity ^0.8.10;











contract MultichainV7Router is
    MPCManageable,
    PausableControlWithAdmin,
    ReentrancyGuard,
    IRetrySwapinAndExec
{
    using Address for address;
    using SafeERC20 for IERC20;

    bytes32 public constant Swapin_Paused_ROLE =
        keccak256("Swapin_Paused_ROLE");
    bytes32 public constant Swapout_Paused_ROLE =
        keccak256("Swapout_Paused_ROLE");
    bytes32 public constant Call_Paused_ROLE = keccak256("Call_Paused_ROLE");
    bytes32 public constant Exec_Paused_ROLE = keccak256("Exec_Paused_ROLE");

    address public immutable wNATIVE;
    address public immutable anycallExecutor;

    address public routerSecurity;

    struct ProxyInfo {
        bool supported;
        bool acceptAnyToken;
    }

    mapping(address => ProxyInfo) public anycallProxyInfo;
    mapping(bytes32 => bool) public retryRecords;

    event LogAnySwapIn(
        string swapID,
        bytes32 indexed swapoutID,
        address indexed token,
        address indexed receiver,
        uint256 amount,
        uint256 fromChainID
    );
    event LogAnySwapOut(
        bytes32 indexed swapoutID,
        address indexed token,
        address indexed from,
        string receiver,
        uint256 amount,
        uint256 toChainID
    );

    event LogAnySwapInAndExec(
        string swapID,
        bytes32 indexed swapoutID,
        address indexed token,
        address indexed receiver,
        uint256 amount,
        uint256 fromChainID,
        bool success,
        bytes result
    );
    event LogAnySwapOutAndCall(
        bytes32 indexed swapoutID,
        address indexed token,
        address indexed from,
        string receiver,
        uint256 amount,
        uint256 toChainID,
        string anycallProxy,
        bytes data
    );

    event LogRetryExecRecord(
        string swapID,
        bytes32 swapoutID,
        address token,
        address receiver,
        uint256 amount,
        uint256 fromChainID,
        address anycallProxy,
        bytes data
    );
    event LogRetrySwapInAndExec(
        string swapID,
        bytes32 swapoutID,
        address token,
        address receiver,
        uint256 amount,
        uint256 fromChainID,
        bool dontExec,
        bool success,
        bytes result
    );

    constructor(
        address _admin,
        address _mpc,
        address _wNATIVE,
        address _anycallExecutor,
        address _routerSecurity
    ) MPCManageable(_mpc) PausableControlWithAdmin(_admin) {
        require(_anycallExecutor != address(0), "zero anycall executor");
        anycallExecutor = _anycallExecutor;
        wNATIVE = _wNATIVE;
        routerSecurity = _routerSecurity;
    }

    receive() external payable {
        assert(msg.sender == wNATIVE); // only accept Native via fallback from the wNative contract
    }

    function setRouterSecurity(address _routerSecurity)
        external
        nonReentrant
        onlyMPC
    {
        routerSecurity = _routerSecurity;
    }

    function changeVault(address token, address newVault)
        external
        nonReentrant
        onlyMPC
        returns (bool)
    {
        return IAnyswapERC20Auth(token).changeVault(newVault);
    }

    function addAnycallProxies(
        address[] calldata proxies,
        bool[] calldata acceptAnyTokenFlags
    ) external nonReentrant onlyMPC {
        uint256 length = proxies.length;
        require(length == acceptAnyTokenFlags.length, "length mismatch");
        for (uint256 i = 0; i < length; i++) {
            anycallProxyInfo[proxies[i]] = ProxyInfo(
                true,
                acceptAnyTokenFlags[i]
            );
        }
    }

    function removeAnycallProxies(address[] calldata proxies)
        external
        nonReentrant
        onlyMPC
    {
        for (uint256 i = 0; i < proxies.length; i++) {
            delete anycallProxyInfo[proxies[i]];
        }
    }

    // Swaps `amount` `token` from this chain to `toChainID` chain with recipient `to`
    function anySwapOut(
        address token,
        string calldata to,
        uint256 amount,
        uint256 toChainID
    ) external whenNotPaused(Swapout_Paused_ROLE) nonReentrant {
        bytes32 swapoutID = IRouterSecurity(routerSecurity).registerSwapout(
            token,
            msg.sender,
            to,
            amount,
            toChainID,
            "",
            ""
        );
        assert(IRouterMintBurn(token).burn(msg.sender, amount));
        emit LogAnySwapOut(swapoutID, token, msg.sender, to, amount, toChainID);
    }

    // Swaps `amount` `token` from this chain to `toChainID` chain with recipient `to` and call anycall proxy with `data`
    function anySwapOutAndCall(
        address token,
        string calldata to,
        uint256 amount,
        uint256 toChainID,
        string calldata anycallProxy,
        bytes calldata data
    )
        external
        whenNotPaused(Swapout_Paused_ROLE)
        whenNotPaused(Call_Paused_ROLE)
        nonReentrant
    {
        require(data.length > 0, "empty call data");
        bytes32 swapoutID = IRouterSecurity(routerSecurity).registerSwapout(
            token,
            msg.sender,
            to,
            amount,
            toChainID,
            anycallProxy,
            data
        );
        assert(IRouterMintBurn(token).burn(msg.sender, amount));
        emit LogAnySwapOutAndCall(
            swapoutID,
            token,
            msg.sender,
            to,
            amount,
            toChainID,
            anycallProxy,
            data
        );
    }

    function _anySwapOutUnderlying(address token, uint256 amount)
        internal
        whenNotPaused(Swapout_Paused_ROLE)
        returns (uint256)
    {
        address _underlying = IUnderlying(token).underlying();
        require(_underlying != address(0), "MultichainRouter: zero underlying");
        uint256 old_balance = IERC20(_underlying).balanceOf(token);
        IERC20(_underlying).safeTransferFrom(msg.sender, token, amount);
        uint256 new_balance = IERC20(_underlying).balanceOf(token);
        require(
            new_balance >= old_balance && new_balance <= old_balance + amount
        );
        return new_balance - old_balance;
    }

    // Swaps `amount` `token` from this chain to `toChainID` chain with recipient `to` by minting with `underlying`
    function anySwapOutUnderlying(
        address token,
        string calldata to,
        uint256 amount,
        uint256 toChainID
    ) external nonReentrant {
        uint256 recvAmount = _anySwapOutUnderlying(token, amount);
        bytes32 swapoutID = IRouterSecurity(routerSecurity).registerSwapout(
            token,
            msg.sender,
            to,
            recvAmount,
            toChainID,
            "",
            ""
        );
        emit LogAnySwapOut(
            swapoutID,
            token,
            msg.sender,
            to,
            recvAmount,
            toChainID
        );
    }

    // Swaps `amount` `token` from this chain to `toChainID` chain with recipient `to` by minting with `underlying` and call anycall proxy with `data`
    function anySwapOutUnderlyingAndCall(
        address token,
        string calldata to,
        uint256 amount,
        uint256 toChainID,
        string calldata anycallProxy,
        bytes calldata data
    ) external whenNotPaused(Call_Paused_ROLE) nonReentrant {
        require(data.length > 0, "empty call data");
        uint256 recvAmount = _anySwapOutUnderlying(token, amount);
        bytes32 swapoutID = IRouterSecurity(routerSecurity).registerSwapout(
            token,
            msg.sender,
            to,
            recvAmount,
            toChainID,
            anycallProxy,
            data
        );
        emit LogAnySwapOutAndCall(
            swapoutID,
            token,
            msg.sender,
            to,
            recvAmount,
            toChainID,
            anycallProxy,
            data
        );
    }

    function _anySwapOutNative(address token)
        internal
        whenNotPaused(Swapout_Paused_ROLE)
        returns (uint256)
    {
        require(wNATIVE != address(0), "MultichainRouter: zero wNATIVE");
        require(
            IUnderlying(token).underlying() == wNATIVE,
            "MultichainRouter: underlying is not wNATIVE"
        );
        uint256 old_balance = IERC20(wNATIVE).balanceOf(token);
        IwNATIVE(wNATIVE).deposit{value: msg.value}();
        IERC20(wNATIVE).safeTransfer(token, msg.value);
        uint256 new_balance = IERC20(wNATIVE).balanceOf(token);
        require(
            new_balance >= old_balance && new_balance <= old_balance + msg.value
        );
        return new_balance - old_balance;
    }

    // Swaps `msg.value` `Native` from this chain to `toChainID` chain with recipient `to`
    function anySwapOutNative(
        address token,
        string calldata to,
        uint256 toChainID
    ) external payable nonReentrant {
        uint256 recvAmount = _anySwapOutNative(token);
        bytes32 swapoutID = IRouterSecurity(routerSecurity).registerSwapout(
            token,
            msg.sender,
            to,
            recvAmount,
            toChainID,
            "",
            ""
        );
        emit LogAnySwapOut(
            swapoutID,
            token,
            msg.sender,
            to,
            recvAmount,
            toChainID
        );
    }

    // Swaps `msg.value` `Native` from this chain to `toChainID` chain with recipient `to` and call anycall proxy with `data`
    function anySwapOutNativeAndCall(
        address token,
        string calldata to,
        uint256 toChainID,
        string calldata anycallProxy,
        bytes calldata data
    ) external payable whenNotPaused(Call_Paused_ROLE) nonReentrant {
        require(data.length > 0, "empty call data");
        uint256 recvAmount = _anySwapOutNative(token);
        bytes32 swapoutID = IRouterSecurity(routerSecurity).registerSwapout(
            token,
            msg.sender,
            to,
            recvAmount,
            toChainID,
            anycallProxy,
            data
        );
        emit LogAnySwapOutAndCall(
            swapoutID,
            token,
            msg.sender,
            to,
            recvAmount,
            toChainID,
            anycallProxy,
            data
        );
    }

    // Swaps `amount` `token` in `fromChainID` to `to` on this chainID
    function anySwapIn(string calldata swapID, SwapInfo calldata swapInfo)
        external
        whenNotPaused(Swapin_Paused_ROLE)
        nonReentrant
        onlyMPC
    {
        IRouterSecurity(routerSecurity).registerSwapin(swapID, swapInfo);
        assert(
            IRouterMintBurn(swapInfo.token).mint(
                swapInfo.receiver,
                swapInfo.amount
            )
        );
        emit LogAnySwapIn(
            swapID,
            swapInfo.swapoutID,
            swapInfo.token,
            swapInfo.receiver,
            swapInfo.amount,
            swapInfo.fromChainID
        );
    }

    // Swaps `amount` `token` in `fromChainID` to `to` on this chainID with `to` receiving `underlying`
    function anySwapInUnderlying(
        string calldata swapID,
        SwapInfo calldata swapInfo
    ) external whenNotPaused(Swapin_Paused_ROLE) nonReentrant onlyMPC {
        require(
            IUnderlying(swapInfo.token).underlying() != address(0),
            "MultichainRouter: zero underlying"
        );
        IRouterSecurity(routerSecurity).registerSwapin(swapID, swapInfo);
        assert(
            IRouterMintBurn(swapInfo.token).mint(address(this), swapInfo.amount)
        );
        IUnderlying(swapInfo.token).withdraw(
            swapInfo.amount,
            swapInfo.receiver
        );
        emit LogAnySwapIn(
            swapID,
            swapInfo.swapoutID,
            swapInfo.token,
            swapInfo.receiver,
            swapInfo.amount,
            swapInfo.fromChainID
        );
    }

    // Swaps `amount` `token` in `fromChainID` to `to` on this chainID with `to` receiving `Native`
    function anySwapInNative(string calldata swapID, SwapInfo calldata swapInfo)
        external
        whenNotPaused(Swapin_Paused_ROLE)
        nonReentrant
        onlyMPC
    {
        require(wNATIVE != address(0), "MultichainRouter: zero wNATIVE");
        require(
            IUnderlying(swapInfo.token).underlying() == wNATIVE,
            "MultichainRouter: underlying is not wNATIVE"
        );
        IRouterSecurity(routerSecurity).registerSwapin(swapID, swapInfo);
        assert(
            IRouterMintBurn(swapInfo.token).mint(address(this), swapInfo.amount)
        );
        IUnderlying(swapInfo.token).withdraw(swapInfo.amount, address(this));
        IwNATIVE(wNATIVE).withdraw(swapInfo.amount);
        Address.sendValue(payable(swapInfo.receiver), swapInfo.amount);
        emit LogAnySwapIn(
            swapID,
            swapInfo.swapoutID,
            swapInfo.token,
            swapInfo.receiver,
            swapInfo.amount,
            swapInfo.fromChainID
        );
    }

    // Swaps `amount` `token` in `fromChainID` to `to` on this chainID with `to` receiving `underlying` or `Native` if possible
    function anySwapInAuto(string calldata swapID, SwapInfo calldata swapInfo)
        external
        whenNotPaused(Swapin_Paused_ROLE)
        nonReentrant
        onlyMPC
    {
        IRouterSecurity(routerSecurity).registerSwapin(swapID, swapInfo);
        address _underlying = IUnderlying(swapInfo.token).underlying();
        if (
            _underlying != address(0) &&
            IERC20(_underlying).balanceOf(swapInfo.token) >= swapInfo.amount
        ) {
            assert(
                IRouterMintBurn(swapInfo.token).mint(
                    address(this),
                    swapInfo.amount
                )
            );
            if (_underlying == wNATIVE) {
                IUnderlying(swapInfo.token).withdraw(
                    swapInfo.amount,
                    address(this)
                );
                IwNATIVE(wNATIVE).withdraw(swapInfo.amount);
                Address.sendValue(payable(swapInfo.receiver), swapInfo.amount);
            } else {
                IUnderlying(swapInfo.token).withdraw(
                    swapInfo.amount,
                    swapInfo.receiver
                );
            }
        } else {
            assert(
                IRouterMintBurn(swapInfo.token).mint(
                    swapInfo.receiver,
                    swapInfo.amount
                )
            );
        }
        emit LogAnySwapIn(
            swapID,
            swapInfo.swapoutID,
            swapInfo.token,
            swapInfo.receiver,
            swapInfo.amount,
            swapInfo.fromChainID
        );
    }

    // Swaps `amount` `token` in `fromChainID` to `to` on this chainID
    function anySwapInAndExec(
        string calldata swapID,
        SwapInfo calldata swapInfo,
        address anycallProxy,
        bytes calldata data
    )
        external
        whenNotPaused(Swapin_Paused_ROLE)
        whenNotPaused(Exec_Paused_ROLE)
        nonReentrant
        onlyMPC
    {
        require(
            anycallProxyInfo[anycallProxy].supported,
            "unsupported ancall proxy"
        );
        IRouterSecurity(routerSecurity).registerSwapin(swapID, swapInfo);

        assert(
            IRouterMintBurn(swapInfo.token).mint(
                swapInfo.receiver,
                swapInfo.amount
            )
        );

        bool success;
        bytes memory result;
        try
            IAnycallExecutor(anycallExecutor).execute(
                anycallProxy,
                swapInfo.token,
                swapInfo.amount,
                data
            )
        returns (bool succ, bytes memory res) {
            (success, result) = (succ, res);
        } catch {}

        emit LogAnySwapInAndExec(
            swapID,
            swapInfo.swapoutID,
            swapInfo.token,
            swapInfo.receiver,
            swapInfo.amount,
            swapInfo.fromChainID,
            success,
            result
        );
    }

    // Swaps `amount` `token` in `fromChainID` to `to` on this chainID with `to` receiving `underlying`
    function anySwapInUnderlyingAndExec(
        string calldata swapID,
        SwapInfo calldata swapInfo,
        address anycallProxy,
        bytes calldata data
    )
        external
        whenNotPaused(Swapin_Paused_ROLE)
        whenNotPaused(Exec_Paused_ROLE)
        nonReentrant
        onlyMPC
    {
        require(
            anycallProxyInfo[anycallProxy].supported,
            "unsupported ancall proxy"
        );
        IRouterSecurity(routerSecurity).registerSwapin(swapID, swapInfo);

        address receiveToken;
        // transfer token to the receiver before execution
        {
            address _underlying = IUnderlying(swapInfo.token).underlying();
            require(
                _underlying != address(0),
                "MultichainRouter: zero underlying"
            );

            if (
                IERC20(_underlying).balanceOf(swapInfo.token) >= swapInfo.amount
            ) {
                receiveToken = _underlying;
                assert(
                    IRouterMintBurn(swapInfo.token).mint(
                        address(this),
                        swapInfo.amount
                    )
                );
                IUnderlying(swapInfo.token).withdraw(
                    swapInfo.amount,
                    swapInfo.receiver
                );
            } else if (anycallProxyInfo[anycallProxy].acceptAnyToken) {
                receiveToken = swapInfo.token;
                assert(
                    IRouterMintBurn(swapInfo.token).mint(
                        swapInfo.receiver,
                        swapInfo.amount
                    )
                );
            } else {
                bytes32 retryHash = keccak256(
                    abi.encode(
                        swapID,
                        swapInfo.swapoutID,
                        swapInfo.token,
                        swapInfo.receiver,
                        swapInfo.amount,
                        swapInfo.fromChainID,
                        anycallProxy,
                        data
                    )
                );
                retryRecords[retryHash] = true;
                emit LogRetryExecRecord(
                    swapID,
                    swapInfo.swapoutID,
                    swapInfo.token,
                    swapInfo.receiver,
                    swapInfo.amount,
                    swapInfo.fromChainID,
                    anycallProxy,
                    data
                );
                return;
            }
        }

        bool success;
        bytes memory result;
        try
            IAnycallExecutor(anycallExecutor).execute(
                anycallProxy,
                receiveToken,
                swapInfo.amount,
                data
            )
        returns (bool succ, bytes memory res) {
            (success, result) = (succ, res);
        } catch {}

        emit LogAnySwapInAndExec(
            swapID,
            swapInfo.swapoutID,
            swapInfo.token,
            swapInfo.receiver,
            swapInfo.amount,
            swapInfo.fromChainID,
            success,
            result
        );
    }

    // should be called only by the `receiver`
    // @param dontExec
    // if `true` transfer the underlying token to the `receiver`,
    //      and the `receiver` should complete the left job.
    // if `false` retry swapin and execute in normal way.
    function retrySwapinAndExec(
        string calldata swapID,
        SwapInfo calldata swapInfo,
        address anycallProxy,
        bytes calldata data,
        bool dontExec
    ) external nonReentrant {
        require(msg.sender == swapInfo.receiver, "forbid retry swap");
        require(
            IRouterSecurity(routerSecurity).isSwapCompleted(
                swapID,
                swapInfo.swapoutID,
                swapInfo.fromChainID
            ),
            "swap not completed"
        );
        bytes32 retryHash = keccak256(
            abi.encode(
                swapID,
                swapInfo.swapoutID,
                swapInfo.token,
                swapInfo.receiver,
                swapInfo.amount,
                swapInfo.fromChainID,
                anycallProxy,
                data
            )
        );
        require(retryRecords[retryHash], "retry record not exist");
        retryRecords[retryHash] = false;

        address _underlying = IUnderlying(swapInfo.token).underlying();
        require(_underlying != address(0), "MultichainRouter: zero underlying");
        require(
            IERC20(_underlying).balanceOf(swapInfo.token) >= swapInfo.amount,
            "MultichainRouter: retry failed"
        );
        assert(
            IRouterMintBurn(swapInfo.token).mint(address(this), swapInfo.amount)
        );
        IUnderlying(swapInfo.token).withdraw(
            swapInfo.amount,
            swapInfo.receiver
        );

        bool success;
        bytes memory result;

        if (!dontExec) {
            try
                IAnycallExecutor(anycallExecutor).execute(
                    anycallProxy,
                    _underlying,
                    swapInfo.amount,
                    data
                )
            returns (bool succ, bytes memory res) {
                (success, result) = (succ, res);
            } catch {}
        }

        emit LogRetrySwapInAndExec(
            swapID,
            swapInfo.swapoutID,
            swapInfo.token,
            swapInfo.receiver,
            swapInfo.amount,
            swapInfo.fromChainID,
            dontExec,
            success,
            result
        );
    }

    // extracts mpc fee from bridge fees
    function anySwapFeeTo(address token, uint256 amount)
        external
        nonReentrant
        onlyMPC
    {
        IRouterMintBurn(token).mint(address(this), amount);
        IUnderlying(token).withdraw(amount, msg.sender);
    }
}