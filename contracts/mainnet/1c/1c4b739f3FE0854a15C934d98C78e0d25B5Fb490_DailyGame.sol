/**
 *Submitted for verification at BscScan.com on 2022-06-16
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

// OFFICIAL WEBSITE: https://smartdailygame.com/

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

contract DailyGame is ReentrancyGuard {
    struct User {
        uint256 id;
        uint256 registrationTimestamp;
        address referrer;
        uint256 referrals;
        uint256 referralPayoutSum;
        uint256 levelsRewardSum;
        uint256 missedReferralPayoutSum;
        mapping(uint8 => UserLevelInfo) levels;
    }

    struct UserLevelInfo {
        uint16 activationTimes;
        uint16 maxPayouts;
        uint16 payouts;
        bool active;
        uint256 rewardSum;
        uint256 referralPayoutSum;
    }

    struct GlobalStat {
        uint256 members;
        uint256 transactions;
        uint256 turnover;
    }

    struct DayStat {
        uint256 day;
        uint256 members;
        uint256 transactions;
        uint256 turnover;
    }

    event BuyLevel(uint256 userId, uint8 level);
    event LevelPayout(
        uint256 userId,
        uint8 level,
        uint256 rewardValue,
        uint256 fromUserId
    );
    event LevelDeactivation(uint256 userId, uint8 level);
    event IncreaseLevelMaxPayouts(
        uint256 userId,
        uint8 level,
        uint16 newMaxPayouts
    );

    event UserRegistration(uint256 referralId, uint256 referrerId);
    event ReferralPayout(
        uint256 referrerId,
        uint256 referralId,
        uint8 level,
        uint256 rewardValue
    );
    event MissedReferralPayout(
        uint256 referrerId,
        uint256 referralId,
        uint8 level,
        uint256 rewardValue
    );

    uint256 public constant registrationPrice = 0.01 ether;
    uint8 public constant rewardPayouts = 3;
    uint8 public constant rewardPercents = 80;

    uint256[] public referralRewardPercents = [
        0,
        5,
        3,
        2
    ];
    uint256 rewardableLines = referralRewardPercents.length - 1;

    address payable public owner;
    address payable public tokenBurner;


    uint256[] public levelPrice = [
        0 ether,
        0.05 ether,
        0.075 ether,
        0.1 ether,
        0.125 ether,
        0.15 ether,
        0.175 ether,
        0.2 ether,
        0.25 ether,
        0.3 ether,
        0.5 ether,
        0.8 ether,
        1 ether,
        1.5 ether,
        0.05 ether,
        0.085 ether,
        0.12 ether,
        0.155 ether,
        0.19 ether,
        0.225 ether,
        0.26 ether,
        0.3 ether,
        0.35 ether,
        0.55 ether,
        0.85 ether,
        1.1 ether,
        1.6 ether,
        0.05 ether,
        0.095 ether,
        0.14 ether,
        0.185 ether,
        0.23 ether,
        0.275 ether,
        0.3 ether,
        0.37 ether,
        0.42 ether,
        0.66 ether,
        0.96 ether,
        1.16 ether,
        1.66 ether,
        0.08 ether,
        0.135 ether,
        0.19 ether,
        0.245 ether,
        0.3 ether,
        0.355 ether,
        0.4 ether,
        0.5 ether,
        0.8 ether,
        1.1 ether,
        1.4 ether,
        1.6 ether,
        2.1 ether,
        0.08 ether,
        0.145 ether,
        0.21 ether, 
        0.275 ether, 
        0.34 ether, 
        0.405 ether, 
        0.47 ether, 
        0.6 ether, 
        0.9 ether, 
        1.2 ether, 
        1.5 ether, 
        1.7 ether, 
        2.2 ether, 
        0.12 ether, 
        0.175 ether, 
        0.25 ether,
        0.325 ether, 
        0.4 ether, 
        0.475 ether, 
        0.6 ether, 
        0.9 ether, 
        1.2 ether, 
        1.5 ether, 
        1.8 ether, 
        2 ether, 
        2.5 ether, 
        0.15 ether, 
        0.205 ether, 
        0.29 ether, 
        0.375 ether, 
        0.46 ether, 
        0.545 ether, 
        0.7 ether, 
        1 ether, 
        1.3 ether, 
        1.6 ether, 
        1.9 ether, 
        2.4 ether, 
        3 ether 
    ];

    uint256[] public levelAllowedTime = [
        0,
        1655622000 + (86400 * 0) + (3600 * 0),
        1655622000 + (86400 * 0) + (3600 * 1),
        1655622000 + (86400 * 0) + (3600 * 2),
        1655622000 + (86400 * 0) + (3600 * 3),
        1655622000 + (86400 * 0) + (3600 * 4),
        1655622000 + (86400 * 0) + (3600 * 5),
        1655622000 + (86400 * 0) + (3600 * 6),
        1655622000 + (86400 * 0) + (3600 * 7),
        1655622000 + (86400 * 0) + (3600 * 8),
        1655622000 + (86400 * 0) + (3600 * 9),
        1655622000 + (86400 * 0) + (3600 * 10),
        1655622000 + (86400 * 0) + (3600 * 11),
        1655622000 + (86400 * 0) + (3600 * 12),
        1655622000 + (86400 * 1) + (3600 * 0),
        1655622000 + (86400 * 1) + (3600 * 1),
        1655622000 + (86400 * 1) + (3600 * 2),
        1655622000 + (86400 * 1) + (3600 * 3),
        1655622000 + (86400 * 1) + (3600 * 4),
        1655622000 + (86400 * 1) + (3600 * 5),
        1655622000 + (86400 * 1) + (3600 * 6),
        1655622000 + (86400 * 1) + (3600 * 7),
        1655622000 + (86400 * 1) + (3600 * 8),
        1655622000 + (86400 * 1) + (3600 * 9),
        1655622000 + (86400 * 1) + (3600 * 10),
        1655622000 + (86400 * 1) + (3600 * 11),
        1655622000 + (86400 * 1) + (3600 * 12),
        1655622000 + (86400 * 2) + (3600 * 0),
        1655622000 + (86400 * 2) + (3600 * 1),
        1655622000 + (86400 * 2) + (3600 * 2),
        1655622000 + (86400 * 2) + (3600 * 3),
        1655622000 + (86400 * 2) + (3600 * 4),
        1655622000 + (86400 * 2) + (3600 * 5),
        1655622000 + (86400 * 2) + (3600 * 6),
        1655622000 + (86400 * 2) + (3600 * 7),
        1655622000 + (86400 * 2) + (3600 * 8),
        1655622000 + (86400 * 2) + (3600 * 9),
        1655622000 + (86400 * 2) + (3600 * 10),
        1655622000 + (86400 * 2) + (3600 * 11),
        1655622000 + (86400 * 2) + (3600 * 12),
        1655622000 + (86400 * 3) + (3600 * 0),
        1655622000 + (86400 * 3) + (3600 * 1),
        1655622000 + (86400 * 3) + (3600 * 2),
        1655622000 + (86400 * 3) + (3600 * 3),
        1655622000 + (86400 * 3) + (3600 * 4),
        1655622000 + (86400 * 3) + (3600 * 5),
        1655622000 + (86400 * 3) + (3600 * 6),
        1655622000 + (86400 * 3) + (3600 * 7),
        1655622000 + (86400 * 3) + (3600 * 8),
        1655622000 + (86400 * 3) + (3600 * 9),
        1655622000 + (86400 * 3) + (3600 * 10),
        1655622000 + (86400 * 3) + (3600 * 11),
        1655622000 + (86400 * 3) + (3600 * 12),
        1655622000 + (86400 * 4) + (3600 * 0),
        1655622000 + (86400 * 4) + (3600 * 1),
        1655622000 + (86400 * 4) + (3600 * 2),
        1655622000 + (86400 * 4) + (3600 * 3),
        1655622000 + (86400 * 4) + (3600 * 4),
        1655622000 + (86400 * 4) + (3600 * 5),
        1655622000 + (86400 * 4) + (3600 * 6),
        1655622000 + (86400 * 4) + (3600 * 7),
        1655622000 + (86400 * 4) + (3600 * 8),
        1655622000 + (86400 * 4) + (3600 * 9),
        1655622000 + (86400 * 4) + (3600 * 10),
        1655622000 + (86400 * 4) + (3600 * 11),
        1655622000 + (86400 * 4) + (3600 * 12),
        1655622000 + (86400 * 5) + (3600 * 0),
        1655622000 + (86400 * 5) + (3600 * 1),
        1655622000 + (86400 * 5) + (3600 * 2),
        1655622000 + (86400 * 5) + (3600 * 3),
        1655622000 + (86400 * 5) + (3600 * 4),
        1655622000 + (86400 * 5) + (3600 * 5),
        1655622000 + (86400 * 5) + (3600 * 6),
        1655622000 + (86400 * 5) + (3600 * 7),
        1655622000 + (86400 * 5) + (3600 * 8),
        1655622000 + (86400 * 5) + (3600 * 9),
        1655622000 + (86400 * 5) + (3600 * 10),
        1655622000 + (86400 * 5) + (3600 * 11),
        1655622000 + (86400 * 5) + (3600 * 12),
        1655622000 + (86400 * 6) + (3600 * 0),
        1655622000 + (86400 * 6) + (3600 * 1),
        1655622000 + (86400 * 6) + (3600 * 2),
        1655622000 + (86400 * 6) + (3600 * 3),
        1655622000 + (86400 * 6) + (3600 * 4),
        1655622000 + (86400 * 6) + (3600 * 5),
        1655622000 + (86400 * 6) + (3600 * 6),
        1655622000 + (86400 * 6) + (3600 * 7),
        1655622000 + (86400 * 6) + (3600 * 8),
        1655622000 + (86400 * 6) + (3600 * 9),
        1655622000 + (86400 * 6) + (3600 * 10),
        1655622000 + (86400 * 6) + (3600 * 11),
        1655622000 + (86400 * 6) + (3600 * 12)
    ];

    uint256 totalLevels = levelPrice.length - 1;

    uint256 newUserId = 2;
    mapping(address => User) users;
    mapping(uint256 => address) usersAddressById;
    mapping(uint8 => address[]) levelQueue;
    mapping(uint8 => uint256) headIndex;

    GlobalStat globalStat;
    DayStat dayStat;

    constructor(address payable _tokenBurner) public {
        owner = payable(msg.sender);
        tokenBurner = _tokenBurner;

        users[owner] = User({
            id: 1,
            registrationTimestamp: now,
            referrer: address(0),
            referrals: 0,
            referralPayoutSum: 0,
            levelsRewardSum: 0,
            missedReferralPayoutSum: 0
        });
        usersAddressById[1] = owner;
        globalStat.members++;
        globalStat.transactions++;

        uint256 _day = now / 86400;
        if (dayStat.day == 0) {
            dayStat.day = _day;
        } else if (dayStat.day != _day) {
            dayStat.day = _day;
            dayStat.members = 0;
            dayStat.transactions = 0;
            dayStat.turnover = 0;
        }

        dayStat.members++;
        dayStat.transactions++;

        for (uint8 level = 1; level <= totalLevels; level++) {
            users[owner].levels[level].active = true;
            users[owner].levels[level].maxPayouts = 50000;
            levelQueue[level].push(owner);
        }
    }

    receive() external payable {
        if (!isUserRegistered(msg.sender)) {
            register();
            return;
        }

        for (uint8 level = 1; level <= totalLevels; level++) {
            if (levelPrice[level] == msg.value) {
                buyLevel(level);
                return;
            }
        }

        revert("Can't find level to buy. Maybe sent value is invalid.");
    }

    function register() public payable {
        registerWithReferrer(owner);
    }

    function registerWithReferrer(address referrer) public payable {
        require(msg.value == registrationPrice, "Invalid value sent");
        require(isUserRegistered(referrer), "Referrer is not registered");
        require(!isUserRegistered(msg.sender), "User already registered");
        require(!isContract(msg.sender), "Can not be a contract");

        User memory user = User({
            id: newUserId++,
            registrationTimestamp: now,
            referrer: referrer,
            referrals: 0,
            referralPayoutSum: 0,
            levelsRewardSum: 0,
            missedReferralPayoutSum: 0
        });
        users[msg.sender] = user;
        usersAddressById[user.id] = msg.sender;

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

        uint256 _day = now / 86400;
        if (dayStat.day == 0) {
            dayStat.day = _day;
        } else if (dayStat.day != _day) {
            dayStat.day = _day;
            dayStat.members = 0;
            dayStat.transactions = 0;
            dayStat.turnover = 0;
        }

        dayStat.members++;
        dayStat.transactions++;

        emit UserRegistration(user.id, users[referrer].id);
    }

    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }

    function buyLevel(uint8 level) public payable nonReentrant {
        require(isUserRegistered(msg.sender), "User is not registered");
        require(level > 0 && level <= totalLevels, "Invalid level");
        require(levelPrice[level] == msg.value, "Invalid BNB value");
        require(!isContract(msg.sender), "Can not be a contract");

        uint256 _now_day = now / 86400;

        require(
            now > levelAllowedTime[level],
            uint2str(levelAllowedTime[level])
        );

        for (uint8 l = 1; l < level; l++) {
            uint256 _now_level_day = levelAllowedTime[l] / 86400;
            if (_now_day == _now_level_day) {
                require(
                    users[msg.sender].levels[l].active,
                    uint2str(_now_level_day)
                );
            } else if (_now_day < _now_level_day) {
                break;
            }
        }

        globalStat.transactions++;
        globalStat.turnover += msg.value;

        uint256 _day = now / 86400;
        if (dayStat.day == 0) {
            dayStat.day = _day;
        } else if (dayStat.day != _day) {
            dayStat.day = _day;
            dayStat.members = 0;
            dayStat.transactions = 0;
            dayStat.turnover = 0;
        }

        dayStat.transactions++;
        dayStat.turnover += msg.value;

        uint256 onePercent = msg.value / 100;

        if (!users[msg.sender].levels[level].active) {
            users[msg.sender].levels[level].activationTimes++;
            users[msg.sender].levels[level].maxPayouts = rewardPayouts;
            users[msg.sender].levels[level].active = true;

            levelQueue[level].push(msg.sender);
            emit BuyLevel(users[msg.sender].id, level);
        } else {
            users[msg.sender].levels[level].activationTimes++;
            users[msg.sender].levels[level].maxPayouts = rewardPayouts;
            emit IncreaseLevelMaxPayouts(
                users[msg.sender].id,
                level,
                users[msg.sender].levels[level].maxPayouts
            );
        }

        uint256 reward = onePercent * rewardPercents;

        if (levelQueue[level][headIndex[level]] != msg.sender) {
            address rewardAddress = levelQueue[level][headIndex[level]];
            bool sent = payable(rewardAddress).send(reward);
            if (sent) {
                users[rewardAddress].levels[level].rewardSum += reward;
                users[rewardAddress].levels[level].payouts++;
                users[rewardAddress].levelsRewardSum += reward;
                emit LevelPayout(
                    users[rewardAddress].id,
                    level,
                    reward,
                    users[msg.sender].id
                );
            } else {
                owner.transfer(reward);
            }

            if (
                users[rewardAddress].levels[level].payouts <
                users[rewardAddress].levels[level].maxPayouts
            ) {
                levelQueue[level].push(rewardAddress);
            } else {
                users[rewardAddress].levels[level].active = false;
                users[rewardAddress].levels[level].payouts = 0;
                emit LevelDeactivation(users[rewardAddress].id, level);
            }

            delete levelQueue[level][headIndex[level]];
            headIndex[level]++;
        } else {
            owner.transfer(reward);
            users[owner].levels[level].payouts++;
            users[owner].levels[level].rewardSum += reward;
            users[owner].levelsRewardSum += reward;
        }

        for (uint8 line = 1; line <= rewardableLines; line++) {
            uint256 rewardValue = onePercent * referralRewardPercents[line];
            sendRewardToReferrer(msg.sender, line, level, rewardValue);
        }

        uint256 rewardSystem = onePercent * 10;
        bool sent = payable(owner).send(rewardSystem);
        require(sent, "error when paying the commission to the system");
    }

    function sendRewardToReferrer(
        address userAddress,
        uint8 line,
        uint8 level,
        uint256 rewardValue
    ) private {
        require(line > 0, "Line must be greater than zero");

        uint8 curLine = 1;
        address referrer = users[userAddress].referrer;
        while (curLine != line && referrer != owner) {
            referrer = users[referrer].referrer;
            curLine++;
        }

        while (!users[referrer].levels[level].active && referrer != owner) {
            users[referrer].missedReferralPayoutSum += rewardValue;
            emit MissedReferralPayout(
                users[referrer].id,
                users[userAddress].id,
                level,
                rewardValue
            );
            referrer = users[referrer].referrer;
        }

        bool sent = payable(referrer).send(rewardValue);
        if (sent) {
            users[referrer].levels[level].referralPayoutSum += rewardValue;
            users[referrer].referralPayoutSum += rewardValue;
            emit ReferralPayout(
                users[referrer].id,
                users[userAddress].id,
                level,
                rewardValue
            );
        } else {
            owner.transfer(rewardValue);
        }
    }

    function setTokenBurner(address payable _tokenBurner) public {
        require(
            msg.sender == owner,
            "Only owner can update tokenBurner address"
        );
        tokenBurner = _tokenBurner;
    }

    function getUser(address userAddress)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            address,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        User memory user = users[userAddress];
        return (
            user.id,
            user.registrationTimestamp,
            users[user.referrer].id,
            user.referrer,
            user.referrals,
            user.referralPayoutSum,
            user.levelsRewardSum,
            user.missedReferralPayoutSum
        );
    }

    function getUserLevels(address userAddress)
        public
        view
        returns (
            bool[] memory,
            uint16[] memory,
            uint16[] memory,
            uint16[] memory,
            uint256[] memory,
            uint256[] memory
        )
    {
        bool[] memory active = new bool[](totalLevels + 1);
        uint16[] memory payouts = new uint16[](totalLevels + 1);
        uint16[] memory maxPayouts = new uint16[](totalLevels + 1);
        uint16[] memory activationTimes = new uint16[](totalLevels + 1);
        uint256[] memory rewardSum = new uint256[](totalLevels + 1);
        uint256[] memory referralPayoutSum = new uint256[](totalLevels + 1);

        for (uint8 level = 1; level <= totalLevels; level++) {
            active[level] = users[userAddress].levels[level].active;
            payouts[level] = users[userAddress].levels[level].payouts;
            maxPayouts[level] = users[userAddress].levels[level].maxPayouts;
            activationTimes[level] = users[userAddress]
                .levels[level]
                .activationTimes;
            rewardSum[level] = users[userAddress].levels[level].rewardSum;
            referralPayoutSum[level] = users[userAddress]
                .levels[level]
                .referralPayoutSum;
        }

        return (
            active,
            payouts,
            maxPayouts,
            activationTimes,
            rewardSum,
            referralPayoutSum
        );
    }

    function getLevelPrices() public view returns (uint256[] memory) {
        return levelPrice;
    }

    function getGlobalStatistic()
        public
        view
        returns (uint256[3] memory result)
    {
        return [
            globalStat.members,
            globalStat.transactions,
            globalStat.turnover
        ];
    }

    function getDayStatistic() public view returns (uint256[3] memory result) {
        return [dayStat.members, dayStat.transactions, dayStat.turnover];
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function isUserRegistered(address addr) public view returns (bool) {
        return users[addr].id != 0;
    }

    function getUserAddressById(uint256 userId) public view returns (address) {
        return usersAddressById[userId];
    }

    function getUserIdByAddress(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].id;
    }

    function getReferrerId(address userAddress) public view returns (uint256) {
        address referrerAddress = users[userAddress].referrer;
        return users[referrerAddress].id;
    }

    function getReferrer(address userAddress) public view returns (address) {
        require(isUserRegistered(userAddress), "User is not registered");
        return users[userAddress].referrer;
    }

    function getPlaceInQueue(address userAddress, uint8 level)
        public
        view
        returns (uint256, uint256)
    {
        require(level > 0 && level <= totalLevels, "Invalid level");

        if (!users[userAddress].levels[level].active) {
            return (0, 0);
        }

        uint256 place = 0;
        for (uint256 i = headIndex[level]; i < levelQueue[level].length; i++) {
            place++;
            if (levelQueue[level][i] == userAddress) {
                return (place, levelQueue[level].length - headIndex[level]);
            }
        }

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