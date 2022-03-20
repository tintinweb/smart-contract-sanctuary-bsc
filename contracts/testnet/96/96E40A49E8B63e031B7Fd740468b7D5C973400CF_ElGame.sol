// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

import "IERC721.sol";

contract ElGame {
    struct NftMetadata {
        uint gamesPlayed;
        uint won;
        uint8 status;
    }

    struct GameOn {
        uint gameStyle;
        uint amount;
        uint8 status;
    }
    
    mapping (uint256 => GameOn) public gameOn;
    mapping (uint256 => NftMetadata) public nftData;
    // PlayStyle
    // 0 = Random
    // 1 = Use Store Sequence


    //TODO REMOVE ===========================
    uint public value;
    
    //END TODO ==============================

    address public owner;
    IERC721 public ntf_interface;
    
    // ============ EVENTS =========================
    event LetsPlayMaster(address sender, uint256 nftId, uint256 amount_);
    event GameResult(address winner_, uint256 winnerId_, uint256 loserId_, uint256 amount_);
    // ============= END EVENTS ====================

    constructor(address nft_address_) {
        owner = msg.sender;
        ntf_interface = IERC721(nft_address_);
    }

    modifier onlyAdmin() {
        require(msg.sender == owner, "CF1-401");
        _;
    }
    
    receive() external payable {}
    
    function setNFTContract(address nft) external {
        ntf_interface = IERC721(nft);
    }

    function setValue(uint val) external {
        value = val;
    }

    //TODO: needs to change to payable =)
    function letsPlayVsMaster(uint nftId) external {
        require(ntf_interface.ownerOf(nftId) == msg.sender, "NOT NFT OWNER");
        require (gameOn[nftId].status == 0, "GAME ALREADY REQUESTED");
        gameOn[nftId] = GameOn({gameStyle: 0, amount: 0, status: 1});
        emit LetsPlayMaster(msg.sender, nftId, 0);
    }
    ///@dev if game play vs Master -- nftId1 will always be master
    function setGameResult(
        uint256 nftId1_, uint256 nftId2_, 
        address player1_, address player2_,
        address payable winner_, uint256 amount_) external onlyAdmin {
        
        if (amount_ > 0) { //Paying so either 1 or 2 won
            if (winner_ == player1_) {
                nftData[nftId1_].won += 1;
                emit GameResult(winner_, nftId1_, nftId2_, amount_);
            } else {
                nftData[nftId2_].won += 1;
                emit GameResult(winner_, nftId2_, nftId1_, amount_);
            }
            //TODO Transfer amount to winner by amount
            //(bool sent, ) = winner_.call{ value: amount_ }(""); 
        } else {
            emit GameResult(winner_, nftId1_, nftId2_, amount_);
        }
        if (nftId1_ > 0) {
            nftData[nftId1_].gamesPlayed += 1;
            gameOn[nftId1_].status = 0;
        }
        nftData[nftId2_].gamesPlayed += 1;
        gameOn[nftId2_].status = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "IERC165.sol";

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