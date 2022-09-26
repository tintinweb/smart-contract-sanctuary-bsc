/**
 *Submitted for verification at BscScan.com on 2022-09-26
*/

pragma solidity 0.7.6;

 
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
    function allowance(address owner, address spender) external view returns (uint256);

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
// File: @openzeppelin/contracts/utils/Address.sol



pragma solidity 0.7.6;

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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
        return functionCall(target, data, "Address: low-level call failed");
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
        return functionCallWithValue(target, data, 0, errorMessage);
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol

pragma solidity 0.7.6;

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

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
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
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol

pragma solidity 0.7.6;
pragma abicoder v2;
/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
        return c;
    }
}

contract DeliveryGuy{
    
    address payable internal contractOwner;
	
    modifier onlyContractOwner() { 
        require(msg.sender == contractOwner, "onlyOwner"); 
        _; 
    }
	

	
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
 
    // array 
	
	
	address[][] public address_old;
	address[][] public address_new;	
    uint256[] private prices_of_levels =[3e16,5e16,9e16,15e16,21e16,31e16,42e16,56e16,74e16,1e18,2e18,4e18,8e18,16e18,32e18];

    uint256[] private percent_for_reciver =[50,55,60,65,70,50,55,60,70,60,65,70,75,75,75];

    //uint256 internal max_place = 2;  	
    uint256[] public now_place = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];   
    uint256[] public array_way = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];   
    struct User {
        uint id;
        address referrer;
        uint partnersCount;
        uint256 investCount;
        bool[15] activeLevels;
    }


  
    
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds;
    mapping(address => uint) public balances; 

    uint public lastUserId;
    address public id1;

    constructor(address _ownerAddress, address _developerAddress) {
        



        
        id1 = _ownerAddress;
        
        User memory user = User({
            id: 1,
            referrer: address(0),
            partnersCount: uint(0),
            investCount: uint256(0),
            activeLevels: [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]
        });
        
        users[_ownerAddress] = user;
        idToAddress[1] = _ownerAddress;
          
        
        userIds[1] = _ownerAddress;
        lastUserId = 2;
		
		for(uint i = 0; i <= 14; i++){
          address_new.push([_developerAddress,_ownerAddress]);
          delete address_new[i];
		}
		for(uint i = 0; i <= 14; i++){
          address_old.push([_developerAddress,_ownerAddress]);
		}			


        
        User memory user2 = User({
            id: 2,
            referrer: address(0),
            partnersCount: uint(0),
            investCount: uint256(0),
            activeLevels: [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]
        });
        
        users[_developerAddress] = user2;
        idToAddress[2] = _developerAddress;

        
        userIds[2] = _developerAddress;
        lastUserId = 3;

    }




	function get_user_levels(address user) public view returns (bool[15] memory) {
        bool[15] memory array_return = users[user].activeLevels;
        return (array_return);
    }
	
	
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function reverseArray(address[] memory _array) internal pure returns(address[] memory) {
        uint length = _array.length;
        address[] memory reversedArray = new address[](length);
        uint j = 0;
        for(uint i = length; i >= 1; i--) {
            reversedArray[j] = _array[i-1];
            j++;
        }
        return reversedArray;
    }
	
	
    function save_new_address_to_array(address _to, uint256 level) private  returns (address) {
		uint256 now_place_of=now_place[level];
        address address_resive;
        if (array_way[level]==1) {
	    	address_resive=address_old[level][now_place_of];
        }
        else{
            now_place_of=address_old[level].length-now_place[level]-1;
            address_resive=address_old[level][now_place_of];
        }
		address_new[level].push(address_resive);
		address_new[level].push(_to);
		now_place[level]++;
		if (now_place[level] == address_old[level].length) {
			address_old[level] = address_new[level];
			now_place[level] = 0;
			if (array_way[level]==1){
			 	array_way[level]=2;
			}
			else{
				array_way[level]=1;
			}
			delete address_new[level];

			
		}
        return address_resive;

    }
	
	function find_referal_of(address userAddress) public view returns (address){
       address res;
       res=users[userAddress].referrer;
       if (res==address(0)){
           res=userAddress;
       }
       return res;
      
    }


    function registration(address userAddress, address referrerAddress, uint256 value) private {
        //depositToken.safeTransferFrom(msg.sender, address(this), value);
        // require(msg.value == value, "invalid registration value");

        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
       // require(size == 0, "cannot be a contract");
        
        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
            partnersCount: 0,
            investCount: value,
            activeLevels: [false,false,false,false,false,false,false,false,false,false,false,false,false,false,false]
        });
        
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        
        users[userAddress].referrer = referrerAddress;
        
        userIds[lastUserId] = userAddress;
        lastUserId++;
        
        users[referrerAddress].partnersCount++;


        //sendETHDividends(userAddress, userAddress, value);
		
        //emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id , value);
    }
	


    receive() external payable {
        uint256 value;
        uint256 level;
        level =0;
        value = msg.value; 
        require(value!=0, "Zero transaction");
        for (uint i = 0 ; i < prices_of_levels.length; i++) { 
            if (value == prices_of_levels[i]) {
                level=i+1;
        }}
        require(level!=0, "no bnb on that level");
        level=level -1;

        require((prices_of_levels[level]==value), "BNB value sent is not correct"); 
        address referrerAddress;
        referrerAddress = id1;
		require(!users[msg.sender].activeLevels[level], "level already activated");
        require(level>=0, "level error");
        require(level<15, "level error");

		if (level>12) {
		    require(users[msg.sender].activeLevels[level-1], "buy previous level first");
        }
		if (!isUserExists(msg.sender)) {
            registration(msg.sender, referrerAddress, value);
		}
		address receiver = save_new_address_to_array(msg.sender,level);
		uint random_value= value*percent_for_reciver[level]/100;
     
		//counties = level_counties[level];
		send_referal_money(referrerAddress,value,level);
		transferEther(receiver, random_value);
		users[msg.sender].activeLevels[level]=true;

    }


    function Buing_level(address referrerAddress,uint256 level) external payable {
        uint256 value;
        level=level -1;
        value = msg.value; 
        require(value!=0, "Zero transaction");
        require((prices_of_levels[level]==value), "BNB value sent is not correct"); 


		require(!users[msg.sender].activeLevels[level], "level already activated");
        require(level>=0, "level error");
        require(level<15, "level error");

		if (level>12) {
		    require(users[msg.sender].activeLevels[level-1], "buy previous level first");
        }
		if (!isUserExists(msg.sender)) {
            registration(msg.sender, referrerAddress, value);
		}
		address receiver = save_new_address_to_array(msg.sender,level);
		uint random_value= value*percent_for_reciver[level]/100;
     
		//counties = level_counties[level];
		send_referal_money(find_referal_of(msg.sender),value,level);
		transferEther(receiver, random_value);
		users[msg.sender].activeLevels[level]=true;
        

    }
    
    function find_eth_reciver(address userAddress, uint256 value, uint256 level) private {
        if (users[userAddress].activeLevels[level]==false){
                find_eth_reciver(find_referal_of(userAddress),value,level);
        }
        else {
           		transferEther(userAddress, value);
        }

    }



    function send_referal_money(address referrerAddress, uint256 value, uint256 level) private {
       if (level==0){

           find_eth_reciver(referrerAddress,value*50/100,level);
           
       } 
       if (level==1){

           find_eth_reciver(referrerAddress,value*30/100,level);
           find_eth_reciver(find_referal_of(referrerAddress),value*15/100,level);
       } 
       if (level==2){

           find_eth_reciver(referrerAddress,value*25/100,level);
           find_eth_reciver(find_referal_of(referrerAddress),value*10/100,level);
           find_eth_reciver(find_referal_of(find_referal_of(referrerAddress)),value*5/100,level);
       } 
       if (level==3){

           find_eth_reciver(referrerAddress,value*150/1000,level);
           find_eth_reciver(find_referal_of(referrerAddress),value*100/1000,level);
           find_eth_reciver(find_referal_of(find_referal_of(referrerAddress)),value*75/1000,level);
           find_eth_reciver(find_referal_of(find_referal_of(find_referal_of(referrerAddress))),value*25/1000,level);
       } 
       if (level==4){

           find_eth_reciver(referrerAddress,value*10/100,level);
           find_eth_reciver(find_referal_of(referrerAddress),value*8/100,level);
           find_eth_reciver(find_referal_of(find_referal_of(referrerAddress)),value*6/100,level);
           find_eth_reciver(find_referal_of(find_referal_of(find_referal_of(referrerAddress))),value*4/100,level);
           find_eth_reciver(find_referal_of(find_referal_of(find_referal_of(find_referal_of(referrerAddress)))),value*2/100,level);
       } 
       if (level==5){

           find_eth_reciver(referrerAddress,value*30/100,level);
           find_eth_reciver(find_referal_of(referrerAddress),value*20/100,level);
       }
       if (level==6){

           find_eth_reciver(referrerAddress,value*30/100,level);
           find_eth_reciver(find_referal_of(referrerAddress),value*15/100,level);
       }
       if (level==7){

           find_eth_reciver(referrerAddress,value*200/1000,level);
           find_eth_reciver(find_referal_of(referrerAddress),value*100/1000,level);
           find_eth_reciver(find_referal_of(find_referal_of(referrerAddress)),value*75/1000,level);
           find_eth_reciver(find_referal_of(find_referal_of(find_referal_of(referrerAddress))),value*25/1000,level);
       } 
       if (level==8){

           find_eth_reciver(referrerAddress,value*10/100,level);
           find_eth_reciver(find_referal_of(referrerAddress),value*8/100,level);
           find_eth_reciver(find_referal_of(find_referal_of(referrerAddress)),value*6/100,level);
           find_eth_reciver(find_referal_of(find_referal_of(find_referal_of(referrerAddress))),value*4/100,level);
           find_eth_reciver(find_referal_of(find_referal_of(find_referal_of(find_referal_of(referrerAddress)))),value*2/100,level);
       } 
       if (level==9){

           find_eth_reciver(referrerAddress,value*25/100,level);
           find_eth_reciver(find_referal_of(referrerAddress),value*15/100,level);
       }
       if (level==10){

           find_eth_reciver(referrerAddress,value*15/100,level);
           find_eth_reciver(find_referal_of(referrerAddress),value*10/100,level);
           find_eth_reciver(find_referal_of(find_referal_of(referrerAddress)),value*5/100,level);
       } 
       if (level==11){

           find_eth_reciver(referrerAddress,value*12/100,level);
           find_eth_reciver(find_referal_of(referrerAddress),value*9/100,level);
           find_eth_reciver(find_referal_of(find_referal_of(referrerAddress)),value*6/100,level);
           find_eth_reciver(find_referal_of(find_referal_of(find_referal_of(referrerAddress))),value*4/100,level);
       } 
       if (level==12){

           find_eth_reciver(referrerAddress,value*7/100,level);
           find_eth_reciver(find_referal_of(referrerAddress),value*6/100,level);
           find_eth_reciver(find_referal_of(find_referal_of(referrerAddress)),value*5/100,level);
           find_eth_reciver(find_referal_of(find_referal_of(find_referal_of(referrerAddress))),value*4/100,level);
           find_eth_reciver(find_referal_of(find_referal_of(find_referal_of(find_referal_of(referrerAddress)))),value*3/100,level);
       } 
       if (level==13){

           find_eth_reciver(referrerAddress,value*7/100,level);
           find_eth_reciver(find_referal_of(referrerAddress),value*6/100,level);
           find_eth_reciver(find_referal_of(find_referal_of(referrerAddress)),value*5/100,level);
           find_eth_reciver(find_referal_of(find_referal_of(find_referal_of(referrerAddress))),value*4/100,level);
           find_eth_reciver(find_referal_of(find_referal_of(find_referal_of(find_referal_of(referrerAddress)))),value*3/100,level);
       } 
       if (level==14){

           find_eth_reciver(referrerAddress,value*7/100,level);
           find_eth_reciver(find_referal_of(referrerAddress),value*6/100,level);
           find_eth_reciver(find_referal_of(find_referal_of(referrerAddress)),value*5/100,level);
           find_eth_reciver(find_referal_of(find_referal_of(find_referal_of(referrerAddress))),value*4/100,level);
           find_eth_reciver(find_referal_of(find_referal_of(find_referal_of(find_referal_of(referrerAddress)))),value*3/100,level);
       } 
    }

    function transferEther(address receiverAdr, uint256 value) private { 
        address payable receiverAdrpay = payable(receiverAdr);
        receiverAdrpay.transfer(value);
    }
}