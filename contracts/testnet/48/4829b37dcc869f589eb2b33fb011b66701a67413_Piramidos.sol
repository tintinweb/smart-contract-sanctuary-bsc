/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

pragma solidity ^0.8.7;

//SPDX-License-Identifier: UNLICENSED

interface IPiramidos {
    function itersOf(address account) external view returns (uint256);
    function addUserToQueue(address account) external;   
}

contract GalimiyPiramidos {
    address public myParant;

    mapping(uint256 => address) public Queue;
    mapping(uint256 => uint256) public Cycles;
    mapping(uint256 => bool) public Full;

    uint256 public QueueStart  = 0;
    uint256 public QueueFinish = 0;

    mapping(address => bool) public User;
    mapping(address => address) public UserLeft;
    mapping(address => address) public UserRight;
    mapping(uint256 => uint256) public UserLeftNum;
    mapping(uint256 => uint256) public UserRightNum;
    mapping(uint256 => uint256) public Parent;

    mapping(address => uint256) public Referal;
    address public owner;

    uint256 public payValue;
    uint256 private startTime;

    constructor(uint256 value, uint256 timeStamp, address Owner) {
        owner = Owner;
        Queue[QueueFinish++] = owner;

        Parent[0] = 0;
        Cycles[0] = 2**256 - 1;

        payValue = value;
        startTime = timeStamp;

        Referal[owner] = (QueueFinish - 1); 

        myParant = msg.sender;
        User[owner] = true;
    }

    function random(uint256 number) public view returns(uint256)
    {
        return uint256(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % number;
    }

    function isUser(address a) public view returns(bool)
    {
        return User[a];
    }

    function addUser(uint256 ReferalNumber)
        public   
        payable
        returns (uint256)
    {
        require(ReferalNumber < QueueFinish);
        require(!Full[ReferalNumber], "0");
        require(block.timestamp > startTime, "1");
        require(msg.value == payValue, "2");

        User[msg.sender] = true;

        (bool success, ) = Queue[random(QueueFinish)].call{value: ((74 * payValue)/100)}("");        
        require(success, "3");
        (success, ) = Queue[ReferalNumber].call{value: ((13 * payValue)/100)}("");        
        require(success, "4");
        (success, ) = Queue[Parent[ReferalNumber]].call{value: ((8 * payValue)/100)}("");        
        require(success, "5");
        (success, ) = Queue[Parent[Parent[ReferalNumber]]].call{value: ((5 * payValue)/100)}("");        
        require(success, "6");
        
        while(Cycles[QueueStart++] == 0)
        {

        }        

        UserRight[Queue[ReferalNumber]] = Queue[QueueStart - 1];
        UserLeft[Queue[ReferalNumber]] = msg.sender;        

        Queue[QueueFinish++] = UserRight[Queue[ReferalNumber]];
        Queue[QueueFinish++] = msg.sender;

        UserRightNum[ReferalNumber] = (QueueFinish - 1);
        UserLeftNum[ReferalNumber] = (QueueFinish - 1);     

        Parent[(QueueFinish - 1)] = ReferalNumber;
        Parent[(QueueFinish - 2)] = ReferalNumber;

        IPiramidos ip = IPiramidos(myParant);

        Cycles[(QueueFinish - 1)] = ip.itersOf(msg.sender);
        Cycles[(QueueFinish - 2)] = Cycles[QueueStart - 1] - 1;

        Full[ReferalNumber] = true; 
        Referal[msg.sender] = (QueueFinish - 1);
        Referal[UserRight[Queue[ReferalNumber]]] = (QueueFinish - 2); 

        ip.addUserToQueue(msg.sender);       

        return Referal[msg.sender];
    }

    function addUser(uint256 ReferalNumber , address newUser)
        public   
        returns (uint256)
    {
        require(ReferalNumber < QueueFinish);
        require(!Full[ReferalNumber]);
        require(msg.sender == owner);

        User[newUser] = true;
        
        while(Cycles[QueueStart++] == 0)
        {

        }

        UserRight[Queue[ReferalNumber]] = Queue[QueueStart - 1];
        UserLeft[Queue[ReferalNumber]] = newUser;

        Queue[QueueFinish++] = UserRight[Queue[ReferalNumber]];
        Queue[QueueFinish++] = newUser;

        UserRightNum[ReferalNumber] = (QueueFinish - 1);
        UserLeftNum[ReferalNumber] = (QueueFinish - 1); 

        Parent[(QueueFinish - 1)] = ReferalNumber;
        Parent[(QueueFinish - 2)] = ReferalNumber;

        Cycles[(QueueFinish - 1)] = 2**256 - 1; 
        Cycles[(QueueFinish - 2)] = Cycles[QueueStart - 1] - 1;

        Full[ReferalNumber] = true; 
        Referal[newUser] = (QueueFinish - 1);   
        Referal[UserRight[Queue[ReferalNumber]]] = (QueueFinish - 2);      

        return Referal[newUser];
    }

    function addUserToQueue(address newUser)
        public           
    {
        require(msg.sender == myParant);

        Full[QueueFinish] = true;
        Queue[QueueFinish] = newUser;
        Cycles[QueueFinish++] = 2**256 - 1; 

        Referal[newUser] = (QueueFinish - 1);
    }
}

contract Piramidos is IPiramidos{
    mapping(uint256 => address) public NumLevels;
    mapping(address => uint256) public Levels;
    uint256 public iter = 0;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function newLevel(uint256 value, uint256 timeStamp) external
    {
        require(msg.sender == owner);

        GalimiyPiramidos gp = new GalimiyPiramidos(value, timeStamp, msg.sender);
        NumLevels[++iter] = address(gp);
        Levels[NumLevels[iter]] = iter;
    }

    function itersOf(address account) override external view returns (uint256)
    {
        require(Levels[msg.sender] > 0, "7");

        if(Levels[msg.sender] == 1)
            return 2**256 - 1;

        GalimiyPiramidos gp = GalimiyPiramidos(NumLevels[Levels[msg.sender] - 1]);
        if(gp.isUser(account))
            return 2**256 - 1;

        return 2;
    }

    function addUserToQueue(address account) override external                   
    {
        require(Levels[msg.sender] > 0, "8");
        if(Levels[msg.sender] + 1 <= iter)
        {
            GalimiyPiramidos gp = GalimiyPiramidos(NumLevels[Levels[msg.sender] + 1]);
            if(gp.isUser(account))
                gp.addUserToQueue(account);        
        }
    }
}