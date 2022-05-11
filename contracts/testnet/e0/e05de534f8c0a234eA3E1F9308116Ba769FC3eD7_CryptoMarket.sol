// SPDX-License-Identifier: Unlicensed


pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CryptoMarket is Ownable{

    struct Product {
       uint256 BaseId; 
       uint256 Price;
       address Seller;  
       bool Bought;
       bool Accepted;
    }

    struct Purchase {
       uint256 ProductId;
       address Buyer;
       uint256 Amount;
       uint256 PurchaseTime;  
       bool TrackNumber;  
       bool AcceptDelivery;
       uint256 DisputeOpened;
       bool BuyerShipBack;
    }

    struct Disput {
       uint256 PurchaseId; 
       address Initiator;
    }

    event ResolvedDisput(
        address initiator,
        uint256 id,
        bool refundBuyer,
        uint256 timestamp
    );

    event Shipped(
        address initiator,
        uint256 idPurchase,
        uint256 timestamp
    );

    event Refunded(
        address initiator,
        uint256 idPurchase,
        uint256 timestamp
    );

    event Purchased(
        address initiator,
        uint256 idProduct,
        uint256 timestamp
    );

    event DeliveryAccepted(
        address initiator,
        uint256 idPurchase,
        uint256 timestamp
    );

    event FeeChanged(
        address initiator,
        uint256 amount,
        uint256 timestamp
    );

    event ModeratorFeeChanged(
        address initiator,
        uint256 amount,
        uint256 timestamp
    );

    uint256 public fee = 6;
    uint256 public Moderatorfee = 3;
    uint256 public ProductCount = 0;
    uint256 public PurchaseCount = 0;
    uint256 public DisputCount = 0;

    uint256 public TracknumberRequired = 7 days;

    mapping(uint256 => Product) public Products;
    mapping(uint256 => Disput) public Disputs;
    mapping(uint256 => Purchase) public Purchases;


    mapping(address => bool) public Blacklist;
    mapping(address => bool) public ModeratorList;

    address public BUSDToken = address(0);
    address public feeReceiver = address(0);

    

    constructor(address _BUSDToken) {
        BUSDToken = _BUSDToken;
        feeReceiver = _msgSender();
    }

    function addProduct(uint256 _price, uint256 _baseId) external returns(uint256){

        require(Blacklist[_msgSender()] == false, "You have been blacklisted.");

        Product memory item = Product({
            BaseId: _baseId,
            Price: _price,
            Seller: _msgSender(),
            Bought: false,
            Accepted: false       
        });

        ProductCount+= 1;
        uint256 ProductId = ProductCount;

        Products[ProductId] = item;

      

        return ProductId;
    }

    function purchaseProduct(uint256 _idProduct) external returns(uint256){

        require(Blacklist[_msgSender()] == false, "You have been blacklisted.");

        Product storage product = Products[_idProduct];

        require(product.Bought == false, "Item already purchased.");
        require(product.Accepted == true, "Item not verified.");

        uint256 feeAmount = (product.Price/100) * Moderatorfee;

        product.Bought = true;

        Purchase memory item = Purchase({
           ProductId: _idProduct,
           Buyer: _msgSender(),
           PurchaseTime: block.timestamp,  
           TrackNumber: false,     
           AcceptDelivery: false,
           Amount: product.Price - feeAmount,
           DisputeOpened: 0,
           BuyerShipBack: false  
        });

        PurchaseCount+= 1;
        uint256 PurchaseId = PurchaseCount;
        Purchases[PurchaseId] = item;

        
     

        IERC20(BUSDToken).transferFrom(_msgSender(), address(this), product.Price);

        IERC20(BUSDToken).transfer(feeReceiver, feeAmount);

        emit Purchased(
            _msgSender(),
            _idProduct, 
            block.timestamp
            );

        return PurchaseId;

    }

    function acceptDelivery(uint256 _idPurchase) external{

        Purchase storage purchase = Purchases[_idPurchase];
        Product memory product = Products[purchase.ProductId];

        require(purchase.Buyer == _msgSender(), "You is not buyer.");
        require(purchase.AcceptDelivery == false, "You have already confirmed that you have accepted the goods.");

        if(purchase.DisputeOpened != 0){
            purchase.DisputeOpened = 0;
        }

        purchase.AcceptDelivery = true;
        
        uint256 feeAmount = (purchase.Amount/100) * fee;
        
        IERC20(BUSDToken).transfer(product.Seller, purchase.Amount - feeAmount);
        IERC20(BUSDToken).transfer(feeReceiver, feeAmount);

        emit DeliveryAccepted(
            _msgSender(),
            _idPurchase, 
            block.timestamp
            );

    }

    function demandDeliveryRefund(uint256 _idPurchase) external{

        Purchase storage purchase = Purchases[_idPurchase];

        require(purchase.Buyer == _msgSender(), "You is not buyer.");
        require(purchase.TrackNumber == false, "The seller shipped the goods.");
        require(purchase.PurchaseTime + TracknumberRequired < block.timestamp, "You can't claim a refund yet.");
        require(purchase.Amount > 0, "Refund already done.");
        require(purchase.AcceptDelivery == false, "You have already confirmed that you have accepted the goods.");

        purchase.Amount = 0;
        purchase.AcceptDelivery = true;

        if(purchase.DisputeOpened != 0){
            purchase.DisputeOpened = 0;
        }

        IERC20(BUSDToken).transfer(purchase.Buyer, purchase.Amount);

    }

    function openDisputeByBuyer(uint256 _idPurchase) external{

        Purchase storage purchase = Purchases[_idPurchase];

        require(purchase.Buyer == _msgSender(), "You is not buyer.");
        require(purchase.PurchaseTime + 60 days > block.timestamp, "More than 60 days have passed since the purchase.");
        require(purchase.PurchaseTime + TracknumberRequired < block.timestamp, "You can't claim a refund yet.");
        require(purchase.AcceptDelivery == false, "You have already confirmed that you have accepted the goods.");
        require(purchase.DisputeOpened == 0, "Disput alredy opened");

        Disput memory item = Disput({
           PurchaseId: _idPurchase,
           Initiator: _msgSender()
        });

        DisputCount+= 1;

        Disputs[DisputCount] = item;

        purchase.DisputeOpened = DisputCount;
        
    }

    function openDisputeBySeller(uint256 _idPurchase) external{

        Purchase storage purchase = Purchases[_idPurchase];
        Product memory product = Products[purchase.ProductId];

        require(product.Seller == _msgSender(), "You is not seller.");
        require(purchase.AcceptDelivery == false, "Buyer have already confirmed that him have accepted the goods.");
        require(purchase.PurchaseTime + TracknumberRequired < block.timestamp, "You can't claim a refund yet.");
        require(purchase.DisputeOpened == 0, "Disput alredy opened");

        Disput memory item = Disput({
           PurchaseId: _idPurchase,
           Initiator: _msgSender()
        });

        DisputCount+= 1;

        Disputs[DisputCount] = item;

        purchase.DisputeOpened = DisputCount;
        
    }

    function resolveDispute(uint256 _idDisput, bool refundBuyer) external{
    
        require(ModeratorList[_msgSender()] == true || owner() == _msgSender(), "You is not moderator");

        Disput memory disput = Disputs[_idDisput];

        Purchase storage purchase = Purchases[disput.PurchaseId];

        require(purchase.DisputeOpened == _idDisput, "Disput is not opened");
        require(purchase.AcceptDelivery == false, "Buyer have already confirmed that him have accepted the goods.");

        purchase.DisputeOpened = 0;
        purchase.AcceptDelivery = true;

        if(refundBuyer){
            IERC20(BUSDToken).transfer(purchase.Buyer, purchase.Amount);
    
        }else{
            Product memory product = Products[purchase.ProductId];
        
            uint256 feeAmount = (purchase.Amount/100) * fee;
        
            IERC20(BUSDToken).transfer(product.Seller, purchase.Amount - feeAmount);
            IERC20(BUSDToken).transfer(feeReceiver, feeAmount);
        }
        
        emit ResolvedDisput(
            _msgSender(),
            _idDisput, 
            refundBuyer,
            block.timestamp
            );

    }

    function makeRefund(uint256 _idPurchase) external{

        Purchase storage purchase = Purchases[_idPurchase];
        Product memory product = Products[purchase.ProductId];

        require(product.Seller == _msgSender(), "You is not seller.");
        require(purchase.PurchaseTime + 60 days > block.timestamp, "More than 60 days have passed since the purchase.");
        require(purchase.AcceptDelivery == false, "Buyer have already confirmed that him have accepted the goods.");
        require(purchase.PurchaseTime + TracknumberRequired < block.timestamp, "You can't claim a refund yet.");
       
        purchase.DisputeOpened = 0;
        purchase.AcceptDelivery = true;
        
        IERC20(BUSDToken).transfer(purchase.Buyer, purchase.Amount);

        emit Refunded(
            _msgSender(),
            _idPurchase, 
            block.timestamp
            );

    }

    function setShipped(uint256 _idPurchase) external{
        Purchase storage purchase = Purchases[_idPurchase];
        Product memory product = Products[purchase.ProductId];

        require(product.Seller == _msgSender(), "You is not seller.");

        purchase.TrackNumber = true;

        emit Shipped(
            _msgSender(),
            _idPurchase, 
            block.timestamp
            );

    }

    function AcceptProduct(uint256 _idProduct) external{
        require(ModeratorList[_msgSender()] == true || owner() == _msgSender(), "You is not moderator");
        Product storage product = Products[_idProduct];
        product.Accepted = true;
    }

    function removeBlacklist(address _to) external{
        require(ModeratorList[_msgSender()] == true || owner() == _msgSender(), "You is not moderator");
        Blacklist[_to] = false;        
    }

    function addBlacklist(address _to) external{
        require(ModeratorList[_msgSender()] == true || owner() == _msgSender(), "You is not moderator");
        Blacklist[_to] = true; 
    }

    function removeModerator(address _to) external onlyOwner{
        ModeratorList[_to] = false;        
    }

    function addModerator(address _to) external onlyOwner{
        ModeratorList[_to] = true;
    }

    function setFeeReceiver(address _to) external onlyOwner{
        feeReceiver = _to;       
    }

    function setFee(uint256 _fee) external onlyOwner{

        require(_fee <= 15, "Too hight.");

        fee = _fee;    

        emit FeeChanged(
            _msgSender(),
            fee, 
            block.timestamp
            );   
    }

    function setModeratorFee(uint256 _fee) external onlyOwner{

        require(_fee <= 5, "Too hight.");

        Moderatorfee = _fee;  

        emit ModeratorFeeChanged(
            _msgSender(),
            Moderatorfee, 
            block.timestamp
            );      
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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