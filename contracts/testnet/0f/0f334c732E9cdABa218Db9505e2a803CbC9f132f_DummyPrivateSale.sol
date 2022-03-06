/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-08
*/

pragma solidity ^0.8.4;
//SPDX-License-Identifier: Unlicensed
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }


    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;


        return c;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
interface IERC20 {

   
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
   
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
function transferFromPresale(address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
   
    

}
 library Library {
  struct userdata {
     string email;
     }
}
library LibraryEmail {
  struct userdata {
     address userAddress;
     }
}

library StringUtils {
    /// @dev Does a byte-by-byte lexicographical comparison of two strings.
    /// @return a negative number if `_a` is smaller, zero if they are equal
    /// and a positive numbe if `_b` is smaller.
    function compare(string memory  _a, string  memory _b) public pure  returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        //@todo unroll the loop into increments of 32 and do full 32 byte comparisons
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
    }
    /// @dev Compares two strings and returns true iff they are equal.
    function equal(string  memory _a, string  memory _b) public pure returns (bool) {
        return compare(_a, _b) == 0;
    }
    /// @dev Finds the index of the first occurrence of _needle in _haystack
   function indexOf(string  memory _haystack, string  memory _needle)  public pure returns (int)
    {
    	bytes memory h = bytes(_haystack);
    	bytes memory n = bytes(_needle);
    	if(h.length < 1 || n.length < 1 || (n.length > h.length)) 
    		return -1;
    	else if(h.length > (2**128 -1)) // since we have to be able to return -1 (if the char isn't found or input error), this function must return an "int" type with a max length of (2^128 - 1)
    		return -1;									
    	else
    	{
    		uint subindex = 0;
    		for (uint i = 0; i < h.length; i ++)
    		{
    			if (h[i] == n[0]) // found the first char of b
    			{
    				subindex = 1;
    				while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex]) // search until the chars don't match or until we reach the end of a or b
    				{
    					subindex++;
    				}	
    				if(subindex == n.length)
    					return int(i);
    			}
    		}
    		return -1;
    	}	
    }
}
contract DummyPrivateSale{
   

using SafeMath for uint256;
 address owner;
address tokenContract;
 
  uint256 privateSaleStart;
 uint8 currentPresaleindex=0;
 uint256 totalDaysDistribution= 1 hours;
uint256 totalTokenSell=0;
 struct Plan {
        uint256 rate;
        uint256 planSupply;
        uint256 totalInvested;
        uint256 totalRaised;
       
    }
     struct UniqueUsers {
       address userAddress;
       
    }
    struct Deposit {
        uint8 plan;
		
		uint256 amount;
		uint256 profit;
		uint256 start;
		uint256 finish;
		 string email;
	}
	struct WitthdrawHistory {
        
		uint256 amount;
		
		uint256 start;
		
	}
    string emptyEmail="";
    mapping (address => User) internal users;
struct User {
		Deposit[] deposits;
		WitthdrawHistory[] whistory;
		uint256 checkpoint;
		uint256 totalWithdraw;
        uint256 totalInvest;
       
	}
    Plan[] public plans;
    UniqueUsers[] public uniqueContractuser;
    using Library for Library.userdata;
     using LibraryEmail for LibraryEmail.userdata;
    mapping(address => Library.userdata) clusterContract;
    mapping(string => LibraryEmail.userdata) clusterContractEmail;
    uint8 decimalContract=0;
    uint256 totalInvest=0; 
    uint256 totalWithdrawToken=0;
     constructor(address _tokenContract,uint8 _decimalContract)  {
       
         require(_tokenContract != address(this), "Can't let you take all native token");
          tokenContract = _tokenContract;
       decimalContract=_decimalContract;
       owner=msg.sender;
       
    }
    function totalUser() public view returns(uint256 length) {
	   
	return uniqueContractuser.length;
		
		
	}
    function contractUserAdress(uint256 index) public view returns(address userAddress) {
	   
	return uniqueContractuser[index].userAddress;
		
		
	}
     function withdrawunSoldToken() public onlyOwner {
		uint256 availableToken = IERC20(tokenContract).balanceOf(address(this)).sub(totalTokenSell.div(10**18).mul(10**decimalContract));
		
        if(availableToken>0){
IERC20(tokenContract).transfer(msg.sender,availableToken);
        }
		
        
     }
      function isPrivateSaleStart() public view returns (uint256) {
        return privateSaleStart;
    }
    function _currentPresaleindex() public view returns (uint256) {
        return currentPresaleindex;
    }
     function addNewPlan(uint256 rate,uint256 planSupply) public onlyOwner {
      
         plans.push(Plan(rate,planSupply,0,0));
        
    }
    function updatePlanSupply(uint256 index,uint256 planSupply) public onlyOwner {
      
         plans[index].planSupply=planSupply;
        
    }
    function setCurrentPresale(uint8 index) public onlyOwner {
      require(index>currentPresaleindex,"Can not downgrade");

      currentPresaleindex=index  ; 
        
    }
    function startPrivateSale() public onlyOwner {
      
         privateSaleStart=block.timestamp;   
        
    }
   function isOwner(address account) public view returns (bool) {
        return account == owner;
    }
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }
    function participate(string memory email) public payable    {

        require(privateSaleStart>0,"Private sale not start");
         require(plans.length>=currentPresaleindex&&plans.length!=0,"Sale expired or not exist");
           uint8 isallow=0;
          if(StringUtils.equal(clusterContract[msg.sender].email,emptyEmail)&&clusterContractEmail[email].userAddress==address(0x00)){
isallow=1;
clusterContract[msg.sender].email=email;
clusterContractEmail[email].userAddress=msg.sender;
uniqueContractuser.push(UniqueUsers(msg.sender));
          }else{
if(StringUtils.equal(clusterContract[msg.sender].email,email)){
isallow=1;

}

          }
          
       

          require(isallow==1,"Account already linked with other Email");
        uint256 token=0;
      uint256 price=plans[currentPresaleindex-1].rate;
      
            token=price.mul(msg.value);
          
        require(plans[currentPresaleindex-1].totalRaised.add(token)<=plans[currentPresaleindex-1].planSupply.mul(10**18),"Sale filled");
       if(token>0){
            User storage user = users[msg.sender];
            totalTokenSell=totalTokenSell.add(token);
         	user.deposits.push(Deposit(currentPresaleindex-1, msg.value, token, block.timestamp,block.timestamp.add(totalDaysDistribution),clusterContract[msg.sender].email ));
	        user.totalInvest=user.totalInvest.add(msg.value);
            plans[currentPresaleindex-1].totalInvested=plans[currentPresaleindex-1].totalInvested.add(msg.value);
            plans[currentPresaleindex-1].totalRaised=plans[currentPresaleindex-1].totalRaised.add(token);
            totalInvest=totalInvest.add(msg.value);
            payable(owner).transfer(msg.value);
       }else{
           require(token>0,"Please enter a valid amount");
       }
        
       
    }
    function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			uint256 daysv =block.timestamp-user.deposits[i].start;
            if(daysv>=90 minutes){
                totalAmount=totalAmount.add(user.deposits[i].profit);
            }
            else if(daysv>60 minutes && daysv<90 minutes){
                totalAmount=totalAmount.add(user.deposits[i].profit.mul(75).div(100));
            }
            else if(daysv>=35  minutes && daysv<60 minutes){
                totalAmount=totalAmount.add(user.deposits[i].profit.mul(50).div(100));
            }
            else if(daysv>=15  minutes && daysv<35  minutes){
                totalAmount=totalAmount.add(user.deposits[i].profit.mul(25).div(100));
            }
		}

		return totalAmount;
	}
      
    function checkuSerEmail(address userAddress) public view returns (string memory){
    return clusterContract[userAddress].email;
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
       
        owner = newOwner;
    }
function getAvailableBalance(address userAddress) public view returns (uint256) {
uint256 dividend=getUserDividends(userAddress);
User storage user = users[userAddress];
uint256 withdrawAmount =user.totalWithdraw;
return dividend.sub(withdrawAmount);
}
   function withdraw() public {
	
		User storage user = users[msg.sender];

		uint256 totalAmount = getAvailableBalance(msg.sender);

		
		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = IERC20(tokenContract).balanceOf(address(this));
		if (contractBalance < totalAmount.div(10**18).mul(10**decimalContract)) {
			totalAmount = contractBalance;
		}
       
		user.checkpoint = block.timestamp;
      	user.totalWithdraw=user.totalWithdraw.add(totalAmount);
		IERC20(tokenContract).transfer(msg.sender,totalAmount.div(10**18).mul(10**decimalContract));
        user.whistory.push(WitthdrawHistory(totalAmount,block.timestamp));
		totalWithdrawToken=totalWithdrawToken.add(totalAmount);
	

	}
    function getUserWithdrawHistory(address userAddress, uint256 index) public view returns(uint256 amount, uint256 start) {
	    User storage user = users[userAddress];

		amount = user.whistory[index].amount;
		start=user.whistory[index].start;
		
	}
    function getPlanSize() public view returns(uint256 length) {
		return plans.length;
		
	}
  function getPlanInfo(uint8 plan) public view returns(uint256 rate,uint256 planSupply,uint256 totalRaisedv,uint256 totalInvestv) {
		rate = plans[plan].rate;
		planSupply= plans[plan].planSupply;
        totalInvestv= plans[plan].totalInvested;
        totalRaisedv= plans[plan].totalRaised;
      
	}
     function getUserInfo(address userAddress) public view returns(uint256 totalInvestV,uint256 totalWithdraw,uint256 depositsV,uint256 withdrawV) {
           User storage user = users[userAddress];
		totalInvestV = user.totalInvest;
		
		totalWithdraw = user.totalWithdraw;
		depositsV = user.deposits.length;
		withdrawV = user.whistory.length;
		
	}
   
	function getUserWithdrawSize(address userAddress) public view returns(uint256 length) {
	    User storage user = users[userAddress];
	
		return user.whistory.length;
		
	}
    function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}
    function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 amount, uint256 profit, uint256 start, uint256 finish,string memory email) {
	    User storage user = users[userAddress];

		plan = user.deposits[index].plan;
		
		amount = user.deposits[index].amount;
		profit = user.deposits[index].profit;
		start = user.deposits[index].start;
		finish = user.deposits[index].finish;
		  email= user.deposits[index].email;
	}
}