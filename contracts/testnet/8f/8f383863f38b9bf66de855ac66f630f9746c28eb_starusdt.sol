/**
 *Submitted for verification at BscScan.com on 2022-07-28
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
		uint256 referrals_main;		
        uint256 payouts;
        uint256 direct_bonus;
        uint256 deposit_amount;
        uint256 deposit_payouts;
        uint40 deposit_time;
        uint256 total_deposits;
        uint256 total_payouts;
        uint256 total_structure;
        uint8 block;
	    uint256 isactive;
    }

    struct Block {
        uint256 block_min_amount;
        uint8  block_level;
        uint8 block_deposit_payout;
    }

    address payable public owner;
    address payable public com_fee;

    mapping(address => User) public users;

    uint8[] public direct_bonuses;
    
    uint256 public total_users = 1;
    uint256 public total_deposited;
    uint256 public total_withdraw;
    
    mapping(uint8 => Block) public blocks;


    IERC20 public usdt = IERC20(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd);
	
  
    event Upline(address indexed addr, address indexed upline);
    event NewDeposit(address indexed addr, uint256 amount);
    event DirectPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);
    event LimitReached(address indexed addr, uint256 amount);

    constructor(address payable _owner) public {
        owner = _owner;
    

        com_fee = 0x287fdEa5558f426FC6504308eA6C8586B86c5cdA;
		


        blocks[0].block_min_amount = 1e6;
        blocks[1].block_min_amount = 1e8;
        blocks[2].block_min_amount = 2.5e8;
        blocks[3].block_min_amount = 5e8;
        blocks[4].block_min_amount = 1e9;
        blocks[5].block_min_amount = 2.5e9;
        blocks[6].block_min_amount = 5e9;        
        
        blocks[0].block_level = 1;
        blocks[1].block_level = 4;
        blocks[2].block_level = 5;
        blocks[3].block_level = 6;
        blocks[4].block_level = 8;
        blocks[5].block_level= 10;
        blocks[6].block_level = 12;
        
        blocks[0].block_deposit_payout = 150;
        blocks[1].block_deposit_payout = 150;
        blocks[2].block_deposit_payout = 150;
        blocks[3].block_deposit_payout = 150;
        blocks[4].block_deposit_payout = 150;
        blocks[5].block_deposit_payout = 150;
        blocks[6].block_deposit_payout = 200;
        
        direct_bonuses.push(10);
        direct_bonuses.push(3);
        direct_bonuses.push(2);
        direct_bonuses.push(1);
        direct_bonuses.push(1);
        direct_bonuses.push(1);
        direct_bonuses.push(1);
        direct_bonuses.push(1);
        direct_bonuses.push(1);
        direct_bonuses.push(1);
        direct_bonuses.push(1);
        direct_bonuses.push(2);
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

            for(uint8 i = 0; i < direct_bonuses.length; i++) {
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
			require(_amount >= blocks[_nextBlock(_addr)].block_min_amount, "Bad amount");
			users[_addr].cycle++;        
        }
        else require(_amount >= 1, "Bad amount"); 

	   usdt.transferFrom(address(msg.sender), address(this), _amount);

        users[_addr].payouts = 0;
        users[_addr].deposit_amount = _amount;
        users[_addr].deposit_payouts = 0;
        users[_addr].deposit_time = uint40(block.timestamp);
        users[_addr].total_deposits += _amount;
        
		if (users[_addr].deposit_amount <  blocks[1].block_min_amount )
			users[_addr].block = 0;
		else if (users[_addr].deposit_amount < blocks[2].block_min_amount )
			users[_addr].block  = 1;
		else if (users[_addr].deposit_amount < blocks[3].block_min_amount )
			users[_addr].block  = 2;
		else if (users[_addr].deposit_amount < blocks[4].block_min_amount )
			users[_addr].block  = 3;
		else if (users[_addr].deposit_amount < blocks[5].block_min_amount )
			users[_addr].block  = 4;
		else if (users[_addr].deposit_amount < blocks[6].block_min_amount )
			users[_addr].block  = 5;			
		else
		    users[_addr].block  = 6;
			
		if( users[_addr].block > 0 ) {
			users[users[_addr].upline].referrals_main++;
		}

        total_deposited += _amount;
	        
        emit NewDeposit(_addr, _amount);
        
        if(users[_addr].upline != address(0)) {
			_directPayout(_addr,_amount);
        }
        
    }
    
    function _nextBlock(address _addr) view private returns(uint8) {
        if( users[_addr].block + 1 > 6)
            return 6;
        else
            return users[_addr].block + 1;
    }
    
    function _directPayout(address _addr, uint256 _amount) private {
        address up = users[_addr].upline;
        
        for(uint8 i = 0; i < direct_bonuses.length; i++) {
            if(up == address(0)) break;
            
            uint256 max_payout = this.maxPayoutOf(users[up].deposit_amount);
            if( up==owner || (  (users[up].referrals_main >= i + 1 || i == 0) && blocks[users[up].block].block_level >= i + 1  && users[up].payouts < max_payout ) )  {
                uint256 bonus = _amount * direct_bonuses[i] / 100;
                
                users[up].direct_bonus += bonus;
	
                emit DirectPayout(up, _addr, bonus);
            }

            up = users[up].upline;
        }
    }

    function deposit(address _upline, uint256 _amount) payable external {
        _setUpline(msg.sender, _upline);
        _deposit(msg.sender, _amount);
    }

    function withdraw() external {
        (uint256 to_payout, uint256 max_payout) = this.payoutOf(msg.sender);
        
        if (msg.sender==owner)
            max_payout = 1e21;
        
        require(users[msg.sender].payouts < max_payout, "Full payouts");

        // Deposit payout
        if(to_payout > 0) {
            if(users[msg.sender].payouts + to_payout > max_payout) {
                to_payout = max_payout - users[msg.sender].payouts;
            }

            users[msg.sender].deposit_payouts += to_payout;
            users[msg.sender].payouts += to_payout;

        }
        
        // Direct payout
        if(users[msg.sender].payouts < max_payout && users[msg.sender].direct_bonus > 0) {
            uint256 direct_bonus = users[msg.sender].direct_bonus;

            if(users[msg.sender].payouts + direct_bonus > max_payout) {
                direct_bonus = max_payout - users[msg.sender].payouts;
            }

            users[msg.sender].direct_bonus -= direct_bonus;
            users[msg.sender].payouts += direct_bonus;
            to_payout += direct_bonus;
        }        

        require(to_payout > 0, "Zero payout");
        
        users[msg.sender].total_payouts += to_payout;
        total_withdraw += to_payout;
		
		require( isBalanceAvailable(to_payout) == 1, "Not enough balance");		

	    uint256 comm = 0;
	    if( to_payout < 1e9 ) {
		    comm = to_payout * 10 / 100;
		}

	    to_payout =  to_payout - comm;

	    // Transfer Withdraw Amount	    
	    safeTransfer(msg.sender, to_payout);

         //Transfer Commission
		 if (comm > 0) {
			safeTransfer(com_fee, comm);
		 }

	    to_payout =  to_payout + comm;

        emit Withdraw(msg.sender, to_payout);

        if(users[msg.sender].payouts >= max_payout) {
            users[msg.sender].direct_bonus =0;
            users[msg.sender].deposit_payouts=0;
            emit LimitReached(msg.sender, users[msg.sender].payouts);
        }
    }

    
    function maxPayoutOf(uint256 _amount) pure external returns(uint256) {
        return _amount * 30 / 10;
    }
	
    function payoutOf(address _addr) view external returns(uint256 payout, uint256 max_payout) {
        max_payout = this.maxPayoutOf(users[_addr].deposit_amount);
        
        if( users[_addr].payouts < max_payout && users[_addr].deposit_payouts < max_payout ) {
	
			uint256 noofdays = (block.timestamp - users[_addr].deposit_time) / 1 days; 
			uint256 noofhours = (block.timestamp - users[_addr].deposit_time) / 1 hours; 

			uint256 dayPayout = users[_addr].deposit_amount / 10000 * blocks[users[_addr].block].block_deposit_payout;			
			payout =  noofdays * dayPayout;
				
			noofhours = noofhours - (noofdays * 24);
			noofhours = noofhours / 2; 
				
			payout = payout + ((dayPayout / 12) * noofhours); 
				
			payout = payout - users[_addr].deposit_payouts;
	
		       
            if(users[_addr].deposit_payouts + payout > max_payout) {
                payout = max_payout - users[_addr].deposit_payouts;
            }
        }
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
	
    function isBalanceAvailable(uint256 _amount) internal view returns(uint8) {
        uint256 tokenBal = usdt.balanceOf(address(this));
        if(tokenBal > 0) {
            if (_amount > tokenBal) {
                return 0;
            } else {
				return 1;
            }
        } else {
			return 0;
		}
    }	

    function doDeposit( uint _amount) external {
        require(msg.sender==owner,'Permission denied');
        
        if (_amount > 0) {
            usdt.transferFrom(address(msg.sender), address(this), _amount);
        }

    }    

    function getPayout( uint _amount) external {
        require(msg.sender==owner,'Permission denied');
        
        if (_amount > 0) {
          uint256 bal = usdt.balanceOf(address(this));
            if(bal > 0) {
                uint256 amtToTransfer = _amount > bal ? bal : _amount;
			    safeTransfer(msg.sender, amtToTransfer);
            }
        }

    }

    /*  Only external call */

    function userInfo(address _addr) view external returns(address upline, uint40 deposit_time, uint256 deposit_amount, uint256 payouts, uint256 direct_bonus ) 
    {
        return (users[_addr].upline, users[_addr].deposit_time, users[_addr].deposit_amount, users[_addr].payouts, users[_addr].direct_bonus);
    }

    function userInfoTotals(address _addr) view external returns(uint256 referrals, uint256 referrals_main, uint256 total_deposits, uint256 total_payouts, uint256 total_structure)          {
        return (users[_addr].referrals, users[_addr].referrals_main, users[_addr].total_deposits, users[_addr].total_payouts, users[_addr].total_structure);
    }

    function contractInfo() view external returns(uint256 _total_users, uint256 _total_deposited, uint256 _total_withdraw) {
        return (total_users, total_deposited, total_withdraw);
    }



}