// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./dvc.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract DVCFactory {
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private allDVCs;

    struct BuyCriteriaArgs {
        address[] _nftAddress;
        bool _isPack;
        bool _isAuction;
        uint256 _maxPrice;
        uint256 _minPrice;
        uint256 _auctionRate;
        uint64 _protectionRate;
        uint64 _protectionExpiryTime;
        bool _useMLR;
    }

    struct SellCriteriaArgs {
        bool _isFixedAbovePrice;
        uint256 _abovePriceRate;
        bool _isAuction;
        bool _isPack;
        uint256 _amountNFT;
        uint64 _protectionRate;
        bool _isFixedProtection;
        bool _useMLR;
        uint32 _royalty;
        uint256 _buyoutPrice;
    }

    event DVCCreated(
        address dvc,
        uint count
    );

    function allDVCsLength() external view returns (uint) {
        return allDVCs.length();
    }

    function getDVCByIndex(uint256 index) external view returns (address) {
        return allDVCs.at(index);
    }

    function createDVC(
        string memory _uniqueID,
        address _protectedMarketplace,
        address _mlrFactory,
        bool _isCloseEnded,
        uint256 _dueDate,
        uint256 _finalDate,
        BuyCriteriaArgs memory buyArgs,
        SellCriteriaArgs memory sellArgs
    ) external returns ( address dvc ) {
        require( _protectedMarketplace != address(0) && _mlrFactory != address(0), "NA" );

        dvc = address(
            new DVC(_uniqueID, _protectedMarketplace, _mlrFactory, _isCloseEnded)
        );

        if ( _isCloseEnded ) {
            IDvc(dvc).setFundingPeriod( _dueDate, _finalDate );
        }
        IDvc(dvc).setBuycriteria(
            buyArgs._nftAddress,
            buyArgs._isPack,
            buyArgs._isAuction,
            buyArgs._maxPrice,
            buyArgs._minPrice,
            buyArgs._auctionRate,
            buyArgs._protectionRate,
            buyArgs._protectionExpiryTime,
            buyArgs._useMLR
        );
        IDvc(dvc).setSellcriteria(
            sellArgs._isFixedAbovePrice,
            sellArgs._abovePriceRate,
            sellArgs._isAuction,
            sellArgs._isPack,
            sellArgs._amountNFT,
            sellArgs._protectionRate,
            sellArgs._isFixedProtection,
            sellArgs._useMLR,
            sellArgs._royalty,
            sellArgs._buyoutPrice
        );

        allDVCs.add(dvc);

        emit DVCCreated(
            dvc, 
            allDVCs.length()
        );
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function add32(uint32 a, uint32 b) internal pure returns (uint32) {
        uint32 c = a + b;
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

    function mul32(uint32 a, uint32 b) internal pure returns (uint32) {
        if (a == 0) {
            return 0;
        }

        uint32 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

interface IProtectedMarketplace {

    function createOrder(
        address _tokenAddress,  // NFT token contract address (where NFT was minted)
        uint256 _nftTokenId,    // NFT token ID (what to sell)
        uint256 _tokenPrice,    // Fix price or start price of auction
        uint64 _protectionRate, // downside protection rate in percentage with 2 decimals (i.e. 3412 = 34.12%)
        bool _isFixedProtection,    // false -> soldTime + protectionTime, true -> fix date
        uint256 _protectionTime,// downside protection duration (in seconds). I.e. 604800 = 1 week (60*60*24*7)
        bool _acceptOffers,     // false = fix price order, true - auction order
        uint256 _offerClosingTime   // Epoch time (in seconds) when auction will be closed (or fixed order expired)
    )
    external;

    function createSubOrder(
        uint256 _orderId, //original order ID
        address payable _buyerAddress,
        uint256 _tokenPrice,
        uint64 _protectionRate,
        uint256 _protectionTime,
        uint256 _validUntil
    )
    external;
  
    function buySubOrder(uint256 _orderId, uint256 _subOrderId) external ;
    
    function buyFixedPayOrder(uint256 _orderId) external payable;

    function cancelOrder(uint256 _orderId) external ;

    function claimDownsideProtectionAmount(uint256 _orderId) external;

    function sellerCheckClaimDownsideProtectionAmount(uint256 _orderId) external returns (bool) ;

    function buyerCheckClaimDownsideProtectionAmount(uint256 _orderId)  external returns (bool);

    function createBid(uint256 _orderId) external payable;

    function executeBid(uint256 _orderId) external ;

    function getOrder(uint256 _orderId) external returns(Order memory);
     
    enum OrderType { FixedPay, AuctionType }
    enum OrderStatus { Active, Bidded, UnderDownsideProtectionPhase, Completed, Cancelled }
    enum BidStatus { NotAccepted, Pending, Refunded, Executed }

    // mapping (address => mapping(uint256 => BidStatus)) public buyerBidStatus;
    function buyerBidStatus(address, uint256) view external returns (BidStatus);
     
    struct Order {
        OrderStatus statusOrder;
        OrderType typeOrder;
        address tokenAddress;
        uint256 nftTokenId;
        address payable sellerAddress;
        address payable buyerAddress;
        uint256 tokenPrice;
        uint256 protectionAmount;
        // uint256 protectionShares;
        uint64 protectionRate;
        bool isFixedProtection; // false -> soldTime + protectionTime, true -> fix date
        uint256 protectionTime;
        uint256 depositId;
        // uint256 protectionExpiryTime;
        uint256 soldTime; // time when order sold, if equal to 0 than order unsold (so no need to use additional variable "bool saleNFT")
        uint256 offerClosingTime;
        // uint256 maxOfferAmount;
        uint256[] subOrderList;
    }

}

interface IMLRFactory {

    function getMLR(address nftContract, uint256 tokenID) external view returns(address mlr);

}

interface IMultilevelRoyalty {

    function createOrder(
        uint256 _buyoutPrice,    // Buyout price
        uint32 _royaltyFee,
        uint256 _tokenPrice,    // Fix price or start price of auction
        uint64 _protectionRate, // downside protection rate in percentage with 2 decimals (i.e. 3412 = 34.12%)
        bool _isFixedProtection,    // false -> soldTime + protectionTime, true -> fix date
        uint256 _protectionTime,// downside protection duration (in seconds). I.e. 604800 = 1 week (60*60*24*7)
        bool _acceptOffers,     // false = fix price order, true - auction order
        uint256 _offerClosingTime   // Epoch time (in seconds) when auction will be closed (or fixed order expired)
    )
    external;

    function buyFixedPayOrder(uint256 _orderId) external payable;

    function cancelOrder(uint256 _orderId) external ;

    function claimDownsideProtectionAmount(uint256 _orderId) external;

    function sellerCheckClaimDownsideProtectionAmount(uint256 _orderId) external returns (bool) ;

    function buyerCheckClaimDownsideProtectionAmount(uint256 _orderId)  external returns (bool);

    function createBid(uint256 _orderId) external payable;

    function executeBid(uint256 _orderId) external ;

    function orders(uint256 _orderId) external returns(Order memory);
     
    enum OrderType { FixedPay, AuctionType }
    enum OrderStatus { Active, Bidded, UnderDownsideProtectionPhase, Completed, Cancelled }
    enum BidStatus { NotAccepted, Pending, Refunded, Executed }

    // mapping (address => mapping(uint256 => BidStatus)) public buyerBidStatus;
    function buyerBidStatus(address, uint256) view external returns (BidStatus);
     
    struct Order {
		OrderStatus statusOrder;
        OrderType typeOrder;
		address payable sellerAddress;
        address payable buyerAddress;
        uint256 tokenPrice; // In fix sale - token price. Auction: start price or max offer price
		uint256 buyPrice; // previous buy price, to calculate profit
		// protection
		uint256 protectionAmount;
        uint256 depositId;
        uint64 protectionRate;  // in percent with 2 decimals
        bool isFixedProtection; // false -> soldTime + protectionTime, true -> fix date
        uint256 protectionTime;
		uint256 soldTime; // time when order sold, if equal to 0 than order unsold (so no need to use additional variable "bool saleNFT")
		uint256 offerClosingTime;	// for auction
	}

    function updateRoyaltyInfo(uint32 _royaltyFee, uint256 _buyoutPrice) external returns (bool);

}

interface IDvc {

    function setFundingPeriod( uint256 _dueDate, uint256 _finalDate ) external;

    function setBuycriteria(
        address[] memory _nftAddress, 
        bool _isPack,
        bool _isAuction,
        uint256 _maxPrice,
        uint256 _minPrice,
        uint256 _auctionRate,    
        uint64 _protectionRate, 
        uint64 _protectionExpiryTime,
        bool _useMLR
    ) external;

    function setSellcriteria(
        bool _isFixedAbovePrice,
        uint256 _abovePriceRate, 
        bool _isAuction,
        bool _isPack,
        uint256 _amountNFT,
        uint64 _protectionRate,
        bool _isFixedProtection,
        bool _useMLR,
        uint32 _royalty,
        uint256 _buyoutPrice
    ) external;

}

contract DVC is ERC20, Ownable{

    using SafeMath for uint256;
    using SafeMath for uint;

    event AddLiquidity( address depositor, uint256 amount );
    event Withdrawl( address withdrawer, uint256 amount, uint256 invested, uint256 lpBalance );
    event SetBuycriteria( BuyNFTCriteria buyNFTCriteria );
    event SetSellcriteria( SellNFTCriteria sellNFTCriteria );
    event GetBuyCriteria( BuyNFTCriteria buyNFTCriteria );
    event GetSellCriteria( SellNFTCriteria sellNFTCriteria );
    event BuyNFTOnCriteria(
        uint256 orderID,
        IProtectedMarketplace.OrderType orderType,
        uint256 buyValue,
        IProtectedMarketplace.BidStatus bidStatus,
        uint offerClosingTime
    );
    event BuyNFTOnCriteriaFromMLR(
        address nftContract,
        uint256 tokenID,
        uint256 orderID,
        IMultilevelRoyalty.OrderType orderType,
        uint256 buyValue,
        IMultilevelRoyalty.BidStatus bidStatus,
        uint offerClosingTime
    );
    event SellNFTOnCriteria(
        uint256 orderID,
        bool isAuction,
        uint256 sellPrice,
        uint64 protectionRate,
        bool isFixedProtection,
        uint256 protectionTime
    );
    event SellNFTOnCriteriaFromMLR(
        address nftContract,
        uint256 tokenID,
        uint256 orderID,
        bool isAuction,
        uint256 sellPrice,
        uint64 protectionRate,
        bool isFixedProtection,
        uint256 protectionTime
    );

    address public factory;
    string public uniqueID;
    uint public totalValue;

    IProtectedMarketplace marketplace; // address of the deployed contract
    IMLRFactory mlrFactory; // address of the MLR Factory

    struct BuyNFTCriteria {
        // these have to be checked by smart contract when create order
        address[] nftAddress;     // NFT token contract address
        bool isPack;          // true -> pack, false -> normal nft
        bool isAuction;         // Fixedpay = 0 , AuctionType = 1
        uint256 maxPrice;       // maximum price to buy NFT
        uint256 minPrice;       // minimum price to buy NFT
        uint256 auctionRate;     // in hundreds 500 = 5%, increase token price to win auction
        uint64 protectionRate;  // minimum percentage of downside protection (with 2 decimals)
        uint64 protectionExpiryTime;    // protection expired time (in seconds).
        bool useMLR;    // use MLR = 1, no = 0
    }
    
    struct SellNFTCriteria {
        bool isFixedAbovePrice; // true -> x bnb above, false -> x% above
        uint256 abovePriceRate;  // percentage that must added above the purchasing price to get sell price.
        bool isAuction;         // true if Auction else Fix sale
        bool isPack;         // true -> pack, false -> normal nft
        uint256 amountNFT;      // pack this amount of NFT into lootbox (if isPack is true)
        uint64 protectionRate;  // minimum percentage of downside protection (with 2 decimals)
        bool isFixedProtection; // false -> soldTime + protectionTime, true -> fix date
        bool useMLR;    // use MLR = 1, no = 0
        uint32 royalty; // 500 = 5%
        uint256 buyoutPrice;
    }

    BuyNFTCriteria buyNFT ;
    SellNFTCriteria sellNFT ;
    mapping( address => bool ) isCollection;
    
    struct PendingWithdraw {
        address payable pendingDepositor;
        uint256 pendingAmount;
    }

    PendingWithdraw[] pendingToWithdraw;

    bool public isCloseEnded;
    uint256 public dueDate;
    uint256 public finalDate;

    constructor(
        string memory _uniqueID,
        address _protectedMarketplace,
        address _mlrFactory,
        bool _isCloseEnded
    ) ERC20( "LPToken", "LPT" ){
        factory = msg.sender;
        uniqueID = _uniqueID;
        marketplace = IProtectedMarketplace( _protectedMarketplace );
        mlrFactory = IMLRFactory( _mlrFactory );
        isCloseEnded = _isCloseEnded;
    }

    receive() external payable {
        
        if( address(this).balance > totalValue ) {
            totalValue = address(this).balance;
        }

        processPending();

    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external pure returns(bytes4) {
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    /**
     * @notice Mint LP tokens for the corresponding sent amount.
     */
    function addLiquidity() external payable {

        if( isCloseEnded ) {
            require( block.timestamp <= dueDate, "Funding due date ended" );
        }
        
        uint mintLP;
        
        if (totalValue == 0) {
            mintLP = msg.value;
        } else {
            mintLP = totalSupply().mul( msg.value ).div( totalValue );
        } 
        
        totalValue = totalValue.add( msg.value );
        _mint( msg.sender, mintLP );

        processPending();
        
        emit AddLiquidity( msg.sender, msg.value );

    }

    /**
     * @notice Redeems LP amount for its underlying token amount.
     * @param _lpamount The amount of LP tokens to redeem
     */
    function withdraw( uint256 _lpamount ) external {

        if( isCloseEnded ) {
            require( block.timestamp > finalDate, "Before final date" );
        }
        
        require( _lpamount > 0 && _lpamount <= balanceOf(msg.sender), "LP BALANCE_INSUFFICIENT" );
        
        uint256 invested = totalSupply();
        uint amount = _lpamount.mul( totalValue ).div( invested );

        if ( address(this).balance < amount ) {
            PendingWithdraw memory newPending = PendingWithdraw(
                payable(msg.sender),
                amount - address(this).balance
            );
            pendingToWithdraw.push( newPending );
            amount = address(this).balance;
        }
        
        _burn( msg.sender, _lpamount );
        payable( msg.sender ).transfer( amount );
        totalValue = totalValue.sub( amount );
        
        emit Withdrawl( msg.sender, amount, invested, totalSupply() );

    }

    function processPending() internal {
        
        if ( address(this).balance == 0 ) return;

        uint withdrawCount = 0;
        while( withdrawCount < pendingToWithdraw.length ) {
            uint pendingAmount = pendingToWithdraw[withdrawCount].pendingAmount;
            if ( pendingAmount > address(this).balance ) {
                pendingToWithdraw[withdrawCount].pendingAmount = pendingAmount - address(this).balance;
                pendingToWithdraw[withdrawCount].pendingDepositor.transfer( address(this).balance );
                totalValue = totalValue.sub( address(this).balance );
                break;
            } else {
                pendingToWithdraw[withdrawCount].pendingDepositor.transfer( pendingAmount );
                totalValue = totalValue.sub( pendingAmount );
                withdrawCount ++;
            }
        }

        if ( withdrawCount == 0 ) return;
        
        if (withdrawCount < pendingToWithdraw.length ) {
            for ( uint i = withdrawCount; i < pendingToWithdraw.length; i ++ ) {
                pendingToWithdraw[i - withdrawCount] = pendingToWithdraw[i];
            }
            for ( uint j = 0; j < withdrawCount; j ++ ) {
                pendingToWithdraw.pop();
            }
        } else {
            delete pendingToWithdraw;
        }
    }

    function setFundingPeriod( uint256 _dueDate, uint256 _finalDate ) external {
        require( msg.sender == factory || msg.sender == owner(), "Not Authorized" );
        require( isCloseEnded, "This is open ended funds" );
        require( _dueDate > block.timestamp && _finalDate > _dueDate, "Not acceptable date" );
        
        dueDate = _dueDate;
        finalDate = _finalDate;
    }
    
    /**
     * @notice Used to set buy criteria according to the user.
     * @param _nftAddress NFT address array provided by user
     * @param _isPack true -> pack, false -> normal nft
     * @param _isAuction   Fixedpay = false or Auction = true
     * @param _maxPrice  Maximum price of NFT
     * @param _minPrice  Maximum price of NFT
     * @param _auctionRate Increasement rate to win auction
     * @param _protectionRate   minimum percentage of downside protection (with 2 decimals)
     * @param _protectionExpiryTime minimum protection expired time (in seconds).
     * @param _useMLR   use MLR = 1, no = 0
     */    
    function setBuycriteria(
        address[] memory _nftAddress,
        bool _isPack,
        bool _isAuction,
        uint256 _maxPrice,
        uint256 _minPrice,
        uint256 _auctionRate,    
        uint64 _protectionRate, 
        uint64 _protectionExpiryTime,
        bool _useMLR
    ) external onlyOwner {

       buyNFT = BuyNFTCriteria(
           _nftAddress,
           _isPack,
           _isAuction,
           _maxPrice,
           _minPrice,
           _auctionRate,
           _protectionRate, 
           _protectionExpiryTime,
           _useMLR
      );

      for (uint256 index = 0; index < _nftAddress.length; index++) {
        isCollection[_nftAddress[index]] = true;
      }

      emit SetBuycriteria( buyNFT );

    }
    
    /**
     * @notice Used to set th Sell Criteria
     * @param _abovePriceRate   Percentage that must added above the purchasing price to get sell price
     * @param _isAuction   True if Auction else Fix sale
     * @param _isPack   True if Pack else Single
     * @param _amountNFT   Pack this amount of NFT into lootbox (if isLootbox is true)
     * @param _protectionRate   minimum percentage of downside protection (with 2 decimals)
     * @param _isFixedProtection false -> soldTime + protectionTime, true -> fix date
     * @param _useMLR   use MLR = 1, no = 0
     * @param _royalty  royalty percentage (with 2 decimals)
     * @param _buyoutPrice  buyout price
     */
    function setSellcriteria(
        bool _isFixedAbovePrice,
        uint256 _abovePriceRate, 
        bool _isAuction,
        bool _isPack,
        uint256 _amountNFT,
        uint64 _protectionRate,
        bool _isFixedProtection,
        bool _useMLR,
        uint32 _royalty,
        uint256 _buyoutPrice
    ) external onlyOwner {
            
        sellNFT = SellNFTCriteria(
            _isFixedAbovePrice,
            _abovePriceRate,
            _isAuction,
            _isPack,
            _amountNFT,
            _protectionRate,
            _isFixedProtection,
            _useMLR,
            _royalty,
            _buyoutPrice
        );

        emit SetSellcriteria( sellNFT );

    }

    function getBuyCriteria() external view returns ( BuyNFTCriteria memory ) {
        return buyNFT;
    }

    function getSellCriteria() external view returns ( SellNFTCriteria memory ) {
        return sellNFT;
    }
    
    /**
     * @notice used to check that the Marketplace NFT is satisfied the nft buy criteria.
     * @param _orderID Order Id of NFT
     */
    function checkBuyCriteriaStatus(uint256 _orderID) internal returns(bool) {
        
        IProtectedMarketplace.Order memory ipo = marketplace.getOrder( _orderID );

        require( buyNFT.nftAddress.length == 0 || isCollection[ipo.tokenAddress],"NFT address are not matched" );
        require( ipo.tokenPrice.mul(buyNFT.auctionRate.add(10000)).div(10000) <= buyNFT.maxPrice, "Price is over max limit" );
        require( ipo.tokenPrice.mul(buyNFT.auctionRate.add(10000)).div(10000) >= buyNFT.minPrice, "Price is under min limit" );
        require( ipo.protectionRate >= buyNFT.protectionRate,"Protection Rate is not valid" );
        
        uint256 protectionExpiryTime = ipo.isFixedProtection ? ipo.protectionTime : (block.timestamp + ipo.protectionTime);
        require( protectionExpiryTime >= buyNFT.protectionExpiryTime,"Protection time is different" );
            
        if ( buyNFT.isAuction ){
            require( uint(ipo.typeOrder) == 1, "typeorder should be AuctionType" );
        } else {
            require( uint(ipo.typeOrder) == 0, "typeorder should be FixedPay" );
        }
        
        return true;

    }

    /**
     * @notice used to buy Marketplace NFT that is satisfied by nft buy criteria.
     * @param _orderID Order Id of NFT
     */
    function buyNftOnCriteria( uint256 _orderID ) external returns ( bool ) {
        
        IProtectedMarketplace.Order memory ipo = marketplace.getOrder( _orderID );
        
        require( checkBuyCriteriaStatus(_orderID), "This order should match BuyNFTCriteria." );
        
        if ( buyNFT.isAuction ) {
            uint256 bidValue = ipo.tokenPrice.mul( buyNFT.auctionRate.add(10000) ).div( 10000 );
            
            marketplace.createBid{value: bidValue}( _orderID );   //FIXME
             //When bid is closed ?????? So we called ExecuteBid fucntion
            emit BuyNFTOnCriteria( _orderID, ipo.typeOrder, bidValue, marketplace.buyerBidStatus( address(this), _orderID ), ipo.offerClosingTime );
        } else {
            marketplace.buyFixedPayOrder{value:ipo.tokenPrice}( _orderID );
            sellNftOnCriteria( _orderID );
            
            emit BuyNFTOnCriteria( _orderID, ipo.typeOrder, ipo.tokenPrice, IProtectedMarketplace.BidStatus.NotAccepted, 0 );
        }

        return true;

    }

    /**
     * @notice used to create order to sell Marketplace NFT by nft sell criteria.
     * @param _orderID Order Id of NFT
     */
    function sellNftOnCriteria( uint256 _orderID ) public returns ( bool ) {
        
        IProtectedMarketplace.Order memory ipo = marketplace.getOrder( _orderID );

        require( ipo.buyerAddress == payable(address(this)), "This order should be done by buyer" );
        
        uint256 priceChange;
        if ( sellNFT.isFixedAbovePrice ) {
            priceChange = sellNFT.abovePriceRate;
        } else {
            priceChange = ipo.tokenPrice.mul( sellNFT.abovePriceRate ).div( 100 );
        }
        uint256 sellPrice = ipo.tokenPrice.add( priceChange );

        uint256 endSellOrderTime = ipo.isFixedProtection ? ipo.protectionTime - 86400 : block.timestamp + ipo.protectionTime - 86400;

        require( block.timestamp < endSellOrderTime, "Insufficient offer time" );
        uint256 newProtectionTime = endSellOrderTime;
        if (!sellNFT.isFixedProtection) {
            newProtectionTime -= block.timestamp;
        }
        
        marketplace.createOrder( ipo.tokenAddress, ipo.nftTokenId, sellPrice, sellNFT.protectionRate, sellNFT.isFixedProtection, newProtectionTime, sellNFT.isAuction, endSellOrderTime );
        
        emit SellNFTOnCriteria( _orderID, sellNFT.isAuction, sellPrice, sellNFT.protectionRate, sellNFT.isFixedProtection, newProtectionTime );
        
        return true;
    
    }

    function getFundsFromDownsideProtectionAsBuyer( uint256 _orderId ) public returns ( bool ) {

        IProtectedMarketplace.Order memory ipo = marketplace.getOrder( _orderId );

        IERC721(ipo.tokenAddress).approve(address(marketplace), ipo.nftTokenId);
        marketplace.claimDownsideProtectionAmount( _orderId );

        return true;

    }

    function getFundsFromDownsideProtectionAsSeller( uint256 _orderId ) public returns ( bool ) {

        marketplace.claimDownsideProtectionAmount( _orderId );

        return true;

    }

// Buy or Sell via MLR contract

    modifier buyMLRValidator(
        address _nftContract,
        uint256 _tokenID
    ) {
        require( buyNFT.useMLR, "Cannot use MLR" );
        require( mlrFactory.getMLR(_nftContract, _tokenID) != address(0), "MLR doesn't exist" );
        _;
    }

    modifier sellMLRValidator(
        address _nftContract,
        uint256 _tokenID
    ) {
        require( sellNFT.useMLR, "Cannot use MLR" );
        require( mlrFactory.getMLR(_nftContract, _tokenID) != address(0), "MLR doesn't exist" );
        _;
    }

    /**
     * @notice used to check that the MLR NFT is satisfied the nft buy criteria.
     * @param _nftContract  NFT address
     * @param _tokenID  NFT token id
     * @param _orderID Order Id of NFT
     */
    function checkBuyCriteriaStatusFromMLR (
        address _nftContract,
        uint256 _tokenID,
        uint256 _orderID
    ) internal returns (bool) {
        
        IMultilevelRoyalty mlr = IMultilevelRoyalty( mlrFactory.getMLR(_nftContract, _tokenID) );
        IMultilevelRoyalty.Order memory imo = mlr.orders( _orderID );

        require( buyNFT.nftAddress.length == 0 || isCollection[_nftContract],"NFT address are not matched" );
        require( imo.tokenPrice.mul(buyNFT.auctionRate.add(10000)).div(10000) <= buyNFT.maxPrice, "Price is over max limit" );
        require( imo.tokenPrice.mul(buyNFT.auctionRate.add(10000)).div(10000) >= buyNFT.minPrice, "Price is under min limit" );
        require( imo.protectionRate >= buyNFT.protectionRate,"Protection Rate is not valid" );
        
        uint256 protectionExpiryTime = imo.isFixedProtection ? imo.protectionTime : (block.timestamp + imo.protectionTime);
        require( protectionExpiryTime >= buyNFT.protectionExpiryTime,"Protection time is different" );
            
        if ( buyNFT.isAuction ){
            require( uint(imo.typeOrder) == 1, "typeorder should be AuctionType" );
        } else {
            require( uint(imo.typeOrder) == 0, "typeorder should be FixedPay" );
        }
        
        return true;

    }

    /**
     * @notice used to buy MLR NFT that is satisfied by nft buy criteria.
     * @param _nftContract  NFT address
     * @param _tokenID  NFT token id
     * @param _orderID Order Id of NFT
     */
    function buyNftOnCriteriaFromMLR(
        address _nftContract,
        uint256 _tokenID,
        uint256 _orderID
    ) external
    buyMLRValidator( _nftContract, _tokenID )
    returns ( bool ) {
        
        require( checkBuyCriteriaStatusFromMLR(_nftContract, _tokenID, _orderID), "Should match BuyNFTCriteria." );

        IMultilevelRoyalty mlr = IMultilevelRoyalty( mlrFactory.getMLR(_nftContract, _tokenID) );
        IMultilevelRoyalty.Order memory imo = mlr.orders( _orderID );
        
        if ( buyNFT.isAuction ) {
            uint256 bidValue = imo.tokenPrice.mul( buyNFT.auctionRate.add(10000) ).div( 10000 );
            
            mlr.createBid{value: bidValue}( _orderID );   //FIXME
             //When bid is closed ?????? So we called ExecuteBid fucntion
            emit BuyNFTOnCriteriaFromMLR(
                _nftContract,
                _tokenID,
                _orderID,
                imo.typeOrder,
                bidValue,
                mlr.buyerBidStatus( address(this), _orderID ),
                imo.offerClosingTime
            );
        } else {
            mlr.buyFixedPayOrder{value:imo.tokenPrice}( _orderID );
            sellNftOnCriteriaFromMLR(
                _nftContract,
                _tokenID,
                _orderID
            );
            
            emit BuyNFTOnCriteriaFromMLR(
                _nftContract,
                _tokenID,
                _orderID,
                imo.typeOrder,
                imo.tokenPrice,
                IMultilevelRoyalty.BidStatus.NotAccepted,
                0
            );
        }

        return true;

    }

    /**
     * @notice used to create order to sell MLR NFT by nft sell criteria.
     * @param _nftContract  NFT address
     * @param _tokenID  NFT token id
     * @param _orderID Order Id of NFT
     */
    function sellNftOnCriteriaFromMLR(
        address _nftContract,
        uint256 _tokenID,
        uint256 _orderID
    ) public
    sellMLRValidator( _nftContract, _tokenID )
    returns ( bool ) {
        
        IMultilevelRoyalty mlr = IMultilevelRoyalty( mlrFactory.getMLR(_nftContract, _tokenID) );
        IMultilevelRoyalty.Order memory imo = mlr.orders( _orderID );

        require( imo.buyerAddress == payable(address(this)), "Only buyer can sell" );

        // set royalty fee and buyout price
        mlr.updateRoyaltyInfo(sellNFT.royalty, sellNFT.buyoutPrice);
        
        uint256 priceChange;
        if ( sellNFT.isFixedAbovePrice ) {
            priceChange = sellNFT.abovePriceRate;
        } else {
            priceChange = imo.tokenPrice.mul( sellNFT.abovePriceRate ).div( 100 );
        }
        uint256 sellPrice = imo.tokenPrice.add( priceChange );

        uint256 endSellOrderTime = imo.isFixedProtection ? imo.protectionTime - 86400 : block.timestamp + imo.protectionTime - 86400;

        require( block.timestamp < endSellOrderTime, "Insufficient offer time" );
        uint256 newProtectionTime = endSellOrderTime;
        if (!sellNFT.isFixedProtection) {
            newProtectionTime -= block.timestamp;
        }
        
        mlr.createOrder(
            sellNFT.buyoutPrice,
            sellNFT.royalty,
            sellPrice,
            sellNFT.protectionRate,
            sellNFT.isFixedProtection,
            newProtectionTime,
            sellNFT.isAuction,
            endSellOrderTime
        );
        
        emit SellNFTOnCriteriaFromMLR(
            _nftContract,
            _tokenID,
            _orderID,
            sellNFT.isAuction,
            sellPrice,
            sellNFT.protectionRate,
            sellNFT.isFixedProtection,
            newProtectionTime
        );
        
        return true;
    
    }

    function getFundsFromDownsideProtectionAsBuyerFromMLR(
        address _nftContract,
        uint256 _tokenID,
        uint256 _orderID
    ) public returns ( bool ) {

        require( mlrFactory.getMLR(_nftContract, _tokenID) != address(0), "MLR doesn't exist" );

        IMultilevelRoyalty mlr = IMultilevelRoyalty( mlrFactory.getMLR(_nftContract, _tokenID) );
        mlr.claimDownsideProtectionAmount( _orderID );

        return true;

    }

    function getFundsFromDownsideProtectionAsSellerFromMLR(
        address _nftContract,
        uint256 _tokenID,
        uint256 _orderID
    ) public returns ( bool ) {

        require( mlrFactory.getMLR(_nftContract, _tokenID) != address(0), "MLR doesn't exist" );

        IMultilevelRoyalty mlr = IMultilevelRoyalty( mlrFactory.getMLR(_nftContract, _tokenID) );
        mlr.claimDownsideProtectionAmount( _orderID );

        return true;

    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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