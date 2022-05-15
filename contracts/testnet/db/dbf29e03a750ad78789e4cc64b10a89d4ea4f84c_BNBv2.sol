/**
 *Submitted for verification at BscScan.com on 2022-05-15
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.13;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract BNBv2 is Ownable {
    struct RewardInfo {
        address user;
        uint256 amount;
    }

    struct Trade {
        address user;
        uint256 amount;
        uint256 time1;
        uint256 time2;
        uint256 value1;
        uint256 value2;
    }

    address public constant GUARD = address(1);
    uint256 public constant ONE_HOUR = 1 hours;
    uint256 public constant ONE_DAY = 1 days;
    uint256 public constant ONE_MONTH = ONE_DAY * 30;

    uint256 public lastBuyTime;
    uint256 public launchTime;
    uint256 public prizePool;
    uint256 public foundationPool;
    uint256 public rewardCount;

    address public marketAddress;

    bool public initialized = false;

    mapping(address => address) public referrals;
    mapping(address => uint256) public buyerTime;
    mapping(uint256 => address) public lastBuyUser;

    uint256 public period;
    uint256[8] private rewardFee = [12, 10, 8, 6, 5, 4, 3, 2];
    mapping(uint256 => uint256) public periodStartTime;
    mapping(uint256 => uint256) public buyerNumber;
    mapping(uint256 => mapping(address => address)) public nextBuyer;
    mapping(uint256 => mapping(address => uint256)) public buyAmount;

    uint256 public invitePeriod;
    uint256[5] private inviteRewardFee = [15, 10, 8, 5, 3];
    mapping(uint256 => uint256) public invitePeriodStartTime;
    mapping(uint256 => uint256) public inviteNumber;
    mapping(uint256 => mapping(address => address)) public nextInviter;
    mapping(uint256 => mapping(address => uint256)) public inviteAmount;

    uint256 public tradeId;
    mapping(address => uint256[]) public userTradeIds;
    mapping(uint256 => Trade) public trades;
    mapping(uint256 => uint256) public lastHarvest;

    constructor(address _marketAddress) {
        marketAddress = _marketAddress;
    }

    function launch() public onlyOwner {
        initialized = true;
        launchTime = block.timestamp;
        lastBuyTime = block.timestamp;

        period = 1;
        periodStartTime[period] = block.timestamp;
        nextBuyer[period][GUARD] = GUARD;

        invitePeriod = 1;
        invitePeriodStartTime[invitePeriod] = block.timestamp;
        nextInviter[invitePeriod][GUARD] = GUARD;
    }

    function deposit(address _ref) public payable {
        require(initialized);

        if (buyerTime[msg.sender] == 0) {
            buyerTime[msg.sender] = block.timestamp;
        }

        lastBuyTime = block.timestamp;
        lastBuyUser[lastBuyTime] = msg.sender;

        // 40% of fee to prize pool, 60% to market address
        uint256 fee = _depositFee(msg.value);
        payable(owner()).transfer(SafeMath.div(SafeMath.mul(fee, 60), 100));
        prizePool = SafeMath.add(
            prizePool,
            SafeMath.div(SafeMath.mul(fee, 40), 100)
        );

        _ref = _checkRef(_ref);
        _updateBuyAmount(msg.value);

        if (
            referrals[msg.sender] != address(0) &&
            referrals[msg.sender] != owner() &&
            userTradeIds[referrals[msg.sender]].length > 0
        ) {
            _updateInviteAmount(msg.value, referrals[msg.sender]);
        }

        _trade(SafeMath.sub(msg.value, fee), _ref);
    }

    function hatch(address _ref) public {
        require(initialized);
        uint256 reward = getRewardSinceLastHarvest(msg.sender);
        require(reward > 0);
        for (uint256 i = 0; i < userTradeIds[msg.sender].length; i++) {
            lastHarvest[userTradeIds[msg.sender][i]] = block.timestamp;
        }
        _ref = _checkRef(_ref);
        _trade(reward, _ref);
    }

    function harvest() public {
        require(initialized);
        _checkAndPayReward();

        uint256 reward = getRewardSinceLastHarvest(msg.sender);
        require(getBalance() > reward);

        // 50% of fee to prize pool, 50% to market address
        uint256 fee = _harvestFee(reward);
        payable(marketAddress).transfer(
            SafeMath.div(SafeMath.mul(fee, 50), 100)
        );
        prizePool = SafeMath.add(
            prizePool,
            SafeMath.div(SafeMath.mul(fee, 50), 100)
        );

        for (uint256 i = 0; i < userTradeIds[msg.sender].length; i++) {
            lastHarvest[userTradeIds[msg.sender][i]] = block.timestamp;
        }

        payable(msg.sender).transfer(SafeMath.sub(reward, fee));
    }

    function calculateFee(address _user) public view returns (uint256) {
        if (buyerTime[_user] == 0) return 10;
        uint256 timestamp = block.timestamp - buyerTime[_user];
        uint256 months = timestamp / ONE_MONTH;
        return months < 10 ? 10 - months : 1;
    }

    function getRewardSinceLastHarvest(address _user)
        public
        view
        returns (uint256 _reward)
    {
        for (uint256 i = 0; i < userTradeIds[_user].length; i++) {
            uint256 id = userTradeIds[_user][i];
            if (lastHarvest[id] > trades[id].time2) {
                _reward = SafeMath.add(
                    _reward,
                    SafeMath.mul(
                        block.timestamp - lastHarvest[id],
                        trades[id].value2
                    )
                );
            } else {
                uint256 time1 = block.timestamp - lastHarvest[id];
                uint256 time2 = block.timestamp > trades[id].time2
                    ? block.timestamp - trades[id].time2
                    : 0;
                if (time2 != 0) time1 -= time2;

                _reward = SafeMath.add(
                    _reward,
                    SafeMath.add(
                        SafeMath.mul(time1, trades[id].value1),
                        SafeMath.mul(time2, trades[id].value2)
                    )
                );
            }
        }
    }

    function getRewardPerDay(address _user)
        public
        view
        returns (uint256 _reward)
    {
        for (uint256 i = 0; i < userTradeIds[_user].length; i++) {
            uint256 id = userTradeIds[_user][i];
            if (block.timestamp > trades[id].time2) {
                _reward = SafeMath.add(
                    _reward,
                    SafeMath.mul(ONE_DAY, trades[id].value2)
                );
            } else {
                _reward = SafeMath.add(
                    _reward,
                    SafeMath.mul(ONE_DAY, trades[id].value1)
                );
            }
        }
    }

    function getTopBuyers(uint256 _period, uint256 _length)
        public
        view
        returns (RewardInfo[] memory)
    {
        uint256 count = min(_length, buyerNumber[_period]);
        RewardInfo[] memory _results = new RewardInfo[](count);
        address currentAddress = nextBuyer[_period][GUARD];
        for (uint256 i = 0; i < count; ++i) {
            _results[i] = RewardInfo(
                currentAddress,
                buyAmount[_period][currentAddress]
            );
            currentAddress = nextBuyer[_period][currentAddress];
        }
        return _results;
    }

    function getTopInviters(uint256 _period, uint256 _length)
        public
        view
        returns (RewardInfo[] memory)
    {
        uint256 count = min(_length, inviteNumber[_period]);
        RewardInfo[] memory _results = new RewardInfo[](count);
        address currentAddress = nextInviter[_period][GUARD];
        for (uint256 i = 0; i < count; ++i) {
            _results[i] = RewardInfo(
                currentAddress,
                inviteAmount[_period][currentAddress]
            );
            currentAddress = nextInviter[_period][currentAddress];
        }
        return _results;
    }

    function getBalance() public view returns (uint256) {
        return
            SafeMath.sub(
                SafeMath.sub(address(this).balance, getPrizePoolBalance()),
                getFoundationPoolBalance()
            );
    }

    function getPrizePoolBalance() public view returns (uint256) {
        return prizePool;
    }

    function getFoundationPoolBalance() public view returns (uint256) {
        return foundationPool;
    }

    function getLastBuyTime() public view returns (uint256) {
        return lastBuyTime;
    }

    function getLastBuyUser() public view returns (address) {
        return lastBuyUser[lastBuyTime];
    }

    function withdrawFoundation() external onlyOwner {
        require(block.timestamp - launchTime >= 365 * ONE_DAY);
        payable(msg.sender).transfer(foundationPool);
        foundationPool = 0;
    }

    function _trade(uint256 _amount, address _ref) internal {
        require(_amount > 0);
        _checkAndPayReward();

        tradeId++;
        (uint256 value1, uint256 value2) = _calculateRewardPerSecond(_amount);
        trades[tradeId] = Trade(
            msg.sender,
            _amount,
            block.timestamp,
            block.timestamp + ONE_DAY * 40,
            value1,
            value2
        );
        userTradeIds[msg.sender].push(tradeId);
        lastHarvest[tradeId] = block.timestamp;

        //send referral reward
        tradeId++;
        uint256 _referralAmount = SafeMath.div(SafeMath.mul(_amount, 10), 100);
        (uint256 value3, uint256 value4) = _calculateRewardPerSecond(
            _referralAmount
        );
        trades[tradeId] = Trade(
            _ref,
            _referralAmount,
            block.timestamp,
            block.timestamp + ONE_DAY * 40,
            value3,
            value4
        );
        userTradeIds[_ref].push(tradeId);
        lastHarvest[tradeId] = block.timestamp;
    }

    function _depositFee(uint256 _amount) internal pure returns (uint256) {
        return SafeMath.div(SafeMath.mul(_amount, 5), 100); // 5%
    }

    function _harvestFee(uint256 _amount) internal view returns (uint256) {
        uint256 fee = calculateFee(msg.sender);
        return SafeMath.div(SafeMath.mul(_amount, fee), 100);
    }

    function _calculateRewardPerSecond(uint256 _amount)
        internal
        pure
        returns (uint256 value1, uint256 value2)
    {
        value1 = SafeMath.div(
            SafeMath.div(SafeMath.mul(_amount, 5), 100),
            ONE_DAY
        );
        value2 = SafeMath.div(_amount, ONE_DAY * 365);
    }

    function _checkRef(address _ref) internal returns (address) {
        if (
            _ref == msg.sender ||
            _ref == address(0) ||
            userTradeIds[_ref].length == 0
        ) {
            _ref = owner();
        }
        if (referrals[msg.sender] == address(0)) {
            referrals[msg.sender] = _ref;
        }
        return referrals[msg.sender];
    }

    function _checkAndPayReward() internal {
        if (
            block.timestamp - invitePeriodStartTime[invitePeriod] >=
            ONE_DAY * 7 &&
            prizePool > 0
        ) {
            // get top 5 inviters for the past week
            RewardInfo[] memory _inviters = getTopInviters(invitePeriod, 5);
            uint256 _rewardValue;
            for (uint256 i = 0; i < _inviters.length; i++) {
                address _inviter = _inviters[i].user;
                if (_inviter != address(0) && _inviter != address(1)) {
                    uint256 _value = SafeMath.div(
                        SafeMath.mul(prizePool, inviteRewardFee[i]),
                        100
                    );
                    payable(_inviter).transfer(_value);
                    _rewardValue += _value;
                }
            }
            prizePool = SafeMath.sub(prizePool, _rewardValue);

            invitePeriod += 1;
            invitePeriodStartTime[invitePeriod] = block.timestamp;
            nextInviter[invitePeriod][GUARD] = GUARD;
        }

        if (
            block.timestamp - periodStartTime[period] >= ONE_HOUR * 72 &&
            prizePool > 0
        ) {
            // get top 8 buyers for the past 72 hours
            RewardInfo[] memory _buyers = getTopBuyers(period, 8);
            uint256 _rewardValue;
            for (uint256 i = 0; i < _buyers.length; i++) {
                address _buyer = _buyers[i].user;
                if (_buyer != address(0) && _buyer != address(1)) {
                    uint256 _value = SafeMath.div(
                        SafeMath.mul(prizePool, rewardFee[i]),
                        100
                    );
                    payable(_buyer).transfer(_value);
                    _rewardValue += _value;
                }
            }

            prizePool = SafeMath.div(
                SafeMath.mul(SafeMath.sub(prizePool, _rewardValue), 50),
                100
            );
            foundationPool = SafeMath.add(foundationPool, prizePool);
            rewardCount += 1;

            period += 1;
            periodStartTime[period] = block.timestamp;
            nextBuyer[period][GUARD] = GUARD;

            if (rewardCount == 5 && foundationPool > 0) {
                foundationPool = SafeMath.div(
                    SafeMath.mul(foundationPool, 50),
                    100
                );
                prizePool = SafeMath.add(prizePool, foundationPool);
                rewardCount = 0;
            }
        }

        // if no one buy for 24 hours, then transfer all of the bnb to last buy user
        if (
            lastBuyTime > 0 &&
            block.timestamp - lastBuyTime >= ONE_DAY &&
            lastBuyUser[lastBuyTime] != address(0) &&
            getBalance() > 0
        ) {
            payable(lastBuyUser[lastBuyTime]).transfer(getBalance());
        }
    }

    function _updateInviteAmount(uint256 _amount, address _inviter) internal {
        if (nextInviter[invitePeriod][_inviter] != address(0)) {
            address preInviter = _findPreInviter(_inviter);
            nextInviter[invitePeriod][preInviter] = nextInviter[invitePeriod][
                _inviter
            ];
            nextInviter[invitePeriod][_inviter] = address(0);
            inviteNumber[invitePeriod] -= 1;
        }

        inviteAmount[invitePeriod][_inviter] = SafeMath.add(
            inviteAmount[invitePeriod][_inviter],
            _amount
        );
        address index = _findInviteIndex(inviteAmount[invitePeriod][_inviter]);
        nextInviter[invitePeriod][_inviter] = nextInviter[invitePeriod][index];
        nextInviter[invitePeriod][index] = _inviter;
        inviteNumber[invitePeriod] += 1;
    }

    function _verifyInviteIndex(
        address _preInviter,
        uint256 _newValue,
        address _nextInviter
    ) internal view returns (bool) {
        return
            (_preInviter == GUARD ||
                inviteAmount[invitePeriod][_preInviter] >= _newValue) &&
            (_nextInviter == GUARD ||
                _newValue > inviteAmount[invitePeriod][_nextInviter]);
    }

    function _findInviteIndex(uint256 _newValue)
        internal
        view
        returns (address index)
    {
        index = GUARD;
        while (true) {
            if (
                _verifyInviteIndex(
                    index,
                    _newValue,
                    nextInviter[invitePeriod][index]
                )
            ) return index;
            index = nextInviter[invitePeriod][index];
        }
    }

    function _isPreInviter(address _inviter, address _preInviter)
        internal
        view
        returns (bool)
    {
        return nextInviter[invitePeriod][_preInviter] == _inviter;
    }

    function _findPreInviter(address _inviter) internal view returns (address) {
        address currentAddress = GUARD;
        while (nextInviter[invitePeriod][currentAddress] != GUARD) {
            if (_isPreInviter(_inviter, currentAddress)) return currentAddress;
            currentAddress = nextInviter[invitePeriod][currentAddress];
        }
        return address(0);
    }

    function _updateBuyAmount(uint256 _amount) internal {
        if (nextBuyer[period][msg.sender] != address(0)) {
            address preBuyer = _findPreBuyer(msg.sender);
            nextBuyer[period][preBuyer] = nextBuyer[period][msg.sender];
            nextBuyer[period][msg.sender] = address(0);
            buyerNumber[period] -= 1;
        }

        buyAmount[period][msg.sender] = SafeMath.add(
            buyAmount[period][msg.sender],
            _amount
        );
        address index = _findIndex(buyAmount[period][msg.sender]);
        nextBuyer[period][msg.sender] = nextBuyer[period][index];
        nextBuyer[period][index] = msg.sender;
        buyerNumber[period] += 1;
    }

    function _verifyIndex(
        address _preBuyer,
        uint256 _newValue,
        address _nextBuyer
    ) internal view returns (bool) {
        return
            (_preBuyer == GUARD || buyAmount[period][_preBuyer] >= _newValue) &&
            (_nextBuyer == GUARD || _newValue > buyAmount[period][_nextBuyer]);
    }

    function _findIndex(uint256 _newValue)
        internal
        view
        returns (address index)
    {
        index = GUARD;
        while (true) {
            if (_verifyIndex(index, _newValue, nextBuyer[period][index]))
                return index;
            index = nextBuyer[period][index];
        }
    }

    function _isPreBuyer(address _buyer, address _preBuyer)
        internal
        view
        returns (bool)
    {
        return nextBuyer[period][_preBuyer] == _buyer;
    }

    function _findPreBuyer(address _buyer) internal view returns (address) {
        address currentAddress = GUARD;
        while (nextBuyer[period][currentAddress] != GUARD) {
            if (_isPreBuyer(_buyer, currentAddress)) return currentAddress;
            currentAddress = nextBuyer[period][currentAddress];
        }
        return address(0);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}

library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
     * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}