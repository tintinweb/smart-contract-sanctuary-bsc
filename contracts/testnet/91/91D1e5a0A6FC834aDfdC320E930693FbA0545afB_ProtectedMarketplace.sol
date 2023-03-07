/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

// SPDX-License-Identifier: No License (None)

pragma solidity ^0.8.0;
// pragma experimental ABIEncoderV2;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

interface IDepository {
    function deposit() external payable returns(uint256);
    function withdraw(uint256 depositId) external returns(uint256);
    function withdrawVToken(uint256 depositId) external returns(uint256 value);
}

interface VBep20Interface {
    function transfer(address dst, uint amount) external returns (bool);
    function balanceOfUnderlying(address owner) external returns (uint);
}

interface IDerivativeFactory {
    function isDerivative(address _nftContract) external view returns (bool);
}

interface IVault {
    function withdraw(address _to, uint256 _value) external returns(uint256 balance);
    function owner() external view returns (address);
}

contract ProtectedMarketplace {
    IDepository public depository;
    VBep20Interface public vBNB;    // Venus BNB token contract
    IDerivativeFactory public derivativeFactory;    // NFT sub collection factory

    enum OrderType { FixedPay, AuctionType }
    enum OrderStatus { Active, Bidded, UnderDownsideProtectionPhase, Completed, Cancelled }
    enum BidStatus { NotAccepted, Pending, Refunded, Executed }
    enum OfferStatus { NotCreated, Active, UnderDownsideProtectionPhase, Completed, Cancelled }

    struct OrderArgs {
        address tokenAddress;   // NFT contract address
        uint256 nftTokenId;     // and token id
        uint256 tokenPrice;     // Fix price or start price of auction
        bool useDepository;    // set if will use depository for downside protection
        uint64 protectionRate; // downside protection rate in percentage with 2 decimals (i.e. 3412 = 34.12%)
        bool isFixedProtection;    // false -> soldTime + protectionTime, true -> fix date
        uint256 protectionTime; // downside protection duration (in seconds). I.e. 604800 = 1 week (60*60*24*7)
        bool acceptOffers;  // false = fix price order, true - auction order
        uint256 offerClosingTime;   // Epoch time (in seconds) when auction will be closed
    }

    struct Order {
        OrderStatus statusOrder;
        OrderType typeOrder;
        address tokenAddress;
        uint256 nftTokenId;
        bool isDerivativeNft;
        address payable sellerAddress;
        address payable buyerAddress;
        uint256 tokenPrice; // In fix sale - token price. Auction: start price or max offer price
        // protection
        bool useDepository;
        uint256 protectionAmount;
        uint256 depositId;
        uint64 protectionRate;  // in percent with 2 decimals
        bool isFixedProtection; // false -> soldTime + protectionTime, true -> fix date
        uint256 protectionTime;
        //uint256 protectionExpiryTime = soldTime + protectionTime
        uint256 soldTime; // time when order sold, if equal to 0 than order unsold (so no need to use additional variable "bool saleNFT")
        //suborder
        uint256 offerClosingTime;
        uint256[] subOrderList;
    }

    struct SubOrder {
        //uint256 subOrderId;
        uint256 orderId; //original order ID
        address payable buyerAddress;
        uint256 tokenPrice;
        uint64 protectionRate;
        uint256 protectionTime;
        uint256 validUntil;
    }

    address payable public company;     // company address
    uint256 public companyFeeRate;       // company fee rate in percent (with 2 decimals) (current rate 2%)
    uint256 public derivativeFeeRate;   // Extra company fee for Derivative NFTs

    uint256 public orderIdCount;
    uint256 public subOrderIdCount;

    mapping(uint256 => Order) orders;                     // identify offers by orderID
    mapping(uint256 => SubOrder) public subOrders;                     // identify offers by orderID
    mapping (address => mapping(uint256 => BidStatus)) public buyerBidStatus;       // To check a buyer's bid status(can be used in frontend)

    struct Offer {
        OfferStatus statusOffer;
        address tokenAddress;
        uint256 nftTokenId;
        bool isDerivativeNft;
        address payable sellerAddress;
        address payable buyerAddress;
        bool useVault;
        address vaultAddress;
        uint256 tokenPrice; // token price
        // protection
        bool useDepository;
        uint256 protectionAmount;
        uint256 depositId;
        uint64 protectionRate;  // in percent with 2 decimals
        uint256 protectionTime;
        //uint256 protectionExpiryTime = soldTime + protectionTime
        uint256 soldTime; // time when order sold, if equal to 0 than order unsold (so no need to use additional variable "bool saleNFT")
        uint256 offerExpiration;
    }

    uint256 public offerIdCount;
    mapping(uint256 => Offer) offers;                     // identify offers by offerID
    // order event
    event CreateOrder(uint256 orderID, OrderType typeOrder);
    event BuyOrder(uint256 orderID, OrderType typeOrder, address indexed buyerAddress, uint256 protectionAmount, uint256 protectionExpiryTime);
    event ClaimDownsideProtection(uint256 orderID, uint256 statusOrder, uint256 soldTime, address indexed buyerOrSeller, uint256 claimAmount);
    event ClaimDownsideProtectionByVToken(uint256 orderID, uint256 statusOrder, uint256 soldTime, address indexed buyerOrSeller, uint256 claimAmount);
    event CreateSubOrder(uint256 orderID, OrderType typeOrder, address indexed buyerAddress, uint256 tokenPrice, uint64 protectionRate, uint256 validUntil);
    event CreateBid(uint256 orderID, OrderType typeOrder, address indexed buyerAddress, uint256 bidAmount);
    event UpdateBid(uint256 orderID, OrderType typeOrder, address indexed bidderAddress, uint256 increaseAmount);
    event CompanyChanged(address indexed oldCompany, address indexed newCompany);
    event CompanyFeeRateChanged(uint256 oldCompanyRate, uint256 _companyFeeRate, uint256 oldDerivativeRate, uint256 _derivativeFeeRate);
    event CancelOrder(uint256 orderID);
    // offer event
    event CreateOffer(uint256 offerID);
    event AcceptOffer(uint256 offerID, address indexed sellerAddress, uint256 protectionAmount, uint256 protectionExpiryTime);
    event ClaimDownsideProtectionInOffer(uint256 offerID, uint256 statusOrder, uint256 soldTime, address indexed buyerOrSeller, uint256 claimAmount);
    event ClaimDownsideProtectionInOfferByVToken(uint256 offerID, uint256 statusOrder, uint256 soldTime, address indexed buyerOrSeller, uint256 claimAmount);
    event CancelOffer(uint256 offerID);

    // Initialize a valid company and a non zero fee rate
    //constructor (address payable _company, uint256 _companyFeeRate, address payable _depository) public {
    function initialize (address payable _company, uint256 _companyFeeRate, uint256 _derivativeFeeRate, address payable _depository, address _vBNB, address _derivativeFactory) public {
        require(company == address(0), "Already initialized");
        require(_company != address(0) && _companyFeeRate > 0 && _companyFeeRate < 10000, "Invalid company and details");
        require(_depository != address(0), "Invalid depository");
        require(_vBNB != address(0), "Invalid vBNB");
        company = _company;
        companyFeeRate = _companyFeeRate;
        derivativeFeeRate = _derivativeFeeRate;
        depository = IDepository(_depository);
        vBNB = VBep20Interface(_vBNB);
        derivativeFactory = IDerivativeFactory(_derivativeFactory);
    }

    // To receive BNB from depository
    receive() external payable {}

    modifier createSubOrderValidator(uint256 _orderId) {
        Order storage order = orders[_orderId];
        require(order.statusOrder == OrderStatus.Active, "Invalid OrderStatus");   
        require(order.typeOrder == OrderType.FixedPay, "Invalid OrderType");   // AuctionType orders are directly executed by seller
        require(order.sellerAddress == msg.sender, "Invalid Authentication");  
        _;
    }

    modifier onlySeller(uint256[] memory _orderIds) {
        for (uint256 i = 0; i < _orderIds.length; i ++ ) {
            Order storage order = orders[_orderIds[i]];
            require(msg.sender == order.sellerAddress, "Invalid Authentication");
        }
        _;
    }

    modifier onlyBuyerOrExpired(uint256 _offerId) {
        Offer storage offer = offers[_offerId];
        require(msg.sender == offer.buyerAddress || block.timestamp > offer.offerExpiration, "Invalid Authentication");
        _;
    }

    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function createOrder(
        OrderArgs[] memory _orderArgs
    ) external {
        for (uint256 i = 0; i < _orderArgs.length; i ++) {
            require(IERC721(_orderArgs[i].tokenAddress).ownerOf(_orderArgs[i].nftTokenId) == msg.sender, "Invalid token owner");
            require(_orderArgs[i].tokenPrice > 0, "Invalid token price");
            if(_orderArgs[i].acceptOffers){
                require(_orderArgs[i].offerClosingTime > 0, "AuctionType orders need a closing time");
            }
            require(_orderArgs[i].protectionRate <= 10000 , "ProtectedMarketplace::createOrder: Protection rate above 100 percent");

            IERC721(_orderArgs[i].tokenAddress).safeTransferFrom(msg.sender, address(this), _orderArgs[i].nftTokenId);

            orderIdCount++;
            Order storage order = orders[orderIdCount];

            // Update the Order
            order.statusOrder = OrderStatus.Active;
            order.tokenAddress = _orderArgs[i].tokenAddress;
            order.nftTokenId = _orderArgs[i].nftTokenId;
            order.isDerivativeNft = derivativeFactory.isDerivative(_orderArgs[i].tokenAddress);
            order.sellerAddress = payable(msg.sender);
            order.buyerAddress = payable(address(0));
            order.tokenPrice = _orderArgs[i].tokenPrice;
            order.useDepository = _orderArgs[i].useDepository;
            order.protectionRate = _orderArgs[i].protectionRate;
            order.isFixedProtection = _orderArgs[i].isFixedProtection;
            order.protectionTime = _orderArgs[i].protectionTime;
            order.typeOrder = _orderArgs[i].acceptOffers ? OrderType.AuctionType : OrderType.FixedPay;
            order.offerClosingTime = _orderArgs[i].acceptOffers ? _orderArgs[i].offerClosingTime : 0;
            
            emit CreateOrder(orderIdCount, order.typeOrder);
        }
    }

    function createSubOrder(
        uint256 _orderId, //original order ID
        address payable _buyerAddress, // address of buyer who may accept this offer
        uint256 _tokenPrice,    // new offer price
        uint64 _protectionRate, // new protection rate in percentage with 2 decimals (i.e. 3412 = 34.12%)
        uint256 _protectionTime,// new downside protection duration (in seconds). I.e. 604800 = 1 week (60*60*24*7)
        uint256 _validUntil // Epoch time (in seconds) until offer is valid
    )
    external
    createSubOrderValidator(_orderId)
    {   
        require(_protectionRate <= 10000, "Protection rate above 100 percent");
        Order storage order = orders[_orderId];
        require(msg.sender == order.sellerAddress, "Invalid Authentication");

        subOrderIdCount++;
        SubOrder memory subOrder;
        //subOrder.subOrderId = subOrderIdCount;
        subOrder.orderId = _orderId;
        subOrder.buyerAddress = _buyerAddress;
        subOrder.tokenPrice = _tokenPrice;
        subOrder.protectionRate = _protectionRate;
        subOrder.protectionTime = _protectionTime;
        subOrder.validUntil = _validUntil;

        orders[_orderId].subOrderList.push(subOrderIdCount);
        subOrders[subOrderIdCount] = subOrder;

        emit CreateSubOrder(_orderId, order.typeOrder, subOrder.buyerAddress, subOrder.tokenPrice, subOrder.protectionRate, subOrder.validUntil);
    }

    function buySubOrder(uint256 _orderId, uint256 _subOrderId) external payable {   
        Order storage order = orders[_orderId];
        SubOrder storage subOrder = subOrders[_subOrderId];

        require(_orderId == subOrder.orderId, "Invalid SubOrder");
        require(msg.sender == subOrder.buyerAddress, "Invalid Authentication");
        require(msg.value == subOrder.tokenPrice, "Insufficient token price");
        require(block.timestamp <= subOrder.validUntil, "SubOrder offer Expired");
        require(order.statusOrder == OrderStatus.Active, "Invalid OrderStatus");

        order.protectionRate = subOrder.protectionRate;
        order.protectionTime = subOrder.protectionTime;
        order.buyerAddress = payable(msg.sender);

        _proceedPayments(_orderId, subOrder.tokenPrice, subOrder.protectionRate, payable(msg.sender));
        emit BuyOrder(_orderId, order.typeOrder, order.buyerAddress, order.protectionAmount, order.soldTime + order.protectionTime);
    }

    function buyFixedPayOrder(uint256[] memory _orderIds, address _vaultAddress) external payable {
        uint256 inputValue = msg.value;
        uint256 orderPrice = 0;
        for ( uint256 i = 0; i < _orderIds.length; i ++ ) {
            uint256 _orderId = _orderIds[i];
            Order storage order = orders[_orderId];
            require(order.statusOrder == OrderStatus.Active, "Invalid OrderStatus");   
            require(order.typeOrder == OrderType.FixedPay, "Invalid OrderType");   // AuctionType orders are directly executed by seller
            orderPrice += order.tokenPrice;
        }
        if (inputValue > 0) {
            require( inputValue >= orderPrice, "low token price" );
        } else {
            require( _vaultAddress != address(0), "NA" );
            require( IVault(_vaultAddress).owner() == msg.sender, "Invalid owner" );
            IVault(_vaultAddress).withdraw(address(this), orderPrice);
        }

        for ( uint256 i = 0; i < _orderIds.length; i ++ ) {
            uint256 _orderId = _orderIds[i];
            Order storage order = orders[_orderId];
            require(order.statusOrder == OrderStatus.Active, "Invalid OrderStatus");

            _proceedPayments(_orderId, order.tokenPrice, order.protectionRate, payable(msg.sender));
            order.buyerAddress = payable(msg.sender);

            uint256 protectionExpiryTime = order.isFixedProtection ? order.protectionTime : (order.soldTime + order.protectionTime);
            emit BuyOrder(_orderId, order.typeOrder, order.buyerAddress, order.protectionAmount, protectionExpiryTime);
        }
    }

    function cancelOrder(uint256[] memory _orderIds) external onlySeller(_orderIds) {
        for ( uint256 i = 0; i < _orderIds.length; i ++ ) {
            Order storage order = orders[_orderIds[i]];
            require(order.statusOrder == OrderStatus.Active, "Invalid OrderStatus");

            IERC721(order.tokenAddress).safeTransferFrom(address(this), order.sellerAddress, order.nftTokenId);     // Transfer the NFT
            order.statusOrder = OrderStatus.Cancelled;        

            emit CancelOrder(_orderIds[i]);
        }
    }

    function claimDownsideProtectionAmount(uint256[] memory _orderIds) external returns (bool) {        //Although receiver not a contract, adding reentrant guard for extra protection
        for ( uint256 i = 0; i < _orderIds.length; i ++ ) {
            uint256 _orderId = _orderIds[i];
            Order storage order = orders[_orderId];
            require(order.statusOrder == OrderStatus.UnderDownsideProtectionPhase, "Invalid OrderStatus");   

            uint256 protectionExpiryTime = order.isFixedProtection ? order.protectionTime : (order.soldTime + order.protectionTime);
            // Fetch the token amount worth the face value of protection amount
            if(msg.sender == order.sellerAddress 
                && block.timestamp > protectionExpiryTime
                && order.soldTime != 0)
            {
                order.statusOrder = OrderStatus.Completed;
                uint256 value = order.useDepository ? depository.withdraw(order.depositId) : order.protectionAmount;      // Withdraw from depository
                if (value > 0) {    // value is 0 if not enough BNB on depository contract
                    order.sellerAddress.transfer(value);   // Transfer to Seller the whole Yield Amount
                }
                
                emit ClaimDownsideProtection(_orderId, uint(order.statusOrder), order.soldTime, order.sellerAddress, value);

                return true;
            } else if(block.timestamp <= protectionExpiryTime 
                && order.soldTime != 0)
            {
                address nftOwner = IERC721(order.tokenAddress).ownerOf(order.nftTokenId);
                require(msg.sender == nftOwner, "sender is not NFT owner");
                
                order.statusOrder = OrderStatus.Active;
                uint256 value = order.useDepository ? depository.withdraw(order.depositId) : order.protectionAmount;      // Withdraw from depository
                if (value > 0) {    // value is 0 if not enough BNB on depository contract
                    IERC721(order.tokenAddress).safeTransferFrom(msg.sender, address(this), order.nftTokenId);     // Send NFT back to seller
                    order.buyerAddress.transfer(order.protectionAmount);    // Transfer to Buyer only his protection amount
                    order.sellerAddress.transfer(value - order.protectionAmount);   // Transfer to Seller the Yield reward
                }
                order.buyerAddress = payable(address(0));
                if (!order.isFixedProtection) {
                    order.protectionTime = protectionExpiryTime - block.timestamp;
                }

                emit ClaimDownsideProtection(_orderId, uint(order.statusOrder), order.soldTime, msg.sender, order.protectionAmount);

                return true;
            }
        }

        return false;
    }

    function claimDownsideProtectionAmountByVToken(uint256[] memory _orderIds) external returns (bool) {        //Although receiver not a contract, adding reentrant guard for extra protection
        for ( uint256 i = 0; i < _orderIds.length; i ++ ) {
            uint256 _orderId = _orderIds[i];
            Order storage order = orders[_orderId];
            require(order.statusOrder == OrderStatus.UnderDownsideProtectionPhase, "Invalid OrderStatus");

            uint256 protectionExpiryTime = order.isFixedProtection ? order.protectionTime : (order.soldTime + order.protectionTime);
            // Fetch the token amount worth the face value of protection amount
            if(msg.sender == order.sellerAddress 
                && block.timestamp > protectionExpiryTime
                && order.soldTime != 0)
            {
                order.statusOrder = OrderStatus.Completed;
                uint256 value = order.useDepository ? depository.withdrawVToken(order.depositId) : order.protectionAmount;
                if (order.useDepository) {
                    vBNB.transfer(order.sellerAddress, value);   // Transfer to Seller the whole Yield Amount
                } else {
                    order.sellerAddress.transfer(value);
                }
                
                emit ClaimDownsideProtectionByVToken(_orderId, uint(order.statusOrder), order.soldTime, order.sellerAddress, value);

                return true;
            } else if(block.timestamp <= protectionExpiryTime 
                && order.soldTime != 0)
            {
                address nftOwner = IERC721(order.tokenAddress).ownerOf(order.nftTokenId);
                require(msg.sender == nftOwner, "sender is not NFT owner");
                
                order.statusOrder = OrderStatus.Active;
                uint256 value = order.useDepository ? depository.withdrawVToken(order.depositId) : order.protectionAmount;      // Withdraw from depository
                uint256 underlyingBalance = order.useDepository ? vBNB.balanceOfUnderlying(address(this)) : order.protectionAmount;
                IERC721(order.tokenAddress).safeTransferFrom(msg.sender, address(this), order.nftTokenId);     // Send NFT back to seller

                uint256 buyerShares = value * order.protectionAmount / underlyingBalance;
                if (order.useDepository) {
                    vBNB.transfer(order.buyerAddress, buyerShares);    // Transfer to Buyer only his protection amount
                    vBNB.transfer(order.sellerAddress, value - buyerShares);   // Transfer to Seller the Yield reward
                } else {
                    order.buyerAddress.transfer(buyerShares);
                }
                
                order.buyerAddress = payable(address(0));
                if (!order.isFixedProtection) {
                    order.protectionTime = protectionExpiryTime - block.timestamp;
                }
                
                emit ClaimDownsideProtectionByVToken(_orderId, uint(order.statusOrder), order.soldTime, msg.sender, buyerShares);

                return true;
            }
        }

        return false;
    }

    // claim money from downside protection on seller behalf
    function claimDownsideProtectionOnSellerBehalf(address _seller, uint256[] memory _orderIds) external {
        for ( uint256 i = 0; i < _orderIds.length; i ++ ) {
            uint256 _orderId = _orderIds[i];
            Order storage order = orders[_orderId];
            require(order.statusOrder == OrderStatus.UnderDownsideProtectionPhase, "Invalid OrderStatus");   

            uint256 protectionExpiryTime = order.isFixedProtection ? order.protectionTime : (order.soldTime + order.protectionTime);
            // Fetch the token amount worth the face value of protection amount
            if(_seller == order.sellerAddress 
                && block.timestamp > protectionExpiryTime
                && order.soldTime != 0)
            {
                order.statusOrder = OrderStatus.Completed;
                uint256 value = order.useDepository ? depository.withdraw(order.depositId) : order.protectionAmount;      // Withdraw from depository
                if (value > 0) {
                    order.sellerAddress.transfer(value);   // Transfer to Seller the whole Yield Amount
                }
                
                emit ClaimDownsideProtection(_orderId, uint(order.statusOrder), order.soldTime, order.sellerAddress, value);
            }
        }
    }

    function claimDownsideProtectionByVTokenOnSellerBehalf(address _seller, uint256[] memory _orderIds) external {
        for ( uint256 i = 0; i < _orderIds.length; i ++ ) {
            uint256 _orderId = _orderIds[i];
            Order storage order = orders[_orderId];
            require(order.statusOrder == OrderStatus.UnderDownsideProtectionPhase, "Invalid OrderStatus");   

            uint256 protectionExpiryTime = order.isFixedProtection ? order.protectionTime : (order.soldTime + order.protectionTime);
            // Fetch the token amount worth the face value of protection amount
            if(_seller == order.sellerAddress 
                && block.timestamp > protectionExpiryTime
                && order.soldTime != 0)
            {
                order.statusOrder = OrderStatus.Completed;
                uint256 value = order.useDepository ? depository.withdrawVToken(order.depositId) : order.protectionAmount;      // Withdraw from depository
                if (order.useDepository) {
                    vBNB.transfer(order.sellerAddress, value);   // Transfer to Seller the whole Yield Amount
                } else {
                    order.sellerAddress.transfer(value);
                }
                
                emit ClaimDownsideProtectionByVToken(_orderId, uint(order.statusOrder), order.soldTime, order.sellerAddress, value);
            }
        }
    }

    function createBid(uint256 _orderId, address _vaultAddress, uint256 _bidAmount) external payable {
        uint256 inputValue = msg.value > 0 ? msg.value : _bidAmount;
        Order storage order = orders[_orderId];
        uint256 previousMaxOfferAmount = order.tokenPrice;
        require(inputValue > previousMaxOfferAmount, "Investment too low");
        require(order.statusOrder == OrderStatus.Active || order.statusOrder == OrderStatus.Bidded, "Invalid OrderType");
        require(order.typeOrder == OrderType.AuctionType, "Invalid OrderType");
        require(order.offerClosingTime >= block.timestamp, "Bidding beyond Closing Time");

        if (msg.value == 0) {
            require( _vaultAddress != address(0), "NA" );
            require( IVault(_vaultAddress).owner() == msg.sender, "Invalid owner" );
            IVault(_vaultAddress).withdraw(address(this), inputValue);
        }

        address payable previousBuyer =  order.buyerAddress;

        // Update the new bidder details
        order.tokenPrice = msg.value;   // maxOfferAmount
        order.buyerAddress = payable(msg.sender);
        buyerBidStatus[msg.sender][_orderId] = BidStatus.Pending;
        order.statusOrder = OrderStatus.Bidded;

        // Return the funds to the previous bidder
        if (previousBuyer != address(0)) {
            buyerBidStatus[previousBuyer][_orderId] = BidStatus.Refunded; 
            previousBuyer.transfer(previousMaxOfferAmount);
        }
        emit CreateBid(_orderId, order.typeOrder, msg.sender, msg.value);
    }

    function executeBid(uint256 _orderId) external {
        Order storage order = orders[_orderId];

        require(order.statusOrder == OrderStatus.Bidded, "Invalid OrderStatus");
        require(order.typeOrder == OrderType.AuctionType, "Invalid OrderType");
        require(order.offerClosingTime <= block.timestamp, "Executing Bid before Closing Time");

        _proceedPayments(_orderId, order.tokenPrice, order.protectionRate, order.buyerAddress);
        buyerBidStatus[order.buyerAddress][_orderId] = BidStatus.Executed;

        uint256 protectionExpiryTime = order.isFixedProtection ? order.protectionTime : (order.soldTime + order.protectionTime);
        emit BuyOrder(_orderId, order.typeOrder, order.buyerAddress, order.protectionAmount, protectionExpiryTime);
    }

    function updateBid(uint256 _orderId) external payable {
        Order storage order = orders[_orderId];

        require(order.statusOrder == OrderStatus.Bidded, "Invalid OrderStatus");
        require(order.typeOrder == OrderType.AuctionType, "Invalid OrderType");
        require(order.buyerAddress == payable(msg.sender), "Only bidder can update");
        require(order.offerClosingTime >= block.timestamp, "Bidding beyond Closing Time");
        require(buyerBidStatus[order.buyerAddress][_orderId] == BidStatus.Pending, "Bid status should be pending");
        
        order.tokenPrice += msg.value;
        
        emit UpdateBid(_orderId, order.typeOrder, msg.sender, msg.value);
    }

    function createOffer(
        address _tokenAddress,    // NFT token address and token id
        uint256 _nftTokenId,
        address _vaultAddress,  // user's vault address
        uint256 _tokenPrice,    // Fix price or start price of auction
        bool _useDepository,
        uint64 _protectionRate, // downside protection rate in percentage with 2 decimals (i.e. 3412 = 34.12%)
        uint256 _protectionTime,     // downside protection duration (in seconds). I.e. 604800 = 1 week (60*60*24*7)
        uint256 _offerExpiration    // the time when offer is canceled automatically if NFT owner doesn't accept offer
    ) external payable returns (uint256) {
        require(_tokenPrice > 0, "token price > 0");
        uint256 inputValue = msg.value;
        if (inputValue > 0) {
            require(_tokenPrice == inputValue, "Invalid token price");
        } else {
            require(_vaultAddress != address(0), "NA");
            require(IVault(_vaultAddress).owner() == msg.sender, "Should be owner");
        }
        require(_protectionRate <= 10000 , "ProtectedMarketplace::createOffer: Protection rate above 100 percent");
        
        offerIdCount++;
        Offer storage offer = offers[offerIdCount];

        // Update the Offer
        offer.statusOffer = OfferStatus.Active;
        offer.tokenAddress = _tokenAddress;
        offer.nftTokenId = _nftTokenId;
        offer.isDerivativeNft = derivativeFactory.isDerivative(_tokenAddress);
        offer.sellerAddress = payable(address(0));
        offer.buyerAddress = payable(msg.sender);
        offer.useVault = inputValue == 0;
        if (inputValue == 0) {
            offer.vaultAddress = _vaultAddress;
        }
        offer.tokenPrice = _tokenPrice;
        offer.useDepository = _useDepository;
        offer.protectionRate = _protectionRate;
        offer.protectionTime = _protectionTime;
        offer.offerExpiration = _offerExpiration;
        
        emit CreateOffer(offerIdCount);
        return offerIdCount;
    }

    function acceptOffer(uint256 _offerId) external returns (bool) {
        Offer storage offer = offers[_offerId];
        require(offer.statusOffer == OfferStatus.Active, "Invalid OfferStatus");
        require(IERC721(offer.tokenAddress).ownerOf(offer.nftTokenId) == msg.sender, "Invalid token owner");
        
        offer.statusOffer = OfferStatus.UnderDownsideProtectionPhase;
        offer.sellerAddress = payable(msg.sender);

        if (offer.useVault) {
            IVault(offer.vaultAddress).withdraw(address(this), offer.tokenPrice);
        }

        uint256 companyShare = offer.tokenPrice * companyFeeRate / 10000;
        if (offer.isDerivativeNft) {
            companyShare += offer.tokenPrice * derivativeFeeRate / 10000;
        }
        company.transfer(companyShare);                        // Transfer the company fees
        
        uint256 netAmount = offer.tokenPrice - companyShare;
        uint256 downsideAmount = netAmount * offer.protectionRate / 10000;    // downsideAmount comes after companyShare
        offer.sellerAddress.transfer(netAmount - downsideAmount);        // Transfer the seller his amount

        if (offer.useDepository) {
            offer.depositId = depository.deposit{value: downsideAmount}();     // Invest the downside in Venus
        }

        IERC721(offer.tokenAddress).safeTransferFrom(msg.sender, offer.buyerAddress, offer.nftTokenId);     // Transfer the NFT
        offer.protectionAmount = downsideAmount;
        offer.soldTime = block.timestamp;

        emit AcceptOffer(_offerId, offer.sellerAddress, offer.protectionAmount, offer.soldTime + offer.protectionTime);
        return true;
    }

    function claimDownsideProtectionAmountInOffer(uint256 _offerId) external returns (bool) {
        Offer storage offer = offers[_offerId];
        require(offer.statusOffer == OfferStatus.UnderDownsideProtectionPhase, "Invalid OfferStatus");   

        // Fetch the token amount worth the face value of protection amount
        if(block.timestamp > offer.soldTime + offer.protectionTime
            && offer.soldTime != 0)
        {
            offer.statusOffer = OfferStatus.Completed;
            uint256 value = offer.useDepository ? depository.withdraw(offer.depositId) : offer.protectionAmount;      // Withdraw from depository
            if (value > 0) {    // value is 0 if not enough BNB on depository contract
                offer.sellerAddress.transfer(value);   // Transfer to Seller the whole Yield Amount
            }
            
            emit ClaimDownsideProtectionInOffer(_offerId, uint(offer.statusOffer), offer.soldTime, offer.sellerAddress, value);

            return true;
        } else if(block.timestamp <= offer.soldTime + offer.protectionTime 
            && offer.soldTime != 0)
        {
            address nftOwner = IERC721(offer.tokenAddress).ownerOf(offer.nftTokenId);
            require(msg.sender == nftOwner, "sender is not NFT owner");
            offer.statusOffer = OfferStatus.Cancelled;
            uint256 value = offer.useDepository ? depository.withdraw(offer.depositId) : offer.protectionAmount;      // Withdraw from depository
            if (value > 0) {
                IERC721(offer.tokenAddress).safeTransferFrom(msg.sender, offer.sellerAddress, offer.nftTokenId);     // Send NFT back to seller

                offer.buyerAddress.transfer(offer.protectionAmount);    // Transfer to Buyer only his protection amount
                offer.sellerAddress.transfer(value - offer.protectionAmount);   // Transfer to Seller the Yield reward
            }
            
            emit ClaimDownsideProtectionInOffer(_offerId, uint(offer.statusOffer), offer.soldTime, msg.sender, offer.protectionAmount);

            return true;
        }

        return false;
    }

    function claimDownsideProtectionAmountInOfferByVToken(uint256 _offerId) external returns (bool) {
        Offer storage offer = offers[_offerId];
        require(offer.statusOffer == OfferStatus.UnderDownsideProtectionPhase, "Invalid OfferStatus");   

        // Fetch the token amount worth the face value of protection amount
        if(block.timestamp > offer.soldTime + offer.protectionTime
            && offer.soldTime != 0)
        {
            offer.statusOffer = OfferStatus.Completed;
            uint256 value = offer.useDepository ? depository.withdrawVToken(offer.depositId) : offer.protectionAmount;      // Withdraw from depository
            if (offer.useDepository) {
                vBNB.transfer(offer.sellerAddress, value);   // Transfer to Seller the whole Yield Amount
            } else {
                offer.sellerAddress.transfer(value);
            }
            
            emit ClaimDownsideProtectionInOfferByVToken(_offerId, uint(offer.statusOffer), offer.soldTime, offer.sellerAddress, value);

            return true;
        } else if(block.timestamp <= offer.soldTime + offer.protectionTime 
            && offer.soldTime != 0)
        {
            address nftOwner = IERC721(offer.tokenAddress).ownerOf(offer.nftTokenId);
            require(msg.sender == nftOwner, "sender is not NFT owner");
            offer.statusOffer = OfferStatus.Cancelled;
            uint256 value = offer.useDepository ? depository.withdrawVToken(offer.depositId) : offer.protectionAmount;      // Withdraw from depository
            uint256 underlyingBalance = offer.useDepository ? vBNB.balanceOfUnderlying(address(this)) : offer.protectionAmount;
            IERC721(offer.tokenAddress).safeTransferFrom(msg.sender, offer.sellerAddress, offer.nftTokenId);     // Send NFT back to seller

            uint256 buyerShares = value * offer.protectionAmount / underlyingBalance;
            if (offer.useDepository) {
                vBNB.transfer(offer.buyerAddress, buyerShares);    // Transfer to Buyer only his protection amount
                vBNB.transfer(offer.sellerAddress, value - buyerShares);   // Transfer to Seller the Yield reward
            } else {
                offer.buyerAddress.transfer(buyerShares);
            }
            
            emit ClaimDownsideProtectionInOfferByVToken(_offerId, uint(offer.statusOffer), offer.soldTime, msg.sender, buyerShares);

            return true;
        }

        return false;
    }

    function cancelOffer(uint256 _offerId) external onlyBuyerOrExpired(_offerId) {
        Offer storage offer = offers[_offerId];
        require(offer.statusOffer == OfferStatus.Active, "Invalid OfferStatus");

        offer.buyerAddress.transfer(offer.tokenPrice);     // Transfer deposited funds
        offer.statusOffer = OfferStatus.Cancelled;        

        emit CancelOffer(_offerId);
    }

    function _proceedPayments(uint256 _orderId, uint256 _price, uint256 _protectionRate, address payable buyerAddress) internal {
        Order storage order = orders[_orderId];
        order.statusOrder = OrderStatus.UnderDownsideProtectionPhase;

        uint256 companyShare = _price * companyFeeRate / 10000;
        if (order.isDerivativeNft) {
            companyShare += _price * derivativeFeeRate / 10000;
        }
        company.transfer(companyShare);                        // Transfer the company fees
        
        uint256 netAmount = _price - companyShare;
        uint256 downsideAmount = netAmount * _protectionRate / 10000;    // downsideAmount comes after companyShare
        order.sellerAddress.transfer(netAmount - downsideAmount);        // Transfer the seller his amount

        if (order.useDepository) {
            order.depositId = depository.deposit{value: downsideAmount}();     // Invest the downside in Venus
        }

        IERC721(order.tokenAddress).safeTransferFrom(address(this), buyerAddress, order.nftTokenId);     // Transfer the NFT
        order.protectionAmount = downsideAmount;
        order.soldTime = block.timestamp;
        //order.protectionExpiryTime = order.soldTime + order.protectionTime;
    }

    function setNewCompany(address payable _newCompany) external {
        require(msg.sender == company, "Invalid Authentication");
        require(_newCompany != address(0));
        address oldCompany = company;
        company = _newCompany;

        emit CompanyChanged(oldCompany, _newCompany);
    }

    // Set company fee rate in percentage with 2 decimals (i.e. 3412 = 34.12%)
    function setCompanyFeeRate(uint256 _companyFeeRate, uint256 _derivativeFeeRate) external {
        require(msg.sender == company, "Invalid Authentication");
        require(_companyFeeRate > 0 && _companyFeeRate < 10000, "Rate exceeding 100 percent");
        require(_derivativeFeeRate > 0 && _derivativeFeeRate < 10000, "Fee Rate exceeding 100 percent");
        uint256 oldCompanyRate = companyFeeRate;
        uint256 oldDerivativeRate = derivativeFeeRate;
        companyFeeRate = _companyFeeRate;
        derivativeFeeRate = _derivativeFeeRate;

        emit CompanyFeeRateChanged(oldCompanyRate, _companyFeeRate, oldDerivativeRate, _derivativeFeeRate);
    }

    function getOrder(uint256 _orderId) external view returns (Order memory) {
        return orders[_orderId];
    }

    function getOffer(uint256 _offerId) external view returns (Offer memory) {
        return offers[_offerId];
    }

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
}