// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;


    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}


contract CryptoTaxi is ReentrancyGuard {

enum RentLevelState{NOT_GRANTED, PENDING, GRANTED}

    struct User {
        uint id;
        uint registrationTimestamp;
        address referrer;
        uint referrals;
        uint referralPayoutSum;
        uint levelsRewardSum;
        uint missedReferralPayoutSum;
        mapping(uint8 => UserLevelInfo) levels;
    }

    struct UserLevelInfo {
        uint16 activationTimes;
        uint16 payouts;
        bool active;
        uint rewardSum;
        uint referralPayoutSum;
        uint buyLevelTime;
        mapping(uint16 => Rent) levelRents; //
    }

    struct Rent { //
        uint timeStampReceived;
        RentLevelState rentLevelState;
    }

    struct GlobalStat {
        uint members;
        uint transactions;
        uint turnover;
    }

    // User related events
    event BuyLevel(uint userId, uint8 level);
    event LevelPayout(uint userId, uint8 level, uint rewardValue, uint fromUserId);
    event LevelDeactivation(uint userId, uint8 level);
    event IncreaseLevelMaxPayouts(uint userId, uint8 level, uint16 newMaxPayouts);

    // Referrer related events
    event UserRegistration(uint referralId, uint referrerId);
    event ReferralPayout(uint referrerId, uint referralId, uint8 level, uint rewardValue);
    event MissedReferralPayout(uint referrerId, uint referralId, uint8 level, uint rewardValue);

    //time


    // event getLevelTime(uint userId, uint level, uint buyLevelTime);

    // Constants
    uint public constant REGISTRATION_PRICE = 0.025 ether;
    uint8 public constant REWARDPAYOUTS = 3;
    uint8 public constant REWARD_PERCENTS = 74;
    uint8 public constant TOKEN_BUYER_PERCENTS = 2;

    // Referral system (24%)
    uint[] public referralRewardPercents = [
        0, // none line
        8, // 1st line
        5, // 2nd line
        3, // 3rd line
        2, // 4th line
        1, // 5th line
        1, // 6th line
        1, // 7th line
        1, // 8th line
        1, // 9th line
        1  // 10th line
    ];
    uint rewardableLines = referralRewardPercents.length - 1;

    // Addresses
    address payable public owner;
    address payable public tokenBurner;

    // Levels
    uint[] public levelPrice = [
        0 ether,    // none level
        0.05 ether, // Level 1
        0.07 ether, // Level 2
        0.1 ether,  // Level 3
        0.14 ether, // Level 4
        0.2 ether,  // Level 5
        0.28 ether, // Level 6
        0.4 ether,  // Level 7
        0.55 ether, // Level 8
        0.8 ether,  // Level 9
        1.1 ether,  // Level 10
        1.6 ether,  // Level 11
        2.2 ether,  // Level 12
        3.2 ether,  // Level 13
        4.4 ether,  // Level 14
        6.5 ether,  // Level 15
        8 ether,    // Level 16
        10 ether,   // Level 17
        12.5 ether, // Level 18
        16 ether,   // Level 19
        20 ether    // Level 20
    ];
    mapping(uint8 => uint) minTotalUsersForLevel;
    uint totalLevels = levelPrice.length - 1;

    // State variables
    uint newUserId = 2;
    mapping(address => User) users;
    mapping(uint => address) usersAddressById;
    mapping(uint8 => address[]) levelQueue;
    mapping(uint8 => uint) headIndex;
    GlobalStat globalStat;

    constructor(address payable _tokenBurner) {
        owner = payable(msg.sender);
        tokenBurner = _tokenBurner;

        minTotalUsersForLevel[18] = 25000;  // min 25k users
        minTotalUsersForLevel[19] = 50000;  // min 50k users
        minTotalUsersForLevel[20] = 100000; // min 100k users

        // Register owner
        users[owner].id = 1;
        users[owner].registrationTimestamp = block.timestamp;
        users[owner].referrer = address(0);
        usersAddressById[1] = owner;
        globalStat.members++;
        globalStat.transactions++;

        for(uint8 level = 1; level <= totalLevels; level++) {
            users[owner].levels[level].active = true;
            users[owner].levels[level].levelRents[0].rentLevelState = RentLevelState.NOT_GRANTED;
            levelQueue[level].push(owner);
        }
    }



    receive() external payable {

        if (!isUserRegistered(msg.sender)) {
            register();
            return;
        }


        for(uint8 level = 1; level <= totalLevels; level++) {
            if (levelPrice[level] == msg.value) {
                buyLevel(level);
                return;
            }
        }

        revert("Can't find level to buy. Maybe sent value is invalid.");
    }

    function transferPayout (uint8 level) public payable {
        require(isUserRegistered(msg.sender), "Please, register");

        require(block.timestamp >= users[msg.sender].levels[level].buyLevelTime + 1 days, "24 hours did not expire yet");
        require(users[msg.sender].levels[level].active, "You have not bought this level");

        uint timeForRentPayout = users[msg.sender].levels[level].buyLevelTime;
        uint onePercent = levelPrice[level] / 100;
        uint reward = onePercent * REWARD_PERCENTS;

        for(uint16 i = 0; i < REWARDPAYOUTS; i++) {
            if(users[msg.sender].levels[level].levelRents[i].rentLevelState == RentLevelState.GRANTED) {
                timeForRentPayout = users[msg.sender].levels[level].levelRents[i].timeStampReceived;
                continue;
            }

            require(users[msg.sender].levels[level].levelRents[i].rentLevelState == RentLevelState.PENDING, "Not granted");
            require(block.timestamp >= timeForRentPayout + 1 minutes, "1 minute did not expire yet");


            bool sent = payable(msg.sender).send(reward);
            users[msg.sender].levels[level].levelRents[i].timeStampReceived = block.timestamp;
            users[msg.sender].levels[level].levelRents[i].rentLevelState = RentLevelState.GRANTED;

            if (sent) {
                // Update head user statistic
                users[msg.sender].levels[level].rewardSum += reward;
                users[msg.sender].levels[level].payouts++;
                users[msg.sender].levelsRewardSum += reward;
                emit LevelPayout(users[msg.sender].id, level, reward, users[msg.sender].id);
            } else {
                // Only if rewardAddress is smart contract (not a common case)
                owner.transfer(reward);
            }

            break;
        }

            // Send reward to owner
            // owner.transfer(reward);
            // users[owner].levels[level].payouts++;
            // users[owner].levels[level].rewardSum += reward;
            // users[owner].levelsRewardSum += reward;

        // uint reward = levelPrice[level] * 25 / 100;
        // _to.transfer(reward);
    }

    function register() public payable {
        registerWithReferrer(owner);
    }

    function registerWithReferrer(address referrer) public payable {
        require(msg.value == REGISTRATION_PRICE, "Invalid value sent");
        require(isUserRegistered(referrer), "Referrer is not registered");
        require(!isUserRegistered(msg.sender), "User already registered");
        require(!isContract(msg.sender), "Can not be a contract");

        users[msg.sender].id = 1;
        users[msg.sender].registrationTimestamp = block.timestamp;
        users[msg.sender].referrer = address(0);
        usersAddressById[users[msg.sender].id] = msg.sender;

        uint8 line = 1;
        address ref = referrer;
        while (line <= rewardableLines && ref != address(0)) {
            users[ref].referrals++;
            ref = users[ref].referrer;
            line++;
        }

        (bool success, ) = tokenBurner.call{value: msg.value}("");
        require(success, "token burn failed while registration");

        globalStat.members++;
        globalStat.transactions++;
        emit UserRegistration(users[msg.sender].id, users[referrer].id); /////???????
    }

    function buyLevel(uint8 level) public payable nonReentrant {
        require(isUserRegistered(msg.sender), "User is not registered");
        require(level > 0 && level <= totalLevels, "Invalid level");
        require(levelPrice[level] == msg.value, "Invalid BNB value");
        require(globalStat.members >= minTotalUsersForLevel[level], "Level not available yet");
        require(!isContract(msg.sender), "Can not be a contract");

        for(uint8 l = 1; l < level; l++) {
            require(users[msg.sender].levels[l].active, "All previous levels must be active");
        } //проверяем все этажи до вызываемого, активны ли они. если нет то выдаем ошибку

        // Update global stat
        globalStat.transactions++; //в глобальном стейте у нас members, transactions, turnover
        globalStat.turnover += msg.value; //увеличиваем показатель оборота в глобальном стейте на сумму покупки

        // If sender level is not active
        if (!users[msg.sender].levels[level].active) {
            // Activate level
            users[msg.sender].levels[level].active = true; //активируем этаж
            users[msg.sender].levels[level].buyLevelTime = block.timestamp;// //присваиваем время покупки

            for(uint16 j = 0; j < 3; j++) {
                users[msg.sender].levels[level].levelRents[j].rentLevelState = RentLevelState.NOT_GRANTED;//всем 3м выплатам этажа присвоить статус not granted
            }

            // Add user to level queue
            levelQueue[level].push(msg.sender); //добавить покупателя в очередь этажа
            emit BuyLevel(users[msg.sender].id, level);
        }

        address firstUserInQueue = levelQueue[level][0];

        // Increase user level maxPayouts


        users[firstUserInQueue].levels[level].levelRents[users[firstUserInQueue].levels[level].activationTimes].rentLevelState = RentLevelState.PENDING; // !! этаж активен, переводим статус выплаты в ожидание
        users[firstUserInQueue].levels[level].activationTimes++; // увеличиваем количество активаций на 1

        if (users[firstUserInQueue].levels[level].activationTimes == REWARDPAYOUTS) {
            users[firstUserInQueue].levels[level].active = false;
            users[firstUserInQueue].levels[level].activationTimes = 0;

            for(uint16 j = 0; j < 3; j++) {
                users[firstUserInQueue].levels[level].levelRents[j].rentLevelState = RentLevelState.NOT_GRANTED;//всем 3м выплатам этажа присвоить статус not granted
            }

            emit LevelDeactivation(users[firstUserInQueue].id, level);
        }

        // Calc reward to first user in queue


        // Shift level head index
        //delete levelQueue[level][headIndex[level]]; //удалить из очереди предыдущего

            //headIndex[level]++; //переводим первого в очереди на следующего

            for(uint s = 0; s < levelQueue[level].length - 1; s++) {
                address temp = levelQueue[level][s];
                levelQueue[level][s] = levelQueue[level][s + 1];
                levelQueue[level][s + 1] = temp;
            }

        // If head user is not sender (user can't get a reward from himself)


        // Send referral payouts
        uint onePercent = levelPrice[level] / 100;

        for (uint8 line = 1; line <= rewardableLines; line++) {
            uint rewardValue = onePercent * referralRewardPercents[line];
            sendRewardToReferrer(msg.sender, line, level, rewardValue);
        }

        // // Buy and burn tokens
        (bool success, ) = tokenBurner.call{value: onePercent * TOKEN_BUYER_PERCENTS}("");
        require(success, "token burn failed to buy level");
    }

    function getLevelTime(uint8 level) view public returns(uint) {
        return users[msg.sender].levels[level].buyLevelTime;
    }



    function sendRewardToReferrer(address userAddress, uint8 line, uint8 level, uint rewardValue) private {
        require(line > 0, "Line must be greater than zero");

        uint8 curLine = 1;
        address referrer = users[userAddress].referrer;
        while (curLine != line && referrer != owner) {
            referrer = users[referrer].referrer;
            curLine++;
        }

        while (!users[referrer].levels[level].active && referrer != owner) {
            users[referrer].missedReferralPayoutSum += rewardValue;
            emit MissedReferralPayout(users[referrer].id, users[userAddress].id, level, rewardValue);

            referrer = users[referrer].referrer;
        }

        bool sent = payable(referrer).send(rewardValue);
        if (sent) {
            users[referrer].levels[level].referralPayoutSum += rewardValue;
            users[referrer].referralPayoutSum += rewardValue;
            emit ReferralPayout(users[referrer].id, users[userAddress].id, level, rewardValue);
        } else {
            // Only if referrer is smart contract (not a common case)
            owner.transfer(rewardValue);
        }
    }

    // In case if we would like to migrate to Pancake Router V3
    function setTokenBurner(address payable _tokenBurner) public {
        require(msg.sender == owner, "Only owner can update tokenBurner address");
        tokenBurner = _tokenBurner;
    }


    function getUser(address userAddress) public view returns(uint, uint, uint, address, uint, uint, uint) {
        return (
            users[userAddress].id,
            users[userAddress].registrationTimestamp,
            users[users[userAddress].referrer].id,
            users[userAddress].referrer,
            users[userAddress].referrals,
            users[userAddress].referralPayoutSum,
            users[userAddress].levelsRewardSum
        );
    }

    function getUserLevels(address userAddress) public view returns (bool[] memory, uint16[] memory, uint16[] memory, uint16[] memory, uint[] memory, uint[] memory) {
        bool[] memory active = new bool[](totalLevels + 1);
        uint16[] memory payouts = new uint16[](totalLevels + 1);
        uint16[] memory maxPayouts = new uint16[](totalLevels + 1);
        uint16[] memory activationTimes = new uint16[](totalLevels + 1);
        uint[] memory rewardSum = new uint[](totalLevels + 1);
        uint[] memory referralPayoutSum = new uint[](totalLevels + 1);

        for (uint8 level = 1; level <= totalLevels; level++) {
            active[level] = users[userAddress].levels[level].active;
            payouts[level] = users[userAddress].levels[level].payouts;
            activationTimes[level] = users[userAddress].levels[level].activationTimes;
            rewardSum[level] = users[userAddress].levels[level].rewardSum;
            referralPayoutSum[level] = users[userAddress].levels[level].referralPayoutSum;
        }

        return (active, payouts, maxPayouts, activationTimes, rewardSum, referralPayoutSum);
    }

    function getLevelPrices() public view returns(uint[] memory) {
        return levelPrice;
    }

    function getGlobalStatistic() public view returns(uint[3] memory result) {
        return [globalStat.members, globalStat.transactions, globalStat.turnover];
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }

    function isUserRegistered(address addr) public view returns (bool) {
        return users[addr].id != 0;
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

    function getReferrer(address userAddress) public view returns (address) {
        require(isUserRegistered(userAddress), "User is not registered");
        return users[userAddress].referrer;
    }


    function getQueueOrder(uint8 level) public view returns(uint[] memory) {
        uint [] memory usersIds = new uint[] (levelQueue[level].length);
        for(uint i = 0; i < levelQueue[level].length; i++) {
            usersIds[i] = users[levelQueue[level][i]].id;
        }
        return usersIds;
    }

    function getPlaceInQueue(address userAddress, uint8 level) public view returns(uint) {
        require(level > 0 && level <= totalLevels, "Invalid level");

        // If user is not in the level queue
        if(!users[userAddress].levels[level].active) {
            return 0;
        }

        for(uint i = 0; i < levelQueue[level].length; i++) {

            if(levelQueue[level][i] == userAddress) {
                return i + 1;
            }
        }

        // impossible case
        revert();
    }

    function isContract(address addr) public view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(addr)
        }
        return size != 0;
    }
}