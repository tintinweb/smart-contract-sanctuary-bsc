/**
 *Submitted for verification at BscScan.com on 2022-05-13
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
    address public constant GUARD = address(1);
    uint256 public constant ONE_HOUR = 0.2 minutes;
    uint256 public constant ONE_DAY = 5 minutes;
    uint256 public constant ONE_MONTH = ONE_DAY * 30;
    uint256 public constant BEEFS_TO_HATCH_1MINERS = 864000; //for final version should be seconds in a day

    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    uint256 public marketBeefs;
    uint256 public lastBuyTime;
    uint256 public launchTime;
    uint256 public prizePool;
    uint256 public foundationPool;
    uint256 public rewardCount;

    address public marketAddress;

    bool public initialized = false;

    mapping(address => uint256) public hatcheryMiners;
    mapping(address => uint256) public claimedBeefs;
    mapping(address => uint256) public lastHatch;
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

    struct RewardInfo {
        address user;
        uint256 amount;
    }

    constructor(address _marketAddress) {
        marketAddress = _marketAddress;
    }

    function hatchBeefs(address ref) public {
        require(initialized);
        _checkReward();

        if (
            ref == msg.sender || ref == address(0) || hatcheryMiners[ref] == 0
        ) {
            ref = owner();
        }

        if (referrals[msg.sender] == address(0)) {
            referrals[msg.sender] = ref;
        }

        if (buyerTime[msg.sender] == 0) {
            buyerTime[msg.sender] = block.timestamp;
        }

        uint256 beefsUsed = getMyBeefs();
        uint256 newMiners = SafeMath.div(beefsUsed, BEEFS_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender] = SafeMath.add(
            hatcheryMiners[msg.sender],
            newMiners
        );
        claimedBeefs[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;

        //send referral beefs
        claimedBeefs[referrals[msg.sender]] = SafeMath.add(
            claimedBeefs[referrals[msg.sender]],
            SafeMath.div(SafeMath.mul(beefsUsed, 10), 100)
        );

        //boost market to nerf miners hoarding
        marketBeefs = SafeMath.add(marketBeefs, SafeMath.div(beefsUsed, 5));

        lastBuyTime = block.timestamp;
        lastBuyUser[lastBuyTime] = msg.sender;
    }

    function sellBeefs() public {
        require(initialized);
        _checkReward();

        uint256 hasBeefs = getMyBeefs();
        uint256 beefValue = calculateBeefSell(hasBeefs);
        claimedBeefs[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        marketBeefs = SafeMath.add(marketBeefs, hasBeefs);

        // 50% of fee to prize pool, 50% to market address
        uint256 fee = sellFee(beefValue);
        payable(marketAddress).transfer(
            SafeMath.div(SafeMath.mul(fee, 50), 100)
        );
        prizePool = SafeMath.add(
            prizePool,
            SafeMath.div(SafeMath.mul(fee, 50), 100)
        );

        payable(msg.sender).transfer(SafeMath.sub(beefValue, fee));
    }

    function buyBeefs(address ref) public payable {
        require(initialized);

        uint256 beefsBought = calculateBeefBuy(
            msg.value,
            SafeMath.sub(getBalance(), msg.value)
        );
        beefsBought = SafeMath.sub(beefsBought, buyFee(beefsBought));

        // 40% of fee to prize pool, 60% to market address
        uint256 fee = buyFee(msg.value);
        payable(owner()).transfer(SafeMath.div(SafeMath.mul(fee, 60), 100));
        prizePool = SafeMath.add(
            prizePool,
            SafeMath.div(SafeMath.mul(fee, 40), 100)
        );

        claimedBeefs[msg.sender] = SafeMath.add(
            claimedBeefs[msg.sender],
            beefsBought
        );

        hatchBeefs(ref);
        _updateBuyAmount(msg.value);

        if (
            referrals[msg.sender] != address(0) &&
            referrals[msg.sender] != owner() &&
            hatcheryMiners[referrals[msg.sender]] > 0
        ) {
            _updateInviteAmount(msg.value, referrals[msg.sender]);
        }
    }

    //magic trade balancing algorithm
    function calculateTrade(
        uint256 rt,
        uint256 rs,
        uint256 bs
    ) public view returns (uint256) {
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return
            SafeMath.div(
                SafeMath.mul(PSN, bs),
                SafeMath.add(
                    PSNH,
                    SafeMath.div(
                        SafeMath.add(
                            SafeMath.mul(PSN, rs),
                            SafeMath.mul(PSNH, rt)
                        ),
                        rt
                    )
                )
            );
    }

    function calculateBeefSell(uint256 beefs) public view returns (uint256) {
        return calculateTrade(beefs, marketBeefs, getBalance());
    }

    function calculateBeefBuy(uint256 bnb, uint256 contractBalance)
        public
        view
        returns (uint256)
    {
        return calculateTrade(bnb, contractBalance, marketBeefs);
    }

    function calculateBeefBuySimple(uint256 bnb) public view returns (uint256) {
        return calculateBeefBuy(bnb, getBalance());
    }

    function buyFee(uint256 amount) public pure returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, 5), 100); // 5%
    }

    function sellFee(uint256 amount) public view returns (uint256) {
        uint256 fee = calculateFee(msg.sender);
        return SafeMath.div(SafeMath.mul(amount, fee), 100);
    }

    function calculateFee(address user) public view returns (uint256) {
        uint256 timestamp = block.timestamp - buyerTime[user];
        uint256 months = timestamp / ONE_MONTH;
        return months < 10 ? 10 - months : 1;
    }

    function seedMarket() public payable {
        require(msg.sender == owner(), "invalid call");
        require(marketBeefs == 0);
        initialized = true;
        marketBeefs = 86400000000;
        launchTime = block.timestamp;

        period = 1;
        periodStartTime[period] = block.timestamp;
        nextBuyer[period][GUARD] = GUARD;

        invitePeriod = 1;
        invitePeriodStartTime[invitePeriod] = block.timestamp;
        nextInviter[invitePeriod][GUARD] = GUARD;
    }

    function _checkReward() internal {
        _checkAndPayReward();
        _checkAndPayBuyerReward();
    }

    function _checkAndPayBuyerReward() internal {
        // if no one buy for 24 hours, then transfer all of the prizePool to last buy user
        if (
            lastBuyTime > 0 &&
            block.timestamp - lastBuyTime >= ONE_DAY &&
            prizePool > 0
        ) {
            payable(lastBuyUser[lastBuyTime]).transfer(prizePool);
            prizePool = 0;
        }
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

            foundationPool = SafeMath.add(
                foundationPool,
                SafeMath.sub(prizePool, _rewardValue)
            );
            prizePool = 0;
            rewardCount += 1;

            period += 1;
            periodStartTime[period] = block.timestamp;
            nextBuyer[period][GUARD] = GUARD;

            if (rewardCount == 4 && foundationPool > 0) {
                foundationPool = SafeMath.div(
                    SafeMath.mul(foundationPool, 50),
                    100
                );
                prizePool = SafeMath.add(prizePool, foundationPool);
                rewardCount = 0;
            }
        }
    }

    function _updateInviteAmount(uint256 _amount, address inviter) internal {
        if (nextInviter[invitePeriod][inviter] != address(0)) {
            address preInviter = _findPreInviter(inviter);
            nextInviter[invitePeriod][preInviter] = nextInviter[invitePeriod][
                inviter
            ];
            nextInviter[invitePeriod][inviter] = address(0);
            inviteNumber[invitePeriod] -= 1;
        }

        inviteAmount[invitePeriod][inviter] += _amount;
        address index = _findInviteIndex(inviteAmount[invitePeriod][inviter]);
        nextInviter[invitePeriod][inviter] = nextInviter[invitePeriod][index];
        nextInviter[invitePeriod][index] = inviter;
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

        buyAmount[period][msg.sender] += _amount;
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
                buyAmount[_period][currentAddress]
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

    function getMyMiners() public view returns (uint256) {
        return hatcheryMiners[msg.sender];
    }

    function getMyBeefs() public view returns (uint256) {
        return
            SafeMath.add(
                claimedBeefs[msg.sender],
                getBeefsSinceLastHatch(msg.sender)
            );
    }

    function getLastBuyTime() public view returns (uint256) {
        return lastBuyTime;
    }

    function getLastBuyUser() public view returns (address) {
        return lastBuyUser[lastBuyTime];
    }

    function getBeefsSinceLastHatch(address adr) public view returns (uint256) {
        uint256 secondsPassed = min(
            BEEFS_TO_HATCH_1MINERS,
            SafeMath.sub(block.timestamp, lastHatch[adr])
        );
        return SafeMath.mul(secondsPassed, hatcheryMiners[adr]);
    }

    function withdrawFoundation() external onlyOwner {
        require(block.timestamp - launchTime >= 180 * ONE_DAY);
        payable(msg.sender).transfer(foundationPool);
        foundationPool = 0;
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