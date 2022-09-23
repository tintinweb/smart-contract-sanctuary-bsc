// SPDX-License-Identifier: MIT
// EverClub

pragma solidity ^0.8.16;

/// @title  Base contracts
contract BASE_CONSTANTS_ENTITIES {

    /// @dev Treasury contract for receive platform commission payments
    address internal treasury;

    /// @dev Users
    mapping(address => User) public users;

    /// @dev Addresses ids
    mapping(uint256 => address) public addressIds;

    /// @dev Prices for unactive platform
    mapping(uint8 => uint256) public platformPricesUnActive;

    /// @dev Prices for active platform
    mapping(uint8 => uint256) public platformPricesActive;

    /// @dev Buy prices
    mapping(uint8 => uint256) public platformPricesBuy;

    /// @dev Last level number
    uint8 public constant LAST_PLATFORM = 15;

    /// @dev First level number
    uint8 public constant START_PLATFORM = 1;

    /// @dev Platform commission base percents
    uint256 public constant PLATFORM_COMMISSION_ACTIVE_PERCENT = 30;
    uint256 public constant PLATFORM_COMMISSION_BUY_PERCENT = 50;

    /// @dev Last added user id
    uint256 public nextUserId = 1;

    /// @dev Platform cells
    struct ThreeCells {
        address currentReferrer;
        address[] referrers;
        bool blocked;
        uint256 reinvestCount;
        uint256 queuePosition;
    }

    /// @dev Platform cells
    struct QueueAddresses {
        address referrer;
        bool blocked;
    }

    /// @dev Added level queues
    mapping(uint256 => QueueAddresses[]) internal levelQueues;

    /// @dev Base user object structure
    struct User {
        uint256 id;
        address referrer;
        uint256 parentsCount;
        bool exists;

        mapping(uint256 => bool) activeLevels;
        mapping(uint256 => ThreeCells) cellsMatrix;
    }

    /// @dev Init prices for buy platforms
    function initPricesBuyPlatform() internal {
        platformPricesBuy[1] = 10e18;
        platformPricesBuy[2] = 3e18;
        platformPricesBuy[3] = 5e18;
        platformPricesBuy[4] = 9e18;
        platformPricesBuy[5] = 16e18;
        platformPricesBuy[6] = 28e18;
        platformPricesBuy[7] = 49e18;
        platformPricesBuy[8] = 86e18;
        platformPricesBuy[9] = 151e18;
        platformPricesBuy[10] = 264e18;
        platformPricesBuy[11] = 462e18;
        platformPricesBuy[12] = 809e18;
        platformPricesBuy[13] = 1416e18;
        platformPricesBuy[14] = 2478e18;
        platformPricesBuy[15] = 4337e18;
    }

    /// @dev Init prices for 15 unactive platforms
    function initPricesUnActivePlatform() internal {
        /// @dev platformPricesBuy + platformPricesActive = platformPricesUnActive
        platformPricesUnActive[1] = 20e18;
        platformPricesUnActive[2] = 21e18;
        platformPricesUnActive[3] = 37e18;
        platformPricesUnActive[4] = 67e18;
        platformPricesUnActive[5] = 121e18;
        platformPricesUnActive[6] = 219e18;
        platformPricesUnActive[7] = 398e18;
        platformPricesUnActive[8] = 726e18;
        platformPricesUnActive[9] = 1332e18;
        platformPricesUnActive[10] = 2458e18;
        platformPricesUnActive[11] = 4566e18;
        platformPricesUnActive[12] = 8540e18;
        platformPricesUnActive[13] = 16087e18;
        platformPricesUnActive[14] = 30526e18;
        platformPricesUnActive[15] = 58355e18;
    }

    /// @dev Init prices for active platform
    function initPricesActivePlatform() internal {
        platformPricesActive[1] = 10e18;
        platformPricesActive[2] = 18e18;
        platformPricesActive[3] = 32e18;
        platformPricesActive[4] = 58e18;
        platformPricesActive[5] = 105e18;
        platformPricesActive[6] = 191e18;
        platformPricesActive[7] = 349e18;
        platformPricesActive[8] = 640e18;
        platformPricesActive[9] = 1181e18;
        platformPricesActive[10] = 2194e18;
        platformPricesActive[11] = 4104e18;
        platformPricesActive[12] = 7731e18;
        platformPricesActive[13] = 14671e18;
        platformPricesActive[14] = 28048e18;
        platformPricesActive[15] = 54018e18;
    }
}

/// @title EverClubContract
contract EverClubContract is BASE_CONSTANTS_ENTITIES {

    // Events

    event Registration(address indexed user, address indexed referrer, uint256 indexed userId, uint256 referrerId, uint256 amount);
    event Reinvest(address indexed user, address indexed currentReferrer, address indexed caller, uint8 platform);
    event Upgrade(address indexed user, address indexed referrer, uint8 platform);
    event NewUserPlace(address indexed user, address indexed owner, uint8 platform, uint8 place);

    event RegisteredByReferrer(address indexed user, address indexed referrer);

    event MissedEthPayment(address indexed receiver, address indexed from, uint8 platform);

    /// Internal transfer events

    event ReferrerPaymentTransfer(address indexed buyReceiver, uint256 buyAmount, address indexed activateReceiver, uint256 activateAmount, address indexed feeReceiver, uint256 fee);

    // Constructor

    constructor (address _treasury) {
        treasury = _treasury;

        createUser(treasury, nextUserId, address(0));
        addressIds[nextUserId] = treasury;

        ++nextUserId;

        QueueAddresses memory queueAddresses = QueueAddresses({
            referrer : treasury,
            blocked : false
        });
        for (uint8 i = START_PLATFORM; i <= LAST_PLATFORM; i++) {
            users[treasury].activeLevels[i] = true;
            users[treasury].cellsMatrix[i].queuePosition = 0;
            levelQueues[i].push(queueAddresses);
        }

        /// @dev init platform prices
        initPricesActivePlatform();
        initPricesUnActivePlatform();
        initPricesBuyPlatform();
    }

    // Functions

    /// @dev Check if address is from wallet
    function isNotContract(address user) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(user)
        }
        return size == 0;
    }

    /// @dev Convert bytes to Address
    function bytesToAddress(bytes memory _bytes) internal pure returns (address _address) {
        assembly {
            _address := mload(add(_bytes, 20))
        }
    }

    /// @dev Find free referrer
    function internalFindFreeReferrer(uint256 levelPosition, address user, address _from, uint8 platform) private returns (address) {
        address receiver = levelQueues[platform][levelPosition].referrer;

        if (users[receiver].cellsMatrix[platform].blocked || levelQueues[platform][levelPosition].blocked) {
            if (receiver == user) {
                emit MissedEthPayment(receiver, _from, platform);
            }
            if (levelQueues[platform].length == levelPosition + 1) {
                return treasury;
            } else {
                return internalFindFreeReferrer(levelPosition + 1, user, _from, platform);
            }
        }
        return receiver;
    }

    /// @dev Find free referrer
    function findFreeReferrer(address user, address _from, uint8 platform) private returns (address) {
        return internalFindFreeReferrer(0, user, _from, platform);
    }

    /// @dev Find referrer address
    function internalFindReferrer(address user, uint8 platform) private view returns (address) {
        if (users[users[user].referrer].activeLevels[platform]) {
            return users[user].referrer;
        }
        return internalFindReferrer(users[user].referrer, platform);
    }

    /// @dev Find referrer address
    function findReferrer(address user, uint8 platform) public view returns (address) {
        require(userExists(user), "User not found");
        require(platform >= START_PLATFORM && platform <= LAST_PLATFORM, "Invalid level");

        return internalFindReferrer(user, platform);
    }

    /// @dev Check if user exists
    function userExists(address user) public view returns (bool){
        return users[user].exists;
    }

    /// @dev Get added members count
    function userPlatformMembersCount(address user, uint256 platform) public view returns (uint) {
        return users[user].cellsMatrix[platform].referrers.length;
    }

    /// @dev Check is user tree cells is filled
    function isUserPlatformFilled(address user, uint256 platform) public view returns (bool) {
        return users[user].cellsMatrix[platform].blocked;
    }

    /// @dev Get user matrix
    function usersMatrix(address user, uint8 platform) public view returns (address, address[] memory, bool, uint) {
        ThreeCells memory cell = users[user].cellsMatrix[platform];

        return (cell.currentReferrer, cell.referrers, cell.blocked, cell.queuePosition);
    }

    /// @dev Get activated levels for users
    function userActivePlatform(address user, uint256 platform) public view returns (bool) {
        return users[user].activeLevels[platform];
    }

    /// @dev Get level queue user
    function levelQueueUser(uint256 platform, uint256 position) public view returns (address, bool) {
        QueueAddresses memory addresses = levelQueues[platform][position];

        return (addresses.referrer, addresses.blocked);
    }

    function createUser(address user, uint256 id, address referrer) private {
        User storage u = users[user];

        u.id = id;
        u.referrer = referrer;
        u.parentsCount = 0;
        u.exists = true;
    }

    /// @dev Register new user in contract
    function registrationInt() private {
        if (msg.data.length == 0) {
            return registrationWithReferralLink(msg.sender, treasury);
        }

        address refferer = bytesToAddress(msg.data);
        registrationWithReferralLink(msg.sender, refferer);

        emit RegisteredByReferrer(msg.sender, refferer);
    }

    /// @dev Register new user in system
    function registrationWithReferralLink(address user, address referrer) private {
        require(!userExists(user), "User already created");
        require(userExists(referrer), "Referer not exist");
        require(isNotContract(user), "This address cannot be contract");
        require(msg.value == platformPricesUnActive[START_PLATFORM], "Invalid registration cost");

        createUser(user, nextUserId, referrer);
        addressIds[nextUserId] = user;
        users[user].activeLevels[START_PLATFORM] = true;

        nextUserId++;

        users[user].parentsCount++;
        QueueAddresses memory queueAddresses = QueueAddresses({
            referrer : user,
            blocked : false
        });
        levelQueues[START_PLATFORM].push(queueAddresses);
        users[user].cellsMatrix[START_PLATFORM].queuePosition = levelQueues[START_PLATFORM].length - 1;

        address freeReferrer = findFreeReferrer(referrer, user, START_PLATFORM);
        users[user].cellsMatrix[START_PLATFORM].currentReferrer = freeReferrer;

        updateMatrixReferrers(user, freeReferrer, START_PLATFORM);

        emit Registration(user, referrer, users[user].id, users[referrer].id, msg.value);
        emit Upgrade(msg.sender, users[user].cellsMatrix[START_PLATFORM].currentReferrer, START_PLATFORM);
    }

    /// @dev Update referrers list for three cells matrix
    function updateMatrixReferrers(address user, address referrer, uint8 platform) private {
        if (users[referrer].cellsMatrix[platform].referrers.length < 3) {
            /// @dev Add user to referrer account
            users[referrer].cellsMatrix[platform].referrers.push(user);
            emit NewUserPlace(user, referrer, platform, uint8(users[referrer].cellsMatrix[platform].referrers.length));
            sendDividends(referrer, user, msg.value, platform);
            if (users[referrer].cellsMatrix[platform].referrers.length == 3) {
                users[referrer].cellsMatrix[platform].blocked = true;
                levelQueues[platform][users[referrer].cellsMatrix[platform].queuePosition].blocked = true;
            }
            return;
        }

        users[referrer].cellsMatrix[platform].blocked = true;
        levelQueues[platform][users[referrer].cellsMatrix[platform].queuePosition].blocked = true;
        address freeReferrer = findFreeReferrer(referrer, user, platform);
        if (users[referrer].cellsMatrix[platform].currentReferrer != freeReferrer) {
            users[referrer].cellsMatrix[platform].currentReferrer = freeReferrer;
        }
        updateMatrixReferrers(user, freeReferrer, platform);
    }

    /// @dev Send dividends to referrer
    function sendDividends(address receiver, address _from, uint256 value, uint8 platform) private {
        address freeReferrer = findFreeReferrer(receiver, _from, platform);
        uint256 commissionBuyPrice = 0;
        uint256 buyPrice = 0;
        uint256 commissionActivatePrice = platformPricesActive[platform] * PLATFORM_COMMISSION_ACTIVE_PERCENT / 100;
        uint256 activatePrice = platformPricesActive[platform] - commissionActivatePrice;

        if (value == platformPricesUnActive[platform]) {
            receiver = findReferrer(_from, platform);
            commissionBuyPrice = platformPricesBuy[platform] * PLATFORM_COMMISSION_BUY_PERCENT / 100;
            buyPrice = platformPricesBuy[platform] - commissionBuyPrice;
        }

        emit ReferrerPaymentTransfer(freeReferrer, activatePrice, receiver, buyPrice, addressIds[1], commissionBuyPrice + commissionActivatePrice);

        bool success;
        if (receiver != freeReferrer) {
            if (buyPrice > 0) {
                (success,) = payable(receiver).call{value: buyPrice}("");
                require(success, "Error transfer referrer payment");
            }
            (success,) = payable(freeReferrer).call{value: activatePrice}("");
            require(success, "Error transfer referrer payment");
        } else {
            (success,) = payable(receiver).call{value: buyPrice + activatePrice}("");
            require(success, "Error transfer referrer payment");
        }
        (success,) = payable(addressIds[1]).call{value: commissionBuyPrice + commissionActivatePrice}("");
        require(success, "Error transfer referrer payment");
    }

    receive() external payable {
        registrationInt();
    }

    /// @dev Register new user api
    function registrationExt(address referrer) external payable {
        if (referrer == address(0x0)) {
            return registrationWithReferralLink(msg.sender, addressIds[1]);
        }

        registrationWithReferralLink(msg.sender, referrer);

        emit RegisteredByReferrer(msg.sender, referrer);
    }

    /// @dev Byu new level, used for activation new platform
    function buyNewLevel(uint8 platform) external payable {
        require(userExists(msg.sender), "User not found. Register first");
        require(!users[msg.sender].activeLevels[platform], 'Level already activated');
        require(msg.value == platformPricesUnActive[platform], "Invalid price");
        require(platform > START_PLATFORM && platform <= LAST_PLATFORM, "Invalid level");
        require(users[msg.sender].activeLevels[platform - 1], 'Buy previous level first');

        address freeReferrer = findFreeReferrer(users[msg.sender].referrer, msg.sender, platform);
        users[msg.sender].cellsMatrix[platform].currentReferrer = freeReferrer;
        users[msg.sender].activeLevels[platform] = true;
        QueueAddresses memory queueAddresses = QueueAddresses({
            referrer : msg.sender,
            blocked : false
        });
        levelQueues[platform].push(queueAddresses);
        users[msg.sender].cellsMatrix[platform].queuePosition = levelQueues[platform].length - 1;
        updateMatrixReferrers(msg.sender, freeReferrer, platform);

        emit Upgrade(msg.sender, freeReferrer, platform);
    }

    /// @dev Reactivate platform
    function reactivatePlatform(uint8 platform) external payable {
        address user = msg.sender;

        require(users[user].cellsMatrix[platform].referrers.length >= 3, 'Cannot reactivate platform');
        require(msg.value == platformPricesActive[platform], "Invalid price");
        require(platform >= START_PLATFORM && platform <= LAST_PLATFORM, "Invalid level");

        address freeReferrer = findFreeReferrer(address(0), user, platform);

        if (users[user].cellsMatrix[platform].currentReferrer != freeReferrer) {
            users[user].cellsMatrix[platform].currentReferrer = freeReferrer;
        }

        users[user].cellsMatrix[platform].blocked = false;
        users[user].cellsMatrix[platform].referrers = new address[](0);
        QueueAddresses memory queueAddresses = QueueAddresses({
            referrer : user,
            blocked : false
        });
        levelQueues[platform].push(queueAddresses);
        users[user].cellsMatrix[platform].reinvestCount++;
        updateMatrixReferrers(user, freeReferrer, platform);
        users[user].cellsMatrix[platform].queuePosition = levelQueues[platform].length - 1;

        emit Reinvest(users[user].referrer, freeReferrer, user, platform);
    }
}