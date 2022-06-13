/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-03
 */

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract DTC {
    using SafeMath for uint256;

    /** base parameters **/
    uint256 public EGGS_TO_HIRE_1MINERS = 1440000;
    uint256 public FIRSTREF = 100;
    uint256 public SECOUNDREF = 50;
    uint256 public THIRDREF = 50;
    uint256 public FOURTHREF = 25;
    uint256 public FIVEFITHREF = 25;

    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public TAX = 35;
    uint256 public MKT = 35;
    uint256 public MKT2 = 10;

    uint256 public MARKET_EGGS_DIVISOR = 2;

    uint256 public MIN_INVEST_LIMIT = 1 * 1e16; /** 0.1 BNB  **/
    uint256 public WALLET_DEPOSIT_LIMIT = 25 * 1e18; /** 25 BNB  **/

    uint256 public COMPOUND_BONUS = 20;
    uint256 public COMPOUND_BONUS_MAX_TIMES = 10;
    uint256 public COMPOUND_STEP = 12 * 60 * 60;

    uint256 public WITHDRAWAL_TAX = 800;
    uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 12;

    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;

    mapping(address => bool) public isWhitelisted;

    uint256 public minPreSale = 1 * 10**17;
    uint256 public maxPreSale = 2 * 10**18;

    uint256 public marketEggs = 1440000000;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    bool public contractStarted;
    bool public blacklistActive = true;
    mapping(address => bool) public Blacklisted;

    uint256 public CUTOFF_STEP = 48 * 60 * 60;
    uint256 public WITHDRAW_COOLDOWN = 4 * 60 * 60;

    /* addresses */
    address public owner;
    address payable public dev1;
    address payable public dev2;
    address payable public mkt;
    address payable public mkt2;

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
        uint256 farmerCompoundCount; //added to monitor farmer consecutive compound without cap
        uint256 lastWithdrawTime;
    }

    mapping(address => User) public users;

    constructor(
        address payable _dev1,
        address payable _dev2,
        address payable _mkt,
        address payable _mkt2
    ) {
        owner = msg.sender;
        dev1 = _dev1;
        dev2 = _dev2;
        mkt = _mkt;
        mkt2 = _mkt2;
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function setblacklistActive(bool isActive) public {
        require(msg.sender == owner, "Admin use only.");
        blacklistActive = isActive;
    }

    function blackListWallet(address Wallet, bool isBlacklisted) public {
        require(msg.sender == owner, "Admin use only.");
        Blacklisted[Wallet] = isBlacklisted;
    }

    function blackMultipleWallets(address[] calldata Wallet, bool isBlacklisted)
        public
    {
        require(msg.sender == owner, "Admin use only.");
        for (uint256 i = 0; i < Wallet.length; i++) {
            Blacklisted[Wallet[i]] = isBlacklisted;
        }
    }

    function checkIfBlacklisted(address Wallet)
        public
        view
        returns (bool blacklisted)
    {
        require(msg.sender == owner, "Admin use only.");
        blacklisted = Blacklisted[Wallet];
    }

    function startBread() public payable {
        if (!contractStarted) {
            if (msg.sender == owner) {
                contractStarted = true;
                marketEggs = 144000000000;
            } else revert("Contract not yet started.");
        }
    }

    //fund contract with BNB before launch.
    function fundContract() external payable {}

    function clearStuckBalance(uint256 amountPercentage) public {
        require(msg.sender == owner, "Admin use only.");
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer((amountBNB * amountPercentage) / 100);
    }

    function whitelistForPreSale(address _wallet, bool status) public {
        require(msg.sender == owner, "Admin use only.");

        isWhitelisted[_wallet] = status;
    }

    function hireMoreDragons(bool isCompound) public {
        User storage user = users[msg.sender];

        if (!contractStarted) {
            require(isWhitelisted[msg.sender], "Contract not yet Started.");
        }

        uint256 eggsUsed = getMyEggs();
        uint256 eggsForCompound = eggsUsed;

        if (isCompound) {
            uint256 dailyCompoundBonus = getDailyCompoundBonus(
                msg.sender,
                eggsForCompound
            );
            eggsForCompound = eggsForCompound.add(dailyCompoundBonus);
            uint256 eggsUsedValue = calculateEggSell(eggsForCompound);
            user.userDeposit = user.userDeposit.add(eggsUsedValue);
            totalCompound = totalCompound.add(eggsUsedValue);
        }

        if (block.timestamp.sub(user.lastHatch) >= COMPOUND_STEP) {
            if (user.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES) {
                user.dailyCompoundBonus = user.dailyCompoundBonus.add(1);
            }
            //add compoundCount for monitoring purposes.
            user.farmerCompoundCount = user.farmerCompoundCount.add(1);
        }

        user.miners = user.miners.add(
            eggsForCompound.div(EGGS_TO_HIRE_1MINERS)
        );
        user.claimedEggs = 0;
        user.lastHatch = block.timestamp;

        marketEggs = marketEggs.add(eggsUsed.div(MARKET_EGGS_DIVISOR));
    }

    function sellDragonEggs() public {
        require(contractStarted, "Contract not yet Started.");

        if (blacklistActive) {
            require(!Blacklisted[msg.sender], "Address is blacklisted.");
        }

        User storage user = users[msg.sender];
        uint256 hasEggs = getMyEggs();
        uint256 eggValue = calculateEggSell(hasEggs);

        /** 
            if user compound < to mandatory compound days**/
        if (user.dailyCompoundBonus < COMPOUND_FOR_NO_TAX_WITHDRAWAL) {
            //daily compound bonus count will not reset and eggValue will be deducted with 60% feedback tax.
            eggValue = eggValue.sub(
                eggValue.mul(WITHDRAWAL_TAX).div(PERCENTS_DIVIDER)
            );
        } else {
            //set daily compound bonus count to 0 and eggValue will remain without deductions
            user.dailyCompoundBonus = 0;
            user.farmerCompoundCount = 0;
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

    /** transfer amount of BNB **/
    function hireDragons(address ref) public payable {
        if (!contractStarted) {
            require(isWhitelisted[msg.sender], "Contract not yet Started.");
            require(
                minPreSale <= msg.value && maxPreSale >= msg.value,
                "Amount over pre sale rate"
            );
        }
        User storage user = users[msg.sender];
        require(msg.value >= MIN_INVEST_LIMIT, "Mininum investment not met.");
        require(
            user.initialDeposit.add(msg.value) <= WALLET_DEPOSIT_LIMIT,
            "Max deposit limit reached."
        );
        uint256 eggsBought = calculateEggBuy(
            msg.value,
            address(this).balance.sub(msg.value)
        );
        user.userDeposit = user.userDeposit.add(msg.value);
        user.initialDeposit = user.initialDeposit.add(msg.value);
        user.claimedEggs = user.claimedEggs.add(eggsBought);

        if (user.referrer == address(0)) {
            if (ref != msg.sender) {
                user.referrer = ref;
            }

            address upline1 = user.referrer;
            if (upline1 != address(0)) {
                users[upline1].referralsCount = users[upline1]
                    .referralsCount
                    .add(1);
            }
        }
        // 1st level
        if (user.referrer != address(0)) {
            address upline = user.referrer;
            if (upline != address(0)) {
                uint256 refRewards = msg.value.mul(FIRSTREF).div(
                    PERCENTS_DIVIDER
                );
                payable(address(upline)).transfer(refRewards);
                users[upline].referralEggRewards = users[upline]
                    .referralEggRewards
                    .add(refRewards);
                totalRefBonus = totalRefBonus.add(refRewards);

                // 2nd level

                address upline2 = users[upline].referrer;
                if (upline2 != address(0)) {
                    uint256 refRewards2 = msg.value.mul(SECOUNDREF).div(
                        PERCENTS_DIVIDER
                    );
                    payable(address(upline2)).transfer(refRewards2);
                    users[upline2].referralEggRewards = users[upline2]
                        .referralEggRewards
                        .add(refRewards);
                    totalRefBonus = totalRefBonus.add(refRewards2);

                    //3rd level
                    address upline3 = users[upline2].referrer;
                    if (upline3 != address(0)) {
                        uint256 refRewards3 = msg.value.mul(THIRDREF).div(
                            PERCENTS_DIVIDER
                        );
                        payable(address(upline3)).transfer(refRewards3);
                        users[upline3].referralEggRewards = users[upline3]
                            .referralEggRewards
                            .add(refRewards3);
                        totalRefBonus = totalRefBonus.add(refRewards3);
                        //4th level

                        address upline4 = users[upline3].referrer;
                        if (upline4 != address(0)) {
                            uint256 refRewards4 = msg.value.mul(FOURTHREF).div(
                                PERCENTS_DIVIDER
                            );
                            payable(address(upline4)).transfer(refRewards4);
                            users[upline4].referralEggRewards = users[upline4]
                                .referralEggRewards
                                .add(refRewards4);
                            totalRefBonus = totalRefBonus.add(refRewards4);

                            // 5th level

                            address upline5 = users[upline4].referrer;
                            if (upline5 != address(0)) {
                                uint256 refRewards5 = msg
                                    .value
                                    .mul(FIVEFITHREF)
                                    .div(PERCENTS_DIVIDER);
                                payable(address(upline5)).transfer(refRewards5);
                                users[upline5].referralEggRewards = users[
                                    upline5
                                ].referralEggRewards.add(refRewards5);
                                totalRefBonus = totalRefBonus.add(refRewards5);
                            }
                        }
                    }
                }
            }
        }

        uint256 eggsPayout = payFees(msg.value);
        totalStaked = totalStaked.add(msg.value.sub(eggsPayout));
        totalDeposits = totalDeposits.add(1);
        hireMoreDragons(false);
    }

    function payFees(uint256 eggValue) internal returns (uint256) {
        uint256 tax = eggValue.mul(TAX).div(PERCENTS_DIVIDER);
        uint256 mktng = eggValue.mul(MKT).div(PERCENTS_DIVIDER);
        uint256 mktng2 = eggValue.mul(MKT2).div(PERCENTS_DIVIDER);

        dev1.transfer(tax);
        dev2.transfer(tax);
        mkt.transfer(mktng);
        mkt2.transfer(mktng2);

        return mktng.add(tax.mul(5)).add(mktng2);
    }

    function getDailyCompoundBonus(address _adr, uint256 amount)
        public
        view
        returns (uint256)
    {
        if (users[_adr].dailyCompoundBonus == 0) {
            return 0;
        } else {
            uint256 totalBonus = users[_adr].dailyCompoundBonus.mul(
                COMPOUND_BONUS
            );
            uint256 result = amount.mul(totalBonus).div(PERCENTS_DIVIDER);
            return result;
        }
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

    function getTimeStamp() public view returns (uint256) {
        return block.timestamp;
    }

    function getAvailableEarnings(address _adr) public view returns (uint256) {
        uint256 userEggs = users[_adr].claimedEggs.add(
            getEggsSinceLastHatch(_adr)
        );
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

    function calculateEggSell(uint256 eggs) public view returns (uint256) {
        return calculateTrade(eggs, marketEggs, getBalance());
    }

    function calculateEggBuy(uint256 eth, uint256 contractBalance)
        public
        view
        returns (uint256)
    {
        return calculateTrade(eth, contractBalance, marketEggs);
    }

    function calculateEggBuySimple(uint256 eth) public view returns (uint256) {
        return calculateEggBuy(eth, getBalance());
    }

    /** How many miners and eggs per day user will recieve based on BNB deposit **/
    function getEggsYield(uint256 amount)
        public
        view
        returns (uint256, uint256)
    {
        uint256 eggsAmount = calculateEggBuy(
            amount,
            getBalance().add(amount).sub(amount)
        );
        uint256 miners = eggsAmount.div(EGGS_TO_HIRE_1MINERS);
        uint256 day = 1 days;
        uint256 eggsPerDay = day.mul(miners);
        uint256 earningsPerDay = calculateEggSellForYield(eggsPerDay, amount);
        return (miners, earningsPerDay);
    }

    function calculateEggSellForYield(uint256 eggs, uint256 amount)
        public
        view
        returns (uint256)
    {
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

    function getMyMiners() public view returns (uint256) {
        return users[msg.sender].miners;
    }

    function getMyEggs() public view returns (uint256) {
        return
            users[msg.sender].claimedEggs.add(
                getEggsSinceLastHatch(msg.sender)
            );
    }

    function getEggsSinceLastHatch(address adr) public view returns (uint256) {
        uint256 secondsSinceLastHatch = block.timestamp.sub(
            users[adr].lastHatch
        );
        /** get min time. **/
        uint256 cutoffTime = min(secondsSinceLastHatch, CUTOFF_STEP);
        uint256 secondsPassed = min(EGGS_TO_HIRE_1MINERS, cutoffTime);
        return secondsPassed.mul(users[adr].miners);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function CHANGE_OWNERSHIP(address value) external {
        require(msg.sender == owner, "Admin use only.");
        owner = value;
    }

    function CHANGE_DEV1(address value) external {
        require(msg.sender == owner, "Admin use only.");
        dev1 = payable(value);
    }

    function CHANGE_DEV2(address value) external {
        require(msg.sender == owner, "Admin use only.");
        dev2 = payable(value);
    }

    function CHANGE_MKT(address value) external {
        require(msg.sender == owner, "Admin use only.");
        mkt = payable(value);
    }

    function CHANGE_MKT2(address value) external {
        require(msg.sender == owner, "Admin use only.");
        mkt2 = payable(value);
    }

    /** percentage setters **/

    // 2592000 - 3%, 2160000 - 4%, 1728000 - 5%, 1440000 - 6%, 1200000 - 7%
    // 1080000 - 8%, 959000 - 9%, 864000 - 10%, 720000 - 12%
    function changeRefCommission(
        uint256 level1,
        uint256 level2,
        uint256 level3,
        uint256 level4,
        uint256 level5
    ) external {
        require(msg.sender == owner, "Admin use only.");
        FIRSTREF = level1;
        SECOUNDREF = level2;
        THIRDREF = level3;
        FOURTHREF = level4;
        FIVEFITHREF = level5;
    }

    function PRC_EGGS_TO_HIRE_1MINERS(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        EGGS_TO_HIRE_1MINERS = value;
    }

    function changePreSaleRange(uint256 _min, uint256 _max) public {
        require(msg.sender == owner, "Admin use only.");

        minPreSale = _min;
        maxPreSale = _max;
    }

    function PRC_TAX(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 15);
        TAX = value;
    }

    function PRC_MKT(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 20);
        MKT = value;
    }

    function PRC_MKT2(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 20);
        MKT2 = value;
    }

    function PRC_MARKET_EGGS_DIVISOR(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 50);
        MARKET_EGGS_DIVISOR = value;
    }

    function SET_WITHDRAWAL_TAX(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 900);
        WITHDRAWAL_TAX = value;
    }

    function BONUS_DAILY_COMPOUND(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 900);
        COMPOUND_BONUS = value;
    }

    function BONUS_DAILY_COMPOUND_BONUS_MAX_TIMES(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 40);
        COMPOUND_BONUS_MAX_TIMES = value;
    }

    function BONUS_COMPOUND_STEP(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 24);
        COMPOUND_STEP = value * 60 * 60;
    }

    function SET_INVEST_MIN(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        MIN_INVEST_LIMIT = value * 1e17;
    }

    function SET_CUTOFF_STEP(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        CUTOFF_STEP = value * 60 * 60;
    }

    function SET_WITHDRAW_COOLDOWN(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value <= 24);
        WITHDRAW_COOLDOWN = value * 60 * 60;
    }

    function SET_WALLET_DEPOSIT_LIMIT(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value >= 10);
        WALLET_DEPOSIT_LIMIT = value * 1 ether;
    }

    function SET_COMPOUND_FOR_NO_TAX_WITHDRAWAL(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 12);
        COMPOUND_FOR_NO_TAX_WITHDRAWAL = value;
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