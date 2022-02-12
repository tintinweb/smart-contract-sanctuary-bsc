/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function mint(address account, uint amount) external;
}

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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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


library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success,) = recipient.call{value : amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }


    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }


    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value : weiValue}(data);
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
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {// Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// MasterChef is the master of Good. He can make Good and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once Good is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract Lockup{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    mapping(address => bool) public manager;
    

    address public lp = 0x0B57b70ff25C2B4B93E9AfC814c6858E4Ed7A0Be;   
	
	uint256 public totalSupply;
	uint256 public lockTime;
	
	struct UserInfo{
		uint256 lastTime;
		uint256 lpAmount;
	}
    mapping(address => UserInfo) public userMap;
	mapping(address => mapping(address => uint256)) public profit;
	
	address[] public userGroup;
	uint256 public userLength;
	
	
	event WithdrawLp(address user, uint256 lpAmount);
	event Lockin(address user, uint256 lpAmount);
	event Withdraw(address user, address _contract , uint256 amount);
	
    constructor() public {
        manager[msg.sender] = true;   
		lockTime = 15 * 86400;
    }
    
    receive() external payable {
	}
	
    function setManger(address addr, bool stauts) public onlyOwner{
        manager[addr] = stauts;
    }
    
    function withdraw(address _contract) public onlyOwner{
       uint256 amount = profit[msg.sender][_contract];
	   profit[msg.sender][_contract] = 0;
	   IERC20(_contract).transfer(msg.sender,amount);
	   emit Withdraw(msg.sender,_contract,amount);
	   
    }
	
	function withdrawLp() public {
        require(block.timestamp > userMap[msg.sender].lastTime.add(lockTime), "time not yet");
		uint256 bal = userMap[msg.sender].lpAmount;
		userMap[msg.sender].lpAmount = 0;
		totalSupply = totalSupply.sub(bal);
		(bool isIn, uint256 index) = firstIndexOf(userGroup,msg.sender);
        if(isIn){
          removeByIndex(index);
		  userLength--;
        }
        IERC20(lp).transfer(msg.sender, bal);		
		emit WithdrawLp(msg.sender,bal);
    }
    
    function lockin(uint256 _lpAmount) public returns(bool){
        IERC20(lp).transferFrom(msg.sender, address(this), _lpAmount);
		userMap[msg.sender].lpAmount = userMap[msg.sender].lpAmount.add(_lpAmount);
		(bool isUserIn, ) = firstIndexOf(userGroup,msg.sender);
		
        if(!isUserIn){
			(bool isIn, uint256 index) = firstIndexOf(userGroup,address(0));	
			if(isIn){
				userGroup[index] = msg.sender;
				userLength++;
			}else{
				userGroup.push(msg.sender);
				userLength++;
			}
        }
		
		userMap[msg.sender].lastTime = block.timestamp;
		totalSupply = totalSupply.add(_lpAmount);
		emit Lockin(msg.sender,_lpAmount);
		
    }

	
    function grant(address _contract, uint256 amount)external onlyOwner{
        uint256 currentProfit;
		address currentAddress;
		for(uint256 i= 0; i< userLength; i++){
			currentAddress = userGroup[i];
			if(userMap[currentAddress].lpAmount > 0 ){
				currentProfit = amount.mul(userMap[currentAddress].lpAmount).div(totalSupply);
				profit[currentAddress][_contract] = profit[currentAddress][_contract].add(currentProfit);
			}
		}
	
	}
	

	
	function firstIndexOf(address[] memory array, address key) internal pure returns (bool, uint256) {

    	if(array.length == 0){
    		return (false, 0);
    	}

    	for(uint256 i = 0; i < array.length; i++){
    		if(array[i] == key){
    			return (true, i);
    		}
    	}
    	return (false, 0);
    }

	function removeByIndex(uint256 index) internal{
    	require(index < userGroup.length, "ArrayForUint256: index out of bounds");
        userGroup[index] = userGroup[userLength - 1];
        delete userGroup[userLength - 1] ;
		
    }
	
    
    function setlp(address _lp) public onlyOwner{
        lp =_lp;
    }
    
    function setLockTime(uint256 _lockTime) public onlyOwner{
        lockTime = _lockTime;
    }
	
	function CrossTransfer(IERC20 token, address to , uint256 amount) public onlyOwner {
        require(address(token) !=  lp, "Can't withdraw");
        uint256 tokenamount = token.balanceOf(address(this));
        require(tokenamount > amount, "no tokens to release");
        token.safeTransfer(to, amount);
    }
  
    function PayTransfer(address payable recipient) public onlyOwner {
        recipient.transfer(address(this).balance);
   }
    
    modifier onlyOwner {
        require(manager[msg.sender] == true);
        _;
    }
}