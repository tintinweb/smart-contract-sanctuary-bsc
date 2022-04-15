/**
 *Submitted for verification at BscScan.com on 2022-04-14
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;


contract recommend{
    address public runner;
    address public owner; 

    uint8 public d1;
    uint8 public d2;


    struct user{
        address user;
        address recommender;
        address[] recommend;
        bool isValid;
    }

    mapping (address => user) database;

    mapping (address => uint256) sumget;
    mapping (address => uint256) sendairdrop;

    mapping (uint256 => address) addressdata;
    uint256 addressdatalength = 0;

    constructor(){
        owner = msg.sender;
    }

    function getdata(address _user) external view returns(address,address) {
        address recommender1 = database[_user].recommender;
        address recommender2 = database[recommender1].recommender;
        return (recommender1,recommender2);
    }

    function updata(address _user) external {
        if(!database[msg.sender].isValid)
        {
            database[msg.sender].user = msg.sender;
            database[msg.sender].recommender = _user;
            database[msg.sender].isValid = true;
            addressdata[addressdatalength] = msg.sender;
            addressdatalength+=1;
            if(!database[_user].isValid){
                database[_user].user = _user;
                database[_user].isValid = true;
                database[_user].recommender = address(0);
                database[_user].recommend.push(msg.sender);
                addressdata[addressdatalength] = _user;
                addressdatalength+=1;
            }else{
                database[_user].recommend.push(msg.sender);
            }
        }else{
            if (database[msg.sender].recommender == address(0)){
                if(database[msg.sender].recommend.length == 0){
                    database[msg.sender].recommender = _user;
                }else{
                    for(uint i = 0;i <database[msg.sender].recommend.length;i++ ){
                        require(_user == database[msg.sender].recommend[i], "_user can't is recommend");
                    }
                    database[msg.sender].recommender = _user;
                }
            }
        }
    }

    function getnext(address _user) external view returns(address[] memory){
        return database[_user].recommend;
    }

    function getnextnext(address _user) external view returns(address[] memory) {
        return database[_user].recommend;
    }

    function getsumget(address _user) external view returns(uint256) {
        return sumget[_user];
    }

    function setsumget(address _user,uint256 _sumnum) external{
        require(runner == msg.sender, "Only owner can request");
        sumget[_user] += _sumnum;
    }

    function getsendairdrop(address _user) external view returns(uint256) {
        return sendairdrop[_user];
    }

    function setsendairdrop(address _user,uint256 _sumnum) external{
        require(runner == msg.sender, "Only owner can request");
        sendairdrop[_user] += _sumnum;
    }

    function setrunner(address _runner) external {
        require(owner == msg.sender, "Only runner can request");
        runner = _runner;
    }

    function getaddressdata(uint256 _index) external view returns(address){
        return addressdata[_index];
    }

}