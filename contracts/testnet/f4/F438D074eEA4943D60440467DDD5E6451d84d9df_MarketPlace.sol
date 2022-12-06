/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
interface IERC20 {
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value)external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function burn(uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IERC721{
    function transferFrom(address from,address to,uint256 tokenId) external;
    function ownerOf(uint256 tokenId)external returns (address);
    function countryCitizenShip(string memory _countryname,address _user)external returns(bool);
    function blockCountryCitizenship(string memory _countryname,address _user,bool status)external returns(bool);
    function checkTokenIdstatus(uint256 _tokenid) external view returns(bool);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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

contract MarketPlace is Ownable{

    constructor(address _nft,address _Admin)
       {
           nft = _nft;
           Admin = _Admin;
    }
    
    address public nft;
    address public Admin;
    // ------------------ marketpalce
    mapping(uint256 => bool) public sellstatus;

    mapping(uint256 => Sell) public sellDetails;

    mapping(uint256 => Auction) public auctionDetails;

    struct Sell{
        address seller;
        address buyer;
        uint256 price;
        bool isnative;
        address tokenaddress;
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
        address tokenaddress;
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


    event OfferCancelled(uint256 offerid, address owner,uint256 returnamount);
    event OfferFilled(uint256 offerid, address newOwner);
    event sell_auction_create(uint256 tokenId, address beneficiary, uint256 startTime, uint256 endTime, uint256 reservePrice, bool isNative);
    event onBid(uint256 tokenid, address highestBidder, uint256 highestBid);
    event refund(address previousbidder, uint256 previoushighestbid);
    event onCommision(uint256 tokenid, uint256 adminCommision, uint256 creatorRoyalty, uint256 ownerAmount);
    event closed(uint256 tokenId, uint auctionId);

    uint8 public commision = 100;
    uint8 public nativecommision = 150;

    receive() external payable {}
    function Withdraw(address _address,uint256 _amount,address _contract) public returns (bool) {
        require(msg.sender == owner(),"is not owner !!!");
        if(_contract != address(this)){
            IERC20(_contract).transfer(_address,IERC20(_contract).balanceOf(address(this)));
            return true;
        }else{
            payable(_address).transfer(_amount);
            return true;
        }
    }
    function changeNft(address _nft) public onlyOwner returns(bool){
        nft = _nft;  // commition collector address
        return true;
    }
    function changeAdmin(address _Admin) public onlyOwner returns(bool){
        Admin = _Admin;  // commition collector address
        return true;
    }
    function updateCommission(uint8 _commissionRate,uint8 _nativecommision) public onlyOwner returns (bool){
        commision = _commissionRate;
        nativecommision = _nativecommision;
        return true;
    }
    function sell(uint256[] memory _tokenId, uint256[] memory _price, bool[] memory _isnative, address[] memory _tokenaddress) public returns(bool){
        
        require(_tokenId.length == _price.length && _isnative.length == _tokenaddress.length && _tokenaddress.length == _tokenId.length,"all array is not same");
        for(uint256 i=0;i<_tokenId.length;i++){
            
            require(_price[i] > 0, "set to 0");
            require(IERC721(nft).ownerOf(_tokenId[i])  == msg.sender, "3");
            require(!sellstatus[_tokenId[i]], "4");
            

            sellDetails[_tokenId[i]]= Sell({
                    seller: msg.sender,
                    buyer: address(0x0),
                    price:  _price[i],
                    isnative : _isnative[i],
                    tokenaddress : _tokenaddress[i]
            });

            sellstatus[_tokenId[i]] = true;
            IERC721(nft).transferFrom(msg.sender, address(this), _tokenId[i]);
            emit sell_auction_create(_tokenId[i], msg.sender, 0, 0, sellDetails[_tokenId[i]].price, _isnative[i]);
        }
        return true;
    }

    function buy(uint256 _tokenId) public returns(bool){
        
        uint256 _price = (sellDetails[_tokenId].price);
        require(msg.sender != sellDetails[_tokenId].seller, "7");
        require(sellstatus[_tokenId], "8");
        require(!sellDetails[_tokenId].isnative,"9");

        address tokenadd = sellDetails[_tokenId].tokenaddress;
        require(IERC20(tokenadd).balanceOf(msg.sender) >= _price,"10");

        uint256 _commision4admin = (_price * commision) / (10000);
        uint256 _amount4owner = _price - (_commision4admin);
        require(IERC20(tokenadd).transferFrom(msg.sender,address(this),_price),"11");
        require(IERC20(tokenadd).transfer(sellDetails[_tokenId].seller,_amount4owner),"12");
        require(IERC20(tokenadd).transfer(owner(),_commision4admin),"13");

        IERC721(nft).transferFrom(address(this), msg.sender, _tokenId);


        emit onCommision(_tokenId, _commision4admin, 0, _amount4owner);

        sellstatus[_tokenId] = false;
        sellDetails[_tokenId].buyer = msg.sender;
        return true;
    }

    function nativeBuy(uint256 _tokenId) public payable returns(bool){
        
        uint256 _price = sellDetails[_tokenId].price;
        require(sellstatus[_tokenId],"15");
        require(msg.sender != sellDetails[_tokenId].seller, "16");
        require(msg.value >= _price, "17");
        require(sellDetails[_tokenId].isnative, "18");

        uint256 _commision4admin = uint256((_price * nativecommision) / (10000));
        uint256 _amount4owner = uint256(_price - (uint256(_commision4admin)));


        payable(sellDetails[_tokenId].seller).transfer(_amount4owner);
        payable(owner()).transfer(_commision4admin);

        IERC721(nft).transferFrom(address(this), msg.sender, _tokenId);

        emit onCommision(_tokenId, _commision4admin, 0, _amount4owner);

        sellstatus[_tokenId] = false;
        sellDetails[_tokenId].isnative =  false;
        sellDetails[_tokenId].buyer = msg.sender;
        return true;
    }

    function createAuction_(uint256[] memory _tokenId, uint256[] memory _startingTime, uint256[] memory _closingTime, uint256[] memory _reservePrice, bool[] memory _isnativeauciton,address[] memory _tokenaddress) public returns(bool){
        
        require(_tokenId.length == _startingTime.length && _closingTime.length == _reservePrice.length && _startingTime.length == _tokenId.length,"all array is not same");
        for(uint256 i=0;i<_tokenId.length;i++){
            
            
            
            require(_reservePrice[i] > 0, "22");
            require(IERC721(nft).ownerOf(_tokenId[i]) == msg.sender, "23");
            require(!sellstatus[_tokenId[i]], "24");
            require(_startingTime[i] < _closingTime[i], "25");

            auctionDetails[_tokenId[i]]= Auction({
                            beneficiary: msg.sender,
                            highestBid: 0,
                            highestBidder: address(0x0),
                            startvalue: _reservePrice[i],
                            open: true,
                            isnative: _isnativeauciton[i],
                            start: _startingTime[i],
                            end: _closingTime[i],
                            tokenaddress : _tokenaddress[i]
                        });

            IERC721(nft).transferFrom(msg.sender, address(this), _tokenId[i]);
            sellstatus[_tokenId[i]] = true;
            emit sell_auction_create(_tokenId[i], msg.sender, _startingTime[i], _closingTime[i], _reservePrice[i], _isnativeauciton[i]);
        }

        return true;
    }

    function bid(uint256 _tokenId, uint256 _price) public returns(bool) {

        require(!auctionDetails[_tokenId].isnative,"27");
        require(sellstatus[_tokenId],"28");
        require(msg.sender != auctionDetails[_tokenId].beneficiary, "29");

        require(auctionDetails[_tokenId].open, "30");
        require(auctionDetails[_tokenId].startvalue < _price ,"31");

        address tokenadd = auctionDetails[_tokenId].tokenaddress;
        require(IERC20(tokenadd).balanceOf(msg.sender) >= _price,"32");

        require(
            block.timestamp >= auctionDetails[_tokenId].start,
            "33"
        );

        require(
            block.timestamp <= auctionDetails[_tokenId].end,
            "34"
        );

        require(
            _price > auctionDetails[_tokenId].highestBid,
            "35"
        );

        if (auctionDetails[_tokenId].highestBid > 0) {
            require(IERC20(tokenadd).transfer(auctionDetails[_tokenId].highestBidder,auctionDetails[_tokenId].highestBid),"36");
            emit refund(auctionDetails[_tokenId].highestBidder, auctionDetails[_tokenId].highestBid);
        }

        require(IERC20(tokenadd).transferFrom(msg.sender,address(this),_price),"37");

        auctionDetails[_tokenId].highestBidder = msg.sender;
        auctionDetails[_tokenId].highestBid = _price;

        emit onBid(_tokenId, auctionDetails[_tokenId].highestBidder, auctionDetails[_tokenId].highestBid);
        return true;
    }

    function nativeBid(uint256 _tokenId) public payable returns(bool) {
        
        require(auctionDetails[_tokenId].isnative,"39");
        require(sellstatus[_tokenId],"40");
        require(msg.sender != auctionDetails[_tokenId].beneficiary, "41");
        require(auctionDetails[_tokenId].open, "42");
        require(auctionDetails[_tokenId].startvalue < msg.value,"43");
        require(
            block.timestamp >= auctionDetails[_tokenId].start,
            "44."
        );

        require(
            block.timestamp <= auctionDetails[_tokenId].end,
            "45"
        );

        require(
            msg.value > auctionDetails[_tokenId].highestBid,
            "46"
        );

        if (auctionDetails[_tokenId].highestBid>0) {
            payable(auctionDetails[_tokenId].highestBidder).transfer(auctionDetails[_tokenId].highestBid);
            emit refund(auctionDetails[_tokenId].highestBidder, auctionDetails[_tokenId].highestBid);
        }

        auctionDetails[_tokenId].highestBidder = msg.sender;
        auctionDetails[_tokenId].highestBid = msg.value;

        emit onBid(_tokenId, auctionDetails[_tokenId].highestBidder, auctionDetails[_tokenId].highestBid);
        return true;
    }

    function auctionFinalize(uint256 _tokenId) public returns(bool){
        uint256 bid_ = auctionDetails[_tokenId].highestBid;
        require(sellstatus[_tokenId],"47");

        require(auctionDetails[_tokenId].beneficiary == msg.sender || Admin == msg.sender,"48");
        require(auctionDetails[_tokenId].open, "49");
        require(block.timestamp >= auctionDetails[_tokenId].end, "50");

        address from = auctionDetails[_tokenId].beneficiary;

        if(bid_ != 0 ){
            address highestBidder = auctionDetails[_tokenId].highestBidder;
            if(auctionDetails[_tokenId].isnative){
                uint256 amount4admin_ = (bid_ * nativecommision) / (10000);
                uint256 amount4owner_ = (bid_) - (amount4admin_);
                payable(from).transfer( amount4owner_);
                payable(owner()).transfer(amount4admin_);

                IERC721(nft).transferFrom(address(this), highestBidder, _tokenId);
                emit onCommision(_tokenId, amount4admin_, 0, amount4owner_);
            }
            else{
                uint256 amount4admin = (bid_ * commision) / (10000);
                uint256 amount4owner = (bid_) - (amount4admin);

                address tokenadd = auctionDetails[_tokenId].tokenaddress;

                require(IERC20(tokenadd).transfer(from,amount4owner),"51");
                require(IERC20(tokenadd).transfer(owner(),amount4admin),"52");

                IERC721(nft).transferFrom(address(this), highestBidder, _tokenId);

                emit onCommision(_tokenId, amount4admin, 0, amount4owner);
            }
        }else{

            IERC721(nft).transferFrom(address(this), msg.sender, _tokenId);
        }

        auctionDetails[_tokenId].open = false;
        sellstatus[_tokenId] = false;
        auctionDetails[_tokenId].isnative = false;
        return true;
    }

    struct Offer {
        address user;
        uint256 price;
        uint256 tokenid;
        uint256 offerEnd;
        bool fulfilled;
        bool cancelled;
        bool nativeoffer;
        address tokenaddres;
    }
    mapping (uint256 => Offer) public offers;
    uint256 public Offerid;
    mapping(uint256=>bool)public statusoffer;
    

    function makeOffer(uint256 _tokenId, uint256 _endtime, uint256 _price,address _tokenaddress,bool isnativeoffer) public payable returns(bool){
        
        require(_price > 0, "54");
        require(IERC721(nft).ownerOf(_tokenId) != address(0x0), "55");
        require(IERC721(nft).ownerOf(_tokenId) != msg.sender, "56");

        
        if(isnativeoffer){
            require(msg.value > 0,"85");
        }else{
            require(IERC20(_tokenaddress).transferFrom(msg.sender,address(this),_price),"57");
        }

        Offerid = Offerid + (1);
        offers[Offerid] = Offer({
            user: msg.sender,
            price: _price,
            tokenid: _tokenId,
            offerEnd: _endtime,
            fulfilled: false,
            cancelled: false,
            nativeoffer : isnativeoffer,
            tokenaddres : _tokenaddress
        });
        statusoffer[Offerid] = true;
        emit onOffer(Offerid,_tokenId, msg.sender, _price, IERC721(nft).ownerOf(_tokenId), false, false);

        return true;
    }

    function sellfilloffer(uint256 offerid,uint256 _tokenId)public returns(bool){
        require(removeSell(_tokenId),"62");
        return fillOffer(offerid);
    }

    function fillOffer(uint256 offerid) public returns (bool){
        
        require(statusoffer[offerid],"64");
        require(offers[offerid].user != msg.sender, "65");

        require(block.timestamp <= offers[offerid].offerEnd, "66");
        require(!offers[offerid].fulfilled, "67");
        require(!offers[offerid].cancelled, "68");
        uint256 tokenid = offers[offerid].tokenid;
        address towner = IERC721(nft).ownerOf(tokenid);
        require(towner == msg.sender,"69");


        if(offers[offerid].nativeoffer){
            uint256 amount4admin_ = (offers[offerid].price * nativecommision) / (10000);
            uint256 amount4owner_ = (offers[offerid].price) - (amount4admin_);
            payable(towner).transfer(amount4owner_);
            payable(owner()).transfer(amount4admin_);

        }else{
            uint256 amount4admin = (offers[offerid].price * commision) / (10000);
            uint256 amount4owner = (offers[offerid].price) - (amount4admin);
            address tokenadd = offers[offerid].tokenaddres;

            require(IERC20(tokenadd).transfer(towner,amount4owner),"70");
            require(IERC20(tokenadd).transfer(owner(),amount4admin),"71");

            }
        IERC721(nft).transferFrom(msg.sender, offers[offerid].user, tokenid);
        offers[offerid].fulfilled = true;
        statusoffer[offerid] = false;
        offers[offerid].nativeoffer = false;
        emit OfferFilled(offerid, msg.sender);

        return true;
    }

    function withdrawOffer(uint256 offerid) public returns(bool){
        require(statusoffer[offerid],"72");
        require(offers[offerid].user == msg.sender || Admin == msg.sender, "73");
        require(!offers[offerid].fulfilled , "74");
        require(!offers[offerid].cancelled , "75");

        if(offers[offerid].nativeoffer){
            payable(offers[offerid].user).transfer(offers[offerid].price);
        }else{
            address tokenadd = offers[offerid].tokenaddres;
            require(IERC20(tokenadd).transfer(offers[offerid].user,offers[offerid].price),"77");
        }
        statusoffer[offerid] = false;
        offers[offerid].cancelled = true;
        emit OfferCancelled(offerid, offers[offerid].user,offers[offerid].price);

        return true;
    }

    function removeAuction(uint256 _tokenId) external returns(bool success){
        require(sellstatus[_tokenId],"79");
        require(auctionDetails[_tokenId].open, "80");
        require(auctionDetails[_tokenId].beneficiary == msg.sender || Admin == msg.sender,"81");

        if (auctionDetails[_tokenId].highestBid>0) {
            if(auctionDetails[_tokenId].isnative){
                payable(auctionDetails[_tokenId].highestBidder).transfer(auctionDetails[_tokenId].highestBid);
            }else{
                address tokenadd = auctionDetails[_tokenId].tokenaddress;
                require(IERC20(tokenadd).transfer(auctionDetails[_tokenId].highestBidder, auctionDetails[_tokenId].highestBid),"82");
            }
            emit refund(auctionDetails[_tokenId].highestBidder, auctionDetails[_tokenId].highestBid);
        }

        IERC721(nft).transferFrom(address(this), auctionDetails[_tokenId].beneficiary, _tokenId);
        emit closed(_tokenId, _tokenId);
        auctionDetails[_tokenId].open = false;
        sellstatus[_tokenId] = false;
        auctionDetails[_tokenId].isnative = false;
        delete auctionDetails[_tokenId];
        return true;
    }

    function removeSell(uint256 _tokenId) public returns(bool){
        require(sellstatus[_tokenId],"83");
        require(sellDetails[_tokenId].seller == msg.sender || Admin == msg.sender,"84");
        IERC721(nft).transferFrom(address(this), sellDetails[_tokenId].seller, _tokenId);
        sellstatus[_tokenId] = false;
        sellDetails[_tokenId].isnative = false;
        delete sellDetails[_tokenId];
        emit closed(_tokenId, _tokenId);
        return true;
    }
}