/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

// SPDX-License-Identifier: MIT
// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/IERC165.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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

pragma solidity ^0.8.0;

contract BuyAndSale
{

    event SaleCreated(uint256 tokenId, address seller, uint256 price);
    event NFTBuySuccessful(uint256 tokenId, address from, address to, uint256 price);

    struct SaleInformation {
        uint256 price;
        bool flag;
        address seller;
    }

    uint256 private _developerFees = 1.5 * 10**14;

    mapping(uint256 => SaleInformation) private allSales;
    address payable private  _owner;
    address private _nftJagContractAddress = 0x4107aB1C2d03b9ceC5f9b397E33244b101BBe792;

    constructor() {
        _owner = payable(msg.sender);
    }

    function putOnSale(uint256 _tokenId, uint256 _price) external payable {
        require(IERC721(_nftJagContractAddress).ownerOf(_tokenId) == msg.sender, "You are not owner of this token");
        require(!allSales[_tokenId].flag, "Token is already on sale");
        require(_price > 0, "Token Price should be atleast 1 wei");
        require(msg.value > _developerFees);
        IERC721(_nftJagContractAddress).transferFrom(msg.sender, address(this), _tokenId);
        _setSale(_tokenId, _price, msg.sender);
        allSales[_tokenId].flag = true;
        _owner.transfer(_developerFees);
        emit SaleCreated(_tokenId, msg.sender, _price);
    }

    function cancelSale(uint256 _tokenId) external 
    {
        require(allSales[_tokenId].flag, "This NFT is not on sale");
        require(msg.sender == allSales[_tokenId].seller, "This is not your NFT");
        allSales[_tokenId].flag = false;
        IERC721(_nftJagContractAddress).transferFrom(address(this), msg.sender, _tokenId);
        _setSale(_tokenId, 0, address(0));
    }

    function buyNFT(uint256 _tokenId) external payable 
    {
        require(allSales[_tokenId].flag, "This NFT is not on sale");
        require(allSales[_tokenId].seller != msg.sender, "Owner cannot buy his own nft");
        require(msg.value >= (allSales[_tokenId].price + _developerFees), "You are paying less");
        allSales[_tokenId].flag = false;
        uint256 _price = allSales[_tokenId].price;
        uint256 exceededValue = msg.value - (_price + _developerFees);
        address _tokenOwner = allSales[_tokenId].seller;
        IERC721(_nftJagContractAddress).transferFrom(address(this), msg.sender, _tokenId);
        payable(_tokenOwner).transfer(_price);
        _owner.transfer(_developerFees);
        payable(msg.sender).transfer(exceededValue);
        _setSale(_tokenId, 0, address(0));
        emit NFTBuySuccessful(_tokenId, _tokenOwner, msg.sender, _price);
    }

    function changePrice(uint256 _tokenId, uint256 _newPrice) external {
        require(allSales[_tokenId].flag, "This NFT is not on sale");
        require(allSales[_tokenId].seller == msg.sender, "You are not owner of this token");
        allSales[_tokenId].price = _newPrice;
    }

    function _setSale(uint256 _tokenId, uint256 _price, address _seller) private
    {
        allSales[_tokenId].price = _price;
        allSales[_tokenId].seller = _seller;
    }

    function isOnSale(uint256 _tokenId) external view returns(bool){
        return allSales[_tokenId].flag;
    }

    function getPrice(uint256 _tokenId) external view returns(uint256) {
        return allSales[_tokenId].price + _developerFees;
    }

    function getSeller(uint256 _tokenId) external view returns(address) {
        return allSales[_tokenId].seller;
    }
}