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

contract Dao7Users is Ownable {
    // version
    uint public version=1;

    constructor() {
		owner = msg.sender;
    }

    struct Map {
        address[] keys;
        mapping(address => uint256) indexOf;// index or Invitation Code
        mapping(address => bool) inserted;
        mapping(address => bool) validReferral;// The invitation is valid for 72 hours, after which the transaction becomes false
        mapping(address => address) inviter;
        mapping(address => uint256) registerTime;// Record the block number at the time of registration
        mapping(address => address[]) lowerUsers;// Users at a lower level
    }
    Map private usersMap;

    function get(address key)
    public 
    view 
    returns (
        uint256 indexOf,
        bool validReferral,
        address inviter,
        uint256 registerTime
    )
    {
        indexOf = usersMap.indexOf[key];
        validReferral = usersMap.validReferral[key];
        inviter = usersMap.inviter[key];
        registerTime = usersMap.registerTime[key];
    }

    function getIndexOfKey(address key)
    public
    view
    returns (int256)
    {
        if (!usersMap.inserted[key]) {
            return -1;
        }
        return int256(usersMap.indexOf[key]);
    }

    function getKeyAtIndex(uint256 index)
    public
    view
    returns (address)
    {
        return usersMap.keys[index];
    }

    function size() public view returns (uint256) {
        return usersMap.keys.length;
    }

    function set(
        address key,
        bool validReferral,
        address inviter,
        uint256 registerTime
    ) public onlyadmin {
        if (usersMap.inserted[key]) {
            usersMap.validReferral[key] = validReferral;
            usersMap.inviter[key] = inviter;
            usersMap.registerTime[key] = registerTime;
        } else {
            usersMap.inserted[key] = true;
            usersMap.validReferral[key] = validReferral;
            usersMap.inviter[key] = inviter;
            usersMap.registerTime[key] = registerTime;
            usersMap.indexOf[key] = usersMap.keys.length;
            usersMap.keys.push(key);
        }
    }

    function setLowerUsers(
        address key,
        address[] memory lowerUsers
    ) public onlyadmin {
        require(usersMap.inserted[key],"no register");
        for (uint256 i = 0; i < lowerUsers.length; i++) {
            usersMap.lowerUsers[key].push(lowerUsers[i]);
		}
    }

    function removeLowerUser(address key,address lowerUser) public onlyadmin{
        require(usersMap.inserted[key],"no register");
        uint256 lowerUserIndex=0;
        for (uint256 i=0; i < usersMap.lowerUsers[key].length; i++){
            if(usersMap.lowerUsers[key][i] == lowerUser){
                lowerUserIndex=i;
                break;
            }
        }
        require(lowerUserIndex >= 0 && lowerUserIndex < usersMap.lowerUsers[key].length, "index out of range");
        
        if(lowerUserIndex == usersMap.lowerUsers[key].length - 1){
            usersMap.lowerUsers[key].pop();
        }else{
            address lastElement = usersMap.lowerUsers[key][usersMap.lowerUsers[key].length - 1];
            usersMap.lowerUsers[key][lowerUserIndex] =  lastElement;
            usersMap.lowerUsers[key].pop();
        }
    }

    function getLowerUsers(address key) 
    public 
    view 
    returns (
        address[] memory
    )
    {
        return usersMap.lowerUsers[key];
    }

    function register(uint256 inviteCode) public {
        require(getIndexOfKey(msg.sender)<0,"already registered");

        address inviteAddr = getKeyAtIndex(inviteCode);
        
        set(msg.sender, false, inviteAddr, block.number);
    }

    function withdraw(address target,uint amount) public onlyowneres {
        payable(target).transfer(amount);
    }
    

    function withdrawToken(address token,address target, uint amount) public onlyowneres {
        IERC20(token).transfer(target, amount);
    }
    receive() external payable {}
}