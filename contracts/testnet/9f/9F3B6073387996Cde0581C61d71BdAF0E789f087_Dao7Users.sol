/**
 *Submitted for verification at BscScan.com on 2022-10-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract Ownable {
    address public owner;
    mapping(address => bool) private admins;

    event owneresshipTransferred(address indexed previousowneres, address indexed newowneres);
    event adminshipTransferred(address indexed previousowneres, address indexed newowneres);

    modifier onlyowneres() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyadmin() {
        require(admins[msg.sender]);
        _;
    }

    function transferowneresship(address newowneres) public onlyowneres {
        require(newowneres != address(0));
        emit owneresshipTransferred(owner, newowneres);
        owner = newowneres;
    }

    function renounceowneresship() public onlyowneres {
        emit owneresshipTransferred(owner, address(0));
        owner = address(0);
    }

    function setAdmins(address[] memory addrs,bool flag) public onlyowneres{
		for (uint256 i = 0; i < addrs.length; i++) {
            admins[addrs[i]] = flag;
		}
    }
}

// user mapping library
library UserMapping {
    struct Map {
        address[] keys;
        mapping(address => uint256) indexOf;// index or Invitation Code
        mapping(address => bool) inserted;
        mapping(address => bool) validReferral;// The invitation is valid for 72 hours, after which the transaction becomes false
        mapping(address => address) inviter;
        mapping(address => uint256) registerTime;// Record the block number at the time of registration
        mapping(address => address[]) lowerUsers;// Users at a lower level
    }

    function get(Map storage map, address key) 
    public 
    view 
    returns (
        uint256 indexOf,
        bool validReferral,
        address inviter,
        uint256 registerTime
        //address[] memory lowerUsers
    )
    {
        indexOf = map.indexOf[key];
        validReferral = map.validReferral[key];
        inviter = map.inviter[key];
        registerTime = map.registerTime[key];
        //lowerUsers = map.lowerUsers[key];
    }

    function getIndexOfKey(Map storage map, address key)
    public
    view
    returns (int256)
    {
        if (!map.inserted[key]) {
            return -1;
        }
        return int256(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint256 index)
    public
    view
    returns (address)
    {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint256) {
        return map.keys.length;
    }

    function set(
        Map storage map,
        address key,
        bool validReferral,
        address inviter,
        uint256 registerTime
    ) public {
        if (map.inserted[key]) {
            map.validReferral[key] = validReferral;
            map.inviter[key] = inviter;
            map.registerTime[key] = registerTime;
        } else {
            map.inserted[key] = true;
            map.validReferral[key] = validReferral;
            map.inviter[key] = inviter;
            map.registerTime[key] = registerTime;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function setLowerUsers(
        Map storage map,
        address key,
        address[] memory lowerUsers
    ) public {
        require(map.inserted[key],"no register");
        for (uint256 i = 0; i < lowerUsers.length; i++) {
            map.lowerUsers[key].push(lowerUsers[i]);
		}
    }

    function removeLowerUser(Map storage map,address key,address lowerUser) public{
        require(map.inserted[key],"no register");
        uint256 lowerUserIndex=0;
        for (uint256 i=0; i < map.lowerUsers[key].length; i++){
            if(map.lowerUsers[key][i] == lowerUser){
                lowerUserIndex=i;
                break;
            }
        }
        require(lowerUserIndex >= 0 && lowerUserIndex < map.lowerUsers[key].length, "index out of range");
        
        if(lowerUserIndex == map.lowerUsers[key].length - 1){
            map.lowerUsers[key].pop();
        }else{
            address lastElement = map.lowerUsers[key][map.lowerUsers[key].length - 1];
            map.lowerUsers[key][lowerUserIndex] =  lastElement;
            map.lowerUsers[key].pop();
        }
    }

    function getLowerUsers(Map storage map, address key) 
    public 
    view 
    returns (
        address[] memory
    )
    {
        return map.lowerUsers[key];
    }

}


contract Dao7Users is Ownable {
    using UserMapping for UserMapping.Map;

    UserMapping.Map private usersMap;

    // version
    uint public version=1;

    constructor() {
		owner = msg.sender;
    }

    // function usersLength() public view returns (uint256) {
    //     return usersMap.keys.length;
    // }

    // function getUser(address key) 
    // public 
    // view 
    // returns (        
    //     uint256 indexOf,
    //     bool validReferral,
    //     address inviter,
    //     uint256 registerTime
    // )
    // {
    //     return usersMap.get(key);
    // }

    // function getUserIndexOfKey(address key) public view returns (int256){
    //     return usersMap.getIndexOfKey(key);
    // }

    // function getUserKeyAtIndex(uint256 index) public view returns (address){
    //     return usersMap.getKeyAtIndex(index);
    // }

    // function setUser(address key,bool validReferral,address inviter,uint256 registerTime) public onlyadmin{
    //     usersMap.set(key, validReferral, inviter, registerTime);
    // }

    // function register(uint256 inviteCode) public {
    //     require(usersMap.getIndexOfKey(msg.sender)<0,"already registered");

    //     address inviteAddr = usersMap.getKeyAtIndex(inviteCode);
        
    //     usersMap.set(msg.sender, false, inviteAddr, block.number);
    // }

    // function getLowerUsers(address key) public view returns (address[] memory){
    //     return usersMap.getLowerUsers(key);
    // }

    // function setLowerUsers(address key,address[] memory lowerUsers) public onlyadmin{
    //     usersMap.setLowerUsers(key, lowerUsers);
    // }

    // function removeLowerUser(address key,address lowerUser) public onlyadmin{
    //     usersMap.removeLowerUser(key, lowerUser);
    // }

    function withdraw(address target,uint amount) public onlyowneres {
        payable(target).transfer(amount);
    }
    

    function withdrawToken(address token,address target, uint amount) public onlyowneres {
        IERC20(token).transfer(target, amount);
    }
    receive() external payable {}
}