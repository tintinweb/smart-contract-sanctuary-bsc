/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7 <0.9.0;


//import "../utils/Context.sol";
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


//import "@openzeppelin/contracts/access/Ownable.sol";
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


//import "../../utils/introspection/IERC165.sol";
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


//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
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


//import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
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


//import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
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


//import "./Common/ITrade.sol";
//-----------------------------------------------------------------------
// ITrade
//-----------------------------------------------------------------------
interface ITrade {
    //----------------------------------------
    // Events
    //----------------------------------------
    event MaxPriceModified( uint256 maxPrice );
    event MinPriceModified( uint256 minPrice );

    event MaxPeriodModified( uint256 maxPrice );
    event MinPeriodModified( uint256 minPrice );

    event OnlyNoLimitPeriodModified( bool );
    event AcceptNoLimiPeriodModified( bool );

    //----------------------------------------
    // Functions
    //----------------------------------------
    function maxPrice() external view returns ( uint256 );
    function minPrice() external view returns ( uint256 );
    function setMaxPrice( uint256 price ) external;
    function setMinPrice( uint256 price ) external;

    function maxPeriod() external view returns ( uint256 );
    function minPeriod() external view returns ( uint256 );
    function setMaxPeriod( uint256 period ) external;
    function setMinPeriod( uint256 period ) external;

    function onlyNoLimitPeriod() external view returns (bool);
    function acceptNoLimitPeriod() external view returns (bool);
    function setOnlyNoLimitPeriod( bool flag ) external;
    function setAcceptNoLimitPeriod( bool flag ) external;

    //----------------------------------------------
    // トークンの転送情報
    //----------------------------------------------
    // uint256[4]の内訳は下記
    // ・[0]:トークンコントラクト(ERC721へキャストして使う)
    // ・[1]:トークンID
    // ・[2]:供出側(addressへキャストして使う)
    // ・[3]:受領側(addressへキャストして使う)
    //----------------------------------------------
    function transferInfo( uint256 tradeId ) external view returns (uint256[4] memory);

    //----------------------------------------------
    // 支払い情報の取得
    //----------------------------------------------
    // uint256[2]の内訳は下記
    // ・[0]:支払い先(addressへキャストして使う)
    // ・[1]:支払額
    //----------------------------------------------
    function payInfo( uint256 tradeId ) external view returns (uint256[2] memory);

    //----------------------------------------------
    // 払い戻し情報の取得
    //----------------------------------------------
    // uint256[2]の内訳は下記
    // ・[0]:払い戻し先(addressへキャストして使う)
    // ・[1]:払い戻し額
    //----------------------------------------------
    function refundInfo( uint256 tradeId ) external view returns (uint256[2] memory);
}


//import "./Common/ISale.sol";
//-----------------------------------------------------------------------
// ISale
//-----------------------------------------------------------------------
interface ISale {
    //----------------------------------------
    // Events
    //----------------------------------------
    event Sale( address indexed contractAddress, uint256 indexed tokenId, address indexed seller, uint256 price, uint256 expireDate, uint256 saleId );
    event SaleCanceled( uint256 indexed saleId, address indexed contractAddress, uint256 indexed tokenId, address seller );
    event Sold( uint256 indexed saleId, address indexed contractAddress, uint256 indexed tokenId, address seller, address buyer, uint256 price );

    event SaleInvalidated( uint256 indexed saleId, address indexed contractAddress, uint256 indexed tokenId, address seller );

    //----------------------------------------
    // Functions
    //----------------------------------------
    function sell( address msgSender, address contractAddress, uint256 tokenId, uint256 price, uint256 period ) external;
    function cancelSale( address msgSender, uint256 saleId ) external;
    function buy( address msgSender, uint256 saleId ) external;

    function invalidateSales( uint256[] calldata saleIds ) external;
}


//import "./Common/IOffer.sol";
//-----------------------------------------------------------------------
// IOffer
//-----------------------------------------------------------------------
interface IOffer {
    //----------------------------------------
    // Events
    //----------------------------------------
    event Offer( address indexed contractAddress, uint256 indexed tokenId, address owner, address offeror, uint256 price, uint256 expireDate, uint256 offerId );
    event OfferCanceled( uint256 indexed offerId, address indexed contractAddress, uint256 indexed tokenId, address owner, address offeror, uint256 price );
    event OfferAccepted( uint256 indexed offerId, address indexed contractAddress, uint256 indexed tokenId, address owner, address offeror, uint256 price );
    event OfferWithdrawn( uint256 indexed offerId, address indexed contractAddress, uint256 indexed tokenId, address owner, address offeror, uint256 price );

    event OfferInvalidated( uint256 indexed offerId, address indexed contractAddress, uint256 indexed tokenId, address owner, address offeror );

    //----------------------------------------
    // Functions
    //----------------------------------------
    function offer( address msgSender, address contractAddress, uint256 tokenId, uint256 price, uint256 period ) external;
    function cancelOffer( address msgSender, uint256 offerId ) external;
    function acceptOffer( address msgSender, uint256 offerId ) external;
    function withdrawFromOffer( address msgSender, uint256 offerId ) external;

    function invalidateOffers( uint256[] calldata offerIds ) external;
}


//import "./Common/IAuction.sol";
//-----------------------------------------------------------------------
// IAuction
//-----------------------------------------------------------------------
interface IAuction  {
    //----------------------------------------
    // Events
    //----------------------------------------
    event Auction( address indexed contractAddress, uint256 indexed tokenId, address auctioneer, uint256 startingPrice, uint256 expireDate, uint256 auctionId );
    event AuctionCanceled( uint256 indexed auctionId, address indexed contractAddress, uint256 indexed tokenId, address auctioneer );
    event AuctionBidded ( uint256 indexed auctionId,  address indexed contractAddress, uint256 indexed tokenId, address auctioneer, address newBidder, address oldBidder, uint256 newPrice, uint256 updatedExpireDate ); 
    event AuctionFinished( uint256 indexed auctionId, address indexed contractAddress, uint256 indexed tokenId, address auctioneer, address winner, uint256 price, uint256 expireDate );
    event AuctionWithdrawn( uint256 indexed auctionId, address indexed contractAddress, uint256 indexed tokenId, address auctioneer, address bidder, uint256 price );

    event AuctionInvalidated( uint256 indexed auctionId, address indexed contractAddress, uint256 indexed tokenId, address auctioneer, address bidder );

    //----------------------------------------
    // Functions
    //----------------------------------------
    function auction( address msgSender, address contractAddress, uint256 tokenId, uint256 startingPrice, uint256 period ) external;
    function cancelAuction( address msgSender, uint256 auctionId ) external;
    function bid( address msgSender, uint256 auctionId, uint256 price ) external;
    function finishAuction( address msgSender, uint256 auctionId ) external;
    function withdrawFromAuction( address msgSender, uint256 auctionId ) external;

    function invalidateAuctions( uint256[] calldata auctionIds ) external;
}



//import "./Common/IDutchAuction.sol";
//-----------------------------------------------------------------------
// IDutchAuction
//-----------------------------------------------------------------------
interface IDutchAuction  {
    //----------------------------------------
    // Events
    //----------------------------------------
    event DutchAuction( address indexed contractAddress, uint256 indexed tokenId, address auctioneer, uint256 startingPrice, uint256 endingPrice, uint256 expireDate, uint256 priceDownStartDate, uint256 priceDownEndDate, uint256 dutchAuctionId );
    event DutchAuctionCanceled( uint256 indexed dutchAuctionId, address indexed contractAddress, uint256 indexed tokenId, address auctioneer );
    event DutchAuctionSold( uint256 indexed dutchAuctionId, address indexed contractAddress, uint256 indexed tokenId, address auctioneer, address buyer, uint256 price ); 

    event DutchAuctionInvalidated( uint256 indexed dutchAuctionId, address indexed contractAddress, uint256 indexed tokenId, address auctioneer );

    //----------------------------------------
    // Functions
    //----------------------------------------
    function dutchAuction( address msgSender, address contractAddress, uint256 tokenId, uint256 startingPrice, uint256 endingPrice, uint256 period, uint256 startMargin, uint256 endMargin ) external;
    function cancelDutchAuction( address msgSender, uint256 dutchAuctionId ) external;
    function buyDutchAuction( address msgSender, uint256 dutchAuctionId ) external;

    function invalidateDutchAuctions( uint256[] calldata dutchAuctionIds ) external;
}


//-----------------------------------------
// SabongMarket
//-----------------------------------------
contract SabongMarket is Ownable, ReentrancyGuard {
    //-----------------------------------------
    // イベント
    //-----------------------------------------
    // 手数料関連
    event FeeReceiverModified( address receiver );
    event FeeRateModified( uint256 rate );

    // コイン
    event CoinModified( address contractAddress );

    // 取引開始の停止フラグ
    event SaleStartSuspended( bool );
    event OfferStartSuspended( bool );
    event AuctionStartSuspended( bool );
    event DutchAuctionStartSuspended( bool );

    // 構成要素
    event SaleModified( address contractAddress );
    event OfferModified( address contractAddress );
    event AuctionModified( address contractAddress );
    event DutchAuctionModified( address contractAddress );

    // 取り扱い商品
    event ProductModified( uint256 indexed productType, address contractAddress );

    //-----------------------------------------
    // 定数
    //-----------------------------------------
/*
    // mainnet
    address constant private OWNER_ADDRESS = 0x0000000000000000000000000000000000000000;
    address constant private MANAGER_ADDRESS = 0x0000000000000000000000000000000000000000;
    address constant private COIN_ADDRESS = 0x0000000000000000000000000000000000000000;
*/
    // testnet
    address constant private OWNER_ADDRESS = 0xf7831EA80Fc5179f86f82Af3aedDF2b7a2Ce13Df;
    address constant private MANAGER_ADDRESS = 0x0474Bbd0f1C84A5f8676E542625160d92Fe32cf2;
    address constant private COIN_ADDRESS = 0x4E4D04a6Eb1E6B1D3d907a0939b4872B665E1df2;

    uint256 constant private FEE_RATE_BASE = 10000;     // 手数料の基底値（万分率）
    uint256 constant private FEE_RATE_DEFAULT = 500;    // 手数料のデフォルト値(5%)

    //-----------------------------------------
    // 管理
    //-----------------------------------------
    // 管理者(複数登録可能)
    mapping( address => bool ) private _map_manager;

    //-----------------------------------------
    // 設定
    //-----------------------------------------
    // 手数料関連
    address private _fee_receiver;
    uint256 private _fee_rate;

    // 取引に利用するコイン(ERC20)
    IERC20 _coin;

    // 取引開始の停止フラグ
    bool private _sale_start_suspended;
    bool private _offer_start_suspended;
    bool private _auction_start_suspended;
    bool private _dutch_auction_start_suspended;

    // 構成要素
    ISale private _sale;
    IOffer private _offer;
    IAuction private _auction;
    IDutchAuction private _dutch_auction;

    // 取り扱い商品(ERC721)
    mapping( uint256 => address ) private _product_address;

    //--------------------------------------------------------
    // [modifier] onlyOwnerOrManager
    //--------------------------------------------------------
    modifier onlyOwnerOrManager() {
        require( msg.sender == owner() || isManager(msg.sender), "caller is not the owner neither manager" );
        _;
    }

    //-----------------------------------------
    // コンストラクタ
    //-----------------------------------------
    constructor() Ownable() {
        transferOwnership( OWNER_ADDRESS );

        _map_manager[msg.sender] = true;
        _map_manager[MANAGER_ADDRESS] = true;

        _fee_receiver = OWNER_ADDRESS;
        emit FeeReceiverModified( _fee_receiver );

        _fee_rate = FEE_RATE_DEFAULT;
        emit FeeRateModified( _fee_rate );

        _coin = IERC20( COIN_ADDRESS );
        emit CoinModified( address(_coin) );

        // 各種トレードは停止しておく
        _sale_start_suspended = true;
        emit SaleStartSuspended( _sale_start_suspended );

        _offer_start_suspended = true;
        emit OfferStartSuspended( _offer_start_suspended );

        _auction_start_suspended = true;
        emit AuctionStartSuspended( _auction_start_suspended );

        _dutch_auction_start_suspended = true;
        emit DutchAuctionStartSuspended( _dutch_auction_start_suspended );
    }

    //--------------------------------------------------------
    // [public] isManager
    //--------------------------------------------------------
    function isManager( address target ) public view returns (bool) {
        return( _map_manager[target] );
    }

    //--------------------------------------------------------
    // [external/onlyOwner] setManager
    //--------------------------------------------------------
    function setManager( address target, bool flag ) external onlyOwner {
        if( flag ){
            _map_manager[target] = true;
        }else{
            delete _map_manager[target];
        }
    }

    //-----------------------------------------
    // [external] 確認
    //-----------------------------------------
    // 手数料関連
    function feeReceiver() external view returns (address) { return( _fee_receiver ); }
    function feeRate() external view returns (uint256) { return( _fee_rate ); }

    // コイン
    function coin() external view returns (address) { return( address(_coin) ); }

    // 取引開始の停止フラグ
    function saleStartSuspended() external view returns (bool) { return( _sale_start_suspended ); }
    function offerStartSuspended() external view returns (bool) { return( _offer_start_suspended ); }
    function auctionStartSuspended() external view returns (bool) { return( _auction_start_suspended ); }
    function dutchAuctionStartSuspended() external view returns (bool) { return( _dutch_auction_start_suspended ); }

    // 構成要素
    function sale() external view returns (address) { return( address(_sale) ); }
    function offer() external view returns (address) { return( address(_offer) ); }
    function auction() external view returns (address) { return( address(_auction) ); }
    function dutchAuction() external view returns (address) { return( address(_dutch_auction) ); }

    // 取り扱い商品
    function productAddress( uint256 productType ) external view returns (address) { return( _product_address[productType] ); }

    //-----------------------------------------
    // [external/onlyOwnerOrManager] 設定
    //-----------------------------------------
    // 手数料関連
    function setFeeReceiver( address receiver ) external onlyOwnerOrManager {
        _fee_receiver = receiver;
        emit FeeReceiverModified( _fee_receiver );
    }

    function setFeeRate( uint256 rate ) external onlyOwnerOrManager {
        _fee_rate = rate;
        emit FeeRateModified( _fee_rate );
    }

    // コイン
    function setCoin( address contractAddress ) external onlyOwnerOrManager {
        _coin = IERC20(contractAddress);
        emit CoinModified( address(_coin) );
    }

    // 取引開始の停止フラグ
    function setSaleStartSuspended( bool flag ) external onlyOwnerOrManager {
        _sale_start_suspended = flag;
        emit SaleStartSuspended( _sale_start_suspended );
    }

    function setOfferStartSuspended( bool flag ) external onlyOwnerOrManager {
        _offer_start_suspended = flag;
        emit OfferStartSuspended( _offer_start_suspended );
    }

    function setAuctionStartSuspended( bool flag ) external onlyOwnerOrManager {
        _auction_start_suspended = flag;
        emit AuctionStartSuspended( _auction_start_suspended );
    }

    function setDutchAuctionStartSuspended( bool flag ) external onlyOwnerOrManager {
        _dutch_auction_start_suspended = flag;
        emit DutchAuctionStartSuspended( _dutch_auction_start_suspended );
    }

    // 構成要素
    function setSale( address contractAddress ) external onlyOwnerOrManager {
        _sale = ISale(contractAddress);
        emit SaleModified( address(_sale) );
    }

    function setOffer( address contractAddress ) external onlyOwnerOrManager {
        _offer = IOffer( contractAddress );
        emit OfferModified( address(_offer) );
    }

    function setAuction( address contractAddress ) external onlyOwnerOrManager {
        _auction = IAuction( contractAddress );
        emit AuctionModified( address(_auction) );
    }

    function setDutchAuction( address contractAddress ) external onlyOwnerOrManager {
        _dutch_auction = IDutchAuction( contractAddress );
        emit DutchAuctionModified( address(_dutch_auction) );
    }

    // 取り扱い商品
    function setProductAddress( uint256 productType, address contractAddress ) external onlyOwnerOrManager {
        if( contractAddress != address(0) ){
            _product_address[productType] = contractAddress;
            emit ProductModified( productType, _product_address[productType] );
        }else{
            delete _product_address[productType];
            emit ProductModified( productType, 0x0000000000000000000000000000000000000000 );
        }
    }

    //-----------------------------------------
    // [external/nonReentrant] 窓口：Sale
    //-----------------------------------------
    // 販売
    function sell( uint256 productType, uint256 tokenId, uint256 price, uint256 period ) external nonReentrant {
        require( address(_sale) != address(0), "invalid sale" );
        require( !_sale_start_suspended, "sale suspended" );  // 新規セール中止中
        require( _product_address[productType] != address(0), "unknown productType" );

        _sale.sell( msg.sender, _product_address[productType], tokenId, price, period );
    }

    // 取り消し
    function cancelSale( uint256 saleId ) external nonReentrant {
        require( address(_sale) != address(0), "invalid sale" );

        _sale.cancelSale( msg.sender, saleId );
    }

    // 購入
    function buy( uint256 saleId ) external nonReentrant {
        require( address(_sale) != address(0), "invalid sale" );

        _sale.buy( msg.sender, saleId );

        // トークンの転送
        uint256[4] memory transferInfo = ITrade(address(_sale)).transferInfo( saleId );
        _transfer( transferInfo );

        // 支払い
        uint256[2] memory payInfo = ITrade(address(_sale)).payInfo( saleId );
        _pay( msg.sender, payInfo );
    }

    //-----------------------------------------
    // [external/nonReentrant] 窓口：Offer
    //-----------------------------------------
    // オファーを出す
    function offer( uint256 productType, uint256 tokenId, uint256 price, uint256 period ) external nonReentrant {
        require( address(_offer) != address(0), "invalid offer" );
        require( !_offer_start_suspended, "offer suspended" );  // 新規オファー中止中
        require( _product_address[productType] != address(0), "unknown productType" );

        _offer.offer( msg.sender, _product_address[productType], tokenId, price, period );

        // 預託
        _deposit( msg.sender, price );
    }

    // オファーの取り消し
    function cancelOffer( uint256 offerId ) external nonReentrant {
        require( address(_offer) != address(0), "invalid offer" );

        _offer.cancelOffer( msg.sender, offerId );

        // 払い戻し
        uint256[2] memory refundInfo = ITrade(address(_offer)).refundInfo( offerId );
        _refund( refundInfo );
    }

    // オファーの承諾
    function acceptOffer( uint256 offerId ) external nonReentrant {
        require( address(_offer) != address(0), "invalid offer" );

        _offer.acceptOffer( msg.sender, offerId );

        // トークンの転送
        uint256[4] memory transferInfo = ITrade(address(_offer)).transferInfo( offerId );
        _transfer( transferInfo );

        // 支払い（預託金から）
        uint256[2] memory payInfo = ITrade(address(_offer)).payInfo( offerId );
        _pay( address(0), payInfo );
    }

    // オファーからの払戻（無効化されたオファーの申請ユーザーが呼ぶ）
    function withdrawFromOffer( uint256 offerId ) external nonReentrant {
        require( address(_offer) != address(0), "invalid offer" );

        _offer.withdrawFromOffer( msg.sender, offerId );

        // 払い戻し
        uint256[2] memory refundInfo = ITrade(address(_offer)).refundInfo( offerId );
        _refund( refundInfo );
    }

    //-----------------------------------------
    // [external/nonReentrant] 窓口：Auction
    //-----------------------------------------
    // オークションの出品
    function auction( uint256 productType, uint256 tokenId, uint256 startingPrice, uint256 period ) external nonReentrant {
        require( address(_auction) != address(0), "invalid auction" );
        require( !_auction_start_suspended, "auction suspended" );  // 新規オークション中止中
        require( _product_address[productType] != address(0), "unknown productType" );

        _auction.auction( msg.sender, _product_address[productType], tokenId, startingPrice, period );
    }

    // オークションの取り消し
    function cancelAuction( uint256 auctionId ) external nonReentrant {
        require( address(_auction) != address(0), "invalid auction" );

        _auction.cancelAuction( msg.sender, auctionId );
    }

    // オークションに入札
    function bid( uint256 auctionId, uint256 price ) external nonReentrant {
        require( address(_auction) != address(0), "invalid auction" );

        // 既存の入札に対して払い戻し（既存データの入札者が有効であれば）
        uint256[2] memory refundInfo = ITrade(address(_auction)).refundInfo( auctionId );
        if( refundInfo[0] != 0 ){
            _refund( refundInfo );
        }

        _auction.bid( msg.sender, auctionId, price );

        // 預託
        _deposit( msg.sender, price );
    }

    // オークションの完了
    function finishAuction( uint256 auctionId ) external nonReentrant {
        require( address(_auction) != address(0), "invalid auction" );

        _auction.finishAuction( msg.sender, auctionId );

        // トークンの転送(落札者が有効なら／落札者がいなければ入札無し＝何もしない)
        uint256[4] memory transferInfo = ITrade(address(_auction)).transferInfo( auctionId );
        if( transferInfo[3] != 0 ){
            _transfer( transferInfo );

            // 支払い（預託金から）
            uint256[2] memory payInfo = ITrade(address(_auction)).payInfo( auctionId );
            _pay( address(0), payInfo );
        }
    }

    // 入札したオークションからの払戻（無効化されたオークションに入札していたユーザーが呼ぶ）
    function withdrawFromAuction( uint256 auctionId ) external nonReentrant {
        require( address(_auction) != address(0), "invalid auction" );

        _auction.withdrawFromAuction( msg.sender, auctionId );

        // 払い戻し
        uint256[2] memory refundInfo = ITrade(address(_auction)).refundInfo( auctionId );
        _refund( refundInfo );
    }

    //-----------------------------------------
    // [external/nonReentrant] 窓口：DutchAuction
    //-----------------------------------------
    // ダッチオークションの出品
    function dutchAuction( uint256 productType, uint256 tokenId, uint256 startingPrice, uint256 endingPrice, uint256 period, uint256 startMargin, uint256 endMargin ) external nonReentrant {
        require( address(_dutch_auction) != address(0), "invalid dutch auction" );
        require( !_dutch_auction_start_suspended, "dutch_auction suspended" );  // 新規ダッチオークション中止中
        require( _product_address[productType] != address(0), "unknown productType" );

        _dutch_auction.dutchAuction( msg.sender, _product_address[productType], tokenId, startingPrice, endingPrice, period, startMargin, endMargin );
    }

    // ダッチオークションの取り消し
    function cancelDutchAuction( uint256 auctionId ) external nonReentrant {
        require( address(_dutch_auction) != address(0), "invalid dutch auction" );

        _dutch_auction.cancelDutchAuction( msg.sender, auctionId );
    }

    // ダッチオークションに入札(実質的な購入)
    function bidDutchAuction( uint256 auctionId ) external nonReentrant {
        require( address(_dutch_auction) != address(0), "invalid dutch_auction" );

        _dutch_auction.buyDutchAuction( msg.sender, auctionId );

        // トークンの転送
        uint256[4] memory transferInfo = ITrade(address(_dutch_auction)).transferInfo( auctionId );
        _transfer( transferInfo );

        // 支払い（直接）
        uint256[2] memory payInfo = ITrade(address(_dutch_auction)).payInfo( auctionId );
        _pay( msg.sender, payInfo );
    }

    //----------------------------------------------
    // [internal] 共通処理：コインの預託
    //----------------------------------------------
    // ・from: 支払い元
    // ・amount: 支払う額(事前にapproveが必要)
    //----------------------------------------------
    function _deposit( address from, uint256 amount ) internal {
        if( amount > 0 ){
            require( from != address(0), "invalid from" );

            _coin.transferFrom( from, address(this), amount );  // 支払い先はマーケットコントラクト      
        }
    }

    //----------------------------------------------
    // [internal] 共通処理：預託したコインの払い戻し
    //----------------------------------------------
    // uint256[2]の内訳は下記（詳細は ITrade.sol を参照)
    // ・[0]:払い戻し先(addressへキャストして使う)
    // ・[1]:払い戻し額
    //----------------------------------------------
    function _refund( uint256[2] memory words ) internal {
        if( words[1] > 0 ){
            require( words[0] != 0, "invalid to" );

            address to = address( uint160( words[0] ) );
            _coin.transfer( to, words[1] ); // マーケットコントラクトから直接払い戻す
        }
    }

    //----------------------------------------------
    // [internal] 共通処理：コインの支払い(手数料が発生する)
    //----------------------------------------------
    // ・from: 支払い元(無効ならスマコン＝預託金から支払う)
    // uint256[2]の内訳は下記（詳細は ITrade.sol を参照)
    // ・[0]:支払い先(addressへキャストして使う)
    // ・[1]:支払額
    //----------------------------------------------
    function _pay( address from, uint256[2] memory words ) internal {
        if( words[1] > 0 ){
            require( words[0] != 0, "invalid to" );

            // 精算
            address to = address( uint160( words[0] ) );
            uint256 amount = words[1];

            // 手数料の転送（一応、無効＆重複確認をしておく）
            if( _fee_receiver != address(0) && _fee_receiver != to ){
                uint256 fee = (words[1] * _fee_rate)/FEE_RATE_BASE;
                if( fee > 0 ){
                    // 用心
                    if( fee > amount ){
                        fee = amount;
                    }

                    // 手数料の徴収（指定が有効ならfromから払う）
                    if( from != address(0) ){
                        _coin.transferFrom( from, _fee_receiver, fee );
                    }
                    // 指定が無効なら預託(スマコン)から払う
                    else{
                        _coin.transfer( _fee_receiver, fee );
                    }
                    amount -= fee;
                }
            }

            // 売り上げの転送
            if( amount > 0 ){
                // 指定が有効ならfromから払う
                if( from != address(0) ){
                    _coin.transferFrom( from, to, amount );
                }
                // 指定が無効なら預託(スマコン)から払う
                else{
                    _coin.transfer( to, amount );
                }
            }
        }
    }

    //----------------------------------------------
    // [internal] 共通処理：トークンの転送
    //----------------------------------------------
    // uint256[4]の内訳は下記（詳細は ITrade.sol を参照)
    // ・[0]:トークンコントラクト(ERC721へキャストして使う)
    // ・[1]:トークンID
    // ・[2]:供出側(addressへキャストして使う)
    // ・[3]:受領側(addressへキャストして使う)
    //----------------------------------------------
    function _transfer( uint256[4] memory words ) internal {
        require( words[0] != 0, "invalid contract" );
        require( words[2] != 0, "invalid from" );
        require( words[3] != 0, "invalid to" );

        // NFTの転送
        IERC721 tokenContract = IERC721( address( uint160( words[0] ) ) );
        address from = address( uint160( words[2] ) );
        address to = address( uint160( words[3] ) );
        tokenContract.safeTransferFrom( from, to, words[1] );
    }

}