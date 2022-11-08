// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IMYNTIST {
    function mintAmountForNftAA(address _to, uint256 _amount) external;
}

interface IMYNTIST_NFT {
    function balanceOf(address user) external view returns (uint256);
}

interface IMYNTISTB_1155 {
    function getTokenIds() external view returns (uint256[] memory);

    function balanceOf(address account, uint256 id)
        external
        view
        returns (uint256);
}

interface IMYNTISTE_1155 {
    function getTokenIds() external view returns (uint256[] memory);

    function balanceOf(address account, uint256 id)
        external
        view
        returns (uint256);
}

contract NFTAA {
    address nftContractAddress;
    uint256 internal constant LAUNCH_TIME = 1667887200;
    uint256 internal constant totalSupply = 750000000 * 10**8;
    uint256 internal constant perDaySupply = totalSupply / 365;
    address internal owner;
    IMYNTIST public tokenContarct;
    IMYNTIST_NFT public nftContract;
    IMYNTISTB_1155 public collectionContract;
    IMYNTISTE_1155 public collectionContract2;

    struct recordsStruct {
        uint256 userTotalBalance;
        bool isClaim;
    }
    mapping(uint256 => mapping(address => recordsStruct)) public userRecord;
    mapping(uint256 => uint256) public totalBalancePerDay;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(
        address myntistTokenAddress,
        address myntistNftAddress,
        address myntist1155BAddress,
        address myntist1155EAddress
    ) {
        nftContract = IMYNTIST_NFT(myntistNftAddress);
        tokenContarct = IMYNTIST(myntistTokenAddress);
        collectionContract = IMYNTISTB_1155(myntist1155BAddress);
        collectionContract2 = IMYNTISTE_1155(myntist1155EAddress);
        owner = msg.sender;
    }

    function getUserNFTBalance(address userAddress)
        external
        view
        returns (uint256)
    {
        return nftContract.balanceOf(userAddress);
    }

    function get1155BUserBalance(address userAddress)
        public
        view
        returns (uint256 userBalance)
    {
        uint256[] memory ids = collectionContract.getTokenIds();
        for (uint256 i = 0; i < ids.length; i++) {
            uint256 balance = collectionContract.balanceOf(userAddress, ids[i]);
            userBalance = userBalance + balance;
        }
        return userBalance;
    }

    function get1155EUserBalance(address userAddress)
        public
        view
        returns (uint256 userBalance)
    {
        uint256[] memory ids = collectionContract2.getTokenIds();
        for (uint256 i = 0; i < ids.length; i++) {
            uint256 balance = collectionContract2.balanceOf(
                userAddress,
                ids[i]
            );
            userBalance = userBalance + balance;
        }
        return userBalance;
    }

    function _currentDay() public view returns (uint256) {
        return (block.timestamp - LAUNCH_TIME) / 300;
    }

    function enterLobby() external {
        uint256 enterDay = _currentDay();
        uint256 nftBalance = nftContract.balanceOf(msg.sender);
        uint256 balance1155B = get1155BUserBalance(msg.sender);
        uint256 balance1155E = get1155EUserBalance(msg.sender);
        uint256 totalBalance = nftBalance + balance1155B + balance1155E;
        recordsStruct storage qRef = userRecord[enterDay][msg.sender];
        require(
            qRef.userTotalBalance == 0 && totalBalance > 0,
            "Already Added for current day"
        );
        qRef.userTotalBalance = totalBalance;
        qRef.isClaim = false;
        totalBalancePerDay[enterDay] += totalBalance;
    }

    function claimTokens(uint256 day, address user) external {
        uint256 currentDay = _currentDay();
        require(day == currentDay - 1 && day != 0, "Not claim Day");
        recordsStruct storage qRef = userRecord[day][user];
        require(qRef.userTotalBalance > 0, "Record Not Found");
        require(qRef.isClaim == false, "Already Claimed");
        uint256 userShare = (perDaySupply * qRef.userTotalBalance) /
            totalBalancePerDay[day];
        tokenContarct.mintAmountForNftAA(msg.sender, userShare);
        qRef.isClaim = true;
    }

    function resetContractAddresses(
        address myntistTokenAddress,
        address myntistNftAddress,
        address myntist1155BAddress,
        address myntist1155EAddress
    ) external onlyOwner{
        nftContract = IMYNTIST_NFT(myntistNftAddress);
        tokenContarct = IMYNTIST(myntistTokenAddress);
        collectionContract = IMYNTISTB_1155(myntist1155BAddress);
        collectionContract2 = IMYNTISTE_1155(myntist1155EAddress);
    }
}

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