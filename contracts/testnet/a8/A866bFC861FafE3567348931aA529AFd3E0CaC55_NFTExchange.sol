/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

// File: exchange.sol

/**
 *Submitted for verification at testnet.snowtrace.io on 2023-01-24
*/

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

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
pragma solidity ^0.8.0;



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
pragma solidity ^0.8.0;



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
pragma solidity ^0.8.0;

/*
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
pragma solidity ^0.8.0;


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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
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

pragma solidity ^0.8.2;

 contract NFTExchange is IERC721Receiver , Ownable {
    struct bid{
        address payable bidder;
        bool isActive;
        uint256 amount;
    }
    struct ItemForSale{
        uint256 id;
        address tokenAddress;
        uint256 tokenID;
        address payable owner;
        uint256 askingPrice;
        bool auctionable;
        address[] bidders;
        bid winningBid;
        mapping(address => bid) bids;
        bool isSold;
        address acceptedPaymentMethod;
    }
    uint256[] public itemsForSaleList;
    mapping(uint256 => ItemForSale) public itemsForSale;
    mapping( address => mapping(uint256 => bool)) public isActiveOnSale;
    // percentage of sales
  
    address payable private feeRemitanceAddress;
    
    
    struct paymentMethod {
        address tokenAddress;
        uint256 fees;
        uint256 feeBalance;
        bool isSet;
    }
    address[] public  acceptedPayments;
    mapping(address =>  paymentMethod) private paymentMethods;
    mapping(address =>  bool) public isActivepaymentMethod;
    mapping(address => bool) public acceptedTokens;
    mapping (address => bool) public isExcludedFromFees;
   
    //settings 
    bool private activeMinimums;
    bool private canWithdrawBid;
   
    //events 
    event itemAddedToSales(address seller ,uint256 saleID , uint256 askingPrice , bool auctionable );
    event bidAddedToSale(address bidder , uint256 saleID , uint256 bidAmount);
    event itemSold(address buyer , address seller , uint256 saleID , uint256 amount);
    
    modifier onlySalesOwner(uint256 saleID) {
        require(itemsForSale[saleID].owner == _msgSender() , "Only Sales Owner can call this function");
        _;
    }
  
  
    modifier activSales (uint256 saleID){
         require(isActiveOnSale[itemsForSale[saleID].tokenAddress][itemsForSale[saleID].tokenID]  && !itemsForSale[saleID].isSold  , "Item not in sale");
         _;  
    }
     function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
    function addItemToSale(
        address _tokenAddress ,
        uint256 _tokenID ,  
        uint256 _askingPrice , 
        address _acceptedPayment ,
        bool _auctionable) public  returns (uint256) {
         require(acceptedTokens[_tokenAddress] , "NFT not Accepted");
         require(IERC721(_tokenAddress).ownerOf(_tokenID) == _msgSender() , "not Token Owner");
          require(IERC721(_tokenAddress).getApproved(_tokenID) == address(this) , "Approval not granted.");
         require(!isActiveOnSale[_tokenAddress][_tokenID] , "item already on sales"); 
         require(isActivepaymentMethod[_acceptedPayment] , "Payment Method Not Active");
         acceptNewNFT(_tokenAddress , _tokenID); 
        
        uint256 salesID = itemsForSaleList.length;
        ItemForSale storage newItemForSale = itemsForSale[salesID];
        newItemForSale.id = salesID;
        newItemForSale.tokenAddress  = _tokenAddress;
        newItemForSale.tokenID = _tokenID;
        newItemForSale.owner = payable(_msgSender());
        newItemForSale.askingPrice  = _askingPrice;
        newItemForSale.auctionable = _auctionable;
        newItemForSale.isSold = false;
        newItemForSale.acceptedPaymentMethod  = _acceptedPayment;
        itemsForSaleList.push(salesID);
        emit itemAddedToSales(_msgSender() , salesID ,  _askingPrice ,  _auctionable );
        return salesID;
    }   
    function buyItem(uint256 saleID , uint256 amount ) public payable activSales(saleID) {
        require(!itemsForSale[saleID].auctionable , "auctionable sales dont allow outright purchase, place a bid");
        require(amount >= itemsForSale[saleID].askingPrice , "amount below asking price");
        require(processedPayment(saleID , amount) , "insuficient balance");
         ItemForSale storage currentSaleItem =  itemsForSale[saleID];
         paymentMethod storage currentPaymentMethod = paymentMethods[currentSaleItem.acceptedPaymentMethod];
         if(currentPaymentMethod.fees > 0){
        amount = deductFees(saleID , amount);  
         }
         //send BFT to buyer
         sendNFT( currentSaleItem.tokenAddress , currentSaleItem.tokenID , msg.sender);
         //pay owner
         payoutUser(currentSaleItem.owner , currentSaleItem.acceptedPaymentMethod , amount);
         currentSaleItem.isSold = true;
         isActiveOnSale[currentSaleItem.tokenAddress][currentSaleItem.tokenID] = false;
         
         emit itemSold( _msgSender() , currentSaleItem.owner ,  saleID ,  amount);
        
    }
    function placeBID(uint256 saleID , uint256 amount ) public payable activSales(saleID){
        require(itemsForSale[saleID].auctionable , "not an auctionable sale, purchasse outrightly");
        
        if(activeMinimums) {
            require(amount >= itemsForSale[saleID].askingPrice , "amount below asking price");
            require(amount >= itemsForSale[saleID].winningBid.amount || topUpCanDefietWinningBid(saleID , amount) , "Amount less than winning Bid");
            
        }
        require(processedPayment(saleID , amount) , "insuficient balance");
        
        //check for top up
        if(itemsForSale[saleID].bids[_msgSender()].isActive){
            itemsForSale[saleID].bids[_msgSender()].amount += amount;
            
        }else{
            bid storage newbid = itemsForSale[saleID].bids[_msgSender()];
            newbid.bidder = payable(_msgSender());
            newbid.amount = amount;
            newbid.isActive = true; 
            itemsForSale[saleID].bidders.push(_msgSender());
        }
        if( itemsForSale[saleID].bids[_msgSender()].amount >  itemsForSale[saleID].winningBid.amount){
            itemsForSale[saleID].winningBid =  itemsForSale[saleID].bids[_msgSender()];
        }
       emit  bidAddedToSale( _msgSender() ,  saleID ,  amount);
        
    }
    function withdrawBid(uint256 saleID) public activSales(saleID){
        require(canWithdrawBid , "Bid Withdrawal Not Accepted");
        require(itemsForSale[saleID].bids[_msgSender()].bidder != itemsForSale[saleID].winningBid.bidder ,"cant withdraw a winning bid");
        require(itemsForSale[saleID].bids[_msgSender()].isActive && itemsForSale[saleID].bids[_msgSender()].amount > 0 , "You Have No Active Bid ont this sales");
         payoutUser(itemsForSale[saleID].bids[_msgSender()].bidder , itemsForSale[saleID].acceptedPaymentMethod , itemsForSale[saleID].bids[_msgSender()].amount);
         itemsForSale[saleID].bids[_msgSender()].amount = 0;
         itemsForSale[saleID].bids[_msgSender()].isActive = false;
         
    }
    function acceptWinningBid(uint256 saleID) public onlySalesOwner(saleID) activSales(saleID){
        
        
         require(itemsForSale[saleID].bidders.length > 0 && itemsForSale[saleID].winningBid.bidder != address(0) , "No active bid for item,cancel sales or wait for buyer ");
         require(itemsForSale[saleID].auctionable , "not an auctionable sale, cancel sales or wait for buyer");
         ItemForSale storage currentSaleItem =  itemsForSale[saleID];
         paymentMethod storage currentPaymentMethod = paymentMethods[currentSaleItem.acceptedPaymentMethod];
         sendNFT( currentSaleItem.tokenAddress , currentSaleItem.tokenID , currentSaleItem.winningBid.bidder);
         uint256 payoutAmount  = currentSaleItem.winningBid.amount;
          currentSaleItem.bids[currentSaleItem.winningBid.bidder].isActive = false; 
         if(currentPaymentMethod.fees > 0){
          payoutAmount = deductFees(saleID , payoutAmount);  
         }
         payoutUser(currentSaleItem.owner , currentSaleItem.acceptedPaymentMethod , payoutAmount);
         
         refundActiveBidders(saleID);
         currentSaleItem.isSold = true;
         isActiveOnSale[currentSaleItem.tokenAddress][currentSaleItem.tokenID] = false;
          emit itemSold( currentSaleItem.owner , currentSaleItem.winningBid.bidder ,  saleID ,  currentSaleItem.winningBid.amount);
        
    }
    function cancelSales(uint256 saleID) public onlySalesOwner(saleID) activSales(saleID) {
        
        ItemForSale storage currentSaleItem =  itemsForSale[saleID];
     
         sendNFT( currentSaleItem.tokenAddress , currentSaleItem.tokenID , currentSaleItem.owner);
         
         if(currentSaleItem.auctionable && currentSaleItem.bidders.length > 0){
             refundActiveBidders(saleID);
         }
         isActiveOnSale[currentSaleItem.tokenAddress][currentSaleItem.tokenID] = false;
    }
    function refundActiveBidders(uint256 saleID) internal {
       ItemForSale storage currentSaleItem =  itemsForSale[saleID];
       
       for(uint256 i = 0 ; i < currentSaleItem.bidders.length ;i++){
           if(currentSaleItem.bids[currentSaleItem.bidders[i]].isActive &&
              currentSaleItem.bids[currentSaleItem.bidders[i]].amount > 0 &&
              currentSaleItem.bids[currentSaleItem.bidders[i]].bidder != address(0)){
                payoutUser(currentSaleItem.bids[currentSaleItem.bidders[i]].bidder , currentSaleItem.acceptedPaymentMethod ,currentSaleItem.bids[currentSaleItem.bidders[i]].amount );
                currentSaleItem.bids[currentSaleItem.bidders[i]].isActive = false;
                  
              }
       }
    }
     function acceptNewNFT(address _dtokenAddress ,uint256 _dtokenID) public {
        IERC721 NFTtoken =  IERC721(_dtokenAddress);
        NFTtoken.safeTransferFrom(_msgSender(), address(this) , _dtokenID  );
    
    }
    function sendNFT(address _dtokenAddress ,uint256 _dtokenID , address recipient) private {
        IERC721 NFTtoken =  IERC721(_dtokenAddress);
        NFTtoken.safeTransferFrom(address(this),  recipient , _dtokenID);
    }
    function payoutUser(address payable recipient , address _paymentMethod , uint256 amount) private{
        if(_paymentMethod == address(0)){
          recipient.transfer(amount);
        }else {
             IERC20 currentPaymentMethod = IERC20(_paymentMethod);
             currentPaymentMethod.transfer(recipient , amount);
        }
    }
      
    
     function NftTokenStatusUpdate(address _tokenAddress ,bool Nftstatus) public onlyOwner {
         require(_tokenAddress != address(0), " NFT not supported at zero address");
         acceptedTokens[_tokenAddress] = Nftstatus;
         
    }
    function addPaymentMethod(address paymentAddress ,  uint256 fee) public onlyOwner {
         
        require(!paymentMethods[paymentAddress].isSet, "payment method already added");
        paymentMethod storage newPaymentMethod = paymentMethods[paymentAddress];
        newPaymentMethod.tokenAddress = paymentAddress;
        newPaymentMethod.fees = fee;
        newPaymentMethod.isSet = true ;
        isActivepaymentMethod[paymentAddress] = true;
        
        
    }
    function processedPayment(uint256 saleID , uint256 amount ) internal returns (bool) {
        ItemForSale storage currentItem =  itemsForSale[saleID];
        if(currentItem.acceptedPaymentMethod == address(0)){
            if(msg.value >= currentItem.askingPrice){
                return true;
            }else{
               return false; 
            }
        }else{
            IERC20 currentPaymentMethod = IERC20(currentItem.acceptedPaymentMethod);
            if(currentPaymentMethod.allowance(_msgSender(), address(this)) >= amount ){
               currentPaymentMethod.transferFrom(_msgSender() , address(0) , amount);
               return true;
            }else{
                return false;
            }
        }
    }
    function topUpCanDefietWinningBid(uint256 saleID ,uint256 amount) internal view  returns(bool){
          
          if(itemsForSale[saleID].bids[_msgSender()].isActive &&( itemsForSale[saleID].bids[_msgSender()].amount + amount) >  itemsForSale[saleID].winningBid.amount){
              return true;
          }else {
            return false;  
          }
    }
    function deductFees(uint256 saleID , uint256 amount) internal returns (uint256) {
        ItemForSale storage currentSaleItem =  itemsForSale[saleID];
         paymentMethod storage currentPaymentMethod = paymentMethods[currentSaleItem.acceptedPaymentMethod];
         
         if(currentPaymentMethod.fees > 0){
          uint256 fees_to_deduct = amount * currentPaymentMethod.fees  / 1000;
          currentPaymentMethod.feeBalance += fees_to_deduct;
          return amount - fees_to_deduct;
          
         }else {
             return amount;
         }
    }
    function remitFees() public onlyOwner {
        for (uint256 i = 0 ; i < acceptedPayments.length ; i++){
            if(isActivepaymentMethod[acceptedPayments[i]]){
                if(paymentMethods[acceptedPayments[i]].feeBalance > 0 &&
                IERC20(paymentMethods[acceptedPayments[i]].tokenAddress).balanceOf(address(this)) >= paymentMethods[acceptedPayments[i]].feeBalance) {
                  payoutUser(feeRemitanceAddress , acceptedPayments[i] ,  paymentMethods[acceptedPayments[i]].feeBalance) ;
                   paymentMethods[acceptedPayments[i]].feeBalance = 0;
                }
            }
        }
    }
     function activatePaymentMethod(address paymentAddress) public onlyOwner {
          require(paymentMethods[paymentAddress].isSet, "payment method not added");
         require(!isActivepaymentMethod[paymentAddress] , "payment method already active");
       isActivepaymentMethod[paymentAddress] = true;
         
    }
     function deactivatePaymentMethod(address paymentAddress) public onlyOwner {
          require(paymentMethods[paymentAddress].isSet, "payment method not  added");
          require(isActivepaymentMethod[paymentAddress] , "payment method already inactive");
          isActivepaymentMethod[paymentAddress] = false;
         
         
    }
    function feeRemitanceAddressUpdate(address payable _feeRemitanceAddress) public onlyOwner {
        require(_feeRemitanceAddress != address(0) , "cant make address 0 fee remitance address");
        feeRemitanceAddress = _feeRemitanceAddress;
    }
    function settings(bool activeMinimumsState , bool canWithdrawBidState) public onlyOwner {
        activeMinimums = activeMinimumsState;
        canWithdrawBid = canWithdrawBidState;
    }
    function setPaymentMethodFees(address _paymentMethod ,  uint256 _fees) public onlyOwner{
        require(_fees >= 1 && _fees <= 300 , "out of range");
        require(paymentMethods[_paymentMethod].isSet , "invalid paymentMethod");
        paymentMethods[_paymentMethod].fees = _fees;
    }
    function ex_in_Clude_FromFee(address _seller , bool status) public onlyOwner {
        isExcludedFromFees[_seller] = status;
    }
   

}