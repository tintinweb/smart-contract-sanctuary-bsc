/**
 *Submitted for verification at BscScan.com on 2023-02-01
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-01
*/

pragma solidity ^0.8.17;

//SPDX-License-Identifier: MIT
contract PiggyBankBUSD{
    token public BUSD = token(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address public owner;
    address public project;
    address public dev;
    uint256 public min_withdraw = 1 ether; //1busd
    uint256 public INVEST_MIN_AMOUNT = 1 ether; //1busd
    uint256 public INVEST_MAX_AMOUNT_NORMAL = 10_000 ether; //10kbusd
    uint256 public INVEST_MAX_AMOUNT_VIP = 45_000 ether; //45kbusd
    uint256 public VIP_USER_REQUIRED = 5;
    uint256 public project_percent = 5_000;
    uint256 public dev_percent = 5_000;
    uint256[5] public REFERRAL_PERCENTS = [5_000, 4_000, 3_000, 2_000, 1_000];
    uint256 public ROI_PERCENTAGE = 300_000; //300%maxroi
    uint256 public TIME_STEP_ROI_PERCENTAGE = 10000; //10%daily
    uint256 public MAX_PER_DAY = 200 ether; //200busd
    uint256 public ADDITIONAL_REFERRAL_PERCENT = 3_000;
    uint256 public totalUsers;
    uint256 public totalInvested;
    uint256 public totalWithdrawn;
    uint256 public totalDeposits;

    uint256 public constant PERCENTS_DIVIDER = 100_000;
    uint256 public constant TIME_STEP = 1 days;

    struct Deposit {
        uint256 amount;
        uint256 withdrawn;
        uint256 start;
    }

    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        uint256 dailycheckpoint;
        uint256 dailylimitreceived;
        address referrer;
        address[] directs;
        bool directsfilled;
        mapping(address => bool) alreadyReffered;
        uint256 additionalincome;
        uint256 additionalincomewithdrawn;
        uint256 levelbonus;
        uint256 levelbonuswithdrawn;
        uint256[5] levelusers;
        uint256[5] levelincome;
        address residualbonusreceiver;
    }

    mapping(address => User) public users;

    constructor() {
        owner = (0xc4B3e364105eeCa60B1FE0DbC6f264c9C7245ec2);// non sponsor WALLET
        project = (0x0F32d9d894352e1c451e73F08cB67401207cc48B);//for 5% project fee
        dev = (0x6153C5c317e38E7662FF1908018770D73b1D48C0);//for 5% dev fee
    }

    function invest(address referrer, uint256 _amount) public {
        User storage user = users[msg.sender];
        if (user.directs.length >= VIP_USER_REQUIRED) {
            require(
                _amount >= INVEST_MIN_AMOUNT &&
                    _amount <= INVEST_MAX_AMOUNT_VIP,
                "Amount must be between 1 and 45000"
            );
        } else {
            require(
                _amount >= INVEST_MIN_AMOUNT &&
                    _amount <= INVEST_MAX_AMOUNT_NORMAL,
                "Amount must be between 1 and 10000"
            );
        }
        require(
            msg.sender != referrer,
            "Referrer cannot be the same as investor"
        );
        require(referrer != address(0), "Referrer cannot be 0x0");

        BUSD.transferFrom(msg.sender, address(this), _amount);

        BUSD.transfer(
            project,
            (_amount * (project_percent)) / (PERCENTS_DIVIDER)
        );
        BUSD.transfer(dev, (_amount * (dev_percent)) / (PERCENTS_DIVIDER));

        if (msg.sender == owner) {
            user.referrer = address(0);
        } else if (
            users[referrer].deposits.length == 0 && user.referrer == address(0)
        ) {
            referrer = owner;
            user.referrer = referrer;
            user.residualbonusreceiver = referrer;
            users[referrer].directs.push(msg.sender);
        } else if (user.referrer == address(0)) {
            user.residualbonusreceiver = referrer;
            updateref(msg.sender, referrer);
            address upline = user.referrer;
            for (uint256 i = 0; i < REFERRAL_PERCENTS.length; i++) {
                if (upline != address(0)) {
                    users[upline].levelusers[i]++;
                    upline = users[upline].referrer;
                } else break;
            }
        }

        if (user.referrer != address(0)) {
            address upline = user.referrer;
            for (uint256 i = 0; i < REFERRAL_PERCENTS.length; i++) {
                if (upline != address(0)) {
                    uint256 amount = (_amount * (REFERRAL_PERCENTS[i])) /
                        (PERCENTS_DIVIDER);
                    users[upline].levelbonus =
                        users[upline].levelbonus +
                        (amount);
                    users[upline].levelincome[i] =
                        users[upline].levelincome[i] +
                        (amount);
                    upline = users[upline].referrer;
                } else break;
            }
        }

        if (user.deposits.length == 0) {
            totalUsers = totalUsers + (1);
        }
        user.deposits.push(Deposit(_amount, 0, block.timestamp));
        totalInvested = totalInvested + (_amount);
        totalDeposits = totalDeposits + (1);
    }

    function updateref(address sender, address referrer) internal {
        User storage user = users[sender];
        if (!users[referrer].directsfilled) {
            user.referrer = referrer;
            users[referrer].directs.push(sender);
            if (users[referrer].directs.length == 5) {
                users[referrer].directsfilled = true;
            }
        } else {
            referrer = getuserrefspot(referrer);
            user.referrer = referrer;
            users[referrer].directs.push(sender);
            if (users[referrer].directs.length == 5) {
                users[referrer].directsfilled = true;
            }
        }
    }

    function getuserrefspot(address user)
        internal
        view
        returns (address referrer)
    {
        (address ref, bool found) = checkdownline(user);
        if (found) {
            return ref;
        } else {
            for (uint256 i = 0; i < users[user].directs.length; i++) {
                (address ref1, bool found1) = checkdownline(
                    users[user].directs[i]
                );
                if (found1) {
                    return ref1;
                } else {
                    getuserrefspot(users[user].directs[i]);
                }
            }
        }
    }

    function checkdownline(address user)
        internal
        view
        returns (address referrer, bool found)
    {
        for (uint256 i = 0; i < users[user].directs.length; i++) {
            if (!users[users[user].directs[i]].directsfilled) {
                return (users[user].directs[i], true);
            }
        }
        return (address(0), false);
    }

    function withdraw() public {
        User storage user = users[msg.sender];
        require(getUserDividendsWithdrawable(msg.sender) > min_withdraw, "Minimum withdraw amount is 1");
        require(
            block.timestamp > user.checkpoint + (TIME_STEP),
            "you can only take withdraw once in TIME_STEP"
        );
        if (user.dailylimitreceived >= MAX_PER_DAY) {
            require(
                block.timestamp > user.dailycheckpoint + (TIME_STEP),
                "your max daily limit is reached"
            );
            user.dailylimitreceived = 0;
            user.dailycheckpoint = block.timestamp;
        }

        uint256 totalAmount;
        uint256 dividends;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (
                user.deposits[i].withdrawn <
                (user.deposits[i].amount * (ROI_PERCENTAGE)) /
                    (PERCENTS_DIVIDER)
            ) {
                dividends =
                    (((user.deposits[i].amount * (TIME_STEP_ROI_PERCENTAGE)) /
                        (PERCENTS_DIVIDER)) *
                        (block.timestamp - (user.deposits[i].start))) /
                    (TIME_STEP);
                user.deposits[i].start = block.timestamp;
                if (
                    user.deposits[i].withdrawn + (dividends) >
                    (user.deposits[i].amount * (ROI_PERCENTAGE)) /
                        (PERCENTS_DIVIDER)
                ) {
                    dividends =
                        ((user.deposits[i].amount * (ROI_PERCENTAGE)) /
                            (PERCENTS_DIVIDER)) -
                        (user.deposits[i].withdrawn);
                }
                bool breaked = false;
                if (
                    totalAmount >= MAX_PER_DAY ||
                    totalAmount + dividends >= MAX_PER_DAY ||
                    dividends >= MAX_PER_DAY
                ) {
                    if (totalAmount >= MAX_PER_DAY) {
                        dividends = 0;
                        totalAmount = MAX_PER_DAY;
                    } else if (dividends >= MAX_PER_DAY) {
                        dividends = MAX_PER_DAY - totalAmount;
                        totalAmount = MAX_PER_DAY;
                    } else if (totalAmount + dividends >= MAX_PER_DAY) {
                        dividends = MAX_PER_DAY - totalAmount;
                        totalAmount = MAX_PER_DAY;
                    }
                    user.dailylimitreceived = MAX_PER_DAY;
                    breaked = true;
                }
                user.deposits[i].withdrawn =
                    user.deposits[i].withdrawn +
                    (dividends); /// changing of storage data
                if (breaked) {
                    break;
                }
                totalAmount = totalAmount + (dividends);
                user.dailylimitreceived = user.dailylimitreceived + (dividends);
            }
        }
        uint256 contractBalance = getContractBalance();
        if (contractBalance < totalAmount) {
            totalAmount = contractBalance;
        }

        user.checkpoint = block.timestamp;

        uint256 devfe = (totalAmount * (dev_percent)) / (PERCENTS_DIVIDER);
        uint256 additionalbonus = (totalAmount *
            (ADDITIONAL_REFERRAL_PERCENT)) / (PERCENTS_DIVIDER);
        if (users[user.residualbonusreceiver].directs.length >= 5) {
            if (user.residualbonusreceiver == owner) {
                users[user.residualbonusreceiver].additionalincome =
                    users[user.residualbonusreceiver].additionalincome +
                    (additionalbonus);
            } else if (Active(user.residualbonusreceiver)) {
                users[user.residualbonusreceiver].additionalincome =
                    users[user.residualbonusreceiver].additionalincome +
                    (additionalbonus);
            }
        } else {
            additionalbonus = 0;
        }

        totalWithdrawn = totalWithdrawn + (totalAmount);

        totalAmount = totalAmount - (devfe) - (additionalbonus);
        BUSD.transfer(dev, devfe);
        BUSD.transfer(msg.sender, totalAmount);
    }

    function withdrawbonus() public {
        User storage user = users[msg.sender];
        require(
            user.levelbonus > user.levelbonuswithdrawn ||
                user.additionalincome > user.additionalincomewithdrawn,
            "you have no bonus to withdraw"
        );
        if (user.dailylimitreceived >= MAX_PER_DAY) {
            require(
                block.timestamp > user.dailycheckpoint + (TIME_STEP),
                "your max daily limit is reached"
            );
            user.dailylimitreceived = 0;
            user.dailycheckpoint = block.timestamp;
        }
        uint256 amount = user.levelbonus - (user.levelbonuswithdrawn);
        uint256 amount1 = user.additionalincome -
            (user.additionalincomewithdrawn);
        if (getContractBalance() < amount) {
            amount = getContractBalance();
        }
        if (amount + user.dailylimitreceived >= MAX_PER_DAY) {
            amount = MAX_PER_DAY - user.dailylimitreceived;
            user.dailylimitreceived += amount;
        }
        user.levelbonuswithdrawn = user.levelbonuswithdrawn + (amount);
        if (amount > 0) {
            BUSD.transfer(msg.sender, amount);
        }
        if (getContractBalance() < amount1) {
            amount1 = getContractBalance();
        }
        if (amount1 + user.dailylimitreceived >= MAX_PER_DAY) {
            amount1 = MAX_PER_DAY - user.dailylimitreceived;
            user.dailylimitreceived += amount1;
        }
        user.additionalincomewithdrawn =
            user.additionalincomewithdrawn +
            (amount1);
        if (amount1 > 0) {
            BUSD.transfer(msg.sender, amount1);
        }
    }

    function getuserDirects(address _user)
        public
        view
        returns (address[] memory)
    {
        return users[_user].directs;
    }

    function getContractBalance() public view returns (uint256) {
        return BUSD.balanceOf(address(this));
    }

    function getUserDividendsWithdrawable(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = users[userAddress];
        uint256 totalDividends;
        uint256 dividends;
        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (
                user.deposits[i].withdrawn <
                (user.deposits[i].amount * (ROI_PERCENTAGE)) /
                    (PERCENTS_DIVIDER)
            ) {
                dividends =
                    (((user.deposits[i].amount * (TIME_STEP_ROI_PERCENTAGE)) /
                        (PERCENTS_DIVIDER)) *
                        (block.timestamp - (user.deposits[i].start))) /
                    (TIME_STEP);
                if (
                    user.deposits[i].withdrawn + (dividends) >
                    (user.deposits[i].amount * (ROI_PERCENTAGE)) /
                        (PERCENTS_DIVIDER)
                ) {
                    dividends =
                        ((user.deposits[i].amount * (ROI_PERCENTAGE)) /
                            (PERCENTS_DIVIDER)) -
                        (user.deposits[i].withdrawn);
                }

                totalDividends = totalDividends + (dividends);
            }
        }

        return (totalDividends);
    }

    function Active(address userAddress) internal view returns (bool active) {
        User storage user = users[userAddress];
        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (isActive(userAddress, i)) {
                return true;
            }
        }
        return false;
    }

    function isActive(address userAddress, uint256 index)
        public
        view
        returns (bool active)
    {
        User storage user = users[userAddress];

        if (user.deposits.length > 0) {
            if (
                user.deposits[index].withdrawn <
                (user.deposits[index].amount * (ROI_PERCENTAGE)) /
                    (PERCENTS_DIVIDER)
            ) {
                return true;
            } else {
                return false;
            }
        }
    }

    function getUserDepositInfo(address userAddress, uint256 index)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        User storage user = users[userAddress];

        return (
            user.deposits[index].amount,
            user.deposits[index].withdrawn,
            user.deposits[index].start
        );
    }

    function getUserAmountOfDeposits(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].deposits.length;
    }

    function getUserDownlineCount(address userAddress)
        public
        view
        returns (
            uint256 level1,
            uint256 level2,
            uint256 level3,
            uint256 level4,
            uint256 level5
        )
    {
        return (
            users[userAddress].levelusers[0],
            users[userAddress].levelusers[1],
            users[userAddress].levelusers[2],
            users[userAddress].levelusers[3],
            users[userAddress].levelusers[4]
        );
    }

    function getUserLevelIncome(address userAddress)
        public
        view
        returns (
            uint256 level1income,
            uint256 level2income,
            uint256 level3income,
            uint256 level4income,
            uint256 level5income
        )
    {
        return (
            users[userAddress].levelincome[0],
            users[userAddress].levelincome[1],
            users[userAddress].levelincome[2],
            users[userAddress].levelincome[3],
            users[userAddress].levelincome[4]
        );
    }

    function getUserTotalDeposits(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = users[userAddress];

        uint256 amount;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            amount = amount + (user.deposits[i].amount);
        }

        return amount;
    }

    function getUserTotalWithdrawn(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = users[userAddress];

        uint256 amount;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            amount = amount + (user.deposits[i].withdrawn);
        }

        return amount;
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function withdrawStuckToken(token _token, uint256 amount) external {
        require(msg.sender == owner, "Only owner can withdraw stuck token");
        require(amount > 0, "Amount must be greater than 0");
        require(
            amount <= _token.balanceOf(address(this)),
            "Amount must be less than or equal to balance"
        );
        _token.transfer(msg.sender, amount);
    }

    function withdrawStuckETH(uint256 amount) external {
        require(msg.sender == owner, "Only owner can withdraw stuck token");
        require(amount > 0, "Amount must be greater than 0");
        require(
            amount <= address(this).balance,
            "Amount must be less than or equal to balance"
        );
        payable(owner).transfer(amount);
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