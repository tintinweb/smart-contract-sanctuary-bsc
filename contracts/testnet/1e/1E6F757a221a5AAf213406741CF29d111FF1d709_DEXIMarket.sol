// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./interfaces/IERC721TokenCreator.sol";

contract DEXIMarket is Ownable {
    using SafeMath for uint256;

    // Enum for the type of selling
    enum SELLING_TYPE { FIXED_PRICE, AUCTION, UNLIMITED_AUCTION }

    // Struct for the selling attributes
    struct Selling {
        SELLING_TYPE sellingType;
        address seller;
        uint256 price;
        uint256 startTime;
        uint256 endTime;
        address topBidder;
        uint256 topBid;
    }

    // Struct for the auction bid
    struct AuctionBid {
        uint256 value;
        address bidder;
    }

    address public paymentTokenAddress;
    address public nftContractAddress;

    address public feeAddress;
    uint256 public feePercent = 3;

    // Mapping from a token for selling to its attributes
    mapping (uint256=>Selling) public sellings;

    // Mapping from a token auction to its bids
    mapping (uint256=>AuctionBid[]) public tokenBids;

    // Contract events
    event AuctionCreated(address creator, uint256 price, uint256 startTime, uint256 endTime, uint256 tokenId);
    event AuctionClaimed(address seller, address winner, address creator, uint256 price, uint256 royalty, uint256 tokenId);
    event Sell(address seller, uint256 price, uint256 tokenId);
    event Purchase(address seller, address buyer, uint256 price, uint256 tokenId);
    event Bid(address bidder, uint tokenId, uint price);
    event PriceChanged(uint256 tokenId, uint256 price, address caller);
    event SellingCanceled(uint256 tokenId, address caller);
    event BidCanceled(address bidder, uint256 nftId);

    constructor(address _nftContractAddress, address _paymentTokenAddress) {
        nftContractAddress = _nftContractAddress;
        paymentTokenAddress = _paymentTokenAddress;
    }

    /**
     * @notice Sets the fee address and its percentage
     *
     * @param _feeAddress The fee address.
     * @param _feePercent The fee percentage.
     */
    function setFee(address _feeAddress, uint256 _feePercent) external onlyOwner {
        feeAddress = _feeAddress;
        feePercent = _feePercent;
    }

    /**
     * @notice Sets the payment token address
     *
     * @param _paymentTokenAddress The payment token address.
     */
    function setPaymentTokenAddress(address _paymentTokenAddress) external onlyOwner {
        paymentTokenAddress = _paymentTokenAddress;
    }

    /**
     * @notice Sets the NFT contract address
     *
     * @param _nftContractAddress The payment token address.
     */
    function setNftContractAddress(address _nftContractAddress) external onlyOwner {
        nftContractAddress = _nftContractAddress;
    }

    /**
     * @notice Creates new bulk auction sellings of tokens for a fixed price
     *
     * @param tokenIds Token IDs for selling.
     */
    function bulkCreateAuction(uint256[] memory tokenIds, uint256 price, uint256 startTime, uint256 endTime) external {
        for(uint i = 0; i < tokenIds.length; i++) {
            createAuction(tokenIds[i], price, startTime, endTime);
        }
    }

    /**
     * @notice Creates new sellings of tokens for a fixed price
     *
     * @param tokenIds Token IDs for selling.
     */
    function bulkSell(uint256[] memory tokenIds, uint256 price) external {
        for(uint i = 0; i < tokenIds.length; i++) {
            sell(tokenIds[i], price);
        }
    }

    /**
     * @notice Creates the new selling for a fixed price
     *
     * @param tokenId The token ID for selling.
     */
    function sell(uint256 tokenId, uint256 price) public {
        Selling storage selling = sellings[tokenId];

        address creator = IERC721TokenCreator(nftContractAddress).creator(tokenId);

        require(creator != address(0), "Token does not exist");
        require(selling.seller == address(0), "Selling has been created already");

        selling.sellingType = SELLING_TYPE.FIXED_PRICE;
        selling.seller = msg.sender;
        selling.price = price;

        IERC721(nftContractAddress).transferFrom(msg.sender, address(this), tokenId);

        emit Sell(msg.sender, price, tokenId);
    }

    /**
     * @notice The payable method executes to buy the token for selling
     *
     * @param tokenId The token ID for selling.
     */
    function buy(uint256 tokenId) external {
        Selling storage selling = sellings[tokenId];

        require(selling.sellingType == SELLING_TYPE.FIXED_PRICE, "This selling is not for fixed price");
        require(paymentTokenAddress != address(0), "Payment token is not set");

        uint256 price = selling.price;
        address seller = selling.seller;
        uint256 royalty = IERC721TokenCreator(nftContractAddress).royalty(tokenId);
        address creator = IERC721TokenCreator(nftContractAddress).creator(tokenId);

        delete sellings[tokenId];
        delete tokenBids[tokenId];

        // payments royalty to the creator, the fee to contract, and profit to the seller
        uint256 royaltyValue = price.div(100).mul(royalty);
        uint256 feeValue = price.div(100).mul(feePercent);
        uint256 profitValue = price.sub(feeValue).sub(royaltyValue);

        if (royaltyValue > 0) {
            IERC20(paymentTokenAddress).transferFrom(msg.sender, creator, royaltyValue);
        }

        IERC20(paymentTokenAddress).transferFrom(msg.sender, seller, profitValue);

        if (feeAddress != address(0) && feeValue > 0) {
            IERC20(paymentTokenAddress).transferFrom(msg.sender, feeAddress, feeValue);
        }

        IERC721(nftContractAddress).transferFrom(address(this), msg.sender, tokenId);

        emit Purchase(seller, msg.sender, price, tokenId);
    }

    /**
     * @notice Creates the new auction
     *
     * @param tokenId The token ID for selling.
     * @param price The minimum bid price.
     * @param endTime The timestamp of the auction ending time.
     */
    function createAuction(uint256 tokenId, uint256 price, uint256 startTime, uint256 endTime) public {
        Selling storage auction = sellings[tokenId];

        address creator = IERC721TokenCreator(nftContractAddress).creator(tokenId);

        require(creator != address(0), "Token does not exist");
        require(auction.seller == address(0), "Auction has been created already");

        auction.sellingType = endTime > 0 ? SELLING_TYPE.AUCTION : SELLING_TYPE.UNLIMITED_AUCTION;
        auction.seller = msg.sender;
        auction.price = price;
        auction.startTime = startTime;
        auction.endTime = endTime;

        IERC721(nftContractAddress).transferFrom(msg.sender, address(this), tokenId);

        emit AuctionCreated(msg.sender, price, startTime, endTime, tokenId);
    }

    /**
     * @notice Returns the selling data for a given token.
     *
     * @param tokenId The token ID.
     *
     * @return The AuctionData containing all data related to a given NFT.
     */
    function getSellingData(uint256 tokenId) external view returns (Selling memory) {
        Selling memory selling = sellings[tokenId];

        require(selling.seller != address(0), "Selling does not  exist");

        return selling;
    }

    /**
     * @notice Creates the new bid for the active auction
     *
     * @param tokenId The token ID.
     * @param price The bid price.
     */
    function bid(uint256 tokenId, uint256 price) external {
        Selling storage auction = sellings[tokenId];

        require(auction.seller != address(0), "Auction does not exist");
        require(auction.sellingType == SELLING_TYPE.AUCTION || auction.sellingType == SELLING_TYPE.UNLIMITED_AUCTION, "This selling is not an auction");
        require(auction.startTime < block.timestamp, "Auction is not started");
        require(IERC20(paymentTokenAddress).balanceOf(msg.sender) >= price, "Insufficient balance");

        if (auction.sellingType == SELLING_TYPE.AUCTION) {
            require(auction.endTime > block.timestamp, "Auction is ended");
        }

        uint256 topBid = auction.topBid;

        require(price > topBid && price >= auction.price, "Bid price is too low");
        require(paymentTokenAddress != address(0), "Payment token is not set");

        auction.topBidder = msg.sender;
        auction.topBid = price;

        AuctionBid memory newBidEntity = AuctionBid(price, msg.sender);
        tokenBids[tokenId].push(newBidEntity);

        emit Bid(_msgSender(), tokenId, price);
    }

    /**
     * @notice Executes procedures of token and payments transfers when auction is ended
     *
     * @param tokenId The token ID.
     */
    function claimAuction(uint256 tokenId, address claimer) external {
        Selling storage auction = sellings[tokenId];

        require(paymentTokenAddress != address(0), "Payment token is not set");
        require(auction.sellingType == SELLING_TYPE.AUCTION || auction.sellingType == SELLING_TYPE.UNLIMITED_AUCTION, "This selling is not an auction");

        if (auction.sellingType == SELLING_TYPE.AUCTION) {
            require(auction.endTime < block.timestamp, "Auction is not ended yet");
        }

        uint256 price = auction.topBid;
        uint256 royalty = IERC721TokenCreator(nftContractAddress).royalty(tokenId);
        address winner = auction.topBidder;
        address creator = IERC721TokenCreator(nftContractAddress).creator(tokenId);

        require(winner != address(0), "Auction has no winner");
        require(msg.sender == winner || msg.sender == auction.seller || msg.sender == owner(), "Caller has no rights to call this method");

        if (msg.sender == auction.seller || msg.sender == owner()) {
            winner = claimer;
            price = 0;

            for(uint256 i = 0; i < tokenBids[tokenId].length; i++)
            {
                if (tokenBids[tokenId][i].bidder == claimer) {
                    price = tokenBids[tokenId][i].value;
                    break;
                }
            }
        }

        require(price > 0, "Claimer address has no bids for the auction");

        // payments royalty to the creator, the fee to contract, and profit to the seller
        uint256 royaltyValue = price.div(100).mul(royalty);
        uint256 feeValue = price.div(100).mul(feePercent);
        uint256 profitValue = price.sub(feeValue).sub(royaltyValue);

        IERC20(paymentTokenAddress).transferFrom(winner, creator, royaltyValue);
        IERC20(paymentTokenAddress).transferFrom(winner, auction.seller, profitValue);

        if (feeAddress != address(0)) {
            IERC20(paymentTokenAddress).transferFrom(winner, feeAddress, feeValue);
        }

        IERC721(nftContractAddress).transferFrom(address(this), winner, tokenId);

        delete sellings[tokenId];
        delete tokenBids[tokenId];

        emit AuctionClaimed(auction.seller, winner, creator, price, royalty, tokenId);
    }

    /**
     * @notice Change the price (or minimum bid if this is an auction) of the selling.
     *
     * @param tokenId The token ID.
     * @param price New price (or minimum bid if this is an auction).
     */
    function changePrice(uint256 tokenId, uint256 price) external {
        Selling storage selling = sellings[tokenId];

        require(selling.seller != address(0), "Selling does not exist");
        require(msg.sender == selling.seller || msg.sender == owner(), "Caller has no rights to call this method");
        require(selling.topBidder == address(0), "Auction already started");
        require(price > 0, "Invalid price value");

        selling.price = price;

        emit PriceChanged(tokenId, price, msg.sender);
    }

    /**
     * @notice Cancel a selling.
     *
     * @param tokenId The token ID.
     */
    function cancelSelling(uint256 tokenId) external {
        Selling storage selling = sellings[tokenId];

        require(selling.seller != address(0), "Selling does not  exist");
        require(msg.sender == selling.seller || msg.sender == owner(), "Caller has no rights to call this method");

        address seller = selling.seller;

        delete sellings[tokenId];
        delete tokenBids[tokenId];

        emit SellingCanceled(tokenId, msg.sender);

        IERC721(nftContractAddress).transferFrom(address(this), seller, tokenId);
    }

    /**
     * @notice Cancel the bid.
     *
     * @param tokenId The token ID.
     */
    function cancelBid(uint256 tokenId) external {
        Selling storage selling = sellings[tokenId];

        require(selling.seller != address(0), "Selling does not  exist");
        require(selling.sellingType == SELLING_TYPE.AUCTION || selling.sellingType == SELLING_TYPE.UNLIMITED_AUCTION, "This selling is not an auction");

        for(uint256 i = 0; i < tokenBids[tokenId].length; i++)
        {
            if (tokenBids[tokenId][i].bidder == msg.sender) {
                // if this bid is top, change the top bid and bidder to previous
                if (selling.topBidder == msg.sender) {
                    selling.topBidder = tokenBids[tokenId][i - 1].bidder;
                    selling.topBid = tokenBids[tokenId][i - 1].value;
                }
                tokenBids[tokenId].pop();
                break;
            }
        }

        emit BidCanceled(msg.sender, tokenId);
    }
}

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

/**
 * @dev Interface of extension of the ERC721 standard to allow `creator` method.
 */
interface IERC721TokenCreator {
    /**
     * @dev Returns the creator of tokens in existence.
     */
    function creator(uint256 tokenId) external view returns(address);

    /**
     * @dev Returns the royalty of tokens in existence.
     */
    function royalty(uint256 tokenId) external view returns(uint256);

    /**
     * @notice Safely mints new token and sets its `_tokenURI`.
     *
     * Emits a {Transfer} event.
     */
    function mint(address to, string memory _tokenURI, uint256 _royalty) external returns (uint256);
}

// SPDX-License-Identifier: MIT

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