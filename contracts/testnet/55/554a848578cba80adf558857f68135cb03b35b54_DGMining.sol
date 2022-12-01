/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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


/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}

contract DGMining {

    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;
    IBEP20 public bepToken;

    uint256 private _rate;
    address public owner;
    address payable public master_wallet;      	
	
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
	event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

	constructor(uint256 rate,address payable _master,address _token) { 
				
		require(!isContract(_master));	
		        
		owner = msg.sender;
        _rate = rate;
		master_wallet = _master;
		bepToken =IBEP20(_token);		
		       		
		currUserID = 0;
		currUserID++;
		users[master_wallet].id = currUserID;	
		users[master_wallet].sponsorid=0;	
		users[master_wallet].curRank = 1;	
		users[master_wallet].totalReserveRewardAmt = 0;	
		users[master_wallet].rankStatus = 1;		
	    users[master_wallet].depositTime =block.timestamp;	
		users[master_wallet].checkpoint = block.timestamp;		
		
		userList[currUserID] = master_wallet; 
		TotalMembers = TotalMembers.add(1);	 		

	}

	function _msgSender() internal view returns (address) {
        return msg.sender;
    }
	modifier OnlyOwner() {
        require(msg.sender == owner);
        _;
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


    function buyTokens() public payable {
       
        uint256 weiAmount = msg.value;
        uint256 tokens = weiAmount.mul(_rate).div(100);
        address beneficiary=msg.sender;
		forwardtokens(beneficiary,tokens);

        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);

        
    }
	

	function dGSignup(address sponsorUpline,uint256[] memory refComs,uint256[] memory levComUrs) public payable {
		
		require(users[sponsorUpline].id > 0,"Incorrect referrer wallet address"); 	      
		require(users[msg.sender].id <= 0,"Please enter your correct wallet address");   		
						        		
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
	    users[msg.sender].depositTime =block.timestamp;	
		users[msg.sender].checkpoint = block.timestamp;		


		userList[currUserID] = msg.sender; 
								
		TotalMembers = TotalMembers.add(1);		
		TotalJoiningAmount = TotalJoiningAmount.add(msg.value);	
		TotalRewardAmount=TotalRewardAmount.add(msg.value.mul(tokenBalance).div(percentDiv));			
		
			
	   //Direct Referral or Spill Over Commission
        if(uplineuser.referralCount<=2){		 
		   address senderAddr = address(uint160(sponsorUpline));
           payable(senderAddr).transfer(dirrefcom);
		   uplineuser.binaryIncome=uplineuser.binaryIncome.add(dirrefcom);
		   uplineuser.totalcommisions=uplineuser.totalcommisions.add(dirrefcom);

		   TotalBinaryCommission=TotalBinaryCommission.add(dirrefcom);
		   TotalCommissions=TotalCommissions.add(dirrefcom);	

	    } else {
           address senderAddr = address(uint160(sponsorUpline));
           payable(senderAddr).transfer(spilloverrefcom);
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
	
        uint256 weiAmount = msg.value;
        uint256 tokens = weiAmount.mul(_rate).div(100);
        address beneficiary=msg.sender;
		forwardtokens(beneficiary,tokens);

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
		
		    address uplineAddr = address(uint160(upline));
            payable(uplineAddr).transfer(com_amount);	

			TotalSingleLineCommission=TotalSingleLineCommission.add(com_amount);

		    emit sLLevelCommission(upline, senderaddress, com_amount,i);  
			    
		  }		  

       }
    }

	function withdrawEarnings() requireUser public {               	      
	     (uint256 to_payout) = this.payoutOf(msg.sender);          
           
           require(to_payout > 0, "Limit not available");

			address senderAddr = address(uint160(msg.sender));
            payable(senderAddr).transfer(to_payout);				
           
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

		address senderAddr = address(uint160(msg.sender));
        payable(senderAddr).transfer(amount);       

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

	function balance() public view returns (uint256) {
       return bepToken.balanceOf(address(this));
    }

	function forwardtokens(address beneficiary,uint256 token_value) internal {
       // if(!bepToken.transfer(beneficiary,token_value)){
            bepToken.safeTransfer(beneficiary,token_value);
        //}
    }
     
    function forwardFunds() internal {
        payable(owner).transfer(msg.value);
    }

    function withdraw() external OnlyOwner {
        require(address(this).balance > 0, 'Contract has no money');
        payable(owner).transfer(address(this).balance);
    }

    function setTokenContract(address _contract) OnlyOwner public{     
        bepToken = IBEP20(_contract);
    } 
  
    function getTokenContract() public view returns(IBEP20){
      return bepToken;
    }
}