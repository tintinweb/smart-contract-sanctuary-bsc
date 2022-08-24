// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

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

contract ShipGame is ReentrancyGuard {
    struct User {
        uint id;
        address partner;
        uint referrals;
        uint partnerPayoutSum;
        uint containerSubleaseSum;
        uint missedPartnerPayoutSum;
        mapping(uint8 => UserContainerInfo) containers;
        uint time;
    }

    struct UserContainerInfo {
        uint16 rentCount;
        uint16 maxSubleases;
        uint16 payouts;
        bool active;
        uint subleaseSum;
        uint partnerPayoutSum;
    }

    struct TotalStat {
        uint users;
        uint operations;
        uint rent;
    }

    event Registration(uint referralId, uint referrerId);
    event RentContainer(uint userId, uint8 container);
    event PartnerPayout(uint referrerId, uint referralId, uint8 container, uint partnerValue);
    event ContainerPayout(uint userId, uint8 container, uint partnerValue, uint fromUserId);
    event ContainerDeactivation(uint userId, uint8 container);
    event IncContainerMaxSubleases(uint userId, uint8 container, uint16 newMaxSubleases);
    event MissedPartnerPayout(uint referrerId, uint referralId, uint8 container, uint partnerValue);

    uint public constant certfPrice = 0.025 ether;
    uint8 public constant subleasesCount = 3;
    uint8 public constant subleasePercents = 74;
    uint8 public constant futurePercents = 2;

    uint[] public partnerPercentageList = [
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

    mapping(uint8 => uint) minUsersForRent;
    uint partnerLevelsNumber = partnerPercentageList.length - 1;
    uint totalContainerCount = containerPriceList.length - 1;
    uint currUserId = 2;

    mapping(address => User) users;
    mapping(uint => address) usersAddressById;
    mapping(uint8 => address[]) rentQueue;
    mapping(uint8 => uint) queuePos;
    TotalStat totalStat;

    constructor(address payable _tokenBurner) {
        owner = payable(msg.sender);
        tokenBurner = _tokenBurner;

        minUsersForRent[18] = 25000;  
        minUsersForRent[19] = 50000;  
        minUsersForRent[20] = 100000; 

        User storage u = users[msg.sender];
        u.id = 1;
        u.time = block.timestamp;
        u.partner = address(0);
        u.referrals = 0;
        u.partnerPayoutSum = 0;
        u.containerSubleaseSum = 0;
        u.missedPartnerPayoutSum = 0;
        usersAddressById[1] = owner;
        totalStat.users++;
        totalStat.operations++;

        for(uint8 container = 1; container <= totalContainerCount; container++) {
            users[owner].containers[container].active = true;
            users[owner].containers[container].maxSubleases = 55555;
            rentQueue[container].push(owner);
        }
    }

    receive() external payable {
        if (!isUserRegistered(msg.sender)) {
            register();
            return;
        }

        for(uint8 container = 1; container <= totalContainerCount; container++) {
            if (containerPriceList[container] == msg.value) {
                rentContainer(container);
                return;
            }
        }

        revert("Can't find container to buy.");
    }

    function register() public payable {
        partnerRegister(owner);
    }

    function partnerRegister(address partner) public payable {
        require(msg.value == certfPrice, "Invalid value sent");
        require(!isContract(msg.sender), "Can not be a contract");
        require(!isUserRegistered(msg.sender), "User already registered");
        require(isUserRegistered(partner), "Partner is not registered");

        User storage u = users[msg.sender];
        u.id = currUserId++;
        u.time = block.timestamp;
        u.partner = partner;
        u.referrals = 0;
        u.partnerPayoutSum = 0;
        u.containerSubleaseSum = 0;
        u.missedPartnerPayoutSum = 0;
        usersAddressById[u.id] = msg.sender;

        uint8 partnerLevel = 1;
        address ref = partner;
        while (partnerLevel <= partnerLevelsNumber && ref != address(0)) {
            users[ref].referrals++;
            ref = users[ref].partner;
            partnerLevel++;
        }

        owner.transfer(msg.value);
    
        totalStat.users++;
        totalStat.operations++;
        emit Registration(u.id, users[partner].id);
    }

    function rentContainer(uint8 container) public payable nonReentrant {
        require(isUserRegistered(msg.sender), "User is not registered");
        require(container > 0 && container <= totalContainerCount, "Invalid container number");
        require(containerPriceList[container] == msg.value, "Invalid BNB value");
        require(totalStat.users >= minUsersForRent[container], "Container not available yet");
        require(!isContract(msg.sender), "Can not be a contract");
        for(uint8 i = 1; i < container; i++) {
            require(users[msg.sender].containers[i].active, "All previous Containers must be active");
        }

        totalStat.operations++;
        totalStat.rent += msg.value;

        uint percent = msg.value / 100;

        if (!users[msg.sender].containers[container].active) {
            users[msg.sender].containers[container].rentCount++;
            users[msg.sender].containers[container].maxSubleases += subleasesCount;
            users[msg.sender].containers[container].active = true;
            rentQueue[container].push(msg.sender);
            emit RentContainer(users[msg.sender].id, container);
        } else {
            users[msg.sender].containers[container].rentCount++;
            users[msg.sender].containers[container].maxSubleases += subleasesCount;
            emit IncContainerMaxSubleases(users[msg.sender].id, container, users[msg.sender].containers[container].maxSubleases);
        }

        uint sublease = percent * subleasePercents;

        if (rentQueue[container][queuePos[container]] != msg.sender) {
            address renterAddress = rentQueue[container][queuePos[container]];
            bool sent = payable(renterAddress).send(sublease);
            if (sent) {
                users[renterAddress].containers[container].subleaseSum += sublease;
                users[renterAddress].containers[container].payouts++;
                users[renterAddress].containerSubleaseSum += sublease;
                emit ContainerPayout(users[renterAddress].id, container, sublease, users[msg.sender].id);
            } else {
                owner.transfer(sublease);
            }

            if (users[renterAddress].containers[container].payouts < users[renterAddress].containers[container].maxSubleases) {
                rentQueue[container].push(renterAddress);
            } else {
                users[renterAddress].containers[container].active = false;
                emit ContainerDeactivation(users[renterAddress].id, container);
            }

            delete rentQueue[container][queuePos[container]];
            queuePos[container]++;
        } else {
            owner.transfer(sublease);
            users[owner].containers[container].payouts++;
            users[owner].containers[container].subleaseSum += sublease;
            users[owner].containerSubleaseSum += sublease;
        }

        for (uint8 level = 1; level <= partnerLevelsNumber; level++) {
            uint partnerValue = percent * partnerPercentageList[level];
            sendRewardToPartner(msg.sender, level, container, partnerValue);
        }

        (bool success, ) = tokenBurner.call{value: percent * futurePercents}("");
        require(success, "token burn failed while buy container");
    }

    function sendRewardToPartner(address userAddress, uint8 line, uint8 container, uint partnerValue) private {
        require(line > 0, "Line must be greater than zero");

        uint8 curLine = 1;
        address partner = users[userAddress].partner;
        while (curLine != line && partner != owner) {
            partner = users[partner].partner;
            curLine++;
        }

        while (!users[partner].containers[container].active && partner != owner) {
            users[partner].missedPartnerPayoutSum += partnerValue;
            emit MissedPartnerPayout(users[partner].id, users[userAddress].id, container, partnerValue);

            partner = users[partner].partner;
        }
        bool sent = payable(partner).send(partnerValue);
        if (sent) {
            users[partner].containers[container].partnerPayoutSum += partnerValue;
            users[partner].partnerPayoutSum += partnerValue;
            emit PartnerPayout(users[partner].id, users[userAddress].id, container, partnerValue);
        } else {
            owner.transfer(partnerValue);
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
            users[user.partner].id,
            user.partner,
            user.referrals,
            user.partnerPayoutSum,
            user.containerSubleaseSum,
            user.missedPartnerPayoutSum
        );
    }
    
    function getUserContainers(address userAddress) public view returns (bool[] memory, uint16[] memory, uint16[] memory, uint16[] memory, uint[] memory, uint[] memory) {
        bool[] memory active = new bool[](totalContainerCount + 1);
        uint16[] memory payouts = new uint16[](totalContainerCount + 1);
        uint16[] memory maxSubleases = new uint16[](totalContainerCount + 1);
        uint16[] memory rentCount = new uint16[](totalContainerCount + 1);
        uint[] memory subleaseSum = new uint[](totalContainerCount + 1);
        uint[] memory partnerPayoutSum = new uint[](totalContainerCount + 1);

        for (uint8 container = 1; container <= totalContainerCount; container++) {
            active[container] = users[userAddress].containers[container].active;
            payouts[container] = users[userAddress].containers[container].payouts;
            maxSubleases[container] = users[userAddress].containers[container].maxSubleases;
            rentCount[container] = users[userAddress].containers[container].rentCount;
            subleaseSum[container] = users[userAddress].containers[container].subleaseSum;
            partnerPayoutSum[container] = users[userAddress].containers[container].partnerPayoutSum;
        }

        return (active, payouts, maxSubleases, rentCount, subleaseSum, partnerPayoutSum);
    }

    function getContainerPrices() public view returns(uint[] memory) {
        return containerPriceList;
    }

    function getTotalStatistic() public view returns(uint[3] memory result) {
        return [totalStat.users, totalStat.operations, totalStat.rent];
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

    function getPartnerId(address userAddress) public view returns (uint) {
        address partnerAddress = users[userAddress].partner;
        return users[partnerAddress].id;
    }

    function getPartner(address userAddress) public view returns (address) {
        require(isUserRegistered(userAddress), "User is not registered");
        return users[userAddress].partner;
    }

    function getPlaceInQueue(address userAddress, uint8 container) public view returns(uint, uint) {
        require(container > 0 && container <= totalContainerCount, "Invalid container");

        // If user is not in the container queue
        if(!users[userAddress].containers[container].active) {
            return (0, 0);
        }

        uint place = 0;
        for(uint i = queuePos[container]; i < rentQueue[container].length; i++) {
            place++;
            if(rentQueue[container][i] == userAddress) {
                return (place, rentQueue[container].length - queuePos[container]);
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