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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
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

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

interface IEssenceMiddleware {
    /**
     * @notice Sets essence related data for middleware.
     *
     * @param profileId The profile id that owns this middleware.
     * @param essenceId The essence id that owns this middleware.
     * @param data Extra data to set.
     */
    function setEssenceMwData(
        uint256 profileId,
        uint256 essenceId,
        bytes calldata data
    ) external returns (bytes memory);

    /**
     * @notice Process that runs before the essenceNFT mint happens.
     *
     * @param profileId The profile Id.
     * @param essenceId The essence Id.
     * @param collector The collector address.
     * @param essenceNFT The essence nft address.
     * @param data Extra data to process.
     */
    function preProcess(
        uint256 profileId,
        uint256 essenceId,
        address collector,
        address essenceNFT,
        bytes calldata data
    ) external;

    /**
     * @notice Process that runs after the essenceNFT mint happens.
     *
     * @param profileId The profile Id.
     * @param essenceId The essence Id.
     * @param collector The collector address.
     * @param essenceNFT The essence nft address.
     * @param data Extra data to process.
     */
    function postProcess(
        uint256 profileId,
        uint256 essenceId,
        address collector,
        address essenceNFT,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

import { IProfileNFTEvents } from "./IProfileNFTEvents.sol";

import { DataTypes } from "../libraries/DataTypes.sol";

interface IProfileNFT is IProfileNFTEvents {
    /**
     * @notice Initializes the Profile NFT.
     *
     * @param _owner Owner of the Profile NFT.
     * @param name Name to set for the Profile NFT.
     * @param symbol Symbol to set for the Profile NFT.
     */
    function initialize(
        address _owner,
        string calldata name,
        string calldata symbol
    ) external;

    /*
     * @notice Creates a profile and mints it to the recipient address.
     *
     * @param params contains all params.
     * @param data contains extra data.
     *
     * @dev The current function validates the caller address and the handle before minting
     * and the following conditions must be met:
     * - The caller address must be the engine address.
     * - The recipient address must be a valid Ethereum address.
     * - The handle must contain only a-z, A-Z, 0-9.
     * - The handle must not be already used.
     * - The handle must not be longer than 27 bytes.
     * - The handle must not be empty.
     */
    function createProfile(
        DataTypes.CreateProfileParams calldata params,
        bytes calldata preData,
        bytes calldata postData
    ) external payable returns (uint256);

    /**
     * @notice The subscription functionality.
     *
     * @param params The params for subscription.
     * @param preDatas The subscription data for preprocess.
     * @param postDatas The subscription data for postprocess.
     * @return uint256[] The subscription nft ids.
     * @dev the function requires the stated to be not paused.
     */
    function subscribe(
        DataTypes.SubscribeParams calldata params,
        bytes[] calldata preDatas,
        bytes[] calldata postDatas
    ) external returns (uint256[] memory);

    /**
     * @notice Subscribe to an address(es) with a signature.
     *
     * @param sender The sender address.
     * @param params The params for subscription.
     * @param preDatas The subscription data for preprocess.
     * @param postDatas The subscription data for postprocess.
     * @param sig The EIP712 signature.
     * @dev the function requires the stated to be not paused.
     * @return uint256[] The subscription nft ids.
     */
    function subscribeWithSig(
        DataTypes.SubscribeParams calldata params,
        bytes[] calldata preDatas,
        bytes[] calldata postDatas,
        address sender,
        DataTypes.EIP712Signature calldata sig
    ) external returns (uint256[] memory);

    /**
     * @notice Collect a profile's essence. Anyone can collect to another wallet
     *
     * @param params The params for collect.
     * @param preData The collect data for preprocess.
     * @param postData The collect data for postprocess.
     * @return uint256 The collected essence nft id.
     */
    function collect(
        DataTypes.CollectParams calldata params,
        bytes calldata preData,
        bytes calldata postData
    ) external returns (uint256);

    /**
     * @notice Collect a profile's essence with signature.
     *
     * @param sender The sender address.
     * @param params The params for collect.
     * @param preData The collect data for preprocess.
     * @param postData The collect data for postprocess.
     * @param sig The EIP712 signature.
     * @dev Only owner's signature works.
     * @return uint256 The collected essence nft id.
     */
    function collectWithSig(
        DataTypes.CollectParams calldata params,
        bytes calldata preData,
        bytes calldata postData,
        address sender,
        DataTypes.EIP712Signature calldata sig
    ) external returns (uint256);

    /**
     * @notice Register an essence.
     *
     * @param params The params for registration.
     * @param initData The registration initial data.
     * @return uint256 The new essence count.
     */
    function registerEssence(
        DataTypes.RegisterEssenceParams calldata params,
        bytes calldata initData
    ) external returns (uint256);

    /**
     * @notice Register an essence with signature.
     *
     * @param params The params for registration.
     * @param initData The registration initial data.
     * @param sig The EIP712 signature.
     * @dev Only owner's signature works.
     * @return uint256 The new essence count.
     */
    function registerEssenceWithSig(
        DataTypes.RegisterEssenceParams calldata params,
        bytes calldata initData,
        DataTypes.EIP712Signature calldata sig
    ) external returns (uint256);

    /**
     * @notice Changes the pause state of the profile nft.
     *
     * @param toPause The pause state.
     */
    function pause(bool toPause) external;

    /**
     * @notice Set new namespace owner.
     *
     * @param owner The new owner.
     */
    function setNamespaceOwner(address owner) external;

    /**
     * @notice Sets the Profile NFT Descriptor.
     *
     * @param descriptor The new descriptor address to set.
     */
    function setNFTDescriptor(address descriptor) external;

    /**
     * @notice Sets the NFT metadata as IPFS hash.
     *
     * @param profileId The profile ID.
     * @param metadata The new metadata to set.
     */
    function setMetadata(uint256 profileId, string calldata metadata) external;

    /**
     * @notice Sets the profile metadata with a signture.
     *
     * @param profileId The profile ID.
     * @param metadata The new metadata to be set.
     * @param sig The EIP712 signature.
     * @dev Only owner's signature works.
     */
    function setMetadataWithSig(
        uint256 profileId,
        string calldata metadata,
        DataTypes.EIP712Signature calldata sig
    ) external;

    /**
     * @notice Sets subscribe middleware for a profile.
     *
     * @param profileId The profile ID.
     * @param tokenURI The new token URI.
     * @param mw The new middleware to be set.
     * @param data The data for middleware.
     */
    function setSubscribeData(
        uint256 profileId,
        string calldata tokenURI,
        address mw,
        bytes calldata data
    ) external;

    /**
     * @notice Sets subscribe middleware for a profile with signature.
     *
     * @param profileId The profile ID.
     * @param tokenURI The new token URI.
     * @param mw The new middleware to be set.
     * @param data The data for middleware.
     * @param sig The EIP712 signature.
     * @dev Only owner's signature works.
     */
    function setSubscribeDataWithSig(
        uint256 profileId,
        string calldata tokenURI,
        address mw,
        bytes calldata data,
        DataTypes.EIP712Signature calldata sig
    ) external;

    /**
     * @notice Sets subscribe middleware for a profile.
     *
     * @param profileId The profile ID.
     * @param essenceId The profile ID.
     * @param tokenURI The new token URI.
     * @param mw The new middleware to be set.
     * @param data The data for middleware.
     */
    function setEssenceData(
        uint256 profileId,
        uint256 essenceId,
        string calldata tokenURI,
        address mw,
        bytes calldata data
    ) external;

    /**
     * @notice Sets subscribe middleware for a profile with signature.
     *
     * @param profileId The profile ID.
     * @param essenceId The profile ID.
     * @param tokenURI The new token URI.
     * @param mw The new middleware to be set.
     * @param data The data for middleware.
     * @param sig The EIP712 signature.
     * @dev Only owner's signature works.
     */
    function setEssenceDataWithSig(
        uint256 profileId,
        uint256 essenceId,
        string calldata tokenURI,
        address mw,
        bytes calldata data,
        DataTypes.EIP712Signature calldata sig
    ) external;

    /**
     * @notice Sets the primary profile for the user.
     *
     * @param profileId The profile ID that is set to be primary.
     */
    function setPrimaryProfile(uint256 profileId) external;

    /**
     * @notice Sets the primary profile for the user with signature.
     *
     * @param profileId The profile ID that is set to be primary.
     * @param sig The EIP712 signature.
     * @dev Only owner's signature works.
     */
    function setPrimaryProfileWithSig(
        uint256 profileId,
        DataTypes.EIP712Signature calldata sig
    ) external;

    /**
     * @notice Sets the NFT avatar as IPFS hash.
     *
     * @param profileId The profile ID.
     * @param avatar The new avatar to set.
     */
    function setAvatar(uint256 profileId, string calldata avatar) external;

    /**
     * @notice Sets the NFT avatar as IPFS hash with signature.
     *
     * @param profileId The profile ID.
     * @param avatar The new avatar to set.
     * @param sig The EIP712 signature.
     * @dev Only owner's signature works.
     */
    function setAvatarWithSig(
        uint256 profileId,
        string calldata avatar,
        DataTypes.EIP712Signature calldata sig
    ) external;

    /**
     * @notice Sets the operator approval.
     *
     * @param profileId The profile ID.
     * @param operator The operator address.
     * @param approved The approval status.
     */
    function setOperatorApproval(
        uint256 profileId,
        address operator,
        bool approved
    ) external;

    /**
     * @notice Gets the profile metadata.
     *
     * @param profileId The profile ID.
     * @return string The metadata of the profile.
     */
    function getMetadata(uint256 profileId)
        external
        view
        returns (string memory);

    /**
     * @notice Gets the profile NFT descriptor.
     *
     * @return address The descriptor address.
     */
    function getNFTDescriptor() external view returns (address);

    /**
     * @notice Gets the profile avatar.
     *
     * @param profileId The profile ID.
     * @return string The avatar of the profile.
     */
    function getAvatar(uint256 profileId) external view returns (string memory);

    /**
     * @notice Gets the operator approval status.
     *
     * @param profileId The profile ID.
     * @param operator The operator address.
     * @return bool The approval status.
     */
    function getOperatorApproval(uint256 profileId, address operator)
        external
        view
        returns (bool);

    /**
     * @notice Gets the profile handle by ID.
     *
     * @param profileId The profile ID.
     * @return string the profile handle.
     */
    function getHandleByProfileId(uint256 profileId)
        external
        view
        returns (string memory);

    /**
     * @notice Gets the profile ID by handle.
     *
     * @param handle The profile handle.
     * @return uint256 the profile ID.
     */
    function getProfileIdByHandle(string calldata handle)
        external
        view
        returns (uint256);

    /**
     * @notice Gets a profile subscribe middleware address.
     *
     * @param profileId The profile id.
     * @return address The middleware address.
     */
    function getSubscribeMw(uint256 profileId) external view returns (address);

    /**
     * @notice Gets the primary profile of the user.
     *
     * @param user The wallet address of the user.
     * @return profileId The primary profile of the user.
     */
    function getPrimaryProfile(address user)
        external
        view
        returns (uint256 profileId);

    /**
     * @notice Gets the Subscribe NFT token URI.
     *
     * @param profileId The profile ID.
     * @return string The Subscribe NFT token URI.
     */
    function getSubscribeNFTTokenURI(uint256 profileId)
        external
        view
        returns (string memory);

    /**
     * @notice Gets the Subscribe NFT address.
     *
     * @param profileId The profile ID.
     * @return address The Subscribe NFT address.
     */
    function getSubscribeNFT(uint256 profileId) external view returns (address);

    /**
     * @notice Gets the Essence NFT token URI.
     *
     * @param profileId The profile ID.
     * @param essenceId The Essence ID.
     * @return string The Essence NFT token URI.
     */
    function getEssenceNFTTokenURI(uint256 profileId, uint256 essenceId)
        external
        view
        returns (string memory);

    /**
     * @notice Gets the Essence NFT address.
     *
     * @param profileId The profile ID.
     * @param essenceId The Essence ID.
     * @return address The Essence NFT address.
     */
    function getEssenceNFT(uint256 profileId, uint256 essenceId)
        external
        view
        returns (address);

    /**
     * @notice Gets a profile essence middleware address.
     *
     * @param profileId The profile id.
     * @param essenceId The Essence ID.
     * @return address The middleware address.
     */
    function getEssenceMw(uint256 profileId, uint256 essenceId)
        external
        view
        returns (address);

    /**
     * @notice Gets the profile namespace owner.
     *
     * @return address The owner of this profile namespace.
     */
    function getNamespaceOwner() external view returns (address);
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

import { DataTypes } from "../libraries/DataTypes.sol";

interface IProfileNFTEvents {
    /**
     * @dev Emitted when the ProfileNFT is initialized.
     *
     * @param owner Namespace owner.
     */
    event Initialize(address indexed owner, string name, string symbol);

    /**
     * @notice Emitted when a new Profile NFT Descriptor has been set.
     *
     * @param newDescriptor The newly set descriptor address.
     */
    event SetNFTDescriptor(address indexed newDescriptor);

    /**
     * @notice Emitted when a new namespace owner has been set.
     *
     * @param preOwner The previous owner address.
     * @param newOwner The newly set owner address.
     */
    event SetNamespaceOwner(address indexed preOwner, address indexed newOwner);

    /**
     * @notice Emitted when a new metadata has been set to a profile.
     *
     * @param profileId The profile id.
     * @param newMetadata The newly set metadata.
     */
    event SetMetadata(uint256 indexed profileId, string newMetadata);

    /**
     * @notice Emitted when a new avatar has been set to a profile.
     *
     * @param profileId The profile id.
     * @param newAvatar The newly set avatar.
     */
    event SetAvatar(uint256 indexed profileId, string newAvatar);

    /**
     * @notice Emitted when a primary profile has been set.
     *
     * @param profileId The profile id.
     */
    event SetPrimaryProfile(address indexed user, uint256 indexed profileId);

    /**
     * @notice Emitted when the operator approval has been set.
     *
     * @param profileId The profile id.
     * @param operator The operator address.
     * @param prevApproved The previously set bool value for operator approval.
     * @param approved The newly set bool value for operator approval.
     */
    event SetOperatorApproval(
        uint256 indexed profileId,
        address indexed operator,
        bool prevApproved,
        bool approved
    );

    /**
     * @notice Emitted when a subscription middleware has been set to a profile.
     *
     * @param profileId The profile id.
     * @param tokenURI The new token URI.
     * @param mw The new middleware.
     * @param prepareReturnData The data used to prepare middleware.
     */
    event SetSubscribeData(
        uint256 indexed profileId,
        string tokenURI,
        address mw,
        bytes prepareReturnData
    );

    /**
     * @notice Emitted when a essence middleware has been set to a profile.
     *
     * @param profileId The profile id.
     * @param essenceId The essence id.
     * @param tokenURI The new token URI.
     * @param mw The new middleware.
     * @param prepareReturnData The data used to prepare middleware.
     */
    event SetEssenceData(
        uint256 indexed profileId,
        uint256 indexed essenceId,
        string tokenURI,
        address mw,
        bytes prepareReturnData
    );

    /**
     * @notice Emitted when a new profile been created.
     *
     * @param to The receiver address.
     * @param profileId The newly generated profile id.
     * @param handle The newly set handle.
     * @param avatar The newly set avatar.
     * @param metadata The newly set metadata.
     */
    event CreateProfile(
        address indexed to,
        uint256 indexed profileId,
        string handle,
        string avatar,
        string metadata
    );

    /**
     * @notice Emitted when a new essence been created.
     *
     * @param profileId The profile id.
     * @param essenceId The essence id.
     * @param name The essence name.
     * @param symbol The essence symbol.
     * @param essenceTokenURI the essence tokenURI.
     * @param essenceMw The essence middleware.
     * @param prepareReturnData The data returned from prepare.
     */
    event RegisterEssence(
        uint256 indexed profileId,
        uint256 indexed essenceId,
        string name,
        string symbol,
        string essenceTokenURI,
        address essenceMw,
        bytes prepareReturnData
    );

    /**
     * @notice Emitted when a subscription has been created.
     *
     * @param sender The sender address.
     * @param profileIds The profile ids subscribed to.
     * @param preDatas The subscription data for preprocess.
     * @param postDatas The subscription data for postprocess.
     */
    event Subscribe(
        address indexed sender,
        uint256[] profileIds,
        bytes[] preDatas,
        bytes[] postDatas
    );

    /**
     * @notice Emitted when a new subscribe nft has been deployed.
     *
     * @param profileId The profile id.
     * @param subscribeNFT The newly deployed subscribe nft address.
     */
    event DeploySubscribeNFT(
        uint256 indexed profileId,
        address indexed subscribeNFT
    );

    /**
     * @notice Emitted when a new essence nft has been deployed.
     *
     * @param profileId The profile id.
     * @param essenceId The essence id.
     * @param essenceNFT The newly deployed subscribe nft address.
     */
    event DeployEssenceNFT(
        uint256 indexed profileId,
        uint256 indexed essenceId,
        address indexed essenceNFT
    );

    /**
     * @notice Emitted when an essence has been collected.
     *
     * @param collector The collector address.
     * @param profileId The profile id.
     * @param essenceId The essence id.
     * @param tokenId The token id of the newly minted essent NFT.
     * @param preData The collect data for preprocess.
     * @param postData The collect data for postprocess.
     */
    event CollectEssence(
        address indexed collector,
        uint256 indexed profileId,
        uint256 indexed essenceId,
        uint256 tokenId,
        bytes preData,
        bytes postData
    );
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

import { ITreasuryEvents } from "../interfaces/ITreasuryEvents.sol";

interface ITreasury is ITreasuryEvents {
    /**
     * @notice Gets the treasury address.
     *
     * @return address The treasury address.
     */
    function getTreasuryAddress() external view returns (address);

    /**
     * @notice Gets the treasury fee. The percentage is calculated as: treasuryFee/_MAX_BPS.
     *
     * @return address The treasury fee.
     */
    function getTreasuryFee() external view returns (uint256);

    /**
     * @notice Checks if the currency is allowed.
     *
     * @return bool The status of allowance for the currency.
     */
    function isCurrencyAllowed(address currency) external view returns (bool);
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

import { DataTypes } from "../libraries/DataTypes.sol";

interface ITreasuryEvents {
    /**
     * @notice Emitted when a currency has been allowed.
     *
     * @param currency The ERC20 token contract address.
     * @param preAllowed The previously allow state.
     * @param newAllowed The newly set allow state.
     */
    event AllowCurrency(
        address indexed currency,
        bool indexed preAllowed,
        bool indexed newAllowed
    );

    /**
     * @notice Emitted when a new treasuryAddress has been set.
     *
     * @param preTreasuryAddress The previous treasuryAddress.
     * @param treasuryAddress The new treasuryAddress.
     */
    event SetTreasuryAddress(
        address indexed preTreasuryAddress,
        address indexed treasuryAddress
    );

    /**
     * @notice Emitted when a new treasuryFee has been set.
     *
     * @param preTreasuryFee The previous treasuryFee.
     * @param treasuryFee The new treasuryFee.
     */
    event SetTreasuryFee(
        uint16 indexed preTreasuryFee,
        uint16 indexed treasuryFee
    );
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

library Constants {
    // Access Control for CyberEngine
    uint8 internal constant _ENGINE_GOV_ROLE = 1;
    bytes4 internal constant _AUTHORIZE_UPGRADE =
        bytes4(keccak256(bytes("_authorizeUpgrade(address)")));

    // EIP712 TypeHash
    bytes32 internal constant _PERMIT_TYPEHASH =
        keccak256(
            "permit(address spender,uint256 tokenId,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _CREATE_PROFILE_TYPEHASH =
        keccak256(
            "createProfile(address to,string handle,string avatar,string metadata,address operator,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _CREATE_PROFILE_ORACLE_TYPEHASH =
        keccak256(
            "createProfileOracle(address to,string handle,string avatar,string metadata,address operator,uint256 nonce,uint256 deadline,uint80 roundId)"
        );
    bytes32 internal constant _SUBSCRIBE_TYPEHASH =
        keccak256(
            "subscribeWithSig(uint256[] profileIds,bytes[] preDatas,bytes[] postDatas,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _COLLECT_TYPEHASH =
        keccak256(
            "collectWithSig(address collector,uint256 profileId,uint256 essenceId,bytes data,bytes postDatas,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _REGISTER_ESSENCE_TYPEHASH =
        keccak256(
            "registerEssenceWithSig(uint256 profileId,string name,string symbol,string essenceTokenURI,address essenceMw,bool transferable,bytes initData,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _SET_METADATA_TYPEHASH =
        keccak256(
            "setMetadataWithSig(uint256 profileId,string metadata,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _SET_OPERATOR_APPROVAL_TYPEHASH =
        keccak256(
            "setOperatorApprovalWithSig(uint256 profileId,address operator,bool approved,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _SET_SUBSCRIBE_DATA_TYPEHASH =
        keccak256(
            "setSubscribeDataWithSig(uint256 profileId,string tokenURI,address mw,bytes data,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _SET_ESSENCE_DATA_TYPEHASH =
        keccak256(
            "setEssenceDataWithSig(uint256 profileId,uint256 essenceId,string tokenURI,address mw,bytes data,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _SET_AVATAR_TYPEHASH =
        keccak256(
            "setAvatarWithSig(uint256 profileId,string avatar,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _SET_PRIMARY_PROFILE_TYPEHASH =
        keccak256(
            "setPrimaryProfileWithSig(uint256 profileId,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _CLAIM_BOX_TYPEHASH =
        keccak256("claimBox(address to,uint256 nonce,uint256 deadline)");
    bytes32 internal constant _CLAIM_GRAND_TYPEHASH =
        keccak256("claimGrand(address to,uint256 nonce,uint256 deadline)");
    bytes32 internal constant _CLAIM_TYPEHASH =
        keccak256(
            "claim(string profileId,address to,address currency,uint256 amount,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _CLAIM721_TYPEHASH =
        keccak256(
            "claim(string profileId,address to,address currency,uint256 tokenId,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _CLAIM1155_TYPEHASH =
        keccak256(
            "claim(string profileId,address to,address currency,uint256 tokenId,uint256 amount,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _CLAIM_PROFILE_TYPEHASH =
        keccak256(
            "claimProfile(address to,string handle,string avatar,string metadata,address operator,uint256 nonce,uint256 deadline)"
        );

    // Parameters
    uint8 internal constant _MAX_HANDLE_LENGTH = 20;
    uint8 internal constant _MAX_NAME_LENGTH = 20;
    uint8 internal constant _MAX_SYMBOL_LENGTH = 20;
    uint16 internal constant _MAX_URI_LENGTH = 2000;
    uint16 internal constant _MAX_BPS = 10000;

    // Access Control for UpgradeableBeacon
    bytes4 internal constant _BEACON_UPGRADE_TO =
        bytes4(keccak256(bytes("upgradeTo(address)")));

    // Subscribe NFT
    string internal constant _SUBSCRIBE_NFT_NAME_SUFFIX = "_subscriber";
    string internal constant _SUBSCRIBE_NFT_SYMBOL_SUFFIX = "_SUB";
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

library DataTypes {
    struct EIP712Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 deadline;
    }

    struct CreateProfileParams {
        address to;
        string handle;
        string avatar;
        string metadata;
        address operator;
    }

    struct CreateProfilePostProcessData {
        uint256 tokenID;
        bytes32 handleHash;
        address profileMw;
    }

    struct CreateNamespaceParams {
        string name;
        string symbol;
        address owner;
        ComputedAddresses addrs;
    }

    struct RegisterEssenceParams {
        uint256 profileId;
        string name;
        string symbol;
        string essenceTokenURI;
        address essenceMw;
        bool transferable;
        bool deployAtRegister;
    }

    struct SubscribeParams {
        uint256[] profileIds;
    }

    struct CollectParams {
        address collector;
        uint256 profileId;
        uint256 essenceId;
    }

    struct RegisterEssenceData {
        uint256 profileId;
        string name;
        string symbol;
        string essenceTokenURI;
        bytes initData;
        address essenceMw;
        bool transferable;
        bool deployAtRegister;
        address essBeacon;
    }

    struct SubscribeData {
        address sender;
        uint256[] profileIds;
        bytes[] preDatas;
        bytes[] postDatas;
        address subBeacon;
        address engine;
    }

    struct CollectData {
        address collector;
        uint256 profileId;
        uint256 essenceId;
        bytes preData;
        bytes postData;
        address essBeacon;
        address engine;
    }

    struct ProfileStruct {
        string handle;
        string avatar;
        uint256 essenceCount;
    }

    struct SubscribeStruct {
        string tokenURI;
        address subscribeNFT;
        address subscribeMw;
    }

    struct EssenceStruct {
        address essenceNFT;
        address essenceMw;
        string name;
        string symbol;
        string tokenURI;
        bool transferable;
    }

    struct NamespaceStruct {
        address profileMw;
        string name;
    }

    struct ConstructTokenURIParams {
        uint256 tokenId;
        string handle;
        uint256 subscribers;
    }

    struct ComputedAddresses {
        address profileProxy;
        address profileFactory;
        address subscribeFactory;
        address essenceFactory;
    }

    struct ProfileDeployParameters {
        address engine;
        address subBeacon;
        address essenceBeacon;
    }

    struct SubscribeDeployParameters {
        address profileProxy;
    }

    struct EssenceDeployParameters {
        address profileProxy;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

import { ITreasury } from "../../interfaces/ITreasury.sol";

abstract contract FeeMw {
    /*//////////////////////////////////////////////////////////////
                              STATES
    //////////////////////////////////////////////////////////////*/
    address public immutable TREASURY; // solhint-disable-line

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address treasury) {
        require(treasury != address(0), "ZERO_TREASURY_ADDRESS");
        TREASURY = treasury;
    }

    /*//////////////////////////////////////////////////////////////
                              INTERNAL
    //////////////////////////////////////////////////////////////*/

    function _currencyAllowed(address currency) internal view returns (bool) {
        return ITreasury(TREASURY).isCurrencyAllowed(currency);
    }

    function _treasuryAddress() internal view returns (address) {
        return ITreasury(TREASURY).getTreasuryAddress();
    }

    function _treasuryFee() internal view returns (uint256) {
        return ITreasury(TREASURY).getTreasuryFee();
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

import { Address } from "openzeppelin-contracts/contracts/utils/Address.sol";
import { IERC721 } from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import { SafeERC20 } from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20 } from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import { IEssenceMiddleware } from "../../interfaces/IEssenceMiddleware.sol";
import { IProfileNFT } from "../../interfaces/IProfileNFT.sol";

import { Constants } from "../../libraries/Constants.sol";

import { FeeMw } from "../base/FeeMw.sol";

/**
 * @title  Collect LimitedTimePaid Middleware
 * @author CyberConnect
 * @notice This contract is a middleware to only allow users to collect when they pay a certain fee to the essence owner.
 * the essence creator can choose to set rules including whether collecting this essence require profile/subscribe holder,
 * start/end time and has a total supply.
 */
contract CollectLimitedTimePaidMw is IEssenceMiddleware, FeeMw {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                              MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier onlyValidNamespace() {
        require(_namespace == msg.sender, "ONLY_VALID_NAMESPACE");
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                EVENT
    //////////////////////////////////////////////////////////////*/

    event CollectLimitedTimePaidMwSet(
        address indexed namespace,
        uint256 indexed profileId,
        uint256 indexed essenceId,
        uint256 totalSupply,
        uint256 price,
        address recipient,
        address currency,
        uint256 endTimestamp,
        uint256 startTimestamp,
        bool profileRequired,
        bool subscribeRequired
    );

    /*//////////////////////////////////////////////////////////////
                               STATES
    //////////////////////////////////////////////////////////////*/

    struct CollectLimitedTimePaidData {
        uint256 totalSupply;
        uint256 currentCollect;
        uint256 price;
        address recipient;
        address currency;
        uint256 endTimestamp;
        uint256 startTimestamp;
        bool profileRequired;
        bool subscribeRequired;
    }

    mapping(uint256 => mapping(uint256 => CollectLimitedTimePaidData))
        internal _data;
    address internal _namespace;

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address treasury, address namespace) FeeMw(treasury) {
        _namespace = namespace;
    }

    /*//////////////////////////////////////////////////////////////
                              EXTERNAL
    //////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IEssenceMiddleware
     * @notice Stores the parameters for setting up the limited time paid essence middleware, checks if the recipient, total suppply
     * start/end time is valid and currency is approved.
     */
    function setEssenceMwData(
        uint256 profileId,
        uint256 essenceId,
        bytes calldata data
    ) external override onlyValidNamespace returns (bytes memory) {
        (
            uint256 totalSupply,
            uint256 price,
            address recipient,
            address currency,
            uint256 endTimestamp,
            uint256 startTimestamp,
            bool profileRequired,
            bool subscribeRequired
        ) = abi.decode(
                data,
                (
                    uint256,
                    uint256,
                    address,
                    address,
                    uint256,
                    uint256,
                    bool,
                    bool
                )
            );

        require(recipient != address(0), "INVALID_RECIPENT");
        require(totalSupply > 0, "INVALID_TOTAL_SUPPLY");
        require(endTimestamp > startTimestamp, "INVALID_TIME_RANGE");
        require(_currencyAllowed(currency), "CURRENCY_NOT_ALLOWED");

        _data[profileId][essenceId].totalSupply = totalSupply;
        _data[profileId][essenceId].price = price;
        _data[profileId][essenceId].recipient = recipient;
        _data[profileId][essenceId].subscribeRequired = subscribeRequired;
        _data[profileId][essenceId].profileRequired = profileRequired;
        _data[profileId][essenceId].startTimestamp = startTimestamp;
        _data[profileId][essenceId].endTimestamp = endTimestamp;
        _data[profileId][essenceId].currency = currency;

        emit CollectLimitedTimePaidMwSet(
            _namespace,
            profileId,
            essenceId,
            totalSupply,
            price,
            recipient,
            currency,
            endTimestamp,
            startTimestamp,
            profileRequired,
            subscribeRequired
        );

        return new bytes(0);
    }

    /**
     * @inheritdoc IEssenceMiddleware
     * @notice Determines whether the collection requires prior subscription and whether there is a limit, and processes the transaction
     * from the essence collector to the essence owner.
     */
    function preProcess(
        uint256 profileId,
        uint256 essenceId,
        address collector,
        address,
        bytes calldata
    ) external override onlyValidNamespace {
        require(tx.origin == collector, "NOT_FROM_COLLECTOR");
        require(
            _data[profileId][essenceId].totalSupply >
                _data[profileId][essenceId].currentCollect,
            "COLLECT_LIMIT_EXCEEDED"
        );

        require(
            block.timestamp >= _data[profileId][essenceId].startTimestamp,
            "NOT_STARTED"
        );

        require(
            block.timestamp <= _data[profileId][essenceId].endTimestamp,
            "ENDED"
        );

        if (_data[profileId][essenceId].subscribeRequired == true) {
            require(
                _checkSubscribe(_namespace, profileId, collector),
                "NOT_SUBSCRIBED"
            );
        }

        if (_data[profileId][essenceId].profileRequired == true) {
            require(_checkProfile(_namespace, collector), "NOT_PROFILE_OWNER");
        }

        uint256 price = _data[profileId][essenceId].price;

        if (price > 0) {
            address currency = _data[profileId][essenceId].currency;
            uint256 treasuryCollected = (price * _treasuryFee()) /
                Constants._MAX_BPS;
            uint256 actualPaid = price - treasuryCollected;

            IERC20(currency).safeTransferFrom(
                collector,
                _data[profileId][essenceId].recipient,
                actualPaid
            );

            if (treasuryCollected > 0) {
                IERC20(currency).safeTransferFrom(
                    collector,
                    _treasuryAddress(),
                    treasuryCollected
                );
            }
        }

        ++_data[profileId][essenceId].currentCollect;
    }

    /// @inheritdoc IEssenceMiddleware
    function postProcess(
        uint256,
        uint256,
        address,
        address,
        bytes calldata
    ) external {
        // do nothing
    }

    /*//////////////////////////////////////////////////////////////
                              INTERNAL
    //////////////////////////////////////////////////////////////*/

    function _checkSubscribe(
        address namespace,
        uint256 profileId,
        address collector
    ) internal view returns (bool) {
        address essenceOwnerSubscribeNFT = IProfileNFT(namespace)
            .getSubscribeNFT(profileId);

        return (essenceOwnerSubscribeNFT != address(0) &&
            IERC721(essenceOwnerSubscribeNFT).balanceOf(collector) > 0);
    }

    function _checkProfile(address namespace, address collector)
        internal
        view
        returns (bool)
    {
        return (IERC721(namespace).balanceOf(collector) > 0);
    }
}