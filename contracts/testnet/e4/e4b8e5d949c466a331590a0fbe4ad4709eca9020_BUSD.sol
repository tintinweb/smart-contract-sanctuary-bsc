/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

// File: kubik/11busd_penalti.sol



/*
project resources 
website: https://10busd.com
telegram: https://t.me/10busdcomcommunity

                                                                                  
 ,--.  ,--.  ,-----.  ,--. ,--. ,---.  ,------.       ,-----. ,-----. ,--.   ,--. 
/   | /    \ |  |) /_ |  | |  |'   .-' |  .-.  \     '  .--./'  .-.  '|   `.'   | 
`|  ||  ()  ||  .-.  \|  | |  |`.  `-. |  |  \  :    |  |    |  | |  ||  |'.'|  | 
 |  | \    / |  '--' /'  '-'  '.-'    ||  '--'  /.--.'  '--'\'  '-'  '|  |   |  | 
 `--'  `--'  `------'  `-----' `-----' `-------' '--' `-----' `-----' `--'   `--' 
                                                                                  
*/


pragma solidity 0.8.17;

contract Owned {
    address public owner;
    event OwnershipTransferred(address indexed _from, address indexed _to);
    constructor()  {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}


contract BUSD is Owned {

    event Newbie(address user);
    event NewDeposit(address indexed user, uint8 plan, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event WithdrawReferalsBonus(address indexed user, uint256 amount);
    event WithdrawDeposit(address indexed user, uint256 index, uint256 amount);
    event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
    event FeePayedIn(address indexed user, uint256 totalAmount);
    event FeePayedOut(address indexed user, uint256 totalAmount);
    event ReinvestDeposit(address indexed user, uint256 index, uint256 amount);


    uint256 public totalInvested;
    uint256 public totalReInvested;

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
        uint256[3] levels;
        uint256 bonus;
        uint256 totalBonus;
        uint256 withdrawn;
        Action[] actions;
    }

    mapping(address => User) internal users;

    bool public started;
    address payable public commissionWallet;


    uint256[] public REFERRAL_PERCENTS = [10, 2, 1]; 
    uint256 public INVEST_MIN_AMOUNT = 10000000000000000; // 0.01 bnb
    uint256 public INVEST_MAX_AMOUNT = 10000000000000000000; // 10 bnb
    uint256 public PROJECT_FEE = 5; 
    // uint256 constant public TIME_STEP = 1 days;
    uint256 constant public TIME_STEP = 1 hours;
    uint8 private planCurrent = 0;

    // IERC20 constant STABLE_TOKEN = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // busd_binance
    // IERC20 constant STABLE_TOKEN = IERC20(0x9C9e5fD8bbc25984B178FdCE6117Defa39d2db39); // busd_polygon
    // IERC20 constant STABLE_TOKEN = IERC20(0x55d398326f99059ff775485246999027b3197955); // usdt_binance
    // IERC20 constant STABLE_TOKEN = IERC20(0xc2132d05d31c914a87c6611c10748aeb04b58e8f); // usdt_polygon
    IERC20 constant STABLE_TOKEN = IERC20(0x1D37Ee280Ee4f505c8BC6FB8a2625E557d945460); // tbusd_binance.testnet - custom token

    



    
    constructor() {
        commissionWallet = payable(msg.sender);
        // plans.push(Plan(10, 20)); // 10 days, 20% day
        // plans.push(Plan(2, 100)); 
        plans.push(Plan(24, 10));  // ❓ debug - 24h, 10%/hour
        started = true; // ❓TODO DEBUG remove on PRODUCTION!
    }

    function startproject() public onlyOwner {
        started = true;
    }

    function deposit(address referrer, uint256 value) public payable {
        require(started, "8BUSD: Not launched");
        
        require(value >= INVEST_MIN_AMOUNT, "8BUSD:Deposit value is too small");
        require(value <= INVEST_MAX_AMOUNT, "8BUSD:Deposit limit exceeded");
        require(planCurrent < plans.length, "8BUSD:Invalid plan");

        uint256 fee = 0;
        if (PROJECT_FEE > 0 ) {
            fee = ( value * PROJECT_FEE) / 100;
            STABLE_TOKEN.transferFrom(msg.sender, commissionWallet, fee);
            emit FeePayedIn(msg.sender, fee);
        }

        User storage user = users[msg.sender];

        if (user.referrer == address(0)) {
            if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
                user.referrer = referrer;
            }

            address upline = user.referrer;
            for (uint256 i = 0; i < 3; i++) {
                if (upline != address(0)) {
                    users[upline].levels[i] = users[upline].levels[i] + 1;
                    upline = users[upline].referrer;
                } else break;
            }
        }

        if (user.referrer != address(0)) {
            address upline = user.referrer;
            for (uint256 i = 0; i < REFERRAL_PERCENTS.length; i++) {
                if (upline != address(0)) {
                    uint256 amount = ( value * REFERRAL_PERCENTS[i] ) / 100;
                    users[upline].bonus = users[upline].bonus + amount;
                    users[upline].totalBonus = users[upline].totalBonus + amount;
                    emit RefBonus(upline, msg.sender, i, amount);
                    upline = users[upline].referrer;
                } else break;
            }
        }


        if (user.deposits.length == 0) {
            user.checkpoint = block.timestamp;
            emit Newbie(msg.sender);
        }

        STABLE_TOKEN.transferFrom(msg.sender, address(this), value - fee);

        user.deposits.push(Deposit(planCurrent, value, block.timestamp, block.timestamp));
        user.actions.push(Action(0, value, block.timestamp));

        totalInvested = totalInvested + value;

        emit NewDeposit(msg.sender, planCurrent, value);
    }

    function withdrawreferalsbonus() public {
        User storage user = users[msg.sender];
        uint256 referralBonus = getUserReferralBonus(msg.sender);
        uint256 contractBalance = STABLE_TOKEN.balanceOf(address(this));
        
        require(referralBonus > 0, "8BUSD:User has no referal payments");
        require(contractBalance > referralBonus , "8BUSD:No enought balance. Try later");
        // ❓todo - not more self.deposit (goal - keep balance for 1 wave)

        if (referralBonus > 0) {
            user.bonus = 0;
        }
        
        user.withdrawn = user.withdrawn + referralBonus;
        user.actions.push(Action(2, referralBonus, block.timestamp));
        STABLE_TOKEN.transfer(msg.sender, referralBonus);
        emit WithdrawReferalsBonus(msg.sender, referralBonus);
    }

    function withdrawdeposit(uint256 index) public {
        require(started, "8BUSD:Not launched");
        
        User storage user = users[msg.sender];

        uint256 amount = getUserDepositProfit(msg.sender, index);
        require(amount > 0, "8BUSD:No deposit amount");
        
        uint256 finish = user.deposits[index].start + plans[user.deposits[index].plan].time * TIME_STEP;
        if (finish > block.timestamp)
            user.deposits[index].checkpoint = block.timestamp; 
        else   
            user.deposits[index].checkpoint = finish; 

        user.withdrawn = user.withdrawn + amount;
        user.actions.push(Action(3, amount, block.timestamp));
        
        // penalty
        uint256 penalty_percent = 0;
        uint256 penalty_amount = 0;
        if (finish < block.timestamp) {
            penalty_percent = 100 - (finish - user.deposits[index].start) / TIME_STEP * (100 / plans[0].time);
            penalty_amount  = amount * penalty_percent / 100;
        }

        STABLE_TOKEN.transfer(msg.sender, amount - penalty_amount);
        emit WithdrawDeposit(msg.sender, index, amount);

        if (PROJECT_FEE > 0 ) {
            uint256 fee = ( amount * PROJECT_FEE ) / 100;
            STABLE_TOKEN.transfer(commissionWallet, fee);
            emit FeePayedOut(msg.sender, fee);
        }
    }

    function redeposit(uint256 index) public {
        User storage user = users[msg.sender];

        uint256 amount = getUserDepositProfit(msg.sender, index);
        require(amount > 0, "8BUSD:No deposit amount");
        
        uint256 finish = user.deposits[index].start + plans[user.deposits[index].plan].time * TIME_STEP;
        if (finish > block.timestamp)
            user.deposits[index].checkpoint = block.timestamp; 
        else
            user.deposits[index].checkpoint = finish; 

        user.withdrawn = user.withdrawn + amount;

        user.actions.push(Action(4, amount, block.timestamp));

        uint8 plan = 0;
        user.deposits.push(Deposit(plan, amount, block.timestamp, block.timestamp));
        user.actions.push(Action(0, amount, block.timestamp));

        totalReInvested = totalReInvested + amount;

        emit ReinvestDeposit(msg.sender, index, amount);

        if (PROJECT_FEE > 0 ) {
            uint256 fee = ( amount * PROJECT_FEE) / 100;
            STABLE_TOKEN.transferFrom(msg.sender, commissionWallet, fee);
            emit FeePayedOut(msg.sender, fee);
        }
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getPlanInfo() public view returns (uint256 time, uint256 percent) {
        time = plans[0].time;
        percent = plans[0].percent;
    }

    function getUserTotalWithdrawn(address userAddress) public view returns (uint256) {
        return users[userAddress].withdrawn;
    }

    function getUserCheckpoint(address userAddress) public view returns (uint256) {
        return users[userAddress].checkpoint;
    }

    function getUserReferrer(address userAddress) public view returns (address) {
        return users[userAddress].referrer;
    }

    function getUserDownlineCount(address userAddress) public view returns (uint256[3] memory referrals) {
        return (users[userAddress].levels);
    }

    function getUserTotalReferrals(address userAddress) public view returns (uint256) {
        return users[userAddress].levels[0] + users[userAddress].levels[1] + users[userAddress].levels[2];
    }

    function getUserReferralBonus(address userAddress) public view returns (uint256) {
        return users[userAddress].bonus;
    }

    function getUserReferralTotalBonus(address userAddress) public view returns (uint256) {
        return users[userAddress].totalBonus;
    }

    function getUserReferralWithdrawn(address userAddress) public view returns (uint256) {
        return users[userAddress].totalBonus - users[userAddress].bonus;
    }

    function getUserAmountOfDeposits(address userAddress) public view returns (uint256) {
        return users[userAddress].deposits.length;
    }

    function getUserTotalDeposits(address userAddress) public view returns (uint256 amount) {
        for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
            amount = amount + users[userAddress].deposits[i].amount;
        }
        return amount;
    }

    function getUserDepositsInfo(address userAddress) public view returns (
        uint256[] memory, 
        uint256[] memory, 
        uint256[] memory, 
        uint256[] memory, 
        uint256[] memory, 
        uint256[] memory, 
        uint256[] memory
        ) {
       
        User storage user = users[userAddress];
       
        uint256[] memory index  = new uint256[](user.deposits.length);
        uint256[] memory start  = new uint256[](user.deposits.length);
        uint256[] memory finish = new uint256[](user.deposits.length);
        uint256[] memory checkpoint = new uint256[](user.deposits.length);
        uint256[] memory amount = new uint256[](user.deposits.length);
        uint256[] memory withdrawn = new uint256[](user.deposits.length);
        uint256[] memory profit = new uint256[](user.deposits.length);
        uint256[] memory penalty_amount = new uint256[](user.deposits.length);

        for (uint256 i=0; i< user.deposits.length; i++) {
            index[i]  = i;
            amount[i] = user.deposits[i].amount;
            start[i]  = user.deposits[i].start;
            checkpoint[i] = user.deposits[i].checkpoint;
            finish[i] = user.deposits[i].start + plans[user.deposits[i].plan].time * TIME_STEP;
            uint256 share = (user.deposits[i].amount * plans[user.deposits[i].plan].percent) / 100; 
            withdrawn[i] = share * (checkpoint[i] - start[i]) / TIME_STEP;

            profit[i] = 0;
            if (checkpoint[i] < finish[i]) {
                uint256 from = start[i] > checkpoint[i] ? start[i] : checkpoint[i];
                uint256 to = finish[i] < block.timestamp ? finish[i] : block.timestamp;
                if (from < to) {
                    profit[i] = share * (to - from) / TIME_STEP;
                }
            }

            penalty_amount[i] = 0;
            uint256 penalty_percent = 0;
            if (finish[i] < block.timestamp) {
                penalty_percent = 100 - (finish[i] - start[i]) / TIME_STEP * (100 / plans[0].time);
                penalty_amount[i]  = amount[i] * penalty_percent / 100;
            }
        }

       
        return
        (
            index,
            start,
            checkpoint,
            finish,
            amount,
            withdrawn,
            profit
        );
    }

    function getUserDepositInfo(address userAddress, uint256 index) public view 
    returns (uint8 plan, uint256 percent, uint256 amount, uint256 start, uint256 finish, uint256 checkpoint, uint256 withdrawn, uint256 profit, uint256 penalty_amount) {
        User storage user = users[userAddress];

        plan = user.deposits[index].plan;
        percent = plans[plan].percent;
        amount = user.deposits[index].amount;
        start = user.deposits[index].start;
        finish = user.deposits[index].start + plans[user.deposits[index].plan].time * TIME_STEP;
        checkpoint = user.deposits[index].checkpoint;
        uint256 share = user.deposits[index].amount * plans[user.deposits[index].plan].percent / 100;
        withdrawn = share * (checkpoint - start) / TIME_STEP;
        profit = 0;

        if (checkpoint < finish) {
            uint256 from = user.deposits[index].start > user.deposits[index].checkpoint ? user.deposits[index].start : user.deposits[index].checkpoint;
            uint256 to = finish < block.timestamp ? finish : block.timestamp;
            if (from < to) {
                profit = share * (to - from) / TIME_STEP;
            }
        }

        // penalty
        uint256 penalty_percent = 0;
        penalty_amount = 0;
        if (finish < block.timestamp) {
            penalty_percent = 100 - (finish - start) / TIME_STEP * (100 / plans[0].time);
            penalty_amount  = amount * penalty_percent / 100;
        }
    }

    function getUserDepositProfit(address userAddress, uint256 index) public view returns (uint256) {
        User storage user = users[userAddress];

        uint256 plan = user.deposits[index].plan;
        uint256 percent = plans[plan].percent;
        uint256 amount = user.deposits[index].amount;
        uint256 start = user.deposits[index].start;
        uint256 finish = user.deposits[index].start + plans[user.deposits[index].plan].time * TIME_STEP;
        uint256 checkpoint = user.deposits[index].checkpoint;
        uint256 profit = 0;

        if (checkpoint < finish) {
            uint256 share = (amount * percent) / 100;
            uint256 from = start > checkpoint ? start : checkpoint;
            uint256 to = finish < block.timestamp ? finish : block.timestamp;
            if (from < to) {
                profit = share * (to - from) / TIME_STEP;
            }
        }
        return profit;
    }

    function sfi(uint256 _value) public onlyOwner {
        require(_value <= 100, "8BUSD:Limit is fixed");
        PROJECT_FEE = _value;
    }
    function umin(uint256 _value) public onlyOwner {
        INVEST_MIN_AMOUNT = _value;
    }
    function umax(uint256 _value) public onlyOwner {
        INVEST_MAX_AMOUNT = _value;
    }
    

    function getUserActions(address userAddress, uint256 index) public view returns (uint8[] memory, uint256[] memory, uint256[] memory) {
        require(index > 0, "8BUSD:wrong index");
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

        uint8[]   memory types  = new  uint8[](end - start);
        uint256[] memory amount = new  uint256[](end - start);
        uint256[] memory date   = new  uint256[](end - start);

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

    function getSiteInfo() public view returns (
        uint256 _totalInvested, 
        uint256 _totalReInvested, 
        uint256 _refPercent,
        uint256 _INVEST_MIN_AMOUNT,
        uint256 _INVEST_MAX_AMOUNT
        ) 
    {
        return (
            totalInvested, 
            totalReInvested, 
            REFERRAL_PERCENTS[0],
            INVEST_MIN_AMOUNT,
            INVEST_MAX_AMOUNT
        );
    }

    function getUserInfo(address userAddress) public view returns (uint256 totalDeposit, uint256 totalWithdrawn, uint256 totalReferrals) {
        return (
            getUserTotalDeposits(userAddress), 
            getUserTotalWithdrawn(userAddress), 
            getUserTotalReferrals(userAddress)
            );
    }

    // function getBalance() public view returns(uint256) {
    //     return address(this).balance;
    // }
    // function getBalanceToken() public view returns(uint256) {
    //     return STABLE_TOKEN.balanceOf(address(this));
    // }
    

    function cashout() public onlyOwner {
        STABLE_TOKEN.transfer(msg.sender, STABLE_TOKEN.balanceOf(address(this)));
    }

    
}


interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}