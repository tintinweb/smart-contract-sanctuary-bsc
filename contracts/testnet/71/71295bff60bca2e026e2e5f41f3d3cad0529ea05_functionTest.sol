/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// import "./Library.sol";
contract functionTest{
    //管理员地址
    address public owner;

    //所有字母集合
    string[26] public letterArr = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];

    //游戏难度，一个单词的字母个数
    uint public difficulty = 6;

    //记录玩家一局游戏的hash值对应的游戏结果
    mapping(string => string) private gameRes;

    //记录一个玩家的游戏过程
    struct Record {
        //当局游戏的id
        string _hash;
        //游戏当前输入行数
        uint8 _row;
    }

    //玩家游戏列表
    mapping(address => Record) public Records;

    constructor(){
        owner = msg.sender;
    }

    //从26个字母中随机获取指定数量字符
    function randomStr() private view returns(string memory){
        string memory word = '';
        for(uint i = 0; i < difficulty; i++){
            uint index = randNumber(25,i);
            word = string(abi.encodePacked(word,letterArr[index]));
            // word = string.concat(word, letterArr[index]);
        }
        return word;
    }

    //随机一个数字 0 - _length 的整数,这是是随机0 - 25
    function randNumber(uint256 _length, uint _randNonce) private view returns(uint) {
        uint random = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender, _randNonce))) % _length;
        return random;
    }

    //获取一个随机结果
    function startNewGame() public view returns(string memory) {
        return randomStr();
    }

    //获取对应游戏id的结果
    function getGameRes(string memory _hash) public view onlyOwner returns(string memory){
        return gameRes[_hash];
    }

    //获取一个hash
    function getHash() public view returns(bytes32){
        return keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender));
    }

    function getTimeStamp() public view returns(uint){
        return block.timestamp;
    }

    //设置游戏难度
    function setDifficulty(uint _difficulty) public onlyOwner {
        difficulty = _difficulty;
    }

    //管理员权限
    modifier onlyOwner{
        require(msg.sender == owner,"Is Not Owner");
        _;
    }

    //转移管理员
    function transferShip(address _newOwner) public onlyOwner{
        owner = _newOwner;
    }
}