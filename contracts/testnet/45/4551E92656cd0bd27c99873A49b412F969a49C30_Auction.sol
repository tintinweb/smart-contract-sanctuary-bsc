//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IMarketplace {
    function isMarketOwner() external view returns (bool);

    function getMarketFee() external view returns (uint256);
}

interface IYLT {
    function transfer(address to, uint256 tokens)
        external
        returns (bool success);
}

// test
contract Auction is ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _auctionIds;

    IMarketplace public marketplaceContract;
    IERC721 public ylnft721;
    IERC1155 public ylnft1155;
    IYLT public ylt20;

    enum AuctionState {
        Active,
        Release
    }

    struct AuctionItem {
        uint256 auctionId;
        uint256 tokenId;
        uint256 auStart;
        uint256 auEnd;
        uint256 highestBid;
        address owner;
        address highestBidder;
        uint256 amount;
        uint256 limitPrice;
        AuctionState state;
    }

    event AdminSetBid(
        address admin,
        uint256 period,
        uint256 tokenId,
        uint256 amount,
        uint256 limitPrice,
        uint256 timestamp
    );
    event UserSetBid(
        address user,
        uint256 period,
        uint256 tokenId,
        uint256 amount,
        uint256 limitPrice,
        uint256 timestamp
    );
    event UserBidoffer(
        address user,
        uint256 price,
        uint256 tokenId,
        uint256 amount,
        uint256 bidId,
        uint256 timestamp
    );
    event BidWinner(
        address user,
        uint256 auctionId,
        uint256 tokenId,
        uint256 amount,
        uint256 timestamp
    );
    event BidNull(
        uint256 auctionId,
        uint256 tokenId,
        uint256 amount,
        address owner,
        uint256 timestamp
    );
    event AuctionItemEditted(
        address user,
        uint256 tokenId,
        uint256 period,
        uint256 limitPrice,
        uint256 timestamp
    );

    mapping(uint256 => AuctionItem) private idToAuctionItem;

    constructor(
        IERC721 _ylnft721,
        IERC1155 _ylnft1155,
        IMarketplace _marketplaceContract
    ) {
        ylnft721 = _ylnft721;
        ylnft1155 = _ylnft1155;
        marketplaceContract = _marketplaceContract;
    }

    //get itemId
    function getItemId() public view returns (uint256) {
        return _itemIds.current();
    }

    //get auction
    function getAuctionId() public view returns (uint256) {
        return _auctionIds.current();
    }

    //get auction data
    function getAuction(uint256 _auctionId)
        public
        view
        returns (AuctionItem memory)
    {
        return idToAuctionItem[_auctionId];
    }

    //f.
    function MinterListNFT(
        uint256 _tokenId,
        uint256 _price,
        uint256 _amount,
        uint256 _limitPrice,
        uint256 _period,
        bool _isERC721
    ) public returns (uint256) {
        require(
            marketplaceContract.isMarketOwner() == true,
            "You aren't the owner of marketplace"
        );

        if (_isERC721) {
            require(
                ylnft721.ownerOf(_tokenId) == msg.sender,
                "You haven't this token"
            );
            require(
                ylnft721.getApproved(_tokenId) == address(this),
                "NFT must be approved to market"
            );

            ylnft721.transferFrom(msg.sender, address(this), _tokenId);
        } else {
            require(
                ylnft1155.balanceOf(msg.sender, _tokenId) >= _amount,
                "You haven't this token"
            );
            require(
                ylnft1155.isApprovedForAll(msg.sender, address(this)) == true,
                "NFT must be approved to market"
            );

            ylnft1155.safeTransferFrom(
                msg.sender,
                address(this),
                _tokenId,
                _amount,
                ""
            );
        }

        uint256 _auctionId = 0;
        for (uint256 i = 1; i <= _auctionIds.current(); i++) {
            if (idToAuctionItem[i].tokenId == _tokenId) {
                _auctionId = idToAuctionItem[i].auctionId;
                break;
            }
        }

        if (_auctionId == 0) {
            _auctionIds.increment();
            _auctionId = _auctionIds.current();
            idToAuctionItem[_auctionId] = AuctionItem(
                _auctionId,
                _tokenId,
                block.timestamp,
                block.timestamp + _period * 86400,
                _price,
                msg.sender,
                msg.sender,
                _amount,
                _limitPrice,
                AuctionState.Active
            );
        } else {
            idToAuctionItem[_auctionId] = AuctionItem(
                _auctionId,
                _tokenId,
                block.timestamp,
                block.timestamp + _period * 86400,
                _price,
                msg.sender,
                msg.sender,
                _amount,
                _limitPrice,
                AuctionState.Active
            );
        }

        emit AdminSetBid(
            msg.sender,
            _period,
            _tokenId,
            _amount,
            _limitPrice,
            block.timestamp
        );
        return _auctionId;
    }

    //g.
    function BuyerListNFT(
        uint256 _tokenId,
        uint256 _price,
        uint256 _amount,
        uint256 _limitPrice,
        uint256 _period,
        bool _isERC721
    ) public returns (uint256) {
        if (_isERC721) {
            require(
                ylnft721.ownerOf(_tokenId) == msg.sender,
                "You haven't this token"
            );
            require(
                ylnft721.getApproved(_tokenId) == address(this),
                "NFT must be approved to market"
            );

            ylnft721.transferFrom(msg.sender, address(this), _tokenId);
        } else {
            require(
                ylnft1155.balanceOf(msg.sender, _tokenId) >= _amount,
                "You haven't this token"
            );
            require(
                ylnft1155.isApprovedForAll(msg.sender, address(this)) == true,
                "NFT must be approved to market"
            );

            ylnft1155.safeTransferFrom(
                msg.sender,
                address(this),
                _tokenId,
                _amount,
                ""
            );
        }
        uint256 _auctionId = 0;
        for (uint256 i = 1; i <= _auctionIds.current(); i++) {
            if (idToAuctionItem[i].tokenId == _tokenId) {
                _auctionId = idToAuctionItem[i].auctionId;
                break;
            }
        }

        if (_auctionId == 0) {
            _auctionIds.increment();
            _auctionId = _auctionIds.current();
            idToAuctionItem[_auctionId] = AuctionItem(
                _auctionId,
                _tokenId,
                block.timestamp,
                block.timestamp + _period * 86400,
                _price,
                msg.sender,
                msg.sender,
                _amount,
                _limitPrice,
                AuctionState.Active
            );
        } else {
            idToAuctionItem[_auctionId] = AuctionItem(
                _auctionId,
                _tokenId,
                block.timestamp,
                block.timestamp + _period * 86400,
                _price,
                msg.sender,
                msg.sender,
                _amount,
                _limitPrice,
                AuctionState.Active
            );
        }

        emit UserSetBid(
            msg.sender,
            _period,
            _tokenId,
            _amount,
            _limitPrice,
            block.timestamp
        );
        return _auctionId;
    }

    function userBidOffer(
        uint256 _auctionId,
        uint256 _price,
        uint256 _amount,
        bool _isERC721
    ) public {
        require(
            idToAuctionItem[_auctionId].auEnd > block.timestamp,
            "The bidding period has already passed."
        );
        require(
            idToAuctionItem[_auctionId].highestBid < _price,
            "The bid price must be higher than before."
        );
        if (_isERC721)
            require(
                ylnft721.ownerOf(idToAuctionItem[_auctionId].tokenId) ==
                    address(this),
                "This token don't exist in market."
            );
        else
            require(
                ylnft1155.balanceOf(
                    address(this),
                    idToAuctionItem[_auctionId].tokenId
                ) >= _amount,
                "This token don't exist in market."
            );
        idToAuctionItem[_auctionId].highestBid = _price;
        idToAuctionItem[_auctionId].highestBidder = msg.sender;

        emit UserBidoffer(
            msg.sender,
            _price,
            idToAuctionItem[_auctionId].tokenId,
            _amount,
            _auctionId,
            block.timestamp
        );
    }

    function withdrawBid(uint256 _auctionId, bool _isERC721)
        public
        nonReentrant
    {
        require(
            (ylnft721.ownerOf(idToAuctionItem[_auctionId].tokenId) ==
                address(this)) ||
                ylnft1155.balanceOf(
                    address(this),
                    idToAuctionItem[_auctionId].tokenId
                ) >=
                idToAuctionItem[_auctionId].amount,
            "This token don't exist in market."
        );
        require(
            idToAuctionItem[_auctionId].auEnd < block.timestamp,
            "The bidding period have to pass."
        );
        require(
            idToAuctionItem[_auctionId].highestBidder == msg.sender,
            "The highest bidder can withdraw this token."
        );

        if (idToAuctionItem[_auctionId].owner == msg.sender) {
            bool isTransferred = ylt20.transfer(
                address(this),
                marketplaceContract.getMarketFee()
            );
            require(isTransferred, "Insufficient Fund.");
            if (_isERC721) {
                ylnft721.transferFrom(
                    address(this),
                    msg.sender,
                    idToAuctionItem[_auctionId].tokenId
                );
            } else {
                ylnft1155.safeTransferFrom(
                    address(this),
                    msg.sender,
                    idToAuctionItem[_auctionId].tokenId,
                    idToAuctionItem[_auctionId].amount,
                    ""
                );
            }
            emit BidNull(
                _auctionId,
                idToAuctionItem[_auctionId].tokenId,
                idToAuctionItem[_auctionId].amount,
                msg.sender,
                block.timestamp
            );
        } else {
            bool isTransferred = ylt20.transfer(
                address(this),
                idToAuctionItem[_auctionId].highestBid +
                    marketplaceContract.getMarketFee()
            );
            require(isTransferred, "Insufficient Fund.");
            if (_isERC721)
                ylnft721.transferFrom(
                    address(this),
                    msg.sender,
                    idToAuctionItem[_auctionId].tokenId
                );
            else
                ylnft1155.safeTransferFrom(
                    address(this),
                    msg.sender,
                    idToAuctionItem[_auctionId].tokenId,
                    idToAuctionItem[_auctionId].amount,
                    ""
                );
            bool sent = ylt20.transfer(
                idToAuctionItem[_auctionId].owner,
                idToAuctionItem[_auctionId].highestBid
            );
            require(sent, "Failed to send token to the seller");
            emit BidWinner(
                msg.sender,
                _auctionId,
                idToAuctionItem[_auctionId].tokenId,
                idToAuctionItem[_auctionId].amount,
                block.timestamp
            );
        }
    }

    function withdrawNFTInstant(uint256 _auctionId, bool _isERC721)
        public
        nonReentrant
    {
        require(
            (ylnft721.ownerOf(idToAuctionItem[_auctionId].tokenId) ==
                address(this)) ||
                ylnft1155.balanceOf(
                    address(this),
                    idToAuctionItem[_auctionId].tokenId
                ) >=
                idToAuctionItem[_auctionId].amount,
            "This token don't exist in market."
        );
        require(
            idToAuctionItem[_auctionId].highestBid >=
                idToAuctionItem[_auctionId].limitPrice,
            "Your bid is not reached to limit price"
        );
        bool isTransferred = ylt20.transfer(
            address(this),
            idToAuctionItem[_auctionId].highestBid +
                marketplaceContract.getMarketFee()
        );
        require(isTransferred, "Insufficient Fund.");
        if (_isERC721)
            ylnft721.transferFrom(
                address(this),
                msg.sender,
                idToAuctionItem[_auctionId].tokenId
            );
        else
            ylnft1155.safeTransferFrom(
                address(this),
                msg.sender,
                idToAuctionItem[_auctionId].tokenId,
                idToAuctionItem[_auctionId].amount,
                ""
            );
        bool sent = ylt20.transfer(
            idToAuctionItem[_auctionId].owner,
            idToAuctionItem[_auctionId].highestBid
        );
        require(sent, "Failed to send token to the seller");
        emit BidWinner(
            msg.sender,
            _auctionId,
            idToAuctionItem[_auctionId].tokenId,
            idToAuctionItem[_auctionId].amount,
            block.timestamp
        );
    }

    function fetchAuctionItems() public view returns (AuctionItem[] memory) {
        uint256 total = _itemIds.current();

        uint256 itemCount = 0;
        for (uint256 i = 1; i <= total; i++) {
            if (
                idToAuctionItem[i].state == AuctionState.Active &&
                idToAuctionItem[i].owner == address(this)
            ) {
                itemCount++;
            }
        }

        AuctionItem[] memory items = new AuctionItem[](itemCount);
        uint256 index = 0;
        for (uint256 i = 1; i <= total; i++) {
            if (
                idToAuctionItem[i].state == AuctionState.Active &&
                idToAuctionItem[i].owner == address(this)
            ) {
                items[index] = idToAuctionItem[i];
                index++;
            }
        }

        return items;
    }

    function editAuctionItems(
        uint256 _auctionId,
        uint256 _period,
        uint256 _limitPrice
    ) public {
        require(
            idToAuctionItem[_auctionId].state == AuctionState.Active,
            "This auction item is not active"
        );
        require(
            idToAuctionItem[_auctionId].owner == msg.sender,
            "You can't edit this auction item"
        );
        idToAuctionItem[_auctionId].limitPrice = _limitPrice;
        idToAuctionItem[_auctionId].auEnd =
            idToAuctionItem[_auctionId].auStart +
            _period *
            86400;
        emit AuctionItemEditted(
            msg.sender,
            idToAuctionItem[_auctionId].tokenId,
            _period,
            _limitPrice,
            block.timestamp
        );
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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