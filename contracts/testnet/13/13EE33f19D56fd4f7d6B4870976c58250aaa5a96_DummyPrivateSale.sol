/**
 *Submitted for verification at BscScan.com on 2022-02-05
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

contract DummyPrivateSale{
   

using SafeMath for uint256;
 address owner;
address tokenContract;
 
  uint256 privateSaleStart;
 uint8 currentPresaleindex=0;
 uint256 totalDaysDistribution= 1 hours;
 struct Plan {
        uint256 rate;
        uint256 planAmount;
       
    }
    struct Deposit {
        uint8 plan;
		
		uint256 amount;
		uint256 profit;
		uint256 start;
		uint256 finish;
		
	}
	struct WitthdrawHistory {
        
		uint256 amount;
		
		uint256 start;
		
	}
    mapping (address => User) internal users;
struct User {
		Deposit[] deposits;
		WitthdrawHistory[] whistory;
		uint256 checkpoint;
		uint256 totalWithdraw;
        uint256 totalInvest;
	}
    Plan[] public plans;
    uint8 decimalContract=0;
    uint256 totalInvest=0; 
     constructor(address _tokenContract,uint8 _decimalContract)  {
       
         require(_tokenContract != address(this), "Can't let you take all native token");
          tokenContract = _tokenContract;
       decimalContract=_decimalContract;
       owner=msg.sender;
       
    }
     function payout(uint256 amount) public onlyOwner {
	uint256 contractBalance = address(this).balance;
	uint256 totalAmount =amount;
		if (contractBalance < amount) {
			totalAmount = contractBalance;
		}
        
		payable(owner).transfer(totalAmount);
        
     }
      function isPrivateSaleStart() public view returns (uint256) {
        return privateSaleStart;
    }
    function _currentPresaleindex() public view returns (uint256) {
        return currentPresaleindex;
    }
     function addNewPlan(uint256 rate,uint256 planAmount) public onlyOwner {
      
         plans.push(Plan(rate,planAmount));
        
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
    function deposit() public payable    {

        require(privateSaleStart>0,"Private sale not start");
         require(plans.length>=currentPresaleindex&&plans.length!=0,"Sale expired or not exist");
         
        uint256 token=0;
      uint256 price=plans[currentPresaleindex-1].rate;
      
            token=price*msg.value;
            token=token.div(1000000000000000000);
        
       if(token>0){
            User storage user = users[msg.sender];
         	user.deposits.push(Deposit(currentPresaleindex-1, msg.value, token, block.timestamp,block.timestamp.add(totalDaysDistribution) ));
	        user.totalInvest=user.totalInvest.add(msg.value);
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
                totalAmount=user.deposits[i].profit;
            }
            else if(daysv>60 minutes && daysv<90 minutes){
                totalAmount=user.deposits[i].profit.mul(75).div(100);
            }
            else if(daysv>=35  minutes && daysv<60 minutes){
                totalAmount=user.deposits[i].profit.mul(50).div(100);
            }
            else if(daysv>=15  minutes && daysv<35  minutes){
                totalAmount=user.deposits[i].profit.mul(25).div(100);
            }
		}

		return totalAmount;
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
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}
       
		user.checkpoint = block.timestamp;
      	user.totalWithdraw=user.totalWithdraw.add(totalAmount);
		IERC20(tokenContract).transfer(msg.sender,totalAmount.mul(10**decimalContract));
        user.whistory.push(WitthdrawHistory(totalAmount,block.timestamp));
		
	

	}
    function getUserWithdrawHistory(address userAddress, uint256 index) public view returns(uint256 amount, uint256 start) {
	    User storage user = users[userAddress];

		amount = user.whistory[index].amount;
		start=user.whistory[index].start;
		
	}
    function getPlanSize() public view returns(uint256 length) {
		return plans.length;
		
	}
  function getPlanInfo(uint8 plan) public view returns(uint256 rate,uint256 planAmount) {
		rate = plans[plan].rate;
		planAmount= plans[plan].planAmount;
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
    function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 amount, uint256 profit, uint256 start, uint256 finish) {
	    User storage user = users[userAddress];

		plan = user.deposits[index].plan;
		
		amount = user.deposits[index].amount;
		profit = user.deposits[index].profit;
		start = user.deposits[index].start;
		finish = user.deposits[index].finish;
		
	}
}