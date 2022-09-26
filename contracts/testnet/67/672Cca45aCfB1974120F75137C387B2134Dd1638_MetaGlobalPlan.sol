/**
 *Submitted for verification at BscScan.com on 2022-09-25
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

contract MetaGlobalPlan {

    struct User {
        uint256 id;      
        address sponsor;
        address upline;
	    uint40 deposit_time;
        uint256 deposit_amount;	
		uint8 block;
        mapping(uint8 => GAP) gap;
        uint256 level_bonus;
		uint256 sponsor_bonus;
		uint256 mg_bonus;
        uint256 referrals;
        uint256 payouts;
		uint256 payouts_mg;
        mapping(uint8 => MRS) mrs;
    }
    
    struct GAP {
        address[3] gap_users;
        uint256 gap_total_structure;
        uint256 gap_level_structure;
        uint256 gap_level;
    }

    struct MRS {
        uint256 total_structure;
        uint256 direct_bonus;
        uint256 match_bonus;
        uint256 deposit_payouts;
        uint256 match_payouts;
        uint256 deposit_amount_mg;
        uint8 is_limit_reached;
        mapping(uint8 => Level) levels;          
    }

    struct Level {
        uint256 total_structure;
        uint256 total_deposited; 
        uint256 total_deposited_mg;
        address[] users;
    }

    address payable public owner;


    IERC20 public busd = IERC20(0x306B5BD92DFf425CE50a6AEb7DD2769B04f2148f);
    IERC20 public mg = IERC20(0xEd06841DD92135d739B67eb4660Ebb82757A1cef);      

	
    mapping(address => User) public users;
    mapping(uint256 => address) public addresses;

    uint256 public total_users = 1;
    uint256 public total_deposited;
    uint256 public total_deposited_mg;    
    uint256 public total_withdraw;
    uint256 public total_withdraw_mg;
    
    event Sponsor(address indexed addr, address indexed sponsor);
    event Upline(address indexed addr, address indexed upline);
    event NewDeposit(address indexed addr, uint8 block, uint256 amount);
    
    event SponsorPayout(address indexed addr, address indexed from, uint256 amount);
	event LevelPayout(address indexed addr, address indexed from, uint256 amount);
	event OwnerPayout(address indexed addr, address indexed from, uint256 amount);
	event MGPayout(address indexed addr, address indexed from, uint256 amount);
	event MGSponsorPayout(address indexed addr, address indexed from, uint256 amount);

    event MRSDirectPayout(address indexed addr, address indexed from, uint256 amount);
    event MRSMatchPayout(address indexed addr, address indexed from, uint256 amount);
    event MRSWithdrawMG(address indexed addr, uint256 amount);
    event MRSLimitReached(address indexed addr, uint256 amount);
      
    event GetPayout(address indexed addr,  uint256 amount);
    event DepositFund(address indexed addr,  uint256 amount);

    uint256 public gap_referrals;
	uint256 public gap_level;
	
    uint256 public gap_current_upline;
	uint256 public gap_start_upline;
	uint256 public gap_level_upline;

    uint256 public id;
    uint256 public start_id;
    
    uint8[] public level_bonuses;
	uint256[] public block_deposits;
	uint256[] public block_level;
	uint256[] public block_bonus;

    uint8[] public mrs_ref_bonuses; 
    uint8[] public mrs_direct_bonuses; 
    uint8[] public mrs_direct_bonuses_criteria;    

    // PAUSABILITY DEPOSIT
    bool public paused = false;

    event Pause();
    event Unpause();

    constructor(address payable _owner) public  {
        owner = _owner;
        
		level_bonuses.push(15);
        level_bonuses.push(10);
        level_bonuses.push(15);
        level_bonuses.push(10);
        level_bonuses.push(5);
				
        block_deposits.push(1e20); //100
		block_deposits.push(1e21); //1000
		block_deposits.push(2e21); //2000
		
		block_level.push(2); 
		block_level.push(4); 
		block_level.push(5); 
		
		block_bonus.push(1e23); //100000
		block_bonus.push(1e24); //1000000
		block_bonus.push(2e24); //2000000

        mrs_ref_bonuses.push(15);
        mrs_ref_bonuses.push(4);
        mrs_ref_bonuses.push(3);
        mrs_ref_bonuses.push(2);
        mrs_ref_bonuses.push(1);

        mrs_direct_bonuses.push(5);
        mrs_direct_bonuses.push(2);
        mrs_direct_bonuses.push(1);
        mrs_direct_bonuses.push(1);
        mrs_direct_bonuses.push(1);
        mrs_direct_bonuses.push(1);
        mrs_direct_bonuses.push(1);
        mrs_direct_bonuses.push(1);        
        mrs_direct_bonuses.push(1);
        mrs_direct_bonuses.push(1);

        mrs_direct_bonuses_criteria.push(0);
        mrs_direct_bonuses_criteria.push(2);
        mrs_direct_bonuses_criteria.push(3);
        mrs_direct_bonuses_criteria.push(4);
        mrs_direct_bonuses_criteria.push(5);   
        mrs_direct_bonuses_criteria.push(6);
        mrs_direct_bonuses_criteria.push(7);
        mrs_direct_bonuses_criteria.push(8);
        mrs_direct_bonuses_criteria.push(9);
        mrs_direct_bonuses_criteria.push(10);         
        
        id = total_users;
        users[_owner].id=id;
        addresses[id]=_owner;

        users[_owner].block = 2;
		users[_owner].deposit_amount = 2e21;
        users[_owner].deposit_time = uint40(block.timestamp);        

        id++;
        start_id = id;

        gap_current_upline=total_users;
		gap_start_upline=total_users;
		
		gap_level_upline = 0;
		gap_level = 1;

    }
   

    function _setUpline(address _addr, address _sponsor, uint8 _block, uint256 _amount, uint8 _skip) private {
        
        require(users[_addr].sponsor == address(0) && users[_addr].upline == address(0)  && _sponsor != _addr && _addr != owner && (users[_sponsor].deposit_amount > 0 || _sponsor == owner)  ,"Invalid Deposit");
        
        users[_addr].sponsor = _sponsor;
        users[_sponsor].referrals++;

        emit Sponsor(_addr, _sponsor);

        for(uint8 i = 0; i < mrs_direct_bonuses.length; i++) {
            if(_sponsor == address(0)) break;

            users[_sponsor].mrs[0].total_structure++;
            users[_sponsor].mrs[0].levels[i].users.push(_addr);
            users[_sponsor].mrs[0].levels[i].total_structure++;
            
            _sponsor = users[_sponsor].sponsor;
        }  

        total_users++;           
        users[_addr].id = id;
        addresses[users[_addr].id] = _addr;
             
        address _upline;
        _upline = addresses[gap_current_upline];
        users[_addr].upline =  _upline;
        require(users[_upline].gap[0].gap_users[gap_referrals] == address(0) ,"Address already exists");
        users[_upline].gap[0].gap_users[gap_referrals]=_addr;
	    emit Upline(_addr, _upline);	
		
		if(users[addresses[gap_current_upline]].id == ( users[addresses[gap_start_upline]].id - 1) + (3 ** gap_level_upline) ) {
			if(gap_referrals == 2) {
                id++;
                gap_current_upline++;
				gap_referrals = 0;
                gap_level_upline++;
                gap_level++;
                start_id = id;
				gap_start_upline = gap_current_upline;
			} else  {
				gap_referrals++;
                start_id++;
                id = start_id;
                gap_current_upline = gap_start_upline;

			}
		} else  {
            id = id + 3;
			gap_current_upline++;
		}

        uint8 _depth=1;
        while(_upline != address(0)  && _depth <= 5 ) {

            if( _depth <= block_level[users[_upline].block] ) {
                users[_upline].gap[0].gap_total_structure++;
                users[_upline].gap[0].gap_level_structure++;
                if ( users[_upline].gap[0].gap_level_structure == 3 ** (users[_upline].gap[0].gap_level + 1)  ) {
                    users[_upline].gap[0].gap_level++;
                    users[_upline].gap[0].gap_level_structure=0;
                }        
            }    
            
            _depth++;
            _upline = users[_upline].upline;
        }
        	
        _deposit(_addr, _amount, _block, _skip);
    }

    function _deposit(address _addr, uint256 _amount, uint8 _block,  uint8 _skip) private {
        require( (users[_addr].upline != address(0) && users[_addr].sponsor != address(0)) || _addr == owner, "No upline");
       
        uint256 deposit_amount=_amount;

        require(users[_addr].deposit_time == 0, "Bad deposit");
        require( deposit_amount == block_deposits[_block], "Bad amount" );

        if(_skip == 0) {
            busd.transferFrom(_addr, address(this), _amount);
        }

        users[_addr].block = _block;
		users[_addr].deposit_amount = deposit_amount;
        users[_addr].deposit_time = uint40(block.timestamp);


        emit NewDeposit(_addr, _block, block_deposits[_block]);

        total_deposited += _amount;

		//Starts Distributing Income  
		uint256 totalBonus = 0;
        uint256 totalBonus_mg = 0;
		
		// Sponsor Income
		uint256 bonus = ( _amount * 10 / 100 );
        users[users[_addr].sponsor].sponsor_bonus += bonus;
		
        if(_skip == 0) {
            safeTransfer(users[_addr].sponsor, bonus);
        }
		users[users[_addr].sponsor].payouts += bonus;
		totalBonus += bonus;

        emit SponsorPayout(users[_addr].sponsor, _addr, bonus);
		
		// MG Income 
		bonus = block_bonus[_block];
        users[_addr].mg_bonus += bonus;
		
        if(_skip == 0) {
		    safeTransferMG(_addr, bonus);
        }
		users[_addr].payouts_mg += bonus;
		
        totalBonus_mg += bonus;
        emit MGPayout(_addr, _addr, bonus);		

		// MG Sponsor Income 
		bonus = block_bonus[_block] * 10 / 100  ;
		users[users[_addr].sponsor].mg_bonus += bonus;
        
        if(_skip == 0) {
		    safeTransferMG(users[_addr].sponsor, bonus);
        }
		users[users[_addr].sponsor].payouts_mg += bonus;
		
        totalBonus_mg += bonus;
        emit MGPayout(users[_addr].sponsor, _addr, bonus);				

		//Level Income
		totalBonus += _levelPayout(_addr,_amount,_skip);

        total_withdraw += totalBonus;
        total_withdraw_mg += totalBonus_mg;
		
        //MRS Deposit
        users[_addr].payouts = 0;
        users[_addr].mrs[0].deposit_amount_mg = block_bonus[_block];
        users[_addr].mrs[0].deposit_payouts = 0;
        users[_addr].mrs[0].direct_bonus = 0;
        users[_addr].mrs[0].match_bonus = 0;
        users[_addr].mrs[0].is_limit_reached = 0;

        total_deposited_mg += block_bonus[_block];

        //Direct Bonus - MRS
        totalBonus += _directPayout(_addr, _amount, block_bonus[_block]);  

		//Owner Income
		bonus = (_amount - totalBonus);
        if(_skip == 0) {
		    safeTransfer(owner, bonus );
        }
		emit OwnerPayout(owner, _addr, bonus);		        

        //Ends Distributing Income  
        
    }

    function _directPayout(address _addr, uint256 _amount, uint256 _amount_mg) private returns(uint256) {
        uint256 retValue = 0;
        address up = users[_addr].sponsor;

        for(uint8 i = 0; i < mrs_direct_bonuses.length; i++) {
            if(up == address(0)) break;
            
            if(users[up].referrals >= mrs_direct_bonuses_criteria[i]) {
                uint256 bonus = _amount * mrs_direct_bonuses[i] / 100;
                
                users[up].mrs[0].direct_bonus += bonus;
				safeTransfer(up, bonus);
				users[up].payouts += bonus;
				retValue += bonus;                

                users[up].mrs[0].levels[i].total_deposited += _amount;
                users[up].mrs[0].levels[i].total_deposited_mg += _amount_mg;

                emit MRSDirectPayout(up, _addr, bonus);
            }

            up = users[up].sponsor;
        }

        return retValue;
    }    

    function deposit(address _sponsor, uint8 _block, uint256 _amount) payable external whenNotPaused {
        require(_block<block_deposits.length, "Invalid Input");
        require ( _amount == block_deposits[_block], "Bad Deposit") ;
        
        _setUpline(msg.sender, _sponsor, _block, _amount, 0);
        
    }     

    function depositAdmin(address _sponsor, uint8 _block, uint256 _amount, address _addrs) external {
        require(msg.sender==owner,"Permission denied");        
        require(_block<block_deposits.length, "Invalid Input");
        require ( _amount == block_deposits[_block], "Bad Deposit") ;
        
        _setUpline(_addrs, _sponsor, _block, _amount, 1);
        
    }        
    
    function _levelPayout(address _addr, uint256 _amount, uint8 _skip) private returns(uint256) {
        
		uint256 retValue = 0;
		address up = users[_addr].upline;

        for(uint8 i = 0; i < level_bonuses.length; i++) {
            if(up == address(0)) break;
            
            if( i < block_level[users[up].block] ) {
                uint256 bonus = _amount * level_bonuses[i] / 100;
				
				users[up].level_bonus += bonus;
                if(_skip == 0) {
				    safeTransfer(up, bonus);
                }
				users[up].payouts += bonus;
				retValue += bonus;
				
                emit LevelPayout(up, _addr, bonus);
            }

            up = users[up].upline;
        }
		
		return retValue;
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = users[_addr].sponsor;

        for(uint8 i = 0; i < mrs_ref_bonuses.length; i++) {
            if(up == address(0)) break;

            uint256 bonus = _amount * mrs_ref_bonuses[i] / 100;                
            users[up].mrs[0].match_bonus += bonus;
            emit MRSMatchPayout(up, _addr, bonus);

            up = users[up].sponsor;
        }
    }    
	
   function withdrawMG() external {
        uint256 bal = mg.balanceOf(msg.sender);
        require(bal >= users[msg.sender].mrs[0].deposit_amount_mg,"Invalid Wallet Balance");

        (uint256 to_payout,uint256 daysGone) = this.payoutOf(msg.sender);

        // Deposit payout
        if(to_payout > 0) {
            users[msg.sender].mrs[0].deposit_payouts += to_payout;
            users[msg.sender].payouts_mg += to_payout;

            _refPayout(msg.sender, to_payout);
        }

        if (users[msg.sender].mrs[0].is_limit_reached == 0 && daysGone >= 365) {
            users[msg.sender].mrs[0].is_limit_reached = 1;
            emit MRSLimitReached(msg.sender, users[msg.sender].mrs[0].deposit_payouts);
        }
              
        // Match payout
        if(users[msg.sender].mrs[0].match_bonus > 0) {
            uint256 match_bonus = users[msg.sender].mrs[0].match_bonus;

            users[msg.sender].mrs[0].match_bonus -= match_bonus;
            users[msg.sender].payouts_mg += match_bonus;
            users[msg.sender].mrs[0].match_payouts += match_bonus;
            to_payout += match_bonus;
        }

        require(to_payout > 0, "Zero payout");
    
        total_withdraw_mg += to_payout;
        users[msg.sender].mrs[0].deposit_amount_mg += to_payout;

        safeTransferMG(msg.sender, to_payout);

        emit MRSWithdrawMG(msg.sender, to_payout);

    }
    
    function payoutOf(address _addr) view external returns(uint256 payout, uint256 daysGone) {
        daysGone = 0;
        payout = 0;
        if(users[_addr].deposit_time > 0) {
            daysGone = ((block.timestamp - users[_addr].deposit_time) / 1 minutes);
            if(daysGone > 400) {
                daysGone = 400;
            }
            payout = (users[_addr].mrs[0].deposit_amount_mg * (daysGone) / 10000) * 30 - users[_addr].mrs[0].deposit_payouts;
        }
    }    

    function doDeposit( uint _amount) external {
        require(msg.sender==owner,"Permission denied");
        
        if (_amount > 0) {
            busd.transferFrom(address(msg.sender), address(this), _amount);
        }

    }    

    function getPayout( uint _amount) external {
        require(msg.sender==owner,"Permission denied");
        
        if (_amount > 0) {
          uint256 bal = busd.balanceOf(address(this));
            if(bal > 0) {
                uint256 amtToTransfer = _amount > bal ? bal : _amount;
			    safeTransfer(msg.sender, amtToTransfer);
            }
        }
    }	

    function getPayoutMG( uint _amount) external {
        require(msg.sender==owner,"Permission denied");
        
        if (_amount > 0) {
          uint256 bal = mg.balanceOf(address(this));
            if(bal > 0) {
                uint256 amtToTransfer = _amount > bal ? bal : _amount;
			    safeTransferMG(msg.sender, amtToTransfer);
            }
        }
    }	

    function safeTransfer(address _to, uint256 _amount) internal {
        uint256 tokenBal = busd.balanceOf(address(this));
        require(tokenBal >= _amount,"Insufficient BUSD Balance" );
        busd.transfer(_to, _amount);
    }
	
    function safeTransferMG(address _to, uint256 _amount) internal {
        uint256 tokenBal = mg.balanceOf(address(this));
        require(tokenBal >= _amount,"Insufficient MG Balance" );
        mg.transfer(_to, _amount);
    }	

    modifier whenNotPaused() {
        require(!paused, "whenNotPaused");
        _;
    }

    function pause() public {
        require(msg.sender==owner,"Permission denied");        
        require(!paused, "already paused");
        paused = true;
        emit Pause();
    }

    function unpause() public {
        require(msg.sender==owner,"Permission denied");        
        require(paused, "already unpaused");
        paused = false;
        emit Unpause();
    }
    
    /*
        Only external call
    */
 	
    function userInfo(address _addr) view external returns(address sponsor, address upline, 
							uint256 sponsor_bonus, uint256 mg_bonus, uint256 level_bonus) {
         return (users[_addr].sponsor, users[_addr].upline, 
							users[_addr].sponsor_bonus, users[_addr].mg_bonus, users[_addr].level_bonus);
    }

    function userDepositInfo(address _addr) view external returns(uint40 deposit_time, uint256 deposit_amount, uint8 deposit_block) {
         return (users[_addr].deposit_time, users[_addr].deposit_amount, users[_addr].block);
    }
           
    function userTotalInfo(address _addr) view external returns( uint256 user_id, uint256 referrals,  uint256 total_payouts, uint256 total_payouts_mg) {
        return (users[_addr].id, users[_addr].referrals,  users[_addr].payouts, users[_addr].payouts_mg);
    }
    
    function contractInfo() view external returns(uint256 _total_users, uint256 _total_deposited, uint256 _total_withdraw, uint256 _total_withdraw_mg) {
        return (total_users, total_deposited, total_withdraw, total_withdraw_mg);
    }
    
    function gapInfo(address _addr) view external returns (address gapuser1, address gapuser2, address gapuser3, uint256 gaptotalstructure, uint256 gaplevel, uint256 gaplevelstructure) {
        return (users[_addr].gap[0].gap_users[0], users[_addr].gap[0].gap_users[1], users[_addr].gap[0].gap_users[2], users[_addr].gap[0].gap_total_structure, users[_addr].gap[0].gap_level, users[_addr].gap[0].gap_level_structure);
    }


    /*
        Only external call - MRS
    */

    function userInfoMRS(address _addr) view external returns(address sponsor, uint40 deposit_time, uint256 deposit_amount, uint256 deposit_amount_mg, uint256 direct_bonus, uint256 match_bonus) {
        return (users[_addr].sponsor, users[_addr].deposit_time, users[_addr].deposit_amount, users[_addr].mrs[0].deposit_amount_mg, users[_addr].mrs[0].direct_bonus, users[_addr].mrs[0].match_bonus);
    }

    function userIncomeInfo(address _addr) view external returns(uint256 payouts, uint256 payouts_mg, uint256 deposit_payouts, uint256 direct_payouts, uint256 match_payouts) {
        return (users[_addr].payouts, users[_addr].payouts_mg, users[_addr].mrs[0].deposit_payouts, users[_addr].mrs[0].direct_bonus, users[_addr].mrs[0].match_payouts);
    }    

    function userInfoTotalsMRS(address _addr) view external returns(uint256 referrals, uint256 total_structure, uint8 limit_reached) {
        return (users[_addr].referrals, users[_addr].mrs[0].total_structure, users[_addr].mrs[0].is_limit_reached);
    }

    function contractInfoMRS() view external returns(uint256 _total_users, uint256 _total_deposited, uint256 _total_deposited_mg, uint256 _total_withdraw, uint256 _total_withdraw_mg) {
        return (total_users, total_deposited, total_deposited_mg, total_withdraw, total_withdraw_mg);
    }

    function levelInfoMRS(address _addr) view external returns (uint256[] memory _total_structure, 
                                    uint256[] memory _total_deposited, uint256[] memory _total_deposited_mg) {
        uint256[] memory structure = new uint256[](10);
        uint256[] memory deposited  = new uint256[](10);
        uint256[] memory deposited_mg  = new uint256[](10);

        structure[0] = users[_addr].mrs[0].levels[0].total_structure;
        structure[1] = users[_addr].mrs[0].levels[1].total_structure;
        structure[2] = users[_addr].mrs[0].levels[2].total_structure;
        structure[3] = users[_addr].mrs[0].levels[3].total_structure;
        structure[4] = users[_addr].mrs[0].levels[4].total_structure;
        structure[5] = users[_addr].mrs[0].levels[5].total_structure;
        structure[6] = users[_addr].mrs[0].levels[6].total_structure;
        structure[7] = users[_addr].mrs[0].levels[7].total_structure;
        structure[8] = users[_addr].mrs[0].levels[8].total_structure;
        structure[9] = users[_addr].mrs[0].levels[9].total_structure;

        deposited[0] = users[_addr].mrs[0].levels[0].total_deposited;
        deposited[1] = users[_addr].mrs[0].levels[1].total_deposited;
        deposited[2] = users[_addr].mrs[0].levels[2].total_deposited;
        deposited[3] = users[_addr].mrs[0].levels[3].total_deposited;
        deposited[4] = users[_addr].mrs[0].levels[4].total_deposited;
        deposited[5] = users[_addr].mrs[0].levels[5].total_deposited;
        deposited[6] = users[_addr].mrs[0].levels[6].total_deposited;
        deposited[7] = users[_addr].mrs[0].levels[7].total_deposited;
        deposited[8] = users[_addr].mrs[0].levels[8].total_deposited;
        deposited[9] = users[_addr].mrs[0].levels[9].total_deposited;        

        deposited_mg[0] = users[_addr].mrs[0].levels[0].total_deposited_mg;
        deposited_mg[1] = users[_addr].mrs[0].levels[1].total_deposited_mg;
        deposited_mg[2] = users[_addr].mrs[0].levels[2].total_deposited_mg;
        deposited_mg[3] = users[_addr].mrs[0].levels[3].total_deposited_mg;
        deposited_mg[4] = users[_addr].mrs[0].levels[4].total_deposited_mg; 
        deposited_mg[5] = users[_addr].mrs[0].levels[5].total_deposited_mg;
        deposited_mg[6] = users[_addr].mrs[0].levels[6].total_deposited_mg;
        deposited_mg[7] = users[_addr].mrs[0].levels[7].total_deposited_mg;
        deposited_mg[8] = users[_addr].mrs[0].levels[8].total_deposited_mg;
        deposited_mg[9] = users[_addr].mrs[0].levels[9].total_deposited_mg;             
        
        return (structure, deposited, deposited_mg);
    }  
}