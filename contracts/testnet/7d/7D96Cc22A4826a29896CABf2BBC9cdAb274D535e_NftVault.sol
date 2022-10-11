/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

// Sources flattened with hardhat v2.11.2 https://hardhat.org

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


// File contracts/libs/UniversalERC20.sol

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

// File: contracts/UniversalERC20.sol
/**
 * @notice Library for wrapping ERC20 token and ETH
 * @dev It uses msg.sender directly so only use in normal contract, not in GSN-like contract
 */
library UniversalERC20 {
    using SafeERC20 for IERC20;

    IERC20 internal constant ZERO_ADDRESS =
        IERC20(0x0000000000000000000000000000000000000000);
    IERC20 internal constant ETH_ADDRESS =
        IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    function universalTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        if (amount == 0) {
            return;
        }

        if (isETH(token)) {
            (bool sent, ) = payable(address(uint160(to))).call{value: amount}(
                ""
            );
            require(sent, "Send ETH failed");
        } else {
            token.safeTransfer(to, amount);
        }
    }

    function universalTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        if (amount == 0) {
            return;
        }

        if (isETH(token)) {
            require(
                from == msg.sender && msg.value >= amount,
                "Wrong useage of ETH.universalTransferFrom()"
            );
            if (to != address(this)) {
                (bool sent, ) = payable(address(uint160(to))).call{
                    value: amount
                }("");
                require(sent, "Send ETH failed");
            }
            if (msg.value > amount) {
                // refund redundant amount
                (bool sent, ) = payable(msg.sender).call{
                    value: msg.value - amount
                }("");
                require(sent, "Send-back ETH failed");
            }
        } else {
            token.safeTransferFrom(from, to, amount);
        }
    }

    function universalTransferFromSenderToThis(
        IERC20 token,
        uint256 amount
    ) internal {
        if (amount == 0) {
            return;
        }

        if (isETH(token)) {
            if (msg.value > amount) {
                // Return remainder if exist
                (bool sent, ) = payable(msg.sender).call{
                    value: msg.value - amount
                }("");
                require(sent, "Send-back ETH failed");
            }
        } else {
            token.safeTransferFrom(msg.sender, address(this), amount);
        }
    }

    function universalApprove(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        if (!isETH(token)) {
            if (amount > 0 && token.allowance(address(this), to) > 0) {
                token.safeApprove(to, 0);
            }
            token.safeApprove(to, amount);
        }
    }

    function universalBalanceOf(IERC20 token, address who)
        internal
        view
        returns (uint256)
    {
        if (isETH(token)) {
            return who.balance;
        } else {
            return token.balanceOf(who);
        }
    }

    function universalDecimals(IERC20 token)
        internal
        view
        returns (uint256)
    {
        if (isETH(token)) {
            return 18;
        }

        (bool success, bytes memory data) = address(token).staticcall{
            gas: 10000
        }(abi.encodeWithSignature("decimals()"));
        if (!success || data.length == 0) {
            (success, data) = address(token).staticcall{gas: 10000}(
                abi.encodeWithSignature("DECIMALS()")
            );
        }

        return (success && data.length > 0) ? abi.decode(data, (uint256)) : 18;
    }

    function isETH(IERC20 token) internal pure returns (bool) {
        return (address(token) == address(ZERO_ADDRESS) ||
            address(token) == address(ETH_ADDRESS));
    }
}


// File contracts/interfaces/INftVault.sol

pragma solidity ^0.8.0;

interface INftVault {

    /**
     * @notice check all token balances of key NFT
     * @param _nftAddress key NFT contract address
     * @param _nftTokenId key NFT token ID
     * @return tokens token list that of key NFT
     * @return balances balance list of key NFT
     */
    function balanceOf(
        address _nftAddress,
        uint256 _nftTokenId
    ) external returns (
        address[] memory tokens,
        uint256[] memory balances
    );

    /**
     * @notice check specified token balance of key NFT
     * @param _nftAddress key NFT contract address
     * @param _nftTokenId key NFT token ID
     * @return balance token balance of key NFT
     */
    function balanceOf(
        address _nftAddress, 
        uint256 _nftTokenId,
        address _token
    ) external returns (uint256 balance);

    /**
     * @notice deposit to vault
     * allow from Slash Extension Contract only
     * Supported NFT is ERC721 only
     * @param _nftAddress key NFT contract address
     * @param _nftTokenId key NFT contract token ID
     * @param _token ERC20 token contract address to deposit
     * @param _amount deposit amount
     */
    function deposit(
        address _nftAddress, 
        uint256 _nftTokenId, 
        address _token,
        uint256 _amount
    ) external;

    /**
     * @notice withdraw ERC20 token from NftVault contract
     * msg.sender should own key NFT
     * recipient is msg.sender
     * @param _nftAddress key NFT contract address
     * @param _nftTokenId key NFT token ID
     * @param _token withdraw token contract address
     * @param _amount withdraw amount
     */
    function withdraw(
        address _nftAddress,
        uint256 _nftTokenId,
        address _token,
        uint256 _amount
    ) external;

    /**
     * @notice withdraw ERC20 token from NftVault contract
     * msg.sender should own key NFT
     * @param _nftAddress key NFT contract address
     * @param _nftTokenId key NFT token ID
     * @param _token withdraw token contract address
     * @param _amount withdraw amount
     * @param _recipient recipient
     */
    function withdraw(
        address _nftAddress,
        uint256 _nftTokenId,
        address _token,
        uint256 _amount,
        address _recipient
    ) external;

    /**
     * @notice payment using SlashProtocol
     * @param nftAddress_ paying NFT Address
     * @param nftTokenId_ paying NFT Token ID
     * @param slashContract_ merchant contract to pay
     * @param payingToken_ paying Token Address
     * @param amountIn_ payment amount by paying token
     * @param requiredAmountOut_ payment amount by receive token
     * @param path_ swap path / paying token to receive token
     * @param feePath_ swap path / paying token to native token
     * @param paymentId_ payment id, this param will pass to merchant (if merchant received by contract)
     * @param optional_: optional data, this param will pass to merchant (if merchant received by contract)
     * @param reserved_: reserved parameter
     * @return txNumber Transaction number
     */
    function payment(
        address nftAddress_,
        uint256 nftTokenId_,
        address slashContract_,
        address payingToken_,
        uint256 amountIn_,
        uint256 requiredAmountOut_,
        address[] memory path_,
        address[] memory feePath_,
        string memory paymentId_,
        string memory optional_,
        bytes memory reserved_ /** reserved */
    ) external payable returns (
        bytes16 txNumber
    );
}


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


// File @openzeppelin/contracts/utils/math/[email protected]


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


// File @openzeppelin/contracts/utils/introspection/[email protected]


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File @openzeppelin/contracts/token/ERC721/[email protected]


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}


// File contracts/NftVault.sol


pragma solidity ^0.8.0;






interface IMerchant {
    function submitTransaction(
        address payingToken_,
        uint256 amountIn_,
        uint256 requiredAmountOut_,
        address[] memory path_,
        address[] memory feePath_,
        string memory paymentId_,
        string memory optional_,
        bytes memory reserved_ /** reserved */
    ) external payable returns (
        bytes16 txNumber
    );
}

contract NftVault is Ownable, INftVault {
    using SafeMath for uint256;
    using UniversalERC20 for IERC20;

    bool canWithdraw = false;

    // ERC20 token list in this contract
    address[] private tokenList;
    // total balance for each tokens
    mapping(address => uint256) private _totalBalances;

    // ERC20 token balance for each key NFT
    // mapping(
    //   NftContractAddress => mapping(
    //     NftTokenId => mapping(
    //       ERC20 TokenContractAddress => balance
    //     )
    //   )
    // )
    mapping(address => mapping(uint256 => mapping(address => uint256))) private _balances;

    // white list to deposit
    // allow from SlashExtension contract only
    mapping(address => bool) private _depositWhiteList;

    // withdraw fee percentage. denominator 10000
    uint private withdrawFee = 200;

    // fee receive wallet address
    address private marketingWallet;

    // events
    event Deposit(
        address _nftAddress,
        uint256 _nftTokenId,
        address _token,
        uint256 _amount
    );
    event Withdraw(
        address _nftAddress,
        uint256 _nftTokenId,
        address _token,
        uint256 _amount,
        address indexed recipient
    );
    event Payment(
        address indexed _payer,
        address _slashContract,
        address _payingToken,
        uint256 _amountIn,
        uint256 _requiredAmountOut,
        string _paymentId
    );
    event RecoverWrongToken(
        address _token,
        uint256 _amount
    );

    /**
     * @notice check all token balances of key NFT
     * @param _nftAddress key NFT contract address
     * @param _nftTokenId key NFT token ID
     * @return tokens token list that of key NFT
     * @return balances balance list of key NFT
     */
    function balanceOf(
        address _nftAddress,
        uint256 _nftTokenId
    ) public view override returns (
        address[] memory tokens,
        uint256[] memory balances
    ) {
        tokens = new address[](tokenList.length);
        balances = new uint256[](tokenList.length);

        for (uint i=0; i<tokenList.length; i++) {
            tokens[i] = tokenList[i];
            balances[i] = _balances[_nftAddress][_nftTokenId][tokens[i]];
        }

    }

    /**
     * @notice check specified token balance of key NFT
     * @param _nftAddress key NFT contract address
     * @param _nftTokenId key NFT token ID
     * @return balance token balance of key NFT
     */
    function balanceOf(
        address _nftAddress, 
        uint256 _nftTokenId,
        address _token
    ) public view override returns (uint256 balance) {
        balance = _balances[_nftAddress][_nftTokenId][_token];
    }

    /**
     * @notice deposit to vault
     * allow from Slash Extension Contract only
     * Supported NFT is ERC721 only
     * @param _nftAddress key NFT contract address
     * @param _nftTokenId key NFT contract token ID
     * @param _token ERC20 token contract address to deposit
     * @param _amount deposit amount
     */
    function deposit(
        address _nftAddress, 
        uint256 _nftTokenId, 
        address _token,
        uint256 _amount
    ) external override {
        IERC721 nft = IERC721(_nftAddress);
        require(nft.supportsInterface(0x80ac58cd), "it's not ERC721");
        require(_depositWhiteList[msg.sender], "cannot deposit");

        uint256 balanceBefore = IERC20(_token).balanceOf(address(this));

        IERC20(_token).universalTransferFrom(
            msg.sender,
            address(this),
            _amount
        );

        uint256 deposited = IERC20(_token).balanceOf(address(this)).sub(balanceBefore);

        _balances[_nftAddress][_nftTokenId][_token]
             = _balances[_nftAddress][_nftTokenId][_token].add(deposited);
        
        _addToken(_token);
        _totalBalances[_token] = _totalBalances[_token].add(deposited);

        emit Deposit(_nftAddress, _nftTokenId, _token, deposited);
    }

    /**
     * @notice add token address in to tokenList
     * @param _token token address
     */
    function _addToken(address _token) internal {
        bool found = false;
        for (uint i=0; i<tokenList.length; i++) {
            if (tokenList[i] == _token) {
                found = true;
                break;
            }
        }
        if (found == false) {
            tokenList.push(_token);
        }
    }


    /**
     * @notice withdraw ERC20 token from NftVault contract
     * msg.sender should own key NFT
     * recipient is msg.sender
     * @param _nftAddress key NFT contract address
     * @param _nftTokenId key NFT token ID
     * @param _token withdraw token contract address
     * @param _amount withdraw amount
     */
    function withdraw(
        address _nftAddress,
        uint256 _nftTokenId,
        address _token,
        uint256 _amount
    ) external override {
        _withdraw(_nftAddress, _nftTokenId, _token, _amount, msg.sender);
    }

    /**
     * @notice withdraw ERC20 token from NftVault contract
     * msg.sender should own key NFT
     * @param _nftAddress key NFT contract address
     * @param _nftTokenId key NFT token ID
     * @param _token withdraw token contract address
     * @param _amount withdraw amount
     * @param _recipient recipient
     */
    function withdraw(
        address _nftAddress,
        uint256 _nftTokenId,
        address _token,
        uint256 _amount,
        address _recipient
    ) external override {
        _withdraw(_nftAddress, _nftTokenId, _token, _amount, _recipient);
    }

    function _withdraw(
        address _nftAddress,
        uint256 _nftTokenId,
        address _token,
        uint256 _amount,
        address _recipient
    ) internal {
        require(canWithdraw, "cannot withdraw");
        require(
            _balances[_nftAddress][_nftTokenId][_token] >= _amount,
            "insufficient balance"
        );
        require(
            _isOwned(_nftAddress, _nftTokenId),
            "you are not own this NFT"
        );

        uint256 fee = 0;
        if (withdrawFee > 0) {
            fee = _amount.mul(withdrawFee).div(10000);
        }

        IERC20(_token).universalTransfer(_recipient, _amount.sub(fee));
        if (marketingWallet != address(0)) {
            IERC20(_token).universalTransfer(marketingWallet, fee);
        }

        _balances[_nftAddress][_nftTokenId][_token] = _balances[_nftAddress][_nftTokenId][_token].sub(_amount);
        _totalBalances[_token] = _totalBalances[_token].sub(_amount);

        emit Withdraw(_nftAddress, _nftTokenId, _token, _amount, _recipient);
    }

    /**
     * @notice payment using SlashProtocol
     * flow:
     * 1. transfer payingToken from vault to payer
     * 2. call submitTransaction on Slash
     * @param nftAddress_ paying NFT Address
     * @param nftTokenId_ paying NFT Token ID
     * @param slashContract_ merchant contract to pay
     * @param payingToken_ paying Token Address
     * @param amountIn_ payment amount by paying token
     * @param requiredAmountOut_ payment amount by receive token
     * @param path_ swap path / paying token to receive token
     * @param feePath_ swap path / paying token to native token
     * @param paymentId_ payment id, this param will pass to merchant (if merchant received by contract)
     * @param optional_: optional data, this param will pass to merchant (if merchant received by contract)
     * @param reserved_: reserved parameter
     * @return txNumber Transaction number
     */
    function payment(
        address nftAddress_,
        uint256 nftTokenId_,
        address slashContract_,
        address payingToken_,
        uint256 amountIn_,
        uint256 requiredAmountOut_,
        address[] memory path_,
        address[] memory feePath_,
        string memory paymentId_,
        string memory optional_,
        bytes memory reserved_ /** reserved */
    ) external payable override returns (
        bytes16 txNumber
    ) {
        require(_isOwned(nftAddress_, nftTokenId_), "you are not NFT owner");
        require(
            amountIn_ >= balanceOf(nftAddress_, nftTokenId_, payingToken_).add(
                IERC20(payingToken_).universalBalanceOf(msg.sender)
            ),
            "insufficient balance"
        );

        IERC20(payingToken_).universalTransfer(msg.sender, amountIn_);
        IMerchant merchantContract = IMerchant(slashContract_);
        txNumber = merchantContract.submitTransaction(
            payingToken_, 
            amountIn_, 
            requiredAmountOut_, 
            path_, 
            feePath_, 
            paymentId_, 
            optional_, 
            reserved_
        );

        emit Payment(
            msg.sender, 
            slashContract_, 
            payingToken_, 
            amountIn_, 
            requiredAmountOut_, 
            paymentId_
        );
    }

    /**
     * @notice check sender owned key NFT or not
     * @param _nftAddress key NFT contract address
     * @param _nftTokenId key NFT token ID
     * @return owned sender owned key NFT: true
     */
    function _isOwned(
        address _nftAddress,
        uint256 _nftTokenId
    ) internal view returns (bool owned) {
        IERC721 nft = IERC721(_nftAddress);
        require(nft.supportsInterface(0x80ac58cd), "it's not ERC721");
        owned = nft.ownerOf(_nftTokenId) == msg.sender;
    }

    /**
     * @notice recover wrong token
     * owner can withdraw token nobady own
     * @param _token withdraw token contract address 
     */
    function recoverWrongToken(address _token) external onlyOwner {
        require(_token != address(0), "invalid address");

        uint256 balance = IERC20(_token).universalBalanceOf(address(this));
        require(balance > _totalBalances[_token], "cannot withdraw this token");
        uint256 withdrawable = balance.sub(_totalBalances[_token]);

        IERC20(_token).universalTransfer(msg.sender, withdrawable);

        emit RecoverWrongToken(_token, withdrawable);

    }

    /**
     * @notice manage deposit white list
     * @param _address from address (contract / wallet)
     * @param _permit true: can deposit / false: cannot deposit
     */
    function updateDepositWhiteList(address _address, bool _permit) external onlyOwner {
        require(_address != address(0), "invalid address");
        require(_permit != _depositWhiteList[_address], "not changed");
        _depositWhiteList[_address] = _permit;
    }

    /**
     * @notice update marketing wallet to receive withdraw fee
     * @param _wallet fee receive address
     */
    function updateMarketingWallet(address _wallet) external onlyOwner {
        require(_wallet != address(0), "invalid address");
        marketingWallet = _wallet;
    }

    /**
     * @notice update withdraw fee percentage
     * @param _fee withdraw fee percentage (denominator 10000)
     * up to 1000 (10%)
     */
    function updateWithdrawFee(uint _fee) external onlyOwner {
        require(_fee <= 1000, "up to 10%");
        withdrawFee = _fee;
    }
}