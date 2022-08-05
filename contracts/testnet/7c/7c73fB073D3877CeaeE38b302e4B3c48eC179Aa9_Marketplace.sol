/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

// SPDX-License-Identifier: GPL-3.0

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

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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

// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;


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

pragma solidity >=0.7.0 <0.9.0;


contract Marketplace {

    IERC721Metadata public estateCollection;
    address public admin;

    constructor(address _estateCollection, address _admin)  {
        estateCollection = IERC721Metadata(_estateCollection);
        admin = _admin;
    }

    struct Estate {
        uint256 estateID;
        address seller;
        uint256 amount;
        address buyer;
        bool listed;
        bool verified;
        bool dealInitated;
        bool paymentIssued;
        bool dealClosed;
    }

    mapping(uint256 => Estate) public estates;

    modifier onlyAdmin(){
        require(msg.sender == admin,"ONLY_ADMIN_CAN_CALL_THIS_FUNCTION");
        _;
    }

    function listEstate(uint256 _estateID, uint256 _cost) public {
        require(estateCollection.ownerOf(_estateID) == msg.sender);
        require(estates[_estateID].listed == false,"ESTATE_ALREADY_LISTED");
        require(estateCollection.ownerOf(_estateID)== msg.sender,"YOU_ARE_NOT_OWNER_OF_THE_ESTATE");
       
        Estate memory newEstate = Estate(
            _estateID, 
            msg.sender,
            _cost,
            0x000000000000000000000000000000000000dEaD,
            true,
            false,
            false,
            false,
            false
        );

        estates[_estateID] = newEstate;
    }

    function verifyEstate(uint256 _estateID) public onlyAdmin {
        require(estates[_estateID].listed, "ESTATE_NOT_LISTED_YET");
        require(!estates[_estateID].verified, "ESTATE_ALREADY_VERIFIED");
        estates[_estateID].verified = true;
    }

    function initateDeal(uint256 _estateID, address _buyer) public {
        require(estates[_estateID].verified, "ESTATE_NOT_VERIFIED");
        require(!estates[_estateID].dealInitated, "DEAL_ALREADY_INITIATED");
        require(estates[_estateID].seller == msg.sender, "ONLY_OWNER_OF_ESTATE_CAN_INITIATE_DEAL");
         require(estateCollection.isApprovedForAll(estateCollection.ownerOf(_estateID), address(this)),"ESTATE_NOT_APPROVED");
        estates[_estateID].dealInitated = true;
        estates[_estateID].buyer = _buyer;
    }

    function makePayment(uint256 _estateID) public payable {
        require(estates[_estateID].verified, "DEAL_NOT_INITIATED");
        require(msg.value == estates[_estateID].amount, "INCORRECT_AMOUNT");
        require(!estates[_estateID].paymentIssued, "PAYMENT_ALREADY_ISSUED");
        estates[_estateID].paymentIssued = true;
    }

    function releasePayment(uint256 _estateID) public {
        require(estates[_estateID].paymentIssued, "PAYMENT_NOT_ISSUED_BY_BUYER");
        require(!estates[_estateID].dealClosed, "DEAL_WAS_CLOSED");
        require(msg.sender == estates[_estateID].buyer, "ONLY_BUYER");
        payable(estates[_estateID].seller).transfer(estates[_estateID].amount);
        estates[_estateID].dealClosed = true;
    }

    function updateAdmin(address _newAdmin) public onlyAdmin {
        admin = _newAdmin;
    }

}