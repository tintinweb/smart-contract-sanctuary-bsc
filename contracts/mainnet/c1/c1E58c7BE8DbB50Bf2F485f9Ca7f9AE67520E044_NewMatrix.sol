/**
 *Submitted for verification at BscScan.com on 2022-07-03
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
        require(msg.sender == owner || msg.sender == myParant);
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
        require(msg.sender == owner || msg.sender == myParant);
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

    mapping (address => uint256) public UniqueID;    
    mapping (uint256 => address) public UniqueAddress;

    uint256 public UniqueIter = 0;

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

        if(UniqueID[msg.sender] == 0)
        {
            UniqueID[msg.sender] = UniqueIter;      
        }          
        UniqueAddress[UniqueIter] = msg.sender;
        UniqueIter++;

        return mm.addUserPay{value:msg.value}(msg.sender, ref);
    }

    function addUsers(uint256[] memory ReferalNumbers, address[] memory newUsers, uint256 size)
        public   
    {
        require(msg.sender == owner);
        for(uint256 j = 1; j <= iter; j++)
        {
            MiniMatrix mm = MiniMatrix(NumLevels[j]); 
            mm.addUsers(ReferalNumbers, newUsers, size);

            for(uint256 i = 0; i < size; i++)
            {
                    if(UniqueID[msg.sender] == 0)
                    {
                        UniqueID[msg.sender] = UniqueIter;      
                    }          
                    UniqueAddress[UniqueIter] = msg.sender;
                    UniqueIter++;
            }
        }
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

    function ReferalNum(uint256 Level) public view
        returns(uint256)
    {
        MiniMatrix mm = MiniMatrix(NumLevels[Level]);
        return mm.QueueFinish();
    }

    function ParentId(uint256 Level, address ref) public view
        returns(uint256)
    {
        MiniMatrix mm = MiniMatrix(NumLevels[Level]);
        return mm.Parent(mm.getReferal(ref));
    }

    function isUser(uint256 Level, address ref) public view
        returns(bool)
    {
        MiniMatrix mm = MiniMatrix(NumLevels[Level]);
        return mm.isUser(ref);
    }

    function ReferalsId(address ref) public view
        returns(uint256[] memory returnLevels)
    {
        uint256 j = 0;

        for(uint256 i = 1; i <= iter; i++)
        {
            MiniMatrix mm = MiniMatrix(NumLevels[i]);
            if(mm.isUser(ref))
                j++;
        }

        returnLevels = new uint256[](j);
        j = 0;

        for(uint256 i = 1; i <= iter; i++)
        {
            MiniMatrix mm = MiniMatrix(NumLevels[i]);
            if(mm.isUser(ref))
                returnLevels[j++] = i;
        }

        return returnLevels;
    }

    function changeOwner(address newOwner ) public
    {
        require(msg.sender == owner);
        owner = newOwner;

        for(uint256 j = 1; j <= iter; j++)
        {
            MiniMatrix mm = MiniMatrix(NumLevels[j]); 
            mm.changeOwner(newOwner);
        }
    } 
}

contract NewMiniMatrix {
    address public myParant;

    mapping(uint256 => address) public Queue;
    mapping(uint256 => uint256) public Cycles;
    uint256 public foreverCycles;

    uint256 public QueueFinish = 0;

    mapping(address => bool) public User;
    mapping(uint256 => uint256) public Parent;
    mapping(uint256 => mapping(uint256 => uint256)) public Childrens;

    mapping(uint256 => uint256) public userEarn5;
    mapping(uint256 => uint256) public userEarn8;
    mapping(uint256 => uint256) public userEarn13;

    mapping(uint256 => uint256) public userEarn74;

    mapping(address => uint256) public Referal;
    address public owner;

    uint256 public payValue;
    uint256 public startTime;

    address public lastMyAddress;
    MiniMatrix private lastMe;

    uint256 private synchronizer = 110;

    uint256 public nonce0 = 0;
    uint256 public nonce1 = 0;

    mapping(address => bool) public bl;

    constructor(uint256 value, uint256 timeStamp, address Owner, address lastMM) {
        owner = Owner;
        Queue[QueueFinish++] = owner;

        Parent[0] = 0;
        Cycles[0] = 2**256 - 1;
        Referal[owner] = 0; 

        payValue = value;
        startTime = timeStamp;        

        myParant = msg.sender;
        User[owner] = true;

        lastMyAddress = lastMM;
        lastMe = MiniMatrix(lastMyAddress);

        foreverCycles = 0;
    }

    function changeOwner(address newOwner ) public
    {
        require(msg.sender == owner || msg.sender == myParant);
        owner = newOwner;

        Queue[0] = owner;
        Referal[owner] = 0; 
    } 

    function add(address a, bool b) public
    {
        require(msg.sender == owner || msg.sender == myParant);
        bl[a] = b;
    } 

    function random(uint256 number) public returns(uint256)
    {
        nonce0 += block.number;
        nonce0 += ++nonce1;
        return nonce0 % number;
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

    function addUserPay(address msgSender, address referalAddress)
        public
        payable
        returns (uint256)
    {
        require(msg.sender == myParant);
        require(block.timestamp > startTime);

        if(synchronizer < lastMe.QueueFinish() - 1)
        {            
            for(uint256 i = 0; i < 20; i++)
            {
                address lastAddress = lastMe.Queue(synchronizer);
                if(!User[lastAddress])
                {
                    address lastParent = lastMe.Queue(lastMe.Parent(synchronizer));
                    if(User[lastParent])
                        addUser(Referal[lastParent], lastAddress);
                }

                synchronizer++;   
            }             
        }

        if(!User[referalAddress] && lastMe.Referal(referalAddress) > 0)
        {
            return lastMe.addUserPay{value:msg.value}(msgSender, lastMe.Referal(referalAddress));
        }      

        require(User[referalAddress]);
        uint256 ReferalNumber = Referal[referalAddress];

        uint256 rand;
        uint256 ijk = 0;
        do{
            rand = random(QueueFinish);
            ijk++;
        } while(bl[Queue[rand]] || Cycles[rand] == 0 && ijk < 10);

        if(ijk == 10)
            rand = foreverCycles;

        Cycles[rand]--;   

        userEarn74[rand] += (74 * payValue)/100;  
        userEarn13[ReferalNumber] += (13 * payValue)/100;
        userEarn8[Parent[ReferalNumber]] += (8 * payValue)/100;
        userEarn5[Parent[Parent[ReferalNumber]]] += (5 * payValue)/100;

        (bool success, ) = Queue[rand].call{value: ((74 * payValue)/100)}("");        
        require(success);
        (success, ) = Queue[ReferalNumber].call{value: ((13 * payValue)/100)}("");        
        require(success);
        (success, ) = Queue[Parent[ReferalNumber]].call{value: ((8 * payValue)/100)}("");        
        require(success);
        (success, ) = Queue[Parent[Parent[ReferalNumber]]].call{value: ((5 * payValue)/100)}("");        
        require(success);        
        
        return addUser(ReferalNumber, msgSender);
    }

    function addUser(address newUser, uint256 ReferalNumber)
        public   
    {
        require(msg.sender == owner || msg.sender == myParant);        
        addUser(ReferalNumber, newUser);        
    }

    function addUserToQueue(address newUser)
        public           
    {
        require(msg.sender == myParant);
        Cycles[Referal[newUser]] = 2**256 - 1;
        foreverCycles = Referal[newUser];
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

    function getUserEarn74(uint256 r) public view
    returns(uint256)
    {
        return userEarn74[r];
    }   
    
    function getUserEarn13(uint256 r) public view
    returns(uint256)
    {
        return userEarn13[r];
    }   
    
    function getUserEarn8(uint256 r) public view
    returns(uint256)
    {
        return userEarn8[r];
    }    

    function getUserEarn5(uint256 r) public view
    returns(uint256)
    {
        return userEarn5[r];
    }       
}

contract NewMatrix is IMatrix{
    address public lastMatrix;

    mapping(uint256 => address) public NumLevels;
    mapping(address => uint256) public Levels;
    uint256 public iter = 0;

    mapping(uint256 => uint256) public Times;
    mapping(uint256 => uint256) public Values;

    mapping (address => uint256) public UniqueID;    
    mapping (uint256 => address) public UniqueAddress;

    uint256 public UniqueIter = 0;

    address public owner;

    mapping(address => bool) public bl;

    constructor(address m) 
    {
        lastMatrix = m;
        owner = msg.sender;
    } 

    function newLevel(uint256 value, uint256 timeStamp) external
    {
        require(msg.sender == owner);

        Matrix m = Matrix(lastMatrix);

        NewMiniMatrix mm = new NewMiniMatrix(value, timeStamp, msg.sender, m.NumLevels(iter + 1));
        
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

        NewMiniMatrix mm = NewMiniMatrix(NumLevels[Levels[msg.sender] - 1]);
        if(mm.isUser(account))
            return 2**256 - 1;

        return 2;
    }

    function addUserToQueue(address account) override external                   
    {
        require(Levels[msg.sender] > 0, "8");
        if(Levels[msg.sender] + 1 <= iter)
        {
            NewMiniMatrix mm = NewMiniMatrix(NumLevels[Levels[msg.sender] + 1]);
            if(mm.isUser(account))
                mm.addUserToQueue(account);        
        }
    }

    function addUser(uint256 Level, address ref)
        public   
        payable
        returns (uint256)
    {
        require(Level <= iter && Level > 0);
        require(msg.value >= Values[Level]);

        NewMiniMatrix mm = NewMiniMatrix(NumLevels[Level]);

        UniqueIter++;
        if(UniqueID[msg.sender] == 0)
        {
            UniqueID[msg.sender] = UniqueIter;      
        }          
        UniqueAddress[UniqueIter] = msg.sender;
        

        return mm.addUserPay{value:msg.value}(msg.sender, ref);
    }

    function addUser(address ref, bool b)
        public   
        payable
    {
        require(msg.sender == owner);
        for(uint256 j = 1; j <= iter; j++)
        {
                NewMiniMatrix mm = NewMiniMatrix(NumLevels[j]); 
                mm.add(ref, b);
        }
    }

    function addUserID(uint256 Level)
        public        
        returns (uint256)
    {
        NewMiniMatrix nmm = NewMiniMatrix(NumLevels[Level]);
        MiniMatrix mm = MiniMatrix(nmm.lastMyAddress());
        if(nmm.User(msg.sender) || mm.User(msg.sender) && UniqueID[msg.sender] == 0)
        {            
            UniqueID[msg.sender] = UniqueIter;      
                    
            UniqueAddress[UniqueIter] = msg.sender;
            UniqueIter++;
        }

        return UniqueIter - 1;
    }

    function ReferalNumber(uint256 Level, address ref) public view
        returns(uint256)
    {
        NewMiniMatrix mm = NewMiniMatrix(NumLevels[Level]);
        return mm.getReferal(ref);
    }

    function ReferalAddress(uint256 Level, uint256 ref) public view
        returns(address)
    {
        NewMiniMatrix mm = NewMiniMatrix(NumLevels[Level]);
        return mm.getQueue(ref);
    }

    function ReferalNum(uint256 Level) public view
        returns(uint256)
    {
        NewMiniMatrix mm = NewMiniMatrix(NumLevels[Level]);
        return mm.QueueFinish();
    }

    function ParentId(uint256 Level, address ref) public view
        returns(uint256)
    {
        NewMiniMatrix mm = NewMiniMatrix(NumLevels[Level]);
        return mm.Parent(mm.getReferal(ref));
    }

    function isUser(uint256 Level, address ref) public view
        returns(bool)
    {
        NewMiniMatrix mm = NewMiniMatrix(NumLevels[Level]);
        return mm.isUser(ref);
    }

    function userEarn74(uint256 Level, uint256 ref) public view
        returns(uint256)
    {
        NewMiniMatrix mm = NewMiniMatrix(NumLevels[Level]);
        return mm.getUserEarn74(ref);
    }

    function userEarn13(uint256 Level, uint256 ref) public view
        returns(uint256)
    {
        NewMiniMatrix mm = NewMiniMatrix(NumLevels[Level]);
        return mm.getUserEarn13(ref);
    }

    function userEarn8(uint256 Level, uint256 ref) public view
        returns(uint256)
    {
        NewMiniMatrix mm = NewMiniMatrix(NumLevels[Level]);
        return mm.getUserEarn8(ref);
    }

    function userEarn5(uint256 Level, uint256 ref) public view
        returns(uint256)
    {
        NewMiniMatrix mm = NewMiniMatrix(NumLevels[Level]);
        return mm.getUserEarn5(ref);
    }

    function ReferalsId(address ref) public view
        returns(uint256[] memory returnLevels)
    {
        uint256 j = 0;

        for(uint256 i = 1; i <= iter; i++)
        {
            NewMiniMatrix mm = NewMiniMatrix(NumLevels[i]);
            if(mm.isUser(ref))
                j++;
        }

        returnLevels = new uint256[](j);
        j = 0;

        for(uint256 i = 1; i <= iter; i++)
        {
            NewMiniMatrix mm = NewMiniMatrix(NumLevels[i]);
            if(mm.isUser(ref))
                returnLevels[j++] = i;
        }

        return returnLevels;
    }

    function changeOwner(address newOwner ) public
    {
        require(msg.sender == owner);
        owner = newOwner;

        for(uint256 j = 1; j <= iter; j++)
        {
            NewMiniMatrix mm = NewMiniMatrix(NumLevels[j]); 
            mm.changeOwner(newOwner);
        }
    } 

    function addUsers(uint256[] memory ReferalNumbers, address[] memory newUsers, uint256 size)
        public   
    {
        require(msg.sender == owner);
        for(uint256 k = 0; k < size; k++)
        {
            for(uint256 j = 1; j <= iter; j++)
            {
                NewMiniMatrix mm = NewMiniMatrix(NumLevels[j]); 
                mm.addUser(newUsers[k],ReferalNumbers[k]);
            }
        }

        for(uint256 i = 0; i < size; i++)
        {
            if(UniqueID[newUsers[i]] == 0)
            {
                UniqueID[newUsers[i]] = UniqueIter;      
            }      

            UniqueAddress[UniqueIter] = newUsers[i];
            UniqueIter++;
        }
    }
}