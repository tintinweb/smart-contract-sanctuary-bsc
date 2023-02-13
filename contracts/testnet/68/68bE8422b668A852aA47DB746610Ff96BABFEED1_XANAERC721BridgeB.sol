/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)
pragma solidity =0.8.17;

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


// File @openzeppelin/contracts/token/ERC721/[email protected]
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


// File contracts/targetChainBridge.sol
interface IERC721MintBurn {
    function mint(address owner, uint256 tokenId) external;
    function burn(uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address owner);
}


contract XANAERC721BridgeB {
    constructor() {
        owner = msg.sender;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    address public owner;
    uint256 public depositId;
    uint256 public depositLimit = 5;
    uint256 public bridgeFee = 0.001 ether;

    // target collection address > source collection address
    mapping(address => address) public sourceCollectionInfo;

    // source collection address > source chain Id
    mapping(address => uint256) public sourceCollectionChain;

    // source chainId > source chain collection address > target collection address
    mapping(uint256 => mapping(address => address)) public collectionPair;

    // collection>nftId>status of deposit/release
    mapping(address => mapping(uint256 => depositData)) public nftDeposits;

    struct depositData {
        bool _burned;
        bool _minted;
        uint256 _sourceChainId;
    }

    event Deposit(address owner, address targetCollection, uint256 nftId, address sourceCollection, uint256 sourceChainId);

    modifier onlyOwner {
        require(msg.sender == owner, "caller is not owner");
        _;
    }

    function mintNft(address _user, address _sourceCollectionAddress, uint256 _sourceChainId, uint256 _nftId) external onlyOwner {
        // get target collection address mapped against source collection and mint
        IERC721MintBurn(collectionPair[_sourceChainId][_sourceCollectionAddress]).mint(_user, _nftId);
        nftDeposits[collectionPair[_sourceChainId][_sourceCollectionAddress]][_nftId] = depositData(false, true, _sourceChainId);
    }

    function deposit(address _targetCollection, uint256 _nftId) public payable {
        require(msg.value >= bridgeFee, "required fee not sent");

        address sourceCollection = sourceCollectionInfo[_targetCollection];
        uint256 sourceChainId = sourceCollectionChain[sourceCollection];
        
        require(collectionPair[sourceChainId][sourceCollection] != address(0), "collection not supported");
        require(IERC721MintBurn(_targetCollection).ownerOf(_nftId) == msg.sender, "not owner of nft");
        IERC721MintBurn(_targetCollection).burn(_nftId);
    
        nftDeposits[collectionPair[sourceChainId][sourceCollection]][_nftId]._burned = true;
        nftDeposits[collectionPair[sourceChainId][sourceCollection]][_nftId]._minted = false;

        // send remaining ether back
        if (msg.value > bridgeFee) {
            (bool sent,) = msg.sender.call{value: msg.value - bridgeFee}("");
            require(sent, "failed to return extra value");
        }

        emit Deposit(msg.sender, _targetCollection, _nftId, sourceCollection, sourceChainId);
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    function addCollectionSupport(uint256 _sourceChainId, address _sourceCollectionAddress, address _targetCollection) external onlyOwner {
        collectionPair[_sourceChainId][_sourceCollectionAddress] = _targetCollection;
        sourceCollectionInfo[_targetCollection] = _sourceCollectionAddress;
        sourceCollectionChain[_sourceCollectionAddress] = _sourceChainId;
    }

    function removeCollectionSupport(uint256 _sourceChainId, address _sourceCollectionAddress, address _targetCollection) external onlyOwner {
        collectionPair[_sourceChainId][_sourceCollectionAddress] = address(0);
        sourceCollectionInfo[_targetCollection] = address(0);
        sourceCollectionChain[_sourceCollectionAddress] = 0;
    }

    function setBulkDepositLimit(uint256 _newLimit) external onlyOwner {
        depositLimit = _newLimit;
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}