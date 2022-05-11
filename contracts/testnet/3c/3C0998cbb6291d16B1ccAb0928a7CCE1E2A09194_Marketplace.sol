/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

interface IERC165 {
        function supportsInterface(bytes4 interfaceId) external view returns (bool);
    }

interface IERC1155 is IERC165 {

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function isApprovedForAll(address account, address operator) external view returns (bool);

    function setApprovalForAll(address operator, bool approved) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        string calldata data
    ) external;

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

    address nftadd;
    address tokenadd;

    mapping(uint256 => History) private Tokenhistory;

    mapping(uint256 => mapping(uint256 => Sell)) public sellDetails;
    mapping(uint256 => uint256) public tokenOFsell;
    mapping(uint256 => bool) public isnativeSell;

    mapping(uint256 => mapping(uint256 => Auction)) public auctionDetails;
    mapping(uint256 => uint256) public tokenOFauction;
    mapping(uint256 => bool) public isnativeauction;
    mapping(uint256 => bool) public auctionDetailstatus;

    mapping (uint256 => mapping(uint256 => Offer)) public offers;
    mapping (address => uint) public userFunds;
    mapping(uint256 => uint256) public tokenOFoffer;
    mapping(uint256 => bool) public isnativeOffer;

    mapping(uint256 => ownerDetail) private ownerDetails;

    struct Sell{
        uint tokenId;
        uint values;
        address seller;
        uint256 price;
        bool sold;
    }

    struct Auction{
        uint256 tokenId;
        uint256 values;
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

    struct Offer {
        uint offerId;
        address user;
        uint256 price;
        uint256 values;
        address owner;
        uint256 offerEnd;
        bool fulfilled;
        bool cancelled;
    }

    event onOffer(
        uint256 offerId,
        uint256 tokenId,
        address user,
        uint256 price,
        uint256 values,
        address owner,
        bool fulfilled,
        bool cancelled
    );

    struct ownerDetail{
        address[] _history;
        uint256[] _amount;
    }

    event OfferCancelled(uint256 offerId, uint256 tokenId, address owner,uint256 retuneamount);
    event OfferFilled(uint256 offerId, uint256 tokenId, address newOwner);
    event sell_auction_create(uint256 tokenId, uint256 marketId, uint256 values, address beneficiary, uint256 startTime, uint256 endTime, uint256 reservePrice);
    event onBid(uint256 marketId, address highestBidder, uint256 highestBid);
    event refund(address previousbidder, uint256 previoushighestbid);
    event onCommision(uint256 marketId, uint256 adminCommision, uint256 creatorRoyalty, uint256 ownerAmount);
    event closed(uint256 tokenId, uint auctionId);

    constructor (address _tokenaddress, address _nftaddress, uint256 _commision, uint256 _nativecommision) {
        commision = _commision;
        nativecommision = _nativecommision;

        nftadd = _nftaddress;
        tokenadd = _tokenaddress;
    }

    function sell(uint256 _tokenId, uint256 _value, uint256 _price, bool _isnativesell) public returns(bool){

        require(_price > 0, "Price set to zero");
        require(canSell(_tokenId, _value, _msgSender()), "Sell is open");

        idCount.increment();
        uint256 _sellID = uint256(idCount.current());
        tokenOFsell[_sellID] = _tokenId;

        if(_isnativesell){
            isnativeSell[_sellID] = true;
        }

        sellDetails[_tokenId][_sellID] = Sell({
                tokenId: _tokenId,
                values: _value,
                seller: _msgSender(),
                price:  _price,
                sold: false
        });

        IERC1155(nftadd).safeTransferFrom(_msgSender(), address(this), _tokenId, _value, "");

        emit sell_auction_create(_tokenId, _sellID, _value, sellDetails[_tokenId][_sellID].seller, 0, 0, _price);
        return true;
    }


    function buy(uint256 _sellID, uint256 _values) public returns(bool){

        uint256 _tokenId = tokenOFsell[_sellID];
        uint256 _price = (sellDetails[_tokenId][_sellID].price * _values);

        require(_msgSender() != sellDetails[_tokenId][_sellID].seller, "owner can't buy");
        require(!sellDetails[_tokenId][_sellID].sold, "already sold");
        require(!isnativeSell[_sellID], "Tokenid for native sell");
        require(_values <= sellDetails[_tokenId][_sellID].values, "value is not for sale");
        require(IERC20(tokenadd).balanceOf(_msgSender()) >= _price, "not enough balance");


        address _creator = IERC1155(nftadd).creatorOf(_tokenId);

        uint256 _royalty = IERC1155(nftadd).royaltyOf(_tokenId);

        uint256 _commision4creator = _price.mul(_royalty).div(10000);
        uint256 _commision4admin = _price.mul(commision).div(10000);
        uint256 _amount4owner = _price.sub((_commision4creator).add(_commision4admin));

        IERC1155(nftadd).safeTransferFrom(address(this), _msgSender(), _tokenId, _values, "");
        updatedata(address(this), _msgSender(), _tokenId);

        sellDetails[_tokenId][_sellID].values = sellDetails[_tokenId][_sellID].values - _values;

        if(sellDetails[_tokenId][_sellID].values == 0){
            sellDetails[_tokenId][_sellID].sold = true;
        }

        address a = _msgSender();

        IERC20(tokenadd).transferFrom(a, address(this), _price);
        IERC20(tokenadd).transfer(_creator, _commision4creator);
        IERC20(tokenadd).transfer(sellDetails[_tokenId][_sellID].seller, _amount4owner);
        IERC20(tokenadd).transfer(owner(), _commision4admin);

        emit onCommision(_sellID, _commision4admin, _commision4creator, _amount4owner);
        return true;
    }

    function nativeBuy(uint256 _sellID, uint256 _values) public payable returns(bool){

        uint256 _tokenId = tokenOFsell[_sellID];
        uint256 _price = sellDetails[_tokenId][_sellID].price.mul(_values);

        require(_msgSender() != sellDetails[_tokenId][_sellID].seller, "owner can't buy");
        require(msg.value == _price, "not enough balance");
        require(!sellDetails[_tokenId][_sellID].sold, "already sold");
        require(isnativeSell[_sellID], "not native sell");
        require(_values <= sellDetails[_tokenId][_sellID].values, "value is not for sale");

        address _creator = IERC1155(nftadd).creatorOf(_tokenId);

        uint256 _royalty = uint256(IERC1155(nftadd).royaltyOf(_tokenId));
        uint256 _commision4creator = uint256(_price.mul(_royalty).div(10000));
        uint256 _commision4admin = uint256(_price.mul(nativecommision).div(10000));
        uint256 _amount4owner = uint256(_price.sub(uint256(_commision4creator).add(_commision4admin)));

        IERC1155(nftadd).safeTransferFrom(address(this), _msgSender(), _tokenId, _values, "");
        updatedata(address(this), _msgSender(), _tokenId);

        sellDetails[_tokenId][_sellID].values = sellDetails[_tokenId][_sellID].values - _values;

            if(sellDetails[_tokenId][_sellID].values == 0){
                sellDetails[_tokenId][_sellID].sold = true;
            }

        payable(_creator).transfer(_commision4creator);
        payable(sellDetails[_tokenId][_sellID].seller).transfer(_amount4owner);
        payable(owner()).transfer(_commision4admin);

        emit onCommision(_sellID, _commision4admin, _commision4creator, _amount4owner);
        return true;
    }

    function createAuction(uint256 _tokenId, uint256 _values, uint256 _startingTime, uint256 _closingTime, uint256 _reservePrice, bool _isnativeauciton) public returns(bool){

        idCount.increment();
        uint256 _auctionId = uint256(idCount.current());

        tokenOFauction[_auctionId] = _tokenId;

        if(_isnativeauciton){
            isnativeauction[_auctionId] = true;
        }

        require(canSell(_tokenId, _values, msg.sender), "Can not auction this values");
        require(IERC1155(nftadd).balanceOf(msg.sender, _tokenId) >= _values, "sellDetails does not have enough balance");
        require(_startingTime < _closingTime, "Invalid start or end time");

        auctionDetails[_tokenId][_auctionId] = Auction({
                        tokenId: _tokenId,
                        values: _values,
                        beneficiary: _msgSender(),
                        highestBid: 0,
                        highestBidder: address(0x0),
                        open: true,
                        start: _startingTime,
                        end: _closingTime
                    });

        IERC1155(nftadd).safeTransferFrom(_msgSender(), address(this), _tokenId, _values, "");

        emit sell_auction_create(_tokenId, _auctionId, _values, auctionDetails[_tokenId][_auctionId].beneficiary, _startingTime, _closingTime, _reservePrice);

        return true;
    }

    function bid(uint256 _auctionId, uint256 _price) public returns(bool) {

        uint256 _tokenId = tokenOFauction[_auctionId];

        require(!isnativeauction[_auctionId],"no native auction");
        require(_msgSender() != auctionDetails[_tokenId][_auctionId].beneficiary, "The owner cannot bid");
        require(!_msgSender().isContract(), "No script kiddies");
        require(auctionDetails[_tokenId][_auctionId].open, "No opened auction found");
        require(IERC20(tokenadd).balanceOf(_msgSender()) >= _price, "Insuffucuent funds");
        require(
            block.timestamp >= auctionDetails[_tokenId][_auctionId].start,
            "Auction not yet started."
        );

        require(
            block.timestamp <= auctionDetails[_tokenId][_auctionId].end,
            "Auction already ended."
        );

        require(
            _price > auctionDetails[_tokenId][_auctionId].highestBid,
            "There already is a higher bid."
        );

        if (auctionDetails[_tokenId][_auctionId].highestBid > 0) {
            IERC20(tokenadd).transfer(auctionDetails[_tokenId][_auctionId].highestBidder, auctionDetails[_tokenId][_auctionId].highestBid);
            emit refund(auctionDetails[_tokenId][_auctionId].highestBidder, auctionDetails[_tokenId][_auctionId].highestBid);
        }

        IERC20(tokenadd).transferFrom(_msgSender(), address(this), _price);

        auctionDetails[_tokenId][_auctionId].highestBidder = _msgSender();
        auctionDetails[_tokenId][_auctionId].highestBid = _price;

        Tokenhistory[_tokenId]._history.push(auctionDetails[_tokenId][_auctionId].highestBidder);
        Tokenhistory[_tokenId]._amount.push(auctionDetails[_tokenId][_auctionId].highestBid);
        Tokenhistory[_tokenId]._biddingtime.push(block.timestamp);

        emit onBid(_auctionId, auctionDetails[_tokenId][_auctionId].highestBidder, auctionDetails[_tokenId][_auctionId].highestBid);
        return true;
    }

    function nativeBid(uint256 _auctionId, uint256 price) public payable returns(bool) {

        uint256 _tokenId = tokenOFauction[_auctionId];

        require(isnativeauction[_auctionId], "NFT:not native auction");
        require(_msgSender() != auctionDetails[_tokenId][_auctionId].beneficiary, "The owner cannot bid his own collectible");
        require(!_msgSender().isContract(), "No script kiddies");
        require(auctionDetails[_tokenId][_auctionId].open, "No opened auction found");
        require(
            block.timestamp >= auctionDetails[_tokenId][_auctionId].start,
            "Auction not yet started."
        );

        require(
            block.timestamp <= auctionDetails[_tokenId][_auctionId].end,
            "Auction already ended."
        );

        require(
            msg.value > auctionDetails[_tokenId][_auctionId].highestBid,
            "There already is a higher bid."
        );

        if (auctionDetails[_tokenId][_auctionId].highestBid>0) {
            payable(auctionDetails[_tokenId][_auctionId].highestBidder).transfer(auctionDetails[_tokenId][_auctionId].highestBid);
            emit refund(auctionDetails[_tokenId][_auctionId].highestBidder, auctionDetails[_tokenId][_auctionId].highestBid);
        }

        payable(address(this)).transfer(price);

        auctionDetails[_tokenId][_auctionId].highestBidder = _msgSender();
        auctionDetails[_tokenId][_auctionId].highestBid = msg.value;

        Tokenhistory[_tokenId]._history.push(auctionDetails[_tokenId][_auctionId].highestBidder);
        Tokenhistory[_tokenId]._amount.push(auctionDetails[_tokenId][_auctionId].highestBid);
        Tokenhistory[_tokenId]._biddingtime.push(block.timestamp);

        emit onBid(_auctionId, auctionDetails[_tokenId][_auctionId].highestBidder, auctionDetails[_tokenId][_auctionId].highestBid);

        return true;
    }

    function auctionFinalize(uint256 _auctionId) public returns(bool){

        uint256 _tokenId = tokenOFauction[_auctionId];

        uint256 bid_ = auctionDetails[_tokenId][_auctionId].highestBid;
        uint256 royalty = uint256(IERC1155(nftadd).royaltyOf(_tokenId));

        require(auctionDetails[_tokenId][_auctionId].beneficiary == _msgSender(),"Only owner can finalize this collectibles ");
        require(auctionDetails[_tokenId][_auctionId].open, "There is no auction opened for this tokenId");
        require(block.timestamp >= auctionDetails[_tokenId][_auctionId].end, "Auction not yet ended.");

        address from = auctionDetails[_tokenId][_auctionId].beneficiary;
        address highestBidder = auctionDetails[_tokenId][_auctionId].highestBidder;

        if (bid_ == 0){
            auctionDetails[_tokenId][_auctionId].open = false;
            return true;
        }
        else{
            address tokencreator = IERC1155(nftadd).creatorOf(_tokenId);
            uint256 royalty4creator = (bid_).mul(royalty).div(10000);

            if(isnativeauction[_auctionId]){

                uint256 amount4admin_ = (bid_).mul(nativecommision).div(10000);
                uint256 amount4owner_ = (bid_).sub(amount4admin_.add(royalty4creator));

                payable(from).transfer( amount4owner_);
                payable(owner()).transfer(amount4admin_);
                payable(tokencreator).transfer(royalty4creator);

                emit onCommision(_auctionId, amount4admin_, royalty4creator, amount4owner_);
            }else{
                uint256 amount4admin = (bid_).mul(commision).div(10000);
                uint256 amount4owner = (bid_).sub(amount4admin.add(royalty4creator));
                
                IERC20(tokenadd).transfer(from, amount4owner);
                IERC20(tokenadd).transfer(owner(), amount4admin);
                IERC20(tokenadd).transfer(tokencreator, royalty4creator);
                
                emit onCommision(_auctionId, amount4admin, royalty4creator, amount4owner);
            }

            IERC1155(nftadd).safeTransferFrom(from, highestBidder, _tokenId, auctionDetails[_tokenId][_auctionId].values, "");
            updatedata(address(this), _msgSender(), _tokenId);

            auctionDetails[_tokenId][_auctionId].open = false;
            return true;
        }
    }

    function canSell(uint256 tokenId, uint256 _value, address _from) public view returns (bool) {
        uint256 value;
        uint256 f = IERC1155(nftadd).balanceOf(_from, tokenId);

        for(uint256 i=1; i< idCount.current(); i++){
            if(sellDetails[tokenId][i].sold && sellDetails[tokenId][i].seller == _from && sellDetails[tokenId][i].tokenId == tokenId){
                value +=  sellDetails[tokenId][i+1].values;
            }
            if(auctionDetails[tokenId][i].open  && auctionDetails[tokenId][i].beneficiary == _from){
                value += auctionDetails[tokenId][i].values;
            }
        }

        if(f >= value + _value){
            return true;
        }

        else{
            return false;
        }
    }

    function makeOffer(uint256 _tokenId, uint256 _values, address _owner, uint256 _endtime, uint256 _price) public returns(bool){
        require(_price > 0, "price set to zero");
        require(IERC1155(nftadd).balanceOf(_owner, _tokenId) >= _values, "NFT: not enough values");
        require(_owner != _msgSender(), "NFT: Owner can't");
        idCount.increment();
        uint256 _offerId = uint256(idCount.current());

        tokenOFoffer[_offerId] = _tokenId;

        IERC20(tokenadd).transferFrom(_msgSender(), address(this), _price);

        offers[_tokenId][_offerId] = Offer({
            offerId: _offerId,
            user: _msgSender(),
            price: _price,
            values: _values,
            owner: _owner,
            offerEnd: _endtime,
            fulfilled: false,
            cancelled: false
        });

        emit onOffer(_offerId, _tokenId, _msgSender(), _price, _values, _owner, false, false);
        return true;

    }

    function makeNativeOffer(uint256 _tokenId, uint256 _values, address _owner, uint256 _endtime) public payable returns(bool){
        require(msg.value > 0, "Price set to zero");
        require(IERC1155(nftadd).balanceOf(_owner, _tokenId) >= _values, "NFT: not enough values");
        require(_owner != _msgSender(), "NFT: Owner can't");

        idCount.increment();
        uint256 _offerId = uint256(idCount.current());

        isnativeOffer[_offerId] = true;
        tokenOFoffer[_offerId] = _tokenId;

        offers[_tokenId][_offerId] = Offer({
            offerId: _offerId,
            user: _msgSender(),
            price: msg.value,
            values: _values,
            owner: _owner,
            offerEnd: _endtime,
            fulfilled: false,
            cancelled: false
        });

        emit onOffer(_offerId, _tokenId, _msgSender(), msg.value, _values, _owner, false, false);
        return true;
    }

    function fillOffer(uint256 _offerId) public{

        uint256 _tokenId = tokenOFoffer[_offerId];

        require(offers[_tokenId][_offerId].owner == _msgSender(), "NFT: only owner can");
        require(offers[_tokenId][_offerId].offerId == _offerId, "offer not exist");
        require(offers[_tokenId][_offerId].user != msg.sender, "NFT:owner can't");
        require(!offers[_tokenId][_offerId].fulfilled, "fullfilled twice");
        require(!offers[_tokenId][_offerId].cancelled, "offer cancelled");
        require(IERC1155(nftadd).balanceOf(offers[_tokenId][_offerId].owner, _tokenId) >= offers[_tokenId][_offerId].values,"not enough values");

        uint256 royalty = uint256(IERC1155(nftadd).royaltyOf(_tokenId));

        uint256 royalty4creator = (offers[_tokenId][_offerId].price).mul(royalty).div(10000);

        if(isnativeOffer[_offerId]){
            uint256 amount4admin_ = (offers[_tokenId][_offerId].price).mul(nativecommision).div(10000);
            uint256 amount4owner_ = (offers[_tokenId][_offerId].price).sub(amount4admin_.add(royalty4creator));
            payable(offers[_tokenId][_offerId].owner).transfer(amount4owner_);
            payable(owner()).transfer(amount4admin_);
            payable(IERC1155(nftadd).creatorOf(_tokenId)).transfer(royalty4creator);
        }else{
            uint256 amount4admin = (offers[_tokenId][_offerId].price).mul(commision).div(10000);
            uint256 amount4owner = (offers[_tokenId][_offerId].price).sub(amount4admin.add(royalty4creator));
            IERC20(tokenadd).transfer(offers[_tokenId][_offerId].owner, amount4owner);
            IERC20(tokenadd).transfer(owner(), amount4admin);
            IERC20(tokenadd).transfer(IERC1155(nftadd).creatorOf(_tokenId), royalty4creator);
            }

        IERC1155(nftadd).safeTransferFrom(address(this), _msgSender(), _tokenId, offers[_tokenId][_offerId].values, "");

        delete offers[_tokenId][_offerId];
        emit OfferFilled(_offerId, _tokenId, msg.sender);
    }

    function withdrawOffer(uint256 _offerId) public {

        uint256 _tokenId = tokenOFoffer[_offerId];

        require(offers[_tokenId][_offerId].offerId == _offerId, "The offer must exist");
        require(offers[_tokenId][_offerId].user == msg.sender, "Only owner can");
        require(offers[_tokenId][_offerId].fulfilled == false, "offer fullfilled");
        require(offers[_tokenId][_offerId].cancelled == false, "offer cancel twice");

        if(isnativeOffer[_offerId]){
            payable(_msgSender()).transfer(offers[_tokenId][_offerId].price);
        }else{
            require(!isnativeOffer[_offerId], "native offer");
            IERC20(tokenadd).transfer(_msgSender(), offers[_tokenId][_offerId].price);
        }

        delete offers[_tokenId][_offerId];
        emit OfferCancelled(_offerId, _tokenId, _msgSender(),offers[_tokenId][_offerId].price);
    }

    function listOfBidder(uint256 tokenId)public view returns(address[] memory, uint256[] memory, uint256[] memory){
        return (Tokenhistory[tokenId]._history, Tokenhistory[tokenId]._amount, Tokenhistory[tokenId]._biddingtime);
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

    function removeAuction(uint256 _auctionId) external returns(bool success){

        uint256 _tokenId = tokenOFauction[_auctionId];

        require(auctionDetails[_tokenId][_auctionId].open, "No opened auction found");
        require(auctionDetails[_tokenId][_auctionId].beneficiary == msg.sender,"Only owner can remove collectibles");

        if (auctionDetails[_tokenId][_auctionId].highestBid>0) {
            if(isnativeauction[_auctionId]){
                payable(auctionDetails[_tokenId][_auctionId].highestBidder).transfer(auctionDetails[_tokenId][_auctionId].highestBid);
            }else{
                IERC20(tokenadd).transfer(auctionDetails[_tokenId][_auctionId].highestBidder, auctionDetails[_tokenId][_auctionId].highestBid);
            }

            IERC1155(nftadd).safeTransferFrom(address(this), _msgSender(), _tokenId, auctionDetails[_tokenId][_auctionId].values, "");
            emit refund(auctionDetails[_tokenId][_auctionId].highestBidder, auctionDetails[_tokenId][_auctionId].highestBid);
        }

        delete auctionDetails[_tokenId][_auctionId];
        emit closed(_tokenId, _auctionId);
        return true;
    }

    function removeSell(uint256 _sellId) public returns(bool success){

        uint256 _tokenId = tokenOFsell[_sellId];

        require(sellDetails[_tokenId][_sellId].seller==msg.sender,"Only owner can remove this sell item");
        require(!sellDetails[_tokenId][_sellId].sold, "The collectible is not for sale");

        IERC1155(nftadd).safeTransferFrom(address(this), _msgSender(), _tokenId, sellDetails[_tokenId][_sellId].values, "");

        delete sellDetails[_tokenId][_sellId];
        emit closed(_tokenId, _sellId);
        return true;
    }

    function auctionDetail(uint256 _auctionId) public view returns(Auction memory){
        uint256 tokenId = tokenOFauction[_auctionId];
        return auctionDetails[tokenId][_auctionId];
    }

    function sellDetail(uint256 _sellId) public view returns(Sell memory){
        uint256 tokenId = tokenOFsell[_sellId];
        return sellDetails[tokenId][_sellId];
    }

    function openSell() public view returns(uint256[] memory){

        uint256 totalOpen;
        uint256 currentId;

        uint256 totalsupply = IERC1155(nftadd).totalSupply();
        for(uint256 i=1; i <= totalsupply; i++){
            for(uint256 j = 1; j<=idCount.current(); j++){
                if(sellDetails[i][j].sold){
                    totalOpen++;
                }
            }
        }

        uint256[] memory list = new uint256[] (totalOpen);

        for(uint256 i=1; i <= totalsupply; i++){
            for(uint256 j = 1; j<=idCount.current(); j++){
                if(sellDetails[i][j].sold){
                    list[currentId] = j;
                    currentId = currentId + 1;
                }
            }
        }
        return list;
    }

    function openAuction() public view returns(uint256[] memory){

        uint256 totalOpen;
        uint256 currentId;

        uint256 totalsupply = IERC1155(nftadd).totalSupply();

        for(uint256 i=1; i<=totalsupply; i++){
            for(uint256 j = 1; j<=idCount.current(); j++){
                if(auctionDetails[i][j].open){
                    totalOpen++;
                }
            }
        }

        uint256[] memory list = new uint256[] (totalOpen);

        for(uint256 i=1; i<=totalsupply; i++){
            for(uint256 j = 1; j<=idCount.current(); j++){
                if(auctionDetails[i][j].open){
                    list[currentId] = j;
                    currentId = currentId + 1;
                }
            }
        }
        return list;
    }

    function updatedata(address _from, address _to, uint256 _id) private returns(bool) {
        address[] memory _totalAddress =  ownerDetails[_id]._history;
        bool fropm;
        bool topm;
        for(uint256 i=0;i<_totalAddress.length;i++){
            if(_from == _totalAddress[i]){
                fropm = true;
                ownerDetails[_id]._history[i] = _from;
                ownerDetails[_id]._amount[i] = IERC1155(nftadd).balanceOf(_from, _id);
            }
            if(_to == _totalAddress[i]){
                topm = true;
                ownerDetails[_id]._history[i] = _to;
                ownerDetails[_id]._amount[i] = IERC1155(nftadd).balanceOf(_to, _id);
            }
        }
        if(!fropm){
            ownerDetails[_id]._history.push(_from);
            ownerDetails[_id]._amount.push(IERC1155(nftadd).balanceOf(_from, _id));
        }
        if(!topm){
            ownerDetails[_id]._history.push(_to);
            ownerDetails[_id]._amount.push(IERC1155(nftadd).balanceOf(_to, _id));
        }
        return true;
    }
}