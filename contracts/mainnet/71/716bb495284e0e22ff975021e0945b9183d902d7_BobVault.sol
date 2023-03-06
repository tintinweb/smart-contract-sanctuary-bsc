// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: CC0-1.0

pragma solidity 0.8.15;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./yield/YieldConnector.sol";
import "./proxy/EIP1967Admin.sol";
import "./utils/Ownable.sol";

/**
 * @title BobVault
 * @dev This contract contains logic for buying/selling BOB tokens for multiple underlying collaterals at a fixed flat rate.
 * Locked collateral can be seamlessly invested in arbitrary yield-generating protocols (e.g. Compound or AAVE)
 */
contract BobVault is EIP1967Admin, Ownable, YieldConnector {
    using SafeERC20 for IERC20;

    address public yieldAdmin; // permissioned receiver of swap fees and generated compound yields
    address public investAdmin; // account triggering invest of excess collateral
    IERC20 public immutable bobToken;

    mapping(address => Collateral) public collateral;

    uint64 internal constant MAX_FEE = 0.01 ether; // 1%

    struct Collateral {
        uint128 balance; // accounted required collateral balance
        uint128 buffer; // buffer of tokens that should not be invested and kept as is
        uint96 dust; // small non-withdrawable yield to account for possible rounding issues
        address yield; // address of yield-generating implementation
        uint128 price; // X tokens / 1 bob
        uint64 inFee; // fee for TOKEN->BOB buys
        uint64 outFee; // fee for BOB->TOKEN sells
        uint256 maxBalance; // limit on the amount of the specific collateral
        uint256 maxInvested; // limit on the amount of the specific collateral subject to investment
    }

    struct Stat {
        uint256 total; // current balance of collateral (total == required + farmed)
        uint256 required; // min required balance of collateral
        uint256 farmed; // withdrawable collateral yield
    }

    event AddCollateral(address indexed token, uint128 price);
    event UpdateFees(address indexed token, uint64 inFee, uint64 outFee);
    event UpdateMaxBalance(address indexed token, uint256 maxBalance);
    event EnableYield(address indexed token, address indexed yield, uint128 buffer, uint96 dust, uint256 maxInvested);
    event UpdateYield(address indexed token, address indexed yield, uint128 buffer, uint96 dust, uint256 maxInvested);
    event DisableYield(address indexed token, address indexed yield);

    event Invest(address indexed token, address indexed yield, uint256 amount);
    event Withdraw(address indexed token, address indexed yield, uint256 amount);
    event Farm(address indexed token, address indexed yield, uint256 amount);
    event FarmExtra(address indexed token, address indexed yield);

    event Buy(address indexed token, address indexed user, uint256 amountIn, uint256 amountOut);
    event Sell(address indexed token, address indexed user, uint256 amountIn, uint256 amountOut);
    event Swap(address indexed inToken, address outToken, address indexed user, uint256 amountIn, uint256 amountOut);
    event Give(address indexed token, uint256 amount);

    constructor(address _bobToken) {
        require(Address.isContract(_bobToken), "BobVault: not a contract");
        bobToken = IERC20(_bobToken);
        _transferOwnership(address(0));
    }

    /**
     * @dev Tells if given token address belongs to one of the whitelisted collaterals.
     * @param _token address of the token contract.
     * @return true, if token is a supported collateral.
     */
    function isCollateral(address _token) external view returns (bool) {
        return collateral[_token].price > 0;
    }

    /**
     * @dev Tells the balance-related stats for the specific collateral.
     * @param _token address of the token contract.
     * @return res balance stats struct.
     */
    function stat(address _token) external returns (Stat memory res) {
        Collateral storage token = collateral[_token];
        require(token.price > 0, "BobVault: unsupported collateral");

        res.total = IERC20(_token).balanceOf(address(this));
        res.required = token.balance;
        if (token.yield != address(0)) {
            res.total += _delegateInvestedAmount(token.yield, _token);
            res.required += token.dust;
        }
        res.farmed = res.total - res.required;
    }

    /**
     * @dev Adds a new collateral token.
     * Any tokens with reentrant transfers, such as an ERC777 token, MUST NOT be used as collateral. Otherwise
     * it could lead to inconsistent event orderings or potentially more severe issues.
     * Callable only by the contract owner / proxy admin.
     * @param _token address of added collateral token. Token can be added only once.
     * @param _collateral added collateral settings.
     */
    function addCollateral(address _token, Collateral calldata _collateral) external onlyOwner {
        Collateral storage token = collateral[_token];
        require(token.price == 0, "BobVault: already initialized collateral");

        require(_collateral.price > 0, "BobVault: invalid price");
        require(_collateral.inFee <= MAX_FEE, "BobVault: invalid inFee");
        require(_collateral.outFee <= MAX_FEE, "BobVault: invalid outFee");

        require(_collateral.maxBalance <= type(uint128).max, "BobVault: max balance too large");

        emit UpdateFees(_token, _collateral.inFee, _collateral.outFee);
        emit UpdateMaxBalance(_token, _collateral.maxBalance);

        (token.price, token.inFee, token.outFee, token.maxBalance) =
            (_collateral.price, _collateral.inFee, _collateral.outFee, _collateral.maxBalance);

        if (_collateral.yield != address(0)) {
            _enableCollateralYield(
                _token, _collateral.yield, _collateral.buffer, _collateral.dust, _collateral.maxInvested
            );
        }

        emit AddCollateral(_token, _collateral.price);
    }

    /**
     * @dev Enables yield-earning on the particular collateral token.
     * Callable only by the contract owner / proxy admin.
     * In order to change yield provider for already yield-enabled tokens,
     * disableCollateralYield should be called first.
     * @param _token address of the collateral token.
     * @param _yield address of the yield provider contract.
     * @param _buffer amount of non-invested collateral.
     * @param _dust small amount of non-withdrawable yield.
     * @param _maxInvested max amount to be invested.
     */
    function enableCollateralYield(
        address _token,
        address _yield,
        uint128 _buffer,
        uint96 _dust,
        uint256 _maxInvested
    )
        external
        onlyOwner
    {
        Collateral storage token = collateral[_token];
        require(token.price > 0, "BobVault: unsupported collateral");
        require(token.yield == address(0), "BobVault: yield already enabled");

        _enableCollateralYield(_token, _yield, _buffer, _dust, _maxInvested);
    }

    /**
     * @dev Updates yield-earning parameters on the particular collateral token.
     * Callable only by the contract owner / proxy admin.
     * @param _token address of the collateral token.
     * @param _buffer amount of non-invested collateral.
     * @param _dust small amount of non-withdrawable yield.
     * @param _maxInvested max amount to be invested.
     */
    function updateCollateralYield(
        address _token,
        uint128 _buffer,
        uint96 _dust,
        uint256 _maxInvested
    )
        external
        onlyOwner
    {
        Collateral storage token = collateral[_token];
        require(token.price > 0, "BobVault: unsupported collateral");
        address yield = token.yield;
        require(yield != address(0), "BobVault: yield not enabled");

        (token.buffer, token.dust, token.maxInvested) = (_buffer, _dust, _maxInvested);

        _investExcess(_token, yield, _buffer, _maxInvested);

        emit UpdateYield(_token, yield, _buffer, _dust, _maxInvested);
    }

    /**
     * @dev Internal function that enables yield-earning on the particular collateral token.
     * Delegate-calls initialize and invest functions on the yield provider contract.
     * @param _token address of the collateral token.
     * @param _yield address of the yield provider contract.
     * @param _buffer amount of non-invested collateral.
     * @param _dust small amount of non-withdrawable yield.
     * @param _maxInvested max amount to be invested.
     */
    function _enableCollateralYield(
        address _token,
        address _yield,
        uint128 _buffer,
        uint96 _dust,
        uint256 _maxInvested
    )
        internal
    {
        Collateral storage token = collateral[_token];

        require(Address.isContract(_yield), "BobVault: yield not a contract");

        (token.buffer, token.dust, token.yield, token.maxInvested) = (_buffer, _dust, _yield, _maxInvested);
        _delegateInitialize(_yield, _token);

        _investExcess(_token, _yield, _buffer, _maxInvested);

        emit EnableYield(_token, _yield, _buffer, _dust, _maxInvested);
    }

    /**
     * @dev Disable yield-earning on the particular collateral token.
     * Callable only by the contract owner / proxy admin.
     * Yield can only be disabled on collaterals on which enableCollateralYield was called first.
     * Delegate-calls investedAmount, withdraw and exit functions on the yield provider contract.
     * @param _token address of the collateral token.
     */
    function disableCollateralYield(address _token) external onlyOwner {
        Collateral storage token = collateral[_token];
        require(token.price > 0, "BobVault: unsupported collateral");
        address yield = token.yield;
        require(yield != address(0), "BobVault: yield not enabled");

        (token.buffer, token.dust, token.yield) = (0, 0, address(0));

        uint256 invested = _delegateInvestedAmount(yield, _token);
        _delegateWithdraw(yield, _token, invested);
        emit Withdraw(_token, yield, invested);

        _delegateExit(yield, _token);
        emit DisableYield(_token, yield);
    }

    /**
     * @dev Updates in/out fees on the particular collateral.
     * Callable only by the contract owner / proxy admin.
     * Can only be called on already whitelisted collaterals.
     * @param _token address of the collateral token.
     * @param _inFee fee for TOKEN->BOB buys (or 1 ether to pause buys).
     * @param _outFee fee for BOB->TOKEN sells (or 1 ether to pause sells).
     */
    function setCollateralFees(address _token, uint64 _inFee, uint64 _outFee) external onlyOwner {
        Collateral storage token = collateral[_token];
        require(token.price > 0, "BobVault: unsupported collateral");

        require(_inFee <= MAX_FEE || _inFee == 1 ether, "BobVault: invalid inFee");
        require(_outFee <= MAX_FEE || _outFee == 1 ether, "BobVault: invalid outFee");

        (token.inFee, token.outFee) = (_inFee, _outFee);

        emit UpdateFees(_token, _inFee, _outFee);
    }

    /**
     * @dev Updates max balance of the particular collateral.
     * Callable only by the contract owner / proxy admin.
     * Can only be called on already whitelisted collaterals.
     * @param _token address of the collateral token.
     * @param _maxBalance new max balance of the particular collateral.
     */
    function setMaxBalance(address _token, uint256 _maxBalance) external onlyOwner {
        Collateral storage token = collateral[_token];
        require(token.price > 0, "BobVault: unsupported collateral");
        require(_maxBalance <= type(uint128).max, "BobVault: max balance too large");

        token.maxBalance = _maxBalance;

        emit UpdateMaxBalance(_token, _maxBalance);
    }

    /**
     * @dev Sets address of the yield receiver account.
     * Callable only by the contract owner / proxy admin.
     * Nominated address will be capable of withdrawing accumulated fees and generated yields by calling farm function.
     * @param _yieldAdmin new yield receiver address.
     */
    function setYieldAdmin(address _yieldAdmin) external onlyOwner {
        yieldAdmin = _yieldAdmin;
    }

    /**
     * @dev Sets address of the invest manager.
     * Callable only by the contract owner / proxy admin.
     * Nominated address will be only capable of investing excess collateral tokens by calling invest function.
     * @param _investAdmin new invest manager address.
     */
    function setInvestAdmin(address _investAdmin) external onlyOwner {
        investAdmin = _investAdmin;
    }

    /**
     * @dev Estimates amount of received tokens, when swapping some amount of inToken for outToken.
     * @param _inToken address of the sold token. Can be either the address of BOB token or one of whitelisted collaterals.
     * @param _outToken address of the bought token. Can be either the address of BOB token or one of whitelisted collaterals.
     * @param _inAmount amount of sold _inToken.
     * @return estimated amount of received _outToken.
     */
    function getAmountOut(address _inToken, address _outToken, uint256 _inAmount) public view returns (uint256) {
        require(_inToken != _outToken, "BobVault: tokens should be different");

        if (_outToken == address(bobToken)) {
            Collateral storage token = collateral[_inToken];
            require(token.price > 0, "BobVault: unsupported collateral");
            require(token.inFee <= MAX_FEE, "BobVault: collateral deposit suspended");

            uint256 fee = _inAmount * uint256(token.inFee) / 1 ether;
            uint256 sellAmount = _inAmount - fee;
            uint256 outAmount = sellAmount * 1 ether / token.price;

            require(outAmount <= bobToken.balanceOf(address(this)), "BobVault: exceeds available liquidity");
            require(token.balance + sellAmount <= token.maxBalance, "BobVault: exceeds max balance");

            return outAmount;
        } else if (_inToken == address(bobToken)) {
            Collateral storage token = collateral[_outToken];
            require(token.price > 0, "BobVault: unsupported collateral");
            require(token.outFee <= MAX_FEE, "BobVault: collateral withdrawal suspended");

            uint256 outAmount = _inAmount * token.price / 1 ether;
            // collected outFee should be available for withdrawal after the swap,
            // so collateral liquidity is checked before subtracting the fee
            require(token.balance >= outAmount, "BobVault: insufficient liquidity for collateral");
            outAmount -= outAmount * uint256(token.outFee) / 1 ether;

            return outAmount;
        } else {
            Collateral storage inToken = collateral[_inToken];
            Collateral storage outToken = collateral[_outToken];
            require(inToken.price > 0, "BobVault: unsupported input collateral");
            require(outToken.price > 0, "BobVault: unsupported output collateral");
            require(inToken.inFee <= MAX_FEE, "BobVault: collateral deposit suspended");
            require(outToken.outFee <= MAX_FEE, "BobVault: collateral withdrawal suspended");

            uint256 fee = _inAmount * uint256(inToken.inFee) / 1 ether;
            uint256 sellAmount = _inAmount - fee;
            uint256 bobAmount = sellAmount * 1 ether / inToken.price;

            uint256 outAmount = bobAmount * outToken.price / 1 ether;
            // collected outFee should be available for withdrawal after the swap,
            // so collateral liquidity is checked before subtracting the fee
            require(outToken.balance >= outAmount, "BobVault: insufficient liquidity for collateral");
            outAmount -= outAmount * uint256(outToken.outFee) / 1 ether;

            require(inToken.balance + sellAmount <= inToken.maxBalance, "BobVault: exceeds max balance");

            return outAmount;
        }
    }

    /**
     * @dev Estimates amount of tokens that should be sold, in order to get required amount of out bought tokens,
     * when swapping inToken for outToken.
     * @param _inToken address of the sold token. Can be either the address of BOB token or one of whitelisted collaterals.
     * @param _outToken address of the bought token. Can be either the address of BOB token or one of whitelisted collaterals.
     * @param _outAmount desired amount of bought _outToken.
     * @return estimated amount of _inToken that should be sold.
     */
    function getAmountIn(address _inToken, address _outToken, uint256 _outAmount) public view returns (uint256) {
        require(_inToken != _outToken, "BobVault: tokens should be different");

        if (_outToken == address(bobToken)) {
            Collateral storage token = collateral[_inToken];
            require(token.price > 0, "BobVault: unsupported collateral");
            require(token.inFee <= MAX_FEE, "BobVault: collateral deposit suspended");

            require(_outAmount <= bobToken.balanceOf(address(this)), "BobVault: exceeds available liquidity");

            uint256 sellAmount = _outAmount * token.price / 1 ether;
            uint256 inAmount = sellAmount * 1 ether / (1 ether - uint256(token.inFee));

            require(token.balance + sellAmount <= token.maxBalance, "BobVault: exceeds max balance");

            return inAmount;
        } else if (_inToken == address(bobToken)) {
            Collateral storage token = collateral[_outToken];
            require(token.price > 0, "BobVault: unsupported collateral");
            require(token.outFee <= MAX_FEE, "BobVault: collateral withdrawal suspended");

            uint256 buyAmount = _outAmount * 1 ether / (1 ether - uint256(token.outFee));
            // collected outFee should be available for withdrawal after the swap,
            // so collateral liquidity is checked before subtracting the fee
            require(token.balance >= buyAmount, "BobVault: insufficient liquidity for collateral");

            uint256 inAmount = buyAmount * 1 ether / token.price;

            return inAmount;
        } else {
            Collateral storage inToken = collateral[_inToken];
            Collateral storage outToken = collateral[_outToken];
            require(inToken.price > 0, "BobVault: unsupported input collateral");
            require(outToken.price > 0, "BobVault: unsupported output collateral");
            require(inToken.inFee <= MAX_FEE, "BobVault: collateral deposit suspended");
            require(outToken.outFee <= MAX_FEE, "BobVault: collateral withdrawal suspended");

            uint256 buyAmount = _outAmount * 1 ether / (1 ether - uint256(outToken.outFee));
            // collected outFee should be available for withdrawal after the swap,
            // so collateral liquidity is checked before subtracting the fee
            require(outToken.balance >= buyAmount, "BobVault: insufficient liquidity for collateral");

            uint256 bobAmount = buyAmount * 1 ether / outToken.price;
            uint256 sellAmount = bobAmount * inToken.price / 1 ether;
            uint256 inAmount = sellAmount * 1 ether / (1 ether - uint256(inToken.inFee));

            require(inToken.balance + sellAmount <= inToken.maxBalance, "BobVault: exceeds max balance");

            return inAmount;
        }
    }

    /**
     * @dev Buys BOB with one of the collaterals at a fixed rate.
     * Collateral token should be pre-approved to the vault contract.
     * Swap will revert, if order cannot be fully filled due to the lack of BOB tokens.
     * Swapped amount of collateral will be subject to relevant inFee.
     * @param _token address of the sold collateral token.
     * @param _amount amount of sold collateral.
     * @return amount of received _outToken, i.e. getAmountOut(_token, BOB, _amount).
     */
    function buy(address _token, uint256 _amount) external returns (uint256) {
        Collateral storage token = collateral[_token];
        require(token.price > 0, "BobVault: unsupported collateral");
        require(token.inFee <= MAX_FEE, "BobVault: collateral deposit suspended");

        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);

        uint256 fee = _amount * uint256(token.inFee) / 1 ether;
        uint256 sellAmount = _amount - fee;
        uint256 buyAmount = sellAmount * 1 ether / token.price;
        unchecked {
            require(token.balance + sellAmount <= token.maxBalance, "BobVault: exceeds max balance");
            token.balance += uint128(sellAmount);
        }

        bobToken.transfer(msg.sender, buyAmount);

        emit Buy(_token, msg.sender, _amount, buyAmount);

        return buyAmount;
    }

    /**
     * @dev Sells BOB for one of the collaterals at a fixed rate.
     * BOB token should be pre-approved to the vault contract.
     * Swap will revert, if order cannot be fully filled due to the lack of particular collateral.
     * Swapped amount of collateral will be subject to relevant outFee.
     * @param _token address of the received collateral token.
     * @param _amount amount of sold BOB tokens.
     * @return amount of received _outToken, i.e. getAmountOut(BOB, _token, _amount).
     */
    function sell(address _token, uint256 _amount) external returns (uint256) {
        Collateral storage token = collateral[_token];
        require(token.price > 0, "BobVault: unsupported collateral");
        require(token.outFee <= MAX_FEE, "BobVault: collateral withdrawal suspended");

        bobToken.transferFrom(msg.sender, address(this), _amount);

        uint256 buyAmount = _amount * token.price / 1 ether;
        // collected outFee should be available for withdrawal after the swap,
        // so collateral liquidity is checked before subtracting the fee
        require(token.balance >= buyAmount, "BobVault: insufficient liquidity for collateral");
        unchecked {
            token.balance -= uint128(buyAmount);
        }

        buyAmount -= buyAmount * uint256(token.outFee) / 1 ether;

        _transferOut(_token, msg.sender, buyAmount);

        emit Sell(_token, msg.sender, _amount, buyAmount);

        return buyAmount;
    }

    /**
     * @dev Buys one collateral with another collateral by virtually routing swap through BOB token at a fixed rate.
     * Collateral token should be pre-approved to the vault contract.
     * Identical to sequence of buy+sell calls,
     * with the exception that swap does not require presence of the BOB liquidity and has a much lower gas usage.
     * Swap will revert, if order cannot be fully filled due to the lack of particular collateral.
     * Swapped amount of collateral will be subject to relevant inFee and outFee.
     * @param _inToken address of the sold collateral token.
     * @param _outToken address of the bought collateral token.
     * @param _amount amount of sold collateral.
     * @return amount of received _outToken, i.e. getAmountOut(_inToken, _outToken, _amount).
     */
    function swap(address _inToken, address _outToken, uint256 _amount) external returns (uint256) {
        Collateral storage inToken = collateral[_inToken];
        Collateral storage outToken = collateral[_outToken];
        require(_inToken != _outToken, "BobVault: tokens should be different");
        require(inToken.price > 0, "BobVault: unsupported input collateral");
        require(outToken.price > 0, "BobVault: unsupported output collateral");
        require(inToken.inFee <= MAX_FEE, "BobVault: collateral deposit suspended");
        require(outToken.outFee <= MAX_FEE, "BobVault: collateral withdrawal suspended");

        IERC20(_inToken).safeTransferFrom(msg.sender, address(this), _amount);

        // buy virtual bob

        uint256 fee = _amount * uint256(inToken.inFee) / 1 ether;
        uint256 sellAmount = _amount - fee;
        unchecked {
            require(inToken.balance + sellAmount <= inToken.maxBalance, "BobVault: exceeds max balance");
            inToken.balance += uint128(sellAmount);
        }
        uint256 bobAmount = sellAmount * 1 ether / inToken.price;

        // sell virtual bob

        uint256 buyAmount = bobAmount * outToken.price / 1 ether;
        // collected outFee should be available for withdrawal after the swap,
        // so collateral liquidity is checked before subtracting the fee
        require(outToken.balance >= buyAmount, "BobVault: insufficient liquidity for collateral");
        unchecked {
            outToken.balance -= uint128(buyAmount);
        }

        buyAmount -= buyAmount * uint256(outToken.outFee) / 1 ether;

        _transferOut(_outToken, msg.sender, buyAmount);

        emit Swap(_inToken, _outToken, msg.sender, _amount, buyAmount);

        return buyAmount;
    }

    /**
     * @dev Invests excess tokens into the yield provider.
     * Callable only by the contract owner / proxy admin / invest admin.
     * @param _token address of collateral to invest.
     */
    function invest(address _token) external {
        require(msg.sender == investAdmin || _isOwner(), "BobVault: not authorized");

        Collateral storage token = collateral[_token];
        require(token.price > 0, "BobVault: unsupported collateral");

        _investExcess(_token, token.yield, token.buffer, token.maxInvested);
    }

    /**
     * @dev Internal function for investing excess tokens into the yield provider.
     * Delegate-calls invest function on the yield provider contract.
     * @param _token address of collateral to invest.
     */
    function _investExcess(address _token, address _yield, uint256 _buffer, uint256 _maxInvested) internal {
        uint256 balance = IERC20(_token).balanceOf(address(this));

        if (balance > _buffer) {
            uint256 value = balance - _buffer;

            uint256 invested = _delegateInvestedAmount(_yield, _token);
            if (invested < _maxInvested) {
                if (value > _maxInvested - invested) {
                    value = _maxInvested - invested;
                }
                _delegateInvest(_yield, _token, value);
                emit Invest(_token, _yield, value);
            }
        }
    }

    /**
     * @dev Collects accumulated fees and generated yield for the specific collateral.
     * Callable only by the contract owner / proxy admin / yield admin.
     * @param _token address of collateral to collect fess / interest for.
     */
    function farm(address _token) external returns (uint256) {
        require(msg.sender == yieldAdmin || _isOwner(), "BobVault: not authorized");

        Collateral storage token = collateral[_token];
        require(token.price > 0, "BobVault: unsupported collateral");

        uint256 currentBalance = IERC20(_token).balanceOf(address(this));
        uint256 requiredBalance = token.balance;

        if (token.yield != address(0)) {
            currentBalance += _delegateInvestedAmount(token.yield, _token);
            requiredBalance += token.dust;
        }

        if (requiredBalance >= currentBalance) {
            return 0;
        }

        uint256 value = currentBalance - requiredBalance;
        _transferOut(_token, msg.sender, value);
        emit Farm(_token, token.yield, value);

        return value;
    }

    /**
     * @dev Collects extra rewards from the specific yield provider (e.g. COMP tokens).
     * Callable only by the contract owner / proxy admin / yield admin.
     * @param _token address of collateral to collect rewards for.
     * @param _data arbitrary extra data required for rewards collection.
     */
    function farmExtra(address _token, bytes calldata _data) external returns (bytes memory returnData) {
        require(msg.sender == yieldAdmin || _isOwner(), "BobVault: not authorized");

        Collateral memory token = collateral[_token];
        require(token.price > 0, "BobVault: unsupported collateral");

        returnData = _delegateFarmExtra(token.yield, _token, msg.sender, _data);

        emit FarmExtra(_token, token.yield);
    }

    /**
     * @dev Top up balance of the particular collateral.
     * Can be used when migrating liquidity from other sources (e.g. from Uniswap).
     * @param _token address of collateral to top up.
     * @param _amount amount of collateral to add.
     */
    function give(address _token, uint256 _amount) external {
        Collateral storage token = collateral[_token];
        require(token.price > 0, "BobVault: unsupported collateral");

        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);

        unchecked {
            require(token.balance + _amount <= type(uint128).max, "BobVault: amount too large");
            token.balance += uint128(_amount);
        }

        emit Give(_token, _amount);
    }

    /**
     * @dev Withdraws BOB liquidity.
     * Can be used when migrating BOB liquidity into other pools. (e.g. to a different BobVault contract).
     * Will withdraw at most _value tokens, but no more than the current available balance.
     * @param _to address of BOB tokens receiver.
     * @param _value max amount of BOB tokens to withdraw.
     */
    function reclaim(address _to, uint256 _value) external onlyOwner {
        uint256 balance = bobToken.balanceOf(address(this));
        uint256 value = balance > _value ? _value : balance;
        if (value > 0) {
            bobToken.transfer(_to, value);
        }
    }

    /**
     * @dev Internal function for doing collateral payouts.
     * Delegate-calls investedAmount and withdraw functions on the yield provider contract.
     * Seamlessly withdraws the necessary amount of invested liquidity, when needed.
     * @param _token address of withdrawn collateral token.
     * @param _to address of withdrawn collateral receiver.
     * @param _value amount of collateral tokens to withdraw.
     */
    function _transferOut(address _token, address _to, uint256 _value) internal {
        Collateral storage token = collateral[_token];

        uint256 balance = IERC20(_token).balanceOf(address(this));

        if (_value > balance) {
            address yield = token.yield;
            require(yield != address(0), "BobVault: yield not enabled");

            uint256 invested = _delegateInvestedAmount(yield, _token);
            uint256 withdrawValue = token.buffer + _value - balance;
            if (invested < withdrawValue) {
                withdrawValue = invested;
            }
            _delegateWithdraw(token.yield, _token, withdrawValue);
            emit Withdraw(_token, yield, withdrawValue);
        }

        IERC20(_token).safeTransfer(_to, _value);
    }

    /**
     * @dev Tells if caller is the contract owner.
     * Gives ownership rights to the proxy admin as well.
     * @return true, if caller is the contract owner or proxy admin.
     */
    function _isOwner() internal view override returns (bool) {
        return super._isOwner() || _admin() == _msgSender();
    }
}

// SPDX-License-Identifier: CC0-1.0

pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IYieldImplementation {
    function initialize(address _token) external;

    function exit(address _token) external;

    function invest(address _token, uint256 _amount) external;

    function withdraw(address _token, uint256 _amount) external;

    function farmExtra(address _token, address _to, bytes calldata _data) external returns (bytes memory);

    function investedAmount(address _token) external returns (uint256);
}

// SPDX-License-Identifier: CC0-1.0

pragma solidity 0.8.15;

/**
 * @title EIP1967Admin
 * @dev Upgradeable proxy pattern implementation according to minimalistic EIP1967.
 */
contract EIP1967Admin {
    // EIP 1967
    // bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1)
    uint256 internal constant EIP1967_ADMIN_STORAGE = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    modifier onlyAdmin() {
        require(msg.sender == _admin(), "EIP1967Admin: not an admin");
        _;
    }

    function _admin() internal view returns (address res) {
        assembly {
            res := sload(EIP1967_ADMIN_STORAGE)
        }
    }
}

// SPDX-License-Identifier: CC0-1.0

pragma solidity 0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol" as OZOwnable;

/**
 * @title Ownable
 */
contract Ownable is OZOwnable.Ownable {
    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view override {
        require(_isOwner(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Tells if caller is the contract owner.
     * @return true, if caller is the contract owner.
     */
    function _isOwner() internal view virtual returns (bool) {
        return owner() == _msgSender();
    }
}

// SPDX-License-Identifier: CC0-1.0

pragma solidity 0.8.15;

import "@openzeppelin/contracts/utils/Address.sol";
import "../interfaces/IYieldImplementation.sol";

/**
 * @title YieldConnector
 */
contract YieldConnector {
    function _delegateInitialize(address _impl, address _token) internal {
        _delegate(_impl, abi.encodeWithSelector(IYieldImplementation.initialize.selector, _token));
    }

    function _delegateExit(address _impl, address _token) internal {
        _delegate(_impl, abi.encodeWithSelector(IYieldImplementation.exit.selector, _token));
    }

    function _delegateInvest(address _impl, address _token, uint256 _amount) internal {
        _delegate(_impl, abi.encodeWithSelector(IYieldImplementation.invest.selector, _token, _amount));
    }

    function _delegateWithdraw(address _impl, address _token, uint256 _amount) internal {
        _delegate(_impl, abi.encodeWithSelector(IYieldImplementation.withdraw.selector, _token, _amount));
    }

    function _delegateInvestedAmount(address _impl, address _token) internal returns (uint256) {
        bytes memory data =
            _delegate(_impl, abi.encodeWithSelector(IYieldImplementation.investedAmount.selector, _token));
        return abi.decode(data, (uint256));
    }

    function _delegateFarmExtra(
        address _impl,
        address _token,
        address _to,
        bytes calldata _data
    )
        internal
        returns (bytes memory)
    {
        return _delegate(_impl, abi.encodeWithSelector(IYieldImplementation.farmExtra.selector, _token, _to, _data));
    }

    function _delegate(address _impl, bytes memory _data) private returns (bytes memory) {
        (bool status, bytes memory data) = _impl.delegatecall(_data);
        require(status, "YieldConnector: delegatecall failed");
        return data;
    }
}