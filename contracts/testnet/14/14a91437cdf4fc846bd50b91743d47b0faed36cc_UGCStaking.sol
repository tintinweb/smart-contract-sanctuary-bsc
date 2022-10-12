/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract UGCStaking {
    token public UGC = token(0x59FA022bcc9139B407F7713FEFdc7A5162B721FA);
    uint256 public Nonce = 1;

    address public Admin;
    address public Market_wallet;

    uint256 public totalinvested;
    uint256 public totalwithdrawn;

    uint256 public constant TIME_STEP = 3 minutes ;
    uint256 public constant PERCENTS_DIVIDER = 100_000;
    uint256 public constant ONE_MONTH = 3 minutes ;
    uint256 public usdtotoken = 4;

    uint256[10] public TREASURE_LEVEL_PERCENTS = [
        10_000,
        10_000,
        5_000,
        5_000,
        4_000,
        4_000,
        3_000,
        3_000,
        2_000,
        2_000
    ];
    uint256[10] public STAKE_LEVEL_PERCENTS = [
        5_000,
        5_000,
        3_000,
        3_000,
        2_000,
        2_000,
        2_000,
        1_000,
        1_000,
        1_000
    ];
    uint256 public MONTHLY_REWARD_POOL_PERCENT = 1_000;
    uint256 public IMMORTAL_POOL_PERCENT = 1_000;
    uint256 public SUPREME_LEADERSHIP_PERCENT = 1_000;
    uint256 public SUPREME_INVESTORS_PERCENT = 1_000;
    uint256 public MARKETING_PERCENT = 10_000;

    uint256[5] public DURATIONS = [
        2 minutes,
        4 minutes,
        5 minutes,
        7 minutes,
        8 minutes
    ];
    uint256[5] public REWARD_PERCENTS_MONTHLY = [
        5_000,
        7_000,
        10_000,
        12_000,
        15_000
    ];

    uint256[4] public TEAM_TURNOVER_AMOUNTS_MONTHLY = [
        10_000,
        100_000,
        1_000_000,
        10_000_000
    ];
    uint256[2] public TEAM_DIRECTS_SUPREME_LEADERSHIP = [20, 10];
    uint256[2] public TEAM_AMOUNT_SUPREME_LEADERSHIP = [500, 1000];
    uint256 public SUPREME_INVESTORS_AMOUNT = 7000;
    uint256 public IMMORTAL_AMOUNT = 1000;
    uint256 public MINIMUM_DURATION_IMMORTAL = 360 days;
    uint256[4] public TEAM_TURNOVER_DIRECTS = [10, 20, 30, 50];

    uint256 public MONTHLY_REWARD_POOL_SILVER;
    uint256 public MONTHLY_REWARD_POOL_GOLD;
    uint256 public MONTHLY_REWARD_POOL_DIAMOND;
    uint256 public MONTHLY_REWARD_POOL_CROWN;
    uint256 public IMMORTAL_POOL;
    uint256 public SUPREME_INVESTORS_POOL;
    uint256 public SUPREME_LEADERSHIP_POOL;

    uint256 public MONTHLY_REWARD_POOL_SILVER_TRIGGERD_AT;
    uint256 public MONTHLY_REWARD_POOL_GOLD_TRIGGERD_AT;
    uint256 public MONTHLY_REWARD_POOL_DIAMOND_TRIGGERD_AT;
    uint256 public MONTHLY_REWARD_POOL_CROWN_TRIGGERD_AT;
    uint256 public IMMORTAL_POOL_TRIGGERD_AT;
    uint256 public SUPREME_INVESTORS_POOL_TRIGGERD_AT;
    uint256 public SUPREME_LEADERSHIP_POOL_TRIGGERD_AT;

    address[] public MONTHLY_REWARD_POOL_SILVER_ELIGIBLES;
    address[] public MONTHLY_REWARD_POOL_GOLD_ELIGIBLES;
    address[] public MONTHLY_REWARD_POOL_DIAMOND_ELIGIBLES;
    address[] public MONTHLY_REWARD_POOL_CROWN_ELIGIBLES;
    address[] public IMMORTAL_POOL_ELIGIBLES;
    address[] public SUPREME_INVESTORS_POOL_ELIGIBLES;
    address[] public SUPREME_LEADERSHIP_POOL_ELIGIBLES;

    //deposti plan data
    uint256[6] public LEVEL_UNLOCKED = [2, 4, 6, 8, 10, 10];
    uint256[6] public PLAN_AMOUNTS_TOKEN = [20, 50, 100, 200, 500, 1000];
    uint256[6] public MAX_PURCHASEABLE_PLAN = [
        50_000,
        50_000,
        40_000,
        30_000,
        25_000,
        5_000
    ];
    uint256[6] public PURCHASED_PLAN;

    struct Deposit {
        uint256 amount;
        uint256 withdrawn;
        uint256 start;
        uint256 time_step_percentge;
        uint256 total_percentge;
    }

    struct User {
        uint256 id;
        Deposit[] deposits;
        uint256 total_deposit;
        address referrer;
        address[] directs;
        mapping(uint256 => bool) plan_purchased;
        mapping(address => bool) isDirect;
        uint256 level_unlocked;
        uint256 teamturnover;
        uint256 teamturnover_directs;
        mapping(uint256 => uint256) ref_teamturnover_per_level;
        mapping(uint256 => uint256) ref_count;
        mapping(uint256 => uint256) stake_teamturnover_per_level;
        mapping(uint256 => uint256) stake_count;
        mapping(uint256 => bool) is_eligible_staking_level_income;
        bool is_monthly_reward_pool_silver_eligible;
        bool is_monthly_reward_pool_gold_eligible;
        bool is_monthly_reward_pool_diamond_eligible;
        bool is_monthly_reward_pool_crown_eligible;
        bool is_immortal_pool_eligible;
        bool is_supreme_investors_pool_eligible;
        bool is_supreme_leadership_pool_eligible;
    }
    struct poolclaimed {
        uint256 monthly_reward_pool_silver_earned;
        uint256 monthly_reward_pool_gold_earned;
        uint256 monthly_reward_pool_diamond_earned;
        uint256 monthly_reward_pool_crown_earned;
        uint256 immortal_pool_earned;
        uint256 supreme_investors_pool_earned;
        uint256 supreme_leadership_pool_earned;
    }
    mapping(address => User) public users;
    mapping(address => poolclaimed) public poolmembers;
    mapping(uint256 => address) public idtoaddress;

    constructor() {
        Admin = 0x0169fc65E3986eDeb8B1aaD921B6681Cc378E601;
        idtoaddress[Nonce] = Admin;
        users[Admin].id = Nonce;
        Nonce++;
        users[Admin].level_unlocked = 10;
        for(uint256 i ; i < 6 ;i++){
        users[Admin].plan_purchased[i] = true;
        }
        Market_wallet = 0x0169fc65E3986eDeb8B1aaD921B6681Cc378E601;
        usdtotoken = usdtotoken * (10**(UGC.decimals()));
        MONTHLY_REWARD_POOL_SILVER_TRIGGERD_AT = block.timestamp;
        MONTHLY_REWARD_POOL_GOLD_TRIGGERD_AT = block.timestamp;
        MONTHLY_REWARD_POOL_DIAMOND_TRIGGERD_AT = block.timestamp;
        MONTHLY_REWARD_POOL_CROWN_TRIGGERD_AT = block.timestamp;
        IMMORTAL_POOL_TRIGGERD_AT = block.timestamp;
        SUPREME_INVESTORS_POOL_TRIGGERD_AT = block.timestamp;
        SUPREME_LEADERSHIP_POOL_TRIGGERD_AT = block.timestamp;
    }

    function buy(
        address referrer,
        uint256 _plan,
        uint256 _duration
    ) public {
        User storage user = users[msg.sender];
        require(
            PURCHASED_PLAN[_plan] <= MAX_PURCHASEABLE_PLAN[_plan],
            "Plan is not available"
        );
        if (msg.sender != Admin) {
            require(referrer != address(0), "Referrer is not valid");
            require(referrer != msg.sender, "You can't refer yourself");
        }
        require(_plan < 6, "Plan is not valid");
        if (_plan > 0) {
            require(
                user.plan_purchased[_plan - 1] == true,
                "Previous plan is not purchased"
            );
        }
        require(_duration < 5, "Duration is not valid");
        uint256 _amount = PLAN_AMOUNTS_TOKEN[_plan]*usdtotoken;
        user.total_deposit += _amount;
        UGC.transferFrom(msg.sender, address(this), _amount);
        UGC.transfer(Market_wallet,(_amount*MARKETING_PERCENT)/PERCENTS_DIVIDER);
        totalinvested += _amount;

        setupline(msg.sender, referrer, _amount);

        seteligibility(msg.sender, _amount, _duration);

        distributeunilevelrewards(msg.sender, _amount);

        user.plan_purchased[_plan] = true;
        PURCHASED_PLAN[_plan]++;
        if (user.deposits.length == 0 && user.id == 0) {
            idtoaddress[Nonce] = msg.sender;
            user.id = Nonce;
            Nonce++;
        }
        user.deposits.push(
            Deposit({
                amount: (_amount),
                withdrawn: 0,
                start: block.timestamp,
                time_step_percentge: REWARD_PERCENTS_MONTHLY[_duration],
                total_percentge: PERCENTS_DIVIDER
            })
        );

        if (user.level_unlocked < LEVEL_UNLOCKED[_plan]) {
            user.level_unlocked = LEVEL_UNLOCKED[_plan];
        }
        if (_duration > 1) {
            for (uint256 i; i < user.level_unlocked; i++) {
                user.is_eligible_staking_level_income[i] = true;
            }
        }

        MONTHLY_REWARD_POOL_SILVER +=
            (_amount * MONTHLY_REWARD_POOL_PERCENT) /
            PERCENTS_DIVIDER;
        MONTHLY_REWARD_POOL_GOLD +=
            (_amount * MONTHLY_REWARD_POOL_PERCENT) /
            PERCENTS_DIVIDER;
        MONTHLY_REWARD_POOL_DIAMOND +=
            (_amount * MONTHLY_REWARD_POOL_PERCENT) /
            PERCENTS_DIVIDER;
        MONTHLY_REWARD_POOL_CROWN +=
            (_amount * MONTHLY_REWARD_POOL_PERCENT) /
            PERCENTS_DIVIDER;

        IMMORTAL_POOL += (_amount * IMMORTAL_POOL_PERCENT) / PERCENTS_DIVIDER;
        SUPREME_INVESTORS_POOL +=
            (_amount * SUPREME_INVESTORS_PERCENT) /
            PERCENTS_DIVIDER;
        SUPREME_LEADERSHIP_POOL +=
            (_amount * SUPREME_LEADERSHIP_PERCENT) /
            PERCENTS_DIVIDER;
    }

    function setupline(
        address _user,
        address referrer,
        uint256 _amount
    ) internal {
        User storage user = users[_user];
        if (_user == Admin) {
            user.referrer = address(0);
        } else if (user.referrer == address(0)) {
            if (
                (users[referrer].deposits.length == 0 || referrer == _user) &&
                _user != Admin
            ) {
                referrer = Admin;
            }
        }
        user.referrer = referrer;
        if (!users[referrer].isDirect[_user]) {
            users[referrer].directs.push(_user);
            users[referrer].isDirect[_user] = true;
        }

        address upline = user.referrer;
        for (uint256 i = 0; i < TREASURE_LEVEL_PERCENTS.length; i++) {
            if (upline != address(0)) {
                users[upline].teamturnover += _amount;

                upline = users[upline].referrer;
            } else break;
        }
    }

    function seteligibility(
        address _user,
        uint256 _amount,
        uint256 _duration
    ) internal {
        User storage user = users[_user];
        address upline = user.referrer;
        users[upline].teamturnover_directs += _amount;
        if (
            users[upline].teamturnover >= TEAM_TURNOVER_AMOUNTS_MONTHLY[0]*usdtotoken &&
            users[upline].directs.length >= TEAM_TURNOVER_DIRECTS[0] &&
            !users[upline].is_monthly_reward_pool_silver_eligible
        ) {
            MONTHLY_REWARD_POOL_SILVER_ELIGIBLES.push(upline);
            users[upline].is_monthly_reward_pool_silver_eligible = true;
        }
        if (
            users[upline].teamturnover >= TEAM_TURNOVER_AMOUNTS_MONTHLY[1]*usdtotoken &&
            users[upline].directs.length >= TEAM_TURNOVER_DIRECTS[1] &&
            !users[upline].is_monthly_reward_pool_gold_eligible
        ) {
            MONTHLY_REWARD_POOL_GOLD_ELIGIBLES.push(upline);
            users[upline].is_monthly_reward_pool_gold_eligible = true;
        }
        if (
            users[upline].teamturnover >= TEAM_TURNOVER_AMOUNTS_MONTHLY[2]*usdtotoken &&
            users[upline].directs.length >= TEAM_TURNOVER_DIRECTS[2] &&
            !users[upline].is_monthly_reward_pool_diamond_eligible
        ) {
            MONTHLY_REWARD_POOL_DIAMOND_ELIGIBLES.push(upline);
            users[upline].is_monthly_reward_pool_diamond_eligible = true;
        }
        if (
            users[upline].teamturnover >= TEAM_TURNOVER_AMOUNTS_MONTHLY[3]*usdtotoken &&
            users[upline].directs.length >= TEAM_TURNOVER_DIRECTS[3] &&
            !users[upline].is_monthly_reward_pool_crown_eligible
        ) {
            MONTHLY_REWARD_POOL_CROWN_ELIGIBLES.push(upline);
            users[upline].is_monthly_reward_pool_crown_eligible = true;
        }

        if (
            (users[upline].teamturnover_directs >=
                TEAM_AMOUNT_SUPREME_LEADERSHIP[0]*usdtotoken &&
                users[upline].directs.length >
                TEAM_DIRECTS_SUPREME_LEADERSHIP[0]) ||
            (users[upline].teamturnover_directs >=
                TEAM_AMOUNT_SUPREME_LEADERSHIP[1]*usdtotoken &&
                users[upline].directs.length >
                TEAM_DIRECTS_SUPREME_LEADERSHIP[1])
        ) {
            if (!users[upline].is_supreme_leadership_pool_eligible) {
                SUPREME_LEADERSHIP_POOL_ELIGIBLES.push(upline);
                users[upline].is_supreme_leadership_pool_eligible = true;
            }
        }
        if (!users[_user].is_immortal_pool_eligible) {
            if (
                _amount >= IMMORTAL_AMOUNT*usdtotoken &&
                DURATIONS[_duration] >= MINIMUM_DURATION_IMMORTAL
            ) {
                IMMORTAL_POOL_ELIGIBLES.push(_user);
                users[_user].is_immortal_pool_eligible = true;
            }
        }
        if (!users[_user].is_supreme_investors_pool_eligible) {
            if (users[_user].total_deposit >= SUPREME_INVESTORS_AMOUNT*usdtotoken) {
                SUPREME_INVESTORS_POOL_ELIGIBLES.push(_user);
                users[_user].is_supreme_investors_pool_eligible = true;
            }
        }
    }

    function distributeunilevelrewards(address _user, uint256 _amount)
        internal
    {
        User storage user = users[_user];
        address upline = user.referrer;
        if (user.referrer != address(0)) {
            for (uint256 i = 0; i < TREASURE_LEVEL_PERCENTS.length; i++) {
                if ((upline != address(0))) {
                    if (i <= users[upline].level_unlocked) {
                        uint256 amount = (_amount *
                            (TREASURE_LEVEL_PERCENTS[i])) / (PERCENTS_DIVIDER);
                        if (
                            (
                                users[upline].is_eligible_staking_level_income[
                                    i
                                ]
                            ) || upline == Admin
                        ) {
                            uint256 amount2 = (_amount *
                                (STAKE_LEVEL_PERCENTS[i])) / (PERCENTS_DIVIDER);
                            UGC.transfer(upline, amount2);
                            users[upline].stake_teamturnover_per_level[
                                    i
                                ] += amount2;
                            users[upline].stake_count[i]++;
                        }
                        UGC.transfer(upline, amount);
                        users[upline].ref_teamturnover_per_level[i] += amount;
                        users[upline].ref_count[i]++;
                    }

                    upline = users[upline].referrer;
                } else break;
            }
        }
    }

    function withdraw() public {
        User storage user = users[msg.sender];

        uint256 totalAmount;
        uint256 dividends;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (
                user.deposits[i].withdrawn <
                (user.deposits[i].amount * (user.deposits[i].total_percentge)) /
                    (PERCENTS_DIVIDER) &&
                block.timestamp > user.deposits[i].start + ONE_MONTH
            ) {
                dividends =
                    (((user.deposits[i].amount *
                        (user.deposits[i].time_step_percentge)) /
                        (PERCENTS_DIVIDER)) *
                        (block.timestamp - (user.deposits[i].start))) /
                    (TIME_STEP);
                user.deposits[i].start = block.timestamp;
                if (
                    user.deposits[i].withdrawn + (dividends) >
                    (user.deposits[i].amount *
                        (user.deposits[i].total_percentge)) /
                        (PERCENTS_DIVIDER)
                ) {
                    dividends =
                        ((user.deposits[i].amount *
                            (user.deposits[i].total_percentge)) /
                            (PERCENTS_DIVIDER)) -
                        (user.deposits[i].withdrawn);
                }

                user.deposits[i].withdrawn =
                    user.deposits[i].withdrawn +
                    (dividends); /// changing of storage data
                totalAmount = totalAmount + (dividends);
            }
        }

        uint256 contractBalance = UGC.balanceOf(address(this));
        if (contractBalance < totalAmount) {
            totalAmount = contractBalance;
        }
        UGC.transfer(msg.sender, totalAmount);
        totalwithdrawn = totalwithdrawn + totalAmount;
    }

    function withdraw_immortal_pool() external {
        require(
            get_contract_balance() > IMMORTAL_POOL,
            "not enough contract balance"
        );
        require(IMMORTAL_POOL > 0, "no rewards available yet");
        require(users[msg.sender].is_immortal_pool_eligible, "not eligible");
        require(block.timestamp > IMMORTAL_POOL_TRIGGERD_AT + ONE_MONTH);
        {
            uint256 amount = IMMORTAL_POOL / IMMORTAL_POOL_ELIGIBLES.length;
            for (uint256 i = 0; i < IMMORTAL_POOL_ELIGIBLES.length; i++) {
                UGC.transfer(IMMORTAL_POOL_ELIGIBLES[i], amount);
                poolmembers[IMMORTAL_POOL_ELIGIBLES[i]]
                    .immortal_pool_earned += amount;
            }
            totalwithdrawn += IMMORTAL_POOL;
            IMMORTAL_POOL = 0;
            IMMORTAL_POOL_TRIGGERD_AT = block.timestamp;
        }
    }

    function withdraw_supremeinverstor_pool() external {
        require(
            get_contract_balance() > SUPREME_INVESTORS_POOL,
            "not enough contract balance"
        );
        require(SUPREME_INVESTORS_POOL > 0, "no rewards available yet");
        require(
            users[msg.sender].is_supreme_investors_pool_eligible,
            "not eligible"
        );
        require(
            block.timestamp > SUPREME_INVESTORS_POOL_TRIGGERD_AT + ONE_MONTH
        );
        {
            uint256 amount = SUPREME_INVESTORS_POOL /
                SUPREME_INVESTORS_POOL_ELIGIBLES.length;
            for (
                uint256 i = 0;
                i < SUPREME_INVESTORS_POOL_ELIGIBLES.length;
                i++
            ) {
                UGC.transfer(SUPREME_INVESTORS_POOL_ELIGIBLES[i], amount);
                poolmembers[SUPREME_INVESTORS_POOL_ELIGIBLES[i]]
                    .supreme_investors_pool_earned += amount;
            }
            totalwithdrawn += SUPREME_INVESTORS_POOL;
            SUPREME_INVESTORS_POOL = 0;
            SUPREME_INVESTORS_POOL_TRIGGERD_AT = block.timestamp;
        }
    }

    function withdraw_supremeleader_pool() external {
        require(
            get_contract_balance() > SUPREME_LEADERSHIP_POOL,
            "not enough contract balance"
        );
        require(SUPREME_LEADERSHIP_POOL > 0, "no rewards available yet");
        require(
            users[msg.sender].is_supreme_leadership_pool_eligible,
            "not eligible"
        );
        require(
            block.timestamp > SUPREME_LEADERSHIP_POOL_TRIGGERD_AT + ONE_MONTH
        );
        {
            uint256 amount = SUPREME_LEADERSHIP_POOL /
                SUPREME_LEADERSHIP_POOL_ELIGIBLES.length;
            for (
                uint256 i = 0;
                i < SUPREME_LEADERSHIP_POOL_ELIGIBLES.length;
                i++
            ) {
                UGC.transfer(SUPREME_LEADERSHIP_POOL_ELIGIBLES[i], amount);
                poolmembers[SUPREME_LEADERSHIP_POOL_ELIGIBLES[i]]
                    .supreme_leadership_pool_earned += amount;
            }
            totalwithdrawn += SUPREME_LEADERSHIP_POOL;
            SUPREME_LEADERSHIP_POOL = 0;
            SUPREME_LEADERSHIP_POOL_TRIGGERD_AT = block.timestamp;
        }
    }

    function withdraw_monthly_pool_silver() external {
        require(
            get_contract_balance() > MONTHLY_REWARD_POOL_SILVER,
            "not enough contract balance"
        );
        require(MONTHLY_REWARD_POOL_SILVER > 0, "no rewards available yet");
        require(
            users[msg.sender].is_monthly_reward_pool_silver_eligible,
            "not eligible"
        );
        require(
            block.timestamp > MONTHLY_REWARD_POOL_SILVER_TRIGGERD_AT + ONE_MONTH
        );
        {
            uint256 amount = MONTHLY_REWARD_POOL_SILVER /
                MONTHLY_REWARD_POOL_SILVER_ELIGIBLES.length;
            for (
                uint256 i = 0;
                i < MONTHLY_REWARD_POOL_SILVER_ELIGIBLES.length;
                i++
            ) {
                UGC.transfer(MONTHLY_REWARD_POOL_SILVER_ELIGIBLES[i], amount);
                poolmembers[MONTHLY_REWARD_POOL_SILVER_ELIGIBLES[i]]
                    .monthly_reward_pool_silver_earned += amount;
            }
            totalwithdrawn += MONTHLY_REWARD_POOL_SILVER;
            MONTHLY_REWARD_POOL_SILVER = 0;
            MONTHLY_REWARD_POOL_SILVER_TRIGGERD_AT = block.timestamp;
        }
    }

    function withdraw_monthly_pool_gold() external {
        require(
            get_contract_balance() > MONTHLY_REWARD_POOL_GOLD,
            "not enough contract balance"
        );
        require(MONTHLY_REWARD_POOL_GOLD > 0, "no rewards available yet");
        require(
            users[msg.sender].is_monthly_reward_pool_gold_eligible,
            "not eligible"
        );
        require(
            block.timestamp > MONTHLY_REWARD_POOL_GOLD_TRIGGERD_AT + ONE_MONTH
        );
        {
            uint256 amount = MONTHLY_REWARD_POOL_GOLD /
                MONTHLY_REWARD_POOL_GOLD_ELIGIBLES.length;
            for (
                uint256 i = 0;
                i < MONTHLY_REWARD_POOL_GOLD_ELIGIBLES.length;
                i++
            ) {
                UGC.transfer(MONTHLY_REWARD_POOL_GOLD_ELIGIBLES[i], amount);
                poolmembers[MONTHLY_REWARD_POOL_GOLD_ELIGIBLES[i]]
                    .monthly_reward_pool_gold_earned += amount;
            }
            totalwithdrawn += MONTHLY_REWARD_POOL_GOLD;
            MONTHLY_REWARD_POOL_GOLD = 0;
            MONTHLY_REWARD_POOL_GOLD_TRIGGERD_AT = block.timestamp;
        }
    }

    function withdraw_monthly_pool_diamond() external {
        require(
            get_contract_balance() > MONTHLY_REWARD_POOL_DIAMOND,
            "not enough contract balance"
        );
        require(MONTHLY_REWARD_POOL_DIAMOND > 0, "no rewards available yet");
        require(
            users[msg.sender].is_monthly_reward_pool_diamond_eligible,
            "not eligible"
        );
        require(
            block.timestamp >
                MONTHLY_REWARD_POOL_DIAMOND_TRIGGERD_AT + ONE_MONTH
        );
        {
            uint256 amount = MONTHLY_REWARD_POOL_DIAMOND /
                MONTHLY_REWARD_POOL_DIAMOND_ELIGIBLES.length;
            for (
                uint256 i = 0;
                i < MONTHLY_REWARD_POOL_DIAMOND_ELIGIBLES.length;
                i++
            ) {
                UGC.transfer(MONTHLY_REWARD_POOL_DIAMOND_ELIGIBLES[i], amount);
                poolmembers[MONTHLY_REWARD_POOL_DIAMOND_ELIGIBLES[i]]
                    .monthly_reward_pool_diamond_earned += amount;
            }
            totalwithdrawn += MONTHLY_REWARD_POOL_DIAMOND;
            MONTHLY_REWARD_POOL_DIAMOND = 0;
            MONTHLY_REWARD_POOL_DIAMOND_TRIGGERD_AT = block.timestamp;
        }
    }

    function withdraw_monthly_pool_crown() external {
        require(
            get_contract_balance() > MONTHLY_REWARD_POOL_CROWN,
            "not enough contract balance"
        );
        require(MONTHLY_REWARD_POOL_CROWN > 0, "no rewards available yet");
        require(
            users[msg.sender].is_monthly_reward_pool_crown_eligible,
            "not eligible"
        );
        require(
            block.timestamp > MONTHLY_REWARD_POOL_CROWN_TRIGGERD_AT + ONE_MONTH
        );
        {
            uint256 amount = MONTHLY_REWARD_POOL_CROWN /
                MONTHLY_REWARD_POOL_CROWN_ELIGIBLES.length;
            for (
                uint256 i = 0;
                i < MONTHLY_REWARD_POOL_CROWN_ELIGIBLES.length;
                i++
            ) {
                UGC.transfer(MONTHLY_REWARD_POOL_CROWN_ELIGIBLES[i], amount);
                poolmembers[MONTHLY_REWARD_POOL_CROWN_ELIGIBLES[i]]
                    .monthly_reward_pool_crown_earned += amount;
            }
            totalwithdrawn += MONTHLY_REWARD_POOL_CROWN;
            MONTHLY_REWARD_POOL_CROWN = 0;
            MONTHLY_REWARD_POOL_CROWN_TRIGGERD_AT = block.timestamp;
        }
    }

    function get_user_total_deposits_count(address _user)
        external
        view
        returns (uint256 count)
    {
        return users[_user].deposits.length;
    }

    function get_user_withdrawable(address usr) public view returns (uint256) {
        User storage user = users[usr];

        uint256 totalAmount;
        uint256 dividends;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (
                user.deposits[i].withdrawn <
                (user.deposits[i].amount * (user.deposits[i].total_percentge)) /
                    (PERCENTS_DIVIDER) &&
                block.timestamp > user.deposits[i].start + ONE_MONTH
            ) {
                dividends =
                    (((user.deposits[i].amount *
                        (user.deposits[i].time_step_percentge)) /
                        (PERCENTS_DIVIDER)) *
                        (block.timestamp - (user.deposits[i].start))) /
                    (TIME_STEP);
                if (
                    user.deposits[i].withdrawn + (dividends) >
                    (user.deposits[i].amount *
                        (user.deposits[i].total_percentge)) /
                        (PERCENTS_DIVIDER)
                ) {
                    dividends =
                        ((user.deposits[i].amount *
                            (user.deposits[i].total_percentge)) /
                            (PERCENTS_DIVIDER)) -
                        (user.deposits[i].withdrawn);
                }

                totalAmount = totalAmount + (dividends);
            }
        }

        return totalAmount;
    }

    function get_user_withdrawn(address usr)
        public
        view
        returns (uint256 _withdrawn)
    {
        for (uint256 i = 0; i < users[usr].deposits.length; i++) {
            _withdrawn = _withdrawn + users[usr].deposits[i].withdrawn;
        }
        return _withdrawn;
    }

    function get_user_ref_team_turnover_per_level(address _user, uint256 level)
        external
        view
        returns (uint256 amount, uint256 usercount)
    {
        return (
            users[_user].ref_teamturnover_per_level[level],
            users[_user].ref_count[level]
        );
    }

    function get_user_stake_team_turnover_per_level(
        address _user,
        uint256 level
    ) external view returns (uint256 count, uint256 usercount) {
        return (
            users[_user].stake_teamturnover_per_level[level],
            users[_user].stake_count[level]
        );
    }

    function get_user_plan_purchased(address user, uint256 level)
        external
        view
        returns (bool result)
    {
        return users[user].plan_purchased[level];
    }

    function get_directs(address user)
        external
        view
        returns (uint256 length, address[] memory directs)
    {
        return (users[user].directs.length, users[user].directs);
    }

    function get_user_deposit_details(address user, uint256 index)
        external
        view
        returns (Deposit memory details)
    {
        return users[user].deposits[index];
    }

    function transfer_Adminship(address _newAdmin) public {
        require(msg.sender == Admin, "only Admin can transfer Adminship");
        require(_newAdmin != address(0), "cannot transfer to zero address");
        require(!isContract(_newAdmin), "cannot transfer to contract address");
        Admin = _newAdmin;
    }

    function set_market_wallet(address _marketwallet) public {
        require(msg.sender == Admin, "only Admin can set market wallet");
        require(_marketwallet != address(0), "cannot set to zero address");
        require(!isContract(_marketwallet), "cannot set to contract address");
        Market_wallet = _marketwallet;
    }

    function get_contract_balance() public view returns (uint256) {
        return UGC.balanceOf(address(this));
    }

    function setToken(token _token) external {
      require(msg.sender == Admin, "only Admin can set token");
      require(address(_token) != address(0), "tokens must be different");
      UGC = _token;
    }

    function setUSDtoToken(uint256 amount) external {
        require(msg.sender == Admin,"caller is not Admin");
        usdtotoken = amount;
    }

    function withdraw_stuck_token(token _token, uint256 _stuck_amount) public {
        require(_stuck_amount > 0, "no rewards available yet");
        require(msg.sender == Admin, "caller is not Admin");
        require(
            _token.balanceOf(address(this)) >= _stuck_amount,
            "not enough stuck token"
        );
        _token.transfer(msg.sender, _stuck_amount);
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}

interface token {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}