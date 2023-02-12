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