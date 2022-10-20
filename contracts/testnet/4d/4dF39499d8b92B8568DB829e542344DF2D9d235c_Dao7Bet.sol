/**
 *Submitted for verification at BscScan.com on 2022-10-20
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


contract Dao7Bet is Ownable {
    // version
    uint public version=1;

    constructor() {
		owner = msg.sender;
    }

    // start topics
    address[] public allTopics;
    
    function allTopicsLength() external view returns (uint) {
        return allTopics.length;
    }

    // end topics

    // start tokens CRUD

    struct TokensMap {
        address[] keys;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
        mapping(address => string) name;
        mapping(address => uint256) minAmount;
        mapping(address => uint256) singleAmount;
        mapping(address => uint256) fee;// e.g. 10 on behalf of 10%
        mapping(address => uint256) sort;
        mapping(address => bool) enabled;
    }

    TokensMap private tMap;

    function getToken(address key) 
    public 
    view 
    returns (
        bool inserted,
        string memory name,
        uint256 minAmount,
        uint256 singleAmount,
        uint256 fee,
        uint256 sort,
        bool enabled
    )
    {
        inserted = tMap.inserted[key];
        name = tMap.name[key];
        minAmount = tMap.minAmount[key];
        singleAmount = tMap.singleAmount[key];
        fee = tMap.fee[key];
        sort = tMap.sort[key];
        enabled = tMap.enabled[key];
    }

    function getTokenIndexOfKey(address key)
    public
    view
    returns (int256)
    {
        if (!tMap.inserted[key]) {
            return -1;
        }
        return int256(tMap.indexOf[key]);
    }

    function getTokenKeyAtIndex(uint256 index)
    public
    view
    returns (address)
    {
        return tMap.keys[index];
    }

    function tokensLength() public view returns (uint256) {
        return tMap.keys.length;
    }

    function setToken(
        address key,
        string memory name,
        uint256 minAmount,
        uint256 singleAmount,
        uint256 fee,
        uint256 sort,
        bool enabled
    ) public onlyadmin{
        if (tMap.inserted[key]) {
            tMap.name[key] = name;
            tMap.minAmount[key] =  minAmount;
            tMap.singleAmount[key] =  singleAmount;
            tMap.fee[key] = fee;
            tMap.sort[key] = sort;
            tMap.enabled[key] = enabled;
        } else {
            tMap.inserted[key] = true;
            tMap.name[key] = name;
            tMap.minAmount[key] =  minAmount;
            tMap.singleAmount[key] =  singleAmount;
            tMap.fee[key] = fee;
            tMap.sort[key] = sort;
            tMap.enabled[key] = enabled;
            tMap.indexOf[key] = tMap.keys.length;
            tMap.keys.push(key);
        }
    }

    function removeToken(address key) public onlyadmin{
        if (!tMap.inserted[key]) {
            return;
        }

        delete tMap.inserted[key];
        delete tMap.name[key];
        delete tMap.minAmount[key];
        delete tMap.singleAmount[key];
        delete tMap.fee[key];
        delete tMap.sort[key];
        delete tMap.enabled[key];
        uint256 index = tMap.indexOf[key];
        uint256 lastIndex = tMap.keys.length - 1;
        address lastKey = tMap.keys[lastIndex];

        tMap.indexOf[lastKey] = index;
        delete tMap.indexOf[key];

        tMap.keys[index] = lastKey;
        tMap.keys.pop();
    }

    // end tokens CRUD

    // start navigation
    string public navJson;

    // base64 data
    function setNavJson(string memory data) public onlyadmin{
        navJson=data;
    }

    // end navigation

    function withdraw(address target,uint amount) public onlyowneres {
        payable(target).transfer(amount);
    }

    function withdrawToken(address token,address target, uint amount) public onlyowneres {
        IERC20(token).transfer(target, amount);
    }
    receive() external payable {}

}