/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

// Sources flattened with hardhat v2.12.6 https://hardhat.org

// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]

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
	function allowance(
		address owner,
		address spender
	) external view returns (uint256);

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

// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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

		(bool success, ) = recipient.call{ value: amount }("");
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
	function functionCall(
		address target,
		bytes memory data
	) internal returns (bytes memory) {
		return
			functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
		(bool success, bytes memory returndata) = target.call{ value: value }(data);
		return
			verifyCallResultFromTarget(target, success, returndata, errorMessage);
	}

	/**
	 * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
	 * but performing a static call.
	 *
	 * _Available since v3.3._
	 */
	function functionStaticCall(
		address target,
		bytes memory data
	) internal view returns (bytes memory) {
		return
			functionStaticCall(target, data, "Address: low-level static call failed");
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
		return
			verifyCallResultFromTarget(target, success, returndata, errorMessage);
	}

	/**
	 * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
	 * but performing a delegate call.
	 *
	 * _Available since v3.4._
	 */
	function functionDelegateCall(
		address target,
		bytes memory data
	) internal returns (bytes memory) {
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
		(bool success, bytes memory returndata) = target.delegatecall(data);
		return
			verifyCallResultFromTarget(target, success, returndata, errorMessage);
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

	function _revert(
		bytes memory returndata,
		string memory errorMessage
	) private pure {
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

// File @openzeppelin/contracts/token/ERC20/utils/[email protected]

// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

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

	function safeTransfer(IERC20 token, address to, uint256 value) internal {
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
	function safeApprove(IERC20 token, address spender, uint256 value) internal {
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
			require(
				oldAllowance >= value,
				"SafeERC20: decreased allowance below zero"
			);
			uint256 newAllowance = oldAllowance - value;
			_callOptionalReturn(
				token,
				abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
			);
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

// File contracts/interfaces/ISoulBound.sol

pragma solidity ^0.8.0;

interface ISoulBound is IERC165 {
	/**
	 * @dev Emitted when `soulboundId` of a soulbound token is minted and linked to `owner`
	 */
	event Issued(uint256 indexed soulboundId, address indexed owner);

	/**
	 * @dev Emitted when `soulboundId` of a soulbound token is unlinked from `owner`
	 */
	event Revoked(uint256 indexed soulboundId, address indexed owner);

	/**
	 * @dev Emitted when `soulboundId` of a soulbound token is:
	 * unlinked with `from` and linked to `to`
	 */
	event Changed(
		uint256 indexed soulboundId,
		address indexed from,
		address indexed to
	);

	/**
	 * @dev Emitted when `soulboundId` of a soulbound token is transferred from:
	 * address(0) to `to` OR `to` to address(0)
	 */
	event Transfer(
		address indexed from,
		address indexed to,
		uint256 indexed soulboundId
	);

	/**
	 * @dev Returns the total number of SoulBound tokens has been released
	 */
	function totalSupply() external view returns (uint256);

	/**
	 * @dev Returns the owner of the `soulboundId` token.
	 * Requirements:
	 * - `soulboundId` must exist.
	 */
	function ownerOf(uint256 soulboundId) external view returns (address owner);

	/**
	 * @dev Returns the soulboundId of the `owner`.
	 * Requirements:
	 * - `owner` must own a soulbound token.
	 */
	function tokenOf(address owner) external view returns (uint256);

	/**
       	@notice Get total number of accounts that linked to `soulboundId`
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id
    */
	function numOfLinkedAccounts(
		uint256 soulboundId
	) external view returns (uint256);

	/**
       	@notice Get accounts that linked to `soulboundId`
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id
        @param	fromIndex				Starting index of query range
        @param	toIndex				    Ending index of query range
    */
	function linkedAccounts(
		uint256 soulboundId,
		uint256 fromIndex,
		uint256 toIndex
	) external view returns (address[] memory accounts);

	/**
       	@notice Checking if `soulboundId` is assigned, but revoked
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id
    */
	function isRevoked(uint256 soulboundId) external view returns (bool);
}

// File contracts/interfaces/IERC721Metadata.sol

pragma solidity ^0.8.0;

interface IERC721Metadata is ISoulBound {
	/**
	 * @dev Returns the SoulBound Token name.
	 */
	function name() external view returns (string memory);

	/**
	 * @dev Returns the SoulBound Token symbol.
	 */
	function symbol() external view returns (string memory);

	/**
	 * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
	 */
	function tokenURI(uint256 tokenId) external view returns (string memory);
}

// File contracts/interfaces/IAttribute.sol

pragma solidity ^0.8.0;

interface IAttribute {
	/**
	 * @dev Emitted when `attributedId` is registered for one `soulbound`
	 */
	event Set(address indexed soulbound, uint256 indexed attributeId);

	/**
	 * @dev Emitted when `attributedId` is removed out of one `soulbound`
	 */
	event Removed(address indexed soulbound, uint256 indexed attributeId);

	/**
       	@notice Check whether `_attributeId` exists
       	@dev  Caller can be ANY
        @param	attributeId				    Number ID of Attribute type
    */
	function isValidAttribute(uint256 attributeId) external view returns (bool);

	/**
       	@notice Get size of Attributes currently available
       	@dev  Caller can be ANY
    */
	function numOfAttributes() external view returns (uint256);

	/**
       	@notice Get a list of available Attributes
       	@dev  Caller can be ANY
        @param	fromIdx				    Starting index in a list
        @param	toIdx				        Ending index in a list
    */
	function listOfAttributes(
		uint256 fromIdx,
		uint256 toIdx
	) external view returns (uint256[] memory attributeIds);

	/**
       	@notice Retrieve Attribute's URI of `_soulboundId`
       	@dev  Caller can be ANY
        @param	soulboundId				    Soulbound Id
        @param	attributeId				    Number ID of Attribute type
    */
	function attributeURI(
		uint256 soulboundId,
		uint256 attributeId
	) external view returns (string memory);
}

// File contracts/interfaces/ISoulBoundMintable.sol

pragma solidity ^0.8.0;

interface ISoulBoundMintable {
	/**
       	@notice Assign `soulboundId` to `owner`
       	@dev  Caller must have Minter role
		    @param	owner				        Address of soulbound's owner
        @param	soulboundId				Soulbound id

        Note: One `owner` is assigned ONLY one `soulboundId` that binds to off-chain profile
    */
	function issue(address owner, uint256 soulboundId) external;

	/**
       	@notice Unlink `soulboundId` to its `owner`
       	@dev  Caller must have Minter role
        @param	soulboundId				Soulbound id

        Note: After revoke, the update is:
        - `soulboundId` -> `owner` is unlinked, but
        - `owner` -> `soulboundId` is still linked
    */
	function revoke(uint256 soulboundId) external;

	/**
       	@notice Change `soulboundId` to new `owner`
       	@dev  Caller must have Minter role
        @param	soulboundId				Soulbound id
        @param	from				        Address of a current `owner`
        @param	to				            Address of a new `owner`

        Note: Change address from `from` to `to` does not mean ownership transfer
        Instead, it indicates which account is currently set as Primary
        Using `linkedAccounts()` can query all accounts that are linked to `soulboundId`
    */
	function change(uint256 soulboundId, address from, address to) external;
}

// File contracts/interfaces/IReputation.sol

pragma solidity ^0.8.0;

interface IReputation is IERC721Metadata, ISoulBoundMintable, IAttribute {
	/**
       	@notice Add new `attributeId` as Reputation Score of `soulboundId`
       	@dev  Caller must have OPERATOR_ROLE
        @param	soulboundId				Soulbound Id
        @param	attributeId				Attribute ID of Reputation Score

        Note: 
        - This method is designed to be called by Service/Minter/Helper contract
            + In Service contract:
                Owner of `soulboundId` requests to add Category Reputation Score in his/her profile.
                However, for easy extendability and flexibility, Service contract can be set as OPERATOR_ROLE
                so that authorized clients could also call this method
            + In Minter/Helper contract:
                General Reputation Score will be added in the `soulboundId` profile (as default)
        - Validity of `attributeId` and ownership of `soulboundId` must be checked prior calling this method
    */
	function addAttributeOf(uint256 soulboundId, uint256 attributeId) external;

	/**
       	@notice Update latest General/Category Reputation Scores of `soulboundIds`
       	@dev  Caller must have OPERATOR_ROLE
        @param	attributeId				  Attribute ID of Reputation Score
        @param	soulboundIds				A list of `soulboundId`
        @param	scores				      A list of latest scores that corresponding to each `soulboundId` respectively
    */
	function fulfill(
		uint256 attributeId,
		uint256[] calldata soulboundIds,
		uint256[] calldata scores
	) external;

	/**
       	@notice Get size of Reputation Score list that `soulboundId` has
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id
    */
	function sizeOf(uint256 soulboundId) external view returns (uint256);

	/**
       	@notice Get Reputation Score list that `soulboundId` has
       	@dev  Caller can be ANY
        @param	soulboundId				  Soulbound Id
        @param	fromIdx				      Starting index in a list
        @param	toIdx				        Ending index in a list
    */
	function listOf(
		uint256 soulboundId,
		uint256 fromIdx,
		uint256 toIdx
	) external view returns (uint256[] memory attributeIds);

	/**
       	@notice Get latest Reputation Scores of `soulboundId`
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id
        @param	attributeId				Attribute ID of Reputation Score
    */
	function latestAnswer(
		uint256 soulboundId,
		uint256 attributeId
	) external view returns (uint256 _score, uint256 _lastUpdate);

	/**
       	@notice Check whether a list of `soulboundIds` exists
       	@dev  Caller can be ANY
        @param	soulboundIds				A list of `soulboundId`
    */
	function exist(uint256[] calldata soulboundIds) external view returns (bool);

	/**
       	@notice Check whether `soulboundId` contains `attributeId` as the Reputation Score
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id
        @param	attributeId				Attribute ID of Reputation Score
    */
	function existAttributeOf(
		uint256 soulboundId,
		uint256 attributeId
	) external view returns (bool);
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

// File contracts/interfaces/IManagement.sol

pragma solidity ^0.8.0;

interface IManagement {
	/**
       	@notice Get address of Treasury
       	@dev  Caller can be ANY
    */
	function treasury() external view returns (address);

	/**
       	@notice Verify `role` of `account`
       	@dev  Caller can be ANY
        @param	role				    Bytes32 hash role
        @param	account				Address of `account` that needs to check `role`
    */
	function hasRole(bytes32 role, address account) external view returns (bool);

	/**
       	@notice Get status of `paused`
       	@dev  Caller can be ANY
    */
	function paused() external view returns (bool);

	/**
       	@notice Checking whether `account` is blacklisted
       	@dev  Caller can be ANY
        @param	account				Address of `account` that needs to check
    */
	function blacklist(address account) external view returns (bool);

	/**
       	@notice Checking whether `account` is whitelisted
       	@dev  Caller can be ANY
        @param	account				Address of `account` that needs to check
    */
	function whitelist(address account) external view returns (bool);
}

// File contracts/Service.sol

pragma solidity ^0.8.0;

contract Service is Context {
	using SafeERC20 for IERC20;
	using Address for address;

	struct UpdateFee {
		uint256 fee;
		address paymentToken;
	}

	bytes32 internal constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
	uint256 private constant GENERAL_TYPE = 1;

	//  Address of Reputation contract
	IReputation private immutable _REPUTATION;

	//  Address of Management contract
	IManagement public _management;

	//  Time delay between two update requests
	uint256 public delayTime;

	//  Accepted Payment Token
	address public paymentToken;

	//  Amount Fee to pay per request
	uint256 public fee;

	modifier hasRole(bytes32 role) {
		require(management().hasRole(role, _msgSender()), "Unauthorized");
		_;
	}

	modifier onlyWhitelist() {
		require(management().whitelist(_msgSender()), "Only whitelist");
		_;
	}

	/**
	 * @dev Emitted when `requestor` send a request to update latest reputation scores of `soulboundIds`
	 */
	event Request(
		address indexed requestor,
		uint256 indexed attributeId,
		uint256[] soulboundIds
	);

	constructor(
		IManagement management_,
		IReputation reputation_,
		address paymentToken_,
		uint256 fee_,
		uint256 delayTime_
	) {
		_REPUTATION = reputation_;
		_management = management_;
		paymentToken = paymentToken_;
		fee = fee_;
		delayTime = delayTime_;
	}

	/**
       	@notice Update Address of Management contract
       	@dev  Caller must have MANAGER_ROLE
		    @param	management_				Address of new Management contract
    */
	function setManagement(
		address management_
	) external virtual hasRole(MANAGER_ROLE) {
		require(management_.isContract(), "Must be a contract");
		_management = IManagement(management_);
	}

	/**
       	@notice Set new `_updateFee`
       	@dev  Caller must have MANAGER_ROLE
        @param	paymentToken_		    Address of payment token (0x00 for native coin) 
		    @param	fee_		            New value of `fee` that `msg.sender` must pay for each update request                
    */
	function setFee(
		address paymentToken_,
		uint256 fee_
	) external hasRole(MANAGER_ROLE) {
		paymentToken = paymentToken_;
		fee = fee_;
	}

	/**
       	@notice Set new `_delayTime`
       	@dev  Caller must have MANAGER_ROLE
		    @param	delayTime_		    New value of delay time between two update requests 
    */
	function setDelayTime(uint256 delayTime_) external hasRole(MANAGER_ROLE) {
		delayTime = delayTime_;
	}

	/**
       	@notice Request to update latest General Reputation Scores of `soulboundIds`
       	@dev  Caller can be ANY
        @param	soulboundIds				A list of `soulboundId`
    */
	function generalRequest(
		uint256[] calldata soulboundIds
	) external onlyWhitelist {
		require(
			reputation().exist(soulboundIds),
			"Contain non-existed soulboundId"
		);

		emit Request(_msgSender(), GENERAL_TYPE, soulboundIds);
	}

	/**
       	@notice Request to update latest Category Reputation Score of `soulboundId`
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id to be requested
        @param	attributeId				Attribute ID of Reputation Score
    */
	function categoryRequest(
		uint256 soulboundId,
		uint256 attributeId
	) external payable {
		//  Only owner of `soulboundId` can request to update Category Score
		//  And `attributeId` must be valid
		address caller = _msgSender();
		IReputation reputation_ = reputation();
		require(reputation_.ownerOf(soulboundId) == caller, "Soulbound not owned");
		require(
			reputation_.isValidAttribute(attributeId) && attributeId != GENERAL_TYPE,
			"Invalid attributeId"
		);

		//  Get Fee info that `msg.sender` must pay
		//  If `paymentToken = 0x00` -> `msg.value` must be equal to `_fee`
		address token = paymentToken; //  save gas
		uint256 paymentFee = fee; //  save gas
		if (token == address(0))
			require(msg.value == paymentFee, "Invalid payment");

		//  make a payment
		_makePayment(token, caller, paymentFee);

		//  For the first time, add `attributeId` of Category Reputation Score to `soulboundId`
		//  and let the request go through
		//  Others, must check `lastUpdate` to verify time constraint `_delayTime`
		if (!reputation_.existAttributeOf(soulboundId, attributeId))
			reputation_.addAttributeOf(soulboundId, attributeId);
		else {
			(, uint256 lastUpdate) = reputation_.latestAnswer(
				soulboundId,
				attributeId
			);
			require(block.timestamp - lastUpdate >= delayTime, "Request too close");
		}

		uint256[] memory soulboundIds = _array1(soulboundId);
		emit Request(caller, attributeId, soulboundIds);
	}

	/**
       	@notice Get address of Reputation contract
       	@dev  Caller can be ANY
    */
	function reputation() public view returns (IReputation) {
		return _REPUTATION;
	}

	/**
       	@notice Get address of Management contract
       	@dev  Caller can be ANY
    */
	function management() public view returns (IManagement) {
		return _management;
	}

	/**
       	@notice Query URL link to get Reputation Score metadata (General and Category) of `soulboundId`
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id
        @param	attributeId				Attribute ID of Reputation Score
    */
	function uri(
		uint256 soulboundId,
		uint256 attributeId
	) external view returns (string memory) {
		return reputation().attributeURI(soulboundId, attributeId);
	}

	/**
       	@notice Get latest Reputation Scores of `soulboundId`
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id
        @param	attributeId				Attribute ID of Reputation Score 
            - `attributeId = 1`: General Reputation Score
            - Others: Category Reputation Score
    */
	function latestAnswer(
		uint256 soulboundId,
		uint256 attributeId
	) public view returns (uint256 _score, uint256 lastUpdate) {
		return reputation().latestAnswer(soulboundId, attributeId);
	}

	function _makePayment(address token, address from, uint256 amount) private {
		address treasury = management().treasury();
		if (amount != 0) {
			if (token == address(0)) Address.sendValue(payable(treasury), amount);
			else IERC20(token).safeTransferFrom(from, treasury, amount);
		}
	}

	function _array1(
		uint256 soulboundId
	) private pure returns (uint256[] memory array) {
		array = new uint256[](1);
		array[0] = soulboundId;
	}
}