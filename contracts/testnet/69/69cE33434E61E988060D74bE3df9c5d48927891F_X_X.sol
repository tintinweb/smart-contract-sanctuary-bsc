//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
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

contract X_X {
    address public ADMIN;
    address public TEACHTOEARNWALLET;
    address public BONUSWALLET;

    IBEP20 public token;

    uint256 public constant PERCENTS_DIVIDER = 100_000; //divider for percentage

    uint256 public MAX_LEVEL = 4; //maximam number of levels
    uint256 public MAX_Profit_Bonus = 300_000; //percentage of profit
    uint256 public MAX_Profit_Regular = 200_000; //percentage of profit
    uint256 public min_duration = 30 minutes; //minimum duration to Claim
    uint256 public max_duration = 360 minutes; //maximum duration to Claim
    uint256 public fee_percent = 40_000; //percentage of fee
    uint256 public cashback_percent = 20_000; //percentage of cashback
    uint256 public level_percent = 80_000; //percentage of level
    uint256 public personal_refral_percent = 10_000; //percentage of personal refral
    uint256 public total_invested; //total invested
    uint256 public total_withdrawn; //total withdrawn
    uint256 public total_referral_bonus; //total referral bonus

    rank REQUIRED_LEVEL = rank(1); //required level to claim
    uint256 public BASIC_DURATION = 30 minutes; //basic duration
    uint256 public BASIC_INTEREST = 200_000; //basic interest
    uint256 public ADVANCED_DURATION = 180 minutes; //advanced duration
    uint256 public ADVANCED_INTEREST = 250_000; //advanced interest
    uint256 public PREMIUM_DURATION = 360 minutes; //premium duration
    uint256 public PREMIUM_INTEREST = 300_000; //premium interest
    uint256 public TIME_STEP = 30 minutes;

    uint256 public nonce = 1; //nonce for Users ids;for each tire requirement
    uint256 public registration_fee = 10 ether; //registration fee
    uint256[10] public uni_level_requirements = [0, 0, 1, 1, 2, 2, 3, 3, 4, 4]; //minimum requirements for each level
    uint256[10] public uni_level_bonus = [
        10,
        10,
        10,
        10,
        10,
        10,
        10,
        10,
        10,
        10
    ]; //percentage of bonus for each level
    uint256[7] public rank_requirements = [
        0,
        25_000 ether,
        50_000 ether,
        100_000 ether,
        200_000 ether,
        300_000 ether,
        500_000 ether
    ]; //minimum requirements for each rank

    uint256[5] public price = [
        0,
        100 ether,
        200 ether,
        300 ether,
        400 ether
    ]; //price for each level

    struct matrix {
        uint256 withdrawn;
        uint256 Count;
        bool complete;
    }
    struct ROI {
        uint256 amount;
        uint256 withdrawn;
        uint256 matrixTime;
        uint256 lastwithdraw;
        uint256 FirstWithdrawTime;
    }
    struct accountinfo {
        mapping(uint256 => matrix[]) matrixs;
        mapping(uint256 => ROI[]) ROI;
        address[] directs;
        bool registerd;
        uint256 id;
        address owner;
        uint256 total_invested;
        mapping (uint256 => uint256) total_invested_level;
        uint256 total_withdrawn;
        mapping (uint256 => uint256) total_withdrawn_level;
        uint256 total_referral_bonus;
        mapping (uint256 => uint256) total_referral_bonus_level;
        uint256 total_Matrix_bonus;
        mapping (uint256 => uint256) total_Matrix_bonus_level;
        uint256 total_cashback;
        mapping (uint256 => uint256) total_cashback_level;
        uint256 total_ROI_withdrawn;
        mapping (uint256 => uint256) total_ROI_withdrawn_level;
        rank current_rank;
    }
    enum rank {
        None,
        Bronze,
        Silver,
        Gold,
        Ruby,
        Emerald,
        Diamond
    }
    mapping(address => accountinfo) public accounts;
    mapping(uint256 => address) public id_to_address;

    constructor() {
        ADMIN = msg.sender;
        token = IBEP20(0xfCacB1e616F0Aa55378a68fb3A815444CFF9f9fc);
        accounts[ADMIN].registerd = true;
        accounts[ADMIN].id = nonce;
        accounts[ADMIN].owner = ADMIN;
        TEACHTOEARNWALLET = 0xbE7a8FAaE8c37139496689Cd1906596E2D734743;
        BONUSWALLET = 0xB8684538b07d6c1C11Fa04223D4f94DE84429792;
        nonce++;
    }

    function register(address ref) public returns (bool) {
        require(accounts[ref].registerd == true, "Invalid Referral");
        require(accounts[msg.sender].registerd == false, "Already registerd");
        accounts[msg.sender].registerd = true;
        accounts[msg.sender].id = nonce;
        accounts[msg.sender].owner = msg.sender;
        accounts[ref].directs.push(msg.sender);
        nonce++;
        return true;
    }

    function buy_level(
        address[] memory upline,
        address[] memory level1,
        address[] memory level2,
        address[] memory level3,
        address[] memory level4,
        uint256 _plan
    ) public returns (bool success) {
        if (
            accounts[msg.sender].matrixs[_plan].length > 0 &&
            accounts[msg.sender].ROI[_plan].length > 0
        ) {
            require(
                accounts[msg.sender]
                .matrixs[_plan][accounts[msg.sender].matrixs[_plan].length - 1]
                    .complete == true,
                "Previous Plan Not Complete"
            );
        }
        require(level1.length <= 3, "Invalid Upline");
        require(level2.length <= 9, "Invalid Upline");
        require(level3.length <= 27, "Invalid Upline");
        require(level4.length <= 81, "Invalid Upline");
        require(_plan >= 1 && _plan <= 4, "Invalid Plan");
        uint256 MARTIX_AMOUNT = (price[_plan] * 30) / 100;
        uint256 TRADING_AMOUNT = (price[_plan] * 70) / 100;
        uint256 UPLINE_AMOUNT = (TRADING_AMOUNT * 20) / 100;
        uint256 ROI_AMOUNT = (TRADING_AMOUNT * 80) / 100;
        uint256 MLM_AMOUNT = (MARTIX_AMOUNT * 80) / 100;
        uint256 PERWALLET_AMOUNT = (MARTIX_AMOUNT * 5) / 100;

        require(upline.length <= 10);
        require(accounts[msg.sender].registerd == true, "Not registerd");
        token.transferFrom(msg.sender, address(this), price[_plan]);
        token.transfer(TEACHTOEARNWALLET, PERWALLET_AMOUNT);
        token.transfer(BONUSWALLET, PERWALLET_AMOUNT);
        token.transfer(ADMIN, PERWALLET_AMOUNT);
        if (
            accounts[upline[0]].current_rank > REQUIRED_LEVEL &&
            accounts[upline[0]].current_rank >=
            accounts[msg.sender].current_rank
        ) {
            token.transfer(upline[0], PERWALLET_AMOUNT);
            accounts[upline[0]].total_cashback += PERWALLET_AMOUNT;
            accounts[upline[0]].total_cashback_level[_plan] += PERWALLET_AMOUNT;
        }
        if (upline.length > 0) {
            distributeUpline(upline, UPLINE_AMOUNT, _plan);
        }
        if (level1.length > 0) {
            distributeMatrix(level1, _plan, MLM_AMOUNT / 4);
        }
        if (level2.length > 0) {
            distributeMatrix(level2, _plan, MLM_AMOUNT / 4);
        }
        if (level3.length > 0) {
            distributeMatrix(level3, _plan, MLM_AMOUNT / 4);
        }
        if (level4.length > 0) {
            distributeMatrix(level4, _plan, MLM_AMOUNT / 4);
        }

        accounts[msg.sender].matrixs[_plan].push(matrix(0, 0, false));
        accounts[msg.sender].ROI[_plan].push(
            ROI(ROI_AMOUNT, 0, block.timestamp, block.timestamp, block.timestamp)
        );
        total_invested += price[_plan];
        accounts[msg.sender].total_invested += price[_plan];
        accounts[msg.sender].total_invested_level[_plan] += price[_plan];

        for (uint256 i = 0; i < rank_requirements.length; i++) {
            if (accounts[msg.sender].total_invested >= rank_requirements[i]) {
                accounts[msg.sender].current_rank = rank(i);
            }
        }

        return true;
    }

    function distributeUpline(address[] memory upline, uint256 _amount,uint256 _plan)
        internal
        returns (bool success)
    {
        uint256 withdrawable = _amount / 10;
        for (uint256 i = 0; i < upline.length; i++) {
            if (upline[i] != address(0)) {
                if (
                    accounts[upline[i]].registerd == true || upline[i] == ADMIN
                ) {
                    token.transfer(upline[i], withdrawable);
                    total_withdrawn += withdrawable;
                    accounts[upline[i]].total_withdrawn += withdrawable;
                    accounts[upline[i]].total_withdrawn_level[_plan] += withdrawable;
                    total_referral_bonus += withdrawable;
                    accounts[upline[i]].total_referral_bonus += withdrawable;
                    accounts[upline[i]].total_referral_bonus_level[_plan] += withdrawable;
                }
            }
        }
        return true;
    }

    function distributeMatrix(
        address[] memory level,
        uint256 _plan,
        uint256 _amount
    ) internal returns (bool success) {
        uint256 withdrawable = _amount / level.length;
        for (uint256 i = 0; i < level.length; i++) {
            if(level[i] == ADMIN){
                token.transfer(level[i], withdrawable);
                total_withdrawn += withdrawable;
                accounts[level[i]].total_withdrawn += withdrawable;
                accounts[level[i]].total_withdrawn_level[_plan] += withdrawable;
                accounts[level[i]].total_Matrix_bonus += withdrawable;
                accounts[level[i]].total_Matrix_bonus_level[_plan] += withdrawable;
            }else if (
                !accounts[level[i]]
                .matrixs[_plan][accounts[level[i]].matrixs[_plan].length - 1]
                    .complete
            ) {
                token.transfer(level[i], withdrawable);
                total_withdrawn += withdrawable;
                accounts[level[i]].total_withdrawn += withdrawable;
                accounts[level[i]].total_withdrawn_level[_plan] += withdrawable;
                accounts[level[i]].total_Matrix_bonus += withdrawable;
                accounts[level[i]].total_Matrix_bonus_level[_plan] += withdrawable;
                accounts[level[i]]
                .matrixs[_plan][accounts[level[i]].matrixs[_plan].length - 1]
                    .withdrawn += withdrawable;
                accounts[level[i]]
                .matrixs[_plan][accounts[level[i]].matrixs[_plan].length - 1]
                    .Count += 1;
                if (
                    accounts[level[i]]
                    .matrixs[_plan][
                        accounts[level[i]].matrixs[_plan].length - 1
                    ].Count == 120
                ) {
                    accounts[level[i]]
                    .matrixs[_plan][
                        accounts[level[i]].matrixs[_plan].length - 1
                    ].complete = true;
                }
            }
        }
        return true;
    }

    function withdraw(uint256 _plan) public {
        accountinfo storage user = accounts[msg.sender];

        uint256 totalAmount;
        uint256 dividends;

        uint256 ROI_PERCENTAGE;
        uint256 TIME_STEP_ROI_PERCENTAGE;

        for (uint256 i; i < user.ROI[_plan].length; i++) {
            if (user.ROI[_plan][i].FirstWithdrawTime == user.ROI[_plan][i].matrixTime) {
                if (block.timestamp > user.ROI[_plan][i].matrixTime + 90 minutes) {
                    user.ROI[_plan][i].FirstWithdrawTime = block.timestamp;
                }
            }

            if (
                user.ROI[_plan][i].FirstWithdrawTime >=
                user.ROI[_plan][i].matrixTime
            ) {
                (ROI_PERCENTAGE, TIME_STEP_ROI_PERCENTAGE) = getROIpercentge(
                    user.ROI[_plan][i].FirstWithdrawTime -
                        user.ROI[_plan][i].matrixTime
                );
            }

            if (
                user.ROI[_plan][i].withdrawn <
                (user.ROI[_plan][i].amount * (ROI_PERCENTAGE)) /
                    (PERCENTS_DIVIDER)
            ) {
                dividends =
                    (((user.ROI[_plan][i].amount * (TIME_STEP_ROI_PERCENTAGE)) /
                        (PERCENTS_DIVIDER)) *
                        (block.timestamp - (user.ROI[_plan][i].lastwithdraw))) /
                    (TIME_STEP);
                user.ROI[_plan][i].lastwithdraw = block.timestamp;
                if (
                    user.ROI[_plan][i].withdrawn + (dividends) >
                    (user.ROI[_plan][i].amount * (ROI_PERCENTAGE)) /
                        (PERCENTS_DIVIDER)
                ) {
                    dividends =
                        ((user.ROI[_plan][i].amount * (ROI_PERCENTAGE)) /
                            (PERCENTS_DIVIDER)) -
                        (user.ROI[_plan][i].withdrawn);
                }
            }
            user.ROI[_plan][i].withdrawn =
                user.ROI[_plan][i].withdrawn +
                (dividends); /// changing of storage data
            totalAmount = totalAmount + (dividends);
        }

        total_withdrawn = total_withdrawn + (totalAmount);
        user.total_withdrawn = user.total_withdrawn + (totalAmount);
        user.total_withdrawn_level[_plan] = user.total_withdrawn_level[_plan] + (totalAmount);
        user.total_ROI_withdrawn = user.total_ROI_withdrawn + (totalAmount);
        user.total_ROI_withdrawn_level[_plan] = user.total_ROI_withdrawn_level[_plan] + (totalAmount);
        token.transferFrom(ADMIN, msg.sender, totalAmount);
    }

    function getUserWithdrawable(address user, uint256 _plan)
        public
        view
        returns (uint256 _withdrawable)
    {
        accountinfo storage _user = accounts[user];
        uint256 totalAmount;
        uint256 dividends;

        uint256 ROI_PERCENTAGE;
        uint256 TIME_STEP_ROI_PERCENTAGE;

        for (uint256 i; i < _user.ROI[_plan].length; i++) {
            if (
                _user.ROI[_plan][i].FirstWithdrawTime >=
                _user.ROI[_plan][i].matrixTime
            ) {
                (ROI_PERCENTAGE, TIME_STEP_ROI_PERCENTAGE) = getROIpercentge(
                    _user.ROI[_plan][i].FirstWithdrawTime -
                        _user.ROI[_plan][i].matrixTime
                );
            }

            if (
                _user.ROI[_plan][i].withdrawn <
                (_user.ROI[_plan][i].amount * (ROI_PERCENTAGE)) /
                    (PERCENTS_DIVIDER)
            ) {
                dividends =
                    (((_user.ROI[_plan][i].amount *
                        (TIME_STEP_ROI_PERCENTAGE)) / (PERCENTS_DIVIDER)) *
                        (block.timestamp -
                            (_user.ROI[_plan][i].lastwithdraw))) /
                    (TIME_STEP);
                if (
                    _user.ROI[_plan][i].withdrawn + (dividends) >
                    (_user.ROI[_plan][i].amount * (ROI_PERCENTAGE)) /
                        (PERCENTS_DIVIDER)
                ) {
                    dividends =
                        ((_user.ROI[_plan][i].amount * (ROI_PERCENTAGE)) /
                            (PERCENTS_DIVIDER)) -
                        (_user.ROI[_plan][i].withdrawn);
                }
            }
            totalAmount = totalAmount + (dividends);
        }
        return totalAmount;
    }

    function getUserPlanDetails(address user, uint256 _plan)
        public
        view
        returns (
            uint256 total_invested_level,
            uint256 total_withdrawn_level,
            uint256 total_referral_bonus_level,
            uint256 total_Matrix_bonus_level,
            uint256 total_Cashback_level,
            uint256 total_ROI_withdrawn_level
        ){
        accountinfo storage _user = accounts[user];
        return (
            _user.total_invested_level[_plan],
            _user.total_withdrawn_level[_plan],
            _user.total_referral_bonus_level[_plan],
            _user.total_Matrix_bonus_level[_plan],
            _user.total_cashback_level[_plan],
            _user.total_ROI_withdrawn_level[_plan]
        );
        }
            

            


    function getROIpercentge(uint256 durationpassed)
        internal
        view
        returns (uint256 ROI_PERCENTAGE, uint256 TIME_STEP_ROI_PERCENTAGE)
    {
        if(durationpassed == 0){
            ROI_PERCENTAGE = PREMIUM_INTEREST;

            TIME_STEP_ROI_PERCENTAGE = PREMIUM_INTEREST / 12;

        }else if (durationpassed > 0 && durationpassed <= BASIC_DURATION) {
            ROI_PERCENTAGE = BASIC_INTEREST;

            TIME_STEP_ROI_PERCENTAGE = BASIC_INTEREST / 12;
        } else if (
            durationpassed > BASIC_DURATION &&
            durationpassed <= ADVANCED_DURATION
        ) {
            ROI_PERCENTAGE = ADVANCED_INTEREST;
            TIME_STEP_ROI_PERCENTAGE = ADVANCED_INTEREST / 12;
        } else if (
            durationpassed > ADVANCED_DURATION 
        ) {
            ROI_PERCENTAGE = PREMIUM_INTEREST;

            TIME_STEP_ROI_PERCENTAGE = PREMIUM_INTEREST / 12;
        }
    }

    function getMatrixdata(
        address user,
        uint256 plan,
        uint256 index
    )
        public
        view
        returns (
            uint256 withdrawn,
            uint256 Count,
            bool complete
        )
    {
        withdrawn = accounts[user].matrixs[plan][index].withdrawn;
        complete = accounts[user].matrixs[plan][index].complete;
        Count = accounts[user].matrixs[plan][index].Count;
        return (withdrawn, Count, complete);
    }

    function getMatrixLength(address user, uint256 plan)
        public
        view
        returns (uint256)
    {
        return accounts[user].matrixs[plan].length;
    }

    function getROIdata(
        address user,
        uint256 plan,
        uint256 index
    )
        public
        view
        returns (
            uint256 amount,
            uint256 matrixTime,
            uint256 FirstWithdrawTime,
            uint256 lastwithdraw,
            uint256 withdrawn
        )
    {
        amount = accounts[user].ROI[plan][index].amount;
        matrixTime = accounts[user].ROI[plan][index].matrixTime;
        FirstWithdrawTime = accounts[user].ROI[plan][index].FirstWithdrawTime;
        lastwithdraw = accounts[user].ROI[plan][index].lastwithdraw;
        withdrawn = accounts[user].ROI[plan][index].withdrawn;
        return (amount, matrixTime, FirstWithdrawTime, lastwithdraw, withdrawn);
    }

    function getROILength(address user, uint256 plan)
        public
        view
        returns (uint256)
    {
        return accounts[user].ROI[plan].length;
    }
}