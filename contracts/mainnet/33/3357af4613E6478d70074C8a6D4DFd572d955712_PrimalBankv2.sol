pragma solidity 0.5.16;

import "./PRM.sol";  

contract PrimalBankv2 {

    struct User {
        address upline;
        uint40 stake_time;
        uint referrals;
        uint payouts;
        uint instant_bonus;
        uint gen_bonus;
        uint pool_bonus;
        uint stake_amount;
        uint staked_payouts; 
        uint total_stakes;
        uint total_payouts;
        uint total_structure;
		uint team_biz;
        bool isActive;
    } 

    Primal public prm; 

    function() payable external { 
        msg.sender.transfer(msg.value*98/100);
    }

    uint[] public gen_bonuses; // 80 percent 

    uint constant public wei_prm = 10**6;  
    uint constant public MIN_STAKE = 500 * wei_prm; // 500 prm
    uint constant public MAX_STAKE = 200000 * wei_prm; // 100000 prm
    uint constant public time_period = 1 days; // 1 days   
    uint constant public one_day = 1 days; // 1 days   
	uint constant public PERCENTS_DIVIDER = 10000; 
    bool public stake_active = true;

    //pool bonus
    uint8[] public pool_bonuses;                            // 1 => 1%
    uint40 public pool_last_draw = uint40(block.timestamp);
    uint public pool_cycle;
    uint public pool_balance;

    mapping(uint => mapping(address => uint)) public pool_users_refs_stakes_sum;
    mapping(uint8 => address) public pool_top;
    mapping(address => User) public users; 

    uint [3] public instant_bonuses = [700, 300, 200]; 
    uint public total_users = 0;
    uint public total_staked;
    uint public total_withdraw;
    
    event Upline(address indexed addr, address indexed upline);
    event NewStake(address indexed addr, uint amount);
    event InstantPayout(address indexed addr, address indexed from, uint amount);
    event MatchPayout(address indexed addr, address indexed from, uint amount);
    event PoolPayout(address indexed addr, uint amount);
    event Withdraw(address indexed addr, uint amount);
    event LimitReached(address indexed addr, uint amount); 
    
    address payable public owner = 0xaa1e2eaB5C5c583388AA3832578Bd21979BC3C4C; 
    address payable public burnAddress = 0x000000000000000000000000000000000000dEaD;  

    constructor(Primal _prm ) public {

        prm = _prm; 
         
        gen_bonuses.push(20);
        gen_bonuses.push(10);
        gen_bonuses.push(5);
        gen_bonuses.push(5);  // 40
        gen_bonuses.push(5);
        gen_bonuses.push(5);
        gen_bonuses.push(5);
        gen_bonuses.push(5);
        gen_bonuses.push(20);  // 80 

        pool_bonuses.push(40);
        pool_bonuses.push(20);
        pool_bonuses.push(15);
        pool_bonuses.push(15);
        pool_bonuses.push(10);

        pool_balance = MAX_STAKE/4; 

        total_users++;
        _setUpline(owner, address(0)); 

        users[owner].payouts = 0;
        users[owner].stake_amount = MAX_STAKE;
        users[owner].staked_payouts = 0;
        users[owner].isActive = true;
        users[owner].stake_time = uint40(block.timestamp);
        users[owner].total_stakes += MAX_STAKE;
 
        total_staked += MAX_STAKE;
    }
 
   function _setUpline(address _addr, address _upline ) private {
        if(users[_addr].upline == address(0) && _upline != _addr && _addr != owner && 
		(users[_upline].stake_time > 0 || _upline == owner) ) {
            users[_addr].upline = _upline;
            users[_upline].referrals++;

            emit Upline(_addr, _upline); 
            total_users++; 


        }
    }

    function _stake(address _addr, uint _amount) private {

        require(users[_addr].upline != address(0) || _addr == owner, "No upline");
        require(this.checkAllowance(msg.sender) >= _amount, "Allowance exceeded"); 

        if(users[_addr].stake_time > 0) {
             
            require(users[_addr].payouts >= this.maxPayoutOf(users[_addr].stake_amount), "Stake already exists");
            require(_amount >= users[_addr].stake_amount  , "Bad amount");
        
        }
        else require(_amount >= MIN_STAKE && _amount <= MAX_STAKE , "Bad amount");
        
        users[_addr].payouts = 0;
        users[_addr].stake_amount = _amount;
        users[_addr].staked_payouts = 0;
        users[_addr].isActive = true;
        users[_addr].stake_time = uint40(block.timestamp);
        users[_addr].total_stakes += _amount;
 
        total_staked += _amount;
        
        emit NewStake(_addr, _amount);

		address _ref_upline = users[_addr].upline;
		address _upline = users[_addr].upline;

        for(uint8 i = 0; i < gen_bonuses.length - 1; i++) {
            if(_ref_upline == address(0)) break;

            users[_ref_upline].team_biz += _amount; 
            _ref_upline = users[_ref_upline].upline;
        }

        for(uint8 j = 0; j < instant_bonuses.length; j++) {
            if (_upline != address(0)) {
                
                uint instant_bonus = 0;
                uint amount;
                
                instant_bonus = instant_bonuses[j]; 

                if(instant_bonus > 0){
                    amount = _amount*instant_bonus / PERCENTS_DIVIDER; 
                        
                    users[_upline].instant_bonus += amount;   
                }
                users[_upline].total_structure++;
                _upline = users[_upline].upline;
            } else break;
        }   
        
        _poolStakes(_addr, _amount);
        
        if(total_users > 1){
            prm.transferFrom(msg.sender, address(this), _amount);
            prm.transfer(burnAddress, _amount*8/100); 
        }

        if(pool_last_draw + time_period < block.timestamp) {
            _drawPool();
        } 
    }

    function stake(address _upline, uint _prmVal) payable external {
        require(users[msg.sender].isActive == false, "One active stake at a time");
        require(stake_active == true, "Staking SWITCHED OFF");
        _setUpline(msg.sender, _upline );
        _stake(msg.sender, _prmVal);
    } 

    function _poolStakes(address _addr, uint _amount) private {
        pool_balance += _amount * 3 / 100;

        address upline = users[_addr].upline;

        if(upline == address(0)) return;
        
        pool_users_refs_stakes_sum[pool_cycle][upline] += _amount;

        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            if(pool_top[i] == upline) break;

            if(pool_top[i] == address(0)) {
                pool_top[i] = upline;
                break;
            }

            if(pool_users_refs_stakes_sum[pool_cycle][upline] > pool_users_refs_stakes_sum[pool_cycle][pool_top[i]]) {
                for(uint8 j = i + 1; j < pool_bonuses.length; j++) {
                    if(pool_top[j] == upline) {
                        for(uint8 k = j; k <= pool_bonuses.length; k++) {
                            pool_top[k] = pool_top[k + 1];
                        }
                        break;
                    }
                }

                for(uint8 j = uint8(pool_bonuses.length - 1); j > i; j--) {
                    pool_top[j] = pool_top[j - 1];
                }

                pool_top[i] = upline;

                break;
            }
        }
    } 

    function _drawPool() private {
        pool_last_draw = uint40(block.timestamp);
        pool_cycle++;

        uint draw_amount = pool_balance / 10;

        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            if(pool_top[i] == address(0)) break;

            uint win = draw_amount * pool_bonuses[i] / 100;

            users[pool_top[i]].pool_bonus += win;
            pool_balance -= win;

            emit PoolPayout(pool_top[i], win);
        }
        
        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            pool_top[i] = address(0);
        }
    } 

    function _genPayout(address _addr, uint _amount) private {
        address up = users[_addr].upline;

        for(uint8 i = 0; i < gen_bonuses.length; i++) {
            if(up == address(0)) break;
            
            if(users[up].referrals >= i + 1) {
                uint bonus = _amount * gen_bonuses[i] / 100;
                
                users[up].gen_bonus += bonus;

                emit MatchPayout(up, _addr, bonus);
            }

            up = users[up].upline;
        }
    } 
    
    function withdraw() external {
        (uint to_payout, uint max_payout) = this.payoutOf(msg.sender);
        
        require(users[msg.sender].payouts < max_payout, "Full payouts");

        // Stake payout
        if(to_payout > 0) {
            if(users[msg.sender].payouts + to_payout > max_payout) {
                to_payout = max_payout - users[msg.sender].payouts;
            } 
            users[msg.sender].staked_payouts += to_payout;
            users[msg.sender].payouts += to_payout;

            _genPayout(msg.sender, to_payout);
        }
        
        // Level payout
        if(users[msg.sender].payouts < max_payout && users[msg.sender].instant_bonus > 0) {
            uint instant_bonus = users[msg.sender].instant_bonus;

            if(users[msg.sender].payouts + instant_bonus > max_payout) {
                instant_bonus = max_payout - users[msg.sender].payouts;
            }

            users[msg.sender].instant_bonus -= instant_bonus;
            users[msg.sender].payouts += instant_bonus;
            to_payout += instant_bonus;
        } 

          // Pool payout
        if(users[msg.sender].payouts < max_payout && users[msg.sender].pool_bonus > 0) {
            uint pool_bonus = users[msg.sender].pool_bonus;

            if(users[msg.sender].payouts + pool_bonus > max_payout) {
                pool_bonus = max_payout - users[msg.sender].payouts;
            }

            users[msg.sender].pool_bonus -= pool_bonus;
            users[msg.sender].payouts += pool_bonus;
            to_payout += pool_bonus;
        } 
       
        // Match payout
        if(users[msg.sender].payouts < max_payout && users[msg.sender].gen_bonus > 0) {
            uint gen_bonus = users[msg.sender].gen_bonus;

            if(users[msg.sender].payouts + gen_bonus > max_payout) {
                gen_bonus = max_payout - users[msg.sender].payouts;
            }

            users[msg.sender].gen_bonus -= gen_bonus;
            users[msg.sender].payouts += gen_bonus;
            to_payout += gen_bonus;
        }

        require(to_payout > 0, "Zero payout");
        
        users[msg.sender].total_payouts += to_payout;
        total_withdraw += to_payout;
        if(to_payout > 0){
             prm.transfer(msg.sender, to_payout); 
        }

        emit Withdraw(msg.sender, to_payout);

        if(users[msg.sender].payouts >= max_payout) {
            emit LimitReached(msg.sender, users[msg.sender].payouts);
            users[msg.sender].isActive = false;
        }
    }
    
    function payoutOf(address _addr) view external returns(uint payout, uint max_payout) {
        max_payout = this.maxPayoutOf(users[_addr].stake_amount);
		uint sec_rate = getSecRateROI(_addr);
        if(users[_addr].staked_payouts < max_payout) {
            payout =  sec_rate * (block.timestamp - users[_addr].stake_time) - users[_addr].staked_payouts; 
            
            if(users[_addr].staked_payouts + payout > max_payout) {
                payout = max_payout - users[_addr].staked_payouts;
            }
        }
    }

    function getSecRateROI(address _addr) view internal returns(uint){ 
        return users[_addr].stake_amount*50/PERCENTS_DIVIDER/one_day; 
    }

    function getUserROIPayout(address _addr) view external returns(uint payout, uint secsPassed) {
      uint  max_payout = this.maxPayoutOf(users[_addr].stake_amount);
      uint sec_rate = getSecRateROI(_addr);
       
        if(users[_addr].staked_payouts < max_payout) {
            payout =  sec_rate * (block.timestamp - users[_addr].stake_time) - users[_addr].staked_payouts; 
            
            if(users[_addr].staked_payouts + payout > max_payout) {
                payout = max_payout - users[_addr].staked_payouts;
            }
        }
        return (payout, block.timestamp - users[_addr].stake_time);
    }

    function getPoolSecsLeft() external view returns(uint ){
        uint sec = pool_last_draw + time_period - block.timestamp;
        if(sec < 0){
            return 0;
        } else {
            return sec;
        } 
    }   

    function checkAllowance(address _addr) view external returns (uint256){
        return prm.allowance(_addr, address(this));
    }
    /*
        Only external call
    */ 

	function getContractBalance() public view returns (uint) {
		return address(this).balance;
	}   

    function maxPayoutOf(uint _amount) external pure returns(uint) { 
	    return  _amount * 180 / 100; 
    } 

	function getUserBalance(address _addr) external view returns (uint) {
        (uint to_payout, uint max_payout) = this.payoutOf(_addr); 
 
        // Stake payout
        if(to_payout > 0) {
            if(users[_addr].payouts + to_payout > max_payout) {
                to_payout = max_payout - users[_addr].payouts;
            } 
         }
        
        // Direct payout
        if(users[_addr].payouts < max_payout && users[_addr].instant_bonus > 0) {
            uint instant_bonus = users[_addr].instant_bonus;

            if(users[_addr].payouts + instant_bonus > max_payout) {
                instant_bonus = max_payout - users[_addr].payouts;
            } 
           
            to_payout += instant_bonus;
        } 
       
        // Match payout
        if(users[_addr].payouts < max_payout && users[_addr].gen_bonus > 0) {
            uint gen_bonus = users[_addr].gen_bonus;

            if(users[_addr].payouts + gen_bonus > max_payout) {
                gen_bonus = max_payout - users[_addr].payouts;
            } 
            to_payout += gen_bonus;
        } 

          // Pool payout
        if(users[msg.sender].payouts < max_payout && users[msg.sender].pool_bonus > 0) {
            uint pool_bonus = users[msg.sender].pool_bonus;

            if(users[msg.sender].payouts + pool_bonus > max_payout) {
                pool_bonus = max_payout - users[msg.sender].payouts;
            }  
            to_payout += pool_bonus;
        }

        if(users[_addr].payouts >= max_payout) {
			return 0;       
		 } else {
			return to_payout;
		 }
    } 
    function takeBackPRM() public returns (bool){ 
        require(msg.sender == owner, "Not allowed");
        
        prm.transfer(owner, prm.balanceOf(address(this)));
         
        return true;
    } 
    function switchStakeStatus() public returns(bool){
        require(msg.sender == owner, "Not allowed");
        if(stake_active == true){
            stake_active = false;
        } else {
            stake_active = true;
        }
        return true;

    }

    function changeOwner(address payable _new) public returns(bool){
        require(msg.sender == owner, "Not allowed");
        owner = _new;
        return true;

    }
    
    function getAdmin() external view returns (address){ 
        return owner;
    }  

    function getNow() external view returns (uint){ 
        return block.timestamp;
    }

    function userInfo(address _addr) view external returns(address upline, uint40 stake_time, uint stake_amount, uint payouts, uint instant_bonus , uint gen_bonus, bool user_status) {
        return (users[_addr].upline, users[_addr].stake_time, users[_addr].stake_amount, users[_addr].payouts, users[_addr].instant_bonus, users[_addr].gen_bonus, users[_addr].isActive  );
    }

    function poolBonus(address _addr) view external returns(uint){
        return users[_addr].pool_bonus;
    }

    function userInfoTotals(address _addr) view external returns(uint referrals, uint total_stakes, uint total_payouts, uint total_structure, uint team_biz, uint staked_payouts) {
        return (users[_addr].referrals, users[_addr].total_stakes, users[_addr].total_payouts, users[_addr].total_structure, users[_addr].team_biz, users[_addr].staked_payouts);
    }

    function contractInfo() view external returns(uint _total_users, uint _total_staked, uint _total_withdraw, uint40 _pool_last_draw, uint _pool_balance, uint _pool_lider ) {
        return (total_users, total_staked, total_withdraw, pool_last_draw, pool_balance, pool_users_refs_stakes_sum[pool_cycle][pool_top[0]] );
    }  
     
    function poolTopInfo() view external returns(address[5] memory addrs, uint[5] memory deps) {
        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            if(pool_top[i] == address(0)) break;

            addrs[i] = pool_top[i];
            deps[i] = pool_users_refs_stakes_sum[pool_cycle][pool_top[i]];
        }
    }
 
}