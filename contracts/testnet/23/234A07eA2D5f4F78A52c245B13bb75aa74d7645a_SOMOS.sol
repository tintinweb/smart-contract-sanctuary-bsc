/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

interface IERC20 {
    function transfer(address _to, uint256 _amount) external returns (bool);

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract SOMOS {
    address public ownerWallet;
    address public devAddress = 0x350F84C2f5272973646342Be1AdbE232324A552E;
    IERC20 public tokenAddress =
        IERC20(0xd3521B5dD10061245ABf863A3ae36732171084c3);
    struct UserStruct {
        bool isExist;
        uint256 id;
        mapping(uint256 => uint256) referrerID;
        uint8 activeLevel;
        mapping(uint256 => address[]) referral;
        mapping(uint16 => uint16) paymentCount;
        uint256 earning;
    }

    uint256 REFERRER_1_LEVEL_LIMIT = 2;

    mapping(uint256 => uint256) public LEVEL_PRICE;

    mapping(address => UserStruct) public users;
    mapping(uint256 => address) public userList;
    uint256 public currUserID = 0;
    uint256 public defaultReferralId = 1;

    event regLevelEvent(
        address indexed _user,
        address indexed _referrer,
        uint256 _time
    );
    event buyLevelEvent(address indexed _user, uint256 _level, uint256 _time);
    event prolongateLevelEvent(
        address indexed _user,
        uint256 _level,
        uint256 _time
    );
    event getMoneyForLevelEvent(
        uint256 indexed _userId,
        uint256 indexed _referralId,
        uint256 _level,
        uint256 _time
    );
    event lostMoneyForLevelEvent(
        address indexed _user,
        address indexed _referral,
        uint256 _level,
        uint256 _time
    );

    constructor() {
        ownerWallet = msg.sender;

        LEVEL_PRICE[1] = 1 ether;
        LEVEL_PRICE[2] = 10 ether;
        LEVEL_PRICE[3] = 100 ether;
        LEVEL_PRICE[4] = 1000 ether;
        LEVEL_PRICE[5] = 10000 ether;
        LEVEL_PRICE[6] = 100000 ether;
        LEVEL_PRICE[7] = 1000000 ether;

        currUserID++;

        users[ownerWallet].isExist = true;
        users[ownerWallet].id = currUserID;
        users[ownerWallet].activeLevel = 1;
        userList[currUserID] = ownerWallet;
    }

    function regUser(uint256 _referrerID) public {
        require(!users[msg.sender].isExist, "User exist");
        require(
            _referrerID > 0 && _referrerID <= currUserID,
            "Incorrect referrer Id"
        );
        tokenAddress.transferFrom(msg.sender, address(this), LEVEL_PRICE[1]);

        if (
            users[userList[_referrerID]].referral[1].length >=
            REFERRER_1_LEVEL_LIMIT
        ) _referrerID = users[findFreeReferrer(userList[_referrerID], 1)].id;

        currUserID++;

        users[msg.sender].isExist = true;
        users[msg.sender].id = currUserID;
        users[msg.sender].referrerID[1] = _referrerID;
        users[msg.sender].activeLevel = 1;
        userList[currUserID] = msg.sender;

        users[userList[_referrerID]].referral[1].push(msg.sender);

        payForLevel(1, msg.sender);

        emit regLevelEvent(msg.sender, userList[_referrerID], block.timestamp);
    }

    function buyLevel(uint16 _level, address user) internal {
        require(users[user].isExist, "User not exist");
        require(_level > 0 && _level <= 7, "Incorrect level");
        uint256 _referrerID = users[user].referrerID[_level];
        if (users[userList[_referrerID]].activeLevel < _level) {
            _referrerID = defaultReferralId;
        }
        if (
            users[userList[_referrerID]].referral[_level].length >=
            REFERRER_1_LEVEL_LIMIT
        )
            _referrerID = users[findFreeReferrer(userList[_referrerID], _level)]
                .id;
        users[userList[_referrerID]].referral[_level].push(msg.sender);
        users[userList[_referrerID]].referrerID[_level] = _referrerID;
        payForLevel(_level, user);
        emit buyLevelEvent(user, _level, block.timestamp);
    }

    function payForLevel(uint16 _level, address _user) internal {
        address referer = userList[users[_user].referrerID[_level]];
        for (uint256 i = 0; i < 3; i++) {
            referer = userList[users[referer].referrerID[_level]];
        }
        if (!users[referer].isExist) {} else {
            users[referer].paymentCount[_level]++;
            uint16 payCount = users[referer].paymentCount[_level];
            if (payCount == 1) {
                tokenAddress.transfer(devAddress, LEVEL_PRICE[_level]);
            } else if (payCount > 1 && payCount <= 6) {
                users[referer].earning += LEVEL_PRICE[_level];
                tokenAddress.transfer(referer, LEVEL_PRICE[_level]);
                emit getMoneyForLevelEvent(
                        users[referer].id,
                        users[_user].id,
                        _level,
                        block.timestamp
                    );
            } else if (payCount > 6 && payCount <= 16) {
                if (_level == 7) {
                    users[referer].earning += LEVEL_PRICE[_level];
                    tokenAddress.transfer(referer, LEVEL_PRICE[_level]);
                    emit getMoneyForLevelEvent(
                        users[referer].id,
                        users[_user].id,
                        _level,
                        block.timestamp
                    );
                } else if (payCount == 16) {
                    users[referer].activeLevel++;
                    buyLevel(_level + 1, referer);
                }
            }
        }
    }

    function setDefaultReferralId(uint256 id) external {
        require(msg.sender == ownerWallet, "Invalid user");
        defaultReferralId = id;
    }

    function findFreeReferrer(address _user, uint256 _level)
        public
        view
        returns (address)
    {
        if (users[_user].referral[_level].length < REFERRER_1_LEVEL_LIMIT)
            return _user;

        address[] memory referrals = new address[](126);
        referrals[0] = users[_user].referral[_level][0];
        referrals[1] = users[_user].referral[_level][1];

        address freeReferrer;
        bool noFreeReferrer = true;

        for (uint256 i = 0; i < 126; i++) {
            if (
                users[referrals[i]].referral[_level].length ==
                REFERRER_1_LEVEL_LIMIT
            ) {
                if (i < 62) {
                    referrals[(i + 1) * 2] = users[referrals[i]].referral[
                        _level
                    ][0];
                    referrals[(i + 1) * 2 + 1] = users[referrals[i]].referral[
                        _level
                    ][1];
                }
            } else {
                noFreeReferrer = false;
                freeReferrer = referrals[i];
                break;
            }
        }

        require(!noFreeReferrer, "No Free Referrer");

        return freeReferrer;
    }

    function viewUserReferral(address _user, uint256 _level)
        public
        view
        returns (address[] memory)
    {
        return users[_user].referral[_level];
    }

    function viewUserReferrId(address _user, uint256 _level)
        public
        view
        returns (uint256)
    {
        return users[_user].referrerID[_level];
    }

    function getUserPaymentInfo(address _user)
        external
        view
        returns (uint256[] memory paymentCount)
    {
        for (uint16 i = 1; i <= 7; i++) {
            paymentCount[i] = users[_user].paymentCount[i];
        }
        return paymentCount;
    }

    function bytesToAddress(bytes memory bys)
        private
        pure
        returns (address addr)
    {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}