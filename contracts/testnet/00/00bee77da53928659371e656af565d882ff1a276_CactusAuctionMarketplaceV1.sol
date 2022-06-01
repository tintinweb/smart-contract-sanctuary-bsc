// SPDX-License-Identifier: None
pragma solidity 0.8.10;

/// @dev for normal mints, need to import normal versions of ERC721/ERC2981 
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/interfaces/IERC1155.sol";

/// @dev for upgradeable mints, need to import upgradeable versions of ERC721/ERC2981
import "@openzeppelin/contracts-upgradeable/interfaces/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @dev common
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
/// @dev SafeERC20 is not upgrade safe, causes deploy err. So changed to SafeERC20Upgradeable
//import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";



interface IAddressRegistry {
    function cactus() external view returns (address);
    function marketplace() external view returns (address);
    function tokenRegistry() external view returns (address);
}

interface ITokenRegistry {
    function mapped(address) external returns (bool);
}

/// @notice listed items for Sale
    struct Listing {
	    address seller;
        uint256 quantity;
        address payToken;
	    // Can be bought at any moment by providing this price
        // if payToken is 0x0 then buyNowPricePerItem is in native coin else in payToken
        uint256 buyNowPricePerItem; 
        uint256 startingTime; 
    }

interface IMarketplace {
    function inSale(address, uint256)
        external
        view
        returns (
            address,
            uint256,
            address,
            uint256,
            uint256
        );
}

/**
 * @notice contract for NFT auction market
 * @dev This contract is upgradeable
 * @dev Initializable needs to be the first to be derived from 
 * @dev currently supports highest Bidder auction: scheduled and reserve auctions 
 * @dev currently supports ERC721 token standard
 * @dev todo: support other tokens like ERC1155 
 * @dev todo: contract owner and transfer of ownership
 * @dev state varibles, static variables and internal/private functions start with _
 */
contract CactusAuctionMarketplaceV1 is  Initializable, 
                                        OwnableUpgradeable, 
                                        ReentrancyGuardUpgradeable {

    using SafeMath for uint256;
    using AddressUpgradeable for address payable;
    using SafeERC20Upgradeable for IERC20;

    /// @notice Event emitted only on contract deployment.
    /// @dev Can be used from admin panel
    event AuctionContractDeployed();
    
    /// @notice Event emiited when pause toggled by admin(owner) of auction contract
    /// @dev Can be used from admin panel.
    event PauseToggled(bool isPaused);

    event AddressRegistryUpdated(address registry);

    ////////////////////////////////////////////////
    /// Events for updateable auction parameters ///
    /// Only settable by seller (auction owner   ///
    /// OR  auction admin/controller aka admin)  ///
    ////////////////////////////////////////////////
 
    event PlatformFeeUpdated(uint256 platformFee);

    event PlatformFeeRecipientUpdated(address payable platformFeeRecipient);

    event MinBidIncrementUpdated(uint256 minBidIncrement);

    event BidWithdrawalLockTimeUpdated(uint256 bidWithdrawalLockTime);

    event AuctionStartTimeUpdated(
        address indexed assetContract,
        uint256 indexed tokenId,
        uint256 startTime
    );

    event AuctionEndTimeUpdated(
        address indexed assetContract,
        uint256 indexed tokenId,
        uint256 endTime
    );

    event AuctionMinBidUpdated(
        address indexed assetContract,
        uint256 indexed tokenId,
        address payToken,
        uint256 newMinBid
    );

    event AuctionReservePriceUpdated(
        address indexed assetContract,
        uint256 indexed tokenId,
        address payToken,
        uint256 newReservePrice
    );

    event AuctionPayTokenUpdated(
        address indexed assetContract, 
        uint256 indexed tokenId, 
        address previousPayToken, 
        address newPayToken
    );

    //////////////////////////////////////////
    /// @notice Main Events in Auction     ///
    //////////////////////////////////////////

    /// @notice Events emitted during auction
    event AuctionCreated(
        address indexed assetContract,
        uint256 indexed tokenId,
        address payToken
    );

    event AuctionHighestBidAccepted(
        address oldOwner,
        address indexed assetContract,
        uint256 indexed tokenId,
        address indexed winner,
        address payToken,
        uint256 winningBid
    );

    event AuctionSettled(
        address oldOwner,
        address indexed assetContract,
        uint256 indexed tokenId,
        address indexed winner,
        address payToken,
        uint256 winningBid
    );


    event AuctionCancelled(
        address indexed assetContract, 
        uint256 indexed tokenId
    );

    event BidMade(
        address indexed assetContract,
        uint256 indexed tokenId,
        address indexed bidder,
        uint256 bid
    );

    event BidTransferred(
        address indexed assetContract,
        uint256 indexed tokenId,
        address indexed bidder,
        address to,
        uint256 bid,
        address payToken
    );

    event BidWithdrawn(
        address indexed assetContract,
        uint256 indexed tokenId,
        address indexed bidder,
        uint256 bid
    );

    event BidRefunded(
        address indexed assetContract,
        uint256 indexed tokenId,
        address indexed bidder,
        uint256 bid
    );

   event PaidOut(
            address assetContract, 
            uint256 tokenId,
            address payToken, 
            uint256 price,
            address payable recipient, 
            uint256 amount,
            bool transferSuccess
    );

    ///////////////////////////////////////////////////////////////////////////
    ////////////////////////// @notice State Variables ////////////////////////
    ///////////////////////////////////////////////////////////////////////////
    /// @notice if upgradeable contracts, then need to be cautious about variable layout
    /// @dev Dont delete, redorder variables if this contract is upgradeable
    /// @dev Dont use constructor but use initilizer to avoid intializing twice if this contract is upgradeable
    /// @dev Dont use inline intilization for variables if this contract is upgradeable
    /// @dev Always add new variables at end of the layout if this contract is upgradeable

    /// @notice States of auction
    // DONT_EXIST - initial state
    // EXISTS - on creating a new auction
    // BIDDEN -  atleast one valid bid placed
    // ACCEPTED - valid bid is accepted by seller without settling process(auction stops to exist)
    // EXTENDED - auction time is extended
    // CANCELLED - auction cancelled (auction stops to exist)
    // CLOSED/SETTLED - After auction ends auction is closed if 
                    // acceptable bid with exchange of nft and highestbid((auction stops to exist)
    // WITHDREW_BID - bid withdrawn if settlement dont happen (auction still exists)
    enum State { 
        DONT_EXIST,
        EXISTS, 
        BIDDEN,  
        ACCEPTED, 
        EXTENDED, 
        CANCELLED,
        CLOSED, 
        WITHDREW_BID 
    }

    /// @notice Types of auction
    enum AuctionType { 
        HIGHESTBIDDER_SCHEDULED,                    // have start & end time, minBid=0
        HIGHESTBIDDER_SCHEDULED_MINBID,             // start & end time, minBid>0
        HIGHESTBIDDER_RESERVE,                      // start & end time, minBid <= reserveprice
        HIGHESTBIDDER_RESERVE_WITH_MINBID_CUTOFF    // start & end time, minBid <= reserveprice * cutoff/100  
    }

    /// @notice Parameters and info of an auction
    /// @dev These are specific for each Auction
    /// @dev Kept separate from struct HighestBid to reset independently
    struct Auction {
        AuctionType auctionType;
        State   inState; // current state auction is in
        address owner; // owner of token ID
        address admin; // controller of auction
        address payToken; // BEP20 Token used to bid for auction
        uint256 minBid;  // optional(ie minBid =0) in highestBidder scheduledAuction
        uint256 rsvPricePerToken; // only needed in highestBidder reserverAuction 
        uint256 startTime; // when auction starts in UNIX epoch
        uint256 endTime;  //when auction starts in UNIX epoch 
        uint256 Id; //auction Id
    }

    /// @notice Information about the sender that placed a bid on an auction
    /// @dev Kept separate from Auction struct to reset independently
    struct HighestBid {
        address payable bidder;
        uint256 bid;
        uint256 lastBidTime;
    }


    /// @notice for debugging and stats only
    /// @dev can remove in live versions
    struct Bidder {
        address payable bidder;
        uint256 bidAmount;
        uint256 bidAt;
    }
    /// @notice for debugging and stats only
    /// @dev can remove in live versions
    struct Stats{
        uint256 startTime;
        uint256 endTime;
        uint256 nftHighestlastBidTime;
        Bidder[] bidders;
    }

    /// @dev todo: planning needed to handle ERC1155 auctions also
    /// @dev todo: check constant (impact)  in upgradeable version
    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 private constant INTERFACE_ID_ERC1155 = 0xd9b67a26;
    mapping(address => mapping(uint256 => Auction)) public _auctions;
    mapping(address => mapping(uint256 => HighestBid)) public _highestBids;

    /////////////////////////////////////////
    /// Global params across all auctions ///
    /////////////////////////////////////////

    /// todo: global platform fee, eg: 25 = 2.5%
    uint256 public _platformFeePercent;

    /// @notice where to send platform/commission fee funds to
    address payable public _platformFeeRecipient;
  
    /// @notice the amount by which a bid has to increase for all auctions
    /// @dev in WEI
    uint256 public _minBidIncrement; 

    /// Mimimum margin (expressed in percent) between minBid and reserve price 
    /// @dev todo: currently whole numbers only supported, need to support decimals, eg: 85.5
    uint256 public _minBidCutoff;

    /// Time afterwhich bid can be withdrawn post auction's end
    uint256 public _bidWithdrawalLockTime;

    // stats or Count for auctions, sales 
    uint256 public _onAuction;
    uint256 public _sold;

    /// @notice for switching off/on auction creations, bids and withdrawals
    bool public _isPaused;


    /////////////////////////////////////////////////////////////////////////////////////////
    /// @notice  Static Variables ///////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////

    /// @notice Address registry for looking up other contract addresses
    IAddressRegistry public _addressRegistry;

    /// @dev todo: auctionExtendBy 
    /// @dev todo: get owner of deployed contract, change owner of deployed contract

    /*
    /// @notice constructor to init auction params/settings
    /// @dev todo: comment constructor if upgradebale contracts and move intilization to initializer
    /// @param platformFeeRecipient  address of fee/commission reciever
    /// @param platformFeePercent  fee/comission percent 
    /// @param minBidCutoff cutoff percent for minimum Bid with respect to reserve price
    /// @param minBidIncrement next bid increment step in wei
    /// @param bidWithdrawalLockTime  time afterwhich bid can be withdrawn post auction end
    constructor(
        address payable platformFeeRecipient, 
        uint256 platformFeePercent,
        uint256 minBidCutoff,
        uint256 minBidIncrement,
        uint256 bidWithdrawalLockTime
    )
    {
        require(platformFeeRecipient != address(0), "Zero address");
        require(platformFeePercent>=0, "platform fee less than 0");
        /// @dev todo: Make them constants?
        require(minBidCutoff>0  && minBidCutoff<=100);
        require(minBidIncrement > 0, "Minimum BidIncrement should be greater than 0");
        require(bidWithdrawalLockTime >= 1200 && 
                bidWithdrawalLockTime <= 86400);
       
        _platformFeeRecipient = platformFeeRecipient;
        _platformFeePercent = platformFeePercent;
        _minBidCutoff = minBidCutoff;
        _minBidIncrement = minBidIncrement;
        _bidWithdrawalLockTime = bidWithdrawalLockTime;
        emit AuctionContractDeployed();
    }
    */

    /// @notice Contract initializer used in upgradeable contract inplace of constructor
    /// @dev todo: comment constructor if upgradebale contracts and move intilization to initializer
    /// @param platformFeeRecipient  address of fee/commission reciever
    /// @param platformFeePercent  fee/comission percent 
    /// @param minBidCutoff cutoff percent for minimum Bid with respect to reserve price
    /// @param minBidIncrement next bid increment step in wei
    /// @param bidWithdrawalLockTime  time afterwhich bid can be withdrawn post auction end
    function initialize(
        address payable platformFeeRecipient, 
        uint256 platformFeePercent,
        uint256 minBidCutoff,
        uint256 minBidIncrement,
        uint256 bidWithdrawalLockTime
    )   public
        initializer
    {
        require(platformFeeRecipient != payable(address(0)), "Zero address for platformFeeRecipient");
        require(platformFeePercent>=0, "platform fee less than 0");
        /// @dev todo: Make them constants?
        require(minBidCutoff>0  && minBidCutoff<=100);
        require(minBidIncrement > 0, "Minimum BidIncrement should be greater than 0");
        require(bidWithdrawalLockTime >= 1200 && 
                bidWithdrawalLockTime <= 86400);
       
        _platformFeeRecipient = platformFeeRecipient;
        _platformFeePercent = platformFeePercent;
        _minBidCutoff = minBidCutoff;
        _minBidIncrement = minBidIncrement;
        _bidWithdrawalLockTime = bidWithdrawalLockTime;
        emit AuctionContractDeployed();
        
        __Ownable_init();
        __ReentrancyGuard_init();
    }

    /////////////////////////////////////////////////////
    /// @notice External fucntions                  /////       
    //  can change state                           //////
    /////////////////////////////////////////////////////

    /////////////////////////////////////////////////////
    //////////// TERMS used /////////////////////////////
    /////////////////////////////////////////////////////

    /**
     @notice Create a new auction 
     @dev  Call approve token before calling createAuction
     @dev  Only callable by token owner  
     @dev  Checks for validity of auction types and the bid settings are added as functions instead of modifiers to prevent "stack too deep" issue
     @dev  PayToken is ERC20 Token contract address or 0x0 (for Native coin).
     @dev  Some auctions dont have reserve price
     @dev  minBid should be >0 or be a starting bid>=x
     @dev  It can be a reserve auction or not
     @dev  If reserve auction, then sometimes minBid may be start with rsvPricePerToken
     @dev  If not a reserve auction, then ignore rsvPricePerToken
     @param assetContract ERC721 nft address. The contract address of the NFTs being listed for sale.
     @param tokenId The token ID on the 'assetContract' of the NFTs to list for sale.
     @param auctionMethod type of acution 
     @param startTimestamp scheduled starttime of the auction.The unix timestamp after which NFTs can be bought from the listing.
     @param endTimestamp time at which auction ends
     @param payTokenContract address 0x0 if native currency else token address if ERC20/BEP20
     @param quantity The amount of NFTs of the given 'assetContract' and 'tokenId' to list for sale. For ERC721 NFTs, this is always 1.
     @param minimumBid acceptable starting price (aka floor price)
     @param rsvPricePerToken bids equal or higherthan rsvPricePerToken is desired by seller.  All bids made to this auction must be at least as great as the reserve price per unit of NFTs auctioned, times the total number of NFTs put up for auction.
     @param buyOutPriceperToken optional parameter. If a buyer bids an amount greater than or equal to the buyout price per unit of NFTs auctioned, times the total number of NFTs put up for auction, the auction is considered closed and the buyer wins the auctioned items
    */
    function createAuction(
       address assetContract,
       uint256 tokenId,
       AuctionType auctionMethod,
       uint256 startTimestamp,
       uint256 endTimestamp,
       address payTokenContract,
       uint256 quantity, 
       uint256 minimumBid,
       uint256 rsvPricePerToken,
       uint256 buyOutPriceperToken
    )   external 
        returns (uint256)
    {
        // Only if contract is nonzero valid NFT and tokenId exists
        _onlyNFT(assetContract, tokenId, quantity); 

        // Only if token owner then go ahead
        /// @dev: Stack too deeep issue- more number of args in createAuction 
        /// @dev: so onlyRoleTokenOwner modifier was changed to internal call  
        _onlyRoleTokenOwner(assetContract, tokenId);

        // only if all NFTs in the asset contract are preapproved for auction marketplace, then go ahead.
        _onlyApproved(assetContract,_msgSender());

        // only the auction type is known
        require(_onlyAuctionTypes(auctionMethod),"unknown auction type");
        
        // @dev todo: optimize or reduce code logic in onlyBidSettings
        _onlyBidSettings(auctionMethod, minimumBid, rsvPricePerToken);
        
        // check nft alreadggy in an ongoing auction or listedin marketplace for sale
        require(_auctions[assetContract][tokenId].endTime == 0,"item is already in ongoing auction");

        // Only if item not listed in auction market
        ( ,uint256 quantityListed, , ,) = IMarketplace(_addressRegistry.marketplace()).inSale(assetContract, tokenId);
        require(quantityListed == 0 ,"item is already listed in marketplace for sale");

        // validate ranges of start and end time for new auction
        require(startTimestamp > _currentTime(),"invalid start time: should be greater than current time");
        require(endTimestamp >= startTimestamp + 300, "end time must be greater than start (by margin(default=5) minutes)");
    
        // check the paying Token belongs to tokens whitelisted
        require(payTokenContract == address(0) ||
                (_addressRegistry.tokenRegistry() != address(0) &&
                    ITokenRegistry(_addressRegistry.tokenRegistry())
                        .mapped(payTokenContract)), "pay token invalid or not enabled"); 
        
        
        // auction dont exist now
        _auctions[assetContract][tokenId].inState = State.DONT_EXIST;

	    // Setup the auction
        // @dev todo: Currently owner and admin are kept same
        _auctions[assetContract][tokenId] = Auction({
            owner: _msgSender(),
            admin: _msgSender(),
            payToken: payTokenContract,
            auctionType: auctionMethod,
            minBid: minimumBid,
            rsvPricePerToken: rsvPricePerToken,
            startTime: startTimestamp,
            endTime: endTimestamp,
            inState: State.EXISTS,
            Id: _onAuction++
        });
                
        // @dev todo: log more info about auction init params?
        emit AuctionCreated(
            assetContract, 
            tokenId, 
            payTokenContract
        );
        return _auctions[assetContract][tokenId].Id;
    }
    
    /**
     @notice place bid with BNB and enabled tokens
     @dev call approve of the token(eg: citrus token) before calling this function if bidding is in Token
     @dev only callable by others except seller(token owner/auction admin) and contracts
     @dev seller prevented from placing bid because seller can run up the price, hoping for more profits
     @dev only callable during bidding window(between starttime and end time) and when auction exists
     @dev Contracts are not permitted to place bids.If a user sent a bid from a contract with a maliciously-crafted fallback function designed
          to expend all of the gas provided to it, then that user could never be outbid, because when 
          someone else tried to place a bid, the EVM would send ETH/BNB/token back to that malicious 
          fallback function. The transaction would run out of gas, preventing the new user’s bid from being recorded
     @dev todo test: if not expected payment mode, then revert the payment.
     @param assetContract ERC721 nft address 
     @param tokenId token Id of nft
     @param bidAmount bid amount placed by bidder of nft
     @param payToken 0x0 if native coin otherwise token contract address if token
     */
    function makeBid(
        address assetContract,
        uint256 tokenId,
        uint256 bidAmount,
        address payToken
    )   external 
        payable 
        nonReentrant 
        whenNotPaused
        onlyRoleNotSeller(assetContract, tokenId) 
        onlyRoleNotContracts()
        returns (bool success)
    {

        Auction storage auction = _auctions[assetContract][tokenId];
        // check auction is in bidding window/open for bids
        // otherwise auction started not yet, endtime is over or got accepted/canceled/ended/settled
        require(_currentTime() >= auction.startTime , "auction has not started yet");
        require(_currentTime() <= auction.endTime,"aucton endtime is over");

        HighestBid storage highestBid = _highestBids[assetContract][tokenId];
        // Accept bids above starting price and higher than previous bid plus minIncrement
        require(bidAmount > auction.minBid,"bid is less than minBid required");
        require(bidAmount >= highestBid.bid.add(_minBidIncrement),"failed to outbid highest bidder");
        
        // check coin or payToken used to bid
        require(auction.payToken == payToken,"bid payToken different from token in auction settings");
        require((payToken == address(0) && msg.value == bidAmount)||
                (payToken != address(0) && msg.value == 0),
                "mismatch in payment mode usage in bidding");
        
        // If Token used to bid, then transfer bidAmount in payToken to auction contract address
        if (payToken != address(0)) {
            _transferBid(assetContract, tokenId, _msgSender(), address(this), bidAmount, payToken);
        }//else bid placed using Native coin

        // Save current highest bidder info
        
        address payable currentHighestBidder = highestBid.bidder;
        uint256 currentHighestBid = highestBid.bid;

        // If not the first bidder, then refund previous bidder saved
        // Refund using native coin or payToken whichever is setup 
        // while creating auction
        // todo: try using safe transfer
        if(currentHighestBidder != address(0) && currentHighestBid > 0){
           _refundBid(assetContract, tokenId, currentHighestBidder, currentHighestBid, payToken);
        }
	    // assign top bidder and bid time
        highestBid.bidder = payable(_msgSender());
        highestBid.bid = bidAmount;
        highestBid.lastBidTime = _currentTime();
        auction.inState = State.BIDDEN;
    	emit BidMade(assetContract, tokenId, highestBid.bidder, highestBid.bid);
       
	    /// @dev todo: check need for this?
        //update ongoing auction end time.
	    //auction end should be now + bidEndPeriod
        //uint256 auctionEndPeriod = _auctions[nft][tokenId].auctionEndPeriod;
        //auctionEndPeriod = getAuctionBidPeriod(nft, tokenId) + block.Timestamp;
        //emit AuctionPeriodUpdated(nft, tokenId, auctionEndPeriod);
        return true;
    }

    /** 
     @notice Before auction end time is over, Seller can end the auction by accepting the current highest bid, and swap NFT with highestBidder
     @dev Only callable by seller(Token owner or auction admin)
     @dev todo: UX to add accept button to UI for this.
     @dev Auction should be ongoing/existing (not ended , not {accepted/closed/canceled}) and have a valid open bid
     @param assetContract ERC 721 Address
     @param tokenId Token ID of the item 
     */
    function acceptAuctionHighestBid(
        address assetContract, 
        uint256 tokenId
    )   external 
        nonReentrant
        onlyRoleSeller(assetContract, tokenId)
        onlyApproved(assetContract,_msgSender())
    {
        Auction storage auction = _auctions[assetContract][tokenId];

        // To accept a bid, auction end time should not have reached
        require(_currentTime() <= auction.endTime, "aucton endtime is over");
        require(auction.inState != State.ACCEPTED, "Bid already accepted");

        HighestBid storage highestBid = _highestBids[assetContract][tokenId];
        // Only if atleast one bid 
        require(highestBid.bidder != address(0),"no open bids");
        // Additional check to flag the bid as ACCEPTABLE
        require(highestBid.bid > auction.minBid, "highest bid is below minBid plus minIncrement");

        // Get info on who the highest bidder is
        address winner = highestBid.bidder;
        uint256 price = highestBid.bid;
        // Clean up the highest bid
        delete _highestBids[assetContract][tokenId];

        auction.inState = State.ACCEPTED;
        _exchange(assetContract, tokenId, auction.owner, winner, price, auction.payToken);
        _onAuction--;

        emit AuctionHighestBidAccepted(
            _msgSender(),
            assetContract,
            tokenId,
            highestBid.bidder,
            auction.payToken,
            highestBid.bid
        );

        // Remove specific auction
        delete _auctions[assetContract][tokenId];
    }

    /**
     @notice Closes an ended auction and exchanges nft&bid between winner and seller
     @dev Only seller can call (token owner or auction admin)
     @dev Auction can only be closed if there has been a bidder and minBid+increment met
     @dev Additional conditions to close the auction can be added as per requirement
     @dev Auction needs to be cancelled instead using `cancelAuction()` if no open bids
     @param assetContract ERC 721 Address
     @param tokenId Token ID of the item 
     */
    function CloseAuction(
        address assetContract, 
        uint256 tokenId
    )   external nonReentrant
        onlyRoleSellerORTopBidder(assetContract, tokenId) 
        onlyApproved(assetContract, _msgSender())
    {
        Auction storage auction = _auctions[assetContract][tokenId];
        // Auction should have ended and still exist
        require(auction.endTime > 0,"no auction exists");
        require(_currentTime() > auction.endTime,"auction has not ended");
        require(auction.inState != State.CLOSED,"auction already closed");

        HighestBid storage highestBid = _highestBids[assetContract][tokenId];
        // condition to decide auction is closeable
        require(highestBid .bidder != address(0),"no open bids");
        require(highestBid .bid > auction.minBid, 
                "highest bid is below minBid plus increment");

        // Get info on who the highest bidder is
        address winner = highestBid.bidder;
        uint256 price = highestBid.bid;
        // Clean up the highest bid
        delete _highestBids[assetContract][tokenId];

        auction.inState = State.CLOSED;
        _exchange(assetContract, tokenId, auction.owner, winner, price, auction.payToken);

        _onAuction--;
        emit AuctionSettled(
            _msgSender(),
            assetContract,
            tokenId,
            winner,
            auction.payToken,
            price
        );
        delete _auctions[assetContract][tokenId];
        
    }

    /**
     @notice To cancel unsettled existing/ongoing auctions
     @notice Returning the funds to the top bidder if found
     @dev Only token owner can call
     @dev Call CancelAuction if there are no open Bids after auction ended
     @dev If buyer withdraws Bid, then also there will be no outstanding bids, then also cancelAuction should work.
     @param assetContract ERC 721 Address
     @param tokenId Token ID of the NFT 
     */
    function cancelAuction(
        address assetContract, 
        uint256 tokenId
    )   external
        nonReentrant
        onlyRoleSeller(assetContract, tokenId)
    {
        // check auction exists(ongoing and not canceled or not closed)
        Auction storage auction = _auctions[assetContract][tokenId];
        require(auction.endTime > 0,"no auction exists");
        require(auction.inState != State.CLOSED,"auction already closed");

         // refund existing top bidder if found
        HighestBid storage highestBid = _highestBids[assetContract][tokenId];
        if (highestBid.bidder != address(0)) {
            _refundBid(assetContract, tokenId, highestBid.bidder, highestBid.bid, auction.payToken);
            // Reset highest bid
            delete _highestBids[assetContract][tokenId];
        }
        auction.inState = State.CANCELLED;
        // Remove this specfic auction
        delete _auctions[assetContract][tokenId];
        _onAuction--;
        emit AuctionCancelled(assetContract, tokenId);
    }

    /**
     @notice Allows the winner to withdraw the bid after some hours post auction's end 
     @dev Only callable by the existing top bidder
     @dev Only condition needed to check is whether auction has ended and x hours past after end of auction
     @dev After winner calls withdrawBid(), CancelAuction() can be called, else auction struture is not cleared
     @param assetContract ERC 721 Address
     @param tokenId Token ID of the item 
     */
    function withdrawBid(address assetContract, uint256 tokenId)
        external
        nonReentrant
        whenNotPaused
        onlyRoleTopBidder(assetContract, tokenId)
    {
        // check auction end time is over and withdrawal lock time is over
        require( _currentTime() > _auctions[assetContract][tokenId].endTime && 
                (_currentTime() - _auctions[assetContract][tokenId].endTime >= _bidWithdrawalLockTime),
                "can withdraw bid only after lock time Hrs once auction ended"
        );

        //Reset highest bid 
        HighestBid storage highestBid = _highestBids[assetContract][tokenId];
        uint256 previousBid = highestBid.bid;
        delete _highestBids[assetContract][tokenId];

        // To change auction state to withdrew
        Auction storage auction = _auctions[assetContract][tokenId];
        address payToken = auction.payToken;

        // Refund the top bidder
        // Refund using native coin or payToken whichever is setup while creating auction.
       if(_msgSender() != address(0) &&  previousBid > 0){
             _refundBid(assetContract, tokenId, payable(_msgSender()), previousBid, payToken);
        }
        auction.inState = State.WITHDREW_BID;
        emit BidWithdrawn(assetContract, tokenId, _msgSender(), previousBid);
    }

    ///////////////////////////////////
    //////Update Auction parameters////
    //////External functions///////////
    //////Only Contract Owner(admin)///
    ///////////////////////////////////

    /**
     @notice Toggling off/on the pause flag 
     @dev Only admin (Auction contract owner)
     @dev currently applied to on/off calls to createAuction,makeBid,withdrawBid
     */
    function toggleIsPaused() 
    external 
    onlyOwner 
    {
        _isPaused = !_isPaused;
        emit PauseToggled(_isPaused);
    }

    /**
     @notice for updating platform fee/commission fee
     @dev Only admin (Auction contract owner)
     @param platformFee uint256 the platform fee to set
     */
    function updatePlatformFee(
        uint256 platformFee
    )   external 
        onlyOwner 
    {
        _platformFeePercent = platformFee;
        emit PlatformFeeUpdated(platformFee);
    }

    /**
     @notice for updating platform fee recipient address
     @dev Only admin (Auction contract owner)
     @param platformFeeRecipient payable address the address to sends the funds to
     */
    function updatePlatformFeeRecipient(
        address payable platformFeeRecipient
    )   external
        onlyOwner
    {
        require(_platformFeeRecipient != address(0), "zero address");
        _platformFeeRecipient = platformFeeRecipient;
        emit PlatformFeeRecipientUpdated(platformFeeRecipient);
    }

    /**
     @notice Bid amount increment across all auctions
     @dev Only admin (Auction contract owner)
     @param minBidIncrement New bid step in WEI
     */
    function updateMinBidIncrement(uint256 minBidIncrement)
        external
        onlyOwner
    {
        _minBidIncrement = minBidIncrement;
        emit MinBidIncrementUpdated(minBidIncrement);
    }

    /**
     @notice Update the global bid withdrawal lockout time
     @dev Only admin (Auction contract owner)
     @param bidWithdrawalLockTime New bid withdrawal lock time
     */
    function updateBidWithdrawalLockTime(
        uint256 bidWithdrawalLockTime
    )   external
        onlyOwner
    {
        _bidWithdrawalLockTime = bidWithdrawalLockTime;
        emit BidWithdrawalLockTimeUpdated(bidWithdrawalLockTime);
    }

    /**
     @notice Update AddressRegistry contract
     @dev Only admin (Auction contract owner)
     */
    function updateAddressRegistry(
        address registry
    )   external 
        onlyOwner 
    {
        _addressRegistry = IAddressRegistry(registry);
        emit AddressRegistryUpdated(registry);

    }

    /**
     * @notice claim ERC20 Compatible tokens
     * @dev can change state: balance of auction smart contract
     * @dev Only owner of contract (contract admin, admin panel) allowed to claim
     * @dev todo: test the EnabledToken,  check admin can withdraw bids placed during bidding??
     * @param payToken The address of the token contract
     */
    function reclaimPayToken(
        address payToken
    )   external 
        onlyOwner
    {
        require( payToken != address(0), "Invalid address");
        //require(onlyEnabledToken(payToken), "pay token invalid or not enabled");
        IERC20 token = IERC20(payToken);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(_msgSender(), balance), "Transfer failed");
    }

    /**
     * @notice claim ERC20 Compatible tokens
     * @dev can change state: balance of auction smart contract
     * @dev Only owner of contract (contract admin, admin panel) allowed to claim
     * @dev todo: check admin can withdraw bids placed during bidding??
     */
    function reclaimBNB(
    )   external 
        onlyOwner 
    {
        uint256 balance = address(this).balance;
        (bool successRefund, ) = _msgSender().call{value: balance}("");
        require(successRefund, "Transfer failed");
    }

    ////////////////////////////////////////////////
    //////Update Auction parameters             ////
    //////External functions                    ////
    //////Only Seller(Tokenowner/auction admin)/////
    ////////////////////////////////////////////////
 
    /** 
     * @notice Update MinimumBid
     * @dev Only Seller (token owner or auction admin) can call
     * @dev As long as auction is there(and not ended) and Till first bid happens(BIDDEN), can change MinBid
     * @dev onlyMinBidForUpdate( if mindBid setting was 10, then bid was 11, then 12, 
     * @dev then newminBid cannot be 15  )  
     * @dev making newminBid of 9 dont make sense as hghhestBid is now already 12
     * @param assetContract ERC721 nft address
     * @param tokenId token Id of the nft/item
     * @param newMinBid new Min Bid
     * @param payToken intended payToken
     */

    function updateAuctionMinimumBid(
        address assetContract, 
        uint256 tokenId, 
        uint256 newMinBid,
        address payToken
    ) external
        onlyRoleSeller(assetContract, tokenId)
        onlyMinBidForUpdate(assetContract, tokenId, newMinBid)
    {
        Auction storage auction = _auctions[assetContract][tokenId]; 
        require(auction.endTime > 0,"no auction exists");
        require(_currentTime() <= auction.endTime,"auction has ended");
        require(_highestBids[assetContract][tokenId].bidder == address(0),"auction has open bids");
        require(auction.payToken == payToken,"bid payToken different from token in auction settings");

        auction.minBid = newMinBid;
        emit AuctionMinBidUpdated(assetContract, tokenId, payToken, newMinBid);
    }

    /** 
     * @notice Update ReservePrice
     * @dev Only Seller (token owner or auction admin) can call
     * @param assetContract ERC721 nft address
     * @param tokenId Token Id of the nft/item
     * @param newReservePrice New Reserve Price
     * @param payToken Intended payToken
     */
    function updateAuctionReservePrice(
        address assetContract, 
        uint256 tokenId,
        uint256 newReservePrice,
        address payToken
    ) external 
        onlyRoleSeller(assetContract, tokenId)
        onlyReservePriceForUpdate(assetContract, tokenId, newReservePrice)
    {
        Auction storage auction = _auctions[assetContract][tokenId];
        require(auction.endTime > 0, "no auction exists");
        require(auction.inState != State.CLOSED, "auction already settled");
        require(auction.payToken == payToken,"bid payToken different from token in auction settings");
        auction.rsvPricePerToken = newReservePrice;
        emit AuctionReservePriceUpdated(
            assetContract,
            tokenId,
            payToken,
            newReservePrice
        );
    }

    /**
     @notice Update the current start time for an auction
     @dev Only Seller (token owner or auction admin)
     @dev Auction must exist
     @param assetContract ERC 721 Address
     @param tokenId Token ID of the NFT 
     @param startTime New start time (unix epoch in seconds)
     */
    function updateAuctionStartTime(
        address assetContract,
        uint256 tokenId,
        uint256 startTime
    )   external
        onlyRoleSeller(assetContract, tokenId)
    {
        Auction storage auction = _auctions[assetContract][tokenId];
        // only existing auction
        require(auction.endTime > 0, "no auction exists");
        require(startTime > 0, "invalid start time"); 
        //only if auction not already started   
        require(auction.startTime + 60 > _currentTime(), "auction already started" );
        //New starting time should be less than endTime by atleast 5 minutes
        require(startTime + 300 < auction.endTime, 
                "start time should be less than end time (by margin=5 minutes)"
        );
        auction.startTime = startTime;
        emit AuctionStartTimeUpdated(assetContract, tokenId, startTime);
    }

    /**
     @notice Update the current end time for an auction
     @dev Only Seller (token owner or auction admin)
     @dev Auction must exist
     @param assetContract ERC 721 Address
     @param tokenId Token ID of the NFT 
     @param endTimestamp New end time (unix epoch in seconds)
     */
    function updateAuctionEndTime(
        address assetContract,
        uint256 tokenId,
        uint256 endTimestamp
    )   external
        onlyRoleSeller(assetContract, tokenId)
    {
        Auction storage auction = _auctions[assetContract][tokenId];
        // only existing auction
        require(auction.endTime > 0, "no auction exists");
        // Auction end time is not over
        require(_currentTime() <= auction.endTime, "auction has ended");  
        // New endtime should be in future
        require(auction.startTime < endTimestamp, 
                "end time must be greater than start"); 
        // New endtime need to be atleast 5 minutes apart from current time        
        require(endTimestamp >= _currentTime() + 300,
                "end time must be greater than now by (margin(default=5) minutes)");

        auction.endTime = endTimestamp;
        emit AuctionEndTimeUpdated(assetContract, tokenId, endTimestamp);
    }

    /**
     @notice Update the payToken used in bidding for an auction
     @dev Only Seller (token owner or auction admin)
     @dev Auction must exist
     @param assetContract ERC 721 Address
     @param tokenId Token ID of the NFT 
     @param newPayToken New paying token
     */
    function updateAuctionPayToken(
        address assetContract,
        uint256 tokenId,
        address newPayToken
    )   external 
        onlyRoleSeller(assetContract, tokenId)
    {
        Auction storage auction = _auctions[assetContract][tokenId];
        
        // only if auction is ongoing and no open bids and have not ended
        require(auction.endTime > 0, "no auction exists");
        require(_highestBids[assetContract][tokenId].bidder == address(0),"auction has open bids");
        require(_currentTime() <= auction.endTime,"auction has ended");
        
        // only if the paying Token belongs to tokens whitelisted
        require(newPayToken == address(0) ||
                (_addressRegistry.tokenRegistry() != address(0) &&
                    ITokenRegistry(_addressRegistry.tokenRegistry())
                        .mapped(newPayToken)), "new pay token invalid or not enabled"); 
        
        // only if the new token is different from current token
        require(auction.payToken != newPayToken, 
            "bid payToken same as token in auction settings");
        
        address previousPayToken = auction.payToken;
        auction.payToken = newPayToken;
        emit AuctionPayTokenUpdated(assetContract, tokenId, previousPayToken, newPayToken);
    }

    /////////////////////////
    // External Querys //////
    // Read only      /////// 
    // Accessors     //////// 
    /////////////////////////

    /**
     @notice get all info about the auction
     @param assetContract ERC 721 Address
     @param tokenId Token ID of the NFT 
     */
    function getAuctionInfo(
        address assetContract, 
        uint256 tokenId
    )   external
        view
        returns (
            AuctionType auctionType,
            address owner,
            address admin,
            address payToken,
            uint256 minBid,
            uint256 rsvPricePerToken,
            uint256 startTime,
            uint256 endTime,
            State state
        )
    {
        Auction storage auction = _auctions[assetContract][tokenId];
        return (
            auction.auctionType,
            auction.owner,
            auction.admin,
            auction.payToken,
            auction.minBid,
            auction.rsvPricePerToken,
            auction.startTime,
            auction.endTime,
            auction.inState
        );
    }
    
    /**
     @notice get all info about the highest bidder
     @dev return a struct
     @param assetContract ERC 721 Address
     @param tokenId Token ID of the NFT 
     */
    function getAuctionHighestBid(
        address assetContract, 
        uint256 tokenId
    )   external
        view
        returns (
            address payable bidder,
            uint256 bid,
            uint256 lastBidTime
        )
    {
        return (
            _highestBids[assetContract][tokenId].bidder, 
            _highestBids[assetContract][tokenId].bid, 
            _highestBids[assetContract][tokenId].lastBidTime
        );
    }


    /////////////////////////////////////
    // Internal and Private functions  //
    /////////////////////////////////////

    /**
     @notice Internal function get current time in UNIX epoch time
     */
    function _currentTime() internal virtual view returns (uint256) {
        return block.timestamp;
    }
    
    /**
     @notice Internal function to move bid in token to other address(here auction contract) address
     @dev Assumes all params are prevalidated by the caller before invoking this function
     @param assetContract ERC 721 Address
     @param tokenId Token ID of the NFT 
     @param from sender address
     @param to contract address
     @param bidAmount bid amount placed by bidder or sender
     @param payToken token used for paying
     */
    function _transferBid(
        address assetContract,
        uint256 tokenId,
        address from, 
        address to, 
        uint256 bidAmount,
        address payToken
    )   private 
    {
        IERC20 payTokenAddr = IERC20(payToken);
        // This contract (market contract) moves money owned by "from" address
        // So transferFrom call is required (Need approval which need to be previously given to market contract by the buyer)  
        require(
                payTokenAddr.transferFrom(from, to, bidAmount), 
                "Insufficient balance or not approved"
        );
        emit BidTransferred(
            assetContract,
            tokenId,
            from,
            to,
            bidAmount,
            payToken
        );
    }

    /**
     @notice Internal function to refunds bid amount to current highest bidder if there is a outbid or auction gets cancelled
     @dev Assumes all params are prevalidated by the caller before invoking this function
     @dev similar to _payout() internal method but purpose is different, ie refund
     @param assetContract ERC 721 Address
     @param tokenId Token ID of the NFT 
     @param to recpient/bidders address
     @param amount bid amount placed by bidder or sender to refund
     @param payToken token used for paying
     */
    function _refundBid(
        address assetContract,
        uint256 tokenId,
        address payable to,
        uint256 amount,
        address payToken
    ) private {
        if (payToken == address(0)) {
            // refund previous best (if bid exists)
            (bool successRefund, ) = to.call{
                value: amount
            }("");
            require(successRefund, "failed to refund previous bidder");
        } else {
            IERC20 payTokenAddr = IERC20(payToken);
            require(
                payTokenAddr.transfer(to, amount),
                "failed to refund previous bidder"
            );
        }
        emit BidRefunded(
            assetContract,
            tokenId,
            to,
            amount
        );
    }
 
    /**
     @notice Internal function to do the exchange of nft and  highestbid amount
     @dev Assumes all params are prevalidated by the caller before invoking this function
     @dev sets state, clears specific auction, makes auction stop to exist
     @param assetContract ERC 721 Address
     @param tokenId Token ID of the NFT 
     @param owner address of the NFT owner
     @param winner address of highest bidder 
     @param price price of the item or highestbid
     @param payToken paying Token
     */
    function _exchange(
        address assetContract, 
        uint256 tokenId,
        address owner,
        address winner,
        uint256 price,
        address payToken
    ) private 
    {
        /* do mutual trasnsfer */
        // Transfer winning bid as split payments 
        // to platformfeerecipient,seller,royaltyrecipient
        // Reverts if needed

        // Marketplace fee calculation
        uint256 platformFee = price.mul(_platformFeePercent).div(100);
        
        // Checking royalties
        // todo: check nft is ERC2981 compatible or not before calling
        (address royaltyRecipient, uint256 royaltyAmount) = 
            IERC2981(assetContract).royaltyInfo(tokenId, price.sub(platformFee));
        
        // Seller Amount
        uint256 toSellerAmount = price.sub(platformFee);
        toSellerAmount = toSellerAmount.sub(royaltyAmount);

        // make split payouts
        require(_payout(assetContract, tokenId, price, _platformFeeRecipient, platformFee, payToken), 
                "platform fee transfer failed");
        require(_payout(assetContract, tokenId, price, payable(royaltyRecipient), royaltyAmount, payToken), 
                "royalty transfer failed");
        require(_payout(assetContract, tokenId, price, payable(owner), toSellerAmount, payToken), 
                "seller amount transfer failed");

        // Transfer the token to the winner
        // reverts if needed
        // @dev todo: log message during failure
        // @dev todo: how to check specifically for ERC721Upgradeable NFT?
        if (IERC165(assetContract).supportsInterface(INTERFACE_ID_ERC721)) {
            IERC721(assetContract).safeTransferFrom(
                owner,
                winner,
                tokenId
            );
        }else if (IERC165(assetContract).supportsInterface(INTERFACE_ID_ERC1155)) {
            
        }
    }

    /**
     @notice Internal function to payout the royalty, platform fee and sale amount
     @dev Assumes all params are prevalidated by the caller before invoking this function
     @dev similar to _refundBid() internal method but purpose is different, ie to pay
     @param assetContract ERC 721 Address
     @param tokenId Token ID of the NFT 
     @param price winning bid amount
     @param recipient address of the party recieving split payment
     @param amount split amount to be paid to the recipient
     @param payToken token used for paying
     */
    function _payout(
        address assetContract,
        uint256 tokenId,
        uint256 price,
        address payable recipient, 
        uint256 amount, 
        address payToken
    )   private returns (bool)
    {
        bool transferSuccess = false;

        if(recipient != address(0)){
            if (payToken == address(0)){ 

                (transferSuccess, ) = payable(recipient).call{value: amount}("");
            }else{
                // Moves token from and owned by market contract to recipient
                // since the token is owned by market contract, transfer call is enough(transferFrom call is not required)
                transferSuccess = IERC20(payToken).transfer(recipient, amount);
            }
        }
                 
        emit PaidOut(
            assetContract, 
            tokenId,
            payToken, 
            price,
            payable(recipient), 
            amount,
            transferSuccess
        );
        return transferSuccess;
    }

    ///////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////MODIFIERS////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////
    /// most modifiers are wrapped inside functions to reduce code (24kb contract size limit issue)

    // Control to switch off/on main functions
    modifier whenNotPaused() {
       _whenNotPaused();
        _;
    }

    function _whenNotPaused() private view
    {
        require(!_isPaused, "contract paused");
    } 

    /////////////////////////////////////////
    // Modifiers related to Address checks //
    /////////////////////////////////////////

    modifier onlyNotZero(address assetContract){
        
        _onlyNotZero(assetContract);
        _;
    }
    
    function _onlyNotZero(address assetContract ) 
    private pure
    {
        require( 
            assetContract != address(0), 
            "zero address"
        );
    } 

    // Only NFT address
    modifier onlyNFT(
    address assetContract, 
    uint256 tokenId, 
    uint256 quantity)
    {
        _onlyNFT(assetContract, tokenId, quantity);
        _onlyExistingToken(assetContract, tokenId);
        _;
    }

    function _onlyNFT(
    address assetContract, 
    uint256 tokenId, 
    uint256 quantity
    ) private view
    {
        _onlyNotZero(assetContract);

        if (IERC165(assetContract).supportsInterface(INTERFACE_ID_ERC721)) {
        } 
        else 
        if (IERC165(assetContract).supportsInterface(INTERFACE_ID_ERC1155)) {
            require(IERC1155(assetContract).balanceOf(_msgSender(), tokenId) >= quantity,
                    "sender must hold enough nfts"
            );
        } else {
            revert("invalid or unknown type nft address");
        }
    }

    ////////////////////////////////////////////////////////////
    /// Modfiers related to role,access control, ownership  ////
    ////////////////////////////////////////////////////////////

    // For ensuring only marketplace contract can call
    modifier onlyRoleMarketplace() {
        _onlyRoleMarketplace();
        _;
    }

    function _onlyRoleMarketplace() private view{
        require(
            _addressRegistry.marketplace() == _msgSender(),
            "not marketplace contract"
        );
    }
    
    // Used before auction creation as no info in map
    // For ensuring only token owner can call
    modifier onlyRoleTokenOwner(
        address assetContract, 
        uint256 tokenId 
    )
    {
        _onlyRoleTokenOwner(assetContract, tokenId); 
        _;
    }

    function _onlyRoleTokenOwner(
        address assetContract, 
        uint256 tokenId
    )private view
    {
        if (IERC165(assetContract).supportsInterface(INTERFACE_ID_ERC721)) {
            require(_msgSender() == IERC721(assetContract).ownerOf(tokenId),
                    "sender must be item owner"
            );
        }
        else 
        if (IERC165(assetContract).supportsInterface(INTERFACE_ID_ERC1155)) {
            require(IERC1155(assetContract).balanceOf(_msgSender(), tokenId) !=0,
                    "owner must hold enough nfts"
            );
        }else {
            revert("invalid or unknown type nft address");
        }
    }

    // Used after auction creation as info available in map also
    // For ensuring only seller(token owner or auction admin) can call
    modifier onlyRoleSeller(
        address assetContract, 
        uint256 tokenId 
    )
    {
        _onlyRoleSeller(assetContract, tokenId);
        _;
    }

    function _onlyRoleSeller(
        address assetContract, 
        uint256 tokenId 
    ) private view
    {
        require(
            (_msgSender()  ==  IERC721(assetContract).ownerOf(tokenId) &&
             _msgSender()  ==  _auctions[assetContract][tokenId].owner )
             || _msgSender()  == _auctions[assetContract][tokenId].admin,
            "sender must be token owner or auction admin"
        );
    
    }

    
    // Used after auction creation as info available in map also
    // For ensuring token owner and auction admin cannot call, like place a bid
    modifier onlyRoleNotSeller(
        address assetContract, 
        uint256 tokenId 
    )
    {
        _onlyRoleNotSeller(assetContract, tokenId);
        _;
    }

    function _onlyRoleNotSeller(
        address assetContract, 
        uint256 tokenId 
    )private view
    {
        require(
            _msgSender() != _auctions[assetContract][tokenId].admin &&
            _msgSender() != _auctions[assetContract][tokenId].owner &&
            _msgSender() != IERC721(assetContract).ownerOf(tokenId),
            "sender cannot be auction seller/owner"
        );
        
    }

    // Used in cases where only top bidder can call like withdrawBid
    // Ensure highest bidder is the caller
    modifier onlyRoleTopBidder(
        address assetContract, 
        uint256 tokenId
    ){
        _onlyRoleTopBidder(assetContract, tokenId);
        _;
    }
    
    function _onlyRoleTopBidder(
        address assetContract, 
        uint256 tokenId 
    )private view
    {
        require(
             _highestBids[assetContract][tokenId].bidder != address(0) &&
            _msgSender() == _highestBids[assetContract][tokenId].bidder,
            "you are not the highest bidder"
        );
        
    }
    
    // Ensure highest bidder is the caller or the Seller
    // Used in case like closing an auction which seller and buyer with highest bid can do
    modifier onlyRoleSellerORTopBidder(
        address assetContract, 
        uint256 tokenId
    ){
        
        _onlyRoleSellerORTopBidder(assetContract, tokenId);
        _;
    }

    function _onlyRoleSellerORTopBidder(
        address assetContract, 
        uint256 tokenId
    )private view{
        require(
                    (_highestBids[assetContract][tokenId].bidder != address(0) &&
                    _msgSender() == _highestBids[assetContract][tokenId].bidder) ||
                    (_msgSender()  ==  IERC721(assetContract).ownerOf(tokenId) &&
                    _msgSender()  ==  _auctions[assetContract][tokenId].owner ) ||
                    _msgSender()  == _auctions[assetContract][tokenId].admin,
                    "you are neither the highest bidder nor seller"
        );
    }
    

    //  Cases like sender is not smart contract like making bids which smart contracts are not permitted
    /// @dev todo check security 
    modifier onlyRoleNotContracts()
    {
        require(
            _msgSender().code.length > 0 == false, 
            "no contracts permitted"
        );
        _;
    }

    // Checks token Id is valid by finding owner of the token exists (non zero)
    modifier onlyExistingToken(
        address assetContract,
        uint256 tokenId
    )
    {
        _onlyExistingToken(assetContract, tokenId);
        _;
    }

    function _onlyExistingToken(
        address assetContract,
        uint256 tokenId
    )private view 
    {
        //todo
        if (IERC165(assetContract).supportsInterface(INTERFACE_ID_ERC721)) {
            require(IERC721(assetContract).ownerOf(tokenId) != address(0),
                    "Token Id do not exist"
            );
        } 
        else 
        if (IERC165(assetContract).supportsInterface(INTERFACE_ID_ERC1155)) {
            require(IERC1155(assetContract).balanceOf(_msgSender(), tokenId) != 0,
                    "Token Id do not exist"
            );
        } else {
            revert("invalid or unknown type nft address");
        }
    }

    // Checks Auction Contract is approved to move all NFT of a seller
    // Note that this approval is not specific to 1 token.
    modifier onlyApproved(
        address assetContract,
        address approvedBy
    )
    {
        _onlyApproved(assetContract, approvedBy);
        _;
    }

    function _onlyApproved(
        address assetContract,
        address approvedBy 
    ) private view 
    {
        if (IERC165(assetContract).supportsInterface(INTERFACE_ID_ERC721)) {
            require(IERC721(assetContract).isApprovedForAll(
                    approvedBy,
                    address(this)), 
                    "auction contract not approved to move the token"
            );
        } 
        else 
        if (IERC165(assetContract).supportsInterface(INTERFACE_ID_ERC1155)) {
            require(IERC1155(assetContract).isApprovedForAll(
                    approvedBy,
                    address(this)), 
                    "auction contract not approved to move the token"
            );
        } else {
            revert("invalid or unknown type nft address");
        }
    }
    
    ////////////////////////////////////////////////////////////////////
    /// Private functions related to Validity Checks /////
    ////////////////////////////////////////////////////////////////////

    // Checks auction type is known
    function _onlyAuctionTypes(
        AuctionType method
    )private pure returns(bool)
    {
        return(
            method == AuctionType.HIGHESTBIDDER_SCHEDULED ||
            method == AuctionType.HIGHESTBIDDER_SCHEDULED_MINBID ||
            method == AuctionType.HIGHESTBIDDER_RESERVE ||
            method == AuctionType.HIGHESTBIDDER_RESERVE_WITH_MINBID_CUTOFF
        );
    }

    //  Use when creating auction
    /// @dev currently using the fucntion instead of modifier to prevent "stack too deep" issue
    modifier onlyBidSettings(
        AuctionType method, 
        uint256 minBid, 
        uint256 rsvPricePerToken
    )
    {
       _onlyBidSettings(method, minBid, rsvPricePerToken);
        _;
    }

    //  Checks validaty of bid parameters passed while creating a new auction
    /// @dev todo: Optimize the code size
    function _onlyBidSettings(
        AuctionType method, 
        uint256 minBid, 
        uint256 rsvPricePerToken
    )private view
    {
        
        //todo: should be >0 in both types of auction
        if (method == AuctionType.HIGHESTBIDDER_RESERVE){
            require( minBid > 0, "MinBid is zero" );
            require( rsvPricePerToken > 0, "rsvPricePerToken is zero" );
            require( 
                minBid <= rsvPricePerToken , 
                "MinBid is greater than rsvPricePerToken" 
            );
        }else if (method == AuctionType.HIGHESTBIDDER_RESERVE_WITH_MINBID_CUTOFF){
            require( minBid > 0, "MinBid is zero" );
            require( rsvPricePerToken > 0, "rsvPricePerToken is zero" );
            require( 
                 minBid < (rsvPricePerToken.mul(_minBidCutoff).div(100)), 
                "minimum bid > cutoff % of rsvPricePerToken"
            );
        }else if (method == AuctionType.HIGHESTBIDDER_SCHEDULED_MINBID){
            require( minBid > 0, "MinBid is zero" );
            //ignore reserve price
            require( rsvPricePerToken == 0, "rsvPricePerToken is non zero" );
        }else if (method == AuctionType.HIGHESTBIDDER_SCHEDULED){
            require( minBid == 0, "MinBid is non zero" ); 
            //ignore reserve price
            require( rsvPricePerToken == 0, "rsvPricePerToken is non zero" );
        }
    }

    // Use when updating minBid to check range of minBid 
    // wrt to rsvPricePerToken if reserve price
    // If scheduled auction , ignore reserve price but check newMinBid>0
    modifier onlyMinBidForUpdate( 
        address assetContract, 
        uint256 tokenId,
        uint256 newMinBid
    )
    {
        _onlyMinBidForUpdate(assetContract, tokenId, newMinBid);
        _;
    }

    // use when updating minBid to check range of minBid 
    // wrt to rsvPricePerToken if reserve price
    // if scheduled auction , ignore reserve price but check newMinBid>0
    function _onlyMinBidForUpdate( 
        address assetContract, 
        uint256 tokenId,
        uint256 newMinBid
    )private view
    {
        //todo: should be >0 in both types of auction
        require( newMinBid > 0, "New MinBid is zero" );
        Auction memory auction = _auctions[assetContract][tokenId];

        if (auction.auctionType == AuctionType.HIGHESTBIDDER_RESERVE){
            require( 
                newMinBid <= auction.rsvPricePerToken, 
                "New MinBid is greater than reserve price" 
            );
        }else if (auction.auctionType == AuctionType.HIGHESTBIDDER_RESERVE_WITH_MINBID_CUTOFF){
            require( 
                 newMinBid <= auction.rsvPricePerToken.mul(_minBidCutoff).div(100), 
                "minimum bid > cutoff % of rsvPricePerToken"
            );
        }
    }

    function _onlyReservePriceForUpdate(
        address assetContract, 
        uint256 tokenId, 
        uint256 rsvPricePerToken
    ) private view
    {
        //todo: should be >0 in both types of auction
        require( rsvPricePerToken > 0, "New reserve price is zero" );
        Auction memory auction = _auctions[assetContract][tokenId];

        if (auction.auctionType == AuctionType.HIGHESTBIDDER_RESERVE){
            require( 
                auction.minBid <= rsvPricePerToken, 
                "New MinBid is greater than reserve price" 
            );
        }else if (auction.auctionType == AuctionType.HIGHESTBIDDER_RESERVE_WITH_MINBID_CUTOFF){
            require( 
                auction.minBid <= rsvPricePerToken.mul(_minBidCutoff).div(100), 
                "minimum bid > cutoff % of rsvPricePerToken"
            );
        }
    }

    // use when updating rsvPricePerToken to check range of rsvPricePerToken wrt to minBid
    modifier onlyReservePriceForUpdate(
        address assetContract, 
        uint256 tokenId, 
        uint256 rsvPricePerToken
    )
    {
        _onlyReservePriceForUpdate(assetContract, tokenId, rsvPricePerToken);
        _;
    }

    // Only supports ERC20 tokens 
    // Dont support native coin
    function _onlyEnabledToken(
        address payToken
    )private returns(bool)
    {
        return(
                (_addressRegistry.tokenRegistry() != address(0) &&
                    ITokenRegistry(_addressRegistry.tokenRegistry())
                        .mapped(payToken))
        );
    }

    modifier onlyEnabledToken(
        address payToken
    )
    {
        _onlyEnabledToken(payToken);
        _;
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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC1155.sol)

pragma solidity ^0.8.0;

import "../token/ERC1155/IERC1155.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721Upgradeable.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981Upgradeable is IERC165Upgradeable {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC1155.sol)

pragma solidity ^0.8.0;

import "../token/ERC1155/IERC1155Upgradeable.sol";

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
interface IERC165Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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
library CountersUpgradeable {
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

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
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155Upgradeable is IERC165Upgradeable {
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
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
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
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}