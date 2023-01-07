/**
 *Submitted for verification at BscScan.com on 2023-01-07
*/

//SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.14;

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
contract Clones {

    /**
        @dev Deploys and returns the address of a clone of address(this
        Created by DeFi Mark To Allow Clone Contract To Easily Create Clones Of Itself
        Without redundancy
     */
    function clone() external returns(address) {
        return _clone(address(this));
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function _clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }
}

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

interface INonFungibleToken is IERC165 {

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

interface IFractionalAsset is INonFungibleToken {

    /**
        Returns The URI To An Image Representing `tokenId`
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);

    /**
        Returns The URI Associated With The Collection
     */
    function URI() external view returns (string memory);

    /**
        Returns The Name Of A Collection
     */
    function name() external view returns (string memory);

    /**
        Returns The Symbol (Ticker) Of A Collection
     */
    function symbol() external view returns (string memory);

    /**
        Returns The Number Of Fractions This NFT Is Split Into
     */
    function numFractions() external view returns (uint256);

    /**
        Initializes Fraction
     */
    function __init__(
        string calldata name_,
        string calldata symbol_,
        string calldata baseURI_,
        uint256 number_of_fractions,
        address[] calldata mintTokens,
        uint256[] calldata costs
    ) external;
}

interface IDatabase {
    function isVerified(address account) external view returns (bool);
    function isAuthorized(address account) external view returns (bool);
}

contract FractionalAssetManager is Context {

    /**
        Master Database Which Interacts With KYC And Auth Databases
     */
    IDatabase public immutable Database;

    /**
        Implementation Contract
     */
    address public implementation;

    /**
        List Of All Fractionalized Assets
     */
    address[] public allAssets;

    /**
        Mapping From Fractionalized Asset To Index In Array
     */
    mapping ( address => uint256 ) public assetIndex;

    /**
        Ensures Caller Is Authorized To Call Restricted Functions
     */
    modifier onlyAuthorized() {
        require(
            Database.isAuthorized(_msgSender()) == true,
            'Not Authorized To Call'
        );
        _;
    }

    constructor(
        address implementation_,
        address DB
    ) {
        implementation = implementation_;
        Database = IDatabase(DB);
    }

    function create(
        string calldata name,
        string calldata symbol,
        string calldata uri,
        uint256 number_of_fractions,
        address[] calldata mintTokens,
        uint256[] calldata costs
    ) external onlyAuthorized {

        // Newly Made Asset
        address newAsset = Clones(implementation).clone();

        // initialize new asset
        IFractionalAsset(newAsset).__init__(name, symbol, uri, number_of_fractions, mintTokens, costs);

        // set position in array
        assetIndex[newAsset] = allAssets.length;

        // add to list of assets
        allAssets.push(newAsset);
    }

    function remove(address asset) external onlyAuthorized {
        require(
            allAssets[assetIndex[asset]] == asset,
            'Not Registered Asset'
        );

        uint rmIndex = assetIndex[asset];
        address lastElement = allAssets[allAssets.length - 1];

        // set last element's index to be the removed element
        assetIndex[
            lastElement
        ] = rmIndex;

        // set last elements position to replace the removed element
        allAssets[
            rmIndex
        ] = lastElement;

        // pop last element (copy) off the end of the array
        allAssets.pop();
    }

    function setImplementation(address newImplementation) external onlyAuthorized {
        implementation = newImplementation;
    }

    function listAllAssets() external view returns (address[] memory) {
        return allAssets;
    }
}