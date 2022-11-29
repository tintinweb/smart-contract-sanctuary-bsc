/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

interface IDao7Bet{

    function WETH() external pure returns (address);

    function topicInserted(address key) external view returns (bool);

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

    // main contract
    mapping(address => bool) mainContracts;

    constructor() {
        owner = msg.sender;
    }

    struct Map {
        address[] keys;
        mapping(address => uint256) indexOf;// index or Invitation Code
        mapping(address => bool) inserted;
        mapping(address => address) inviter;
        mapping(address => uint256) registerTime;// Record the block number at the time of registration
        mapping(address => address[]) lowerUsers;// Users at a lower level
    }
    Map private usersMap;

    function get(address userKey)
    public 
    view 
    returns (
        address key,
        bool inserted,
        uint256 indexOf,
        address inviter,
        uint256 registerTime
    )
    {
        key = userKey;
        inserted = usersMap.inserted[key];
        indexOf = usersMap.indexOf[key];
        inviter = usersMap.inviter[key];
        registerTime = usersMap.registerTime[key];
    }

    function getUserOfIndex(uint256 index)
    public 
    view 
    returns (
        address key,
        bool inserted,
        uint256 indexOf,
        address inviter,
        uint256 registerTime
    )
    {
        return get(usersMap.keys[index]);
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

    function userInserted(address key) public view returns (bool){
        return usersMap.inserted[key];
    }

    function set(
        address key,
        address inviter,
        uint256 registerTime
    ) public onlyadmin {
        if (usersMap.inserted[key]) {
            usersMap.inviter[key] = inviter;
            usersMap.registerTime[key] = registerTime;
        } else {
            usersMap.inserted[key] = true;
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
            bool userExist =  false;
            for (uint256 j=0; j < usersMap.lowerUsers[key].length; i++){
                if(usersMap.lowerUsers[key][j] == lowerUsers[i]){
                    userExist=true;
                    break;
                }
            }
            if(userExist){
                continue;
            }
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

    function getRegisterTime(address key) public view returns (uint256){
        return usersMap.registerTime[key];
    }

    function getInviter(address key) public view returns(address){
        return usersMap.inviter[key];
    }

    function registerOfBet(address key,uint256 inviteCode,address mainAddress) public{
        require(mainContracts[mainAddress],"Illegal main address");
        IDao7Bet main = IDao7Bet(mainAddress);
        require(main.topicInserted(msg.sender),"Illegal sources");

        registerUser(key, inviteCode);
    }

    function registerUser(address key,uint256 inviteCode) private{

        require(!usersMap.inserted[key],"already registered");

        usersMap.inserted[key] = true;
        address inviteAddr = address(0);
        if(inviteCode > 0){
            inviteAddr = usersMap.keys[inviteCode];
            usersMap.lowerUsers[inviteAddr].push(key);
        }
        usersMap.inviter[key] = inviteAddr;
        usersMap.registerTime[key] = block.number;
        usersMap.indexOf[key] = usersMap.keys.length;
        usersMap.keys.push(key);
    }

    function setMainList(address _address,bool _flag) public onlyadmin{
        mainContracts[_address] = _flag;
    }
}