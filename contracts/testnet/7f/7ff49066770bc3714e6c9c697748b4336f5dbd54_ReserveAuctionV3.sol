/**
 *Submitted for verification at BscScan.com on 2022-04-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

// librray for TokenDets
library TokenDetArrayLib {
    // Using for array of strcutres for storing mintable address and token id
    using TokenDetArrayLib for TokenDets;

    struct TokenDet {
        address NFTAddress;
        uint256 tokenID;
    }

    // custom type array TokenDets
    struct TokenDets {
        TokenDet[] array;
    }

    function addTokenDet(TokenDets storage self, TokenDet memory _tokenDet)
        internal
    {
        if (!self.exists(_tokenDet)) {
            self.array.push(_tokenDet);
        }
    }

    function getIndexByTokenDet(
        TokenDets storage self,
        TokenDet memory _tokenDet
    ) internal view returns (uint256, bool) {
        uint256 index;
        bool tokenExists = false;
        for (uint256 i = 0; i < self.array.length; i++) {
            if (
                self.array[i].NFTAddress == _tokenDet.NFTAddress &&
                self.array[i].tokenID == _tokenDet.tokenID
            ) {
                index = i;
                tokenExists = true;
                break;
            }
        }
        return (index, tokenExists);
    }

    function removeTokenDet(TokenDets storage self, TokenDet memory _tokenDet)
        internal
        returns (bool)
    {
        (uint256 i, bool tokenExists) = self.getIndexByTokenDet(_tokenDet);
        if (tokenExists == true) {
            self.array[i] = self.array[self.array.length - 1];
            self.array.pop();
            return true;
        }
        return false;
    }

    function exists(TokenDets storage self, TokenDet memory _tokenDet)
        internal
        view
        returns (bool)
    {
        for (uint256 i = 0; i < self.array.length; i++) {
            if (
                self.array[i].NFTAddress == _tokenDet.NFTAddress &&
                self.array[i].tokenID == _tokenDet.tokenID
            ) {
                return true;
            }
        }
        return false;
    }
}
// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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

// File: contracts/ReserveAuctionV3.sol


pragma solidity ^0.8.12;

// OpenZeppelin library for performing math operations without overflows.

// OpenZeppelin security library for preventing reentrancy attacks.


// For checking `supportsInterface`.

// For interacting with NFT tokens.




interface IBNB {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
}
interface IBleufiNft is IERC721 {
    // Required methods
    function royalities(uint256 _tokenId) external view returns (uint256);
    function creators(uint256 _tokenId) external view returns (address payable);
}
contract ReserveAuctionV3 is ReentrancyGuard, Ownable {
    // Use OpenZeppelin's SafeMath library to prevent overflows.
    using SafeMath for uint256;
    // Using custom library to handle multiple collections
    using TokenDetArrayLib for TokenDetArrayLib.TokenDets;
    // ============ Constants ============
    // The minimum amount of time left in an auction after a new bid is created; 15 min.
    uint16 public constant TIME_BUFFER = 60;
    // The BNB needed above the current bid for a new bid to be valid; 0.001 BNB.
    uint8 public constant MIN_BID_INCREMENT_PERCENT = 10;
    // Interface constant for ERC721, to check values in constructor.
    bytes4 private constant ERC721_INTERFACE_ID = 0x80ac58cd;
    // Allows external read `getVersion()` to return a version for the auction.
    uint256 private constant RESERVE_AUCTION_VERSION = 1;
    // ============ Immutable Storage ============
    // The address of the ERC721 contract for tokens auctioned via this contract.
    // address public immutable nftContract;
    // The address of the WBNB contract, so that BNB can be transferred via
    // WBNB if native BNB transfers fail.
    address public immutable wbnbAddress;
    // The address that initially is able to recover assets.
    // address public immutable adminRecoveryAddress;
     address payable public brokerAddress;
     uint256 public brokrage;
    // ============ Mutable Storage ============
    /**
     * To start, there will be an admin account that can recover funds
     * if anything goes wrong. Later, this public flag will be irrevocably
     * set to false, removing any admin privileges forever.
     *
     * To check if admin recovery is enabled, call the public function `adminRecoveryEnabled()`.
     */
    bool private _paused;
    // A mapping of all of the auctions currently running.
    mapping(address => mapping(uint256 => Auction)) public auctions;
    // A mapping to store all NFts on sale per user.
    mapping(address => TokenDetArrayLib.TokenDets) tokensForSalePerUser;
    // A mapping to store All NFTs on sale
    TokenDetArrayLib.TokenDets auctionTokens;
    // ============ Structs ============
    struct Auction {
        // The value of the current highest bid.
        uint256 amount;
        // The amount of time that the auction should run for,
        // after the first bid was made.
        uint256 duration;
        // The time of the first bid.
        uint256 firstBidTime;
        // The minimum price of the first bid.
        uint256 reservePrice;
        // The address of the current highest bid.
        address payable bidder;
        // The address will be owner of NFT
        address  owner;
    }
    // ============ Events ============
    // All of the details of a new auction,
    // with an index created for the tokenId.
    event AuctionCreated(
        uint256 indexed tokenId,
        address nftContractAddress,
        uint256 auctionStart,
        uint256 duration,
        uint256 reservePrice,
        address owner
    );
    // All of the details of a new bid,
    // with an index created for the tokenId.
    event AuctionBid(
        uint256 indexed tokenId,
        address nftContractAddress,
        address sender,
        uint256 value
    );
    // All of the details of an auction's cancelation,
    // with an index created for the tokenId.
    event AuctionCanceled(
        uint256 indexed tokenId,
        address nftContractAddress,
        address owner
    );

    // All of the details of an auction's close,
    // with an index created for the tokenId.
    event AuctionEnded(
        uint256 indexed tokenId,
        address nftContractAddress,
        address winner,
        uint256 amount,
        address owner
    );
    // Emitted in the case that the contract is paused.
    event Paused(address account);
    // Emitted when the contract is unpaused.
    event Unpaused(address account);
    // ============ Modifiers ============
   // Reverts if the contract is paused.
    modifier whenNotPaused() {
        require(!paused(), "Contract is paused");
        _;
    }
    // Reverts if the auction does not exist.
    modifier auctionExists(address nftContract, uint256 tokenId) {
   // The auction exists if the owner is not null.
        require(!auctionCuratorIsNull(nftContract, tokenId),"Auction doesn't exist");
        _;
    }
    // Reverts if the auction exists.
    modifier auctionNonExistant(address nftContract, uint256 tokenId) {
        // The auction does not exist if the  owner is null.
        require(auctionCuratorIsNull(nftContract, tokenId), "Auction already exists");
        _;
    }
    // Reverts if the auction is expired.
    modifier auctionNotExpired(address nftContract, uint256 tokenId) {
        require(
            // Auction is not expired if there's never been a bid, or if the
            // current time is less than the time at which the auction ends.
            auctions[nftContract][tokenId].firstBidTime == 0 ||
                block.timestamp < auctionEnds(nftContract, tokenId),
            "Auction expired"
        );
        _;
    }
    // Reverts if the auction is not complete.
    // Auction is complete if there was a bid, and the time has run out.
    modifier auctionComplete(address nftContract, uint256 tokenId) {
        require(
            // Auction is complete if there has been a bid, and the current time
            // is greater than the auction's end time.
            auctions[nftContract][tokenId].firstBidTime > 0 &&
                block.timestamp >= auctionEnds(nftContract, tokenId),
            "Auction hasn't completed"
        );
        _;
    }
    // ============ Constructor ============
    constructor(address wbnbAddress_,address payable _broker,uint256 _brokrageAmt) {
        // Initialize immutable memory.
        wbnbAddress = wbnbAddress_;
        _paused = false;
        _setBrokerDetails(_broker, _brokrageAmt);
    }
    // ============ set brokerAddress and brokrage ============
    function setBrokerDetails(address payable _broker, uint256 _brokrageAmt) public onlyOwner{
        _setBrokerDetails(_broker, _brokrageAmt);
    }
    function _setBrokerDetails(address payable _broker, uint256 _brokrageAmt) internal{
        require(_brokrageAmt < 100, "Brokerage can't be 100%");
        brokerAddress = _broker;
        brokrage = _brokrageAmt;
    }
    // ============ set brokerAddress and brokrage ============
    // ============ getters for public variables ============
    function getAuctionTokensForSale()external view returns (TokenDetArrayLib.TokenDet[] memory){
        return auctionTokens.array;
    }
    function getTokensForSalePerUser(address _user) public view returns (TokenDetArrayLib.TokenDet[] memory)
    {
        return tokensForSalePerUser[_user].array;
    }
    function _addToSaleMappings(address nftContract, uint256 tokenId) private {
        TokenDetArrayLib.TokenDet memory _tokenDet =
            TokenDetArrayLib.TokenDet(nftContract, tokenId);
        tokensForSalePerUser[msg.sender].addTokenDet(_tokenDet);
        auctionTokens.addTokenDet(_tokenDet);
    }
    function _removeFromSaleMappings(address nftContract, uint256 tokenId)private{
        TokenDetArrayLib.TokenDet memory _tokenDet =
            TokenDetArrayLib.TokenDet(nftContract, tokenId);
        tokensForSalePerUser[msg.sender].removeTokenDet(_tokenDet);
        auctionTokens.removeTokenDet(_tokenDet);
        delete auctions[nftContract][tokenId];

    }
    // ============ getters for public variables ============
    // ============ Create Auction ============
    function createAuction(address nftContract,uint256 tokenId,uint256 duration,uint256 reservePrice) external nonReentrant whenNotPaused auctionNonExistant(nftContract, tokenId){
      uint256 auctionCreatetime = block.timestamp;
      // Check basic input requirements are reasonable.
      IBleufiNft instane = IBleufiNft(nftContract);
    require(instane.isApprovedForAll(instane.ownerOf(tokenId), address(this)) || instane.getApproved(tokenId) == address(this),"address not approve for putOnsale the NFT" );
       
       address _owner =instane.ownerOf(tokenId);
        // Initialize the auction details, including null values.
        auctions[nftContract][tokenId] = Auction({
         duration: duration,reservePrice: reservePrice,amount: 0,firstBidTime: 0,bidder: payable(address(0)),owner : _owner
        });
        // Transfer the NFT into this auction contract, from whoever owns it.
        instane.transferFrom(instane.ownerOf(tokenId), address(this), tokenId);
        // Emit an event describing the new auction.
        emit AuctionCreated(tokenId, nftContract, auctionCreatetime, duration, reservePrice ,_owner );
        // Add to mappings.
        _addToSaleMappings(nftContract, tokenId);
    }
    // ============ Create Bid ============
    function createBid(address nftContract, uint256 tokenId, uint256 amount) external payable nonReentrant whenNotPaused auctionExists(nftContract, tokenId) auctionNotExpired(nftContract, tokenId){
        // Validate that the user's expected bid value matches the BNB deposit.
        require(amount == msg.value, "Amount doesn't equal msg.value");
        require(amount > 0, "Amount must be greater than 0");
        // Check if the current bid amount is 0.
        if (auctions[nftContract][tokenId].amount == 0) {
            // If so, it is the first bid.
            auctions[nftContract][tokenId].firstBidTime = block.timestamp;
            // We only need to check if the bid matches reserve bid for the first bid,
            // since future checks will need to be higher than any previous bid.
            require(amount >= auctions[nftContract][tokenId].reservePrice,"Must bid reservePrice or more");
        } else {
            // Check that the new bid is sufficiently higher than the previous bid, by
            // the percentage defined as MIN_BID_INCREMENT_PERCENT.
            // Add 10% of the current bid to the current bid.
            require(amount >= auctions[nftContract][tokenId].amount.add(auctions[nftContract][tokenId].amount.mul(MIN_BID_INCREMENT_PERCENT).div(100)),"Must bid more than last bid by MIN_BID_INCREMENT_PERCENT amount");
           // Refund the previous bidder.
            transferBNBOrWBNB(auctions[nftContract][tokenId].bidder, auctions[nftContract][tokenId].amount);
        }
        // Update the current auction.
        auctions[nftContract][tokenId].amount = amount;
        auctions[nftContract][tokenId].bidder = payable(msg.sender);
        // Compare the auction's end time with the current time plus the 15 minute extension,
        // to see whether we're near the auctions end and should extend the auction.
        if (auctionEnds(nftContract, tokenId) < block.timestamp.add(TIME_BUFFER)) {
            // We add onto the duration whenever time increment is required, so
            // that the auctionEnds at the current time plus the buffer.
            auctions[nftContract][tokenId].duration += block.timestamp.add(TIME_BUFFER).sub(auctionEnds(nftContract, tokenId));}
        // Emit the event that a bid has been made.
        emit AuctionBid(tokenId, nftContract, msg.sender, amount);
    }
    // ============ End Auction ============
    function endAuction(address nftContract, uint256 tokenId)external nonReentrant whenNotPaused auctionComplete(nftContract, tokenId){
        // Store relevant auction data in memory for the life of this function.
        IBleufiNft Token = IBleufiNft(nftContract);

        address payable creator;
        uint256 royalities;
        try Token.creators(tokenId) returns (address payable _creator) {
            creator = _creator;
        } catch {
            creator = payable(address(0));
        }

        try Token.royalities(tokenId) returns (uint256 _royalities) {
            royalities = _royalities;
        } catch {
            royalities = 0;
        }

        if (royalities != 0) {
            (royalities * auctions[nftContract][tokenId].amount) / 1000;
        } else {
            royalities = 0;
        }
        address winner = auctions[nftContract][tokenId].bidder;
        uint256 amount = auctions[nftContract][tokenId].amount;
        address  fundsRecipient =
            auctions[nftContract][tokenId].owner;
            IBleufiNft(nftContract).transferFrom(address(this), winner, tokenId);
        // First handle the  owner's fee.
        if (brokrage > 0) {
            // Determine the  owner amount, which is some percent of the total.
            uint256 borkerAmount = amount.mul(brokrage).div(100);
            // Send it to the  owner.
            transferBNBOrWBNB(brokerAddress, borkerAmount);
            // Subtract the  owner amount from the total funds available
            // to send to the funds recipient and original NFT creator.
            amount = amount.sub(borkerAmount);
            // Emit the details of the transfer as an event.
        }
        if (creator == fundsRecipient) {
            transferBNBOrWBNB(creator, amount);
        } else {
            // Otherwise, we should determine the percent that goes to the creator.
            // Send the creator's share to the creator.
            if (royalities > 0) {
                transferBNBOrWBNB(creator, royalities);
            }
            // Send the remainder of the amount to the funds recipient.
            transferBNBOrWBNB(fundsRecipient, amount.sub(royalities));
        }
        // Emit an event describing the end of the auction.
        emit AuctionEnded(tokenId, nftContract, winner, amount, fundsRecipient);
        // remove from mappings.
        _removeFromSaleMappings(nftContract, tokenId);
        
    }
    // ============ Cancel Auction ============
    function cancelAuction(address nftContract, uint256 tokenId) external nonReentrant auctionExists(nftContract, tokenId) onlyOwner{
        // Check that there hasn't already been a bid for this NFT.
        require(uint256(auctions[nftContract][tokenId].firstBidTime) == 0, "Auction already started");
        // Pull the creator address before removing the auction.
        address owner = auctions[nftContract][tokenId].owner;
        // Remove all data about the auction.
        //delete auctions[nftContract][tokenId];
        // Transfer the NFT back to the  owner.
        IBleufiNft(nftContract).transferFrom(address(this), owner, tokenId);
        // Emit an event describing that the auction has been canceled.
        emit AuctionCanceled(tokenId, nftContract, owner);

        _removeFromSaleMappings(nftContract, tokenId);
    }
    function transferNFTs(address[] calldata nftContracts, uint256[] calldata tokenIds, address _toAddress ) external onlyOwner {
        require(nftContracts.length == tokenIds.length, "Must have same number of nftContracts and tokenIds");
        for (uint256 i = 0; i < nftContracts.length; i++) {
            IBleufiNft erc721 = IBleufiNft(nftContracts[i]);
            if (erc721.ownerOf(tokenIds[i]) == address(this)) {
                erc721.transferFrom(address(this), _toAddress, tokenIds[i]);
            }
        }
    }
    function removeNFTs(address[] calldata nftContracts, uint256[] calldata tokenIds) external onlyOwner {
        require(nftContracts.length == tokenIds.length,"Must have same number of nftContracts and tokenIds");
        for (uint256 i = 0; i < nftContracts.length; i++) {
            if (auctions[nftContracts[i]][tokenIds[i]].owner != address(0)) {
                // transfer fund to bidder if any bid is there.
                if (
                    auctions[nftContracts[i]][tokenIds[i]].bidder != address(0)
                ) {
                    transferBNBOrWBNB(
                        auctions[nftContracts[i]][tokenIds[i]].bidder,
                        auctions[nftContracts[i]][tokenIds[i]].amount
                    );
                }
                else {
                    try
                        IBleufiNft(nftContracts[i]).transferFrom(
                            // From the auction contract.
                            address(this),
                            // To the recovery account.
                            auctions[nftContracts[i]][tokenIds[i]].owner,
                            // For the specified token.
                            tokenIds[i]
                        )
                    {} catch {}
                }
            }
          
            // Emit an event describing that the auction has been canceled.
            emit AuctionCanceled(tokenIds[i], nftContracts[i], msg.sender);

            _removeFromSaleMappings(nftContracts[i], tokenIds[i]);
        }
    }
    // ============ Admin Functions ============
    function pauseContract() external onlyOwner {
        _paused = true;
        emit Paused(msg.sender);
    }
    function unpauseContract() external onlyOwner {
        _paused = false;
        emit Unpaused(msg.sender);
    }
    // Allows the admin to transfer any NFT from this contract
    // to the recovery address.
    function recoverNFT(address nftContract, uint256 tokenId) external onlyOwner
    {
        IBleufiNft(nftContract).transferFrom(
            // From the auction contract.
            address(this),
            // To the recovery account.
            owner(),
            // For the specified token.
            tokenId
        );
    }
    // Allows the admin to transfer any BNB from this contract to the recovery address.
    function recoverBNB(uint256 amount) external onlyOwner returns (bool success)
    {
        // Attempt an BNB transfer to the recovery account, and return true if it succeeds.
        success = attemptBNBTransfer(owner(), amount);
    }
    // ============ Miscellaneous Public and External ============
    // Returns true if the contract is paused.
    function paused() public view returns (bool) {
        return _paused;
    }
    // Returns the version of the deployed contract.
    function getVersion() external pure returns (uint256 version) {
        version = RESERVE_AUCTION_VERSION;
    }
    // ============ Private Functions ============
    // Will attempt to transfer BNB, but will transfer WBNB instead if it fails.
    function transferBNBOrWBNB(address to, uint256 value) private {
        // Try to transfer BNB to the given recipient.
        if (!attemptBNBTransfer(to, value)) {
            // If the transfer fails, wrap and send as WBNB, so that
            // the auction is not impeded and the recipient still
            // can claim BNB via the WBNB contract (similar to escrow).
            IBNB(wbnbAddress).deposit{value: value}();
            IBNB(wbnbAddress).transfer(to, value);
            // At this point, the recipient can unwrap WBNB.
        }
    }
    // Sending BNB is not guaranteed complete, and the method used here will return false if
    // it fails. For example, a contract can block BNB transfer, or might use
    // an excessive amount of gas, thereby griefing a new bidder.
    // We should limit the gas used in transfers, and handle failure cases.
    function attemptBNBTransfer(address to, uint256 value) private returns (bool){
        // Here increase the gas limit a reasonable amount above the default, and try
        // to send BNB to the recipient.
        // NOTE: This might allow the recipient to attempt a limited reentrancy attack.
        (bool success, ) = to.call{value: value, gas: 30000}("");
        return success;
    }
    // Returns true if the auction's  owner is set to the null address.
    function auctionCuratorIsNull(address nftContract, uint256 tokenId) private view returns (bool)
    {
        // The auction does not exist if the  owner is the null address,
        // since the NFT would not have been transferred in `createAuction`.
        return auctions[nftContract][tokenId].owner == address(0);
    }

    // Returns the timestamp at which an auction will finish.
    function auctionEnds(address nftContract, uint256 tokenId) private view returns (uint256){
        // Derived by adding the auction's duration to the time of the first bid.
        // NOTE: duration can be extended conditionally after each new bid is added.
        return
            auctions[nftContract][tokenId].firstBidTime.add(auctions[nftContract][tokenId].duration);
    }
}