/**
 *Submitted for verification at BscScan.com on 2022-07-30
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract AvariceBNBMiner {
    using SafeMath for uint256;

    IERC20 public avcToken;
    IAVARICE public avarice;
    address public AVARICE_ADDRESS;

    /** Base parameters **/
    uint256 public EGGS_TO_HIRE_1MINERS = 1080000;
    uint256 public REFERRAL = 50;
    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public DEV = 10;
    uint256 public TEAM = 25;
    uint256 public MKT = 5;
    uint256 public MARKET_EGGS_DIVISOR = 2;

    uint256 public MIN_INVEST_LIMIT = 1 * 1e17; /** min. 0.1 BNB  **/
    uint256 public WALLET_DEPOSIT_LIMIT = 500 * 1e18; /** max. 500 BNB  **/

    uint256 public COMPOUND_BONUS_MAX_TIMES = 6; /** 6 Times Compound every 24 Hours / 6 days. **/
    uint256 public COMPOUND_STEP = 2 minutes; /** 24 Hours Compound Timer **/

    uint256 public WITHDRAWAL_TAX = 990; // 99% tax for For Early Withdrawals - Penalties
    uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 6; // Compound days, for no tax Withdrawal.

    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;
    uint256 public totalStakedAVC;

    uint256 public marketEggs;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    bool public contractStarted;

    uint256 public CUTOFF_STEP = 36 * 60 * 60; /** 36 Hours Rewards Accumulation Cut-Off **/

    /* addresses */
    address public owner;
    address payable public dev1;
    address payable public dev2;
    address payable public mkt;
    address payable public team;

    mapping(address => uint256) public levelMap;
    mapping(address => uint256) public stakeAmount;

    struct User {
        uint256 initialDeposit;
        uint256 userDeposit;
        uint256 miners;
        uint256 claimedEggs;
        uint256 lastHatch;
        address referrer;
        uint256 referralsCount;
        uint256 referralEggRewards;
        uint256 totalWithdrawn;
        uint256 dailyCompoundBonus;
        uint256 minerCompoundCount;
        uint256 lastWithdrawTime;
    }

    mapping(address => User) public users;

    constructor(
        address payable _dev1,
        address payable _dev2,
        address payable _mkt,
        address payable _team,
        address payable _avarice_address
    ) {
        require(!isContract(_dev1) && !isContract(_dev2) && !isContract(_team));
        owner = msg.sender;
        dev1 = _dev1;
        dev2 = _dev2;
        mkt = _mkt;
        team = _team;
        AVARICE_ADDRESS = _avarice_address;
        avcToken = IERC20(_avarice_address);
        avarice = IAVARICE(_avarice_address);
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function startMiner() public {
        if (!contractStarted) {
            if (msg.sender == owner) {
                require(marketEggs == 0);
                contractStarted = true;
                marketEggs = 108000000000;
            } else revert('Contract not started yet.');
        }
    }

    // Compound Function
    function hireMoreMiners(bool isCompound) public {
        User storage user = users[msg.sender];
        require(contractStarted, 'Contract not started yet.');

        uint256 eggsUsed = getMyEggs();
        uint256 eggsForCompound = eggsUsed;

        if (isCompound) {
            uint256 eggsUsedValue = calculateEggSell(eggsForCompound);
            user.userDeposit = user.userDeposit.add(eggsUsedValue);
            totalCompound = totalCompound.add(eggsUsedValue);
            require(block.timestamp.sub(user.lastHatch) >= COMPOUND_STEP, 'Tried to compound too early.');
            if (user.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES) {
                user.dailyCompoundBonus = user.dailyCompoundBonus.add(1);
            }
            //add compoundCount for monitoring purposes.
            user.minerCompoundCount = user.minerCompoundCount.add(1);
        }

        user.miners = user.miners.add(eggsForCompound.div(EGGS_TO_HIRE_1MINERS));
        user.claimedEggs = 0;
        user.lastHatch = block.timestamp;

        marketEggs = marketEggs.add(eggsUsed.div(MARKET_EGGS_DIVISOR));
    }

    function sell() public {
        require(contractStarted, 'Contract not started yet.');

        User storage user = users[msg.sender];
        uint256 hasEggs = getMyEggs();
        uint256 eggValue = calculateEggSell(hasEggs);

        /** 
            if user compound < to mandatory compound days**/
        if (user.dailyCompoundBonus < COMPOUND_FOR_NO_TAX_WITHDRAWAL) {
            //daily compound bonus count will not reset and eggValue will be deducted with feedback tax.
            eggValue = eggValue.sub(eggValue.mul(WITHDRAWAL_TAX).div(PERCENTS_DIVIDER));
        } else {
            //set daily compound bonus count to 0 and eggValue will remain without deductions
            user.dailyCompoundBonus = 0;
            user.minerCompoundCount = 0;
        }

        user.lastWithdrawTime = block.timestamp;
        user.claimedEggs = 0;
        user.lastHatch = block.timestamp;
        marketEggs = marketEggs.add(hasEggs.div(MARKET_EGGS_DIVISOR));

        if (getBalance() < eggValue) {
            eggValue = getBalance();
        }

        uint256 eggsPayout = eggValue.sub(payFees(eggValue));
        payable(address(msg.sender)).transfer(eggsPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(eggsPayout);
        totalWithdrawn = totalWithdrawn.add(eggsPayout);
    }

    /** Buy Winemakers with BNB **/
    function hireMiners(address ref) public payable {
        require(contractStarted, 'Contract not started yet.');
        User storage user = users[msg.sender];
        require(msg.value >= MIN_INVEST_LIMIT, 'Mininum investment not met.');
        require(user.initialDeposit.add(msg.value) <= WALLET_DEPOSIT_LIMIT, 'Max deposit limit reached.');
        uint256 eggsBought = calculateEggBuy(msg.value, address(this).balance.sub(msg.value));
        user.userDeposit = user.userDeposit.add(msg.value);
        user.initialDeposit = user.initialDeposit.add(msg.value);
        user.claimedEggs = user.claimedEggs.add(eggsBought);

        if (user.referrer == address(0)) {
            if (ref != msg.sender) {
                user.referrer = ref;
            }

            address upline1 = user.referrer;
            if (upline1 != address(0)) {
                users[upline1].referralsCount = users[upline1].referralsCount.add(1);
            }
        }

        if (user.referrer != address(0)) {
            address upline = user.referrer;
            if (upline != address(0)) {
                uint256 refRewards = msg.value.mul(REFERRAL).div(PERCENTS_DIVIDER);
                payable(address(upline)).transfer(refRewards);
                users[upline].referralEggRewards = users[upline].referralEggRewards.add(refRewards);
                totalRefBonus = totalRefBonus.add(refRewards);
            }
        }

        uint256 eggsPayout = payFees(msg.value);
        uint256 eggsUsed = getMyEggs();
        uint256 eggsForCompound = eggsUsed;

        if (user.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES) {
            user.dailyCompoundBonus = user.dailyCompoundBonus.add(1);
        }

        //add compoundCount for monitoring purposes.
        user.minerCompoundCount = user.minerCompoundCount.add(1);

        user.miners = user.miners.add(eggsForCompound.div(EGGS_TO_HIRE_1MINERS));
        user.claimedEggs = 0;
        user.lastHatch = block.timestamp;

        marketEggs = marketEggs.add(eggsUsed.div(MARKET_EGGS_DIVISOR));

        totalStaked = totalStaked.add(msg.value.sub(eggsPayout));
        totalDeposits = totalDeposits.add(1);
    }

    function payFees(uint256 eggValue) internal returns (uint256) {
        uint256 devtax = eggValue.mul(DEV).div(PERCENTS_DIVIDER);
        uint256 mktng = eggValue.mul(MKT).div(PERCENTS_DIVIDER);
        uint256 teamtax = eggValue.mul(TEAM).div(PERCENTS_DIVIDER);
        dev1.transfer(devtax);
        dev2.transfer(devtax);
        mkt.transfer(mktng);
        team.transfer(teamtax);
        return mktng.add(devtax.mul(2)).add(teamtax);
    }

    function getUserInfo(address _adr)
        public
        view
        returns (
            uint256 _initialDeposit,
            uint256 _userDeposit,
            uint256 _miners,
            uint256 _claimedEggs,
            uint256 _lastHatch,
            address _referrer,
            uint256 _referrals,
            uint256 _totalWithdrawn,
            uint256 _referralEggRewards,
            uint256 _dailyCompoundBonus,
            uint256 _minerCompoundCount,
            uint256 _lastWithdrawTime
        )
    {
        _initialDeposit = users[_adr].initialDeposit;
        _userDeposit = users[_adr].userDeposit;
        _miners = users[_adr].miners;
        _claimedEggs = users[_adr].claimedEggs;
        _lastHatch = users[_adr].lastHatch;
        _referrer = users[_adr].referrer;
        _referrals = users[_adr].referralsCount;
        _totalWithdrawn = users[_adr].totalWithdrawn;
        _referralEggRewards = users[_adr].referralEggRewards;
        _dailyCompoundBonus = users[_adr].dailyCompoundBonus;
        _minerCompoundCount = users[_adr].minerCompoundCount;
        _lastWithdrawTime = users[_adr].lastWithdrawTime;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getTimeStamp() public view returns (uint256) {
        return block.timestamp;
    }

    function getAvailableEarnings(address _adr) public view returns (uint256) {
        uint256 userEggs = users[_adr].claimedEggs.add(getEggsSinceLastHatch(_adr));
        return calculateEggSell(userEggs);
    }

    function calculateTrade(
        uint256 rt,
        uint256 rs,
        uint256 bs
    ) public view returns (uint256) {
        return
            SafeMath.div(
                SafeMath.mul(PSN, bs),
                SafeMath.add(PSNH, SafeMath.div(SafeMath.add(SafeMath.mul(PSN, rs), SafeMath.mul(PSNH, rt)), rt))
            );
    }

    function calculateEggSell(uint256 eggs) public view returns (uint256) {
        return calculateTrade(eggs, marketEggs, getBalance());
    }

    function calculateEggBuy(uint256 eth, uint256 contractBalance) public view returns (uint256) {
        return calculateTrade(eth, contractBalance, marketEggs);
    }

    function calculateEggBuySimple(uint256 eth) public view returns (uint256) {
        return calculateEggBuy(eth, getBalance());
    }

    /** How many miners and eggs per day user will recieve based on BNB deposit **/
    function getEggsYield(uint256 amount) public view returns (uint256, uint256) {
        uint256 eggsAmount = calculateEggBuy(amount, getBalance().add(amount).sub(amount));
        uint256 miners = eggsAmount.div(EGGS_TO_HIRE_1MINERS);
        uint256 day = 1 days;
        uint256 eggsPerDay = day.mul(miners);
        uint256 earningsPerDay = calculateEggSellForYield(eggsPerDay, amount);
        return (miners, earningsPerDay);
    }

    function calculateEggSellForYield(uint256 eggs, uint256 amount) public view returns (uint256) {
        return calculateTrade(eggs, marketEggs, getBalance().add(amount));
    }

    function getSiteInfo()
        public
        view
        returns (
            uint256 _totalStaked,
            uint256 _totalDeposits,
            uint256 _totalCompound,
            uint256 _totalRefBonus
        )
    {
        return (totalStaked, totalDeposits, totalCompound, totalRefBonus);
    }

    function getMyMiners(address adr) public view returns (uint256) {
        return users[adr].miners;
    }

    function getMyEggs() public view returns (uint256) {
        return users[msg.sender].claimedEggs.add(getEggsSinceLastHatch(msg.sender));
    }

    function getEggsSinceLastHatch(address adr) public view returns (uint256) {
        uint256 secondsSinceLastHatch = block.timestamp.sub(users[adr].lastHatch);
        // get min time.
        uint256 cutoffTime = min(secondsSinceLastHatch, CUTOFF_STEP);
        uint256 secondsPassed = min(EGGS_TO_HIRE_1MINERS, cutoffTime);

        uint256 _miners = users[adr].miners;
        uint256 boostedMiners = getBoostedMiners(levelMap[adr], _miners);

        return secondsPassed.mul(users[adr].miners.add(boostedMiners));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    // AVC amount for a given day
    function getAmountForDay(uint256 _day) public pure returns (uint256) {
        uint256 amount = 3000000 ether;
        if (_day < 1) {
            return amount;
        }
        for (uint256 i = 0; i < _day; i++) {
            amount = amount.mul(995).div(1000);
        }
        return amount;
    }

    function getBoostedMiners(uint256 level, uint256 originalMiners) public pure returns (uint256) {
        uint256 baseBoost = originalMiners.mul(9375).div(2).div(75000);
        if (level == 0) {
            return 0;
        } else {
            return level.mul(baseBoost);
        }
    }

    /* Get avc amount needed to reach each level */
    function getAVCForLevelsList() public view returns (uint256[8] memory) {
        uint256 currentDay = avarice._clcDay();
        uint256 previousAVCAmount = getAmountForDay(currentDay.sub(1));
        uint256 previousBNBAmount = avarice.lobbyEntry(currentDay.sub(1));
        uint256 AVCPerBNB = previousAVCAmount.mul(1e18).div(previousBNBAmount);
        return [
            AVCPerBNB.div(10),
            AVCPerBNB.div(4),
            AVCPerBNB.div(2),
            AVCPerBNB.mul(4).div(5),
            AVCPerBNB.mul(5).div(4),
            AVCPerBNB.mul(7).div(4),
            AVCPerBNB.mul(5).div(2),
            AVCPerBNB.mul(7).div(2)
        ];
    }

    function setUserLevel(address adr, uint256 _userStakedAmount) internal {
        uint256[8] memory _avcList = getAVCForLevelsList();
        if (_userStakedAmount < _avcList[0]) {
            levelMap[adr] = 0;
        } else if (_avcList[0] <= _userStakedAmount && _userStakedAmount < _avcList[1]) {
            levelMap[adr] = 1;
        } else if (_avcList[1] <= _userStakedAmount && _userStakedAmount < _avcList[2]) {
            levelMap[adr] = 2;
        } else if (_avcList[2] <= _userStakedAmount && _userStakedAmount < _avcList[3]) {
            levelMap[adr] = 3;
        } else if (_avcList[3] <= _userStakedAmount && _userStakedAmount < _avcList[4]) {
            levelMap[adr] = 4;
        } else if (_avcList[4] <= _userStakedAmount && _userStakedAmount < _avcList[5]) {
            levelMap[adr] = 5;
        } else if (_avcList[5] <= _userStakedAmount && _userStakedAmount < _avcList[6]) {
            levelMap[adr] = 6;
        } else if (_avcList[6] <= _userStakedAmount && _userStakedAmount < _avcList[7]) {
            levelMap[adr] = 7;
        } else {
            levelMap[adr] = 8;
        }
    }

    function stakeAVC(uint256 _sAmount) public {
        require(_sAmount > 0, 'Stake amount can not be empty!');
        require(users[msg.sender].miners > 0, 'Miners can not be empty!');

        hireMoreMiners(true);
        avcToken.transferFrom(address(msg.sender), address(this), _sAmount);
        stakeAmount[msg.sender] = stakeAmount[msg.sender].add(_sAmount);
        setUserLevel(msg.sender, stakeAmount[msg.sender]);
        totalStakedAVC = totalStakedAVC.add(_sAmount);
    }

    function unstakeAVC(uint256 _uAmount) public {
        require(_uAmount >= stakeAmount[msg.sender], 'Unstake amount can not be greater than staked amount!');

        hireMoreMiners(true);
        avcToken.transfer(msg.sender, _uAmount);
        stakeAmount[msg.sender] = stakeAmount[msg.sender].sub(_uAmount);
        setUserLevel(msg.sender, stakeAmount[msg.sender]);
        totalStakedAVC = totalStakedAVC.sub(_uAmount);
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IAVARICE {
    function _clcDay() external view returns (uint256);

    function lobbyEntry(uint256) external view returns (uint256); //BNB amount for a given day
}

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}