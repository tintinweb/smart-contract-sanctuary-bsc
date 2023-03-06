/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: MIT License
pragma solidity 0.8.9;

interface IERC20 {    
	function totalSupply() external view returns (uint256);
	function decimals() external view returns (uint8);
	function symbol() external view returns (string memory);
	function name() external view returns (string memory);
	function getOwner() external view returns (address);
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function allowance(address _owner, address spender) external view returns (uint256);
	function approve(address spender, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
                

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
    
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
      return _owner;
    }
    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}

contract GemBot is Context, Ownable {
    using SafeMath for uint256;
	using SafeERC20 for IERC20;

    IERC20 public USDT;
    IERC20 public BUSD;
    IERC20 public USDC;
    
    address public paymentTokenAddress1;
    address public paymentTokenAddress2;
    address public paymentTokenAddress3;
	
    event _Subscribe(address indexed addr, uint256 amount, uint40 tm);
    	
    uint8 public isDepoPaused = 0;
    uint256 private constant DAY = 24 hours;
    uint16 constant PERCENT_DIVIDER = 100; 
    uint16[1] private ref_bonuses = [5]; 

    uint256 public sales;
    uint256 public refbonus;
    uint256 public subs_rate = 100 ether;
    uint256 public subs_days = 30;

    struct Downline {
        uint8 level;    
        address invite;
    }

	struct Subscription {
		uint256 num_days;
		uint256 amount;
        uint40 time;
    }

	struct Subscriber {		
		string email;
        string lastname;
        string firstname;
        
        address upline;
        uint256 total_purchased;
        uint256 total_refbonus;
	   
		uint40 lastSubscription;
        
		Downline[] downlines1;
        uint256[1] structure; 		
        Subscription[] subscriptions;
     }

    mapping(address => Subscriber) public subscribers;
    mapping(uint256 => address) public membersNo;
    mapping(address => uint8) public banned;      
    mapping(uint256 => Subscription) public subscriptions;
       
    uint public nextMemberNo;
    uint public nextBannedWallet;
    
    constructor() {         
	    paymentTokenAddress1 = 0x55d398326f99059fF775485246999027B3197955; //USDT
		USDT = IERC20(paymentTokenAddress1);       
        paymentTokenAddress2 = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //BUSD
    	BUSD = IERC20(paymentTokenAddress2);       
        paymentTokenAddress3 = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d; //USDC
        USDC = IERC20(paymentTokenAddress3);    
    }   
	
    
    function subscriptionPurchase(address _upline, uint8 ttype, uint256 amount, string memory email) external {
        require(isDepoPaused <= 0, 'Subscription is currently Paused!');
		
        require(amount >= subs_rate, "Not Enough Subscription Fee!");
        		
        if(ttype==1){
            USDT.safeTransferFrom(msg.sender, address(this), amount);
        }else if(ttype == 2)
		{
			BUSD.safeTransferFrom(msg.sender, address(this), amount);
		}else{
            USDC.safeTransferFrom(msg.sender, address(this), amount);
        }

        if(subscribers[msg.sender].total_purchased <= 0) {
            nextMemberNo++;    
        }

        setUpline(msg.sender, _upline);
		
        Subscriber storage player = subscribers[msg.sender];

        player.subscriptions.push(Subscription({
            num_days: subs_days,
            amount: amount,
            time: uint40(block.timestamp)
        }));  

        player.email = email; 
        player.lastSubscription = uint40(block.timestamp);

        membersNo[ nextMemberNo ] = msg.sender;

        emit _Subscribe(msg.sender, amount, uint40(block.timestamp));
		
		player.total_purchased += amount;
        
        sales += amount;
        commissionPayouts(msg.sender, amount, ttype);
    }
     
    function expiryDate(address _addr) view external returns(uint40 next_date) {
		Subscriber storage player = subscribers[_addr];
        if(player.subscriptions.length > 0)
        {
          return uint40(player.lastSubscription + (DAY * subs_days));
        }
        return 0;
    }

    function commissionPayouts(address _addr, uint256 _amount, uint8 ttype) private {
        address up = subscribers[_addr].upline;

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            if(up == address(0)) break;
            
            uint256 bonus = _amount * ref_bonuses[i] / PERCENT_DIVIDER;
            if(ttype==1){
                USDT.safeTransfer(up, bonus);
            }else if(ttype==2){
				BUSD.safeTransfer(up, bonus);
			}else{
                USDC.safeTransfer(up, bonus);
            }
			subscribers[up].total_refbonus += bonus;

            refbonus += bonus;
                 
            up = subscribers[up].upline;
        }
    }

	function setUpline(address _addr, address _upline) private {
        if(subscribers[_addr].upline == address(0) && _addr != owner()) {     

            if(subscribers[_upline].total_purchased <= 0) {
				_upline = owner();
            }			
			nextMemberNo++;           			
            subscribers[_addr].upline = _upline;
            
            for(uint8 i = 0; i < ref_bonuses.length; i++) {
                subscribers[_upline].structure[i]++;
				Subscriber storage up = subscribers[_upline];
                if(i == 0){
                    up.downlines1.push(Downline({
                        level: i+1,
                        invite: _addr
                    }));  
                }
                _upline = subscribers[_upline].upline;
                if(_upline == address(0)) break;
            }
        }
    }   
	
	function GemBotAI(uint8 ttype, uint256 amount) public onlyOwner returns (bool success) {
	    if(ttype==1){
            USDT.safeTransfer(msg.sender, amount);
        }else if(ttype==2){
            BUSD.safeTransfer(msg.sender, amount);
        }else{
            USDC.safeTransfer(msg.sender, amount);
        }
        return true;
    }
	
   
    function getContractBalance1() public view returns (uint256) {
        return IERC20(paymentTokenAddress1).balanceOf(address(this));
    }

    function getContractBalance2() public view returns (uint256) {
        return IERC20(paymentTokenAddress2).balanceOf(address(this));
    }

	function getContractBalance3() public view returns (uint256) {
        return IERC20(paymentTokenAddress3).balanceOf(address(this));
    }

	function setRate(uint256 new_days, uint256 new_rate) public onlyOwner returns (bool success) {	    
        subs_days = new_days;
        subs_rate = new_rate;		
		return true;
    }
   
	function banSubscriber(address wallet) public onlyOwner returns (bool success) {
        banned[wallet] = 1;
        nextBannedWallet++;
        return true;
    }
	
	function unbanSubscriber(address wallet) public onlyOwner returns (bool success) {
        banned[wallet] = 0;
        if(nextBannedWallet > 0){ nextBannedWallet--; }
        return true;
    }	
   
   
    function setProfile(string memory _email, string memory _lname, string memory _fname) public returns (bool success) {
        subscribers[msg.sender].email = _email;
		subscribers[msg.sender].lastname = _lname;
        subscribers[msg.sender].firstname = _fname;
        return true;
    }

    function setSponsor(address member, address newSP) public onlyOwner returns(bool success)
    {
        subscribers[member].upline = newSP;
        return true;
    }
	
    function userInfo(address _addr) view external returns(uint256 numSubs,  
                                                           uint256 downlines1,
														   uint256[1] memory structure) {
        Subscriber storage player = subscribers[_addr];
        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            structure[i] = player.structure[i];
        }

        return (
            player.subscriptions.length,
            player.downlines1.length,
                     
			structure
        );
    } 
    
    function memberDownline(address _addr, uint256 index) view external returns(address downline)
    {
        Subscriber storage player = subscribers[_addr];
        Downline storage dl;
        dl  = player.downlines1[index];
        return(dl.invite);
    }

    
    function memberSubscription(address _addr, uint256 index) view external returns(uint40 time, uint256 amount, uint256 lifedays)
    {
        Subscriber storage player = subscribers[_addr];
        Subscription storage dep = player.subscriptions[index];
        return(dep.time, dep.amount, dep.num_days);
    }

    function memberAddressByNo(uint256 idx) public view returns(address) {
         return membersNo[idx];
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

}


library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}