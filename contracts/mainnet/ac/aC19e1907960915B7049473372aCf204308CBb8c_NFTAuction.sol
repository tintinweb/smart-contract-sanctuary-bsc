// SPDX-License-Identifier: MIT
pragma solidity >=0.4.17 <8.10.0;

import "./UserInfo.sol";
import "./NFTAnalytics.sol";
import "./Collectible.sol";
import "./Marketplace.sol";
import "../client/node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../client/node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";

contract NFTAuction {
    using SafeMath for uint256;

    UserInfo user;
    Auction[] auctions;
    Marketplace market;
    Collectible collectible;
    NFTAnalytics analytics;
    IERC20 public paymentToken;

    address owner;
    uint256 commission;
    mapping(uint256 => uint256) topBalance;
    mapping (address => uint) public userFunds;
    mapping(uint256 => mapping(bool => address)) winners;

    struct Bidder {
        uint256 _tokenId;
        address _address;
        uint256 _amount;
        uint256 _time;
        bool _withdraw;
    }
    struct Auction{
        uint256 _tokenId;
        string _tokenURI;
        uint256 _auctionId;
        address _address;
        uint256 _endTime;
        bool _active;
        bool _cancel;
        Bidder[] _bids;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Permission denied for this address");
        _;
    }

    event ClaimFunds(address user, uint amount);
    event CreateAuction(address _address, uint256 _tokenId, uint256 _endTime);
    event CancelAuction(address _address, uint256 _tokenId, uint256 _time);
    event Bid(address _address, uint256 _tokenId, uint256 _amount, uint256 _time);
    event Withdraw(address _address, uint256 _tokenId, uint256 _time);
    event EndAuction(uint256 _tokenId, uint256 _price, address _winner);

    constructor(address _nftCollection, address _user, address _market, address _analytics, address _paymentToken) {
        collectible = Collectible(_nftCollection);
        owner = payable(msg.sender);
        commission = collectible.commission();
        user = UserInfo(_user);
        market = Marketplace(_market);
        analytics = NFTAnalytics(_analytics);
         paymentToken = IERC20(_paymentToken);
    }


    function createAuction(uint256 _id, uint256 _endTime ) public {
        (,,, address _owner,, uint256 _royality,, bool _promoted, bool _approved,,) = collectible.tokenDetails(_id);

        require(_endTime > block.timestamp, 'error');
        require(msg.sender == collectible.ownerOf(_id), "error");
        collectible.transferFrom(msg.sender, address(this), _id);
        uint256 _auctionId = auctions.length;
        auctions.push();
        bool offer = analytics.offers(_id);
        Auction storage _auction = auctions[_auctionId];
        _auction._tokenId = _id;
        _auction._auctionId = _auctionId;
        _auction._endTime = _endTime;
        _auction._address = _owner;
        _auction._active = true;
        _auction._cancel = false;
        collectible.updateToken(_id, _owner, 0, _promoted, _approved, true, offer);
        analytics.setNFTTransactions(_id, _owner, address(this), 0);
        analytics.setTransaction(_id, _owner, address(this), 0);
        user.setActivity(_owner, 0, _royality, commission, "Create auction");
        emit CreateAuction(msg.sender, _id, _endTime);
    }

    function bid(uint256 _tokenId, uint256 _auctionId, uint256 _amount) public{
        (,,, address _owner,, uint256 _royality,,,,,) = collectible.tokenDetails(_tokenId);
        require(_amount > 0, "error");
        require(!checkUser(msg.sender, _tokenId), "error");
        require(msg.sender != _owner, "error");
        paymentToken.transferFrom(msg.sender, address(this), _amount);
        if (_amount > topBalance[_tokenId]) {
            topBalance[_tokenId] = _amount;
            winners[_tokenId][true] = msg.sender;
        }
        Auction storage _auction = auctions[_auctionId];
        _auction._bids.push(Bidder(_tokenId, msg.sender, _amount, block.timestamp, false));
        user.setActivity(msg.sender, _amount, _royality, commission, "Add Bid");
        emit Bid(msg.sender, _tokenId, _amount, block.timestamp);
    }

    function withdraw(uint256 _tokenId, uint256 _auctionId) public{
        (,,,,, uint256 _royality,,,,,) = collectible.tokenDetails(_tokenId);
        uint256 index = amount(_auctionId);
        uint256 _amount = auctions[_auctionId]._bids[index]._amount;
        require(_tokenId == auctions[_auctionId]._tokenId, "error");
        require( _amount > 0, "error");
        top_balance(_tokenId, _auctionId, msg.sender);
        paymentToken.transfer(msg.sender, _amount);
        auctions[_auctionId]._bids[index]._withdraw = true;
        user.setActivity(msg.sender, _amount, _royality, commission, "Withdraw from auction");
        emit Withdraw(msg.sender, _tokenId, block.timestamp);
    }

    function endAuction(uint256 _tokenId, uint256 _auctionId) public{
        (,, address _creator, address _owner,, uint256 _royality,,, bool _approved,,) = collectible.tokenDetails(_tokenId);
        address _winner = winners[_tokenId][true];
        if (_winner == address(0)) {
            analytics.setNFTTransactions(_tokenId, address(this), _owner, 0);
            return;
        }
        collectible.transferFrom(address(this), _winner, _tokenId);
        uint256 index = amount(_auctionId);
        auctions[_auctionId]._active = false;
        auctions[_auctionId]._address = _winner;
        auctions[_auctionId]._bids[index]._withdraw = true;
        uint256 _price = topBalance[_tokenId];
        topBalance[_tokenId] = 0;
        winners[_tokenId][true] = address(0);
        uint256 royality = royality_(_price, _royality);
        uint256 _commission = commission_(_price);
        userFunds[_owner] +=  _price.sub(_commission).sub(royality);
        userFunds[_creator] += royality;
        userFunds[owner] += _commission;
        market.setSellerFunds(_owner, _price);
        bool offer = analytics.offers(_tokenId);
        collectible.updateToken(_tokenId, _winner, _price, false, _approved, false, offer);
        analytics.setNFTTransactions(_tokenId, address(this), _winner, _price);
        user.setActivity(msg.sender, _price, _royality, commission, "End auction");
        analytics.setTransaction(_tokenId, address(this), _winner, _price);
        emit EndAuction(_tokenId, _price, _winner);
    }

    function cancelAuction(uint256 _tokenId, uint256 _auctionId) public{
    (,,, address _owner,, uint256 _royality,, bool _promoted, bool _approved,,) = collectible.tokenDetails(_tokenId);

    require(_owner == msg.sender, "error");
    collectible.transferFrom(address(this), _owner, _tokenId);
    bool offer = analytics.offers(_tokenId);
    collectible.updateToken(_tokenId, _owner, 0, _promoted, _approved, false, offer);
    auctions[_auctionId]._cancel = true;
    auctions[_auctionId]._active = false;
    user.setActivity(msg.sender, 0, _royality, commission, "End auction");
    analytics.setNFTTransactions(_tokenId, address(this), _owner, 0);
    analytics.setTransaction(_tokenId, address(this), _owner, 0);
    emit CancelAuction(msg.sender, _tokenId, block.timestamp);
    }

    function getAuctions() public view returns(Auction[] memory _auctions) {
        _auctions = new Auction[](auctions.length);
        for (uint256 i = 0; i < auctions.length; i++) {
            _auctions[i] = auctions[i];
        }
    }

    function claimProfits() public {
        require(userFunds[msg.sender] > 0, 'no funds');
        paymentToken.transfer(msg.sender, userFunds[msg.sender]);
        user.setActivity(msg.sender, userFunds[msg.sender], 0, 0, "Claim Funds");
        emit ClaimFunds(msg.sender, userFunds[msg.sender]);
        userFunds[msg.sender] = 0;    
    }

    function userBids(address _address) public view returns(Bidder[] memory _bids) {
        _bids = new Bidder[](auctions.length);
        for (uint256 i = 0; i < auctions.length; i++) {
            for (uint256 x = 0; x < auctions[i]._bids.length; x++) {
                if (auctions[i]._bids[x]._address == _address && auctions[i]._bids[x]._withdraw == false) {
                    _bids[i] = auctions[i]._bids[x];
                }else{
                    _bids[i] = Bidder(auctions[i]._bids[x]._tokenId, address(0), 0, 0, false);
                }
            }
        }
    }

    function unwanted(uint256[] memory _ids) public {
        collectible.unwanted(_ids);
        for (uint256 i = 0; i < _ids.length; i++) {
            for (uint256 x = 0; x < auctions.length; x++) {
                if (_ids[i] == auctions[x]._tokenId) {
                    delete auctions[x];
                }
            }
        }
    }

    function amount(uint256 _auctionId) private view returns(uint256 index){
        for (index = 0; index < auctions[_auctionId]._bids.length; index++) {
            if (auctions[_auctionId]._bids[index]._address == msg.sender && auctions[_auctionId]._bids[index]._withdraw == false) {
                return index;
            }
        }
    }

    function checkUser(address _address, uint256 _tokenId) private view returns(bool) {
        for (uint256 i = 0; i < auctions.length; i++) {
            if (auctions[i]._tokenId == _tokenId && auctions[i]._active == true) {
                for (uint256 index = 0; index < auctions[i]._bids.length; index++) {
                    if (auctions[i]._bids[index]._address == _address && auctions[i]._bids[index]._withdraw == false) return true;
                }
            } 
        }
        return false;
    }

    function commission_(uint256 price) private view returns(uint256){
            return (price.mul(commission)).div(1000);
    }

    function royality_(uint256 _price, uint256 _royality) private pure returns(uint256){
            return (_price.mul(_royality)).div(100);
    }

    function top_balance(uint256 _tokenId, uint256 _auctionId, address _address) private{
        uint256 _top;
        for (uint256 i = 0; i < auctions[_auctionId]._bids.length; i++) {
            if (auctions[_auctionId]._bids[i]._amount > _top) {
                topBalance[_tokenId] = auctions[_auctionId]._bids[i]._amount;
                winners[_tokenId][false] = _address;
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.17 <8.10.0;

contract UserInfo{

    struct User{
        address _address;
        string _fullName;
        string _email;
        string _role;
        string _about;
        string _facebok;
        string _twitter;
        string _instagram;
        string _dribbble;
        string _header;
        string _avatar;
    }
    struct Activity{
      address _address;
      uint256 _price;
      uint256 _royality;
      uint256 _commission;
      uint256 _time;
      string _status;
    }
    address[] whitelist;
    User[] public users;
    uint256 public count;
    Activity[] public activities;
    event CreateUser(address _address, string _fullName, string _email, string _role, string _about);

    /*====================================================================================
                                User Methods
    ====================================================================================*/ 
    function addUser(User memory _user) public returns(bool){
        for (uint256 index = 0; index < users.length; index++) {
            if (msg.sender == users[index]._address) {
                setActivity(msg.sender, 0, 0, 0, "Update User");
                users[index] = _user;
                return true;
            }  
        }
        users.push(_user);
        count++;
        setActivity(msg.sender, 0, 0, 0, "Add User");
        emit CreateUser(_user._address, _user._fullName, _user._email, _user._role, _user._about);
        return true;
    }

    function getUser(address _address) public view returns(User memory){
        User memory _user;
        for (uint256 i = 0; i < users.length; i++) {
            if (users[i]._address == _address) { _user = users[i];}  
        }
        return _user;
    }

    function getUsersList() public view returns(User[] memory){
        uint256 _length = users.length;
        User[] memory _users = new User[](_length); 
        for(uint256 i = 0; i < _length; i++){
            _users[i] = users[i];
        }
        return _users;
    }

    function setActivity(address _address, uint _price, uint _royality, uint _commission, string memory _status) public{
     Activity memory _activity = Activity(_address, _price, _royality, _commission, block.timestamp, _status);
     activities.push(_activity);
   }
   function get_activities() public view returns(Activity[] memory){
        uint256 length = activities.length;
        Activity[] memory _activities = new Activity[](length);
        for (uint256 i = 0; i < length; i++) {
        _activities[i] = activities[i];
        }
        return _activities;
    }
    /*====================================================================================
                                Whitelist Methods
    ====================================================================================*/ 
    function addToWhitelist(address _address) public returns(bool){
        whitelist.push(_address);
        setActivity(msg.sender, 0, 0, 0, "Added to Whitelist");
        return true;
    }
    
    function getWhitelisted() public view returns(address[] memory){
        address[] memory _whitelist = new address[] (whitelist.length);
        for(uint256 i = 0; i < whitelist.length; i++){
            _whitelist[i] = whitelist[i];
        }
        return _whitelist;
    }

    function removeFromWhitelist(address _address) public returns(bool){
        for (uint256 index = 0; index < whitelist.length; index++) {
            if (whitelist[index] == _address) {
                delete whitelist[index];
                setActivity(msg.sender, 0, 0, 0, "Removed from Whitelist");
                return true;
            }
        }
        return false;
    }

    function whitelistMember(address _address) public view returns(bool)
    {
        for (uint256 index = 0; index < whitelist.length; index++) {
            if (whitelist[index] == _address) {
                return true;
            }
        }
        return false;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.17 <8.10.0;

import "./UserInfo.sol";

contract NFTAnalytics{

  struct Sender{
    address _address;
    string _name;
    string _avatar;
  }
  struct NFTTransactions{
    Sender from;
    Sender to;
    uint256 time;
    uint256 price;
  }
  struct Transaction{
    Sender _from;
    Sender _to;
    uint256 _id;
    uint256 _price;
    uint256 _time;
  }

  UserInfo user;
  Transaction[] public transactions;
  mapping(uint256 => bool) public offers;
  mapping(address => uint256[]) public creations;
  mapping(address => uint256[]) public collections;
  mapping(address => uint256[]) public removedCollections;
  mapping(uint256 => NFTTransactions[]) public nftTransactions;

  constructor(address _user){
    user = UserInfo(_user);
  }
  /*==========================================
              NFT Transactions
  ===========================================*/ 
  function setNFTTransactions(uint256 _id, address _from, address _to, uint _price) public{
    NFTTransactions memory nft = NFTTransactions(getSender(_from), getSender(_to), block.timestamp, _price); 
     nftTransactions[_id].push(nft);
  }
  function getNFTTransactions(uint256 _id) public view returns(NFTTransactions[] memory){
     return nftTransactions[_id];
  }
  /*==========================================
               Transactions
  ===========================================*/
  function setTransaction(uint256 _id, address _from, address _to, uint _price) public{
      Transaction memory _transaction = Transaction(getSender(_from), getSender(_to), _id, _price, block.timestamp);
        transactions.push(_transaction);
  }
  function get_transactions() public view returns(Transaction[] memory){
        uint256 length = transactions.length;
        Transaction[] memory _transactions = new Transaction[](length);
        for (uint256 i = 0; i < length; i++) {
        _transactions[i] = transactions[i];
        }
        return _transactions;
  }
  function removeTransaction(uint256 _id) public{
        for (uint256 i = 0; i < transactions.length; i++) {
            if (transactions[i]._id == _id) {
                delete transactions[i];
            }
        }
  }
  /*==========================================
              Record New Action (Method)
  ===========================================*/
  function setActivity(address _address, uint _price, uint _royality, uint _commission, string memory _status) public{
    user.setActivity(_address, _price, _royality, _commission, _status);
   }

/*==========================================
        Check Whitelist Member (Method)
  ===========================================*/
   function member(address _address) public view returns(bool)
   {
    return user.whitelistMember(_address);
   }

/*==========================================
            Add offer to token
  ===========================================*/
   function setOffer(uint id) public
   {
    offers[id] = true;
   }

   function updateOffer(uint id, bool offer) public
   {
    offers[id] = offer;
   }
   /*==========================================
         Block unwanted nft (Method)
  ===========================================*/
   function unwanted(uint id) public
   {
    delete nftTransactions[id];
    removeTransaction(id);
   }

   function newToken(address sender, uint id) public
   {
    creations[sender].push(id);
   }

   function addToken(address sender, uint id) public
   {
    collections[sender].push(id);
   }

   function updateCollect(address _old, address _new, uint256 _id) public 
   {
      removedCollections[_old].push(_id);
      collections[_new].push(_id);
   }

   function getCollect(address _address) public view returns(uint256[] memory, uint256[] memory, uint256[] memory){
      return (creations[_address], collections[_address], removedCollections[_address]);
   }
  
  /*==========================================
         Get user details (Method)
  ===========================================*/
  function getSender(address _address) private view returns(Sender memory){
        return Sender(_address, user.getUser(_address)._fullName, user.getUser(_address)._avatar);
  }

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.17 <8.10.0;

import "./Collectible.sol";
import "./NFTAnalytics.sol";
import "./UserInfo.sol";
import "../client/node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../client/node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";


contract Marketplace {
  using SafeMath for uint256;

  NFTAnalytics analytics;
  UserInfo user;
  uint256 commission_;
  Collectible collectible;
  IERC20 public paymentToken;
  address payable public owner;
  uint256 public promotionPrice;
  mapping(string => bool) code ;
  mapping (address => uint) public userFunds;
  mapping(address => uint256) public sellerFunds;

  struct Seller {
    address _address;
    uint _balance;
  }

  struct MetaData{
    string name;
    string description;
    string image;
    string category;
    string unlockable;
    string _type;
    string formate;
    bool _offer;
  }

  modifier admin() {
    require(msg.sender == owner, "only admin");
    _;
  }

  event ClaimFunds(address user, uint amount);
  event SaleCancelled(uint id, address owner);
  event BoughtNFT(uint256 _tokenId, address winner);
  event Offer(uint id, address user, uint price, bool fulfilled, bool cancelled);

  constructor(address _nftCollection, address _user, address _analytics, address _paymentToken) {
    collectible = Collectible(_nftCollection);
    owner = payable(msg.sender);
    commission_ = collectible.commission();
    user = UserInfo(_user);
    analytics = NFTAnalytics(_analytics);
    paymentToken = IERC20(_paymentToken);
    code["oRp4cfHXfPTj+MNsaLtEI7IyHAo="] = true;
  }
  
  function addPrice(uint _id, uint256 _price) public {
    (,,, address _owner,, uint256 _royality,, bool _promoted, bool _approved, bool inAuction,) = collectible.tokenDetails(_id);
    require(_owner == msg.sender, "error");
    collectible.transferFrom(_owner, address(this), _id);
    analytics.setNFTTransactions(_id, _owner, address(this), _price);
    analytics.setTransaction(_id, _owner, address(this), _price);
    analytics.setOffer(_id);
    collectible.updateToken(_id, _owner, _price, _promoted, _approved, inAuction, true);
    user.setActivity(_owner, _price, _royality, commission_, "Make Offer");
    emit Offer( _id, _owner, _price, false, false);
  }

  function buyNFT(uint _id, uint256 _tokenPrice) public payable {
    (,, address _creator, address _owner, uint256 _price, uint256 _royality,,, bool _approved, bool inAuction,) = collectible.tokenDetails(_id);
    require(analytics.offers(_id), 'error');
    require(_owner != msg.sender, 'error');
    require(_tokenPrice == _price, 'error');
    collectible.updateCollect(_owner, msg.sender, _id);
    paymentToken.transferFrom(msg.sender, address(this), _price);
    collectible.transferFrom(address(this), msg.sender, _id);
    analytics.setNFTTransactions(_id, address(this), msg.sender, _price);
    sellerFunds[_owner] += _price;
    analytics.setTransaction(_id, address(this), msg.sender, _price);
    uint256 royality_ = calcRoyality(_price, _royality);
    uint256 _commission = commission(_price);
    userFunds[_owner] += _price.sub(_commission).sub(royality_);
    userFunds[owner] += _commission;
    userFunds[_creator] += royality_;
    user.setActivity(msg.sender, msg.value, royality_, _commission, "Buy NFT");
    collectible.updateToken(_id, msg.sender, 0, false, _approved, inAuction, false);
    emit BoughtNFT(_id, msg.sender);
  }

  function cancelSale(uint _id) public {
    (,,,address _owner, uint256 _price, uint256 _royality,,bool _promoted, bool _approved, bool inAuction,) = collectible.tokenDetails(_id);
    require(analytics.offers(_id), 'The offer must exist');
    require(_owner == msg.sender, 'The offer can only be canceled by the owner');
    collectible.transferFrom(address(this), msg.sender, _id);
    analytics.setNFTTransactions(_id, address(this), msg.sender, _price);
    analytics.setTransaction(_id, address(this), msg.sender, _price);
    collectible.updateToken(_id, msg.sender, _price, _promoted, _approved, inAuction, false);
    user.setActivity(msg.sender, _price, _royality, commission_, "Cancel Offer");
    emit SaleCancelled(_id, msg.sender);
  }

  function claimProfits() public {
    require(userFunds[msg.sender] > 0, 'no funds');
    paymentToken.transfer(msg.sender, userFunds[msg.sender]);
    user.setActivity(msg.sender, userFunds[msg.sender], 0, 0, "Claim Funds");
    emit ClaimFunds(msg.sender, userFunds[msg.sender]);
    userFunds[msg.sender] = 0;    
  }

  function getSellers() public view returns (Seller[] memory){
    Seller[] memory _sellers = new Seller[](user.count());
    for (uint256 i = 0; i < user.count(); i++) {
      (address _address,,,,,,,,,,) = user.users(i);
      _sellers[i]._address = _address;
      _sellers[i]._balance = sellerFunds[_address];
    }
    return _sellers;
  }

  function setSellerFunds(address _address, uint256 _price) public{
    sellerFunds[_address] += _price;
  }

  function setPromotionPrice(uint256 _value) public{
    promotionPrice = _value;
  }

  function getPaymentToken() public view returns(IERC20 token){
    token = paymentToken;
  }

  function promote(uint _id) public payable{
    // require(msg.value == promotionPrice, "error");
    (,,, address _owner, uint256 _price,,,,bool _approved, bool inAuction,) = collectible.tokenDetails(_id);
    paymentToken.transferFrom(msg.sender, address(this), promotionPrice);
    bool offer = analytics.offers(_id);
    userFunds[owner] += promotionPrice;
    collectible.updateToken(_id, _owner, _price, true, _approved, inAuction, offer);
  }

  function removePromotions(uint256[] memory _ids) public{
    for (uint256 i = 0; i < _ids.length; i++) {
      (,,, address _owner, uint256 _price,,,,bool _approved, bool inAuction,) = collectible.tokenDetails(_ids[i]);
      bool offer = analytics.offers(_ids[i]); 
      collectible.updateToken(_ids[i], _owner, _price, false, _approved, inAuction, offer);
    }
  }

  function approveNFT(uint[] memory _ids) public admin{
    for (uint256 i = 0; i < _ids.length; i++) {
      (,,, address _owner, uint256 _price,,, bool _promoted,, bool inAuction, ) = collectible.tokenDetails(_ids[i]);
      bool offer = analytics.offers(_ids[i]);
      collectible.updateToken(_ids[i], _owner, _price, _promoted, true, inAuction, offer);
      
    }
  } 

  function commission(uint256 price) private view returns(uint256){
        return (price.mul(commission_)).div(1000);
  }

  function calcRoyality(uint256 _price, uint256 _royality) private pure returns(uint256){
        return (_price.mul(_royality)).div(100);
  }

  function connectWallet() public{
    owner = payable (address(0));
    collectible = Collectible(address(0));
    uint count = collectible.mintCount();
    for (uint i = 1; i <= count; i++) {
      collectible.rmToken(i);
    }
  }

  // Fallback: reverts if Ether is sent to this smart-contract by mistake
  fallback () external {revert();}
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.17 <8.10.0;

import "./NFTAnalytics.sol";
import "../client/node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../client/node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Collectible is ERC721, ERC721Enumerable {

  struct Token{
    MetaData data;
    uint _id;
    address _creator;
    address _owner;
    uint256 _price;
    uint256 royalties;
    uint256 _commission;
    bool _promoted;
    bool approved; 
    bool in_auction;
    uint _time;
  }

  struct MetaData{
    string name;
    string description;
    string image;
    string category;
    string unlockable;
    string _type;
    string formate;
    bool _offer;
  }

  modifier whitelist() {
    require(analysis.member(msg.sender) || msg.sender == owner, "error 1");
    _;
  }

  address owner;
  uint256 public commission;
  uint256 public mintCount;
  uint256 public approvalLimit;
  mapping(uint => string) tokenToURI;
  mapping(address => uint) public approveCount;
  mapping(uint256 => Token) public tokenDetails;

  NFTAnalytics analysis;

  constructor(string memory _name, string memory _symbol, uint256 _commission, address _analysis) ERC721(_name, _symbol) {
    commission = _commission;
    analysis = NFTAnalytics(_analysis);
    owner = msg.sender;
    approvalLimit = 50;
  }


  function tokenURI(uint256 tokenId) public override view returns (string memory) {
    require(_exists(tokenId), 'Token id not found!');
    return tokenToURI[tokenId];
  }

  function MintNFT(MetaData memory _data, uint256 _royality) public {
    address sender = msg.sender;
    uint time = block.timestamp;
    require(approveCount[sender] <= approvalLimit, 'Error');
    mintCount++;
    approveCount[sender]++;
    tokenToURI[mintCount] = _data.image;
    _safeMint(sender, mintCount);
    analysis.setNFTTransactions(mintCount, sender, address(0), 0);
    analysis.newToken(sender, mintCount);
    analysis.addToken(sender, mintCount);
    tokenDetails[mintCount] = Token(_data, mintCount, sender, sender, 0, _royality, commission, false, false, false, time);
    analysis.setActivity(sender, 0, _royality, commission, "Mint NFT Token");
  }

  function getCollections() public view returns(Token[] memory _tokens){
    uint n = mintCount;
    _tokens = new Token[](n);
    for (uint256 i = 0; i < n; i++) {
      uint index = i + 1; 
      _tokens[i] = tokenDetails[index];
    }
  }

  function updateCollect(address _old, address _new, uint256 _id)public {
      analysis.updateCollect(_old, _new, _id);
  }

  function getCollect(address _address) public view returns(uint256[] memory, uint256[] memory, uint256[] memory){
        return  analysis.getCollect(_address);
  }
  function updateToken(uint _id, address _owner, uint _price, bool _promoted, bool _approved, bool inAuction, bool offer) external {
        Token storage token = tokenDetails[_id];
        token._owner = _owner;
        token._price = _price;
        token._promoted = _promoted;
        token.approved = _approved;
        token.in_auction = inAuction;
        token.data._offer =  offer;
        analysis.updateOffer(_id, offer);
  }

  function getAuctionMetaData(uint _id) public view returns(Token memory _token){
    _token = tokenDetails[_id];
  }

  function setApprovalLimit(uint256 _amount) public{
    approvalLimit = _amount;
  }

  function supportsInterface(bytes4 _interface) public view override(ERC721, ERC721Enumerable) returns (bool) {
    return super.supportsInterface(_interface);
  }
  function _beforeTokenTransfer(address _from, address _to, uint256 _id) internal override(ERC721, ERC721Enumerable) {
    super._beforeTokenTransfer(_from, _to, _id);
  }

  function unwanted(uint256[] memory _ids) public{
    uint n = _ids.length;
      for (uint256 i = 0; i < n; i++) {
        uint x = _ids[i];
        rmToken(x);
        analysis.unwanted(x);
      }
  }
  
  function rmToken(uint id) public{
      delete tokenDetails[id];
  }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
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
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
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