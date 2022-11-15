/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

contract StorageExample1 {

    struct Entry1 {
        uint id;
        uint  value;
    }

    //compacted @ slot[0], 紧凑存储，是否考虑对其？
    uint8  public a = 11;  
    // uint8  public a1 = 111;
    uint16 public a2 = 2049;
    bool public a3 = true;
    uint128 public a4 = 4097;

    uint256 b=12; //slot[1]
    uint[2] c= [13,14]; //slot[2], slot[3]

    Entry1 d; //slot[4], slot[5]

    //string and bytes
    //如果数据长度小于等于 31 字节， 则它存储在高位字节（左对齐），最低位字节存储 length * 2
    //如果数据长度超出 31 字节，则在主插槽存储 length * 2 + 1， 数据存储在 keccak256(slot) 中
    //bytes 的存储与string 类似。
    string e  = "hello, world";  //slot[6]
    string e1  = "hello, world, welcome to earth, nice to meet you, it is a great day, do you think so?"; //length 存在slot[7], 数据值存在keccak256(slot)开始的连续几个slot中

    // 动态数组的
    // 在定义所在的插槽位置存储数组元素数量， 元素数据存储的起始位置是：keccak256(slot)，每个元素需要根据下标和元素大小来读取数据
    uint16[] public f =  [401,402,403,405,406];  //slot[8] = 5,  
    uint256[] public f1 =  [401,402,403,405,406]; //slot[9] = 5, 

    //mapping
    // keccak256(key,slot)
    mapping(uint256 => string) memos; // 例如, 此处slot = 10, address = 0x01 所对应的slot = keccak(0x01, 10)

    constructor () {
        memos[0] = "memo0";
    }

}



contract StorageExample2 {
    uint256 a = 11;
    uint8 b = 12;
    uint128 c = 13;
    bool d = true;
    uint128 e =  14;
    uint256[] public array =  [401,402,403,405,406];
    

    address owner;
    mapping(address => UserInfo) public users;
    mapping(address => mapping(address => uint256[])) records;
    string  str="name value";

    struct UserInfo {
        string name;
        uint8 age;
        uint8 weight;
        uint256[] orders;
        uint64[3] lastLogins;
    }

   constructor() {
       owner=msg.sender;
   }

   function addUser(address user,string memory name,uint8 age,uint8 weight) public {
        require(age>0 && age <100 ,"bad age");
        require(bytes(name).length != 0 ,"empty name");
        require(bytes(users[user].name).length != 0, "user alread exist");

        users[user].name = name;
        users[user].age = age;
        users[user].weight = weight;
   }

   function addLog(address user,uint64 id1,uint64 id2,uint64 id3) public{
       UserInfo storage u = users[user];
       assert(u.age>0);

       u.lastLogins[0]=id1;
       u.lastLogins[1]=id2;
       u.lastLogins[2]=id3;
   }

   function addOrder(address user,uint256 orderID) public{
       UserInfo storage u = users[user];
       assert(u.age>0);
       u.orders.push(orderID);
   }

   function addRecord(address from, address to, uint256 amount) public{
       records[from][to].push(amount);
   }

   function getLogins(address user) public view returns (uint64,uint64,uint64){
        UserInfo storage u = users[user];
       return  (u.lastLogins[0],u.lastLogins[1],u.lastLogins[2]);
   }

   function getOrders(address user) public view returns (uint256[] memory){
        UserInfo storage u = users[user];
       return  u.orders;
   }

   function getRecords(address from, address to) public view returns(uint256[] memory){
       return records[from][to];
   }

}

contract SlotHelp {

    // 获取字符串的存储起始位置
    function arrayStoragePosition(uint256 slot) public pure returns (bytes32) {
        bytes memory slotEncoded  = abi.encodePacked(slot);
        return  keccak256(slotEncoded);
    }

    // 获取字符串 Key 的字典值存储位置
    function mapStoragePosition(string memory key, uint256 slot) public pure returns (bytes32) {
        bytes memory slotEncoded  = abi.encodePacked(key,slot);
        return  keccak256(slotEncoded);
    }

    // 获取address Key 的字典值存储位置
    function mapStoragePosition(address key, uint256 slot) public pure returns (bytes32) {
        bytes memory slotEncoded  = abi.encodePacked(key,slot);
        return  keccak256(slotEncoded);
    }

    // 获取uiny256 Key 的字典值存储位置
    function mapStoragePosition(uint256 key, uint256 slot) public pure returns (bytes32) {
        bytes memory slotEncoded  = abi.encodePacked(key,slot);
        return  keccak256(slotEncoded);
    }

    //获取 mapping(address(key1) => mapping(address(key2) => Type)) 二层字典的存储位置 
    function mapStoragePosition(uint256 slot, address key1, address key2) public pure returns (bytes32) {
        bytes memory slotEncoded  = abi.encodePacked(key1,slot);
        bytes memory slotEncoded1 = abi.encodePacked(key2, slotEncoded);
        return  keccak256(slotEncoded1);
    }
}