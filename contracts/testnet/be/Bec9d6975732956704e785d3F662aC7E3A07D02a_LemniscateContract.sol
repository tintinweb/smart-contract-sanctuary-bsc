// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./IBEP20.sol";
import "./SafeMath.sol";

contract LemniscateContract {
    using SafeMath for uint256;

    struct User {
        uint256 joinTime;
        address referrer;
        uint256 totalDepositUsd;
        uint256 totalWithdrawUsd;
        uint256 totalDepositUsdForReward;
        uint256 totalSponsorUsdForReward;
        uint256 numToken;
        uint256 withdrawableSellUsd;
        uint256 withdrawableCommissionUsd;
        uint256 withdrawableRewardUsd;
        uint256 lastDrawRewardTime;
        uint256 rerunToPayUsd;
        uint256 rerunCriteriaUsd;
        uint256 withdrawableRerunUsd;
        bool rerunLock;
    }

    IBEP20 private _usdToken;
    IBEP20 private _lmncToken;
    mapping(address => User) private _userMaps;
    mapping(uint256 => address) private _rerunMaps;

    address private _owner;
    address private _stakingAddress;
    address private _developerAddress;

    uint256 private _userCount;
    uint256 private _totalDepositUsd;
    uint256 private _totalWithdrawUsd;
    uint256 private _totalTokenSupply;

    uint256 constant private INITIAL_TOKEN_PRICE = 1e15;
    uint256 constant private BALANCE_IN_SMART_CONTRACT_FOR_SAME_PRICE = 800e18;
    uint256 constant private BUY_PRICE_INCREASING = 3;
    uint256 constant private MAX_BUY_PRICE_SELL_PRICE_DIFFERENT_PERCENT = 3;

    uint256 constant private COMMISSION_PERCENT = 5;
    
    uint256 private _totalDepositUsdForReward;
    uint256 private _lastDrawRewardTime;

    uint256 constant private DRAW_REWARD_PERIOD = 30 days;
    uint256[3] private REWARD_PERTTHS = [125, 75, 50];
    address[3] private _topDepositUsers = [ address(0), address(0), address(0) ];
    address[3] private _topSponsorUsers = [ address(0), address(0), address(0) ];

    uint256 constant private STAKING_PERCENT = 10;
    uint256 constant private BUY_LMNC_PERCENT = 40;
    uint256 constant private RERUN_PERCENT = 30;

    uint256 private _rerunCriteriaUsd;
    uint256 private _rerunTotalUsd;
    uint256 private _rerunIdPay;
    uint256 private _rerunIdNext;

    uint256 constant private RERUN_PAYBACK_PERCENT = 80;

    uint256 constant private OWNER_PERCENT = 3;
    uint256 constant private DEVELOPER_PERCENT = 7;

    constructor(IBEP20 usdToken, IBEP20 lmncToken, address stakingAddress, address developerAddress) public {
        _usdToken = usdToken;
        _lmncToken = lmncToken;
        _stakingAddress = stakingAddress;
        _developerAddress = developerAddress;
        _owner = msg.sender;
        _lastDrawRewardTime = block.timestamp;
        _rerunCriteriaUsd = 0;
        _rerunTotalUsd = 0;
        _rerunIdPay = 0;
        _rerunIdNext = 0;
    }

    receive() external payable {
        revert("Not allowed");
    }
    
    function getSystemInfo() external view returns(uint256[] memory) {
        uint256[] memory info = new uint256[](15);

        info[0] = _userCount;
        info[1] = _totalDepositUsd;
        info[2] = _totalWithdrawUsd;
        info[3] = _totalTokenSupply;
        info[4] = _totalDepositUsdForReward;
        info[5] = _lastDrawRewardTime;
        info[6] = _rerunCriteriaUsd;
        info[7] = _rerunTotalUsd;
        info[8] = _rerunIdPay;
        info[9] = _rerunIdNext;
        info[10] = getContractBalanceUsd();
        info[11] = _totalTokenSupply;
        info[12] = _lastDrawRewardTime.add(DRAW_REWARD_PERIOD).subNoNegative(block.timestamp);
        info[13] = getSellPrice();
        info[14] = getBuyPrice();

        return info;
    }

    function getSystemUsers() external view returns(address, address, address) {
        return (_owner, _stakingAddress, _developerAddress);
    }

    function getTopUsers() external view returns(address[] memory, uint256[] memory, address[] memory, uint256[] memory) {
        address[] memory topDepositUsers = new address[](3);
        address[] memory topSponsorUsers = new address[](3);
        uint256[] memory topDepositUsd = new uint256[](3);
        uint256[] memory topSponsorUsd = new uint256[](3);

        for (uint i = 0; i < _topDepositUsers.length; i++) {
            topDepositUsers[i] = _topDepositUsers[i];
            topDepositUsd[i] = _userMaps[_topDepositUsers[i]].totalDepositUsdForReward;
            topSponsorUsers[i] = _topSponsorUsers[i];
            topSponsorUsd[i] = _userMaps[_topSponsorUsers[i]].totalSponsorUsdForReward;
        }

        return (topDepositUsers, topDepositUsd, topSponsorUsers, topSponsorUsd);
    }

    function getUserInfo(address user) external view returns(uint256[] memory, address) {
        uint256[] memory info = new uint256[](14);

        if (hasUserJoined(user)) {
            info[0] = _userMaps[user].joinTime;
            info[1] = _userMaps[user].totalDepositUsd;
            info[2] = _userMaps[user].totalWithdrawUsd;
            info[3] = _userMaps[user].totalDepositUsdForReward;
            info[4] = _userMaps[user].totalSponsorUsdForReward;
            info[5] = _userMaps[user].numToken;
            info[6] = _userMaps[user].withdrawableSellUsd;
            info[7] = _userMaps[user].withdrawableCommissionUsd;
            info[8] = _userMaps[user].withdrawableRewardUsd;
            info[9] = _userMaps[user].lastDrawRewardTime;
            info[10] = _userMaps[user].rerunToPayUsd;
            info[11] = _userMaps[user].rerunCriteriaUsd;
            info[12] = _userMaps[user].withdrawableRerunUsd;

            if (_userMaps[user].rerunLock) {
                info[13] = 1;
            } else {
                info[13] = 0;
            }

            return (info, _userMaps[user].referrer);
        } else {
            for (uint256 i = 0; i < info.length; i++) {
                info[i] = 0;
            }

            return (info, address(0));
        }
    }

    function getRerunInfo() external view returns(uint256, uint256[] memory, address[] memory) {
        if (_rerunIdPay < _rerunIdNext) {
            uint256 count = _rerunIdNext - _rerunIdPay;
            uint256[] memory info = new uint256[](count);
            address[] memory users = new address[](count);
            for (uint256 i = _rerunIdPay; i < _rerunIdNext; i++) {
                info[i - _rerunIdPay] = _userMaps[_rerunMaps[i]].rerunToPayUsd;
                users[i - _rerunIdPay] = _rerunMaps[i];
            }
            return (count, info, users);
        } else {
            uint256[] memory info = new uint256[](1);
            address[] memory users = new address[](1);
            info[0] = 0;
            users[0] = address(0);
            return (0, info, users);
        }
    }

    function getTokenAddresses() public view returns(address, address, address) {
        return (address(_usdToken), address(_lmncToken), _stakingAddress);
    }

    function setOwner(address newOwner) external returns(address) {
        if (msg.sender != _owner) {
            revert("This is for the owner only");
        }
        _owner = newOwner;
        return _owner;
    }

    function setUsdTokenAddress(IBEP20 token) external returns(address) {
        if (msg.sender != _owner) {
            revert("This is for the owner only");
        }
        _usdToken = token;
        return address(_usdToken);
    }

    function setLmncTokenAddress(IBEP20 token) external returns(address) {
        if (msg.sender != _owner) {
            revert("This is for the owner only");
        }
        _lmncToken = token;
        return address(_lmncToken);
    }

    function setStakingAddress(address stakingAddress) external returns(address) {
        if (msg.sender != _owner) {
            revert("This is for the owner only");
        }
        _stakingAddress = stakingAddress;
        return _stakingAddress;
    }

    function getContractBalanceUsd() public view returns(uint256) {
        return _usdToken.balanceOf(address(this));
    }

    function getTokenSupply() public view returns(uint256) {
        return _totalTokenSupply;
    }

    function getSellPrice() public view returns (uint256) {
        if (_totalTokenSupply > 0) {
            uint256 contractBalanceUsd = getContractBalanceUsd();
            return contractBalanceUsd.div(_totalTokenSupply);
        } else {
            return INITIAL_TOKEN_PRICE;
        }
    }

    function getBuyPrice() public view returns (uint256) {
        uint256 contractBalanceUsd = getContractBalanceUsd();
        uint256 max = contractBalanceUsd.div(BALANCE_IN_SMART_CONTRACT_FOR_SAME_PRICE);
        uint256 buyPrice = INITIAL_TOKEN_PRICE;
        uint256 sellPrice = getSellPrice();

        for (uint256 i = 0; i < max; i++) {
            if (buyPrice.subNoNegative(sellPrice).mul(100).div(buyPrice) < MAX_BUY_PRICE_SELL_PRICE_DIFFERENT_PERCENT) {
                buyPrice = buyPrice.permill(1000 + BUY_PRICE_INCREASING);    
            } else {
                return sellPrice;
            }
        }
        
        return buyPrice;
    }

    function hasUserJoined(address user) public view returns(bool) {
        if (_userMaps[user].joinTime > 0) {
            return true;
        }
        return false;
    }

    function getTokensReceived(uint256 valueBuyUsd) public view returns (uint256) {
        return valueBuyUsd.div(getBuyPrice());
    }

    function getUsdReceived(uint256 amountSellToken) public view returns (uint256) {
        return amountSellToken.mul(getSellPrice());
    }

    function buy(uint256 valueUsd, address referrer) external returns(bool) {
        address user = msg.sender;

        if (user == _owner) {
            revert("Owner cannot join");
        }

        if (user == referrer) {
            revert("Self-referring is not allowed");
        }

        if (!hasUserJoined(user)) {
            if (!hasUserJoined(referrer) && referrer != _owner) {
                revert("Invalid referrer user");
            }

            initNewUser(referrer);
        } else {
            if (_userMaps[user].rerunLock) {
                revert("Waiting for rerun to finish");
            }

            referrer = _userMaps[user].referrer;
        }

        doRewards();

        _usdToken.transferFrom(user, address(this), valueUsd);
        _userMaps[user].totalDepositUsd = _userMaps[user].totalDepositUsd.add(valueUsd);

        doCommission(valueUsd);
        doSystemFee(valueUsd);
        doStaking(valueUsd);
        doBuyLmncToken(valueUsd);
        doRerun(valueUsd);

        _totalDepositUsd = _totalDepositUsd.add(valueUsd);
        _totalDepositUsdForReward = _totalDepositUsdForReward.add(valueUsd);

        if (_userMaps[user].lastDrawRewardTime < _lastDrawRewardTime) {
            _userMaps[user].lastDrawRewardTime = _lastDrawRewardTime;
            _userMaps[user].totalDepositUsdForReward = valueUsd;
        } else {
            _userMaps[user].totalDepositUsdForReward = _userMaps[user].totalDepositUsdForReward.add(valueUsd);
        }

        if (referrer != _owner) {
            if (_userMaps[referrer].lastDrawRewardTime < _lastDrawRewardTime) {
                _userMaps[referrer].lastDrawRewardTime = _lastDrawRewardTime;
                _userMaps[referrer].totalSponsorUsdForReward = valueUsd;
            } else {
                _userMaps[referrer].totalSponsorUsdForReward = _userMaps[referrer].totalSponsorUsdForReward.add(valueUsd);
            }
            updateTopSponsorUsers(referrer);
        }

        updateTopDepositUsers(user);

        return true;
    }

    function sell(uint256 numSellToken) external returns(bool) {
        address user = msg.sender;

        if (!hasUserJoined(user)) {
            revert("User has not joined");
        }

        if (numSellToken > _userMaps[user].numToken) {
            revert("Overselling token is not allowed");
        }

        uint256 valueUsd = getUsdReceived(numSellToken);

        if (getContractBalanceUsd() <= valueUsd) {
            revert("Contract overpay on selling!");
        }

        _lmncToken.transferFrom(user, address(this), numSellToken);

        _userMaps[user].withdrawableSellUsd = _userMaps[user].withdrawableSellUsd.add(valueUsd);
        _userMaps[user].numToken = _userMaps[user].numToken.subNoNegative(numSellToken);
        _totalTokenSupply = _totalTokenSupply.subNoNegative(numSellToken);

        return true;
    }

    function withdraw() external returns(bool) {
        address user = msg.sender;

        if (!hasUserJoined(user)) {
            revert("User has not joined");
        }

        uint256 withdrawUsd = 0;

        withdrawUsd = withdrawUsd.add(_userMaps[user].withdrawableSellUsd);
        withdrawUsd = withdrawUsd.add(_userMaps[user].withdrawableCommissionUsd);
        withdrawUsd = withdrawUsd.add(_userMaps[user].withdrawableRewardUsd);
        withdrawUsd = withdrawUsd.add(_userMaps[user].withdrawableRerunUsd);

        if (withdrawUsd > 0) {
            if (getContractBalanceUsd() > withdrawUsd) {
                _usdToken.transfer(user, withdrawUsd);
                _totalWithdrawUsd = _totalWithdrawUsd.add(withdrawUsd);
                _userMaps[user].withdrawableSellUsd = 0;
                _userMaps[user].withdrawableCommissionUsd = 0;
                _userMaps[user].withdrawableRewardUsd = 0;
                _userMaps[user].withdrawableRerunUsd =0;
                _userMaps[user].totalWithdrawUsd = _userMaps[user].totalWithdrawUsd.add(withdrawUsd);
            } else {
                revert("Contract overpay on withdrawing!");
            }
        } else {
            revert("Withdrawals are not allowed");
        }

        return true;
    }

    function initNewUser(address referrer) private {
        address user = msg.sender;
        _userMaps[user].joinTime = block.timestamp;
        _userMaps[user].referrer = referrer;
        _userMaps[user].totalDepositUsd = 0;
        _userMaps[user].totalWithdrawUsd = 0;
        _userMaps[user].totalDepositUsdForReward = 0;
        _userMaps[user].totalSponsorUsdForReward = 0;
        _userMaps[user].numToken = 0;
        _userMaps[user].withdrawableSellUsd = 0;
        _userMaps[user].withdrawableCommissionUsd =0;
        _userMaps[user].withdrawableRewardUsd = 0;
        _userMaps[user].lastDrawRewardTime = 0;
        _userMaps[user].rerunToPayUsd = 0;
        _userMaps[user].rerunCriteriaUsd = 0;
        _userMaps[user].rerunLock = false;
        _userCount = _userCount.add(1);
    }

    function doCommission(uint256 valueUsd) private {
        address user = msg.sender;
        address referrer = _userMaps[user].referrer;

        if (referrer != _owner) {
            uint256 commissionUsd = valueUsd.percent(COMMISSION_PERCENT);
            _userMaps[referrer].withdrawableCommissionUsd = _userMaps[referrer].withdrawableCommissionUsd.add(commissionUsd);
        }
    }

    function doSystemFee(uint256 valueUsd) private {
        uint256 ownerUsd = valueUsd.percent(OWNER_PERCENT);
        _usdToken.transfer(_owner, ownerUsd);

        uint256 developerUsd = valueUsd.percent(DEVELOPER_PERCENT);
        _usdToken.transfer(_developerAddress, developerUsd);
    }

    function doStaking(uint256 valueUsd) private {
        uint256 stakingUsd = valueUsd.percent(STAKING_PERCENT);
        _usdToken.transfer(_stakingAddress, stakingUsd);
    }

    function doBuyLmncToken(uint256 valueUsd) private {
        address user = msg.sender;
        uint256 numToken = getTokensReceived(valueUsd.percent(BUY_LMNC_PERCENT));
        _lmncToken.transfer(user, numToken);
        _userMaps[user].numToken = _userMaps[user].numToken.add(numToken);
        _totalTokenSupply = _totalTokenSupply.add(numToken);
    }

    function doRerun(uint256 valueUsd) private {
        address user = msg.sender;
        uint256 rerunUsd = valueUsd.percent(RERUN_PAYBACK_PERCENT);

        _rerunCriteriaUsd = _rerunCriteriaUsd.add(rerunUsd);
        _userMaps[user].rerunCriteriaUsd = _rerunCriteriaUsd;
        
        _userMaps[user].rerunToPayUsd = rerunUsd;
        _userMaps[user].rerunLock = true;

        _rerunMaps[_rerunIdNext] = user;
        _rerunIdNext = _rerunIdNext.add(1);

        _rerunTotalUsd = _rerunTotalUsd.add(valueUsd.percent(RERUN_PERCENT));

        for (uint256 i = _rerunIdPay; i < _rerunIdNext; i++) {
            address rerunUser = _rerunMaps[i];

            if (_rerunTotalUsd < _userMaps[rerunUser].rerunCriteriaUsd) {
                break;
            }

            _userMaps[rerunUser].withdrawableRerunUsd = _userMaps[rerunUser].withdrawableRerunUsd.add(_userMaps[rerunUser].rerunToPayUsd);
            _userMaps[rerunUser].rerunLock = false;
            _rerunIdPay = _rerunIdPay.add(1);
        }
    }

    function doRewards() private {
        if (block.timestamp.subNoNegative(_lastDrawRewardTime) >= DRAW_REWARD_PERIOD) {
            _lastDrawRewardTime = block.timestamp;

            for (uint i = 0; i < _topDepositUsers.length; i++) {
                address user = _topDepositUsers[i];

                if (user != address(0)) {
                    _userMaps[user].withdrawableRewardUsd = _userMaps[user].withdrawableRewardUsd.add(_totalDepositUsdForReward.pertths(REWARD_PERTTHS[i]));
                    _userMaps[user].totalDepositUsdForReward = 0;
                }

                _topDepositUsers[i] = address(0);
            }

            for (uint i = 0; i < _topSponsorUsers.length; i++) {
                address user = _topSponsorUsers[i];

                if (user != address(0)) {
                    _userMaps[user].withdrawableRewardUsd = _userMaps[user].withdrawableRewardUsd.add(_totalDepositUsdForReward.pertths(REWARD_PERTTHS[i]));
                    _userMaps[user].totalSponsorUsdForReward = 0;
                }

                _topSponsorUsers[i] = address(0);
            }

            _totalDepositUsdForReward = 0;
        }
    }

    function updateTopSponsorUsers(address referrer) private {
        removeUserFromTopSponsorUsers(referrer);

        for (uint i = 0; i < _topSponsorUsers.length; i++) {
            if (_topSponsorUsers[i] == address(0)) {
                _topSponsorUsers[i] = referrer;
                break;
            } else {
                if (_userMaps[referrer].totalSponsorUsdForReward > _userMaps[_topSponsorUsers[i]].totalSponsorUsdForReward) {
                    shiftDownTopSponsorUsers(i);
                    _topSponsorUsers[i] = referrer;
                    break;
                }
            }
        }
    }

    function removeUserFromTopSponsorUsers(address user) private {
        for (uint i = 0; i < _topSponsorUsers.length; i++) {
            if (user == _topSponsorUsers[i]) {
                shiftUpTopSponsorUsers(i);
                break;
            }
        }
    }

    function shiftUpTopSponsorUsers(uint256 index) private {
        for (uint i = index; i < _topSponsorUsers.length - 1; i++) {
            _topSponsorUsers[i] = _topSponsorUsers[i + 1];
        }

        _topSponsorUsers[_topSponsorUsers.length - 1] = address(0);
    }

    function shiftDownTopSponsorUsers(uint256 index) private {
        for (uint i = _topSponsorUsers.length - 1; i > index; i--) {
            _topSponsorUsers[i] = _topSponsorUsers[i - 1];
        }

        _topSponsorUsers[index] = address(0);
    }

    function updateTopDepositUsers(address user) private {
        removeUserFromTopDepositUsers(user);

        for (uint i = 0; i < _topDepositUsers.length; i++) {
            if (_topDepositUsers[i] == address(0)) {
                _topDepositUsers[i] = user;
                break;
            } else {
                if (_userMaps[user].totalDepositUsdForReward > _userMaps[_topDepositUsers[i]].totalDepositUsdForReward) {
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
}