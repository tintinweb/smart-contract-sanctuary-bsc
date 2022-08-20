/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

/**
 *Submitted for verification at BscScan.com on 2021-05-14
*/

pragma solidity 0.8.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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

contract PrimeReflux{
    IBEP20 internal busd_token;
    using SafeMath for uint256;
    address internal service_wallet;
    uint256 internal service_wallet_bal;
    
    uint256 public deposit_id;
    uint256 public total_deposits;
    uint256 public current_balance;
	uint256 public can_transfer_balance;
    uint256 public total_members;
    
    
    struct CData{
        
        
        uint8 MATCHING_LEVELS;
    	uint8 REFERRALS_REQ_FOR_MATCHING;
    	
    	uint8 REFERRALS_REQ_FOR_BUSINESS;
    	
    	uint8 JOINING_MAINTENANCE_FEE;
    	uint8 JOINING_DISTRIBUTION_PER;
    	
    	uint8 PAYOUT_MAINTENANCE_FEE;
    	uint8 PAYOUT_DISTRIBUTION_PER;
    	
    	uint8 DIRECT_DIS_PER;
    	uint8 MATCHING_DIS_PER;
    	
    	uint256 JOINING_FEE;
    	
    	uint256[10] ENTRY_FEE;

    }
    
    struct Member{
        bool direct_income_distributed;
	    uint256 total_referrals;
        uint256 joined_at;
	    uint256 current_balance;
	    uint256 total_withdraw_amt;
	    uint256 last_withdraw_amt;
	    uint256 last_withdraw_at;
	    uint256 total_deposit_amt;
	    uint256 last_deposit_id;
	    uint256 m_id;
	    uint256 m_sp_id;
	    address mw_address;
	    
    }
   
	struct Deposits{
	    uint256 member_id;
	    string deposit_type;
	    uint8 entry_fee_id;
	    uint256 amount;
	    uint256 depostited_at;
	}

   CData public contract_data;
	
	mapping(address => uint256) public  users_index;
	mapping(uint256 => Member) public users;
	mapping(address => bool) public registered;
	mapping(uint256 => Deposits) public deposits;
	mapping(uint256 => bool) public payouts;
	mapping(uint256 => uint256[]) public referrals;
    mapping(address => uint256[]) public userDepositeIds;
     
	 
	
	event Deposit(address indexed _from, uint256 _id, uint256 _value);
    event Withdraw(address indexed _by, uint256 _id, uint256 _value);
	
	constructor(address _token_address ){
	    busd_token = IBEP20(_token_address);
        service_wallet=msg.sender;
        
        deposit_id=0;
        total_deposits=0;
        current_balance=0;
        
        total_members=0;
        service_wallet_bal=0;
        
        contract_data.MATCHING_LEVELS=10;
    	contract_data.REFERRALS_REQ_FOR_MATCHING=2;
    	
    	contract_data.REFERRALS_REQ_FOR_BUSINESS=2;
    	
    	contract_data.JOINING_MAINTENANCE_FEE=0;
    	contract_data.JOINING_DISTRIBUTION_PER=100;
    	
    	contract_data.PAYOUT_MAINTENANCE_FEE=2;
    	contract_data.PAYOUT_DISTRIBUTION_PER=98;
    	
    	contract_data.DIRECT_DIS_PER=50;
    	contract_data.MATCHING_DIS_PER=5;
    	
    	contract_data.JOINING_FEE=30e18;
	    contract_data.ENTRY_FEE[0]=30e18;
	    contract_data.ENTRY_FEE[1]=600e18;
	    contract_data.ENTRY_FEE[2]=630e18;
	    contract_data.ENTRY_FEE[3]=2000e18;
	}
	
	function init_con(uint8 _mathing_level,uint8 _ref_req_for_matching,uint8 _ref_req_for_biz,uint8 _joining_m_fee,uint8 _joining_d_per,uint8 _payout_m_fee,uint8 _payout_d_per,uint8 _direct_dis_per,uint8 _matching_dis_per,uint256 _joining_fee) external returns(bool)
	{
	    require(msg.sender==service_wallet, "Invalid request.");
	    contract_data.MATCHING_LEVELS=_mathing_level;
    	contract_data.REFERRALS_REQ_FOR_MATCHING=_ref_req_for_matching;
    	
    	contract_data.REFERRALS_REQ_FOR_BUSINESS=_ref_req_for_biz;
    	
    	contract_data.JOINING_MAINTENANCE_FEE=_joining_m_fee;
    	contract_data.JOINING_DISTRIBUTION_PER=_joining_d_per;
    	
    	contract_data.PAYOUT_MAINTENANCE_FEE=_payout_m_fee;
    	contract_data.PAYOUT_DISTRIBUTION_PER=_payout_d_per;
    	
    	contract_data.DIRECT_DIS_PER=_direct_dis_per;
    	contract_data.MATCHING_DIS_PER=_matching_dis_per;
    	
    	contract_data.JOINING_FEE=_joining_fee;
    	
    	
	 return true;   
	}
	
	function init_entry_fee(uint8 _index,uint256 _entry_fee) external returns(bool)
	{
	    require(msg.sender==service_wallet, "Invalid request.");
	    require(_index>0, "Invalid request.");
	    require(_index-1<10, "Invalid request.");
	    require(_entry_fee>0, "Invalid request.");

    	contract_data.ENTRY_FEE[_index-1]=_entry_fee;
	 return true;   
	}
	    
	
	
    modifier isRegistered(bool requirement) {
        if(requirement==false)
        require(registered[msg.sender] == requirement, "Already Registered");
        else
        require(registered[msg.sender] == requirement, "Not Registered");
        _;
    }

    function investorDepositeIds(address investor)
        external
        view
        returns (uint256[] memory ids)
    {
        uint256[] memory arr = userDepositeIds[investor];
        return arr;
    }
    
    
    function Join(address referrer_user)  external isRegistered(false) returns(uint256)
    {        
        require(registered[msg.sender]==false, "Already registered.");
        
        uint256 referrer_index=0;
        if(total_members>0)
        {
            require(registered[referrer_user]==true, "Invalid referrer id.");
            referrer_index=users_index[referrer_user];
        }
        
        busd_token.transferFrom(msg.sender, address(this), contract_data.JOINING_FEE);
        total_members=total_members.add(1);
        
        Deposits memory deposit_new;
        deposit_id=deposit_id.add(1);
        
    	deposit_new.member_id=total_members;
    	deposit_new.deposit_type="Joining Fee";
    	deposit_new.entry_fee_id=0;
    	deposit_new.amount=contract_data.JOINING_FEE;
    	deposit_new.depostited_at=block.timestamp;
    	
        deposits[deposit_id]=deposit_new;
        userDepositeIds[msg.sender].push(deposit_id);
        
        registered[msg.sender]=true;
        
        users_index[msg.sender]=total_members;
        
        Member memory mem_new;
        
        mem_new.direct_income_distributed=false;
	    mem_new.total_referrals=0;
        mem_new.joined_at=block.timestamp;
	    mem_new.current_balance=0;
	    mem_new.total_withdraw_amt=0;
	    mem_new.last_withdraw_amt=0;
	    mem_new.last_withdraw_at=block.timestamp;
	    mem_new.total_deposit_amt=mem_new.total_deposit_amt.add(contract_data.JOINING_FEE);
	    mem_new.last_deposit_id=deposit_id;
	    mem_new.m_id=total_members;
	    mem_new.m_sp_id=referrer_index;
	    mem_new.mw_address=msg.sender;
	    
        users[total_members]=mem_new;
        
        total_deposits=total_deposits.add(contract_data.JOINING_FEE);
		uint8 d_count=0;
       
       
        
        
       
        uint256 direct_income=(((contract_data.JOINING_FEE.mul(contract_data.DIRECT_DIS_PER)).mul(contract_data.JOINING_DISTRIBUTION_PER)).div(100)).div(100);
        uint256 level_income=(((contract_data.JOINING_FEE.mul(contract_data.MATCHING_DIS_PER)).mul(contract_data.JOINING_DISTRIBUTION_PER)).div(100)).div(100);
        
        if(contract_data.JOINING_MAINTENANCE_FEE>0)
        {
            uint256 joining_charges=contract_data.JOINING_FEE.mul(contract_data.JOINING_MAINTENANCE_FEE).div(100);
            busd_token.transfer(service_wallet,joining_charges);
        }
        
       
        uint256 total_distributed=0;
        
        if(referrer_index>0)
        {
            
            
           referrals[referrer_index].push(total_members);
           
           
           users[referrer_index].total_referrals=users[referrer_index].total_referrals.add(1);
           
       
           busd_token.transfer(users[referrer_index].mw_address,direct_income);
            total_distributed=total_distributed.add(direct_income);
        
            users[referrer_index].total_withdraw_amt=users[referrer_index].total_withdraw_amt.add(direct_income);
    	    users[referrer_index].last_withdraw_amt=direct_income;
    	   users[referrer_index].last_withdraw_at=block.timestamp;
	        
	        
          referrer_index=users[referrer_index].m_sp_id;
       
        }
        
       
       
       while(d_count<contract_data.MATCHING_LEVELS && referrer_index>0)
       {
           if(referrer_index>0)
           {
               if(users[referrer_index].total_referrals>=2)
               {
                    busd_token.transfer(users[referrer_index].mw_address,level_income);
                     total_distributed=total_distributed.add(level_income);
                     
                        users[referrer_index].total_withdraw_amt=users[referrer_index].total_withdraw_amt.add(level_income);
                	    users[referrer_index].last_withdraw_amt=level_income;
                	   users[referrer_index].last_withdraw_at=block.timestamp;
            	        
            	       
                      referrer_index=users[referrer_index].m_sp_id;
                    d_count++; 
                     
               }
               else{
                   referrer_index=users[referrer_index].m_sp_id;
               }
           }
       }
       
       
       if((direct_income.add(level_income.mul(contract_data.MATCHING_LEVELS)))>total_distributed)
       {
           busd_token.transfer(service_wallet,(direct_income.add(level_income.mul(contract_data.MATCHING_LEVELS))).sub(total_distributed));
       }
       
       users[total_members].direct_income_distributed=true;
       
        return total_members;
    }
    
    function Join_OReq(address user_address, address referrer_user) external returns(uint256)
    {
        require(msg.sender==service_wallet, "Invalid request.");
        
        require(registered[msg.sender]==false, "Already registered.");
        
        uint256 referrer_index=0;
        if(total_members>0)
        {
            require(registered[referrer_user]==true, "Invalid referrer id.");
            referrer_index=users_index[referrer_user];
        }
        
        busd_token.transferFrom(user_address, address(this), contract_data.JOINING_FEE);
	
    	total_members=total_members.add(1);
        
        Deposits memory deposit_new;
        deposit_id=deposit_id.add(1);

        

    	deposit_new.member_id=total_members;
    	deposit_new.deposit_type="Joining Fee";
    	deposit_new.entry_fee_id=0;
    	deposit_new.amount=contract_data.JOINING_FEE;
    	deposit_new.depostited_at=block.timestamp;
    	
        deposits[deposit_id]=deposit_new;
        userDepositeIds[msg.sender].push(deposit_id);
        
        registered[user_address]=true;
        
        
       
        users_index[user_address]=total_members;
        
        Member memory mem_new;
        
        mem_new.direct_income_distributed=false;
	    mem_new.total_referrals=0;
        mem_new.joined_at=block.timestamp;
	    mem_new.current_balance=0;
	    mem_new.total_withdraw_amt=0;
	    mem_new.last_withdraw_amt=0;
	    mem_new.last_withdraw_at=block.timestamp;
	    mem_new.total_deposit_amt=mem_new.total_deposit_amt.add(contract_data.JOINING_FEE);
	    mem_new.last_deposit_id=deposit_id;
	    mem_new.m_id=total_members;
	    mem_new.m_sp_id=referrer_index;
	    mem_new.mw_address=user_address;
	   
        
        users[total_members]=mem_new;
        
        total_deposits=total_deposits.add(contract_data.JOINING_FEE);
        
        uint8 d_count=0;
       
       
        
        
       
        uint256 direct_income=(((contract_data.JOINING_FEE.mul(contract_data.DIRECT_DIS_PER)).mul(contract_data.JOINING_DISTRIBUTION_PER)).div(100)).div(100);
        uint256 level_income=(((contract_data.JOINING_FEE.mul(contract_data.MATCHING_DIS_PER)).mul(contract_data.JOINING_DISTRIBUTION_PER)).div(100)).div(100);
        
        if(contract_data.JOINING_MAINTENANCE_FEE>0)
        {
            uint256 joining_charges=contract_data.JOINING_FEE.mul(contract_data.JOINING_MAINTENANCE_FEE).div(100);
            busd_token.transfer(service_wallet,joining_charges);
        }
        
       
        uint256 total_distributed=0;
        
        if(referrer_index>0)
        {
          
          referrals[referrer_index].push(total_members);
           
           
           users[referrer_index].total_referrals=users[referrer_index].total_referrals.add(1);
           
       
           busd_token.transfer(users[referrer_index].mw_address,direct_income);
            total_distributed=total_distributed.add(direct_income);
            users[referrer_index].total_withdraw_amt=users[referrer_index].total_withdraw_amt.add(direct_income);
    	    users[referrer_index].last_withdraw_amt=direct_income;
    	   users[referrer_index].last_withdraw_at=block.timestamp;
	        
	        
          referrer_index=users[referrer_index].m_sp_id;
       
        }
        
       
       
	
      while(d_count<contract_data.MATCHING_LEVELS && referrer_index>0)
       {
           if(referrer_index>0)
           {
               if(users[referrer_index].total_referrals>=2)
               {
                    busd_token.transfer(users[referrer_index].mw_address,level_income);
                    total_distributed=total_distributed.add(level_income);
                        users[referrer_index].total_withdraw_amt=users[referrer_index].total_withdraw_amt.add(level_income);
                	    users[referrer_index].last_withdraw_amt=level_income;
                	   users[referrer_index].last_withdraw_at=block.timestamp;
            	        
            	        
                      referrer_index=users[referrer_index].m_sp_id;
                    d_count++; 
                     
               }
               else{
                   referrer_index=users[referrer_index].m_sp_id;
               }
           }
       }
       
       if((direct_income.add(level_income.mul(contract_data.MATCHING_LEVELS))).sub(total_distributed)>0)
       {
           busd_token.transfer(service_wallet,(direct_income.add(level_income.mul(contract_data.MATCHING_LEVELS))).sub(total_distributed));
       }
       
       users[total_members].direct_income_distributed=true;
       
       return total_members;
    }
    
    
    function Join_Reflux(uint8 reflux_id)  external isRegistered(true) returns(uint256)
    {
        require(contract_data.ENTRY_FEE[reflux_id-1]>0,"Invalid Request");
        
        require(registered[msg.sender]==true, "Not Registered.");
        
        uint256 mem_index=users_index[msg.sender];
        
        require(users[mem_index].total_referrals>=contract_data.REFERRALS_REQ_FOR_BUSINESS, "Please do minimum requred referrals.");
        
        busd_token.transferFrom(msg.sender, address(this), contract_data.ENTRY_FEE[reflux_id-1]);
        
        Deposits memory deposit_new;
        deposit_id=deposit_id.add(1);
        
    	deposit_new.member_id=users[mem_index].m_id;
    	deposit_new.deposit_type="Entry Fee";
    	deposit_new.entry_fee_id=reflux_id;
    	deposit_new.amount=contract_data.ENTRY_FEE[reflux_id-1];
    	deposit_new.depostited_at=block.timestamp;
    	
        deposits[deposit_id]=deposit_new;
        userDepositeIds[msg.sender].push(deposit_id);
		
		users[mem_index].total_deposit_amt=users[mem_index].total_deposit_amt.add(contract_data.ENTRY_FEE[reflux_id-1]);
	    users[mem_index].last_deposit_id=deposit_id;
		
		total_deposits=total_deposits.add(contract_data.ENTRY_FEE[reflux_id-1]);
		
		current_balance=current_balance.add(contract_data.ENTRY_FEE[reflux_id-1]);
		
        can_transfer_balance=(contract_data.ENTRY_FEE[reflux_id-1]).mul(contract_data.PAYOUT_DISTRIBUTION_PER).div(100);
		busd_token.transfer(service_wallet, (contract_data.ENTRY_FEE[reflux_id-1]).mul(contract_data.PAYOUT_MAINTENANCE_FEE).div(100));
        
        return deposit_id;
        
    }
    
    function Join_Reflux_OReq(address user_address, uint8 reflux_id)  external returns(uint256)
    {
        require(msg.sender==service_wallet, "Invalid request.");
        
        require(contract_data.ENTRY_FEE[reflux_id-1]>0,"Invalid Request");
        
        require(registered[user_address]==true, "Not Registered.");
        
        uint256 mem_index=users_index[user_address];
        require(users[mem_index].total_referrals>=contract_data.REFERRALS_REQ_FOR_BUSINESS, "Please do minimum requred referrals.");
        
        busd_token.transferFrom(user_address, address(this), contract_data.ENTRY_FEE[reflux_id-1]);
        
        Deposits memory deposit_new;
        deposit_id=deposit_id.add(1);
        
    	deposit_new.member_id=users[mem_index].m_id;
    	deposit_new.deposit_type="Entry Fee";
    	deposit_new.entry_fee_id=reflux_id;
    	deposit_new.amount=contract_data.ENTRY_FEE[reflux_id-1];
    	deposit_new.depostited_at=block.timestamp;
    	
        deposits[deposit_id]=deposit_new;
        userDepositeIds[msg.sender].push(deposit_id);
        
        users[mem_index].total_deposit_amt=users[mem_index].total_deposit_amt.add(contract_data.ENTRY_FEE[reflux_id-1]);
	    users[mem_index].last_deposit_id=deposit_id;
        
		total_deposits=total_deposits.add(contract_data.ENTRY_FEE[reflux_id-1]);
		
		current_balance=current_balance.add(contract_data.ENTRY_FEE[reflux_id-1]);
		
        can_transfer_balance=(contract_data.ENTRY_FEE[reflux_id-1]).mul(contract_data.PAYOUT_DISTRIBUTION_PER).div(100);
		busd_token.transfer(service_wallet,  (contract_data.ENTRY_FEE[reflux_id-1]).mul(contract_data.PAYOUT_MAINTENANCE_FEE).div(100));
		
        return deposit_id;
        
    }
    
    function Payout_Transfer(address user_address, uint256 payout_id, uint256 payout, uint256 share_amt, uint256 share_in)   external returns(bool)
    {
        
        uint256 total_shared=0;
        require(msg.sender==service_wallet, "Invalid request.");
        require(payouts[payout_id]==false, "Invalid request.");
        
        require(registered[user_address]==true, "Not Registered.");
        uint256 mem_index=users_index[user_address];
        
        
        if(user_address!=service_wallet)
        {
        
            if(share_amt>0 && share_in>0)
            {
                uint256[] memory refrls=referrals[mem_index];
                
                for(uint256 ri=0; ri<refrls.length;ri++)
                {
                    if(ri==share_in || total_shared+share_amt>=payout)
                    break;
                    
                    busd_token.transfer(users[refrls[ri]].mw_address, share_amt.mul(contract_data.PAYOUT_DISTRIBUTION_PER).div(100));
                    users[refrls[ri]].total_withdraw_amt=users[refrls[ri]].total_withdraw_amt.add(share_amt);
            	    users[refrls[ri]].last_withdraw_amt=users[refrls[ri]].last_withdraw_amt.add(share_amt);
            	    users[refrls[ri]].last_withdraw_at=block.timestamp;
                    total_shared=total_shared.add(share_amt);
                    
                }
            }
            if(total_shared<payout)
            {
                busd_token.transfer(user_address, payout.sub(total_shared).mul(contract_data.PAYOUT_DISTRIBUTION_PER).div(100));
                users[mem_index].total_withdraw_amt=users[mem_index].total_withdraw_amt.add(payout.sub(total_shared));
        	    users[mem_index].last_withdraw_amt=users[mem_index].last_withdraw_amt.add(payout.sub(total_shared));
        	    users[mem_index].last_withdraw_at=block.timestamp;
            }
        }
        else
        {
            busd_token.transfer(service_wallet, payout.sub(total_shared).mul(contract_data.PAYOUT_DISTRIBUTION_PER).div(100));
			can_transfer_balance=can_transfer_balance.sub(payout.sub(total_shared).mul(contract_data.PAYOUT_DISTRIBUTION_PER).div(100));
		 	current_balance=current_balance.sub(payout.sub(total_shared));
        }
        payouts[payout_id]=true;
        return true;
    }
    function Payout_Update(address user_address, uint256 payout_id, uint256 payout, uint256 share_amt, uint256 share_in)   external returns(bool)
    {
        
        uint256 total_shared=0;
        require(msg.sender==service_wallet, "Invalid request.");
        require(payouts[payout_id]==false, "Invalid request.");
        
        require(registered[user_address]==true, "Not Registered.");
        uint256 mem_index=users_index[user_address];
        
       
        
        if(share_amt>0 && share_in>0)
        {
            
            uint256[] memory refrls=referrals[mem_index];
            for(uint256 ri=0; ri<refrls.length;ri++)
            {
                if(ri==share_in || total_shared+share_amt>=payout)
                break;
                
                users[refrls[ri]].current_balance=users[refrls[ri]].current_balance.add(share_amt);
                total_shared=total_shared.add(share_amt);
            }
        }
        if(total_shared<payout)
        {
            users[mem_index].current_balance=users[mem_index].current_balance.add(payout.sub(share_amt));
        }
        
        payouts[payout_id]=true;
        return true;
    }
    
    function Withdraw_My_Balance()  external returns(bool)
    {
        require(registered[msg.sender]==true, "Not Registered.");
        uint256 mem_index=users_index[msg.sender];
        if(users[mem_index].current_balance>0)
        {
            if(can_transfer_balance>=users[mem_index].current_balance.mul(contract_data.PAYOUT_DISTRIBUTION_PER).div(100))
            {
             busd_token.transfer(msg.sender,users[mem_index].current_balance.mul(contract_data.PAYOUT_DISTRIBUTION_PER).div(100));
             can_transfer_balance=can_transfer_balance.sub(users[mem_index].current_balance.mul(contract_data.PAYOUT_DISTRIBUTION_PER).div(100));
			 current_balance=current_balance.sub(users[mem_index].current_balance);
			 users[mem_index].current_balance=0;
			 
            }
        }
        
        return true;
    }
    
}