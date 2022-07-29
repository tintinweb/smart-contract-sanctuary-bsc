// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// import ERC721 iterface
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IDepository {
	function initialize() external;
    function deposit() external payable returns(uint256);
    function withdraw(uint256 depositId) external returns(uint256);
}

interface IMultilevelRoyalty {
	function initialize(uint32 _royaltyFee, address _nftOwner) external returns (bool);
}

interface IMLRFactory {
	function deleteMLR(address _nftContract, uint256 _tokenID) external returns (bool);
}

contract MultilevelRoyalty is Ownable, ERC20 {

	uint256 public maxRoyaltyOwner;
	address public nftContract;
	uint256 public tokenID;
	string private _contractName;
	address public factory;
	// define multilevel royalty order
	bool public isInitialized;
	address payable public currentOwner;
	uint256 public buyPrice;	// current buy price
	address payable[] public royaltyHolders;
	mapping( address => uint256 ) private royaltyIndex; // 2 = second index, 0 = no index
	mapping( address => uint256 ) public buyoutPrices;		// if 0, no buyout

	IDepository public depository;

	enum OrderType { FixedPay, AuctionType }
    enum OrderStatus { Active, Bidded, UnderDownsideProtectionPhase, Completed, Cancelled }
    enum BidStatus { NotAccepted, Pending, Refunded, Executed }

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
        uint256 protectionTime;
		uint256 soldTime; // time when order sold, if equal to 0 than order unsold (so no need to use additional variable "bool saleNFT")
		uint256 offerClosingTime;	// for auction
	}
	
	uint256 public orderIdCount;
	mapping(uint256 => Order) public orders;	// identify offers by offerID
	mapping (address => mapping(uint256 => BidStatus)) public buyerBidStatus;	// To check a buyer's bid status(can be used in frontend)

	event RoyaltyInit(
		address nftOwner,
		address nftContract,
		uint256 tokenID,
		string contractName,
		uint32 royaltyFee
	);
	
	event RoyaltyAdded(
		address owner,
		address nftContract,
		uint256 tokenID,
		uint32 royaltyFee
	);

	event RoyaltyUpdated(
		address previousOwner,
		address nftContract,
		uint256 tokenID,
		uint32 royaltyFee
	);

	event BuyoutPriceSet(
		address owner,
		address nftContract,
		uint256 tokenID,
		uint256 buyoutPrice
	);

	event PreviousOwnerChanged(
		address oldPreviousOwner,
		address newPreviousOwner,
		address nftContract,
		uint256 tokenID
	);

	event CreateOrder(
		uint256 orderID,
		OrderType typeOrder,
		uint256 tokenPrice,
		uint64 protectionRate,
		uint256 protectionTime
	);

    event BuyOrder(
		uint256 orderID,
		OrderType typeOrder,
		address indexed buyerAddress,
		uint256 protectionAmount,
		uint256 protectionExpiryTime
	);

    event ClaimDownsideProtection(
		uint256 orderID,
		uint256 statusOrder,
		uint256 soldTime,
		address indexed buyerOrSeller,
		uint256 claimAmount
	);

	event CreateBid(
		uint256 orderID,
		OrderType typeOrder,
		address indexed buyerAddress,
		uint256 bidAmount
	);

	event CancelOrder(
		uint256 orderID
	);

	constructor(
		address _nftContract,
		uint256 _tokenID,
		uint256 _maxRoyaltyOwner,
		string memory _name,
		string memory _tokenName,
		string memory _tokenSymbol,
		address _depository
	) ERC20(_tokenName, _tokenSymbol) {
		require( _nftContract != address(0), "NA" );
		
		factory = msg.sender;
		nftContract = _nftContract;
		tokenID = _tokenID;
		maxRoyaltyOwner = _maxRoyaltyOwner;
		_contractName = _name;
		depository = IDepository( _depository );

	}

	function decimals() public view virtual override returns (uint8) {
        return 2;
    }

	function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
		require(balanceOf(owner) == amount, "Only can transfer entire balance");
        _transfer(owner, to, amount);
		_changeRoyaltyHolder(owner, to);
        return true;
    }

	function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
		require(balanceOf(from) == amount, "Only can transfer entire balance");
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
		_changeRoyaltyHolder(from, to);
        return true;
    }

	function contractName() public view returns (string memory) {
		return _contractName;
	}

	receive() external payable {}

	function onERC721Received(address, address, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }

	// For only factory
	function initialize(
		uint32 _royaltyFee,
		address _nftOwner
	) external returns ( bool ) {
		require( msg.sender == factory, "Only factory can initialize" );
		
		currentOwner = payable( _nftOwner );
		_mint( _nftOwner, _royaltyFee );
		isInitialized = true;

		emit RoyaltyInit(
			_nftOwner,
			nftContract,
			tokenID,
			_contractName,
			_royaltyFee
		);

		return true;
	}

	// For current owner
	function addRoyalty(
		address _nftContract,
		uint256 _tokenID,
		uint32 _royaltyFee
	) external returns ( bool ) {
		require( _nftContract == nftContract && _tokenID == tokenID, "Please select the correct NFT" );
		require( isInitialized, "Royalty should be initialized" );
		require( currentOwner == payable(msg.sender), "Only NFT owner can add royalty" );
		require( balanceOf(msg.sender) == 0, "Already set royalty" );
		require( royaltyHolders.length < maxRoyaltyOwner, "Royalty owner limit is exceeded" );

		_mint( msg.sender, _royaltyFee );

		emit RoyaltyAdded(
			msg.sender,
			_nftContract,
			_tokenID,
			_royaltyFee
		);

		return true;
	}

	// For previous owner
	function updateRoyalty(
		address _nftContract,
		uint256 _tokenID,
		uint32 _royaltyFee
	) external returns ( bool ) {
		require( _nftContract == nftContract && _tokenID == tokenID, "Please select the correct NFT" );
		require( isInitialized, "Royalty should be initialized" );
		require( balanceOf(msg.sender) > 0, "Only previous owner can update" );
		require( _royaltyFee < balanceOf(msg.sender), "Royalty Fee can't increase" );

		_burn(msg.sender, balanceOf(msg.sender) - _royaltyFee);

		if ( balanceOf(msg.sender) == 0 ) {
			_deleteRoyaltyHolder( msg.sender );
			delete buyoutPrices[msg.sender];
		}

		emit RoyaltyUpdated(
			msg.sender,
			_nftContract,
			_tokenID,
			_royaltyFee
		);

		return true;
	}

	function _deleteRoyaltyHolder(address _royaltyHolder) internal {
		uint256 targetIndex = royaltyIndex[_royaltyHolder] - 1;
		for (uint256 index = targetIndex; index < royaltyHolders.length - 1; index ++) {
			royaltyHolders[index] = royaltyHolders[index + 1];
			royaltyHolders.pop();
		}
		delete royaltyIndex[_royaltyHolder];
	}

	// For current owner or previous owner
	function setBuyoutPrice(
		address _nftContract,
		uint256 _tokenID,
		uint256 _buyoutPrice
	) external returns ( bool ) {
		require( _nftContract == nftContract && _tokenID == tokenID, "Please select the correct NFT" );
		require( isInitialized, "Royalty should be initialized" );
		require( currentOwner == payable(msg.sender) || balanceOf(msg.sender) > 0, "Only NFT owner can set buyout" );

		buyoutPrices[msg.sender] = _buyoutPrice;

		emit BuyoutPriceSet(
			msg.sender,
			_nftContract,
			_tokenID,
			_buyoutPrice
		);

		return true;
	}

	// For any user
	function buyOut(
		address _nftContract,
		uint256 _tokenID,
		address _previousOwner
	) external payable {
		require( _nftContract == nftContract && _tokenID == tokenID, "Please select the correct NFT" );
		require( isInitialized, "Royalty should be initialized" );
		require( royaltyIndex[_previousOwner] > 0 , "Should be royalty owner" );
		uint256 buyoutPrice = buyoutPrices[_previousOwner];	// price per 1%
		uint32 realRoyalty = getRealRoyalty(_previousOwner);
		require( msg.value >= buyoutPrice * realRoyalty / 100 && buyoutPrice > 0, "Less than buyout price or no" );

		uint256 royaltyFee = balanceOf(_previousOwner);
		_burn(_previousOwner, royaltyFee);
		_mint(msg.sender, royaltyFee);

		_changeRoyaltyHolder( _previousOwner, msg.sender );

		payable(_previousOwner).transfer(buyoutPrice * realRoyalty);

		emit PreviousOwnerChanged(
			_previousOwner,
			msg.sender,
			_nftContract,
			_tokenID
		);
	}

	function getRealRoyalty( address _royaltyHolder ) public view returns (uint32) {
		uint256 targetIndex = royaltyIndex[_royaltyHolder] - 1;
		uint totalAmount = 0;
		uint realRoyalty = 0;
		for(uint256 index = royaltyHolders.length - 1; index >= targetIndex; index --) {
			realRoyalty = (10000 - totalAmount) * balanceOf(royaltyHolders[index]) / 10000;
			totalAmount = totalAmount + realRoyalty;
		}

		return uint32(realRoyalty);
	}

	function _changeRoyaltyHolder(
		address _previousOwner,
		address _newOwner
	) internal {
		uint256 targetIndex = royaltyIndex[_previousOwner] - 1;
		royaltyHolders[targetIndex] = payable(_newOwner);
		royaltyIndex[_newOwner] = royaltyIndex[_previousOwner];
		delete royaltyIndex[_previousOwner];

		buyoutPrices[_newOwner] = buyoutPrices[_previousOwner];
		delete buyoutPrices[_previousOwner];
	}

	function getBuyoutList(
		address _nftContract,
		uint256 _tokenID
	) public view returns (
		address payable[] memory royaltyHolders_,
		uint256[] memory buyoutPrices_
	) {
		require( _nftContract == nftContract && _tokenID == tokenID, "Please select the correct NFT" );

		uint256 length = 0;
		for(uint256 index = 0; index < royaltyHolders.length; index ++) {
			if ( buyoutPrices[royaltyHolders[index]] > 0 ) {
				length ++;
			}
		}

		address payable[] memory tempHolders = new address payable[](length);
		uint256[] memory tempBuyout = new uint256[](length);
		length = 0;
		for(uint256 index = 0; index < royaltyHolders.length; index ++) {
			if ( buyoutPrices[royaltyHolders[index]] > 0 ) {
				tempHolders[length] = royaltyHolders[index];
				tempBuyout[length] = buyoutPrices[royaltyHolders[index]];
				length ++;
			}
		}
		royaltyHolders_ = tempHolders;
		buyoutPrices_ = tempBuyout;
	}

	// For downside protection and auction

	modifier createOrderValidator(
		address _nftContract,
		uint256 _tokenID,
		uint256 _tokenPrice,
		bool _acceptOffers,
		uint256 _offerClosingTime
	) {
		require( _nftContract == nftContract && _tokenID == tokenID, "Please select the correct NFT" );
		require( currentOwner == payable(msg.sender), "Invalid token owner" );
		require( _tokenPrice > 0, "Invalid token price" );
		if ( _acceptOffers ) {
			require( _offerClosingTime > 0, "Auction orders need closing time" );
		}
		_;
	}

	modifier buyFixedPayOrderValidator( uint256 _orderId ) {
        Order storage order = orders[_orderId];
        require( order.statusOrder == OrderStatus.Active, "Invalid OrderStatus" );   
        require( order.typeOrder == OrderType.FixedPay, "Invalid OrderType" );   // AuctionType orders are directly executed by seller
        _;
    }

    modifier onlySeller( uint256 _orderId ) {
        Order storage order = orders[_orderId];
        require( payable(msg.sender) == order.sellerAddress, "Only seller can call function" );
        _;
    }

	function createOrder(
		address _nftContract,
		uint256 _tokenID,
		uint256 _tokenPrice,
		uint64 _protectionRate, // downside protection rate in percentage with 2 decimals (i.e. 3412 = 34.12%)
		uint256 _protectionTime,// downside protection duration (in seconds). I.e. 604800 = 1 week (60*60*24*7)
        bool _acceptOffers,     // false = fix price order, true - auction order
        uint256 _offerClosingTime   // Epoch time (in seconds) when auction will be closed (or fixed order expired)
	) external
	createOrderValidator( _nftContract, _tokenID, _tokenPrice, _acceptOffers, _offerClosingTime )
	{
		require(_protectionRate <= 10000 , "Protection rate above 100%");
		
		orderIdCount ++;
		Order storage order = orders[orderIdCount];

		order.statusOrder = OrderStatus.Active;
		order.typeOrder = _acceptOffers ? OrderType.AuctionType : OrderType.FixedPay;
		order.sellerAddress = payable( msg.sender );
		order.buyerAddress = payable( address(0) );
		order.tokenPrice = _tokenPrice;
		order.protectionRate = _protectionRate;
		order.protectionTime = _protectionTime;
		order.offerClosingTime = _acceptOffers ? _offerClosingTime : 0;

		emit CreateOrder(
			orderIdCount,
			order.typeOrder,
			_tokenPrice,
			_protectionRate,
			_protectionTime
		);
	}

	function buyFixedPayOrder( uint256 _orderId ) external payable 
	buyFixedPayOrderValidator( _orderId )
	{
		Order storage order = orders[_orderId];
        require( msg.value >= order.tokenPrice, "token price" );
        
        _proceedPayments( _orderId, order.tokenPrice, order.protectionRate, payable(msg.sender) );
        order.buyerAddress = payable(msg.sender);

        emit BuyOrder(
			_orderId,
			order.typeOrder,
			order.buyerAddress,
			order.protectionAmount,
			order.soldTime + order.protectionTime
		);
	}

	function cancelOrder( uint256 _orderId ) external 
	onlySeller( _orderId )
	{
        Order storage order = orders[_orderId];
        require( order.statusOrder == OrderStatus.Active, "Invalid OrderStatus" );

        order.statusOrder = OrderStatus.Cancelled;        

        emit CancelOrder(_orderId);
    }

	function claimDownsideProtectionAmount( uint256 _orderId ) external {
        Order storage order = orders[_orderId];
        require(order.statusOrder == OrderStatus.UnderDownsideProtectionPhase, "Invalid OrderStatus");   

        // Fetch the token amount worth the face value of protection amount
        if ( msg.sender == order.sellerAddress && 
			sellerCheckClaimDownsideProtectionAmount( _orderId ) && 
			order.soldTime != 0 
		) {
            order.statusOrder = OrderStatus.Completed;
            uint256 value = depository.withdraw( order.depositId );      // Withdraw from depository
			uint256 allRoyaltyFees = 0;
			if ( order.tokenPrice > order.buyPrice ) {
				uint256 profit = value - order.buyPrice * order.protectionRate / 10000;
				allRoyaltyFees = _sendRoyaltyFee( profit );
			}
            order.sellerAddress.transfer( value - allRoyaltyFees );   // Transfer to Seller the whole Yield Amount
            
            emit ClaimDownsideProtection(
				_orderId,
				uint(order.statusOrder),
				order.soldTime,
				msg.sender,
				value
			);
        } else if ( msg.sender == order.buyerAddress && 
			buyerCheckClaimDownsideProtectionAmount(_orderId) && 
			order.soldTime != 0
		) {
            order.statusOrder = OrderStatus.Cancelled;
            currentOwner = order.sellerAddress;     // Send NFT back to seller
			_deleteRoyaltyHolder( currentOwner );
			buyPrice = order.buyPrice;
            
			uint256 value = depository.withdraw( order.depositId );      // Withdraw from depository
            order.buyerAddress.transfer( order.protectionAmount );    // Transfer to Buyer only his protection amount
            order.sellerAddress.transfer( value - order.protectionAmount );   // Transfer to Seller the Yield reward
            
            emit ClaimDownsideProtection(
				_orderId,
				uint(order.statusOrder),
				order.soldTime,
				msg.sender,
				order.protectionAmount
			);
        }
    }

	// claim money from downside protection on seller behalf
    function claimDownsideProtectionOnSellerBehalf(
		address _seller,
		uint256 _orderId
	) external {
        Order storage order = orders[_orderId];
        require(order.statusOrder == OrderStatus.UnderDownsideProtectionPhase, "Invalid OrderStatus");   

        // Fetch the token amount worth the face value of protection amount
        if (
			_seller == order.sellerAddress &&
			sellerCheckClaimDownsideProtectionAmount(_orderId) &&
			order.soldTime != 0
		) {
            order.statusOrder = OrderStatus.Completed;
            uint256 value = depository.withdraw( order.depositId );      // Withdraw from depository
            uint256 allRoyaltyFees = 0;
			if ( order.tokenPrice > order.buyPrice ) {
				uint256 profit = value - order.buyPrice * order.protectionRate / 10000;
				allRoyaltyFees = _sendRoyaltyFee( profit );
			}
            order.sellerAddress.transfer( value - allRoyaltyFees );   // Transfer to Seller the whole Yield Amount
            
            emit ClaimDownsideProtection(
				_orderId,
				uint(order.statusOrder),
				order.soldTime,
				_seller,
				value
			);
        }
    }

	function sellerCheckClaimDownsideProtectionAmount( uint256 _orderId ) public view returns ( bool ) {
        Order storage order = orders[_orderId];
        
		if ( currentOwner != order.buyerAddress ) {       // tokenOwnership changed
            return true;
        }
        
        if ( block.timestamp > order.soldTime + order.protectionTime ) {     // protectionTime surpasses
            return true;
        }

        return false;
    }

	function buyerCheckClaimDownsideProtectionAmount( uint256 _orderId ) public view returns ( bool ) {
        Order storage order = orders[_orderId];
        
        if ( currentOwner == order.buyerAddress && block.timestamp <= order.soldTime + order.protectionTime ) {       // tokenOwnership & protectionTime DONT surpasses
            return true;
        }

        return false;
    }

	function createBid( uint256 _orderId ) external payable {
        Order storage order = orders[_orderId];
        uint256 previousMaxOfferAmount = order.tokenPrice;
        
		require( msg.value > previousMaxOfferAmount, "Investment too low" );
        require( order.statusOrder == OrderStatus.Active || order.statusOrder == OrderStatus.Bidded, "Invalid OrderType" );
        require( order.typeOrder == OrderType.AuctionType, "Invalid OrderType" );
        require( order.offerClosingTime >= block.timestamp, "Bidding beyond Closing Time" );

        address payable previousBuyer =  order.buyerAddress;

        // Update the new bidder details
        order.tokenPrice = msg.value;   // maxOfferAmount
        order.buyerAddress = payable(msg.sender);
        buyerBidStatus[msg.sender][_orderId] = BidStatus.Pending;
        order.statusOrder = OrderStatus.Bidded;

        // Return the funds to the previous bidder
        if ( previousBuyer != address(0) ) {
            buyerBidStatus[previousBuyer][_orderId] = BidStatus.Refunded; 
            previousBuyer.transfer( previousMaxOfferAmount );
        }

        emit CreateBid(_orderId, order.typeOrder, msg.sender, msg.value);
    }

	function executeBid( uint256 _orderId ) external {
        Order storage order = orders[_orderId];

        require(order.typeOrder == OrderType.AuctionType, "Invalid OrderType");
        require(order.statusOrder == OrderStatus.Bidded, "Invalid OrderType");
        require(order.offerClosingTime <= block.timestamp, "Executing Bid before Closing Time");

        _proceedPayments( _orderId, order.tokenPrice, order.protectionRate, order.buyerAddress );
        buyerBidStatus[order.buyerAddress][_orderId] = BidStatus.Executed;

        emit BuyOrder(
			_orderId,
			order.typeOrder,
			order.buyerAddress,
			order.protectionAmount,
			order.soldTime + order.protectionTime
		);
    }

	function _proceedPayments(
		uint256 _orderId,
		uint256 _price,
		uint256 _protectionRate,
		address payable buyerAddress
	) internal {
        Order storage order = orders[_orderId];
        order.statusOrder = OrderStatus.UnderDownsideProtectionPhase;
		
        uint256 downsideAmount = _price * _protectionRate / 10000;
		uint256 allRoyaltyFees = 0;
		if ( _price - buyPrice > 0 ) {
			uint256 profit = (_price - buyPrice) * (10000 - _protectionRate) / 10000;
			allRoyaltyFees = _sendRoyaltyFee( profit );
		}
        order.sellerAddress.transfer( _price - downsideAmount - allRoyaltyFees );        // Transfer the seller his amount

        uint256 depositId = depository.deposit{value: downsideAmount}();     // Invest the downside in Venus
        order.depositId = depositId;

        currentOwner = buyerAddress;     // Transfer the NFT
		royaltyHolders.push( order.sellerAddress );
		royaltyIndex[order.sellerAddress] = royaltyHolders.length;
		order.buyPrice = buyPrice;
		buyPrice = _price;
        order.protectionAmount = downsideAmount;
        order.soldTime = block.timestamp;
    }

	function _sendRoyaltyFee( uint256 _profit ) internal returns ( uint256 allRoyaltyFees_ ) {
		allRoyaltyFees_ = 0;
		for (uint256 index = royaltyHolders.length - 1; index >= 0; index --) {
			uint256 realRoyalty = _profit * getRealRoyalty( royaltyHolders[index] ) / 10000;
			royaltyHolders[index].transfer( realRoyalty );
			allRoyaltyFees_ += realRoyalty;
		}
	}
	
	// For current owner
	function withdrawNFT(
		address _nftContract,
		uint256 _tokenID
	) external {
		require( _nftContract == nftContract && _tokenID == tokenID, "Please select the correct NFT" );
		require( isInitialized, "Royalty should be initialized" );
		require( currentOwner == payable(msg.sender), "Only NFT owner can withdraw NFT" );
		require( totalSupply() == 0, "All royalty should be zero" );

		IERC721(nftContract).safeTransferFrom( address(this), currentOwner, tokenID );
		IMLRFactory(factory).deleteMLR(_nftContract, _tokenID);
		selfdestruct( currentOwner );
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