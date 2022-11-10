/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IERC20Permit {
  
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

   
    function nonces(address owner) external view returns (uint256);

   
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


library Address {
    
    function isContract(address account) internal view returns (bool) {
       
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

   
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

   
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

   
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
         require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

   
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
       bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract GTITstaking {
	using SafeMath for uint256;
	using SafeERC20 for IERC20;

	uint256[] public REFERRAL_PERCENTS 	= [70000, 30000];	
	uint256 public LiquidityFees = 10;
	
	uint256 constant public PERCENTS_DIVIDER = 1000000;
	uint256 constant public PLANPER_DIVIDER = 1000000;
	uint256 constant public TIME_STEP = 1 days;

	uint256 public totalInvested;
	
	address chkLv2;	
    
    struct RefUserDetail {
        address refUserAddress;
        uint256 refLevel;
    }

    mapping(address => mapping (uint => RefUserDetail)) public RefUser;
    mapping(address => uint256) public referralCount_;
    
	
	mapping(address => address) public referralLevel1Address;
    mapping(address => address) public referralLevel2Address;
	
	
    struct Plan {
        uint256 time;
        uint256 percent;
		bool isActive;
        uint256 totalDeposit;
    }

    Plan[] public plans;

	struct Deposit {
        uint8 plan;
		uint256 amount;
		uint256 start;
	}

	struct User {
		Deposit[] deposits;
		uint256 checkpoint;
		address referrer;
		uint256[2] levels;
		uint256 bonus;
		uint256 totalBonus;
		uint256 seedincome;
		uint256 withdrawn;
		uint256 withdrawnseed;
	}
	
	mapping (address => User) public users;

	bool public started=true;
	address payable public commissionWallet;
	IERC20 public  token;
	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event SeedIncome(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);
    
   address [] private admins;  
	constructor(address payable wallet)  {
		require(!isContract(wallet));
		commissionWallet = wallet;
		admins.push(wallet);
        plans.push(Plan(180, 50000,true,0));
		plans.push(Plan(365, 100000,true,0));
    	token = IERC20(0xACd3074cA95f1e62EE96c0D7955E2555630868Ff); //** Need to change mainnet token address
	}

	modifier onlyAdmin(){
		require(msg.sender==commissionWallet,"Error: You Are Not Admin");
		_;
	}

   	function addadmins(address _address) public onlyAdmin {
		require(!checkExitsAddress(_address),"Address already added");
		admins.push(_address);
	}

    function fetchAdmins() public view returns(address [] memory){
		return admins;
	}

	function checkExitsAddress(address _userAdd) private view returns (bool){
       bool found=false;
        for (uint i=0; i<admins.length; i++) {
            if(admins[i]==_userAdd){
                found=true;
                break;
            }
        }
        return found;
    }    

	function getDownlineRef(address senderAddress, uint dataId) public view returns (address,uint) { 
        return (RefUser[senderAddress][dataId].refUserAddress,RefUser[senderAddress][dataId].refLevel);
    }

    function addPlans(uint256 time,uint256 percentage,bool isActive) public onlyAdmin{
		plans.push(Plan(time, percentage,isActive,0));
	}

    function updatePlanStatus(uint8 plan,bool isActive) public onlyAdmin{
        plans[plan].isActive = isActive;
    }

    function setLiqiduidityFees(uint256 _fees) public onlyAdmin{
        LiquidityFees = _fees;
    }
    
    function addDownlineRef(address senderAddress, address refUserAddress, uint refLevel) internal {
        referralCount_[senderAddress]++;
        uint dataId = referralCount_[senderAddress];
        RefUser[senderAddress][dataId].refUserAddress = refUserAddress;
        RefUser[senderAddress][dataId].refLevel = refLevel;
    }

	function distributeRef(address _referredBy,address _sender, bool _newReferral) internal {
       
          address _customerAddress        = _sender;
        // Level 1
        referralLevel1Address[_customerAddress]                     = _referredBy;
        if(_newReferral == true) {
            addDownlineRef(_referredBy, _customerAddress, 1);
        }
        
        chkLv2                          = referralLevel1Address[_referredBy];
	
        // Level 2
        if(chkLv2 != 0x0000000000000000000000000000000000000000) {
            referralLevel2Address[_customerAddress]                     = referralLevel1Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel1Address[_referredBy], _customerAddress, 2);
            }
        }
      
	}	
	function invest(address referrer, uint8 plan,uint256 stackAmount) public  {
        require(stackAmount>0,"Amount must be greater then zero");
		require(plans[plan].time>0,"Invalid Plan");
		require(plans[plan].isActive,"Plan is not Active");

		User storage user = users[msg.sender];
		
		
		if (user.referrer == address(0)) {
			if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
				user.referrer = referrer;
			}

			address upline = user.referrer;
			for (uint256 i = 0; i < 2; i++) {
				if (upline != address(0)) {
					users[upline].levels[i] = users[upline].levels[i].add(1);
					upline = users[upline].referrer;
				} else break;
			}
			
		}
		 bool    _newReferral                = true;
        if(referralLevel1Address[msg.sender] != 0x0000000000000000000000000000000000000000) {
            referrer                     = referralLevel1Address[msg.sender];
            _newReferral                    = false;
        }
		
		distributeRef(referrer, msg.sender, _newReferral);
		uint256 refReards=0;
		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < 2; i++) {
				if (upline != address(0)) {
					uint256 amount = stackAmount.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
					refReards+=amount;
					token.safeTransferFrom(msg.sender,upline,amount);
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			emit Newbie(msg.sender);
		}

		user.deposits.push(Deposit(plan, stackAmount, block.timestamp));
		
        totalInvested = totalInvested.add(stackAmount);
        plans[plan].totalDeposit += stackAmount;
			
		uint256 fee = stackAmount.mul(LiquidityFees).div(100);
        uint256 depositedAmount = stackAmount.sub(fee).sub(refReards);
		token.safeTransferFrom(msg.sender,address(this),fee);
		token.safeTransferFrom(msg.sender,address(this),depositedAmount);		
		emit NewDeposit(msg.sender, plan, stackAmount);
	}

	function withdraw(uint8 plan) public {
		User storage user = users[msg.sender];

		uint256 totalAmount = getUserDividends(msg.sender,plan);
        uint256 totalDepositeAmount = getUserWithdrawAmount(msg.sender,plan);
		
		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = token.balanceOf(address(this));	
		require(contractBalance>=totalAmount,"Contract has not Insufficent Balance");
		if (contractBalance < totalAmount) {
			user.bonus = totalAmount.sub(contractBalance);
			user.totalBonus = user.totalBonus.add(user.bonus);
			totalAmount = contractBalance;
		}

		user.checkpoint = block.timestamp;
		user.withdrawn = user.withdrawn.add(totalAmount);

        if(totalDepositeAmount>0){
            token.safeTransfer(msg.sender,totalDepositeAmount);    

            for (uint256 i = 0; i < user.deposits.length; i++) {
                if(user.deposits[i].plan==plan){
                    user.deposits[i].amount = 0;				
                }
            } 
            totalInvested = totalInvested.sub(totalDepositeAmount);           
        }

		token.safeTransfer(msg.sender,totalAmount);
		emit Withdrawn(msg.sender, totalAmount);
	}

	function withdrwal(address _token,uint256 value ) public onlyAdmin{
        if(_token==address(0)){
            commissionWallet.transfer(address(this).balance);
        }else{
           token = IERC20(_token);
          token.safeTransfer(commissionWallet, value);
        }
    }
    
	function updateWallet(address payable _newWallet) public onlyAdmin{
		commissionWallet=_newWallet;
	}

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}
	

	function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent,bool isActive,uint256 totalDeposit) {
		time = plans[plan].time;
		percent = plans[plan].percent;
		isActive = plans[plan].isActive;
        totalDeposit = plans[plan].totalDeposit;
	}

    function getTotalPlans() public view returns(uint256){
        return plans.length;
    }

    function getUserWithdrawAmount(address userAddress,uint8 plan) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount=0;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			if(user.deposits[i].plan==plan){

				uint256 finish = user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(1 days));												
                uint256 to = finish < block.timestamp ? finish : block.timestamp;
                if (finish <= to) {
                    totalAmount += user.deposits[i].amount;
                }				
			}
		}

		return totalAmount;
	}

	function getUserDividends(address userAddress,uint8 plan) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount=0;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			if(user.deposits[i].plan==plan){

				uint256 finish = user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(1 days));
				if (user.checkpoint < finish) {
                    uint256 shareAmount = user.deposits[i].amount.mul(plans[user.deposits[i].plan].percent);
					uint256 share = shareAmount.div(PLANPER_DIVIDER);
					uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
					uint256 to = finish < block.timestamp ? finish : block.timestamp;
					if (from < to) {
                        uint256 shareMul = share.mul(to.sub(from).div(30));
						totalAmount = totalAmount.add(shareMul).div(TIME_STEP);
					}
				}
			}
		}

		return totalAmount;
	}


    function getUserPlanDeposit(address _useradress,uint8 plan) public view returns (uint256){
        User storage user = users[_useradress];
        uint256 totalAmount=0;
        for(uint256 i=0;i<user.deposits.length;i++){
            if(user.deposits[i].plan == plan){
                totalAmount += user.deposits[i].amount;
            }
        }
        return totalAmount;
    }
	
	
	function getUserTotalSeedWithdrawn(address userAddress) public view returns (uint256) {
		return users[userAddress].withdrawnseed;
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

	function getUserDownlineCount(address userAddress) public view returns(uint256[2] memory referrals) {
		return (users[userAddress].levels);
	}

	function getUserTotalReferrals(address userAddress) public view returns(uint256) {
		return users[userAddress].levels[0]+users[userAddress].levels[1];
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

	function getUserAvailable(address userAddress,uint8 plan) public view returns(uint256) {
		return getUserReferralBonus(userAddress).add(getUserDividends(userAddress,plan));
	}

	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 start, uint256 finish) {
	    User storage user = users[userAddress];

		plan = user.deposits[index].plan;
		percent = plans[plan].percent;
		amount = user.deposits[index].amount;
		start = user.deposits[index].start;
		finish = user.deposits[index].start.add(plans[user.deposits[index].plan].time.mul(1 days));
	}

	function getSiteInfo() public view returns(uint256 _totalInvested) {
		return(totalInvested);
	}

	function getUserInfo(address userAddress) public view returns(uint256 totalDeposit, uint256 totalWithdrawn, uint256 totalReferrals) {
		return(getUserTotalDeposits(userAddress), getUserTotalWithdrawn(userAddress), getUserTotalReferrals(userAddress));
	}

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
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