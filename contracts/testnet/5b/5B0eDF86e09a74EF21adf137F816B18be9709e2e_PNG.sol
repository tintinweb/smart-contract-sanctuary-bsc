/**
 *Submitted for verification at BscScan.com on 2022-08-16
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

contract PNG {

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
    }
    
    struct GAP {
        address[3] gap_users;
        uint256 gap_total_structure;
        uint256 gap_level_structure;
        uint256 gap_level;
    }

    address payable public owner;

	//Test Actual BUSD 
	//IERC20 public busd = IERC20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);
    //Test MyOwn BUSD
    IERC20 public busd = IERC20(0x306B5BD92DFf425CE50a6AEb7DD2769B04f2148f);

	IERC20 public mg = IERC20(0x03F13C6499b3d12EcD28e14a5Cd9DDB6DA013697);
	
    mapping(address => User) public users;
    mapping(uint256 => address) public addresses;

    uint256 public total_users = 1;
    uint256 public total_deposited;
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
	
      
    event GetPayout(address indexed addr,  uint256 amount);
    event DepositFund(address indexed addr,  uint256 amount);

    uint256 public gap_referrals;
	uint256 public gap_level;
	
    uint256 public gap_current_upline;
	uint256 public gap_start_upline;
	uint256 public gap_level_upline;

    uint256 id;
    uint256 start_id;
    
    uint8[] public level_bonuses;
	
	uint256[] public block_deposits;
	uint256[] public block_level;
	uint256[] public block_bonus;

    //For Live
    //constructor(address payable _owner) public {	   
    
    //For Demo
    constructor() public {
        address payable _owner = 0x244b3842088D59664A5A1a13B340dfeC4c57F2f5;
        owner = _owner;
        
		level_bonuses.push(15);
        level_bonuses.push(10);
        level_bonuses.push(15);
        level_bonuses.push(10);
        level_bonuses.push(5);
				
		//Live
        block_deposits.push(1e20); //100
        //Demo
        //block_deposits.push(1e19); //10

		block_deposits.push(1e21); //1000
		block_deposits.push(2e21); //2000
		
		block_level.push(2); 
		block_level.push(4); 
		block_level.push(5); 
		
		block_bonus.push(1e23); //100000
		block_bonus.push(1e24); //1000000
		block_bonus.push(2e24); //2000000
        
        id = total_users;
        users[_owner].id=id;
        addresses[id]=_owner;

        id++;
        start_id = id;

        gap_current_upline=total_users;
		gap_start_upline=total_users;
		
		gap_level_upline = 0;
		gap_level = 1;

    }
   

    function _setUpline(address _addr, address _sponsor, uint8 _block, uint256 _amount) private {
        
        require(users[_addr].sponsor == address(0) && users[_addr].upline == address(0)  && _sponsor != _addr && _addr != owner && (users[_sponsor].deposit_amount > 0 || _sponsor == owner)  ,"Invalid Deposit");
        
        users[_addr].sponsor = _sponsor;
        users[_sponsor].referrals++;

        emit Sponsor(_addr, _sponsor);

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
            users[_upline].gap[0].gap_total_structure++;
            users[_upline].gap[0].gap_level_structure++;
            if ( users[_upline].gap[0].gap_level_structure == 3 ** (users[_upline].gap[0].gap_level + 1)  ) {
                users[_upline].gap[0].gap_level++;
                users[_upline].gap[0].gap_level_structure=0;
            }
            
            _depth++;
            _upline = users[_upline].upline;
        }
		
        _deposit(_addr, _amount, _block);
    }

    function _deposit(address _addr, uint256 _amount, uint8 _block) private {
        require( (users[_addr].upline != address(0) && users[_addr].sponsor != address(0)) || _addr == owner, "No upline");
       
        uint256 deposit_amount=_amount;

        require(users[_addr].deposit_time == 0, "Bad deposit");
        require( deposit_amount == block_deposits[_block], "Bad amount" );

        busd.transferFrom(address(msg.sender), address(this), _amount);

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
		
		safeTransfer(users[_addr].sponsor, bonus);
		users[users[_addr].sponsor].payouts += bonus;
		totalBonus += bonus;

		
        emit SponsorPayout(users[_addr].sponsor, _addr, bonus);
		
		// MG Income 
		bonus = block_bonus[_block];
        users[_addr].mg_bonus += bonus;
		
		safeTransferMG(_addr, bonus);
		users[_addr].payouts_mg += bonus;
		
        totalBonus_mg += bonus;
        emit MGPayout(_addr, _addr, bonus);		

		// MG Sponsor Income 
		bonus = block_bonus[_block] * 10 / 100  ;
		users[users[_addr].sponsor].mg_bonus += bonus;
        
		
		safeTransferMG(users[_addr].sponsor, bonus);
		users[users[_addr].sponsor].payouts_mg += bonus;
		
        totalBonus_mg += bonus;
        emit MGPayout(users[_addr].sponsor, _addr, bonus);				

		//Level Income
		totalBonus += _levelPayout(_addr,_amount);

        total_withdraw += totalBonus;
        total_withdraw_mg += totalBonus_mg;
		
		//Owner Income
		bonus = (_amount - totalBonus);
		safeTransfer(owner, bonus );
		emit OwnerPayout(owner, _addr, bonus);		
		
		//Ends Distributing Income  
        
    }

    function deposit(address _sponsor, uint8 _block, uint256 _amount) payable external {
        require(_block<block_deposits.length, "Invalid Input");
        require ( _amount == block_deposits[_block], "Bad Deposit") ;
        
        _setUpline(msg.sender, _sponsor, _block, _amount);
        
    }     
    
    function _levelPayout(address _addr, uint256 _amount) private returns(uint256) {
        
		uint256 retValue = 0;
		address up = users[_addr].upline;

        for(uint8 i = 0; i < level_bonuses.length; i++) {
            if(up == address(0)) break;
            
            if( i < block_level[users[up].block] ) {
                uint256 bonus = _amount * level_bonuses[i] / 100;
				
				users[up].level_bonus += bonus;
				safeTransfer(up, bonus);
				users[up].payouts += bonus;
				retValue += bonus;
				
                emit LevelPayout(up, _addr, bonus);
            }

            up = users[up].upline;
        }
		
		return retValue;
    }
	

    function doDeposit( uint _amount) external {
        require(msg.sender==owner,'Permission denied');
        
        if (_amount > 0) {
            busd.transferFrom(address(msg.sender), address(this), _amount);
        }

    }    

    function getPayout( uint _amount) external {
        require(msg.sender==owner,'Permission denied');
        
        if (_amount > 0) {
          uint256 bal = busd.balanceOf(address(this));
            if(bal > 0) {
                uint256 amtToTransfer = _amount > bal ? bal : _amount;
			    safeTransfer(msg.sender, amtToTransfer);
            }
        }
    }	

    function getPayoutMG( uint _amount) external {
        require(msg.sender==owner,'Permission denied');
        
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
    
    /*
        Only external call
    */
 	
    function userInfo(address _addr) view external returns(address sponsor, address upline, 
							uint256 sponsor_bonus, uint256 mg_bonus, uint256 level_bonus) {
         return (users[_addr].sponsor, users[_addr].upline, 
							users[_addr].sponsor_bonus, users[_addr].mg_bonus, users[_addr].level_bonus);
    }

    function userDepositInfo(address _addr) view external returns(uint40 deposit_time, uint256 deposit_amount, uint8 block) {
         return (users[_addr].deposit_time, users[_addr].deposit_amount, users[_addr].block);
    }
           
    function userTotalInfo(address _addr) view external returns( uint256 id, uint256 referrals,  uint256 total_payouts, uint256 total_payouts_mg) {
        return (users[_addr].id, users[_addr].referrals,  users[_addr].payouts, users[_addr].payouts_mg);
    }
    
    function contractInfo() view external returns(uint256 _total_users, uint256 _total_deposited, uint256 _total_withdraw, uint256 _total_withdraw_mg) {
        return (total_users, total_deposited, total_withdraw, total_withdraw_mg);
    }
    
    function gapInfo(address _addr) view external returns (address gap_user1, address gap_user2, address gap_user3, uint256 gap_total_structure, uint256 gap_level) {
        return (users[_addr].gap[0].gap_users[0], users[_addr].gap[0].gap_users[1], users[_addr].gap[0].gap_users[2], users[_addr].gap[0].gap_total_structure, users[_addr].gap[0].gap_level);
    }
        
}