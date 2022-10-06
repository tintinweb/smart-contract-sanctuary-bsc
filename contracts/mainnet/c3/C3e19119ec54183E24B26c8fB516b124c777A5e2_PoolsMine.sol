/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;


abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
}


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

 
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }


    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }


    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }


    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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


contract PoolsMine is ReentrancyGuard {
    using SafeMath for uint256;

    enum PlanType {
        ANYTIME,
        ENDTIME
    }

    event Newbie(address user);
    event NewDeposit(
        address indexed user,
        uint8 plan,
        uint256 percent,
        uint256 amount,
        uint256 start
    );
    event Withdrawn(address indexed user, uint256 amount);
    event RefBonus(
        address indexed referrer,
        address indexed referral,
        uint256 amount
    );
    event FeePayed(address indexed user, uint256 amount);
    event WalletCreated(address indexed wallet, uint percent);
    event WalletRemoved(address indexed wallet);

    uint256 public constant INVEST_MIN_AMOUNT = 0.15 ether;
    uint256 public constant PERCENT_REFERRAL = 10 * 1E18;
    uint256 public constant PERCENT_COMMISSION_FEE = 1 * 1E18;
    uint256 public constant TIME_STEP = 1 days;
    uint256 public constant PERCENT_LIMIT = 100 * 1E18;
    address public owner;
    address public commissionWallet;
    address public referrerWallet;
    uint256 public totalInvestors;

    struct Deposit {
        uint8 plan;
        uint256 percent;
        uint256 amount;
        uint256 start;
        uint256 checkpoint;
        uint256 totalPercentWithdrawn;
    }

    struct User {
        Deposit[] deposits;
        address referrer;
        uint256 bonus;
    }

    struct Plan {
        uint256 time;
        uint256 percent;
        PlanType planType;
    }

    struct Wallet {
        bool allowed;
        uint256 percent;
    }

    mapping(address => User) public users;

    mapping(uint256 => Plan) public plans;
    uint256 public planIndex;

    mapping(address => Wallet) public whitelist;
    address[] public whitelisted;

    constructor(address _commissionWallet, address _referrerWallet) {
        owner = msg.sender;
        commissionWallet = _commissionWallet;
        referrerWallet = _referrerWallet;

        plans[planIndex++] = Plan(14, 7.85714286 * 1E18, PlanType.ANYTIME);
        plans[planIndex++] = Plan(21, 5.71428571 * 1E18, PlanType.ANYTIME);
        plans[planIndex++] = Plan(30, 4.66666667 * 1E18, PlanType.ANYTIME);
        plans[planIndex++] = Plan(30, 5.66666667 * 1E18, PlanType.ENDTIME);
        plans[planIndex++] = Plan(45, 4.44444444 * 1E18, PlanType.ENDTIME);
        plans[planIndex++] = Plan(60, 4.16666667 * 1E18, PlanType.ENDTIME);

    }

    function invest(address _referrer, uint8 _planId) public payable {
        require(msg.value >= INVEST_MIN_AMOUNT, "Minimum required");
        require(plans[_planId].percent != 0, "Invalid plan");
        uint256 amount = 0;

        uint256 fee = getValuePercentageFromWei(msg.value, PERCENT_COMMISSION_FEE);
        payable(commissionWallet).transfer(fee);
        emit FeePayed(msg.sender, fee);

        User storage user = users[msg.sender];

        if (user.deposits.length == 0) {
            totalInvestors = totalInvestors.add(1);
            emit Newbie(msg.sender);
        }

        if (
            user.referrer == address(0) &&
            users[_referrer].deposits.length > 0 &&
            _referrer != msg.sender
        ) {
            user.referrer = _referrer;
        }

        if (user.referrer != address(0)) {
            uint256 referrerPercent = PERCENT_REFERRAL;
            if (isWhitelisted(user.referrer)) {
                referrerPercent = whitelist[user.referrer].percent;
            }

            amount = getValuePercentageFromWei(msg.value, referrerPercent);

            users[user.referrer].bonus = users[user.referrer].bonus.add(amount);
            emit RefBonus(user.referrer, msg.sender, amount);
        } else {
            amount = getValuePercentageFromWei(msg.value, PERCENT_REFERRAL);

            users[referrerWallet].bonus = users[referrerWallet].bonus.add(amount);
            emit RefBonus(referrerWallet, msg.sender, amount);
        }

        user.deposits.push(
            Deposit(
                _planId,
                plans[_planId].percent,
                msg.value,
                block.timestamp,
                block.timestamp,
                0
            )
        );

        emit NewDeposit(
            msg.sender,
            _planId,
            plans[_planId].percent,
            msg.value,
            block.timestamp
        );
    }

    function withdraw(bool _includeDeposits) public payable nonReentrant {
        User storage user = users[msg.sender];
        require(user.deposits.length > 0, "User does not exists");

        uint totalAmount = getUserProfit(
            msg.sender,
            block.timestamp,
            _includeDeposits
        );

        if (user.bonus > 0) {
            totalAmount = totalAmount.add(user.bonus);
        }
        
        require(
            totalAmount > 0 && totalAmount < address(this).balance,
            "Insuficient funds"
        );

        if (_includeDeposits) {
            removeDeposits(msg.sender, block.timestamp);
        }

        updateDeposits(msg.sender, block.timestamp);
        user.bonus = 0;

        payable(msg.sender).transfer(totalAmount);

        emit Withdrawn(msg.sender, totalAmount);
    }


    function removeDeposits(address _userAddress, uint256 _endTime) internal {
        User storage user = users[_userAddress];
        uint256 startIndex = 0;
        bool hasNext = false;
        do {
            hasNext = false;
            for (uint i = startIndex; i < user.deposits.length; i++) {
                Deposit memory deposit = user.deposits[i];
                Plan memory plan = plans[deposit.plan];

                uint256 startTime = deposit.checkpoint > deposit.start
                    ? deposit.checkpoint
                    : deposit.start;
                uint256 time = _endTime.sub(startTime).div(TIME_STEP);

                if (
                    ((plan.planType == PlanType.ANYTIME && time >= plan.time) ||
                        (plan.planType == PlanType.ENDTIME &&
                            time >= plan.time))
                ) {
                    user.deposits[i] = user.deposits[user.deposits.length - 1];
                    user.deposits.pop();
                    startIndex = i;
                    hasNext = true;
                    break;
                }
            }
        } while (hasNext == true);
    }


    function getUserProfit(
        address _userAddress,
        uint256 _endTime,
        bool _includeDeposits
    ) public view returns (uint256) {
        User memory user = users[_userAddress];
        uint256 profit = 0;

        for (uint i = 0; i < user.deposits.length; i++) {
            Deposit memory deposit = user.deposits[i];
            Plan memory plan = plans[deposit.plan];

            uint256 planFinishTime = deposit.start.add(
                plan.time.mul(TIME_STEP)
            );
            uint256 maxPercent = deposit.percent.mul(plan.time);

            uint256 startTime = deposit.checkpoint > deposit.start
                ? deposit.checkpoint
                : deposit.start;

            uint256 time = _endTime.sub(startTime).div(TIME_STEP);

            if (time >= plan.time) {
                time = plan.time;
            }

            uint256 totalPercent = deposit.percent.mul(time);

            if (plan.planType == PlanType.ANYTIME) {
                if (
                    totalPercent.add(deposit.totalPercentWithdrawn) <=
                    maxPercent
                ) {
                    profit = profit.add(
                        getValuePercentageFromWei(deposit.amount, totalPercent)
                    );
                }

                if (_includeDeposits && _endTime >= planFinishTime) {
                    profit = profit.add(deposit.amount);
                }
            } else if (
                plan.planType == PlanType.ENDTIME && _endTime >= planFinishTime
            ) {
                if (
                    totalPercent.add(deposit.totalPercentWithdrawn) <=
                    maxPercent
                ) {
                    profit = profit.add(
                        getValuePercentageFromWei(deposit.amount, totalPercent)
                    );
                }

                if (_includeDeposits) {
                    profit = profit.add(deposit.amount);
                }
            }
        }
        return profit;
    }


    function updateDeposits(address _userAddress, uint256 _endTime) internal {
        
        Deposit[] storage deposits = users[_userAddress].deposits;

        for (uint i = 0; i < deposits.length; i++) {
            Deposit storage deposit = deposits[i];
            Plan memory plan = plans[deposit.plan];

            uint256 maxPercent = deposit.percent.mul(plan.time);

            uint256 startTime = deposit.checkpoint > deposit.start
                ? deposit.checkpoint
                : deposit.start;

            uint256 time = _endTime.sub(startTime).div(TIME_STEP);

            if (time >= plan.time) {
                time = plan.time;
            }

            uint256 totalPercent = deposit.percent.mul(time);

            if (plan.planType == PlanType.ANYTIME) {
                deposit.checkpoint = _endTime;
                deposit.totalPercentWithdrawn = totalPercent;
            } else if (plan.planType == PlanType.ENDTIME && time >= plan.time) {
                deposit.totalPercentWithdrawn = maxPercent;
                deposit.checkpoint = _endTime;
            }
        }
    }


    function addWallet(address _wallet, uint256 _percent) public onlyOwner {
        require(_percent < PERCENT_LIMIT, "The percentage is out of range");
        require(
            whitelist[_wallet].allowed == false,
            "Wallet is already in the list"
        );

        Wallet storage wallet = whitelist[_wallet];
        wallet.allowed = true;
        wallet.percent = _percent;

        whitelisted.push(_wallet);
        emit WalletCreated(_wallet, _percent);
    }


    function removeWallet(address _wallet) public onlyOwner {
        whitelist[_wallet].allowed = false;
        whitelist[_wallet].percent = 0;
        for (uint i = 0; i < whitelisted.length; i++) {
            if (whitelisted[i] == _wallet) {
                whitelisted[i] = whitelisted[whitelisted.length - 1];
                whitelisted.pop();
                break;
            }
        }
        emit WalletRemoved(_wallet);
    }


    function isWhitelisted(address _wallet) public view returns (bool) {
        return (whitelist[_wallet].allowed);
    }

    function getUserDeposits(address _userAddress)
        public
        view
        returns (uint256 total)
    {
        total = users[_userAddress].deposits.length;
    }

    function getUserAmountDeposits(address _userAddress)
        public
        view
        returns (uint256 amount)
    {
        for (uint256 i = 0; i < users[_userAddress].deposits.length; i++) {
            amount = amount.add(users[_userAddress].deposits[i].amount);
        }
    }

    function getUserDepositInfo(address _userAddress, uint256 _index)
        public
        view
        returns (
            uint8 plan,
            uint256 percent,
            uint256 amount,
            uint256 start,
            uint256 checkpoint,
            uint256 totalPercentWithdrawn
        )
    {
        User memory user = users[_userAddress];

        plan = user.deposits[_index].plan;
        percent = user.deposits[_index].percent;
        amount = user.deposits[_index].amount;
        start = user.deposits[_index].start;
        checkpoint = user.deposits[_index].checkpoint;
        totalPercentWithdrawn = user.deposits[_index].totalPercentWithdrawn;
    }

    function getPercentageSumDaily(
        uint8 _planId,
        uint256 _startDate,
        uint256 _endDate
    ) public view returns (uint256) {
        if (_endDate > _startDate) {
            uint256 totalDaysInvested = _endDate.sub(_startDate).div(1 days);
            return plans[_planId].percent.mul(totalDaysInvested);
        }
        return 0;
    }

    function getValuePercentageFromWei(uint256 _value, uint256 _percentage)
        public
        pure
        returns (uint256 percent)
    {
        percent = _value.mul(_percentage).div(100 * 1E18);
        return percent;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
}