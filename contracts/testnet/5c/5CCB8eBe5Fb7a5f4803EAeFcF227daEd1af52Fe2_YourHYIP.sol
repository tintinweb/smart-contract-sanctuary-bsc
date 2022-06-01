/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract YourHYIP {
    bool launched = false; // Если false, контракт изначально не принимает депозиты, для запуска админу необходимо вызвать функцию launch()

    address public founder;

    uint256 public investors;
    uint256 public invested;
    uint256 public withdrawn;
    uint256 public match_bonus;
    

    uint16 constant PERCENT_DIVIDER = 1000;                     // Делитель, в данном случае 1000 == 100%
    uint8 constant FOUNDER_FEE = 150;                           // Коммисия админу, в данном случае 15%

    uint8 constant REF_LEVELS = 5;                              // Кол-во реферальных уровней
    uint8[REF_LEVELS] public REF_FEE = [50, 40, 30, 20, 10];    // Реферальный процент на каждом уровне: 5% - 4%- 3% - 2% - 1%

    uint8[] PLAN_DURATION = [8];                                 // Продолжительность депозита в днях, в данном случае 8 дней
    uint8[] PLAN_PERCENT = [200];                                // Общая выплата по окончании срока, в данном случае 200%

    struct Plan {
        uint8 life_days;
        uint8 percent;
    }

    struct Deposit {
        uint8 plan;
        uint256 amount;
        uint40 time;
    }

    struct User {
        address upline;
        uint256 dividends;
        uint256 match_bonus;
        uint40 last_payout;
        uint256 total_invested;
        uint256 total_withdrawn;
        uint256 total_match_bonus;
        Deposit[] deposits;
        uint256[REF_LEVELS] structure; 
    }

    mapping(uint8 => Plan) public plans;
    mapping(address => User) public users;

    event Upline(address indexed addr, address indexed upline, uint256 bonus);
    event NewDeposit(address indexed addr, uint256 amount, uint8 plan);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);

    constructor() {
        founder = msg.sender;

         for(uint8 i = 0; i < PLAN_DURATION.length; i++) {
            plans[PLAN_DURATION[i]] = Plan(PLAN_DURATION[i], PLAN_PERCENT[i]);
         }
    }

    function launch() external {
        require(msg.sender == founder, "You must be admin");
		launched = true;
    }

    function _payout(address _addr) private {
        uint256 payout = this.payoutOf(_addr);

        if(payout > 0) {
            users[_addr].last_payout = uint40(block.timestamp);
            users[_addr].dividends += payout;
        }
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = users[_addr].upline;

        for(uint8 i = 0; i < REF_FEE.length; i++) {
            if(up == address(0)) break;
            
            uint256 bonus = _amount * REF_FEE[i] / PERCENT_DIVIDER;
            
            users[up].match_bonus += bonus;
            users[up].total_match_bonus += bonus;

            match_bonus += bonus;

            emit MatchPayout(up, _addr, bonus);

            up = users[up].upline;
        }
    }

    function _setUpline(address _addr, address _upline, uint256 _amount) private {
        if(users[_addr].upline == address(0) && _addr != founder) {
            users[_addr].upline = _upline;

            emit Upline(_addr, _upline, _amount / 100);
            
            for(uint8 i = 0; i < REF_LEVELS; i++) {
                users[_upline].structure[i]++;

                _upline = users[_upline].upline;

                if(_upline == address(0)) break;
            }
        }
    }
    
    function deposit(uint8 _plan, address _upline) external payable {
        require(launched, "Contract must be launched");
        require(plans[_plan].life_days > 0, "Plan not found");
        require(msg.value >= 0.01 ether, "Minimum deposit amount is 0.01 BNB");

        User storage user = users[msg.sender];
        
        require(user.deposits.length < 100, "Max 100 deposits per address");

        if(user.deposits.length == 0) {
            investors += 1;
        }
        _setUpline(msg.sender, _upline, msg.value);

        user.deposits.push(Deposit({
            plan: _plan,
            amount: msg.value,
            time: uint40(block.timestamp)
        }));

        user.total_invested += msg.value;
        invested += msg.value;

        _refPayout(msg.sender, msg.value);

        uint256 founder_fee = ((msg.value * FOUNDER_FEE) / PERCENT_DIVIDER) / 2;

        payable(founder).transfer(founder_fee);
        
        emit NewDeposit(msg.sender, msg.value, _plan);
    }
    
    function withdraw() external {
        User storage user = users[msg.sender];

        _payout(msg.sender);

        require(user.dividends > 0 || user.match_bonus > 0, "Zero amount");

        uint256 amount = user.dividends + user.match_bonus;

        user.dividends = 0;
        user.match_bonus = 0;
        user.total_withdrawn += amount;
        withdrawn += amount;

        payable(msg.sender).transfer(amount);
        
        emit Withdraw(msg.sender, amount);
    }

    function payoutOf(address _addr) view external returns(uint256 value) {
        User storage user = users[_addr];

        for(uint256 i = 0; i < user.deposits.length; i++) {
            Deposit storage dep = user.deposits[i];
            Plan storage plan = plans[dep.plan];

            uint40 time_end = dep.time + plan.life_days * 86400;
            uint40 from = user.last_payout > dep.time ? user.last_payout : dep.time;
            uint40 to = block.timestamp > time_end ? time_end : uint40(block.timestamp);

            if(from < to) {
                value += dep.amount * (to - from) * plan.percent / plan.life_days / 8640000;
            }
        }

        return value;
    }

    function userInfo(address _addr) view external returns(uint256 for_withdraw, uint256 total_invested, uint256 total_withdrawn, uint256 total_match_bonus, uint256[REF_LEVELS] memory structure) {
        User storage user = users[_addr];

        uint256 payout = this.payoutOf(_addr);

        for(uint8 i = 0; i < REF_FEE.length; i++) {
            structure[i] = user.structure[i];
        }

        return (
            payout + user.dividends + user.match_bonus,
            user.total_invested,
            user.total_withdrawn,
            user.total_match_bonus,
            structure
        );
    }

    function contractInfo() view external returns(uint256 _investors, uint256 _invested, uint256 _withdrawn, uint256 _match_bonus) {
        return (investors, invested, withdrawn, match_bonus);
    }
}