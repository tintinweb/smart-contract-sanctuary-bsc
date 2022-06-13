/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-15
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

    address public _nftadd;
    address public tokenadd;

    mapping(uint256 => bool) private sellstatus;

    mapping(uint256 => History) private Tokenhistory;
    mapping(uint256 => HistoryNative) private TokenhistoryNative;

    mapping(uint256 => Sell) public sellDetails;
    // mapping(uint256 => uint256) public tokenOFsell;
    mapping(uint256 => bool) public isnative;

    mapping(uint256 => Auction) public auctionDetails;

    mapping (uint256 => Offer) public offers;

    mapping(uint256 => ownerDetail) private ownerDetails;

    struct Sell{
        address seller;
        address buyer;
        uint256 price;
        bool isnative;
        bool open;
    }

    struct Auction{
        address beneficiary;
        uint256 highestBid;
        address highestBidder;
        uint256 startvalue;
        bool open;
        bool isnative;
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
        uint256 tokenid;
        uint256 offerEnd;
        bool fulfilled;
        bool cancelled;
    }

    event onOffer(
        uint256 Offerid,
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

    event OfferCancelled(uint256 offerid, address owner,uint256 returnamount);
    event OfferFilled(uint256 offerid, address newOwner);
    event sell_auction_create(uint256 tokenId, address beneficiary, uint256 startTime, uint256 endTime, uint256 reservePrice, bool isNative);
    event onBid(uint256 tokenid, address highestBidder, uint256 highestBid);
    event refund(address previousbidder, uint256 previoushighestbid);
    event onCommision(uint256 tokenid, uint256 adminCommision, uint256 creatorRoyalty, uint256 ownerAmount);
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
    struct OpenSell{
        uint256[] ids;
    }
    mapping(address=>OpenSell)private opensell; 

    function userallids(address _a)public view returns(uint256[] memory){
        return opensell[_a].ids;
    }
    // opensell[address(this)].ids.push(tokenId);
    // require(findindex(_tokenId,address(this)),"is not update listof opensell");
    function findindex(uint256 _u,address _address)private returns(bool){
        uint256 l;
        for(uint i=0;i<opensell[_address].ids.length;i++){
            if(opensell[_address].ids[i]==_u){
                l = i;
            }
        }
        if(l == 0 && opensell[_address].ids[l]==_u){
            return openupdateArray(l,_address);
        }
        else if(l != 0 && opensell[_address].ids[l]==_u){
            return openupdateArray(l,_address);
        }
        else{
            return false;
        }
    }

    function openupdateArray(uint index,address _address) private returns(bool){
        for(uint i = index; i < opensell[_address].ids.length-1; i++){
            opensell[_address].ids[i] = opensell[_address].ids[i+1];      
        }
        opensell[_address].ids.pop();
        return true;
    }
    function sell(uint256 _tokenId, uint256 _price, bool _isnative) public returns(bool){

        require(_price > 0, "Price set to zero");
        require(IERC721(_nftadd).ownerOf(_tokenId) == _msgSender(), "NFT: Not owner");
        require(!sellstatus[_tokenId], "NFT: Open auction found");
        require(_nftadd != address(0x0),"NFT: address initialize to zero address");


        if(_isnative){
            isnative[_tokenId] = true;
        }
        sellDetails[_tokenId]= Sell({
                seller: _msgSender(),
                buyer: address(0x0),
                price:  _price,
                isnative : _isnative,
                open: true
        });

        sellstatus[_tokenId] = true;

        IERC721(_nftadd).transferFrom(_msgSender(), address(this), _tokenId);
        opensell[address(this)].ids.push(_tokenId);
        emit sell_auction_create(_tokenId, _msgSender(), 0, 0, sellDetails[_tokenId].price, _isnative);
        return true;
    }

    function buy(uint256 _tokenId) public returns(bool){

        uint256 _price = (sellDetails[_tokenId].price);

        require(_msgSender() != sellDetails[_tokenId].seller, "owner can't buy");
        require(sellDetails[_tokenId].open, "already open");
        require(sellstatus[_tokenId], "NFT for native sell");
        require(IERC20(tokenadd).balanceOf(_msgSender()) >= _price, "not enough balance");

        address _creator = IERC721(_nftadd).creatorOf(_tokenId);

        uint256 _royalty = IERC721(_nftadd).royaltyOf(_tokenId);

        uint256 _commision4creator = _price.mul(_royalty).div(10000);
        uint256 _commision4admin = _price.mul(commision).div(10000);
        uint256 _amount4owner = _price.sub((_commision4creator).add(_commision4admin));

        IERC20(tokenadd).transferFrom(_msgSender(), address(this), _price);
        IERC20(tokenadd).transfer(_creator, _commision4creator);
        IERC20(tokenadd).transfer(sellDetails[_tokenId].seller, _amount4owner);
        IERC20(tokenadd).transfer(owner(), _commision4admin);

        IERC721(_nftadd).transferFrom(address(this), _msgSender(),_tokenId);

        emit onCommision(_tokenId, _commision4admin, _commision4creator, _amount4owner);

        sellstatus[_tokenId] = false;
        sellDetails[_tokenId].buyer = _msgSender();
        sellDetails[_tokenId].open = false;
        require(findindex(_tokenId,address(this)),"is not update listof opensell");
        return true;
    }

    function nativeBuy(uint256 _tokenId) public payable returns(bool){
        uint256 _price = sellDetails[_tokenId].price;
        require(sellstatus[_tokenId],"tokenid not buy");
        require(_msgSender() != sellDetails[_tokenId].seller, "owner can't buy");
        require(msg.value >= _price, "not enough balance");
        require(sellDetails[_tokenId].open, "already open");
        require(isnative[_tokenId], "not native sell");

        address _creator = IERC721(_nftadd).creatorOf(_tokenId);
        uint256 _royalty = uint256(IERC721(_nftadd).royaltyOf(_tokenId));
        uint256 _commision4creator = uint256(_price.mul(_royalty).div(10000));
        uint256 _commision4admin = uint256(_price.mul(nativecommision).div(10000));
        uint256 _amount4owner = uint256(_price.sub(uint256(_commision4creator).add(_commision4admin)));


        payable(_creator).transfer(_commision4creator);
        payable(sellDetails[_tokenId].seller).transfer(_amount4owner);
        payable(owner()).transfer(_commision4admin);

        IERC721(_nftadd).transferFrom(address(this), _msgSender(),_tokenId);

        emit onCommision(_tokenId, _commision4admin, _commision4creator, _amount4owner);

        sellstatus[_tokenId] = false;
        sellDetails[_tokenId].buyer = _msgSender();
        sellDetails[_tokenId].open = false;
        require(findindex(_tokenId,address(this)),"is not update listof opensell");
        return true;
    }
    struct OpenAuction{
        uint256[] ids;
    }
    mapping(address=>OpenAuction)private openauction; 

    function OpenAlltokenid(address _a)public view returns(uint256[] memory){
        return openauction[_a].ids;
    }
    // openauction[address(this)].ids.push(tokenId);
    // require(findindexInAuction(_tokenId,address(this)),"is not update listof opensell");
    function findindexInAuction(uint256 _u,address _address)private returns(bool){
        uint256 l;
        for(uint i=0;i<openauction[_address].ids.length;i++){
            if(openauction[_address].ids[i]==_u){
                l = i;
            }
        }
        if(l == 0 && openauction[_address].ids[l]==_u){
            return openupdateArrayinAuction(l,_address);
        }
        else if(l != 0 && openauction[_address].ids[l]==_u){
            return openupdateArrayinAuction(l,_address);
        }
        else{
            return false;
        }
    }

    function openupdateArrayinAuction(uint index,address _address) private returns(bool){
        for(uint i = index; i < openauction[_address].ids.length-1; i++){
            openauction[_address].ids[i] = openauction[_address].ids[i+1];      
        }
        openauction[_address].ids.pop();
        return true;
    }
    function createAuction(uint256 _tokenId, uint256 _startingTime, uint256 _closingTime, uint256 _reservePrice, bool _isnativeauciton) public returns(bool){

        require(_reservePrice > 0, "Price set to zero");
        require(IERC721(_nftadd).ownerOf(_tokenId) == _msgSender(), "NFT: Not owner");
        require(!sellstatus[_tokenId], "NFT: Open sell found");

        if(_isnativeauciton){
            isnative[_tokenId] = true;
        }

        require(_startingTime < _closingTime, "Invalid start or end time");

        auctionDetails[_tokenId]= Auction({
                        beneficiary: _msgSender(),
                        highestBid: 0,
                        highestBidder: address(0x0),
                        startvalue: _reservePrice,
                        open: true,
                        isnative: _isnativeauciton,
                        start: _startingTime,
                        end: _closingTime
                    });

        IERC721(_nftadd).transferFrom(_msgSender(), address(this), _tokenId);

        sellstatus[_tokenId] = true;
        
        emit sell_auction_create(_tokenId, _msgSender(), 0, 0, auctionDetails[_tokenId].highestBid, _isnativeauciton);
        openauction[address(this)].ids.push(_tokenId);
        return true;
    }

    function bid(uint256 _tokenId, uint256 _price) public returns(bool) {

        require(!isnative[_tokenId],"is native auction");
        require(sellstatus[_tokenId],"token id not auction");
        require(_msgSender() != auctionDetails[_tokenId].beneficiary, "The owner cannot bid");
        require(!_msgSender().isContract(), "No script kiddies");
        require(auctionDetails[_tokenId].open, "No opened auction found");
        require(auctionDetails[_tokenId].startvalue < _price ,"is not more then startvalue");
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
        require(isnative[_tokenId],"no native auction");
        require(sellstatus[_tokenId],"token id not auction");
        require(_msgSender() != auctionDetails[_tokenId].beneficiary, "The owner cannot bid his own collectible");
        require(!_msgSender().isContract(), "No script kiddies");
        require(auctionDetails[_tokenId].open, "No opened auction found");
        require(auctionDetails[_tokenId].startvalue < msg.value,"is not more then startvalue");
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

        require(sellstatus[_tokenId],"token id not auction");

        require(auctionDetails[_tokenId].beneficiary == _msgSender(),"Only owner can finalize this collectibles ");
        require(auctionDetails[_tokenId].open, "There is no auction opened for this tokenId");
        require(block.timestamp >= auctionDetails[_tokenId].end, "Auction not yet ended.");

        address from = auctionDetails[_tokenId].beneficiary;
        address highestBidder = auctionDetails[_tokenId].highestBidder;

        // address _owner = IERC721(_nftadd).ownerOf(_tokenId);

        address tokencreator = IERC721(_nftadd).creatorOf(_tokenId);
        uint256 royalty4creator = (bid_).mul(royalty).div(10000);
        if(bid_ != 0 ){
            if(isnative[_tokenId]){
            uint256 amount4admin_ = (bid_).mul(nativecommision).div(10000);
            uint256 amount4owner_ = (bid_).sub(amount4admin_.add(royalty4creator));
            payable(from).transfer( amount4owner_);
            payable(owner()).transfer(amount4admin_);
            payable(tokencreator).transfer(royalty4creator);
            IERC721(_nftadd).transferFrom(address(this), highestBidder,_tokenId);
            emit onCommision(_tokenId, amount4admin_, royalty4creator, amount4owner_);
            }
            else{
                uint256 amount4admin = (bid_).mul(commision).div(10000);
                uint256 amount4owner = (bid_).sub(amount4admin.add(royalty4creator));

                IERC20(tokenadd).transfer(from, amount4owner);
                IERC20(tokenadd).transfer(owner(), amount4admin);
                IERC20(tokenadd).transfer(tokencreator, royalty4creator);
                IERC721(_nftadd).transferFrom(address(this), highestBidder,_tokenId);
                emit onCommision(_tokenId, amount4admin, royalty4creator, amount4owner);
            }
        }else{
            IERC721(_nftadd).transferFrom(address(this), _msgSender(),_tokenId);
        }

        auctionDetails[_tokenId].open = false;
        sellstatus[_tokenId] = false;
        require(findindexInAuction(_tokenId,address(this)),"is not update listof opensell");
        return true;
    }
    struct OpenOffer{
        uint256[] ids;
    }
    mapping(address=>OpenOffer)private openoffer; 

    function Openoffertokenid(address _a)public view returns(uint256[] memory){
        return openoffer[_a].ids;
    }
    // openoffer[address(this)].ids.push(tokenId);
    // require(findindexInOffer(_tokenId,address(this)),"is not update listof opensell");
    function findindexInOffer(uint256 _u,address _address)private returns(bool){
        uint256 l;
        for(uint i=0;i < openoffer[_address].ids.length;i++){
            if(openoffer[_address].ids[i]==_u){
                l = i;
            }
        }
        if(l == 0 && openoffer[_address].ids[l] ==_u){
            for(uint i = l; i < openoffer[_address].ids.length-1; i++){
                openoffer[_address].ids[i] = openoffer[_address].ids[i+1];      
            }
            openoffer[_address].ids.pop();
            return true;
        }
        else if(l != 0 && openoffer[_address].ids[l]==_u){
            for(uint i = l; i < openoffer[_address].ids.length-1; i++){
                openoffer[_address].ids[i] = openoffer[_address].ids[i+1];      
            }
            openoffer[_address].ids.pop();
            return true;
        }
        else{
            return false;
        }
    }

    // function openupdateArrayinAuction(uint index,address _address) private returns(bool){
    //     for(uint i = index; i < openauction[_address].ids.length-1; i++){
    //         openauction[_address].ids[i] = openauction[_address].ids[i+1];      
    //     }
    //     openauction[_address].ids.pop();
    //     return true;
    // }
    uint256 public Offerid;
    mapping(uint256=>bool)public statusoffer;
    mapping(uint256=>bool) public nativeoffer;
    function makeOffer(uint256 _tokenId, uint256 _endtime, uint256 _price) public returns(bool){
        require(_price > 0, "price set to zero");
        require(IERC721(_nftadd).ownerOf(_tokenId) != address(0x0), "NFT: Owner can't");
        require(IERC721(_nftadd).ownerOf(_tokenId) != _msgSender(), "NFT: Owner can't");
        require(!sellstatus[_tokenId],"tokenid is sell or auction");

        IERC20(tokenadd).transferFrom(_msgSender(), address(this), _price);

        Offerid = Offerid.add(1);
        offers[Offerid] = Offer({
            user: _msgSender(),
            price: _price,
            tokenid: _tokenId,
            offerEnd: _endtime,
            fulfilled: false,
            cancelled: false
        });
        statusoffer[Offerid] = true;
        emit onOffer(Offerid,_tokenId, _msgSender(), _price, IERC721(_nftadd).ownerOf(_tokenId), false, false);
        openoffer[address(this)].ids.push(_tokenId);
        return true;
    }

    function makeNativeOffer(uint256 _tokenId, uint256 _endtime) public payable returns(bool){
        require(msg.value > 0, "Price set to zero");

        require(IERC721(_nftadd).ownerOf(_tokenId) != address(0x0), "NFT: Owner can't");
        require(IERC721(_nftadd).ownerOf(_tokenId) != _msgSender(), "NFT: Owner can't");

        require(!sellstatus[_tokenId],"tokenid is sell or auction");

        Offerid = Offerid.add(1);
        offers[Offerid] = Offer({
            user: _msgSender(),
            price: msg.value,
            tokenid: _tokenId,
            offerEnd: _endtime,
            fulfilled: false,
            cancelled: false
        });
        statusoffer[Offerid] = true;
        nativeoffer[Offerid] = true;
        emit onOffer(Offerid,_tokenId, _msgSender(), msg.value, IERC721(_nftadd).ownerOf(_tokenId), false, false);
        openoffer[address(this)].ids.push(_tokenId);
        return true;
    }
    function sellfilloffer(uint256 offerid,uint256 _tokenId)public returns(bool){
        require(removeSell(_tokenId),"not the remove sell");
        return fillOffer(offerid);
    }
    function fillOffer(uint256 offerid) public returns (bool){
        require(statusoffer[offerid],"not availble offer");
        require(offers[offerid].user != msg.sender, "NFT:owner can't");

        require(block.timestamp <= offers[offerid].offerEnd, "NFT: offer ended");
        require(!offers[offerid].fulfilled, "fullfilled twice");
        require(!offers[offerid].cancelled, "offer cancelled");
        uint256 tokenid = offers[offerid].tokenid;
        address towner = IERC721(_nftadd).ownerOf(tokenid);
        require(towner == _msgSender(),"is not tokenid owner");

        uint256 royalty = uint256(IERC721(_nftadd).royaltyOf(tokenid));

        uint256 royalty4creator = (offers[offerid].price).mul(royalty).div(10000);

        if(nativeoffer[offerid]){
            uint256 amount4admin_ = (offers[offerid].price).mul(nativecommision).div(10000);
            uint256 amount4owner_ = (offers[offerid].price).sub(amount4admin_.add(royalty4creator));
            payable(towner).transfer(amount4owner_);
            payable(owner()).transfer(amount4admin_);
            payable(IERC721(_nftadd).creatorOf(tokenid)).transfer(royalty4creator);
        }else{
            uint256 amount4admin = (offers[offerid].price).mul(commision).div(10000);
            uint256 amount4owner = (offers[offerid].price).sub(amount4admin.add(royalty4creator));
            IERC20(tokenadd).transfer(towner, amount4owner);
            IERC20(tokenadd).transfer(owner(), amount4admin);
            IERC20(tokenadd).transfer(IERC721(_nftadd).creatorOf(tokenid), royalty4creator);
            }

        IERC721(_nftadd).transferFrom(address(this), offers[offerid].user,tokenid);
        offers[offerid].fulfilled = true;
        statusoffer[offerid] = false;
        emit OfferFilled(offerid, msg.sender);
        require(findindexInOffer(offers[offerid].tokenid,address(this)),"is not update listof opensell");
        return true;
    }

    function withdrawOffer(uint256 offerid) public returns(bool){
        require(statusoffer[offerid],"offer status is not on ");
        require(offers[offerid].user == msg.sender, "Only owner can");
        require(!offers[offerid].fulfilled , "offer fullfilled");
        require(!offers[offerid].cancelled , "offer cancel twice");

        if(nativeoffer[offerid]){
            payable(_msgSender()).transfer(offers[offerid].price);
        }else{
            require(!nativeoffer[offerid], "native offer");
            IERC20(tokenadd).transfer(_msgSender(), offers[offerid].price);
        }
        statusoffer[offerid] = false;
        emit OfferCancelled(offerid, _msgSender(),offers[offerid].price);
        require(findindexInOffer(offers[offerid].tokenid,address(this)),"is not update listof opensell");
        return true;
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
        require(sellstatus[_tokenId],"is not for auction");
        require(auctionDetails[_tokenId].open, "No opened auction found");
        require(auctionDetails[_tokenId].beneficiary == msg.sender,"Only owner can remove collectibles");

        if (auctionDetails[_tokenId].highestBid>0) {
            if(isnative[_tokenId]){
                payable(auctionDetails[_tokenId].highestBidder).transfer(auctionDetails[_tokenId].highestBid);
            }else{
                IERC20(tokenadd).transfer(auctionDetails[_tokenId].highestBidder, auctionDetails[_tokenId].highestBid);
            }
            emit refund(auctionDetails[_tokenId].highestBidder, auctionDetails[_tokenId].highestBid);
        }

        IERC721(_nftadd).transferFrom(address(this), _msgSender(), _tokenId);

        emit closed(_tokenId, _tokenId);
        sellstatus[_tokenId] = false;
        require(findindexInAuction(_tokenId,address(this)),"is not update listof opensell");
        return true;
    }

    function removeSell(uint256 _tokenId) public returns(bool){
        require(sellstatus[_tokenId],"not for sell");
        require(sellDetails[_tokenId].seller == msg.sender,"Only owner can remove this sell item");
        require(sellDetails[_tokenId].open, "The collectible is not for sale");

        IERC721(_nftadd).transferFrom(address(this), _msgSender(), _tokenId);
        sellstatus[_tokenId] = false;
        sellDetails[_tokenId].open = false;
        emit closed(_tokenId, _tokenId);
        require(findindex(_tokenId,address(this)),"is not update listof opensell");
        return true;
    }

    function auctionDetail(uint256 _tokenId) public view returns(Auction memory){
        return auctionDetails[_tokenId];
    }

    function sellDetail(uint256 _tokenId) public view returns(Sell memory){
        return sellDetails[_tokenId];
    }

    function changenftadd(address _nft) public returns(bool){
        _nftadd = _nft;
        return true;
    }

    function changetokenadd(address _token) public returns(bool){
        tokenadd = _token;
        return true;
    }
}