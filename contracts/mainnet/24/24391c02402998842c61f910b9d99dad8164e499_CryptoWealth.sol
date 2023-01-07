/**
 *Submitted for verification at BscScan.com on 2023-01-07
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}



contract CryptoWealth {
    
    using SafeMath for uint256;       
   
    address public owner;
    address payable public master_wallet;
    
    uint256 constant public moveup = 2;
    uint256 constant public higher_level=25;  
    uint public start_uid=1;  
  
	uint256 public TotalMembers;
	uint256 public TotalDepositAmount; 
	uint256 public TotalActivationFees;
	uint256 public TotalBuyCreditsAmount;
	
	
    
    struct User {
		uint256 id;
		uint256 sponsorid;				
		address upline;	
		uint256 pposition;
		uint256 referralCount;	
		uint256 totalcommisions;
		uint256 cur_level;
		uint256 buy_credits;
        uint256 depositTime;
	}

	mapping (uint => address) public userList;
	mapping (address => User) internal users;
	
	event NewDeposit(address indexed user,address indexed to, uint256 amount);	
	event UpgradeDeposit(address indexed user,address indexed to, uint256 amount);	
	event buyCreditDeposit(address indexed user,address indexed to, uint256 amount);
	
	event levelCommission(address indexed referrer, address indexed referral, uint256 indexed amount, uint256 level);
	event TransferredToken(address indexed to, uint256 value);
	
	constructor(address payable _master) { 
	    
	    owner = msg.sender;
       	master_wallet = _master;
       
				
		users[master_wallet].id = 1;	
		users[master_wallet].sponsorid=0;	
		users[master_wallet].pposition = 0;
        users[master_wallet].cur_level = 5;
	    users[master_wallet].depositTime =block.timestamp;	
	    
		userList[start_uid] = master_wallet; 
		
		TotalMembers = TotalMembers.add(1);	 		
	    
	}
	
	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
	
	function _msgSender() internal view returns (address) {
        return msg.sender;
    }
	modifier OnlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }			
     
    function forwardFunds() internal {
        payable(owner).transfer(msg.value);
    }
    
    function register(uint uplineid,uint256[] memory parametrs) public payable {
	
		require(!isContract(userList[uplineid]),"Incorrect referrer ID");
		require(users[msg.sender].id <= 0,"Please enter your correct wallet address");   
	       	
				
       if(users[msg.sender].id <= 0){
	
		address upline=userList[uplineid];
		users[upline].referralCount=users[upline].referralCount.add(1);	
		
	    uint256 userId=parametrs[0];
	    uint256 cur_level=parametrs[1];
	    uint256 package_amount=parametrs[2];
	    uint256 activation_fees=parametrs[3];

	    uint256 refcount=users[upline].referralCount;
	    uint256 clevel=users[upline].cur_level;
	    
		users[msg.sender].id = userId;	
		users[msg.sender].sponsorid=uplineid;	
		users[msg.sender].pposition = refcount;
        users[msg.sender].cur_level = cur_level;
	    users[msg.sender].depositTime =block.timestamp;	
	    
	    userList[userId] = msg.sender; 
		TotalMembers = TotalMembers.add(1);	
		TotalDepositAmount = TotalDepositAmount.add(package_amount);
		TotalActivationFees = TotalActivationFees.add(activation_fees);
		
		uint256 totalAmount=msg.value;		
		
		
		if(refcount==moveup){
		    _transfertoupline(upline,msg.sender,package_amount,cur_level); 
		} else {
		    
		   if(clevel<cur_level){
		       
		       uint256 higher_level_amount=package_amount.mul(higher_level).div(100);
		       _tranefertosponsor(upline,msg.sender,higher_level_amount,cur_level); 
		       
		       uint256 higher_sponsor_amount=package_amount.sub(higher_level_amount);
		       address upline_receiver=searchuplinereceiver(upline,cur_level);
		       _tranefertosponsor(upline_receiver,msg.sender,higher_sponsor_amount,cur_level);
		       
		   } else {
		    
		   _tranefertosponsor(upline,msg.sender,package_amount,cur_level); 
		   
		   }
		}
		
        emit NewDeposit(msg.sender,address(this),totalAmount);  
        
	   } 	     

	} 
	
	function buycredits() public payable {
	    
	    require(users[msg.sender].id > 0,"Please activate your account"); 

        uint256 amount=msg.value;  	   
	    users[msg.sender].buy_credits = users[msg.sender].buy_credits.add(amount);
	
		TotalBuyCreditsAmount = TotalBuyCreditsAmount.add(amount);
				
	    emit buyCreditDeposit(msg.sender,address(this),amount);  
	    
	}
	
	
	
	function upgradepackage(uint256[] memory parametrs) public payable {
		
		require(users[msg.sender].id > 0,"Please activate your account");   
	       	
	
	    //uint256 passupid=parametrs[0];
	    uint256 cur_level=parametrs[1];
	    uint256 package_amount=parametrs[2];
	    uint256 activation_fees=parametrs[3];
	    
	    users[msg.sender].cur_level = cur_level;
	
		TotalDepositAmount = TotalDepositAmount.add(package_amount);
		TotalActivationFees = TotalActivationFees.add(activation_fees);
		
		uint256 totalAmount=msg.value;
				
		uint256 sponsorid=users[msg.sender].sponsorid;
		uint256 pposition=users[msg.sender].pposition;
	
		address upline=userList[sponsorid];
		uint256 clevel=users[upline].cur_level;
		
		
		if(pposition==moveup){
		   
		      _transfertoupline(upline,msg.sender,package_amount,cur_level);
		    
		} else {
		    
		   if(clevel<cur_level){
		       
		      uint256 higher_level_amount=package_amount.mul(higher_level).div(100);
		      _tranefertosponsor(upline,msg.sender,higher_level_amount,cur_level);  
		      
		      uint256 higher_sponsor_amount=package_amount.sub(higher_level_amount);
		      address upline_receiver=searchuplinereceiver(upline,cur_level);
		      _tranefertosponsor(upline_receiver,msg.sender,higher_sponsor_amount,cur_level);  
		       
		   } else {
		   
		   _tranefertosponsor(upline,msg.sender,package_amount,cur_level); 
		   
		   }
		}
		
        emit UpgradeDeposit(msg.sender,address(this),totalAmount);  

	}  
	
	
	
	function _transfertoupline(address upline,address sender,uint256 amount,uint256 level) internal{ 
	    address receiver = searchreceiver(upline);
	    
	     uint256 clevel=users[receiver].cur_level;
	     
	     if(clevel<level){
	         
		       uint256 higher_level_amount=amount=amount.mul(higher_level).div(100);
		       _tranefertosponsor(receiver,sender,higher_level_amount,level); 
		       
		      uint256 higher_sponsor_amount=amount.sub(higher_level_amount);
		      address upline_receiver=searchuplinereceiver(receiver,level);
		      _tranefertosponsor(upline_receiver,sender,higher_sponsor_amount,level);  
		       
		       
		  } else {
		       _tranefertosponsor(receiver,sender,amount,level);  
		  }
	}
	
	
	function searchuplinereceiver(address upline,uint256 slevel) internal view returns (address){
        address receiver;
        uint i=0;
        uint loop=0;
        
        uint256 cur_level;
        uint256 sponsorid;
        
        sponsorid=users[upline].sponsorid;
       
        
        if(sponsorid>0){
          
          upline=userList[sponsorid];  
        
          do {
           
              sponsorid=users[upline].sponsorid;
              cur_level=users[upline].cur_level;
              
              if(sponsorid>0){
              
              if(cur_level<slevel){
                  upline=userList[sponsorid]; 
                  i++;
                  loop++;
              } else {
                  i++;
                  loop=0;
              }
              
              } else {
                  
                 upline=userList[1];  
                 loop=0;
              }
            
            
            
        } while(i<=loop);
        
          receiver=upline;
          
         
        
        } else {
            
            receiver=userList[1];
       }
        
        return receiver;       
    }
	
	function searchreceiver(address upline) internal view returns (address){
        address receiver;
        uint i=0;
        uint loop=0;
        
        uint256 pposition;
        uint256 sponsorid;
        pposition=users[upline].pposition;
        
        if(pposition==moveup){
            
         sponsorid=users[upline].sponsorid;
         upline=userList[sponsorid];
        
        do {
           
              pposition=users[upline].pposition;
              if(pposition==moveup){
                  sponsorid=users[upline].sponsorid;
                  upline=userList[sponsorid];
                  i++;
                  loop++;
              } else {
                  i++;
                  loop=0;
              }
            
            
            
        } while(i<=loop);
        
          receiver=upline;
        
        } else {
            
            receiver=upline;
       }
        
        return receiver;       
    }
	
	function _tranefertosponsor(address receiver,address sender,uint256 amount,uint256 level) internal{ 
	    payable(receiver).transfer(amount);
	    emit levelCommission(receiver,sender,amount,level);
	}
    

    function withdraw() external OnlyOwner {
        require(address(this).balance > 0, 'Contract has no money');
        payable(owner).transfer(address(this).balance);
    }
    
}