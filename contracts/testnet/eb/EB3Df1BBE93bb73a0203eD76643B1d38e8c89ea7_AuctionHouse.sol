/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;
pragma experimental ABIEncoderV2;
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
interface IBEP165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
interface IBEP721 is IBEP165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor (){
        _status = _NOT_ENTERED;
    }
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
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target,bytes memory data,string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target,bytes memory data,uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target,bytes memory data,uint256 value,string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(address target,bytes memory data,string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(address target,bytes memory data,string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(bool success,bytes memory returndata,string memory errorMessage) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;
    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(IBEP20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),"SafeBEP20: approve from non-zero to non-zero allowance");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function safeDecreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeBEP20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}
library Counters {
    using SafeMath for uint256;
    struct Counter {
        uint256 _value; // default: 0
    }
    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }
    function increment(Counter storage counter) internal {
        // The {SafeMath} overflow check can be skipped here, see the comment at the top
        counter._value += 1;
    }
    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}
interface IMarket {
    struct Bid {
        // Amount of the currency being bid
        uint256 amount;
        // Address to the BEP20 token being used to bid
        address currency;
        // Address of the bidder
        address bidder;
        // Address of the recipient
        address recipient;
        // % of the next sale to award the current owner
        Decimal.D256 sellOnShare;
    }
    struct Ask {
        // Amount of the currency being asked
        uint256 amount;
        // Address to the BEP20 token being asked
        address currency;
    }
    struct BidShares {
        // % of sale value that goes to the _previous_ owner of the nft
        Decimal.D256 prevOwner;
        // % of sale value that goes to the original creator of the nft
        Decimal.D256 creator;
        // % of sale value that goes to the seller (current owner) of the nft
        Decimal.D256 owner;
    }
    event BidCreated(uint256 indexed tokenId, Bid bid);
    event BidRemoved(uint256 indexed tokenId, Bid bid);
    event BidFinalized(uint256 indexed tokenId, Bid bid);
    event AskCreated(uint256 indexed tokenId, Ask ask);
    event AskRemoved(uint256 indexed tokenId, Ask ask);
    event BidShareUpdated(uint256 indexed tokenId, BidShares bidShares);
    function bidForTokenBidder(uint256 tokenId, address bidder)external view returns (Bid memory);
    function currentAskForToken(uint256 tokenId)external view returns (Ask memory);
    function bidSharesForToken(uint256 tokenId)external view returns (BidShares memory);
    function isValidBid(uint256 tokenId, uint256 bidAmount)external view returns (bool);
    function isValidBidShares(BidShares calldata bidShares)external pure returns (bool);
    function splitShare(Decimal.D256 calldata sharePercentage, uint256 amount)external pure returns (uint256);
    function configure(address mediaContractAddress) external;
    function setBidShares(uint256 tokenId, BidShares calldata bidShares) external;
    function setAsk(uint256 tokenId, Ask calldata ask) external;
    function removeAsk(uint256 tokenId) external;
    function setBid(uint256 tokenId,Bid calldata bid,address spender) external;
    function removeBid(uint256 tokenId, address bidder) external;
    function acceptBid(uint256 tokenId, Bid calldata expectedBid) external;
}
interface IMedia {
    struct EIP712Signature {
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
    struct MediaData {
        // A valid URI of the content represented by this token
        string tokenURI;
        // A valid URI of the metadata associated with this token
        string metadataURI;
        // A SHA256 hash of the content pointed to by tokenURI
        bytes32 contentHash;
        // A SHA256 hash of the content pointed to by metadataURI
        bytes32 metadataHash;
    }
    event TokenURIUpdated(uint256 indexed _tokenId, address owner, string _uri);
    event TokenMetadataURIUpdated(uint256 indexed _tokenId,address owner,string _uri);
    function tokenMetadataURI(uint256 tokenId)external view returns (string memory);
    function mint(MediaData calldata data, IMarket.BidShares calldata bidShares) external;
    function mintWithSig(address creator,MediaData calldata data, IMarket.BidShares calldata bidShares, EIP712Signature calldata sig) external;
    function auctionTransfer(uint256 tokenId, address recipient) external;
    function setAsk(uint256 tokenId, IMarket.Ask calldata ask) external;
    function removeAsk(uint256 tokenId) external;
    function setBid(uint256 tokenId, IMarket.Bid calldata bid) external;
    function removeBid(uint256 tokenId) external;
    function acceptBid(uint256 tokenId, IMarket.Bid calldata bid) external;
    function revokeApproval(uint256 tokenId) external;
    function updateTokenURI(uint256 tokenId, string calldata tokenURI) external;
    function updateTokenMetadataURI(uint256 tokenId,string calldata metadataURI) external;
    function permit(address spender,uint256 tokenId, EIP712Signature calldata sig) external;
}
interface IAuctionHouse {
    struct Auction {
        // ID for the BEP721 token
        uint256 tokenId;
        // Address for the BEP721 contract
        address tokenContract;
        // Whether or not the auction curator has approved the auction to start
        bool approved;
        // The current highest bid amount
        uint256 amount;
        // The length of time to run the auction for, after the first bid was made
        uint256 duration;
        // The time of the first bid
        uint256 firstBidTime;
        // The minimum price of the first bid
        uint256 reservePrice;
        // The sale percentage to send to the curator
        uint8 curatorFeePercentage;
        // The address that should receive the funds once the NFT is sold.
        address tokenOwner;
        // The address of the current highest bid
        address payable bidder;
        // The address of the auction's curator.
        // The curator can reject or approve an auction
        address payable curator;
        // The address of the ERC-20 currency to run the auction with.
        // If set to 0x0, the auction will be run in BNB
        address auctionCurrency;
    }
    event AuctionCreated(uint256 indexed auctionId,uint256 indexed tokenId,address indexed tokenContract,uint256 duration,
        uint256 reservePrice,address tokenOwner,address curator,uint8 curatorFeePercentage,address auctionCurrency);
    event AuctionApprovalUpdated(uint256 indexed auctionId,uint256 indexed tokenId,address indexed tokenContract,bool approved);
    event AuctionReservePriceUpdated(uint256 indexed auctionId,uint256 indexed tokenId,address indexed tokenContract,uint256 reservePrice);
    event AuctionBid(uint256 indexed auctionId,uint256 indexed tokenId,address indexed tokenContract,address sender,uint256 value,
        bool firstBid,bool extended);
    event AuctionDurationExtended(uint256 indexed auctionId,uint256 indexed tokenId,address indexed tokenContract,uint256 duration);
    event AuctionEnded(uint256 indexed auctionId,uint256 indexed tokenId,address indexed tokenContract,address tokenOwner,
        address curator,address winner,uint256 amount,uint256 curatorFee,address auctionCurrency);
    event AuctionCanceled(uint256 indexed auctionId,uint256 indexed tokenId,address indexed tokenContract,address tokenOwner);
    function createAuction(uint256 tokenId,address tokenContract,uint256 duration,uint256 reservePrice,
        address payable curator,uint8 curatorFeePercentages,address auctionCurrency) external returns (uint256);
    function setAuctionApproval(uint256 auctionId, bool approved) external;
    function setAuctionReservePrice(uint256 auctionId, uint256 reservePrice) external;
    function createBid(uint256 auctionId, uint256 amount) external payable;
    function endAuction(uint256 auctionId) external;
    function cancelAuction(uint256 auctionId) external;
}
library Math {
    using SafeMath for uint256;
    function getPartial(uint256 target,uint256 numerator,uint256 denominator) internal pure returns (uint256) {
        return target.mul(numerator).div(denominator);
    }
    function getPartialRoundUp(uint256 target,uint256 numerator,uint256 denominator) internal pure returns (uint256) {
        if (target == 0 || numerator == 0) {
            // SafeMath will check for zero denominator
            return SafeMath.div(0, denominator);
        }
        return target.mul(numerator).sub(1).div(denominator).add(1);
    }
    function to128(uint256 number) internal pure returns (uint128) {
        uint128 result = uint128(number);
        require(result == number, "Math: Unsafe cast to uint128");
        return result;
    }
    function to96(uint256 number) internal pure returns (uint96) {
        uint96 result = uint96(number);
        require(result == number, "Math: Unsafe cast to uint96");
        return result;
    }
    function to32(uint256 number) internal pure returns (uint32) {
        uint32 result = uint32(number);
        require(result == number, "Math: Unsafe cast to uint32");
        return result;
    }
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }
}
library Decimal {
    using SafeMath for uint256;
    uint256 constant BASE_POW = 18;
    uint256 constant BASE = 10**BASE_POW;
    struct D256 {
        uint256 value;
    }
    function one() internal pure returns (D256 memory) {
        return D256({value: BASE});
    }
    function onePlus(D256 memory d) internal pure returns (D256 memory) {
        return D256({value: d.value.add(BASE)});
    }
    function mul(uint256 target, D256 memory d)internal pure returns (uint256){
        return Math.getPartial(target, d.value, BASE);
    }
    function div(uint256 target, D256 memory d)internal pure returns (uint256){
        return Math.getPartial(target, BASE, d.value);
    }
}
interface IWBNB {
    function deposit() external payable;
    function withdraw(uint wad) external;
    function transfer(address to, uint256 value) external returns (bool);
}
interface IMediaExtended is IMedia {
    function marketContract() external returns(address);
}
contract AuctionHouse is IAuctionHouse, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;
    using Counters for Counters.Counter;
    // The minimum amount of time left in an auction after a new bid is created
    uint256 public timeBuffer;
    // The minimum percentage difference between the last bid amount and the current bid.
    uint8 public minBidIncrementPercentage;
    // The address of the sss protocol to use via this contract
    address public sss;
    // / The address of the WBNB contract, so that any BNB transferred can be handled as an BEP-20
    address public wbnbAddress;
    // A mapping of all of the auctions currently running.
    mapping(uint256 => IAuctionHouse.Auction) public auctions;
    bytes4 constant interfaceId = 0x80ac58cd; // 721 interface id
    Counters.Counter private _auctionIdTracker;
    modifier auctionExists(uint256 auctionId) {
        require(_exists(auctionId), "Auction doesn't exist");
        _;
    }
    constructor(address _sss, address _wbnb){
        require(IBEP165(_sss).supportsInterface(interfaceId),"Doesn't support NFT interface");
        sss = _sss;
        wbnbAddress = _wbnb;
        timeBuffer = 15 * 60; // extend 15 minutes after every bid made in last 15 minutes
        minBidIncrementPercentage = 5; // 5%
    }
    function createAuction(uint256 tokenId,address tokenContract,uint256 duration,uint256 reservePrice,address payable curator,
        uint8 curatorFeePercentage,address auctionCurrency) public override nonReentrant returns (uint256) {
        require(IBEP165(tokenContract).supportsInterface(interfaceId),"tokenContract does not support BEP721 interface");
        require(curatorFeePercentage < 100, "curatorFeePercentage must be less than 100");
        address tokenOwner = IBEP721(tokenContract).ownerOf(tokenId);
        require(msg.sender == IBEP721(tokenContract).getApproved(tokenId) || msg.sender == tokenOwner, "Caller must be approved or owner for token id");
        uint256 auctionId = _auctionIdTracker.current();
        auctions[auctionId] = Auction({
            tokenId: tokenId,
            tokenContract: tokenContract,
            approved: false,
            amount: 0,
            duration: duration,
            firstBidTime: 0,
            reservePrice: reservePrice,
            curatorFeePercentage: curatorFeePercentage,
            tokenOwner: tokenOwner,
            bidder: payable(address(0)),
            curator: curator,
            auctionCurrency: auctionCurrency
        });
        IBEP721(tokenContract).transferFrom(tokenOwner, address(this), tokenId);
        _auctionIdTracker.increment();
        emit AuctionCreated(auctionId, tokenId, tokenContract, duration, reservePrice, tokenOwner, curator, curatorFeePercentage, auctionCurrency);
        if(auctions[auctionId].curator == address(0) || curator == tokenOwner) {
            _approveAuction(auctionId, true);
        }
        return auctionId;
    }
    function setAuctionApproval(uint256 auctionId, bool approved) external override auctionExists(auctionId) {
        require(msg.sender == auctions[auctionId].curator, "Must be auction curator");
        require(auctions[auctionId].firstBidTime == 0, "Auction has already started");
        _approveAuction(auctionId, approved);
    }
    function setAuctionReservePrice(uint256 auctionId, uint256 reservePrice) external override auctionExists(auctionId) {
        require(msg.sender == auctions[auctionId].curator || msg.sender == auctions[auctionId].tokenOwner, "Must be auction curator or token owner");
        require(auctions[auctionId].firstBidTime == 0, "Auction has already started");
        auctions[auctionId].reservePrice = reservePrice;
        emit AuctionReservePriceUpdated(auctionId, auctions[auctionId].tokenId, auctions[auctionId].tokenContract, reservePrice);
    }
    function createBid(uint256 auctionId, uint256 amount)external override payable auctionExists(auctionId) nonReentrant{
        address payable lastBidder = auctions[auctionId].bidder;
        require(auctions[auctionId].approved, "Auction must be approved by curator");
        require(auctions[auctionId].firstBidTime == 0 || block.timestamp < auctions[auctionId].firstBidTime.add(auctions[auctionId].duration),"Auction expired");
        require(amount >= auctions[auctionId].reservePrice,"Must send at least reservePrice");
        require(amount >= auctions[auctionId].amount.add(auctions[auctionId].amount.mul(minBidIncrementPercentage).div(100)),
            "Must send more than last bid by minBidIncrementPercentage amount"
        );
        // For sss Protocol, ensure that the bid is valid for the current bidShare configuration
        if(auctions[auctionId].tokenContract == sss) {
            require(IMarket(IMediaExtended(sss).marketContract()).isValidBid(auctions[auctionId].tokenId,amount),"Bid invalid for share splitting");
        }
        // If this is the first valid bid, we should set the starting time now.
        // If it's not, then we should refund the last bidder
        if(auctions[auctionId].firstBidTime == 0) {
            auctions[auctionId].firstBidTime = block.timestamp;
        } else if(lastBidder != address(0)) {
            _handleOutgoingBid(lastBidder, auctions[auctionId].amount, auctions[auctionId].auctionCurrency);
        }
        _handleIncomingBid(amount, auctions[auctionId].auctionCurrency);
        auctions[auctionId].amount = amount;
        auctions[auctionId].bidder = payable(msg.sender);
        bool extended = false;
        if (auctions[auctionId].firstBidTime.add(auctions[auctionId].duration).sub(block.timestamp) < timeBuffer) {
            uint256 oldDuration = auctions[auctionId].duration;
            auctions[auctionId].duration = oldDuration.add(timeBuffer.sub(auctions[auctionId].firstBidTime.add(oldDuration).sub(block.timestamp)));
            extended = true;
        }
        emit AuctionBid(
            auctionId,
            auctions[auctionId].tokenId,
            auctions[auctionId].tokenContract,
            msg.sender,
            amount,
            lastBidder == address(0), // firstBid boolean
            extended
        );
        if (extended) {
            emit AuctionDurationExtended(
                auctionId,
                auctions[auctionId].tokenId,
                auctions[auctionId].tokenContract,
                auctions[auctionId].duration
            );
        }
    }
    function endAuction(uint256 auctionId) external override auctionExists(auctionId) nonReentrant {
        require(uint256(auctions[auctionId].firstBidTime) != 0,"Auction hasn't begun");
        require(block.timestamp >= auctions[auctionId].firstBidTime.add(auctions[auctionId].duration),"Auction hasn't completed");
        address currency = auctions[auctionId].auctionCurrency == address(0) ? wbnbAddress : auctions[auctionId].auctionCurrency;
        uint256 curatorFee = 0;
        uint256 tokenOwnerProfit = auctions[auctionId].amount;
        if(auctions[auctionId].tokenContract == sss) {
            // If the auction is running on sss, settle it on the protocol
            (bool success, uint256 remainingProfit) = _handlesssAuctionSettlement(auctionId);
            tokenOwnerProfit = remainingProfit;
            if(success != true) {
                _handleOutgoingBid(auctions[auctionId].bidder, auctions[auctionId].amount, auctions[auctionId].auctionCurrency);
                _cancelAuction(auctionId);
                return;
            }
        } else {
            // Otherwise, transfer the token to the winner and pay out the participants below
            try IBEP721(auctions[auctionId].tokenContract).safeTransferFrom(address(this), auctions[auctionId].bidder, auctions[auctionId].tokenId) {} catch {
                _handleOutgoingBid(auctions[auctionId].bidder, auctions[auctionId].amount, auctions[auctionId].auctionCurrency);
                _cancelAuction(auctionId);
                return;
            }
        }
        if(auctions[auctionId].curator != address(0)) {
            curatorFee = tokenOwnerProfit.mul(auctions[auctionId].curatorFeePercentage).div(100);
            tokenOwnerProfit = tokenOwnerProfit.sub(curatorFee);
            _handleOutgoingBid(auctions[auctionId].curator, curatorFee, auctions[auctionId].auctionCurrency);
        }
        _handleOutgoingBid(auctions[auctionId].tokenOwner, tokenOwnerProfit, auctions[auctionId].auctionCurrency);
        emit AuctionEnded(
            auctionId,
            auctions[auctionId].tokenId,
            auctions[auctionId].tokenContract,
            auctions[auctionId].tokenOwner,
            auctions[auctionId].curator,
            auctions[auctionId].bidder,
            tokenOwnerProfit,
            curatorFee,
            currency
        );
        delete auctions[auctionId];
    }
    function cancelAuction(uint256 auctionId) external override nonReentrant auctionExists(auctionId) {
        require(auctions[auctionId].tokenOwner == msg.sender || auctions[auctionId].curator == msg.sender, "Can only be called by auction creator or curator");
        require(uint256(auctions[auctionId].firstBidTime) == 0,"Can't cancel an auction once it's begun");
        _cancelAuction(auctionId);
    }
    function _handleIncomingBid(uint256 amount, address currency) internal {
        // If this is an BNB bid, ensure they sent enough and convert it to WBNB under the hood
        if(currency == address(0)) {
            require(msg.value == amount, "Sent BNB Value does not match specified bid amount");
            IWBNB(wbnbAddress).deposit{value: amount}();
        } else {
            // We must check the balance that was actually transferred to the auction,
            // as some tokens impose a transfer fee and would not actually transfer the
            // full amount to the market, resulting in potentally locked funds
            IBEP20 token = IBEP20(currency);
            uint256 beforeBalance = token.balanceOf(address(this));
            token.safeTransferFrom(msg.sender, address(this), amount);
            uint256 afterBalance = token.balanceOf(address(this));
            require(beforeBalance.add(amount) == afterBalance, "Token transfer call did not transfer expected amount");
        }
    }
    function _handleOutgoingBid(address to, uint256 amount, address currency) internal {
        // If the auction is in BNB, unwrap it from its underlying WBNB and try to send it to the recipient.
        if(currency == address(0)) {
            IWBNB(wbnbAddress).withdraw(amount);
            // If the BNB transfer fails (sigh), rewrap the BNB and try send it as WBNB.
            if(!_safeTransferBNB(to, amount)) {
                IWBNB(wbnbAddress).deposit{value: amount}();
                IBEP20(wbnbAddress).safeTransfer(to, amount);
            }
        } else {
            IBEP20(currency).safeTransfer(to, amount);
        }
    }
    function _safeTransferBNB(address to, uint256 value) internal returns (bool) {
        (bool success, ) = to.call{value: value}(new bytes(0));
        return success;
    }
    function _cancelAuction(uint256 auctionId) internal {
        address tokenOwner = auctions[auctionId].tokenOwner;
        IBEP721(auctions[auctionId].tokenContract).safeTransferFrom(address(this), tokenOwner, auctions[auctionId].tokenId);
        emit AuctionCanceled(auctionId, auctions[auctionId].tokenId, auctions[auctionId].tokenContract, tokenOwner);
        delete auctions[auctionId];
    }
    function _approveAuction(uint256 auctionId, bool approved) internal {
        auctions[auctionId].approved = approved;
        emit AuctionApprovalUpdated(auctionId, auctions[auctionId].tokenId, auctions[auctionId].tokenContract, approved);
    }
    function _exists(uint256 auctionId) internal view returns(bool) {
        return auctions[auctionId].tokenOwner != address(0);
    }
    function _handlesssAuctionSettlement(uint256 auctionId) internal returns (bool, uint256) {
        address currency = auctions[auctionId].auctionCurrency == address(0) ? wbnbAddress : auctions[auctionId].auctionCurrency;
        IMarket.Bid memory bid = IMarket.Bid({
            amount: auctions[auctionId].amount,
            currency: currency,
            bidder: address(this),
            recipient: auctions[auctionId].bidder,
            sellOnShare: Decimal.D256(0)
        });
        IBEP20(currency).approve(IMediaExtended(sss).marketContract(), bid.amount);
        IMedia(sss).setBid(auctions[auctionId].tokenId, bid);
        uint256 beforeBalance = IBEP20(currency).balanceOf(address(this));
        try IMedia(sss).acceptBid(auctions[auctionId].tokenId, bid) {} catch {
            // If the underlying NFT transfer here fails, we should cancel the auction and refund the winner
            IMediaExtended(sss).removeBid(auctions[auctionId].tokenId);
            return (false, 0);
        }
        uint256 afterBalance = IBEP20(currency).balanceOf(address(this));
        // We have to calculate the amount to send to the token owner here in case there was a
        // sell-on share on the token
        return (true, afterBalance.sub(beforeBalance));
    }
    // TODO: consider reverting if the message sender is not WBNB
    receive() external payable {}
    fallback() external payable {}
}