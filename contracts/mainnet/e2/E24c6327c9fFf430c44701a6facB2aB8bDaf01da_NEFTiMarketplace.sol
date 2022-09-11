// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.7.4 <=0.8.9;

import "./INEFTiLicense.sol";
import "./SafeMath.sol";
import "./ReentrancyGuard.sol";
import "./Ownable.sol";
import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./INEFTiMultiTokens.sol";
import "./INEFTiMPFeeCalcExt.sol";
import "./SafeERC20.sol";
import "./NEFTiMPStorages.sol";

/** a2461f9f */
contract NEFTiMarketplace is NEFTiMPStorages, ReentrancyGuard , Ownable {
    using SafeMath  for uint256;
    using SafeERC20 for IERC20;

    bytes32 public version = keccak256("1.10.55");

    address internal NEFTi20;
    address internal NEFTiMPFeeCalcExt;
    address internal NEFTiMT;
    address private  NEFTiReceivable;
    uint256 private  listingFee;

    event UpdateExternalRelationship(uint8 extType, address extTarget);
    event UpdateReceivableTo(address NEFTiAccount);

    event Sale(
        uint256 indexed saleId,
        uint256 indexed tokenId,
        uint256 price,
        uint256 amount,
        uint8 saleMethod,
        address indexed seller,
        bool[4] states,
        //+-->  bool isPostPaid;
        //+-->  bool isNegotiable;
        //+-->  bool isAuction;
        //+-->  bool isContract;
        uint256[2] saleDate,
        uint8 status
    );

    event Negotiate(
        uint256 indexed saleId,
        uint256 indexed tokenId,
        uint256 amount,
        uint256 price,
        address indexed negotiator,
        uint256 negoDate,
        uint8 status
    );
    event NegotiationCanceled(uint256 _sid, address _negotiator);
    event Bid(
        uint256 indexed saleId,
        uint256 indexed tokenId,
        uint256 amount,
        uint256 price,
        address indexed bidder,
        uint256 bidDate,
        uint8 status
    );   
    event BidCanceled(uint256 _sid, address _negotiator);
    event CancelSale(
        uint256 indexed saleId,
        uint256 indexed tokenId,
        address indexed seller,
        uint8 status
    );
    event Purchase(
        uint256 indexed purchaseId,
        uint256 indexed saleId,
        uint256 indexed tokenId,
        uint256 price,
        uint256 amount,
        uint8   saleMethod,
        address seller,
        bool[4] states,
        //+-->  bool isPostPaid;
        //+-->  bool isNegotiable;
        //+-->  bool isAuction;
        //+-->  bool isContract;
        uint8   status
    );
    event Suspended(uint256 _sid, uint256 _tokenId, address _seller, bool _suspend);
    event Delisted(uint256 _sid, uint256 _tokenId, address _seller);


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~~~~~ LISTING ~~~~~~~~~~~~~█║
    ╚════════════════════════════════════*/

    /**
    ** 31262f27
    ** @dev Proceed Listing item into Marketplace
    ** @param _from         Owner of the item
    ** @param _id           Token ID of the NEFTiMultiToken
    ** @param _amount       Amount of the item
    ** @param _price        Price of the item
    ** @param _saleMethod   Selling method
    **/
    function _sellToken(uint256 _id, uint256 _amount, uint256 _price, SaleMethods _saleMethod, uint256 listingFee)
        internal
    {
        // uint256 listingFee = (
        //     SaleMethods(_saleMethod) == SaleMethods.DIRECT
        //         ?   INEFTiMPFeeCalcExt(NEFTiMPFeeCalcExt).calcFeeOf( uint8(FeeTypes.DirectListingFee), _price, _amount )
        //         :   INEFTiMPFeeCalcExt(NEFTiMPFeeCalcExt).calcFeeOf( uint8(FeeTypes.AuctionListingFee), _price, _amount )
        // );
        // uint256 listingFee;        
        if (listingFee > 0) {
            require(IERC20(NEFTi20).balanceOf(msg.sender) >= listingFee, "ENEFTiMP.01.INSUFFICIENT_NEFTi"); // Not enough NFT balance for listing
            IERC20(NEFTi20).safeTransferFrom( msg.sender, address(this), listingFee );
        }
        INEFTiMultiTokens(NEFTiMT).safeTransferFrom(msg.sender, address(this), _id, _amount, "");
    }
    /**
    ** 6f980d6a
    ** @dev Listing NEFTiMultiTokens (MT) into the Marketplace (MP)
    ** @param _sid          Input Sale ID (client-side)
    ** @param _tokenId      Token ID of the NEFTiMultiToken
    ** @param _price        Price of the item
    ** @param _amount       Amount of the item
    ** @param _saleMethod   Selling method
    ** @param _states       States in array
    ** @param _saleDate     Listing date for sale
    **/
    function txSaleItems(
        uint256    _sid,
        uint256    _tokenId,
        uint256    _price,
        uint256    _amount,
        uint8      _saleMethod,
        bool[4]    memory _states,
        //+----->  bool _isPostPaid,
        //+----->  bool _isNegotiable,
        //+----->  bool _isAuction,
        //+----->  bool _isContract,
        uint256[2] memory _saleDate
    )
        public nonReentrant
    {
        require(_saleMethod < 0x02, "ENEFTiMP.02.INVALID_SALE_METHOD"); // Unknown Sale Method!
        require(_saleDate[0] >= block.timestamp, "ENEFTiMP.03.TIME_BEHIND_CURRENT"); // Time for sale is behind current time!
        require(INEFTiMultiTokens(NEFTiMT).balanceOf(msg.sender, _tokenId) > 0, "ENEFTiMP.04.INSUFFICIENT_TOKEN_ID"); // Not enough current token id balance for listing!
        require(_amount > 0, "ENEFTiMP.05.ZERO_AMOUNT"); // Zero amount is not applicable for listing!

        _poolSales[msg.sender][_tokenId] += _amount;
        // if ((_selling[_sid].amount == 0) && (_selling[_sid].amount == 0)) {
        if (_selling[_sid].amount == 0) {
            // _saleItems.push(_sid);
            _itemsOnSaleItems[msg.sender].push(_sid);
        }

        uint256[3] memory values = [uint(0),uint(0),uint(0)];
        _selling[_sid] = SaleItems(
            _tokenId,
            _price,
            _amount,
            msg.sender,
            _states,
            //+--> _states[0] :  _isPostPaid
            //+--> _states[1] :  _isNegotiable
            //+--> _states[2] :  _isAuction
            //+--> _states[3] :  _isContract
            _saleDate,
            values,
            //+--> values[0]  :  _valContract   0
            //+--> values[1]  :  _highBid       0
            //+--> values[2]  :  _bidMultiplier 0
            address(0),
            SaleStatus.OPEN
        );
        _sellToken( _tokenId, _amount, _price, SaleMethods(_saleMethod), listingFee);

        emit Sale(
            _sid,
            _tokenId,
            _price,
            _amount,
            _saleMethod,
            msg.sender,
            [ _states[0], _states[1], _states[2], false ],
            _saleDate,
            uint8(SaleStatus.OPEN)
        );
    }

    /**
    ** 96fd6550
    ** @dev Add more amount to Sale item
    ** @param _sid      Input Sale ID (client-side)
    ** @param _tokenId  Token ID of the NEFTiMultiToken
    ** @param _amount   Amount of the item
    **/
    function txAddItemForSale(uint256 _sid, uint256 _tokenId, uint256 _amount)
        public nonReentrant
    {
        require((_sid > 0) && (_tokenId > 0) && (_amount > 0), "ENEFTiMP.06.INVALID_PARAMS");
        require(_selling[_sid].seller == msg.sender, "ENEFTiMP.07.FORBIDDEN_EXECUTOR"); // Executor have no rights to the item!
        require(!_selling[_sid].states[2], "ENEFTiMP.08.INVALID_STATE_OF_AUCTION"); // unsupported adding item to Auction

        _selling[_sid].amount += _amount;
        _poolSales[msg.sender][_tokenId] += _amount;

        _sellToken(
            _tokenId,
            _amount,
            _selling[_sid].price,
            SaleMethods(0x00),
            listingFee
        );
        
        emit Sale(
            _sid,
            _tokenId,
            _selling[_sid].price,
            _selling[_sid].amount,
            uint8(0),
            msg.sender,
            _selling[_sid].states,
            _selling[_sid].saleDate,
            uint8(SaleStatus.OPEN)
        );
    }


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~~~~ UTILITIES ~~~~~~~~~~~~█║
    ╚════════════════════════════════════*/

    /**
    ** ec980dea
    ** @dev Get item information by Sale ID
    ** @param _sid  Sale ID
    ** @return      Item information (SaleItems)
    **/
    function getSaleItemsInfo(uint256 _sid)
        public view
        returns (
            uint256[3] memory info,
            //+----->  uint256 tokenId,
            //+----->  uint256 price,
            //+----->  uint256 amount,
            address    seller,
            bool[4]    memory states,
            //+----->  bool isPostPaid,
            //+----->  bool isNegotiable,
            //+----->  bool isAuction,
            //+----->  bool isContract,
            uint256[2] memory saleDate,
            uint256[3] memory values,
            //+----->  uint256 valContract,
            //+----->  uint256 highBid,
            //+----->  uint256 bidMultiplier,
            address    buyer,
            uint8      status
        )
    {
        return (
            [
                _selling[_sid].tokenId,
                _selling[_sid].price,
                _selling[_sid].amount
            ],
            _selling[_sid].seller,
            _selling[_sid].states,
            //+----->  .isPostPaid,
            //+----->  .isNegotiable,
            //+----->  .isAuction,
            //+----->  .isContract,
            _selling[_sid].saleDate,
            _selling[_sid].values,
            //+----->  .valContract,
            //+----->  .highBid,
            //+----->  .bidMultiplier,
            _selling[_sid].buyer,
            uint8(_selling[_sid].status)
        );
    }
    
    /**
    ** 1626da32
    ** @dev Get sale item amount by seller address and token ID
    ** @param _sid      Sale ID
    ** @param _tokenId  Token ID of the NEFTiMultiToken
    ** @return Balance on Sale amount of current token id
    **/
    function balanceOf(address _seller, uint256 _tokenId)
        public view
        returns (uint256)
    { return (_poolSales[_seller][_tokenId]); }

    /**
    ** 90267f9c
    ** @dev Get sale items by seller address
    ** @param _seller   Address of the seller
    ** @return Array of Sale item IDs (bytes32)
    **/
    function itemsOf(address _seller)
        public view
        returns (uint256[] memory items)
    { return _itemsOnSaleItems[_seller]; }

    /**
    ** e894a07a
    ** @dev Cancel Negotiation
    ** @param _sid          Sale ID
    ** @param _negotiator   Negotiator address
    **/
    function cancelNegotiation(uint256 _sid, address _negotiator)
        public nonReentrant
    {
        require((_sid > 0) && (_negotiator != address(0)), "ENEFTiMP.09.INVALID_PARAMS");
        require((msg.sender).balance > 0, "ENEFTiMP.10.ISSUE_TO_PAY_GAS");
        
        bool isNegotiator = false;
        bool isSeller = (msg.sender == _selling[_sid].seller);
        address negotiator = address(0);
        NegotiateStatus cancelStatus;
        uint256 cancellationFee = 0;

        if (isSeller || msg.sender == owner()) {
            cancelStatus = NegotiateStatus.REJECTED;
            negotiator = _negotiator;
        } else {
            for (uint256 i=0; _negotiators[_sid].length > i; i++) {
                if (_negotiators[_sid][i] == msg.sender) {
                    isNegotiator = true;
                    negotiator = msg.sender;
                    break;
                }
            }
            require(isNegotiator, "ENEFTiMP.11.INVALID_EXECUTOR"); // Only seller or negotiator can cancel the negotiation!
            cancelStatus = NegotiateStatus.CANCELED;
        }

        for (uint256 i=0; _negotiators[_sid].length > i; i++) {
            if ((negotiator != address(0)) && (_negotiators[_sid][i] == negotiator)) {
                if (isNegotiator && (cancelStatus == NegotiateStatus.CANCELED)) {
                    cancellationFee = INEFTiMPFeeCalcExt(NEFTiMPFeeCalcExt).calcFeeOf(
                        uint8(FeeTypes.DirectNegotiateCancellationFee),
                        _poolNegotiating[_sid][msg.sender].value,
                        1
                    );

                    require(IERC20(NEFTi20).balanceOf(msg.sender) >= cancellationFee, "ENEFTiMP.12.INSUFFICIENT_NEFTi"); // Not enough current token balance for cancellation!
                    IERC20(NEFTi20).safeTransferFrom(
                        address(this),
                        NEFTiReceivable,
                        cancellationFee
                    );
                }
                IERC20(NEFTi20).safeTransferFrom(
                    address(this),
                    _negotiators[_sid][i],
                    _poolNegotiating[_sid][negotiator].value.sub(cancellationFee)
                );
                
                _poolNegotiating[_sid][negotiator].status = cancelStatus;
                _negotiators[_sid][i] = _negotiators[_sid][_negotiators[_sid].length-1];
                // remove last index
                _negotiators[_sid].pop();
                break;
            }
        }

        emit NegotiationCanceled(_sid, negotiator);
    }

    /**
    ** 27106aa4
    ** @dev Cancel Bid's Auction
    ** @param _sid      Sale ID
    ** @param _bidder   Bidder address
    **/
    function cancelAuctionBid(uint256 _sid, address _bidder)
        public nonReentrant
    {
        bool isBidder = false;
        bool isAdmin = (msg.sender == owner());
        address bidder = address(0);

        if (isAdmin) {
            bidder = _bidder;
        } else {
            for (uint256 i=0; _bidders[_sid].length > i; i++) {
                if (_bidders[_sid][i] == msg.sender) {
                    isBidder = true;
                    bidder = msg.sender;
                    break;
                }
            }
            require(isBidder, "ENEFTiMP.13.INVALID_EXECUTOR"); // Only seller or bidder can cancel the negotiation!
        }

        for (uint256 i=0; _negotiators[_sid].length > i; i++) {
            if (_bidders[_sid][i] == bidder) {
                IERC20(NEFTi20).safeTransferFrom(
                    address(this),
                    _bidders[_sid][i],   // bidder
                    _poolBidding[_sid][bidder]
                );
                _poolBidding[_sid][bidder] = 0;

                _bidders[_sid][i] = _bidders[_sid][_bidders[_sid].length-1];
                // remove last index
                _bidders[_sid].pop();
            }
        }

        emit BidCanceled(_sid, bidder);
    }

    /**
    ** 5447d080
    ** @dev Get listing cancellation fee
    ** @param _sid  Sale ID
    ** @return Value as fee
    **/
    function getListingCancellationFee(uint256 _sid)
        public view
        returns (uint256)
    {
        require(_selling[_sid].status == SaleStatus.OPEN, "ENEFTiMP.14.ITEM_NOT_ONSALE"); // Only open sale can be canceled!

        uint8 cancelFor = (
            (!_selling[_sid].states[2] && !_selling[_sid].states[3])
                ?   0x02            // FeeTypes.DirectListingCancellationFee
                :   (
                    (_selling[_sid].states[2] && !_selling[_sid].states[3])
                        ?   0x07    // FeeTypes.AuctionListingCancellationFee
                        :   0x0c    // FeeTypes.ContractListingCancellationFee
                )
        );
        uint256 cancelFee = INEFTiMPFeeCalcExt(NEFTiMPFeeCalcExt).calcFeeOf(
            cancelFor,
            _selling[_sid].price,
            _selling[_sid].amount
        );
        return cancelFee;
    }

    /**
    ** e40417c9
    ** @dev Cancel item on sale
    ** @param _sid  Sale ID
    **/
    function cancelSaleItem(uint256 _sid)
        public nonReentrant
    {
        require(_sid > 0, "ENEFTiMP.15.INVALID_SALEID"); // Unknown Sale ID
        address seller = _selling[_sid].seller;
        require(msg.sender == seller || msg.sender == owner(), "ENEFTiMP.16.INVALID_EXECUTOR"); // Only seller can cancel the sale!
        require(_selling[_sid].status == SaleStatus.OPEN, "ENEFTiMP.17.NOT_FOR_SALE"); // Only open sale can be canceled!
        // require(msg.sender.balance > 0, "Cancellation cost gas fee");

        address item_seller = _selling[_sid].seller;
        uint256 item_tokenId = _selling[_sid].tokenId;
        uint256 item_amount = _selling[_sid].amount;

        // when it's an Auction
        if ( _selling[_sid].states[2] ) {
            if (_bidders[_sid].length > 0) {
                require(msg.sender == owner(), "ENEFTiMP.18.FORBIDDEN_ONLY_ADMIN"); // Only Admin able to cancel auction when bids are placed
                for (uint256 i=0; i < _bidders[_sid].length; i++) {
                    // cancellation index should stay on [0]!
                    if (_bidders[_sid][0] != address(0)) {
                        cancelAuctionBid(_sid, _bidders[_sid][0]);
                    }
                }
            }
        }
        // when it's a Direct Sale
        else if ( !_selling[_sid].states[2] ) {
            if (_negotiators[_sid].length > 0) {
                for (uint256 i=0; i < _negotiators[_sid].length; i++) {
                    // cancellation index should stay on [0]!
                    if (_negotiators[_sid][0] != address(0)) {
                        cancelNegotiation(_sid, _negotiators[_sid][0]);   
                    }
                }
            }
        }

        if (_itemsOnSaleItems[seller].length > 0) {
            for (uint256 i=0; i < _itemsOnSaleItems[seller].length; i++) {
                if (_itemsOnSaleItems[seller][0] != _sid) {
                    _itemsOnSaleItems[seller][i] = _itemsOnSaleItems[seller][_itemsOnSaleItems[seller].length-1];
                    // remove last index
                    // delete _itemsOnSaleItems[seller][_itemsOnSaleItems[seller].length-1];
                    _itemsOnSaleItems[seller].pop();
                }
            }
        }

        _poolSales[seller][_selling[_sid].tokenId] -= _selling[_sid].amount;
        _selling[_sid].buyer = address(0);
        _selling[_sid].status = SaleStatus.CANCELED;

        INEFTiMultiTokens(NEFTiMT).safeTransferFrom(
            address(this),
            item_seller,
            item_tokenId,
            item_amount,
            ""
        );

        emit CancelSale(
            _sid,
            item_tokenId,
            item_seller,
            uint8(SaleStatus.CANCELED)
        );
    }

    /**
    ** b78c56dd
    ** @dev Get list of negotiators
    ** @param _sid  Sale ID
    ** @return List of negotiator addresses
    **/
    function getNegotiators(uint256 _sid) 
        public view
        returns (address[] memory)
    { return _negotiators[_sid]; }

    /**
    ** b0ec6c52
    ** @dev Get negotiation info
    ** @param _sid          Sale ID
    ** @param _negotiator   Negotiator address
    ** @return (
    **    saleId    - Sale ID
    **    value     - Negotiation value
    **    amount    - Negotiation amount
    **    negoDate  - Negotiation date
    **    status    - Negotiation status
    ** )
    **/
    function getNegotiationInfo(uint256 _sid, address _negotiator) 
        public view
        returns (
            uint256 saleId,
            uint256 value,
            uint256 amount,
            uint256 negoDate,
            uint8   status
        )
    {
        require(_negotiator != address(0), "ENEFTiMP.19.INVALID_NEGOTIATOR"); // Unknown Negotiator
        return (
            _poolNegotiating[_sid][_negotiator].saleHash,
            _poolNegotiating[_sid][_negotiator].value,
            _poolNegotiating[_sid][_negotiator].amount,
            _poolNegotiating[_sid][_negotiator].negoDate,
            uint8(_poolNegotiating[_sid][_negotiator].status)
        );
    }

    /**
    ** 5a02723f
    ** @dev Get list of bidders
    ** @param _sid  Sale ID
    ** @return List of bidder addresses
    **/
    function getAuctionBidders(uint256 _sid) 
        public view
        returns (address[] memory)
    { return _bidders[_sid]; }

    /**
    ** 12f2a515
    ** @dev Get auction bid value
    ** @param _sid      Sale ID
    ** @param _bidder   Bidder address
    ** @return Bid value
    **/
    function getBidValue(uint256 _sid, address _bidder) 
        public view
        returns (uint256)
    {
        require(_bidder != address(0), "ENEFTiMP.20.INVALID_BIDDER"); // Unknown Bidder
        return _poolBidding[_sid][_bidder];
    }

    /**
    ** db794cbe
    ** @dev Get highest bid amount
    ** @param _sid  Sale ID
    ** @return (
    **    bidder  - Bidder address
    **    bid     - Bid value
    ** )
    **/
    function getHighestBidValue(uint256 _sid)
        public view
        returns (address bidder, uint256 bid)
    { return ( _selling[_sid].buyer, _selling[_sid].values[1] ); }
    

    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~ PURCHASING - DIRECT ~~~~~~~█║
    ╚════════════════════════════════════*/

    /**
    ** 7de47861
    ** @dev Buying item directly
    ** @param _sid      Sale ID
    ** @param _pid      Input PurchaseItems ID (client-side)
    ** @param _amount   Amount to buy
    **/
    function txDirectBuy(
        uint256 _sid,
        uint256 _pid,
        uint256 _amount
    )
        public nonReentrant
    {
        require (_selling[_sid].status == SaleStatus.OPEN, "ENEFTiMP.21.NOT_FOR_SALE"); // Item is not for sale!
        require (_selling[_sid].saleDate[0] <= block.timestamp, "ENEFTiMP.22.ITEM_WAIT_FOR_CONFIRMATION"); // Item is not yet for sale!
        require (_selling[_sid].amount >= _amount, "ENEFTiMP.23.PURCHASE_AMOUNT_OVERFLOW"); // Not enough tokens for sale!
        require (address(msg.sender).balance > 0, "ENEFTiMP.24.ISSUE_TO_PAY_GAS"); // Not enough BNB to spend for Gas fee!
        
        uint256 subTotal = _selling[_sid].price * _amount;
        uint256 txFee = INEFTiMPFeeCalcExt(NEFTiMPFeeCalcExt).calcFeeOf( uint8(FeeTypes.DirectTransactionFee), subTotal, 0x01 );
        require (IERC20(NEFTi20).balanceOf(msg.sender) >= subTotal, "ENEFTiMP.25.INSUFFICIENT_NEFTi"); // Not enough NFT balance for purchase!

        // transfer NFT20 purchase value to seller
        IERC20(NEFTi20).safeTransferFrom( msg.sender, _selling[_sid].seller, subTotal.sub(txFee) );
        // transfer NFT20 fee to owner
        IERC20(NEFTi20).safeTransferFrom( msg.sender, NEFTiReceivable, txFee );
        // then transfer NFT1155 token in return
        INEFTiMultiTokens(NEFTiMT).safeTransferFrom( address(this), msg.sender, _selling[_sid].tokenId, _amount, "" );

        _poolSales[ _selling[_sid].seller ][ _selling[_sid].tokenId ] = _selling[_sid].amount.sub(_amount);
        _selling[_sid].amount = _selling[_sid].amount.sub(_amount);
        if (_selling[_sid].amount == 0) { _selling[_sid].status = SaleStatus.FULFILLED; }
        
        emit Purchase(
            _pid,
            _sid,
            _selling[_sid].tokenId,
            _selling[_sid].price,
            _amount,
            1,
            _selling[_sid].seller,
            [ false, false, false, false ],
            uint8(PurchaseStatus.FULFILLED)
        );
    }

    /**
    ** 38e8818e
    ** @dev Buyer negotiate an offer
    ** @param _sid      Sale ID
    ** @param _amount   Amount to buy
    ** @param _price    Price per token
    **/
    function txDirectOffering(
        uint256 _sid,
        uint256 _amount,
        uint256 _price
    )
        public nonReentrant
    {
        require (_selling[_sid].status == SaleStatus.OPEN, "ENEFTiMP.26.NOT_FOR_SALE"); // Item is not for sale!
        require (_selling[_sid].saleDate[0] <= block.timestamp, "ENEFTiMP.27.ITEM_WAIT_FOR_CONFIRMATION"); // Item is not yet for sale!
        require (_selling[_sid].amount >= _amount, "ENEFTiMP.28.OFFERING_AMOUNT_OVERFLOW"); // Not enough tokens for sale!
        require (address(msg.sender).balance > 0, "ENEFTiMP.29.ISSUE_TO_PAY_GAS"); // Not enough BNB to spend for Gas fee!
        require (_selling[_sid].states[1], "ENEFTiMP.30.NEGOTIATION_DISABLED"); // This item is not for negotiation!

        uint256 subTotal = ( _price * _amount );
        uint256 txFee = INEFTiMPFeeCalcExt(NEFTiMPFeeCalcExt).calcFeeOf( uint8(FeeTypes.DirectNegotiateFee), _price, _amount );
        require((subTotal + txFee) <= IERC20(NEFTi20).balanceOf(msg.sender), "ENEFTiMP.31.INSUFFICIENT_NEFTi"); // Not enough NFT token to place the offer!
        
        // transfer NFT20 negotiation price to pool
        IERC20(NEFTi20).safeTransferFrom( msg.sender, address(this), subTotal );
        // transfer NFT20 fee to owner
        IERC20(NEFTi20).safeTransferFrom( msg.sender, NEFTiReceivable, txFee );

        if (_poolNegotiating[_sid][msg.sender].value == 0) { _negotiators[_sid].push(msg.sender); }

        uint256 prevPrice = (
            _poolNegotiating[_sid][msg.sender].amount == 0
                ? 0
                : _poolNegotiating[_sid][msg.sender].value.div( _poolNegotiating[_sid][msg.sender].amount )
        );
        uint256 totalAmount = _poolNegotiating[_sid][msg.sender].amount.add( _amount );
        
        _poolNegotiating[_sid][msg.sender] = Negotiating(
            _sid,
            msg.sender,
            ( prevPrice.add(_price) * totalAmount ),
            totalAmount,
            block.timestamp,
            NegotiateStatus.OPEN
        );

        emit Negotiate(
            _sid,
            _selling[_sid].tokenId,
            _amount,
            _price,
            msg.sender,
            block.timestamp,
            uint8(NegotiateStatus.OPEN)
        );
    }

    /**
    ** 9bf7b83a
    ** @dev Seller accept an offer
    ** @param _sid          Sale ID
    ** @param _pid          Input PurchaseItems ID (client-side)
    ** @param _negotiator   Selected negotiator address
    **/
    function txAcceptDirectOffering(
        uint256 _sid,
        uint256 _pid,
        address _negotiator
    )
        public nonReentrant
    {
        require (_selling[_sid].status == SaleStatus.OPEN, "ENEFTiMP.32.SALE_HAS_PASSED"); // Item is not for sale anymore!
        require (
            (_selling[_sid].amount > 0) &&
            (_poolSales[msg.sender][_selling[_sid].tokenId] > 0) &&
            (_selling[_sid].amount >= _poolNegotiating[_sid][_negotiator].amount),
            "ENEFTiMP.33.SALE_AMOUNT_UNDERFLOW"
        ); // Not enough tokens at pool for sale!
        require (_poolNegotiating[_sid][_negotiator].status == NegotiateStatus.OPEN, "ENEFTiMP.34.OFFER_HAS_PASSED"); // This negotiation is not available anymore!
        require (_poolNegotiating[_sid][_negotiator].amount > 0, "ENEFTiMP.35.UNDEFINED_OFFERING_AMOUNT"); // Current negotiation amount was not set!
        
        uint256 subTotal = _poolNegotiating[_sid][_negotiator].value;
        uint256 txFee = INEFTiMPFeeCalcExt(NEFTiMPFeeCalcExt).calcFeeOf(
            uint8(FeeTypes.DirectTransactionFee),
            subTotal,
            1
        );
        
        // transfer NFT20 purchased value to seller - fee
        IERC20(NEFTi20).safeTransfer( _selling[_sid].seller, subTotal.sub(txFee) );
        // transfer NFT20 fee to owner
        IERC20(NEFTi20).safeTransfer( NEFTiReceivable, txFee );
        // transfer NFT1155 asset to buyer
        INEFTiMultiTokens(NEFTiMT).safeTransferFrom( address(this), _negotiator, _selling[_sid].tokenId, _poolNegotiating[_sid][_negotiator].amount, "" );
        
        uint256 updateAmount = _selling[_sid].amount.sub(1);
        _poolSales[msg.sender][_selling[_sid].tokenId] = updateAmount;
        _selling[_sid].amount = updateAmount;

        if (_selling[_sid].amount == 0) { _selling[_sid].status = SaleStatus.FULFILLED; }
        
        _poolNegotiating[_sid][_negotiator].status = NegotiateStatus.FULFILLED;
        
        emit Purchase(
            _pid,
            _sid,
            _selling[_sid].tokenId,
            _poolNegotiating[_sid][_negotiator].value.div( _poolNegotiating[_sid][_negotiator].amount ), /** price  */ 
            _poolNegotiating[_sid][_negotiator].amount, /** amount */ 
            1,
            _selling[_sid].seller,
            [ false, false, false, false ],
            uint8(PurchaseStatus.FULFILLED)
        );
    }


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~ PURCHASING - AUCTION ~~~~~~~█║
    ╚════════════════════════════════════*/

    /**
    ** 5f212d35
    ** @dev Buyer bid an offer
    ** @param _sid      Sale ID
    ** @param _price    Price to bid
    **/
    function txBid(
        uint256 _sid,
        uint256 _price
    )
        public nonReentrant
    {
        require (_selling[_sid].status == SaleStatus.OPEN, "ENEFTiMP.36.NOT_FOR_AUCTION"); // Item is not for auction!
        require (_selling[_sid].saleDate[0] <= block.timestamp, "ENEFTiMP.37.ITEM_WAIT_FOR_CONFIRMATION"); // Item is not yet for sale!

        uint256 txFee = INEFTiMPFeeCalcExt(NEFTiMPFeeCalcExt).calcFeeOf(uint8(FeeTypes.AuctionBiddingFee), _price, 1);
        require ((_price + txFee) <= IERC20(NEFTi20).balanceOf(msg.sender), "ENEFTiMP.38.INSUFFICIENT_NEFTi"); // Not enough NFT token to bid in auction!
        require (address(msg.sender).balance > 0, "ENEFTiMP.39.ISSUE_TO_PAY_GAS"); // Not enough BNB to spend for Gas fee!

        // when Auction
        if (_selling[_sid].states[2]) {
            require (_price >= _selling[_sid].values[2], "ENEFTiMP.40.BID_UNDERFLOW_THE_MULTIPLIER"); // Bid value less than required multiplier!

            uint256 _totalBids = _poolBidding[_sid][msg.sender].add(_price);
            require ((_selling[_sid].values[1] + _selling[_sid].values[1]) < _totalBids, "ENEFTiMP.41.BID_UNDERFLOW_THE_HIGHEST"); // Price is too lower than highest bid!

            // send NFT20 to auction pool
            IERC20(NEFTi20).safeTransferFrom( msg.sender, address(this), _price );
            // send fee NFT20 to owner
            IERC20(NEFTi20).safeTransferFrom( msg.sender, NEFTiReceivable, txFee );

            if (_poolBidding[_sid][msg.sender] == 0) { _bidders[_sid].push(msg.sender); }

            // if exist and higher than the highest bid, update to auction bidding pool
            _poolBidding[_sid][msg.sender] = _totalBids;

            // update highest bidder price and address
            _selling[_sid].values[1] = _totalBids;
            _selling[_sid].buyer = msg.sender;
            
            _poolBidding[_sid][msg.sender] = _totalBids;

            emit Bid(
                _sid,
                _selling[_sid].tokenId,
                _selling[_sid].amount,
                _totalBids,
                msg.sender,
                block.timestamp,
                uint8(NegotiateStatus.OPEN)
            );
        }
        // This item is not for auction!
        else { revert("ENEFTiMP.42.ITEM_NOT_FOR_AUCTION"); }
    }

    /**
    ** da064fc0
    ** @dev Buyer accept an offer of highest bid
    ** @param _sid  Sale ID
    ** @param _pid  Input PurchaseItems ID (client-side)
    **/
    function txAcceptAuctionBid(
        uint256 _sid,
        uint256 _pid
    )
        public nonReentrant
    {
        require (_selling[_sid].status == SaleStatus.OPEN, "ENEFTiMP.43.AUCTION_HAS_PASSED"); // Item is not for auction anymore!
        require (
            (_selling[_sid].amount > 0) &&
            (_poolSales[msg.sender][_selling[_sid].tokenId] > 0),
            "ENEFTiMP.44.BID_AMOUNT_OVERFLOW"
        ); // Not enough tokens at pool for sale!
        
        require (_selling[_sid].buyer != address(0), "ENEFTiMP.45.INVALID_BIDDER"); // Current bidder address was not set!
        require (_poolBidding[_sid][_selling[_sid].buyer] > 0, "ENEFTiMP.46.INVALID_BID_VALUE"); // Current bid value was not available!
        require (_selling[_sid].values[1] > 0, "ENEFTiMP.47.UNDEFINED_HIGHEST_BID"); // Highest bid value was not set!
        
        uint256 txFee = INEFTiMPFeeCalcExt(NEFTiMPFeeCalcExt).calcFeeOf( uint8(FeeTypes.AuctionTransactionFee), _selling[_sid].values[1], 0x01 );
        
        uint256 subTotal = _selling[_sid].values[1];
        
        // transfer NFT20 purchased value to seller - fee
        IERC20(NEFTi20).safeTransferFrom( address(this), _selling[_sid].seller, subTotal.sub(txFee) );
        // transfer NFT20 fee to owner
        IERC20(NEFTi20).safeTransferFrom( address(this), NEFTiReceivable, txFee );
        // transfer NFT1155 asset to buyer
        INEFTiMultiTokens(NEFTiMT).safeTransferFrom( address(this), _selling[_sid].buyer, _selling[_sid].tokenId, _selling[_sid].amount, "" );
        
        uint256 updateAmount = _selling[_sid].amount.sub(1);
        _poolSales[msg.sender][_selling[_sid].tokenId] = updateAmount;
        _selling[_sid].amount = updateAmount;
        if (_selling[_sid].amount == 0) { _selling[_sid].status = SaleStatus.FULFILLED; }
        _poolBidding[_sid][_selling[_sid].buyer] = 0;
        
        emit Purchase(
            _pid,
            _sid,
            _selling[_sid].tokenId,
            /* price  */ _poolBidding[_sid][ _selling[_sid].buyer ].div( _selling[_sid].amount ),
            /* amount */ _selling[_sid].amount,
            1,
            _selling[_sid].seller,
            [ false, false, true, false ],
            uint8(PurchaseStatus.FULFILLED)
        );
    }


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~~ MISCELLANEOUS ~~~~~~~~~~█║
    ╚════════════════════════════════════*/

    /**
    ** f3c2e296
    ** @dev Caller is refers to a smart contract
    ** @return The acceptance magic value
    **/
    function onERC1155Received(address, address, uint256, uint256, bytes calldata)
        external pure
        returns(bytes4)
    { return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)")); }

    /**
    ** 1cb8a750
    ** @dev Default Payment info
    ** @return (
    **    tokenContract - ERC20 contract address
    **    decimals      - ERC20 decimals
    **    priceUSD      - Equivalent value in USD
    ** )
    **/
    function defaultPayment()
        public view
        returns (address tokenContract, uint8 decimals, uint256 priceUSD)
    { (tokenContract, decimals, priceUSD) = INEFTiMPFeeCalcExt(NEFTiMPFeeCalcExt).defaultPayment(); }

    /**
    ** c1f7235a
    ** @dev Get Calculated Fees
    ** @param _price    Item price
    ** @param _amount   Amount of item
    ** @return List of calculated fees
    ** +--->   uint256 DirectListingFee,
    ** +--->   uint256 DirectListingCancellationFee,
    ** +--->   uint256 DirectNegotiateFee,
    ** +--->   uint256 DirectNegotiateCancellationFee,
    ** +--->   uint256 DirectTransactionFee,
    ** +--->   uint256 AuctionListingFee,
    ** +--->   uint256 AuctionListingCancellationFee,
    ** +--->   uint256 AuctionBiddingFee,
    ** +--->   uint256 AuctionBiddingCancellationFee,
    ** +--->   uint256 AuctionTransactionFee
    **/
    function feesOf(uint256 _price, uint256 _amount)
        public view
        returns (uint256[11] memory fees)
    {   
        // uint256[11] memory fees;
        fees[0] = 0;
        for (uint8 i=1; i<11; i++) { fees[i] = INEFTiMPFeeCalcExt(NEFTiMPFeeCalcExt).calcFeeOf(i, _price, _amount); }
        // return fees;
    }

    /**
    ** 2612ddc0
    ** @dev Update External Relationship
    ** @param _extType   External type
    ** @param _extTarget External address
    **/
    function updateExtRelationship(uint8 _extType, address _extTarget)
        public onlyOwner
    {
        if (ExternalRelationship(_extType) == ExternalRelationship.NEFTi20) { NEFTi20 = _extTarget; }
        else if (ExternalRelationship(_extType) == ExternalRelationship.NEFTiMultiTokens) { NEFTiMT = _extTarget; }
        else if (ExternalRelationship(_extType) == ExternalRelationship.NEFTiMPFeeCalcExt) { NEFTiMPFeeCalcExt = _extTarget; }
        else { revert("ENEFTiMP.48.INVALID_EXTERNAL_RELATIONSHIP"); } // Invalid external relationship type
        emit UpdateExternalRelationship(_extType, _extTarget);
    }

    /**
    ** 4b28fc21
    ** @dev Update Receivable account
    ** @param _NEFTiAccount Account address
    **/
    function updateReceivable(address _NEFTiAccount)
        public onlyOwner
    {
        require(_NEFTiAccount != address(0), "ENEFTiMP.49.INVALID_NEFTi_ACCOUNT");
        NEFTiReceivable = _NEFTiAccount;
        emit UpdateReceivableTo(_NEFTiAccount);
    }

    /**
    ** 220a8b22
    ** @dev Send Asset
    ** @param _to       Receiver address
    ** @param _tokenId  Asset ID
    ** @param _amount   Asset amount
    **/
    function sendAssets(address _to, uint256 _tokenId, uint256 _amount)
        public nonReentrant onlyOwner
    {
        require(_amount > 0, "ENEFTiMP.50.INVALID_AMOUNT"); // Amount must be greater than 0
        require(_tokenId > 0, "ENEFTiMP.51.INVALID_TOKEN_ID"); // Token ID must be greater than 0
        INEFTiMultiTokens cNEFTiMT = INEFTiMultiTokens(NEFTiMT);
        require(cNEFTiMT.balanceOf(address(this), _tokenId) >= _amount, "ENEFTiMP.52.INSUFFICIENT_FOR_TOKEN_ID"); // Insufficient tokens
        cNEFTiMT.safeTransferFrom(address(this), _to, _tokenId, _amount, "");
    }

    /**
    ** 88436dbd
    ** @dev Send Currency
    ** @param _tokenContract    Receiver address
    ** @param _to               Asset ID
    ** @param _amount           Asset amount
    **/
    function sendCurrencies(address _tokenContract, address _to, uint256 _amount)
        public nonReentrant onlyOwner
    {
        require(_amount > 0, "ENEFTiMP.53.INVALID_AMOUNT"); // Amount must be greater than 0
        if (_tokenContract != address(0)) {
            IERC20 _ERC20 = IERC20(_tokenContract);
            require(_ERC20.balanceOf(address(this)) >= _amount, "ENEFTiMP.54.INSUFFICIENT_ERC20"); // Insufficient tokens
            _ERC20.safeTransfer(_to, _amount);
        } else {
            (bool sent, ) = address(this).call{ value: _amount }("");
            require(sent, "ENEFTiMP.55.INSUFFICIENT_BALANCE"); // Insufficient Balance
        }
    }

    /**
    ** b6485833
    ** @dev Suspending Sale item
    ** @param _sid          Sale ID
    ** @param _isSuspended  True/False
    **/
    function suspend(uint256 _sid, bool _isSuspended)
        public onlyOwner
    {
        require(_sid > 0, "ENEFTiMP.56.INVALID_SALE_ITEM_ID"); // Sale item ID must be greater than 0
        _selling[_sid].status = (_isSuspended  ? SaleStatus.SUSPENDED : SaleStatus.OPEN);
        emit Suspended(_sid, _selling[_sid].tokenId, _selling[_sid].seller, _isSuspended);
    }

    /**
    ** f7cced22
    ** @dev Delisting Sale item
    ** @param _sid          Sale ID
    **/
    function delist(uint256 _sid)
        public onlyOwner
    {
        require(_sid > 0, "ENEFTiMP.57.INVALID_SALE_ITEM_ID"); // Sale item ID must be greater than 0
        INEFTiMultiTokens(NEFTiMT).safeTransferFrom( address(this), _selling[_sid].seller, _selling[_sid].tokenId, _selling[_sid].amount, "" );
        _selling[_sid].status = SaleStatus.DELISTED;
        emit Delisted(_sid, _selling[_sid].tokenId, _selling[_sid].seller);
    }

    /**
    ** @dev NEFTi Marketplace contract constructor
    ** @params _NEFTi20 - address of ERC20 contract for NFT20
    ** @params _NEFTiMT - address of ERC1155 contract for NFT1155
    ** @params _NEFTiMPFeeCalcExt - address of NEFTi MP Fee Calc Extension contract
    ** @params _NEFTiReceivable - address of NEFTi Receivable contract
    **/
    constructor(
      address _Busd20, 
      address _NEFTiMT, 
      address _NEFTiMPFeeCalcExt, 
      address _NEFTiAccount
    )
    {
        NEFTi20 = _Busd20;
        NEFTiMT = _NEFTiMT;
        NEFTiMPFeeCalcExt = _NEFTiMPFeeCalcExt;
        NEFTiReceivable = _NEFTiAccount;
    }

    /*════════════════════════════oooooOooooo════════════════════════════╗
    ║█  (!) WARNING  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~█║
    ╚════════════════════════════════════════════════════════════════════╝
    ║  There are no handler in fallback function,                        ║
    ║  If there are any incoming value directly to Smart Contract, will  ║
    ║  considered as generous donation. And Thank you!                   ║
    ╚═══════════════════════════════════════════════════════════════════*/
    receive () external payable /* nonReentrant */ {}
    fallback () external payable /* nonReentrant */ {}
}

/**
**    █▄░█ █▀▀ █▀▀ ▀█▀ █ █▀█ █▀▀ █▀▄ █ ▄▀█
**    █░▀█ ██▄ █▀░ ░█░ █ █▀▀ ██▄ █▄▀ █ █▀█
**    ____________________________________
**    https://neftipedia.com
**    [email protected]
**/

// SPDX-License-Identifier: MIT

// pragma solidity ^0.8.0;
pragma solidity >=0.7.4 <=0.8.9;

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

// SPDX-License-Identifier: MIT OR Apache-2.0

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

pragma solidity >=0.7.4 <=0.8.9;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner_;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor () {
    _owner_ = msg.sender;
    emit OwnershipTransferred(address(0), _owner_);
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == _owner_, "ENEFTiOA__onlyOwner__SENDER_IS_NOT_OWNER");
    _;
  }

  /**
   * @notice Transfers the ownership of the contract to new address
   * @param _newOwner Address of the new owner
   */
  function transferOwnership(address _newOwner)
    public onlyOwner
  {
    require(_newOwner != address(0), "ENEFTiOA__transferOwnership__INVALID_ADDRESS");
    emit OwnershipTransferred(_owner_, _newOwner);
    _owner_ = _newOwner;
  }

  /**
   * @notice Returns the address of the owner.
   */
  function owner()
    public view
    returns (address)
  { return _owner_; }
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

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/*
**    █▄░█ █▀▀ █▀▀ ▀█▀ █ █▀█ █▀▀ █▀▄ █ ▄▀█
**    █░▀█ ██▄ █▀░ ░█░ █ █▀▀ ██▄ █▄▀ █ █▀█
**    ____________________________________
**    https://neftipedia.com
**    [email protected]
**/

/** d6147a8a */
interface INEFTiLicense {
    /** 921fe338 */
    function legalInfo() external view
        returns (string memory _title, string memory _license, string memory _version, string memory _url);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.7.4 <=0.8.9;

import "./IERC1155.sol";

interface INEFTiMultiTokens is IERC1155 {

    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~~~~ FUNCTIONS ~~~~~~~~~~~~█║
    ╚════════════════════════════════════*/

    /**
    ** @notice Transfers amount of an _id from the _from address to the _to address specified
    ** @dev MUST emit TransferSingle event on success
    ** Caller must be approved to manage the _from account's tokens (see isApprovedForAll)
    ** MUST throw if `_to` is the zero address
    ** MUST throw if balance of sender for token `_id` is lower than the `_amount` sent
    ** MUST throw on any other error
    ** When transfer is complete, this function MUST check if `_to` is a smart contract (code size > 0). If so, it MUST call `onERC1155Received` on `_to` and revert if the return amount is not `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
    ** @param _from    Source address
    ** @param _to      Target address
    ** @param _id      ID of the token type
    ** @param _amount  Transfered amount
    ** @param _data    Additional data with no specified format, sent in call to `_to`
    **/
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes calldata _data) external override (IERC1155);

    /**
    ** @notice Send multiple types of Tokens from the _from address to the _to address (with safety call)
    ** @dev MUST emit TransferBatch event on success
    ** Caller must be approved to manage the _from account's tokens (see isApprovedForAll)
    ** MUST throw if `_to` is the zero address
    ** MUST throw if length of `_ids` is not the same as length of `_amounts`
    ** MUST throw if any of the balance of sender for token `_ids` is lower than the respective `_amounts` sent
    ** MUST throw on any other error
    ** When transfer is complete, this function MUST check if `_to` is a smart contract (code size > 0). If so, it MUST call `onERC1155BatchReceived` on `_to` and revert if the return amount is not `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
    ** Transfers and events MUST occur in the array order they were submitted (_ids[0] before _ids[1], etc)
    ** @param _from     Source addresses
    ** @param _to       Target addresses
    ** @param _ids      IDs of each token type
    ** @param _amounts  Transfer amounts per token type
    ** @param _data     Additional data with no specified format, sent in call to `_to`
    **/
    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external override(IERC1155);

    /**
    ** @notice Get the balance of an account's Tokens
    ** @param _owner  The address of the token holder
    ** @param _id     ID of the Token
    ** @return        The _owner's balance of the Token type requested
    **/
    function balanceOf(address _owner, uint256 _id) external view  override(IERC1155) returns (uint256);

    /**
    ** @notice Get the balance of multiple account/token pairs
    ** @param _owners The addresses of the token holders
    ** @param _ids    ID of the Tokens
    ** @return        The _owner's balance of the Token types requested (i.e. balance for each (owner, id) pair)
    **/
    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view override(IERC1155) returns (uint256[] memory);

    /**
    ** @notice Enable or disable approval for a third party ("operator") to manage all of caller's tokens
    ** @dev MUST emit the ApprovalForAll event on success
    ** @param _operator  Address to add to the set of authorized operators
    ** @param _approved  True if the operator is approved, false to revoke approval
    **/
    function setApprovalForAll(address _operator, bool _approved) external override(IERC1155);

    /**
    ** @notice Queries the approval status of an operator for a given owner
    ** @param _owner     The owner of the Tokens
    ** @param _operator  Address of authorized operator
    ** @return isOperator True if the operator is approved, false if not
    **/
    function isApprovedForAll(address _owner, address _operator) external view override(IERC1155) returns (bool isOperator);


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~ TOKEN PROPERTIES ~~~~~~~~█║
    ╚════════════════════════════════════*/

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~~~ MINT & BURN ~~~~~~~~~~~█║
    ╚════════════════════════════════════*/

    function mint(address _to, uint256 _id, uint256 _value, bytes memory _data) external payable;

    function batchMint(address _to, uint256[] memory _ids, uint256[] memory _values, bytes memory _data) external payable;

    function burn(address _from, uint256 _id, uint256 _value) external;

    function batchBurn(address _from, uint256[] memory _ids, uint256[] memory _values) external;


    /*════════════oooooOooooo═════════════╗
    ║█~~~~~~~~~~~~ UTILITIES ~~~~~~~~~~~~█║
    ╚════════════════════════════════════*/

    function requestId() external;

    function totalSupply(uint256 _id) external view returns(uint256);

    function minterOf(uint256 _id) external view returns (address);

    function itemsOf(address _holder) external view returns (uint256[] memory);

    function getMintFee(uint256 amount) external view returns(uint256[3] memory mintFee, uint256 multitokenOnEach, string memory feeAs);

    function getBatchMintFee(uint[] memory _amounts) external view returns(uint256[3] memory mintFee, uint256 multitokenOnEach, string memory feeAs);

}

/**
**    █▄░█ █▀▀ █▀▀ ▀█▀ █ █▀█ █▀▀ █▀▄ █ ▄▀█
**    █░▀█ ██▄ █▀░ ░█░ █ █▀▀ ██▄ █▄▀ █ █▀█
**    ____________________________________
**    https://neftipedia.com
**    [email protected]
**/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface INEFTiMPFeeCalcExt {
    // used
    function defaultPayment()
        external view
        returns (address tokenContract, uint8 decimals, uint256 priceUSD);

    function setDefaultPayment(address _tokenContract)
        external;

    function enablePayment(address _tokenContract)
        external;

    function disablePayment(address _tokenContract)
        external;

    function payments()
        external view
        returns (address[] memory cryptos);

    function paymentIsEnabled(address _tokenContract)
        external view
        returns (bool);
    
    function usdFeeAsToken(uint256 _usdAmount, address _tokenContract)
        external view
        returns (uint256);
    
    function paymentInfo(address _tokenContract)
        external view
        returns (uint256 index, bool isEnabled, string memory name, string memory symbol, uint8 decimals, uint256 priceUSD);

    function staticPercent() external view returns (uint256);
    
    // used
    function feeOf(uint8 feeType) external view returns (uint16);
    // used
    function calcFeeOf(uint8 _feeType, uint256 _price, uint256 _amount)
        external view
        returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.7.4 <=0.8.9;

contract NEFTiMPStorages {
    // enum ResourceClasses {
    //     IMAGE,          // 0x00,
    //     AUDIO,          // 0x01,
    //     VIDEO,          // 0x02,
    //     OBJECT3D,       // 0x03,
    //     DOCUMENT,       // 0x04,
    //     FONT,           // 0x05,
    //     REDEEMABLE,     // 0x06,
    //     GAMEASSETS      // 0x07,
    // }

    enum SaleMethods {
        DIRECT,         // 0x00,                                    (1) seller pays gas to get listing,
                        //                                          (2) buyer pays gas to purchase,
                        //                                          (3) seller receive payment from buyer - transaction fee

        AUCTION         // 0x01,                                    (1) seller pays gas and auction listing fee,
                        //                                          (2) bidder pays gas for each bids to purchase,
                        //                                          (3) auction which have no bidder are able cancel by seller, costs gas
                        //                                          (4) bidder pays gas for cancellation, also costs transaction fee
                        //                                          (5) bidder unable to cancel bids last 1 hour before auction time expired
                        //                                          (6) seller may claim the highest bid when auction was completed
                        //                                              within 1 hour after the expiration time, cost gas and transaction fee
                        //                                          (7) or the company pays gas to set auto-expired for auction after 1 hour
    }

    enum FeeTypes {
        none,
        
        DirectListingFee,                                           // FREE
        DirectListingCancellationFee,                               // FREE
        DirectNegotiateFee,                                         // FREE
        DirectNegotiateCancellationFee,                             // 0.5% x Negotiate Price
        DirectTransactionFee,                                       // 0.8% x Item Price

        AuctionListingFee,                                          // 0.3% x Item Price
        AuctionListingCancellationFee,                              // 0.5% x Item Price
        AuctionBiddingFee,                                          // 0.1% x Bid Price
        AuctionBiddingCancellationFee,                              // 0.5% x Bid Price
        AuctionTransactionFee                                       // 0.8% x Item Price
    }

    enum SaleStatus {
        OPEN,           // 0x00,    sale is open                    (gas pays by the seller)
        FULFILLED,      // 0x01,    sale is filfilled               (gas pays by the buyer)
        RENTING,        // 0x02,    an item goes on rent                
        PAUSED,         // 0x03,    an item paused                  (gas pays by the seller)                
        CANCELED,       // 0x04,    sale is cancelled               (gas may pays by the seller or the buyer)
        EXPIRED,        // 0x05,    sale is expired                 (gas may pays by the seller or the company)
        SUSPENDED,      // 0x06,    sale is suspended               (gas pays by the company)
        DELISTED        // 0x07,    sale is delisted                (gas pays by the company)
    }

    enum PurchaseStatus {
        ACCEPTED,       // 0x00,    sale is open                    (gas pays by the seller)
        SENDING,        // 0x01,    sale is closed                  (gas pays by the buyer)
        INPROGRESS,     // 0x02,    an item goes on rent            
        REJECTED,       // 0x03,    an item on escrow               
        FULFILLED       // 0x04,    sale is cancelled               (gas may pays by the seller or the buyer)
    }

    enum NegotiateStatus {
        OPEN,           // 0x00,    negotiation is open             (gas pays by the buyer as negotiator)
        SENDING,        // 0x01,    negotiation OK, sending         (gas pays by the seler to accept, and sending items)
        INPROGRESS,     // 0x02,    negotiation OK, in progress     (gas pays by the seler to accept, and in progress)
        FULFILLED,      // 0x03,    negotiation is fulfilled        (gas pays by the buyer to fulfill the rent)
        REJECTED,       // 0x04,    negotiation is rejected         (gas pays by the seller to reject)
        CANCELED        // 0x05,    IF BUYER cancel negotiation     (gas pays by the buyer, also charge cancellation fee as income to the company)
                        //          IF SELLER cancel negotiation    (gas pays by the seller, also charge cancellation fee as income to the company)
    }

    enum ExternalRelationship {
        _NONE_,
        NEFTi20,
        NEFTiMultiTokens,
        NEFTiMPFeeCalcExt
    }

    struct SaleItems {
        uint256    tokenId;
        uint256    price;
        uint256    amount;
        address    seller;
        bool[4]    states;
        //+----->  bool isPostPaid;
        //+----->  bool isNegotiable;
        //+----->  bool isAuction;
        //+----->  bool isContract;
        uint256[2] saleDate;
        uint256[3] values;
        //+----->  uint256 valContract;
        //+----->  uint256 highBid;
        //+----->  uint256 bidMultiplier;
        address    buyer;
        SaleStatus status;
    }

    struct Negotiating {
        uint256         saleHash;
        address         negosiator;
        uint256         value;
        uint256         amount;
        uint256         negoDate;
        NegotiateStatus status;
    }

    // @dev Sale Pool
    // @params address Seller address
    // @params uint256 TokenId
    // @return uint256 Balance amount of token
    mapping (address => mapping (uint256 => uint256)) internal _poolSales;

    // @dev Sale Pool Info
    // @params uint256 Sale ID
    // @return SaleItems struct of SaleItems
    mapping (uint256 => SaleItems) internal _selling;

    // @dev Listed items by Seller address
    // @params address Seller address
    // @return uint256[] Sale Ids
    mapping (address => uint256[]) internal _itemsOnSaleItems;

    // @dev All listed items Sale Ids
    // uint256[] internal _saleItems;
    
    // @dev Bidding pool for Auction
    // @params uint256 Sale/Auction ID
    // @params address Buyers (_bidders)
    // @return uint256 Bid value
    mapping (uint256 => mapping (address => uint256)) internal _poolBidding;

    // @dev Negotiation pool
    // @params uint256 Sale ID
    // @params address Negotiator
    // @return uint256 Negotiating Info
    mapping (uint256 => mapping (address => Negotiating)) internal _poolNegotiating;

    // @dev Bidders in Auction
    // @params uint256 Sale ID
    // @return address[] Bidders
    mapping (uint256 => address[]) _bidders;

    // @dev Negotiators in Sale
    // @params uint256 Sale ID
    // @return address[] Negotiators
    mapping (uint256 => address[]) _negotiators;

    // mapping (address => uint256) internal txNonce;
}

/**
**    █▄░█ █▀▀ █▀▀ ▀█▀ █ █▀█ █▀▀ █▀▄ █ ▄▀█
**    █░▀█ ██▄ █▀░ ░█░ █ █▀▀ ██▄ █▄▀ █ █▀█
**    ____________________________________
**    https://neftipedia.com
**    [email protected]
**/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Address.sol";

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

// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.7.4 <=0.8.9;


interface IERC1155 {

  /****************************************|
  |                 Events                 |
  |_______________________________________*/

  /**
   * @dev Either TransferSingle or TransferBatch MUST emit when tokens are transferred, including zero amount transfers as well as minting or burning
   *   Operator MUST be msg.sender
   *   When minting/creating tokens, the `_from` field MUST be set to `0x0`
   *   When burning/destroying tokens, the `_to` field MUST be set to `0x0`
   *   The total amount transferred from address 0x0 minus the total amount transferred to 0x0 may be used by clients and exchanges to be added to the "circulating supply" for a given token ID
   *   To broadcast the existence of a token ID with no initial balance, the contract SHOULD emit the TransferSingle event from `0x0` to `0x0`, with the token creator as `_operator`, and a `_amount` of 0
   */
  event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _amount);

  /**
   * @dev Either TransferSingle or TransferBatch MUST emit when tokens are transferred, including zero amount transfers as well as minting or burning
   *   Operator MUST be msg.sender
   *   When minting/creating tokens, the `_from` field MUST be set to `0x0`
   *   When burning/destroying tokens, the `_to` field MUST be set to `0x0`
   *   The total amount transferred from address 0x0 minus the total amount transferred to 0x0 may be used by clients and exchanges to be added to the "circulating supply" for a given token ID
   *   To broadcast the existence of multiple token IDs with no initial balance, this SHOULD emit the TransferBatch event from `0x0` to `0x0`, with the token creator as `_operator`, and a `_amount` of 0
   */
  event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _amounts);

  /**
   * @dev MUST emit when an approval is updated
   */
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);


  /****************************************|
  |                Functions               |
  |_______________________________________*/

  /**
    * @notice Transfers amount of an _id from the _from address to the _to address specified
    * @dev MUST emit TransferSingle event on success
    * Caller must be approved to manage the _from account's tokens (see isApprovedForAll)
    * MUST throw if `_to` is the zero address
    * MUST throw if balance of sender for token `_id` is lower than the `_amount` sent
    * MUST throw on any other error
    * When transfer is complete, this function MUST check if `_to` is a smart contract (code size > 0). If so, it MUST call `onERC1155Received` on `_to` and revert if the return amount is not `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
    * @param _from    Source address
    * @param _to      Target address
    * @param _id      ID of the token type
    * @param _amount  Transfered amount
    * @param _data    Additional data with no specified format, sent in call to `_to`
    */
  function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes calldata _data) external;

  /**
    * @notice Send multiple types of Tokens from the _from address to the _to address (with safety call)
    * @dev MUST emit TransferBatch event on success
    * Caller must be approved to manage the _from account's tokens (see isApprovedForAll)
    * MUST throw if `_to` is the zero address
    * MUST throw if length of `_ids` is not the same as length of `_amounts`
    * MUST throw if any of the balance of sender for token `_ids` is lower than the respective `_amounts` sent
    * MUST throw on any other error
    * When transfer is complete, this function MUST check if `_to` is a smart contract (code size > 0). If so, it MUST call `onERC1155BatchReceived` on `_to` and revert if the return amount is not `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
    * Transfers and events MUST occur in the array order they were submitted (_ids[0] before _ids[1], etc)
    * @param _from     Source addresses
    * @param _to       Target addresses
    * @param _ids      IDs of each token type
    * @param _amounts  Transfer amounts per token type
    * @param _data     Additional data with no specified format, sent in call to `_to`
  */
  function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external;

  /**
   * @notice Get the balance of an account's Tokens
   * @param _owner  The address of the token holder
   * @param _id     ID of the Token
   * @return        The _owner's balance of the Token type requested
   */
  function balanceOf(address _owner, uint256 _id) external view returns (uint256);

  /**
   * @notice Get the balance of multiple account/token pairs
   * @param _owners The addresses of the token holders
   * @param _ids    ID of the Tokens
   * @return        The _owner's balance of the Token types requested (i.e. balance for each (owner, id) pair)
   */
  function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);

  /**
   * @notice Enable or disable approval for a third party ("operator") to manage all of caller's tokens
   * @dev MUST emit the ApprovalForAll event on success
   * @param _operator  Address to add to the set of authorized operators
   * @param _approved  True if the operator is approved, false to revoke approval
   */
  function setApprovalForAll(address _operator, bool _approved) external;

  /**
   * @notice Queries the approval status of an operator for a given owner
   * @param _owner     The owner of the Tokens
   * @param _operator  Address of authorized operator
   * @return isOperator True if the operator is approved, false if not
   */
  function isApprovedForAll(address _owner, address _operator) external view returns (bool isOperator);

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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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