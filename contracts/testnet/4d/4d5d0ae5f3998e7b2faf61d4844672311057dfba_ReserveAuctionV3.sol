/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


// File @openzeppelin/contracts/utils/[email protected]



pragma solidity ^0.6.0;

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
contract ReentrancyGuard {
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

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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


// File @openzeppelin/contracts/introspection/[email protected]



pragma solidity ^0.6.0;

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


// File @openzeppelin/contracts/token/ERC721/[email protected]



pragma solidity ^0.6.2;

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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}


// File @openzeppelin/contracts/GSN/[email protected]



pragma solidity ^0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// File @openzeppelin/contracts/access/[email protected]



pragma solidity ^0.6.0;

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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


// File contracts/TokenDetArrayLib.sol

pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;


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

    function addTokenDet(
        TokenDets storage self,
        TokenDet memory _tokenDet
    ) public {
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

    function removeTokenDet(
        TokenDets storage self,
        TokenDet memory _tokenDet
    ) internal returns (bool) {
        (uint256 i, bool tokenExists) = self.getIndexByTokenDet(_tokenDet);
        if (tokenExists == true) {
            self.array[i] = self.array[self.array.length - 1];
            self.array.pop();
            return true;
        }
        return false;
    }

    function exists(
        TokenDets storage self,
        TokenDet memory _tokenDet
    ) internal view returns (bool) {
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


interface IBNB {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);
}

interface IBlacklistManager {
    function isBalcklisted(address _sender)
        external
        view
        returns (bool);

    function underAttackMode() external view returns (bool);

    function actionAllowed(address _sender)
        external
        view
        returns (bool);
}

interface BleufiNft {
    // Required methods

    function royalities(uint256 _tokenId) external view returns (uint256);

    function creators(uint256 _tokenId) external view returns (address payable);

    function burn(uint256 _tokenId) external;
}

contract ReserveAuctionV3 is ReentrancyGuard, Ownable {
    // Use OpenZeppelin's SafeMath library to prevent overflows.
    using SafeMath for uint256;

    // Using custom library to handle multiple collections
    using TokenDetArrayLib for TokenDetArrayLib.TokenDets;

    // ============ Constants ============

    // The minimum amount of time left in an auction after a new bid is created; 15 min.
    uint16 public constant TIME_BUFFER = 900;
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
    address public immutable adminRecoveryAddress;
    address public blacklistAddress;
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
    bool private _adminRecoveryEnabled;
    /**
     * The account `adminRecoveryAddress` can also pause the contracts
     * while _adminRecoveryEnabled is enabled. This prevents people from using
     * the contract if there is a known problem with it.
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
        uint8 curatorFeePercent;
        // The address of the auction's curator. The curator
        // can cancel the auction if it hasn't had a bid yet.
        address curator;
        // The address of the current highest bid.
        address payable bidder;
        // The address that should receive funds once the NFT is sold.
        address payable fundsRecipient;
        // The address will be owner of NFT
        address owner;
    }

    // ============ Events ============

    // All of the details of a new auction,
    // with an index created for the tokenId.
    event AuctionCreated(
        uint256 indexed tokenId,
        address nftContractAddress,
        uint256 duration,
        uint256 reservePrice,
        uint8 curatorFeePercent,
        address curator,
        address fundsRecipient
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
        address curator
    );

    // All of the details of an auction's close,
    // with an index created for the tokenId.
    event AuctionEnded(
        uint256 indexed tokenId,
        address nftContractAddress,
        address curator,
        address winner,
        uint256 amount,
        address nftCreator,
        address payable fundsRecipient
    );

    // When the curator recevies fees, emit the details including the amount,
    // with an index created for the tokenId.
    event CuratorFeePercentTransfer(
        uint256 indexed tokenId,
        address curator,
        uint256 amount
    );

    // Emitted in the case that the contract is paused.
    event Paused(address account);
    // Emitted when the contract is unpaused.
    event Unpaused(address account);

    // ============ Modifiers ============

    // Reverts if the sender is not admin, or admin
    // functionality has been turned off.
    modifier onlyAdminRecovery() {
        require(
            // The sender must be the admin address, and
            // adminRecovery must be set to true.
            adminRecoveryAddress == msg.sender && adminRecoveryEnabled(),
            "Caller does not have admin privileges"
        );
        _;
    }

    // Reverts if the sender is not the auction's curator.
    modifier onlyCurator(address nftContract, uint256 tokenId) {
        require(
            auctions[nftContract][tokenId].curator == msg.sender,
            "Can only be called by auction curator"
        );
        _;
    }

    // Reverts if the contract is paused.
    modifier whenNotPaused() {
        require(!paused(), "Contract is paused");
        _;
    }

    // Reverts if the auction does not exist.
    modifier auctionExists(address nftContract, uint256 tokenId) {
        // The auction exists if the curator is not null.
        require(
            !auctionCuratorIsNull(nftContract, tokenId),
            "Auction doesn't exist"
        );
        _;
    }

    // Reverts if the auction exists.
    modifier auctionNonExistant(address nftContract, uint256 tokenId) {
        // The auction does not exist if the curator is null.
        require(
            auctionCuratorIsNull(nftContract, tokenId),
            "Auction already exists"
        );
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

    constructor(
        address wbnbAddress_,
        address adminRecoveryAddress_,
        address _blacklistAddress,
        address payable _broker,
        uint256 _brokrageAmt
    ) public {
        // Initialize immutable memory.
        wbnbAddress = wbnbAddress_;
        adminRecoveryAddress = adminRecoveryAddress_;
        // Initialize mutable memory.
        blacklistAddress = _blacklistAddress;
        _paused = false;
        _adminRecoveryEnabled = true;
        _setBrokerDetails(_broker, _brokrageAmt);
    }

    // ============ set brokerAddress and brokrage ============
    function setBrokerDetails(address payable _broker, uint256 _brokrageAmt)
        public
        onlyOwner
    {
        _setBrokerDetails(_broker, _brokrageAmt);
    }

    function _setBrokerDetails(address payable _broker, uint256 _brokrageAmt)
        internal
    {
        require(_brokrageAmt < 100, "Brokerage can't be 100%");
        brokerAddress = _broker;
        brokrage = _brokrageAmt;
    }

    // ============ set brokerAddress and brokrage ============

    // ============ getters for public variables ============
    function getAuctionTokensForSale()
        external
        view
        returns (TokenDetArrayLib.TokenDet[] memory)
    {
        return auctionTokens.array;
    }

    function getTokensForSalePerUser(address _user)
        public
        view
        returns (TokenDetArrayLib.TokenDet[] memory)
    {
        return tokensForSalePerUser[_user].array;
    }

    function _addToSaleMappings(address nftContract, uint256 tokenId) private {
        TokenDetArrayLib.TokenDet memory _tokenDet = TokenDetArrayLib.TokenDet(
            nftContract,
            tokenId
        );
        tokensForSalePerUser[msg.sender].addTokenDet(_tokenDet);
        auctionTokens.addTokenDet(_tokenDet);
    }

    function _removeFromSaleMappings(address nftContract, uint256 tokenId)
        private
    {
        TokenDetArrayLib.TokenDet memory _tokenDet = TokenDetArrayLib.TokenDet(
            nftContract,
            tokenId
        );
        tokensForSalePerUser[msg.sender].removeTokenDet(_tokenDet);
        auctionTokens.removeTokenDet(_tokenDet);
    }

    // ============ getters for public variables ============

    // ============ Create Auction ============

    function createAuction(
        address nftContract,
        uint256 tokenId,
        uint256 duration,
        uint256 reservePrice,
        uint8 curatorFeePercent,
        address curator,
        address payable fundsRecipient
    )
        external
        nonReentrant
        whenNotPaused
        auctionNonExistant(nftContract, tokenId)
    {
        // Check basic input requirements are reasonable.
        require(
            IBlacklistManager(blacklistAddress).actionAllowed(msg.sender) ==
                true,
            "Action not allowed. User may be blackliested or system maybe in underattckMode"
        );
        require(curator != address(0));
        require(
            curator == brokerAddress,
            "curator address  should be equal to brokeraddress"
        );
        require(fundsRecipient != address(0));
        require(curatorFeePercent >= brokrage, "Curator fee should be < 100");
        // Initialize the auction details, including null values.
        auctions[nftContract][tokenId] = Auction({
            duration: duration,
            reservePrice: reservePrice,
            curatorFeePercent: curatorFeePercent,
            curator: curator,
            fundsRecipient: fundsRecipient,
            amount: 0,
            firstBidTime: 0,
            bidder: address(0),
            owner: IERC721(nftContract).ownerOf(tokenId)
        });
        // Transfer the NFT into this auction contract, from whoever owns it.
        IERC721(nftContract).transferFrom(
            IERC721(nftContract).ownerOf(tokenId),
            address(this),
            tokenId
        );
        // Emit an event describing the new auction.
        emit AuctionCreated(
            tokenId,
            nftContract,
            duration,
            reservePrice,
            curatorFeePercent,
            curator,
            fundsRecipient
        );

        // Add to mappings.
        _addToSaleMappings(nftContract, tokenId);
    }

    // ============ Create Bid ============

    function createBid(
        address nftContract,
        uint256 tokenId,
        uint256 amount
    )
        external
        payable
        nonReentrant
        whenNotPaused
        auctionExists(nftContract, tokenId)
        auctionNotExpired(nftContract, tokenId)
    {
        // Validate that the user's expected bid value matches the BNB deposit.
        require(amount == msg.value, "Amount doesn't equal msg.value");
        require(amount > 0, "Amount must be greater than 0");
        // Check if the current bid amount is 0.
        if (auctions[nftContract][tokenId].amount == 0) {
            // If so, it is the first bid.
            auctions[nftContract][tokenId].firstBidTime = block.timestamp;
            // We only need to check if the bid matches reserve bid for the first bid,
            // since future checks will need to be higher than any previous bid.
            require(
                amount >= auctions[nftContract][tokenId].reservePrice,
                "Must bid reservePrice or more"
            );
        } else {
            // Check that the new bid is sufficiently higher than the previous bid, by
            // the percentage defined as MIN_BID_INCREMENT_PERCENT.
            require(
                amount >=
                    auctions[nftContract][tokenId].amount.add(
                        // Add 10% of the current bid to the current bid.
                        auctions[nftContract][tokenId]
                            .amount
                            .mul(MIN_BID_INCREMENT_PERCENT)
                            .div(100)
                    ),
                "Must bid more than last bid by MIN_BID_INCREMENT_PERCENT amount"
            );

            // Refund the previous bidder.
            transferBNBOrWBNB(
                auctions[nftContract][tokenId].bidder,
                auctions[nftContract][tokenId].amount
            );
        }
        // Update the current auction.
        auctions[nftContract][tokenId].amount = amount;
        auctions[nftContract][tokenId].bidder = msg.sender;
        // Compare the auction's end time with the current time plus the 15 minute extension,
        // to see whether we're near the auctions end and should extend the auction.
        if (
            auctionEnds(nftContract, tokenId) < block.timestamp.add(TIME_BUFFER)
        ) {
            // We add onto the duration whenever time increment is required, so
            // that the auctionEnds at the current time plus the buffer.
            auctions[nftContract][tokenId].duration += block
                .timestamp
                .add(TIME_BUFFER)
                .sub(auctionEnds(nftContract, tokenId));
        }
        // Emit the event that a bid has been made.
        emit AuctionBid(tokenId, nftContract, msg.sender, amount);
    }

    // ============ End Auction ============

    function endAuction(address nftContract, uint256 tokenId)
        external
        nonReentrant
        whenNotPaused
        auctionComplete(nftContract, tokenId)
    {
        // Store relevant auction data in memory for the life of this function.
        BleufiNft Token = BleufiNft(nftContract);

        address payable creator;
        try Token.creators(tokenId) returns (address payable _creator) {
            creator = _creator;
        } catch {
            creator = address(0);
        }
        uint256 royalities;
        try Token.royalities(tokenId) returns (uint256 _royalities) {
            royalities = _royalities;
        } catch {
            royalities = 0;
        }

        uint256 royality;
        if (royalities != 0) {
            (royalities * auctions[nftContract][tokenId].amount) / 10000;
        } else {
            royality = 0;
        }

        address winner = auctions[nftContract][tokenId].bidder;
        uint256 amount = auctions[nftContract][tokenId].amount;
        address curator = auctions[nftContract][tokenId].curator;
        uint8 curatorFeePercent = auctions[nftContract][tokenId]
            .curatorFeePercent;
        address payable fundsRecipient = auctions[nftContract][tokenId]
            .fundsRecipient;
        // Remove all auction data for this token from storage.
        delete auctions[nftContract][tokenId];
        // We don't use safeTransferFrom, to prevent reverts at this point,
        // which would break the auction.
        IERC721(nftContract).transferFrom(address(this), winner, tokenId);

        // First handle the curator's fee.
        if (curatorFeePercent > 0) {
            // Determine the curator amount, which is some percent of the total.
            uint256 curatorAmount = amount.mul(curatorFeePercent).div(100);
            // Send it to the curator.
            transferBNBOrWBNB(curator, curatorAmount);
            // Subtract the curator amount from the total funds available
            // to send to the funds recipient and original NFT creator.
            amount = amount.sub(curatorAmount);
            // Emit the details of the transfer as an event.
            emit CuratorFeePercentTransfer(tokenId, curator, curatorAmount);
        }
        if (creator == fundsRecipient) {
            transferBNBOrWBNB(creator, amount);
        } else {
            // Otherwise, we should determine the percent that goes to the creator.
            // Send the creator's share to the creator.
            if (royality > 0) {
                transferBNBOrWBNB(creator, royality);
            }

            // Send the remainder of the amount to the funds recipient.
            transferBNBOrWBNB(fundsRecipient, amount.sub(royality));
        }
        // Emit an event describing the end of the auction.
        emit AuctionEnded(
            tokenId,
            nftContract,
            curator,
            winner,
            amount,
            creator,
            fundsRecipient
        );

        // remove from mappings.
        _removeFromSaleMappings(nftContract, tokenId);
    }

    // ============ Cancel Auction ============

    function cancelAuction(address nftContract, uint256 tokenId)
        external
        nonReentrant
        auctionExists(nftContract, tokenId)
        onlyOwner
    {
        // Check that there hasn't already been a bid for this NFT.
        require(
            uint256(auctions[nftContract][tokenId].firstBidTime) == 0,
            "Auction already started"
        );
        // Pull the creator address before removing the auction.
        address owner = auctions[nftContract][tokenId].owner;
        // Remove all data about the auction.
        delete auctions[nftContract][tokenId];
        // Transfer the NFT back to the curator.
        IERC721(nftContract).transferFrom(address(this), owner, tokenId);
        // Emit an event describing that the auction has been canceled.
        emit AuctionCanceled(tokenId, nftContract, owner);

        _removeFromSaleMappings(nftContract, tokenId);
    }

    function removeNFTs(
        address[] calldata nftContracts,
        uint256[] calldata tokenIds,
        bool burnNFT
    ) external onlyOwner {
        require(
            nftContracts.length == tokenIds.length,
            "Must have same number of nftContracts and tokenIds"
        );
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
                if (burnNFT) {
                    try BleufiNft(nftContracts[i]).burn(tokenIds[i]) {} catch {}
                } else {
                    try
                        IERC721(nftContracts[i]).transferFrom(
                            // From the auction contract.
                            address(this),
                            // To the recovery account.
                            adminRecoveryAddress,
                            // For the specified token.
                            tokenIds[i]
                        )
                    {} catch {}
                }
            }
            delete auctions[nftContracts[i]][tokenIds[i]];
            // Emit an event describing that the auction has been canceled.
            emit AuctionCanceled(tokenIds[i], nftContracts[i], msg.sender);

            _removeFromSaleMappings(nftContracts[i], tokenIds[i]);
        }
    }

    // ============ Admin Functions ============

    // Irrevocably turns off admin recovery.
    function turnOffAdminRecovery() external onlyAdminRecovery {
        _adminRecoveryEnabled = false;
    }

    function deleteNFT(address nftContract, uint256 tokenId)
        external
        onlyOwner
    {
        require(
            IERC721(nftContract).ownerOf(tokenId) == address(this),
            "NFT not availalbe"
        );
        if (auctions[nftContract][tokenId].bidder != address(0)) {
            transferBNBOrWBNB(
                auctions[nftContract][tokenId].bidder,
                auctions[nftContract][tokenId].amount
            );
        }
        delete auctions[nftContract][tokenId];
        _removeFromSaleMappings(nftContract, tokenId);
        BleufiNft(nftContract).burn(tokenId);
    }

    function pauseContract() external onlyAdminRecovery {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpauseContract() external onlyAdminRecovery {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    // Allows the admin to transfer any NFT from this contract
    // to the recovery address.
    function recoverNFT(address nftContract, uint256 tokenId)
        external
        onlyAdminRecovery
    {
        IERC721(nftContract).transferFrom(
            // From the auction contract.
            address(this),
            // To the recovery account.
            adminRecoveryAddress,
            // For the specified token.
            tokenId
        );
    }

    // Allows the admin to transfer any BNB from this contract to the recovery address.
    function recoverBNB(uint256 amount)
        external
        onlyAdminRecovery
        returns (bool success)
    {
        // Attempt an BNB transfer to the recovery account, and return true if it succeeds.
        success = attemptBNBTransfer(adminRecoveryAddress, amount);
    }

    // ============ Miscellaneous Public and External ============

    // Returns true if the contract is paused.
    function paused() public view returns (bool) {
        return _paused;
    }

    // Returns true if admin recovery is enabled.
    function adminRecoveryEnabled() public view returns (bool) {
        return _adminRecoveryEnabled;
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
    function attemptBNBTransfer(address to, uint256 value)
        private
        returns (bool)
    {
        // Here increase the gas limit a reasonable amount above the default, and try
        // to send BNB to the recipient.
        // NOTE: This might allow the recipient to attempt a limited reentrancy attack.
        (bool success, ) = to.call{value: value, gas: 30000}("");
        return success;
    }

    // Returns true if the auction's curator is set to the null address.
    function auctionCuratorIsNull(address nftContract, uint256 tokenId)
        private
        view
        returns (bool)
    {
        // The auction does not exist if the curator is the null address,
        // since the NFT would not have been transferred in `createAuction`.
        return auctions[nftContract][tokenId].curator == address(0);
    }

    // Returns the timestamp at which an auction will finish.
    function auctionEnds(address nftContract, uint256 tokenId)
        private
        view
        returns (uint256)
    {
        // Derived by adding the auction's duration to the time of the first bid.
        // NOTE: duration can be extended conditionally after each new bid is added.
        return
            auctions[nftContract][tokenId].firstBidTime.add(
                auctions[nftContract][tokenId].duration
            );
    }
}