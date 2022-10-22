/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

pragma solidity ^0.4.26; // solhint-disable-line


contract WADJET {
    uint256 constant DAY = 1 days;
    uint256 CYCLE = 21 * DAY;
    address public ceoAddress;
    address public marketingAddress;
    address public devAddress;
    address public insuranceWallet;
    address public communityWallet;
    address public supportWallet;
    struct User {
        uint256 investment;
        uint256 deposit;
        uint256 profit;
        uint256 rate;
        uint256 reinvestCheckPoint;
        uint256 withdrawCheckPoint;
        uint256 reinvests;
        uint256 withdrawal;
        uint256 refIncome;
        uint256[4] refs;
        address referrer;
        bool rateSet;
    }
    mapping(address => User) public users;

    uint256 public totalUsers;
    uint256 public totalInvestment;
    uint256[] public refPercents = [5, 3, 2, 2];

    event buyEvent(address indexed user, uint256 amount, address referrer);
    event sellEvent(address indexed user, uint256 amount);
    event reinvestEvent(address indexed user, uint256 eggs, uint256 miners);
    event newbie(address indexed user, address referrer);

    constructor(
        address _ceoAddress,
        address _marketingAddress,
        address _insuranceWallet,
        address _communityAddress,
        address _supportWallet
    ) public {
        ceoAddress = _ceoAddress;
        marketingAddress = _marketingAddress;
        devAddress = msg.sender;
        insuranceWallet = _insuranceWallet;
        communityWallet = _communityAddress;
        supportWallet = _supportWallet;

        //a root user is required to make referral mandatory
        users[msg.sender].investment = 0.2 ether; //root user is required to make referrals madatory
        users[msg.sender].withdrawCheckPoint = now;
        users[msg.sender].reinvestCheckPoint = now;
    }

    function reinvest() public {
        User storage user = users[msg.sender];
        if (
            user.reinvestCheckPoint <
            user.withdrawCheckPoint +
                CYCLE *
                (daysPassed(user.withdrawCheckPoint, now) / 21)
        ) {
            user.reinvests = 0;
        }
        uint passedDays = daysPassed(user.withdrawCheckPoint, now) % 21;
        if(user.reinvests & (2**(passedDays)-1) != 2**(passedDays)-1){
            reset(msg.sender);  
            return;
        }        
        user.reinvests =
            user.reinvests |
            (2**(daysPassed(user.withdrawCheckPoint, now) % 21));

        uint256 profit = calculateProfit(msg.sender);
        user.deposit += (user.profit + profit);
        user.profit = 0;
        user.reinvestCheckPoint = now;

        if (canWithdraw(msg.sender) && !user.rateSet) {
            user.rate += 15;
            user.rateSet = true;
        } else if (!canWithdraw(msg.sender) && user.rateSet) {
            user.rateSet = false;
        }

        emit reinvestEvent(msg.sender, profit, user.reinvests);
    }

    function canWithdraw(address _user) public view returns (bool) {
        User storage user = users[msg.sender];
        if (
            user.reinvestCheckPoint <
            user.withdrawCheckPoint +
                CYCLE *
                (daysPassed(user.withdrawCheckPoint, now) / 21)
        ) {
            return false;
        }
        return (users[_user].reinvests & ((2**20) - 1)) == (2**20) - 1
                && (daysPassed(user.withdrawCheckPoint, now) % 21)==20;
    }

    function withdraw() public {
        User storage user = users[msg.sender];
        uint256 passedDays = daysPassed(user.withdrawCheckPoint, now) % 21;
        require(passedDays == 20, "Withdrawal is closed");
        require(canWithdraw(msg.sender), "Non-consecutive reinvest");

        uint256 profit = user.profit + calculateProfit(msg.sender);
        reset(msg.sender);
        uint256 fee = devFee(profit);
        ceoAddress.transfer(fee);
        marketingAddress.transfer(fee);
        devAddress.transfer(fee);
        communityWallet.transfer(fee);
        insuranceWallet.transfer(fee);
        supportWallet.transfer(SafeMath.div(SafeMath.mul(profit, 125), 1000));
        uint256 net = (profit * 85) / 100;
        net = net + user.withdrawal > 8 * user.investment
            ? SafeMath.sub(8 * user.investment, user.withdrawal)
            : net;
        msg.sender.transfer(net);
        user.withdrawal = SafeMath.add(user.withdrawal, net);
        emit sellEvent(msg.sender, profit);
    }

    function reset(address _user) public {
        User storage user = users[_user];
        user.reinvestCheckPoint = now;
        user.withdrawCheckPoint = now;
        user.reinvests = 0;
        user.rateSet = false;
        user.profit = 0;
        user.rate = 5;
        user.deposit = user.investment;
    }

    function deposit(address ref) public payable {
        require(msg.value >= 2 * 10**17, "invalid amount");
        if (users[msg.sender].referrer == address(0)) {
            require(
                ref != msg.sender &&
                    ref != address(0) &&
                    users[ref].investment > 0,
                "invalid referrer"
            );
            users[msg.sender].referrer = ref;
            users[msg.sender].withdrawCheckPoint = now;
            users[msg.sender].rate = 5;
            totalUsers += 1;
            emit newbie(msg.sender, ref);
        }

        uint256 fee = devFee(msg.value);
        ceoAddress.transfer(fee);
        marketingAddress.transfer(fee);
        devAddress.transfer(fee);
        insuranceWallet.transfer(fee);
        communityWallet.transfer(fee);
        users[msg.sender].investment += msg.value;
        users[msg.sender].profit += (users[msg.sender].profit +
            calculateProfit(msg.sender));
        users[msg.sender].reinvestCheckPoint = now;
        users[msg.sender].deposit += msg.value;
        totalInvestment = SafeMath.add(totalInvestment, msg.value);

        if (users[msg.sender].referrer != address(0)) {
            address upline = users[msg.sender].referrer;
            for (uint256 i = 0; i < 4; i++) {
                if (upline != address(0)) {
                    uint256 profit = (SafeMath.mul(msg.value, refPercents[i]) /
                        100);
                    users[upline].deposit += profit;
                    users[upline].refIncome += profit;
                    users[upline].refs[i]++;
                    upline = users[upline].referrer;
                } else break;
            }
        }

        emit buyEvent(msg.sender, msg.value, ref);
    }

    function calculateProfit(address _user) public view returns (uint256) {
        User storage user = users[_user];
        return
            (min(SafeMath.sub(now, user.reinvestCheckPoint), DAY) *
                user.rate *
                user.deposit) /
            DAY /
            1000;
    }

    function devFee(uint256 amount) public pure returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, 25), 1000);
    }

    function changeCeo(address _adr) public payable {
        require(msg.sender == devAddress, "invalid call");
        ceoAddress = _adr;
    }

    function changeMarketing(address _adr) public payable {
        require(msg.sender == devAddress, "invalid call");
        marketingAddress = _adr;
    }

    function changeInsurance(address _adr) public payable {
        require(msg.sender == devAddress, "invalid call");
        insuranceWallet = _adr;
    }

    function changeCommunity(address _adr) public payable {
        require(msg.sender == devAddress, "invalid call");
        communityWallet = _adr;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getContractData(address adr)
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory d = new uint256[](17);
        User storage user = users[adr];

        d[0] = user.investment;
        d[1] = user.profit + calculateProfit(adr);
        d[2] = user.deposit;
        d[3] = user.rate;
        d[4] = user.refIncome;
        d[5] = user.withdrawal;
        d[6] = user.reinvestCheckPoint;
        d[7] = user.withdrawCheckPoint;
        d[8] = user.reinvests;
        d[9] = canWithdraw(adr) ? 1 : 0;
        d[10] = getBalance();
        d[11] = totalInvestment;
        d[12] = totalUsers;
        d[13] = user.refs[0];
        d[14] = user.refs[1];
        d[15] = user.refs[2];
        d[16] = user.refs[3];

        return d;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function daysPassed(uint256 from, uint256 to)
        public
        pure
        returns (uint256)
    {
        return SafeMath.sub(to, from) / DAY;
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