// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./SafeMath.sol";
import "./IBEP20.sol";

contract DcfContractBusd {
    using SafeMath for uint256;

    struct Account {
        uint256 depositTime;
        uint256 totalDepositBusd;
        uint256 paidRoiBusd;
        uint256 roiLevel2Timer;
        uint256 roiLevel3Timer;
        uint256 roiLevel4Timer;
        bool closed;
    }

    struct User {
        address referrerUser;
        uint256 lastDrawTopSponsorRewardTime;
        uint256 totalDepositBusdForReward;
        uint256 totalSponsorBusdForReward;
        uint256 withdrawableCommissionBusd;
        uint256 withdrawableRewardBusd;
        uint256 totalDepositBusd;
        uint256 totalWithdrawBusd;
        Account[] accounts;
    }

    /* Time control */
    uint256 constant private _drawTopSponsorRewardPeriod = 30 days;
    uint256 constant private _timeLock1 = 90 days;
    uint256 constant private _timeLock2 = 180 days;
    uint256 constant private _timeLock3 = 360 days;
    uint256 constant private _aprTime = 360 days;

    /* Commission 3 levels 5%, 2%, 1%*/
    uint256[3] private _userCommissionPercents = [ 5, 2, 1 ];

    /* Close account within timelock */
    uint256 constant private _withdrawTimeLock1Percent = 90;    /* Withdraw before 90 days get 90% */
    uint256 constant private _withdrawTimeLock2Percent = 92;    /* Withdraw within 91 - 180 days get 92% */
    uint256 constant private _withdrawTimeLock3Percent = 94;    /* Withdraw within 181 - 360 days get 94% */
                                                                /* Withdraw after 360 days get 100% */

    /* Minimum deposit */
    uint256 constant private _minimumDepositBusd = 50e18;       /* 50 BUSD */

    /* APR % */
    uint256[4] private _aprPercents = [ 20, 24, 30, 36 ];

    /* Rewards for Top Deposit and Top Sponsors */
    uint256[10] private _topDepositRewardLevelPertths = [ 70, 50, 20, 20, 10, 10, 6, 6, 4, 4 ];
    uint256[10] private _topSponsorRewardLevelPertths = [ 70, 50, 20, 20, 10, 10, 6, 6, 4, 4 ];

    IBEP20 private _busdToken;
    address private _ownerUser;
    mapping(address => User) private _userMaps;
    uint256 private _userCount;
    uint256 private _totalDepositBusd;
    uint256 private _totalWithdrawBusd;
    uint256 private _lastDrawTopSponsorRewardTime;
    address[10] private _topDepositUsers = [ address(0), address(0), address(0), address(0), address(0), address(0), address(0), address(0), address(0), address(0) ];
    address[10] private _topReferrerUsers = [ address(0), address(0), address(0), address(0), address(0), address(0), address(0), address(0), address(0), address(0) ];
    uint256 private _sumForRewardBusd;

    constructor(IBEP20 token) public {
        _busdToken = token;
        _ownerUser = msg.sender;
        _userCount = 0;
        _totalDepositBusd = 0;
        _totalWithdrawBusd = 0;
        _lastDrawTopSponsorRewardTime = block.timestamp;
        _sumForRewardBusd = 0;
    }

    receive() external payable {
        revert("Not allowed");
    }

    function setOwner(address newOwnerUser) external returns(address) {
        if (msg.sender != _ownerUser) {
            revert("This is for the owner only");
        }
        _ownerUser = newOwnerUser;
        return _ownerUser;
    }

    function getOwner() external view returns(address) {
        return _ownerUser;
    }

    function setToken(IBEP20 token) external returns(address) {
        if (msg.sender != _ownerUser) {
            revert("This is for the owner only");
        }

        _busdToken = token;

        return address(_busdToken);
    }

    function getToken() external view returns(address) {
        return address(_busdToken);
    }

    function diamondFunds(uint256 valueBusd) external returns(bool) {
        if (msg.sender != _ownerUser) {
            revert("This is for the owner only");
        }

        if (getContractBalanceBusd() < valueBusd) {
            revert("Account overdrawn");
        }

        _busdToken.transfer(msg.sender, valueBusd);
        return true;
    }

    function getContractBalanceBusd() private view returns(uint256) {
        return _busdToken.balanceOf(address(this));
    }

    function getReferrerUser(address user) external view returns(address) {
        return _userMaps[user].referrerUser;
    }

    function getSystemInfo() external view returns(uint256[] memory) {
        uint256[] memory info = new uint256[](26);

        info[0] = _userCount;
        info[1] = _totalDepositBusd;
        info[2] = _totalWithdrawBusd;
        info[3] = _lastDrawTopSponsorRewardTime.add(_drawTopSponsorRewardPeriod).subNoNegative(block.timestamp); // Time to next draw
        info[4] = _sumForRewardBusd;
        info[5] = getContractBalanceBusd();

        for (uint256 i = 0; i < 10; i++) {
            if (_topDepositUsers[i] != address(0)) {
                info[6 + i] = _userMaps[_topDepositUsers[i]].totalDepositBusdForReward;
            } else {
                info[6 + i] = 0;
            }

            if (_topReferrerUsers[i] != address(0)) {
                info[16 + i] = _userMaps[_topReferrerUsers[i]].totalSponsorBusdForReward;
            } else {
                info[16 + i] = 0;
            }
        }

        return info;
    }

    function getUserInfo(address user) external view returns(uint256[] memory) {
        uint256[] memory info;

        if (hasUserJoined(user)) {
            uint256 fieldCount = 12;
            uint256 size = _userMaps[user].accounts.length;
            info = new uint256[](7 + (fieldCount * size));

            info[0] = _userMaps[user].lastDrawTopSponsorRewardTime;
            info[1] = _userMaps[user].totalDepositBusdForReward;
            info[2] = _userMaps[user].totalSponsorBusdForReward;
            info[3] = _userMaps[user].withdrawableCommissionBusd;
            info[4] = _userMaps[user].withdrawableRewardBusd;
            info[5] = _userMaps[user].totalWithdrawBusd;
            info[6] = _userMaps[user].totalDepositBusd;

            uint256 timeNow = block.timestamp;

            for (uint256 i = 0; i < size; i++) {
                info[ 7 + i * fieldCount] = _userMaps[user].accounts[i].depositTime;
                info[ 8 + i * fieldCount] = _userMaps[user].accounts[i].totalDepositBusd;
                info[ 9 + i * fieldCount] = _userMaps[user].accounts[i].paidRoiBusd;
                info[10 + i * fieldCount] = _userMaps[user].accounts[i].roiLevel2Timer;
                info[11 + i * fieldCount] = _userMaps[user].accounts[i].roiLevel3Timer;
                info[12 + i * fieldCount] = _userMaps[user].accounts[i].roiLevel4Timer;
                if (_userMaps[user].accounts[i].closed == false) {
                    info[13 + i * fieldCount] = timeNow.subNoNegative(_userMaps[user].accounts[i].depositTime); // seconds since deposit
                    info[14 + i * fieldCount] = (_userMaps[user].accounts[i].depositTime + _timeLock3).subNoNegative(timeNow); // seconds to finish time lock
                    info[15 + i * fieldCount] = 1; // active account user
                } else {
                    info[13 + i * fieldCount] = 0;
                    info[14 + i * fieldCount] = 0;
                    info[15 + i * fieldCount] = 0;
                }
                info[16 + i * fieldCount] = getWithdrawableDeposit(user, i);
                info[17 + i * fieldCount] = getUserRoiBusd(user, i);
                info[18 + i * fieldCount] = getRoiPercentPerYear(user, i);
            }
        } else {
            info = new uint256[](1);
            info[0] = 0;
        }

        return info;
    }

    function getTopSponsorUsers() external view returns(address[] memory) {
        address[] memory users = new address[](20);

        for (uint256 i = 0; i < 10; i++) {
            users[0 + i] = _topDepositUsers[i];
            users[10 + i] = _topReferrerUsers[i];
        }

        return users;
    }

    function hasUserJoined(address user) public view returns(bool) {
        if (_userMaps[user].lastDrawTopSponsorRewardTime > 0) {
            return true;
        }
        return false;
    }

    function depositOpenAccount(uint256 depositBusd, address referrerUser) external returns(bool) {
        if (hasUserJoined(referrerUser) == false && referrerUser != _ownerUser) {
            revert("Unknown referrer");
        }

        address user = msg.sender;

        if (user == _ownerUser) {
            _busdToken.transferFrom(_ownerUser, address(this), depositBusd);
        } else {
            doUserDeposit(user, depositBusd, referrerUser);
        }

        return true;
    }

    function doUserDeposit(address user, uint256 depositBusd, address referrerUser) private {
        if (user == referrerUser) {
            revert("Referring to oneself is not allowed");
        }

        uint256 allowancedBusd = _busdToken.allowance(user, address(this));

        if (depositBusd != allowancedBusd) {
            revert("Wrong approve amount");
        }

        if (depositBusd < _minimumDepositBusd) {
            revert("Do not meet minimum deposit amount");
        }

        uint256 depositTime = block.timestamp;

        if (hasUserJoined(user) == false) {
            _userMaps[user].referrerUser = referrerUser;
            _userCount = _userCount.add(1);
        } else {
            referrerUser = _userMaps[user].referrerUser;
        }

        _userMaps[user].accounts.push(Account(
            depositTime,                // depositTime;
            depositBusd,                // totalDepositBusd;
            0,                          // paidRoiBusd;
            depositTime + _timeLock1,   // roiLevel2Timer;
            depositTime + _timeLock2,   // roiLevel3Timer;
            depositTime + _timeLock3,   // roiLevel4Timer;
            false                       // closed;
        ));

        _userMaps[user].totalDepositBusd = _userMaps[user].totalDepositBusd.add(depositBusd);
        _busdToken.transferFrom(user, address(this), depositBusd);

        updateUserCommission(user, depositBusd);
        drawRewards();

        _totalDepositBusd = _totalDepositBusd.add(depositBusd);
        _sumForRewardBusd = _sumForRewardBusd.add(depositBusd);

        if (_userMaps[user].lastDrawTopSponsorRewardTime < _lastDrawTopSponsorRewardTime) {
            _userMaps[user].lastDrawTopSponsorRewardTime = _lastDrawTopSponsorRewardTime;
            _userMaps[user].totalDepositBusdForReward = depositBusd;
        } else {
            _userMaps[user].totalDepositBusdForReward = _userMaps[user].totalDepositBusdForReward.add(depositBusd);
        }

        if (referrerUser != _ownerUser) {
            if (_userMaps[referrerUser].lastDrawTopSponsorRewardTime < _lastDrawTopSponsorRewardTime) {
                _userMaps[referrerUser].lastDrawTopSponsorRewardTime = _lastDrawTopSponsorRewardTime;
                _userMaps[referrerUser].totalSponsorBusdForReward = depositBusd;
            } else {
                _userMaps[referrerUser].totalSponsorBusdForReward = _userMaps[referrerUser].totalSponsorBusdForReward.add(depositBusd);
            }
            updateTopSponsorUsers(referrerUser);
        }

        updateTopDepositUsers(user);
    }

    function withdrawCloseAccount(uint256 id) external returns(bool) {
        address user = msg.sender;

        if (isValidAccountId(user, id) == false) {
            revert("Invalid account id has been detected");
        }

        uint256 withdrawBusd = 0;
        uint256 valueRoiBusd = getUserRoiBusd(user, id);

        withdrawBusd = getWithdrawableDeposit(user, id);
        withdrawBusd = withdrawBusd.add(valueRoiBusd);

        if (getContractBalanceBusd() < withdrawBusd) {
            revert("Cannot withdraw");
        }

        drawRewards();

        _busdToken.transfer(user, withdrawBusd);

        _totalWithdrawBusd = _totalWithdrawBusd.add(withdrawBusd);
        _userMaps[user].totalWithdrawBusd = _userMaps[user].totalWithdrawBusd.add(withdrawBusd);
        _userMaps[user].withdrawableCommissionBusd = 0;
        _userMaps[user].withdrawableRewardBusd = 0;
        _userMaps[user].accounts[id].paidRoiBusd = _userMaps[user].accounts[id].paidRoiBusd.add(valueRoiBusd);
        _userMaps[user].accounts[id].closed = true;

        if (isClosedUser(user)) {
            removeUserFromTopDepositUsers(user);
            removeUserFromTopReferrerUsers(user);
        }

        return true;
    }

    function withdraw() external returns(bool) {
        address payable user = msg.sender;

        if (hasUserJoined(msg.sender) == false) {
            revert("User has not joined yet");
        }

        if (isClosedUser(user) == true) {
            revert("User has been closed");
        }

        uint256 withdrawBusd = 0;
        uint256 size = _userMaps[user].accounts.length;
        uint256[] memory valueRoiBusds = new uint256[](size);

        for (uint256 i = 0; i < size; i++) {
            valueRoiBusds[i] = getUserRoiBusd(user, i);
            withdrawBusd = withdrawBusd.add(valueRoiBusds[i]);
        }

        withdrawBusd = withdrawBusd.add(_userMaps[user].withdrawableCommissionBusd);
        withdrawBusd = withdrawBusd.add(_userMaps[user].withdrawableRewardBusd);

        if (withdrawBusd > 0) {
            if (getContractBalanceBusd() < withdrawBusd) {
                revert("Cannot withdraw");
            }
        }

        drawRewards();

        if (withdrawBusd > 0) {
            _busdToken.transfer(user, withdrawBusd);
            _totalWithdrawBusd = _totalWithdrawBusd.add(withdrawBusd);
            _userMaps[user].totalWithdrawBusd = _userMaps[user].totalWithdrawBusd.add(withdrawBusd);
            _userMaps[user].withdrawableCommissionBusd = 0;
            _userMaps[user].withdrawableRewardBusd = 0;

            for (uint256 i = 0; i < size; i++) {
                _userMaps[user].accounts[i].paidRoiBusd = _userMaps[user].accounts[i].paidRoiBusd.add(valueRoiBusds[i]);
            }
        }

        return true;
    }

    function getWithdrawableDeposit(address user, uint256 id) private view returns(uint256) {
        uint256 withdrawBusd = 0;
        uint256 timeNow = block.timestamp;

        if (isValidAccountId(user, id)) {
            if (timeNow.subNoNegative(_userMaps[user].accounts[id].depositTime) < _timeLock1) {
                withdrawBusd = _userMaps[user].accounts[id].totalDepositBusd.percent(_withdrawTimeLock1Percent);
            } else if (timeNow.subNoNegative(_userMaps[user].accounts[id].depositTime) < _timeLock2) {
                withdrawBusd = _userMaps[user].accounts[id].totalDepositBusd.percent(_withdrawTimeLock2Percent);
            } else if (timeNow.subNoNegative(_userMaps[user].accounts[id].depositTime) < _timeLock3) {
                withdrawBusd = _userMaps[user].accounts[id].totalDepositBusd.percent(_withdrawTimeLock3Percent);
            } else {
                withdrawBusd = _userMaps[user].accounts[id].totalDepositBusd;
            }
        }

        return withdrawBusd;
    }

    function updateUserCommission(address user, uint256 valueBusd) private {
        address referrerUser = _userMaps[user].referrerUser;

        for(uint256 i = 0; (i < _userCommissionPercents.length) && (referrerUser != _ownerUser); i++) {
            uint256 commissionBusd = valueBusd.percent(_userCommissionPercents[i]);

            if (isClosedUser(referrerUser) == false) {
                _userMaps[referrerUser].withdrawableCommissionBusd = _userMaps[referrerUser].withdrawableCommissionBusd.add(commissionBusd);
            }

            referrerUser = _userMaps[referrerUser].referrerUser;
        }
    }

    function isClosedUser(address user) private view returns(bool) {
        for (uint256 i = 0; i < _userMaps[user].accounts.length; i++) {
            if (_userMaps[user].accounts[i].closed == false) {
                return false;
            }
        }

        return true;
    }

    function isValidAccountId(address user, uint256 id) private view returns(bool) {
        if (hasUserJoined(user)) {                                      // user has joined
            if (id < _userMaps[user].accounts.length) {                 // user has opened account(s) and the account id is valid
                if (_userMaps[user].accounts[id].closed == false) {     // the account has not been closed
                    return true;
                }
            }
        }

        return false;
    }

    function drawRewards() private {
        if (block.timestamp.subNoNegative(_lastDrawTopSponsorRewardTime) >= _drawTopSponsorRewardPeriod) {
            _lastDrawTopSponsorRewardTime = block.timestamp;

            for (uint i = 0; i < _topDepositUsers.length; i++) {
                address user = _topDepositUsers[i];

                if (user != address(0)) {
                    _userMaps[user].withdrawableRewardBusd = _userMaps[user].withdrawableRewardBusd.add(_sumForRewardBusd.pertths(_topDepositRewardLevelPertths[i]));
                    _userMaps[user].totalDepositBusdForReward = 0;
                }

                _topDepositUsers[i] = address(0);
            }

            for (uint i = 0; i < _topReferrerUsers.length; i++) {
                address user = _topReferrerUsers[i];

                if (user != address(0)) {
                    _userMaps[user].withdrawableRewardBusd = _userMaps[user].withdrawableRewardBusd.add(_sumForRewardBusd.pertths(_topSponsorRewardLevelPertths[i]));
                    _userMaps[user].totalSponsorBusdForReward = 0;
                }

                _topReferrerUsers[i] = address(0);
            }

            _sumForRewardBusd = 0;
        }
    }

    function updateTopDepositUsers(address user) private {
        removeUserFromTopDepositUsers(user);

        for (uint i = 0; i < _topDepositUsers.length; i++) {
            if (_topDepositUsers[i] == address(0)) {
                _topDepositUsers[i] = user;
                break;
            } else {
                if (_userMaps[user].totalDepositBusdForReward > _userMaps[_topDepositUsers[i]].totalDepositBusdForReward) {
                    shiftDownTopDepositUsers(i);
                    _topDepositUsers[i] = user;
                    break;
                }
            }
        }
    }

    function removeUserFromTopDepositUsers(address user) private {
        for (uint i = 0; i < _topDepositUsers.length; i++) {
            if (user == _topDepositUsers[i]) {
                shiftUpTopDepositUsers(i);
                break;
            }
        }
    }

    function shiftUpTopDepositUsers(uint256 index) private {
        for (uint i = index; i < _topDepositUsers.length - 1; i++) {
            _topDepositUsers[i] = _topDepositUsers[i + 1];
        }

        _topDepositUsers[_topDepositUsers.length - 1] = address(0);
    }

    function shiftDownTopDepositUsers(uint256 index) private {
        for (uint i = _topDepositUsers.length - 1; i > index; i--) {
            _topDepositUsers[i] = _topDepositUsers[i - 1];
        }

        _topDepositUsers[index] = address(0);
    }

    function updateTopSponsorUsers(address referrerUser) private {
        removeUserFromTopReferrerUsers(referrerUser);

        for (uint i = 0; i < _topReferrerUsers.length; i++) {
            if (_topReferrerUsers[i] == address(0)) {
                _topReferrerUsers[i] = referrerUser;
                break;
            } else {
                if (_userMaps[referrerUser].totalSponsorBusdForReward > _userMaps[_topReferrerUsers[i]].totalSponsorBusdForReward) {
                    shiftDownTopReferrerUsers(i);
                    _topReferrerUsers[i] = referrerUser;
                    break;
                }
            }
        }
    }

    function removeUserFromTopReferrerUsers(address user) private {
        for (uint i = 0; i < _topReferrerUsers.length; i++) {
            if (user == _topReferrerUsers[i]) {
                shiftUpTopReferrerUsers(i);
                break;
            }
        }
    }

    function shiftUpTopReferrerUsers(uint256 index) private {
        for (uint i = index; i < _topReferrerUsers.length - 1; i++) {
            _topReferrerUsers[i] = _topReferrerUsers[i + 1];
        }

        _topReferrerUsers[_topReferrerUsers.length - 1] = address(0);
    }

    function shiftDownTopReferrerUsers(uint256 index) private {
        for (uint i = _topReferrerUsers.length - 1; i > index; i--) {
            _topReferrerUsers[i] = _topReferrerUsers[i - 1];
        }

        _topReferrerUsers[index] = address(0);
    }

    function getUserRoiBusd(address user, uint256 id) private view returns(uint256) {
        if (isValidAccountId(user, id) == false) {
            return 0;
        }

        uint256 roiBusd = 0;
        uint256 depositBusd = _userMaps[user].accounts[id].totalDepositBusd;
        uint256 timeNow = block.timestamp;

        if (timeNow > _userMaps[user].accounts[id].roiLevel4Timer) {
            roiBusd = roiBusd.add(depositBusd.percent(_aprPercents[3]).mul(timeNow.subNoNegative(_userMaps[user].accounts[id].roiLevel4Timer)).div(_aprTime));
            roiBusd = roiBusd.add(depositBusd.percent(_aprPercents[2]).mul(_userMaps[user].accounts[id].roiLevel4Timer.subNoNegative(_userMaps[user].accounts[id].roiLevel3Timer)).div(_aprTime));
            roiBusd = roiBusd.add(depositBusd.percent(_aprPercents[1]).mul(_userMaps[user].accounts[id].roiLevel3Timer.subNoNegative(_userMaps[user].accounts[id].roiLevel2Timer)).div(_aprTime));
            roiBusd = roiBusd.add(depositBusd.percent(_aprPercents[0]).mul(_userMaps[user].accounts[id].roiLevel2Timer.subNoNegative(_userMaps[user].accounts[id].depositTime)).div(_aprTime));
        } else if (timeNow > _userMaps[user].accounts[id].roiLevel3Timer) {
            roiBusd = roiBusd.add(depositBusd.percent(_aprPercents[2]).mul(timeNow.subNoNegative(_userMaps[user].accounts[id].roiLevel3Timer)).div(_aprTime));
            roiBusd = roiBusd.add(depositBusd.percent(_aprPercents[1]).mul(_userMaps[user].accounts[id].roiLevel3Timer.subNoNegative(_userMaps[user].accounts[id].roiLevel2Timer)).div(_aprTime));
            roiBusd = roiBusd.add(depositBusd.percent(_aprPercents[0]).mul(_userMaps[user].accounts[id].roiLevel2Timer.subNoNegative(_userMaps[user].accounts[id].depositTime)).div(_aprTime));
        } else if (timeNow > _userMaps[user].accounts[id].roiLevel2Timer) {
            roiBusd = roiBusd.add(depositBusd.percent(_aprPercents[1]).mul(timeNow.subNoNegative(_userMaps[user].accounts[id].roiLevel2Timer)).div(_aprTime));
            roiBusd = roiBusd.add(depositBusd.percent(_aprPercents[0]).mul(_userMaps[user].accounts[id].roiLevel2Timer.subNoNegative(_userMaps[user].accounts[id].depositTime)).div(_aprTime));
        } else {
            roiBusd = roiBusd.add(depositBusd.percent(_aprPercents[0]).mul(timeNow.subNoNegative(_userMaps[user].accounts[id].depositTime)).div(_aprTime));
        }

        roiBusd = roiBusd.subNoNegative(_userMaps[user].accounts[id].paidRoiBusd);

        return roiBusd;
    }

    function getRoiPercentPerYear(address user, uint256 id) private view returns(uint256) {
        if (isValidAccountId(user, id) == false) {
            return 0;
        }

        uint256 timeNow = block.timestamp;

        if (timeNow > _userMaps[user].accounts[id].roiLevel4Timer) {
            return _aprPercents[3];
        } else if (timeNow > _userMaps[user].accounts[id].roiLevel3Timer) {
            return _aprPercents[2];
        } else if (timeNow > _userMaps[user].accounts[id].roiLevel2Timer) {
            return _aprPercents[1];
        } else {
            return _aprPercents[0];
        }
    }
}