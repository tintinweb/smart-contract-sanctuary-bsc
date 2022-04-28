/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma abicoder v2;
interface IBEP721Receiver {
    function onBEP721Received(address operator,address from,uint256 tokenId,bytes calldata data) external returns (bytes4);
}
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
interface IBEP721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from,address to,uint256 tokenId) external;
    function transferFrom(address from,address to,uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from,address to,uint256 tokenId,bytes calldata data) external;
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _setOwner(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }
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
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract NFTMarket is IBEP721Receiver , Ownable {
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
     function onBEP721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onBEP721Received.selector;
    }
    function addItemToSale(
        address _tokenAddress ,
        uint256 _tokenID ,  
        uint256 _askingPrice , 
        address _acceptedPayment ,
        bool _auctionable) public  returns (uint256) {
        require(acceptedTokens[_tokenAddress] , "NFT not Accepted");
        require(IBEP721(_tokenAddress).ownerOf(_tokenID) == _msgSender() , "not Token Owner");
        require(IBEP721(_tokenAddress).getApproved(_tokenID) == address(this) , "Approval not granted.");
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
        sendNTF( currentSaleItem.tokenAddress , currentSaleItem.tokenID , msg.sender);
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
        sendNTF( currentSaleItem.tokenAddress , currentSaleItem.tokenID , currentSaleItem.winningBid.bidder);
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
        sendNTF( currentSaleItem.tokenAddress , currentSaleItem.tokenID , currentSaleItem.owner);
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
    function acceptNewNFT(address _dtokenAddress ,uint256 _dtokenID) private {
        IBEP721 NFTtoken =  IBEP721(_dtokenAddress);
        NFTtoken.safeTransferFrom(_msgSender(), address(this) , _dtokenID  );
    }
    function sendNTF(address _dtokenAddress ,uint256 _dtokenID , address recipient) private {
        IBEP721 NFTtoken =  IBEP721(_dtokenAddress);
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