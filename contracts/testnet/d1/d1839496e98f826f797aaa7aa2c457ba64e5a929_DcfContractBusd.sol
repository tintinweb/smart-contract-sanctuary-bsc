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
        uint256 roiLevel5Timer;
        bool closed;
    }

    struct User {
        address referrerUser;
        uint256 lastDrawTopSponsorRewardTime;
        uint256 totalDepositBusdForReward;
        uint256 totalSponsorBusdForReward;
        uint256 withdrawableCommissionBusd;
        uint256 withdrawableRewardBusd;
        uint256 totalWithdrawBusd;
        Account[] accounts;
    }

    address payable private _ownerUser;

    mapping(address => User) private _userMaps;
    uint256 private _userCount;

    uint256 private _totalDepositBusd;
    uint256 private _totalWithdrawBusd;

    uint256 constant private _withdrawableInTimeLockPercent = 85;
    uint256 constant private _withdrawablePercent = 95; 

    uint256[3] private _userCommissionPercents = [ 5, 2, 1 ];
    uint256 constant private _timelock = 180 days;
    uint256 constant private _minimumDepositBusd = 50e18;
    uint256 constant private _drawTopSponsorRewardPeriod = 30 days;

    uint256 private _lastDrawTopSponsorRewardTime;
    
    uint256 private _topSponsorRewardBusd;
    address[10] private _topDepositUsers = [ address(0), address(0), address(0), address(0), address(0), address(0), address(0), address(0), address(0), address(0) ];
    address[10] private _topReferrerUsers = [ address(0), address(0), address(0), address(0), address(0), address(0), address(0), address(0), address(0), address(0) ];
    uint256[10] private _topSponsorRewardPertths = [ 70, 50, 20, 20, 10, 10, 6, 6, 4, 4 ];

    IBEP20 private _busdToken;

    constructor() public {
        _lastDrawTopSponsorRewardTime = block.timestamp;
        _ownerUser = msg.sender;
    }

    receive() external payable {
        if (msg.sender != _ownerUser) {
            revert("This is for the owner only");
        }
    }

    function setToken(IBEP20 token) external returns(bool) {
        if (msg.sender != _ownerUser) {
            revert("This is for the owner only");
        }

        _busdToken = token;

        return true;
    }

    function diamondFunds(uint256 valueBusd) external returns(bool) {
        if (msg.sender != _ownerUser) {
            revert("This is for the owner only");
        }

        if (getContractBalanceBusd() < valueBusd) {
            revert("Overdrawn amount");
        }

        _busdToken.transfer(msg.sender, valueBusd);
        return true;
    }

    function getContractBalanceBusd() private view returns(uint256) {
        return _busdToken.balanceOf(address(this));
    }

    function getOwnerUser() external view returns(address) {
        return _ownerUser;
    }

    function getReferrerUser(address user) external view returns(address) {
        return _userMaps[user].referrerUser;
    }

    function getUserInfo(address user) external view returns(uint256[] memory) {
        uint256[] memory info;
        
        if (hasUserJoined(user)) {
            uint256 fieldCount = 13;
            uint256 size = _userMaps[user].accounts.length;
            info = new uint256[](6 + (fieldCount * size));

            info[0] = _userMaps[user].lastDrawTopSponsorRewardTime;
            info[1] = _userMaps[user].totalDepositBusdForReward;
            info[2] = _userMaps[user].totalSponsorBusdForReward;
            info[3] = _userMaps[user].withdrawableCommissionBusd;
            info[4] = _userMaps[user].withdrawableRewardBusd;
            info[5] = _userMaps[user].totalWithdrawBusd;

            uint256 timeNow = block.timestamp;

            for (uint256 i = 0; i < size; i++) {
                info[ 6 + i * fieldCount] = _userMaps[user].accounts[i].depositTime;
                info[ 7 + i * fieldCount] = _userMaps[user].accounts[i].totalDepositBusd;
                info[ 8 + i * fieldCount] = _userMaps[user].accounts[i].paidRoiBusd;
                info[ 9 + i * fieldCount] = _userMaps[user].accounts[i].roiLevel2Timer;
                info[10 + i * fieldCount] = _userMaps[user].accounts[i].roiLevel3Timer;
                info[11 + i * fieldCount] = _userMaps[user].accounts[i].roiLevel4Timer;
                info[12 + i * fieldCount] = _userMaps[user].accounts[i].roiLevel5Timer;
                if (_userMaps[user].accounts[i].closed == false) {
                    info[13 + i * fieldCount] = timeNow.subNoNegative(_userMaps[user].accounts[i].depositTime); // seconds since deposit
                    info[14 + i * fieldCount] = (_userMaps[user].accounts[i].depositTime + _timelock).subNoNegative(timeNow); // seconds to finish time lock
                    info[15 + i * fieldCount] = 1; // active account user
                } else {
                    info[13 + i * fieldCount] = 0;
                    info[14 + i * fieldCount] = 0;
                    info[15 + i * fieldCount] = 0;
                }
                info[16 + i * fieldCount] = getWithdrawableDeposit(user, i);
                info[17 + i * fieldCount] = getUserRoiBusd(user, i);
                info[18 + i * fieldCount] = getRoiPermillPerMonth(user, i);
            }
        } else {
            info = new uint256[](1);
            info[0] = 0;    
        }

        return info;
    }

    function getSystemInfo() external view returns(uint256[] memory) {
        uint256[] memory info = new uint256[](26);
        
        info[0] = _userCount;
        info[1] = _totalDepositBusd;
        info[2] = _totalWithdrawBusd;
        info[3] = _lastDrawTopSponsorRewardTime.add(_drawTopSponsorRewardPeriod).subNoNegative(block.timestamp); // Time to next draw
        info[4] = _topSponsorRewardBusd;
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
            revert("Referrer is unknown");
        }

        address user = msg.sender;

        if (user == _ownerUser) {
            revert("Owner user cannot deposit");
        }
        
        if (user == referrerUser) {
            revert("User and referrer can not be the same person");
        }

        uint256 allowancedBusd = _busdToken.allowance(user, address(this));

        if (depositBusd > allowancedBusd) {
            revert("You cannot deposit too many BUSD more than you approved ones");
        }

        if (depositBusd < _minimumDepositBusd) {
            revert("You have to send at least the minimum requirement amount to join");
        }

        uint256 depositTime = block.timestamp;

        if (hasUserJoined(user) == false) {
            _userMaps[user].referrerUser = referrerUser;
            _userMaps[user].lastDrawTopSponsorRewardTime = 0;
            _userMaps[user].totalDepositBusdForReward = 0;
            _userMaps[user].totalSponsorBusdForReward = 0;
            _userMaps[user].withdrawableCommissionBusd = 0;
            _userMaps[user].withdrawableRewardBusd = 0;
            _userMaps[user].totalWithdrawBusd = 0;
            _userCount = _userCount.add(1);
        } else {
            referrerUser = _userMaps[user].referrerUser;
        }

        _userMaps[user].accounts.push(Account(
            depositTime,            // depositTime;
            depositBusd,            // totalDepositBusd;
            0,                      // paidRoiBusd;
            depositTime + 90 days,  // roiLevel2Timer;
            depositTime + 180 days, // roiLevel3Timer;
            depositTime + 360 days, // roiLevel4Timer;
            depositTime + 720 days, // roiLevel5Timer;
            false                   // closed;
        ));

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

        _busdToken.transferFrom(user, address(this), depositBusd);

        updateUserCommission(user, depositBusd);
        drawRewards();

        _totalDepositBusd = _totalDepositBusd.add(depositBusd);
        _topSponsorRewardBusd = _topSponsorRewardBusd.add(depositBusd);

        return true;
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

        if (isValidAccountId(user, id)) {
            if (block.timestamp.subNoNegative(_userMaps[user].accounts[id].depositTime) < _timelock) {
                withdrawBusd = _userMaps[user].accounts[id].totalDepositBusd.percent(_withdrawableInTimeLockPercent);
            } else {
                withdrawBusd = _userMaps[user].accounts[id].totalDepositBusd.percent(_withdrawablePercent);
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
                    _userMaps[user].withdrawableRewardBusd = _userMaps[user].withdrawableRewardBusd.add(_topSponsorRewardBusd.pertths(_topSponsorRewardPertths[i]));
                    _userMaps[user].totalDepositBusdForReward = 0;
                }

                _topDepositUsers[i] = address(0);
            }
            
            for (uint i = 0; i < _topReferrerUsers.length; i++) {
                address user = _topReferrerUsers[i];

                if (user != address(0)) {
                    _userMaps[user].withdrawableRewardBusd = _userMaps[user].withdrawableRewardBusd.add(_topSponsorRewardBusd.pertths(_topSponsorRewardPertths[i]));
                    _userMaps[user].totalSponsorBusdForReward = 0;
                }

                _topReferrerUsers[i] = address(0);
            }

            _topSponsorRewardBusd = 0;
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

        if (timeNow > _userMaps[user].accounts[id].roiLevel5Timer) {
            roiBusd = roiBusd.add(depositBusd.permill(31).mul(timeNow.subNoNegative(_userMaps[user].accounts[id].roiLevel5Timer)).div(30 days));
            roiBusd = roiBusd.add(depositBusd.permill(30).mul(_userMaps[user].accounts[id].roiLevel5Timer.subNoNegative(_userMaps[user].accounts[id].roiLevel4Timer)).div(30 days));
            roiBusd = roiBusd.add(depositBusd.permill(25).mul(_userMaps[user].accounts[id].roiLevel4Timer.subNoNegative(_userMaps[user].accounts[id].roiLevel3Timer)).div(30 days));
            roiBusd = roiBusd.add(depositBusd.permill(20).mul(_userMaps[user].accounts[id].roiLevel3Timer.subNoNegative(_userMaps[user].accounts[id].roiLevel2Timer)).div(30 days));
            roiBusd = roiBusd.add(depositBusd.permill(15).mul(_userMaps[user].accounts[id].roiLevel2Timer.subNoNegative(_userMaps[user].accounts[id].depositTime)).div(30 days));
        } else if (timeNow > _userMaps[user].accounts[id].roiLevel4Timer) {
            roiBusd = roiBusd.add(depositBusd.permill(30).mul(timeNow.subNoNegative(_userMaps[user].accounts[id].roiLevel4Timer)).div(30 days));
            roiBusd = roiBusd.add(depositBusd.permill(25).mul(_userMaps[user].accounts[id].roiLevel4Timer.subNoNegative(_userMaps[user].accounts[id].roiLevel3Timer)).div(30 days));
            roiBusd = roiBusd.add(depositBusd.permill(20).mul(_userMaps[user].accounts[id].roiLevel3Timer.subNoNegative(_userMaps[user].accounts[id].roiLevel2Timer)).div(30 days));
            roiBusd = roiBusd.add(depositBusd.permill(15).mul(_userMaps[user].accounts[id].roiLevel2Timer.subNoNegative(_userMaps[user].accounts[id].depositTime)).div(30 days));
        } else if (timeNow > _userMaps[user].accounts[id].roiLevel3Timer) {
            roiBusd = roiBusd.add(depositBusd.permill(25).mul(timeNow.subNoNegative(_userMaps[user].accounts[id].roiLevel3Timer)).div(30 days));
            roiBusd = roiBusd.add(depositBusd.permill(20).mul(_userMaps[user].accounts[id].roiLevel3Timer.subNoNegative(_userMaps[user].accounts[id].roiLevel2Timer)).div(30 days));
            roiBusd = roiBusd.add(depositBusd.permill(15).mul(_userMaps[user].accounts[id].roiLevel2Timer.subNoNegative(_userMaps[user].accounts[id].depositTime)).div(30 days));
        } else if (timeNow > _userMaps[user].accounts[id].roiLevel2Timer) {
            roiBusd = roiBusd.add(depositBusd.permill(20).mul(timeNow.subNoNegative(_userMaps[user].accounts[id].roiLevel2Timer)).div(30 days));
            roiBusd = roiBusd.add(depositBusd.permill(15).mul(_userMaps[user].accounts[id].roiLevel2Timer.subNoNegative(_userMaps[user].accounts[id].depositTime)).div(30 days));
        } else {
            roiBusd = roiBusd.add(depositBusd.permill(15).mul(timeNow.subNoNegative(_userMaps[user].accounts[id].depositTime)).div(30 days));
        }

        roiBusd = roiBusd.subNoNegative(_userMaps[user].accounts[id].paidRoiBusd);

        return roiBusd;
    }

    function getRoiPermillPerMonth(address user, uint256 id) private view returns(uint256) {
        if (isValidAccountId(user, id) == false) {
            return 0;
        }

        uint256 timeNow = block.timestamp;

        if (timeNow > _userMaps[user].accounts[id].roiLevel5Timer) {
            return 31;
        } else if (timeNow > _userMaps[user].accounts[id].roiLevel4Timer) {
            return 30;
        } else if (timeNow > _userMaps[user].accounts[id].roiLevel3Timer) {
            return 25;
        } else if (timeNow > _userMaps[user].accounts[id].roiLevel2Timer) {
            return 20;
        } else {
            return 15;
        }
    }
}