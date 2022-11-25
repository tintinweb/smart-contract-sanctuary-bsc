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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

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
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
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

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";


interface IProxy{
    function isMintableAccount(address _address) external view returns(bool);
    function isBurnAccount(address _address) external view returns(bool);
    function isTransferAccount(address _address) external view returns(bool);
    function isPauseAccount(address _address) external view returns(bool);
}

interface IVault{
    function transferToMarketplace(address market, address seller, uint256 _tokenId, uint256 _amount) external;
}

interface IYLT{
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
    function transfer(address to, uint256 tokens) external returns (bool success);
    function approve(address spender, uint256 tokens) external returns (bool success);
}

contract YLNFTMarketplace is ERC1155Holder, ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;

    IProxy public proxy;
    IERC721 public ylnft721;
    IERC1155 public ylnft1155;
    IYLT public ylt20;
    
    address public _marketplaceOwner;
    uint256 public marketfee = 1;
    uint256 public marketcommission = 5; // = 5%

    enum State { Active, Inactive, Release}

    struct MarketItem {
        uint256 itemId;
        uint256 tokenId;
        address seller;
        address owner;
        uint256 price;
        uint256 amount;
        bool isERC721;
        State state;
    }

    event AdminListedNFT(address user, uint256 tokenId, uint256 price, uint256 amount, uint256 timestamp);
    event UserlistedNFTtoMarket(address user, uint256 tokenId, uint256 price, uint256 amount, address market, uint256 timestamp);
    event UserNFTDirectTransferto(address user, uint256 tokenId, address to, uint256 price, uint256 amount, uint256 gas, uint256 commission, uint256 timestamp);
    event AdminPauselistedNFT(address user, uint256 tokenId, address marketplace, uint256 timestamp);
    event AdminUnpauselistedNFT(address user, uint256 tokenId, uint256 amount, address marketplace, uint256 timestamp);
    event PurchasedNFT(address user, uint256 tokenId, uint256 amount, uint256 price, uint256 commission);
    event SoldNFT(uint256 tokenId, uint256 amount, address market, uint256 timestamp);
    event UserNFTtoMarketSold(uint256 tokenId, address user, uint256 price, uint256 amount, uint256 commission, uint256 timestamp);
    event AdminWithdrawFromEscrow(address admin, uint256 amount, uint256 timestamp);
    event EscrowTransferFundsToSeller(address market, uint256 price, address user); //???
    event WithdrawNFTfromMarkettoWallet(uint256 tokenId, address user, uint256 amount, uint256 commission, uint256 timestamp);
    event TransferedNFTfromMarkettoVault(uint256 tokenId, address vault, uint256 amount, uint256 timestamp);
    event TransferedNFTfromVaulttoMarket(uint256 tokenId, address vault, uint256 amount, uint256 timestamp);
    event AdminApprovalNFTwithdrawtoWallet(address admin, uint256 tokenId, address user, uint256 amount, uint256 commission, uint256 timestamp);
    event DepositNFTFromWallettoMarketApproval(uint256 tokenId, address user, uint256 amount, uint256 commission, address admin, uint256 timestamp);
    event RevertDepositFromWalletToMarket(uint256 tokenId, address user, uint256 amount, address admin, uint256 timestamp);
    event DepositNFTFromWallettoTeamsApproval(uint256 tokenId, address user, uint256 amount, uint256 commission, address admin, uint256 timestamp);
    event RevertDepositFromWalletToTeams(uint256 tokenId, address user, uint256 amount, address admin, uint256 timestamp);
    event AdminTransferNFT(address admin, uint256 tokenId, uint256 amount, address user, uint256 timestamp);
    event MarketPerCommissionSet(address admin, uint256 commission, uint256 timestamp);
    event MarketVCommisionSet(address admin, uint256 commission, uint256 timestamp);
    event MarketItemEditted(address user, uint256 tokenId, uint256 price, uint256 timestamp);

    mapping(address => bool) public marketplaceOwners;
    mapping(uint256 => MarketItem) private idToMarketItem;
    mapping(address => mapping(uint256 => bool)) depositUsers;
    mapping(address => mapping(uint256 => bool)) withdrawUsers;
    mapping(address => mapping(uint256 => bool)) depositTeamUsers;

    modifier ylOwners() {
        require(marketplaceOwners[msg.sender] == true, "You aren't the owner of marketplace");
        _;
    }

    constructor(IERC721 _ylnft721, IERC1155 _ylnft1155, IYLT _ylt20, IProxy _proxy) {
        ylnft721 = _ylnft721;
        ylnft1155 = _ylnft1155;
        ylt20 = _ylt20;
        proxy = _proxy;
        _marketplaceOwner = msg.sender;
        marketplaceOwners[msg.sender] = true;
    }

    function isMarketOwner() public view returns(bool) {
        return marketplaceOwners[tx.origin];
    }

    //get itemId
    function getItemId() public view returns(uint256) {
        return _itemIds.current();
    }

    //get item data
    function getItem(uint256 _itemId) public view returns(MarketItem memory) {
        return idToMarketItem[_itemId];
    }

    //get owner
    function getOwner(address _owner) public view returns(bool) {
        return marketplaceOwners[_owner];
    }

    // Setting Market Fee
    function setMarketFee(uint256 _fee) public ylOwners {
        marketfee = _fee;
        emit MarketVCommisionSet(msg.sender, marketfee, block.timestamp);
    }

    // Setting Market commission
    function setMarketcommission(uint256 _commission) public ylOwners {
        marketcommission = _commission;
        emit MarketVCommisionSet(msg.sender, marketcommission, block.timestamp);
    }

    //c. Marketplace Credential
    function allowCredential(address _mOwner, bool _flag) public ylOwners returns(bool) {
        marketplaceOwners[_mOwner] = _flag;
        return true;
    }

    //a. Minter listed NFT to Marketplace
    function minterListedNFT(uint256 _tokenId, uint256 _price, uint256 _amount, bool _isERC721) public returns(uint256) {
        require(proxy.isMintableAccount(msg.sender), "You aren't Minter account");
        if (_isERC721 == true){
            require(ylnft721.ownerOf(_tokenId) == msg.sender, "User haven't this token ID.");
            require(ylnft721.getApproved(_tokenId) == address(this), "NFT must be approved to market");

            ylnft721.transferFrom(msg.sender, address(this), _tokenId);
        }
        else{
            require(ylnft1155.balanceOf(msg.sender, _tokenId) >= _amount, "User haven't this token ID.");
            require(ylnft1155.isApprovedForAll(msg.sender, address(this)) == true, "NFT must be approved to market");

            ylnft1155.safeTransferFrom(msg.sender, address(this), _tokenId, _amount, "");
        }

        uint256 _itemId = 0;
        for(uint i = 1; i <= _itemIds.current(); i++) {
            if(idToMarketItem[i].tokenId == _tokenId) {
                _itemId = idToMarketItem[i].itemId;
                break;
            }
        }

        if(_itemId == 0) {
            _itemIds.increment();
            _itemId = _itemIds.current();
            idToMarketItem[_itemId] = MarketItem(
                _itemId,
                _tokenId,
                msg.sender,
                address(this),
                _price,
                _amount,
                _isERC721,
                State.Active
            );
        } else {
            idToMarketItem[_itemId].state = State.Active;
            idToMarketItem[_itemId].owner = address(this);
            idToMarketItem[_itemId].seller = msg.sender;
            idToMarketItem[_itemId].price = _price;
            idToMarketItem[_itemId].isERC721 = _isERC721;
            if(_isERC721)
                idToMarketItem[_itemId].amount = _amount;
            else
                idToMarketItem[_itemId].amount += _amount;
        }

        emit AdminListedNFT(msg.sender, _tokenId, _price, _amount, block.timestamp);
        return _itemId;
    }

    //b. Buyer listed NFT to Marketplace
    function buyerListedNFT(uint256 _tokenId, uint256 _price, uint256 _amount, bool _isERC721) public returns(uint256) {
        bool isTransferred;
        if(_isERC721){
            require(ylnft721.ownerOf(_tokenId) == msg.sender, "User haven't this token ID.");
            require(depositUsers[msg.sender][_tokenId] == true, "This token has not been approved by administrator.");
            require(ylnft721.getApproved(_tokenId) == address(this), "NFT must be approved to market");
            isTransferred = ylt20.transfer(address(this), marketfee);
            require(isTransferred, "Insufficient Fund.");

            ylnft721.transferFrom(msg.sender, address(this), _tokenId);
        }
        else{
            require(ylnft1155.balanceOf(msg.sender, _tokenId) >= _amount, "User haven't this token ID.");
            require(depositUsers[msg.sender][_tokenId] == true, "This token has not been approved by administrator.");
            require(ylnft1155.isApprovedForAll(msg.sender, address(this)) == true, "NFT must be approved to market");
            isTransferred = ylt20.transfer(address(this), marketfee);
            require(isTransferred, "Insufficient Fund.");

            ylnft1155.safeTransferFrom(msg.sender, address(this), _tokenId, _amount, "");
        }
        uint256 _itemId = 0;
        for(uint i = 1; i <= _itemIds.current(); i++) {
            if(idToMarketItem[i].tokenId == _tokenId) {
                _itemId = idToMarketItem[i].itemId;
                break;
            }
        }

        if(_itemId == 0) {
            _itemIds.increment();
            _itemId = _itemIds.current();
            idToMarketItem[_itemId] = MarketItem(
                _itemId,
                _tokenId,
                msg.sender,
                address(this),
                _price,
                _amount,
                _isERC721,
                State.Active
            );
        } else {
            idToMarketItem[_itemId].state = State.Active;
            idToMarketItem[_itemId].owner = address(this);
            idToMarketItem[_itemId].seller = msg.sender;
            idToMarketItem[_itemId].price = _price;
            idToMarketItem[_itemId].isERC721 = _isERC721;
            if(_isERC721)
                idToMarketItem[_itemId].amount = _amount;
            else
                idToMarketItem[_itemId].amount += _amount;
        }

        emit UserlistedNFTtoMarket(msg.sender, _tokenId, _price, _amount, address(this), block.timestamp);
        return _itemId;
    }

    //e. To transfer Direct
    function directTransferToBuyer(address _from, uint256 _tokenId, uint256 _price, uint256 _amount, bool _isERC721) public nonReentrant {
        uint256 startGas = gasleft();
        if(_isERC721){
            require(ylnft721.ownerOf(_tokenId) == _from, "You haven't this NFT.");
            bool isTransferred = ylt20.transfer(address(this), _price + marketfee);
            require(isTransferred, "Insufficient Fund.");
            require(ylnft721.getApproved(_tokenId) == address(this), "NFT must be approved to market");

            ylnft721.transferFrom(_from, msg.sender, _tokenId);

            isTransferred = ylt20.transfer(_from, _price);
            require(isTransferred, "Failed to send token");

            uint256 gasUsed = startGas - gasleft();
            emit UserNFTDirectTransferto(_from, _tokenId, msg.sender, _price, 1, gasUsed, marketfee, block.timestamp);
        }
        else{
            require(ylnft1155.balanceOf(_from, _tokenId) >= _amount, "You haven't this NFT.");
            bool isTransferred = ylt20.transfer(address(this), _price * _amount + marketfee);
            require(isTransferred, "Insufficient Fund.");
            require(ylnft1155.isApprovedForAll(_from, address(this)) == true, "NFT must be approved to market");

            ylnft1155.safeTransferFrom(_from, msg.sender, _tokenId, _amount, "");

            isTransferred = ylt20.transfer(_from, _price * _amount);
            require(isTransferred, "Failed to send token");

            uint256 gasUsed = startGas - gasleft();
            emit UserNFTDirectTransferto(_from, _tokenId, msg.sender, _price, _amount, gasUsed, marketfee, block.timestamp);
        }
    }

    //h. Pause
    function adminPauseToggle(uint256 _itemId, uint256 _amount, bool _flag) public {
        uint256 _tokenId = idToMarketItem[_itemId].tokenId;
        require(ylnft721.ownerOf(_tokenId) == address(this) || ylnft1155.balanceOf(address(this), idToMarketItem[_itemId].tokenId) >= idToMarketItem[_itemId].amount, "You haven't this tokenID.");
        require(idToMarketItem[_itemId].seller == msg.sender || marketplaceOwners[msg.sender] == true);
        if(_flag == true) {
            idToMarketItem[_itemId].state = State.Inactive;
            emit AdminPauselistedNFT(msg.sender, _tokenId, address(this), block.timestamp);
        } else {
            idToMarketItem[_itemId].state = State.Active;
            emit AdminUnpauselistedNFT(msg.sender, _tokenId, _amount, address(this), block.timestamp);
        }
    }

    //i. withdraw NFT
    function withdrawNFT(uint256 itemId, uint256 _amount, bool _isERC721) public nonReentrant {
        uint256 _tokenId = idToMarketItem[itemId].tokenId;
        require(idToMarketItem[itemId].seller == msg.sender, "You haven't this NFT");
        bool isTransferred = ylt20.transfer(address(this), marketfee);
        require(isTransferred, "Insufficient Fund.");
        require(withdrawUsers[msg.sender][itemId] == true, "This token has not been approved by admin");
        if(_isERC721){
            ylnft721.transferFrom(address(this), msg.sender, _tokenId);
            idToMarketItem[itemId].state = State.Release;
            idToMarketItem[itemId].owner = msg.sender;
        }
        else{
            ylnft1155.safeTransferFrom(address(this), msg.sender, _tokenId, _amount, "");
            if(idToMarketItem[itemId].amount == _amount){
                idToMarketItem[itemId].state = State.Release;
                idToMarketItem[itemId].owner = msg.sender;
            }
            else{
                idToMarketItem[itemId].amount -= _amount;
            }
        }
        emit WithdrawNFTfromMarkettoWallet(_tokenId, msg.sender, _amount, marketfee, block.timestamp);
    }

    //j. deposit NFT
    function depositNFT(uint256 _tokenId, uint256 _amount, uint256 _price, bool _isERC721) public returns(uint256) {
        require(ylnft721.ownerOf(_tokenId) == msg.sender || ylnft1155.balanceOf(msg.sender, _tokenId) >= _amount, "You haven't this NFT");
        bool isTransferred = ylt20.transfer(address(this), marketfee);
        require(isTransferred, "Insufficient Fund.");
        require(depositUsers[msg.sender][_tokenId] == true, "This token has not been approved by admin.");
        require(ylnft721.getApproved(_tokenId) == address(this) || ylnft1155.isApprovedForAll(msg.sender, address(this)) == true, "NFT must be approved to market");

        if(_isERC721)
            ylnft721.transferFrom(msg.sender, address(this), _tokenId);
        else
            ylnft1155.safeTransferFrom(msg.sender, address(this), _tokenId, _amount, "");

        uint256 _itemId = 0;
        for(uint i = 1; i <= _itemIds.current(); i++) {
            if(idToMarketItem[i].tokenId == _tokenId) {
                _itemId = idToMarketItem[i].itemId;
                break;
            }
        }

        if(_itemId == 0) {
            _itemIds.increment();
            _itemId = _itemIds.current();
            idToMarketItem[_itemId] = MarketItem(
                _itemId,
                _tokenId,
                msg.sender,
                address(this),
                _price,
                _amount,
                _isERC721,
                State.Active
            );
        } else {
            idToMarketItem[_itemId].state = State.Active;
            idToMarketItem[_itemId].owner = address(this);
            idToMarketItem[_itemId].seller = msg.sender;
            idToMarketItem[_itemId].price = _price;
            idToMarketItem[_itemId].isERC721 = _isERC721;
            if(_isERC721)
                idToMarketItem[_itemId].amount = _amount;
            else
                idToMarketItem[_itemId].amount += _amount;
        }

        return _itemId;
    }

    // deposit approval from Admin
    function depositApproval(address _user, uint256 _tokenId, uint256 _amount, bool _flag) public ylOwners {
        require(ylnft721.ownerOf(_tokenId) == _user || ylnft1155.balanceOf(_user, _tokenId) >= _amount, "The User aren't owner of this token.");
        depositUsers[_user][_tokenId] = _flag;
        if(_flag == true) {
            emit DepositNFTFromWallettoMarketApproval(_tokenId, _user, _amount, marketfee, msg.sender, block.timestamp);
        } else {
            emit RevertDepositFromWalletToMarket(_tokenId, _user, _amount, msg.sender, block.timestamp);
        }
    }

    // withdraw approval from Admin
    function withdrawApproval(address _user, uint256 _itemId, uint256 _amount, bool _flag) public ylOwners {
        require(idToMarketItem[_itemId].seller == _user, "You don't owner of this NFT.");
        require(ylnft721.ownerOf(idToMarketItem[_itemId].tokenId) == address(this) || ylnft1155.balanceOf(address(this), idToMarketItem[_itemId].tokenId) >= _amount , "This token don't exist in market.");
        withdrawUsers[_user][_itemId] = _flag;
        if(_flag == true) {
            emit AdminApprovalNFTwithdrawtoWallet(msg.sender, idToMarketItem[_itemId].tokenId, _user, _amount, marketfee, block.timestamp);
        }
    }

    //k. To transfer the NFTs to his team(vault)
    function transferToVault(uint256 _itemId, uint256 _amount, address _vault, bool _isERC721) public nonReentrant returns(uint256) {
        uint256 _tokenId = idToMarketItem[_itemId].tokenId;
        require(ylnft721.ownerOf(_tokenId) == address(this) || ylnft1155.balanceOf(address(this), _tokenId) >= _amount, "This token didn't list on marketplace");
        require(idToMarketItem[_itemId].seller == msg.sender, "You don't owner of this token");
        require(depositTeamUsers[msg.sender][_itemId] == true, "This token has not been approved by admin");
        
        if(_isERC721){
            ylnft721.transferFrom(address(this), _vault, _tokenId);
            idToMarketItem[_itemId].state = State.Release;
            idToMarketItem[_itemId].owner = _vault;
        }
        else{
            ylnft1155.safeTransferFrom(address(this), _vault, _tokenId, _amount, "");
            if(idToMarketItem[_itemId].amount == _amount){
                idToMarketItem[_itemId].state = State.Release;
                idToMarketItem[_itemId].owner = _vault;
            }
            else
                idToMarketItem[_itemId].amount -= _amount;
        }
        emit TransferedNFTfromMarkettoVault(_tokenId, _vault, _amount, block.timestamp);
        return _tokenId;
    }

    // team approval
    function depositTeamApproval(address _user, uint256 _itemId, uint256 _amount, bool _flag) public ylOwners {
        require(ylnft721.ownerOf(idToMarketItem[_itemId].tokenId) == address(this) || ylnft1155.balanceOf(address(this), idToMarketItem[_itemId].tokenId) >= _amount, "This token don't exist in market");
        require(idToMarketItem[_itemId].seller == _user, "The user isn't the owner of token");
        depositTeamUsers[_user][_itemId] = _flag;
        if(_flag == true) {
            emit DepositNFTFromWallettoTeamsApproval(idToMarketItem[_itemId].tokenId, _user, _amount, marketfee, msg.sender, block.timestamp);
        } else {
            emit RevertDepositFromWalletToTeams(idToMarketItem[_itemId].tokenId, _user, _amount, msg.sender, block.timestamp);
        }
    }

    //l. transfer from vault to marketplace
    function transferFromVaultToMarketplace(uint256 _tokenId, address _vault, uint256 _price, uint256 _amount, bool _isERC721) public {
        require(ylnft721.ownerOf(_tokenId) == _vault || ylnft1155.balanceOf(_vault, _tokenId) >= _amount, "The team haven't this token.");
        IVault vault = IVault(_vault);
        vault.transferToMarketplace(address(this), msg.sender, _tokenId, _amount);// Implement this function in the Vault Contract.

        uint256 _itemId = 0;
        for(uint i = 1; i <= _itemIds.current(); i++) {
            if(idToMarketItem[i].tokenId == _tokenId) {
                _itemId = idToMarketItem[i].itemId;
                break;
            }
        }

        if(_itemId == 0) {
            _itemIds.increment();
            _itemId = _itemIds.current();
            idToMarketItem[_itemId] = MarketItem(
                _itemId,
                _tokenId,
                msg.sender,
                address(this),
                _price,
                _amount,
                _isERC721,
                State.Active
            );
        } else {
            idToMarketItem[_itemId].state = State.Active;
            idToMarketItem[_itemId].owner = address(this);
            idToMarketItem[_itemId].seller = msg.sender;
            idToMarketItem[_itemId].isERC721 = _isERC721;
            if(_isERC721)
                idToMarketItem[_itemId].amount = _amount;
            else
                idToMarketItem[_itemId].amount += _amount;
        }

        emit TransferedNFTfromVaulttoMarket(_tokenId, _vault, _amount, block.timestamp);
    }

    //o.
    function adminTransfer(address _to, uint256 _itemId, uint256 _amount, bool _isERC721) public ylOwners {
        require(ylnft721.ownerOf(idToMarketItem[_itemId].tokenId) == address(this) || ylnft1155.balanceOf(address(this), idToMarketItem[_itemId].tokenId) >= _amount, "This contract haven't this NFT.");
        bool isTransferred = ylt20.transfer(address(this), idToMarketItem[_itemId].price);
        require(isTransferred, "Insufficient Fund.");
        uint256 _tokenId = idToMarketItem[_itemId].tokenId;
        if(_isERC721)
            ylnft721.transferFrom(address(this), _to, _tokenId);
        else
            ylnft1155.safeTransferFrom(address(this), _to, _itemId, _amount, "");
        isTransferred = ylt20.transfer(idToMarketItem[_itemId].seller, idToMarketItem[_itemId].price);
        require(isTransferred, "Failed to send token");
        if(_isERC721){
            idToMarketItem[_itemId].owner = _to;
            idToMarketItem[_itemId].state = State.Release;
        }
        else{
            if(idToMarketItem[_itemId].amount == _amount){
                idToMarketItem[_itemId].owner = _to;
                idToMarketItem[_itemId].state = State.Release;
            }
            else{
                idToMarketItem[_itemId].amount -= _amount;
            }
        }

        emit AdminTransferNFT(msg.sender, _tokenId, _amount, _to, block.timestamp);
    }

    // Marketplace Listed NFTs
    function fetchMarketItems() public view returns(MarketItem[] memory) {
        uint256 total = _itemIds.current();
        
        uint256 itemCount = 0;
        for(uint i = 1; i <= total; i++) {
            if(idToMarketItem[i].state == State.Active && idToMarketItem[i].owner == address(this)) {
                itemCount++;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        uint256 index = 0;
        for(uint i = 1; i <= total; i++) {
            if(idToMarketItem[i].state == State.Active && idToMarketItem[i].owner == address(this)) {
                items[index] = idToMarketItem[i];
                index++;
            }
        }

        return items;
    }

    // My listed NFTs
    function fetchMyItems() public view returns(MarketItem[] memory) {
        uint256 total = _itemIds.current();

        uint itemCount = 0;
        for(uint i = 1; i <= total; i++) {
            if( idToMarketItem[i].state == State.Active 
                && idToMarketItem[i].seller == msg.sender
                && idToMarketItem[i].owner == address(this)) {
                itemCount++;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        uint256 index = 0;
        for(uint i = 1; i <= total; i++) {
            if( idToMarketItem[i].state == State.Active 
                && idToMarketItem[i].seller == msg.sender
                && idToMarketItem[i].owner == address(this)) {
                items[index] = idToMarketItem[i];
                index++;
            }
        }
        return items;
    }

    // Purchased NFT
    function MarketItemSale(uint256 itemId, uint256 _amount, bool _isERC721) public nonReentrant returns(uint256) {
        bool isTransferred = ylt20.transfer(address(this), idToMarketItem[itemId].price + marketfee);
        require(isTransferred, "Insufficient Fund.");
        require(idToMarketItem[itemId].seller != msg.sender, "This token is your NFT.");
        require(idToMarketItem[itemId].owner == address(this), "This NFT don't exist in market");
        if(_isERC721)
            ylnft721.transferFrom(address(this), msg.sender, idToMarketItem[itemId].tokenId);
        else
            ylnft1155.safeTransferFrom(address(this), msg.sender, idToMarketItem[itemId].tokenId, _amount, "");
        isTransferred = ylt20.transfer(idToMarketItem[itemId].seller, idToMarketItem[itemId].price);
        require(isTransferred, "Failed to send Ether to the seller");
        if(_isERC721){
            idToMarketItem[itemId].state = State.Release;
            idToMarketItem[itemId].owner = msg.sender;
        }
        else{
            if(idToMarketItem[itemId].amount == _amount){
                idToMarketItem[itemId].state = State.Release;
                idToMarketItem[itemId].owner = msg.sender;
            }
            else
                idToMarketItem[itemId].amount -= _amount;
        }

        emit UserNFTtoMarketSold(idToMarketItem[itemId].tokenId, idToMarketItem[itemId].seller, idToMarketItem[itemId].price, _amount, marketfee, block.timestamp);
        emit SoldNFT(idToMarketItem[itemId].tokenId, _amount, address(this), block.timestamp);
        emit PurchasedNFT(msg.sender, idToMarketItem[itemId].tokenId, _amount, idToMarketItem[itemId].price, marketfee);

        return idToMarketItem[itemId].tokenId;
    }

    //withdraw token
    function withdrawToken(uint256 _amount) public ylOwners nonReentrant {
        require(ylt20.balanceOf(address(this)) >= _amount, "insufficient fund");
        (bool sent) = ylt20.transfer(msg.sender, _amount);
        require(sent, "Failed to send token");
        emit AdminWithdrawFromEscrow(msg.sender, _amount, block.timestamp);
    }

    function editMarketItem(uint256 _itemId, uint256 _price) public {
        require(idToMarketItem[_itemId].state == State.Active, "This item is not active on marketplace");
        require(idToMarketItem[_itemId].seller == msg.sender, "You can't edit this market item");
        idToMarketItem[_itemId].price = _price;
        emit MarketItemEditted(msg.sender, idToMarketItem[_itemId].tokenId, _price, block.timestamp);
    }
}