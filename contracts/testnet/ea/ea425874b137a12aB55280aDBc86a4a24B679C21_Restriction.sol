// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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

//  SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./interfaces/IOKGManagement.sol";

/**
    @title Restriction contract
    @dev This contract provide additional retrictions on the `tokenID` of one NFT Contract
        + Supports both ERC-721 and ERC-1155
        + Leasing/Renting ONLY for ERC-721
        + Not for Trade/Restricted Listing can be applied on ERC-1155 and/or ERC-721
        + Note: TokenID can be 'Not for Trade'/'Restricted Listing', but also  'On Leasing' at the same time
*/
contract Restriction {
	IOKGManagement public gov;

	bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
	uint64 public constant NOT_FOR_TRADE = type(uint64).max;
	uint32 public constant RESTRICTED_LISTING = type(uint32).max;

	mapping(address => mapping(uint256 => uint256)) public allowancesMap; //  restrict TokenID on trade - Not for Trade/Restricted Listing
	mapping(address => mapping(uint256 => uint256)) public onLeasing; //  TokenID on leasing
	mapping(address => bool) public stores; //  a list of other MP's storefront is restricted
	mapping(address => bool) public whitelisted;

	mapping(address => uint256) public lockUntil; // restrict token address transfer until this timestamp

	modifier onlyManager() {
		require(gov.hasRole(MANAGER_ROLE, msg.sender), "Caller is not Manager");
		_;
	}

	constructor(address _gov) {
		gov = IOKGManagement(_gov);
	}

	/**
        @notice Change a new Manager contract
        @dev Caller must have MANAGER ROLE
        @param _newGov       Address of new Governance Contract
    */
	function setGov(address _newGov) external onlyManager {
		require(_newGov != address(0), "Set zero address");
		gov = IOKGManagement(_newGov);
	}

	/**
        @notice Register MP's storefront to be restricted
        @dev Caller must have MANAGER ROLE
        @param _store       Address of Store Front contract
    */
	function addStore(address _store) external onlyManager {
		require(!stores[_store], "Store already restricted");
		require(_store != address(0), "Set zero address");
		stores[_store] = true;
	}

	/**
        @notice Unregister MP's storefront out of restricted list
        @dev Caller must have MANAGER ROLE
        @param _store       Address of Store Front contract
    */
	function removeStore(address _store) external onlyManager {
		require(stores[_store], "Store not recorded");
		delete stores[_store];
	}

	/**
        @notice Set restriction of the `_tokenId` from `_token` contract
        @dev Caller must have MANAGER ROLE
        @param _token           Address of new NFT Contract (ERC-721 or ERC-1155)
        @param _tokenId         ID number of Token to be restricted
        Note:  When `_tokenId` is set, trade is DISALLOWABLE
    */
	function untradeable(address _token, uint256 _tokenId) external onlyManager {
		require(gov.listOfNFTs(_token), "Token not supported");
		allowancesMap[_token][_tokenId] = NOT_FOR_TRADE;
	}

	/**
        @notice Set restriction of the `_tokenId` from `_token` contract
        @dev Caller must have MANAGER ROLE
        @param _token           Address of new NFT Contract (ERC-721 or ERC-1155)
        @param _tokenId         ID number of Token to be restricted
        Note:  When `_tokenId` is set, item is allowable to trade
            But it's restricted trading only on OKG Marketplace
    */
	function restrict(address _token, uint256 _tokenId) external onlyManager {
		require(gov.listOfNFTs(_token), "Token not supported");
		allowancesMap[_token][_tokenId] = RESTRICTED_LISTING;
	}

	/**
        @notice Unset restriction of the `_tokenId` from `_token` contract
        @dev Caller must have MANAGER ROLE
        @param _token           Address of new NFT Contract (ERC-721 or ERC-1155)
        @param _tokenId         ID number of Token to be restricted
        Note:  When `_tokenId` is unset, trade is ALLOWABLE with NO restriction
    */
	function unrestrict(address _token, uint256 _tokenId) external onlyManager {
		require(gov.listOfNFTs(_token), "Token not supported");
		delete allowancesMap[_token][_tokenId];
	}

	function setForLease(
		address _token,
		uint256 _tokenId,
		uint256 _endTime
	) external onlyManager {
		require(gov.listOfNFTs(_token), "Token not supported");
		require(
			IERC721(_token).ownerOf(_tokenId) == msg.sender,
			"TokenId not owned"
		);
		require(onLeasing[_token][_tokenId] < block.timestamp, "On leasing");
		onLeasing[_token][_tokenId] = _endTime;
	}

	function lockTransferUntil(address _token, uint256 _until) external onlyManager {
		require(_until > block.timestamp, "Invalid timestamp");
		lockUntil[_token] = _until;
	}

	function allowances(address _token, uint256 _tokenId) external view returns (uint256) {
		if (lockUntil[_token] != 0 && lockUntil[_token] >= block.timestamp) {
			return type(uint64).max;
		} else {
			return allowancesMap[_token][_tokenId];
		}
	}

	/**
        @notice set transfer whitelist
        @dev Caller must have MANAGER ROLE
        @param _user	whitelisted user address
    */
	function addWhitelist(address _user) external onlyManager {
		whitelisted[_user] = true;
	}

	function removeWhitelist(address _user) external onlyManager {
		delete whitelisted[_user];
	}
}

// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

/**
   @title IOKGManagement contract
   @dev Provide interfaces that allow interaction to OKGManagement contract
*/
interface IOKGManagement {
    function treasury() external view returns (address);
    function FEE_DENOMINATOR() external view returns (uint256);
    function commissionFee() external view returns (uint256);
    function hasRole(bytes32 role, address account) external view returns (bool);
    function listOfNFTs(address _nftContr) external view returns (bool);
    function blacklist(address _account) external view returns (bool);
    function paymentTokens(address _token) external view returns (bool);
    function locked() external view returns (bool);
}