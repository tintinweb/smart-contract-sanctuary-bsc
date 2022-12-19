// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity 0.8.17;

import "openzeppelin-solidity/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-solidity/contracts/security/Pausable.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";

contract Auction is Ownable, Pausable {
    struct TokenDetails {
        IERC721 token;
        uint256 tokenId;
        uint256 salePrice;
        uint256 startTime;
        uint256 endTime;
    }
    TokenDetails[] public tokenInfo;

    // set User price
    mapping(uint256 => mapping(address => uint256)) public UserPrice;
    //to store maxBidprice
    uint256 public _maxBidPrice;
    //to store maxbitPriceholder address
    address public _maxBidPriceHolder;

    /**
     * @dev Emitted when owner set the auction
     */
    event setAuctionDetails(
        uint256 _SalePrice,
        uint256 _StartTime,
        uint256 _EndTime,
        uint256 _tokenId,
        uint256 auctionId
    );

    /**
     * @dev Emitted when user transfer their balances from the contract.
     */

    event Transfer(address account, uint256 amount);

    /**
     * @dev Emitted when user involve in auction
     */

    event AuctionDetails(uint256 _tokenId, uint256 amount);

    /**
     * @dev Emitted when owner withdraw the balances of maxBidPriceHoldder
     */
    event TransferNFT(
        address tokenHolder,
        address _maxBidPriceHolder,
        uint256 TokenId
    );

    constructor() {}

    /*
     * @dev auction for perticular NFT
     * @param tokenId and Amount(Ether)
     */

    function auction(uint256 auctionId) public payable{
         require(
            tokenInfo[auctionId].startTime <= block.timestamp,
            "Sale time is not started yet"
        );
        require(tokenInfo[auctionId].endTime >= block.timestamp, "Time up");
        require(
            tokenInfo.length < auctionId,
            "Sale is not started for this token id"
        );
        require(
            msg.value >= tokenInfo[auctionId].salePrice,
            "Amount should be greater than the sales price"
        );
        UserPrice[auctionId][msg.sender] = msg.value;
        maxBidder(msg.value);
        emit AuctionDetails(auctionId, msg.value);
    }

    /*
     * Internal function to set maxBitPrice and maxBitPriceHolder
     */

    function maxBidder(uint256 amount) internal {
        if (amount > _maxBidPrice) {
            _maxBidPriceHolder = msg.sender;
            _maxBidPrice = amount;
        }
    }

    /*
     * Once the sales is over, the owner send nft to maxBidPriceHolder
     * Owner can withdraw the maxBitPrice
     */

    function transferNFT(uint256 auctionId) external {
        require(
            block.timestamp >= tokenInfo[auctionId].endTime,
            "sale is not completed"
        );
        IERC721 tokenAddress = tokenInfo[auctionId].token;
        address tokenHolder = tokenAddress.ownerOf(
            tokenInfo[auctionId].tokenId
        );
        require(
            tokenHolder == msg.sender,
            "Only token holder transfer the token"
        );
        tokenAddress.safeTransferFrom(
            tokenHolder,
            _maxBidPriceHolder,
            tokenInfo[auctionId].tokenId
        );
        payable(msg.sender).transfer(_maxBidPrice);
        UserPrice[auctionId][_maxBidPriceHolder] = 0;
        emit TransferNFT(
            tokenHolder,
            _maxBidPriceHolder,
            tokenInfo[auctionId].tokenId
        );
    }

    receive() external payable {}

    //user can withdraw their amount

    function withDraw(uint256 auctionId) external returns (bool) {
        require(
            _maxBidPriceHolder != msg.sender,
            "You cannot transfer your amount"
        );
        payable(msg.sender).transfer(UserPrice[auctionId][msg.sender]);
        emit Transfer(msg.sender, UserPrice[auctionId][msg.sender]);
        return true;
    }

    /* *
     * @dev set Auction details for perticular NFT
     * @param setSalesPrice, setStartTime, setEndTime and tokenID
     */

    function setAuction(
        uint256 setSalePrice,
        uint256 setStartTime,
        uint256 setEndTime,
        uint256 _tokenId,
        IERC721 tokenAddress
    ) external {
        tokenInfo.push(
            TokenDetails({
                token: tokenAddress,
                salePrice: setSalePrice,
                startTime: setStartTime,
                endTime: setEndTime,
                tokenId: _tokenId
            })
        );
        uint256 auctionId = tokenInfo.length - 1;
        IERC721 _tokenAddress = tokenInfo[auctionId].token;
        require(
            _tokenAddress.ownerOf(_tokenId) == msg.sender,
            "Only owner can set Auction"
        );

        emit setAuctionDetails(
            setSalePrice,
            setStartTime,
            setEndTime,
            _tokenId,
            auctionId
        );
    }

    // owner can update the end time
    function updateEndTime(uint256 auctionId, uint256 setEndTime) external {
        require(auctionId > tokenInfo.length, "check Auction id");
        IERC721 _tokenAddress = tokenInfo[auctionId].token;
        require(
            _tokenAddress.ownerOf(tokenInfo[auctionId].tokenId) == msg.sender,
            "Only owner can change the end time"
        );
        require(
            setEndTime >= block.timestamp,
            "Time should be greater than the current time"
        );
        require(
            tokenInfo[auctionId].endTime <= setEndTime,
            "Time should be greater than the current end time"
        );
        tokenInfo[auctionId].endTime = setEndTime;
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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