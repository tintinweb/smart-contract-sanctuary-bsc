//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/utils/Counters.sol';

interface IEternalDomains {
    function domainName(uint256 _tokenId) external view returns (string memory);
}

contract DomainMarket {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    IERC721 public domainContract;
    IEternalDomains public eternalDomainsInterface;

    constructor(address _domainContract) {
        domainContract = IERC721(_domainContract);
        eternalDomainsInterface = IEternalDomains(_domainContract);
    }

    address public wasabi = 0xB505d036b8434AE01401ba2865A931b12Ca8cAF6; // 70%
    address public eternal = 0x1a713D6d4280E23DcCF1e4bF24BFd56c1c9EbA11; // 5%
    address public admin = 0xB409bE677b01eAb068A1e22bedeBBeEBdd90b053; // 25%

    Counters.Counter private _listingCount;
    Counters.Counter private _offerCount;
    Counters.Counter private _totalSales;

    mapping(uint256 => MarketItem) public marketItems;
    mapping(uint256 => Offer) public offers;

    event MarketItemCreated(
        uint256 indexed itemId,
        address indexed seller,
        uint256 price,
        uint256 tokenId,
        string domainName
    );
    event MarketItemSold(
        uint256 indexed itemId,
        address indexed seller,
        address indexed buyer,
        uint256 price,
        uint256 tokenId,
        string domainName
    );
    event MarketItemCancelled(
        uint256 indexed itemId,
        address indexed seller,
        address indexed buyer,
        uint256 price,
        uint256 tokenId,
        string domainName
    );

    event OfferCreated(
        uint256 indexed offerId,
        address indexed seller,
        address indexed buyer,
        uint256 price,
        uint256 tokenId,
        string domainName
    );
    event OfferAccepted(
        uint256 indexed offerId,
        address indexed seller,
        address indexed buyer,
        uint256 price,
        uint256 tokenId,
        string domainName
    );
    event OfferCancelled(
        uint256 indexed offerId,
        address indexed seller,
        address indexed buyer,
        uint256 price,
        uint256 tokenId,
        string domainName
    );

    struct MarketItem {
        uint256 tokenId;
        address seller;
        uint256 price;
        bool isSold;
    }

    struct Offer {
        uint256 tokenId;
        address buyer;
        uint256 offerValue;
        bool isAccepted;
    }

    function totalSales() public view returns (uint256) {
        return _totalSales.current();
    }

    function createListing(uint256 _tokenId, uint256 _price) public {
        require(_price > 0, 'Price must be a positive value');
        require(
            domainContract.ownerOf(_tokenId) == msg.sender,
            'You must own the token to create a listing'
        );

        uint256 id = _listingCount.current() + 1;
        _listingCount.increment();

        marketItems[id] = MarketItem(_tokenId, msg.sender, _price, false);

        domainContract.transferFrom(msg.sender, address(this), _tokenId);

        emit MarketItemCreated(
            id,
            msg.sender,
            _price,
            _tokenId,
            eternalDomainsInterface.domainName(_tokenId)
        );
    }

    function cancelListing(uint256 _listingId) public {
        //MarketItem memory item = marketItems[_itemId];
        require(
            marketItems[_listingId].seller == msg.sender,
            'You must be the seller to cancel the listing'
        );
        require(
            marketItems[_listingId].isSold == false,
            'Item is already sold'
        );

        marketItems[_listingId].isSold = true;

        domainContract.transferFrom(
            address(this),
            marketItems[_listingId].seller,
            marketItems[_listingId].tokenId
        );

        emit MarketItemCancelled(
            _listingId,
            marketItems[_listingId].seller,
            address(0),
            marketItems[_listingId].price,
            marketItems[_listingId].tokenId,
            eternalDomainsInterface.domainName(marketItems[_listingId].tokenId)
        );
    }

    function purchaseListing(uint256 _listingId) public payable {
        require(
            marketItems[_listingId].isSold == false,
            'Item is already sold'
        );
        require(
            marketItems[_listingId].price == msg.value,
            'Please submit the accurate asking price'
        );

        marketItems[_listingId].isSold = true;

        domainContract.transferFrom(
            address(this),
            msg.sender,
            marketItems[_listingId].tokenId
        );

        uint256 sellerValue = (msg.value * 975) / 1000; // 2.5% fee
        uint256 feeValue = msg.value - sellerValue;

        uint256 wasabiShare = (feeValue * 70) / 100; // (70%)
        uint256 eternalShare = (feeValue * 5) / 100; // (5%)
        uint256 adminShare = (feeValue * 25) / 100; // (25%)
        payable(wasabi).transfer(wasabiShare);
        payable(admin).transfer(adminShare);
        payable(eternal).transfer(eternalShare);

        payable(marketItems[_listingId].seller).transfer(sellerValue);

        _totalSales.increment();

        emit MarketItemSold(
            _listingId,
            marketItems[_listingId].seller,
            msg.sender,
            marketItems[_listingId].price,
            marketItems[_listingId].tokenId,
            eternalDomainsInterface.domainName(marketItems[_listingId].tokenId)
        );
    }

    function createOffer(uint256 _tokenId, uint256 _offerValue) public payable {
        require(_offerValue > 0, 'Offer must be a positive value');
        require(_offerValue == msg.value, 'Please submit the offer price');

        uint256 id = _offerCount.current() + 1;
        _offerCount.increment();

        offers[id] = Offer(_tokenId, msg.sender, _offerValue, false);

        emit OfferCreated(
            id,
            domainContract.ownerOf(_tokenId),
            msg.sender,
            _offerValue,
            _tokenId,
            eternalDomainsInterface.domainName(_tokenId)
        );
    }

    function cancelOffer(uint256 _offerId) public {
        require(
            offers[_offerId].buyer == msg.sender,
            'You must be the buyer to cancel the offer'
        );
        require(
            offers[_offerId].isAccepted == false,
            'Offer is already accepted'
        );

        offers[_offerId].isAccepted = true;

        payable(offers[_offerId].buyer).transfer(offers[_offerId].offerValue);

        emit OfferCancelled(
            _offerId,
            offers[_offerId].buyer,
            domainContract.ownerOf(offers[_offerId].tokenId),
            offers[_offerId].offerValue,
            offers[_offerId].tokenId,
            eternalDomainsInterface.domainName(offers[_offerId].tokenId)
        );
    }

    function acceptOffer(uint256 _offerId) public {
        require(
            domainContract.ownerOf(offers[_offerId].tokenId) == msg.sender,
            'You must be the seller to accept the offer'
        );
        require(
            offers[_offerId].isAccepted == false,
            'Offer is already accepted'
        );

        offers[_offerId].isAccepted = true;

        uint256 sellerValue = (offers[_offerId].offerValue * 975) / 1000; // 2.5% fee
        uint256 feeValue = offers[_offerId].offerValue - sellerValue;

        domainContract.transferFrom(
            msg.sender,
            offers[_offerId].buyer,
            offers[_offerId].tokenId
        );

        uint256 wasabiShare = (feeValue * 70) / 100; // (70%)
        uint256 eternalShare = (feeValue * 5) / 100; // (5%)
        uint256 adminShare = (feeValue * 25) / 100; // (25%)
        payable(wasabi).transfer(wasabiShare);
        payable(admin).transfer(adminShare);
        payable(eternal).transfer(eternalShare);

        payable(msg.sender).transfer(sellerValue);

        _totalSales.increment();

        emit OfferAccepted(
            _offerId,
            msg.sender,
            offers[_offerId].buyer,
            offers[_offerId].offerValue,
            offers[_offerId].tokenId,
            eternalDomainsInterface.domainName(offers[_offerId].tokenId)
        );
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
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