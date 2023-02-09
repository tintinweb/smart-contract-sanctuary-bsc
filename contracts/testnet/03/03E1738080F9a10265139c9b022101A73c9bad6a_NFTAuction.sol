/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

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

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721  {
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
    

    function royaltyFee(uint256 tokenId) external view returns (uint256);

    function getCreator(uint256 tokenId) external view returns (address);
    function merchantFee(uint256 tokenId) external view returns (uint256);

    function getMerchant(uint256 tokenId) external view returns (address);
    function royaltyInfo(uint256 tokenId, uint256 price)
        external
        view
        returns (address receiver, uint256 royaltyAmount);

    function merchantRoyaltyInfo(uint256 tokenId, uint256 price)
        external
        view
        returns (address receiver, uint256 royaltyAmount);

    function royaltyInfo(uint256 tokenId)
        external
        view
        returns (address receiver, uint256 royalty);

        function merchantRoyaltyInfo(uint256 tokenId)
        external
        view
        returns (address receiver, uint256 royalty);
    
}

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


contract AuctionStrorage {

    struct bidderDetails {
        uint256 auctionId;
        address bidderAddress;
        uint256 amount;
        uint256 fee;
        uint256 feeAmount;
        bool isReturn;
    }    

    struct auction {
        uint256 auctionId;
        uint256 tokenId;
        address auctionOwner;
        uint256 startTime;
        uint256 endTime;
        uint256 initialAmount;
        uint256 maxPrice;
        uint256 incrementRate;
        bool isCompleted;
        uint256 fee;
        uint256 totalbidPrice;
        mapping(uint => bidderDetails) bidDetail;
    }

    struct auctionDetails {
        uint256 auctionId;
        string auctionName;
        address nftAddress;
        string tokenName;
        address tokenAddress;
        uint256 highestBidAmount;
        address highestBidderId;
        uint256 totalBidCount;
        bool isAuctionEnded;
        address nftOwner;

    }

    struct auctionReturn {
        uint256 auctionId;
        uint256 tokenId;
        address auctionOwner;
        address nftAddress;
        string tokenName;
        address tokenAddress;
        string auctionName;
        uint256 startTime;
        uint256 endTime;
        uint256 initialAmount;
        uint256 maxPrice;
        uint256 incrementRate;
        bool isCompleted;
        uint fee;
        uint256 feeAmount;
        uint256 totalPrice;
         uint256 highestBidAmount;
        address highestBidderId;
        uint256 totalBidCount;
         bool isAuctionEnded;
        address nftOwner;
    }
    
    
}


interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

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


contract NFTAuction is AuctionStrorage,IERC721Receiver,ReentrancyGuard {
    using SafeMath for uint256;

    using Counters for Counters.Counter;
    Counters.Counter private _auctionIds;
    Counters.Counter private _bidIds;
    
    //Ashish
    address public ownAddress;
    IERC20 public tokenContract;
    IERC721 public nftContract;

    uint256 public fee;
    address payable public marketingWallet;
    

    mapping(uint => auction) public idToAction;
    mapping(uint => auctionDetails) public idToAuctionDetail;

    modifier onlyOwner() {
        require(ownAddress == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    event NewAuction(uint256 indexed auctionId);
    event IncrementRate(uint256 indexed asset, uint256 indexed incrementRate);
    event EndAuction(uint256 indexed auctionId);
    event CancelAuction(uint256 indexed auctionId);
    event Claim(uint256 indexed auctionId, address indexed user, uint256 indexed tokenId);
    event Claimwithdrawal(uint256 indexed auctionId, address indexed user);
    event LogErrorString(string message);
    event LogErrorBytes(bytes data);

     function SetMarketingFee(uint256 _fee) public onlyOwner {
        require(msg.sender == ownAddress, "Only owner can update fee");
        fee = _fee;
    } 

    function SetMarketingWallet(address _marketingWallet) public onlyOwner {
        require(msg.sender == ownAddress, "Only owner can update wallet");
        marketingWallet = payable(_marketingWallet);
    }

    constructor(address _nftContract, address _tokenContract, uint256 _fee,address _marketingWallet) {
        nftContract = IERC721(_nftContract);
        tokenContract = IERC20(_tokenContract);
        ownAddress = msg.sender;
        fee = _fee;
        marketingWallet = payable(_marketingWallet);
    }   

    function createAuction(address _nftContract, address _tokenContract, string memory auctionName, string memory tokenName, uint256 auctionStartTime, 
        uint256 auctionEndTime, uint256 initialAmount, uint256 maxAmount, uint256 tokenId, uint256 incrementRate) public nonReentrant 
    {
        require(initialAmount > 0, "Price cannot be zero");
        require(auctionStartTime > 0, "Auction Start Time cannot be zero");
        require(auctionEndTime > auctionStartTime, "Auction end time must be grater than auction start time");

        _auctionIds.increment();
        uint256 auctionId = _auctionIds.current();

        auction storage auctionindex = idToAction[auctionId];
        auctionDetails storage auctionDetailindex = idToAuctionDetail[auctionId];

        auctionindex.auctionId = auctionId;
        auctionindex.tokenId = tokenId;
        auctionindex.auctionOwner = msg.sender;
        auctionindex.startTime = auctionStartTime;
        auctionindex.endTime = auctionEndTime;
        auctionindex.initialAmount = initialAmount;
        auctionindex.maxPrice = maxAmount;
        auctionindex.incrementRate = incrementRate;
        auctionindex.isCompleted = false;
        auctionindex.fee = fee;

        //DataEnter In auctionDetailStruct
        auctionDetailindex.auctionId = auctionId;
        auctionDetailindex.auctionName = auctionName;
        auctionDetailindex.nftAddress = _nftContract;
        auctionDetailindex.tokenName = tokenName;
        auctionDetailindex.tokenAddress = _tokenContract;
        auctionDetailindex.highestBidAmount = 0;
        auctionDetailindex.totalBidCount = 0;
        auctionDetailindex.isAuctionEnded=false;
        auctionDetailindex.nftOwner=address(this);
        nftContract = IERC721(_nftContract);
        nftContract.safeTransferFrom(
            msg.sender,
            address(this),
            tokenId
        );

        emit NewAuction(auctionId);
    }
   
    function GetAuctions() public view returns(auctionReturn[] memory) {
        uint256 totalItemCount = _auctionIds.current();
        uint256 currentIndex = 0;
        auctionReturn[] memory items = new auctionReturn[](totalItemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            currentIndex = i + 1;

            items[i].auctionId = idToAction[currentIndex].auctionId;
            items[i].tokenId = idToAction[currentIndex].tokenId;
            items[i].nftAddress = idToAuctionDetail[currentIndex].nftAddress;
            items[i].tokenName = idToAuctionDetail[currentIndex].tokenName;
            items[i].tokenAddress = idToAuctionDetail[currentIndex].tokenAddress;
            items[i].auctionName = idToAuctionDetail[currentIndex].auctionName;
            items[i].auctionOwner = idToAction[currentIndex].auctionOwner;
            items[i].startTime = idToAction[currentIndex].startTime;
            items[i].endTime = idToAction[currentIndex].endTime;
            items[i].initialAmount = idToAction[currentIndex].initialAmount;
            items[i].maxPrice = idToAction[currentIndex].maxPrice;
            items[i].incrementRate = idToAction[currentIndex].incrementRate;
            items[i].isCompleted = idToAction[currentIndex].isCompleted;
            items[i].fee = idToAction[currentIndex].fee;
            items[i].highestBidAmount= idToAuctionDetail[currentIndex].highestBidAmount;
            items[i].highestBidderId= idToAuctionDetail[currentIndex].highestBidderId;
            items[i].totalBidCount=idToAuctionDetail[currentIndex].totalBidCount;
            items[i].isAuctionEnded=idToAuctionDetail[currentIndex].isAuctionEnded;
             items[i].nftOwner=idToAuctionDetail[currentIndex].nftOwner;
                currentIndex += 1;
        }
        return items;
    }

  function GetAuctionDetailById(uint256 auctionId) public view returns(auctionReturn[] memory,bidderDetails[] memory) {
            auctionReturn[] memory auctionindex = new auctionReturn[](1);
            auctionindex[0].auctionId = idToAction[auctionId].auctionId;
            auctionindex[0].tokenId = idToAction[auctionId].tokenId;
            auctionindex[0].nftAddress = idToAuctionDetail[auctionId].nftAddress;
            auctionindex[0].tokenName = idToAuctionDetail[auctionId].tokenName;
            auctionindex[0].tokenAddress = idToAuctionDetail[auctionId].tokenAddress;
            auctionindex[0].auctionName = idToAuctionDetail[auctionId].auctionName;
            auctionindex[0].auctionOwner = idToAction[auctionId].auctionOwner;
            auctionindex[0].startTime = idToAction[auctionId].startTime;
            auctionindex[0].endTime = idToAction[auctionId].endTime;
            auctionindex[0].initialAmount = idToAction[auctionId].initialAmount;
            auctionindex[0].maxPrice = idToAction[auctionId].maxPrice;
            auctionindex[0].incrementRate = idToAction[auctionId].incrementRate;
            auctionindex[0].isCompleted = idToAction[auctionId].isCompleted;
            auctionindex[0].fee = idToAction[auctionId].fee;
            auctionindex[0].highestBidAmount= idToAuctionDetail[auctionId].highestBidAmount;
            auctionindex[0].highestBidderId= idToAuctionDetail[auctionId].highestBidderId;
            auctionindex[0].totalBidCount=idToAuctionDetail[auctionId].totalBidCount;
            auctionindex[0].isAuctionEnded=idToAuctionDetail[auctionId].isAuctionEnded;
            auctionindex[0].nftOwner=idToAuctionDetail[auctionId].nftOwner;
        

        uint256 totalItemCount = idToAuctionDetail[auctionId].totalBidCount; //_bidIds.current();
        uint256 currentIndex = 0;
        
        bidderDetails[] memory itemsbid = new bidderDetails[](totalItemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            currentIndex = i + 1;
            itemsbid[i].auctionId = idToAction[auctionId].bidDetail[currentIndex].auctionId;
            itemsbid[i].bidderAddress = idToAction[auctionId].bidDetail[currentIndex].bidderAddress;
            itemsbid[i].amount = idToAction[auctionId].bidDetail[currentIndex].amount;
            itemsbid[i].isReturn=idToAction[auctionId].bidDetail[currentIndex].isReturn;
            currentIndex += 1;
        }
        return (auctionindex,itemsbid);
    }



    function createBid(uint auctionId, uint256 bidAmount) payable public nonReentrant
    { 
     
          if(idToAction[auctionId].endTime > block.timestamp ){            

            require(idToAction[auctionId].startTime < block.timestamp, "Auction: Auction is not started yet");

            require(bidAmount > 0, "Bid amount cannot be zero"); 

            require(bidAmount > idToAuctionDetail[auctionId].highestBidAmount, "Next Bid amount must be grater than highest bid amount"); 

            uint modAmount = bidAmount.mod(idToAction[auctionId].incrementRate);

            require(modAmount == 0, "Bid amount should be Increment in incrementRate.");

            require(bidAmount > idToAction[auctionId].initialAmount, "Auction: Bid amount is too less");
            uint256 calFee = (bidAmount * idToAction[auctionId].fee) / 100;
            

            idToAuctionDetail[auctionId].highestBidAmount = bidAmount;
            idToAuctionDetail[auctionId].highestBidderId = msg.sender;
            idToAction[auctionId].fee = fee;
            idToAction[auctionId].totalbidPrice += bidAmount;

            uint256 bidId = idToAuctionDetail[auctionId].totalBidCount + 1;
            idToAuctionDetail[auctionId].totalBidCount += 1;

            idToAction[auctionId].bidDetail[bidId].auctionId = auctionId;
            idToAction[auctionId].bidDetail[bidId].bidderAddress = msg.sender;
            idToAction[auctionId].bidDetail[bidId].amount = bidAmount;
            idToAction[auctionId].bidDetail[bidId].isReturn = false;            
            idToAction[auctionId].bidDetail[bidId].fee = fee;
            idToAction[auctionId].bidDetail[bidId].feeAmount = calFee;

            tokenContract = IERC20(idToAuctionDetail[auctionId].tokenAddress);

            if (calFee > 0) {
                tokenContract.transferFrom(msg.sender, marketingWallet, calFee);
            }

            tokenContract.transferFrom(msg.sender, address(this), bidAmount);
        }
        else {
            revert("Bid can not be process because auction is completed!");
        }
   
    }

    function getBid(uint256 auctionId) public view returns (bidderDetails[] memory)
    {
        uint256 totalItemCount = idToAuctionDetail[auctionId].totalBidCount; //_bidIds.current();
        uint256 currentIndex = 0;
        
        bidderDetails[] memory items = new bidderDetails[](totalItemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            currentIndex = i + 1;
            items[i].auctionId = idToAction[auctionId].bidDetail[currentIndex].auctionId;
            items[i].bidderAddress = idToAction[auctionId].bidDetail[currentIndex].bidderAddress;
            items[i].amount = idToAction[auctionId].bidDetail[currentIndex].amount;
            items[i].isReturn=idToAction[auctionId].bidDetail[currentIndex].isReturn;
            currentIndex += 1;
        }
        return items;
    }

    function changeIncrementRate(uint256 _auctionId, uint256 _incrementRate) public nonReentrant
    {
        require(idToAction[_auctionId].auctionOwner == msg.sender , "Only auction owner can be change");
        require(_incrementRate > 0, "Increment rate can not be zero");
        idToAction[_auctionId].incrementRate = _incrementRate;
        emit IncrementRate(_auctionId, _incrementRate);
    }

    function endAuction(uint256 _auctionId) public nonReentrant{
        require(idToAction[_auctionId].auctionOwner == msg.sender || ownAddress == msg.sender , "Only owner can call");
        
        uint256 currentIndex = 0;
        idToAction[_auctionId].isCompleted = true;
        bool isNFTTransfer=false;
        nftContract = IERC721(idToAuctionDetail[_auctionId].nftAddress);
        tokenContract = IERC20(idToAuctionDetail[_auctionId].tokenAddress);

        uint256 totalItemCount = idToAuctionDetail[_auctionId].totalBidCount;

            for (uint256 i = 0; i < totalItemCount; i++) {
                currentIndex = i + 1;

                if(idToAction[_auctionId].bidDetail[currentIndex].bidderAddress == idToAuctionDetail[_auctionId].highestBidderId 
                && idToAction[_auctionId].bidDetail[currentIndex].isReturn == false
                && idToAction[_auctionId].bidDetail[currentIndex].amount == idToAuctionDetail[_auctionId].highestBidAmount) {
                    
                    idToAction[_auctionId].bidDetail[currentIndex].isReturn = true;

                    uint256 royaltyFeeAmount = 0;
                    uint256 merchantFeeAmount=0 ;      
                try nftContract.royaltyInfo(idToAction[_auctionId].tokenId) returns (address creator, uint256 royaltyFee) {
                    royaltyFeeAmount = royaltyFee;
                    if (royaltyFeeAmount > 0) {
                          tokenContract.transfer(creator, royaltyFeeAmount);
                       
                    }
                    }
                    catch Error(string memory reason) {
                        emit LogErrorString(reason);
                    } 
                    catch (bytes memory reason) {
                        // catch failing assert()
                        emit LogErrorBytes(reason);
                    }
                    // merchant Fee
                    try nftContract.merchantRoyaltyInfo(idToAction[_auctionId].tokenId) returns (address merchant, uint256 merchantFee) {
                        merchantFeeAmount = merchantFee;
                        if (merchantFeeAmount > 0) {
                              tokenContract.transfer(merchant, merchantFeeAmount);
                        }
                    }
                    catch Error(string memory reason) {
                        emit LogErrorString(reason);
                    } 
                    catch (bytes memory reason) {
                        // catch failing assert()
                        emit LogErrorBytes(reason);
                    }
                   nftContract.safeTransferFrom(
                    address(this),
                        idToAction[_auctionId].bidDetail[currentIndex].bidderAddress,
                        idToAction[_auctionId].tokenId
                    );
                    isNFTTransfer=true;
                       idToAuctionDetail[_auctionId].isAuctionEnded=true;
                       idToAuctionDetail[_auctionId].nftOwner=idToAction[_auctionId].bidDetail[currentIndex].bidderAddress;
                    tokenContract.transfer(idToAction[_auctionId].auctionOwner, idToAuctionDetail[_auctionId].highestBidAmount - royaltyFeeAmount-merchantFeeAmount);
                }
                else if(idToAction[_auctionId].bidDetail[currentIndex].isReturn == false) {
                    
                    idToAction[_auctionId].bidDetail[currentIndex].isReturn = true;

                    tokenContract.transfer(idToAction[_auctionId].bidDetail[currentIndex].bidderAddress,
                     idToAction[_auctionId].bidDetail[currentIndex].amount);

                }

                currentIndex += 1;
            }
            if(!isNFTTransfer)
            {
                
            if(idToAuctionDetail[_auctionId].nftOwner == address(this)) {
                nftContract.safeTransferFrom(
                    address(this),
                    msg.sender,
                    idToAction[_auctionId].tokenId);
                idToAuctionDetail[_auctionId].nftOwner= msg.sender;
            }
               idToAuctionDetail[_auctionId].isAuctionEnded=true;
               
            }

        emit EndAuction(_auctionId);
    }

    function withdrawal(uint256 _auctionId) public nonReentrant {
        require(idToAction[_auctionId].endTime < block.timestamp, "Auction: Auction is not ended yet");

        if(idToAction[_auctionId].isCompleted == false) {
            idToAction[_auctionId].isCompleted = true;
        }
            nftContract = IERC721(idToAuctionDetail[_auctionId].nftAddress);
            tokenContract = IERC20(idToAuctionDetail[_auctionId].tokenAddress);

            uint256 currentIndex = 0;

            uint256 totalItemCount = idToAuctionDetail[_auctionId].totalBidCount;
            
            for (uint256 i = 0; i < totalItemCount; i++) {
                currentIndex = i + 1;

                if(msg.sender == idToAuctionDetail[_auctionId].highestBidderId 
                && idToAction[_auctionId].bidDetail[currentIndex].isReturn == false
                && idToAuctionDetail[_auctionId].highestBidAmount == idToAction[_auctionId].bidDetail[currentIndex].amount 
                && msg.sender == idToAction[_auctionId].bidDetail[currentIndex].bidderAddress) {
                    
                    idToAction[_auctionId].bidDetail[currentIndex].isReturn = true;

                    uint256 royaltyFeeAmount = 0;
                    uint256 merchantFeeAmount =0;
              try nftContract.royaltyInfo(idToAction[_auctionId].tokenId) returns (address creator, uint256 royaltyFee) {
                    royaltyFeeAmount = royaltyFee;
                    if (royaltyFeeAmount > 0) {
                         tokenContract.transfer(creator, royaltyFeeAmount);
                    }
                    }
                    catch Error(string memory reason) {
                        emit LogErrorString(reason);
                    } 
                    catch (bytes memory reason) {
                        // catch failing assert()
                        emit LogErrorBytes(reason);
                    }
                    // merchant Fee
                    try nftContract.merchantRoyaltyInfo(idToAction[_auctionId].tokenId) returns (address merchant, uint256 merchantFee) {
                        merchantFeeAmount = merchantFee;
                        if (merchantFeeAmount > 0) {
                             tokenContract.transfer(merchant, merchantFeeAmount);
                           
                        }
                    }
                    catch Error(string memory reason) {
                        emit LogErrorString(reason);
                    } 
                    catch (bytes memory reason) {
                        // catch failing assert()
                        emit LogErrorBytes(reason);
                    }
                   nftContract.safeTransferFrom(
                    address(this),
                        msg.sender,
                        idToAction[_auctionId].tokenId
                    );
                    idToAuctionDetail[_auctionId].nftOwner= msg.sender;
                    tokenContract.transfer(idToAction[_auctionId].auctionOwner, idToAuctionDetail[_auctionId].highestBidAmount - royaltyFeeAmount-merchantFeeAmount);
                }
                else if(msg.sender == idToAction[_auctionId].bidDetail[currentIndex].bidderAddress 
                && idToAction[_auctionId].bidDetail[currentIndex].isReturn == false) {
                    
                    idToAction[_auctionId].bidDetail[currentIndex].isReturn = true;
                    tokenContract.transfer(msg.sender, idToAction[_auctionId].bidDetail[currentIndex].amount);
                }
               
                currentIndex += 1;
            }
            emit Claimwithdrawal(_auctionId,msg.sender);
    }

    function cancelAuction(uint256 _auctionId) public nonReentrant
    {
        require(idToAction[_auctionId].auctionOwner == msg.sender || ownAddress == msg.sender , "Only owner can call");
        uint256 totalItemCount = idToAuctionDetail[_auctionId].totalBidCount;
        if(totalItemCount==0)
        {
            idToAction[_auctionId].isCompleted = true;
            nftContract = IERC721(idToAuctionDetail[_auctionId].nftAddress);
            
            nftContract.safeTransferFrom(
            address(this),
             msg.sender,
             idToAction[_auctionId].tokenId
        );
               idToAuctionDetail[_auctionId].isAuctionEnded=true;
               idToAuctionDetail[_auctionId].nftOwner= msg.sender;
        emit CancelAuction(_auctionId);
        }
        else {
            revert("Auction cannot cancel because bid in process !");
        }

    }
     function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}