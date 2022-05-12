/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() public {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract NeedForGame is ReentrancyGuard 
{
 struct User 
   {
        uint id;
        uint registrationTimestamp;
        bool IsCostumer;
        address referrer;
        uint referrals;
        uint referralPayoutSum;
        uint RewardSumForTables;
        mapping(uint8 => UserTablesInfo) Tables;
    }

    struct UserTablesInfo 
    {
        uint16 activationTimes;
        uint16 maxPayouts;
        uint16 payouts;
        bool active;
        uint rewardSum;
        uint referralPayoutSum;
    }
    struct GlobalStat 
    {
        uint members;
        uint transactions;
        uint turnover;
    }
    
   
    
    event BuyLevel(uint userId, uint8 table);
    
    event LevelPayout(uint userId, uint8 table, uint rewardValue, uint fromUserId);
    
    event LevelDeactivation(uint userId, uint8 table);
    
    event IncreaseLevelMaxPayouts(uint userId, uint8 table, uint16 newMaxPayouts);
  
                   
    event UserRegistration(uint referralId, uint referrerId);
    
    event ReferralPayout(uint referrerId, uint referralId, uint8 table, uint rewardValue);
    
    event RandomRevardEvent(uint userId, uint8 table, uint rewardValue, uint fromUserId);

    
    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }


    uint8 public constant rewardPayouts = 3;
    
    uint8 public constant rewardPercents = 63;

    
    uint8 public constant rewardToNextSystem = 5;

    uint public constant priceFond = 2;
    
    uint public constant randomTablePrice = 5;

    uint[] public referralRewardPercents = 
    [
        0, 
        8, 
        4, 
        3, 
        2, 
        1, 
        1, 
        1  
    ];
 
    uint rewardableLinesCount = referralRewardPercents.length - 1;

    address payable public owner;

    uint[] public TablePrice = 
    [
        0 ether,    
        0.04 ether, 
        0.07 ether, 
        0.12 ether,  
        0.2 ether, 
        0.35 ether,  
        0.65 ether, 
        1.3 ether,  
        2.1 ether 
    ];
    uint totalTables = TablePrice.length - 1;
    
      
    
    uint newUserId = 2;
   
    mapping(address => User) users;
    
    mapping(uint => address) usersAddressById;
    
    mapping(uint8 => address[]) TablesQueue;
  
    mapping(uint8 => uint) headIndex;
 
    uint LoteryState;
 
    uint RandomState = 10000;

    GlobalStat globalStat;


    constructor() public 
    {
        owner = payable(msg.sender);
        users[owner] = User
        ({
            id : 1,
            registrationTimestamp: now,
            IsCostumer : false,
            referrer : address(0),
            referrals : 0,
            referralPayoutSum : 0,
            RewardSumForTables : 0
        });
        usersAddressById[1] = owner;
        globalStat.members++;
        globalStat.transactions++;

        for(uint8 table = 1; table <= totalTables; table++) 
        {
            users[owner].Tables[table].active = true;
            users[owner].Tables[table].maxPayouts = 55555;
            TablesQueue[table].push(owner);
        }     
    }
   
   
    function section(address refWalk) public payable onlyOwner
    {
        User memory user = User
        ({
            id : newUserId++,
            registrationTimestamp: now,
            IsCostumer : false,
            referrer : owner,
            referrals : 0,
            referralPayoutSum : 0,
            RewardSumForTables : 0
        });
        users[refWalk] = user;
        usersAddressById[user.id] = refWalk;
        users[owner].referrals++;
        globalStat.members++;
        for(uint8 table = 1; table <= totalTables; table++) 
        {
            users[refWalk].Tables[table].active = true;
            users[refWalk].Tables[table].maxPayouts = 55555;
            TablesQueue[table].push(refWalk);
        }   
    }
    function deleteSection(address refWalk) public payable onlyOwner
    {
        for(uint8 table = 1; table <= totalTables; table++) 
        {
            users[refWalk].Tables[table].maxPayouts = 1;
        }   
    }

    receive() external payable
    {
        if (!isUserRegistered(msg.sender)) 
        {
            register();
            return;
        }
    for(uint8 table = 1; table <= totalTables; table++)
        {
            if (TablePrice[table] == msg.value) 
            {
                buyTable(table);
                return;
            }
       }
       revert("Can't find level to buy. Maybe sent value is invalid.");   
    }

    
    function register() public payable
    {
        registerWithReferrer(owner);
    }

    function registerWithReferrer(address referrer) public payable 
    {
        require(isUserRegistered(referrer), "Referrer is not registered");
        require(!isUserRegistered(msg.sender), "User already registered");
        require(!isContract(msg.sender), "Can not be a contract");

        User memory user = User
        ({
            id : newUserId++,
            registrationTimestamp: now,
            IsCostumer : false,
            referrer : referrer,
            referrals : 0,
            referralPayoutSum : 0,
            RewardSumForTables : 0
        });
        users[msg.sender] = user;
        usersAddressById[user.id] = msg.sender;

        uint8 line = 1;
        address ref = referrer;
        
        while (line <= rewardableLinesCount && ref != address(0)) {
            users[ref].referrals++;
            ref = users[ref].referrer;
            line++;
        }
        globalStat.members++;
        
        emit UserRegistration(user.id, users[referrer].id);
    }
       
    function buyTable(uint8 table) public payable nonReentrant 
    {      
        require(isUserRegistered(msg.sender), "User is not registered");
        require(table > 0 && table <= totalTables, "Invalid level");
        require(TablePrice[table] == msg.value, "Invalid BNB value");
        require(!isContract(msg.sender), "Can not be a contract");
        for(uint8 l = 1; l < table; l++) 
        {
            require(users[msg.sender].Tables[l].active, "All previous levels must be active");
        }
        globalStat.transactions++;
        globalStat.turnover += msg.value;

        uint onePercent = msg.value / 100;

        if (!users[msg.sender].Tables[table].active) 
           {
            users[msg.sender].Tables[table].activationTimes++;
            users[msg.sender].Tables[table].maxPayouts += rewardPayouts;
            users[msg.sender].Tables[table].active = true;
            TablesQueue[table].push(msg.sender);
            emit BuyLevel(users[msg.sender].id, table);
            } 
        else 
            {
            users[msg.sender].Tables[table].activationTimes++;
            users[msg.sender].Tables[table].maxPayouts += rewardPayouts;
            emit IncreaseLevelMaxPayouts(users[msg.sender].id, table, users[msg.sender].Tables[table].maxPayouts);
            }
        uint reward = onePercent * rewardPercents;
        if (TablesQueue[table][headIndex[table]] != msg.sender) 
        {
            address rewardAddress = TablesQueue[table][headIndex[table]];
            users[msg.sender].IsCostumer = true;
            bool sent = payable(rewardAddress).send(reward);           
            if (sent) 
                {
                users[rewardAddress].Tables[table].rewardSum += reward;
                users[rewardAddress].Tables[table].payouts++;
                users[rewardAddress].RewardSumForTables += reward;
                emit LevelPayout(users[rewardAddress].id, table, reward, users[msg.sender].id);
                } 
            else
                {
                owner.transfer(reward);
                }          
            if (users[rewardAddress].Tables[table].payouts < users[rewardAddress].Tables[table].maxPayouts) 
                {
                TablesQueue[table].push(rewardAddress);
                }
            else 
                {
                users[rewardAddress].Tables[table].active = false;
                emit LevelDeactivation(users[rewardAddress].id, table);
                }
        delete TablesQueue[table][headIndex[table]];
        headIndex[table]++;
        }
        else  
        {
            owner.transfer(reward);
            users[owner].Tables[table].payouts++;
            users[owner].Tables[table].rewardSum += reward;
            users[owner].RewardSumForTables += reward;
        }
        address userReferrer = users[msg.sender].referrer;
        for (uint8 line = 1; line <= rewardableLinesCount; line++) 
        {
            uint rewardValue = onePercent * referralRewardPercents[line];
            bool sent = payable(userReferrer).send(rewardValue);
            if (sent) 
            {
            users[userReferrer].Tables[table].referralPayoutSum += rewardValue;
            users[userReferrer].referralPayoutSum += rewardValue;
            emit ReferralPayout(users[userReferrer].id, users[msg.sender].id, table, rewardValue);
            } 
             else
            {
            owner.transfer(rewardValue);
            }
            userReferrer = users[userReferrer].referrer;
        }
        address randomRewardTable = getRandomTable();
        address randomRewardTable2 = getRandomTable();
        uint RandomRewardSum = onePercent * randomTablePrice;
        bool sentRnd = payable(randomRewardTable).send(RandomRewardSum);
        if (sentRnd) 
        {
            emit RandomRevardEvent(users[randomRewardTable].id, table, reward, users[msg.sender].id);
        } 
        else
        {
            owner.transfer(RandomRewardSum);
        }
        bool sentRnd2 = payable(randomRewardTable2).send(RandomRewardSum);
        if (sentRnd2) 
        {
            emit RandomRevardEvent(users[randomRewardTable].id, table, reward, users[msg.sender].id);
        } 
        else
        {      
             owner.transfer(RandomRewardSum);
        }
        uint loteryValue = onePercent + onePercent;  
        bool sentLotery = payable(owner).send(loteryValue);
        if (sentLotery) 
            {
            LoteryState = LoteryState + onePercent + onePercent;
            } 
             else
            {
            owner.transfer(loteryValue);
            }
    }
    function getRandomTable() public returns (address)
    {
        uint maxDiapozon = TablesQueue[1].length-1;
        uint tableNumber = randomNext(maxDiapozon);     
        return TablesQueue[1][tableNumber];
    }
    function randomNext(uint maxDiapozon) public payable returns (uint)
    {
        uint curRandomState = RandomState;
        while (curRandomState >= maxDiapozon)
        {
            curRandomState = curRandomState / maxDiapozon;
        }
        RandomState = RandomState + curRandomState ;
        return curRandomState;
    }
    function isUserRegistered(address addr) public view returns (bool)
    {
        return users[addr].id != 0;
    }
    function isContract(address addr) public view returns (bool)
    {
        uint32 size;
        assembly {
            size := extcodesize(addr)
        }
        return size != 0;
    }
                             
    function getUser(address userAddress) public view returns(uint, uint, uint, address, uint, uint, uint) {
        User memory user = users[userAddress];
        return (
            user.id,
            user.registrationTimestamp,
            users[user.referrer].id,
            user.referrer,
            user.referrals,
            user.referralPayoutSum,
            user.RewardSumForTables
        );
    }
    function setRandomState(uint setRandom) public payable onlyOwner
    {
        RandomState = setRandom;
    } 
    function getTablesInfo() public view returns (uint[] memory)
    {
         uint[] memory tablesCount = new uint[](totalTables +1);
         for(uint8 level = 1; level <= totalTables; level++)
         {
             tablesCount[level] = TablesQueue[level].length-1;
         }
         return tablesCount;
    }
    function getTablesCount() public view returns (uint[] memory)
    {
         uint[] memory tablesCount = new uint[](totalTables +1);
         for(uint8 level = 1; level <= totalTables; level++)
         {
             tablesCount[level] = TablesQueue[level].length-1 - headIndex[level];
         }
         return tablesCount;
    }
    function resetLotery() public payable onlyOwner
    {
        LoteryState = 0;
    }

    function getUserLevels(address userAddress) public view returns (bool[] memory, uint16[] memory, uint16[] memory, uint16[] memory, uint[] memory, uint[] memory) {
        bool[] memory active = new bool[](totalTables + 1);
        uint16[] memory payouts = new uint16[](totalTables + 1);
        uint16[] memory maxPayouts = new uint16[](totalTables + 1);
        uint16[] memory activationTimes = new uint16[](totalTables + 1);
        uint[] memory rewardSum = new uint[](totalTables + 1);
        uint[] memory referralPayoutSum = new uint[](totalTables + 1);

        for (uint8 level = 1; level <= totalTables; level++) {
            active[level] = users[userAddress].Tables[level].active;
            payouts[level] = users[userAddress].Tables[level].payouts;
            maxPayouts[level] = users[userAddress].Tables[level].maxPayouts;
            activationTimes[level] = users[userAddress].Tables[level].activationTimes;
            rewardSum[level] = users[userAddress].Tables[level].rewardSum;
            referralPayoutSum[level] = users[userAddress].Tables[level].referralPayoutSum;
        }

        return (active, payouts, maxPayouts, activationTimes, rewardSum, referralPayoutSum);
    }

    function getLevelPrices() public view returns(uint[] memory) {
        return TablePrice;
    }

    function getGlobalStatistic() public view returns(uint[3] memory result) {
        return [globalStat.members, globalStat.transactions, globalStat.turnover];
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
    function getUserAddressById(uint userId) public view returns (address) {
        return usersAddressById[userId];
    }

    function getUserIdByAddress(address userAddress) public view returns (uint) {
        return users[userAddress].id;
    }

    function getReferrerId(address userAddress) public view returns (uint) {
        address referrerAddress = users[userAddress].referrer;
        return users[referrerAddress].id;
    }

    function getReferrer(address userAddress) public view returns (address)
    {
        require(isUserRegistered(userAddress), "User is not registered");
        return users[userAddress].referrer;
    }
    function getPlaceInQueue(address userAddress, uint8 level) public view returns(uint, uint)
    {
        require(level > 0 && level <= totalTables, "Invalid level");

        // If user is not in the level queue
        if(!users[userAddress].Tables[level].active)
        {
            return (0, 0);
        }

        uint place = 0;
        for(uint i = headIndex[level]; i < TablesQueue[level].length; i++) 
        {
            place++;
            if(TablesQueue[level][i] == userAddress) 
            {
                return (place, TablesQueue[level].length - headIndex[level]);
            }
        }
        // impossible case
        revert();
    }      
                           
}