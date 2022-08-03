// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

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

contract ContainersGame is ReentrancyGuard {
    struct User {
        uint id;
        uint time;
        address referrer;
        uint referrals;
        uint referralPayoutSum;
        uint containerRewardSum;
        uint missedReferralPayoutSum;
        mapping(uint8 => UserLevelInfo) containers;
    }

    struct UserLevelInfo {
        uint16 activationTimes;
        uint16 maxPayouts;
        uint16 payouts;
        bool active;
        uint rewardSum;
        uint referralPayoutSum;
    }

    struct TotalStat {
        uint users;
        uint operations;
        uint purchases;
    }

    event BuyContainer(uint userId, uint8 container);
    event ContainerPayout(uint userId, uint8 container, uint rewardValue, uint fromUserId);
    event ContainerDeactivation(uint userId, uint8 container);
    event IncContainerMaxPayouts(uint userId, uint8 container, uint16 newMaxPayouts);

    event Registration(uint referralId, uint referrerId);
    event ReferralPayout(uint referrerId, uint referralId, uint8 container, uint rewardValue);
    event MissedReferralPayout(uint referrerId, uint referralId, uint8 container, uint rewardValue);

    uint public constant certfPrice = 0.025 ether;
    uint8 public constant payCount = 3;
    uint8 public constant rewardPercents = 74;
    uint8 public constant tokenBuyerPercents = 2;

    uint[] public referralPercentageLevels = [
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
     // Container prices
    uint[] public containerPriceList = [
        0 ether,    // none container
        0.05 ether, // Container #1
        0.07 ether, // Container #2
        0.1 ether,  // Container #3
        0.14 ether, // Container #4
        0.2 ether,  // Container #5
        0.28 ether, // Container #6
        0.4 ether,  // Container #7
        0.55 ether, // Container #8
        0.8 ether,  // Container #9
        1.1 ether,  // Container #10
        1.6 ether,  // Container #11
        2.2 ether,  // Container #12
        3.2 ether,  // Container #13
        4.4 ether,  // Container #14
        6.5 ether,  // Container #15
        8 ether,    // Container #16
        10 ether,   // Container #17
        12.5 ether, // Container #18
        16 ether,   // Container #19
        20 ether    // Container #20
    ];

    address payable public owner;
    address payable public tokenBurner;

    mapping(uint8 => uint) minTotalUsersForContainer;
    uint referralLevelsNumber = referralPercentageLevels.length - 1;
    uint totalContainerCount = containerPriceList.length - 1;
    uint currentUID = 2;

    mapping(address => User) users;
    mapping(uint => address) usersAddressById;
    mapping(uint8 => address[]) rewardQueue;
    mapping(uint8 => uint) queuePos;
    TotalStat totalStat;

    constructor(address payable _tokenBurner) public {
        owner = payable(msg.sender);
        tokenBurner = _tokenBurner;

        minTotalUsersForContainer[18] = 25000;  // min 25k users
        minTotalUsersForContainer[19] = 50000;  // min 50k users
        minTotalUsersForContainer[20] = 100000; // min 100k users

        User storage u = users[msg.sender];
        u.id = 1;
        u.time = block.timestamp;
        u.referrer = address(0);
        u.referrals = 0;
        u.referralPayoutSum = 0;
        u.containerRewardSum = 0;
        u.missedReferralPayoutSum = 0;
        usersAddressById[1] = owner;
        totalStat.users++;
        totalStat.operations++;

        for(uint8 container = 1; container <= totalContainerCount; container++) {
            users[owner].containers[container].active = true;
            users[owner].containers[container].maxPayouts = 55555;
            rewardQueue[container].push(owner);
        }
    }

    receive() external payable {
        if (!isUserRegistered(msg.sender)) {
            register();
            return;
        }

        for(uint8 container = 1; container <= totalContainerCount; container++) {
            if (containerPriceList[container] == msg.value) {
                buyContainer(container);
                return;
            }
        }

        revert("Can't find container to buy.");
    }

    function register() public payable {
        partnerRegister(owner);
    }

    function partnerRegister(address referrer) public payable {
        require(msg.value == certfPrice, "Invalid value sent");
        require(!isContract(msg.sender), "Can not be a contract");
        require(!isUserRegistered(msg.sender), "User already registered");
        require(isUserRegistered(referrer), "Referrer is not registered");

        User storage u = users[msg.sender];
        u.id = currentUID++;
        u.time = block.timestamp;
        u.referrer = referrer;
        u.referrals = 0;
        u.referralPayoutSum = 0;
        u.containerRewardSum = 0;
        u.missedReferralPayoutSum = 0;
        usersAddressById[u.id] = msg.sender;

        uint8 referralLevel = 1;
        address ref = referrer;
        while (referralLevel <= referralLevelsNumber && ref != address(0)) {
            users[ref].referrals++;
            ref = users[ref].referrer;
            referralLevel++;
        }

        (bool success, ) = tokenBurner.call{value: msg.value}("");
        require(success, "token burn failed while registration");

        totalStat.users++;
        totalStat.operations++;
        emit Registration(u.id, users[referrer].id);
    }

    function buyContainer(uint8 container) public payable nonReentrant {
        require(isUserRegistered(msg.sender), "User is not registered");
        require(container > 0 && container <= totalContainerCount, "Invalid container number");
        require(containerPriceList[container] == msg.value, "Invalid BNB value");
        require(totalStat.users >= minTotalUsersForContainer[container], "Container not available yet");
        require(!isContract(msg.sender), "Can not be a contract");
        for(uint8 i = 1; i < container; i++) {
            require(users[msg.sender].containers[i].active, "All previous Containers must be active");
        }

        totalStat.operations++;
        totalStat.purchases += msg.value;

        uint percent = msg.value / 100;

        if (!users[msg.sender].containers[container].active) {
            users[msg.sender].containers[container].activationTimes++;
            users[msg.sender].containers[container].maxPayouts += payCount;
            users[msg.sender].containers[container].active = true;
            rewardQueue[container].push(msg.sender);
            emit BuyContainer(users[msg.sender].id, container);
        } else {
            users[msg.sender].containers[container].activationTimes++;
            users[msg.sender].containers[container].maxPayouts += payCount;
            emit IncContainerMaxPayouts(users[msg.sender].id, container, users[msg.sender].containers[container].maxPayouts);
        }

        uint reward = percent * rewardPercents;

        if (rewardQueue[container][queuePos[container]] != msg.sender) {
            address rewardAddress = rewardQueue[container][queuePos[container]];
            bool sent = payable(rewardAddress).send(reward);
            if (sent) {
                users[rewardAddress].containers[container].rewardSum += reward;
                users[rewardAddress].containers[container].payouts++;
                users[rewardAddress].containerRewardSum += reward;
                emit ContainerPayout(users[rewardAddress].id, container, reward, users[msg.sender].id);
            } else {
                owner.transfer(reward);
            }

            if (users[rewardAddress].containers[container].payouts < users[rewardAddress].containers[container].maxPayouts) {
                rewardQueue[container].push(rewardAddress);
            } else {
                users[rewardAddress].containers[container].active = false;
                emit ContainerDeactivation(users[rewardAddress].id, container);
            }

            delete rewardQueue[container][queuePos[container]];
            queuePos[container]++;
        } else {
            owner.transfer(reward);
            users[owner].containers[container].payouts++;
            users[owner].containers[container].rewardSum += reward;
            users[owner].containerRewardSum += reward;
        }

        for (uint8 line = 1; line <= referralLevelsNumber; line++) {
            uint rewardValue = percent * referralPercentageLevels[line];
            sendRewardToReferrer(msg.sender, line, container, rewardValue);
        }

        (bool success, ) = tokenBurner.call{value: percent * tokenBuyerPercents}("");
        require(success, "token burn failed while buy container");
    }

    function sendRewardToReferrer(address userAddress, uint8 line, uint8 container, uint rewardValue) private {
        require(line > 0, "Line must be greater than zero");

        uint8 curLine = 1;
        address referrer = users[userAddress].referrer;
        while (curLine != line && referrer != owner) {
            referrer = users[referrer].referrer;
            curLine++;
        }

        while (!users[referrer].containers[container].active && referrer != owner) {
            users[referrer].missedReferralPayoutSum += rewardValue;
            emit MissedReferralPayout(users[referrer].id, users[userAddress].id, container, rewardValue);

            referrer = users[referrer].referrer;
        }
        bool sent = payable(referrer).send(rewardValue);
        if (sent) {
            users[referrer].containers[container].referralPayoutSum += rewardValue;
            users[referrer].referralPayoutSum += rewardValue;
            emit ReferralPayout(users[referrer].id, users[userAddress].id, container, rewardValue);
        } else {
            owner.transfer(rewardValue);
        }
    }

    function setTokenBurner(address payable _tokenBurner) public {
        require(msg.sender == owner, "Only owner can update tokenBurner address");
        tokenBurner = _tokenBurner;
    }

    function getUser(address userAddress) public view returns(uint, uint, uint, address, uint, uint, uint, uint) {
        User storage user = users[userAddress];
        return (
            user.id,
            user.time,
            users[user.referrer].id,
            user.referrer,
            user.referrals,
            user.referralPayoutSum,
            user.containerRewardSum,
            user.missedReferralPayoutSum
        );
    }
    
    function getUserContainers(address userAddress) public view returns (bool[] memory, uint16[] memory, uint16[] memory, uint16[] memory, uint[] memory, uint[] memory) {
        bool[] memory active = new bool[](totalContainerCount + 1);
        uint16[] memory payouts = new uint16[](totalContainerCount + 1);
        uint16[] memory maxPayouts = new uint16[](totalContainerCount + 1);
        uint16[] memory activationTimes = new uint16[](totalContainerCount + 1);
        uint[] memory rewardSum = new uint[](totalContainerCount + 1);
        uint[] memory referralPayoutSum = new uint[](totalContainerCount + 1);

        for (uint8 container = 1; container <= totalContainerCount; container++) {
            active[container] = users[userAddress].containers[container].active;
            payouts[container] = users[userAddress].containers[container].payouts;
            maxPayouts[container] = users[userAddress].containers[container].maxPayouts;
            activationTimes[container] = users[userAddress].containers[container].activationTimes;
            rewardSum[container] = users[userAddress].containers[container].rewardSum;
            referralPayoutSum[container] = users[userAddress].containers[container].referralPayoutSum;
        }

        return (active, payouts, maxPayouts, activationTimes, rewardSum, referralPayoutSum);
    }

    function getContainerPrices() public view returns(uint[] memory) {
        return containerPriceList;
    }

    function getTotalStatistic() public view returns(uint[3] memory result) {
        return [totalStat.users, totalStat.operations, totalStat.purchases];
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

    function getPlaceInQueue(address userAddress, uint8 container) public view returns(uint, uint) {
        require(container > 0 && container <= totalContainerCount, "Invalid container");

        // If user is not in the container queue
        if(!users[userAddress].containers[container].active) {
            return (0, 0);
        }

        uint place = 0;
        for(uint i = queuePos[container]; i < rewardQueue[container].length; i++) {
            place++;
            if(rewardQueue[container][i] == userAddress) {
                return (place, rewardQueue[container].length - queuePos[container]);
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