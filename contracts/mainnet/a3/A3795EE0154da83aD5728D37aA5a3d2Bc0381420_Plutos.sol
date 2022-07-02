/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


contract Plutos is ReentrancyGuard {
    
    struct User {
        uint id;
        uint regDate;
        address referrer;
        address[] refs;
        uint referrals;
        uint referralPayoutSum;
        uint levelsRewardSum;
        uint missedReferralPayoutSum;
        mapping(uint8 => UserLevelInfo) levels;
    }

    struct UserLevelInfo {
        uint16 activationTimes;
        uint16 maxPayouts;
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
    event BuyLevel(uint indexed userId, uint8 level,uint timestamp);
    event LevelPayout(uint indexed userId, uint8 level, uint rewardValue,uint timestamp);
    event LevelDeactivation(uint indexed userId, uint8 level,uint timestamp);

    // Referrer related events
    event UserRegistration(uint indexed userId, uint indexed referrerId,uint256 timestamp);
    event ReferralPayout(uint indexed userId, uint referralId, uint8 level, uint rewardValue,uint256 timestamp);
    event MissedReferralPayout(uint indexed userId, uint referralId, uint8 level, uint rewardValue,uint256 timestamp);

    // Constants
    uint8 public constant rewardPayouts = 2;
    uint8 public constant rewardPercents = 74;

    // Referral system (24%)
    uint[] public referralRewardPercents = [
        0, // none line
        13, // 1st line
        8, // 2nd line
        5 // 3nd line
    ];
    uint rewardableLines = referralRewardPercents.length - 1;

    // Addresses
    address public owner;
    //address payable public tokenBurner;

    // Levels
    uint[] public levelPrice = [
        0 ether,    // none level
        0.15 ether, // Level 1
        0.22 ether, // Level 2
        0.32 ether,  // Level 3
        0.47 ether, // Level 4
        0.69 ether,  // Level 5
        1 ether, // Level 6
        1.45 ether,  // Level 7
        2.1 ether, // Level 8
        3.1 ether,  // Level 9
        4.5 ether,  // Level 10
        6.6 ether,  // Level 11
        9.7 ether,  // Level 12
        14.3 ether,  // Level 13
        21 ether,  // Level 14
        31 ether,  // Level 15
        45.8 ether,    // Level 16
        67.7 ether,   // Level 17
        100 ether, // Level 18
        150 ether,   // Level 19
        222 ether    // Level 20
    ];
    uint totalLevels = levelPrice.length - 1;

    // State variables
    uint newUserId = 2;
    mapping(address => User) users;
    mapping(uint => address) usersAddressById;
    mapping(uint8 => address[]) levelQueue;
    mapping(uint8 => uint) headIndex;
    GlobalStat globalStat;

    constructor() {
        owner = msg.sender;
        User storage newUser = users[owner];
        // Register owner
        newUser.id = 1;
        newUser.regDate = block.timestamp;
        newUser.referrer = address(0);
        newUser.refs.push(address(0));
        newUser.referrals = 0;
        newUser.referralPayoutSum = 0;
        newUser.levelsRewardSum = 0;
        newUser.missedReferralPayoutSum = 0;
        for(uint8 level = 1; level <= totalLevels; level++) {
            newUser.levels[level].active = true;
            newUser.levels[level].maxPayouts = 50000;
            levelQueue[level].push(owner);
            levelQueue[level].push(owner);
            headIndex[level] = 0;
        }
        usersAddressById[1] = owner;
        globalStat.members++;
        globalStat.transactions++;
        emit UserRegistration(1, 0,block.timestamp);
    }

    receive() external payable {
        if (!isUserRegistered(msg.sender)&&levelPrice[1] == msg.value) {
            register(msg.sender,owner);
        }
        for(uint8 level = 1; level <= totalLevels; level++) {            
            if (levelPrice[level] == msg.value) {
                buyLevel(level);
                return;
            }
        }
        revert("Can't find level to buy. Maybe sent value is invalid.");
    }
    
    function registerWithReferrer(uint id) public payable {
        require(levelPrice[1] == msg.value, "Invalid BNB value");
        if (!isUserRegistered(msg.sender)) {
            address referrer = getUserAddressById(id);
            if (!isUserRegistered(referrer)) {
                referrer = owner;
            }
            register(msg.sender,referrer);
        }
        buyLevel(1);
    }

    function register(address userAddr, address referrer) private {
        User storage newUser = users[userAddr];
        newUser.id = newUserId++;
        newUser.regDate = block.timestamp;
        newUser.referrer = referrer;
        newUser.refs.push(address(0));
        newUser.referrals = 0;
        newUser.referralPayoutSum = 0;
        newUser.levelsRewardSum = 0;
        newUser.missedReferralPayoutSum = 0;
        users[referrer].referrals++;
        users[referrer].refs.push(userAddr);
        usersAddressById[newUser.id] = msg.sender;
        globalStat.members++;

        emit UserRegistration(newUser.id, users[referrer].id,block.timestamp);
    }

    function buyLevel(uint8 level) public payable nonReentrant {
        require(level > 0 && level <= totalLevels, "Invalid level");
        require(levelPrice[level] == msg.value, "Invalid BNB value");
        require(!isContract(msg.sender), "Can not be a contract");
        require(isUserRegistered(msg.sender), "User is not registered yet");
        for(uint8 l = 1; l < level; l++) {
            require(users[msg.sender].levels[l].active, "All previous levels must be active");
        }

        // Update global stat
        globalStat.transactions++;
        globalStat.turnover += msg.value;

        // Calc 1% from level price
        uint onePercent = msg.value / 100;

        // Calc reward to first user in queue
        uint reward = onePercent * rewardPercents;

        // Send reward to first user in queue
        address rewardAddress = levelQueue[level][headIndex[level]];
        bool sent = payable(rewardAddress).send(reward);
        if (sent) {
            // Update user statistic
            users[rewardAddress].levels[level].rewardSum += reward;
            users[rewardAddress].levels[level].maxPayouts--;
            users[rewardAddress].levelsRewardSum += reward;
            emit LevelPayout(users[rewardAddress].id, level, reward,block.timestamp);
        } else {
            // Only if rewardAddress is smart contract (not a common case)
            payable(owner).transfer(reward);
        }
        //Move the queue
        headIndex[level]++;
        // Add user to queue
        levelQueue[level].push(msg.sender);

        // If sender level is not active
        if (!users[msg.sender].levels[level].active) {
            // Activate level
            users[msg.sender].levels[level].active = true;
            }
            users[msg.sender].levels[level].activationTimes++;
            users[msg.sender].levels[level].maxPayouts += rewardPayouts;
            emit BuyLevel(users[msg.sender].id, level,block.timestamp);
   
        // If head user has not reached the maxPayouts yet
        if (users[rewardAddress].levels[level].maxPayouts > 0) {
            // Add user to end of level queue
            levelQueue[level].push(rewardAddress);
        } else {
            // Deactivate level
            emit LevelDeactivation(users[rewardAddress].id, level,block.timestamp);
        }
        // Send referral bonus
        sendRewardToReferrer(msg.sender, level);
       
    }

    function sendRewardToReferrer(address userAddress, uint8 level) private {
        require(level > 0, "Line must be greater than zero");
        uint rewardValue = 0;
        address referrer = users[userAddress].referrer;
        for(uint8 refln = 1; refln <= rewardableLines; refln++) {
            rewardValue = levelPrice[level]*referralRewardPercents[refln]/100;
            if (users[referrer].levels[level].active) {
                bool sent = payable(referrer).send(rewardValue);
                if (sent) {
                    users[referrer].levels[level].referralPayoutSum += rewardValue;
                    users[referrer].referralPayoutSum += rewardValue;
                    emit ReferralPayout(users[referrer].id, users[userAddress].id, level, rewardValue,block.timestamp);
                } else {
                    // Referrer is smart contract? (not a common case)
                    payable(owner).transfer(rewardValue);
                }
            }
            else {
                //Level is not activated
                users[referrer].missedReferralPayoutSum += rewardValue;
                emit MissedReferralPayout(users[referrer].id, users[userAddress].id, level, rewardValue,block.timestamp);
                payable(owner).transfer(rewardValue);
            }
            if (referrer != owner) {
                referrer = users[referrer].referrer;
            }
        }
    }

    function getReferals(address userAddress) public view returns(uint[] memory,uint[] memory,uint8[] memory,address[] memory,uint[] memory) {
        require(users[userAddress].referrals > 0, "You have no referrals");
        uint[] memory refDate = new uint[](users[userAddress].referrals);
        uint[] memory refId = new uint[](users[userAddress].referrals);
        uint8[] memory active = new uint8[](users[userAddress].referrals);
        address[] memory refAddr = new address[](users[userAddress].referrals);
        uint[] memory refCount = new uint[](users[userAddress].referrals);

        for (uint8 refs = 0; refs <= users[userAddress].referrals-1; refs++) {
            address ref = users[userAddress].refs[refs+1];
            uint8 activated = 1;
            for (uint8 level = 2; level <= totalLevels; level++) {
                if (users[ref].levels[level].active) {activated++;}
            }   
            refDate[refs] = users[ref].regDate;
            refId[refs] = users[ref].id;
            active[refs] = activated;
            refAddr[refs] = ref;
            refCount[refs] = users[ref].referrals;
        }    
        return (refDate, refId, active, refAddr, refCount);
    }

    function getUser(address userAddress) public view returns(uint, uint, uint, uint, uint, uint) {    
        return (
            users[userAddress].id,
            users[userAddress].regDate,
            users[userAddress].referrals,
            users[userAddress].referralPayoutSum,
            users[userAddress].levelsRewardSum,
            users[userAddress].missedReferralPayoutSum
        );
    }

    function getUserLevels(address userAddress) public view returns (bool[] memory,  uint16[] memory, uint16[] memory, uint[] memory, uint[] memory) {
        bool[] memory active = new bool[](totalLevels + 1);
        uint16[] memory maxPayouts = new uint16[](totalLevels + 1);
        uint16[] memory activationTimes = new uint16[](totalLevels + 1);
        uint[] memory rewardSum = new uint[](totalLevels + 1);
        uint[] memory referralPayoutSum = new uint[](totalLevels + 1);

        for (uint8 level = 1; level <= totalLevels; level++) {
            active[level] = users[userAddress].levels[level].active;
            maxPayouts[level] = users[userAddress].levels[level].maxPayouts;
            activationTimes[level] = users[userAddress].levels[level].activationTimes;
            rewardSum[level] = users[userAddress].levels[level].rewardSum;
            referralPayoutSum[level] = users[userAddress].levels[level].referralPayoutSum;
        }

        return (active, maxPayouts, activationTimes, rewardSum, referralPayoutSum);
    }

    function getLevelPrices() public view returns(uint[] memory) {
        return levelPrice;
    }

    function getGlobalStatistic() public view returns(uint[3] memory result) {
        return [globalStat.members, globalStat.transactions, globalStat.turnover];
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

    function getReferrer(address userAddress) public view returns (address,uint) {
        require(isUserRegistered(userAddress), "User is not registered");
        return (users[userAddress].referrer,users[users[userAddress].referrer].id);
    }

    function getPlaceInQueue(address userAddress, uint8 level) public view returns(uint) {
        require(level > 0 && level <= totalLevels, "Invalid level");
        require(users[userAddress].levels[level].active, "Not activated level");
        require(users[userAddress].levels[level].maxPayouts > 0, "Not in queue");
        for(uint i = headIndex[level]; i <= levelQueue[level].length-headIndex[level]-1; i++) {
            if(levelQueue[level][i] == userAddress) {
                return i;
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