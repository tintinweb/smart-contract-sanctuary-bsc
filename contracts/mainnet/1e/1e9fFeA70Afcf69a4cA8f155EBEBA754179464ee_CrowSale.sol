// SPDX-License-Identifier: MIT
import "./IERC721_EXT.sol";

pragma solidity ^0.8.4;

contract CrowSale {
    IERC721_EXT public token;
    uint public initDate;
    uint constant public timeStep = 1 hours;
    uint constant public priceDuration = timeStep * 2;
    uint constant public initPrice = 1.5 ether;
    uint constant public finallyPrice = 2 ether;
    uint public nftSold;

    bool public paused;

    address public devAddress = address(0x72B81C98be9927e865a3d0B6CE4D180Afb61158B);
    address public owner = address(0x49448d498FD22b0B8876333199De8913dFF73219);
    address public admin;

    uint constant devFee = 15;

    struct User {
        uint invest;
        uint nftBuy;
        address user;
    }

    mapping (address => User) public users;
    uint public constant nftCap = 1500;
    uint public totalInvest;
    uint totalUsers;

    mapping(uint => address) public investors;


    constructor(address _nft) {
        token = IERC721_EXT(_nft);
        admin = msg.sender;
        paused = true;
    }

    modifier onlyAdmin {
        require(msg.sender == admin);
        _;
    }

    modifier onlyUnpaused {
        require(!paused, "CrowSale is paused");
        _;
    }

    function transferAdmin(address _newAdmin) onlyAdmin external {
        admin = _newAdmin;
    }

    function pause() onlyAdmin external {
        paused = true;
    }

    function unpause() onlyAdmin external {
        paused = false;
        if(initDate == 0) {
            initDate = block.timestamp;
        }
    }

    function buyNFT(uint amount) payable external onlyUnpaused {
        require(amount > 0, "amount must be greater than 0");
        require(msg.value == getPrice() * amount, "invalid msg.value");
        nftSold += amount;
        require(nftSold <= nftCap, "nftSold must be less than nftCap");
        uint _devFee = (msg.value * devFee) / 100;
        payable(devAddress).transfer(_devFee);
        payable(owner).transfer(msg.value - _devFee);
        if(users[msg.sender].nftBuy == 0) {
            investors[totalUsers] = msg.sender;
            users[msg.sender].user = msg.sender;
            totalUsers++;
        }
        users[msg.sender].nftBuy += amount;
        users[msg.sender].invest += msg.value;
        totalInvest += msg.value;
        for(uint i = 0; i < amount; i++) {
            token.safeMint(msg.sender, token.uniqueURI());
        }
    }

    function getDeltaTime() public view returns (uint) {
        if(initDate == 0) {
            return 0;
        }
        return block.timestamp - initDate;
    }

    function getDeltaTimeHours() public view returns (uint) {
        return getDeltaTime() / timeStep;
    }

    function getPrice() public view returns (uint) {
        if(initDate == 0) {
            return initPrice;
        }
        uint deltaTime = getDeltaTime();
        if (deltaTime >= priceDuration) {
            return finallyPrice;
        } else {
            return initPrice;
        }
    }

    function getDate() public view returns (uint) {
        return block.timestamp;
    }

    function getUserByindex(uint index) public view returns (address) {
        return users[investors[index]].user;
    }

    function getAllUsers() public view returns(User[] memory) {
        User[] memory _users = new User[](totalUsers);
        for(uint i = 0; i < totalUsers; i++) {
            _users[i] = users[investors[i]];
        }
        return _users;
    }

    function getAllInversors() public view returns(address[] memory) {
        address[] memory _investors = new address[](totalUsers);
        for(uint i = 0; i < totalUsers; i++) {
            _investors[i] = investors[i];
        }
        return _investors;
    }

    function getInvestorByIndex(uint index) public view returns (address) {
        return investors[index];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IERC721_EXT is IERC721 {
    function tokensByOwner(address owner) external view returns (uint256[] memory);
    function exists(uint tokenId) external view returns(bool);
    function safeMint(address to, string memory uri) external;
    function uniqueURI() external view returns(string memory);
    function desposit(uint _amount) external;
    function withDraw() external;
    function canWithdraw(address _user) external view returns(bool);
    function dividendsBalanceOf(address _user) external view returns(uint);
    function dividendsCreditedTo(address _user) external view returns(uint);
    function totalWithdrawn(address _user) external view returns(uint);
    function currentReward(address _user) external view returns(uint);

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