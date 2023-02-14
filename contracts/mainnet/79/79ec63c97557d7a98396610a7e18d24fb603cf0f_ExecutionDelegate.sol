/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

// Sources flattened with hardhat v2.12.3 https://hardhat.org

// File contracts/libraries/OrderStructs.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;


struct MakerOrder {
    bool side; // true --> ask / false --> bid
    address signer; // signer of the maker order
    address policy; // policy for trade execution (e.g., DutchAuction, StandardSaleForFixedPrice)
    address payment; // payment currency (e.g., WETH)
    uint256 nonce; // order nonce (must be unique unless new maker order is meant to override existing one e.g., lower ask price)
    uint256 startTime; // startTime in timestamp
    uint256 endTime; // endTime in timestamp
    bytes params; // additional parameters
    uint8 v; // v: parameter (27 or 28)
    bytes32 r; // r: parameter
    bytes32 s; // s: parameter
}

struct TakerOrder {
    bool side;                      // true --> ask / false --> bid
    address taker;                  // msg.sender
    Fulfillment[] offerComponents;  // offer items
}

struct Fulfillment {
    uint256 orderIndex;
    uint256 itemIndex;
}

struct Properties {
    ItemType itemType;  // item type
    address collection; // collection address
    uint256 royaltyFee;
    address royaltyFeeRecipient;
    uint256 price;
    uint256 tokenId;
    uint256 amount;
}

struct AdvanceOrder {
    address policy;
    address payment;
    address signer;
    uint256 nonce;
    Properties[] items;        // order items
    bytes32 orderHash;
}

enum ItemType {
    NATIVE,  // 0: ETH on mainnet, MATIC on polygon, etc.

    ERC20,   // 1: ERC20 items (ERC777 and ERC20 analogues could also technically work)

    ERC721,  // 2: ERC721 items

    ERC1155, // 3: ERC1155 items

    ERC721_WITH_CRITERIA, // 4: ERC721 items where a number of tokenIds are supported

    ERC1155_WITH_CRITERIA // 5: ERC1155 items where a number of ids are supported
}

struct ERC721NFT {
    address collection;
    uint256[] tokenIds;
}

struct ERC1155NFT {
    address collection;
    uint256[] tokenIds;
    uint256[] amounts;
}


// File contracts/interfaces/IExecutionDelegate.sol

pragma solidity 0.8.13;

interface IExecutionDelegate { 

	function transferERC721Unsafe(
		address collection, 
		address from, 
		address to, 
		uint256 tokenId
	) external; 

	function transferERC721(
		address collection,
		address from,
		address to,
		uint256 tokenId
	) external;

	function transferERC1155(
		address collection,
		address from,
		address to,
		uint256 tokenId,
		uint256 amount
	) external;

	function transferERC20(
		address token,
		address from,
		address to,
		uint256 amount
	) external returns (bool);

    function batchTransferNFT(
        ERC721NFT[] calldata erc721nfts,
        ERC1155NFT[] calldata erc1155nfts,
        address to
    ) external;

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

// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

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


// File @openzeppelin/contracts/token/ERC1155/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

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


// File contracts/ExecutionDelegate.sol

pragma solidity 0.8.13;
pragma abicoder v2;






/**
 * @title ExecutionDelegate
 * @dev Proxy contract to manage user token approvals
 */
contract ExecutionDelegate is IExecutionDelegate, Ownable {

    mapping(address => bool) public contracts;
    mapping(address => bool) public revokedApproval;

    modifier approvedContract() {
        require(contracts[msg.sender], "Contract is not approved to make transfers");
        _;
    }

    event ApproveContract(address indexed _contract);
    event DenyContract(address indexed _contract);

    event RevokeApproval(address indexed user);
    event GrantApproval(address indexed user);

    /**
     * @dev Approve contract to call transfer functions
     * @param _contract address of contract to approve
     */
    function approveContract(address _contract) onlyOwner external {
        contracts[_contract] = true;
        emit ApproveContract(_contract);
    }

    /**
     * @dev Revoke approval of contract to call transfer functions
     * @param _contract address of contract to revoke approval
     */
    function denyContract(address _contract) onlyOwner external {
        contracts[_contract] = false;
        emit DenyContract(_contract);
    }

    /**
     * @dev Block contract from making transfers on-behalf of a specific user
     */
    function revokeApproval() external {
        revokedApproval[msg.sender] = true;
        emit RevokeApproval(msg.sender);
    }

    /**
     * @dev Allow contract to make transfers on-behalf of a specific user
     */
    function grantApproval() external {
        revokedApproval[msg.sender] = false;
        emit GrantApproval(msg.sender);
    }

    /**
     * @dev Transfer ERC721 token using `transferFrom`
     * @param collection address of the collection
     * @param from address of the sender
     * @param to address of the recipient
     * @param tokenId tokenId
     */
    function transferERC721Unsafe(address collection, address from, address to, uint256 tokenId)
        approvedContract
        external
    {
        require(revokedApproval[from] == false, "User has revoked approval");
        IERC721(collection).transferFrom(from, to, tokenId);
    }

    /**
     * @dev Transfer ERC721 token using `safeTransferFrom`
     * @param collection address of the collection
     * @param from address of the sender
     * @param to address of the recipient
     * @param tokenId tokenId
     */
    function transferERC721(address collection, address from, address to, uint256 tokenId)
        approvedContract
        external
    {
        require(revokedApproval[from] == false, "User has revoked approval");
        IERC721(collection).safeTransferFrom(from, to, tokenId);
    }

    /**
     * @dev Transfer ERC1155 token using `safeTransferFrom`
     * @param collection address of the collection
     * @param from address of the sender
     * @param to address of the recipient
     * @param tokenId tokenId
     * @param amount amount
     */
    function transferERC1155(address collection, address from, address to, uint256 tokenId, uint256 amount)
        approvedContract
        external
    {
        require(revokedApproval[from] == false, "User has revoked approval");
        IERC1155(collection).safeTransferFrom(from, to, tokenId, amount, "");
    }

    /**
     * @dev Transfer ERC20 token
     * @param token address of the token
     * @param from address of the sender
     * @param to address of the recipient
     * @param amount amount
     */
    function transferERC20(address token, address from, address to, uint256 amount)
        approvedContract
        external
        returns (bool)
    {
        require(revokedApproval[from] == false, "User has revoked approval");
        return IERC20(token).transferFrom(from, to, amount);
    }

    /**
     * @dev Batch Transfer ERC721 or ERC1155 token
     * @param erc721nfts erc721 tokens
     * @param erc1155nfts erc1155 tokens
     * @param to recipient
     */
    function batchTransferNFT(
        ERC721NFT[] calldata erc721nfts,
        ERC1155NFT[] calldata erc1155nfts,
        address to
    ) external override {
        require(to != address(0), "Transfer: Address is invalid");

        for (uint256 i = 0; i < erc721nfts.length; i++) {
            IERC721 erc721 = (IERC721)(erc721nfts[i].collection);
            for (uint256 j = 0; j < erc721nfts[i].tokenIds.length; j++) {
                erc721.safeTransferFrom(
                    msg.sender,
                    to,
                    erc721nfts[i].tokenIds[j]
                );
            }
        }

        for (uint256 i = 0; i < erc1155nfts.length; i++) {
            IERC1155 erc1155 = (IERC1155)(erc1155nfts[i].collection);
            erc1155.safeBatchTransferFrom(
                msg.sender,
                to,
                erc1155nfts[i].tokenIds,
                erc1155nfts[i].amounts,
                ""
            );
        }
    }

}