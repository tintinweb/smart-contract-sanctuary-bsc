/**
 *Submitted for verification at BscScan.com on 2022-04-17
*/

pragma solidity ^0.6.0;


abstract contract Context {
	function _msgSender() internal view virtual returns (address payable) {
		return msg.sender;
	}

	function _msgData() internal view virtual returns (bytes memory) {
		this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
		return msg.data;
	}
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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

// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity ^0.6.0;
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
		require(c >= a, "SafeMath: addition overflow");

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
		return sub(a, b, "SafeMath: subtraction overflow");
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
	function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
		require(c / a == b, "SafeMath: multiplication overflow");

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
		return div(a, b, "SafeMath: division by zero");
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
	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
		return mod(a, b, "SafeMath: modulo by zero");
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
	function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b != 0, errorMessage);
		return a % b;
	}
}

// File: @openzeppelin/contracts/utils/Address.sol

pragma solidity ^0.6.2;
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
		// This method relies in extcodesize, which returns 0 for contracts in
		// construction, since the code is only stored at the end of the
		// constructor execution.

		uint256 size;
		// solhint-disable-next-line no-inline-assembly
		assembly { size := extcodesize(account) }
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

		// solhint-disable-next-line avoid-low-level-calls, avoid-call-value
		(bool success, ) = recipient.call{ value: amount }("");
		require(success, "Address: unable to send value, recipient may have reverted");
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
	  return functionCall(target, data, "Address: low-level call failed");
	}

	/**
	 * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
	 * `errorMessage` as a fallback revert reason when `target` reverts.
	 *
	 * _Available since v3.1._
	 */
	function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
	function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
		return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
	}

	/**
	 * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
	 * with `errorMessage` as a fallback revert reason when `target` reverts.
	 *
	 * _Available since v3.1._
	 */
	function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
		require(address(this).balance >= value, "Address: insufficient balance for call");
		return _functionCallWithValue(target, data, value, errorMessage);
	}

	function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
		require(isContract(target), "Address: call to non-contract");

		// solhint-disable-next-line avoid-low-level-calls
		(bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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


// File: @openzeppelin/contracts/access/Ownable.sol
pragma solidity ^0.6.0;
contract Ownable is Context {
	address private _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	/**
	 * @dev Initializes the contract setting the deployer as the initial owner.
	 */
	constructor () internal {
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

	/**
	 * @dev Throws if called by any account other than the owner.
	 */
	modifier onlyOwner() {
		require(_owner == _msgSender(), "Ownable: caller is not the owner");
		_;
	}

	/**
	 * @dev Leaves the contract without owner. It will not be possible to call
	 * `onlyOwner` functions anymore. Can only be called by the current owner.
	 *
	 * NOTE: Renouncing ownership will leave the contract without an owner,
	 * thereby removing any functionality that is only available to the owner.
	 */
	function renounceOwnership() public virtual onlyOwner {
		emit OwnershipTransferred(_owner, address(0));
		_owner = address(0);
	}

	/**
	 * @dev Transfers ownership of the contract to a new account (`newOwner`).
	 * Can only be called by the current owner.
	 */
	function transferOwnership(address newOwner) public virtual onlyOwner {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}


pragma solidity ^0.6.12;

contract Matrix_Landing is Ownable {
    using SafeMath for uint256;
	using Address for address;

    struct UserInfo { 
        address _address;
        address _sponsor;
		bool  _active;
        // address[] _listReferrals;
        uint256[10] _memberOfLevel;
    }
	
    IERC20 public _token;
	address public _holderToken;
	uint256 public _packagePrice;  // token pre-sale price in BNB
	uint[10] private _refPercent;
    mapping(address => UserInfo) public _allUser;
	mapping(address => address[]) private _listReferrals;

	uint256 public _endSaleBlock ;
	// uint[4] public _openBlockArr;
    // mapping(address => uint256) public buyed_PreSale;
    
    constructor(IERC20 tokenSale, uint256 packagePrice) public {
        _token = tokenSale;
		_holderToken = msg.sender;
		_packagePrice = packagePrice ;
		_refPercent[0] = 25;
		_refPercent[1] = 20;
		_refPercent[2] = 10;
		_refPercent[3] = 5;
		_refPercent[4] = 5;
		_refPercent[5] = 5;
		_refPercent[6] = 5;
		_refPercent[7] = 5;
		_refPercent[8] = 5;
		_refPercent[9] = 10;
		_endSaleBlock = block.timestamp;
		// _openBlockArr[0] = _endSaleBlock.add(500);
		// _openBlockArr[1] = _endSaleBlock.add(1500);
		// _openBlockArr[2] = _endSaleBlock.add(2000);
		// _openBlockArr[3] = _endSaleBlock.add(2500);
	}

    function DoRegister(address ref_Address) public {
		require(ref_Address != msg.sender, "Invalid referral");

		uint256 senderAllow = _token.allowance(address(msg.sender), address(this));
		require(senderAllow >= _packagePrice, "Invalid allowance from sender");
		_token.transferFrom(address(msg.sender), address(this), _packagePrice);
        
		_loopRef(msg.sender, ref_Address, 1);
		
    }

	function doAddFamily(address sender, UserInfo memory parent, uint256 level) internal {
		parent._memberOfLevel[level - 1] = parent._memberOfLevel[level - 1]  + 1;
		if(parent._address != address(0) ){
			uint256 bonusAmount = _packagePrice.mul(_refPercent[level - 1]).div(100) ;
			_token.transfer(parent._address, bonusAmount);
		}
		//event AddFamily
		emit AddFamily(parent._address, sender, level);
	}

	function _loopRef(address sender, address ref_Address, uint256 level) internal {
		UserInfo storage parent = _allUser[ref_Address];
		if(level == 1){
			UserInfo storage user = _allUser[sender];
			require (user._active == false , "You are already registered");
			user._address = sender;
			user._active = true;
			user._sponsor = ref_Address;

			_listReferrals[parent._address].push(user._address);

			doAddFamily(sender, parent, level);
			// parent._level1 = parent._level1 + 1;
			// uint256 bonusAmount = _packagePrice.mul(_refPercent[level - 1]).div(100) ;
			// _token.transfer(ref_Address, bonusAmount);

			// emit AddFamily(ref_Address, sender, level);
		}else{
			doAddFamily(sender, parent, level);
		}
		
		if(parent._sponsor == address(0))
		{
			uint256 balance = _token.balanceOf(address(this));
			// _token.transfer(this.owner(), balance);
			_token.transfer(_holderToken, balance);
			return;
		}else{
			_loopRef(sender, parent._sponsor, level + 1);
		}
	}

	function getListReferrals (address user) public view returns(address[] memory){
		return _listReferrals[user];
	}

	function getRefPercent () public view returns(uint[10] memory){
		return _refPercent;
	}

	function getTestToken(uint256 _amount) public returns(bool) {
		uint256 poolBalance = _token.balanceOf(address(this));
		require(poolBalance >= _amount, "Pool out of token");
		bool status = _token.transfer(msg.sender, _amount);
		require(status == true, "Pool send token error");
		return status;
	}

	function setPackagePrice(uint256 _price) public onlyOwner {
		_packagePrice = _price ;
	}

	function setHolderToken(address _newHolder) public onlyOwner {
		_holderToken = _newHolder ;
	}

	event Register(address indexed user, uint256 amount);
	event AddFamily(address indexed user, address indexed child, uint256 level);


	// function buy_PreSale(address payable ref_Address) public payable {
	// 	require(_endSaleBlock > block.number , "Pre sale ended .");
		
	// 	uint256 totalToken = msg.value.div(_tokenPrice);
	// 	_tokenPresale.mintFrozenTokens(address(msg.sender), totalToken * 10 ** 18 );
	// 	// _tokenPresale.meltTokens(address(msg.sender), (totalToken * 10 ** 18).mul(20).div(100) );

	// 	address payable hello = payable(this.owner());
	// 	if(ref_Address != address(0) && buyed_PreSale[ref_Address] > 0){
	// 		_tokenPresale.mintFrozenTokens(address(ref_Address), (totalToken * 10 ** 18).mul(10).div(100) );
	// 		_tokenPresale.meltTokens(address(ref_Address), (totalToken * 10 ** 18).mul(10).div(100) );
	// 		ref_Address.transfer(msg.value.mul(10).div(100));
	// 		hello.transfer(msg.value.mul(90).div(100));
	// 	}else{
			
	// 		hello.transfer(msg.value);
	// 	}
	// 	buyed_PreSale[msg.sender] = totalToken;
	// 	emit Buy_PreSale(ref_Address, totalToken);
	// }    
 
    // event Buy_PreSale(address indexed user, uint256 amount);

}