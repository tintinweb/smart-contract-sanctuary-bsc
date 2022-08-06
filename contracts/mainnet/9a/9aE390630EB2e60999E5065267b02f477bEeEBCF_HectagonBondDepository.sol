// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (interfaces/IERC4626.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";
import "../token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @dev Interface of the ERC4626 "Tokenized Vault Standard", as defined in
 * https://eips.ethereum.org/EIPS/eip-4626[ERC-4626].
 *
 * _Available since v4.7._
 */
interface IERC4626 is IERC20, IERC20Metadata {
    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed caller,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    /**
     * @dev Returns the address of the underlying token used for the Vault for accounting, depositing, and withdrawing.
     *
     * - MUST be an ERC-20 token contract.
     * - MUST NOT revert.
     */
    function asset() external view returns (address assetTokenAddress);

    /**
     * @dev Returns the total amount of the underlying asset that is “managed” by Vault.
     *
     * - SHOULD include any compounding that occurs from yield.
     * - MUST be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT revert.
     */
    function totalAssets() external view returns (uint256 totalManagedAssets);

    /**
     * @dev Returns the amount of shares that the Vault would exchange for the amount of assets provided, in an ideal
     * scenario where all the conditions are met.
     *
     * - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT show any variations depending on the caller.
     * - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
     * - MUST NOT revert.
     *
     * NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
     * “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
     * from.
     */
    function convertToShares(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Returns the amount of assets that the Vault would exchange for the amount of shares provided, in an ideal
     * scenario where all the conditions are met.
     *
     * - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT show any variations depending on the caller.
     * - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
     * - MUST NOT revert.
     *
     * NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
     * “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
     * from.
     */
    function convertToAssets(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Returns the maximum amount of the underlying asset that can be deposited into the Vault for the receiver,
     * through a deposit call.
     *
     * - MUST return a limited value if receiver is subject to some deposit limit.
     * - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of assets that may be deposited.
     * - MUST NOT revert.
     */
    function maxDeposit(address receiver) external view returns (uint256 maxAssets);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their deposit at the current block, given
     * current on-chain conditions.
     *
     * - MUST return as close to and no more than the exact amount of Vault shares that would be minted in a deposit
     *   call in the same transaction. I.e. deposit should return the same or more shares as previewDeposit if called
     *   in the same transaction.
     * - MUST NOT account for deposit limits like those returned from maxDeposit and should always act as though the
     *   deposit would be accepted, regardless if the user has enough tokens approved, etc.
     * - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToShares and previewDeposit SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by depositing.
     */
    function previewDeposit(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Mints shares Vault shares to receiver by depositing exactly amount of underlying tokens.
     *
     * - MUST emit the Deposit event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   deposit execution, and are accounted for during deposit.
     * - MUST revert if all of assets cannot be deposited (due to deposit limit being reached, slippage, the user not
     *   approving enough underlying tokens to the Vault contract, etc).
     *
     * NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
     */
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    /**
     * @dev Returns the maximum amount of the Vault shares that can be minted for the receiver, through a mint call.
     * - MUST return a limited value if receiver is subject to some mint limit.
     * - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of shares that may be minted.
     * - MUST NOT revert.
     */
    function maxMint(address receiver) external view returns (uint256 maxShares);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their mint at the current block, given
     * current on-chain conditions.
     *
     * - MUST return as close to and no fewer than the exact amount of assets that would be deposited in a mint call
     *   in the same transaction. I.e. mint should return the same or fewer assets as previewMint if called in the
     *   same transaction.
     * - MUST NOT account for mint limits like those returned from maxMint and should always act as though the mint
     *   would be accepted, regardless if the user has enough tokens approved, etc.
     * - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToAssets and previewMint SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by minting.
     */
    function previewMint(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Mints exactly shares Vault shares to receiver by depositing amount of underlying tokens.
     *
     * - MUST emit the Deposit event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the mint
     *   execution, and are accounted for during mint.
     * - MUST revert if all of shares cannot be minted (due to deposit limit being reached, slippage, the user not
     *   approving enough underlying tokens to the Vault contract, etc).
     *
     * NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
     */
    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    /**
     * @dev Returns the maximum amount of the underlying asset that can be withdrawn from the owner balance in the
     * Vault, through a withdraw call.
     *
     * - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
     * - MUST NOT revert.
     */
    function maxWithdraw(address owner) external view returns (uint256 maxAssets);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their withdrawal at the current block,
     * given current on-chain conditions.
     *
     * - MUST return as close to and no fewer than the exact amount of Vault shares that would be burned in a withdraw
     *   call in the same transaction. I.e. withdraw should return the same or fewer shares as previewWithdraw if
     *   called
     *   in the same transaction.
     * - MUST NOT account for withdrawal limits like those returned from maxWithdraw and should always act as though
     *   the withdrawal would be accepted, regardless if the user has enough shares, etc.
     * - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToShares and previewWithdraw SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by depositing.
     */
    function previewWithdraw(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Burns shares from owner and sends exactly assets of underlying tokens to receiver.
     *
     * - MUST emit the Withdraw event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   withdraw execution, and are accounted for during withdraw.
     * - MUST revert if all of assets cannot be withdrawn (due to withdrawal limit being reached, slippage, the owner
     *   not having enough shares, etc).
     *
     * Note that some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
     * Those methods should be performed separately.
     */
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) external returns (uint256 shares);

    /**
     * @dev Returns the maximum amount of Vault shares that can be redeemed from the owner balance in the Vault,
     * through a redeem call.
     *
     * - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
     * - MUST return balanceOf(owner) if owner is not subject to any withdrawal limit or timelock.
     * - MUST NOT revert.
     */
    function maxRedeem(address owner) external view returns (uint256 maxShares);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their redeemption at the current block,
     * given current on-chain conditions.
     *
     * - MUST return as close to and no more than the exact amount of assets that would be withdrawn in a redeem call
     *   in the same transaction. I.e. redeem should return the same or more assets as previewRedeem if called in the
     *   same transaction.
     * - MUST NOT account for redemption limits like those returned from maxRedeem and should always act as though the
     *   redemption would be accepted, regardless if the user has enough shares, etc.
     * - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToAssets and previewRedeem SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by redeeming.
     */
    function previewRedeem(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Burns exactly shares from owner and sends assets of underlying tokens to receiver.
     *
     * - MUST emit the Withdraw event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   redeem execution, and are accounted for during redeem.
     * - MUST revert if all of shares cannot be redeemed (due to withdrawal limit being reached, slippage, the owner
     *   not having enough shares, etc).
     *
     * NOTE: some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
     * Those methods should be performed separately.
     */
    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) external returns (uint256 assets);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "./types/NoteKeeper.sol";
import "./interfaces/IBondDepository.sol";
import "./interfaces/IgHECTA.sol";

/// @title Hectagon Bond Depository

contract HectagonBondDepository is IBondDepository, NoteKeeper {
    /* ======== DEPENDENCIES ======== */

    using SafeERC20 for IERC20;

    /* ======== EVENTS ======== */

    event CreateMarket(uint256 indexed id, address indexed baseToken, address indexed quoteToken, uint256 initialPrice);
    event CloseMarket(uint256 indexed id);
    event Bond(
        uint256 indexed id,
        uint256 amount,
        uint256 price,
        uint256 noteId,
        address indexed buyer,
        address indexed referral,
        uint256 commission,
        uint256 toBuyer,
        uint256 toDaoCommunity,
        uint256 toDaoInvestment
    );
    event Tuned(uint256 indexed id, uint64 oldControlVariable, uint64 newControlVariable);

    /* ======== STATE VARIABLES ======== */

    // Storage
    Market[] public markets; // persistent market data
    Terms[] public terms; // deposit construction data
    Metadata[] public metadata; // extraneous market data
    mapping(uint256 => Adjustment) public adjustments; // control variable changes

    // Queries
    mapping(address => uint256[]) public marketsForQuote; // market IDs for quote token

    /* ======== CONSTRUCTOR ======== */

    constructor(
        IHectagonAuthority _authority,
        IERC20 _hecta,
        IgHECTA _gHecta,
        ITreasury _treasury
    ) NoteKeeper(_authority, _hecta, _gHecta, _treasury) {
        // save gas for users by bulk approving stake() transactions
        _hecta.approve(address(_gHecta), 1e45);
    }

    /* ======== DEPOSIT ======== */

    /**
     * @notice              deposit quote tokens in exchange for a bond from a specified market
     * @param _id           the ID of the market
     * @param _amount       the amount of quote token to spend
     * @param _maxPrice     the maximum price at which to buy
     * @param _user         the recipient of the payout
     * @param _referral     the front end operator address
     */
    function deposit(
        uint256 _id,
        uint256 _amount,
        uint256 _maxPrice,
        address _user,
        address _referral
    ) external override returns (UserBond memory userBond_) {
        Give memory give; // Give struct inherited fom FrontEndRewarder
        Market storage market = markets[_id];
        Terms memory term = terms[_id];
        uint48 currentTime = uint48(block.timestamp);

        // Markets end at a defined timestamp
        // |-------------------------------------| t
        require(currentTime < term.conclusion, "Depository: market concluded");

        // Debt and the control variable decay over time
        _decay(_id, currentTime);

        // Users input a maximum price, which protects them from price changes after
        // entering the mempool. max price is a slippage mitigation measure
        uint256 price = _marketPrice(_id);
        require(price <= _maxPrice, "Depository: more than max price");

        /**
         * payout for the deposit = amount / price
         *
         * where
         * payout = HECTA out
         * amount = quote tokens in
         * price = quote tokens : hecta (i.e. 42069 DAI : HECTA)
         *
         * 1e18 = HECTA decimals (9) + price decimals (9)
         */
        uint256 payout_ = ((_amount * 1e18) / price) / (10**metadata[_id].quoteDecimals);

        // markets have a max payout amount, capping size because deposits
        // do not experience slippage. max payout is recalculated upon tuning
        require(payout_ <= market.maxPayout, "Depository: max size exceeded");

        /*
         * each market is initialized with a capacity
         *
         * this is either the number of HECTA that the market can sell
         * (if capacity in quote is false),
         *
         * or the number of quote tokens that the market can buy
         * (if capacity in quote is true)
         */
        market.capacity -= market.capacityInQuote ? _amount : payout_;

        /**
         * bonds mature with a cliff at a set timestamp
         * prior to the expiry timestamp, no payout tokens are accessible to the user
         * after the expiry timestamp, the entire payout can be redeemed
         *
         * there are two types of bonds: fixed-term and fixed-expiration
         *
         * fixed-term bonds mature in a set amount of time from deposit
         * i.e. term = 1 week. when alice deposits on day 1, her bond
         * expires on day 8. when bob deposits on day 2, his bond expires day 9.
         *
         * fixed-expiration bonds mature at a set timestamp
         * i.e. expiration = day 10. when alice deposits on day 1, her term
         * is 9 days. when bob deposits on day 2, his term is 8 days.
         */
        userBond_.expiry = term.fixedTerm ? term.vesting + currentTime : term.vesting;

        // markets keep track of how many quote tokens have been
        // purchased, and how much HECTA has been sold
        market.purchased += _amount;
        market.sold += uint64(payout_);

        // incrementing total debt raises the price of the next bond
        market.totalDebt += uint64(payout_);

        /**
         * user data is stored as Notes. these are isolated array entries
         * storing the amount due, the time created, the time when payout
         * is redeemable, the time when payout was redeemed, and the ID
         * of the market deposited into
         */
        (userBond_.index, give) = addNote(_user, payout_, uint48(userBond_.expiry), uint48(_id), _referral);

        userBond_.finalPayout = payout_ + give.toBuyer;

        emit Bond(
            _id,
            _amount,
            price,
            userBond_.index,
            _user,
            _referral,
            give.toRefer,
            give.toBuyer,
            give.toDaoCommunity,
            give.toDaoInvestment
        );

        // transfer payment to treasury
        market.quoteToken.safeTransferFrom(msg.sender, address(treasury), _amount);

        // if max debt is breached, the market is closed
        // this a circuit breaker
        if (term.maxDebt < market.totalDebt) {
            market.capacity = 0;
            emit CloseMarket(_id);
        } else {
            // if market will continue, the control variable is tuned to hit targets on time
            _tune(_id, currentTime);
        }

        return userBond_;
    }

    /**
     * @notice             decay debt, and adjust control variable if there is an active change
     * @param _id          ID of market
     * @param _time        uint48 timestamp (saves gas when passed in)
     */
    function _decay(uint256 _id, uint48 _time) internal {
        // Debt decay

        /*
         * Debt is a time-decayed sum of tokens spent in a market
         * Debt is added when deposits occur and removed over time
         * |
         * |    debt falls with
         * |   / \  inactivity       / \
         * | /     \              /\/    \
         * |         \           /         \
         * |           \      /\/            \
         * |             \  /  and rises       \
         * |                with deposits
         * |
         * |------------------------------------| t
         */
        markets[_id].totalDebt -= debtDecay(_id);
        metadata[_id].lastDecay = _time;

        // Control variable decay

        // The bond control variable is continually tuned. When it is lowered (which
        // lowers the market price), the change is carried out smoothly over time.
        if (adjustments[_id].active) {
            Adjustment storage adjustment = adjustments[_id];

            ControlDecay memory controlDecay = _controlDecay(_id);
            terms[_id].controlVariable -= controlDecay.decay;

            if (controlDecay.active) {
                adjustment.change -= controlDecay.decay;
                adjustment.timeToAdjusted -= controlDecay.secondsSince;
                adjustment.lastAdjustment = _time;
            } else {
                adjustment.active = false;
            }
        }
    }

    /**
     * @notice             auto-adjust control variable to hit capacity/spend target
     * @param _id          ID of market
     * @param _time        uint48 timestamp (saves gas when passed in)
     */
    function _tune(uint256 _id, uint48 _time) internal {
        Metadata memory meta = metadata[_id];

        if (_time >= meta.lastTune + meta.tuneInterval) {
            Market memory market = markets[_id];

            // compute seconds remaining until market will conclude
            uint256 timeRemaining = terms[_id].conclusion - _time;
            uint256 price = _marketPrice(_id);

            // standardize capacity into an base token amount
            // hecta decimals (9) + price decimals (9)
            uint256 capacity = market.capacityInQuote
                ? ((market.capacity * 1e18) / price) / (10**meta.quoteDecimals)
                : market.capacity;

            /**
             * calculate the correct payout to complete on time assuming each bond
             * will be max size in the desired deposit interval for the remaining time
             *
             * i.e. market has 10 days remaining. deposit interval is 1 day. capacity
             * is 10,000 HECTA. max payout would be 1,000 HECTA (10,000 * 1 / 10).
             */
            markets[_id].maxPayout = uint64((capacity * meta.depositInterval) / timeRemaining);

            // calculate the ideal total debt to satisfy capacity in the remaining time
            uint256 targetDebt = (capacity * meta.length) / timeRemaining;

            // derive a new control variable from the target debt and current supply
            uint64 newControlVariable = uint64((price * hecta.totalSupply()) / targetDebt);

            emit Tuned(_id, terms[_id].controlVariable, newControlVariable);

            if (newControlVariable >= terms[_id].controlVariable) {
                terms[_id].controlVariable = newControlVariable;
            } else {
                // if decrease, control variable change will be carried out over the tune interval
                // this is because price will be lowered
                uint64 change = terms[_id].controlVariable - newControlVariable;
                adjustments[_id] = Adjustment(change, _time, meta.tuneInterval, true);
            }
            metadata[_id].lastTune = _time;
        }
    }

    /* ======== CREATE ======== */

    /**
     * @notice             creates a new market type
     * @dev                current price should be in 9 decimals.
     * @param _quoteToken  token used to deposit
     * @param _market      [capacity (in HECTA or quote), initial price / HECTA (9 decimals), debt buffer (3 decimals)]
     * @param _booleans    [capacity in quote, fixed term]
     * @param _terms       [vesting length (if fixed term) or vested timestamp, conclusion timestamp]
     * @param _intervals   [deposit interval (seconds), tune interval (seconds)]
     * @return id_         ID of new bond market
     */
    function create(
        IERC20 _quoteToken,
        uint256[3] memory _market,
        bool[2] memory _booleans,
        uint256[2] memory _terms,
        uint32[2] memory _intervals
    ) external override onlyPolicy returns (uint256 id_) {
        // the length of the program, in seconds
        uint256 secondsToConclusion = _terms[1] - block.timestamp;

        // the decimal count of the quote token
        uint256 decimals = IERC20Metadata(address(_quoteToken)).decimals();

        /*
         * initial target debt is equal to capacity (this is the amount of debt
         * that will decay over in the length of the program if price remains the same).
         * it is converted into base token terms if passed in in quote token terms.
         *
         * 1e18 = hecta decimals (9) + initial price decimals (9)
         */
        uint64 targetDebt = uint64(_booleans[0] ? ((_market[0] * 1e18) / _market[1]) / 10**decimals : _market[0]);

        /*
         * max payout is the amount of capacity that should be utilized in a deposit
         * interval. for example, if capacity is 1,000 HECTA, there are 10 days to conclusion,
         * and the preferred deposit interval is 1 day, max payout would be 100 HECTA.
         */
        uint64 maxPayout = uint64((targetDebt * _intervals[0]) / secondsToConclusion);

        /*
         * max debt serves as a circuit breaker for the market. let's say the quote
         * token is a stablecoin, and that stablecoin depegs. without max debt, the
         * market would continue to buy until it runs out of capacity. this is
         * configurable with a 3 decimal buffer (1000 = 1% above initial price).
         * note that its likely advisable to keep this buffer wide.
         * note that the buffer is above 100%. i.e. 10% buffer = initial debt * 1.1
         */
        uint256 maxDebt = targetDebt + ((targetDebt * _market[2]) / 1e5); // 1e5 = 100,000. 10,000 / 100,000 = 10%.

        /*
         * the control variable is set so that initial price equals the desired
         * initial price. the control variable is the ultimate determinant of price,
         * so we compute this last.
         *
         * price = control variable * debt ratio
         * debt ratio = total debt / supply
         * therefore, control variable = price / debt ratio
         */
        uint256 controlVariable = (_market[1] * hecta.totalSupply()) / targetDebt;

        // depositing into, or getting info for, the created market uses this ID
        id_ = markets.length;

        markets.push(
            Market({
                quoteToken: _quoteToken,
                capacityInQuote: _booleans[0],
                capacity: _market[0],
                totalDebt: targetDebt,
                maxPayout: maxPayout,
                purchased: 0,
                sold: 0
            })
        );

        terms.push(
            Terms({
                fixedTerm: _booleans[1],
                controlVariable: uint64(controlVariable),
                vesting: uint48(_terms[0]),
                conclusion: uint48(_terms[1]),
                maxDebt: uint64(maxDebt)
            })
        );

        metadata.push(
            Metadata({
                lastTune: uint48(block.timestamp),
                lastDecay: uint48(block.timestamp),
                length: uint48(secondsToConclusion),
                depositInterval: _intervals[0],
                tuneInterval: _intervals[1],
                quoteDecimals: uint8(decimals)
            })
        );

        marketsForQuote[address(_quoteToken)].push(id_);

        emit CreateMarket(id_, address(hecta), address(_quoteToken), _market[1]);
    }

    /**
     * @notice             disable existing market
     * @param _id          ID of market to close
     */
    function close(uint256 _id) external override onlyPolicy {
        terms[_id].conclusion = uint48(block.timestamp);
        markets[_id].capacity = 0;
        emit CloseMarket(_id);
    }

    /* ======== EXTERNAL VIEW ======== */

    /**
     * @notice             calculate current market price of quote token in base token
     * @dev                accounts for debt and control variable decay since last deposit (vs _marketPrice())
     * @param _id          ID of market
     * @return             price for market in HECTA decimals
     *
     * price is derived from the equation
     *
     * p = cv * dr
     *
     * where
     * p = price
     * cv = control variable
     * dr = debt ratio
     *
     * dr = d / s
     *
     * where
     * d = debt
     * s = supply of token at market creation
     *
     * d -= ( d * (dt / l) )
     *
     * where
     * dt = change in time
     * l = length of program
     */
    function marketPrice(uint256 _id) public view override returns (uint256) {
        return (currentControlVariable(_id) * debtRatio(_id)) / (10**metadata[_id].quoteDecimals);
    }

    /**
     * @notice             payout due for amount of quote tokens
     * @dev                accounts for debt and control variable decay so it is up to date
     * @param _amount      amount of quote tokens to spend
     * @param _id          ID of market
     * @return             amount of HECTA to be paid in HECTA decimals
     *
     * @dev 1e18 = hecta decimals (9) + market price decimals (9)
     */
    function payoutFor(uint256 _amount, uint256 _id) external view override returns (uint256) {
        Metadata memory meta = metadata[_id];
        return (_amount * 1e18) / marketPrice(_id) / 10**meta.quoteDecimals;
    }

    /**
     * @notice             calculate current ratio of debt to supply
     * @dev                uses current debt, which accounts for debt decay since last deposit (vs _debtRatio())
     * @param _id          ID of market
     * @return             debt ratio for market in quote decimals
     */
    function debtRatio(uint256 _id) public view override returns (uint256) {
        return (currentDebt(_id) * (10**metadata[_id].quoteDecimals)) / hecta.totalSupply();
    }

    /**
     * @notice             calculate debt factoring in decay
     * @dev                accounts for debt decay since last deposit
     * @param _id          ID of market
     * @return             current debt for market in HECTA decimals
     */
    function currentDebt(uint256 _id) public view override returns (uint256) {
        return markets[_id].totalDebt - debtDecay(_id);
    }

    /**
     * @notice             amount of debt to decay from total debt for market ID
     * @param _id          ID of market
     * @return             amount of debt to decay
     */
    function debtDecay(uint256 _id) public view override returns (uint64) {
        Metadata memory meta = metadata[_id];

        uint256 secondsSince = block.timestamp - meta.lastDecay;

        return uint64((markets[_id].totalDebt * secondsSince) / meta.length);
    }

    /**
     * @notice             up to date control variable
     * @dev                accounts for control variable adjustment
     * @param _id          ID of market
     * @return             control variable for market in HECTA decimals
     */
    function currentControlVariable(uint256 _id) public view returns (uint256) {
        ControlDecay memory controlDecay = _controlDecay(_id);
        return terms[_id].controlVariable - controlDecay.decay;
    }

    /**
     * @notice             is a given market accepting deposits
     * @param _id          ID of market
     */
    function isLive(uint256 _id) public view override returns (bool) {
        return (markets[_id].capacity != 0 && terms[_id].conclusion > block.timestamp);
    }

    /**
     * @notice returns an array of all active market IDs
     */
    function liveMarkets() external view override returns (uint256[] memory) {
        uint256 num;
        for (uint256 i = 0; i < markets.length; i++) {
            if (isLive(i)) num++;
        }

        uint256[] memory ids = new uint256[](num);
        uint256 nonce;
        for (uint256 i = 0; i < markets.length; i++) {
            if (isLive(i)) {
                ids[nonce] = i;
                nonce++;
            }
        }
        return ids;
    }

    /**
     * @notice             returns an array of all active market IDs for a given quote token
     * @param _token       quote token to check for
     */
    function liveMarketsFor(address _token) external view override returns (uint256[] memory) {
        uint256[] memory mkts = marketsForQuote[_token];
        uint256 num;

        for (uint256 i = 0; i < mkts.length; i++) {
            if (isLive(mkts[i])) num++;
        }

        uint256[] memory ids = new uint256[](num);
        uint256 nonce;

        for (uint256 i = 0; i < mkts.length; i++) {
            if (isLive(mkts[i])) {
                ids[nonce] = mkts[i];
                nonce++;
            }
        }
        return ids;
    }

    /* ======== INTERNAL VIEW ======== */

    /**
     * @notice                  calculate current market price of quote token in base token
     * @dev                     see marketPrice() for explanation of price computation
     * @dev                     uses info from storage because data has been updated before call (vs marketPrice())
     * @param _id               market ID
     * @return                  price for market in HECTA decimals
     */
    function _marketPrice(uint256 _id) internal view returns (uint256) {
        return (terms[_id].controlVariable * _debtRatio(_id)) / (10**metadata[_id].quoteDecimals);
    }

    /**
     * @notice                  calculate debt factoring in decay
     * @dev                     uses info from storage because data has been updated before call (vs debtRatio())
     * @param _id               market ID
     * @return                  current debt for market in quote decimals
     */
    function _debtRatio(uint256 _id) internal view returns (uint256) {
        return (markets[_id].totalDebt * (10**metadata[_id].quoteDecimals)) / hecta.totalSupply();
    }

    /**
     * @notice                  amount to decay control variable by
     * @param _id               ID of market
     * @return controlDecay
     */
    function _controlDecay(uint256 _id) internal view returns (ControlDecay memory controlDecay) {
        Adjustment memory info = adjustments[_id];
        if (!info.active) return controlDecay;

        controlDecay.secondsSince = uint48(block.timestamp) - info.lastAdjustment;

        controlDecay.active = controlDecay.secondsSince < info.timeToAdjusted;
        controlDecay.decay = controlDecay.active
            ? (info.change * controlDecay.secondsSince) / info.timeToAdjusted
            : info.change;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBondDepository {
    // Info about each type of market
    struct Market {
        uint256 capacity; // capacity remaining
        IERC20 quoteToken; // token to accept as payment
        bool capacityInQuote; // capacity limit is in payment token (true) or in HECTA (false, default)
        uint64 totalDebt; // total debt from market
        uint64 maxPayout; // max tokens in/out (determined by capacityInQuote false/true, respectively)
        uint64 sold; // base tokens out
        uint256 purchased; // quote tokens in
    }

    // Info for creating new markets
    struct Terms {
        bool fixedTerm; // fixed term or fixed expiration
        uint64 controlVariable; // scaling variable for price
        uint48 vesting; // length of time from deposit to maturity if fixed-term
        uint48 conclusion; // timestamp when market no longer offered (doubles as time when market matures if fixed-expiry)
        uint64 maxDebt; // 9 decimal debt maximum in HECTA
    }

    // Additional info about market.
    struct Metadata {
        uint48 lastTune; // last timestamp when control variable was tuned
        uint48 lastDecay; // last timestamp when market was created and debt was decayed
        uint48 length; // time from creation to conclusion. used as speed to decay debt.
        uint48 depositInterval; // target frequency of deposits
        uint48 tuneInterval; // frequency of tuning
        uint8 quoteDecimals; // decimals of quote token
    }

    // Control variable adjustment data
    struct Adjustment {
        uint64 change;
        uint48 lastAdjustment;
        uint48 timeToAdjusted;
        bool active;
    }

    // user's bond info
    struct UserBond {
        uint256 finalPayout;
        uint256 expiry;
        uint256 index;
    }

    struct ControlDecay {
        uint64 decay; // change in control variable
        uint48 secondsSince; // seconds since last change in control variable
        bool active; // whether or not change remains active
    }

    /**
     * @notice deposit market
     * @param _bid uint256
     * @param _amount uint256
     * @param _maxPrice uint256
     * @param _user address
     * @param _referral address
     * @return userBond_ UserBond
     */
    function deposit(
        uint256 _bid,
        uint256 _amount,
        uint256 _maxPrice,
        address _user,
        address _referral
    ) external returns (UserBond memory userBond_);

    function create(
        IERC20 _quoteToken, // token used to deposit
        uint256[3] memory _market, // [capacity, initial price]
        bool[2] memory _booleans, // [capacity in quote, fixed term]
        uint256[2] memory _terms, // [vesting, conclusion]
        uint32[2] memory _intervals // [deposit interval, tune interval]
    ) external returns (uint256 id_);

    function close(uint256 _id) external;

    function isLive(uint256 _bid) external view returns (bool);

    function liveMarkets() external view returns (uint256[] memory);

    function liveMarketsFor(address _quoteToken) external view returns (uint256[] memory);

    function payoutFor(uint256 _amount, uint256 _bid) external view returns (uint256);

    function marketPrice(uint256 _bid) external view returns (uint256);

    function currentDebt(uint256 _bid) external view returns (uint256);

    function debtRatio(uint256 _bid) external view returns (uint256);

    function debtDecay(uint256 _bid) external view returns (uint64);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IHectagonAuthority {
    /* ========== EVENTS ========== */

    event GovernorPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event GuardianPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event PolicyPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event VaultPushed(address indexed from, address indexed to, bool _effectiveImmediately);

    event GovernorPulled(address indexed from, address indexed to);
    event GuardianPulled(address indexed from, address indexed to);
    event PolicyPulled(address indexed from, address indexed to);
    event VaultPulled(address indexed from, address indexed to);

    /* ========== VIEW ========== */

    function governor() external view returns (address);

    function guardian() external view returns (address);

    function policy() external view returns (address);

    function vault() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface INoteKeeper {
    // Info for market note
    struct Note {
        uint256 payout; // gHecta remaining to be paid
        uint48 created; // time market was created
        uint48 matured; // timestamp when market is matured
        uint48 redeemed; // time market was redeemed
        uint48 marketID; // market ID of deposit. uint48 to avoid adding a slot.
    }

    function redeem(
        address _user,
        uint256[] memory _indexes,
        bool _unstake
    ) external returns (uint256);

    function redeemAll(address _user, bool _unstake) external returns (uint256);

    function pushNote(address to, uint256 index) external;

    function pullNote(address from, uint256 index) external returns (uint256 newIndex_);

    function indexesFor(address _user) external view returns (uint256[] memory);

    function pendingFor(address _user, uint256 _index) external view returns (uint256 payout_, bool matured_);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface ITreasury {
    function mint(address _recipient, uint256 _amount) external;

    function withdraw(address _token, uint256 _amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/interfaces/IERC4626.sol";

interface IgHECTA is IERC4626 {
    function nextEpoch() external returns (uint256);

    function index() external view returns (uint256);

    function setDistributor(address _distributor) external;

    function bountyHunter() external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../types/HectagonAccessControlled.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract FrontEndRewarder is HectagonAccessControlled {
    struct Give {
        uint256 toRefer;
        uint256 toDaoInvestment;
        uint256 toDaoCommunity;
        uint256 toBuyer;
    }

    struct ReferTerm {
        uint256 referrerPercent; // reward for referrer (3 decimals: 100 = 1%)
        uint256 buyerPercent; // reward for bond buyer (3 decimals: 100 = 1%)
    }

    struct PartnerTerm {
        uint256 amount; // partner's remaining hecta bonus, decimal 9
        uint256 percent; // partner's bonus percent per deposit, 3 decimals: 100 = 1%
    }

    /* ========= STATE VARIABLES ========== */

    mapping(address => uint256) public rewards; // rewards notes

    mapping(address => PartnerTerm) public partnerTerms; // reward term for each partner
    mapping(address => ReferTerm) public referTerms; // reward term for refer

    uint256 public referTermCap = 2_000; // % cap for referrer (3 decimals: 2,000 = 20%)
    uint256 public partnerTermCap = 10_000; // % cap for partner (3 decimals: 1,0000 = 100%)

    uint256 public daoInvestmentPercent = 10_000; // 3 decimals: 10,000 = 100%

    uint256 public daoCommunityPercent = 45_000; // 3 decimals: 45,000 = 450%

    uint256 private immutable RATE_DENOMINATOR = 10_000;

    IERC20 internal immutable hecta; // reward token

    constructor(IHectagonAuthority _authority, IERC20 _hecta) HectagonAccessControlled(_authority) {
        hecta = _hecta;
    }

    /* ========= EXTERNAL FUNCTIONS ========== */

    // pay reward to referrer
    function getReward() external {
        uint256 reward = rewards[msg.sender];

        rewards[msg.sender] = 0;
        hecta.transfer(msg.sender, reward);
    }

    /* ========= INTERNAL ========== */

    /**
     * @notice          add new market payout to user data
     * @return give     rewards data
     */
    function _giveRewards(
        uint256 _payout,
        address _referral,
        address _buyer
    ) internal returns (Give memory give) {
        // first we calculate rewards paid to the DAO and referrer
        give.toDaoInvestment += (_payout * daoInvestmentPercent) / RATE_DENOMINATOR;
        give.toDaoCommunity += (_payout * daoCommunityPercent) / RATE_DENOMINATOR;

        // check partner logic
        if (partnerTerms[_buyer].percent > 0) {
            uint256 partnerBonus = (_payout * partnerTerms[_buyer].percent) / RATE_DENOMINATOR;
            if (partnerBonus >= partnerTerms[_buyer].amount) {
                give.toBuyer = partnerTerms[_buyer].amount;
            } else {
                give.toBuyer = partnerBonus;
            }
            partnerTerms[_buyer].amount -= give.toBuyer;
        } else {
            ReferTerm memory refTerm = referTerms[_referral];

            if (refTerm.referrerPercent > 0) {
                give.toRefer = (_payout * refTerm.referrerPercent) / RATE_DENOMINATOR;
                rewards[_referral] += give.toRefer;
            }

            if (refTerm.buyerPercent > 0) {
                give.toBuyer = (_payout * refTerm.buyerPercent) / RATE_DENOMINATOR;
            }
        }

        return give;
    }

    /**
     * @notice set Cap for referrer % reward
     */
    function setReferTermCap(uint256 _cap) external onlyGovernor {
        referTermCap = _cap;
    }

    /**
     * @notice set Cap for referrer % reward
     */
    function setPartnerTermCap(uint256 _cap) external onlyGovernor {
        partnerTermCap = _cap;
    }

    function setDaoRewards(uint256 daoInvestmentPercent_, uint256 daoCommunityPercent_) external onlyGovernor {
        daoInvestmentPercent = daoInvestmentPercent_;
        daoCommunityPercent = daoCommunityPercent_;
    }

    /**
     * @notice set referrer term
     */
    function setReferTerm(
        address _referrer,
        uint256 _referrerPercent,
        uint256 _buyerPercent
    ) external onlyPolicy {
        require(_referrer != address(0), "Zero address: Referrer");
        require((_referrerPercent + _buyerPercent) <= referTermCap, "reward too high");
        referTerms[_referrer] = ReferTerm({referrerPercent: _referrerPercent, buyerPercent: _buyerPercent});
    }

    /**
     * @notice set partner term
     */
    function setPartnerTerm(
        address _partner,
        uint256 _amount,
        uint256 _percent
    ) external onlyPolicy {
        require(_partner != address(0), "Zero address: Partner");
        require(_percent <= partnerTermCap, "reward too high");
        partnerTerms[_partner] = PartnerTerm(_amount, _percent);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../interfaces/IHectagonAuthority.sol";

error UNAUTHORIZED();

/**
 *   @dev Reasoning for this contract = modifiers literaly copy code
 *   instead of pointing towards the logic to execute. Over many
 *   functions this bloats contract size unnecessarily.
 */
abstract contract HectagonAccessControlled {
    /* ========== EVENTS ========== */

    event AuthorityUpdated(IHectagonAuthority authority);

    /* ========== STATE VARIABLES ========== */

    IHectagonAuthority public authority;

    /* ========== Constructor ========== */

    constructor(IHectagonAuthority _authority) {
        authority = _authority;
        emit AuthorityUpdated(_authority);
    }

    /* ========== "MODIFIERS" ========== */

    modifier onlyGovernor() {
        _onlyGovernor();
        _;
    }

    modifier onlyGuardian() {
        _onlyGuardian();
        _;
    }

    modifier onlyPolicy() {
        _onlyPolicy();
        _;
    }

    modifier onlyVault() {
        _onlyVault();
        _;
    }

    /* ========== GOV ONLY ========== */

    function setAuthority(IHectagonAuthority _newAuthority) external {
        _onlyGovernor();
        authority = _newAuthority;
        emit AuthorityUpdated(_newAuthority);
    }

    /* ========== INTERNAL CHECKS ========== */

    function _onlyGovernor() internal view {
        if (msg.sender != authority.governor()) revert UNAUTHORIZED();
    }

    function _onlyGuardian() internal view {
        if (msg.sender != authority.guardian()) revert UNAUTHORIZED();
    }

    function _onlyPolicy() internal view {
        if (msg.sender != authority.policy()) revert UNAUTHORIZED();
    }

    function _onlyVault() internal view {
        if (msg.sender != authority.vault()) revert UNAUTHORIZED();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/interfaces/IERC4626.sol";
import "../types/FrontEndRewarder.sol";
import "../interfaces/ITreasury.sol";
import "../interfaces/INoteKeeper.sol";
import "../interfaces/IgHECTA.sol";

abstract contract NoteKeeper is INoteKeeper, FrontEndRewarder {
    mapping(address => Note[]) public notes; // user deposit data
    mapping(address => mapping(uint256 => address)) private noteTransfers; // change note ownership

    IgHECTA internal immutable gHecta;
    ITreasury internal treasury;

    constructor(
        IHectagonAuthority _authority,
        IERC20 _hecta,
        IgHECTA _ghecta,
        ITreasury _treasury
    ) FrontEndRewarder(_authority, _hecta) {
        gHecta = _ghecta;
        treasury = _treasury;
    }

    // if treasury address changes on authority, update it
    function updateTreasury() external {
        require(
            msg.sender == authority.governor() ||
                msg.sender == authority.guardian() ||
                msg.sender == authority.policy(),
            "Only authorized"
        );
        treasury = ITreasury(authority.vault());
    }

    /* ========== ADD ========== */

    /**
     * @notice              adds a new Note for a user, stores Ref & DAO rewards, and mints & stakes payout & rewards
     * @param _user         the user that owns the Note
     * @param _payout       the amount of HECTA due to the user
     * @param _expiry       the timestamp when the Note is redeemable
     * @param _marketID     the ID of the market deposited into
     * @return give         rewards data
     */
    function addNote(
        address _user,
        uint256 _payout,
        uint48 _expiry,
        uint48 _marketID,
        address _referral
    ) internal returns (uint256, Give memory) {
        // front end operators can earn rewards by referring users
        Give memory give = _giveRewards(_payout, _referral, _user); // Give struct inherited fom FrontEndRewarder
        // the index of the note is the next in the user's array
        uint256 index_ = notes[_user].length;

        uint256 finalPayout = give.toBuyer + _payout;
        uint256 daoAmount = give.toDaoCommunity + give.toDaoInvestment - give.toBuyer - give.toRefer;

        // mint buyer's final payout and referer commission
        treasury.mint(address(this), finalPayout + give.toRefer);

        // note that only the buyer's final payout gets staked (referer commission are in HECTA)
        uint256 shares = gHecta.deposit(finalPayout, address(this));

        // mint Dao Community Fund and Dao Investment Fund, store in treasury
        treasury.mint(address(treasury), daoAmount);

        // the new note is pushed to the user's array
        // This logic needs to be executed after staking
        notes[_user].push(
            Note({payout: shares, created: uint48(block.timestamp), matured: _expiry, redeemed: 0, marketID: _marketID})
        );

        return (index_, give);
    }

    /* ========== REDEEM ========== */

    /**
     * @notice             redeem notes for user
     * @param _user        the user to redeem for
     * @param _indexes     the note indexes to redeem
     * @param _unstake     option for redeem gHecta or Hecta
     * @return sum of payout sent, in gHecta or Hecta
     */
    function redeem(
        address _user,
        uint256[] memory _indexes,
        bool _unstake
    ) public override returns (uint256) {
        uint256 payout_;
        uint48 time = uint48(block.timestamp);

        for (uint256 i = 0; i < _indexes.length; i++) {
            (uint256 pay, bool matured) = pendingFor(_user, _indexes[i]);

            if (matured) {
                notes[_user][_indexes[i]].redeemed = time; // mark as redeemed
                payout_ += pay;
            }
        }

        if (_unstake) {
            return gHecta.redeem(payout_, _user, address(this)); // send payout as hecta
        } else {
            gHecta.transfer(_user, payout_); // send payout as gHecta
            return payout_;
        }
    }

    /**
     * @notice             redeem all redeemable markets for user
     * @dev                if possible, query indexesFor() off-chain and input in redeem() to save gas
     * @param _user        user to redeem all notes for
     * @param _unstake     option for redeem gHecta or Hecta
     * @return             sum of payout sent, in gHecta or Hecta
     */
    function redeemAll(address _user, bool _unstake) external returns (uint256) {
        return redeem(_user, indexesFor(_user), _unstake);
    }

    /* ========== TRANSFER ========== */

    /**
     * @notice             approve an address to transfer a note
     * @param _to          address to approve note transfer for
     * @param _index       index of note to approve transfer for
     */
    function pushNote(address _to, uint256 _index) external override {
        require(notes[msg.sender][_index].created != 0, "Depository: note not found");
        noteTransfers[msg.sender][_index] = _to;
    }

    /**
     * @notice             transfer a note that has been approved by an address
     * @param _from        the address that approved the note transfer
     * @param _index       the index of the note to transfer (in the sender's array)
     */
    function pullNote(address _from, uint256 _index) external override returns (uint256 newIndex_) {
        require(noteTransfers[_from][_index] == msg.sender, "Depository: transfer not found");
        require(notes[_from][_index].redeemed == 0, "Depository: note redeemed");

        newIndex_ = notes[msg.sender].length;
        notes[msg.sender].push(notes[_from][_index]);

        delete notes[_from][_index];
    }

    /* ========== VIEW ========== */

    // Note info

    /**
     * @notice             all pending notes for user
     * @param _user        the user to query notes for
     * @return             the pending notes for the user
     */
    function indexesFor(address _user) public view override returns (uint256[] memory) {
        Note[] memory info = notes[_user];

        uint256 length;
        for (uint256 i = 0; i < info.length; i++) {
            if (info[i].redeemed == 0 && info[i].payout != 0) length++;
        }

        uint256[] memory indexes = new uint256[](length);
        uint256 position;

        for (uint256 i = 0; i < info.length; i++) {
            if (info[i].redeemed == 0 && info[i].payout != 0) {
                indexes[position] = i;
                position++;
            }
        }

        return indexes;
    }

    /**
     * @notice             calculate amount available for claim for a single note
     * @param _user        the user that the note belongs to
     * @param _index       the index of the note in the user's array
     * @return payout_     the payout due, in gHecta
     * @return matured_    if the payout can be redeemed
     */
    function pendingFor(address _user, uint256 _index) public view override returns (uint256 payout_, bool matured_) {
        Note memory note = notes[_user][_index];

        payout_ = note.payout;
        matured_ = note.redeemed == 0 && note.matured <= block.timestamp && note.payout != 0;
    }
}