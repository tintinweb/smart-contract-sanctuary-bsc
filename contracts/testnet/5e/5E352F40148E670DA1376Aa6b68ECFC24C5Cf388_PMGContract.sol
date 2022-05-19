// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
interface IStrategy{
    function directDeposit(uint256 _wantAmt,address _user,uint256 isFreeze) external payable;
    function lockFund(uint256 _wantAmt,address _user) external ;
    function unlockFund(uint256 _wantAmt,address _user) external ;
    function deposit(uint256 _wantAmt,address seller,uint256 _tokenId,address buyer,uint256 action,uint256 isFreeze,address _nftContract) external payable;
    function withdraw(uint256 _wantAmt,address _user) external payable returns(uint256);
    function userInfos(address _user) external view returns(uint256,uint256,uint256);

}
contract PMGContract {

    enum Status { DEFAULT,LISTING,SOLD,DELIST,AUCTION,EXPIRE}

    struct listDetail{
        address seller;
        address cryptoToken;
        address nftContract;
        uint256 price;
        uint256 tokenId;
        Status status;
    }

    struct auctionDetail{
        address seller;
        address cryptoToken;
        address nftContract;
        uint256 price;
        uint256 tokenId;
        uint256 endTime;
        uint256 minBid;
        uint256 highestBid;
        address highestBidder;
        Status status;
    }

    struct offerDetail{
        address offerAddress;
        address cryptoToken;
        address nftContract;
        uint256 price;
        uint256 tokenId;
        uint256 endTime;
        bool isActive;
    }


    struct nftProfitSharing{
        address pioneer;
        address[10] exOwner;
        uint256 ownerCount;
    }

    mapping (address=>bool) public isTokenSupport;
    mapping (address=>address) public strategy;
    mapping (address=>bool) public isNFTSupport;
    mapping (address=>mapping(address=>mapping(uint256=>bool))) public userOfferId;
    mapping (uint256=>listDetail) public listItem;
    mapping (uint256=>mapping(address=>nftProfitSharing)) private nftProfit;
    mapping (uint256=>auctionDetail) public auctionItem;
    mapping (uint256=>offerDetail) public offerList;
    uint256 public listItemLength;
    uint256 public auctionItemLength;
    uint256 public offerItemLength;
    address owner;

    constructor(){
        owner=msg.sender;
        isNFTSupport[0xF2F74b394F79f235038B0cB1769c881eEe66a705] = true;
        isTokenSupport[0x734778123652973B37053c1b3CeD4256b2FEdbCb] = true; //telger
        isTokenSupport[0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d] = true; //usdc
        isTokenSupport[0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56] = true; //busd
        isTokenSupport[0xDfb1211E2694193df5765d54350e1145FD2404A1] = true; //wbnb
        isTokenSupport[0x2170Ed0880ac9A755fd29B2688956BD959F933F8] = true; //weth
        strategy[0x734778123652973B37053c1b3CeD4256b2FEdbCb] = 0x5D89AA42010dfB1F98F68b52AA4892AA42B13FF8;
    }
    modifier onlyOwner() {
        require(owner == msg.sender, "not owner");
        _;
    }

    event Listing(address indexed seller, uint256 itemId, address currencyAddress, address nftAddress, uint256 tokenId, uint256 amount);
    event Delist(uint indexed itemId);
    event BuyNFT(address indexed seller,address indexed buyer, uint256 itemId, address currencyAddress, address nftAddress, uint256 tokenId, uint256 amount);
    event NewOffer(address indexed buyer, address currencyAddress, address nftAddress, uint256 tokenId, uint256 offerId, uint256 amount, uint256 expiryTime);
    event CancelOffer(address indexed buyer, uint256 offerId);
    event AcceptOffer(address indexed seller, address indexed buyer, uint256 offerId);
    event Auction(address indexed seller, address currencyAddress, address nftAddress, uint256 minimumAmount,uint256 startingPrice, uint256 auctionId, uint256 tokenId, uint256 expiryTime);
    event Bid(address indexed buyer, address currencyAddress, uint256 bidAmount, uint256 auctionId );
    event AuctionEnd(address indexed buyer, uint256 auctionId);
    event AuctionRestart(uint256 auctionId,address currencyAddress, uint256 minimumAmount,uint256 startingPrice, uint256 expiryTime);
    event AuctionCancel(uint256 auctionId);

    /* add new support token */
    function addCoin(address _token) public onlyOwner {
        require(isTokenSupport[_token] == false,"token already support");
        isTokenSupport[_token] = true;
    }

    /* add new nft contract */
    function addNFT(address _token) public onlyOwner {
        require(isNFTSupport[_token] == false,"NFT already support");
        isNFTSupport[_token] = true;
    }

    /* edit support token strategy */
    function editStrategy(address _tokenContract,address _strategy) public onlyOwner  {
        require(isTokenSupport[_tokenContract] == true && strategy[_tokenContract] != _strategy,"token not supported | same strategy");
        strategy[_tokenContract] = _strategy;
    }


    /* list NFT
        condition
            * require listing address is owner of nft
            * require payment token is supported
            * require nft contract is supported
        increment list length,create list item detail and transfer nft from seller to marketplace
     */
    function listNFT(address _nftContract , address _tokenContract,uint256 _tokenId,uint256 _amount) public  {
        require(IERC721(_nftContract).ownerOf(_tokenId) == msg.sender,"not nft owner");
        require(isTokenSupport[_tokenContract],"payment token not support");
        require(isNFTSupport[_nftContract],"NFT not support");
        listItemLength+=1;
        listItem[listItemLength] =  listDetail( msg.sender,_tokenContract,_nftContract,_amount,_tokenId,Status.LISTING);
        IERC721(_nftContract).transferFrom(msg.sender,address(this),_tokenId);
        emit Listing(msg.sender, listItemLength, _tokenContract, _nftContract, _tokenId, _amount);
    }

    /* delist NFT
        condition
            * require delist address is seller
            * item status MUST be listing
        change status to delist and transfer back nft back to seller from market place
     */
    function delistNFT(uint256 _listItemId) public  {
        require(listItem[_listItemId].seller == msg.sender,"not nft seller");
        require(listItem[_listItemId].status == Status.LISTING,"invalid status");
        listItem[_listItemId].status =  Status.DELIST;
        IERC721(listItem[_listItemId].nftContract).transferFrom(address(this),msg.sender,listItem[_listItemId].tokenId);
        emit Delist(_listItemId);
    }

    /* buy NFT 
        condition 
            * require item status to be listing
            * buyer balance must be sufficient for pay
        1)get list item detail,update exOwner/pioneer info
        2)check avaible balance and freeze balance from strategy
        2a)transfer coin/token to pool if insufficient balance
        3)update related address pool balance and distribute the payment
        4)transfer nft to buyer 
    */
    function buyNFT(uint256 _index ) public payable {
        listDetail memory item = listItem[_index] ;
        require(item.status == Status.LISTING,"invalid status");
        nftProfitSharing  memory profit = nftProfit[item.tokenId][item.nftContract];
        listItem[_index].status = Status.SOLD;
        if(profit.pioneer == address(0)){
            nftProfit[item.tokenId][item.nftContract].pioneer = item.seller;
        }else if(profit.ownerCount<10){
            nftProfit[item.tokenId][item.nftContract].exOwner[profit.ownerCount] = (item.seller);
            nftProfit[item.tokenId][item.nftContract].ownerCount+=1;
        }
        (uint256 balance,uint256 freezeBalance,) = IStrategy(strategy[item.cryptoToken]).userInfos(msg.sender);
        if(item.cryptoToken == 0xDfb1211E2694193df5765d54350e1145FD2404A1){
            if(balance - freezeBalance< item.price){
                require(msg.value == item.price,"deposit bnb for bid");
                IStrategy(strategy[item.cryptoToken]).deposit{value:msg.value}(item.price  ,item.seller,item.tokenId,address(0),0,0,item.nftContract);
            }else{
                require(msg.value == 0,"no bnb deposit require");
                IStrategy(strategy[item.cryptoToken]).deposit(item.price  ,item.seller,item.tokenId,msg.sender,1,0,item.nftContract);
            }
        }else{
            if(balance - freezeBalance< item.price){
                require(IERC20(item.cryptoToken).balanceOf(msg.sender)>=item.price,"insufficient fund");
                IERC20(item.cryptoToken).transferFrom(msg.sender,address(this),item.price);
                IERC20(item.cryptoToken).approve(strategy[item.cryptoToken],item.price);
                IStrategy(strategy[item.cryptoToken]).deposit(item.price  ,item.seller,item.tokenId,address(0),0,0,item.nftContract);
            }else{
                IStrategy(strategy[item.cryptoToken]).deposit(item.price  ,item.seller,item.tokenId,msg.sender,1,0,item.nftContract);
            }
        }
        IERC721(item.nftContract).transferFrom(address(this),msg.sender,item.tokenId);
        
        emit BuyNFT(item.seller,msg.sender,_index,item.cryptoToken,item.nftContract,item.tokenId,item.price);
    }

    /* auction NFT
        condition 
            * require item owner is auction address
            * require payment token is supported
            * require nft contract is supported
            * auction period 0 < days < 7
        1)increment auction list length
        2)create auction detail
        3)transfer nft to market place
     */
    function auctionNFT(address _nftContract ,address _tokenContract,uint256 _tokenId,uint256 _price,uint256 _min_bid,uint256 _day) public  {
        require(IERC721(_nftContract).ownerOf(_tokenId) == msg.sender,"not nft owner");
        require(isTokenSupport[_tokenContract],"payment token not support");
        require(isNFTSupport[_nftContract],"nft contract not support");
        require(0 < _day && _day <= 7,"not support");
        auctionItemLength+=1;
        auctionItem[auctionItemLength] =  auctionDetail(msg.sender,_tokenContract,_nftContract,_price,_tokenId,block.timestamp+ (_day *  1 minutes) ,_min_bid,_price,address(0),Status.AUCTION);
        IERC721(_nftContract).transferFrom(msg.sender,address(this),_tokenId);
        emit Auction( msg.sender,  _tokenContract,  _nftContract,  _min_bid,_price,  auctionItemLength,  _tokenId,  block.timestamp+ (_day *  1 minutes));
    }

    /* bit auction NFT
        condition
            * require auction in valid time stamp
            * require bidder not initiator and previous highest bidder
            * require bid price >= previous highest bid + minimum bid and also multiply of minimum bid
            * require bidder wallet had sufficient balance
        bid auction item,unfreeze previous highest bidder fund and lock current bidder fund,update auction detail
     */
    function bidNFT(uint256 _auctionItemId,uint256 _price) public payable {
        // require(IERC721(nftContract).ownerOf(_tokenId) == msg.sender,"not nft owner");
        auctionDetail memory auctionitem = auctionItem[_auctionItemId];
        require (auctionitem.endTime>block.timestamp,"auction end");
        require (auctionitem.seller != msg.sender && auctionitem.highestBidder != msg.sender,"cannot bid on own auction | already highest bidder");
        require(_price >= auctionitem.highestBid+auctionitem.minBid && (_price - auctionitem.price)% auctionitem.minBid == 0,"invalid amount" );
        (uint256 balance,uint256 freezeBalance,) = IStrategy(strategy[auctionitem.cryptoToken]).userInfos(msg.sender);
        if(auctionitem.cryptoToken == 0xDfb1211E2694193df5765d54350e1145FD2404A1){
            if(balance - freezeBalance< _price){
                require(msg.value == _price,"deposit bnb for bid");
                IStrategy(strategy[auctionitem.cryptoToken]).directDeposit{value:_price}(_price,msg.sender,1);
            }else{
                require(msg.value == 0,"no bnb deposit require");
                IStrategy(strategy[auctionitem.cryptoToken]).lockFund(_price ,msg.sender);
            }
        }else{
            if(balance - freezeBalance< _price){
                require(IERC20(auctionitem.cryptoToken).balanceOf(msg.sender)>= _price,"insufficient fund");
                IERC20(auctionitem.cryptoToken).transferFrom(msg.sender,address(this),_price);
                IERC20(auctionitem.cryptoToken).approve(strategy[auctionitem.cryptoToken],_price);
                IStrategy(strategy[auctionitem.cryptoToken]).directDeposit(_price  ,msg.sender,1);
            }else{
                IStrategy(strategy[auctionitem.cryptoToken]).lockFund(_price ,msg.sender);
            }
        }
        
        if(auctionitem.highestBidder != address(0)){
            IStrategy(strategy[auctionitem.cryptoToken]).unlockFund(auctionitem.highestBid ,auctionitem.highestBidder);
        }
        
        auctionItem[_auctionItemId].highestBid = _price;
        auctionItem[_auctionItemId].highestBidder = msg.sender;
        
        emit Bid( msg.sender, auctionitem.cryptoToken, _price, _auctionItemId);
    }

    /* claim auction NFT
        condition
            * only seller or highest bidder can trigger
            * require auction end and status Auction
        1)get auction item detail
        2)get nft exOwner detail
        3)update auction status
        4)update exOwner
        5)distribute and update related address pool balance
        6)transfer nft to highest bidder
     */
    function claimAuctionNFT(uint256 _auctionItemId) public  {
        auctionDetail memory auctionitem = auctionItem[_auctionItemId];
        nftProfitSharing  memory profit = nftProfit[auctionitem.tokenId][auctionitem.nftContract];
        require(msg.sender == auctionitem.seller || msg.sender == auctionitem.highestBidder ,"unauthorized" );
        require (auctionitem.endTime<block.timestamp,"auction end");
        require( auctionitem.status == Status.AUCTION ,"invalid status" );
        auctionitem.status = Status.SOLD;
        if(profit.pioneer == address(0)){
            nftProfit[auctionitem.tokenId][auctionitem.nftContract].pioneer = auctionitem.seller;
        }else if(profit.ownerCount<10){
            nftProfit[auctionitem.tokenId][auctionitem.nftContract].exOwner[profit.ownerCount] = (auctionitem.seller);
            nftProfit[auctionitem.tokenId][auctionitem.nftContract].ownerCount+=1;
        }
        IStrategy(strategy[auctionitem.cryptoToken]).deposit(auctionitem.highestBid  ,auctionitem.seller,auctionitem.tokenId,auctionitem.highestBidder,1,1,auctionitem.nftContract);
        IERC721(auctionitem.nftContract).transferFrom(address(this),auctionitem.highestBidder,auctionitem.tokenId);
        emit AuctionEnd( auctionitem.highestBidder,  _auctionItemId);
    }

    /* restart or cancel auction
        condition
            * require auction end and status Auction
            * require no highest bidder on previous auction
            * require trigger address to be auction initiator
            * require payment token is supported
            * auction period 0 < days < 7
        1)get auction item detail
        1a)action 0 = cancel, action not equal 0 = restart
        2)update auction detail
        2a)set status to Expire if cancel
     */
    function auctionFail(uint256 _auctionItemId,uint256 _action,uint256 _price,uint256 _min_bid,uint256 _day ,address _tokenContract) public {
        auctionDetail memory auctionitem = auctionItem[_auctionItemId];
        require(msg.sender == auctionitem.seller ,"unauthorized" );
        require(isTokenSupport[_tokenContract],"payment token not support");
        require( auctionitem.status == Status.AUCTION &&  block.timestamp > auctionitem.endTime ,"invalid status" );
        require( auctionitem.highestBidder == address(0),"auction had a winner" );
        if(_action == 0){
            IERC721(auctionitem.nftContract).transferFrom(address(this),msg.sender,auctionitem.tokenId);
            auctionItem[_auctionItemId].status = Status.EXPIRE;
            emit AuctionCancel( _auctionItemId);
            return ;
        }
        
        auctionItem[_auctionItemId].minBid = _min_bid;
        auctionItem[_auctionItemId].price = _price;
        auctionItem[_auctionItemId].highestBid = _price;
        auctionItem[_auctionItemId].cryptoToken = _tokenContract;
        auctionItem[_auctionItemId].endTime = block.timestamp+ (_day *  1 minutes);
        emit AuctionRestart(_auctionItemId,_tokenContract, _min_bid,_price, block.timestamp+ (_day *  1 minutes));
        return ;   
    }

    /* offer NFT
        condition
            * require payment token is supported
            * require nft contract is supported
            * require user not offer this nft before
        1)update offer list length
        2)lock user pool balance
        2a)deposit fund to pool if pool balance insufficient
        3)set offer valid time
        4)create offer item
        5)update user offer nft status
     */
    function offerNFT(address _tokenContract,address _nftContract,uint256 _tokenId,uint256 _price) public payable  {
        /*  need to offer the NFT */
        require(isTokenSupport[_tokenContract],"payment token not support");
        require(isNFTSupport[_nftContract],"nft contract not support");
        require(userOfferId[msg.sender][_nftContract][_tokenId]==false,"User offer this nft before");
        offerItemLength+=1;
        (uint256 balance,uint256 freezeBalance,) = IStrategy(strategy[_tokenContract]).userInfos(msg.sender);
        if(_tokenContract == 0xDfb1211E2694193df5765d54350e1145FD2404A1){
            if(balance - freezeBalance< _price){
                require(msg.value == _price,"deposit bnb for bid");
                IStrategy(strategy[_tokenContract]).directDeposit{value:msg.value}(_price  ,msg.sender,1);
            }else{
                require(msg.value == 0,"no bnb deposit require");
                IStrategy(strategy[_tokenContract]).lockFund(_price ,msg.sender);
            }
        }else{
            if(balance - freezeBalance< _price){
                require(IERC20(_tokenContract).balanceOf(msg.sender)>= _price,"insufficient fund");
                IERC20(_tokenContract).transferFrom(msg.sender,address(this),_price);
                IERC20(_tokenContract).approve(strategy[_tokenContract],_price);
                IStrategy(strategy[_tokenContract]).directDeposit{value:msg.value}(_price  ,msg.sender,1);
            }else{
                IStrategy(strategy[_tokenContract]).lockFund(_price ,msg.sender);
            }
        }
        
        uint256 endTime = block.timestamp + 5 minutes ;
        offerList[offerItemLength]= offerDetail(msg.sender,_tokenContract,_nftContract,_price,_tokenId,endTime,true);
        userOfferId[msg.sender][_nftContract][_tokenId] = true;
        emit NewOffer(  msg.sender ,  _tokenContract,  _nftContract,  _tokenId,  offerItemLength,  _price,  endTime);
    }

    /* cancel offer NFT and claim
        condition
            * require user offer this nft before
        1)update offer item status
        2)unlock user pool balance
        3)update user offer nft status
     */
    function cancelOfferAndClaim(uint256 _offerId) public {
        require(userOfferId[msg.sender][offerList[_offerId].nftContract][offerList[_offerId].tokenId]==true,"Invalid offer");
        offerList[_offerId].isActive = false;
        IStrategy(strategy[offerList[_offerId].cryptoToken]).unlockFund(offerList[_offerId].price ,msg.sender);
        userOfferId[msg.sender][offerList[_offerId].nftContract][offerList[_offerId].tokenId] = false;
        emit CancelOffer(msg.sender, _offerId);
    }

    /*  accept offer 
        condition
            * require user is current owner(nft cant be auction and list)
            * require offer not end
            * require offer status is valid
        1)get offer item detail
        2)get exOwner detail
        3)update exOwner
        4)distribute and update related address pool balance 
        5)update offer status
    */
    function acceptOffer(uint256 _offerId) public  {
        offerDetail memory offerdetail = offerList[_offerId];
        nftProfitSharing  memory profit = nftProfit[offerdetail.tokenId][offerdetail.nftContract];
        address  own = IERC721(offerdetail.nftContract).ownerOf(offerdetail.tokenId);
        require(offerdetail.isActive==true,"offer invalid");
        require(offerdetail.endTime<block.timestamp,"offer expired");
        require(own == msg.sender ,"not owner now");
        if(profit.pioneer == address(0)){
            nftProfit[offerdetail.tokenId][offerdetail.nftContract].pioneer = msg.sender;
        }else if(profit.ownerCount<10){
            nftProfit[offerdetail.tokenId][offerdetail.nftContract].exOwner[profit.ownerCount] = (msg.sender);
            nftProfit[offerdetail.tokenId][offerdetail.nftContract].ownerCount+=1;
        }
        IERC721(offerdetail.nftContract).transferFrom(msg.sender,offerdetail.offerAddress,offerdetail.tokenId);
        IStrategy(strategy[offerdetail.cryptoToken]).deposit(offerdetail.price  ,msg.sender,offerdetail.tokenId,offerdetail.offerAddress,1,1,offerdetail.nftContract);
        offerList[_offerId].isActive = false;
        emit AcceptOffer(msg.sender, offerdetail.offerAddress, _offerId);
    }

    /*  direct deposit to pool
        condition
            * require payment token is supported
            * require user balance must be sufficient for deposit
        1)deposit to pool
        1a)give approve to pool if token transfer
    */
    function deposit(address _tokenContract,uint256 _amount) public payable {
        require(isTokenSupport[_tokenContract]==true,"token contract not support");
        if(_tokenContract == 0xDfb1211E2694193df5765d54350e1145FD2404A1){
            require((msg.sender).balance>= _amount,"insufficient fund");
            IStrategy(strategy[_tokenContract]).directDeposit{value:msg.value}(msg.value ,msg.sender,0);
        }else{
            require(IERC20(_tokenContract).balanceOf(msg.sender) >= _amount,"insufficient fund");
            IERC20(_tokenContract).approve(strategy[_tokenContract],_amount);
            IERC20(_tokenContract).transferFrom(msg.sender,address(this),_amount);
            IStrategy(strategy[_tokenContract]).directDeposit(_amount ,msg.sender,0);
        }
    }

    /*  withdraw from pool
        condition
            * require payment token is supported
            * require user balance must be sufficient from pool(cant withdraw if fund are lock)
        withdraw
    */
    function withdraw(address _tokenContract,uint256 _amount) public  payable {
        require(isTokenSupport[_tokenContract]==true,"token contract not support");
        IStrategy(strategy[_tokenContract]).withdraw(_amount,msg.sender);
    }

    /* nftExOwnerDetail */
    function nftProfitDetail(uint256 _tokenId,address _nftContract) public view returns (nftProfitSharing memory)  {
        return nftProfit[_tokenId][_nftContract];
    }

    /* for staging use */
    function claimNFT(uint256 _tokenId) public {
        IERC721(0xF2F74b394F79f235038B0cB1769c881eEe66a705).transferFrom(address(this),msg.sender,_tokenId);
    }
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
library Counters {
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

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
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        uint256 currentAllowance = allowance(owner, spender);
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

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
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

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