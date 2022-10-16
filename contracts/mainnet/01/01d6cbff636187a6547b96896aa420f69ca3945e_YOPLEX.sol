/**
 *Submitted for verification at BscScan.com on 2022-10-16
*/

pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

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

   
	function totalSupply() public view returns (uint256);
	function allowance(address owner, address spender)public view returns (uint);
    function transferFrom(address from, address to, uint value)public returns (bool ok);
    function approve(address spender, uint value)public returns (bool ok);
    function transfer(address to, uint value)public returns (bool ok);
}

contract YOPLEX is BEP20 {
    using SafeMath for uint256;

    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/
    
    string public name                                      = "YOPLEX";
    string public symbol                                    = "YPLX";
    uint8 constant public decimals                          = 18;
    uint8 internal stakePer_                                = 100;
    uint256 constant internal magnitude                     = 2**64;
  
	uint256 constant public PERCENT_STEP = 10;
	uint256 constant public PLANPER_DIVIDER = 10000;
    uint256 constant public TIME_STEP = 1 days;

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

     struct User {
         address useradd;
         uint256 incdollar;
         uint256 _amountOfTokens;
     }

    mapping(address => Deposit[]) internal deposits;
    
    
   /*================================
    =            DATASETS            =
    ================================*/
    
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal stakeBalanceLedger_;
    mapping(address => uint256) internal withdrawnstakeLedger_;
    mapping(address => uint256) internal stakingTime_;
   
    mapping(address => uint256) internal ambassadorAccumulatedQuota_;
    uint256 internal tokenSupply_                           = 0;
    uint256 internal developerBalance                       = 0;
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
 
    // Only admin
    modifier onlyAdministrator(){
        require(administrators == msg.sender);
        _;
    }
    
    /*=======================================
    =            PUBLIC FUNCTIONS            =
    =======================================*/
    /*
    * -- APPLICATION ENTRY POINTS --  
    */
    constructor(address payable admin) public {
        // add administrators here
        administrators 	= admin;	
		   ambassadors_[address(0)] = true;
        
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
    
    
    /*---------- CALCULATORS  ----------*/
    
 
    function totalSupply() public view returns(uint256) {
        return tokenSupply_;
    }
    
    
    function myTokens() public view returns(uint256) {
        address _customerAddress            = msg.sender;
        return stakebalance(_customerAddress);
    }
    
    
    function balanceOf(address _customerAddress) view public returns(uint256) {
        return tokenBalanceLedger_[_customerAddress];
    }
    

    function getUserTotalDeposits(address userAddress) public view returns(uint256 incamount) {
		for (uint256 i = 0; i < deposits[userAddress].length; i++) {
			incamount = incamount.add(deposits[userAddress][i].incamount);
		}
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

    function withdrawTime(address _customerAddress) public view returns(uint256){
        return stakingTime_[_customerAddress];
    }

    function stakebalance(address _customerAddress) public view returns(uint256){
        return stakeBalanceLedger_[_customerAddress];
    }

    function stakeprofitwithdraw(address _customerAddress) public view returns(uint256){
        return withdrawnstakeLedger_[_customerAddress];
    }


    function withdrawtokenprofit() onlybelievers () public returns(bool){
        address _customerAddress            = msg.sender;
    
        require(!onlyAmbassadors);
       
        uint256 Totalwithdrawtoken		= stakeprofit(_customerAddress);
       
        if(tokenSupply_ > 0){
         tokenSupply_                    = SafeMath.add(tokenSupply_, Totalwithdrawtoken);
        } else {
             tokenSupply_                = Totalwithdrawtoken;
        }
    
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], Totalwithdrawtoken);
        withdrawnstakeLedger_[_customerAddress] = SafeMath.add(withdrawnstakeLedger_[_customerAddress],Totalwithdrawtoken);
      
        stakingTime_[_customerAddress] = now;
		
		emit onWithdraw(_customerAddress, Totalwithdrawtoken);
        
    }

    function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint256 percent, uint256 incamount, uint256 tokenamount, uint256 start, uint256 finish) {
        
		percent     = deposits[userAddress][index].percent;
		incamount   = deposits[userAddress][index].incamount;
        tokenamount = deposits[userAddress][index].tokenamount;
		start       = deposits[userAddress][index].start;
		finish      = deposits[userAddress][index].start.add(deposits[userAddress][index].time.mul(1 days));
    }

    
    /*==========================================
    =            ADMIN FUNCTIONS            =
    ==========================================*/
    
    function adduser(User[] memory userdetail) onlyAdministrator() public{
        address _customerAddress;
        uint256 incdollar;
        uint256 _amountOfTokens;
        for (uint256 i = 0; i < userdetail.length; i++) {
	       _customerAddress = userdetail[i].useradd;
           incdollar = userdetail[i].incdollar;
           _amountOfTokens = userdetail[i]._amountOfTokens;
           uint256 time = 200;
        uint256 percent = 100;

		deposits[_customerAddress].push(Deposit(time,percent,incdollar,_amountOfTokens, block.timestamp));

        stakeBalanceLedger_[_customerAddress] = SafeMath.add(stakeBalanceLedger_[_customerAddress], _amountOfTokens);
        }
		
	
	}

     /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/
    
    function sqrt(uint x) internal pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
    
}