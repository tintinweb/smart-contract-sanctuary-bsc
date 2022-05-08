/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.17 <8.10.0;

contract AsixV3Presale{

    User[] users;
    address[] whitelist;
    Activity[] activities;
    Pending[] pendingTokens;

    struct User{
        address _address;
        string code_name;
    }

    struct Activity{
        address _address;
        uint256 _amount;
        uint256 _priceOfToken;
        uint256 _time;
        uint256 _indexOfPeriod;
        string _status;
    }

    struct Pending{
        address _address;
        uint256 _amount;
    }

    /*====================================================================================
                                User Methods
    ====================================================================================*/ 
    function addUser(address _address, string calldata _name) external returns(bool){
        for (uint256 index = 0; index < users.length; index++) {
            if (msg.sender == users[index]._address) {
                users[index] = User(_address, _name);
                return true;
            }  
        }
        users.push(User(_address, _name));
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

    /*====================================================================================
                                Whitelist Methods
    ====================================================================================*/ 
      function addToWhitelist(address _address) external returns(bool){
        whitelist.push(_address);
        return true;
    }
    
    function getWhitelisted() public view returns(address[] memory){
        address[] memory _whitelist = new address[] (whitelist.length);
        for(uint256 i = 0; i < whitelist.length; i++){
            _whitelist[i] = whitelist[i];
        }
        return _whitelist;
    }

    function removeFromWhitelist(address _address) external returns(bool){
        for (uint256 index = 0; index < whitelist.length; index++) {
            if (whitelist[index] == _address) {
                delete whitelist[index];
                return true;
            }
        }
        return false;
    }
    function checkWhitelist(address _address) external  view returns(bool){
        for(uint256 i = 0; i < whitelist.length; i++){
            if(_address == whitelist[i]) return true;
        }
        return false;
    } 
    /*====================================================================================
                                Activity Methods
    ====================================================================================*/ 
    function addActivity(address _address, uint256 _amount, uint256 _price, uint256 _time, uint256 _id, string memory _status) external returns(bool){
        activities.push(Activity(_address, _amount, _price, _time, _id, _status));
        return true;
    }

    function getActivities() public view returns(Activity[] memory){
        uint256 _length = activities.length;
        Activity[] memory _activities = new Activity[](_length); 
        for(uint256 i = 0; i < _length; i++){
            _activities[i] = activities[i];
        }
        return _activities;
    }

    function getPendingTokens() public view returns(Pending[] memory){
        uint256 _length = pendingTokens.length;
        Pending[] memory _pending  = new Pending[](_length);
        for(uint256 i = 0; i < _length; i++){
            _pending[i] = pendingTokens[i];
        }
        return _pending;
    }

    function deletePending(address _spender) external returns(bool){
        uint256 length = pendingTokens.length;
        for (uint256 index = 0; index < length; index++) {
            if (_spender == pendingTokens[index]._address) {
                delete pendingTokens[index];
            }  
        }
        return true;
    }

    function updatePending(address _spender, uint256 _amount) external returns(bool){
        uint256 length = pendingTokens.length;
        for (uint256 index = 0; index < length; index++) {
            if (_spender == pendingTokens[index]._address) {
                pendingTokens[index]._amount += _amount;
                return true;
            } 
        }
        Pending memory _pending = Pending(_spender, _amount);
        pendingTokens.push(_pending);
        return true;
    }

}