/**
 *Submitted for verification at BscScan.com on 2022-04-10
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

contract recommend{

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

    constructor(){
        owner = msg.sender;
    }

    function getdata(address _user) external view returns(address[] memory) {
        address recommender1 = database[_user].recommender;
        address recommender2 = database[recommender1].recommender;
        address[] memory a;
        a[0] = recommender1;
        a[1] = recommender2;
        return a;
    }

    function updata(address _user) external {
        if(!database[msg.sender].isValid)
        {
            database[msg.sender].user = msg.sender;
            database[msg.sender].recommender = _user;
            database[msg.sender].isValid = true;
            database[_user].recommend.push(msg.sender);
        }else{
            return;
        }
    }

    function getnext() external view returns(address[] memory){
        return database[msg.sender].recommend;
    }

    function getnextnext(address _user) external view returns(address[] memory) {
        return database[_user].recommend;
    }

    function getsumget(address _user) external view returns(uint256) {
        return sumget[_user];
    }

    function setsumget(address _user,uint256 _sumnum) external{
        sumget[_user] += _sumnum;
    }
}