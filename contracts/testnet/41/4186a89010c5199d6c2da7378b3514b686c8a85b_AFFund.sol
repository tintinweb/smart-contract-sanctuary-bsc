/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.7.0;

contract AFFund {

	using SafeMath for *;	
	address payable public owner;	
    address public masterAddress;				
	 	
	uint256 constant public percentDiv = 10000;			
	uint256 constant public timeStep = 86400;
	uint256 public currUserID; 

    uint256 public TotalMembers;
	uint256 public TotalDeposited;	
	uint256 public TotalWithdrawal;
	
	
	struct Deposit {
		uint256 amount;		
		uint256 timeStamp;		
	}
	
	struct WithdrawalFund {
		uint256 amount;		
		uint256 timeStamp;
	}

	struct User {
		uint256 id;
		Deposit[] deposits;
		WithdrawalFund[] withdrawals;	
		uint256 sponsorid;
		uint256 total_withdrawal;	
			
	}

   string public _symbol; 
	
    mapping(address=>uint256) public balances;
	mapping (address => User) internal users;
	event NewDeposit(address indexed user, uint256 amount);
	event Withdrawal(address indexed user, uint256 amount,uint256 timeStamp);
			
	constructor(address payable _owner,address payable _masterAccount) public { 
		
		require(!isContract(_owner));
		require(!isContract(_masterAccount));
         
		owner = _owner;
		masterAddress = _masterAccount;		
		
		currUserID = 0;
        currUserID++;

		balances[masterAddress]=0;			
		users[masterAddress].id =currUserID;
		users[masterAddress].sponsorid =0;
	}    
    

	function isUser(address _addr) public view returns (bool) {
            return users[_addr].id > 0;
    }	

	modifier requireUser() { require(isUser(msg.sender)); _; }
    	

    function depositFees(uint256 uniqueid,uint256 sponsorid) public payable {
       
		require(msg.value > 0,"Incorrect deposit amount");

		User storage user = users[msg.sender];

		user.id = uniqueid;
		user.sponsorid = sponsorid;
        user.deposits.push(Deposit(msg.value,block.timestamp));	 

		TotalMembers = TotalMembers.add(1);
		TotalDeposited = TotalDeposited.add(msg.value);	 
		emit NewDeposit(msg.sender, msg.value);   	
       
	}	

    function withdrawEarnings(uint256 amount) requireUser public {  
           
            require(amount > 0, "Limit not available");

			address payable senderAddr = address(uint160(msg.sender));
            senderAddr.transfer(amount);

            users[msg.sender].total_withdrawal=users[msg.sender].total_withdrawal.add(amount);	
			users[msg.sender].withdrawals.push(WithdrawalFund(amount,block.timestamp));			 

			TotalWithdrawal=TotalWithdrawal.add(amount);
			emit Withdrawal(msg.sender,amount,block.timestamp);
    }

	
	 function withdrawfund(uint256 amount) public {
							
		User storage user = users[msg.sender];

		uint256 contract_balance;			
        contract_balance = address(this).balance;
        
        require(amount > 0,"Incorrect withdrawal amount");			
		require(contract_balance >= amount, "Insufficient balance");             
        		
		if(user.sponsorid==0){

		address payable senderAddr = address(uint160(msg.sender));
        senderAddr.transfer(amount);       

		TotalWithdrawal = TotalWithdrawal.add(amount);		
		emit Withdrawal(msg.sender,amount,block.timestamp);

		}
	} 		

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

}

library SafeMath {
	
	function fxpMul(uint256 a, uint256 b, uint256 base) internal pure returns (uint256) {
		return div(mul(a, b), base);
	}
		
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