/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;


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

interface IERC2981 is IERC165 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be payed in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface IUniswapV2Router {
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
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

abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

abstract contract ERC2981 is IERC2981, ERC165 {
    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc IERC2981
     */
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
        external
        view
        virtual
        override
        returns (address, uint256)
    {
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[_tokenId];

        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }

        uint256 royaltyAmount = (_salePrice * royalty.royaltyFraction) / 1000;

        return (royalty.receiver, royaltyAmount);
    }

    /**
     * @dev The denominator with which to interpret the fee set in {_setTokenRoyalty} and {_setDefaultRoyalty} as a
     * fraction of the sale price. Defaults to 10000 so fees are expressed in basis points, but may be customized by an
     * override.
     */
    /**
     * @dev Sets the royalty information that all ids in this contract will default to.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */

    /**
     * @dev Removes default royalty information.
     */
    function _deleteDefaultRoyalty() internal virtual {
        delete _defaultRoyaltyInfo;
    }

    /**
     * @dev Sets the royalty information for a specific token id, overriding the global default.
     *
     * Requirements:
     *
     * - `tokenId` must be already minted.
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) internal virtual {
        require(feeNumerator <= 1000, "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: Invalid parameters");

        _tokenRoyaltyInfo[tokenId] = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Resets royalty information for the token id back to the global default.
     */
    function _resetTokenRoyalty(uint256 tokenId) internal virtual {
        delete _tokenRoyaltyInfo[tokenId];
    }
}

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
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

contract Marketplace is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    address adminAddress;
    address WFTM = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    bool marketplaceStatus;
    address swapRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    EnumerableSet.AddressSet tokenWhiteList;

    uint256 listingFee = 0 ether; // minimum price, change for what you want
    uint256 _serviceFee = 0;  // 0 % with 1000 factor

    struct CollectionRoyalty {
        address recipient;
        uint256 feeFraction;
        address setBy;
    }

    // Who can set: ERC721 owner and admin
    event SetRoyalty(
        address indexed collectionAddress,
        address indexed recipient,
        uint256 feeFraction
    );

    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;
    uint256 public defaultRoyaltyFraction = 20; // By the factor of 1000, 2%
    uint256 public royaltyUpperLimit = 100; // By the factor of 1000, 8%

    mapping(address => CollectionRoyalty) private _collectionRoyalty;

    struct Bid {
        uint256 tokenId;
        uint256 amount;
        uint256 price;
        address bidder;
        uint256 expireTimestamp;
    }

    struct TokenBids {
        EnumerableSet.AddressSet bidders;
        mapping(address => Bid) bids;
    }

    struct ListItem {
        uint8 contractType;
        uint256 tokenId;
        uint256 amount;
        uint256 price;
        address seller;
        address paymentToken;
        bool listType;
        uint256 expireTimestamp;
        uint256 time;
    }

    struct ListItemInput {
        address nftContract;
        uint8 contractType;
        uint256 tokenId;
        uint256 amount;
        uint256 price;
        address paymentToken;
        bool listType;
        uint256 expireTimestamp;
    }

    struct TransferItem {
        address nftContract;
        uint8 contractType;
        uint256 tokenId;
        uint256 amount;
        address toAccount;
    }

    struct CollectionMarket {
      EnumerableSet.UintSet tokenIdsListing;
      mapping(uint256 => ListItem) listings;
      EnumerableSet.UintSet tokenIdsWithBid;
      mapping(uint256 => TokenBids) bids;
    }

    mapping(address => CollectionMarket) private _marketplaceSales;

    // declare a event for when a item is created on marketplace
    event TokenListed(
        address indexed nftnftContract,
        uint256 indexed tokenId,
        string indexed contractType,
        ListItem listItem
    );
    event ListItemUpdated(
        address indexed nftnftContract,
        uint256 indexed tokenId,
        ListItem listItem
    );
    event TokenDelisted(
        address indexed nftContract,
        uint256 indexed tokenId,
        uint256 amount,
        ListItem listItem
    );
    event TokenBidEntered(
        address indexed nftContract,
        uint256 indexed tokenId,
        uint256 amount,
        Bid bid
    );
    event TokenBidWithdrawn(
        address indexed nftContract,
        uint256 indexed tokenId,
        Bid bid
    );
    event TokenBought(
        address indexed nftContract,
        uint256 indexed tokenId,
        address indexed buyer,
        uint256 amount,
        ListItem listing,
        uint256 serviceFee,
        uint256 royaltyFee
    );
    event TokenBidAccepted(
        address indexed nftContract,
        uint256 indexed tokenId,
        address indexed seller,
        Bid bid,
        uint256 serviceFee,
        uint256 royaltyFee
    );

    constructor() {
        adminAddress = 0x84765060A5D9A9c9ce1a03f8Ce911F0E95e7170B;
        marketplaceStatus = true;
        tokenWhiteList.add(address(0));
        tokenWhiteList.add(WFTM);
    }

    modifier onlyMarketplaceOpen() {
        require(marketplaceStatus, "Listing and bid are not enabled");
        _;
    }

    function _isTokenApproved(address nftContract, uint256 tokenId)
        private
        view
        returns (bool)
    {
        IERC721 _erc721 = IERC721(nftContract);
        try _erc721.getApproved(tokenId) returns (address tokenOperator) {
            return tokenOperator == address(this);
        } catch {
            return false;
        }
    }

    function _isAllTokenApproved(address nftContract, address owner)
        private
        view
        returns (bool)
    {
        IERC721 _erc721 = IERC721(nftContract);
        return _erc721.isApprovedForAll(owner, address(this));
    }

    function _isAllTokenApprovedERC1155(address nftContract, address owner)
        private
        view
        returns (bool)
    {
        IERC1155 _erc1155 = IERC1155(nftContract);
        return _erc1155.isApprovedForAll(owner, address(this));
    }

    function _isTokenOwner(
        address nftContract,
        uint256 tokenId,
        address account
    ) private view returns (bool) {
        IERC721 _erc721 = IERC721(nftContract);
        try _erc721.ownerOf(tokenId) returns (address tokenOwner) {
            return tokenOwner == account;
        } catch {
            return false;
        }
    }

    function _isTokenOwnerERC1155(
        address nftContract,
        uint256 tokenId,
        uint256 amount,
        address account
    ) private view returns (bool) {
        IERC1155 _erc1155 = IERC1155(nftContract);
        try _erc1155.balanceOf(account, tokenId) returns (uint256 ownedBalance) {
            return ownedBalance >= amount;
        } catch {
            return false;
        }
    }

    function _isListItemValid(address nftContract, ListItem memory listItem)
        private
        view
        returns (bool isValid)
    {
        if (
            listItem.contractType == 1 &&
            listItem.amount == 1 &&
            _isTokenOwner(nftContract, listItem.tokenId, listItem.seller) &&
            (_isTokenApproved(nftContract, listItem.tokenId) ||
                _isAllTokenApproved(nftContract, listItem.seller)) &&
            listItem.price > 0 &&
            listItem.expireTimestamp > block.timestamp
        ) {
            isValid = true;
        }
    }

    function _isListItemValidERC1155(address nftContract, ListItem memory listItem)
        private
        view
        returns (bool isValid)
    {
        if (
            listItem.contractType == 2 &&
            listItem.amount >= 1 &&
            _isTokenOwnerERC1155(nftContract, listItem.tokenId, listItem.amount, listItem.seller) &&
            (_isAllTokenApprovedERC1155(nftContract, listItem.seller)) &&
            listItem.price > 0 &&
            listItem.expireTimestamp > block.timestamp
        ) {
            isValid = true;
        }
    }

    function _isBidValid(address nftContract, Bid memory bid)
        private
        view
        returns (bool isValid)
    {
        if (
            !_isTokenOwner(nftContract, bid.tokenId, bid.bidder) &&
            bid.amount == 1 &&
            bid.price > 0 &&
            bid.expireTimestamp > block.timestamp
        ) {
            isValid = true;
        }
    }

    function _isBidValidERC1155(Bid memory bid)
        private
        view
        returns (bool isValid)
    {
        if (
            bid.price > 0 &&
            bid.amount > 0 &&
            bid.expireTimestamp > block.timestamp
        ) {
            isValid = true;
        }
    }

    // returns the listing price of the contract
    function getListingPrice() public view returns (uint256) {
        return listingFee;
    }

    function setListingPrice(uint256 price) external onlyOwner {
        require(
            price <= 2 ether,
            "Attempt to set percentage higher than 2 FTM"
        );
        listingFee = price;
    }

    function getServiceFee() public view returns (uint256) {
        return _serviceFee;
    }

    function setServiceFee(uint256 fee) external onlyOwner {
        require(
            fee <= 100,
            "Attempt to set percentage higher than 10 %"
        );
        _serviceFee = fee;
    }

    function changeMarketplaceStatus (bool status) external onlyOwner {
        require(status != marketplaceStatus, "Already set.");
        marketplaceStatus = status;
    }

    function addPaymentToken(address paymentToken) external onlyOwner {
        require(!tokenWhiteList.contains(paymentToken), "Already added");
        tokenWhiteList.add(paymentToken);
    }

    function _delistToken(address nftContract, uint256 tokenId, uint256 amount) private {
        if (_marketplaceSales[nftContract].tokenIdsListing.contains(tokenId)) {
            if (_marketplaceSales[nftContract].listings[tokenId].amount > amount) {
                _marketplaceSales[nftContract].listings[tokenId].amount -= amount;
            } else {
                delete _marketplaceSales[nftContract].listings[tokenId];
                _marketplaceSales[nftContract].tokenIdsListing.remove(tokenId);
                if (_marketplaceSales[nftContract].tokenIdsWithBid.contains(tokenId)) {
                    delete _marketplaceSales[nftContract].bids[tokenId];
                    _marketplaceSales[nftContract].tokenIdsWithBid.remove(tokenId);
                }
            }
        }
    }

    // function _removeBidOfBidder(
    //     address nftContract,
    //     uint256 tokenId,
    //     address bidder
    // ) private {
    //     if (
    //         _marketplaceSales[nftContract].bids[tokenId].bidders.contains(bidder)
    //     ) {
    //         // Step 1: delete the bid and the address
    //         delete _marketplaceSales[nftContract].bids[tokenId].bids[bidder];
    //         _marketplaceSales[nftContract].bids[tokenId].bidders.remove(bidder);

    //         // Step 2: if no bid left
    //         if (
    //             _marketplaceSales[nftContract].bids[tokenId].bidders.length() == 0
    //         ) {
    //             delete _marketplaceSales[nftContract].bids[tokenId];
    //             _marketplaceSales[nftContract].tokenIdsWithBid.remove(tokenId);
    //         }
    //     }
    // }

    function _listTokenERC1155(
        address nftContract,
        uint256 tokenId,
        uint256 amount,
        uint256 price,
        address paymentToken,
        bool listType,
        uint256 expireTimestamp
    ) internal {
        require(price > 0, "Price must be at least 1 wei");

        require(!_marketplaceSales[nftContract].tokenIdsListing.contains(tokenId), "Already listed");

        require(tokenWhiteList.contains(paymentToken), "Payment token is not allowed");

        ListItem memory listItem = ListItem(
            2,
            tokenId,
            amount,
            price,
            msg.sender,
            paymentToken,
            listType,
            expireTimestamp,
            block.timestamp
        );

        require(
            _isListItemValidERC1155(nftContract, listItem),
            "Listing is not valid"
        );
        
        _marketplaceSales[nftContract].listings[tokenId] = listItem;
        _marketplaceSales[nftContract].tokenIdsListing.add(tokenId);

        if (listingFee > 0) {
            IERC20(paymentToken).transferFrom(msg.sender, adminAddress, listingFee);
        }
        emit TokenListed(nftContract, tokenId, "erc1155", listItem);
    }

    // places an item for sale on the marketplace
    function listTokenERC1155(
        address nftContract,
        uint256 tokenId,
        uint256 amount,
        uint256 price,
        address paymentToken,
        bool listType,
        uint256 expireTimestamp
    ) public payable nonReentrant onlyMarketplaceOpen {
        _listTokenERC1155(nftContract, tokenId, amount, price, paymentToken, listType, expireTimestamp);
    }

    function _listToken(
        address nftContract,
        uint256 tokenId,
        uint256 price,
        address paymentToken,
        bool listType,
        uint256 expireTimestamp
    ) internal {
        require(price > 0, "Price must be at least 1 wei");

        require(!_marketplaceSales[nftContract].tokenIdsListing.contains(tokenId), "Already listed");

        require(tokenWhiteList.contains(paymentToken), "Payment token is not allowed");

        ListItem memory listItem = ListItem(
            1,
            tokenId,
            1,
            price,
            msg.sender,
            paymentToken,
            listType,
            expireTimestamp,
            block.timestamp
        );
        require(
            _isListItemValid(nftContract, listItem),
            "Listing is not valid"
        );

        _marketplaceSales[nftContract].listings[listItem.tokenId] = listItem;
        _marketplaceSales[nftContract].tokenIdsListing.add(listItem.tokenId);

        if (listingFee > 0) {
            payable(adminAddress).transfer(listingFee);
        }
        emit TokenListed(nftContract, listItem.tokenId, "erc721", listItem);
    }

    function listToken(
        address nftContract,
        uint256 tokenId,
        uint256 price,
        address paymentToken,
        bool listType,
        uint256 expireTimestamp
    ) public payable nonReentrant onlyMarketplaceOpen {
        _listToken(nftContract, tokenId, price, paymentToken, listType, expireTimestamp);
    }

    function updateListedToken(
        address nftContract,
        uint256 tokenId,
        uint256 price,
        uint256 amount,
        address paymentToken,
        bool listType,
        uint256 expireTimestamp
    ) public nonReentrant onlyMarketplaceOpen {
        require(price > 0, "Price must be at least 1 wei");

        require(_marketplaceSales[nftContract].tokenIdsListing.contains(tokenId), "Not listed");

        ListItem storage listItem = _marketplaceSales[nftContract].listings[tokenId];

        require(msg.sender == listItem.seller, "Not owner");
        
        listItem.tokenId = tokenId;
        listItem.amount = amount;
        listItem.price = price;
        listItem.listType = listType;
        listItem.paymentToken = paymentToken;
        listItem.expireTimestamp = expireTimestamp;

        if (listItem.contractType == 1) {
            require(
                _isListItemValid(nftContract, listItem),
                "Listing is not valid"
            );
        } else if (listItem.contractType == 2) {
            require(
                _isListItemValidERC1155(nftContract, listItem),
                "Listing is not valid"
            );
        } else {
            revert("Wrong list item");
        }

        emit ListItemUpdated(nftContract, tokenId, listItem);
    }

    function bulkListToken(
        ListItemInput[] memory listItems
    ) external payable nonReentrant onlyMarketplaceOpen {
        for (uint256 i = 0; i < listItems.length; i ++) {
            if (listItems[i].contractType == 1) {
                _listToken(listItems[i].nftContract, listItems[i].tokenId, listItems[i].price, listItems[i].paymentToken, listItems[i].listType, listItems[i].expireTimestamp);
            } else if (listItems[i].contractType == 2) {
                listTokenERC1155(listItems[i].nftContract, listItems[i].tokenId, listItems[i].amount, listItems[i].price, listItems[i].paymentToken, listItems[i].listType, listItems[i].expireTimestamp);
            } else {
                revert("Unsupported contract type");
            }
        }
    }

    function delistToken(address nftContract, uint256 tokenId, uint256 amount)
        external
    {
        require(
            _marketplaceSales[nftContract].listings[tokenId].seller == msg.sender,
            "Only token seller can delist token"
        );

        // emit TokenDelisted(
        //     nftContract,
        //     tokenId,
        //     amount,
        //     _marketplaceSales[nftContract].listings[tokenId]
        // );

        _delistToken(nftContract, tokenId, amount);
    }

    function buyToken(
        address nftContract,
        uint256 tokenId,
        uint256 amount
    ) external payable nonReentrant onlyMarketplaceOpen {

        ListItem memory listItem = _marketplaceSales[nftContract].listings[tokenId];

        if (listItem.contractType == 1) {
            require(
                _isListItemValid(nftContract, listItem),
                "Not for sale"
            );
            require(
                !_isTokenOwner(nftContract, tokenId, msg.sender),
                "Token owner can't buy their own token"
            );
        } else if (listItem.contractType == 2) {
            require(
                _isListItemValidERC1155(nftContract, listItem),
                "Not for sale"
            );
            require(
                !_isTokenOwnerERC1155(nftContract, tokenId, amount, msg.sender),
                "Token owner can't buy their own token"
            );
        } else {
            revert();
        }

        uint256 totalPrice = listItem.price.mul(listItem.amount);
        uint256 royaltyPrice;
        address recipient;
        uint256 serviceFee = totalPrice.mul(_serviceFee).div(1000);
   
        if (checkRoyalties(nftContract)) {
            (recipient, royaltyPrice) = royaltyFromERC2981(nftContract, tokenId, totalPrice);
        } else {
            CollectionRoyalty memory collectionRoyalty = royalty(nftContract);
            recipient = collectionRoyalty.recipient;
            if (recipient != address(0)) royaltyPrice = collectionRoyalty.feeFraction.mul(totalPrice).div(1000);
        }

        if (listItem.paymentToken == address(0)) {
            require(
                msg.value >= listItem.price,
                "The value send is below sale price"
            );
            if (royaltyPrice > 0) Address.sendValue(payable(recipient), royaltyPrice);
            Address.sendValue(payable(adminAddress), serviceFee);
            Address.sendValue(payable(listItem.seller), totalPrice - royaltyPrice - serviceFee);
        } else {
            if (royaltyPrice > 0) IERC20(listItem.paymentToken).safeTransferFrom(msg.sender, recipient, royaltyPrice);
            IERC20(listItem.paymentToken).safeTransferFrom(msg.sender, adminAddress, serviceFee);
            IERC20(listItem.paymentToken).safeTransferFrom(msg.sender, listItem.seller, totalPrice - royaltyPrice - serviceFee);
        }

        if (listItem.contractType == 1) {
            IERC721(nftContract).safeTransferFrom(listItem.seller, msg.sender, tokenId);
        } else if (listItem.contractType == 2) {
            IERC1155(nftContract).safeTransferFrom(listItem.seller, msg.sender, tokenId, amount, "");
        }

        emit TokenBought(
            nftContract,
            tokenId,
            msg.sender,
            amount,
            listItem,
            serviceFee,
            royaltyPrice
        );

        _delistToken(nftContract, tokenId, amount);
    }

    function buyTokenWithOtherTokens(
        address nftContract,
        uint256 tokenId,
        uint256 amount,
        address paymentToken,
        uint256 tokenAmount
    ) external nonReentrant onlyMarketplaceOpen {

        ListItem memory listItem = _marketplaceSales[nftContract].listings[tokenId];

        if (listItem.contractType == 1) {
            require(
                _isListItemValid(nftContract, listItem) &&
                !_isTokenOwner(nftContract, tokenId, msg.sender),
                "Not for sale"
            );
        } else if (listItem.contractType == 2) {
            require(
                _isListItemValidERC1155(nftContract, listItem) &&
                !_isTokenOwnerERC1155(nftContract, tokenId, amount, msg.sender),
                "Not for sale"
            );
        } else {
            revert("Not listed");
        }

        uint256 totalPrice = listItem.price.mul(listItem.amount);
        uint256 royaltyPrice;
        address recipient;
        uint256 serviceFee = totalPrice.mul(_serviceFee).div(1000);
   
        if (checkRoyalties(nftContract)) {
            (recipient, royaltyPrice) = royaltyFromERC2981(nftContract, tokenId, totalPrice);
        } else {
            CollectionRoyalty memory collectionRoyalty = royalty(nftContract);
            recipient = collectionRoyalty.recipient;
            royaltyPrice = collectionRoyalty.feeFraction.mul(totalPrice).div(1000);
        }
        address[] memory path;
        if (paymentToken == WFTM) {
            path = new address[](2);
            path[0] = WFTM;
            path[1] = listItem.paymentToken;
        } else if (listItem.paymentToken == address(0) || listItem.paymentToken == WFTM) {
            path = new address[](2);
            path[0] = paymentToken;
            path[1] = WFTM;
            
        } else {
            path = new address[](3);
            path[0] = paymentToken;
            path[1] = WFTM;
            path[2] = listItem.paymentToken;
            
        }
        IERC20(paymentToken).safeTransferFrom(msg.sender, address(this), tokenAmount);
        IERC20(paymentToken).safeApprove(swapRouter, tokenAmount);

        uint[] memory amounts = IUniswapV2Router(swapRouter).swapTokensForExactTokens(
            totalPrice,
            tokenAmount,
            path,
            address(this),
            block.timestamp
        );
        if (tokenAmount > amounts[0]) IERC20(paymentToken).safeTransfer(msg.sender, tokenAmount - amounts[0]);

        if (recipient != address(0)) IERC20(listItem.paymentToken).safeTransfer(recipient, royaltyPrice);
        IERC20(listItem.paymentToken).safeTransfer(adminAddress, serviceFee);

        IERC20(listItem.paymentToken).safeTransfer(listItem.seller, totalPrice - serviceFee - royaltyPrice);

        if (listItem.contractType == 1) {
            IERC721(nftContract).safeTransferFrom(listItem.seller, msg.sender, tokenId);
        } else if (listItem.contractType == 2) {
            IERC1155(nftContract).safeTransferFrom(listItem.seller, msg.sender, tokenId, amount, "");
        }

        emit TokenBought(
            nftContract,
            tokenId,
            msg.sender,
            amount,
            listItem,
            serviceFee,
            royaltyPrice
        );

        _delistToken(nftContract, tokenId, amount);
    }

    function enterBid(
        address nftContract,
        uint256 tokenId,
        uint256 amount,
        uint256 price,
        uint256 expireTimestamp
    )
        public nonReentrant onlyMarketplaceOpen
    {
        Bid memory bid = Bid(tokenId, amount, price, msg.sender, expireTimestamp);

        require(_marketplaceSales[nftContract].tokenIdsListing.contains(tokenId), "Not for bid");

        ListItem memory listItem = _marketplaceSales[nftContract].listings[tokenId];
        address paymentToken = listItem.paymentToken;
        if ((listItem.contractType == 1 && !_isBidValid(nftContract, bid)) || (listItem.contractType == 2 && !_isBidValidERC1155(bid))) {
            revert("Bid is not valid");
        }
        
        if (paymentToken == address(0)) {
            require(address(msg.sender).balance >= price, "Insurance money");
        } else {
            require((IERC20(paymentToken).balanceOf(msg.sender) >= price &&
                IERC20(paymentToken).allowance(msg.sender, address(this)) >= price),
                "Insurance money or not approved"
            );
        }

        _marketplaceSales[nftContract].tokenIdsWithBid.add(tokenId);
        _marketplaceSales[nftContract].bids[tokenId].bidders.add(msg.sender);
        _marketplaceSales[nftContract].bids[tokenId].bids[msg.sender] = bid;

        emit TokenBidEntered(nftContract, tokenId, amount, bid);
    }

    function accpetBid(
        address nftContract,
        uint8 contractType,
        uint256 tokenId,
        uint256 amount,
        address payable bidder,
        uint256 price
    ) external nonReentrant {
        if (contractType == 1) {
            require(
                _isTokenOwner(nftContract, tokenId, msg.sender),
                "Only token owner can accept bid of token"
            );
            require(
                _isTokenApproved(nftContract, tokenId) ||
                    _isAllTokenApproved(nftContract, msg.sender),
                "The token is not approved to transfer by the contract"
            );
        } else if (contractType == 2) {
            require(
                _isTokenOwnerERC1155(nftContract, tokenId, amount, msg.sender),
                "Only token owner can accept bid of token"
            );
            require(
                _isAllTokenApprovedERC1155(nftContract, msg.sender),
                "The token is not approved to transfer by the contract"
            );
        }

        Bid memory bid = _marketplaceSales[nftContract].bids[tokenId].bids[
            bidder
        ];
        ListItem memory listItem = _marketplaceSales[nftContract].listings[tokenId];
        require(_isBidValid(nftContract, bid), "Not valid bidder");
        require(
            bid.tokenId == tokenId &&
                bid.amount == amount &&
                bid.price == price &&
                bid.bidder == bidder,
            "This nft doesn't have a matching bid"
        );
        require(
            listItem.tokenId == tokenId &&
                listItem.amount >= amount,
            "Don't match with listing"
        );

        uint256 royaltyPrice;
        address recipient;
        uint256 totalPrice = price.mul(amount);
        uint256 serviceFee = totalPrice.mul(_serviceFee).div(1000);
        address paymentToken = _marketplaceSales[nftContract].listings[tokenId].paymentToken;
        

        if (checkRoyalties(nftContract)) {
            (recipient, royaltyPrice) = royaltyFromERC2981(nftContract, tokenId, totalPrice);
        } else {
            CollectionRoyalty memory collectionRoyalty = royalty(nftContract);
            recipient = collectionRoyalty.recipient;
            royaltyPrice = totalPrice.mul(collectionRoyalty.feeFraction).div(1000);
        }

        if (paymentToken == address(0)) {
            paymentToken = WFTM;
        }

        if (recipient != address(0)) {
            IERC20(paymentToken).safeTransferFrom({
                from: bidder,
                to: recipient,
                value: royaltyPrice
            });
        }
        if (serviceFee > 0) {
            IERC20(paymentToken).safeTransferFrom({
                from: bidder,
                to: adminAddress,
                value: serviceFee
            });
        }
        IERC20(paymentToken).safeTransferFrom({
            from: bidder,
            to: msg.sender,
            value: totalPrice - serviceFee - royaltyPrice
        });

        if (listItem.contractType == 1) {
            IERC721(nftContract).safeTransferFrom(listItem.seller, bidder, tokenId);
        } else if (listItem.contractType == 2) {
            IERC1155(nftContract).safeTransferFrom(listItem.seller, bidder, tokenId, amount, "");
        }

        if (paymentToken == address(0)) {
            IWETH(WFTM).withdraw(price - serviceFee - royaltyPrice);
        }

        emit TokenBidAccepted({
            nftContract: nftContract,
            tokenId: tokenId,
            seller: msg.sender,
            bid: bid,
            serviceFee: serviceFee,
            royaltyFee: royaltyPrice
        });
        _delistToken(nftContract, tokenId, amount);
    }

    function bulkTransfer(TransferItem[] memory items)
        external
    {
        for (uint256 i = 0; i < items.length; i ++) {
            TransferItem memory item = items[i];
            if (item.contractType == 1) {
                IERC721(item.nftContract).safeTransferFrom(msg.sender, item.toAccount, item.tokenId);
            } else {
                IERC1155(item.nftContract).safeTransferFrom(msg.sender, item.toAccount, item.tokenId, item.amount, "");
            }
        }
    }

    function getTokenListing(address nftContract, uint256 tokenId)
        public
        view
        returns (ListItem memory validListing)
    {
        ListItem memory listing = _marketplaceSales[nftContract].listings[tokenId];
        if ((listing.contractType == 1 && _isListItemValid(nftContract, listing)) || (listing.contractType == 2 && _isListItemValidERC1155(nftContract, listing))) {
            validListing = listing;
        }
    }

    function numOfTokenListings(address nftContract)
        public
        view
        returns (uint256)
    {
        return _marketplaceSales[nftContract].tokenIdsListing.length();
    }

    function getTokenListings(
        address nftContract,
        uint256 from,
        uint256 size
    ) public view returns (ListItem[] memory listings) {
        uint256 listingsCount = numOfTokenListings(nftContract);

        if (from < listingsCount && size > 0) {
            uint256 querySize = size;
            if ((from + size) > listingsCount) {
                querySize = listingsCount - from;
            }
            listings = new ListItem[](querySize);
            for (uint256 i = 0; i < querySize; i++) {
                uint256 tokenId = _marketplaceSales[nftContract]
                    .tokenIdsListing
                    .at(i + from);
                ListItem memory listing = _marketplaceSales[nftContract].listings[
                    tokenId
                ];
                if ((listing.contractType == 1 && _isListItemValid(nftContract, listing)) || (listing.contractType == 2 && _isListItemValidERC1155(nftContract, listing))) {
                    listings[i] = listing;
                }
            }
        }
    }

    function getBidderTokenBid(
        address nftContract,
        uint256 tokenId,
        address bidder
    ) public view returns (Bid memory validBid) {
        ListItem memory listItem = _marketplaceSales[nftContract].listings[tokenId];
        Bid memory bid = _marketplaceSales[nftContract].bids[tokenId].bids[
            bidder
        ];
        if ((listItem.contractType == 1 && _isBidValid(nftContract, bid)) || (listItem.contractType == 2 && _isBidValidERC1155(bid))) {
            validBid = bid;
        }
    }

    function getTokenBids(address nftContract, uint256 tokenId)
        external
        view
        returns (Bid[] memory bids)
    {
        ListItem memory listItem = _marketplaceSales[nftContract].listings[tokenId];

        uint256 bidderCount = _marketplaceSales[nftContract]
            .bids[tokenId]
            .bidders
            .length();

        bids = new Bid[](bidderCount);
        for (uint256 i; i < bidderCount; i++) {
            address bidder = _marketplaceSales[nftContract]
                .bids[tokenId]
                .bidders
                .at(i);
            Bid memory bid = _marketplaceSales[nftContract].bids[tokenId].bids[
                bidder
            ];
            if ((listItem.contractType == 1 && _isBidValid(nftContract, bid)) || (listItem.contractType == 2 && _isBidValidERC1155(bid))) {
                bids[i] = bid;
            }
        }
    }

    function getTokenHighestBid(address nftContract, uint256 tokenId)
        public
        view
        returns (Bid memory highestBid)
    {
        ListItem memory listItem = _marketplaceSales[nftContract].listings[tokenId];
        highestBid = Bid(tokenId, 1, 0, address(0), 0);
        uint256 bidderCount = _marketplaceSales[nftContract]
            .bids[tokenId]
            .bidders
            .length();
        for (uint256 i; i < bidderCount; i++) {
            address bidder = _marketplaceSales[nftContract]
                .bids[tokenId]
                .bidders
                .at(i);
            Bid memory bid = _marketplaceSales[nftContract].bids[tokenId].bids[
                bidder
            ];
            if (listItem.contractType == 1) {
                if (
                    _isBidValid(nftContract, bid) && bid.price > highestBid.price
                ) {
                    highestBid = bid;
                }
            } else if (listItem.contractType == 2) {
                if (
                    _isBidValidERC1155(bid) && bid.price > highestBid.price
                ) {
                    highestBid = bid;
                }
            }
        }
    }

    function numTokenWithBids(address nftContract)
        public
        view
        returns (uint256)
    {
        return _marketplaceSales[nftContract].tokenIdsWithBid.length();
    }

    function getTokenHighestBids(
        address nftContract,
        uint256 from,
        uint256 size
    ) public view returns (Bid[] memory highestBids) {
        uint256 tokenCount = numTokenWithBids(nftContract);

        if (from < tokenCount && size > 0) {
            uint256 querySize = size;
            if ((from + size) > tokenCount) {
                querySize = tokenCount - from;
            }
            highestBids = new Bid[](querySize);
            for (uint256 i = 0; i < querySize; i++) {
                highestBids[i] = getTokenHighestBid({
                    nftContract: nftContract,
                    tokenId: _marketplaceSales[nftContract].tokenIdsWithBid.at(
                        i + from
                    )
                });
            }
        }
    }

    function getBidderBids(
        address nftContract,
        address bidder,
        uint256 from,
        uint256 size
    ) external view returns (Bid[] memory bidderBids) {
        uint256 tokenCount = _marketplaceSales[nftContract].tokenIdsWithBid.length();

        if (from < tokenCount && size > 0) {
            uint256 querySize = size;
            if ((from + size) > tokenCount) {
                querySize = tokenCount - from;
            }
            bidderBids = new Bid[](querySize);
            for (uint256 i = 0; i < querySize; i++) {
                bidderBids[i] = getBidderTokenBid({
                    nftContract: nftContract,
                    tokenId: _marketplaceSales[nftContract].tokenIdsWithBid.at(
                        i + from
                    ),
                    bidder: bidder
                });
            }
        }
    }

    function checkRoyalties(address _contract) internal view returns (bool) {
        (bool success) = IERC165(_contract).supportsInterface(_INTERFACE_ID_ERC2981);
        return success;
    }

    function _collectionOwner(address collectionAddress)
        private
        view
        returns (address)
    {
        try Ownable(collectionAddress).owner() returns (address _owner) {
            return _owner;
        } catch {
            return address(0);
        }
    }

    function royaltyFromERC2981(
        address collectionAddress,
        uint256 tokenId,
        uint256 salePrice
    ) public view returns (address recipient, uint256 royaltyPrice) {
        (recipient, royaltyPrice) = IERC2981(collectionAddress).royaltyInfo(tokenId, salePrice);
    }

    function royalty(address collectionAddress)
        public
        view
        returns (CollectionRoyalty memory)
    {
        if (_collectionRoyalty[collectionAddress].setBy != address(0)) {
            return _collectionRoyalty[collectionAddress];
        }

        address collectionOwner = _collectionOwner(collectionAddress);
        if (collectionOwner != address(0)) {
            return
                CollectionRoyalty({
                    recipient: collectionOwner,
                    feeFraction: defaultRoyaltyFraction,
                    setBy: address(0)
                });
        }

        return
            CollectionRoyalty({
                recipient: address(0),
                feeFraction: 0,
                setBy: address(0)
            });
    }

    function setRoyalty(
        address collectionAddress,
        address newRecipient,
        uint256 feeFraction
    ) external {
        require(
            feeFraction <= royaltyUpperLimit,
            "Please set the royalty percentange below allowed range"
        );

        require(
            msg.sender == royalty(collectionAddress).recipient,
            "Only royalty recipient is allowed to set Royalty"
        );

        _collectionRoyalty[collectionAddress] = CollectionRoyalty({
            recipient: newRecipient,
            feeFraction: feeFraction,
            setBy: msg.sender
        });

        emit SetRoyalty({
            collectionAddress: collectionAddress,
            recipient: newRecipient,
            feeFraction: feeFraction
        });
    }

    function setRoyaltyByAdmin(
        address collectionAddress,
        address newRecipient,
        uint256 feeFraction
    ) onlyOwner external {
        require(
            feeFraction <= royaltyUpperLimit,
            "Please set the royalty percentange below allowed range"
        );

        _collectionRoyalty[collectionAddress] = CollectionRoyalty({
            recipient: newRecipient,
            feeFraction: feeFraction,
            setBy: msg.sender
        });

        emit SetRoyalty({
            collectionAddress: collectionAddress,
            recipient: newRecipient,
            feeFraction: feeFraction
        });
    }

    // function setRoyaltyForCollection(
    //     address collectionAddress,
    //     address newRecipient,
    //     uint256 feeFraction
    // ) external {
    //     require(
    //         feeFraction <= royaltyUpperLimit,
    //         "Please set the royalty percentange below allowed range"
    //     );

    //     require(
    //         royalty(collectionAddress).setBy == address(0),
    //         "Collection royalty recipient already set"
    //     );

    //     _collectionRoyalty[collectionAddress] = CollectionRoyalty({
    //         recipient: newRecipient,
    //         feeFraction: feeFraction,
    //         setBy: msg.sender
    //     });

    //     emit SetRoyalty({
    //         collectionAddress: collectionAddress,
    //         recipient: newRecipient,
    //         feeFraction: feeFraction
    //     });
    // }

    function updateRoyaltyUpperLimit(uint256 _newUpperLimit)
        external
        onlyOwner
    {
        royaltyUpperLimit = _newUpperLimit;
    }
}