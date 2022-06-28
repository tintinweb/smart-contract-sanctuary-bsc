// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../interfaces/INftfiHub.sol";
import "../interfaces/IPermittedAirdrops.sol";
import "../interfaces/INftWrapper.sol";
import "../utils/ContractKeys.sol";

/**
 * @title AirdropFlashLoan
 * @author NFTfi
 * @dev
 */
contract AirdropFlashLoan is ERC721Holder, ERC1155Holder, ReentrancyGuard {
    using Address for address;
    using SafeERC20 for IERC20;

    INftfiHub public immutable hub;

    constructor(address _nftfiHub) {
        hub = INftfiHub(_nftfiHub);
    }

    function pullAirdrop(
        address _nftCollateralContract,
        uint256 _nftCollateralId,
        address _nftWrapper,
        address _target,
        bytes calldata _data,
        address _nftAirdrop,
        uint256 _nftAirdropId,
        bool _is1155,
        uint256 _nftAirdropAmount,
        address _beneficiary
    ) external nonReentrant {
        require(
            IPermittedAirdrops(hub.getContract(ContractKeys.PERMITTED_AIRDROPS)).isValidAirdrop(
                abi.encode(_target, _getSelector(_data))
            ),
            "Invalid Airdrop"
        );

        // assumes that the collateral nft has been transferreded to this contract before calling this function
        _target.functionCall(_data);

        // return the collateral
        _transferNFT(_nftWrapper, address(this), msg.sender, _nftCollateralContract, _nftCollateralId);

        // in case that arbitray function from _target does not send the airdrop to a specified address
        if (_nftAirdrop != address(0) && _beneficiary != address(0)) {
            // send the airdrop to the beneficiary
            if (_is1155) {
                IERC1155(_nftAirdrop).safeTransferFrom(
                    address(this),
                    _beneficiary,
                    _nftAirdropId,
                    _nftAirdropAmount,
                    "0x"
                );
            } else {
                IERC721(_nftAirdrop).safeTransferFrom(address(this), _beneficiary, _nftAirdropId);
            }
        }
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 _interfaceId) public view virtual override(ERC1155Receiver) returns (bool) {
        return _interfaceId == type(IERC721Receiver).interfaceId || super.supportsInterface(_interfaceId);
    }

    function _transferNFT(
        address _nftWrapper,
        address _sender,
        address _recipient,
        address _nftCollateralContract,
        uint256 _nftCollateralId
    ) internal {
        _nftWrapper.functionDelegateCall(
            abi.encodeWithSelector(
                INftWrapper(_nftWrapper).transferNFT.selector,
                _sender,
                _recipient,
                _nftCollateralContract,
                _nftCollateralId
            ),
            "NFT was not successfully transferred"
        );
    }

    function _getSelector(bytes memory _data) internal pure returns (bytes4 selector) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            selector := mload(add(_data, 32))
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155Receiver.sol";

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

/**
 * @title INftfiHub
 * @author NFTfi
 * @dev NftfiHub interface
 */
interface INftfiHub {
    function setContract(string calldata _contractKey, address _contractAddress) external;

    function getContract(bytes32 _contractKey) external view returns (address);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

interface IPermittedAirdrops {
    function isValidAirdrop(bytes memory _addressSig) external view returns (bool);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

/**
 * @title INftTypeRegistry
 * @author NFTfi
 * @dev Interface for NFT Wrappers.
 */
interface INftWrapper {
    function transferNFT(
        address from,
        address to,
        address nftContract,
        uint256 tokenId
    ) external returns (bool);

    function isOwner(
        address owner,
        address nftContract,
        uint256 tokenId
    ) external view returns (bool);

    function wrapAirdropReceiver(
        address _recipient,
        address _nftContract,
        uint256 _nftId,
        address _beneficiary
    ) external returns (bool);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

/**
 * @title ContractKeys
 * @author NFTfi
 * @dev Common library for contract keys
 */
library ContractKeys {
    bytes32 public constant PERMITTED_ERC20S = bytes32("PERMITTED_ERC20S");
    bytes32 public constant PERMITTED_NFTS = bytes32("PERMITTED_NFTS");
    bytes32 public constant PERMITTED_PARTNERS = bytes32("PERMITTED_PARTNERS");
    bytes32 public constant NFT_TYPE_REGISTRY = bytes32("NFT_TYPE_REGISTRY");
    bytes32 public constant LOAN_REGISTRY = bytes32("LOAN_REGISTRY");
    bytes32 public constant PERMITTED_SNFT_RECEIVER = bytes32("PERMITTED_SNFT_RECEIVER");
    bytes32 public constant PERMITTED_BUNDLE_ERC20S = bytes32("PERMITTED_BUNDLE_ERC20S");
    bytes32 public constant PERMITTED_AIRDROPS = bytes32("PERMITTED_AIRDROPS");
    bytes32 public constant AIRDROP_RECEIVER = bytes32("AIRDROP_RECEIVER");
    bytes32 public constant AIRDROP_FACTORY = bytes32("AIRDROP_FACTORY");
    bytes32 public constant AIRDROP_FLASH_LOAN = bytes32("AIRDROP_FLASH_LOAN");
    bytes32 public constant NFTFI_BUNDLER = bytes32("NFTFI_BUNDLER");

    string public constant AIRDROP_WRAPPER_STRING = "AirdropWrapper";

    /**
     * @notice Returns the bytes32 representation of a string
     * @param _key the string key
     * @return id bytes32 representation
     */
    function getIdFromStringKey(string memory _key) external pure returns (bytes32 id) {
        require(bytes(_key).length <= 32, "invalid key");

        // solhint-disable-next-line no-inline-assembly
        assembly {
            id := mload(add(_key, 32))
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155Receiver.sol";
import "../../../utils/introspection/ERC165.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

import "../interfaces/IPermittedNFTs.sol";
import "../interfaces/INftTypeRegistry.sol";
import "../interfaces/INftfiHub.sol";

import "../utils/Ownable.sol";
import "../utils/ContractKeys.sol";

/**
 * @title  PermittedNFTsAndTypeRegistry
 * @author NFTfi
 * @dev Registry for NFT contracts supported by NFTfi.
 * Each NFT is associated with an NFT Type.
 */
contract PermittedNFTsAndTypeRegistry is Ownable, IPermittedNFTs {
    INftfiHub public hub;
    mapping(bytes32 => address) private nftTypes;

    /**
     * @notice A mapping from an NFT contract's address to the Token type of that contract. A zero Token Type indicates
     * non-permitted.
     */
    mapping(address => bytes32) private nftPermits;

    /* ****** */
    /* EVENTS */
    /* ****** */

    /**
     * @notice This event is fired whenever the admins register a ntf type.
     *
     * @param nftType - Nft type represented by keccak256('nft type').
     * @param nftWrapper - Address of the wrapper contract.
     */
    event TypeUpdated(bytes32 indexed nftType, address indexed nftWrapper);

    /**
     * @notice This event is fired whenever the admin sets a NFT's permit.
     *
     * @param nftContract - Address of the NFT contract.
     * @param nftType - NTF type e.g. bytes32("CRYPTO_KITTIES")
     */
    event NFTPermit(address indexed nftContract, bytes32 indexed nftType);

    /* ********* */
    /* MODIFIERS */
    /* ********* */

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwnerOrAirdropFactory(string memory _nftType) {
        if (
            ContractKeys.getIdFromStringKey(_nftType) ==
            ContractKeys.getIdFromStringKey(ContractKeys.AIRDROP_WRAPPER_STRING)
        ) {
            require(hub.getContract(ContractKeys.AIRDROP_FACTORY) == _msgSender(), "caller is not AirdropFactory");
        } else {
            require(owner() == _msgSender(), "caller is not owner");
        }
        _;
    }

    /* *********** */
    /* CONSTRUCTOR */
    /* *********** */

    /**
     * @dev Sets `nftTypeRegistry`
     * Initialize `nftPermits` with a batch of permitted NFTs
     *
     * @param _admin - Initial admin of this contract.
     * @param _nftfiHub - Address of the NftfiHub contract
     * @param _definedNftTypes - All the ossible nft types
     * @param _definedNftWrappers - All the possible wrappers for the types
     * @param _permittedNftContracts - The addresses of the NFT contracts.
     * @param _permittedNftTypes - The NFT Types. e.g. "CRYPTO_KITTIES"
     * - "" means "disable this permit"
     * - != "" means "enable permit with the given NFT Type"
     */
    constructor(
        address _admin,
        address _nftfiHub,
        string[] memory _definedNftTypes,
        address[] memory _definedNftWrappers,
        address[] memory _permittedNftContracts,
        string[] memory _permittedNftTypes
    ) Ownable(_admin) {
        hub = INftfiHub(_nftfiHub);
        _setNftTypes(_definedNftTypes, _definedNftWrappers);
        _setNFTPermits(_permittedNftContracts, _permittedNftTypes);
    }

    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    /**
     * @notice This function can be called by admins to change the permitted list status of an NFT contract. This
     * includes both adding an NFT contract to the permitted list and removing it.
     * `_nftContract` can not be zero address.
     *
     * @param _nftContract - The address of the NFT contract.
     * @param _nftType - The NFT Type. e.g. "CRYPTO_KITTIES"
     * - "" means "disable this permit"
     * - != "" means "enable permit with the given NFT Type"
     */
    function setNFTPermit(address _nftContract, string memory _nftType)
        external
        override
        onlyOwnerOrAirdropFactory(_nftType)
    {
        _setNFTPermit(_nftContract, _nftType);
    }

    /**
     * @notice This function can be called by admins to change the permitted list status of a batch NFT contracts. This
     * includes both adding an NFT contract to the permitted list and removing it.
     * `_nftContract` can not be zero address.
     *
     * @param _nftContracts - The addresses of the NFT contracts.
     * @param _nftTypes - The NFT Types. e.g. "CRYPTO_KITTIES"
     * - "" means "disable this permit"
     * - != "" means "enable permit with the given NFT Type"
     */
    function setNFTPermits(address[] memory _nftContracts, string[] memory _nftTypes) external onlyOwner {
        _setNFTPermits(_nftContracts, _nftTypes);
    }

    /**
     * @notice This function can be called by anyone to lookup the Nft Type associated with the contract.
     * @param  _nftContract - The address of the NFT contract.
     * @notice Returns the NFT Type:
     * - bytes32("") means "not permitted"
     * - != bytes32("") means "permitted with the given NFT Type"
     */
    function getNFTPermit(address _nftContract) external view override returns (bytes32) {
        return nftPermits[_nftContract];
    }

    /**
     * @notice This function can be called by anyone to lookup the address of the NftWrapper associated to the
     * `_nftContract` type.
     * @param _nftContract - The address of the NFT contract.
     */
    function getNFTWrapper(address _nftContract) external view override returns (address) {
        bytes32 nftType = nftPermits[_nftContract];
        return getNftTypeWrapper(nftType);
    }

    /**
     * @notice Set or update the wrapper contract address for the given NFT Type.
     * Set address(0) for a nft type for un-register such type.
     *
     * @param _nftType - The nft type, e.g. "ERC721", or "ERC1155".
     * @param _nftWrapper - The address of the wrapper contract that implements INftWrapper behaviour for dealing with
     * NFTs.
     */
    function setNftType(string memory _nftType, address _nftWrapper) external onlyOwner {
        _setNftType(_nftType, _nftWrapper);
    }

    /**
     * @notice Batch set or update the wrappers contract address for the given batch of NFT Types.
     * Set address(0) for a nft type for un-register such type.
     *
     * @param _nftTypes - The nft types, e.g. "ERC721", or "ERC1155".
     * @param _nftWrappers - The addresses of the wrapper contract that implements INftWrapper behaviour for dealing
     * with NFTs.
     */
    function setNftTypes(string[] memory _nftTypes, address[] memory _nftWrappers) external onlyOwner {
        _setNftTypes(_nftTypes, _nftWrappers);
    }

    /**
     * @notice This function can be called by anyone to get the contract address that implements the given nft type.
     *
     * @param  _nftType - The nft type, e.g. bytes32("ERC721"), or bytes32("ERC1155").
     */
    function getNftTypeWrapper(bytes32 _nftType) public view returns (address) {
        return nftTypes[_nftType];
    }

    /**
     * @notice Set or update the wrapper contract address for the given NFT Type.
     * Set address(0) for a nft type for un-register such type.
     *
     * @param _nftType - The nft type, e.g. "ERC721", or "ERC1155".
     * @param _nftWrapper - The address of the wrapper contract that implements INftWrapper behaviour for dealing with
     * NFTs.
     */
    function _setNftType(string memory _nftType, address _nftWrapper) internal {
        require(bytes(_nftType).length != 0, "nftType is empty");
        bytes32 nftTypeKey = ContractKeys.getIdFromStringKey(_nftType);

        nftTypes[nftTypeKey] = _nftWrapper;

        emit TypeUpdated(nftTypeKey, _nftWrapper);
    }

    /**
     * @notice Batch set or update the wrappers contract address for the given batch of NFT Types.
     * Set address(0) for a nft type for un-register such type.
     *
     * @param _nftTypes - The nft types, e.g. keccak256("ERC721"), or keccak256("ERC1155").
     * @param _nftWrappers - The addresses of the wrapper contract that implements INftWrapper behaviour for dealing
     * with NFTs.
     */
    function _setNftTypes(string[] memory _nftTypes, address[] memory _nftWrappers) internal {
        require(_nftTypes.length == _nftWrappers.length, "setNftTypes function information arity mismatch");

        for (uint256 i = 0; i < _nftWrappers.length; i++) {
            _setNftType(_nftTypes[i], _nftWrappers[i]);
        }
    }

    /**
     * @notice This function changes the permitted list status of an NFT contract. This includes both adding an NFT
     * contract to the permitted list and removing it.
     * @param _nftContract - The address of the NFT contract.
     * @param _nftType - The NFT Type. e.g. bytes32("CRYPTO_KITTIES")
     * - bytes32("") means "disable this permit"
     * - != bytes32("") means "enable permit with the given NFT Type"
     */
    function _setNFTPermit(address _nftContract, string memory _nftType) internal {
        require(_nftContract != address(0), "nftContract is zero address");
        bytes32 nftTypeKey = ContractKeys.getIdFromStringKey(_nftType);

        if (nftTypeKey != 0) {
            require(getNftTypeWrapper(nftTypeKey) != address(0), "NFT type not registered");
        }

        require(
            nftPermits[_nftContract] != ContractKeys.getIdFromStringKey(ContractKeys.AIRDROP_WRAPPER_STRING),
            "AirdropWrapper can't be modified"
        );
        nftPermits[_nftContract] = nftTypeKey;
        emit NFTPermit(_nftContract, nftTypeKey);
    }

    /**
     * @notice This function changes the permitted list status of a batch NFT contracts. This includes both adding an
     * NFT contract to the permitted list and removing it.
     * @param _nftContracts - The addresses of the NFT contracts.
     * @param _nftTypes - The NFT Types. e.g. "CRYPTO_KITTIES"
     * - "" means "disable this permit"
     * - != "" means "enable permit with the given NFT Type"
     */
    function _setNFTPermits(address[] memory _nftContracts, string[] memory _nftTypes) internal {
        require(_nftContracts.length == _nftTypes.length, "setNFTPermits function information arity mismatch");

        for (uint256 i = 0; i < _nftContracts.length; i++) {
            _setNFTPermit(_nftContracts[i], _nftTypes[i]);
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

interface IPermittedNFTs {
    function setNFTPermit(address _nftContract, string memory _nftType) external;

    function getNFTPermit(address _nftContract) external view returns (bytes32);

    function getNFTWrapper(address _nftContract) external view returns (address);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

/**
 * @title INftTypeRegistry
 * @author NFTfi
 * @dev Interface for NFT Types Registry supported by NFTfi.
 */
interface INftTypeRegistry {
    function setNftType(bytes32 _nftType, address _nftWrapper) external;

    function getNftTypeWrapper(bytes32 _nftType) external view returns (address);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

import "@openzeppelin/contracts/utils/Context.sol";

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
 *
 * Modified version from openzeppelin/contracts/access/Ownable.sol that allows to
 * initialize the owner using a parameter in the constructor
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor(address _initialOwner) {
        _setOwner(_initialOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address _newOwner) public virtual onlyOwner {
        require(_newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(_newOwner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Sets the owner.
     */
    function _setOwner(address _newOwner) private {
        address oldOwner = _owner;
        _owner = _newOwner;
        emit OwnershipTransferred(oldOwner, _newOwner);
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

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

import "../interfaces/INftTypeRegistry.sol";
import "../interfaces/IPermittedPartners.sol";

import "../utils/Ownable.sol";

/**
 * @title  PermittedPartners
 * @author NFTfi
 * @dev Registry for partners permitted for reciving a revenue share.
 * Each partner's address is associated with the percent of the admin fee shared.
 */
contract PermittedPartners is Ownable, IPermittedPartners {
    /* ******* */
    /* STORAGE */
    /* ******* */

    uint256 public constant HUNDRED_PERCENT = 10000;

    /**
     * @notice A mapping from a partner's address to the percent of the admin fee shared with them. A zero indicates
     * non-permitted.
     */
    mapping(address => uint16) private partnerRevenueShare;

    /* ****** */
    /* EVENTS */
    /* ****** */

    /**
     * @notice This event is fired whenever the admin sets a partner's revenue share.
     *
     * @param partner - The address of the partner.
     * @param revenueShareInBasisPoints - The percent (measured in basis points) of the admin fee amount that will be
     * taken as a revenue share for a the partner.
     */
    event PartnerRevenueShare(address indexed partner, uint16 revenueShareInBasisPoints);

    /* *********** */
    /* CONSTRUCTOR */
    /* *********** */

    /**
     * @notice Sets the admin of the contract.
     *
     * @param _admin - Initial admin of this contract.
     */
    constructor(address _admin) Ownable(_admin) {
        // solhint-disable-previous-line no-empty-blocks
    }

    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    /**
     * @notice This function can be called by admins to change the revenue share status of a partner. This includes
     * adding an partner to the revenue share list, removing it and updating the revenue share percent.
     *
     * @param _partner - The address of the partner.
     * @param _revenueShareInBasisPoints - The percent (measured in basis points) of the admin fee amount that will be
     * taken as a revenue share for a the partner.
     */
    function setPartnerRevenueShare(address _partner, uint16 _revenueShareInBasisPoints) external onlyOwner {
        require(_partner != address(0), "Partner is address zero");
        require(_revenueShareInBasisPoints <= HUNDRED_PERCENT, "Revenue share too big");
        partnerRevenueShare[_partner] = _revenueShareInBasisPoints;
        emit PartnerRevenueShare(_partner, _revenueShareInBasisPoints);
    }

    /**
     * @notice This function can be called by anyone to get the revenue share parcent associated with the partner.
     *
     * @param _partner - The address of the partner.
     *
     * @return Returns the partner's revenue share
     */
    function getPartnerPermit(address _partner) external view override returns (uint16) {
        return partnerRevenueShare[_partner];
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

interface IPermittedPartners {
    function getPartnerPermit(address _partner) external view returns (uint16);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

import "./IDirectLoanBase.sol";
import "./LoanData.sol";
import "../../../interfaces/IDirectLoanCoordinator.sol";
import "../../../utils/ContractKeys.sol";
import "../../../interfaces/INftfiHub.sol";
import "../../../interfaces/IPermittedPartners.sol";
import "../../../interfaces/IPermittedERC20s.sol";
import "../../../interfaces/IAirdropFlashLoan.sol";
import "../../../interfaces/INftWrapper.sol";
import "../../../airdrop/IAirdropReceiverFactory.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title  LoanAirdropUtils
 * @author NFTfi
 * @notice Helper library for LoanBase
 */
library LoanAirdropUtils {
    /**
     * @notice This event is fired whenever a flashloan is initiated to pull an airdrop
     *
     * @param  loanId - A unique identifier for this particular loan, sourced from the Loan Coordinator.
     * @param  borrower - The address of the borrower.
     * @param  nftCollateralId - The ID within the AirdropReceiver for the NFT being used as collateral for this
     * loan.
     * @param  nftCollateralContract - The ERC721 contract of the NFT collateral
     * @param target - address of the airdropping contract
     * @param data - function selector to be called
     */
    event AirdropPulledFlashloan(
        uint256 indexed loanId,
        address indexed borrower,
        uint256 nftCollateralId,
        address nftCollateralContract,
        address target,
        bytes data
    );

    /**
     * @notice This event is fired whenever the collateral gets wrapped in an airdrop receiver
     *
     * @param  loanId - A unique identifier for this particular loan, sourced from the Loan Coordinator.
     * @param  borrower - The address of the borrower.
     * @param  nftCollateralId - The ID within the AirdropReceiver for the NFT being used as collateral for this
     * loan.
     * @param  nftCollateralContract - The contract of the NFT collateral
     * @param receiverId - id of the created AirdropReceiver, takes the place of nftCollateralId on the loan
     * @param receiverInstance - address of the created AirdropReceiver
     */
    event CollateralWrapped(
        uint256 indexed loanId,
        address indexed borrower,
        uint256 nftCollateralId,
        address nftCollateralContract,
        uint256 receiverId,
        address receiverInstance
    );

    function pullAirdrop(
        uint32 _loanId,
        LoanData.LoanTerms memory _loan,
        address _target,
        bytes calldata _data,
        address _nftAirdrop,
        uint256 _nftAirdropId,
        bool _is1155,
        uint256 _nftAirdropAmount,
        INftfiHub _hub
    ) external {
        IDirectLoanCoordinator loanCoordinator = IDirectLoanCoordinator(
            _hub.getContract(IDirectLoanBase(address(this)).LOAN_COORDINATOR())
        );

        address borrower;

        // scoped to aviod stack too deep
        {
            IDirectLoanCoordinator.Loan memory loanCoordinatorData = loanCoordinator.getLoanData(_loanId);
            uint256 smartNftId = loanCoordinatorData.smartNftId;
            if (_loan.borrower != address(0)) {
                borrower = _loan.borrower;
            } else {
                borrower = IERC721(loanCoordinator.obligationReceiptToken()).ownerOf(smartNftId);
            }
        }

        require(msg.sender == borrower, "Only borrower can airdrop");

        {
            IAirdropFlashLoan airdropFlashLoan = IAirdropFlashLoan(_hub.getContract(ContractKeys.AIRDROP_FLASH_LOAN));

            _transferNFT(_loan, address(this), address(airdropFlashLoan));

            airdropFlashLoan.pullAirdrop(
                _loan.nftCollateralContract,
                _loan.nftCollateralId,
                _loan.nftCollateralWrapper,
                _target,
                _data,
                _nftAirdrop,
                _nftAirdropId,
                _is1155,
                _nftAirdropAmount,
                borrower
            );
        }

        // revert if the collateral hasn't been transferred back before it ends
        require(
            INftWrapper(_loan.nftCollateralWrapper).isOwner(
                address(this),
                _loan.nftCollateralContract,
                _loan.nftCollateralId
            ),
            "Collateral should be returned"
        );

        emit AirdropPulledFlashloan(
            _loanId,
            borrower,
            _loan.nftCollateralId,
            _loan.nftCollateralContract,
            _target,
            _data
        );
    }

    function wrapCollateral(
        uint32 _loanId,
        LoanData.LoanTerms storage _loan,
        INftfiHub _hub
    ) external returns (address instance, uint256 receiverId) {
        IDirectLoanCoordinator loanCoordinator = IDirectLoanCoordinator(
            _hub.getContract(IDirectLoanBase(address(this)).LOAN_COORDINATOR())
        );
        // Fetch the current lender of the promissory note corresponding to this overdue loan.
        IDirectLoanCoordinator.Loan memory loanCoordinatorData = loanCoordinator.getLoanData(_loanId);
        uint256 smartNftId = loanCoordinatorData.smartNftId;

        address borrower;

        if (_loan.borrower != address(0)) {
            borrower = _loan.borrower;
        } else {
            borrower = IERC721(loanCoordinator.obligationReceiptToken()).ownerOf(smartNftId);
        }

        require(msg.sender == borrower, "Only borrower can wrapp");

        IAirdropReceiverFactory factory = IAirdropReceiverFactory(_hub.getContract(ContractKeys.AIRDROP_FACTORY));
        (instance, receiverId) = factory.createAirdropReceiver(address(this));

        // transfer collateral to airdrop receiver wrapper
        _transferNFTtoAirdropReceiver(_loan, instance, borrower);

        emit CollateralWrapped(
            _loanId,
            borrower,
            _loan.nftCollateralId,
            _loan.nftCollateralContract,
            receiverId,
            instance
        );

        // set the receiver as the new collateral
        _loan.nftCollateralContract = instance;
        _loan.nftCollateralId = receiverId;
    }

    /**
     * @dev Transfers several types of NFTs using a wrapper that knows how to handle each case.
     *
     * @param _loan -
     * @param _sender - Current owner of the NFT
     * @param _recipient - Recipient of the transfer
     */
    function _transferNFT(
        LoanData.LoanTerms memory _loan,
        address _sender,
        address _recipient
    ) internal {
        Address.functionDelegateCall(
            _loan.nftCollateralWrapper,
            abi.encodeWithSelector(
                INftWrapper(_loan.nftCollateralWrapper).transferNFT.selector,
                _sender,
                _recipient,
                _loan.nftCollateralContract,
                _loan.nftCollateralId
            ),
            "NFT not successfully transferred"
        );
    }

    /**
     * @dev Transfers several types of NFTs to an airdrop receiver with an airdrop beneficiary
     * address attached as supplementing data using a wrapper that knows how to handle each case.
     *
     * @param _loan -
     * @param _airdropReceiverInstance - Recipient of the transfer
     * @param _airdropBeneficiary - Beneficiary of the future airdops
     */
    function _transferNFTtoAirdropReceiver(
        LoanData.LoanTerms memory _loan,
        address _airdropReceiverInstance,
        address _airdropBeneficiary
    ) internal {
        Address.functionDelegateCall(
            _loan.nftCollateralWrapper,
            abi.encodeWithSelector(
                INftWrapper(_loan.nftCollateralWrapper).wrapAirdropReceiver.selector,
                _airdropReceiverInstance,
                _loan.nftCollateralContract,
                _loan.nftCollateralId,
                _airdropBeneficiary
            ),
            "NFT was not successfully migrated"
        );
    }
}

// SPDX-License-Identifier: BUSL-1.1

import "./LoanData.sol";

pragma solidity 0.8.4;

interface IDirectLoanBase {
    function maximumLoanDuration() external view returns (uint256);

    function adminFeeInBasisPoints() external view returns (uint16);

    // solhint-disable-next-line func-name-mixedcase
    function LOAN_COORDINATOR() external view returns (bytes32);

    function loanIdToLoan(uint32)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            address,
            uint32,
            uint16,
            uint16,
            address,
            uint64,
            address,
            address
        );

    function loanRepaidOrLiquidated(uint32) external view returns (bool);

    function getWhetherNonceHasBeenUsedForUser(address _user, uint256 _nonce) external view returns (bool);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

/**
 * @title  LoanData
 * @author NFTfi
 * @notice An interface containg the main Loan struct shared by Direct Loans types.
 */
interface LoanData {
    /* ********** */
    /* DATA TYPES */
    /* ********** */

    /**
     * @notice The main Loan Terms struct. This data is saved upon loan creation.
     *
     * @param loanERC20Denomination - The address of the ERC20 contract of the currency being used as principal/interest
     * for this loan.
     * @param loanPrincipalAmount - The original sum of money transferred from lender to borrower at the beginning of
     * the loan, measured in loanERC20Denomination's smallest units.
     * @param maximumRepaymentAmount - The maximum amount of money that the borrower would be required to retrieve their
     * collateral, measured in the smallest units of the ERC20 currency used for the loan. The borrower will always have
     * to pay this amount to retrieve their collateral, regardless of whether they repay early.
     * @param nftCollateralContract - The address of the the NFT collateral contract.
     * @param nftCollateralWrapper - The NFTfi wrapper of the NFT collateral contract.
     * @param nftCollateralId - The ID within the NFTCollateralContract for the NFT being used as collateral for this
     * loan. The NFT is stored within this contract during the duration of the loan.
     * @param loanStartTime - The block.timestamp when the loan first began (measured in seconds).
     * @param loanDuration - The amount of time (measured in seconds) that can elapse before the lender can liquidate
     * the loan and seize the underlying collateral NFT.
     * @param loanInterestRateForDurationInBasisPoints - This is the interest rate (measured in basis points, e.g.
     * hundreths of a percent) for the loan, that must be repaid pro-rata by the borrower at the conclusion of the loan
     * or risk seizure of their nft collateral. Note if the type of the loan is fixed then this value  is not used and
     * is irrelevant so it should be set to 0.
     * @param loanAdminFeeInBasisPoints - The percent (measured in basis points) of the interest earned that will be
     * taken as a fee by the contract admins when the loan is repaid. The fee is stored in the loan struct to prevent an
     * attack where the contract admins could adjust the fee right before a loan is repaid, and take all of the interest
     * earned.
     * @param borrower
     */
    struct LoanTerms {
        uint256 loanPrincipalAmount;
        uint256 maximumRepaymentAmount;
        uint256 nftCollateralId;
        address loanERC20Denomination;
        uint32 loanDuration;
        uint16 loanInterestRateForDurationInBasisPoints;
        uint16 loanAdminFeeInBasisPoints;
        address nftCollateralWrapper;
        uint64 loanStartTime;
        address nftCollateralContract;
        address borrower;
    }

    /**
     * @notice Some extra Loan's settings struct. This data is saved upon loan creation.
     * We need this to avoid stack too deep errors.
     *
     * @param revenueSharePartner - The address of the partner that will receive the revenue share.
     * @param revenueShareInBasisPoints - The percent (measured in basis points) of the admin fee amount that will be
     * taken as a revenue share for a t
     * @param referralFeeInBasisPoints - The percent (measured in basis points) of the loan principal amount that will
     * be taken as a fee to pay to the referrer, 0 if the lender is not paying referral fee.he partner, at the moment
     * the loan is begun.
     */
    struct LoanExtras {
        address revenueSharePartner;
        uint16 revenueShareInBasisPoints;
        uint16 referralFeeInBasisPoints;
    }

    /**
     * @notice The offer made by the lender. Used as parameter on both acceptOffer (initiated by the borrower) and
     * acceptListing (initiated by the lender).
     *
     * @param loanERC20Denomination - The address of the ERC20 contract of the currency being used as principal/interest
     * for this loan.
     * @param loanPrincipalAmount - The original sum of money transferred from lender to borrower at the beginning of
     * the loan, measured in loanERC20Denomination's smallest units.
     * @param maximumRepaymentAmount - The maximum amount of money that the borrower would be required to retrieve their
     *  collateral, measured in the smallest units of the ERC20 currency used for the loan. The borrower will always
     * have to pay this amount to retrieve their collateral, regardless of whether they repay early.
     * @param nftCollateralContract - The address of the ERC721 contract of the NFT collateral.
     * @param nftCollateralId - The ID within the NFTCollateralContract for the NFT being used as collateral for this
     * loan. The NFT is stored within this contract during the duration of the loan.
     * @param referrer - The address of the referrer who found the lender matching the listing, Zero address to signal
     * this there is no referrer.
     * @param loanDuration - The amount of time (measured in seconds) that can elapse before the lender can liquidate
     * the loan and seize the underlying collateral NFT.
     * @param loanAdminFeeInBasisPoints - The percent (measured in basis points) of the interest earned that will be
     * taken as a fee by the contract admins when the loan is repaid. The fee is stored in the loan struct to prevent an
     * attack where the contract admins could adjust the fee right before a loan is repaid, and take all of the interest
     * earned.
     */
    struct Offer {
        uint256 loanPrincipalAmount;
        uint256 maximumRepaymentAmount;
        uint256 nftCollateralId;
        address nftCollateralContract;
        uint32 loanDuration;
        uint16 loanAdminFeeInBasisPoints;
        address loanERC20Denomination;
        address referrer;
    }

    /**
     * @notice Signature related params. Used as parameter on both acceptOffer (containing borrower signature) and
     * acceptListing (containing lender signature).
     *
     * @param signer - The address of the signer. The borrower for `acceptOffer` the lender for `acceptListing`.
     * @param nonce - The nonce referred here is not the same as an Ethereum account's nonce.
     * We are referring instead to a nonce that is used by the lender or the borrower when they are first signing
     * off-chain NFTfi orders. These nonce can be any uint256 value that the user has not previously used to sign an
     * off-chain order. Each nonce can be used at most once per user within NFTfi, regardless of whether they are the
     * lender or the borrower in that situation. This serves two purposes:
     * - First, it prevents replay attacks where an attacker would submit a user's off-chain order more than once.
     * - Second, it allows a user to cancel an off-chain order by calling NFTfi.cancelLoanCommitmentBeforeLoanHasBegun()
     * , which marks the nonce as used and prevents any future loan from using the user's off-chain order that contains
     * that nonce.
     * @param expiry - Date when the signature expires
     * @param signature - The ECDSA signature of the borrower or the lender, obtained off-chain ahead of time, signing
     * the following combination of parameters:
     * - Borrower
     *   - ListingTerms.loanERC20Denomination,
     *   - ListingTerms.minLoanPrincipalAmount,
     *   - ListingTerms.maxLoanPrincipalAmount,
     *   - ListingTerms.nftCollateralContract,
     *   - ListingTerms.nftCollateralId,
     *   - ListingTerms.revenueSharePartner,
     *   - ListingTerms.minLoanDuration,
     *   - ListingTerms.maxLoanDuration,
     *   - ListingTerms.maxInterestRateForDurationInBasisPoints,
     *   - ListingTerms.referralFeeInBasisPoints,
     *   - Signature.signer,
     *   - Signature.nonce,
     *   - Signature.expiry,
     *   - address of the loan type contract
     *   - chainId
     * - Lender:
     *   - Offer.loanERC20Denomination
     *   - Offer.loanPrincipalAmount
     *   - Offer.maximumRepaymentAmount
     *   - Offer.nftCollateralContract
     *   - Offer.nftCollateralId
     *   - Offer.referrer
     *   - Offer.loanDuration
     *   - Offer.loanAdminFeeInBasisPoints
     *   - Signature.signer,
     *   - Signature.nonce,
     *   - Signature.expiry,
     *   - address of the loan type contract
     *   - chainId
     */
    struct Signature {
        uint256 nonce;
        uint256 expiry;
        address signer;
        bytes signature;
    }

    /**
     * @notice Some extra parameters that the borrower needs to set when accepting an offer.
     *
     * @param revenueSharePartner - The address of the partner that will receive the revenue share.
     * @param referralFeeInBasisPoints - The percent (measured in basis points) of the loan principal amount that will
     * be taken as a fee to pay to the referrer, 0 if the lender is not paying referral fee.
     */
    struct BorrowerSettings {
        address revenueSharePartner;
        uint16 referralFeeInBasisPoints;
    }

    /**
     * @notice Terms the borrower set off-chain and is willing to accept automatically when fulfiled by a lender's
     * offer.
     *
     * @param loanERC20Denomination - The address of the ERC20 contract of the currency being used as principal/interest
     * for this loan.
     * @param minLoanPrincipalAmount - The minumum sum of money transferred from lender to borrower at the beginning of
     * the loan, measured in loanERC20Denomination's smallest units.
     * @param maxLoanPrincipalAmount - The  sum of money transferred from lender to borrower at the beginning of
     * the loan, measured in loanERC20Denomination's smallest units.
     * @param maximumRepaymentAmount - The maximum amount of money that the borrower would be required to retrieve their
     * collateral, measured in the smallest units of the ERC20 currency used for the loan. The borrower will always have
     * to pay this amount to retrieve their collateral, regardless of whether they repay early.
     * @param nftCollateralContract - The address of the ERC721 contract of the NFT collateral.
     * @param nftCollateralId - The ID within the NFTCollateralContract for the NFT being used as collateral for this
     * loan. The NFT is stored within this contract during the duration of the loan.
     * @param revenueSharePartner - The address of the partner that will receive the revenue share.
     * @param minLoanDuration - The minumum amount of time (measured in seconds) that can elapse before the lender can
     * liquidate the loan and seize the underlying collateral NFT.
     * @param maxLoanDuration - The maximum amount of time (measured in seconds) that can elapse before the lender can
     * liquidate the loan and seize the underlying collateral NFT.
     * @param maxInterestRateForDurationInBasisPoints - This is maximum the interest rate (measured in basis points,
     * e.g. hundreths of a percent) for the loan.
     * @param referralFeeInBasisPoints - The percent (measured in basis points) of the loan principal amount that will
     * be taken as a fee to pay to the referrer, 0 if the lender is not paying referral fee.
     */
    struct ListingTerms {
        uint256 minLoanPrincipalAmount;
        uint256 maxLoanPrincipalAmount;
        uint256 nftCollateralId;
        address nftCollateralContract;
        uint32 minLoanDuration;
        uint32 maxLoanDuration;
        uint16 maxInterestRateForDurationInBasisPoints;
        uint16 referralFeeInBasisPoints;
        address revenueSharePartner;
        address loanERC20Denomination;
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

/**
 * @title IDirectLoanCoordinator
 * @author NFTfi
 * @dev DirectLoanCoordinator interface.
 */
interface IDirectLoanCoordinator {
    enum StatusType {
        NOT_EXISTS,
        NEW,
        RESOLVED
    }

    /**
     * @notice This struct contains data related to a loan
     *
     * @param smartNftId - The id of both the promissory note and obligation receipt.
     * @param status - The status in which the loan currently is.
     * @param loanContract - Address of the LoanType contract that created the loan.
     */
    struct Loan {
        address loanContract;
        uint64 smartNftId;
        StatusType status;
    }

    function registerLoan(address _lender, bytes32 _loanType) external returns (uint32);

    function mintObligationReceipt(uint32 _loanId, address _borrower) external;

    function resolveLoan(uint32 _loanId) external;

    function promissoryNoteToken() external view returns (address);

    function obligationReceiptToken() external view returns (address);

    function getLoanData(uint32 _loanId) external view returns (Loan memory);

    function isValidLoanId(uint32 _loanId, address _loanContract) external view returns (bool);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

interface IPermittedERC20s {
    function getERC20Permit(address _erc20) external view returns (bool);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

interface IAirdropFlashLoan {
    function pullAirdrop(
        address _nftCollateralContract,
        uint256 _nftCollateralId,
        address _nftWrapper,
        address _target,
        bytes calldata _data,
        address _nftAirdrop,
        uint256 _nftAirdropId,
        bool _is1155,
        uint256 _nftAirdropAmount,
        address _beneficiary
    ) external;
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

/**
 * @title IAirdropReceiver
 * @author NFTfi
 * @dev
 */
interface IAirdropReceiverFactory {
    function createAirdropReceiver(address _to) external returns (address, uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/SignatureChecker.sol)

pragma solidity ^0.8.0;

import "./ECDSA.sol";
import "../Address.sol";
import "../../interfaces/IERC1271.sol";

/**
 * @dev Signature verification helper that can be used instead of `ECDSA.recover` to seamlessly support both ECDSA
 * signatures from externally owned accounts (EOAs) as well as ERC1271 signatures from smart contract wallets like
 * Argent and Gnosis Safe.
 *
 * _Available since v4.1._
 */
library SignatureChecker {
    /**
     * @dev Checks if a signature is valid for a given signer and data hash. If the signer is a smart contract, the
     * signature is validated against that smart contract using ERC1271, otherwise it's validated using `ECDSA.recover`.
     *
     * NOTE: Unlike ECDSA signatures, contract signatures are revocable, and the outcome of this function can thus
     * change through time. It could return true at block N and false at block N+1 (or the opposite).
     */
    function isValidSignatureNow(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal view returns (bool) {
        (address recovered, ECDSA.RecoverError error) = ECDSA.tryRecover(hash, signature);
        if (error == ECDSA.RecoverError.NoError && recovered == signer) {
            return true;
        }

        (bool success, bytes memory result) = signer.staticcall(
            abi.encodeWithSelector(IERC1271.isValidSignature.selector, hash, signature)
        );
        return (success && result.length == 32 && abi.decode(result, (bytes4)) == IERC1271.isValidSignature.selector);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC1271.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC1271 standard signature validation method for
 * contracts as defined in https://eips.ethereum.org/EIPS/eip-1271[ERC-1271].
 *
 * _Available since v4.1._
 */
interface IERC1271 {
    /**
     * @dev Should return whether the signature provided is valid for the provided data
     * @param hash      Hash of the data to be signed
     * @param signature Signature byte array associated with _data
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "../utils/ContractKeys.sol";
import "../interfaces/INftfiHub.sol";

/**
 * @title SmartNft
 * @author NFTfi
 * @dev An ERC721 token which represents a very basic implementation of the NFTfi V2 SmartNFT.
 */
contract SmartNft is ERC721, AccessControl {
    using Address for address;
    using Strings for uint256;

    /**
     * @dev This struct contains data needed to find the loan linked to a SmartNft.
     */
    struct Loan {
        address loanCoordinator;
        uint256 loanId;
    }

    /* ******* */
    /* STORAGE */
    /* ******* */

    bytes32 public constant LOAN_COORDINATOR_ROLE = keccak256("LOAN_COORDINATOR_ROLE");
    bytes32 public constant BASE_URI_ROLE = keccak256("BASE_URI_ROLE");

    INftfiHub public immutable hub;

    // smartNftId => Loan
    mapping(uint256 => Loan) public loans;

    string public baseURI;

    /**
     * @dev Grants the contract the default admin role to `_admin`.
     * Grants LOAN_COORDINATOR_ROLE to `_loanCoordinator`.
     *
     * @param _admin - Account to set as the admin of roles
     * @param _nftfiHub - Address of the NftfiHub contract
     * @param _loanCoordinator - Initial loan coordinator
     * @param _name - Name for the SmarNFT
     * @param _symbol - Symbol for the SmarNFT
     * @param _customBaseURI - Base URI for the SmarNFT
     */
    constructor(
        address _admin,
        address _nftfiHub,
        address _loanCoordinator,
        string memory _name,
        string memory _symbol,
        string memory _customBaseURI
    ) ERC721(_name, _symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(BASE_URI_ROLE, _admin);
        _setupRole(LOAN_COORDINATOR_ROLE, _loanCoordinator);
        _setBaseURI(_customBaseURI);
        hub = INftfiHub(_nftfiHub);
    }

    /**
     * @dev Grants LOAN_COORDINATOR_ROLE to `_account`.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function setLoanCoordinator(address _account) external {
        grantRole(LOAN_COORDINATOR_ROLE, _account);
    }

    /**
     * @dev Mints a new token with `_tokenId` and assigne to `_to`.
     *
     * Requirements:
     *
     * - the caller must have `LOAN_COORDINATOR_ROLE` role.
     *
     * @param _to The address reciving the SmartNft
     * @param _tokenId The id of the new SmartNft
     * @param _data Up to the first 32 bytes contains an integer which represents the loanId linked to the SmartNft
     */
    function mint(
        address _to,
        uint256 _tokenId,
        bytes calldata _data
    ) external onlyRole(LOAN_COORDINATOR_ROLE) {
        require(_data.length > 0, "data must contain loanId");
        uint256 loanId = abi.decode(_data, (uint256));
        loans[_tokenId] = Loan({loanCoordinator: msg.sender, loanId: loanId});
        _safeMint(_to, _tokenId, _data);
    }

    /**
     * @dev Burns `_tokenId` token.
     *
     * Requirements:
     *
     * - the caller must have `LOAN_COORDINATOR_ROLE` role.
     */
    function burn(uint256 _tokenId) external onlyRole(LOAN_COORDINATOR_ROLE) {
        delete loans[_tokenId];
        _burn(_tokenId);
    }

    /**
     * @dev Sets baseURI.
     * @param _customBaseURI - Base URI for the SmarNFT
     */
    function setBaseURI(string memory _customBaseURI) external onlyRole(BASE_URI_ROLE) {
        _setBaseURI(_customBaseURI);
    }

    function exists(uint256 _tokenId) external view returns (bool) {
        return _exists(_tokenId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 _interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(_interfaceId);
    }

    /**
     * @dev Sets baseURI.
     */
    function _setBaseURI(string memory _customBaseURI) internal virtual {
        baseURI = bytes(_customBaseURI).length > 0
            ? string(abi.encodePacked(_customBaseURI, _getChainID().toString(), "/"))
            : "";
    }

    /** @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`.
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    /**
     * @dev This function gets the current chain ID.
     */
    function _getChainID() internal view returns (uint256) {
        uint256 id;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            id := chainid()
        }
        return id;
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

import "./interfaces/INftfiHub.sol";
import "./utils/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./utils/ContractKeys.sol";

/**
 * @title  NftfiHub
 * @author NFTfi
 * @dev Registry for the contracts supported by NFTfi protocol.
 */
contract NftfiHub is Ownable, Pausable, ReentrancyGuard, INftfiHub {
    /* ******* */
    /* STORAGE */
    /* ******* */

    mapping(bytes32 => address) private contracts;

    /* ****** */
    /* EVENTS */
    /* ****** */

    /**
     * @notice This event is fired whenever the admin registers a contract.
     *
     * @param contractKey - Contract key e.g. bytes32('PERMITTED_NFTS').
     * @param contractAddress - Address of the contract.
     */
    event ContractUpdated(bytes32 indexed contractKey, address indexed contractAddress);

    /* *********** */
    /* CONSTRUCTOR */
    /* *********** */

    /**
     * @dev Initializes `contracts` with a batch of permitted contracts
     *
     * @param _admin - Initial admin of this contract.
     * @param _contractKeys - Initial contract keys.
     * @param _contractAddresses - Initial associated contract addresses.
     */
    constructor(
        address _admin,
        string[] memory _contractKeys,
        address[] memory _contractAddresses
    ) Ownable(_admin) {
        _setContracts(_contractKeys, _contractAddresses);
    }

    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    /**
     * @notice Set or update the contract address for the given key.
     * @param _contractKey - New or existing contract key.
     * @param _contractAddress - The associated contract address.
     */
    function setContract(string calldata _contractKey, address _contractAddress) external override onlyOwner {
        _setContract(_contractKey, _contractAddress);
    }

    /**
     * @notice Set or update the contract addresses for the given keys.
     * @param _contractKeys - New or existing contract keys.
     * @param _contractAddresses - The associated contract addresses.
     */
    function setContracts(string[] memory _contractKeys, address[] memory _contractAddresses) external onlyOwner {
        _setContracts(_contractKeys, _contractAddresses);
    }

    /**
     * @notice This function can be called by anyone to lookup the contract address associated with the key.
     * @param  _contractKey - The index to the contract address.
     */
    function getContract(bytes32 _contractKey) external view override returns (address) {
        return contracts[_contractKey];
    }

    /**
     * @notice Set or update the contract address for the given key.
     * @param _contractKey - New or existing contract key.
     * @param _contractAddress - The associated contract address.
     */
    function _setContract(string memory _contractKey, address _contractAddress) internal {
        bytes32 key = ContractKeys.getIdFromStringKey(_contractKey);
        contracts[key] = _contractAddress;

        emit ContractUpdated(key, _contractAddress);
    }

    /**
     * @notice Set or update the contract addresses for the given keys.
     * @param _contractKeys - New or existing contract key.
     * @param _contractAddresses - The associated contract address.
     */
    function _setContracts(string[] memory _contractKeys, address[] memory _contractAddresses) internal {
        require(_contractKeys.length == _contractAddresses.length, "setContracts function information arity mismatch");

        for (uint256 i = 0; i < _contractKeys.length; i++) {
            _setContract(_contractKeys[i], _contractAddresses[i]);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

import "../utils/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title  BaseLoan
 * @author NFTfi
 * @dev Implements base functionalities common to all Loan types.
 * Mostly related to governance and security.
 */
abstract contract BaseLoan is Ownable, Pausable, ReentrancyGuard {
    /* *********** */
    /* CONSTRUCTOR */
    /* *********** */

    /**
     * @notice Sets the admin of the contract.
     *
     * @param _admin - Initial admin of this contract.
     */
    constructor(address _admin) Ownable(_admin) {
        // solhint-disable-previous-line no-empty-blocks
    }

    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - Only the owner can call this method.
     * - The contract must not be paused.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - Only the owner can call this method.
     * - The contract must be paused.
     */
    function unpause() external onlyOwner {
        _unpause();
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

import "./IDirectLoanBase.sol";
import "./LoanData.sol";
import "./LoanChecksAndCalculations.sol";
import "./LoanAirdropUtils.sol";
import "../../BaseLoan.sol";
import "../../../utils/NftReceiver.sol";
import "../../../utils/NFTfiSigningUtils.sol";
import "../../../interfaces/INftfiHub.sol";
import "../../../utils/ContractKeys.sol";
import "../../../interfaces/IDirectLoanCoordinator.sol";
import "../../../interfaces/INftWrapper.sol";
import "../../../interfaces/IPermittedPartners.sol";
import "../../../interfaces/IPermittedERC20s.sol";
import "../../../interfaces/IPermittedNFTs.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title  DirectLoanBase
 * @author NFTfi
 * @notice Main contract for NFTfi Direct Loans Type. This contract manages the ability to create NFT-backed
 * peer-to-peer loans.
 *
 * There are two ways to commence an NFT-backed loan:
 *
 * a. The borrower accepts a lender's offer by calling `acceptOffer`.
 *   1. the borrower calls nftContract.approveAll(NFTfi), approving the NFTfi contract to move their NFT's on their
 * be1alf.
 *   2. the lender calls erc20Contract.approve(NFTfi), allowing NFTfi to move the lender's ERC20 tokens on their
 * behalf.
 *   3. the lender signs an off-chain message, proposing its offer terms.
 *   4. the borrower calls `acceptOffer` to accept these terms and enter into the loan. The NFT is stored in
 * the contract, the borrower receives the loan principal in the specified ERC20 currency, the lender receives an
 * NFTfi promissory note (in ERC721 form) that represents the rights to either the principal-plus-interest, or the
 * underlying NFT collateral if the borrower does not pay back in time, and the borrower receives obligation receipt
 * (in ERC721 form) that gives them the right to pay back the loan and get the collateral back.
 *
 * b. The lender accepts a borrowe's binding terms by calling `acceptListing`.
 *   1. the borrower calls nftContract.approveAll(NFTfi), approving the NFTfi contract to move their NFT's on their
 * be1alf.
 *   2. the lender calls erc20Contract.approve(NFTfi), allowing NFTfi to move the lender's ERC20 tokens on their
 * behalf.
 *   3. the borrower signs an off-chain message, proposing its binding terms.
 *   4. the lender calls `acceptListing` with an offer matching the binding terms and enter into the loan. The NFT is
 * stored in the contract, the borrower receives the loan principal in the specified ERC20 currency, the lender
 * receives an NFTfi promissory note (in ERC721 form) that represents the rights to either the principal-plus-interest,
 * or the underlying NFT collateral if the borrower does not pay back in time, and the borrower receives obligation
 * receipt (in ERC721 form) that gives them the right to pay back the loan and get the collateral back.
 *
 * The lender can freely transfer and trade this ERC721 promissory note as they wish, with the knowledge that
 * transferring the ERC721 promissory note tranfsers the rights to principal-plus-interest and/or collateral, and that
 * they will no longer have a claim on the loan. The ERC721 promissory note itself represents that claim.
 *
 * The borrower can freely transfer and trade this ERC721 obligaiton receipt as they wish, with the knowledge that
 * transferring the ERC721 obligaiton receipt tranfsers the rights right to pay back the loan and get the collateral
 * back.
 *
 * A loan may end in one of two ways:
 * - First, a borrower may call NFTfi.payBackLoan() and pay back the loan plus interest at any time, in which case they
 * receive their NFT back in the same transaction.
 * - Second, if the loan's duration has passed and the loan has not been paid back yet, a lender can call
 * NFTfi.liquidateOverdueLoan(), in which case they receive the underlying NFT collateral and forfeit the rights to the
 * principal-plus-interest, which the borrower now keeps.
 *
 *
 * If the loan was created as a ProRated type loan (pro-rata interest loan), then the user only pays the principal plus
 * pro-rata interest if repaid early.
 * However, if the loan was was created as a Fixed type loan (agreed to be a fixed-repayment loan), then the borrower
 * pays the maximumRepaymentAmount regardless of whether they repay early or not.
 *
 */
abstract contract DirectLoanBaseMinimal is IDirectLoanBase, IPermittedERC20s, BaseLoan, NftReceiver, LoanData {
    using SafeERC20 for IERC20;

    /* ******* */
    /* STORAGE */
    /* ******* */

    uint16 public constant HUNDRED_PERCENT = 10000;

    bytes32 public immutable override LOAN_COORDINATOR;

    /**
     * @notice The maximum duration of any loan started for this loan type, measured in seconds. This is both a
     * sanity-check for borrowers and an upper limit on how long admins will have to support v1 of this contract if they
     * eventually deprecate it, as well as a check to ensure that the loan duration never exceeds the space alotted for
     * it in the loan struct.
     */
    uint256 public override maximumLoanDuration = 53 weeks;

    /**
     * @notice The percentage of interest earned by lenders on this platform that is taken by the contract admin's as a
     * fee, measured in basis points (hundreths of a percent). The max allowed value is 10000.
     */
    uint16 public override adminFeeInBasisPoints = 25;

    /**
     * @notice A mapping from a loan's identifier to the loan's details, represted by the loan struct.
     */
    mapping(uint32 => LoanTerms) public override loanIdToLoan;
    mapping(uint32 => LoanExtras) public loanIdToLoanExtras;

    /**
     * @notice A mapping tracking whether a loan has either been repaid or liquidated. This prevents an attacker trying
     * to repay or liquidate the same loan twice.
     */
    mapping(uint32 => bool) public override loanRepaidOrLiquidated;

    /**
     * @dev keeps track of tokens being held as loan collateral, so we dont allow these
     * to be transferred with the aridrop draining functions
     */
    mapping(address => mapping(uint256 => uint256)) private _escrowTokens;

    /**
     * @notice A mapping that takes both a user's address and a loan nonce that was first used when signing an off-chain
     * order and checks whether that nonce has previously either been used for a loan, or has been pre-emptively
     * cancelled. The nonce referred to here is not the same as an Ethereum account's nonce. We are referring instead to
     * nonces that are used by both the lender and the borrower when they are first signing off-chain NFTfi orders.
     *
     * These nonces can be any uint256 value that the user has not previously used to sign an off-chain order. Each
     * nonce can be used at most once per user within NFTfi, regardless of whether they are the lender or the borrower
     * in that situation. This serves two purposes. First, it prevents replay attacks where an attacker would submit a
     * user's off-chain order more than once. Second, it allows a user to cancel an off-chain order by calling
     * NFTfi.cancelLoanCommitmentBeforeLoanHasBegun(), which marks the nonce as used and prevents any future loan from
     * using the user's off-chain order that contains that nonce.
     */
    mapping(address => mapping(uint256 => bool)) internal _nonceHasBeenUsedForUser;

    /**
     * @notice A mapping from an ERC20 currency address to whether that currency
     * is permitted to be used by this contract.
     */
    mapping(address => bool) private erc20Permits;

    INftfiHub public immutable hub;

    /* ****** */
    /* EVENTS */
    /* ****** */

    /**
     * @notice This event is fired whenever the admins change the percent of interest rates earned that they charge as a
     * fee. Note that newAdminFee can never exceed 10,000, since the fee is measured in basis points.
     *
     * @param  newAdminFee - The new admin fee measured in basis points. This is a percent of the interest paid upon a
     * loan's completion that go to the contract admins.
     */
    event AdminFeeUpdated(uint16 newAdminFee);

    /**
     * @notice This event is fired whenever the admins change the maximum duration of any loan started for this loan
     * type.
     *
     * @param  newMaximumLoanDuration - The new maximum duration.
     */
    event MaximumLoanDurationUpdated(uint256 newMaximumLoanDuration);

    /**
     * @notice This event is fired whenever a borrower begins a loan by calling NFTfi.beginLoan(), which can only occur
     * after both the lender and borrower have approved their ERC721 and ERC20 contracts to use NFTfi, and when they
     * both have signed off-chain messages that agree on the terms of the loan.
     *
     * @param  loanId - A unique identifier for this particular loan, sourced from the Loan Coordinator.
     * @param  borrower - The address of the borrower.
     * @param  lender - The address of the lender. The lender can change their address by transferring the NFTfi ERC721
     * token that they received when the loan began.
     */
    event LoanStarted(
        uint32 indexed loanId,
        address indexed borrower,
        address indexed lender,
        LoanTerms loanTerms,
        LoanExtras loanExtras
    );

    /**
     * @notice This event is fired whenever a borrower successfully repays their loan, paying
     * principal-plus-interest-minus-fee to the lender in loanERC20Denomination, paying fee to owner in
     * loanERC20Denomination, and receiving their NFT collateral back.
     *
     * @param  loanId - A unique identifier for this particular loan, sourced from the Loan Coordinator.
     * @param  borrower - The address of the borrower.
     * @param  lender - The address of the lender. The lender can change their address by transferring the NFTfi ERC721
     * token that they received when the loan began.
     * @param  loanPrincipalAmount - The original sum of money transferred from lender to borrower at the beginning of
     * the loan, measured in loanERC20Denomination's smallest units.
     * @param  nftCollateralId - The ID within the NFTCollateralContract for the NFT being used as collateral for this
     * loan. The NFT is stored within this contract during the duration of the loan.
     * @param  amountPaidToLender The amount of ERC20 that the borrower paid to the lender, measured in the smalled
     * units of loanERC20Denomination.
     * @param  adminFee The amount of interest paid to the contract admins, measured in the smalled units of
     * loanERC20Denomination and determined by adminFeeInBasisPoints. This amount never exceeds the amount of interest
     * earned.
     * @param  revenueShare The amount taken from admin fee amount shared with the partner.
     * @param  revenueSharePartner  - The address of the partner that will receive the revenue share.
     * @param  nftCollateralContract - The ERC721 contract of the NFT collateral
     * @param  loanERC20Denomination - The ERC20 contract of the currency being used as principal/interest for this
     * loan.
     */
    event LoanRepaid(
        uint32 indexed loanId,
        address indexed borrower,
        address indexed lender,
        uint256 loanPrincipalAmount,
        uint256 nftCollateralId,
        uint256 amountPaidToLender,
        uint256 adminFee,
        uint256 revenueShare,
        address revenueSharePartner,
        address nftCollateralContract,
        address loanERC20Denomination
    );

    /**
     * @notice This event is fired whenever a lender liquidates an outstanding loan that is owned to them that has
     * exceeded its duration. The lender receives the underlying NFT collateral, and the borrower no longer needs to
     * repay the loan principal-plus-interest.
     *
     * @param  loanId - A unique identifier for this particular loan, sourced from the Loan Coordinator.
     * @param  borrower - The address of the borrower.
     * @param  lender - The address of the lender. The lender can change their address by transferring the NFTfi ERC721
     * token that they received when the loan began.
     * @param  loanPrincipalAmount - The original sum of money transferred from lender to borrower at the beginning of
     * the loan, measured in loanERC20Denomination's smallest units.
     * @param  nftCollateralId - The ID within the NFTCollateralContract for the NFT being used as collateral for this
     * loan. The NFT is stored within this contract during the duration of the loan.
     * @param  loanMaturityDate - The unix time (measured in seconds) that the loan became due and was eligible for
     * liquidation.
     * @param  loanLiquidationDate - The unix time (measured in seconds) that liquidation occurred.
     * @param  nftCollateralContract - The ERC721 contract of the NFT collateral
     */
    event LoanLiquidated(
        uint32 indexed loanId,
        address indexed borrower,
        address indexed lender,
        uint256 loanPrincipalAmount,
        uint256 nftCollateralId,
        uint256 loanMaturityDate,
        uint256 loanLiquidationDate,
        address nftCollateralContract
    );

    /**
     * @notice This event is fired when some of the terms of a loan are being renegotiated.
     *
     * @param loanId - The unique identifier for the loan to be renegotiated
     * @param newLoanDuration - The new amount of time (measured in seconds) that can elapse before the lender can
     * liquidate the loan and seize the underlying collateral NFT.
     * @param newMaximumRepaymentAmount - The new maximum amount of money that the borrower would be required to
     * retrieve their collateral, measured in the smallest units of the ERC20 currency used for the loan. The
     * borrower will always have to pay this amount to retrieve their collateral, regardless of whether they repay
     * early.
     * @param renegotiationFee Agreed upon fee in loan denomination that borrower pays for the lender for the
     * renegotiation, has to be paid with an ERC20 transfer loanERC20Denomination token, uses transfer from,
     * frontend will have to propmt an erc20 approve for this from the borrower to the lender
     * @param renegotiationAdminFee renegotiationFee admin portion based on determined by adminFeeInBasisPoints
     */
    event LoanRenegotiated(
        uint32 indexed loanId,
        address indexed borrower,
        address indexed lender,
        uint32 newLoanDuration,
        uint256 newMaximumRepaymentAmount,
        uint256 renegotiationFee,
        uint256 renegotiationAdminFee
    );

    /**
     * @notice This event is fired whenever the admin sets a ERC20 permit.
     *
     * @param erc20Contract - Address of the ERC20 contract.
     * @param isPermitted - Signals ERC20 permit.
     */
    event ERC20Permit(address indexed erc20Contract, bool isPermitted);

    /* *********** */
    /* CONSTRUCTOR */
    /* *********** */

    /**
     * @dev Sets `hub`
     *
     * @param _admin - Initial admin of this contract.
     * @param  _nftfiHub - NFTfiHub address
     * @param  _loanCoordinatorKey -
     * @param  _permittedErc20s -
     */
    constructor(
        address _admin,
        address _nftfiHub,
        bytes32 _loanCoordinatorKey,
        address[] memory _permittedErc20s
    ) BaseLoan(_admin) {
        hub = INftfiHub(_nftfiHub);
        LOAN_COORDINATOR = _loanCoordinatorKey;
        for (uint256 i = 0; i < _permittedErc20s.length; i++) {
            _setERC20Permit(_permittedErc20s[i], true);
        }
    }

    /* *************** */
    /* ADMIN FUNCTIONS */
    /* *************** */

    /**
     * @notice This function can be called by admins to change the maximumLoanDuration. Note that they can never change
     * maximumLoanDuration to be greater than UINT32_MAX, since that's the maximum space alotted for the duration in the
     * loan struct.
     *
     * @param _newMaximumLoanDuration - The new maximum loan duration, measured in seconds.
     */
    function updateMaximumLoanDuration(uint256 _newMaximumLoanDuration) external onlyOwner {
        require(_newMaximumLoanDuration <= uint256(type(uint32).max), "Loan duration overflow");
        maximumLoanDuration = _newMaximumLoanDuration;
        emit MaximumLoanDurationUpdated(_newMaximumLoanDuration);
    }

    /**
     * @notice This function can be called by admins to change the percent of interest rates earned that they charge as
     * a fee. Note that newAdminFee can never exceed 10,000, since the fee is measured in basis points.
     *
     * @param _newAdminFeeInBasisPoints - The new admin fee measured in basis points. This is a percent of the interest
     * paid upon a loan's completion that go to the contract admins.
     */
    function updateAdminFee(uint16 _newAdminFeeInBasisPoints) external onlyOwner {
        require(_newAdminFeeInBasisPoints <= HUNDRED_PERCENT, "basis points > 10000");
        adminFeeInBasisPoints = _newAdminFeeInBasisPoints;
        emit AdminFeeUpdated(_newAdminFeeInBasisPoints);
    }

    /**
     * @notice used by the owner account to be able to drain ERC20 tokens received as airdrops
     * for the locked  collateral NFT-s
     * @param _tokenAddress - address of the token contract for the token to be sent out
     * @param _receiver - receiver of the token
     */
    function drainERC20Airdrop(address _tokenAddress, address _receiver) external onlyOwner {
        IERC20 tokenContract = IERC20(_tokenAddress);
        uint256 amount = tokenContract.balanceOf(address(this));
        require(amount > 0, "no tokens owned");
        tokenContract.safeTransfer(_receiver, amount);
    }

    /**
     * @notice This function can be called by admins to change the permitted status of an ERC20 currency. This includes
     * both adding an ERC20 currency to the permitted list and removing it.
     *
     * @param _erc20 - The address of the ERC20 currency whose permit list status changed.
     * @param _permit - The new status of whether the currency is permitted or not.
     */
    function setERC20Permit(address _erc20, bool _permit) external onlyOwner {
        _setERC20Permit(_erc20, _permit);
    }

    /**
     * @notice This function can be called by admins to change the permitted status of a batch of ERC20 currency. This
     * includes both adding an ERC20 currency to the permitted list and removing it.
     *
     * @param _erc20s - The addresses of the ERC20 currencies whose permit list status changed.
     * @param _permits - The new statuses of whether the currency is permitted or not.
     */
    function setERC20Permits(address[] memory _erc20s, bool[] memory _permits) external onlyOwner {
        require(_erc20s.length == _permits.length, "setERC20Permits function information arity mismatch");

        for (uint256 i = 0; i < _erc20s.length; i++) {
            _setERC20Permit(_erc20s[i], _permits[i]);
        }
    }

    /**
     * @notice used by the owner account to be able to drain ERC721 tokens received as airdrops
     * for the locked  collateral NFT-s
     * @param _tokenAddress - address of the token contract for the token to be sent out
     * @param _tokenId - id token to be sent out
     * @param _receiver - receiver of the token
     */
    function drainERC721Airdrop(
        address _tokenAddress,
        uint256 _tokenId,
        address _receiver
    ) external onlyOwner {
        IERC721 tokenContract = IERC721(_tokenAddress);
        require(_escrowTokens[_tokenAddress][_tokenId] == 0, "token is collateral");
        require(tokenContract.ownerOf(_tokenId) == address(this), "nft not owned");
        tokenContract.safeTransferFrom(address(this), _receiver, _tokenId);
    }

    /**
     * @notice used by the owner account to be able to drain ERC1155 tokens received as airdrops
     * for the locked  collateral NFT-s
     * @param _tokenAddress - address of the token contract for the token to be sent out
     * @param _tokenId - id token to be sent out
     * @param _receiver - receiver of the token
     */
    function drainERC1155Airdrop(
        address _tokenAddress,
        uint256 _tokenId,
        address _receiver
    ) external onlyOwner {
        IERC1155 tokenContract = IERC1155(_tokenAddress);
        uint256 amount = tokenContract.balanceOf(address(this), _tokenId);
        require(_escrowTokens[_tokenAddress][_tokenId] == 0, "token is collateral");
        require(amount > 0, "no nfts owned");
        tokenContract.safeTransferFrom(address(this), _receiver, _tokenId, amount, "");
    }

    function mintObligationReceipt(uint32 _loanId) external nonReentrant {
        address borrower = loanIdToLoan[_loanId].borrower;
        require(msg.sender == borrower, "sender has to be borrower");

        IDirectLoanCoordinator loanCoordinator = IDirectLoanCoordinator(hub.getContract(LOAN_COORDINATOR));
        loanCoordinator.mintObligationReceipt(_loanId, borrower);

        delete loanIdToLoan[_loanId].borrower;
    }

    /**
     * @dev makes possible to change loan duration and max repayment amount, loan duration even can be extended if
     * loan was expired but not liquidated.
     *
     * @param _loanId - The unique identifier for the loan to be renegotiated
     * @param _newLoanDuration - The new amount of time (measured in seconds) that can elapse before the lender can
     * liquidate the loan and seize the underlying collateral NFT.
     * @param _newMaximumRepaymentAmount - The new maximum amount of money that the borrower would be required to
     * retrieve their collateral, measured in the smallest units of the ERC20 currency used for the loan. The
     * borrower will always have to pay this amount to retrieve their collateral, regardless of whether they repay
     * early.
     * @param _renegotiationFee Agreed upon fee in ether that borrower pays for the lender for the renegitiation
     * @param _lenderNonce - The nonce referred to here is not the same as an Ethereum account's nonce. We are
     * referring instead to nonces that are used by both the lender and the borrower when they are first signing
     * off-chain NFTfi orders. These nonces can be any uint256 value that the user has not previously used to sign an
     * off-chain order. Each nonce can be used at most once per user within NFTfi, regardless of whether they are the
     * lender or the borrower in that situation. This serves two purposes:
     * - First, it prevents replay attacks where an attacker would submit a user's off-chain order more than once.
     * - Second, it allows a user to cancel an off-chain order by calling NFTfi.cancelLoanCommitmentBeforeLoanHasBegun()
     * , which marks the nonce as used and prevents any future loan from using the user's off-chain order that contains
     * that nonce.
     * @param _expiry - The date when the renegotiation offer expires
     * @param _lenderSignature - The ECDSA signature of the lender, obtained off-chain ahead of time, signing the
     * following combination of parameters:
     * - _loanId
     * - _newLoanDuration
     * - _newMaximumRepaymentAmount
     * - _lender
     * - _expiry
     *  - address of this contract
     * - chainId
     */
    function renegotiateLoan(
        uint32 _loanId,
        uint32 _newLoanDuration,
        uint256 _newMaximumRepaymentAmount,
        uint256 _renegotiationFee,
        uint256 _lenderNonce,
        uint256 _expiry,
        bytes memory _lenderSignature
    ) external whenNotPaused nonReentrant {
        _renegotiateLoan(
            _loanId,
            _newLoanDuration,
            _newMaximumRepaymentAmount,
            _renegotiationFee,
            _lenderNonce,
            _expiry,
            _lenderSignature
        );
    }

    /**
     * @notice This function is called by a anyone to repay a loan. It can be called at any time after the loan has
     * begun and before loan expiry.. The caller will pay a pro-rata portion of their interest if the loan is paid off
     * early and the loan is pro-rated type, but the complete repayment amount if it is fixed type.
     * The the borrower (current owner of the obligation note) will get the collaterl NFT back.
     *
     * This function is purposefully not pausable in order to prevent an attack where the contract admin's pause the
     * contract and hold hostage the NFT's that are still within it.
     *
     * @param _loanId  A unique identifier for this particular loan, sourced from the Loan Coordinator.
     */
    function payBackLoan(uint32 _loanId) external nonReentrant {
        LoanChecksAndCalculations.payBackChecks(_loanId, hub);
        (
            address borrower,
            address lender,
            LoanTerms memory loan,
            IDirectLoanCoordinator loanCoordinator
        ) = _getPartiesAndData(_loanId);

        _payBackLoan(_loanId, borrower, lender, loan);

        _resolveLoan(_loanId, borrower, loan, loanCoordinator);

        // Delete the loan from storage in order to achieve a substantial gas savings and to lessen the burden of
        // storage on Ethereum nodes, since we will never access this loan's details again, and the details are still
        // available through event data.
        delete loanIdToLoan[_loanId];
        delete loanIdToLoanExtras[_loanId];
    }

    /**
     * @notice This function is called by a lender once a loan has finished its duration and the borrower still has not
     * repaid. The lender can call this function to seize the underlying NFT collateral, although the lender gives up
     * all rights to the principal-plus-collateral by doing so.
     *
     * This function is purposefully not pausable in order to prevent an attack where the contract admin's pause
     * the contract and hold hostage the NFT's that are still within it.
     *
     * We intentionally allow anybody to call this function, although only the lender will end up receiving the seized
     * collateral. We are exploring the possbility of incentivizing users to call this function by using some of the
     * admin funds.
     *
     * @param _loanId  A unique identifier for this particular loan, sourced from the Loan Coordinator.
     */
    function liquidateOverdueLoan(uint32 _loanId) external nonReentrant {
        LoanChecksAndCalculations.checkLoanIdValidity(_loanId, hub);
        // Sanity check that payBackLoan() and liquidateOverdueLoan() have never been called on this loanId.
        // Depending on how the rest of the code turns out, this check may be unnecessary.
        require(!loanRepaidOrLiquidated[_loanId], "Loan already repaid/liquidated");

        (
            address borrower,
            address lender,
            LoanTerms memory loan,
            IDirectLoanCoordinator loanCoordinator
        ) = _getPartiesAndData(_loanId);

        // Ensure that the loan is indeed overdue, since we can only liquidate overdue loans.
        uint256 loanMaturityDate = uint256(loan.loanStartTime) + uint256(loan.loanDuration);
        require(block.timestamp > loanMaturityDate, "Loan is not overdue yet");

        require(msg.sender == lender, "Only lender can liquidate");

        _resolveLoan(_loanId, lender, loan, loanCoordinator);

        // Emit an event with all relevant details from this transaction.
        emit LoanLiquidated(
            _loanId,
            borrower,
            lender,
            loan.loanPrincipalAmount,
            loan.nftCollateralId,
            loanMaturityDate,
            block.timestamp,
            loan.nftCollateralContract
        );

        // Delete the loan from storage in order to achieve a substantial gas savings and to lessen the burden of
        // storage on Ethereum nodes, since we will never access this loan's details again, and the details are still
        // available through event data.
        delete loanIdToLoan[_loanId];
        delete loanIdToLoanExtras[_loanId];
    }

    /**
     * @notice this function initiates a flashloan to pull an airdrop from a tartget contract
     *
     * @param _loanId -
     * @param _target - address of the airdropping contract
     * @param _data - function selector to be called on the airdropping contract
     * @param _nftAirdrop - address of the used claiming nft in the drop
     * @param _nftAirdropId - id of the used claiming nft in the drop
     * @param _is1155 -
     * @param _nftAirdropAmount - amount in case of 1155
     */

    function pullAirdrop(
        uint32 _loanId,
        address _target,
        bytes calldata _data,
        address _nftAirdrop,
        uint256 _nftAirdropId,
        bool _is1155,
        uint256 _nftAirdropAmount
    ) external nonReentrant {
        LoanChecksAndCalculations.checkLoanIdValidity(_loanId, hub);
        require(!loanRepaidOrLiquidated[_loanId], "Loan already repaid/liquidated");

        LoanTerms memory loan = loanIdToLoan[_loanId];

        LoanAirdropUtils.pullAirdrop(
            _loanId,
            loan,
            _target,
            _data,
            _nftAirdrop,
            _nftAirdropId,
            _is1155,
            _nftAirdropAmount,
            hub
        );
    }

    /**
     * @notice this function creates a proxy contract wrapping the collateral to be able to catch an expected airdrop
     *
     * @param _loanId -
     */

    function wrapCollateral(uint32 _loanId) external nonReentrant {
        LoanChecksAndCalculations.checkLoanIdValidity(_loanId, hub);
        require(!loanRepaidOrLiquidated[_loanId], "Loan already repaid/liquidated");

        LoanTerms storage loan = loanIdToLoan[_loanId];

        _escrowTokens[loan.nftCollateralContract][loan.nftCollateralId] -= 1;
        (address instance, uint256 receiverId) = LoanAirdropUtils.wrapCollateral(_loanId, loan, hub);
        _escrowTokens[instance][receiverId] += 1;
    }

    /**
     * @notice This function can be called by either a lender or a borrower to cancel all off-chain orders that they
     * have signed that contain this nonce. If the off-chain orders were created correctly, there should only be one
     * off-chain order that contains this nonce at all.
     *
     * The nonce referred to here is not the same as an Ethereum account's nonce. We are referring
     * instead to nonces that are used by both the lender and the borrower when they are first signing off-chain NFTfi
     * orders. These nonces can be any uint256 value that the user has not previously used to sign an off-chain order.
     * Each nonce can be used at most once per user within NFTfi, regardless of whether they are the lender or the
     * borrower in that situation. This serves two purposes. First, it prevents replay attacks where an attacker would
     * submit a user's off-chain order more than once. Second, it allows a user to cancel an off-chain order by calling
     * NFTfi.cancelLoanCommitmentBeforeLoanHasBegun(), which marks the nonce as used and prevents any future loan from
     * using the user's off-chain order that contains that nonce.
     *
     * @param  _nonce - User nonce
     */
    function cancelLoanCommitmentBeforeLoanHasBegun(uint256 _nonce) external {
        require(!_nonceHasBeenUsedForUser[msg.sender][_nonce], "Invalid nonce");
        _nonceHasBeenUsedForUser[msg.sender][_nonce] = true;
    }

    /* ******************* */
    /* READ-ONLY FUNCTIONS */
    /* ******************* */

    /**
     * @notice This function can be used to view the current quantity of the ERC20 currency used in the specified loan
     * required by the borrower to repay their loan, measured in the smallest unit of the ERC20 currency.
     *
     * @param _loanId  A unique identifier for this particular loan, sourced from the Loan Coordinator.
     *
     * @return The amount of the specified ERC20 currency required to pay back this loan, measured in the smallest unit
     * of the specified ERC20 currency.
     */
    function getPayoffAmount(uint32 _loanId) external view virtual returns (uint256);

    /**
     * @notice This function can be used to view whether a particular nonce for a particular user has already been used,
     * either from a successful loan or a cancelled off-chain order.
     *
     * @param _user - The address of the user. This function works for both lenders and borrowers alike.
     * @param  _nonce - The nonce referred to here is not the same as an Ethereum account's nonce. We are referring
     * instead to nonces that are used by both the lender and the borrower when they are first signing off-chain
     * NFTfi orders. These nonces can be any uint256 value that the user has not previously used to sign an off-chain
     * order. Each nonce can be used at most once per user within NFTfi, regardless of whether they are the lender or
     * the borrower in that situation. This serves two purposes:
     * - First, it prevents replay attacks where an attacker would submit a user's off-chain order more than once.
     * - Second, it allows a user to cancel an off-chain order by calling NFTfi.cancelLoanCommitmentBeforeLoanHasBegun()
     * , which marks the nonce as used and prevents any future loan from using the user's off-chain order that contains
     * that nonce.
     *
     * @return A bool representing whether or not this nonce has been used for this user.
     */
    function getWhetherNonceHasBeenUsedForUser(address _user, uint256 _nonce) external view override returns (bool) {
        return _nonceHasBeenUsedForUser[_user][_nonce];
    }

    /**
     * @notice This function can be called by anyone to get the permit associated with the erc20 contract.
     *
     * @param _erc20 - The address of the erc20 contract.
     *
     * @return Returns whether the erc20 is permitted
     */
    function getERC20Permit(address _erc20) public view override returns (bool) {
        return erc20Permits[_erc20];
    }

    /* ****************** */
    /* INTERNAL FUNCTIONS */
    /* ****************** */

    /**
     * @dev makes possible to change loan duration and max repayment amount, loan duration even can be extended if
     * loan was expired but not liquidated. IMPORTANT: Frontend will have to propt the caller to do an ERC20 approve for
     * the fee amount from themselves (borrower/obligation reciept holder) to the lender (promissory note holder)
     *
     * @param _loanId - The unique identifier for the loan to be renegotiated
     * @param _newLoanDuration - The new amount of time (measured in seconds) that can elapse before the lender can
     * liquidate the loan and seize the underlying collateral NFT.
     * @param _newMaximumRepaymentAmount - The new maximum amount of money that the borrower would be required to
     * retrieve their collateral, measured in the smallest units of the ERC20 currency used for the loan. The
     * borrower will always have to pay this amount to retrieve their collateral, regardless of whether they repay
     * early.
     * @param _renegotiationFee Agreed upon fee in loan denomination that borrower pays for the lender and
     * the admin for the renegotiation, has to be paid with an ERC20 transfer loanERC20Denomination token,
     * uses transfer from, frontend will have to propmt an erc20 approve for this from the borrower to the lender,
     * admin fee is calculated by the loan's loanAdminFeeInBasisPoints value
     * @param _lenderNonce - The nonce referred to here is not the same as an Ethereum account's nonce. We are
     * referring instead to nonces that are used by both the lender and the borrower when they are first signing
     * off-chain NFTfi orders. These nonces can be any uint256 value that the user has not previously used to sign an
     * off-chain order. Each nonce can be used at most once per user within NFTfi, regardless of whether they are the
     * lender or the borrower in that situation. This serves two purposes:
     * - First, it prevents replay attacks where an attacker would submit a user's off-chain order more than once.
     * - Second, it allows a user to cancel an off-chain order by calling NFTfi.cancelLoanCommitmentBeforeLoanHasBegun()
     , which marks the nonce as used and prevents any future loan from using the user's off-chain order that contains
     * that nonce.
     * @param _expiry - The date when the renegotiation offer expires
     * @param _lenderSignature - The ECDSA signature of the lender, obtained off-chain ahead of time, signing the
     * following combination of parameters:
     * - _loanId
     * - _newLoanDuration
     * - _newMaximumRepaymentAmount
     * - _lender
     * - _expiry
     * - address of this contract
     * - chainId
     */
    function _renegotiateLoan(
        uint32 _loanId,
        uint32 _newLoanDuration,
        uint256 _newMaximumRepaymentAmount,
        uint256 _renegotiationFee,
        uint256 _lenderNonce,
        uint256 _expiry,
        bytes memory _lenderSignature
    ) internal {
        LoanTerms storage loan = loanIdToLoan[_loanId];

        (address borrower, address lender) = LoanChecksAndCalculations.renegotiationChecks(
            loan,
            _loanId,
            _newLoanDuration,
            _newMaximumRepaymentAmount,
            _lenderNonce,
            hub
        );

        _nonceHasBeenUsedForUser[lender][_lenderNonce] = true;

        require(
            NFTfiSigningUtils.isValidLenderRenegotiationSignature(
                _loanId,
                _newLoanDuration,
                _newMaximumRepaymentAmount,
                _renegotiationFee,
                Signature({signer: lender, nonce: _lenderNonce, expiry: _expiry, signature: _lenderSignature})
            ),
            "Renegotiation signature is invalid"
        );

        uint256 renegotiationAdminFee;
        /**
         * @notice Transfers fee to the lender immediately
         * @dev implements Checks-Effects-Interactions pattern by modifying state only after
         * the transfer happened successfully, we also add the nonReentrant modifier to
         * the pbulic versions
         */
        if (_renegotiationFee > 0) {
            renegotiationAdminFee = LoanChecksAndCalculations.computeAdminFee(
                _renegotiationFee,
                loan.loanAdminFeeInBasisPoints
            );
            // Transfer principal-plus-interest-minus-fees from the caller (always has to be borrower) to lender
            IERC20(loan.loanERC20Denomination).safeTransferFrom(
                borrower,
                lender,
                _renegotiationFee - renegotiationAdminFee
            );
            // Transfer fees from the caller (always has to be borrower) to admins
            IERC20(loan.loanERC20Denomination).safeTransferFrom(borrower, owner(), renegotiationAdminFee);
        }

        loan.loanDuration = _newLoanDuration;
        loan.maximumRepaymentAmount = _newMaximumRepaymentAmount;

        emit LoanRenegotiated(
            _loanId,
            borrower,
            lender,
            _newLoanDuration,
            _newMaximumRepaymentAmount,
            _renegotiationFee,
            renegotiationAdminFee
        );
    }

    /**
     * @dev Transfer collateral NFT from borrower to this contract and principal from lender to the borrower and
     * registers the new loan through the loan coordinator.
     *
     * @param _loanType - The type of loan it is being created
     * @param _loanTerms - Struct containing the loan's settings
     * @param _loanExtras - Struct containing some loan's extra settings, needed to avoid stack too deep
     * @param _lender - The address of the lender.
     * @param _referrer - The address of the referrer who found the lender matching the listing, Zero address to signal
     * that there is no referrer.
     */
    function _createLoan(
        bytes32 _loanType,
        LoanTerms memory _loanTerms,
        LoanExtras memory _loanExtras,
        address _borrower,
        address _lender,
        address _referrer
    ) internal returns (uint32) {
        // Transfer collateral from borrower to this contract to be held until
        // loan completion.
        _transferNFT(_loanTerms, _borrower, address(this));

        return _createLoanNoNftTransfer(_loanType, _loanTerms, _loanExtras, _borrower, _lender, _referrer);
    }

    /**
     * @dev Transfer principal from lender to the borrower and
     * registers the new loan through the loan coordinator.
     *
     * @param _loanType - The type of loan it is being created
     * @param _loanTerms - Struct containing the loan's settings
     * @param _loanExtras - Struct containing some loan's extra settings, needed to avoid stack too deep
     * @param _lender - The address of the lender.
     * @param _referrer - The address of the referrer who found the lender matching the listing, Zero address to signal
     * that there is no referrer.
     */
    function _createLoanNoNftTransfer(
        bytes32 _loanType,
        LoanTerms memory _loanTerms,
        LoanExtras memory _loanExtras,
        address _borrower,
        address _lender,
        address _referrer
    ) internal returns (uint32 loanId) {
        _escrowTokens[_loanTerms.nftCollateralContract][_loanTerms.nftCollateralId] += 1;

        uint256 referralfee = LoanChecksAndCalculations.computeReferralFee(
            _loanTerms.loanPrincipalAmount,
            _loanExtras.referralFeeInBasisPoints,
            _referrer
        );
        uint256 principalAmount = _loanTerms.loanPrincipalAmount - referralfee;
        if (referralfee > 0) {
            // Transfer the referral fee from lender to referrer.
            IERC20(_loanTerms.loanERC20Denomination).safeTransferFrom(_lender, _referrer, referralfee);
        }
        // Transfer principal from lender to borrower.
        IERC20(_loanTerms.loanERC20Denomination).safeTransferFrom(_lender, _borrower, principalAmount);

        // Issue an ERC721 promissory note to the lender that gives them the
        // right to either the principal-plus-interest or the collateral,
        // and an obligation note to the borrower that gives them the
        // right to pay back the loan and get the collateral back.
        IDirectLoanCoordinator loanCoordinator = IDirectLoanCoordinator(hub.getContract(LOAN_COORDINATOR));
        loanId = loanCoordinator.registerLoan(_lender, _loanType);

        // Add the loan to storage before moving collateral/principal to follow
        // the Checks-Effects-Interactions pattern.
        loanIdToLoan[loanId] = _loanTerms;
        loanIdToLoanExtras[loanId] = _loanExtras;

        return loanId;
    }

    /**
     * @dev Transfers several types of NFTs using a wrapper that knows how to handle each case.
     *
     * @param _loanTerms - Struct containing all the loan's parameters
     * @param _sender - Current owner of the NFT
     * @param _recipient - Recipient of the transfer
     */
    function _transferNFT(
        LoanTerms memory _loanTerms,
        address _sender,
        address _recipient
    ) internal {
        Address.functionDelegateCall(
            _loanTerms.nftCollateralWrapper,
            abi.encodeWithSelector(
                INftWrapper(_loanTerms.nftCollateralWrapper).transferNFT.selector,
                _sender,
                _recipient,
                _loanTerms.nftCollateralContract,
                _loanTerms.nftCollateralId
            ),
            "NFT not successfully transferred"
        );
    }

    /**
     * @notice This function is called by a anyone to repay a loan. It can be called at any time after the loan has
     * begun and before loan expiry.. The caller will pay a pro-rata portion of their interest if the loan is paid off
     * early and the loan is pro-rated type, but the complete repayment amount if it is fixed type.
     * The the borrower (current owner of the obligation note) will get the collaterl NFT back.
     *
     * This function is purposefully not pausable in order to prevent an attack where the contract admin's pause the
     * contract and hold hostage the NFT's that are still within it.
     *
     * @param _loanId  A unique identifier for this particular loan, sourced from the Loan Coordinator.
     */
    function _payBackLoan(
        uint32 _loanId,
        address _borrower,
        address _lender,
        LoanTerms memory _loan
    ) internal {
        // Fetch loan details from storage, but store them in memory for the sake of saving gas.
        LoanExtras memory loanExtras = loanIdToLoanExtras[_loanId];

        (uint256 adminFee, uint256 payoffAmount) = _payoffAndFee(_loan);

        // Transfer principal-plus-interest-minus-fees from the caller to lender
        IERC20(_loan.loanERC20Denomination).safeTransferFrom(msg.sender, _lender, payoffAmount);

        uint256 revenueShare = LoanChecksAndCalculations.computeRevenueShare(
            adminFee,
            loanExtras.revenueShareInBasisPoints
        );
        // PermittedPartners contract doesn't allow to set a revenueShareInBasisPoints for address zero so revenuShare
        // > 0 implies that revenueSharePartner ~= address(0), BUT revenueShare can be zero for a partener when the
        // adminFee is low
        if (revenueShare > 0 && loanExtras.revenueSharePartner != address(0)) {
            adminFee -= revenueShare;
            // Transfer revenue share from the caller to permitted partner
            IERC20(_loan.loanERC20Denomination).safeTransferFrom(
                msg.sender,
                loanExtras.revenueSharePartner,
                revenueShare
            );
        }
        // Transfer fees from the caller to admins
        IERC20(_loan.loanERC20Denomination).safeTransferFrom(msg.sender, owner(), adminFee);

        // Emit an event with all relevant details from this transaction.
        emit LoanRepaid(
            _loanId,
            _borrower,
            _lender,
            _loan.loanPrincipalAmount,
            _loan.nftCollateralId,
            payoffAmount,
            adminFee,
            revenueShare,
            loanExtras.revenueSharePartner, // this could be a non address zero even if revenueShare is 0
            _loan.nftCollateralContract,
            _loan.loanERC20Denomination
        );
    }

    /**
     * @notice A convenience function with shared functionality between `payBackLoan` and `liquidateOverdueLoan`.
     *
     * @param _loanId  A unique identifier for this particular loan, sourced from the Loan Coordinator.
     * @param _nftReceiver - The receiver of the collateral nft. The borrower when `payBackLoan` or the lender when
     * `liquidateOverdueLoan`.
     * @param _loanTerms - The main Loan Terms struct. This data is saved upon loan creation on loanIdToLoan.
     * @param _loanCoordinator - The loan coordinator used when creating the loan.
     */
    function _resolveLoan(
        uint32 _loanId,
        address _nftReceiver,
        LoanTerms memory _loanTerms,
        IDirectLoanCoordinator _loanCoordinator
    ) internal {
        _resolveLoanNoNftTransfer(_loanId, _loanTerms, _loanCoordinator);
        // Transfer collateral from this contract to the lender, since the lender is seizing collateral for an overdue
        // loan
        _transferNFT(_loanTerms, address(this), _nftReceiver);
    }

    /**
     * @notice Resolving the loan without trasferring the nft to provide a base for the bundle
     * break up of the bundled loans
     *
     * @param _loanId  A unique identifier for this particular loan, sourced from the Loan Coordinator.
     * @param _loanTerms - The main Loan Terms struct. This data is saved upon loan creation on loanIdToLoan.
     * @param _loanCoordinator - The loan coordinator used when creating the loan.
     */
    function _resolveLoanNoNftTransfer(
        uint32 _loanId,
        LoanTerms memory _loanTerms,
        IDirectLoanCoordinator _loanCoordinator
    ) internal {
        // Mark loan as liquidated before doing any external transfers to follow the Checks-Effects-Interactions design
        // pattern
        loanRepaidOrLiquidated[_loanId] = true;

        _escrowTokens[_loanTerms.nftCollateralContract][_loanTerms.nftCollateralId] -= 1;

        // Destroy the lender's promissory note for this loan and borrower obligation receipt
        _loanCoordinator.resolveLoan(_loanId);
    }

    /**
     * @notice This function can be called by admins to change the permitted status of an ERC20 currency. This includes
     * both adding an ERC20 currency to the permitted list and removing it.
     *
     * @param _erc20 - The address of the ERC20 currency whose permit list status changed.
     * @param _permit - The new status of whether the currency is permitted or not.
     */
    function _setERC20Permit(address _erc20, bool _permit) internal {
        require(_erc20 != address(0), "erc20 is zero address");

        erc20Permits[_erc20] = _permit;

        emit ERC20Permit(_erc20, _permit);
    }

    /**
     * @dev Performs some validation checks over loan parameters
     *
     */
    function _loanSanityChecks(LoanData.Offer memory _offer, address _nftWrapper) internal view {
        require(getERC20Permit(_offer.loanERC20Denomination), "Currency denomination is not permitted");
        require(_nftWrapper != address(0), "NFT collateral contract is not permitted");
        require(uint256(_offer.loanDuration) <= maximumLoanDuration, "Loan duration exceeds maximum loan duration");
        require(uint256(_offer.loanDuration) != 0, "Loan duration cannot be zero");
        require(
            _offer.loanAdminFeeInBasisPoints == adminFeeInBasisPoints,
            "The admin fee has changed since this order was signed."
        );
    }

    /**
     * @dev reads some variable values of a loan for payback functions, created to reduce code repetition
     */
    function _getPartiesAndData(uint32 _loanId)
        internal
        view
        returns (
            address borrower,
            address lender,
            LoanTerms memory loan,
            IDirectLoanCoordinator loanCoordinator
        )
    {
        loanCoordinator = IDirectLoanCoordinator(hub.getContract(LOAN_COORDINATOR));
        IDirectLoanCoordinator.Loan memory loanCoordinatorData = loanCoordinator.getLoanData(_loanId);
        uint256 smartNftId = loanCoordinatorData.smartNftId;
        // Fetch loan details from storage, but store them in memory for the sake of saving gas.
        loan = loanIdToLoan[_loanId];
        if (loan.borrower != address(0)) {
            borrower = loan.borrower;
        } else {
            // Fetch current owner of loan obligation note.
            borrower = IERC721(loanCoordinator.obligationReceiptToken()).ownerOf(smartNftId);
        }
        lender = IERC721(loanCoordinator.promissoryNoteToken()).ownerOf(smartNftId);
    }

    /**
     * @dev Creates a `LoanExtras` struct using data sent as the borrower's extra settings.
     * This is needed in order to avoid stack too deep issues.
     */
    function _setupLoanExtras(address _revenueSharePartner, uint16 _referralFeeInBasisPoints)
        internal
        view
        returns (LoanExtras memory)
    {
        // Save loan details to a struct in memory first, to save on gas if any
        // of the below checks fail, and to avoid the "Stack Too Deep" error by
        // clumping the parameters together into one struct held in memory.
        return
            LoanExtras({
                revenueSharePartner: _revenueSharePartner,
                revenueShareInBasisPoints: LoanChecksAndCalculations.getRevenueSharePercent(_revenueSharePartner, hub),
                referralFeeInBasisPoints: _referralFeeInBasisPoints
            });
    }

    /**
     * @dev Calculates the payoff amount and admin fee
     */
    function _payoffAndFee(LoanTerms memory _loanTerms) internal view virtual returns (uint256, uint256);

    /**
     * @dev Checks that the collateral is a supported contracts and returns what wrapper to use for the loan's NFT
     * collateral contract.
     *
     * @param _nftCollateralContract - The address of the the NFT collateral contract.
     *
     * @return Address of the NftWrapper to use for the loan's NFT collateral.
     */
    function _getWrapper(address _nftCollateralContract) internal view returns (address) {
        return IPermittedNFTs(hub.getContract(ContractKeys.PERMITTED_NFTS)).getNFTWrapper(_nftCollateralContract);
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

import "./IDirectLoanBase.sol";
import "./LoanData.sol";
import "../../../interfaces/IDirectLoanCoordinator.sol";
import "../../../utils/ContractKeys.sol";
import "../../../interfaces/INftfiHub.sol";
import "../../../interfaces/IPermittedPartners.sol";
import "../../../interfaces/IPermittedERC20s.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title  LoanChecksAndCalculations
 * @author NFTfi
 * @notice Helper library for LoanBase
 */
library LoanChecksAndCalculations {
    uint16 private constant HUNDRED_PERCENT = 10000;

    /**
     * @dev Function that performs some validation checks before trying to repay a loan
     *
     * @param _loanId - The id of the loan being repaid
     */
    function payBackChecks(uint32 _loanId, INftfiHub _hub) external view {
        checkLoanIdValidity(_loanId, _hub);
        // Sanity check that payBackLoan() and liquidateOverdueLoan() have never been called on this loanId.
        // Depending on how the rest of the code turns out, this check may be unnecessary.
        require(!IDirectLoanBase(address(this)).loanRepaidOrLiquidated(_loanId), "Loan already repaid/liquidated");

        // Fetch loan details from storage, but store them in memory for the sake of saving gas.
        (, , , , uint32 loanDuration, , , , uint64 loanStartTime, , ) = IDirectLoanBase(address(this)).loanIdToLoan(
            _loanId
        );

        // When a loan exceeds the loan term, it is expired. At this stage the Lender can call Liquidate Loan to resolve
        // the loan.
        require(block.timestamp <= (uint256(loanStartTime) + uint256(loanDuration)), "Loan is expired");
    }

    function checkLoanIdValidity(uint32 _loanId, INftfiHub _hub) public view {
        require(
            IDirectLoanCoordinator(_hub.getContract(IDirectLoanBase(address(this)).LOAN_COORDINATOR())).isValidLoanId(
                _loanId,
                address(this)
            ),
            "invalid loanId"
        );
    }

    /**
     * @dev Function that the partner is permitted and returns its shared percent.
     *
     * @param _revenueSharePartner - Partner's address
     *
     * @return The revenue share percent for the partner.
     */
    function getRevenueSharePercent(address _revenueSharePartner, INftfiHub _hub) external view returns (uint16) {
        // return soon if no partner is set to avoid a public call
        if (_revenueSharePartner == address(0)) {
            return 0;
        }

        uint16 revenueSharePercent = IPermittedPartners(_hub.getContract(ContractKeys.PERMITTED_PARTNERS))
        .getPartnerPermit(_revenueSharePartner);

        return revenueSharePercent;
    }

    /**
     * @dev Performs some validation checks before trying to renegotiate a loan.
     * Needed to avoid stack too deep.
     *
     * @param _loan - The main Loan Terms struct.
     * @param _loanId - The unique identifier for the loan to be renegotiated
     * @param _newLoanDuration - The new amount of time (measured in seconds) that can elapse before the lender can
     * liquidate the loan and seize the underlying collateral NFT.
     * @param _newMaximumRepaymentAmount - The new maximum amount of money that the borrower would be required to
     * retrieve their collateral, measured in the smallest units of the ERC20 currency used for the loan. The
     * borrower will always have to pay this amount to retrieve their collateral, regardless of whether they repay
     * early.
     * @param _lenderNonce - The nonce referred to here is not the same as an Ethereum account's nonce. We are
     * referring instead to nonces that are used by both the lender and the borrower when they are first signing
     * off-chain NFTfi orders. These nonces can be any uint256 value that the user has not previously used to sign an
     * off-chain order. Each nonce can be used at most once per user within NFTfi, regardless of whether they are the
     * lender or the borrower in that situation. This serves two purposes:
     * - First, it prevents replay attacks where an attacker would submit a user's off-chain order more than once.
     * - Second, it allows a user to cancel an off-chain order by calling NFTfi.cancelLoanCommitmentBeforeLoanHasBegun()
     , which marks the nonce as used and prevents any future loan from using the user's off-chain order that contains
     * that nonce.
     * @return Borrower and Lender addresses
     */
    function renegotiationChecks(
        LoanData.LoanTerms memory _loan,
        uint32 _loanId,
        uint32 _newLoanDuration,
        uint256 _newMaximumRepaymentAmount,
        uint256 _lenderNonce,
        INftfiHub _hub
    ) external view returns (address, address) {
        checkLoanIdValidity(_loanId, _hub);
        IDirectLoanCoordinator loanCoordinator = IDirectLoanCoordinator(
            _hub.getContract(IDirectLoanBase(address(this)).LOAN_COORDINATOR())
        );
        uint256 smartNftId = loanCoordinator.getLoanData(_loanId).smartNftId;

        address borrower;

        if (_loan.borrower != address(0)) {
            borrower = _loan.borrower;
        } else {
            borrower = IERC721(loanCoordinator.obligationReceiptToken()).ownerOf(smartNftId);
        }

        require(msg.sender == borrower, "Only borrower can initiate");
        require(block.timestamp <= (uint256(_loan.loanStartTime) + _newLoanDuration), "New duration already expired");
        require(
            uint256(_newLoanDuration) <= IDirectLoanBase(address(this)).maximumLoanDuration(),
            "New duration exceeds maximum loan duration"
        );
        require(!IDirectLoanBase(address(this)).loanRepaidOrLiquidated(_loanId), "Loan already repaid/liquidated");
        require(
            _newMaximumRepaymentAmount >= _loan.loanPrincipalAmount,
            "Negative interest rate loans are not allowed."
        );

        // Fetch current owner of loan promissory note.
        address lender = IERC721(loanCoordinator.promissoryNoteToken()).ownerOf(smartNftId);

        require(
            !IDirectLoanBase(address(this)).getWhetherNonceHasBeenUsedForUser(lender, _lenderNonce),
            "Lender nonce invalid"
        );

        return (borrower, lender);
    }

    /**
     * @dev Performs some validation checks over loan parameters when accepting a listing
     *
     */
    function bindingTermsSanityChecks(LoanData.ListingTerms memory _listingTerms, LoanData.Offer memory _offer)
        external
        pure
    {
        // offer vs listing validations
        require(_offer.loanERC20Denomination == _listingTerms.loanERC20Denomination, "Invalid loanERC20Denomination");
        require(
            _offer.loanPrincipalAmount >= _listingTerms.minLoanPrincipalAmount &&
                _offer.loanPrincipalAmount <= _listingTerms.maxLoanPrincipalAmount,
            "Invalid loanPrincipalAmount"
        );
        uint256 maxRepaymentLimit = _offer.loanPrincipalAmount +
            (_offer.loanPrincipalAmount * _listingTerms.maxInterestRateForDurationInBasisPoints) /
            HUNDRED_PERCENT;
        require(_offer.maximumRepaymentAmount <= maxRepaymentLimit, "maxInterestRateForDurationInBasisPoints violated");

        require(
            _offer.loanDuration >= _listingTerms.minLoanDuration &&
                _offer.loanDuration <= _listingTerms.maxLoanDuration,
            "Invalid loanDuration"
        );
    }

    /**
     * @notice A convenience function computing the revenue share taken from the admin fee to transferr to the permitted
     * partner.
     *
     * @param _adminFee - The quantity of ERC20 currency (measured in smalled units of that ERC20 currency) that is due
     * as an admin fee.
     * @param _revenueShareInBasisPoints - The percent (measured in basis points) of the admin fee amount that will be
     * taken as a revenue share for a the partner, at the moment the loan is begun.
     *
     * @return The quantity of ERC20 currency (measured in smalled units of that ERC20 currency) that should be sent to
     * the `revenueSharePartner`.
     */
    function computeRevenueShare(uint256 _adminFee, uint256 _revenueShareInBasisPoints)
        external
        pure
        returns (uint256)
    {
        return (_adminFee * _revenueShareInBasisPoints) / HUNDRED_PERCENT;
    }

    /**
     * @notice A convenience function computing the adminFee taken from a specified quantity of interest.
     *
     * @param _interestDue - The amount of interest due, measured in the smallest quantity of the ERC20 currency being
     * used to pay the interest.
     * @param _adminFeeInBasisPoints - The percent (measured in basis points) of the interest earned that will be taken
     * as a fee by the contract admins when the loan is repaid. The fee is stored in the loan struct to prevent an
     * attack where the contract admins could adjust the fee right before a loan is repaid, and take all of the interest
     * earned.
     *
     * @return The quantity of ERC20 currency (measured in smalled units of that ERC20 currency) that is due as an admin
     * fee.
     */
    function computeAdminFee(uint256 _interestDue, uint256 _adminFeeInBasisPoints) external pure returns (uint256) {
        return (_interestDue * _adminFeeInBasisPoints) / HUNDRED_PERCENT;
    }

    /**
     * @notice A convenience function computing the referral fee taken from the loan principal amount to transferr to
     * the referrer.
     *
     * @param _loanPrincipalAmount - The original sum of money transferred from lender to borrower at the beginning of
     * the loan, measured in loanERC20Denomination's smallest units.
     * @param _referralFeeInBasisPoints - The percent (measured in basis points) of the loan principal amount that will
     * be taken as a fee to pay to the referrer, 0 if the lender is not paying referral fee.
     * @param _referrer - The address of the referrer who found the lender matching the listing, Zero address to signal
     * that there is no referrer.
     *
     * @return The quantity of ERC20 currency (measured in smalled units of that ERC20 currency) that should be sent to
     * the referrer.
     */
    function computeReferralFee(
        uint256 _loanPrincipalAmount,
        uint256 _referralFeeInBasisPoints,
        address _referrer
    ) external pure returns (uint256) {
        if (_referralFeeInBasisPoints == 0 || _referrer == address(0)) {
            return 0;
        }
        return (_loanPrincipalAmount * _referralFeeInBasisPoints) / HUNDRED_PERCENT;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

/**
 * @title NftReceiver
 * @author NFTfi
 * @dev Base contract with capabilities for receiving ERC1155 and ERC721 tokens
 */
abstract contract NftReceiver is IERC1155Receiver, ERC721Holder {
    /**
     *  @dev Handles the receipt of a single ERC1155 token type. This function is called at the end of a
     * `safeTransferFrom` after the balance has been updated.
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if allowed
     */
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    /**
     *  @dev Handles the receipt of a multiple ERC1155 token types. This function is called at the end of a
     * `safeBatchTransferFrom` after the balances have been updated.
     *  @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if allowed
     */
    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external virtual override returns (bytes4) {
        revert("ERC1155 batch not supported");
    }

    /**
     * @dev Checks whether this contract implements the interface defined by `interfaceId`.
     * @param _interfaceId Id of the interface
     * @return true if this contract implements the interface
     */
    function supportsInterface(bytes4 _interfaceId) public view virtual override returns (bool) {
        return
            _interfaceId == type(IERC1155Receiver).interfaceId ||
            _interfaceId == type(IERC721Receiver).interfaceId ||
            _interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

import "../interfaces/IBundleBuilder.sol";
import "../loans/direct/loanTypes/LoanData.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

/**
 * @title  NFTfiSigningUtils
 * @author NFTfi
 * @notice Helper contract for NFTfi. This contract manages verifying signatures from off-chain NFTfi orders.
 * Based on the version of this same contract used on NFTfi V1
 */
library NFTfiSigningUtils {
    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    /**
     * @dev This function gets the current chain ID.
     */
    function getChainID() public view returns (uint256) {
        uint256 id;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            id := chainid()
        }
        return id;
    }

    /**
     * @notice This function is when the lender accepts a borrower's binding listing terms, to validate the lender's
     * signature that the borrower provided off-chain to verify that it did indeed made such listing.
     *
     * @param _listingTerms - The listing terms struct containing:
     * - loanERC20Denomination: The address of the ERC20 contract of the currency being used as principal/interest
     * for this loan.
     * - minLoanPrincipalAmount: The minumum sum of money transferred from lender to borrower at the beginning of
     * the loan, measured in loanERC20Denomination's smallest units.
     * - maxLoanPrincipalAmount: The  sum of money transferred from lender to borrower at the beginning of
     * the loan, measured in loanERC20Denomination's smallest units.
     * - maximumRepaymentAmount: The maximum amount of money that the borrower would be required to retrieve their
     * collateral, measured in the smallest units of the ERC20 currency used for the loan. The borrower will always have
     * to pay this amount to retrieve their collateral, regardless of whether they repay early.
     * - nftCollateralContract: The address of the ERC721 contract of the NFT collateral.
     * - nftCollateralId: The ID within the NFTCollateralContract for the NFT being used as collateral for this
     * loan. The NFT is stored within this contract during the duration of the loan.
     * - revenueSharePartner: The address of the partner that will receive the revenue share.
     * - minLoanDuration: The minumum amount of time (measured in seconds) that can elapse before the lender can
     * liquidate the loan and seize the underlying collateral NFT.
     * - maxLoanDuration: The maximum amount of time (measured in seconds) that can elapse before the lender can
     * liquidate the loan and seize the underlying collateral NFT.
     * - maxInterestRateForDurationInBasisPoints: This is maximum the interest rate (measured in basis points, e.g.
     * hundreths of a percent) for the loan, that must be repaid pro-rata by the borrower at the conclusion of the loan
     * or risk seizure of their nft collateral. Note if the type of the loan is fixed then this value  is not used and
     * is irrelevant so it should be set to 0.
     * - referralFeeInBasisPoints: The percent (measured in basis points) of the loan principal amount that will be
     * taken as a fee to pay to the referrer, 0 if the lender is not paying referral fee.
     * @param _signature - The offer struct containing:
     * - signer: The address of the signer. The borrower for `acceptOffer` the lender for `acceptListing`.
     * - nonce: The nonce referred here is not the same as an Ethereum account's nonce.
     * We are referring instead to a nonce that is used by the lender or the borrower when they are first signing
     * off-chain NFTfi orders. These nonce can be any uint256 value that the user has not previously used to sign an
     * off-chain order. Each nonce can be used at most once per user within NFTfi, regardless of whether they are the
     * lender or the borrower in that situation. This serves two purposes:
     *   - First, it prevents replay attacks where an attacker would submit a user's off-chain order more than once.
     *   - Second, it allows a user to cancel an off-chain order by calling
     * NFTfi.cancelLoanCommitmentBeforeLoanHasBegun(), which marks the nonce as used and prevents any future loan from
     * using the user's off-chain order that contains that nonce.
     * - expiry: Date when the signature expires
     * - signature: The ECDSA signature of the borrower, obtained off-chain ahead of time, signing the following
     * combination of parameters:
     *   - listingTerms.loanERC20Denomination,
     *   - listingTerms.minLoanPrincipalAmount,
     *   - listingTerms.maxLoanPrincipalAmount,
     *   - listingTerms.nftCollateralContract,
     *   - listingTerms.nftCollateralId,
     *   - listingTerms.revenueSharePartner,
     *   - listingTerms.minLoanDuration,
     *   - listingTerms.maxLoanDuration,
     *   - listingTerms.maxInterestRateForDurationInBasisPoints,
     *   - listingTerms.referralFeeInBasisPoints,
     *   - signature.signer,
     *   - signature.nonce,
     *   - signature.expiry,
     *   - address of this contract
     *   - chainId
     */
    function isValidBorrowerSignature(LoanData.ListingTerms memory _listingTerms, LoanData.Signature memory _signature)
        external
        view
        returns (bool)
    {
        return isValidBorrowerSignature(_listingTerms, _signature, address(this));
    }

    /**
     * @dev This function overload the previous function to allow the caller to specify the address of the contract
     *
     */
    function isValidBorrowerSignature(
        LoanData.ListingTerms memory _listingTerms,
        LoanData.Signature memory _signature,
        address _loanContract
    ) public view returns (bool) {
        require(block.timestamp <= _signature.expiry, "Borrower Signature has expired");
        require(_loanContract != address(0), "Loan is zero address");
        if (_signature.signer == address(0)) {
            return false;
        } else {
            bytes32 message = keccak256(
                abi.encodePacked(
                    getEncodedListing(_listingTerms),
                    getEncodedSignature(_signature),
                    _loanContract,
                    getChainID()
                )
            );

            return
                SignatureChecker.isValidSignatureNow(
                    _signature.signer,
                    ECDSA.toEthSignedMessageHash(message),
                    _signature.signature
                );
        }
    }

    /**
     * @notice This function is when the lender accepts a borrower's binding listing terms, to validate the lender's
     * signature that the borrower provided off-chain to verify that it did indeed made such listing.
     *
     * @param _listingTerms - The listing terms struct containing:
     * - loanERC20Denomination: The address of the ERC20 contract of the currency being used as principal/interest
     * for this loan.
     * - minLoanPrincipalAmount: The minumum sum of money transferred from lender to borrower at the beginning of
     * the loan, measured in loanERC20Denomination's smallest units.
     * - maxLoanPrincipalAmount: The  sum of money transferred from lender to borrower at the beginning of
     * the loan, measured in loanERC20Denomination's smallest units.
     * - maximumRepaymentAmount: The maximum amount of money that the borrower would be required to retrieve their
     * collateral, measured in the smallest units of the ERC20 currency used for the loan. The borrower will always have
     * to pay this amount to retrieve their collateral, regardless of whether they repay early.
     * - nftCollateralContract: The address of the ERC721 contract of the NFT collateral.
     * - nftCollateralId: The ID within the NFTCollateralContract for the NFT being used as collateral for this
     * loan. The NFT is stored within this contract during the duration of the loan.
     * - revenueSharePartner: The address of the partner that will receive the revenue share.
     * - minLoanDuration: The minumum amount of time (measured in seconds) that can elapse before the lender can
     * liquidate the loan and seize the underlying collateral NFT.
     * - maxLoanDuration: The maximum amount of time (measured in seconds) that can elapse before the lender can
     * liquidate the loan and seize the underlying collateral NFT.
     * - maxInterestRateForDurationInBasisPoints: This is maximum the interest rate (measured in basis points, e.g.
     * hundreths of a percent) for the loan, that must be repaid pro-rata by the borrower at the conclusion of the loan
     * or risk seizure of their nft collateral. Note if the type of the loan is fixed then this value  is not used and
     * is irrelevant so it should be set to 0.
     * - referralFeeInBasisPoints: The percent (measured in basis points) of the loan principal amount that will be
     * taken as a fee to pay to the referrer, 0 if the lender is not paying referral fee.
     * @param _bundleElements - the lists of erc721-20-1155 tokens that are to be bundled
     * @param _signature - The offer struct containing:
     * - signer: The address of the signer. The borrower for `acceptOffer` the lender for `acceptListing`.
     * - nonce: The nonce referred here is not the same as an Ethereum account's nonce.
     * We are referring instead to a nonce that is used by the lender or the borrower when they are first signing
     * off-chain NFTfi orders. These nonce can be any uint256 value that the user has not previously used to sign an
     * off-chain order. Each nonce can be used at most once per user within NFTfi, regardless of whether they are the
     * lender or the borrower in that situation. This serves two purposes:
     *   - First, it prevents replay attacks where an attacker would submit a user's off-chain order more than once.
     *   - Second, it allows a user to cancel an off-chain order by calling
     * NFTfi.cancelLoanCommitmentBeforeLoanHasBegun(), which marks the nonce as used and prevents any future loan from
     * using the user's off-chain order that contains that nonce.
     * - expiry: Date when the signature expires
     * - signature: The ECDSA signature of the borrower, obtained off-chain ahead of time, signing the following
     * combination of parameters:
     *   - listingTerms.loanERC20Denomination,
     *   - listingTerms.minLoanPrincipalAmount,
     *   - listingTerms.maxLoanPrincipalAmount,
     *   - listingTerms.nftCollateralContract,
     *   - listingTerms.nftCollateralId,
     *   - listingTerms.revenueSharePartner,
     *   - listingTerms.minLoanDuration,
     *   - listingTerms.maxLoanDuration,
     *   - listingTerms.maxInterestRateForDurationInBasisPoints,
     *   - listingTerms.referralFeeInBasisPoints,
     *   - bundleElements
     *   - signature.signer,
     *   - signature.nonce,
     *   - signature.expiry,
     *   - address of this contract
     *   - chainId
     */
    function isValidBorrowerSignatureBundle(
        LoanData.ListingTerms memory _listingTerms,
        IBundleBuilder.BundleElements memory _bundleElements,
        LoanData.Signature memory _signature
    ) external view returns (bool) {
        return isValidBorrowerSignatureBundle(_listingTerms, _bundleElements, _signature, address(this));
    }

    /**
     * @dev This function overload the previous function to allow the caller to specify the address of the contract
     *
     */
    function isValidBorrowerSignatureBundle(
        LoanData.ListingTerms memory _listingTerms,
        IBundleBuilder.BundleElements memory _bundleElements,
        LoanData.Signature memory _signature,
        address _loanContract
    ) public view returns (bool) {
        require(block.timestamp <= _signature.expiry, "Borrower Signature has expired");
        require(_loanContract != address(0), "Loan is zero address");
        if (_signature.signer == address(0)) {
            return false;
        } else {
            bytes32 message = keccak256(
                abi.encodePacked(
                    getEncodedListing(_listingTerms),
                    abi.encode(_bundleElements),
                    getEncodedSignature(_signature),
                    _loanContract,
                    getChainID()
                )
            );

            return
                SignatureChecker.isValidSignatureNow(
                    _signature.signer,
                    ECDSA.toEthSignedMessageHash(message),
                    _signature.signature
                );
        }
    }

    /**
     * @notice This function is when the borrower accepts a lender's offer, to validate the lender's signature that the
     * lender provided off-chain to verify that it did indeed made such offer.
     *
     * @param _offer - The offer struct containing:
     * - loanERC20Denomination: The address of the ERC20 contract of the currency being used as principal/interest
     * for this loan.
     * - loanPrincipalAmount: The original sum of money transferred from lender to borrower at the beginning of
     * the loan, measured in loanERC20Denomination's smallest units.
     * - maximumRepaymentAmount: The maximum amount of money that the borrower would be required to retrieve their
     * collateral, measured in the smallest units of the ERC20 currency used for the loan. The borrower will always have
     * to pay this amount to retrieve their collateral, regardless of whether they repay early.
     * - nftCollateralContract: The address of the ERC721 contract of the NFT collateral.
     * - nftCollateralId: The ID within the NFTCollateralContract for the NFT being used as collateral for this
     * loan. The NFT is stored within this contract during the duration of the loan.
     * - referrer: The address of the referrer who found the lender matching the listing, Zero address to signal
     * this there is no referrer.
     * - loanDuration: The amount of time (measured in seconds) that can elapse before the lender can liquidate the
     * loan and seize the underlying collateral NFT.
     * - loanInterestRateForDurationInBasisPoints: This is the interest rate (measured in basis points, e.g.
     * hundreths of a percent) for the loan, that must be repaid pro-rata by the borrower at the conclusion of the loan
     * or risk seizure of their nft collateral. Note if the type of the loan is fixed then this value  is not used and
     * is irrelevant so it should be set to 0.
     * - loanAdminFeeInBasisPoints: The percent (measured in basis points) of the interest earned that will be
     * taken as a fee by the contract admins when the loan is repaid. The fee is stored in the loan struct to prevent an
     * attack where the contract admins could adjust the fee right before a loan is repaid, and take all of the interest
     * earned.
     * @param _signature - The signature structure containing:
     * - signer: The address of the signer. The borrower for `acceptOffer` the lender for `acceptListing`.
     * - nonce: The nonce referred here is not the same as an Ethereum account's nonce.
     * We are referring instead to a nonce that is used by the lender or the borrower when they are first signing
     * off-chain NFTfi orders. These nonce can be any uint256 value that the user has not previously used to sign an
     * off-chain order. Each nonce can be used at most once per user within NFTfi, regardless of whether they are the
     * lender or the borrower in that situation. This serves two purposes:
     *   - First, it prevents replay attacks where an attacker would submit a user's off-chain order more than once.
     *   - Second, it allows a user to cancel an off-chain order by calling
     * NFTfi.cancelLoanCommitmentBeforeLoanHasBegun(), which marks the nonce as used and prevents any future loan from
     * using the user's off-chain order that contains that nonce.
     * - expiry: Date when the signature expires
     * - signature: The ECDSA signature of the lender, obtained off-chain ahead of time, signing the following
     * combination of parameters:
     *   - offer.loanERC20Denomination
     *   - offer.loanPrincipalAmount
     *   - offer.maximumRepaymentAmount
     *   - offer.nftCollateralContract
     *   - offer.nftCollateralId
     *   - offer.referrer
     *   - offer.loanDuration
     *   - offer.loanAdminFeeInBasisPoints
     *   - signature.signer,
     *   - signature.nonce,
     *   - signature.expiry,
     *   - address of this contract
     *   - chainId
     */
    function isValidLenderSignature(LoanData.Offer memory _offer, LoanData.Signature memory _signature)
        external
        view
        returns (bool)
    {
        return isValidLenderSignature(_offer, _signature, address(this));
    }

    /**
     * @dev This function overload the previous function to allow the caller to specify the address of the contract
     *
     */
    function isValidLenderSignature(
        LoanData.Offer memory _offer,
        LoanData.Signature memory _signature,
        address _loanContract
    ) public view returns (bool) {
        require(block.timestamp <= _signature.expiry, "Lender Signature has expired");
        require(_loanContract != address(0), "Loan is zero address");
        if (_signature.signer == address(0)) {
            return false;
        } else {
            bytes32 message = keccak256(
                abi.encodePacked(getEncodedOffer(_offer), getEncodedSignature(_signature), _loanContract, getChainID())
            );

            return
                SignatureChecker.isValidSignatureNow(
                    _signature.signer,
                    ECDSA.toEthSignedMessageHash(message),
                    _signature.signature
                );
        }
    }

    /**
     * @notice This function is when the borrower accepts a lender's offer, to validate the lender's signature that the
     * lender provided off-chain to verify that it did indeed made such offer.
     *
     * @param _offer - The offer struct containing:
     * - loanERC20Denomination: The address of the ERC20 contract of the currency being used as principal/interest
     * for this loan.
     * - loanPrincipalAmount: The original sum of money transferred from lender to borrower at the beginning of
     * the loan, measured in loanERC20Denomination's smallest units.
     * - maximumRepaymentAmount: The maximum amount of money that the borrower would be required to retrieve their
     * collateral, measured in the smallest units of the ERC20 currency used for the loan. The borrower will always have
     * to pay this amount to retrieve their collateral, regardless of whether they repay early.
     * - nftCollateralContract: The address of the ERC721 contract of the NFT collateral.
     * - nftCollateralId: The ID within the NFTCollateralContract for the NFT being used as collateral for this
     * loan. The NFT is stored within this contract during the duration of the loan.
     * - referrer: The address of the referrer who found the lender matching the listing, Zero address to signal
     * this there is no referrer.
     * - loanDuration: The amount of time (measured in seconds) that can elapse before the lender can liquidate the
     * loan and seize the underlying collateral NFT.
     * - loanInterestRateForDurationInBasisPoints: This is the interest rate (measured in basis points, e.g.
     * hundreths of a percent) for the loan, that must be repaid pro-rata by the borrower at the conclusion of the loan
     * or risk seizure of their nft collateral. Note if the type of the loan is fixed then this value  is not used and
     * is irrelevant so it should be set to 0.
     * - loanAdminFeeInBasisPoints: The percent (measured in basis points) of the interest earned that will be
     * taken as a fee by the contract admins when the loan is repaid. The fee is stored in the loan struct to prevent an
     * attack where the contract admins could adjust the fee right before a loan is repaid, and take all of the interest
     * earned.
     * @param _bundleElements - the lists of erc721-20-1155 tokens that are to be bundled
     * @param _signature - The signature structure containing:
     * - signer: The address of the signer. The borrower for `acceptOffer` the lender for `acceptListing`.
     * - nonce: The nonce referred here is not the same as an Ethereum account's nonce.
     * We are referring instead to a nonce that is used by the lender or the borrower when they are first signing
     * off-chain NFTfi orders. These nonce can be any uint256 value that the user has not previously used to sign an
     * off-chain order. Each nonce can be used at most once per user within NFTfi, regardless of whether they are the
     * lender or the borrower in that situation. This serves two purposes:
     *   - First, it prevents replay attacks where an attacker would submit a user's off-chain order more than once.
     *   - Second, it allows a user to cancel an off-chain order by calling
     * NFTfi.cancelLoanCommitmentBeforeLoanHasBegun(), which marks the nonce as used and prevents any future loan from
     * using the user's off-chain order that contains that nonce.
     * - expiry: Date when the signature expires
     * - signature: The ECDSA signature of the lender, obtained off-chain ahead of time, signing the following
     * combination of parameters:
     *   - offer.loanERC20Denomination
     *   - offer.loanPrincipalAmount
     *   - offer.maximumRepaymentAmount
     *   - offer.nftCollateralContract
     *   - offer.nftCollateralId
     *   - offer.referrer
     *   - offer.loanDuration
     *   - offer.loanAdminFeeInBasisPoints
     *   - bundleElements
     *   - signature.signer,
     *   - signature.nonce,
     *   - signature.expiry,
     *   - address of this contract
     *   - chainId
     */
    function isValidLenderSignatureBundle(
        LoanData.Offer memory _offer,
        IBundleBuilder.BundleElements memory _bundleElements,
        LoanData.Signature memory _signature
    ) external view returns (bool) {
        return isValidLenderSignatureBundle(_offer, _bundleElements, _signature, address(this));
    }

    /**
     * @dev This function overload the previous function to allow the caller to specify the address of the contract
     *
     */
    function isValidLenderSignatureBundle(
        LoanData.Offer memory _offer,
        IBundleBuilder.BundleElements memory _bundleElements,
        LoanData.Signature memory _signature,
        address _loanContract
    ) public view returns (bool) {
        require(block.timestamp <= _signature.expiry, "Lender Signature has expired");
        require(_loanContract != address(0), "Loan is zero address");
        if (_signature.signer == address(0)) {
            return false;
        } else {
            bytes32 message = keccak256(
                abi.encodePacked(
                    getEncodedOffer(_offer),
                    abi.encode(_bundleElements),
                    getEncodedSignature(_signature),
                    _loanContract,
                    getChainID()
                )
            );

            return
                SignatureChecker.isValidSignatureNow(
                    _signature.signer,
                    ECDSA.toEthSignedMessageHash(message),
                    _signature.signature
                );
        }
    }

    /**
     * @notice This function is called in renegotiateLoan() to validate the lender's signature that the lender provided
     * off-chain to verify that they did indeed want to agree to this loan renegotiation according to these terms.
     *
     * @param _loanId - The unique identifier for the loan to be renegotiated
     * @param _newLoanDuration - The new amount of time (measured in seconds) that can elapse before the lender can
     * liquidate the loan and seize the underlying collateral NFT.
     * @param _newMaximumRepaymentAmount - The new maximum amount of money that the borrower would be required to
     * retrieve their collateral, measured in the smallest units of the ERC20 currency used for the loan. The
     * borrower will always have to pay this amount to retrieve their collateral, regardless of whether they repay
     * early.
     * @param _renegotiationFee Agreed upon fee in ether that borrower pays for the lender for the renegitiation
     * @param _signature - The signature structure containing:
     * - signer: The address of the signer. The borrower for `acceptOffer` the lender for `acceptListing`.
     * - nonce: The nonce referred here is not the same as an Ethereum account's nonce.
     * We are referring instead to a nonce that is used by the lender or the borrower when they are first signing
     * off-chain NFTfi orders. These nonce can be any uint256 value that the user has not previously used to sign an
     * off-chain order. Each nonce can be used at most once per user within NFTfi, regardless of whether they are the
     * lender or the borrower in that situation. This serves two purposes:
     * - First, it prevents replay attacks where an attacker would submit a user's off-chain order more than once.
     * - Second, it allows a user to cancel an off-chain order by calling NFTfi.cancelLoanCommitmentBeforeLoanHasBegun()
     * , which marks the nonce as used and prevents any future loan from using the user's off-chain order that contains
     * that nonce.
     * - expiry - The date when the renegotiation offer expires
     * - lenderSignature - The ECDSA signature of the lender, obtained off-chain ahead of time, signing the
     * following combination of parameters:
     * - _loanId
     * - _newLoanDuration
     * - _newMaximumRepaymentAmount
     * - _lender
     * - _lenderNonce
     * - _expiry
     * - address of this contract
     * - chainId
     */
    function isValidLenderRenegotiationSignature(
        uint256 _loanId,
        uint32 _newLoanDuration,
        uint256 _newMaximumRepaymentAmount,
        uint256 _renegotiationFee,
        LoanData.Signature memory _signature
    ) external view returns (bool) {
        return
            isValidLenderRenegotiationSignature(
                _loanId,
                _newLoanDuration,
                _newMaximumRepaymentAmount,
                _renegotiationFee,
                _signature,
                address(this)
            );
    }

    /**
     * @dev This function overload the previous function to allow the caller to specify the address of the contract
     *
     */
    function isValidLenderRenegotiationSignature(
        uint256 _loanId,
        uint32 _newLoanDuration,
        uint256 _newMaximumRepaymentAmount,
        uint256 _renegotiationFee,
        LoanData.Signature memory _signature,
        address _loanContract
    ) public view returns (bool) {
        require(block.timestamp <= _signature.expiry, "Renegotiation Signature has expired");
        require(_loanContract != address(0), "Loan is zero address");
        if (_signature.signer == address(0)) {
            return false;
        } else {
            bytes32 message = keccak256(
                abi.encodePacked(
                    _loanId,
                    _newLoanDuration,
                    _newMaximumRepaymentAmount,
                    _renegotiationFee,
                    getEncodedSignature(_signature),
                    _loanContract,
                    getChainID()
                )
            );

            return
                SignatureChecker.isValidSignatureNow(
                    _signature.signer,
                    ECDSA.toEthSignedMessageHash(message),
                    _signature.signature
                );
        }
    }

    /**
     * @dev We need this to avoid stack too deep errors.
     */
    function getEncodedListing(LoanData.ListingTerms memory _listingTerms) internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                _listingTerms.loanERC20Denomination,
                _listingTerms.minLoanPrincipalAmount,
                _listingTerms.maxLoanPrincipalAmount,
                _listingTerms.nftCollateralContract,
                _listingTerms.nftCollateralId,
                _listingTerms.revenueSharePartner,
                _listingTerms.minLoanDuration,
                _listingTerms.maxLoanDuration,
                _listingTerms.maxInterestRateForDurationInBasisPoints,
                _listingTerms.referralFeeInBasisPoints
            );
    }

    /**
     * @dev We need this to avoid stack too deep errors.
     */
    function getEncodedOffer(LoanData.Offer memory _offer) internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                _offer.loanERC20Denomination,
                _offer.loanPrincipalAmount,
                _offer.maximumRepaymentAmount,
                _offer.nftCollateralContract,
                _offer.nftCollateralId,
                _offer.referrer,
                _offer.loanDuration,
                _offer.loanAdminFeeInBasisPoints
            );
    }

    /**
     * @dev We need this to avoid stack too deep errors.
     */
    function getEncodedSignature(LoanData.Signature memory _signature) internal pure returns (bytes memory) {
        return abi.encodePacked(_signature.signer, _signature.nonce, _signature.expiry);
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

interface IBundleBuilder {
    /**
     * @notice data of a erc721 bundle element
     *
     * @param tokenContract - address of the token contract
     * @param id - id of the token
     * @param safeTransferable - wether the implementing token contract has a safeTransfer function or not
     */
    struct BundleElementERC721 {
        address tokenContract;
        uint256 id;
        bool safeTransferable;
    }

    /**
     * @notice data of a erc20 bundle element
     *
     * @param tokenContract - address of the token contract
     * @param amount - amount of the token
     */
    struct BundleElementERC20 {
        address tokenContract;
        uint256 amount;
    }

    /**
     * @notice data of a erc20 bundle element
     *
     * @param tokenContract - address of the token contract
     * @param ids - list of ids of the tokens
     * @param amounts - list amounts of the tokens
     */
    struct BundleElementERC1155 {
        address tokenContract;
        uint256[] ids;
        uint256[] amounts;
    }

    /**
     * @notice the lists of erc721-20-1155 tokens that are to be bundled
     *
     * @param erc721s list of erc721 tokens
     * @param erc20s list of erc20 tokens
     * @param erc1155s list of erc1155 tokens
     */
    struct BundleElements {
        BundleElementERC721[] erc721s;
        BundleElementERC20[] erc20s;
        BundleElementERC1155[] erc1155s;
    }

    /**
     * @notice used by the loan contract to build a bundle from the BundleElements struct at the beginning of a loan,
     * returns the id of the created bundle
     *
     * @param _bundleElements - the lists of erc721-20-1155 tokens that are to be bundled
     * @param _sender sender of the tokens in the bundle - the borrower
     * @param _receiver receiver of the created bundle, normally the loan contract
     */
    function buildBundle(
        BundleElements memory _bundleElements,
        address _sender,
        address _receiver
    ) external returns (uint256);

    /**
     * @notice Remove all the children from the bundle
     * @dev This method may run out of gas if the list of children is too big. In that case, children can be removed
     *      individually.
     * @param _tokenId the id of the bundle
     * @param _receiver address of the receiver of the children
     */
    function decomposeBundle(uint256 _tokenId, address _receiver) external;
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

import "./DirectLoanBaseMinimal.sol";
import "../../../utils/ContractKeys.sol";

/**
 * @title  DirectLoanFixed
 * @author NFTfi
 * @notice Main contract for NFTfi Direct Loans Fixed Type. This contract manages the ability to create NFT-backed
 * peer-to-peer loans of type Fixed (agreed to be a fixed-repayment loan) where the borrower pays the
 * maximumRepaymentAmount regardless of whether they repay early or not.
 *
 * There are two ways to commence an NFT-backed loan:
 *
 * a. The borrower accepts a lender's offer by calling `acceptOffer`.
 *   1. the borrower calls nftContract.approveAll(NFTfi), approving the NFTfi contract to move their NFT's on their
 * be1alf.
 *   2. the lender calls erc20Contract.approve(NFTfi), allowing NFTfi to move the lender's ERC20 tokens on their
 * behalf.
 *   3. the lender signs an off-chain message, proposing its offer terms.
 *   4. the borrower calls `acceptOffer` to accept these terms and enter into the loan. The NFT is stored in
 * the contract, the borrower receives the loan principal in the specified ERC20 currency, the lender receives an
 * NFTfi promissory note (in ERC721 form) that represents the rights to either the principal-plus-interest, or the
 * underlying NFT collateral if the borrower does not pay back in time, and the borrower receives obligation receipt
 * (in ERC721 form) that gives them the right to pay back the loan and get the collateral back.
 *
 * b. The lender accepts a borrowe's binding terms by calling `acceptListing`.
 *   1. the borrower calls nftContract.approveAll(NFTfi), approving the NFTfi contract to move their NFT's on their
 * be1alf.
 *   2. the lender calls erc20Contract.approve(NFTfi), allowing NFTfi to move the lender's ERC20 tokens on their
 * behalf.
 *   3. the borrower signs an off-chain message, proposing its binding terms.
 *   4. the lender calls `acceptListing` with an offer matching the binding terms and enter into the loan. The NFT is
 * stored in the contract, the borrower receives the loan principal in the specified ERC20 currency, the lender
 * receives an NFTfi promissory note (in ERC721 form) that represents the rights to either the principal-plus-interest,
 * or the underlying NFT collateral if the borrower does not pay back in time, and the borrower receives obligation
 * receipt (in ERC721 form) that gives them the right to pay back the loan and get the collateral back.
 *
 * The lender can freely transfer and trade this ERC721 promissory note as they wish, with the knowledge that
 * transferring the ERC721 promissory note tranfsers the rights to principal-plus-interest and/or collateral, and that
 * they will no longer have a claim on the loan. The ERC721 promissory note itself represents that claim.
 *
 * The borrower can freely transfer and trade this ERC721 obligaiton receipt as they wish, with the knowledge that
 * transferring the ERC721 obligaiton receipt tranfsers the rights right to pay back the loan and get the collateral
 * back.
 *
 *
 * A loan may end in one of two ways:
 * - First, a borrower may call NFTfi.payBackLoan() and pay back the loan plus interest at any time, in which case they
 * receive their NFT back in the same transaction.
 * - Second, if the loan's duration has passed and the loan has not been paid back yet, a lender can call
 * NFTfi.liquidateOverdueLoan(), in which case they receive the underlying NFT collateral and forfeit the rights to the
 * principal-plus-interest, which the borrower now keeps.
 */
contract DirectLoanFixedOffer is DirectLoanBaseMinimal {
    /* ********** */
    /* DATA TYPES */
    /* ********** */

    bytes32 public constant LOAN_TYPE = bytes32("DIRECT_LOAN_FIXED_OFFER");

    /* *********** */
    /* CONSTRUCTOR */
    /* *********** */

    /**
     * @dev Sets `hub` and permitted erc20-s
     *
     * @param _admin - Initial admin of this contract.
     * @param  _nftfiHub - NFTfiHub address
     * @param  _permittedErc20s - list of permitted ERC20 token contract addresses
     */
    constructor(
        address _admin,
        address _nftfiHub,
        address[] memory _permittedErc20s
    )
        DirectLoanBaseMinimal(
            _admin,
            _nftfiHub,
            ContractKeys.getIdFromStringKey("DIRECT_LOAN_COORDINATOR"),
            _permittedErc20s
        )
    {
        // solhint-disable-previous-line no-empty-blocks
    }

    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    /**
     * @notice This function is called by the borrower when accepting a lender's offer to begin a loan.
     *
     * @param _offer - The offer made by the lender.
     * @param _signature - The components of the lender's signature.
     * @param _borrowerSettings - Some extra parameters that the borrower needs to set when accepting an offer.
     */
    function acceptOffer(
        Offer memory _offer,
        Signature memory _signature,
        BorrowerSettings memory _borrowerSettings
    ) external whenNotPaused nonReentrant {
        address nftWrapper = _getWrapper(_offer.nftCollateralContract);
        _loanSanityChecks(_offer, nftWrapper);
        _loanSanityChecksOffer(_offer);
        _acceptOffer(
            LOAN_TYPE,
            _setupLoanTerms(_offer, nftWrapper),
            _setupLoanExtras(_borrowerSettings.revenueSharePartner, _borrowerSettings.referralFeeInBasisPoints),
            _offer,
            _signature
        );
    }

    /* ******************* */
    /* READ-ONLY FUNCTIONS */
    /* ******************* */

    /**
     * @notice This function can be used to view the current quantity of the ERC20 currency used in the specified loan
     * required by the borrower to repay their loan, measured in the smallest unit of the ERC20 currency.
     *
     * @param _loanId  A unique identifier for this particular loan, sourced from the Loan Coordinator.
     *
     * @return The amount of the specified ERC20 currency required to pay back this loan, measured in the smallest unit
     * of the specified ERC20 currency.
     */
    function getPayoffAmount(uint32 _loanId) external view override returns (uint256) {
        LoanTerms storage loan = loanIdToLoan[_loanId];
        return loan.maximumRepaymentAmount;
    }

    /* ****************** */
    /* INTERNAL FUNCTIONS */
    /* ****************** */

    /**
     * @notice This function is called by the borrower when accepting a lender's offer to begin a loan.
     *
     * @param _loanType - The loan type being created.
     * @param _loanTerms - The main Loan Terms struct. This data is saved upon loan creation on loanIdToLoan.
     * @param _loanExtras - The main Loan Terms struct. This data is saved upon loan creation on loanIdToLoanExtras.
     * @param _offer - The offer made by the lender.
     * @param _signature - The components of the lender's signature.
     */
    function _acceptOffer(
        bytes32 _loanType,
        LoanTerms memory _loanTerms,
        LoanExtras memory _loanExtras,
        Offer memory _offer,
        Signature memory _signature
    ) internal {
        // Check loan nonces. These are different from Ethereum account nonces.
        // Here, these are uint256 numbers that should uniquely identify
        // each signature for each user (i.e. each user should only create one
        // off-chain signature for each nonce, with a nonce being any arbitrary
        // uint256 value that they have not used yet for an off-chain NFTfi
        // signature).
        require(!_nonceHasBeenUsedForUser[_signature.signer][_signature.nonce], "Lender nonce invalid");

        _nonceHasBeenUsedForUser[_signature.signer][_signature.nonce] = true;

        require(NFTfiSigningUtils.isValidLenderSignature(_offer, _signature), "Lender signature is invalid");

        address bundle = hub.getContract(ContractKeys.NFTFI_BUNDLER);
        require(_loanTerms.nftCollateralContract != bundle, "Collateral cannot be bundle");

        uint32 loanId = _createLoan(_loanType, _loanTerms, _loanExtras, msg.sender, _signature.signer, _offer.referrer);

        // Emit an event with all relevant details from this transaction.
        emit LoanStarted(loanId, msg.sender, _signature.signer, _loanTerms, _loanExtras);
    }

    /**
     * @dev Creates a `LoanTerms` struct using data sent as the lender's `_offer` on `acceptOffer`.
     * This is needed in order to avoid stack too deep issues.
     * Since this is a Fixed loan type loanInterestRateForDurationInBasisPoints is ignored.
     */
    function _setupLoanTerms(Offer memory _offer, address _nftWrapper) internal view returns (LoanTerms memory) {
        return
            LoanTerms({
                loanERC20Denomination: _offer.loanERC20Denomination,
                loanPrincipalAmount: _offer.loanPrincipalAmount,
                maximumRepaymentAmount: _offer.maximumRepaymentAmount,
                nftCollateralContract: _offer.nftCollateralContract,
                nftCollateralWrapper: _nftWrapper,
                nftCollateralId: _offer.nftCollateralId,
                loanStartTime: uint64(block.timestamp),
                loanDuration: _offer.loanDuration,
                loanInterestRateForDurationInBasisPoints: uint16(0),
                loanAdminFeeInBasisPoints: _offer.loanAdminFeeInBasisPoints,
                borrower: msg.sender
            });
    }

    /**
     * @dev Calculates the payoff amount and admin fee
     *
     * @param _loanTerms - Struct containing all the loan's parameters
     */
    function _payoffAndFee(LoanTerms memory _loanTerms)
        internal
        pure
        override
        returns (uint256 adminFee, uint256 payoffAmount)
    {
        // Calculate amounts to send to lender and admins
        uint256 interestDue = _loanTerms.maximumRepaymentAmount - _loanTerms.loanPrincipalAmount;
        adminFee = LoanChecksAndCalculations.computeAdminFee(
            interestDue,
            uint256(_loanTerms.loanAdminFeeInBasisPoints)
        );
        payoffAmount = _loanTerms.maximumRepaymentAmount - adminFee;
    }

    /**
     * @dev Function that performs some validation checks over loan parameters when accepting an offer
     *
     */
    function _loanSanityChecksOffer(LoanData.Offer memory _offer) internal pure {
        require(
            _offer.maximumRepaymentAmount >= _offer.loanPrincipalAmount,
            "Negative interest rate loans are not allowed."
        );
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

import "./ERC9981155Extension.sol";
import "./ERC998ERC20Extension.sol";
import "../utils/ContractKeys.sol";
import "../interfaces/IBundleBuilder.sol";
import "../interfaces/INftfiBundler.sol";
import "../interfaces/INftfiHub.sol";
import "../interfaces/IPermittedNFTs.sol";
import "../interfaces/IPermittedERC20s.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title NftfiBundler
 * @author NFTfi
 * @dev ERC998 Top-Down Composable Non-Fungible Token that supports permitted ERC721, ERC1155 and ERC20 children.
 */
contract NftfiBundler is IBundleBuilder, ERC9981155Extension, ERC998ERC20Extension {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    INftfiHub public immutable hub;

    event NewBundle(uint256 bundleId, address indexed sender, address indexed receiver);

    /**
     * @dev Stores the NftfiHub, name and symbol
     *
     * @param _nftfiHub Address of the NftfiHub contract
     * @param _name name of the token contract
     * @param _symbol symbol of the token contract
     */
    constructor(
        address _nftfiHub,
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        hub = INftfiHub(_nftfiHub);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 _interfaceId)
        public
        view
        virtual
        override(ERC9981155Extension, ERC998ERC20Extension)
        returns (bool)
    {
        return
            _interfaceId == type(IERC721Receiver).interfaceId ||
            _interfaceId == type(INftfiBundler).interfaceId ||
            super.supportsInterface(_interfaceId);
    }

    /**
     * @notice Tells if an asset is permitted or not
     * @param _asset address of the asset
     * @return true if permitted, false otherwise
     */
    function permittedAsset(address _asset) public view returns (bool) {
        IPermittedNFTs permittedNFTs = IPermittedNFTs(hub.getContract(ContractKeys.PERMITTED_NFTS));
        return permittedNFTs.getNFTPermit(_asset) > 0;
    }

    /**
     * @notice Tells if the erc20 is permitted or not
     * @param _erc20Contract address of the erc20
     * @return true if permitted, false otherwise
     */
    function permittedErc20Asset(address _erc20Contract) public view returns (bool) {
        IPermittedERC20s permittedERC20s = IPermittedERC20s(hub.getContract(ContractKeys.PERMITTED_BUNDLE_ERC20S));
        return permittedERC20s.getERC20Permit(_erc20Contract);
    }

    /**
     * @dev used by the loan contract to build a bundle from the BundleElements struct at the beginning of a loan,
     * returns the id of the created bundle
     *
     * @param _bundleElements - the lists of erc721-20-1155 tokens that are to be bundled
     * @param _sender sender of the tokens in the bundle - the borrower
     * @param _receiver receiver of the created bundle, normally the loan contract
     */
    function buildBundle(
        BundleElements memory _bundleElements,
        address _sender,
        address _receiver
    ) external override returns (uint256) {
        uint256 bundleId = _safeMint(_receiver);
        require(
            _bundleElements.erc721s.length > 0 ||
                _bundleElements.erc20s.length > 0 ||
                _bundleElements.erc1155s.length > 0,
            "bundle is empty"
        );
        for (uint256 i = 0; i < _bundleElements.erc721s.length; i++) {
            if (_bundleElements.erc721s[i].safeTransferable) {
                IERC721(_bundleElements.erc721s[i].tokenContract).safeTransferFrom(
                    _sender,
                    address(this),
                    _bundleElements.erc721s[i].id,
                    abi.encodePacked(bundleId)
                );
            } else {
                _getChild(_sender, bundleId, _bundleElements.erc721s[i].tokenContract, _bundleElements.erc721s[i].id);
            }
        }

        for (uint256 i = 0; i < _bundleElements.erc20s.length; i++) {
            _getERC20(_sender, bundleId, _bundleElements.erc20s[i].tokenContract, _bundleElements.erc20s[i].amount);
        }

        for (uint256 i = 0; i < _bundleElements.erc1155s.length; i++) {
            IERC1155(_bundleElements.erc1155s[i].tokenContract).safeBatchTransferFrom(
                _sender,
                address(this),
                _bundleElements.erc1155s[i].ids,
                _bundleElements.erc1155s[i].amounts,
                abi.encodePacked(bundleId)
            );
        }

        emit NewBundle(bundleId, _sender, _receiver);
        return bundleId;
    }

    /**
     * @notice Remove all the children from the bundle
     * @dev This method may run out of gas if the list of children is too big. In that case, children can be removed
     *      individually.
     * @param _tokenId the id of the bundle
     * @param _receiver address of the receiver of the children
     */
    function decomposeBundle(uint256 _tokenId, address _receiver) external override nonReentrant {
        require(ownerOf(_tokenId) == msg.sender, "caller is not owner");
        _validateReceiver(_receiver);

        // In each iteration all contracts children are removed, so eventually all contracts are removed
        while (childContracts[_tokenId].length() > 0) {
            address childContract = childContracts[_tokenId].at(0);

            // In each iteration a child is removed, so eventually all contracts children are removed
            while (childTokens[_tokenId][childContract].length() > 0) {
                uint256 childId = childTokens[_tokenId][childContract].at(0);

                uint256 balance = balances[_tokenId][childContract][childId];

                if (balance > 0) {
                    _remove1155Child(_tokenId, childContract, childId, balance);
                    IERC1155(childContract).safeTransferFrom(address(this), _receiver, childId, balance, "");
                    emit Transfer1155Child(_tokenId, _receiver, childContract, childId, balance);
                } else {
                    _removeChild(_tokenId, childContract, childId);

                    try IERC721(childContract).safeTransferFrom(address(this), _receiver, childId) {
                        // solhint-disable-previous-line no-empty-blocks
                    } catch {
                        _oldNFTsTransfer(_receiver, childContract, childId);
                    }
                    emit TransferChild(_tokenId, _receiver, childContract, childId);
                }
            }
        }

        // In each iteration all contracts children are removed, so eventually all contracts are removed
        while (erc20ChildContracts[_tokenId].length() > 0) {
            address erc20Contract = erc20ChildContracts[_tokenId].at(0);
            uint256 balance = erc20Balances[_tokenId][erc20Contract];

            _removeERC20(_tokenId, erc20Contract, balance);
            IERC20(erc20Contract).safeTransfer(_receiver, balance);
            emit TransferERC20(_tokenId, _receiver, erc20Contract, balance);
        }
    }

    /**
     * @dev Update the state to receive a ERC721 child
     * Overrides the implementation to check if the asset is permitted
     * @param _from The owner of the child token
     * @param _tokenId The token receiving the child
     * @param _childContract The ERC721 contract of the child token
     * @param _childTokenId The token that is being transferred to the parent
     */
    function _receiveChild(
        address _from,
        uint256 _tokenId,
        address _childContract,
        uint256 _childTokenId
    ) internal virtual override {
        require(permittedAsset(_childContract), "erc721 not permitted");
        super._receiveChild(_from, _tokenId, _childContract, _childTokenId);
    }

    /**
     * @dev Updates the state to receive a ERC1155 child
     * Overrides the implementation to check if the asset is permitted
     * @param _tokenId The token receiving the child
     * @param _childContract The ERC1155 contract of the child token
     * @param _childTokenId The token id that is being transferred to the parent
     * @param _amount The amount of the token that is being transferred
     */
    function _receive1155Child(
        uint256 _tokenId,
        address _childContract,
        uint256 _childTokenId,
        uint256 _amount
    ) internal virtual override {
        require(permittedAsset(_childContract), "erc1155 not permitted");
        super._receive1155Child(_tokenId, _childContract, _childTokenId, _amount);
    }

    /**
     * @notice Store data for the received ERC20
     * @param _from The current owner address of the ERC20 tokens that are being transferred.
     * @param _tokenId The token to transfer the ERC20 tokens to.
     * @param _erc20Contract The ERC20 token contract
     * @param _value The number of ERC20 tokens to transfer
     */
    function _receiveErc20Child(
        address _from,
        uint256 _tokenId,
        address _erc20Contract,
        uint256 _value
    ) internal virtual override {
        require(permittedErc20Asset(_erc20Contract), "erc20 not permitted");
        super._receiveErc20Child(_from, _tokenId, _erc20Contract, _value);
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./ERC998TopDown.sol";
import "../interfaces/IERC998ERC1155TopDown.sol";

/**
 * @title ERC9981155Extension
 * @author NFTfi
 * @dev ERC998TopDown extension to support ERC1155 children
 */
abstract contract ERC9981155Extension is ERC998TopDown, IERC998ERC1155TopDown, IERC1155Receiver {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    // tokenId => (child address => (child tokenId => balance))
    mapping(uint256 => mapping(address => mapping(uint256 => uint256))) internal balances;

    /**
     * @dev Gives child balance for a specific child contract and child id
     * @param _childContract The ERC1155 contract of the child token
     * @param _childTokenId The tokenId of the child token
     */
    function childBalance(
        uint256 _tokenId,
        address _childContract,
        uint256 _childTokenId
    ) external view override returns (uint256) {
        return balances[_tokenId][_childContract][_childTokenId];
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 _interfaceId)
        public
        view
        virtual
        override(ERC998TopDown, IERC165)
        returns (bool)
    {
        return
            _interfaceId == type(IERC998ERC1155TopDown).interfaceId ||
            _interfaceId == type(IERC1155Receiver).interfaceId ||
            super.supportsInterface(_interfaceId);
    }

    /**
     * @notice Transfer a ERC1155 child token from top-down composable to address or other top-down composable
     * @param _tokenId The owning token to transfer from
     * @param _to The address that receives the child token
     * @param _childContract The ERC1155 contract of the child token
     * @param _childTokenId The tokenId of the token that is being transferred
     * @param _amount The amount of the token that is being transferred
     * @param _data Additional data with no specified format
     */
    function safeTransferChild(
        uint256 _tokenId,
        address _to,
        address _childContract,
        uint256 _childTokenId,
        uint256 _amount,
        bytes memory _data
    ) external override nonReentrant {
        _validateReceiver(_to);
        _validate1155ChildTransfer(_tokenId);
        _remove1155Child(_tokenId, _childContract, _childTokenId, _amount);
        if (_to == address(this)) {
            _validateAndReceive1155Child(msg.sender, _childContract, _childTokenId, _amount, _data);
        } else {
            IERC1155(_childContract).safeTransferFrom(address(this), _to, _childTokenId, _amount, _data);
            emit Transfer1155Child(_tokenId, _to, _childContract, _childTokenId, _amount);
        }
    }

    /**
     * @notice Transfer batch of ERC1155 child token from top-down composable to address or other top-down composable
     * @param _tokenId The owning token to transfer from
     * @param _to The address that receives the child token
     * @param _childContract The ERC1155 contract of the child token
     * @param _childTokenIds The list of tokenId of the token that is being transferred
     * @param _amounts The list of amount of the token that is being transferred
     * @param _data Additional data with no specified format
     */
    function safeBatchTransferChild(
        uint256 _tokenId,
        address _to,
        address _childContract,
        uint256[] memory _childTokenIds,
        uint256[] memory _amounts,
        bytes memory _data
    ) external override nonReentrant {
        require(_childTokenIds.length == _amounts.length, "ids and amounts length mismatch");
        _validateReceiver(_to);

        _validate1155ChildTransfer(_tokenId);
        for (uint256 i = 0; i < _childTokenIds.length; ++i) {
            uint256 childTokenId = _childTokenIds[i];
            uint256 amount = _amounts[i];

            _remove1155Child(_tokenId, _childContract, childTokenId, amount);
            if (_to == address(this)) {
                _validateAndReceive1155Child(msg.sender, _childContract, childTokenId, amount, _data);
            }
        }

        if (_to != address(this)) {
            IERC1155(_childContract).safeBatchTransferFrom(address(this), _to, _childTokenIds, _amounts, _data);
            emit Transfer1155BatchChild(_tokenId, _to, _childContract, _childTokenIds, _amounts);
        }
    }

    /**
     * @notice A token receives a child token
     */
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) external virtual override returns (bytes4) {
        revert("external calls restricted");
    }

    /**
     * @notice A token receives a batch of child tokens
     * param The address that caused the transfer
     * @param _from The owner of the child token
     * @param _ids The list of token id that is being transferred to the parent
     * @param _values The list of amounts of the tokens that is being transferred
     * @param _data Up to the first 32 bytes contains an integer which is the receiving parent tokenId
     * @return the selector of this method
     */
    function onERC1155BatchReceived(
        address,
        address _from,
        uint256[] memory _ids,
        uint256[] memory _values,
        bytes memory _data
    ) external virtual override nonReentrant returns (bytes4) {
        require(_data.length == 32, "data must contain tokenId to transfer the child token to");
        uint256 _receiverTokenId = _parseTokenId(_data);

        for (uint256 i = 0; i < _ids.length; i++) {
            _receive1155Child(_receiverTokenId, msg.sender, _ids[i], _values[i]);
            emit Received1155Child(_from, _receiverTokenId, msg.sender, _ids[i], _values[i]);
        }
        return this.onERC1155BatchReceived.selector;
    }

    /**
     * @dev Validates the data of the child token and receives it
     * @param _from The owner of the child token
     * @param _childContract The ERC1155 contract of the child token
     * @param _id The token id that is being transferred to the parent
     * @param _amount The amount of the token that is being transferred
     * @param _data Up to the first 32 bytes contains an integer which is the receiving parent tokenId
     */
    function _validateAndReceive1155Child(
        address _from,
        address _childContract,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) internal virtual {
        require(_data.length == 32, "data must contain tokenId to transfer the child token to");

        uint256 _receiverTokenId = _parseTokenId(_data);
        _receive1155Child(_receiverTokenId, _childContract, _id, _amount);
        emit Received1155Child(_from, _receiverTokenId, _childContract, _id, _amount);
    }

    /**
     * @dev Updates the state to receive a child
     * @param _tokenId The token receiving the child
     * @param _childContract The ERC1155 contract of the child token
     * @param _childTokenId The token id that is being transferred to the parent
     * @param _amount The amount of the token that is being transferred
     */
    function _receive1155Child(
        uint256 _tokenId,
        address _childContract,
        uint256 _childTokenId,
        uint256 _amount
    ) internal virtual {
        require(_exists(_tokenId), "bundle tokenId does not exist");
        uint256 childTokensLength = childTokens[_tokenId][_childContract].length();
        if (childTokensLength == 0) {
            childContracts[_tokenId].add(_childContract);
        }
        childTokens[_tokenId][_childContract].add(_childTokenId);
        balances[_tokenId][_childContract][_childTokenId] += _amount;
    }

    /**
     * @notice Validates the transfer of a 1155 child
     * @param _fromTokenId The owning token to transfer from
     */
    function _validate1155ChildTransfer(uint256 _fromTokenId) internal virtual {
        _validateTransferSender(_fromTokenId);
    }

    /**
     * @notice Updates the state to remove a ERC1155 child
     * @param _tokenId The owning token to transfer from
     * @param _childContract The ERC1155 contract of the child token
     * @param _childTokenId The tokenId of the token that is being transferred
     * @param _amount The amount of the token that is being transferred
     */
    function _remove1155Child(
        uint256 _tokenId,
        address _childContract,
        uint256 _childTokenId,
        uint256 _amount
    ) internal virtual {
        require(
            _amount != 0 && balances[_tokenId][_childContract][_childTokenId] >= _amount,
            "insufficient child balance for transfer"
        );
        balances[_tokenId][_childContract][_childTokenId] -= _amount;

        if (balances[_tokenId][_childContract][_childTokenId] == 0) {
            // remove child token
            childTokens[_tokenId][_childContract].remove(_childTokenId);

            // remove contract
            if (childTokens[_tokenId][_childContract].length() == 0) {
                childContracts[_tokenId].remove(_childContract);
            }
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

import "./ERC998TopDown.sol";
import "../interfaces/IERC998ERC20TopDown.sol";
import "../interfaces/IERC998ERC20TopDownEnumerable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";

/**
 * @title ERC998ERC20Extension
 * @author NFTfi
 * @dev ERC998TopDown extension to support ERC20 children
 */
abstract contract ERC998ERC20Extension is ERC998TopDown, IERC998ERC20TopDown, IERC998ERC20TopDownEnumerable {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    // tokenId => ERC20 child contract
    mapping(uint256 => EnumerableSet.AddressSet) internal erc20ChildContracts;

    // tokenId => (token contract => balance)
    mapping(uint256 => mapping(address => uint256)) internal erc20Balances;

    /**
     * @dev Look up the balance of ERC20 tokens for a specific token and ERC20 contract
     * @param _tokenId The token that owns the ERC20 tokens
     * @param _erc20Contract The ERC20 contract
     * @return The number of ERC20 tokens owned by a token
     */
    function balanceOfERC20(uint256 _tokenId, address _erc20Contract) external view virtual override returns (uint256) {
        return erc20Balances[_tokenId][_erc20Contract];
    }

    /**
     * @notice Get ERC20 contract by tokenId and index
     * @param _tokenId The parent token of ERC20 tokens
     * @param _index The index position of the child contract
     * @return childContract The contract found at the tokenId and index
     */
    function erc20ContractByIndex(uint256 _tokenId, uint256 _index) external view virtual override returns (address) {
        return erc20ChildContracts[_tokenId].at(_index);
    }

    /**
     * @notice Get the total number of ERC20 tokens owned by tokenId
     * @param _tokenId The parent token of ERC20 tokens
     * @return uint256 The total number of ERC20 tokens
     */
    function totalERC20Contracts(uint256 _tokenId) external view virtual override returns (uint256) {
        return erc20ChildContracts[_tokenId].length();
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 _interfaceId) public view virtual override(ERC998TopDown) returns (bool) {
        return
            _interfaceId == type(IERC998ERC20TopDown).interfaceId ||
            _interfaceId == type(IERC998ERC20TopDownEnumerable).interfaceId ||
            super.supportsInterface(_interfaceId);
    }

    /**
     * @notice Transfer ERC20 tokens to address
     * @param _tokenId The token to transfer from
     * @param _to The address to send the ERC20 tokens to
     * @param _erc20Contract The ERC20 contract
     * @param _value The number of ERC20 tokens to transfer
     */
    function transferERC20(
        uint256 _tokenId,
        address _to,
        address _erc20Contract,
        uint256 _value
    ) external virtual override {
        _validateERC20Value(_value);
        _validateReceiver(_to);
        _validateERC20Transfer(_tokenId);
        _removeERC20(_tokenId, _erc20Contract, _value);

        IERC20(_erc20Contract).safeTransfer(_to, _value);
        emit TransferERC20(_tokenId, _to, _erc20Contract, _value);
    }

    /**
     * @notice Get ERC20 tokens from ERC20 contract.
     * @dev This contract has to be approved first by _erc20Contract
     */
    function getERC20(
        address,
        uint256,
        address,
        uint256
    ) external pure override {
        revert("external calls restricted");
    }

    /**
     * @notice NOT SUPPORTED
     * Intended to transfer ERC223 tokens. ERC223 tokens can be transferred as regular ERC20
     */
    function transferERC223(
        uint256,
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual override {
        revert("TRANSFER_ERC223_NOT_SUPPORTED");
    }

    /**
     * @notice NOT SUPPORTED
     * Intended to receive ERC223 tokens. ERC223 tokens can be deposited as regular ERC20
     */
    function tokenFallback(
        address,
        uint256,
        bytes calldata
    ) external virtual override {
        revert("TOKEN_FALLBACK_ERC223_NOT_SUPPORTED");
    }

    /**
     * @notice Get ERC20 tokens from ERC20 contract.
     * @dev This contract has to be approved first by _erc20Contract
     * @param _from The current owner address of the ERC20 tokens that are being transferred.
     * @param _tokenId The token to transfer the ERC20 tokens to.
     * @param _erc20Contract The ERC20 token contract
     * @param _value The number of ERC20 tokens to transfer
     */
    function _getERC20(
        address _from,
        uint256 _tokenId,
        address _erc20Contract,
        uint256 _value
    ) internal {
        _validateERC20Value(_value);
        _receiveErc20Child(_from, _tokenId, _erc20Contract, _value);
        IERC20(_erc20Contract).safeTransferFrom(_from, address(this), _value);
    }

    /**
     * @notice Validates the value of a ERC20 transfer
     * @param _value The number of ERC20 tokens to transfer
     */
    function _validateERC20Value(uint256 _value) internal virtual {
        require(_value > 0, "zero amount");
    }

    /**
     * @notice Validates the transfer of a ERC20
     * @param _fromTokenId The owning token to transfer from
     */
    function _validateERC20Transfer(uint256 _fromTokenId) internal virtual {
        _validateTransferSender(_fromTokenId);
    }

    /**
     * @notice Store data for the received ERC20
     * @param _from The current owner address of the ERC20 tokens that are being transferred.
     * @param _tokenId The token to transfer the ERC20 tokens to.
     * @param _erc20Contract The ERC20 token contract
     * @param _value The number of ERC20 tokens to transfer
     */
    function _receiveErc20Child(
        address _from,
        uint256 _tokenId,
        address _erc20Contract,
        uint256 _value
    ) internal virtual {
        require(_exists(_tokenId), "bundle tokenId does not exist");
        uint256 erc20Balance = erc20Balances[_tokenId][_erc20Contract];
        if (erc20Balance == 0) {
            erc20ChildContracts[_tokenId].add(_erc20Contract);
        }
        erc20Balances[_tokenId][_erc20Contract] += _value;
        emit ReceivedERC20(_from, _tokenId, _erc20Contract, _value);
    }

    /**
     * @notice Updates the state to remove ERC20 tokens
     * @param _tokenId The token to transfer from
     * @param _erc20Contract The ERC20 contract
     * @param _value The number of ERC20 tokens to transfer
     */
    function _removeERC20(
        uint256 _tokenId,
        address _erc20Contract,
        uint256 _value
    ) internal virtual {
        uint256 erc20Balance = erc20Balances[_tokenId][_erc20Contract];
        require(erc20Balance >= _value, "not enough token available to transfer");
        uint256 newERC20Balance = erc20Balance - _value;
        erc20Balances[_tokenId][_erc20Contract] = newERC20Balance;
        if (newERC20Balance == 0) {
            erc20ChildContracts[_tokenId].remove(_erc20Contract);
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./IERC998ERC721TopDown.sol";

interface INftfiBundler is IERC721 {
    function safeMint(address _to) external returns (uint256);

    function decomposeBundle(uint256 _tokenId, address _receiver) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../interfaces/IERC998ERC721TopDown.sol";
import "../interfaces/IERC998ERC721TopDownEnumerable.sol";

/**
 * @title ERC998TopDown
 * @author NFTfi
 * @dev ERC998ERC721 Top-Down Composable Non-Fungible Token.
 * See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-998.md
 * This implementation does not support children to be nested bundles, erc20 nor bottom-up
 */
abstract contract ERC998TopDown is
    ERC721Enumerable,
    IERC998ERC721TopDown,
    IERC998ERC721TopDownEnumerable,
    ReentrancyGuard
{
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    // return this.rootOwnerOf.selector ^ this.rootOwnerOfChild.selector ^
    //   this.tokenOwnerOf.selector ^ this.ownerOfChild.selector;
    bytes32 public constant ERC998_MAGIC_VALUE = 0xcd740db500000000000000000000000000000000000000000000000000000000;
    bytes32 internal constant ERC998_MAGIC_MASK = 0xffffffff00000000000000000000000000000000000000000000000000000000;

    uint256 public tokenCount = 0;

    // tokenId => child contract
    mapping(uint256 => EnumerableSet.AddressSet) internal childContracts;

    // tokenId => (child address => array of child tokens)
    mapping(uint256 => mapping(address => EnumerableSet.UintSet)) internal childTokens;

    // child address => childId => tokenId
    // this is used for ERC721 type tokens
    mapping(address => mapping(uint256 => uint256)) internal childTokenOwner;

    /**
     * @notice Tells whether the ERC721 type child exists or not
     * @param _childContract The contract address of the child token
     * @param _childTokenId The tokenId of the child
     * @return True if the child exists, false otherwise
     */
    function childExists(address _childContract, uint256 _childTokenId) external view virtual returns (bool) {
        uint256 tokenId = childTokenOwner[_childContract][_childTokenId];
        return tokenId != 0;
    }

    /**
     * @notice Get the total number of child contracts with tokens that are owned by _tokenId
     * @param _tokenId The parent token of child tokens in child contracts
     * @return uint256 The total number of child contracts with tokens owned by _tokenId
     */
    function totalChildContracts(uint256 _tokenId) external view virtual override returns (uint256) {
        return childContracts[_tokenId].length();
    }

    /**
     * @notice Get child contract by tokenId and index
     * @param _tokenId The parent token of child tokens in child contract
     * @param _index The index position of the child contract
     * @return childContract The contract found at the _tokenId and index
     */
    function childContractByIndex(uint256 _tokenId, uint256 _index)
        external
        view
        virtual
        override
        returns (address childContract)
    {
        return childContracts[_tokenId].at(_index);
    }

    /**
     * @notice Get the total number of child tokens owned by tokenId that exist in a child contract
     * @param _tokenId The parent token of child tokens
     * @param _childContract The child contract containing the child tokens
     * @return uint256 The total number of child tokens found in child contract that are owned by _tokenId
     */
    function totalChildTokens(uint256 _tokenId, address _childContract) external view override returns (uint256) {
        return childTokens[_tokenId][_childContract].length();
    }

    /**
     * @notice Get child token owned by _tokenId, in child contract, at index position
     * @param _tokenId The parent token of the child token
     * @param _childContract The child contract of the child token
     * @param _index The index position of the child token
     * @return childTokenId The child tokenId for the parent token, child token and index
     */
    function childTokenByIndex(
        uint256 _tokenId,
        address _childContract,
        uint256 _index
    ) external view virtual override returns (uint256 childTokenId) {
        return childTokens[_tokenId][_childContract].at(_index);
    }

    /**
     * @notice Get the parent tokenId and its owner of a ERC721 child token
     * @param _childContract The contract address of the child token
     * @param _childTokenId The tokenId of the child
     * @return parentTokenOwner The parent address of the parent token and ERC998 magic value
     * @return parentTokenId The parent tokenId of _childTokenId
     */
    function ownerOfChild(address _childContract, uint256 _childTokenId)
        external
        view
        virtual
        override
        returns (bytes32 parentTokenOwner, uint256 parentTokenId)
    {
        parentTokenId = childTokenOwner[_childContract][_childTokenId];
        require(parentTokenId != 0, "owner of child not found");
        address parentTokenOwnerAddress = ownerOf(parentTokenId);
        // solhint-disable-next-line no-inline-assembly
        assembly {
            parentTokenOwner := or(ERC998_MAGIC_VALUE, parentTokenOwnerAddress)
        }
    }

    /**
     * @notice Get the root owner of tokenId
     * @param _tokenId The token to query for a root owner address
     * @return rootOwner The root owner at the top of tree of tokens and ERC998 magic value.
     */
    function rootOwnerOf(uint256 _tokenId) public view virtual override returns (bytes32 rootOwner) {
        return rootOwnerOfChild(address(0), _tokenId);
    }

    /**
     * @notice Get the root owner of a child token
     * @dev Returns the owner at the top of the tree of composables
     * Use Cases handled:
     * - Case 1: Token owner is this contract and token.
     * - Case 2: Token owner is other external top-down composable
     * - Case 3: Token owner is other contract
     * - Case 4: Token owner is user
     * @param _childContract The contract address of the child token
     * @param _childTokenId The tokenId of the child
     * @return rootOwner The root owner at the top of tree of tokens and ERC998 magic value
     */
    function rootOwnerOfChild(address _childContract, uint256 _childTokenId)
        public
        view
        virtual
        override
        returns (bytes32 rootOwner)
    {
        address rootOwnerAddress;
        if (_childContract != address(0)) {
            (rootOwnerAddress, _childTokenId) = _ownerOfChild(_childContract, _childTokenId);
        } else {
            rootOwnerAddress = ownerOf(_childTokenId);
        }

        if (rootOwnerAddress.isContract()) {
            try IERC998ERC721TopDown(rootOwnerAddress).rootOwnerOfChild(address(this), _childTokenId) returns (
                bytes32 returnedRootOwner
            ) {
                // Case 2: Token owner is other external top-down composable
                if (returnedRootOwner & ERC998_MAGIC_MASK == ERC998_MAGIC_VALUE) {
                    return returnedRootOwner;
                }
            } catch {
                // solhint-disable-previous-line no-empty-blocks
            }
        }

        // Case 3: Token owner is other contract
        // Or
        // Case 4: Token owner is user
        // solhint-disable-next-line no-inline-assembly
        assembly {
            rootOwner := or(ERC998_MAGIC_VALUE, rootOwnerAddress)
        }
        return rootOwner;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     * The interface id 0x1efdf36a is added. The spec claims it to be the interface id of IERC998ERC721TopDown.
     * But it is not.
     * It is added anyway in case some contract checks it being compliant with the spec.
     */
    function supportsInterface(bytes4 _interfaceId) public view virtual override(ERC721Enumerable) returns (bool) {
        return
            _interfaceId == type(IERC998ERC721TopDown).interfaceId ||
            _interfaceId == type(IERC998ERC721TopDownEnumerable).interfaceId ||
            _interfaceId == 0x1efdf36a ||
            super.supportsInterface(_interfaceId);
    }

    /**
     * @notice Mints a new bundle
     * @param _to The address that owns the new bundle
     * @return The id of the new bundle
     */
    function _safeMint(address _to) internal returns (uint256) {
        uint256 id = ++tokenCount;
        _safeMint(_to, id);

        return id;
    }

    /**
     * @notice Transfer child token from top-down composable to address
     * @param _fromTokenId The owning token to transfer from
     * @param _to The address that receives the child token
     * @param _childContract The ERC721 contract of the child token
     * @param _childTokenId The tokenId of the token that is being transferred
     */
    function safeTransferChild(
        uint256 _fromTokenId,
        address _to,
        address _childContract,
        uint256 _childTokenId
    ) external virtual override nonReentrant {
        _transferChild(_fromTokenId, _to, _childContract, _childTokenId);
        IERC721(_childContract).safeTransferFrom(address(this), _to, _childTokenId);
        emit TransferChild(_fromTokenId, _to, _childContract, _childTokenId);
    }

    /**
     * @notice Transfer child token from top-down composable to address or other top-down composable
     * @param _fromTokenId The owning token to transfer from
     * @param _to The address that receives the child token
     * @param _childContract The ERC721 contract of the child token
     * @param _childTokenId The tokenId of the token that is being transferred
     * @param _data Additional data with no specified format
     */
    function safeTransferChild(
        uint256 _fromTokenId,
        address _to,
        address _childContract,
        uint256 _childTokenId,
        bytes memory _data
    ) external virtual override nonReentrant {
        _transferChild(_fromTokenId, _to, _childContract, _childTokenId);
        if (_to == address(this)) {
            _validateAndReceiveChild(msg.sender, _childContract, _childTokenId, _data);
        } else {
            IERC721(_childContract).safeTransferFrom(address(this), _to, _childTokenId, _data);
            emit TransferChild(_fromTokenId, _to, _childContract, _childTokenId);
        }
    }

    /**
     * @dev Transfer child token from top-down composable to address
     * @param _fromTokenId The owning token to transfer from
     * @param _to The address that receives the child token
     * @param _childContract The ERC721 contract of the child token
     * @param _childTokenId The tokenId of the token that is being transferred
     */
    function transferChild(
        uint256 _fromTokenId,
        address _to,
        address _childContract,
        uint256 _childTokenId
    ) external virtual override nonReentrant {
        _transferChild(_fromTokenId, _to, _childContract, _childTokenId);
        _oldNFTsTransfer(_to, _childContract, _childTokenId);
        emit TransferChild(_fromTokenId, _to, _childContract, _childTokenId);
    }

    /**
     * @notice NOT SUPPORTED
     * Intended to transfer bottom-up composable child token from top-down composable to other ERC721 token.
     */
    function transferChildToParent(
        uint256,
        address,
        uint256,
        address,
        uint256,
        bytes memory
    ) external pure override {
        revert("BOTTOM_UP_CHILD_NOT_SUPPORTED");
    }

    /**
     * @notice Transfer a child token from an ERC721 contract to a composable. Used for old tokens that does not
     * have a safeTransferFrom method like cryptokitties
     */
    function getChild(
        address,
        uint256,
        address,
        uint256
    ) external pure override {
        revert("external calls restricted");
    }

    /**
     * @notice Transfer a child token from an ERC721 contract to a composable. Used for old tokens that does not
     * have a safeTransferFrom method like cryptokitties
     * @dev This contract has to be approved first in _childContract
     * @param _from The address that owns the child token.
     * @param _tokenId The token that becomes the parent owner
     * @param _childContract The ERC721 contract of the child token
     * @param _childTokenId The tokenId of the child token
     */
    function _getChild(
        address _from,
        uint256 _tokenId,
        address _childContract,
        uint256 _childTokenId
    ) internal virtual nonReentrant {
        _receiveChild(_from, _tokenId, _childContract, _childTokenId);
        IERC721(_childContract).transferFrom(_from, address(this), _childTokenId);
    }

    /**
     * @notice A token receives a child token
     * param The address that caused the transfer
     * @param _from The owner of the child token
     * @param _childTokenId The token that is being transferred to the parent
     * @param _data Up to the first 32 bytes contains an integer which is the receiving parent tokenId
     * @return the selector of this method
     */
    function onERC721Received(
        address,
        address _from,
        uint256 _childTokenId,
        bytes calldata _data
    ) external virtual override nonReentrant returns (bytes4) {
        _validateAndReceiveChild(_from, msg.sender, _childTokenId, _data);
        return this.onERC721Received.selector;
    }

    /**
     * @dev ERC721 implementation hook that is called before any token transfer. Prevents nested bundles
     * @param _from address of the current owner of the token
     * @param _to destination address
     * @param _tokenId id of the token to transfer
     */
    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal virtual override {
        require(_to != address(this), "nested bundles not allowed");
        super._beforeTokenTransfer(_from, _to, _tokenId);
    }

    /**
     * @dev Validates the child transfer parameters and remove the child from the bundle
     * @param _fromTokenId The owning token to transfer from
     * @param _to The address that receives the child token
     * @param _childContract The ERC721 contract of the child token
     * @param _childTokenId The tokenId of the token that is being transferred
     */
    function _transferChild(
        uint256 _fromTokenId,
        address _to,
        address _childContract,
        uint256 _childTokenId
    ) internal virtual {
        _validateReceiver(_to);
        _validateChildTransfer(_fromTokenId, _childContract, _childTokenId);
        _removeChild(_fromTokenId, _childContract, _childTokenId);
    }

    /**
     * @dev Validates the child transfer parameters
     * @param _fromTokenId The owning token to transfer from
     * @param _childContract The ERC721 contract of the child token
     * @param _childTokenId The tokenId of the token that is being transferred
     */
    function _validateChildTransfer(
        uint256 _fromTokenId,
        address _childContract,
        uint256 _childTokenId
    ) internal virtual {
        uint256 tokenId = childTokenOwner[_childContract][_childTokenId];
        require(tokenId != 0, "_transferChild _childContract _childTokenId not found");
        require(tokenId == _fromTokenId, "ComposableTopDown: _transferChild wrong tokenId found");
        _validateTransferSender(tokenId);
    }

    /**
     * @dev Validates the receiver of a child transfer
     * @param _to The address that receives the child token
     */
    function _validateReceiver(address _to) internal virtual {
        require(_to != address(0), "child transfer to zero address");
    }

    /**
     * @dev Updates the state to remove a child
     * @param _tokenId The owning token to transfer from
     * @param _childContract The ERC721 contract of the child token
     * @param _childTokenId The tokenId of the token that is being transferred
     */
    function _removeChild(
        uint256 _tokenId,
        address _childContract,
        uint256 _childTokenId
    ) internal virtual {
        // remove child token
        childTokens[_tokenId][_childContract].remove(_childTokenId);
        delete childTokenOwner[_childContract][_childTokenId];

        // remove contract
        if (childTokens[_tokenId][_childContract].length() == 0) {
            childContracts[_tokenId].remove(_childContract);
        }
    }

    /**
     * @dev Validates the data from a child transfer and receives it
     * @param _from The owner of the child token
     * @param _childContract The ERC721 contract of the child token
     * @param _childTokenId The token that is being transferred to the parent
     * @param _data Up to the first 32 bytes contains an integer which is the receiving parent tokenId
     */
    function _validateAndReceiveChild(
        address _from,
        address _childContract,
        uint256 _childTokenId,
        bytes memory _data
    ) internal virtual {
        require(_data.length > 0, "data must contain tokenId to transfer the child token to");
        // convert up to 32 bytes of _data to uint256, owner nft tokenId passed as uint in bytes
        uint256 tokenId = _parseTokenId(_data);
        _receiveChild(_from, tokenId, _childContract, _childTokenId);
    }

    /**
     * @dev Update the state to receive a child
     * @param _from The owner of the child token
     * @param _tokenId The token receiving the child
     * @param _childContract The ERC721 contract of the child token
     * @param _childTokenId The token that is being transferred to the parent
     */
    function _receiveChild(
        address _from,
        uint256 _tokenId,
        address _childContract,
        uint256 _childTokenId
    ) internal virtual {
        require(_exists(_tokenId), "bundle tokenId does not exist");
        uint256 childTokensLength = childTokens[_tokenId][_childContract].length();
        if (childTokensLength == 0) {
            childContracts[_tokenId].add(_childContract);
        }
        childTokens[_tokenId][_childContract].add(_childTokenId);
        childTokenOwner[_childContract][_childTokenId] = _tokenId;
        emit ReceivedChild(_from, _tokenId, _childContract, _childTokenId);
    }

    /**
     * @dev Returns the owner of a child
     * @param _childContract The contract address of the child token
     * @param _childTokenId The tokenId of the child
     * @return parentTokenOwner The parent address of the parent token and ERC998 magic value
     * @return parentTokenId The parent tokenId of _childTokenId
     */
    function _ownerOfChild(address _childContract, uint256 _childTokenId)
        internal
        view
        virtual
        returns (address parentTokenOwner, uint256 parentTokenId)
    {
        parentTokenId = childTokenOwner[_childContract][_childTokenId];
        require(parentTokenId != 0, "owner of child not found");
        return (ownerOf(parentTokenId), parentTokenId);
    }

    /**
     * @dev Convert up to 32 bytes of_data to uint256, owner nft tokenId passed as uint in bytes
     * @param _data Up to the first 32 bytes contains an integer which is the receiving parent tokenId
     * @return tokenId the token Id encoded in the data
     */
    function _parseTokenId(bytes memory _data) internal pure virtual returns (uint256 tokenId) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            tokenId := mload(add(_data, 0x20))
        }
    }

    /**
     * @dev Transfers the NFT using method compatible with old token contracts
     * @param _to address of the receiver of the children
     * @param _childContract The contract address of the child token
     * @param _childTokenId The tokenId of the child
     */
    function _oldNFTsTransfer(
        address _to,
        address _childContract,
        uint256 _childTokenId
    ) internal {
        // This is here to be compatible with cryptokitties and other old contracts that require being owner and
        // approved before transferring.
        // Does not work with current standard which does not allow approving self, so we must let it fail in that case.
        try IERC721(_childContract).approve(address(this), _childTokenId) {
            // solhint-disable-previous-line no-empty-blocks
        } catch {
            // solhint-disable-previous-line no-empty-blocks
        }

        IERC721(_childContract).transferFrom(address(this), _to, _childTokenId);
    }

    /**
     * @notice Validates that the sender is authorized to perform a child transfer
     * @param _fromTokenId The owning token to transfer from
     */
    function _validateTransferSender(uint256 _fromTokenId) internal virtual {
        address rootOwner = address(uint160(uint256(rootOwnerOf(_fromTokenId))));
        require(
            rootOwner == msg.sender ||
                getApproved(_fromTokenId) == msg.sender ||
                isApprovedForAll(rootOwner, msg.sender),
            "transferChild msg.sender not eligible"
        );
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

interface IERC998ERC1155TopDown {
    event Received1155Child(
        address indexed from,
        uint256 indexed toTokenId,
        address indexed childContract,
        uint256 childTokenId,
        uint256 amount
    );
    event Transfer1155Child(
        uint256 indexed fromTokenId,
        address indexed to,
        address indexed childContract,
        uint256 childTokenId,
        uint256 amount
    );
    event Transfer1155BatchChild(
        uint256 indexed fromTokenId,
        address indexed to,
        address indexed childContract,
        uint256[] childTokenIds,
        uint256[] amounts
    );

    function safeTransferChild(
        uint256 fromTokenId,
        address to,
        address childContract,
        uint256 childTokenId,
        uint256 amount,
        bytes calldata data
    ) external;

    function safeBatchTransferChild(
        uint256 fromTokenId,
        address to,
        address childContract,
        uint256[] calldata childTokenIds,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

    function childBalance(
        uint256 tokenId,
        address childContract,
        uint256 childTokenId
    ) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

interface IERC998ERC721TopDown {
    event ReceivedChild(
        address indexed _from,
        uint256 indexed _tokenId,
        address indexed _childContract,
        uint256 _childTokenId
    );
    event TransferChild(
        uint256 indexed tokenId,
        address indexed _to,
        address indexed _childContract,
        uint256 _childTokenId
    );

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _childTokenId,
        bytes calldata _data
    ) external returns (bytes4);

    function transferChild(
        uint256 _fromTokenId,
        address _to,
        address _childContract,
        uint256 _childTokenId
    ) external;

    function safeTransferChild(
        uint256 _fromTokenId,
        address _to,
        address _childContract,
        uint256 _childTokenId
    ) external;

    function safeTransferChild(
        uint256 _fromTokenId,
        address _to,
        address _childContract,
        uint256 _childTokenId,
        bytes memory _data
    ) external;

    function transferChildToParent(
        uint256 _fromTokenId,
        address _toContract,
        uint256 _toTokenId,
        address _childContract,
        uint256 _childTokenId,
        bytes memory _data
    ) external;

    // getChild function enables older contracts like cryptokitties to be transferred into a composable
    // The _childContract must approve this contract. Then getChild can be called.
    function getChild(
        address _from,
        uint256 _tokenId,
        address _childContract,
        uint256 _childTokenId
    ) external;

    function rootOwnerOf(uint256 _tokenId) external view returns (bytes32 rootOwner);

    function rootOwnerOfChild(address _childContract, uint256 _childTokenId) external view returns (bytes32 rootOwner);

    function ownerOfChild(address _childContract, uint256 _childTokenId)
        external
        view
        returns (bytes32 parentTokenOwner, uint256 parentTokenId);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

interface IERC998ERC721TopDownEnumerable {
    function totalChildContracts(uint256 _tokenId) external view returns (uint256);

    function childContractByIndex(uint256 _tokenId, uint256 _index) external view returns (address childContract);

    function totalChildTokens(uint256 _tokenId, address _childContract) external view returns (uint256);

    function childTokenByIndex(
        uint256 _tokenId,
        address _childContract,
        uint256 _index
    ) external view returns (uint256 childTokenId);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

interface IERC998ERC20TopDown {
    event ReceivedERC20(
        address indexed _from,
        uint256 indexed _tokenId,
        address indexed _erc20Contract,
        uint256 _value
    );
    event TransferERC20(uint256 indexed _tokenId, address indexed _to, address indexed _erc20Contract, uint256 _value);

    function balanceOfERC20(uint256 _tokenId, address __erc20Contract) external view returns (uint256);

    function tokenFallback(
        address _from,
        uint256 _value,
        bytes calldata _data
    ) external;

    function transferERC20(
        uint256 _tokenId,
        address _to,
        address _erc20Contract,
        uint256 _value
    ) external;

    function transferERC223(
        uint256 _tokenId,
        address _to,
        address _erc223Contract,
        uint256 _value,
        bytes calldata _data
    ) external;

    function getERC20(
        address _from,
        uint256 _tokenId,
        address _erc20Contract,
        uint256 _value
    ) external;
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

interface IERC998ERC20TopDownEnumerable {
    function totalERC20Contracts(uint256 _tokenId) external view returns (uint256);

    function erc20ContractByIndex(uint256 _tokenId, uint256 _index) external view returns (address);
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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../../interfaces/INftWrapper.sol";

/**
 * @title ERC721Wrapper
 * @author NFTfi
 * @dev Provides logic to transfer ERC721
 */
contract ERC721Wrapper is INftWrapper {
    /**
     * @dev Transfers ERC721 `_nftId` handled by the contract `_nftContract` from `_sender` to `_recipient`
     *
     * @param _sender - The current owner of the ERC721
     * @param _recipient - The new owner of the ERC721
     * @param _nftContract - ERC721 contract
     * @param _nftId - ERC721 id
     *
     * @return true if successfully transferred, false otherwise
     */
    function transferNFT(
        address _sender,
        address _recipient,
        address _nftContract,
        uint256 _nftId
    ) external override returns (bool) {
        IERC721(_nftContract).safeTransferFrom(_sender, _recipient, _nftId);
        return true;
    }

    function isOwner(
        address _owner,
        address _nftContract,
        uint256 _tokenId
    ) external view override returns (bool) {
        return IERC721(_nftContract).ownerOf(_tokenId) == _owner;
    }

    function wrapAirdropReceiver(
        address _recipient,
        address _nftContract,
        uint256 _nftId,
        address _beneficiary
    ) external override returns (bool) {
        IERC721(_nftContract).safeTransferFrom(address(this), _recipient, _nftId, abi.encode(_beneficiary));

        return true;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "../../interfaces/INftWrapper.sol";

/**
 * @title ERC1155Wrapper
 * @dev Provides logic to transfer ERC1155 tokens
 */
contract ERC1155Wrapper is INftWrapper {
    /**
     * @dev Transfer the nft to the `recipient`
     *
     * @param _sender Address of the current owner of the nft
     * @param _recipient Address that will receive the nft
     * @param _nftContract Address of the nft contract
     * @param _nftId Id of the nft
     *
     * @return true if successfully transferred, false otherwise
     */
    function transferNFT(
        address _sender,
        address _recipient,
        address _nftContract,
        uint256 _nftId
    ) external override returns (bool) {
        // Warning:
        // Since we permit ERC1155s in their entirety, the given nftId may represent a fungible token (amount > 1),
        // in which case they are treated as non-fungible by hard coding the amount to 1.
        IERC1155(_nftContract).safeTransferFrom(_sender, _recipient, _nftId, 1, "");
        return true;
    }

    function isOwner(
        address _owner,
        address _nftContract,
        uint256 _tokenId
    ) external view override returns (bool) {
        return IERC1155(_nftContract).balanceOf(_owner, _tokenId) > 0;
    }

    function wrapAirdropReceiver(
        address _recipient,
        address _nftContract,
        uint256 _nftId,
        address _beneficiary
    ) external override returns (bool) {
        IERC1155(_nftContract).safeTransferFrom(address(this), _recipient, _nftId, 1, abi.encode(_beneficiary));

        return true;
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../interfaces/INftfiHub.sol";
import "../interfaces/IPermittedNFTs.sol";
import "../interfaces/IPermittedAirdrops.sol";
import "../interfaces/INftWrapper.sol";
import "../utils/ContractKeys.sol";

/**
 * @title AirdropReceiver
 * @author NFTfi
 * @dev
 */
contract AirdropReceiver is ERC721Enumerable, ERC721Holder, ERC1155Holder, Initializable, ReentrancyGuard {
    using Address for address;
    using SafeERC20 for IERC20;

    INftfiHub public immutable hub;

    // in the context of this contract the name of this is a bit confusing, this "wrapper" is the one that
    // knows how to transfer a type of nft
    address public nftTransferWrapper;
    address public beneficiary;
    address public wrappedNft;
    uint256 public wrappedNftId;

    bool private wrapping_;

    event Initialized(uint256 indexed tokenId);

    event NftWrapped(
        address indexed nftCollateralContract,
        uint256 indexed nftCollateralId,
        address indexed from,
        address beneficiary,
        address owner
    );
    event NftUnwrapped(
        address indexed nftCollateralContract,
        uint256 indexed nftCollateralId,
        address indexed to,
        address owner
    );

    modifier onlyOwner() {
        require(ownerOf(getTokenId()) == msg.sender, "Only owner");

        _;
    }

    modifier onlyOwnerOrBeneficiary() {
        require(ownerOf(getTokenId()) == msg.sender || msg.sender == beneficiary, "Only owner or beneficiary");

        _;
    }

    constructor(address _nftfiHub) ERC721("", "") {
        hub = INftfiHub(_nftfiHub);

        // grant ownership of implementation to deployer, this blocks initialization of this implementation
        _safeMint(msg.sender, getTokenId());
    }

    function getTokenId() public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(address(this))));
    }

    function initialize(address _to) external initializer nonReentrant returns (uint256) {
        uint256 tokenId = getTokenId();
        _safeMint(_to, tokenId);

        emit Initialized(tokenId);

        return tokenId;
    }

    function wrap(
        address _from,
        address _beneficiary,
        address _nftCollateralContract,
        uint256 _nftCollateralId
    ) external onlyOwner {
        require(wrappedNft == address(0), "already wrapping");
        require(_from != address(0), "from is zero address");
        require(_beneficiary != address(0), "beneficiary is zero address");
        require(_nftCollateralContract != address(0), "nftCollateralContract is zero address");

        wrapping_ = true;

        nftTransferWrapper = IPermittedNFTs(hub.getContract(ContractKeys.PERMITTED_NFTS)).getNFTWrapper(
            _nftCollateralContract
        );

        _transferNFT(nftTransferWrapper, _from, address(this), _nftCollateralContract, _nftCollateralId);

        beneficiary = _beneficiary;
        wrappedNft = _nftCollateralContract;
        wrappedNftId = _nftCollateralId;

        emit NftWrapped(_nftCollateralContract, _nftCollateralId, _from, _beneficiary, msg.sender);

        wrapping_ = false;
    }

    function unwrap(address _receiver) external onlyOwner {
        require(wrappedNft != address(0), "not wrapping");

        _transferNFT(nftTransferWrapper, address(this), _receiver, wrappedNft, wrappedNftId);

        emit NftUnwrapped(wrappedNft, wrappedNftId, _receiver, msg.sender);

        beneficiary = address(0);
        wrappedNft = address(0);
        wrappedNftId = 0;
        nftTransferWrapper = address(0);
    }

    function pullAirdrop(address _target, bytes calldata _data) external nonReentrant onlyOwnerOrBeneficiary {
        require(
            IPermittedAirdrops(hub.getContract(ContractKeys.PERMITTED_AIRDROPS)).isValidAirdrop(
                abi.encode(_target, _getSelector(_data))
            ),
            "Invalid Airdrop"
        );

        _target.functionCall(_data);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 _interfaceId)
        public
        view
        virtual
        override(ERC721Enumerable, ERC1155Receiver)
        returns (bool)
    {
        return _interfaceId == type(IERC721Receiver).interfaceId || super.supportsInterface(_interfaceId);
    }

    /**
     * @notice used by the owner account to be able to drain ERC20 tokens received as airdrops
     * for the locked  collateral NFT-s
     * @param tokenAddress - address of the token contract for the token to be sent out
     * @param receiver - receiver of the token
     */
    function drainERC20Airdrop(address tokenAddress, address receiver) external onlyOwner {
        IERC20 tokenContract = IERC20(tokenAddress);
        uint256 amount = tokenContract.balanceOf(address(this));
        require(amount > 0, "no tokens owned");
        tokenContract.safeTransfer(receiver, amount);
    }

    /**
     * @notice used by the owner account to be able to drain ERC721 tokens received as airdrops
     * for the locked  collateral NFT-s
     * @param tokenAddress - address of the token contract for the token to be sent out
     * @param tokenId - id token to be sent out
     * @param receiver - receiver of the token
     */
    function drainERC721Airdrop(
        address tokenAddress,
        uint256 tokenId,
        address receiver
    ) external onlyOwner {
        require(wrappedNft != tokenAddress && tokenId != wrappedNftId, "token is wrapped");
        IERC721 tokenContract = IERC721(tokenAddress);
        tokenContract.safeTransferFrom(address(this), receiver, tokenId);
    }

    /**
     * @notice used by the owner account to be able to drain ERC1155 tokens received as airdrops
     * for the locked  collateral NFT-s
     * @param tokenAddress - address of the token contract for the token to be sent out
     * @param tokenId - id token to be sent out
     * @param receiver - receiver of the token
     */
    function drainERC1155Airdrop(
        address tokenAddress,
        uint256 tokenId,
        address receiver
    ) external onlyOwner {
        require(wrappedNft != tokenAddress && tokenId != wrappedNftId, "token is wrapped");
        IERC1155 tokenContract = IERC1155(tokenAddress);
        uint256 amount = tokenContract.balanceOf(address(this), tokenId);
        require(amount > 0, "no nfts owned");
        tokenContract.safeTransferFrom(address(this), receiver, tokenId, amount, "");
    }

    function _transferNFT(
        address _nftTransferWrapper,
        address _sender,
        address _recipient,
        address _nftCollateralContract,
        uint256 _nftCollateralId
    ) internal {
        _nftTransferWrapper.functionDelegateCall(
            abi.encodeWithSelector(
                INftWrapper(_nftTransferWrapper).transferNFT.selector,
                _sender,
                _recipient,
                _nftCollateralContract,
                _nftCollateralId
            ),
            "NFT was not successfully transferred"
        );
    }

    function _getSelector(bytes memory _data) internal pure returns (bytes4 selector) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            selector := mload(add(_data, 32))
        }
    }

    function onERC721Received(
        address,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) public virtual override returns (bytes4) {
        // owner can only send with the intention of wrapping
        if (ownerOf(getTokenId()) == _from && !wrapping_) {
            require(wrappedNft == address(0), "already wrapping");

            address _beneficiary = abi.decode(_data, (address));
            require(_beneficiary != address(0), "beneficiary is zero address");

            // sender is the nftCollateral contract
            _receiveAndWrap(_from, _beneficiary, msg.sender, _tokenId);
        }
        // otherwise it is considered an airdrop
        return this.onERC721Received.selector;
    }

    function onERC1155Received(
        address,
        address _from,
        uint256 _id,
        uint256,
        bytes calldata _data
    ) public virtual override returns (bytes4) {
        // owner can only send with the intention of wrapping
        if (ownerOf(getTokenId()) == _from && !wrapping_) {
            require(wrappedNft == address(0), "already wrapping");

            address _beneficiary = abi.decode(_data, (address));
            require(_beneficiary != address(0), "beneficiary is zero address");

            // sender is the nftCollateral contract
            _receiveAndWrap(_from, _beneficiary, msg.sender, _id);
        }
        // otherwise it is considered an airdrop

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address _from,
        uint256[] calldata _ids,
        uint256[] calldata,
        bytes calldata _data
    ) public virtual override returns (bytes4) {
        // owner can only send with the intention of wrapping
        if (ownerOf(getTokenId()) == _from && !wrapping_) {
            require(wrappedNft == address(0), "already wrapping");
            require(_ids.length > 1, "only 0 allowed");

            address _beneficiary = abi.decode(_data, (address));
            require(_beneficiary != address(0), "beneficiary is zero address");

            // sender is the nftCollateral contract
            _receiveAndWrap(_from, _beneficiary, msg.sender, _ids[0]);
        }
        // otherwise it is considered an airdrop

        return this.onERC1155BatchReceived.selector;
    }

    function _receiveAndWrap(
        address _from,
        address _beneficiary,
        address _nftCollateralContract,
        uint256 _nftCollateralId
    ) internal {
        nftTransferWrapper = IPermittedNFTs(hub.getContract(ContractKeys.PERMITTED_NFTS)).getNFTWrapper(
            _nftCollateralContract
        );

        require(nftTransferWrapper != address(0), "bft not permitted");

        beneficiary = _beneficiary;
        wrappedNft = _nftCollateralContract;
        wrappedNftId = _nftCollateralId;

        emit NftWrapped(_nftCollateralContract, _nftCollateralId, _from, _beneficiary, _from);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !Address.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

import "../../interfaces/INftWrapper.sol";
import "../../interfaces/ICryptoKitties.sol";
import "../../airdrop/AirdropReceiver.sol";

/**
 * @title CryptoKittiesWrapper
 * @author NFTfi
 * @dev Provides logic to transfer CryptoKitties
 */
contract CryptoKittiesWrapper is INftWrapper {
    /**
     * @dev Transfers Kitty `_nftId` handled by the contract `_nftContract` from `_sender` to `_recipient`
     *
     * @param _sender - The current owner of the Kitty
     * @param _recipient - The new owner of the Kitty
     * @param _nftContract - CryptoKitties contract
     * @param _nftId - Kitty id
     *
     * @return true if successfully transferred, false otherwise
     */
    function transferNFT(
        address _sender,
        address _recipient,
        address _nftContract,
        uint256 _nftId
    ) external override returns (bool) {
        if (_sender == address(this)) {
            ICryptoKitties(_nftContract).transfer(_recipient, _nftId);
        } else {
            ICryptoKitties(_nftContract).transferFrom(_sender, _recipient, _nftId);
        }

        return true;
    }

    function isOwner(
        address _owner,
        address _nftContract,
        uint256 _tokenId
    ) external view override returns (bool) {
        return ICryptoKitties(_nftContract).ownerOf(_tokenId) == _owner;
    }

    function wrapAirdropReceiver(
        address _recipient,
        address _nftContract,
        uint256 _nftId,
        address _beneficiary
    ) external override returns (bool) {
        ICryptoKitties(_nftContract).approve(_recipient, _nftId);

        AirdropReceiver(_recipient).wrap(address(this), _beneficiary, _nftContract, _nftId);

        return true;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

/**
 * @title IERC721_CryptoKitties
 * @author NFTfi
 * @dev ERC721 compliant interface used by CryptoKitties contract.
 * Extracted from https://etherscan.io/address/0x06012c8cf97bead5deae237070f9587f8e7a266d#code
 */
interface ICryptoKitties {
    // Events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

    function approve(address _to, uint256 _tokenId) external;

    function transfer(address _to, uint256 _tokenId) external;

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;

    // Required methods
    function totalSupply() external view returns (uint256 total);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function ownerOf(uint256 _tokenId) external view returns (address owner);

    // Optional
    // function name() public view returns (string name);
    // function symbol() public view returns (string symbol);
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";

import "../interfaces/INftfiHub.sol";
import "../utils/ContractKeys.sol";
import "../utils/Ownable.sol";

import "./AirdropReceiver.sol";
import "./IAirdropReceiverFactory.sol";

/**
 * @title AirdropReceiver
 * @author NFTfi
 * @dev
 */
contract AirdropReceiverFactory is IAirdropReceiverFactory, Ownable {
    INftfiHub public immutable hub;

    event AirdropReceiverCreated(
        address indexed instance,
        uint256 indexed receiverId,
        address indexed owner,
        address creator
    );

    constructor(address _admin, address _nftfiHub) Ownable(_admin) {
        hub = INftfiHub(_nftfiHub);
    }

    function createAirdropReceiver(address _to) external override returns (address, uint256) {
        address receiverImpl = hub.getContract(ContractKeys.AIRDROP_RECEIVER);

        address instance = Clones.clone(receiverImpl);

        uint256 wrapperId = AirdropReceiver(instance).initialize(_to);

        IPermittedNFTs(hub.getContract(ContractKeys.PERMITTED_NFTS)).setNFTPermit(
            instance,
            ContractKeys.AIRDROP_WRAPPER_STRING
        );

        emit AirdropReceiverCreated(instance, wrapperId, _to, msg.sender);

        return (instance, wrapperId);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

import "../interfaces/IPermittedAirdrops.sol";
import "../utils/Ownable.sol";

/**
 * @title  PermittedAirdrops
 * @author NFTfi
 * @dev Registry for airdropa supported by NFTfi. Each Airdrop is associated with a boolean permit.
 */
contract PermittedAirdrops is Ownable, IPermittedAirdrops {
    /* ******* */
    /* STORAGE */
    /* ******* */

    /**
     * @notice A mapping from an airdrop to whether that airdrop
     * is permitted to be used by NFTfi.
     */
    mapping(bytes => bool) private airdropPermits;

    /* ****** */
    /* EVENTS */
    /* ****** */

    /**
     * @notice This event is fired whenever the admin sets a ERC20 permit.
     *
     * @param airdropContract - Address of the airdrop contract.
     * @param selector - The selector of the permitted function in the `airdropContract`.
     * @param isPermitted - Signals airdrop permit.
     */
    event AirdropPermit(address indexed airdropContract, bytes4 indexed selector, bool isPermitted);

    /* *********** */
    /* CONSTRUCTOR */
    /* *********** */

    /**
     * @notice Initialize `airdropPermits` with a batch of permitted airdops
     *
     * @param _admin - Initial admin of this contract.
     * @param _airdopContracts - The batch of airdrop contract addresses initially permitted.
     * @param _selectors - The batch of selector of the permitted functions for each `_airdopContracts`.
     */
    constructor(
        address _admin,
        address[] memory _airdopContracts,
        bytes4[] memory _selectors
    ) Ownable(_admin) {
        require(_airdopContracts.length == _selectors.length, "function information arity mismatch");
        for (uint256 i = 0; i < _airdopContracts.length; i++) {
            _setAirdroptPermit(_airdopContracts[i], _selectors[i], true);
        }
    }

    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    /**
     * @notice This function can be called by admins to change the permitted status of an airdrop. This includes
     * both adding an airdrop to the permitted list and removing it.
     *
     * @param _airdropContract - The address of airdrop contract whose permit list status changed.
     * @param _selector - The selector of the permitted function whose permit list status changed.
     * @param _permit - The new status of whether the airdrop is permitted or not.
     */
    function setAirdroptPermit(
        address _airdropContract,
        bytes4 _selector,
        bool _permit
    ) external onlyOwner {
        _setAirdroptPermit(_airdropContract, _selector, _permit);
    }

    /**
     * @notice This function can be called by admins to change the permitted status of a batch of airdrops. This
     * includes both adding an airdop to the permitted list and removing it.
     *
     * @param _airdropContracts - The addresses of the airdrop contracts whose permit list status changed.
     * @param _selectors - the selector of the permitted functions for each airdop whose permit list status changed.
     * @param _permits - The new statuses of whether the airdrop is permitted or not.
     */
    function setAirdroptPermits(
        address[] memory _airdropContracts,
        bytes4[] memory _selectors,
        bool[] memory _permits
    ) external onlyOwner {
        require(
            _airdropContracts.length == _selectors.length,
            "setAirdroptPermits function information arity mismatch"
        );
        require(_selectors.length == _permits.length, "setAirdroptPermits function information arity mismatch");

        for (uint256 i = 0; i < _airdropContracts.length; i++) {
            _setAirdroptPermit(_airdropContracts[i], _selectors[i], _permits[i]);
        }
    }

    /**
     * @notice This function can be called by anyone to get the permit associated with the airdrop.
     *
     * @param _addressSel - The address of the airdrop contract + function selector.
     *
     * @return Returns whether the airdrop is permitted
     */
    function isValidAirdrop(bytes memory _addressSel) external view override returns (bool) {
        return airdropPermits[_addressSel];
    }

    /**
     * @notice This function can be called by admins to change the permitted status of an airdrop. This includes
     * both adding an airdrop to the permitted list and removing it.
     *
     * @param _airdropContract - The address of airdrop contract whose permit list status changed.
     * @param _selector - The selector of the permitted function whose permit list status changed.
     * @param _permit - The new status of whether the airdrop is permitted or not.
     */
    function _setAirdroptPermit(
        address _airdropContract,
        bytes4 _selector,
        bool _permit
    ) internal {
        require(_airdropContract != address(0), "airdropContract is zero address");
        require(_selector != bytes4(0), "selector is empty");

        airdropPermits[abi.encode(_airdropContract, _selector)] = _permit;

        emit AirdropPermit(_airdropContract, _selector, _permit);
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

import "../interfaces/IPermittedERC20s.sol";
import "../utils/Ownable.sol";

/**
 * @title  PermittedERC20s
 * @author NFTfi
 * @dev Registry for ERC20 currencies supported by NFTfi. Each ERC20 is
 * associated with a boolean permit.
 */
contract PermittedERC20s is Ownable, IPermittedERC20s {
    /* ******* */
    /* STORAGE */
    /* ******* */

    /**
     * @notice A mapping from an ERC20 currency address to whether that currency
     * is permitted to be used by this contract.
     */
    mapping(address => bool) private erc20Permits;

    /* ****** */
    /* EVENTS */
    /* ****** */

    /**
     * @notice This event is fired whenever the admin sets a ERC20 permit.
     *
     * @param erc20Contract - Address of the ERC20 contract.
     * @param isPermitted - Signals ERC20 permit.
     */
    event ERC20Permit(address indexed erc20Contract, bool isPermitted);

    /* *********** */
    /* CONSTRUCTOR */
    /* *********** */

    /**
     * @notice Initialize `erc20Permits` with a batch of permitted ERC20s
     *
     * @param _admin - Initial admin of this contract.
     * @param _permittedErc20s - The batch of addresses initially permitted.
     */
    constructor(address _admin, address[] memory _permittedErc20s) Ownable(_admin) {
        for (uint256 i = 0; i < _permittedErc20s.length; i++) {
            _setERC20Permit(_permittedErc20s[i], true);
        }
    }

    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    /**
     * @notice This function can be called by admins to change the permitted status of an ERC20 currency. This includes
     * both adding an ERC20 currency to the permitted list and removing it.
     *
     * @param _erc20 - The address of the ERC20 currency whose permit list status changed.
     * @param _permit - The new status of whether the currency is permitted or not.
     */
    function setERC20Permit(address _erc20, bool _permit) external onlyOwner {
        _setERC20Permit(_erc20, _permit);
    }

    /**
     * @notice This function can be called by admins to change the permitted status of a batch of ERC20 currency. This
     * includes both adding an ERC20 currency to the permitted list and removing it.
     *
     * @param _erc20s - The addresses of the ERC20 currencies whose permit list status changed.
     * @param _permits - The new statuses of whether the currency is permitted or not.
     */
    function setERC20Permits(address[] memory _erc20s, bool[] memory _permits) external onlyOwner {
        require(_erc20s.length == _permits.length, "setERC20Permits function information arity mismatch");

        for (uint256 i = 0; i < _erc20s.length; i++) {
            _setERC20Permit(_erc20s[i], _permits[i]);
        }
    }

    /**
     * @notice This function can be called by anyone to get the permit associated with the erc20 contract.
     *
     * @param _erc20 - The address of the erc20 contract.
     *
     * @return Returns whether the erc20 is permitted
     */
    function getERC20Permit(address _erc20) external view override returns (bool) {
        return erc20Permits[_erc20];
    }

    /**
     * @notice This function can be called by admins to change the permitted status of an ERC20 currency. This includes
     * both adding an ERC20 currency to the permitted list and removing it.
     *
     * @param _erc20 - The address of the ERC20 currency whose permit list status changed.
     * @param _permit - The new status of whether the currency is permitted or not.
     */
    function _setERC20Permit(address _erc20, bool _permit) internal {
        require(_erc20 != address(0), "erc20 is zero address");

        erc20Permits[_erc20] = _permit;

        emit ERC20Permit(_erc20, _permit);
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

import "../../smartNft/SmartNft.sol";
import "../../interfaces/IDirectLoanCoordinator.sol";
import "../../interfaces/INftfiHub.sol";
import "../../utils/Ownable.sol";
import "../../utils/ContractKeys.sol";

/**
 * @title  DirectLoanCoordinator
 * @author NFTfi
 * @notice This contract is in charge of coordinating the creation, disctubution and desctruction of the SmartNfts
 * related to a loan, the Promossory Note and Obligaiton Receipt.
 */
contract DirectLoanCoordinator is IDirectLoanCoordinator, Ownable {
    /* ******* */
    /* STORAGE */
    /* ******* */

    INftfiHub public immutable hub;

    /**
     * @dev For each loan type, records the address of the contract that implements the type
     */
    mapping(bytes32 => address) private typeContracts;
    /**
     * @dev reverse mapping of loanTypes - for each contract address, records the associated loan type
     */
    mapping(address => bytes32) private contractTypes;

    /**
     * @notice A continuously increasing counter that simultaneously allows every loan to have a unique ID and provides
     * a running count of how many loans have been started by this contract.
     */
    uint32 public totalNumLoans = 0;

    // The address that deployed this contract
    address private immutable _deployer;
    bool private _initialized = false;

    mapping(uint32 => Loan) private loans;

    address public override promissoryNoteToken;
    address public override obligationReceiptToken;

    /* ****** */
    /* EVENTS */
    /* ****** */

    event UpdateStatus(
        uint32 indexed loanId,
        uint64 indexed smartNftId,
        address indexed loanContract,
        StatusType newStatus
    );

    /**
     * @notice This event is fired whenever the admins register a loan type.
     *
     * @param loanType - Loan type represented by keccak256('loan type').
     * @param loanContract - Address of the loan type contract.
     */
    event TypeUpdated(bytes32 indexed loanType, address indexed loanContract);

    /**
     * @dev Function using this modifier can only be executed after this contract is initialized
     *
     */
    modifier onlyInitialized() {
        require(_initialized, "not initialized");

        _;
    }

    /* *********** */
    /* CONSTRUCTOR */
    /* *********** */

    /**
     * @notice Sets the admin of the contract.
     * Initializes `contractTypes` with a batch of loan types. Sets `NftfiHub`.
     *
     * @param  _nftfiHub - Address of the NftfiHub contract
     * @param _admin - Initial admin of this contract.
     * @param _loanTypes - Loan types represented by keccak256('loan type').
     * @param _loanContracts - The addresses of each wrapper contract that implements the loan type's behaviour.
     */
    constructor(
        address _nftfiHub,
        address _admin,
        string[] memory _loanTypes,
        address[] memory _loanContracts
    ) Ownable(_admin) {
        hub = INftfiHub(_nftfiHub);
        _deployer = msg.sender;
        _registerLoanTypes(_loanTypes, _loanContracts);
    }

    /**
     * @dev Sets `promissoryNoteToken` and `obligationReceiptToken`.
     * It can be executed once by the deployer.
     *
     * @param  _promissoryNoteToken - Promissory Note Token address
     * @param  _obligationReceiptToken - Obligaiton Recipt Token address
     */
    function initialize(address _promissoryNoteToken, address _obligationReceiptToken) external {
        require(msg.sender == _deployer, "only deployer");
        require(!_initialized, "already initialized");
        require(_promissoryNoteToken != address(0), "promissoryNoteToken is zero");
        require(_obligationReceiptToken != address(0), "obligationReceiptToken is zero");

        _initialized = true;
        promissoryNoteToken = _promissoryNoteToken;
        obligationReceiptToken = _obligationReceiptToken;
    }

    /**
     * @dev This is called by the LoanType beginning the new loan.
     * It initialize the new loan data, mints both PromissoryNote and ObligationReceipt SmartNft's and returns the
     * new loan id.
     *
     * @param _lender - Address of the lender
     * @param _loanType - The type of the loan
     */
    function registerLoan(address _lender, bytes32 _loanType) external override onlyInitialized returns (uint32) {
        address loanContract = msg.sender;

        require(getContractFromType(_loanType) == loanContract, "Caller must be registered for loan type");

        // (loanIds start at 1)
        totalNumLoans += 1;

        uint64 smartNftId = uint64(uint256(keccak256(abi.encodePacked(address(this), totalNumLoans))));

        Loan memory newLoan = Loan({status: StatusType.NEW, loanContract: loanContract, smartNftId: smartNftId});

        // Issue an ERC721 promissory note to the lender that gives them the
        // right to either the principal-plus-interest or the collateral.
        SmartNft(promissoryNoteToken).mint(_lender, smartNftId, abi.encode(totalNumLoans));

        loans[totalNumLoans] = newLoan;

        emit UpdateStatus(totalNumLoans, smartNftId, loanContract, StatusType.NEW);

        return totalNumLoans;
    }

    function mintObligationReceipt(uint32 _loanId, address _borrower) external override onlyInitialized {
        address loanContract = msg.sender;

        require(getTypeFromContract(loanContract) != bytes32(0), "Caller must a be registered loan type");

        uint64 smartNftId = loans[_loanId].smartNftId;
        // nedded?
        require(smartNftId != 0, "loan doesn't exist");
        // nedded?
        require(SmartNft(promissoryNoteToken).exists(smartNftId), "Promissory note should exist");
        // nedded?
        require(!SmartNft(obligationReceiptToken).exists(smartNftId), "Obligation r shouldn't exist");

        // Issue an ERC721 obligation receipt to the borrower that gives them the
        // right to pay back the loan and get the collateral back.
        SmartNft(obligationReceiptToken).mint(_borrower, smartNftId, abi.encode(_loanId));
    }

    /**
     * @dev This is called by the LoanType who created the loan, when a loan is resolved whether by paying back or
     * liquidating the loan.
     * It sets the loan as `RESOLVED` and burns both PromossoryNote and ObligationReceipt SmartNft's.
     *
     * @param _loanId - Id of the loan
     */
    function resolveLoan(uint32 _loanId) external override onlyInitialized {
        Loan storage loan = loans[_loanId];
        require(loan.status == StatusType.NEW, "Loan status must be New");
        require(loan.loanContract == msg.sender, "Not the same Contract that registered Loan");

        loan.status = StatusType.RESOLVED;

        SmartNft(promissoryNoteToken).burn(loan.smartNftId);
        if (SmartNft(obligationReceiptToken).exists(loan.smartNftId)) {
            SmartNft(obligationReceiptToken).burn(loan.smartNftId);
        }

        emit UpdateStatus(_loanId, loan.smartNftId, msg.sender, StatusType.RESOLVED);
    }

    /**
     * @dev Returns loan's data for a given id.
     *
     * @param _loanId - Id of the loan
     */
    function getLoanData(uint32 _loanId) external view override returns (Loan memory) {
        return loans[_loanId];
    }

    /**
     * @dev checks if the given id is valid for the given loan contract address
     * @param _loanId - Id of the loan
     * @param _loanContract - address og the loan contract
     */
    function isValidLoanId(uint32 _loanId, address _loanContract) external view override returns (bool validity) {
        validity = loans[_loanId].loanContract == _loanContract;
    }

    /**
     * @notice  Set or update the contract address that implements the given Loan Type.
     * Set address(0) for a loan type for un-register such type.
     *
     * @param _loanType - Loan type represented by 'loan type'.
     * @param _loanContract - The address of the wrapper contract that implements the loan type's behaviour.
     */
    function registerLoanType(string memory _loanType, address _loanContract) external onlyOwner {
        _registerLoanType(_loanType, _loanContract);
    }

    /**
     * @notice  Batch set or update the contract addresses that implement the given batch Loan Type.
     * Set address(0) for a loan type for un-register such type.
     *
     * @param _loanTypes - Loan types represented by 'loan type'.
     * @param _loanContracts - The addresses of each wrapper contract that implements the loan type's behaviour.
     */
    function registerLoanTypes(string[] memory _loanTypes, address[] memory _loanContracts) external onlyOwner {
        _registerLoanTypes(_loanTypes, _loanContracts);
    }

    /**
     * @notice This function can be called by anyone to get the contract address that implements the given loan type.
     *
     * @param  _loanType - The loan type, e.g. bytes32("DIRECT_LOAN_FIXED"), or bytes32("DIRECT_LOAN_PRO_RATED").
     */
    function getContractFromType(bytes32 _loanType) public view returns (address) {
        return typeContracts[_loanType];
    }

    /**
     * @notice This function can be called by anyone to get the loan type of the given contract address.
     *
     * @param  _loanContract - The loan contract
     */
    function getTypeFromContract(address _loanContract) public view returns (bytes32) {
        return contractTypes[_loanContract];
    }

    /**
     * @notice  Set or update the contract address that implements the given Loan Type.
     * Set address(0) for a loan type for un-register such type.
     *
     * @param _loanType - Loan type represented by 'loan type').
     * @param _loanContract - The address of the wrapper contract that implements the loan type's behaviour.
     */
    function _registerLoanType(string memory _loanType, address _loanContract) internal {
        require(bytes(_loanType).length != 0, "loanType is empty");
        bytes32 loanTypeKey = ContractKeys.getIdFromStringKey(_loanType);

        typeContracts[loanTypeKey] = _loanContract;
        contractTypes[_loanContract] = loanTypeKey;

        emit TypeUpdated(loanTypeKey, _loanContract);
    }

    /**
     * @notice  Batch set or update the contract addresses that implement the given batch Loan Type.
     * Set address(0) for a loan type for un-register such type.
     *
     * @param _loanTypes - Loan types represented by keccak256('loan type').
     * @param _loanContracts - The addresses of each wrapper contract that implements the loan type's behaviour.
     */
    function _registerLoanTypes(string[] memory _loanTypes, address[] memory _loanContracts) internal {
        require(_loanTypes.length == _loanContracts.length, "function information arity mismatch");

        for (uint256 i = 0; i < _loanTypes.length; i++) {
            _registerLoanType(_loanTypes[i], _loanContracts[i]);
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

import "./NFTfiSigningUtils.sol";

/**
 * @title  NFTfiSigningUtilsContract
 * @author NFTfi
 * @notice Helper contract for NFTfi. This contract manages externally verifying signatures from off-chain NFTfi orders.
 */
contract NFTfiSigningUtilsContract {
    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    /**
     * @notice This function is when the lender accepts a borrower's binding listing terms, to validate the lender's
     * signature that the borrower provided off-chain to verify that it did indeed made such listing.
     *
     * @param _listingTerms - The listing terms struct containing:
     * - loanERC20Denomination: The address of the ERC20 contract of the currency being used as principal/interest
     * for this loan.
     * - minLoanPrincipalAmount: The minumum sum of money transferred from lender to borrower at the beginning of
     * the loan, measured in loanERC20Denomination's smallest units.
     * - maxLoanPrincipalAmount: The  sum of money transferred from lender to borrower at the beginning of
     * the loan, measured in loanERC20Denomination's smallest units.
     * - maximumRepaymentAmount: The maximum amount of money that the borrower would be required to retrieve their
     * collateral, measured in the smallest units of the ERC20 currency used for the loan. The borrower will always have
     * to pay this amount to retrieve their collateral, regardless of whether they repay early.
     * - nftCollateralContract: The address of the ERC721 contract of the NFT collateral.
     * - nftCollateralId: The ID within the NFTCollateralContract for the NFT being used as collateral for this
     * loan. The NFT is stored within this contract during the duration of the loan.
     * - revenueSharePartner: The address of the partner that will receive the revenue share.
     * - minLoanDuration: The minumum amount of time (measured in seconds) that can elapse before the lender can
     * liquidate the loan and seize the underlying collateral NFT.
     * - maxLoanDuration: The maximum amount of time (measured in seconds) that can elapse before the lender can
     * liquidate the loan and seize the underlying collateral NFT.
     * - maxInterestRateForDurationInBasisPoints: This is maximum the interest rate (measured in basis points, e.g.
     * hundreths of a percent) for the loan, that must be repaid pro-rata by the borrower at the conclusion of the loan
     * or risk seizure of their nft collateral. Note if the type of the loan is fixed then this value  is not used and
     * is irrelevant so it should be set to 0.
     * - referralFeeInBasisPoints: The percent (measured in basis points) of the loan principal amount that will be
     * taken as a fee to pay to the referrer, 0 if the lender is not paying referral fee.
     * @param _signature - The offer struct containing:
     * - signer: The address of the signer. The borrower for `acceptOffer` the lender for `acceptListing`.
     * - nonce: The nonce referred here is not the same as an Ethereum account's nonce.
     * We are referring instead to a nonce that is used by the lender or the borrower when they are first signing
     * off-chain NFTfi orders. These nonce can be any uint256 value that the user has not previously used to sign an
     * off-chain order. Each nonce can be used at most once per user within NFTfi, regardless of whether they are the
     * lender or the borrower in that situation. This serves two purposes:
     *   - First, it prevents replay attacks where an attacker would submit a user's off-chain order more than once.
     *   - Second, it allows a user to cancel an off-chain order by calling
     * NFTfi.cancelLoanCommitmentBeforeLoanHasBegun(), which marks the nonce as used and prevents any future loan from
     * using the user's off-chain order that contains that nonce.
     * - expiry: Date when the signature expires
     * - signature: The ECDSA signature of the borrower, obtained off-chain ahead of time, signing the following
     * combination of parameters:
     *   - listingTerms.loanERC20Denomination,
     *   - listingTerms.minLoanPrincipalAmount,
     *   - listingTerms.maxLoanPrincipalAmount,
     *   - listingTerms.nftCollateralContract,
     *   - listingTerms.nftCollateralId,
     *   - listingTerms.revenueSharePartner,
     *   - listingTerms.minLoanDuration,
     *   - listingTerms.maxLoanDuration,
     *   - listingTerms.maxInterestRateForDurationInBasisPoints,
     *   - listingTerms.referralFeeInBasisPoints,
     *   - signature.signer,
     *   - signature.nonce,
     *   - signature.expiry,
     *   - loan contract address,
     *   - chainId
     * @param _loanContract - Address of the loan contract where the signature is going to be used
     */
    function isValidBorrowerSignature(
        LoanData.ListingTerms memory _listingTerms,
        LoanData.Signature memory _signature,
        address _loanContract
    ) external view returns (bool) {
        return NFTfiSigningUtils.isValidBorrowerSignature(_listingTerms, _signature, _loanContract);
    }

    /**
     * @notice This function is when the lender accepts a borrower's binding listing terms, to validate the lender's
     * signature that the borrower provided off-chain to verify that it did indeed made such listing.
     *
     * @param _listingTerms - The listing terms struct containing:
     * - loanERC20Denomination: The address of the ERC20 contract of the currency being used as principal/interest
     * for this loan.
     * - minLoanPrincipalAmount: The minumum sum of money transferred from lender to borrower at the beginning of
     * the loan, measured in loanERC20Denomination's smallest units.
     * - maxLoanPrincipalAmount: The  sum of money transferred from lender to borrower at the beginning of
     * the loan, measured in loanERC20Denomination's smallest units.
     * - maximumRepaymentAmount: The maximum amount of money that the borrower would be required to retrieve their
     * collateral, measured in the smallest units of the ERC20 currency used for the loan. The borrower will always have
     * to pay this amount to retrieve their collateral, regardless of whether they repay early.
     * - nftCollateralContract: The address of the ERC721 contract of the NFT collateral.
     * - nftCollateralId: The ID within the NFTCollateralContract for the NFT being used as collateral for this
     * loan. The NFT is stored within this contract during the duration of the loan.
     * - revenueSharePartner: The address of the partner that will receive the revenue share.
     * - minLoanDuration: The minumum amount of time (measured in seconds) that can elapse before the lender can
     * liquidate the loan and seize the underlying collateral NFT.
     * - maxLoanDuration: The maximum amount of time (measured in seconds) that can elapse before the lender can
     * liquidate the loan and seize the underlying collateral NFT.
     * - maxInterestRateForDurationInBasisPoints: This is maximum the interest rate (measured in basis points, e.g.
     * hundreths of a percent) for the loan, that must be repaid pro-rata by the borrower at the conclusion of the loan
     * or risk seizure of their nft collateral. Note if the type of the loan is fixed then this value  is not used and
     * is irrelevant so it should be set to 0.
     * - referralFeeInBasisPoints: The percent (measured in basis points) of the loan principal amount that will be
     * taken as a fee to pay to the referrer, 0 if the lender is not paying referral fee.
     * @param _bundleElements - the lists of erc721-20-1155 tokens that are to be bundled
     * @param _signature - The offer struct containing:
     * - signer: The address of the signer. The borrower for `acceptOffer` the lender for `acceptListing`.
     * - nonce: The nonce referred here is not the same as an Ethereum account's nonce.
     * We are referring instead to a nonce that is used by the lender or the borrower when they are first signing
     * off-chain NFTfi orders. These nonce can be any uint256 value that the user has not previously used to sign an
     * off-chain order. Each nonce can be used at most once per user within NFTfi, regardless of whether they are the
     * lender or the borrower in that situation. This serves two purposes:
     *   - First, it prevents replay attacks where an attacker would submit a user's off-chain order more than once.
     *   - Second, it allows a user to cancel an off-chain order by calling
     * NFTfi.cancelLoanCommitmentBeforeLoanHasBegun(), which marks the nonce as used and prevents any future loan from
     * using the user's off-chain order that contains that nonce.
     * - expiry: Date when the signature expires
     * - signature: The ECDSA signature of the borrower, obtained off-chain ahead of time, signing the following
     * combination of parameters:
     *   - listingTerms.loanERC20Denomination,
     *   - listingTerms.minLoanPrincipalAmount,
     *   - listingTerms.maxLoanPrincipalAmount,
     *   - listingTerms.nftCollateralContract,
     *   - listingTerms.nftCollateralId,
     *   - listingTerms.revenueSharePartner,
     *   - listingTerms.minLoanDuration,
     *   - listingTerms.maxLoanDuration,
     *   - listingTerms.maxInterestRateForDurationInBasisPoints,
     *   - listingTerms.referralFeeInBasisPoints,
     *   - bundleElements
     *   - signature.signer,
     *   - signature.nonce,
     *   - signature.expiry,
     *   - loan contract address,
     *   - chainId
     * @param _loanContract - Address of the loan contract where the signature is going to be used
     */
    function isValidBorrowerSignatureBundle(
        LoanData.ListingTerms memory _listingTerms,
        IBundleBuilder.BundleElements memory _bundleElements,
        LoanData.Signature memory _signature,
        address _loanContract
    ) external view returns (bool) {
        return
            NFTfiSigningUtils.isValidBorrowerSignatureBundle(_listingTerms, _bundleElements, _signature, _loanContract);
    }

    /**
     * @notice This function is when the borrower accepts a lender's offer, to validate the lender's signature that the
     * lender provided off-chain to verify that it did indeed made such offer.
     *
     * @param _offer - The offer struct containing:
     * - loanERC20Denomination: The address of the ERC20 contract of the currency being used as principal/interest
     * for this loan.
     * - loanPrincipalAmount: The original sum of money transferred from lender to borrower at the beginning of
     * the loan, measured in loanERC20Denomination's smallest units.
     * - maximumRepaymentAmount: The maximum amount of money that the borrower would be required to retrieve their
     * collateral, measured in the smallest units of the ERC20 currency used for the loan. The borrower will always have
     * to pay this amount to retrieve their collateral, regardless of whether they repay early.
     * - nftCollateralContract: The address of the ERC721 contract of the NFT collateral.
     * - nftCollateralId: The ID within the NFTCollateralContract for the NFT being used as collateral for this
     * loan. The NFT is stored within this contract during the duration of the loan.
     * - referrer: The address of the referrer who found the lender matching the listing, Zero address to signal
     * this there is no referrer.
     * - loanDuration: The amount of time (measured in seconds) that can elapse before the lender can liquidate the
     * loan and seize the underlying collateral NFT.
     * - loanInterestRateForDurationInBasisPoints: This is the interest rate (measured in basis points, e.g.
     * hundreths of a percent) for the loan, that must be repaid pro-rata by the borrower at the conclusion of the loan
     * or risk seizure of their nft collateral. Note if the type of the loan is fixed then this value  is not used and
     * is irrelevant so it should be set to 0.
     * - loanAdminFeeInBasisPoints: The percent (measured in basis points) of the interest earned that will be
     * taken as a fee by the contract admins when the loan is repaid. The fee is stored in the loan struct to prevent an
     * attack where the contract admins could adjust the fee right before a loan is repaid, and take all of the interest
     * earned.
     * @param _signature - The signature structure containing:
     * - signer: The address of the signer. The borrower for `acceptOffer` the lender for `acceptListing`.
     * - nonce: The nonce referred here is not the same as an Ethereum account's nonce.
     * We are referring instead to a nonce that is used by the lender or the borrower when they are first signing
     * off-chain NFTfi orders. These nonce can be any uint256 value that the user has not previously used to sign an
     * off-chain order. Each nonce can be used at most once per user within NFTfi, regardless of whether they are the
     * lender or the borrower in that situation. This serves two purposes:
     *   - First, it prevents replay attacks where an attacker would submit a user's off-chain order more than once.
     *   - Second, it allows a user to cancel an off-chain order by calling
     * NFTfi.cancelLoanCommitmentBeforeLoanHasBegun(), which marks the nonce as used and prevents any future loan from
     * using the user's off-chain order that contains that nonce.
     * - expiry: Date when the signature expires
     * - signature: The ECDSA signature of the lender, obtained off-chain ahead of time, signing the following
     * combination of parameters:
     *   - offer.loanERC20Denomination
     *   - offer.loanPrincipalAmount
     *   - offer.maximumRepaymentAmount
     *   - offer.nftCollateralContract
     *   - offer.nftCollateralId
     *   - offer.referrer
     *   - offer.loanDuration
     *   - offer.loanAdminFeeInBasisPoints
     *   - signature.signer,
     *   - signature.nonce,
     *   - signature.expiry,
     *   - loan contract address,
     *   - chainId
     * @param _loanContract - Address of the loan contract where the signature is going to be used
     */
    function isValidLenderSignature(
        LoanData.Offer memory _offer,
        LoanData.Signature memory _signature,
        address _loanContract
    ) external view returns (bool) {
        return NFTfiSigningUtils.isValidLenderSignature(_offer, _signature, _loanContract);
    }

    /**
     * @notice This function is when the borrower accepts a lender's offer, to validate the lender's signature that the
     * lender provided off-chain to verify that it did indeed made such offer.
     *
     * @param _offer - The offer struct containing:
     * - loanERC20Denomination: The address of the ERC20 contract of the currency being used as principal/interest
     * for this loan.
     * - loanPrincipalAmount: The original sum of money transferred from lender to borrower at the beginning of
     * the loan, measured in loanERC20Denomination's smallest units.
     * - maximumRepaymentAmount: The maximum amount of money that the borrower would be required to retrieve their
     * collateral, measured in the smallest units of the ERC20 currency used for the loan. The borrower will always have
     * to pay this amount to retrieve their collateral, regardless of whether they repay early.
     * - nftCollateralContract: The address of the ERC721 contract of the NFT collateral.
     * - nftCollateralId: The ID within the NFTCollateralContract for the NFT being used as collateral for this
     * loan. The NFT is stored within this contract during the duration of the loan.
     * - referrer: The address of the referrer who found the lender matching the listing, Zero address to signal
     * this there is no referrer.
     * - loanDuration: The amount of time (measured in seconds) that can elapse before the lender can liquidate the
     * loan and seize the underlying collateral NFT.
     * - loanInterestRateForDurationInBasisPoints: This is the interest rate (measured in basis points, e.g.
     * hundreths of a percent) for the loan, that must be repaid pro-rata by the borrower at the conclusion of the loan
     * or risk seizure of their nft collateral. Note if the type of the loan is fixed then this value  is not used and
     * is irrelevant so it should be set to 0.
     * - loanAdminFeeInBasisPoints: The percent (measured in basis points) of the interest earned that will be
     * taken as a fee by the contract admins when the loan is repaid. The fee is stored in the loan struct to prevent an
     * attack where the contract admins could adjust the fee right before a loan is repaid, and take all of the interest
     * earned.
     * @param _bundleElements - the lists of erc721-20-1155 tokens that are to be bundled
     * @param _signature - The signature structure containing:
     * - signer: The address of the signer. The borrower for `acceptOffer` the lender for `acceptListing`.
     * - nonce: The nonce referred here is not the same as an Ethereum account's nonce.
     * We are referring instead to a nonce that is used by the lender or the borrower when they are first signing
     * off-chain NFTfi orders. These nonce can be any uint256 value that the user has not previously used to sign an
     * off-chain order. Each nonce can be used at most once per user within NFTfi, regardless of whether they are the
     * lender or the borrower in that situation. This serves two purposes:
     *   - First, it prevents replay attacks where an attacker would submit a user's off-chain order more than once.
     *   - Second, it allows a user to cancel an off-chain order by calling
     * NFTfi.cancelLoanCommitmentBeforeLoanHasBegun(), which marks the nonce as used and prevents any future loan from
     * using the user's off-chain order that contains that nonce.
     * - expiry: Date when the signature expires
     * - signature: The ECDSA signature of the lender, obtained off-chain ahead of time, signing the following
     * combination of parameters:
     *   - offer.loanERC20Denomination
     *   - offer.loanPrincipalAmount
     *   - offer.maximumRepaymentAmount
     *   - offer.nftCollateralContract
     *   - offer.nftCollateralId
     *   - offer.referrer
     *   - offer.loanDuration
     *   - offer.loanAdminFeeInBasisPoints
     *   - bundleElements
     *   - signature.signer,
     *   - signature.nonce,
     *   - signature.expiry,
     *   - loan contract address,
     *   - chainId
     * @param _loanContract - Address of the loan contract where the signature is going to be used
     */
    function isValidLenderSignatureBundle(
        LoanData.Offer memory _offer,
        IBundleBuilder.BundleElements memory _bundleElements,
        LoanData.Signature memory _signature,
        address _loanContract
    ) external view returns (bool) {
        return NFTfiSigningUtils.isValidLenderSignatureBundle(_offer, _bundleElements, _signature, _loanContract);
    }

    /**
     * @notice This function is called in renegotiateLoan() to validate the lender's signature that the lender provided
     * off-chain to verify that they did indeed want to agree to this loan renegotiation according to these terms.
     *
     * @param _loanId - The unique identifier for the loan to be renegotiated
     * @param _newLoanDuration - The new amount of time (measured in seconds) that can elapse before the lender can
     * liquidate the loan and seize the underlying collateral NFT.
     * @param _newMaximumRepaymentAmount - The new maximum amount of money that the borrower would be required to
     * retrieve their collateral, measured in the smallest units of the ERC20 currency used for the loan. The
     * borrower will always have to pay this amount to retrieve their collateral, regardless of whether they repay
     * early.
     * @param _renegotiationFee Agreed upon fee in ether that borrower pays for the lender for the renegitiation
     * @param _signature - The signature structure containing:
     * - signer: The address of the signer. The borrower for `acceptOffer` the lender for `acceptListing`.
     * - nonce: The nonce referred here is not the same as an Ethereum account's nonce.
     * We are referring instead to a nonce that is used by the lender or the borrower when they are first signing
     * off-chain NFTfi orders. These nonce can be any uint256 value that the user has not previously used to sign an
     * off-chain order. Each nonce can be used at most once per user within NFTfi, regardless of whether they are the
     * lender or the borrower in that situation. This serves two purposes:
     * - First, it prevents replay attacks where an attacker would submit a user's off-chain order more than once.
     * - Second, it allows a user to cancel an off-chain order by calling NFTfi.cancelLoanCommitmentBeforeLoanHasBegun()
     * , which marks the nonce as used and prevents any future loan from using the user's off-chain order that contains
     * that nonce.
     * - expiry - The date when the renegotiation offer expires
     * - lenderSignature - The ECDSA signature of the lender, obtained off-chain ahead of time, signing the
     * following combination of parameters:
     * - _loanId
     * - _newLoanDuration
     * - _newMaximumRepaymentAmount
     * - _lender
     * - _lenderNonce
     * - _expiry
     *  - loan contract address,
     * - chainId
     * @param _loanContract - Address of the loan contract where the signature is going to be used
     */
    function isValidLenderRenegotiationSignature(
        uint256 _loanId,
        uint32 _newLoanDuration,
        uint256 _newMaximumRepaymentAmount,
        uint256 _renegotiationFee,
        LoanData.Signature memory _signature,
        address _loanContract
    ) external view returns (bool) {
        return
            NFTfiSigningUtils.isValidLenderRenegotiationSignature(
                _loanId,
                _newLoanDuration,
                _newMaximumRepaymentAmount,
                _renegotiationFee,
                _signature,
                _loanContract
            );
    }
}