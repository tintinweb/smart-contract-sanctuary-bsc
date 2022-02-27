/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

/*
********************************************************************************************
** RizxCoin Token Smart Contract ***********************************************************
********************************************************************************************
** https://rizxcoin.com ********************************************************************
********************************************************************************************
********************************************************************************************
********************************************************************************************
*/

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
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

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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

/*******************************************
 * RizxCoin Token
 *******************************************
*/

contract RizxCoin is Ownable, IERC20 {
	using SafeMath for uint256;
	using Address for address;

	mapping (address => mapping (address => uint256)) private _allowances;

	string public name = 'RizxCoin';
    string public symbol = 'RXC';
    uint8 public decimals = 9;

	struct Holder {
        uint256 token;
		uint timestamp;
    }

	struct HolderInformation {
		address wallet;
        uint256 token;
		uint timestamp;
    }

    mapping (address => Holder) internal _balances;
	mapping (address => bool) internal _exchanges;
    mapping (address => bool) internal _internalBots;

	uint256 public rewardFee;
	uint256 public devTeamFee;
	uint256 public marketingTeamFee;

	address public devTeamAddress = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
	address public marketingTeamAddress = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
	address public rewardsAddress = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;

	uint256 internal _totalSupply;

	event FeesChanged(
        uint256 rewardFee,
        uint256 devTeamFee,
        uint256 marketingTeamFee
    );

	event TeamAddressChanged(
        address teamAddress,
		string addressType
    );

	constructor() {
		_totalSupply = 55000 * 10**6 * 10**9;

		_balances[_msgSender()].token = _totalSupply;
		_balances[_msgSender()].timestamp = block.timestamp;

		emit Transfer(address(0), _msgSender(), _totalSupply);
	}

	/*******************************************
	* IERC20: Implementation
	********************************************
	*/

	function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

	function balanceOf(address account) public view override returns (uint256)  {
		return _balances[account].token;
    }

	function transfer(address recipient, uint256 amount) public override returns (bool) {
		 _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "Transfer amount exceeds allowance"));
        return true;
    }

	/*******************************************
	* RizxCoin: Customization
	********************************************
	*/

	function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

	function _transfer(address sender, address recipient, uint256 amount) private {
		bool isBot = _internalBots[sender] || _internalBots[recipient];

		if(!isBot) {
			if(_buyTx(sender)) {
				(uint256 rewardAmount, uint256 devTeamAmount, uint256 ownerAmount) = _getBuyAmounts(amount);

				_standardTransfer(sender, rewardsAddress, rewardAmount);
				_standardTransfer(sender, devTeamAddress, devTeamAmount);
				amount = ownerAmount;
			}

			if(_saleTx(recipient)) {
				(uint256 rewardAmount, uint256 marketingTeamAmount, uint256 ownerAmount) = _getSaleAmounts(amount);

				_standardTransfer(sender, rewardsAddress, rewardAmount);
				_standardTransfer(sender, marketingTeamAddress, marketingTeamAmount);
				amount = ownerAmount;
			}
		}

		_setHoldDate(sender, recipient);
		_standardTransfer(sender, recipient, amount);
	}

	// Standard transfer
	function _standardTransfer(address sender, address recipient, uint256 amount) private {
		if(amount == 0)
			return;

		_balances[sender].token = _balances[sender].token.sub(amount, "transfer amount exceeds balance");
		_balances[recipient].token = _balances[recipient].token.add(amount);

		emit Transfer(sender, recipient, amount);
	}

	// Return Holder Information: Token Balance and how long has he been holding
	function holderInformation(address account) public view returns (uint256, uint)  {
		return (_balances[account].token, _balances[account].timestamp);
    }

	// Return Several Holder Information: Token Balance and how long has he been holding
	function bulkHolderInformation(address[] memory accounts) public view returns (HolderInformation[] memory)  {
		HolderInformation[] memory tmp = new HolderInformation[](accounts.length);

        for (uint i = 0; i < accounts.length; i++) {
            tmp[i].token = _balances[accounts[i]].token;
            tmp[i].timestamp = _balances[accounts[i]].timestamp;
            tmp[i].wallet = accounts[i];
        }

        return tmp;
    }

	/*******************************************
	* MetaNFT: Fees and Team Administration
	********************************************
	*/

	// Change Fees
	function changeFees(uint256 rFee, uint256 dFee, uint256 mFee) public onlyOwner()  {
		require(rFee >= 0, "Reward fee can't be < 0");
		require(dFee >= 0, "Dev team fee can't be < 0");
		require(mFee >= 0, "Marketing team fee can't be < 0");
		require((rFee + dFee) <= 8, "Reward and Dev fees can't be > 8");
		require((rFee + mFee) <= 14, "Reward and Marketing fees can't be > 14");

		rewardFee = rFee;
		devTeamFee = dFee;
		marketingTeamFee = mFee;

		emit FeesChanged(rewardFee, devTeamFee, marketingTeamFee);
    }

	// Change Dev Team Address
	function changeDevTeamAddress(address dAddress) public onlyOwner()  {
        require(dAddress != address(0), "DevTeam address can't be the zero address");
		devTeamAddress = dAddress;

		emit TeamAddressChanged(devTeamAddress, "Dev Team");
    }

	// Change Marketing Team Address
	function changeMarketingTeamAddress(address mAddress) public onlyOwner()  {
		require(mAddress != address(0), "MarketingTeam address can't be the zero address");
		marketingTeamAddress = mAddress;

		emit TeamAddressChanged(marketingTeamAddress, "Marketing Team");
    }

	// Change Rewards Team Address
	function changeRewardsTeamAddress(address rAddress) public onlyOwner()  {
        require(rAddress != address(0), "Reward address can't be the zero address");
		rewardsAddress = rAddress;

		emit TeamAddressChanged(rewardsAddress, "Rewards");
    }

	/*******************************************
	* RizxCoin: Exchanges and Bot Administration
	********************************************
	*/

	// Change Internal Bots
	function changeInternalBots(address account, bool isbot) public onlyOwner()  {
        require(account != address(0), "Internal bot address can't be the zero address");

        _internalBots[account] = isbot;
    }

	// Change Exchange Address
	function changeExchange(address account, bool isExchange) public onlyOwner()  {
        require(account != address(0), "Exchange address can't be the zero address");

        _exchanges[account] = isExchange;
    }


	/*******************************************
	* RizxCoin: Private management
	********************************************
	*/

	// Is It Buy Transaction ? from an exchange to a holder
	function _buyTx(address account) internal view returns(bool) {
        return _exchanges[account];
    }

	// Is It Sale Transaction ? from a holder to an exchange
	function _saleTx(address account) internal view returns(bool) {
        return _exchanges[account];
    }

	// Set Hold Date
	function _setHoldDate(address sender, address recipient) internal {
		if(_balances[recipient].timestamp == 0)
			_balances[recipient].timestamp = block.timestamp;

		_balances[sender].timestamp = block.timestamp;
    }

	// Get amounts from a buy transaction
	function _getBuyAmounts(uint256 amount) internal view returns(uint256, uint256, uint256) {
		if(rewardFee == 0)
			return (0, 0, amount);

		uint256 rewardAmount = amount.mul(rewardFee).div(100);
		uint256 devTeamAmount = amount.mul(devTeamFee).div(100);
        uint256 ownerAmount = amount.sub(rewardAmount + devTeamAmount);

		return (rewardAmount, devTeamAmount, ownerAmount);
	}

	// Get amounts from a sale transaction
	function _getSaleAmounts(uint256 amount) internal view returns(uint256, uint256, uint256) {
		if(rewardFee == 0)
			return (0, 0, amount);

		uint256 rewardAmount = amount.mul(rewardFee).div(100);
		uint256 marketingTeamAmount = amount.mul(marketingTeamFee).div(100);
        uint256 ownerAmount = amount.sub(rewardAmount + marketingTeamAmount);

		return (rewardAmount, marketingTeamAmount, ownerAmount);
	}
}