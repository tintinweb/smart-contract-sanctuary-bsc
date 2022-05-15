/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

interface IERC165 {
        function supportsInterface(bytes4 interfaceId) external view returns (bool);
    }

interface IERC721 is IERC165 {
    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function setApprovalForAll(address operator, bool _approved) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function totalSupply() external view returns(uint256);
    function royaltyOf(uint256 tokenId) external view returns(uint256);
    function creatorOf(uint256 tokenId) external view returns(address);

}

interface IERC20 {
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value)external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library Counters {
    struct Counter {
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
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
}


contract Marketplace is Ownable{

    using SafeMath for uint256;
    using Address for address;

    using Counters for Counters.Counter;
    Counters.Counter public idCount;

    address public tokenaddress;

    uint256 public commision;
    uint256 public nativecommision;

    address _nftadd;
    address tokenadd;

    mapping(uint256 => bool) private sellstatus;
    mapping(uint256 => bool) private auctionstatus;
    
    mapping(uint256 => History) private Tokenhistory;
    mapping(uint256 => HistoryNative) private TokenhistoryNative;

    mapping(uint256 => Sell) public sellDetails;
    // mapping(uint256 => uint256) public tokenOFsell;
    mapping(uint256 => bool) public isnativeSell;

    mapping(uint256 => Auction) public auctionDetails;
    mapping(uint256 => uint256) public tokenOFauction;
    mapping(uint256 => bool) public isnativeauction;
    mapping(uint256 => bool) public auctionDetailstatus;

    mapping (uint256 => Offer) public offers;
    mapping (address => uint) public userFunds;
    mapping(uint256 => uint256) public tokenOFoffer;
    mapping(uint256 => bool) public isnativeOffer;

    mapping(uint256 => ownerDetail) private ownerDetails;

    struct Sell{
        address seller;
        address buyer;
        uint256 price;
        bool open;
    }

    struct Auction{
        address beneficiary;
        uint256 highestBid;
        address highestBidder;
        bool open;
        uint256 start;
        uint256 end;
    }

    struct History{
        address[] _history;
        uint256[] _amount;
        uint256[] _biddingtime;
    }

    struct HistoryNative{
        address[] _historyNative;
        uint256[] _amountNative;
        uint256[] _biddingtimeNative;
    }

    struct Offer {
        address user;
        uint256 price;
        address owner;
        uint256 offerEnd;
        bool fulfilled;
        bool cancelled;
    }

    event onOffer(
        uint256 tokenId,
        address user,
        uint256 price,
        address owner,
        bool fulfilled,
        bool cancelled
    );

    struct ownerDetail{
        address[] _history;
        uint256[] _amount;
    }

    event OfferCancelled(uint256 tokenId, address owner,uint256 returnamount);
    event OfferFilled(uint256 tokenId, address newOwner);
    event sell_auction_create(uint256 tokenId, address beneficiary, uint256 startTime, uint256 endTime, uint256 reservePrice, bool isNative);
    event onBid(uint256 marketId, address highestBidder, uint256 highestBid);
    event refund(address previousbidder, uint256 previoushighestbid);
    event onCommision(uint256 marketId, uint256 adminCommision, uint256 creatorRoyalty, uint256 ownerAmount);
    event closed(uint256 tokenId, uint auctionId);

    constructor (address _tokenaddress, address _nftaddress, uint256 _commision, uint256 _nativecommision) {
        commision = _commision;
        nativecommision = _nativecommision;

        _nftadd = _nftaddress;
        tokenadd = _tokenaddress;
    }

    function callOptionalReturn(IERC721 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC721: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC721: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC721: BEP20 operation did not succeed");
        }
    }

    function sell(uint256 _tokenId, uint256 _price, bool _isnativesell) public returns(bool){

        require(_price > 0, "Price set to zero");
        require(IERC721(_nftadd).ownerOf(_tokenId) == _msgSender(), "NFT: Not owner");
        require(!auctionstatus[_tokenId], "NFT: Open auction found");
        require(_nftadd != address(0x0),"NFT: address initialize to zero address");

        
        if(_isnativesell){
            isnativeSell[_tokenId] = true;
        }

        sellDetails[_tokenId]= Sell({
                seller: _msgSender(),
                buyer: address(0x0),
                price:  _price,
                open: true
        });

        sellstatus[_tokenId] = true;

        IERC721(_nftadd).transferFrom(_msgSender(), address(this), _tokenId);

        emit sell_auction_create(_tokenId, _msgSender(), 0, 0, sellDetails[_tokenId].price, _isnativesell);
        return true;
    }

    function buy(uint256 _tokenId) public returns(bool){

        uint256 _price = (sellDetails[_tokenId].price);

        require(_msgSender() != sellDetails[_tokenId].seller, "owner can't buy");
        require(sellDetails[_tokenId].open, "already open");
        require(!isnativeSell[_tokenId], "NFT for native sell");
        require(IERC20(tokenadd).balanceOf(_msgSender()) >= _price, "not enough balance");

        address _owner = IERC721(_nftadd).ownerOf(_tokenId);

        address _creator = IERC721(_nftadd).creatorOf(_tokenId);
        uint256 _royalty = IERC721(_nftadd).royaltyOf(_tokenId);

        uint256 _commision4creator = _price.mul(_royalty).div(10000);
        uint256 _commision4admin = _price.mul(commision).div(10000);
        uint256 _amount4owner = _price.sub((_commision4creator).add(_commision4admin));

        sellstatus[_tokenId] = false;

        sellDetails[_tokenId].buyer = _msgSender();
        sellDetails[_tokenId].open = false;

        IERC20(tokenadd).transferFrom(_msgSender(), address(this), _price);
        IERC20(tokenadd).transfer(_creator, _commision4creator);
        IERC20(tokenadd).transfer(sellDetails[_tokenId].seller, _amount4owner);
        IERC20(tokenadd).transfer(owner(), _commision4admin);

        callOptionalReturn(IERC721(_nftadd), abi.encodeWithSelector(IERC721(_nftadd).transferFrom.selector, _owner, _msgSender(), _tokenId));

        emit onCommision(_tokenId, _commision4admin, _commision4creator, _amount4owner);
        return true;
    }

    function nativeBuy(uint256 _tokenId) public payable returns(bool){

        uint256 _price = sellDetails[_tokenId].price;

        require(_msgSender() != sellDetails[_tokenId].seller, "owner can't buy");
        require(msg.value == _price, "not enough balance");
        require(sellDetails[_tokenId].open, "already open");
        require(isnativeSell[_tokenId], "not native sell");

        address _owner = IERC721(_nftadd).ownerOf(_tokenId);

        address _creator = IERC721(_nftadd).creatorOf(_tokenId);

        uint256 _royalty = uint256(IERC721(_nftadd).royaltyOf(_tokenId));
        uint256 _commision4creator = uint256(_price.mul(_royalty).div(10000));
        uint256 _commision4admin = uint256(_price.mul(nativecommision).div(10000));
        uint256 _amount4owner = uint256(_price.sub(uint256(_commision4creator).add(_commision4admin)));

        sellstatus[_tokenId] = false;

        sellDetails[_tokenId].buyer = _msgSender();
        sellDetails[_tokenId].open = false;
        
        payable(_creator).transfer(_commision4creator);
        payable(sellDetails[_tokenId].seller).transfer(_amount4owner);
        payable(owner()).transfer(_commision4admin);

        callOptionalReturn(IERC721(_nftadd), abi.encodeWithSelector(IERC721(_nftadd).transferFrom.selector, _owner, _msgSender(), _tokenId));

        emit onCommision(_tokenId, _commision4admin, _commision4creator, _amount4owner);
        return true;
    }

    function createAuction(uint256 _tokenId, uint256 _startingTime, uint256 _closingTime, uint256 _reservePrice, bool _isnativeauciton) public returns(bool){
        
        require(_reservePrice > 0, "Price set to zero");
        require(IERC721(_nftadd).ownerOf(_tokenId) == _msgSender(), "NFT: Not owner");
        require(!sellstatus[_tokenId], "NFT: Open sell found");

        if(_isnativeauciton){
            isnativeauction[_tokenId] = true;
        }

        require(_startingTime < _closingTime, "Invalid start or end time");

        auctionDetails[_tokenId]= Auction({
                        beneficiary: _msgSender(),
                        highestBid: 0,
                        highestBidder: address(0x0),
                        open: true,
                        start: _startingTime,
                        end: _closingTime
                    });

        IERC721(_nftadd).transferFrom(_msgSender(), address(this), _tokenId);

        emit sell_auction_create(_tokenId, _msgSender(), 0, 0, auctionDetails[_tokenId].highestBid, _isnativeauciton);

        return true;
    }

    function bid(uint256 _tokenId, uint256 _price) public returns(bool) {

        require(!isnativeauction[_tokenId],"no native auction");
        require(_msgSender() != auctionDetails[_tokenId].beneficiary, "The owner cannot bid");
        require(!_msgSender().isContract(), "No script kiddies");
        require(auctionDetails[_tokenId].open, "No opened auction found");
        require(IERC20(tokenadd).balanceOf(_msgSender()) >= _price, "Insuffucuent funds");
        require(
            block.timestamp >= auctionDetails[_tokenId].start,
            "Auction not yet started."
        );

        require(
            block.timestamp <= auctionDetails[_tokenId].end,
            "Auction already ended."
        );

        require(
            _price > auctionDetails[_tokenId].highestBid,
            "There already is a higher bid."
        );

        if (auctionDetails[_tokenId].highestBid > 0) {
            IERC20(tokenadd).transfer(auctionDetails[_tokenId].highestBidder, auctionDetails[_tokenId].highestBid);
            emit refund(auctionDetails[_tokenId].highestBidder, auctionDetails[_tokenId].highestBid);
        }

        
        IERC20(tokenadd).transferFrom(_msgSender(), address(this), _price);

        auctionDetails[_tokenId].highestBidder = _msgSender();
        auctionDetails[_tokenId].highestBid = _price;

        Tokenhistory[_tokenId]._history.push(auctionDetails[_tokenId].highestBidder);
        Tokenhistory[_tokenId]._amount.push(auctionDetails[_tokenId].highestBid);
        Tokenhistory[_tokenId]._biddingtime.push(block.timestamp);

        emit onBid(_tokenId, auctionDetails[_tokenId].highestBidder, auctionDetails[_tokenId].highestBid);
        return true;
    }

    function nativeBid(uint256 _tokenId) public payable returns(bool) {

        require(_msgSender() != auctionDetails[_tokenId].beneficiary, "The owner cannot bid his own collectible");
        require(!_msgSender().isContract(), "No script kiddies");
        require(auctionDetails[_tokenId].open, "No opened auction found");
        require(
            block.timestamp >= auctionDetails[_tokenId].start,
            "Auction not yet started."
        );

        require(
            block.timestamp <= auctionDetails[_tokenId].end,
            "Auction already ended."
        );

        require(
            msg.value > auctionDetails[_tokenId].highestBid,
            "There already is a higher bid."
        );

        if (auctionDetails[_tokenId].highestBid>0) {
            payable(auctionDetails[_tokenId].highestBidder).transfer(auctionDetails[_tokenId].highestBid);
            emit refund(auctionDetails[_tokenId].highestBidder, auctionDetails[_tokenId].highestBid);
        }

        auctionDetails[_tokenId].highestBidder = _msgSender();
        auctionDetails[_tokenId].highestBid = msg.value;

        TokenhistoryNative[_tokenId]._historyNative.push(auctionDetails[_tokenId].highestBidder);
        TokenhistoryNative[_tokenId]._amountNative.push(auctionDetails[_tokenId].highestBid);
        TokenhistoryNative[_tokenId]._biddingtimeNative.push(block.timestamp);

        emit onBid(_tokenId, auctionDetails[_tokenId].highestBidder, auctionDetails[_tokenId].highestBid);

        return true;
    }

    function auctionFinalize(uint256 _tokenId) public returns(bool){

        uint256 bid_ = auctionDetails[_tokenId].highestBid;
        uint256 royalty = uint256(IERC721(_nftadd).royaltyOf(_tokenId));

        require(auctionDetails[_tokenId].beneficiary == _msgSender(),"Only owner can finalize this collectibles ");
        require(auctionDetails[_tokenId].open, "There is no auction opened for this tokenId");
        require(block.timestamp >= auctionDetails[_tokenId].end, "Auction not yet ended.");

        address from = auctionDetails[_tokenId].beneficiary;
        address highestBidder = auctionDetails[_tokenId].highestBidder;

        address _owner = IERC721(_nftadd).ownerOf(_tokenId);

        address tokencreator = IERC721(_nftadd).creatorOf(_tokenId);
        uint256 royalty4creator = (bid_).mul(royalty).div(10000);

        if(isnativeauction[_tokenId]){
            uint256 amount4admin_ = (bid_).mul(nativecommision).div(10000);
            uint256 amount4owner_ = (bid_).sub(amount4admin_.add(royalty4creator));

            payable(from).transfer( amount4owner_);
            payable(owner()).transfer(amount4admin_);
            payable(tokencreator).transfer(royalty4creator);

            emit onCommision(_tokenId, amount4admin_, royalty4creator, amount4owner_);
        }else{
            uint256 amount4admin = (bid_).mul(commision).div(10000);
            uint256 amount4owner = (bid_).sub(amount4admin.add(royalty4creator));
            
            IERC20(tokenadd).transfer(from, amount4owner);
            IERC20(tokenadd).transfer(owner(), amount4admin);
            IERC20(tokenadd).transfer(tokencreator, royalty4creator);
            
            emit onCommision(_tokenId, amount4admin, royalty4creator, amount4owner);
        }

        callOptionalReturn(IERC721(_nftadd), abi.encodeWithSelector(IERC721(_nftadd).transferFrom.selector, _owner, highestBidder, _tokenId));

        auctionDetails[_tokenId].open = false;
        return true;
    }


    function makeOffer(uint256 _tokenId, address _owner, uint256 _endtime, uint256 _price) public returns(bool){
        require(_price > 0, "price set to zero");
        require(_owner != _msgSender(), "NFT: Owner can't");

        IERC20(tokenadd).transferFrom(_msgSender(), address(this), _price);

        offers[_tokenId] = Offer({
            user: _msgSender(),
            price: _price,
            owner: _owner,
            offerEnd: _endtime,
            fulfilled: false,
            cancelled: false
        });

        emit onOffer(_tokenId, _msgSender(), _price, _owner, false, false);
        return true;

    }

    function makeNativeOffer(uint256 _tokenId, uint256 _values, address _owner, uint256 _endtime) public payable returns(bool){
        require(msg.value > 0, "Price set to zero");
        require(IERC721(_nftadd).balanceOf(_owner) >= _values, "NFT: not enough values");
        require(_owner != _msgSender(), "NFT: Owner can't");

        isnativeOffer[_tokenId] = true;

        offers[_tokenId] = Offer({
            user: _msgSender(),
            price: msg.value,
            owner: _owner,
            offerEnd: _endtime,
            fulfilled: false,
            cancelled: false
        });

        emit onOffer(_tokenId, _msgSender(), msg.value, _owner, false, false);
        return true;
    }

    function fillOffer(uint256 _tokenId) public{

        require(offers[_tokenId].owner == _msgSender(), "NFT: only owner can");
        require(offers[_tokenId].user != msg.sender, "NFT:owner can't");
        require(block.timestamp <= offers[_tokenId].offerEnd, "NFT: offer ended");
        require(!offers[_tokenId].fulfilled, "fullfilled twice");
        require(!offers[_tokenId].cancelled, "offer cancelled");

        address _owner = IERC721(_nftadd).ownerOf(_tokenId);

        uint256 royalty = uint256(IERC721(_nftadd).royaltyOf(_tokenId));

        uint256 royalty4creator = (offers[_tokenId].price).mul(royalty).div(10000);

        if(isnativeOffer[_tokenId]){
            uint256 amount4admin_ = (offers[_tokenId].price).mul(nativecommision).div(10000);
            uint256 amount4owner_ = (offers[_tokenId].price).sub(amount4admin_.add(royalty4creator));
            payable(offers[_tokenId].owner).transfer(amount4owner_);
            payable(owner()).transfer(amount4admin_);
            payable(IERC721(_nftadd).creatorOf(_tokenId)).transfer(royalty4creator);
        }else{
            uint256 amount4admin = (offers[_tokenId].price).mul(commision).div(10000);
            uint256 amount4owner = (offers[_tokenId].price).sub(amount4admin.add(royalty4creator));
            IERC20(tokenadd).transfer(offers[_tokenId].owner, amount4owner);
            IERC20(tokenadd).transfer(owner(), amount4admin);
            IERC20(tokenadd).transfer(IERC721(_nftadd).creatorOf(_tokenId), royalty4creator);
            }

        callOptionalReturn(IERC721(_nftadd), abi.encodeWithSelector(IERC721(_nftadd).transferFrom.selector, _owner, offers[_tokenId].user, _tokenId));

        emit OfferFilled(_tokenId, msg.sender);
    }

    function withdrawOffer(uint256 _tokenId) public {

        require(offers[_tokenId].user == msg.sender, "Only owner can");
        require(offers[_tokenId].fulfilled == false, "offer fullfilled");
        require(offers[_tokenId].cancelled == false, "offer cancel twice");

        if(isnativeOffer[_tokenId]){
            payable(_msgSender()).transfer(offers[_tokenId].price);
        }else{
            require(!isnativeOffer[_tokenId], "native offer");
            IERC20(tokenadd).transfer(_msgSender(), offers[_tokenId].price);
        }

        emit OfferCancelled(_tokenId, _msgSender(),offers[_tokenId].price);
    }

    function listOfBidder(uint256 tokenId)public view returns(address[] memory, uint256[] memory, uint256[] memory){
        return (Tokenhistory[tokenId]._history, Tokenhistory[tokenId]._amount, Tokenhistory[tokenId]._biddingtime);
    }

    function listOfNativeBidder(uint256 tokenId)public view returns(address[] memory, uint256[] memory, uint256[] memory){
        return (TokenhistoryNative[tokenId]._historyNative, TokenhistoryNative[tokenId]._amountNative, TokenhistoryNative[tokenId]._biddingtimeNative);
    }

    function listofOwner(uint256 tokenId)public view returns(address[] memory,uint256[] memory){
        return (ownerDetails[tokenId]._history, ownerDetails[tokenId]._amount);
    }

    function updateCommission(uint256 _commissionRate) public onlyOwner returns (bool){
        commision = _commissionRate;
        return true;
    }

    function updateNativeCommission(uint256 _nativecommision) public onlyOwner returns (bool){
        nativecommision = _nativecommision;
        return true;
    }

    function removeAuction(uint256 _tokenId) external returns(bool success){

        require(auctionDetails[_tokenId].open, "No opened auction found");
        require(auctionDetails[_tokenId].beneficiary == msg.sender,"Only owner can remove collectibles");

        if (auctionDetails[_tokenId].highestBid>0) {
            if(isnativeauction[_tokenId]){
                payable(auctionDetails[_tokenId].highestBidder).transfer(auctionDetails[_tokenId].highestBid);
            }else{
                IERC20(tokenadd).transfer(auctionDetails[_tokenId].highestBidder, auctionDetails[_tokenId].highestBid);
            }
            emit refund(auctionDetails[_tokenId].highestBidder, auctionDetails[_tokenId].highestBid);
        }

        address _owner = IERC721(_nftadd).ownerOf(_tokenId);

        callOptionalReturn(IERC721(_nftadd), abi.encodeWithSelector(IERC721(_nftadd).transferFrom.selector, _owner, _msgSender(), _tokenId));

        delete auctionDetails[_tokenId];
        emit closed(_tokenId, _tokenId);
        return true;
    }

    function removeSell(uint256 _tokenId) public returns(bool success){

        require(sellDetails[_tokenId].seller == msg.sender,"Only owner can remove this sell item");
        require(sellDetails[_tokenId].open, "The collectible is not for sale");

        IERC721(_nftadd).transferFrom(address(this), _msgSender(), _tokenId);

        delete sellDetails[_tokenId];
        return true;
    }

    function auctionDetail(uint256 _tokenId) public view returns(Auction memory){
        return auctionDetails[_tokenId];
    }

    function sellDetail(uint256 _tokenId) public view returns(Sell memory){
        return sellDetails[_tokenId];
    }

    function openSell() public view returns(uint256[] memory){

        uint256 totalOpen;
        uint256 currentId;

        uint256 totalsupply = IERC721(_nftadd).totalSupply();
        for(uint256 i=1; i <= totalsupply; i++){
            if(sellDetails[i].open){
                totalOpen++;
            }
        }

        uint256[] memory list = new uint256[] (totalOpen);

        for(uint256 i=1; i <= totalsupply; i++){
            if(sellDetails[i].open){
                list[currentId] = i;
                currentId = currentId + 1;
            }
        }
        return list;
    }

    function openAuction() public view returns(uint256[] memory){

                uint256 totalOpen;
        uint256 currentId;

        uint256 totalsupply = IERC721(_nftadd).totalSupply();
        for(uint256 i=1; i <= totalsupply; i++){
            if(auctionDetails[i].open){
                totalOpen++;
            }
        }

        uint256[] memory list = new uint256[] (totalOpen);

        for(uint256 i=1; i <= totalsupply; i++){
            if(auctionDetails[i].open){
                list[currentId] = i;
                currentId = currentId + 1;
            }
        }
        return list;
    }
}