/**
 *Submitted for verification at BscScan.com on 2022-06-15
*/

pragma solidity ^0.8.7;

//SPDX-License-Identifier: UNLICENSED

interface IMatrix {
    function itersOf(address account) external view returns (uint256);
    function addUserToQueue(address account) external;   
}

contract MiniMatrix {
    address public myParant;

    mapping(uint256 => address) public Queue;
    mapping(uint256 => uint256) public Cycles;

    uint256 public QueueFinish = 0;

    mapping(address => bool) public User;
    mapping(uint256 => uint256) public Parent;
    mapping(uint256 => mapping(uint256 => uint256)) public Childrens;

    mapping(address => uint256) public Referal;
    address public owner;

    uint256 public payValue;
    uint256 public startTime;

    constructor(uint256 value, uint256 timeStamp, address Owner) {
        owner = Owner;
        Queue[QueueFinish++] = owner;

        Parent[0] = 0;
        Cycles[0] = 2**256 - 1;
        Referal[owner] = 0; 

        payValue = value;
        startTime = timeStamp;        

        myParant = msg.sender;
        User[owner] = true;
    }

    function changeOwner(address newOwner ) public
    {
        require(msg.sender == owner);
        owner = newOwner;

        Queue[0] = owner;
        Referal[owner] = 0; 
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

    function addUser(uint256 ReferalNumber, address user)
        private
        returns (uint256)
    {
        require(!User[user]);
        User[user] = true;

        Childrens[ReferalNumber][++(Childrens[ReferalNumber][0])] = QueueFinish;

        Parent[QueueFinish] = ReferalNumber;
        Queue[QueueFinish] = user;

        IMatrix ip = IMatrix(myParant);

        Cycles[QueueFinish] = ip.itersOf(user);
        Referal[user] = QueueFinish; 

        ip.addUserToQueue(user);  

        QueueFinish++;

        return Referal[user];
    }

    function addUserPay(address msgSender, uint256 ReferalNumber)
        public
        payable
        returns (uint256)
    {
        require(msg.sender == myParant);
        require(ReferalNumber < QueueFinish);
        require(block.timestamp > startTime);       

        uint256 rand;
        do{
            rand = random(QueueFinish);
        } while(Cycles[rand] == 0);

        Cycles[rand]--;
        
        (bool success, ) = Queue[rand].call{value: ((74 * payValue)/100)}("");        
        require(success);
        (success, ) = Queue[ReferalNumber].call{value: ((13 * payValue)/100)}("");        
        require(success);
        (success, ) = Queue[Parent[ReferalNumber]].call{value: ((8 * payValue)/100)}("");        
        require(success);
        (success, ) = Queue[Parent[Parent[ReferalNumber]]].call{value: ((5 * payValue)/100)}("");        
        require(success);

        addUser(ReferalNumber, msgSender);

        return Referal[msgSender];
    }

    function addUsers(uint256[] memory ReferalNumbers, address[] memory newUsers, uint256 size)
        public   
    {
        require(msg.sender == owner);
        for(uint256 i = 0; i < size; i++)
        {
            addUser(ReferalNumbers[i], newUsers[i]);
        }
    }

    function addUserToQueue(address newUser)
        public           
    {
        require(msg.sender == myParant);
        Cycles[Referal[newUser]] = 2**256 - 1;
    }

    function getReferal(address r) public view
    returns(uint256)
    {
        return Referal[r];
    }

    function getQueue(uint256 r) public view
    returns(address)
    {
        return Queue[r];
    }    
}

contract Matrix is IMatrix{
    mapping(uint256 => address) public NumLevels;
    mapping(address => uint256) public Levels;
    uint256 public iter = 0;

    mapping(uint256 => uint256) public Times;
    mapping(uint256 => uint256) public Values;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function newLevel(uint256 value, uint256 timeStamp) external
    {
        require(msg.sender == owner);

        MiniMatrix mm = new MiniMatrix(value, timeStamp, msg.sender);
        
        NumLevels[++iter] = address(mm);
        Times[iter] = timeStamp;
        Values[iter] = value;

        Levels[NumLevels[iter]] = iter;
    }

    function itersOf(address account) override external view returns (uint256)
    {
        require(Levels[msg.sender] > 0, "7");

        if(Levels[msg.sender] == 1)
            return 2**256 - 1;

        MiniMatrix mm = MiniMatrix(NumLevels[Levels[msg.sender] - 1]);
        if(mm.isUser(account))
            return 2**256 - 1;

        return 2;
    }

    function addUserToQueue(address account) override external                   
    {
        require(Levels[msg.sender] > 0, "8");
        if(Levels[msg.sender] + 1 <= iter)
        {
            MiniMatrix mm = MiniMatrix(NumLevels[Levels[msg.sender] + 1]);
            if(mm.isUser(account))
                mm.addUserToQueue(account);        
        }
    }

    function addUser(uint256 Level, uint256 ref)
        public   
        payable
        returns (uint256)
    {
        require(Level <= iter && Level > 0);
        require(msg.value >= Values[Level]);

        MiniMatrix mm = MiniMatrix(NumLevels[Level]);

        return mm.addUserPay{value:msg.value}(msg.sender, ref);
    }

    function ReferalNumber(uint256 Level, address ref) public view
        returns(uint256)
    {
        MiniMatrix mm = MiniMatrix(NumLevels[Level]);
        return mm.getReferal(ref);
    }

    function ReferalAddress(uint256 Level, uint256 ref) public view
        returns(address)
    {
        MiniMatrix mm = MiniMatrix(NumLevels[Level]);
        return mm.getQueue(ref);
    }

    function ReferalsId(uint256 Level) public view
        returns(uint256[] memory IDs)
    {
        MiniMatrix mm = MiniMatrix(NumLevels[Level]);
        IDs = new uint256[](mm.QueueFinish());

        for(uint256 i = 0; i < mm.QueueFinish(); i++)
        {
            IDs[i] = i;
        }

        return IDs;
    }
}