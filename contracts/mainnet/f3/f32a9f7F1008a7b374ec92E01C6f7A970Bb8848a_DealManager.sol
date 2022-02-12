// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IFeedLoan.sol";
import "./interfaces/IVaultController.sol";

contract DealManager is AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    /*****************************
     ** Constants and Vairables **
     *****************************/

    /// @dev Access Roles
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    /// @dev Total number of offers
    uint256 public totalOffersCount;

    /// @dev Total number of active offers
    uint256 public totalActiveOffers;

    /// @dev An address of FeedLoan
    address public feedLoan;

    /// @dev An address of VaultController
    address public vaultController;

    /// @dev Minimum loan duration
    uint256 public minDuration = 0;

    /// @dev Minimum interest rate basis points
    uint256 public minIntRateBP = 0;

    /*********************
     ** Modifiers **
     *********************/

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Forbidden: only admin is allowed");
        _;
    }

    modifier onlyManager() {
        require(hasRole(MANAGER_ROLE, msg.sender), "Forbidden: only manager is allowed");
        _;
    }

    /*********************
     ** Structs & Enums **
     *********************/

    enum OfferStatus {
        Pending,
        Closed,
        Canceled
    }

    struct Offer {
        uint256 id;
        OfferStatus status;
        address maker;
        address taker;
        address collateral;
        uint256 collateralAmount;
        bool useVault;
        uint256 vaultId;
        uint256 bidId;
        uint256 loanId;
    }

    struct OfferAskInfo {
        string askTitle;
        string askDescription;
        uint256 askIntRateBP;
        uint256 askDuration;
        uint256 askCollateralRatio;
    }

    enum OfferBidStatus {
        Open,
        Canceled,
        Accepted
    }

    struct OfferBidInfo {
        uint256 id;
        address account;
        OfferBidStatus status;
        address asset;
        uint256 amount;
        uint256 duration;
        uint256 intRateBP;
        bool intProRated;
        bool allowLiquidator;
        uint256 updatedAt;
    }

    /****************
     ** Enumerable **
     ****************/

    EnumerableSet.AddressSet whitelistedCollaterals;
    EnumerableSet.AddressSet whitelistedAssets;

    /*************
     ** Mapping **
     *************/

    /// @dev mapping collateral address with offer id
    mapping(address => uint256[]) public collateralOffers;

    /// @dev mapping offer id with offer
    mapping(uint256 => Offer) public offers;

    /// @dev mapping offer id -> bids
    mapping(uint256 => OfferBidInfo[]) public offerBids;

    /// @dev mapping offer id -> ask infos
    mapping(uint256 => OfferAskInfo) public offerAskInfos;

    /// @dev mapping offer id -> preferred assets
    mapping(uint256 => address[]) public offerPreferredAssets;

    /// @dev mapping bidder address -> offer id -> bid ids
    mapping(address => mapping(uint256 => uint256[])) public bidderBids;

    /// @dev mapping offer id with bidders address
    mapping(uint256 => EnumerableSet.AddressSet) private offerBidders;

    /// @dev mapping bidder address with offer ids
    mapping(address => uint256[]) private bidderOffers;

    /// @dev mapping offer id with bids count
    mapping(uint256 => uint256) public offerBidsCount;

    /// @dev mapping offer id with active  count
    mapping(uint256 => uint256) public offerActiveBidsCount;

    /// @dev mapping offer id -> bidder address -> bids count
    mapping(uint256 => mapping(address => uint256)) public bidderBidsCount;

    /// @dev mapping offer id -> bidder address -> active bids count
    mapping(uint256 => mapping(address => uint256)) public bidderActiveBidsCount;

    /************
     ** Events **
     ************/

    event OfferCreated(
        uint256 indexed _id,
        address indexed _maker,
        address indexed _collateral,
        uint256 _collateralAmount,
        bool _useVault,
        uint256 _vaultId
    );
    event OfferAskInfoUpdated(
        uint256 indexed _id,
        string _askTitle,
        string _askDescription,
        uint256 _askIntRateBP,
        uint256 _askDuration,
        uint256 _askCollateralRatio
    );
    event OfferPreferredAssetsUpdated(uint256 indexed _id, address[] _preferredAssets);
    event OfferCanceled(uint256 _offerId);
    event OfferBidCreated(
        address indexed _account,
        uint256 indexed _offerId,
        address indexed _asset,
        uint256 _amount,
        uint256 _duration,
        uint256 _intRateBP,
        bool _intProRated,
        bool _allowLiquidator
    );
    event OfferBidAccepted(uint256 indexed _offerId, uint256 indexed _bidId);
    event OfferBidCanceled(uint256 indexed _offerId, uint256 indexed _bidId);
    event OfferBidSet(uint256 indexed _offerId, uint256 indexed _bidId, uint256 indexed _direction, uint256 _amount, uint256 _diff);
    event OfferBidInfoSet(
        uint256 indexed _offerId,
        uint256 indexed _bidId,
        uint256 _duration,
        uint256 _intRateBP,
        bool _intProRated,
        bool _allowLiquidator
    );

    event MinDurationChanged(uint256 _duration);
    event MinIntRateBPChanged(uint256 _intRateBP);
    event FeedLoanChanged(address _feedLoan);
    event VaultControllerChanged(address _vaultController);
    event ManagerChanged(address _manager);
    event CollateralAdded(address _collateral);
    event CollateralRemoved(address _collateral);
    event AssetAdded(address _asset);
    event AssetRemoved(address _asset);

    /**
     * @dev Constructor
     */
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setupRole(MANAGER_ROLE, msg.sender);
        _setRoleAdmin(MANAGER_ROLE, ADMIN_ROLE);
    }

    /*********************
     ** Functions **
     *********************/

    /**
     * @notice Create offer
     * @param _collateral: An address of collateral
     * @param _collateralAmount: Amount of collateral
     * @param _useVault: Enable earn with collateral
     * @param _vaultId: Vault ID to deposit
     * @param _askTitle: Ask title
     * @param _askDescription: Ask description
     * @param _askIntRateBP: Ask interest rate basis point
     * @param _askDuration: Ask duration
     * @param _askCollateralRatio: Ask collateral ratio
     * @param _preferredAssets: Preferred assets
     */
    function createOffer(
        address _collateral,
        uint256 _collateralAmount,
        bool _useVault,
        uint256 _vaultId,
        string memory _askTitle,
        string memory _askDescription,
        uint256 _askIntRateBP,
        uint256 _askDuration,
        uint256 _askCollateralRatio,
        address[] memory _preferredAssets
    ) external nonReentrant {
        require(whitelistedCollaterals.contains(_collateral), "CreateOffer: collateral is not allowed");

        if (_useVault) {
            (address _token, ) = IVaultController(vaultController).vaultInfo(_vaultId);
            require(_collateral == _token, "CreateOffer: vault token mismatch");
        }

        // Collateral balance before transfer
        uint256 _before = IERC20(_collateral).balanceOf(address(this));

        // Transfer collateral to contract
        IERC20(_collateral).safeTransferFrom(address(msg.sender), address(this), _collateralAmount);

        // Deflationary tokens check
        _collateralAmount = IERC20(_collateral).balanceOf(address(this)).sub(_before);

        uint256 _offerId = totalOffersCount;
        Offer memory _offer = Offer({
            id: _offerId,
            status: OfferStatus.Pending,
            maker: address(msg.sender),
            taker: address(0),
            collateral: _collateral,
            collateralAmount: _collateralAmount,
            useVault: _useVault,
            vaultId: _vaultId,
            bidId: 0,
            loanId: 0
        });
        totalOffersCount = totalOffersCount.add(1);
        totalActiveOffers = totalActiveOffers.add(1);
        collateralOffers[_collateral].push(_offerId);

        // Set offer's ask information
        offerAskInfos[_offerId] = OfferAskInfo({
            askTitle: _askTitle,
            askDescription: _askDescription,
            askIntRateBP: _askIntRateBP,
            askDuration: _askDuration,
            askCollateralRatio: _askCollateralRatio
        });

        // Set preferred assets
        offerPreferredAssets[_offerId] = _preferredAssets;

        // Add offer to storage before moving collateral
        offers[_offerId] = _offer;

        // Emit OfferCreated event
        emit OfferCreated(_offerId, address(msg.sender), _collateral, _collateralAmount, _useVault, _vaultId);
    }

    /**
     * @notice Update Offer Ask Info
     * @param _offerId: Offer ID
     * @param _askTitle: Ask title
     * @param _askDescription: Ask description
     * @param _askIntRateBP: Ask interest rate basis point
     * @param _askDuration: Ask duration
     * @param _askCollateralRatio: Ask collateral ratio
     */
    function updateOfferAskInfo(
        uint256 _offerId,
        string memory _askTitle,
        string memory _askDescription,
        uint256 _askIntRateBP,
        uint256 _askDuration,
        uint256 _askCollateralRatio
    ) external nonReentrant {
        require(_offerId < totalOffersCount, "UpdateOffer: offer not found");
        Offer storage _offer = offers[_offerId];
        require(address(msg.sender) == _offer.maker, "UpdateOffer: only maker is allowed to update");
        require(_offer.status == OfferStatus.Pending, "UpdateOffer: offer is either closed or canceled");

        OfferAskInfo storage _info = offerAskInfos[_offerId];

        // Set offer ask title
        _info.askTitle = _askTitle;

        // Set offer ask description
        _info.askDescription = _askDescription;

        // Set offer ask interest rate basis point
        _info.askIntRateBP = _askIntRateBP;

        // Set offer ask duration
        _info.askDuration = _askDuration;

        // Set offer ask collateral ratio
        _info.askCollateralRatio = _askCollateralRatio;

        emit OfferAskInfoUpdated(_offerId, _askTitle, _askDescription, _askIntRateBP, _askDuration, _askCollateralRatio);
    }

    /**off
     * @notice Set offer's preferred assets
     * @param _offerId: Offer ID
     * @param _preferredAssets: Preferred assets
     */
    function setPreferredAssets(uint256 _offerId, address[] memory _preferredAssets) external nonReentrant {
        require(_offerId < totalOffersCount, "SetPreferredAssets: offer not found");
        Offer storage _offer = offers[_offerId];
        require(address(msg.sender) == _offer.maker, "SetPreferredAssets: only maker is allowed to update");
        require(_offer.status == OfferStatus.Pending, "SetPreferredAssets: offer is either closed or canceled");

        // Set new offer preferred assets
        offerPreferredAssets[_offerId] = _preferredAssets;

        emit OfferPreferredAssetsUpdated(_offerId, _preferredAssets);
    }

    /**
     * @notice Cancel Offer
     * @param _offerId: Offer ID
     */
    function cancelOffer(uint256 _offerId) external nonReentrant {
        require(_offerId < totalOffersCount, "CancelOffer: offer not found");
        Offer storage _offer = offers[_offerId];
        require(address(msg.sender) == _offer.maker, "CancelOffer: only maker is allowed to cancel");
        require(_offer.status == OfferStatus.Pending, "CancelOffer: offer is either closed or canceled");

        // Set offer status to cancel
        _offer.status = OfferStatus.Canceled;

        // Reduce total active offers counter
        totalActiveOffers = totalActiveOffers.sub(1);

        // Transfer collateral back to offer's maker
        IERC20(_offer.collateral).safeTransfer(address(_offer.maker), _offer.collateralAmount);

        // Emit OfferCanceled event
        emit OfferCanceled(_offerId);
    }

    /**
     * @notice Create bid to offer
     * @param _offerId: Offer ID
     * @param _asset: An address of asset to lend
     * @param _amount: Amount of asset to lend
     * @param _duration: Duration to lend in seconds
     * @param _intRateBP: Interest rate in basis points
     * @param _intProRated: Enable prorated interest rate
     * @param _allowLiquidator: Allow anyone to liquidate loan
     */
    function offerBid(
        uint256 _offerId,
        address _asset,
        uint256 _amount,
        uint256 _duration,
        uint256 _intRateBP,
        bool _intProRated,
        bool _allowLiquidator
    ) external payable nonReentrant {
        require(_offerId < totalOffersCount, "OfferBid: offer not found");
        require(whitelistedAssets.contains(_asset), "OfferBid: asset is not allowed");
        Offer storage _offer = offers[_offerId];
        require(address(msg.sender) != _offer.maker, "OfferBid: maker is not allowed to bid");
        require(_offer.status == OfferStatus.Pending, "OfferBid: offer is either closed or canceled");

        require(_duration >= minDuration, "OfferBid: duration is shorter than minimum");
        require(_intRateBP >= minIntRateBP, "OfferBid: interest rate is lower than minimum");

        // Asset balance before transfer
        uint256 _before = IERC20(_asset).balanceOf(address(this));

        /// Transfer asset to contract
        IERC20(_asset).safeTransferFrom(address(msg.sender), address(this), _amount);

        // Deflationary tokens check
        _amount = IERC20(_asset).balanceOf(address(this)).sub(_before);

        OfferBidInfo memory _bidInfo = OfferBidInfo({
            id: offerBidsCount[_offer.id],
            account: address(msg.sender),
            status: OfferBidStatus.Open,
            asset: _asset,
            amount: _amount,
            duration: _duration,
            intRateBP: _intRateBP,
            intProRated: _intProRated,
            allowLiquidator: _allowLiquidator,
            updatedAt: block.timestamp
        });

        // Increment offer bids counter
        offerBidsCount[_offer.id] += 1;
        offerActiveBidsCount[_offer.id] += 1;

        // Add bid to storage before moving asset
        offerBids[_offer.id].push(_bidInfo);

        // Track bids by bidder
        bidderBids[address(msg.sender)][_offer.id].push(bidderBidsCount[_offer.id][address(msg.sender)]);

        // Increment bidder bids counter
        bidderBidsCount[_offer.id][address(msg.sender)] += 1;
        bidderActiveBidsCount[_offer.id][address(msg.sender)] += 1;

        // Track offers and bidders
        if (!offerBidders[_offer.id].contains(address(msg.sender))) {
            offerBidders[_offer.id].add(address(msg.sender));
            bidderOffers[address(msg.sender)].push(_offer.id);
        }

        /// Emit OfferBidCreated event
        emit OfferBidCreated(address(msg.sender), _offer.id, _asset, _amount, _duration, _intRateBP, _intProRated, _allowLiquidator);
    }

    /**
     * @notice Set bid
     * @param _offerId: Offer ID
     * @param _bidId: Bid ID
     * @param _amount: Amount of asset
     */
    function setBid(
        uint256 _offerId,
        uint256 _bidId,
        uint256 _amount
    ) external nonReentrant {
        Offer storage _offer = offers[_offerId];
        require(_offer.status == OfferStatus.Pending, "SetBid: offer is either closed or canceled");

        OfferBidInfo storage _bid = offerBids[_offerId][_bidId];
        require(_bid.account == address(msg.sender), "SetBid: account not bidder");
        require(_bid.status == OfferBidStatus.Open, "SetBid: bid is either accepted or canceled");
        require(_bid.amount != _amount, "SetBid: bid amount unchanged");

        _bid.updatedAt = block.timestamp;

        if (_amount > _bid.amount) {
            // Transfer additional bid asset from bidder
            uint256 _incAmount = _amount.sub(_bid.amount);

            // Asset balance before transfer
            uint256 _before = IERC20(_bid.asset).balanceOf(address(this));

            /// Transfer asset to contract
            IERC20(_bid.asset).safeTransferFrom(address(msg.sender), address(this), _incAmount);

            // Deflationary tokens check
            _incAmount = IERC20(_bid.asset).balanceOf(address(this)).sub(_before);

            // Update bidded amount in storage
            _bid.amount += _incAmount;

            // Emit OfferBidSet event
            emit OfferBidSet(_offerId, _bid.id, 1, _bid.amount, _incAmount);
        } else {
            // Transfer reducted bid asset back to bidder
            uint256 _reducAmount = _bid.amount.sub(_amount);
            IERC20(_bid.asset).safeTransfer(address(msg.sender), _reducAmount);

            // Reduce bidded amount in storage
            _bid.amount -= _reducAmount;

            // Emit OfferBidSet event
            emit OfferBidSet(_offerId, _bid.id, 0, _bid.amount, _reducAmount);
        }
    }

    /**
     * @notice Set bid info
     * @param _offerId: Offer ID
     * @param _bidId: Bid ID
     * @param _duration: Duration to lend in seconds
     * @param _intRateBP: Interest rate in basis points
     * @param _intProRated: Enable prorated interest rate
     * @param _allowLiquidator: Allow anyone to liquidate loan
     */
    function setBidInfo(
        uint256 _offerId,
        uint256 _bidId,
        uint256 _duration,
        uint256 _intRateBP,
        bool _intProRated,
        bool _allowLiquidator
    ) external nonReentrant {
        Offer storage _offer = offers[_offerId];
        require(_offer.status == OfferStatus.Pending, "SetBidInfo: offer is either closed or canceled");

        OfferBidInfo storage _bid = offerBids[_offerId][_bidId];
        require(_bid.account == address(msg.sender), "SetBidInfo: account not bidder");
        require(_bid.status == OfferBidStatus.Open, "SetBidInfo: bid is either accepted or canceled");
        require(_duration >= minDuration, "SetBidInfo: duration is shorter than minimum");
        require(_intRateBP >= minIntRateBP, "SetBidInfo: interest rate is lower than minimum");

        // Update Bid info
        _bid.updatedAt = block.timestamp;
        _bid.duration = _duration;
        _bid.intRateBP = _intRateBP;
        _bid.intProRated = _intProRated;
        _bid.allowLiquidator = _allowLiquidator;

        emit OfferBidInfoSet(_offerId, _bid.id, _duration, _intRateBP, _intProRated, _allowLiquidator);
    }

    /**
     * @notice Accept bid
     * @param _offerId: Offer ID
     * @param _bidId: Bid ID
     * @param _safeDuration: Safe duration
     */
    function acceptBid(
        uint256 _offerId,
        uint256 _bidId,
        uint256 _safeDuration
    ) external nonReentrant {
        require(_offerId < totalOffersCount, "AcceptBid: offer not found");
        Offer storage _offer = offers[_offerId];
        OfferBidInfo storage _bid = offerBids[_offer.id][_bidId];
        require(_offer.maker == address(msg.sender), "AcceptBid: account not maker");
        require(_offer.status == OfferStatus.Pending, "AcceptBid: offer is either closed or canceled");
        require(_bid.status == OfferBidStatus.Open, "AcceptBid: bid is already canceled");
        require(block.timestamp > _bid.updatedAt + _safeDuration, "AcceptBid: bid is recently updated");

        // Set offer status to closed
        _offer.status = OfferStatus.Closed;

        // Set offer taker to lender address
        _offer.taker = _bid.account;

        // Set bid status to Accepted
        _bid.status = OfferBidStatus.Accepted;

        // Reduce total active offers counter
        totalActiveOffers -= 1;

        // Reduce offer bids count
        offerActiveBidsCount[_offerId] -= 1;

        // Reduce bidder bids count
        bidderActiveBidsCount[_offerId][_bid.account] -= 1;

        // Transfer asset and collateral to loan manager and open a loan and mint nft
        IERC20(_offer.collateral).safeApprove(address(feedLoan), 0);
        IERC20(_offer.collateral).safeApprove(address(feedLoan), _offer.collateralAmount);
        IERC20(_bid.asset).safeApprove(address(feedLoan), 0);
        IERC20(_bid.asset).safeApprove(address(feedLoan), _bid.amount);
        uint256 _loanId = IFeedLoan(feedLoan).startLoan(
            _bid.account,
            _bid.asset,
            _bid.amount,
            _offer.maker,
            _offer.collateral,
            _offer.collateralAmount,
            _bid.duration,
            _bid.intRateBP,
            _bid.intProRated,
            _offer.useVault,
            _offer.vaultId
        );

        // Set loan's ID to offer info
        _offer.loanId = _loanId;

        // Set accepted bid's ID to offer info
        _offer.bidId = _bid.id;

        if (_bid.allowLiquidator) IFeedLoan(feedLoan).setAllowLiquidator(_loanId, _bid.allowLiquidator);

        // Emit OfferBidAccepted event
        emit OfferBidAccepted(_offerId, _bidId);
    }

    /**
     * @notice Cancel bid
     * @param _offerId: Offer ID
     * @param _bidId: Bid ID
     */
    function cancelBid(uint256 _offerId, uint256 _bidId) external nonReentrant {
        require(_offerId < totalOffersCount, "CancelBid: offer not found");
        Offer storage _offer = offers[_offerId];
        OfferBidInfo storage _bid = offerBids[_offer.id][_bidId];
        require(_bid.account == address(msg.sender), "CancelBid: account not bidder");
        require(_bid.status == OfferBidStatus.Open, "CancelBid: bid is already canceled or accepted");

        // Reduce offer bids count
        offerActiveBidsCount[_offer.id] -= 1;

        // Set bid status to canceled
        _bid.status = OfferBidStatus.Canceled;

        // Set bid updatedAt
        _bid.updatedAt = block.timestamp;

        // Reduce bidder bids count
        bidderActiveBidsCount[_offer.id][address(msg.sender)] -= 1;

        // Transfer asset back to bidder
        IERC20(_bid.asset).safeTransfer(address(msg.sender), _bid.amount);

        /// Emit OfferBidCanceled event
        emit OfferBidCanceled(_offerId, _bidId);
    }

    /*********************
     ** View Functions **
     *********************/

    /**
     * @notice Get collateral address by ID
     * @param _index: Index of collateral
     */
    function collaterals(uint256 _index) external view returns (address _collateral) {
        _collateral = whitelistedCollaterals.at(_index);
    }

    /**
     * @notice Count total number of collaterals
     */
    function collateralsCount() external view returns (uint256 _length) {
        _length = whitelistedCollaterals.length();
    }

    /**
     * @notice Get asset address by ID
     * @param _index: Index of collateral
     */
    function assets(uint256 _index) external view returns (address _asset) {
        _asset = whitelistedAssets.at(_index);
    }

    /**
     * @notice Count total number of collaterals
     */
    function assetsCount() external view returns (uint256 _length) {
        _length = whitelistedAssets.length();
    }

    /**
     * @notice View list of current bidders and bid info for an offer
     * @param _offerId: offer id
     * @param _cursor: cursor
     * @param _size: size
     */
    function viewBidsPerOffer(
        uint256 _offerId,
        uint256 _cursor,
        uint256 _size
    ) external view returns (OfferBidInfo[] memory, uint256) {
        uint256 _length = _size;
        uint256 _bidsLength = offerBids[_offerId].length;
        if (_length > _bidsLength - _cursor) {
            _length = _bidsLength - _cursor;
        }

        OfferBidInfo[] memory _values = new OfferBidInfo[](_length);
        for (uint256 i = 0; i < _length; i++) {
            _values[i] = offerBids[_offerId][_cursor + i];
        }

        return (_values, _cursor + _length);
    }

    /**
     * @notice View list of bids by bidder at specific offer
     * @param _offerId: offer id
     * @param _bidder: bidder
     * @param _cursor: cursor
     * @param _size: size
     */
    function viewBidsPerBidder(
        uint256 _offerId,
        address _bidder,
        uint256 _cursor,
        uint256 _size
    ) external view returns (OfferBidInfo[] memory, uint256) {
        uint256 _length = _size;
        uint256 _bidsLength = bidderBids[_bidder][_offerId].length;
        if (_length > _bidsLength - _cursor) {
            _length = _bidsLength - _cursor;
        }

        OfferBidInfo[] memory _values = new OfferBidInfo[](_length);
        for (uint256 i = 0; i < _length; i++) {
            uint256 _bidId = bidderBids[_bidder][_offerId][_cursor + i];
            _values[i] = offerBids[_offerId][_bidId];
        }

        return (_values, _cursor + _length);
    }

    /**
     * @notice View list of offers
     * @param _cursor: cursor
     * @param _size: size
     */
    function viewOffers(uint256 _cursor, uint256 _size) external view returns (Offer[] memory, uint256) {
        uint256 _length = _size;
        uint256 _offersLength = totalOffersCount;
        if (_length > _offersLength - _cursor) {
            _length = _offersLength - _cursor;
        }

        Offer[] memory _values = new Offer[](_length);
        for (uint256 i = 0; i < _length; i++) {
            _values[i] = offers[_cursor + i];
        }

        return (_values, _cursor + _length);
    }

    /**
     * @notice View list of offers by collateral
     * @param _collateral: collateral address
     * @param _cursor: cursor
     * @param _size: size
     */
    function viewOffersByCollateral(
        address _collateral,
        uint256 _cursor,
        uint256 _size
    ) external view returns (Offer[] memory, uint256) {
        uint256 _length = _size;
        uint256 _offersLength = collateralOffers[_collateral].length;
        if (_length > _offersLength - _cursor) {
            _length = _offersLength - _cursor;
        }

        Offer[] memory _values = new Offer[](_length);
        for (uint256 i = 0; i < _length; i++) {
            uint256 _offerId = collateralOffers[_collateral][_cursor + i];
            _values[i] = offers[_offerId];
        }

        return (_values, _cursor + _length);
    }

    /**
     * @notice Count total number of offers by collateral
     * @param _collateral: collateral address
     */
    function offersCountByCollateral(address _collateral) external view returns (uint256) {
        return collateralOffers[_collateral].length;
    }

    /**
     * @notice Count offer preferred assets
     * @param _offerId: Offer ID
     */
    function offerPreferredAssetsCount(uint256 _offerId) external view returns (uint256) {
        return offerPreferredAssets[_offerId].length;
    }

    /*********************
     ** Admin Functions **
     *********************/

    /**
     * @notice Set FeedLoan address
     * @param _feedLoan: address of new FeedLoan
     * @dev Callable by owner
     */
    function setFeedLoan(address _feedLoan) external onlyAdmin nonReentrant {
        require(_feedLoan != address(0), "SetFeedLoan: Cannot be zero address");

        feedLoan = _feedLoan;

        emit FeedLoanChanged(feedLoan);
    }

    /**
     * @notice Set VaultController address
     * @param _vaultController: address of new VaultController
     * @dev Callable by owner
     */
    function setVaultController(address _vaultController) external onlyAdmin nonReentrant {
        require(_vaultController != address(0), "SetVaultController: Cannot be zero address");
        require(vaultController == address(0), "SetVaultController: Cannot replace vault controller");

        vaultController = _vaultController;

        emit VaultControllerChanged(_vaultController);
    }

    /**
     * @notice Add addresses to whitelisted collateral
     * @param _collaterals: addresses of collaterals to add
     * @dev Callable by manager
     */
    function addCollateral(address[] calldata _collaterals) external onlyManager nonReentrant {
        for (uint256 i = 0; i < _collaterals.length; i++) {
            address _collateral = _collaterals[i];
            if (!whitelistedCollaterals.contains(_collateral)) {
                whitelistedCollaterals.add(_collateral);

                emit CollateralAdded(_collateral);
            }
        }
    }

    /**
     * @notice Remove addresses from whitelisted collateral
     * @param _collaterals: addresses of collaterals to remove
     * @dev Callable by manager
     */
    function removeCollateral(address[] calldata _collaterals) external onlyManager nonReentrant {
        for (uint256 i = 0; i < _collaterals.length; i++) {
            address _collateral = _collaterals[i];

            whitelistedCollaterals.remove(_collateral);

            emit CollateralRemoved(_collateral);
        }
    }

    /**
     * @notice Add addresses to whitelisted assets
     * @param _assets: addresses of assets to add
     * @dev Callable by manager
     */
    function addAsset(address[] calldata _assets) external onlyManager nonReentrant {
        for (uint256 i = 0; i < _assets.length; i++) {
            address _asset = _assets[i];
            if (!whitelistedAssets.contains(_asset)) {
                whitelistedAssets.add(_asset);

                emit AssetAdded(_asset);
            }
        }
    }

    /**
     * @notice Remove addresses from whitelisted assets
     * @param _assets: addresses of assets to remove
     * @dev Callable by manager
     */
    function removeAsset(address[] calldata _assets) external onlyManager nonReentrant {
        for (uint256 i = 0; i < _assets.length; i++) {
            address _asset = _assets[i];

            whitelistedAssets.remove(_asset);

            emit AssetRemoved(_asset);
        }
    }

    /**
     * @notice Set minimum loan duration
     * @param _duration: Minimum loan duration in seconds
     */
    function setMinDuration(uint256 _duration) external onlyManager nonReentrant {
        minDuration = _duration;

        emit MinDurationChanged(_duration);
    }

    /**
     * @notice Set minimum interest rate basis points
     * @param _intRateBP: Minimum interest rate in basis points
     */
    function setMinIntRateBP(uint256 _intRateBP) external onlyManager nonReentrant {
        minIntRateBP = _intRateBP;

        emit MinIntRateBPChanged(_intRateBP);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
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

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
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
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
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
pragma solidity >=0.7.0 <0.9.0;

interface IFeedLoan {
    function startLoan(
        address _lender,
        address _asset,
        uint256 _assetAmount,
        address _borrower,
        address _collateral,
        uint256 _collateralAmount,
        uint256 _duration,
        uint256 _intRateBP,
        bool _intProRated,
        bool _useVault,
        uint256 _vaultId
    ) external returns (uint256 _id);

    function setAllowLiquidator(uint256 _loanId, bool _allowLiquidator) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface IVaultController {
    function deposit(
        uint256 _vid,
        uint256 _loanId,
        uint256 _amount
    ) external;

    function withdraw(uint256 _vid, uint256 _loanId) external;

    function vaultInfo(uint256 _vid) external view returns (address, address);

    function vaultLength() external view returns (uint256);

    function balance(uint256 _vid, uint256 _loanId) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
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

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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