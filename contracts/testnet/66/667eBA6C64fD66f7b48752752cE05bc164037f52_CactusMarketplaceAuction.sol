// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

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
    function marketplace() external view returns (address);

    function tokenRegistry() external view returns (address);
}

interface ITokenRegistry {
    function mapped(address) external view returns (bool);

    function isWhiteListed(address) external view returns (bool);
}

interface IMarketplace {
    function inSale(address, uint256) external view returns (bool);
}

/**
 * @notice contract for NFT auction market
 * @dev This contract is upgradeable
 * @dev Initializable needs to be the first to be derived from
 * @dev currently supports highest Bidder auction: scheduled and reserve auctionsWithId
 * @dev currently supports ERC721 token standard
 * @dev todo: support other tokens like ERC1155
 * @dev todo: contract owner and transfer of ownership
 * @dev state varibles, static variables and internal/private functions start with _
 */
contract CactusMarketplaceAuction is
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeMath for uint256;
    using AddressUpgradeable for address payable;
    using SafeERC20Upgradeable for IERC20;

    event CactusAuctionMarketplaceContractDeployed(
        address payable platformFeeRecipient,
        uint256 platformFeePercent,
        uint256 minBidCutoff,
        uint256 minBidIncrement,
        uint256 bidWithdrawalLockTime
    );

    // event PauseToggled(bool isPaused);

    event AddressRegistryUpdated(address registry);

    ////////////////////////////////////////////////
    /// Events for updateable auction parameters ///
    /// Only settable by seller (auction owner   ///
    /// OR  auction admin/controller aka admin)  ///
    ////////////////////////////////////////////////

    event PlatformFeePercentUpdated(uint256 platformFee);

    event PlatformFeeRecipientUpdated(address payable platformFeeRecipient);

    event MinBidIncrementUpdated(uint256 minBidIncrement);

    event BidWithdrawalLockTimeUpdated(uint256 bidWithdrawalLockTime);

    event auctionsWithIdtartTimeUpdated(
        address indexed assetContract,
        uint256 indexed tokenId,
        uint256 startTime
    );

    event TransferFunds(address _owner, uint _amount);

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

    event auctionsWithIdettled(
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
        HIGHESTBIDDER_SCHEDULED, // have start & end time, minBid=0  |**0
        HIGHESTBIDDER_SCHEDULED_MINBID, // start & end time, minBid>0  |**1
        HIGHESTBIDDER_RESERVE, // start & end time, minBid <= reserveprice  |**2
        HIGHESTBIDDER_RESERVE_WITH_MINBID_CUTOFF // start & end time, minBid <= reserveprice * cutoff/100 |**3
    }

    /// @notice Parameters and info of an auction
    /// @dev These are specific for each Auction
    /// @dev Kept separate from struct HighestBid to reset independently
    struct Auction {
        AuctionType auctionType;
        State inState; // current state auction is in
        address owner; // owner of token ID
        address admin; // controller of auction
        address payToken; // BEP20 Token used to bid for auction
        uint256 minBid; // optional(ie minBid =0) in highestBidder scheduledAuction
        uint256 rsvPricePerToken; // only needed in highestBidder reserverAuction
        uint256 startTime; // when auction starts in UNIX epoch
        uint256 endTime; //when auction starts in UNIX epoch
        uint256 Id; //auction Id
    }

    /// @notice Information about the sender that placed a bid on an auction
    /// @dev Kept separate from Auction struct to reset independently
    struct HighestBid {
        address payable bidder;
        uint256 bid;
        uint256 lastBidTime;
    }

    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 private constant INTERFACE_ID_ERC1155 = 0xd9b67a26;
    mapping(address => mapping(uint256 => Auction)) public auctions;
    mapping(address => mapping(uint256 => HighestBid)) public highestBids;
    mapping(address => mapping(uint256 => bool)) public isOnAuction;
    uint256 public platformFeePercent;
    address payable public platformFeeRecipient;
    uint256 public minBidIncrement;
    uint256 public minBidCutoff;
    uint256 public bidWithdrawalLockTime;
    uint256 public onAuction;
    uint256 public sold;
    bool public isPaused;
    IAddressRegistry public addressRegistry;
    uint256 public auctionCount;
    mapping(uint256 => mapping(address => uint256)) public bids;
    mapping(uint256 => mapping(address => mapping(uint256 => Auction)))
        public auctionsWithId;

    modifier whenNotPaused() {
        require(!isPaused, "contract paused");
        _;
    }

    modifier onlyRoleNotSeller(
        address _assetContract,
        uint256 _tokenId,
        uint256 _auctionNumber
    ) {
        require(
            msg.sender !=
                auctionsWithId[_auctionNumber][_assetContract][_tokenId]
                    .admin &&
                msg.sender !=
                auctionsWithId[_auctionNumber][_assetContract][_tokenId]
                    .owner &&
                msg.sender != IERC721(_assetContract).ownerOf(_tokenId),
            "sender cannot be auction seller/owner"
        );
        _;
    }

    modifier onlyRoleNotContracts() {
        require(msg.sender.code.length > 0 == false, "no contracts permitted");
        _;
    }

    modifier onlyRoleTopBidder(address assetContract, uint256 tokenId) {
        require(
            highestBids[assetContract][tokenId].bidder != address(0) &&
                msg.sender == highestBids[assetContract][tokenId].bidder,
            "you are not the highest bidder"
        );
        _;
    }

    modifier onlyRoleSellerORTopBidder(
        address assetContract,
        uint256 tokenId,
        address _highestBidder,
        uint256 _auctionNumber
    ) {
        require(
            (_highestBidder != address(0) && msg.sender == _highestBidder) ||
                (msg.sender == IERC721(assetContract).ownerOf(tokenId) &&
                    msg.sender ==
                    auctionsWithId[_auctionNumber][assetContract][tokenId]
                        .owner) ||
                msg.sender ==
                auctionsWithId[_auctionNumber][assetContract][tokenId].admin,
            "you are neither the highest bidder nor seller"
        );
        _;
    }

    modifier onlyApproved(address assetContract, address approvedBy) {
        _onlyApproved(assetContract, approvedBy);
        _;
    }

    modifier onlyRoleSeller(
        address assetContract,
        uint256 tokenId,
        uint256 _auctionNumber
    ) {
        require(
            (msg.sender == IERC721(assetContract).ownerOf(tokenId) &&
                msg.sender ==
                auctionsWithId[_auctionNumber][assetContract][tokenId].owner) ||
                msg.sender ==
                auctionsWithId[_auctionNumber][assetContract][tokenId].admin,
            "sender must be token owner or auction admin"
        );
        _;
    }

    // use when updating rsvPricePerToken to check range of rsvPricePerToken wrt to minBid
    modifier onlyReservePriceForUpdate(
        address assetContract,
        uint256 tokenId,
        uint256 rsvPricePerToken,
        uint256 auctionNumber
    ) {
        _onlyReservePriceForUpdate(
            assetContract,
            tokenId,
            rsvPricePerToken,
            auctionNumber
        );
        _;
    }

    modifier onlyMinBidForUpdate(
        address assetContract,
        uint256 tokenId,
        uint256 newMinBid,
        uint256 auctionNumber
    ) {
        _onlyMinBidForUpdate(assetContract, tokenId, newMinBid, auctionNumber);
        _;
    }

    // / @notice Contract initializer used in upgradeable contract inplace of constructor
    // / @dev todo: comment constructor if upgradebale contracts and move intilization to initializer
    // / @param platformFeeRecipient  address of fee/commission reciever
    // / @param platformFeePercent  fee/comission percent
    // / @param minBidCutoff cutoff percent for minimum Bid with respect to reserve price
    // / @param minBidIncrement next bid increment step in wei
    // / @param bidWithdrawalLockTime  time afterwhich bid can be withdrawn post auction end

    function init(
        address payable _platformFeeRecipient,
        uint256 _platformFeePercent,
        uint256 _minBidCutoff,
        uint256 _minBidIncrement,
        uint256 _bidWithdrawalLockTime
    ) public initializer {
        require(
            _platformFeeRecipient != payable(address(0)),
            "Zero address for platformFeeRecipient"
        );
        require(_platformFeePercent > 0, "platform fee less than 0");
        /// @dev todo: Make them constants?
        require(_minBidCutoff > 0 && _minBidCutoff <= 100);
        require(
            _minBidIncrement > 0,
            "Minimum BidIncrement should be greater than 0"
        );
        require(
            _bidWithdrawalLockTime >= 10 && _bidWithdrawalLockTime <= 86400,
            "must be between 1200 to 86400"
        );

        platformFeeRecipient = _platformFeeRecipient;
        platformFeePercent = _platformFeePercent;
        minBidCutoff = _minBidCutoff;
        minBidIncrement = _minBidIncrement;
        bidWithdrawalLockTime = _bidWithdrawalLockTime;

        emit CactusAuctionMarketplaceContractDeployed(
            _platformFeeRecipient,
            _platformFeePercent,
            _minBidCutoff,
            _minBidIncrement,
            _bidWithdrawalLockTime
        );

        __Ownable_init();
        __ReentrancyGuard_init();
    }

    // /**
    //  @notice Create a new auction
    //  @dev  Call approve token before calling createAuction
    //  @dev  Only callable by token owner
    //  @dev  Checks for validity of auction types and the bid settings are added as functions instead of modifiers to prevent "stack too deep" issue
    //  @dev  PayToken is ERC20 Token contract address or 0x0 (for Native coin).
    //  @dev  Some auctionsWithId dont have reserve price
    //  @dev  minBid should be >0 or be a starting bid>=x
    //  @dev  It can be a reserve auction or not
    //  @dev  If reserve auction, then sometimes minBid may be start with rsvPricePerToken
    //  @dev  If not a reserve auction, then ignore rsvPricePerToken
    //  @param assetContract ERC721 nft address. The contract address of the NFTs being listed for sale.
    //  @param tokenId The token ID on the 'assetContract' of the NFTs to list for sale.
    //  @param auctionMethod type of acution
    //  @param startTimestamp scheduled starttime of the auction.The unix timestamp after which NFTs can be bought from the listing.
    //  @param endTimestamp time at which auction ends
    //  @param payTokenContract address 0x0 if native currency else token address if ERC20/BEP20
    //  @param quantity The amount of NFTs of the given 'assetContract' and 'tokenId' to list for sale. For ERC721 NFTs, this is always 1.
    //  @param minimumBid acceptable starting price (aka floor price)
    //  @param rsvPricePerToken bids equal or higherthan rsvPricePerToken is desired by seller.  All bids made to this auction must be at least as great as the reserve price per unit of NFTs auctioned, times the total number of NFTs put up for auction.
    //  @param buyOutPriceperToken optional parameter. If a buyer bids an amount greater than or equal to the buyout price per unit of NFTs auctioned, times the total number of NFTs put up for auction, the auction is considered closed and the buyer wins the auctioned items
    // */

    function createNewNftAuction(
        address _assetContract,
        uint256 _tokenId,
        AuctionType _auctionMethod,
        address _payTokenContract,
        uint256 _startTimestamp,
        uint256 _endTimestamp,
        uint256 _quantity,
        uint256 _minimumBid,
        uint256 _rsvPricePerToken
    ) external returns (uint256 Id) {
        auctionCount++;
        _startTimestamp = _startTimestamp + block.timestamp;
        _endTimestamp = _endTimestamp + _startTimestamp;
        // Only if contract is nonzero valid NFT and tokenId exists
        _onlyNFT(_assetContract, _tokenId, _quantity);
        _onlyExistingToken(_assetContract, _tokenId); //last added

        // Only if token owner then go ahead
        /// @dev: Stack too deeep issue- more number of args in createAuction
        /// @dev: so onlyRoleTokenOwner modifier was changed to internal call
        _onlyRoleTokenOwner(_assetContract, _tokenId);

        // only if all NFTs in the asset contract are preapproved for auction marketplace, then go ahead.
        _onlyApproved(_assetContract, msg.sender);

        // only the auction type is known
        require(_onlyAuctionTypes(_auctionMethod), "unknown auction type");

        // @dev todo: optimize or reduce code logic in onlyBidSettings
        _onlyBidSettings(_auctionMethod, _minimumBid, _rsvPricePerToken);

        // check nft alreadggy in an ongoing auction or listedin marketplace for sale
        require(
            auctionsWithId[auctionCount][_assetContract][_tokenId].endTime == 0,
            "item is already in ongoing auction"
        );

        // Only if item not listed in auction market
        require(
            !IMarketplace(addressRegistry.marketplace()).inSale(
                _assetContract,
                _tokenId
            ),
            "item is already listed in marketplace for sale"
        );

        // validate ranges of start and end time for new auction
        require(
            _startTimestamp > block.timestamp,
            "invalid start time: should be greater than current time"
        );
        require(
            _endTimestamp >= _startTimestamp + 300,
            "end time must be greater than start (by margin(default=5) minutes)"
        );

        require(
            _payTokenContract == address(0) ||
                (addressRegistry.tokenRegistry() != address(0) &&
                    ITokenRegistry(addressRegistry.tokenRegistry()).mapped(
                        _payTokenContract
                    )),
            "pay token invalid or not enabled"
        );

        require(
            (
                ITokenRegistry(addressRegistry.tokenRegistry()).isWhiteListed(
                    _assetContract
                )
            ),
            "NFT contract invalid or not enabled"
        );
        // auction dont exist now
        auctionsWithId[auctionCount][_assetContract][_tokenId].inState = State
            .DONT_EXIST;

        // Setup the auction
        // @dev todo: Currently owner and admin are kept same
        auctionsWithId[auctionCount][_assetContract][_tokenId] = Auction({
            owner: msg.sender,
            admin: msg.sender,
            payToken: _payTokenContract,
            auctionType: _auctionMethod,
            minBid: _minimumBid,
            rsvPricePerToken: _rsvPricePerToken,
            startTime: _startTimestamp,
            endTime: _endTimestamp,
            inState: State.EXISTS,
            Id: auctionCount
        });

        onAuction++;

        // @dev todo: log more info about auction init params?
        emit AuctionCreated(_assetContract, _tokenId, _payTokenContract);

        isOnAuction[_assetContract][_tokenId] = true;
        return auctionsWithId[auctionCount][_assetContract][_tokenId].Id;
    }

    // /**
    //  @notice place bid with BNB and enabled tokens
    //  @dev call approve of the token(eg: citrus token) before calling this function if bidding is in Token
    //  @dev only callable by others except seller(token owner/auction admin) and contracts
    //  @dev seller prevented from placing bid because seller can run up the price, hoping for more profits
    //  @dev only callable during bidding window(between starttime and end time) and when auction exists
    //  @dev Contracts are not permitted to place bids.If a user sent a bid from a contract with a maliciously-crafted fallback function designed
    //       to expend all of the gas provided to it, then that user could never be outbid, because when
    //       someone else tried to place a bid, the EVM would send ETH/BNB/token back to that malicious
    //       fallback function. The transaction would run out of gas, preventing the new user’s bid from being recorded
    //  @dev todo test: if not expected payment mode, then revert the payment.
    //  @param assetContract ERC721 nft address
    //  @param tokenId token Id of nft
    //  @param bidAmount bid amount placed by bidder of nft
    //  @param payToken 0x0 if native coin otherwise token contract address if token
    //  */

    function makeBid(
        address _assetContract,
        uint256 _tokenId,
        uint256 _bidAmount,
        address _payToken,
        uint256 _auctionNumber
    )
        external
        payable
        nonReentrant
        whenNotPaused
        onlyRoleNotSeller(_assetContract, _tokenId, _auctionNumber)
        onlyRoleNotContracts
        returns (bool success)
    {
        Auction storage auction = auctionsWithId[_auctionNumber][
            _assetContract
        ][_tokenId];
        // check auction is in bidding window/open for bids
        // otherwise auction started not yet, endtime is over or got accepted/canceled/ended/settled
        require(
            block.timestamp >= auction.startTime,
            "auction has not started yet"
        );
        require(block.timestamp <= auction.endTime, "aucton endtime is over");

        // Accept bids above starting price and higher than previous bid plus minIncrement
        require(
            _bidAmount >= auction.minBid,
            "bid is less than minBid required"
        );

        require(auction.inState != State.CLOSED, " auction already over");
        require(auction.inState != State.CANCELLED, "Auction Already Ended");

        // check coin or payToken used to bid
        require(
            auction.payToken == _payToken,
            "bid payToken different from token in auction settings"
        );
        require(
            (_payToken == address(0) && msg.value == _bidAmount) ||
                (_payToken != address(0) && msg.value == 0),
            "mismatch in payment mode usage in bidding"
        );

        // If Token used to bid, then transfer bidAmount in payToken to auction contract address
        if (_payToken != address(0)) {
            _transferBid(
                _assetContract,
                _tokenId,
                msg.sender,
                address(this),
                _bidAmount,
                _payToken
            );
        } //else bid placed using Native coin

        auction.inState = State.BIDDEN;
        bids[auction.Id][msg.sender] = bids[auction.Id][msg.sender] + _bidAmount;
        return true;
    }

    // /**
    //  @notice Allows the winner to withdraw the bid after some hours post auction's end
    //  @dev Only callable by the existing top bidder
    //  @dev Only condition needed to check is whether auction has ended and x hours past after end of auction
    //  @dev After winner calls withdrawBid(), CancelAuction() can be called, else auction struture is not cleared
    //  @param assetContract ERC 721 Address
    //  @param tokenId Token ID of the item
    //  */

    function withdrawBid(
        address _assetContract,
        uint256 _tokenId,
        uint256 _auctionNumber
    ) external payable nonReentrant whenNotPaused {
        // To change auction state to withdrew
        Auction storage auction = auctionsWithId[_auctionNumber][
            _assetContract
        ][_tokenId];
        address payToken = auction.payToken;
        uint256 previousBid = bids[auction.Id][msg.sender];
        bids[auction.Id][msg.sender] = 0;

        // Refund the top bidder
        // Refund using native coin or payToken whichever is setup while creating auction.
        require(previousBid > 0, "must be greater than zero");
        _refundBid(
            _assetContract,
            _tokenId,
            payable(msg.sender),
            previousBid,
            payToken
        );

        auction.inState = State.WITHDREW_BID;
        emit BidWithdrawn(_assetContract, _tokenId, msg.sender, previousBid);
    }

    //  /**
    //  @notice Closes an ended auction and exchanges nft&bid between winner and seller
    //  @dev Only seller can call (token owner or auction admin)
    //  @dev Auction can only be closed if there has been a bidder and minBid+increment met
    //  @dev Additional conditions to close the auction can be added as per requirement
    //  @dev Auction needs to be cancelled instead using `cancelAuction()` if no open bids
    //  @param assetContract ERC 721 Address
    //  @param tokenId Token ID of the item
    //  */

    function settleAuction(
        address _assetContract,
        uint256 _tokenId,
        address _highestBidder,
        uint256 _auctionNumber
    ) external onlyApproved(_assetContract, msg.sender) {
        Auction storage auction = auctionsWithId[_auctionNumber][
            _assetContract
        ][_tokenId];

        require(
            (_highestBidder != address(0) && msg.sender == _highestBidder) ||
                (msg.sender == IERC721(_assetContract).ownerOf(_tokenId) &&
                    msg.sender ==
                    auctionsWithId[_auctionNumber][_assetContract][_tokenId]
                        .owner) ||
                msg.sender ==
                auctionsWithId[_auctionNumber][_assetContract][_tokenId].admin,
            "you are neither the highest bidder nor seller"
        );

        // Auction should have ended and still exist
        require(auction.endTime > 0, "no auction exists");
        require(block.timestamp > auction.endTime, "auction has not ended");
        require(auction.inState != State.CLOSED, "auction already closed");

        // condition to decide auction is closeable
        require(_highestBidder != address(0), "no open bids");
        require(
            bids[_auctionNumber][_highestBidder] > auction.minBid,
            "highest bid is below minBid plus increment"
        );

        // Get info on who the highest bidder is
        address winner = _highestBidder;
        uint256 price = bids[_auctionNumber][_highestBidder];
        // Clean up the highest bid
        bids[auction.Id][winner] = 0;

        auction.inState = State.CLOSED;
        _exchange(
            _assetContract,
            _tokenId,
            auction.owner,
            winner,
            price,
            auction.payToken
        );

        onAuction--;
        emit auctionsWithIdettled(
            msg.sender,
            _assetContract,
            _tokenId,
            winner,
            auction.payToken,
            price
        );
        sold++;
        isOnAuction[_assetContract][_tokenId] = false;
    }

    //  /**
    //  @notice To cancel unsettled existing/ongoing auctionsWithId
    //  @notice Returning the funds to the top bidder if found
    //  @dev Only token owner can call
    //  @dev Call CancelAuction if there are no open Bids after auction ended
    //  @dev If buyer withdraws Bid, then also there will be no outstanding bids, then also cancelAuction should work.
    //  @param assetContract ERC 721 Address
    //  @param tokenId Token ID of the NFT
    //  */

    function withdrawAuction(
        address _assetContract,
        uint256 _tokenId,
        uint256 _auctionNumber
    )
        external
        nonReentrant
        onlyRoleSeller(_assetContract, _tokenId, _auctionNumber)
    {
        // check auction exists(ongoing and not canceled or not closed)
        Auction storage auction = auctionsWithId[_auctionNumber][
            _assetContract
        ][_tokenId];
        require(auction.endTime > 0, "no auction exists");
        require(auction.inState != State.CLOSED, "auction already closed");

        auction.inState = State.CANCELLED;
        // Remove this specfic auction
        // delete auctionsWithId[_assetContract][_tokenId];
        onAuction--;
        emit AuctionCancelled(_assetContract, _tokenId);
        isOnAuction[_assetContract][_tokenId] = false;
    }

    // /**
    //  @notice Before auction end time is over, Seller can end the auction by accepting the current highest bid, and swap NFT with highestBidder
    //  @dev Only callable by seller(Token owner or auction admin)
    //  @dev todo: UX to add accept button to UI for this.
    //  @dev Auction should be ongoing/existing (not ended , not {accepted/closed/canceled}) and have a valid open bid
    //  @param assetContract ERC 721 Address
    //  @param tokenId Token ID of the item
    //  */

    function takeHighestBid(
        address _assetContract,
        uint256 _tokenId,
        address _highestBidder,
        uint256 _auctionNumber
    )
        external
        onlyRoleSeller(_assetContract, _tokenId, _auctionNumber)
        onlyApproved(_assetContract, msg.sender)
    {
        Auction storage auction = auctionsWithId[_auctionNumber][
            _assetContract
        ][_tokenId];

        // To accept a bid, auction end time should not have reached
        require(block.timestamp < auction.endTime, "aucton endtime is over");
        require(auction.inState != State.ACCEPTED, "Bid already accepted");

        // Only if atleast one bid
        require(_highestBidder != address(0), "no open bids");
        // Additional check to flag the bid as ACCEPTABLE
        require(
            bids[_auctionNumber][_highestBidder] > auction.minBid,
            "highest bid is below minBid plus minIncrement"
        );

        // Get info on who the highest bidder is
        address winner = _highestBidder;
        uint256 price = bids[_auctionNumber][_highestBidder];

        bids[auction.Id][winner] = 0;
        // Clean up the highest bid

        auction.inState = State.ACCEPTED;
        _exchange(
            _assetContract,
            _tokenId,
            auction.owner,
            winner,
            price,
            auction.payToken
        );
        onAuction--;

        emit AuctionHighestBidAccepted(
            msg.sender,
            _assetContract,
            _tokenId,
            _highestBidder,
            auction.payToken,
            price
        );

        // Remove specific auction
        // delete auctionsWithId[_assetContract][_tokenId];
        sold++;
    }

    // Only NFT address

    function _onlyNFT(
        address _assetContract,
        uint256 _tokenId,
        uint256 _quantity
    ) private view {
        _onlyNotZero(_assetContract);

        if (IERC165(_assetContract).supportsInterface(INTERFACE_ID_ERC721)) {
            require(_quantity == 1, "These NFTs are unique");
        } else if (
            IERC165(_assetContract).supportsInterface(INTERFACE_ID_ERC1155)
        ) {
            require(
                IERC1155(_assetContract).balanceOf(msg.sender, _tokenId) >=
                    _quantity,
                "sender must hold enough nfts"
            );
        } else {
            revert("invalid or unknown type nft address");
        }
    }

    function _onlyNotZero(address _assetContract) private pure {
        require(_assetContract != address(0), "zero address");
    }

    function _onlyExistingToken(address _assetContract, uint256 _tokenId)
        private
        view
    {
        //todo
        if (IERC165(_assetContract).supportsInterface(INTERFACE_ID_ERC721)) {
            require(
                IERC721(_assetContract).ownerOf(_tokenId) != address(0),
                "Token Id do not exist"
            );
        } else if (
            IERC165(_assetContract).supportsInterface(INTERFACE_ID_ERC1155)
        ) {
            require(
                IERC1155(_assetContract).balanceOf(msg.sender, _tokenId) != 0,
                "Token Id do not exist"
            );
        } else {
            revert("invalid or unknown type nft address");
        }
    }

    function _onlyRoleTokenOwner(address _assetContract, uint256 _tokenId)
        private
        view
    {
        if (IERC165(_assetContract).supportsInterface(INTERFACE_ID_ERC721)) {
            require(
                msg.sender == IERC721(_assetContract).ownerOf(_tokenId),
                "sender must be item owner"
            );
        } else if (
            IERC165(_assetContract).supportsInterface(INTERFACE_ID_ERC1155)
        ) {
            require(
                IERC1155(_assetContract).balanceOf(msg.sender, _tokenId) != 0,
                "owner must hold enough nfts"
            );
        } else {
            revert("invalid or unknown type nft address");
        }
    }

    function _onlyApproved(address _assetContract, address _approvedBy)
        private
        view
    {
        if (IERC165(_assetContract).supportsInterface(INTERFACE_ID_ERC721)) {
            require(
                IERC721(_assetContract).isApprovedForAll(
                    _approvedBy,
                    address(this)
                ),
                "auction contract not approved to move the token"
            );
        } else if (
            IERC165(_assetContract).supportsInterface(INTERFACE_ID_ERC1155)
        ) {
            require(
                IERC1155(_assetContract).isApprovedForAll(
                    _approvedBy,
                    address(this)
                ),
                "auction contract not approved to move the token"
            );
        } else {
            revert("invalid or unknown type nft address");
        }
    }

    function _onlyBidSettings(
        AuctionType _method,
        uint256 _minBid,
        uint256 _rsvPricePerToken
    ) private view {
        //todo: should be >0 in both types of auction

        if (_method == AuctionType.HIGHESTBIDDER_RESERVE) {
            require(_minBid > 0, "MinBid is zero");
            require(_rsvPricePerToken > 0, "rsvPricePerToken is zero");
            require(
                _minBid <= _rsvPricePerToken,
                "MinBid is greater than rsvPricePerToken"
            );
        } else if (
            _method == AuctionType.HIGHESTBIDDER_RESERVE_WITH_MINBID_CUTOFF
        ) {
            require(_minBid > 0, "MinBid is zero");
            require(_rsvPricePerToken > 0, "rsvPricePerToken is zero");
            require(
                _minBid < (_rsvPricePerToken.mul(minBidCutoff).div(100)),
                "minimum bid > cutoff % of rsvPricePerToken"
            );
        } else if (_method == AuctionType.HIGHESTBIDDER_SCHEDULED_MINBID) {
            require(_minBid > 0, "MinBid is zero");
            //ignore reserve price
            require(_rsvPricePerToken == 0, "rsvPricePerToken is non zero");
        } else if (_method == AuctionType.HIGHESTBIDDER_SCHEDULED) {
            require(_minBid == 0, "MinBid is non zero");
            //ignore reserve price
            require(_rsvPricePerToken == 0, "rsvPricePerToken is non zero");
        }
    }

    function _onlyAuctionTypes(AuctionType _method)
        private
        pure
        returns (bool)
    {
        return (_method == AuctionType.HIGHESTBIDDER_SCHEDULED ||
            _method == AuctionType.HIGHESTBIDDER_SCHEDULED_MINBID ||
            _method == AuctionType.HIGHESTBIDDER_RESERVE ||
            _method == AuctionType.HIGHESTBIDDER_RESERVE_WITH_MINBID_CUTOFF);
    }

    // /**
    //  @notice Update AddressRegistry contract
    //  @dev Only admin (Auction contract owner)
    //  */

    function updateAddressRegistry(address registry) external onlyOwner {
        addressRegistry = IAddressRegistry(registry);
        emit AddressRegistryUpdated(registry);
    }

    // /**
    //  @notice Internal function to move bid in token to other address(here auction contract) address
    //  @dev Assumes all params are prevalidated by the caller before invoking this function
    //  @param assetContract ERC 721 Address
    //  @param tokenId Token ID of the NFT
    //  @param from sender address
    //  @param to contract address
    //  @param bidAmount bid amount placed by bidder or sender
    //  @param payToken token used for paying
    //  */

    function _transferBid(
        address _assetContract,
        uint256 tokenId,
        address from,
        address to,
        uint256 bidAmount,
        address payToken
    ) private {
        IERC20 payTokenAddr = IERC20(payToken);
        // This contract (market contract) moves money owned by "from" address
        // So transferFrom call is required (Need approval which need to be previously given to market contract by the buyer)
        require(
            payTokenAddr.transferFrom(from, to, bidAmount),
            "Insufficient balance or not approved"
        );
        emit BidTransferred(
            _assetContract,
            tokenId,
            from,
            to,
            bidAmount,
            payToken
        );
    }

    // /**
    //  @notice Internal function to refunds bid amount to current highest bidder if there is a outbid or auction gets cancelled
    //  @dev Assumes all params are prevalidated by the caller before invoking this function
    //  @dev similar to _payout() internal method but purpose is different, ie refund
    //  @param assetContract ERC 721 Address
    //  @param tokenId Token ID of the NFT
    //  @param to recpient/bidders address
    //  @param amount bid amount placed by bidder or sender to refund
    //  @param payToken token used for paying
    //  */

    function _refundBid(
        address _assetContract,
        uint256 _tokenId,
        address payable _to,
        uint256 _amount,
        address _payToken
    ) private {
        if (_payToken == address(0)) {
            // refund previous best (if bid exists)
            (bool successRefund, ) = _to.call{value: _amount}("");
            require(successRefund, "failed to refund previous bidder");
        } else {
            IERC20 payTokenAddr = IERC20(_payToken);
            require(
                payTokenAddr.transfer(_to, _amount),
                "failed to refund previous bidder"
            );
        }
        emit BidRefunded(_assetContract, _tokenId, _to, _amount);
    }

    // /**
    //  @notice Internal function to do the exchange of nft and  highestbid amount
    //  @dev Assumes all params are prevalidated by the caller before invoking this function
    //  @dev sets state, clears specific auction, makes auction stop to exist
    //  @param assetContract ERC 721 Address
    //  @param tokenId Token ID of the NFT
    //  @param owner address of the NFT owner
    //  @param winner address of highest bidder
    //  @param price price of the item or highestbid
    //  @param payToken paying Token
    //  */

    function _exchange(
        address _assetContract,
        uint256 _tokenId,
        address _owner,
        address _winner,
        uint256 _price,
        address _payToken
    ) private {
        /* do mutual trasnsfer */
        // Transfer winning bid as split payments
        // to platformfeerecipient,seller,royaltyrecipient
        // Reverts if needed
        // Marketplace fee calculation
        uint256 platformFee = _price.mul(platformFeePercent).div(100);

        // Checking royalties
        // todo: check nft is ERC2981 compatible or not before calling
        (address royaltyRecipient, uint256 royaltyAmount) = IERC2981(
            _assetContract
        ).royaltyInfo(_tokenId, _price.sub(platformFee));

        // Seller Amount
        uint256 toSellerAmount = _price.sub(platformFee);
        toSellerAmount = toSellerAmount.sub(royaltyAmount);

        // make split payouts
        require(
            _payout(
                _assetContract,
                _tokenId,
                _price,
                platformFeeRecipient,
                platformFee,
                _payToken
            ),
            "platform fee transfer failed"
        );
        require(
            _payout(
                _assetContract,
                _tokenId,
                _price,
                payable(royaltyRecipient),
                royaltyAmount,
                _payToken
            ),
            "royalty transfer failed"
        );
        require(
            _payout(
                _assetContract,
                _tokenId,
                _price,
                payable(_owner),
                toSellerAmount,
                _payToken
            ),
            "seller amount transfer failed"
        );
        IERC721(_assetContract).transferFrom(_owner, _winner, _tokenId);
    }

    // /**
    //  @notice Internal function to payout the royalty, platform fee and sale amount
    //  @dev Assumes all params are prevalidated by the caller before invoking this function
    //  @dev similar to _refundBid() internal method but purpose is different, ie to pay
    //  @param assetContract ERC 721 Address
    //  @param tokenId Token ID of the NFT
    //  @param price winning bid amount
    //  @param recipient address of the party recieving split payment
    //  @param amount split amount to be paid to the recipient
    //  @param payToken token used for paying
    //  */

    function _payout(
        address _assetContract,
        uint256 _tokenId,
        uint256 _price,
        address payable _recipient,
        uint256 _amount,
        address _payToken
    ) private returns (bool) {
        bool transferSuccess = false;

        if (_recipient != address(0)) {
            if (_payToken == address(0)) {
                (transferSuccess, ) = payable(_recipient).call{value: _amount}(
                    ""
                );
            } else {
                // Moves token from and owned by market contract to recipient
                // since the token is owned by market contract, transfer call is enough(transferFrom call is not required)
                transferSuccess = IERC20(_payToken).transfer(
                    _recipient,
                    _amount
                );
            }
        }

        emit PaidOut(
            _assetContract,
            _tokenId,
            _payToken,
            _price,
            payable(_recipient),
            _amount,
            transferSuccess
        );
        return transferSuccess;
    }

    function balanceOf() public view returns (uint) {
        return address(this).balance;
    }

    // /**
    //  @notice get all info about the highest bidder
    //  @dev return a struct
    //  @param assetContract ERC 721 Address
    //  @param tokenId Token ID of the NFT
    //  */
    function getAuctionHighestBid(address _assetContract, uint256 _tokenId)
        external
        view
        returns (
            address payable bidder,
            uint256 bid,
            uint256 lastBidTime
        )
    {
        return (
            highestBids[_assetContract][_tokenId].bidder,
            highestBids[_assetContract][_tokenId].bid,
            highestBids[_assetContract][_tokenId].lastBidTime
        );
    }

    //  /**
    //  @notice get all info about the auction
    //  @param assetContract ERC 721 Address
    //  @param tokenId Token ID of the NFT
    //  */
    function getAuctionInfo(
        address _assetContract,
        uint256 _tokenId,
        uint256 _auctionNumber
    )
        external
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
        Auction storage auction = auctionsWithId[_auctionNumber][
            _assetContract
        ][_tokenId];
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

    // /**
    //  @notice Update the current end time for an auction
    //  @dev Only Seller (token owner or auction admin)
    //  @dev Auction must exist
    //  @param assetContract ERC 721 Address
    //  @param tokenId Token ID of the NFT
    //  @param endTimestamp New end time (unix epoch in seconds)
    //  */
    function updateAuctionEndTime(
        address _assetContract,
        uint256 _tokenId,
        uint256 _endTimestamp,
        uint256 _auctionNumber
    ) external onlyRoleSeller(_assetContract, _tokenId, _auctionNumber) {
        Auction storage auction = auctionsWithId[_auctionNumber][
            _assetContract
        ][_tokenId];
        // only existing auction
        require(auction.endTime > 0, "no auction exists");
        // Auction end time is not over
        require(block.timestamp <= auction.endTime, "auction has ended");
        // New endtime should be in future
        require(
            auction.startTime < _endTimestamp,
            "end time must be greater than start"
        );
        // New endtime need to be atleast 5 minutes apart from current time
        require(
            _endTimestamp >= block.timestamp + 300,
            "end time must be greater than now by (margin(default=5) minutes)"
        );

        auction.endTime = _endTimestamp;
        emit AuctionEndTimeUpdated(_assetContract, _tokenId, _endTimestamp);
    }

    // /**
    //  @notice Update the current start time for an auction
    //  @dev Only Seller (token owner or auction admin)
    //  @dev Auction must exist
    //  @param assetContract ERC 721 Address
    //  @param tokenId Token ID of the NFT
    //  @param startTime New start time (unix epoch in seconds)
    //  */
    function updateauctionsWithIdtartTime(
        address _assetContract,
        uint256 _tokenId,
        uint256 _startTime,
        uint256 _auctionNumber
    ) external onlyRoleSeller(_assetContract, _tokenId, _auctionNumber) {
        Auction storage auction = auctionsWithId[_auctionNumber][
            _assetContract
        ][_tokenId];
        // only existing auction
        require(auction.endTime > 0, "no auction exists");
        require(_startTime > 0, "invalid start time");
        //only if auction not already started
        require(
            auction.startTime + 60 > block.timestamp,
            "auction already started"
        );
        //New starting time should be less than endTime by atleast 5 minutes
        require(
            _startTime + 300 < auction.endTime,
            "start time should be less than end time (by margin=5 minutes)"
        );
        auction.startTime = _startTime;
        emit auctionsWithIdtartTimeUpdated(
            _assetContract,
            _tokenId,
            _startTime
        );
    }

    // /**
    //  * @notice Update ReservePrice
    //  * @dev Only Seller (token owner or auction admin) can call
    //  * @param assetContract ERC721 nft address
    //  * @param tokenId Token Id of the nft/item
    //  * @param newReservePrice New Reserve Price
    //  * @param payToken Intended payToken
    //  */
    function updateAuctionReservePrice(
        address _assetContract,
        uint256 _tokenId,
        uint256 _newReservePrice,
        address _payToken,
        uint256 _auctionNumber
    )
        external
        onlyRoleSeller(_assetContract, _tokenId, _auctionNumber)
        onlyReservePriceForUpdate(
            _assetContract,
            _tokenId,
            _newReservePrice,
            _auctionNumber
        )
    {
        Auction storage auction = auctionsWithId[_auctionNumber][
            _assetContract
        ][_tokenId];
        require(auction.endTime > 0, "no auction exists");
        require(auction.inState != State.CLOSED, "auction already settled");
        require(
            auction.payToken == _payToken,
            "bid payToken different from token in auction settings"
        );
        auction.rsvPricePerToken = _newReservePrice;
        emit AuctionReservePriceUpdated(
            _assetContract,
            _tokenId,
            _payToken,
            _newReservePrice
        );
    }

    // /**
    //  @notice Update the payToken used in bidding for an auction
    //  @dev Only Seller (token owner or auction admin)
    //  @dev Auction must exist
    //  @param assetContract ERC 721 Address
    //  @param tokenId Token ID of the NFT
    //  @param newPayToken New paying token
    //  */

    function updateAuctionPayToken(
        address _assetContract,
        uint256 _tokenId,
        address _newPayToken,
        uint256 _auctionNumber
    ) external onlyRoleSeller(_assetContract, _tokenId, _auctionNumber) {
        Auction storage auction = auctionsWithId[_auctionNumber][
            _assetContract
        ][_tokenId];

        // only if auction is ongoing and no open bids and have not ended
        require(auction.endTime > 0, "no auction exists");
        require(
            highestBids[_assetContract][_tokenId].bidder == address(0),
            "auction has open bids"
        );
        require(block.timestamp < auction.endTime, "auction has ended");

        // only if the paying Token belongs to tokens whitelisted
        require(
            _newPayToken == address(0) ||
                (addressRegistry.tokenRegistry() != address(0) &&
                    ITokenRegistry(addressRegistry.tokenRegistry()).mapped(
                        _newPayToken
                    )),
            "new pay token invalid or not enabled"
        );

        // only if the new token is different from current token
        require(
            auction.payToken != _newPayToken,
            "bid payToken same as token in auction settings"
        );

        address previousPayToken = auction.payToken;
        auction.payToken = _newPayToken;
        emit AuctionPayTokenUpdated(
            _assetContract,
            _tokenId,
            previousPayToken,
            _newPayToken
        );
    }

    // /**
    //  * @notice Update MinimumBid
    //  * @dev Only Seller (token owner or auction admin) can call
    //  * @dev As long as auction is there(and not ended) and Till first bid happens(BIDDEN), can change MinBid
    //  * @dev onlyMinBidForUpdate( if mindBid setting was 10, then bid was 11, then 12,
    //  * @dev then newminBid cannot be 15  )
    //  * @dev making newminBid of 9 dont make sense as hghhestBid is now already 12
    //  * @param assetContract ERC721 nft address
    //  * @param tokenId token Id of the nft/item
    //  * @param newMinBid new Min Bid
    //  * @param payToken intended payToken
    //  */

    function updateMinimumPrice(
        address _assetContract,
        uint256 _tokenId,
        uint256 _newMinBid,
        address _payToken,
        uint256 _auctionNumber
    )
        external
        onlyRoleSeller(_assetContract, _tokenId, _auctionNumber)
        onlyMinBidForUpdate(
            _assetContract,
            _tokenId,
            _newMinBid,
            _auctionNumber
        )
    {
        Auction storage auction = auctionsWithId[_auctionNumber][
            _assetContract
        ][_tokenId];
        require(auction.endTime > 0, "no auction exists");
        require(block.timestamp <= auction.endTime, "auction has ended");
        require(
            highestBids[_assetContract][_tokenId].bidder == address(0),
            "auction has open bids"
        );
        require(
            auction.payToken == _payToken,
            "bid payToken different from token in auction settings"
        );
        auction.minBid = _newMinBid;
        emit AuctionMinBidUpdated(
            _assetContract,
            _tokenId,
            _payToken,
            _newMinBid
        );
    }

    // /**
    //  * @notice claim ERC20 Compatible tokens
    //  * @dev can change state: balance of auction smart contract
    //  * @dev Only owner of contract (contract admin, admin panel) allowed to claim
    //  * @dev todo: test the EnabledToken,  check admin can withdraw bids placed during bidding??
    //  * @param payToken The address of the token contract
    //  */
    function reclaimPayToken(address _payToken) external onlyOwner {
        require(_payToken != address(0), "Invalid address");
        //require(onlyEnabledToken(payToken), "pay token invalid or not enabled");
        IERC20 token = IERC20(_payToken);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(msg.sender, balance), "Transfer failed");
    }

    /**
     * @notice claim ERC20 Compatible tokens
     * @dev can change state: balance of auction smart contract
     * @dev Only owner of contract (contract admin, admin panel) allowed to claim
     * @dev todo: check admin can withdraw bids placed during bidding??
     */
    function reclaimBNB() external onlyOwner {
        uint256 balance = address(this).balance;
        (bool successRefund, ) = msg.sender.call{value: balance}("");
        require(successRefund, "Transfer failed");
    }

    //  /**
    //  @notice for updating platform fee/commission fee
    //  @dev Only admin (Auction contract owner)
    //  @param platformFeePercent uint256 the platform fee to set
    //  */
    function updatePlatformFeePercent(uint256 _platformFeePercent)
        external
        onlyOwner
    {
        platformFeePercent = _platformFeePercent;
        emit PlatformFeePercentUpdated(_platformFeePercent);
    }

    // /**
    //  @notice for updating platform fee recipient address
    //  @dev Only admin (Auction contract owner)
    //  @param platformFeeRecipient payable address the address to sends the funds to
    //  */
    function updatePlatformFeeRecipient(address payable _platformFeeRecipient)
        external
        onlyOwner
    {
        require(_platformFeeRecipient != address(0), "zero address");
        platformFeeRecipient = _platformFeeRecipient;
        emit PlatformFeeRecipientUpdated(_platformFeeRecipient);
    }

    // /**
    //  @notice Bid amount increment across all auctionsWithId
    //  @dev Only admin (Auction contract owner)
    //  @param minBidIncrement New bid step in WEI
    //  */
    function updateMinBidIncrement(uint256 _minBidIncrement)
        external
        onlyOwner
    {
        minBidIncrement = _minBidIncrement;
        emit MinBidIncrementUpdated(_minBidIncrement);
    }

    // /**
    //  @notice Update the global bid withdrawal lockout time
    //  @dev Only admin (Auction contract owner)
    //  @param bidWithdrawalLockTime New bid withdrawal lock time
    //  */
    function updateBidWithdrawalLockTime(uint256 _bidWithdrawalLockTime)
        external
        onlyOwner
    {
        bidWithdrawalLockTime = _bidWithdrawalLockTime;
        emit BidWithdrawalLockTimeUpdated(_bidWithdrawalLockTime);
    }

    function _onlyReservePriceForUpdate(
        address _assetContract,
        uint256 _tokenId,
        uint256 _rsvPricePerToken,
        uint256 _auctionNumber
    ) private view {
        //todo: should be >0 in both types of auction
        require(_rsvPricePerToken > 0, "New reserve price is zero");
        Auction memory auction = auctionsWithId[_auctionNumber][_assetContract][
            _tokenId
        ];

        if (auction.auctionType == AuctionType.HIGHESTBIDDER_RESERVE) {
            require(
                auction.minBid <= _rsvPricePerToken,
                "New MinBid is greater than reserve price"
            );
        } else if (
            auction.auctionType ==
            AuctionType.HIGHESTBIDDER_RESERVE_WITH_MINBID_CUTOFF
        ) {
            require(
                auction.minBid <= _rsvPricePerToken.mul(minBidCutoff).div(100),
                "minimum bid > cutoff % of rsvPricePerToken"
            );
        }
    }

    // use when updating minBid to check range of minBid
    // wrt to rsvPricePerToken if reserve price
    // if scheduled auction , ignore reserve price but check newMinBid>0
    function _onlyMinBidForUpdate(
        address _assetContract,
        uint256 _tokenId,
        uint256 _newMinBid,
        uint256 _auctionNumber
    ) private view {
        //todo: should be >0 in both types of auction
        require(_newMinBid > 0, "New MinBid is zero");
        Auction memory auction = auctionsWithId[_auctionNumber][_assetContract][
            _tokenId
        ];

        if (auction.auctionType == AuctionType.HIGHESTBIDDER_RESERVE) {
            require(
                _newMinBid <= auction.rsvPricePerToken,
                "New MinBid is greater than reserve price"
            );
        } else if (
            auction.auctionType ==
            AuctionType.HIGHESTBIDDER_RESERVE_WITH_MINBID_CUTOFF
        ) {
            require(
                _newMinBid <=
                    auction.rsvPricePerToken.mul(minBidCutoff).div(100),
                "minimum bid > cutoff % of rsvPricePerToken"
            );
        }
    }

    receive() external payable {
        emit TransferFunds(msg.sender, msg.value);
    }

    function inAuction(address _assetContract, uint _tokenId)
        external
        view
        returns (bool)
    {
        return isOnAuction[_assetContract][_tokenId];
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721Upgradeable.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC1155.sol)

pragma solidity ^0.8.0;

import "../token/ERC1155/IERC1155Upgradeable.sol";

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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC1155.sol)

pragma solidity ^0.8.0;

import "../token/ERC1155/IERC1155.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

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
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
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
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
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
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/draft-IERC20PermitUpgradeable.sol";
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

    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}