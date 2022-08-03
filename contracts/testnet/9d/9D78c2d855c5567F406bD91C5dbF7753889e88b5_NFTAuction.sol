/**
 *Submitted for verification at BscScan.com on 2022-08-03
*/

pragma solidity ^0.8.0;

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
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


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)
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


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)
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


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)
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


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)
/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}


// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)
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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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

//SPDX-License-Identifier: MIT
// import "hardhat/console.sol";
string constant FORBIDDEN = "Auction: FORBIDDEN";

string constant INVALID_TIMING = "Auction: INVALID_TIMING";

string constant INVALID_MIN_PRICE = "Auction: INVALID_MIN_PRICE";

string constant INVALID_PRICE_INCREMENT = "Auction: INVALID_PRICE_INCREMENT";

string constant INVALID_PRICE_RANGE =  "Auction: INVALID_PRICE_RANGE";

string constant ZERO_BALANCE = "Auction: ZERO_BALANCE";

string constant INVALID_BID = "Auction: INVALID_BID";

contract NFTAuction is Ownable {
    using SafeMath for uint256;
    mapping(address => mapping(uint256 => Auction)) private auctions;
    mapping(address => uint256[]) private tokens;

    struct Auction {
        uint64 auctionStart;
        uint64 auctionEnd;
        uint256 minPrice;
        uint256 maxPrice;
        uint256 priceIncrement;
        address highestBidder;
        address quote;
        uint256 balance;
        uint256 blockEnd;
        bool locked;
        mapping(address => uint256) bids;
    }
    

    constructor() {}

    fallback() external payable {
        revert(FORBIDDEN);
    }

    receive() external payable {
        revert(FORBIDDEN);
    }

    function createAuction(
        address _nftAddress,
        uint256 _tokenId,
        address _quote,
        uint64 _auctionStart,
        uint64 _auctionEnd,
        uint256 _minPrice,
        uint256 _maxPrice,
        uint256 _priceIncrement
    ) external onlyOwner auctionNotExists(_nftAddress, _tokenId) {
        require(
            IERC721(_nftAddress).ownerOf(_tokenId) == _msgSender(),
            ZERO_BALANCE
        );
        // console.log(block.timestamp );
        require( _auctionEnd > block.timestamp  && _auctionEnd > _auctionStart, INVALID_TIMING);
        require( _minPrice > 0, INVALID_MIN_PRICE);
        require( _minPrice <= _maxPrice, INVALID_PRICE_RANGE);
        if ( _minPrice == _maxPrice ) {
            require( _priceIncrement == 0, INVALID_PRICE_INCREMENT);
        } else {
            require( _priceIncrement > 0, INVALID_PRICE_INCREMENT);
        }
       
        IERC721(_nftAddress).transferFrom(_msgSender(), address(this), _tokenId);
      
        auctions[_nftAddress][_tokenId].auctionStart = _auctionStart;
        auctions[_nftAddress][_tokenId].auctionEnd = _auctionEnd;
        auctions[_nftAddress][_tokenId].minPrice = _minPrice;
        auctions[_nftAddress][_tokenId].maxPrice = _maxPrice;
        auctions[_nftAddress][_tokenId].priceIncrement = _priceIncrement;
        auctions[_nftAddress][_tokenId].quote = _quote;
        auctions[_nftAddress][_tokenId].balance = 0;

        tokens[_nftAddress].push(_tokenId);
    }

    function closeAuction(address _nftAddress, uint256 _tokenId)
        external
        onlyOwner
        auctionExists(_nftAddress,_tokenId)
        auctionRunning(_nftAddress,_tokenId)
       
    {
         auctions[_nftAddress][_tokenId].blockEnd = block.number;
    }

    /*╔═════════════════════════════╗
      ║          GETTERS            ║
      ╚═════════════════════════════╝*/

    function contractTokensInAuction(address _nftAddress) external view returns(uint256[] memory) 
    {
        return tokens[_nftAddress];
    }

    function rules(address _nftAddress, uint256 _tokenId)  external auctionExists(_nftAddress, _tokenId) view returns(address quoteAddress, uint64 auctionStart, uint64 auctionEnd, uint256 minPrice, uint256 maxPrice, uint256 priceIncrement, bool running, bool finished) {
        auctionStart =  auctions[_nftAddress][_tokenId].auctionStart;
        auctionEnd =  auctions[_nftAddress][_tokenId].auctionEnd;
        minPrice =   auctions[_nftAddress][_tokenId].minPrice;
        maxPrice =   auctions[_nftAddress][_tokenId].maxPrice;
        priceIncrement =  auctions[_nftAddress][_tokenId].priceIncrement;
        quoteAddress =  auctions[_nftAddress][_tokenId].quote;
        uint256 blockEnd = auctions[_nftAddress][_tokenId].blockEnd;
       
        running = block.timestamp < auctionEnd && block.timestamp > auctionStart && blockEnd == 0;
        finished =  block.timestamp >= auctionEnd || blockEnd != 0;
     }

    function bestBid(address _nftAddress, uint256 _tokenId)
        external auctionExists(_nftAddress, _tokenId) view returns(uint256 highestBid, address highestBidder)
       
    {
        highestBidder = auctions[_nftAddress][_tokenId].highestBidder;
        highestBid = auctions[_nftAddress][_tokenId].bids[highestBidder];
    }

    function bids(address _nftAddress, uint256 _tokenId)
        external auctionExists(_nftAddress, _tokenId) view returns(uint256 highestBid, address highestBidder, uint256 userBid, bool userIsHighestBidder)
       
    {
        highestBidder = auctions[_nftAddress][_tokenId].highestBidder;
        highestBid = auctions[_nftAddress][_tokenId].bids[highestBidder];
        userBid = auctions[_nftAddress][_tokenId].bids[_msgSender()];
        userIsHighestBidder = highestBidder != address(0) && highestBidder ==  _msgSender();
    }

    function _balances(address _nftAddress, uint256 _tokenId) 
         internal auctionExists(_nftAddress, _tokenId) view returns(uint256 quoteBalance, uint256 nftBalance) 
    {
        quoteBalance = auctions[_nftAddress][_tokenId].balance;
        nftBalance =  IERC721(_nftAddress).ownerOf(_tokenId) == address(this) ? 1 : 0;
    }

    function balances(address _nftAddress, uint256 _tokenId) 
         external onlyOwner view returns(uint256 quoteBalance, uint256 nftBalance) 
    {
        (quoteBalance, nftBalance) = _balances(_nftAddress, _tokenId);
    }

    /*╔═════════════════════════════╗
      ║          MAKE  BID          ║
      ╚═════════════════════════════╝*/

    function _buy(
       
        address _nftAddress,
        uint256 _tokenId,
        uint256 _bidAmount
    )
        internal
    {  
        uint256 _lastUserBid = auctions[_nftAddress][_tokenId].bids[_msgSender()];
        uint256 _amount = _bidAmount.sub(_lastUserBid);
        require( _amount > 0, INVALID_BID);
        IERC20(auctions[_nftAddress][_tokenId].quote).transferFrom(
            _msgSender(),
            address(this),
            _amount
        );
        auctions[_nftAddress][_tokenId].bids[_msgSender()] = _bidAmount;
        auctions[_nftAddress][_tokenId].highestBidder = _msgSender();
        auctions[_nftAddress][_tokenId].balance = auctions[_nftAddress][_tokenId].balance.add(_amount);
        // stop auction
        auctions[_nftAddress][_tokenId].blockEnd = block.number;

    }

    function _bid(
       
        address _nftAddress,
        uint256 _tokenId,
        uint256 _bidAmount
    )
        internal
    {

        uint256 highestBid = auctions[_nftAddress][_tokenId].bids[auctions[_nftAddress][_tokenId].highestBidder];
        require( _bidAmount >= auctions[_nftAddress][_tokenId].minPrice && _bidAmount >= highestBid.add(auctions[_nftAddress][_tokenId].priceIncrement), "Auction: INVALID_BID" );
        uint256 _lastUserBid = auctions[_nftAddress][_tokenId].bids[_msgSender()];
        uint256 _amount = _bidAmount.sub(_lastUserBid);
       
        IERC20(auctions[_nftAddress][_tokenId].quote).transferFrom(
            _msgSender(),
            address(this),
            _amount
        );
        
        auctions[_nftAddress][_tokenId].highestBidder = _msgSender();
        auctions[_nftAddress][_tokenId].bids[msg.sender] = _bidAmount;
        auctions[_nftAddress][_tokenId].balance = auctions[_nftAddress][_tokenId].balance.add(_amount);
 
    }

    function makeBid(
        address _nftAddress,
        uint256 _tokenId,
        uint128 _bidAmount
    )
        external
        auctionExists(_nftAddress, _tokenId)
        auctionRunning(_nftAddress, _tokenId)
        lock(_nftAddress, _tokenId)
    {
       
        require(_bidAmount > 0, INVALID_BID);
        if ( _bidAmount >=  auctions[_nftAddress][_tokenId].maxPrice) {
            _buy( _nftAddress, _tokenId,  auctions[_nftAddress][_tokenId].maxPrice);
        } else { 
            _bid(_nftAddress, _tokenId, _bidAmount);
        }
        
    }

    /*╔═════════════════════════════╗
      ║          WITHDRAW           ║
      ╚═════════════════════════════╝*/

    function _withdrawOwner(address _nftAddress, uint256 _tokenId)
        internal
         onlyOwner
    {
       
        address _highestBidder =  auctions[_nftAddress][_tokenId].highestBidder;

        if (_highestBidder != address(0)) {
            // transfer quote
            uint256 _amount =  auctions[_nftAddress][_tokenId].bids[_highestBidder];
            require(_amount > 0, "Auction: WRONG_AMOUNT");
            auctions[_nftAddress][_tokenId].balance = auctions[_nftAddress][_tokenId].balance.sub(_amount);
            delete auctions[_nftAddress][_tokenId].bids[_highestBidder];
            IERC20( auctions[_nftAddress][_tokenId].quote).transfer(
                _msgSender(),
                _amount
            );
        } else {
            // transfer back NFT
            require(
                IERC721(_nftAddress).ownerOf(_tokenId) == address(this),
                ZERO_BALANCE
            );

            IERC721(_nftAddress).transferFrom(
                address(this),
                 _msgSender(),
                _tokenId
            );
        }
    }

    function _withdrawWinner( address _nftAddress, uint256 _tokenId)
        internal
      
        onlyWinner(_nftAddress, _tokenId)
    {
        require(
            IERC721(_nftAddress).ownerOf(_tokenId) == address(this),
           ZERO_BALANCE
        );
        // transfer NFT
        IERC721(_nftAddress).transferFrom(address(this),_msgSender(), _tokenId);
    }

    function _withdrawLooser( address _nftAddress, uint256 _tokenId)
        internal
         
        onlyLooser(_nftAddress, _tokenId)

    {
        uint256 _amount =  auctions[_nftAddress][_tokenId].bids[_msgSender()];
        require(_amount > 0, ZERO_BALANCE);

        auctions[_nftAddress][_tokenId].bids[_msgSender()] = 0;
        IERC20( auctions[_nftAddress][_tokenId].quote).transfer(
            _msgSender(),
            _amount
        );
        auctions[_nftAddress][_tokenId].balance = auctions[_nftAddress][_tokenId].balance.sub(_amount);
        delete auctions[_nftAddress][_tokenId].bids[_msgSender()];
    }

    function withdraw(address _nftAddress, uint256 _tokenId)
        external
        auctionExists(_nftAddress, _tokenId)
        auctionValid(_nftAddress, _tokenId)
        auctionFinished(_nftAddress, _tokenId)
        lock(_nftAddress, _tokenId)
    {
       
        address _highestBidder =  auctions[_nftAddress][_tokenId].highestBidder;
      
        if (_msgSender() == _highestBidder) {
            _withdrawWinner(_nftAddress, _tokenId);
        } else if (_msgSender() == owner()) {
            _withdrawOwner(_nftAddress, _tokenId);
        } else {
            _withdrawLooser(_nftAddress, _tokenId);
        }
        (uint256 quoteBalance,uint256 nftBalance) = _balances(_nftAddress, _tokenId);
        if ( quoteBalance == 0 && nftBalance == 0 ) {
            delete auctions[_nftAddress][_tokenId];
            uint256[] storage _tokens = tokens[_nftAddress];
            for ( uint i = 0; i < _tokens.length; i++) {
                if ( _tokens[i] == _tokenId) {
                    _tokens[i] = _tokens[_tokens.length-1];
                    _tokens.pop();
                    break;
                }
            }
        }
    }

    /*╔═════════════════════════════╗
      ║          MODIFIERS          ║
      ╚═════════════════════════════╝*/

    modifier lock(address _nftAddress, uint256 _tokenId) {
       require(
            !auctions[_nftAddress][_tokenId].locked,
            "Auction: LOCKED"
        );
        auctions[_nftAddress][_tokenId].locked = true;
        _;
        auctions[_nftAddress][_tokenId].locked = false;
    }


    modifier auctionRunning(address _nftAddress, uint256 _tokenId) {
        require(
            _isAuctionRunning(_nftAddress, _tokenId),
            "Auction: NOT_RUNNING"
        );
        _;
    }

    modifier auctionFinished(address _nftAddress, uint256 _tokenId) {
        require(
            _isAuctionFinished(_nftAddress, _tokenId),
            "Auction: NOT_FINISHED"
        );
        _;
    }

    modifier auctionExists(address _nftAddress, uint256 _tokenId) {
        require(_isAuctionExists(_nftAddress, _tokenId), "Auction: NOT_EXISTS");
        _;
    }

    modifier auctionNotExists(address _nftAddress, uint256 _tokenId) {
        require(
            !_isAuctionExists(_nftAddress, _tokenId),
            "Auction: ALREADY_EXISTS"
        );
        _;
    }

    modifier auctionValid(address _nftAddress, uint256 _tokenId) {
        require(_isAuctionValid(_nftAddress, _tokenId), "Auction: NOT_VALID");
        _;
    }

    modifier onlyWinner(address _nftAddress, uint256 _tokenId) {
        require(_isAuctionWinner(_nftAddress, _tokenId), FORBIDDEN);
        _;
    }

    modifier onlyLooser(address _nftAddress, uint256 _tokenId) {
        require(
            _isAuctionLooser(_nftAddress, _tokenId),
            FORBIDDEN
        );
        _;
    }

    /*╔══════════════════════════════╗
      ║    AUCTION CHECK FUNCTIONS   ║
      ╚══════════════════════════════╝*/


    function _isAuctionExists(address _nftAddress, uint256 _tokenId)
        internal
        view
        returns (bool)
    {
        return auctions[_nftAddress][_tokenId].quote != address(0);
    }

    function _isAuctionRunning(address _nftAddress, uint256 _tokenId)
        internal
        view
        returns (bool)
    {
        return block.timestamp > auctions[_nftAddress][_tokenId].auctionStart && block.timestamp < auctions[_nftAddress][_tokenId].auctionEnd && auctions[_nftAddress][_tokenId].blockEnd == 0;
    }

    function _isAuctionFinished(address _nftAddress, uint256 _tokenId)
        internal
        view
        returns (bool)
    {
        return (auctions[_nftAddress][_tokenId].blockEnd != 0 || block.timestamp >= auctions[_nftAddress][_tokenId].auctionEnd);
    }

    function _isAuctionValid(address _nftAddress, uint256 _tokenId)
        internal
        view
        returns (bool)
    {
        address _highestBidder = auctions[_nftAddress][_tokenId].highestBidder;
        uint256 _highestBid = auctions[_nftAddress][_tokenId].bids[_highestBidder];
        return
            _highestBidder != address(0) &&
            _highestBid >= auctions[_nftAddress][_tokenId].minPrice && 
            auctions[_nftAddress][_tokenId].maxPrice > 0 ? _highestBid <= auctions[_nftAddress][_tokenId].maxPrice : true;
    }

    function _isAuctionWinner(address _nftAddress, uint256 _tokenId)
        internal
        view
        returns (bool)
    {
        address _highestBidder = auctions[_nftAddress][_tokenId].highestBidder;
        return _highestBidder != address(0) && _highestBidder == _msgSender();
    }

    function _isAuctionLooser(address _nftAddress, uint256 _tokenId)
        internal
        view
        returns (bool)
    {
         return auctions[_nftAddress][_tokenId].bids[_msgSender()] != 0 && auctions[_nftAddress][_tokenId].highestBidder != _msgSender();
    }
}