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