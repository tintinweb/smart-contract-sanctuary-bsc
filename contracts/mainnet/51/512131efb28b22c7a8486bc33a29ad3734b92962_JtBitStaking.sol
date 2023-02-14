/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

// SPDX-License-Identifier: MIT

/*

     ██╗████████╗██████╗ ██╗████████╗
     ██║╚══██╔══╝██╔══██╗██║╚══██╔══╝
     ██║   ██║   ██████╔╝██║   ██║   
██   ██║   ██║   ██╔══██╗██║   ██║   
╚█████╔╝   ██║   ██████╔╝██║   ██║   
 ╚════╝    ╚═╝   ╚═════╝ ╚═╝   ╚═╝   

*/

pragma solidity >=0.4.22 <0.9.0;

interface IBEP20 {
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

// Main Contract
contract JtBitStaking {
    using SafeMath for uint256;
    IBEP20 public token;
    address payable public DEPLOYER;

    uint256 public MIN_DEPOSIT = 2_000 ether;
    uint256 public MIN_WITHDRAW = 1_000 ether;
    uint256 public MAX_WITHDRAW = 100_000 ether;
    uint256[5] public REF_DEP_PERCENTS = [10_00, 5_00, 3_00, 1_00, 1_00];
    uint256 public constant WITHDRAW_FEE = 10_00;
    uint256 public constant PERCENTS_DIVIDER = 100_00;
    uint256 public TIME_STEP = 1 days;

    uint256 public totalStaked;
    uint256 public totalWithdrawn;
    uint256 public totalReinvested;
    uint256 public totalRefBonus;
    uint256 public totalUsers;

    bool public launched;

    struct Plan {
        uint256 time;
        uint256 percent;
    }

    Plan[] internal plans;

    struct Deposit {
        uint8 plan;
        uint256 percent;
        uint256 amount;
        uint256 profit;
        uint256 start;
        uint256 finish;
    }

    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        address referrer;
        uint256[5] levels;
        uint256 bonus;
        uint256 debt;
        uint256 totalBonus;
        uint256 totalWithdrawn;
    }

    mapping(address => User) internal users;

    modifier onlyDeployer() {
        require(msg.sender == DEPLOYER, "NOT AN OWNER");
        _;
    }

    event Newbie(address user);
    event NewDeposit(
        address indexed user,
        uint8 plan,
        uint256 percent,
        uint256 amount,
        uint256 profit,
        uint256 start,
        uint256 finish
    );
    event Withdrawn(address indexed user, uint256 amount);
    event RefBonus(
        address indexed referrer,
        address indexed referral,
        uint256 indexed level,
        uint256 amount
    );

    constructor(address _admin, address _token) {
        token = IBEP20(_token);
        DEPLOYER = payable(_admin);

        plans.push(Plan(30, 4_30));
        plans.push(Plan(45, 4_40));
    }

    function invest(
        address referrer,
        uint8 plan,
        uint256 amount
    ) public {
        require(launched, "wait for the launch");
        require(!isContract(msg.sender));
        require(amount >= MIN_DEPOSIT, "less than min Limit");
        token.transferFrom(msg.sender, address(this), amount);
        deposit(msg.sender, referrer, plan, amount);
    }

    function deposit(
        address userAddress,
        address referrer,
        uint8 plan,
        uint256 amount
    ) internal {
        require(plan < 2, "Invalid plan");
        User storage user = users[userAddress];

        if (user.referrer == address(0)) {
            if (referrer == userAddress) {
                referrer = DEPLOYER;
            }

            user.referrer = referrer;

            address upline = user.referrer;
            for (uint256 i = 0; i < REF_DEP_PERCENTS.length; i++) {
                if (upline != address(0)) {
                    users[upline].levels[i] = users[upline].levels[i].add(1);
                    upline = users[upline].referrer;
                } else break;
            }
        }

        if (user.referrer != address(0)) {
            address upline = user.referrer;
            for (uint256 i = 0; i < REF_DEP_PERCENTS.length; i++) {
                if (upline != address(0)) {
                    uint256 refAmount = amount.mul(REF_DEP_PERCENTS[i]).div(
                        PERCENTS_DIVIDER
                    );
                    users[upline].bonus = users[upline].bonus.add(refAmount);
                    users[upline].totalBonus = users[upline].totalBonus.add(
                        refAmount
                    );
                    totalRefBonus = totalRefBonus.add(refAmount);
                    emit RefBonus(upline, userAddress, i, refAmount);
                    upline = users[upline].referrer;
                } else break;
            }
        }

        if (user.deposits.length == 0) {
            totalUsers = totalUsers.add(1);
            user.checkpoint = block.timestamp;
            emit Newbie(userAddress);
        }

        (uint256 percent, uint256 profit, uint256 finish) = getResult(
            plan,
            amount
        );
        user.deposits.push(
            Deposit(plan, percent, amount, profit, block.timestamp, finish)
        );

        totalStaked = totalStaked.add(amount);
        emit NewDeposit(
            userAddress,
            plan,
            percent,
            amount,
            profit,
            block.timestamp,
            finish
        );
    }

    function withdraw() public {
        User storage user = users[msg.sender];
        require(
            block.timestamp >= user.checkpoint.add(TIME_STEP),
            "wait for next withdraw"
        );

        uint256 totalAmount = getUserDividends(msg.sender);
        uint256 referralBonus = getUserReferralBonus(msg.sender);
        if (referralBonus > 0) {
            user.bonus = 0;
            totalAmount = totalAmount.add(referralBonus);
        }
        if (user.debt > 0) {
            totalAmount = totalAmount.add(user.debt);
            user.debt = 0;
        }
        require(
            totalAmount >= MIN_WITHDRAW,
            "User dividends less than min Limit"
        );
        uint256 fee = totalAmount.mul(WITHDRAW_FEE).div(PERCENTS_DIVIDER);
        totalAmount = totalAmount.sub(fee);

        if (totalAmount > MAX_WITHDRAW) {
            user.debt = user.debt.add(totalAmount.sub(MAX_WITHDRAW));
            totalAmount = MAX_WITHDRAW;
        }

        uint256 contractBalance = token.balanceOf(address(this));
        if (totalAmount > contractBalance) {
            user.debt = user.debt.add(totalAmount.sub(contractBalance));
            totalAmount = contractBalance;
        }

        user.checkpoint = block.timestamp;
        user.totalWithdrawn = user.totalWithdrawn.add(totalAmount);
        totalWithdrawn = totalWithdrawn.add(totalAmount);

        token.transfer(msg.sender, totalAmount);

        emit Withdrawn(msg.sender, totalAmount);
    }

    function launch() external onlyDeployer {
        require(!launched, "Already launched");
        launched = true;
    }

    function changeDeployer(address payable _new) external onlyDeployer {
        require(!isContract(_new), "Can't be a contract");
        DEPLOYER = _new;
    }

    function changeLimits(uint256 _minDep, uint256 _minWit, uint256 _maxWit) external onlyDeployer {
        MIN_DEPOSIT = _minDep;
        MIN_WITHDRAW = _minWit;
        MAX_WITHDRAW = _maxWit;
    }

    function getPlanInfo(uint8 plan)
        public
        view
        returns (uint256 time, uint256 percent)
    {
        time = plans[plan].time;
        percent = plans[plan].percent;
    }

    function getResult(uint8 plan, uint256 amount)
        public
        view
        returns (
            uint256 percent,
            uint256 profit,
            uint256 finish
        )
    {
        percent = plans[plan].percent;

        profit = amount.mul(percent).mul(plans[plan].time).div(100);

        finish = block.timestamp.add(plans[plan].time.mul(TIME_STEP));
    }

    function getUserDividends(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = users[userAddress];
        uint256 totalAmount;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (user.checkpoint < user.deposits[i].finish) {
                uint256 share = user
                    .deposits[i]
                    .amount
                    .mul(user.deposits[i].percent)
                    .div(PERCENTS_DIVIDER);
                uint256 from = user.deposits[i].start > user.checkpoint
                    ? user.deposits[i].start
                    : user.checkpoint;
                uint256 to = user.deposits[i].finish < block.timestamp
                    ? user.deposits[i].finish
                    : block.timestamp;
                if (from < to) {
                    totalAmount = totalAmount.add(
                        share.mul(to.sub(from)).div(TIME_STEP)
                    );
                }
            }
        }

        return totalAmount;
    }

    function getUserCheckpoint(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].checkpoint;
    }

    function getUserReferrer(address userAddress)
        public
        view
        returns (address)
    {
        return users[userAddress].referrer;
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
        level1 = users[userAddress].levels[0];
        level2 = users[userAddress].levels[1];
        level3 = users[userAddress].levels[2];
        level4 = users[userAddress].levels[3];
        level5 = users[userAddress].levels[4];
    }

    function getUserReferralBonus(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].bonus;
    }

    function getUserReferralTotalBonus(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].totalBonus;
    }

    function getUserReferralWithdrawn(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].totalBonus.sub(users[userAddress].bonus);
    }

    function getUserDebt(address userAddress) public view returns (uint256) {
        return users[userAddress].debt;
    }

    function getUserAvailable(address userAddress)
        public
        view
        returns (uint256)
    {
        return
            getUserReferralBonus(userAddress)
                .add(getUserDividends(userAddress))
                .add(getUserDebt(userAddress));
    }

    function getUserAmountOfDeposits(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].deposits.length;
    }

    function getUserTotalDeposits(address userAddress)
        public
        view
        returns (uint256 amount)
    {
        for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
            amount = amount.add(users[userAddress].deposits[i].amount);
        }
    }

    function getUserDepositInfo(address userAddress, uint256 index)
        public
        view
        returns (
            uint8 plan,
            uint256 percent,
            uint256 amount,
            uint256 profit,
            uint256 start,
            uint256 finish
        )
    {
        User storage user = users[userAddress];

        plan = user.deposits[index].plan;
        percent = user.deposits[index].percent;
        amount = user.deposits[index].amount;
        profit = user.deposits[index].profit;
        start = user.deposits[index].start;
        finish = user.deposits[index].finish;
    }

    function getUserTotalWithdrawn(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].totalWithdrawn;
    }

    function isDepositActive(address userAddress, uint256 index)
        public
        view
        returns (bool)
    {
        User storage user = users[userAddress];

        return (user.deposits[index].finish > block.timestamp);
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}