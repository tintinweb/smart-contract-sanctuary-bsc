/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

// Sources flattened with hardhat v2.10.1 https://hardhat.org

// SPDX-License-Identifier: UNLICENSED

// File @openzeppelin/contracts/security/[email protected]



pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


// File @openzeppelin/contracts/token/ERC20/[email protected]



pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/utils/[email protected]



pragma solidity ^0.8.0;

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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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


// File @openzeppelin/contracts/token/ERC20/utils/[email protected]



pragma solidity ^0.8.0;


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


// File @openzeppelin/contracts/utils/[email protected]



pragma solidity ^0.8.0;

/**
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
        return msg.data;
    }
}


// File @openzeppelin/contracts/access/[email protected]



pragma solidity ^0.8.0;

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File contracts/HmineMain2.sol


pragma solidity 0.8.9;




contract HmineMain2 is Ownable, ReentrancyGuard
{
	using SafeERC20 for IERC20;

	struct AccountInfo {
		string nickname; // user nickname
		uint256 amount; // xHMINE staked
		uint256 reward; // BUSD reward accumulated but not claimed
		uint256 accRewardDebt; // BUSD reward debt from PCS distribution algorithm
		uint16 period; // user selected grace period for expirations
		uint64 day; // the day index of the last user interaction
		bool whitelisted; // flag indicating whether or not account pays withdraw penalties
	}

	struct PeriodInfo {
		uint256 amount; // total amount staked for a given period
		uint256 fee; // the period percentual fee
		bool available; // whether or not the period is valid/available
		bool privileged; // whether or not the period can only be set by owner
		mapping(uint64 => DayInfo) dayInfo; // period info per day
	}

	struct DayInfo {
		uint256 accRewardPerShare; // BUSD reward debt from PCS distribution algorithm for a given period/day
		uint256 expiringReward; // BUSD reward to expire for a given period/day
	}

	address constant FURNACE = 0x000000000000000000000000000000000000dEaD;

	address constant DEFAULT_BANKROLL = 0x25be1fcF5F51c418a0C30357a4e8371dB9cf9369; // multisig
	address constant DEFAULT_BUYBACK = 0x7674D2a14076e8af53AC4ba9bBCf0c19FeBe8899;

	uint256 constant DAY = 1 days;
	uint256 constant TZ_OFFSET = 23 hours; // UTC-1

	uint16 constant MAX_PERIOD = type(uint16).max; // flag for no expiration

	address public immutable hmineToken; // xHMINE
	address public immutable rewardToken; // BUSD
	address public immutable hmineMain1;

	address public bankroll = DEFAULT_BANKROLL;
	address public buyback = DEFAULT_BUYBACK;

	bool public whitelistAll = false;

	uint256 public totalStaked = 0; // total staked balance
	uint256 public totalReward = 0; // total reward balance

	uint64 public day = today();

	uint16[] public periodIndex;
	mapping(uint16 => PeriodInfo) public periodInfo;

	address[] public accountIndex;
	mapping(address => AccountInfo) public accountInfo;

	function accountIndexLength() external view returns (uint256 _length)
	{
		return accountIndex.length;
	}

	function getAccountByIndex(uint256 _index) external view returns (AccountInfo memory _accountInfo)
	{
		return accountInfo[accountIndex[_index]];
	}

	function dayInfo(uint16 _period, uint64 _day) external view returns (DayInfo memory _dayInfo)
	{
		return periodInfo[_period].dayInfo[_day];
	}

	function today() public view returns (uint64 _today)
	{
		return uint64((block.timestamp + TZ_OFFSET) / DAY);
	}

	constructor(address _hmineToken, address _rewardToken, address _hmineMain1)
	{
		require(_rewardToken != _hmineToken, "invalid token");
		hmineToken = _hmineToken;
		rewardToken = _rewardToken;
		hmineMain1 = _hmineMain1;

		periodIndex.push(1); periodInfo[1].fee = 0e16; periodInfo[1].available = true;
		periodIndex.push(2); periodInfo[2].fee = 10e16; periodInfo[2].available = true;
		periodIndex.push(4); periodInfo[4].fee = 15e16; periodInfo[4].available = true;
		periodIndex.push(7); periodInfo[7].fee = 20e16; periodInfo[7].available = true;
		periodIndex.push(30); periodInfo[30].fee = 50e16; periodInfo[30].available = true;
		periodIndex.push(MAX_PERIOD); periodInfo[MAX_PERIOD].fee = 0e16; periodInfo[MAX_PERIOD].available = true; periodInfo[MAX_PERIOD].privileged = true;
	}

	// migrates user accounts, can only be called once per account
	function migrate(address[] calldata _accounts, uint256[] calldata _amounts, string[] calldata _nicknames) external onlyOwner nonReentrant
	{
		require(_accounts.length == _amounts.length || _accounts.length == _nicknames.length, "lenght mismatch");

		_updateDay();

		uint16 _period = 1;

		PeriodInfo storage _periodInfo = periodInfo[_period];
		DayInfo storage _dayInfo = _periodInfo.dayInfo[day];

		uint256 _amount = 0;

		for (uint256 _i = 0; _i < _accounts.length; _i++) {
			address _account = _accounts[_i];
			AccountInfo storage _accountInfo = accountInfo[_account];

			require(_accountInfo.period == 0, "duplicate account");
			accountIndex.push(_account);

			_accountInfo.nickname = _nicknames[_i];
			_accountInfo.amount = _amounts[_i];
			_accountInfo.accRewardDebt = _accountInfo.amount * _dayInfo.accRewardPerShare / 1e18;
			_accountInfo.period = _period;
			_accountInfo.day = day;

			emit Deposit(_account, hmineToken, _accountInfo.amount);

			_amount += _accountInfo.amount;
		}

		if (_amount > 0) {
			_periodInfo.amount += _amount;

			totalStaked += _amount;

			IERC20(hmineToken).safeTransferFrom(msg.sender, address(this), _amount);
		}
	}

	// updates the bankroll address
	function setBankroll(address _bankroll) external onlyOwner
	{
		require(_bankroll != address(0), "invalid address");
		bankroll = _bankroll;
	}

	// updates the buyback address
	function setBuyback(address _buyback) external onlyOwner
	{
		require(_buyback != address(0), "invalid address");
		buyback = _buyback;
	}

	// flags all accounts for withdrawing without penalty (useful for migration)
	function updateWhitelistAll(bool _whitelistAll) external onlyOwner
	{
		whitelistAll = _whitelistAll;
	}

	// flags multiple accounts for withdrawing without penalty
	function updateWhitelist(address[] calldata _accounts, bool _whitelisted) external onlyOwner
	{
		for (uint256 _i; _i < _accounts.length; _i++) {
			accountInfo[_accounts[_i]].whitelisted = _whitelisted;
		}
	}

	// this is a safety net method for recovering funds that are not being used
	function recoverFunds(address _token) external onlyOwner nonReentrant
	{
		uint256 _amount = IERC20(_token).balanceOf(address(this));
		if (_token == hmineToken) _amount -= totalStaked;
		else
		if (_token == rewardToken) _amount -= totalReward;
		if (_amount > 0) {
			IERC20(_token).safeTransfer(msg.sender, _amount);
		}
	}

	// updates account nickname
	function updateNickname(string calldata _nickname) external
	{
		AccountInfo storage _accountInfo = accountInfo[msg.sender];
		require(_accountInfo.period != 0, "unknown account");
		_accountInfo.nickname = _nickname;
	}

	// updates account period
	function updatePeriod(address _account, uint16 _newPeriod) external nonReentrant
	{
		PeriodInfo storage _periodInfo = periodInfo[_newPeriod];
		require(_periodInfo.available, "unavailable");
		require(msg.sender == _account && !_periodInfo.privileged || msg.sender == owner(), "access denied");

		_updateDay();

		_updateAccount(_account, 0);

		AccountInfo storage _accountInfo = accountInfo[_account];
		uint16 _oldPeriod = _accountInfo.period;
		require(_newPeriod != _oldPeriod, "no change");

		periodInfo[_oldPeriod].amount -= _accountInfo.amount;
		_periodInfo.amount += _accountInfo.amount;

		DayInfo storage _dayInfo = _periodInfo.dayInfo[day];
		_accountInfo.accRewardDebt = _accountInfo.amount * _dayInfo.accRewardPerShare / 1e18;
		_accountInfo.period = _newPeriod;
	}

	// stakes xHMINE
	function deposit(uint256 _amount) external
	{
		depositOnBehalfOf(_amount, msg.sender);
	}

	// stakes xHMINE on behalf of another account
	function depositOnBehalfOf(uint256 _amount, address _account) public nonReentrant
	{
		require(_amount > 0, "invalid amount");

		_updateDay();

		_updateAccount(_account, int256(_amount));

		totalStaked += _amount;

		IERC20(hmineToken).safeTransferFrom(msg.sender, address(this), _amount);

		emit Deposit(_account, hmineToken, _amount);
	}

	// unstakes xHMINE
	function withdraw(uint256 _amount) external
	{
		require(_amount > 0, "invalid amount");

		AccountInfo storage _accountInfo = accountInfo[msg.sender];
		require(_amount <= _accountInfo.amount, "insufficient balance");

		_updateDay();

		_updateAccount(msg.sender, -int256(_amount));

		totalStaked -= _amount;

		if (_accountInfo.whitelisted || whitelistAll) {
			IERC20(hmineToken).safeTransfer(msg.sender, _amount);
		} else {
			uint256 _10percent = _amount * 10e16 / 100e16;
			uint256 _netAmount = _amount - 2 * _10percent;
			IERC20(hmineToken).safeTransfer(FURNACE, _10percent);
			IERC20(hmineToken).safeTransfer(bankroll, _10percent);
			IERC20(hmineToken).safeTransfer(msg.sender, _netAmount);
		}

		emit Withdraw(msg.sender, hmineToken, _amount);
	}

	// claims BUSD rewards
	function claim() external returns (uint256 _amount)
	{
		return claimOnBehalfOf(msg.sender);
	}

	// claims BUSD rewards on behalf of a given user (available only to HmineMain1)
	function claimOnBehalfOf(address _account) public nonReentrant returns (uint256 _amount)
	{
		require(msg.sender == _account || msg.sender == hmineMain1, "access denied");

		_updateDay();

		_updateAccount(_account, 0);

		AccountInfo storage _accountInfo = accountInfo[_account];
		_amount = _accountInfo.reward;
		_accountInfo.reward = 0;

		if (_amount > 0) {
			totalReward -= _amount;

			IERC20(rewardToken).safeTransfer(msg.sender, _amount);
		}

		emit Claim(_account, rewardToken, _amount);

		return _amount;
	}

	// sends BUSD to a set of accounts
	function reward(address[] calldata _accounts, uint256[] calldata _amounts) external nonReentrant
	{
		require(_accounts.length == _amounts.length, "lenght mismatch");

		uint256 _amount = 0;

		for (uint256 _i = 0; _i < _accounts.length; _i++) {
			address _account = _accounts[_i];
			AccountInfo storage _accountInfo = accountInfo[_account];

			_accountInfo.reward += _amounts[_i];

			emit Reward(_account, rewardToken, _amounts[_i]);

			_amount += _amounts[_i];
		}

		if (_amount > 0) {
			totalReward += _amount;

			IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);
		}
	}

	// sends BUSD to all stakers
	function rewardAll(uint256 _amount) external nonReentrant
	{
		require(_amount > 0, "invalid amount");

		if (totalStaked == 0) {
			IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);
			return;
		}

		_updateDay();

		for (uint256 _i = 0; _i < periodIndex.length; _i++) {
			uint16 _period = periodIndex[_i];
			PeriodInfo storage _periodInfo = periodInfo[_period];

			// splits proportionally by period
			uint256 _subamount = _amount * _periodInfo.amount / totalStaked;
			if (_subamount == 0) continue;

			// rewards according to stake using PCS distribution algorithm
			DayInfo storage _dayInfo = _periodInfo.dayInfo[day];
			_dayInfo.accRewardPerShare += _subamount * 1e18 / _periodInfo.amount;
			_dayInfo.expiringReward += _subamount;
		}

		totalReward += _amount;

		IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);

		emit RewardAll(msg.sender, rewardToken, _amount);
	}

	// sends BUSD to the top 20 stakers (list computed off-chain)
	function sendBonusDiv(uint256 _amount, address[] memory _topTen, address[] memory _topTwenty) external nonReentrant
	{
		require(_amount > 0, "invalid amount");
		require(_topTen.length == 10 && _topTwenty.length == 10, "invalid length");

		uint256 _topTenAmount = (_amount * 75e16 / 100e16) / _topTen.length;

		for (uint256 _i = 0; _i < _topTen.length; _i++) {
			address _account = _topTen[_i];
			AccountInfo storage _accountInfo = accountInfo[_account];

			_accountInfo.reward += _topTenAmount;

			emit Reward(_account, rewardToken, _topTenAmount);
		}

		uint256 _topTwentyAmount = (_amount * 25e16 / 100e16) / _topTwenty.length;

		for (uint256 _i = 0; _i < _topTwenty.length; _i++) {
			address _account = _topTwenty[_i];
			AccountInfo storage _accountInfo = accountInfo[_account];

			_accountInfo.reward += _topTwentyAmount;

			emit Reward(_account, rewardToken, _topTenAmount);
		}

		totalReward += _amount;

		IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);
	}

	// performs the daily expiration of rewards from staking (BUSD)
	function updateDay() external nonReentrant
	{
		_updateDay();
	}

	// updates the user account as if he had interacted with this contract (available only to HmineMain1)
	function updateAccount(address _account) external nonReentrant
	{
		require(msg.sender == hmineMain1, "access denied");

		_updateDay();

		_updateAccount(_account, 0);
	}

	function _updateDay() internal
	{
		uint64 _today = today();

		if (day == _today) return;

		uint256 _amount = 0;

		for (uint256 _i = 0; _i < periodIndex.length; _i++) {
			uint16 _period = periodIndex[_i];
			PeriodInfo storage _periodInfo = periodInfo[_period];

			for (uint64 _day = day; _day < _today; _day++) {
				// carry over accRewardPerShare to the next day
				{
					_periodInfo.dayInfo[_day + 1].accRewardPerShare = _periodInfo.dayInfo[_day].accRewardPerShare;
				}

				// sum up the rewards that expired for a given day
				if (_period < MAX_PERIOD) {
					DayInfo storage _dayInfo = _periodInfo.dayInfo[_day - _period];
					_amount += _dayInfo.expiringReward;
					_dayInfo.expiringReward = 0;
				}
			}
		}

		day = _today;

		if (_amount > 0) {
			totalReward -= _amount;

			IERC20(rewardToken).safeTransfer(buyback, _amount);
		}
	}

	function _updateAccount(address _account, int256 _amount) internal
	{
		AccountInfo storage _accountInfo = accountInfo[_account];
		uint16 _period = _accountInfo.period;
		if (_period == 0) {
			// initializes and adds account to index
			_period = 1;

			accountIndex.push(_account);

			_accountInfo.period = _period;
			_accountInfo.day = day - (_period + 1);
		}
		PeriodInfo storage _periodInfo = periodInfo[_period];

		uint256 _rewardBefore = _accountInfo.reward;

		// if account rewards expire, then
		if (_period < MAX_PERIOD) {
			// if rewards beyond reach, resets to the and of previous day
			if (_accountInfo.day < day - _period) {
				DayInfo storage _dayInfo = _periodInfo.dayInfo[day - 1];
				_accountInfo.accRewardDebt = _accountInfo.amount * _dayInfo.accRewardPerShare / 1e18;
			} else {
				// collects rewards for the past days
				for (uint64 _day = _accountInfo.day; _day < day; _day++) {
					DayInfo storage _dayInfo = _periodInfo.dayInfo[_day];
					uint256 _accRewardDebt = _accountInfo.amount * _dayInfo.accRewardPerShare / 1e18;
					uint256 _reward = _accRewardDebt - _accountInfo.accRewardDebt;
					_dayInfo.expiringReward -= _reward;
					_accountInfo.reward += _reward;
					_accountInfo.accRewardDebt = _accRewardDebt;
				}
			}
		}

		// collects rewards for the current day and adjusts balance
		{
			DayInfo storage _dayInfo = _periodInfo.dayInfo[day];
			uint256 _reward = _accountInfo.amount * _dayInfo.accRewardPerShare / 1e18 - _accountInfo.accRewardDebt;
			_dayInfo.expiringReward -= _reward;
			_accountInfo.reward += _reward;
			if (_amount > 0) {
				_accountInfo.amount += uint256(_amount);
				_periodInfo.amount += uint256(_amount);
			}
			else
			if (_amount < 0) {
				_accountInfo.amount -= uint256(-_amount);
				_periodInfo.amount -= uint256(-_amount);
			}
			_accountInfo.accRewardDebt = _accountInfo.amount * _dayInfo.accRewardPerShare / 1e18;
		}

		_accountInfo.day = day;

		// collect period fees from the account reward
		if (_periodInfo.fee > 0) {
			uint256 _rewardAfter = _accountInfo.reward;

			uint256 _reward = _rewardAfter - _rewardBefore;
			uint256 _fee = _reward * _periodInfo.fee / 1e18;
			if (_fee > 0) {
				_accountInfo.reward -= _fee;

				totalReward -= _fee;

				IERC20(rewardToken).safeTransfer(buyback, _fee);
			}
		}
	}

	event Deposit(address indexed _account, address indexed _hmineToken, uint256 _amount);
	event Withdraw(address indexed _account, address indexed _hmineToken, uint256 _amount);
	event Claim(address indexed _account, address indexed _rewardToken, uint256 _amount);
	event Reward(address indexed _account, address indexed _rewardToken, uint256 _amount);
	event RewardAll(address indexed _account, address indexed _rewardToken, uint256 _amount);
}


// File contracts/HmineMain1.sol


pragma solidity 0.8.9;




contract HmineMain1 is Ownable, ReentrancyGuard
{
	using SafeERC20 for IERC20;

	address constant DEFAULT_BANKROLL = 0x25be1fcF5F51c418a0C30357a4e8371dB9cf9369; // multisig
	address constant DEFAULT_MANAGEMENT_0 = 0x36b13280500AEBC5A75EbC1e9cB9Bf1b6A78a95e; // miko
	address constant DEFAULT_MANAGEMENT_1 = 0x2165fa4a32B9c228cD55713f77d2e977297D03e8; // ghost
	address constant DEFAULT_MANAGEMENT_2 = 0xcD8dDeE99C0c4Be4cD699661AE9c00C69D1Eb4A8;
	address constant DEFAULT_LIQUIDITY_TAKER = 0x2165fa4a32B9c228cD55713f77d2e977297D03e8; // ghost

	uint256 constant MAX_SUPPLY = 200_000e18;
	uint256 constant ROUND_INCREMENT = 250e18;
	uint256 constant FIRST_ROUND = 100_000e18;
	uint256 constant SECOND_ROUND = FIRST_ROUND + ROUND_INCREMENT;
	uint256 constant MIN_PRICE = 7e18;
	uint256 constant PRICE_INCREMENT = 0.75e18;

	address public immutable hmineToken; // xHMINE
	address public immutable currencyToken; // BUSD
	address public immutable hmineMain2;

	address public bankroll = DEFAULT_BANKROLL;
	address[3] public management = [DEFAULT_MANAGEMENT_0, DEFAULT_MANAGEMENT_1, DEFAULT_MANAGEMENT_2];
	address public liquidityTaker = DEFAULT_LIQUIDITY_TAKER;

	uint256 public totalSold;
	uint256 public currentPrice;

	modifier onlyLiquidityTaker()
	{
		require(msg.sender == liquidityTaker, "access denied");
		_;
	}

	constructor(address _hmineToken, address _currenctyToken, address _hmineMain2, uint256 _totalSold)
	{
		require(_currenctyToken != _hmineToken, "invalid token");
		require(_totalSold <= MAX_SUPPLY, "invalid amount");
		hmineToken = _hmineToken;
		currencyToken = _currenctyToken;
		hmineMain2 = _hmineMain2;

		totalSold = _totalSold;
		currentPrice = MIN_PRICE;
		if (totalSold > FIRST_ROUND) {
			currentPrice += PRICE_INCREMENT * ((totalSold - FIRST_ROUND) / ROUND_INCREMENT);
		}
		IERC20(hmineToken).safeTransferFrom(msg.sender, address(this), MAX_SUPPLY - totalSold);
	}

	function setBankroll(address _bankroll) external onlyOwner
	{
		require(_bankroll != address(0), "invalid address");
		bankroll = _bankroll;
	}

	function setManagement(uint256 _i, address _management) external onlyOwner
	{
		require(_i < management.length, "invalid index");
		require(_management != address(0), "invalid address");
		management[_i] = _management;
	}

	function setLiquidityTaker(address _liquidityTaker) external onlyOwner
	{
		liquidityTaker = _liquidityTaker;
	}

	function recoverReserve(uint256 _amount) external onlyLiquidityTaker nonReentrant
	{
		uint256 _reserve = IERC20(currencyToken).balanceOf(address(this));
		require(_amount <= _reserve, "insufficient balance");
		IERC20(currencyToken).safeTransfer(msg.sender, _amount);
	}

	function calculateSwap(uint256 _amount, bool _isBuy) external view returns (uint256 _value)
	{
		(_value, ) = _isBuy ? _getBuyValue(_amount) : _getSellValue(_amount);
		return _value;
	}

	function buy(uint256 _amount) external nonReentrant returns (uint256 _value)
	{
		require(_amount > 0, "invalid amount");

		(uint256 _hmineValue, uint256 _price) = _getBuyValue(_amount);

		_buy(msg.sender, _amount, _hmineValue, _price, msg.sender);

		emit Buy(msg.sender, _hmineValue, _price, HmineMain2(hmineMain2).totalStaked());

		return _hmineValue;
	}

	function buyOnBehalfOf(uint256 _amount, address _account) external nonReentrant returns (uint256 _value)
	{
		require(_amount > 0, "invalid amount");

		(uint256 _hmineValue, uint256 _price) = _getBuyValue(_amount);

		_buy(msg.sender, _amount, _hmineValue, _price, _account);

		emit Buy(_account, _hmineValue, _price, HmineMain2(hmineMain2).totalStaked());

		return _hmineValue;
	}

	function compound() external nonReentrant
	{
		uint256 _amount = HmineMain2(hmineMain2).claimOnBehalfOf(msg.sender);

		(uint256 _hmineValue, uint256 _price) = _getBuyValue(_amount);

		_buy(address(this), _amount, _hmineValue, _price, msg.sender);

		emit Compound(msg.sender, _hmineValue, _price, HmineMain2(hmineMain2).totalStaked());
	}

	function _buy(address _sender, uint256 _amount, uint256 _hmineValue, uint256 _price, address _account) internal
	{
		require(totalSold + _hmineValue <= MAX_SUPPLY, "exceeds supply");

		uint256 _managementAmount = (_amount * 10e16 / 100e16) / management.length;
		uint256 _bankrollAmount = _amount * 80e16 / 100e16;
		uint256 _amountToStakers = _amount - (management.length * _managementAmount + _bankrollAmount);

		if (_sender == address(this)) {
			for (uint256 _i = 0; _i < management.length; _i++) {
				IERC20(currencyToken).safeTransfer(management[_i], _managementAmount);
			}
			IERC20(currencyToken).safeTransfer(bankroll, _bankrollAmount);
		} else {
			for (uint256 _i = 0; _i < management.length; _i++) {
				IERC20(currencyToken).safeTransferFrom(_sender, management[_i], _managementAmount);
			}
			IERC20(currencyToken).safeTransferFrom(_sender, bankroll, _bankrollAmount);
			IERC20(currencyToken).safeTransferFrom(_sender, address(this), _amountToStakers);
		}

		IERC20(currencyToken).safeApprove(hmineMain2, _amountToStakers);
		HmineMain2(hmineMain2).rewardAll(_amountToStakers);

		IERC20(hmineToken).safeApprove(hmineMain2, _hmineValue);
		HmineMain2(hmineMain2).depositOnBehalfOf(_hmineValue, _account);

		totalSold += _hmineValue;

		currentPrice = _price;
	}

	function sell(uint256 _amount) external nonReentrant returns (uint256 _value)
	{
		require(_amount > 0, "invalid amount");

		(uint256 _sellValue, uint256 _price) = _getSellValue(_amount);

		uint256 _60percent = (_sellValue * 60e18) / 100e18;

		uint256 _reserve = IERC20(currencyToken).balanceOf(address(this));
		require(_60percent <= _reserve, "insufficient balance");

		IERC20(hmineToken).safeTransferFrom(msg.sender, address(this), _amount);

		IERC20(currencyToken).safeTransfer(msg.sender, _60percent);

		HmineMain2(hmineMain2).updateAccount(msg.sender);

		totalSold -= _amount;

		currentPrice = _price;

		emit Sell(msg.sender, _amount, _price, HmineMain2(hmineMain2).totalStaked());

		return _sellValue;
	}

	function _getBuyValue(uint256 _amount) internal view returns (uint256 _hmineValue, uint256 _price)
	{
		_price = currentPrice;
		_hmineValue = _amount * 1e18 / _price;
		if (totalSold + _hmineValue <= SECOND_ROUND) {
			if (totalSold + _hmineValue == SECOND_ROUND) {
				_price += PRICE_INCREMENT;
			}
		}
		else {
			_hmineValue = 0;
			uint256 _amountLeftOver = _amount;
			uint256 _roundAvailable = ROUND_INCREMENT - totalSold % ROUND_INCREMENT;

			// If short of first round, adjust up to first round
			if (totalSold < FIRST_ROUND) {
				_hmineValue += FIRST_ROUND - totalSold;
				_amountLeftOver -= _hmineValue * _price / 1e18;
				_roundAvailable = ROUND_INCREMENT;
			}

			uint256 _valueOfLeftOver = _amountLeftOver * 1e18 / _price;
			if (_valueOfLeftOver < _roundAvailable) {
				_hmineValue += _valueOfLeftOver;
			} else {
				_hmineValue += _roundAvailable;
				_amountLeftOver = (_valueOfLeftOver - _roundAvailable) * _price / 1e18;
				_price += PRICE_INCREMENT;
				while (_amountLeftOver > 0) {
					_valueOfLeftOver = _amountLeftOver * 1e18 / _price;
					if (_valueOfLeftOver >= ROUND_INCREMENT) {
						_hmineValue += ROUND_INCREMENT;
						_amountLeftOver = (_valueOfLeftOver - ROUND_INCREMENT) * _price / 1e18;
						_price += PRICE_INCREMENT;
					} else {
						_hmineValue += _valueOfLeftOver;
						_amountLeftOver = 0;
					}
				}
			}
		}
		return (_hmineValue, _price);
	}

	function _getSellValue(uint256 _amount) internal view returns (uint256 _sellValue, uint256 _price)
	{
		_price = currentPrice;
		uint256 _roundAvailable = totalSold % ROUND_INCREMENT;
		if (_amount <= _roundAvailable) {
			_sellValue = _amount * _price / 1e18;
		}
		else {
			_sellValue = _roundAvailable * _price / 1e18;
			uint256 _amountLeftOver = _amount - _roundAvailable;
			while (_amountLeftOver > 0) {
				if (_price > MIN_PRICE) {
					_price -= PRICE_INCREMENT;
				}
				if (_amountLeftOver > ROUND_INCREMENT) {
					_sellValue += ROUND_INCREMENT * _price / 1e18;
					_amountLeftOver -= ROUND_INCREMENT;
				} else {
					_sellValue += _amountLeftOver * _price / 1e18;
					_amountLeftOver = 0;
				}
			}
		}
		return (_sellValue, _price);
	}

	event Buy(address indexed _account, uint256 _amount, uint256 _price, uint256 _totalStaked);
	event Sell(address indexed _account, uint256 _amount, uint256 _price, uint256 _totalStaked);
	event Compound(address indexed _account, uint256 _amount, uint256 _price, uint256 _totalStaked);
}


// File contracts/HmineBridge.sol


pragma solidity 0.8.9;



interface IUniswapV2Router
{
	function WETH() external pure returns (address _WETH);
	function getAmountsOut(uint256 _amountIn, address[] calldata _path) external view returns (uint256[] memory _amounts);

	function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable returns (uint256[] memory amounts);
	function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
}

contract HmineBridge is ReentrancyGuard
{
	using SafeERC20 for IERC20;

	address public immutable hmineMain1;
	address public immutable currencyToken;

	address public immutable router;
	address public immutable wrapperToken;

	constructor(address _hmineMain1, address _router)
	{
		hmineMain1 = _hmineMain1;
		router = _router;
		currencyToken = HmineMain1(hmineMain1).currencyToken();
		wrapperToken = IUniswapV2Router(router).WETH();
	}

	function estimateBuy(address _token, uint256 _amount, bool _directRoute) external view returns (uint256 _value)
	{
		address[] memory _path;
		if (_directRoute) {
			_path = new address[](2);
			_path[0] = _token;
			_path[1] = currencyToken;
		} else {
			_path = new address[](3);
			_path[0] = _token;
			_path[1] = wrapperToken;
			_path[2] = currencyToken;
		}
		uint256 _currencyAmount = IUniswapV2Router(router).getAmountsOut(_amount, _path)[_path.length - 1];
		return HmineMain1(hmineMain1).calculateSwap(_currencyAmount, true);
	}

	function buy(uint256 _hmineMinAmount) external payable nonReentrant
	{
		address[] memory _path = new address[](2);
		_path[0] = wrapperToken;
		_path[1] = currencyToken;
		uint256 _currencyAmount = IUniswapV2Router(router).swapExactETHForTokens{value: msg.value}(1, _path, address(this), block.timestamp)[_path.length - 1];
		IERC20(currencyToken).safeApprove(hmineMain1, _currencyAmount);
		uint256 _hmineAmount = HmineMain1(hmineMain1).buyOnBehalfOf(_currencyAmount, msg.sender);
		require(_hmineAmount >= _hmineMinAmount, "high slippage");
	}

	function buy(address _token, uint256 _amount, bool _directRoute, uint256 _hmineMinAmount) external nonReentrant
	{
		IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
		IERC20(_token).safeApprove(router, _amount);
		address[] memory _path;
		if (_directRoute) {
			_path = new address[](2);
			_path[0] = _token;
			_path[1] = currencyToken;
		} else {
			_path = new address[](3);
			_path[0] = _token;
			_path[1] = wrapperToken;
			_path[2] = currencyToken;
		}
		uint256 _currencyAmount = IUniswapV2Router(router).swapExactTokensForTokens(_amount, 1, _path, address(this), block.timestamp)[_path.length - 1];
		IERC20(currencyToken).safeApprove(hmineMain1, _currencyAmount);
		uint256 _hmineAmount = HmineMain1(hmineMain1).buyOnBehalfOf(_currencyAmount, msg.sender);
		require(_hmineAmount >= _hmineMinAmount, "high slippage");
	}
}


// File contracts/HmineBuyback.sol


pragma solidity 0.8.9;




contract HmineBuyback is ReentrancyGuard
{
	using SafeERC20 for IERC20;

	address constant FURNACE = 0x000000000000000000000000000000000000dEaD;

	uint256 constant MIN_CURRENCY_AMOUNT = 1e18; // $1

	address public immutable hmineMain1;
	address public immutable hmineMain2;
	address public immutable hmineToken;
	address public immutable currencyToken;

	constructor(address _hmineMain1, address _hmineMain2)
	{
		hmineMain1 = _hmineMain1;
		hmineMain2 = _hmineMain2;
		hmineToken = HmineMain1(hmineMain1).hmineToken();
		currencyToken = HmineMain1(hmineMain1).currencyToken();
	}

	function buybackAndBurn() external nonReentrant
	{
		HmineMain2(hmineMain2).claim();

		uint256 _currencyAmount = IERC20(currencyToken).balanceOf(address(this));

		if (_currencyAmount >= MIN_CURRENCY_AMOUNT) {
			IERC20(currencyToken).safeApprove(hmineMain1, _currencyAmount);
			uint256 _hmineAmount = HmineMain1(hmineMain1).buy(_currencyAmount);

			(,,,,,,bool _whitelisted) = HmineMain2(hmineMain2).accountInfo(address(this));
			require(_whitelisted, "not whitelisted");
			HmineMain2(hmineMain2).withdraw(_hmineAmount);

			IERC20(hmineToken).safeTransfer(FURNACE, _hmineAmount);

			emit BuybackAndBurn(_currencyAmount, _hmineAmount);
		}
	}

	event BuybackAndBurn(uint256 _currencyAmount, uint256 _hmineAmount);
}


// File contracts/HmineVolatile.sol


pragma solidity 0.8.9;




/*
 Volatile VDC fees are 33% in and 33% out, they are distributed in the following way:
 30% to drip pool
 1% Instant dividends to stakers
 1% HMINE Bankroll
 1% Burnt
 Does not receive BUSD daily but does receive 1% of all HMINE deposited into COMPOUND VDC
 */
contract HmineVolatile is Ownable, ReentrancyGuard
{
	using SafeERC20 for IERC20;

	struct AccountInfo {
		uint256 amount; // xHMINE staked
		uint256 reward; // xHMINE reward from Volatile VDC accumulated but not claimed
		uint256 drip; // xHMINE from drip pool accumulated but not claimed
		/*uint256 yield; // xYIELD accumulated but not claimed*/
		uint256 accRewardDebt; // xHMINE reward debt from PCS distribution algorithm
		uint256 accDripDebt; // xHMINE reward debt from PCS distribution algorithm
		bool whitelisted; // flag indicating whether or not account pays withdraw penalties
		bool exists; // flag to index account
	}

	address constant FURNACE = 0x000000000000000000000000000000000000dEaD;

	address constant DEFAULT_BANKROLL = 0x25be1fcF5F51c418a0C30357a4e8371dB9cf9369; // multisig
	/*address constant DEFAULT_LIQUIDITY_TAKER = 0x2165fa4a32B9c228cD55713f77d2e977297D03e8; // ghost*/

	/*uint256 constant MAXIMUM_YIELD_FACTOR = 555e18; // max 555 xYIELD for each xHMINE deposited*/
	/*uint256 constant DEFAULT_YIELD_FACTOR = 111e18; // 111 xYIELD for each xHMINE deposited*/
	uint256 constant DEFAULT_DRIP_RATE_PER_DAY = 1e16; // 1% per day

	uint256 constant DAY = 1 hours;
	uint256 constant TZ_OFFSET = 0 minutes; // no offset

	address public immutable hmineToken; // xHMINE
	address public immutable rewardToken; // xHMINE
	/*address public immutable yieldToken; // xYIELD*/

	address public bankroll = DEFAULT_BANKROLL;
	/*address public liquidityTaker = DEFAULT_LIQUIDITY_TAKER;*/

	/*uint256 public yieldFactor = DEFAULT_YIELD_FACTOR;*/
	uint256 public dripRatePerDay = DEFAULT_DRIP_RATE_PER_DAY;

	bool public whitelistAll = false;

	/*uint256 public totalYield = 0; // total yield balance allocated*/

	uint256 public totalStaked = 0; // total staked balance

	uint256 public totalDrip = 0; // total drip pool balance
	uint256 public allocDrip = 0; // total drip pool balance allocated

	uint256 public totalReward = 0; // total reward balance

	uint256 public accRewardPerShare = 0; // cumulative reward xHMINE per xHMINE staked from PCS distribution algorithm
	uint256 public accDripPerShare = 0; // cumulative drip pool xHMINE per xHMINE staked from PCS distribution algorithm

	uint64 public day = today();

	address[] public accountIndex;
	mapping(address => AccountInfo) public accountInfo;

	function accountIndexLength() external view returns (uint256 _length)
	{
		return accountIndex.length;
	}

	function getAccountByIndex(uint256 _index) external view returns (AccountInfo memory _accountInfo)
	{
		return accountInfo[accountIndex[_index]];
	}

	function today() public view returns (uint64 _today)
	{
		return uint64((block.timestamp + TZ_OFFSET) / DAY);
	}

	/*
	modifier onlyLiquidityTaker()
	{
		require(msg.sender == liquidityTaker, "access denied");
		_;
	}
	*/

	constructor(address _hmineToken/*, address _yieldToken*/)
	{
		/*require(_yieldToken != _hmineToken, "invalid token");*/
		hmineToken = _hmineToken;
		rewardToken = _hmineToken;
		/*yieldToken = _yieldToken;*/
	}

	// updates the bankroll address
	function setBankroll(address _bankroll) external onlyOwner
	{
		require(_bankroll != address(0), "invalid address");
		bankroll = _bankroll;
	}

	/*
	// allows updating the account that can take the xYIELD excess liquidity
	function setLiquidityTaker(address _liquidityTaker) external onlyOwner
	{
		liquidityTaker = _liquidityTaker;
	}
	*/

	/*
	// updates the xHMINE to xYIELD issuance factor
	function setYieldFactor(uint256 _yieldFactor) external onlyOwner
	{
		require(_yieldFactor <= MAXIMUM_YIELD_FACTOR, "invalid factor");
		yieldFactor = _yieldFactor;
	}
	*/

	// updates the percentual rate of distribution from the drip pool
	function setDripRatePerDay(uint256 _dripRatePerDay) external onlyOwner
	{
		require(_dripRatePerDay <= 100e16, "invalid rate");
		dripRatePerDay = _dripRatePerDay;
	}

	// flags all accounts for withdrawing without penalty (useful for migration)
	function updateWhitelistAll(bool _whitelistAll) external onlyOwner
	{
		whitelistAll = _whitelistAll;
	}

	// flags multiple accounts for withdrawing without penalty
	function updateWhitelist(address[] calldata _accounts, bool _whitelisted) external onlyOwner
	{
		for (uint256 _i; _i < _accounts.length; _i++) {
			accountInfo[_accounts[_i]].whitelisted = _whitelisted;
		}
	}

	// this is a safety net method for recovering funds that are not being used
	function recoverFunds(address _token) external onlyOwner nonReentrant
	{
		/*require(_token != yieldToken, "invalid token");*/
		uint256 _amount = IERC20(_token).balanceOf(address(this));
		if (_token == hmineToken) _amount -= totalStaked + totalDrip + totalReward;
		require(_amount > 0, "no balance");
		IERC20(_token).safeTransfer(msg.sender, _amount);
	}

	/*
	// allows withdrawing excess xYIELD, it will not withdraw more than what has been allocated for users
	function recoverReserve(uint256 _amount) external onlyLiquidityTaker nonReentrant
	{
		uint256 _reserve = IERC20(yieldToken).balanceOf(address(this));
		uint256 _available = _reserve > totalYield ? _reserve - totalYield : 0;
		require(_amount <= _available, "insufficient balance");
		IERC20(yieldToken).safeTransfer(msg.sender, _amount);
	}
	*/

	// stakes xHMINE (sender collects xYIELD)
	function deposit(uint256 _amount) external nonReentrant
	{
		_deposit(msg.sender, _amount, msg.sender/*, true*/);

		emit Deposit(msg.sender, hmineToken, _amount);
	}

	// stakes xHMINE on behalf of another account (which collects  xYIELD)
	function depositOnBehalfOf(uint256 _amount, address _account) external nonReentrant
	{
		_deposit(msg.sender, _amount, _account/*, true*/);

		emit Deposit(_account, hmineToken, _amount);
	}

	function _deposit(address _sender, uint256 _amount, address _account/*, bool _collectYield*/) internal
	{
		require(_amount > 0, "invalid amount");

		/*
		// collects xYIELD for account
		if (_collectYield) {
			uint256 _yieldAmount = yieldFactor * _amount / 1e18;

			AccountInfo storage _accountInfo = accountInfo[_account];

			_accountInfo.yield += _yieldAmount;

			totalYield += _yieldAmount;
		}
		*/

		_updateDay();

		uint256 _1percent = _amount * 1e16 / 100e16;
		uint256 _dripAmount = 31 * _1percent;
		uint256 _netAmount = _amount - (33 * _1percent);

		// 31% accounted for the drip pool
		totalDrip += _dripAmount;

		// 1% instant rewards (only 30% actually go to the drip pool)
		if (totalStaked > 0) {
			accDripPerShare += _1percent * 1e18 / totalStaked;
			allocDrip += _1percent;
		}

		_updateAccount(_account, int256(_netAmount));

		totalStaked += _netAmount;

		if (_sender == address(this)) {
			IERC20(hmineToken).safeTransfer(FURNACE, _1percent);
			IERC20(hmineToken).safeTransfer(bankroll, _1percent);
		} else {
			IERC20(hmineToken).safeTransferFrom(_sender, address(this), _netAmount + _dripAmount);
			IERC20(hmineToken).safeTransferFrom(_sender, FURNACE, _1percent);
			IERC20(hmineToken).safeTransferFrom(_sender, bankroll, _1percent);
		}
	}

	// unstakes xHMINE
	function withdraw(uint256 _amount) external nonReentrant
	{
		require(_amount > 0, "invalid amount");

		AccountInfo storage _accountInfo = accountInfo[msg.sender];
		require(_amount <= _accountInfo.amount, "insufficient balance");

		_updateDay();

		_updateAccount(msg.sender, -int256(_amount));

		totalStaked -= _amount;

		if (_accountInfo.whitelisted || whitelistAll) {
			IERC20(hmineToken).safeTransfer(msg.sender, _amount);
		} else {
			uint256 _1percent = _amount * 1e16 / 100e16;
			uint256 _dripAmount = 31 * _1percent;
			uint256 _netAmount = _amount - (33 * _1percent);

			// 31% accounted for the drip pool
			totalDrip += _dripAmount;

			// 1% instant rewards (only 30% actually go to the drip pool)
			if (totalStaked > 0) {
				accDripPerShare += _1percent * 1e18 / totalStaked;
				allocDrip += _1percent;
			}

			IERC20(hmineToken).safeTransfer(FURNACE, _1percent);
			IERC20(hmineToken).safeTransfer(bankroll, _1percent);

			IERC20(hmineToken).safeTransfer(msg.sender, _netAmount);
		}

		emit Withdraw(msg.sender, hmineToken, _amount);
	}

	// claims all 2 rewards: xHMINE and xYIELD respectivelly
	function claim() external nonReentrant returns (uint256 _rewardPlusDripAmount/*, uint256 _yieldAmount*/)
	{
		_updateDay();

		_updateAccount(msg.sender, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		uint256 _rewardAmount = _accountInfo.reward;
		uint256 _dripAmount = _accountInfo.drip;
		_rewardPlusDripAmount = _rewardAmount + _dripAmount;
		/*_yieldAmount = _accountInfo.yield;*/

		_accountInfo.reward = 0;
		_accountInfo.drip = 0;
		/*_accountInfo.yield = 0;*/

		if (_rewardPlusDripAmount > 0) {
			totalReward -= _rewardAmount;

			totalDrip -= _dripAmount;
			allocDrip -= _dripAmount;

			IERC20(hmineToken).safeTransfer(msg.sender, _rewardPlusDripAmount);

			emit Claim(msg.sender, hmineToken, _rewardPlusDripAmount);
		}

		/*
		if (_yieldAmount > 0) {
			totalYield -= _yieldAmount;

			// this will fail if not enough xYIELD is fed into the contract
			IERC20(yieldToken).safeTransfer(msg.sender, _yieldAmount);

			emit Claim(msg.sender, yieldToken, _yieldAmount);
		}
		*/

		return /*(*/_rewardPlusDripAmount/*, _yieldAmount)*/;
	}

	// compounds all xHMINE rewards
	function compound() external nonReentrant
	{
		_updateDay();

		_updateAccount(msg.sender, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		uint256 _rewardAmount = _accountInfo.reward;
		uint256 _dripAmount = _accountInfo.drip;

		_accountInfo.reward = 0;
		_accountInfo.drip = 0;

		uint256 _rewardPlusDripAmount = _rewardAmount + _dripAmount;
		if (_rewardPlusDripAmount > 0) {
			totalReward -= _rewardAmount;

			totalDrip -= _dripAmount;
			allocDrip -= _dripAmount;

			_deposit(address(this), _rewardPlusDripAmount, msg.sender/*, false*/);
		}

		emit Compound(msg.sender, hmineToken, _rewardPlusDripAmount);
	}

	// sends xHMINE to a set of accounts
	function reward(address[] calldata _accounts, uint256[] calldata _amounts) external nonReentrant
	{
		require(_accounts.length == _amounts.length, "lenght mismatch");

		uint256 _amount = 0;

		for (uint256 _i = 0; _i < _accounts.length; _i++) {
			address _account = _accounts[_i];
			AccountInfo storage _accountInfo = accountInfo[_account];

			_accountInfo.reward += _amounts[_i];

			emit Reward(_account, rewardToken, _amounts[_i]);

			_amount += _amounts[_i];
		}

		if (_amount > 0) {
			totalReward += _amount;

			IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);
		}
	}

	// sends xHMINE to all stakers
	function rewardAll(uint256 _amount) external nonReentrant
	{
		require(_amount > 0, "invalid amount");

		if (totalStaked == 0) {
			IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);
			return;
		}

		_updateDay();

		accRewardPerShare += _amount * 1e18 / totalStaked;

		totalReward += _amount;

		IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);

		emit RewardAll(msg.sender, rewardToken, _amount);
	}

	// performs the daily distribution the drip pool (xHMINE)
	function updateDay() external nonReentrant
	{
		_updateDay();
	}

	function _updateDay() internal
	{
		uint64 _today = today();

		if (day == _today) return;

		if (totalStaked > 0) {
			// calculates the percentage of the drip pool and distributes
			{
				// formula: drip_reward = drip_pool_balance * (1 - (1 - drip_rate_per_day) ^ days_ellapsed)
				uint64 _days = _today - day;
				uint256 _rate = 100e16 - _exp(100e16 - dripRatePerDay, _days);
				uint256 _amount = (totalDrip - allocDrip) * _rate / 100e16;
				accDripPerShare += _amount * 1e18 / totalStaked;
				allocDrip += _amount;
			}
		}

		day = _today;
	}

	// updates the account balances while accumulating reward/drip using PCS distribution algorithm
	function _updateAccount(address _account, int256 _amount) internal
	{
		AccountInfo storage _accountInfo = accountInfo[_account];
		if (!_accountInfo.exists) {
			// adds account to index
			_accountInfo.exists = true;
			accountIndex.push(_account);
		}

		_accountInfo.reward += _accountInfo.amount * accRewardPerShare / 1e18 - _accountInfo.accRewardDebt;
		_accountInfo.drip += _accountInfo.amount * accDripPerShare / 1e18 - _accountInfo.accDripDebt;
		if (_amount > 0) {
			_accountInfo.amount += uint256(_amount);
		}
		else
		if (_amount < 0) {
			_accountInfo.amount -= uint256(-_amount);
		}
		_accountInfo.accRewardDebt = _accountInfo.amount * accRewardPerShare / 1e18;
		_accountInfo.accDripDebt = _accountInfo.amount * accDripPerShare / 1e18;
	}

	// exponentiation with integer exponent
	function _exp(uint256 _x, uint256 _n) internal pure returns (uint256 _y)
	{
		_y = 1e18;
		while (_n > 0) {
			if (_n & 1 != 0) _y = _y * _x / 1e18;
			_n >>= 1;
			_x = _x * _x / 1e18;
		}
		return _y;
	}

	event Deposit(address indexed _account, address indexed _hmineToken, uint256 _amount);
	event Withdraw(address indexed _account, address indexed _hmineToken, uint256 _amount);
	event Claim(address indexed _account, address indexed _rewardToken, uint256 _amount);
	event Compound(address indexed _account, address indexed _rewardToken, uint256 _amount);
	event Reward(address indexed _account, address indexed _rewardToken, uint256 _amount);
	event RewardAll(address indexed _account, address indexed _rewardToken, uint256 _amount);
}


// File contracts/HmineCompound.sol


pragma solidity 0.8.9;






/*
 Compound VDC fees are 11% in and 11% out, they are distributed in the following way:
 7% to drip pool
 1% Instant dividends to stakers
 1% HMINE Bankroll
 1% Burnt
 1% Volatile VDC
 Receives BUSD daily from HMINE staking
 */
contract HmineCompound is Ownable, ReentrancyGuard
{
	using SafeERC20 for IERC20;

	struct AccountInfo {
		uint256 amount; // xHMINE staked
		uint256 reward; // BUSD reward accumulated but not claimed
		uint256 drip; // xHMINE from drip pool accumulated but not claimed
		/*uint256 yield; // xYIELD accumulated but not claimed*/
		uint256 accRewardDebt; // BUSD reward debt from PCS distribution algorithm
		uint256 accDripDebt; // xHMINE reward debt from PCS distribution algorithm
		bool whitelisted; // flag indicating whether or not account pays withdraw penalties
		bool exists; // flag to index account
	}

	address constant FURNACE = 0x000000000000000000000000000000000000dEaD;

	address constant DEFAULT_BANKROLL = 0x25be1fcF5F51c418a0C30357a4e8371dB9cf9369; // multisig
	/*address constant DEFAULT_LIQUIDITY_TAKER = 0x2165fa4a32B9c228cD55713f77d2e977297D03e8; // ghost*/

	/*uint256 constant MAXIMUM_YIELD_FACTOR = 555e18; // max 555 xYIELD for each xHMINE deposited*/
	/*uint256 constant DEFAULT_YIELD_FACTOR = 111e18; // 111 xYIELD for each xHMINE deposited*/
	uint256 constant DEFAULT_DRIP_RATE_PER_DAY = 1e16; // 1% per day

	uint256 constant DAY = 1 hours;
	uint256 constant TZ_OFFSET = 0 minutes; // no offset

	address public immutable hmineToken; // xHMINE
	address public immutable rewardToken; // BUSD
	/*address public immutable yieldToken; // xYIELD*/

	address public hmineMain1;
	address public hmineMain2;
	address public hmineVolatile;

	address public bankroll = DEFAULT_BANKROLL;
	/*address public liquidityTaker = DEFAULT_LIQUIDITY_TAKER;*/

	/*uint256 public yieldFactor = DEFAULT_YIELD_FACTOR;*/
	uint256 public dripRatePerDay = DEFAULT_DRIP_RATE_PER_DAY;

	bool public whitelistAll = false;

	/*uint256 public totalYield = 0; // total yield balance allocated*/

	uint256 public totalStaked = 0; // total staked balance

	uint256 public totalDrip = 0; // total drip pool balance
	uint256 public allocDrip = 0; // total drip pool balance allocated

	uint256 public totalReward = 0; // total reward balance

	uint256 public accRewardPerShare = 0; // cumulative reward BUSD per xHMINE staked from PCS distribution algorithm
	uint256 public accDripPerShare = 0; // cumulative drip pool xHMINE per xHMINE staked from PCS distribution algorithm

	uint64 public day = today();

	address[] public accountIndex;
	mapping(address => AccountInfo) public accountInfo;

	function accountIndexLength() external view returns (uint256 _length)
	{
		return accountIndex.length;
	}

	function getAccountByIndex(uint256 _index) external view returns (AccountInfo memory _accountInfo)
	{
		return accountInfo[accountIndex[_index]];
	}

	function today() public view returns (uint64 _today)
	{
		return uint64((block.timestamp + TZ_OFFSET) / DAY);
	}

	/*
	modifier onlyLiquidityTaker()
	{
		require(msg.sender == liquidityTaker, "access denied");
		_;
	}
	*/

	constructor(address _hmineToken, address _rewardToken/*, address _yieldToken*/, address _hmineMain1, address _hmineMain2, address _hmineVolatile)
	{
		require(_rewardToken != _hmineToken/* && _yieldToken != _hmineToken && _yieldToken != _rewardToken*/, "invalid token");
		hmineToken = _hmineToken;
		rewardToken = _rewardToken;
		/*yieldToken = _yieldToken;*/
		hmineMain1 = _hmineMain1;
		hmineMain2 = _hmineMain2;
		hmineVolatile = _hmineVolatile;
	}

	// updates the xHMINE main exchange contract
	function setHmineMain1(address _hmineMain1) external onlyOwner
	{
		require(_hmineMain1 != address(0), "invalid address");
		hmineMain1 = _hmineMain1;
	}

	// updates the xHMINE main staking contract
	function setHmineMain2(address _hmineMain2) external onlyOwner
	{
		require(_hmineMain2 != address(0), "invalid address");
		hmineMain2 = _hmineMain2;
	}

	// updates the volatile vdc address
	function setHmineVolatile(address _hmineVolatile) external onlyOwner
	{
		require(_hmineVolatile != address(0), "invalid address");
		hmineVolatile = _hmineVolatile;
	}

	// updates the bankroll address
	function setBankroll(address _bankroll) external onlyOwner
	{
		require(_bankroll != address(0), "invalid address");
		bankroll = _bankroll;
	}

	/*
	// allows updating the account that can take the xYIELD excess liquidity
	function setLiquidityTaker(address _liquidityTaker) external onlyOwner
	{
		liquidityTaker = _liquidityTaker;
	}
	*/

	/*
	// updates the xHMINE to xYIELD issuance factor
	function setYieldFactor(uint256 _yieldFactor) external onlyOwner
	{
		require(_yieldFactor <= MAXIMUM_YIELD_FACTOR, "invalid factor");
		yieldFactor = _yieldFactor;
	}
	*/

	// updates the percentual rate of distribution from the drip pool
	function setDripRatePerDay(uint256 _dripRatePerDay) external onlyOwner
	{
		require(_dripRatePerDay <= 100e16, "invalid rate");
		dripRatePerDay = _dripRatePerDay;
	}

	// flags all accounts for withdrawing without penalty (useful for migration)
	function updateWhitelistAll(bool _whitelistAll) external onlyOwner
	{
		whitelistAll = _whitelistAll;
	}

	// flags multiple accounts for withdrawing without penalty
	function updateWhitelist(address[] calldata _accounts, bool _whitelisted) external onlyOwner
	{
		for (uint256 _i; _i < _accounts.length; _i++) {
			accountInfo[_accounts[_i]].whitelisted = _whitelisted;
		}
	}

	// this is a safety net method for recovering funds that are not being used
	function recoverFunds(address _token) external onlyOwner nonReentrant
	{
		/*require(_token != yieldToken, "invalid token");*/
		uint256 _amount = IERC20(_token).balanceOf(address(this));
		if (_token == rewardToken) _amount -= totalReward;
		if (_token == hmineToken) _amount -= totalDrip;
		require(_amount > 0, "no balance");
		IERC20(_token).safeTransfer(msg.sender, _amount);
	}

	/*
	// allows withdrawing excess xYIELD, it will not withdraw more than what has been allocated for users
	function recoverReserve(uint256 _amount) external onlyLiquidityTaker nonReentrant
	{
		uint256 _reserve = IERC20(yieldToken).balanceOf(address(this));
		uint256 _available = _reserve > totalYield ? _reserve - totalYield : 0;
		require(_amount <= _available, "insufficient balance");
		IERC20(yieldToken).safeTransfer(msg.sender, _amount);
	}
	*/

	// stakes xHMINE (sender collects xYIELD)
	function deposit(uint256 _amount) external nonReentrant
	{
		_deposit(msg.sender, _amount, msg.sender/*, true*/);

		emit Deposit(msg.sender, hmineToken, _amount);
	}

	// stakes xHMINE on behalf of another account (which collects  xYIELD)
	function depositOnBehalfOf(uint256 _amount, address _account) external nonReentrant
	{
		_deposit(msg.sender, _amount, _account/*, true*/);

		emit Deposit(_account, hmineToken, _amount);
	}

	function _deposit(address _sender, uint256 _amount, address _account/*, bool _collectYield*/) internal
	{
		require(_amount > 0, "invalid amount");

		/*
		// collects xYIELD for account
		if (_collectYield) {
			uint256 _yieldAmount = yieldFactor * _amount / 1e18;

			AccountInfo storage _accountInfo = accountInfo[_account];

			_accountInfo.yield += _yieldAmount;

			totalYield += _yieldAmount;
		}
		*/

		_updateDay();

		uint256 _1percent = _amount * 1e16 / 100e16;
		uint256 _dripAmount = 8 * _1percent;
		uint256 _netAmount = _amount - (11 * _1percent);

		// 8% accounted for the drip pool
		totalDrip += _dripAmount;

		// 1% instant rewards (only 7% actually go to the drip pool)
		if (totalStaked > 0) {
			accDripPerShare += _1percent * 1e18 / totalStaked;
			allocDrip += _1percent;
		}

		_updateAccount(_account, int256(_netAmount));

		totalStaked += _netAmount;

		if (_sender == address(this)) {
			IERC20(hmineToken).safeTransfer(FURNACE, _1percent);
			IERC20(hmineToken).safeTransfer(bankroll, _1percent);
		} else {
			IERC20(hmineToken).safeTransferFrom(_sender, address(this), _netAmount + _dripAmount + _1percent);
			IERC20(hmineToken).safeTransferFrom(_sender, FURNACE, _1percent);
			IERC20(hmineToken).safeTransferFrom(_sender, bankroll, _1percent);
		}

		// rewards Volatile VDC users
		IERC20(hmineToken).safeApprove(hmineVolatile, _1percent);
		HmineVolatile(hmineVolatile).rewardAll(_1percent);

		// stakes on the main staking contract
		IERC20(hmineToken).safeApprove(hmineMain2, _netAmount);
		HmineMain2(hmineMain2).deposit(_netAmount);
	}

	// unstakes xHMINE
	function withdraw(uint256 _amount) external nonReentrant
	{
		require(_amount > 0, "invalid amount");

		AccountInfo storage _accountInfo = accountInfo[msg.sender];
		require(_amount <= _accountInfo.amount, "insufficient balance");

		_updateDay();

		_updateAccount(msg.sender, -int256(_amount));

		totalStaked -= _amount;

		// unstakes from the main staking contract
		(,,,,,,bool _whitelisted) = HmineMain2(hmineMain2).accountInfo(address(this));
		require(_whitelisted, "not whitelisted");
		HmineMain2(hmineMain2).withdraw(_amount);

		if (_accountInfo.whitelisted || whitelistAll) {
			IERC20(hmineToken).safeTransfer(msg.sender, _amount);
		} else {
			uint256 _1percent = _amount * 1e16 / 100e16;
			uint256 _dripAmount = 8 * _1percent;
			uint256 _netAmount = _amount - (11 * _1percent);

			// 8% accounted for the drip pool
			totalDrip += _dripAmount;

			// 1% instant rewards (only 7% actually go to the drip pool)
			if (totalStaked > 0) {
				accDripPerShare += _1percent * 1e18 / totalStaked;
				allocDrip += _1percent;
			}

			IERC20(hmineToken).safeTransfer(FURNACE, _1percent);
			IERC20(hmineToken).safeTransfer(bankroll, _1percent);

			// rewards Volatile VDC users
			IERC20(hmineToken).safeApprove(hmineVolatile, _1percent);
			HmineVolatile(hmineVolatile).rewardAll(_1percent);

			IERC20(hmineToken).safeTransfer(msg.sender, _netAmount);
		}

		emit Withdraw(msg.sender, hmineToken, _amount);
	}

	// claims all 3 rewards: BUSD, xHMINE, and xYIELD respectivelly
	function claim() external nonReentrant returns (uint256 _rewardAmount, uint256 _dripAmount/*, uint256 _yieldAmount*/)
	{
		_updateDay();

		_updateAccount(msg.sender, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		_rewardAmount = _accountInfo.reward;
		_dripAmount = _accountInfo.drip;
		/*_yieldAmount = _accountInfo.yield;*/

		_accountInfo.reward = 0;
		_accountInfo.drip = 0;
		/*_accountInfo.yield = 0;*/

		if (_rewardAmount > 0) {
			totalReward -= _rewardAmount;

			IERC20(rewardToken).safeTransfer(msg.sender, _rewardAmount);

			emit Claim(msg.sender, rewardToken, _rewardAmount);
		}

		if (_dripAmount > 0) {
			totalDrip -= _dripAmount;
			allocDrip -= _dripAmount;

			IERC20(hmineToken).safeTransfer(msg.sender, _dripAmount);

			emit Claim(msg.sender, hmineToken, _dripAmount);
		}

		/*
		if (_yieldAmount > 0) {
			totalYield -= _yieldAmount;

			// this will fail if not enough xYIELD is fed into the contract
			IERC20(yieldToken).safeTransfer(msg.sender, _yieldAmount);

			emit Claim(msg.sender, yieldToken, _yieldAmount);
		}
		*/

		return (_rewardAmount, _dripAmount/*, _yieldAmount*/);
	}

	// compounds all BUSD and xHMINE rewards
	function compound() external nonReentrant
	{
		_updateDay();

		_updateAccount(msg.sender, 0);

		AccountInfo storage _accountInfo = accountInfo[msg.sender];

		uint256 _rewardAmount = _accountInfo.reward;
		uint256 _dripAmount = _accountInfo.drip;

		_accountInfo.reward = 0;
		_accountInfo.drip = 0;

		uint256 _convertedRewardAmount = 0;
		if (_rewardAmount > 0) {
			IERC20(rewardToken).approve(hmineMain1, _rewardAmount);
			_convertedRewardAmount = HmineMain1(hmineMain1).buy(_rewardAmount);

			(,,,,,,bool _whitelisted) = HmineMain2(hmineMain2).accountInfo(address(this));
			require(_whitelisted, "not whitelisted");
			HmineMain2(hmineMain2).withdraw(_convertedRewardAmount);
		}

		uint256 _convertedRewardPlusDripAmount = _convertedRewardAmount + _dripAmount;
		if (_convertedRewardPlusDripAmount > 0) {
			totalReward -= _rewardAmount;

			totalDrip -= _dripAmount;
			allocDrip -= _dripAmount;

			_deposit(address(this), _convertedRewardPlusDripAmount, msg.sender/*, false*/);
		}

		emit Compound(msg.sender, hmineToken, _convertedRewardPlusDripAmount);
	}

	// sends BUSD to a set of accounts
	function reward(address[] calldata _accounts, uint256[] calldata _amounts) external nonReentrant
	{
		require(_accounts.length == _amounts.length, "lenght mismatch");

		uint256 _amount = 0;

		for (uint256 _i = 0; _i < _accounts.length; _i++) {
			address _account = _accounts[_i];
			AccountInfo storage _accountInfo = accountInfo[_account];

			_accountInfo.reward += _amounts[_i];

			emit Reward(_account, rewardToken, _amounts[_i]);

			_amount += _amounts[_i];
		}

		if (_amount > 0) {
			totalReward += _amount;

			IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);
		}
	}

	// sends BUSD to all stakers
	function rewardAll(uint256 _amount) external nonReentrant
	{
		require(_amount > 0, "invalid amount");

		if (totalStaked == 0) {
			IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);
			return;
		}

		_updateDay();

		accRewardPerShare += _amount * 1e18 / totalStaked;

		totalReward += _amount;

		IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);

		emit RewardAll(msg.sender, rewardToken, _amount);
	}

	// performs the daily distribution from staking (BUSD) and the drip pool (xHMINE)
	function updateDay() external nonReentrant
	{
		_updateDay();
	}

	function _updateDay() internal
	{
		uint64 _today = today();

		if (day == _today) return;

		if (totalStaked > 0) {
			// distributes rewards from staking on HmainMain2
			{
				uint256 _amount = HmineMain2(hmineMain2).claim();
				accRewardPerShare += _amount * 1e18 / totalStaked;
				totalReward += _amount;
			}

			// calculates the percentage of the drip pool and distributes
			{
				// formula: drip_reward = drip_pool_balance * (1 - (1 - drip_rate_per_day) ^ days_ellapsed)
				uint64 _days = _today - day;
				uint256 _rate = 100e16 - _exp(100e16 - dripRatePerDay, _days);
				uint256 _amount = (totalDrip - allocDrip) * _rate / 100e16;
				accDripPerShare += _amount * 1e18 / totalStaked;
				allocDrip += _amount;
			}
		}

		day = _today;
	}

	// updates the account balances while accumulating reward/drip using PCS distribution algorithm
	function _updateAccount(address _account, int256 _amount) internal
	{
		AccountInfo storage _accountInfo = accountInfo[_account];
		if (!_accountInfo.exists) {
			// adds account to index
			_accountInfo.exists = true;
			accountIndex.push(_account);
		}

		_accountInfo.reward += _accountInfo.amount * accRewardPerShare / 1e18 - _accountInfo.accRewardDebt;
		_accountInfo.drip += _accountInfo.amount * accDripPerShare / 1e18 - _accountInfo.accDripDebt;
		if (_amount > 0) {
			_accountInfo.amount += uint256(_amount);
		}
		else
		if (_amount < 0) {
			_accountInfo.amount -= uint256(-_amount);
		}
		_accountInfo.accRewardDebt = _accountInfo.amount * accRewardPerShare / 1e18;
		_accountInfo.accDripDebt = _accountInfo.amount * accDripPerShare / 1e18;
	}

	// exponentiation with integer exponent
	function _exp(uint256 _x, uint256 _n) internal pure returns (uint256 _y)
	{
		_y = 1e18;
		while (_n > 0) {
			if (_n & 1 != 0) _y = _y * _x / 1e18;
			_n >>= 1;
			_x = _x * _x / 1e18;
		}
		return _y;
	}

	event Deposit(address indexed _account, address indexed _hmineToken, uint256 _amount);
	event Withdraw(address indexed _account, address indexed _hmineToken, uint256 _amount);
	event Claim(address indexed _account, address indexed _rewardToken, uint256 _amount);
	event Compound(address indexed _account, address indexed _rewardToken, uint256 _amount);
	event Reward(address indexed _account, address indexed _rewardToken, uint256 _amount);
	event RewardAll(address indexed _account, address indexed _rewardToken, uint256 _amount);
}


// File contracts/HmineMain.sol


pragma solidity 0.8.9;




contract HmineMain is Ownable, ReentrancyGuard
{
	using SafeERC20 for IERC20;

	struct User {
		string nickname;
		address user;
		uint256 amount;
		uint256 reward;
	}

	// dead address to receive "burnt" tokens
	address public constant FURNACE = 0x000000000000000000000000000000000000dEaD;

	address[4] public management = [
		0x5C9dE63470D0D6d8103f7c83F1Be4F55998706FC, // 0 Loft
		0x2165fa4a32B9c228cD55713f77d2e977297D03e8, // 1 Ghost
		0x70F5FB6BE943162545a496eD120495B05dC5ce07, // 2 Mike
		0x36b13280500AEBC5A75EbC1e9cB9Bf1b6A78a95e // 3 Miko
	];

	address public constant safeHolders = 0xcD8dDeE99C0c4Be4cD699661AE9c00C69D1Eb4A8;

	address public bankroll = 0x25be1fcF5F51c418a0C30357a4e8371dB9cf9369; // 4 Way Multisig wallet
	address public rewardGiver = 0x2165fa4a32B9c228cD55713f77d2e977297D03e8; // Ghost
	address public immutable currencyToken; // Will likely be DAI
	address public immutable hmineToken;

	uint256 public startTime;
	uint256 public index;
	uint256 public totalSold; // The contract will start with 100,000 Sold HMINE.
	uint256 public totalStaked; // The contract will start with 100,000 Staked HMINE.
	uint256 public currentPrice = 7e18; // The price is divisible by 1e18.  So in this case 7.00 is the current price.
	uint256 public constant roundIncrement = 1_000e18;
	uint256 public rewardTotal;
	uint256 public constant maxSupply = 200_000e18;
	uint256 public constant firstRound = 100_000e18;
	uint256 public constant secondRound = 101_000e18;

	mapping(address => uint256) public userIndex;
	mapping(uint256 => User) public users;

	// The user's pending reward is user's balance multiplied by the accumulated reward per share minus the user's reward debt.
	// The user's reward debt is always set to balance multiplied by the accumulated reward per share when reward's are distributed
	// (or balance changes, which also forces distribution), such that the diference immediately after distribution is always zero (nothing left)
	uint256 public accRewardPerShare;
	mapping(address => uint256) public userRewardDebt;

	modifier onlyRewardGiver()
	{
		require(msg.sender == rewardGiver, "Unauthorized");
		_;
	}

	modifier isRunning(bool _flag)
	{
		require((startTime != 0 && startTime <= block.timestamp) == _flag, "Unavailable");
		_;
	}

	constructor(address _currenctyToken, address _hmineToken)
	{
		currencyToken = _currenctyToken;
		hmineToken = _hmineToken;
	}

	// Start the contract.
	// Will not initialize if already started.
	function initialize(uint256 _startTime) external onlyOwner isRunning(false)
	{
		startTime = _startTime;

		// Admin is supposed to send an additional 100k HMINE to the contract
		uint256 _balance = IERC20(hmineToken).balanceOf(address(this));
		require(_balance == maxSupply, "Missing hmine balance");
	}

	// Used to initally migrate the user data from the sacrifice round. Can be run multiple times. Do 10 at a time.
	function migrateSacrifice(User[] memory _users) external onlyOwner nonReentrant isRunning(false)
	{
		uint256 _amountSum = 0;
		uint256 _rewardSum = 0;
		for (uint256 _i = 0; _i < _users.length; _i++) {
			address _userAddress = _users[_i].user;
			require(_userAddress != address(0), "Invalid address");
			require(userIndex[_userAddress] == 0, "Duplicate user");
			uint256 _index = _assignUserIndex(_userAddress);
			users[_index] = _users[_i];
			_amountSum += _users[_i].amount;
			_rewardSum += _users[_i].reward;
		}

		// Admin sends send initial token deposits to the contract
		IERC20(hmineToken).safeTransferFrom(msg.sender, address(this), _amountSum);
		totalSold += _amountSum;
		totalStaked += _amountSum;

		// Admin must send initial rewards to the contract
		IERC20(currencyToken).safeTransferFrom(msg.sender, address(this), _rewardSum);
		rewardTotal += _rewardSum;

		// Sanity check, pre-sale must not exceed 100k
		require(totalSold <= 100_000e18, "Migration excess");
	}

	// Total liquidity of HMINE available for trades.
	function hmineReserve() external view returns (uint256 _hmineReserve)
	{
		uint256 _balance = IERC20(hmineToken).balanceOf(address(this));
		return _balance - totalStaked;
	}

	// Total liquidity of DAI available for trades.
	function currencyReserve() external view returns (uint256 _currencyReserve)
	{
		uint256 _balance = IERC20(currencyToken).balanceOf(address(this));
		return _balance - rewardTotal;
	}

	// Allows for withdrawing DAI liquidity.
	// Admin is supposed to send the DAI liquidity directly to the contract.
	function recoverReserve(uint256 _amount) external onlyRewardGiver nonReentrant
	{
		// Checks to make sure there is enough dai on contract to fullfill the withdrawal.
		uint256 _balance = IERC20(currencyToken).balanceOf(address(this));
		uint256 _available = _balance - rewardTotal;
		require(_amount <= _available, "Insufficient DAI on Contract");

		// Send DAI to user.  User only get's 60% of the selling price.
		IERC20(currencyToken).safeTransfer(msg.sender, _amount);
	}

	// An external function to calculate the swap value.
	// If it's a buy then calculate the amount of HMINE you get for the DAI input.
	// If it's a sell then calculate the amount of DAI you get for the HMINE input.
	function calculateSwap(uint256 _amount, bool _isBuy) external view returns (uint256 _value)
	{
		(_value, ) = _isBuy ? _getBuyValue(_amount) : _getSellValue(_amount);
		return _value;
	}

	// Input the amount a DAI and return the HMINE value.
	// It takes into account the price upscale in case a round has been met during the buy.
	function _getBuyValue(uint256 _amount) internal view returns (uint256 _hmineValue, uint256 _price)
	{
		_price = currentPrice;
		_hmineValue = (_amount * 1e18) / _price;
		// Fixed price if below second round
		if (totalSold + _hmineValue <= secondRound) {
			// Increment price if second round is reached
			if (totalSold + _hmineValue == secondRound) {
				_price += 3e18;
			}
		}
		// Price calculation when beyond the second round
		else {
			_hmineValue = 0;
			uint256 _amountLeftOver = _amount;
			uint256 _roundAvailable = roundIncrement -
			(totalSold % roundIncrement);

			// If short of first round, adjust up to first round
			if (totalSold < firstRound) {
				_hmineValue += firstRound - totalSold;
				_amountLeftOver -= (_hmineValue * _price) / 1e18;
				_roundAvailable = roundIncrement;
			}

			uint256 _valueOfLeftOver = (_amountLeftOver * 1e18) / _price;
			if (_valueOfLeftOver < _roundAvailable) {
				_hmineValue += _valueOfLeftOver;
			} else {
				_hmineValue += _roundAvailable;
				_amountLeftOver = ((_valueOfLeftOver - _roundAvailable) * _price) / 1e18;
				_price += 3e18;
				while (_amountLeftOver > 0) {
					_valueOfLeftOver = (_amountLeftOver * 1e18) / _price;
					if (_valueOfLeftOver >= roundIncrement) {
						_hmineValue += roundIncrement;
						_amountLeftOver = ((_valueOfLeftOver - roundIncrement) * _price) / 1e18;
						_price += 3e18;
					} else {
						_hmineValue += _valueOfLeftOver;
						_amountLeftOver = 0;
					}
				}
			}
		}
		return (_hmineValue, _price);
	}

	// This internal function is used to calculate the amount of DAI user will receive.
	// It takes into account the price reversal in case rounds have reversed during a sell order.
	function _getSellValue(uint256 _amount) internal view returns (uint256 _sellValue, uint256 _price)
	{
		_price = currentPrice;
		uint256 _roundAvailable = totalSold % roundIncrement;
		// Still in current round.
		if (_amount <= _roundAvailable) {
			_sellValue = (_amount * _price) / 1e18;
		}
		// Amount plus the mod total tells us tha the round or rounds will most likely be reached.
		else {
			_sellValue = (_roundAvailable * _price) / 1e18;
			uint256 _amountLeftOver = _amount - _roundAvailable;
			while (_amountLeftOver > 0) {
				if (_price > 7e18) {
					_price -= 3e18;
				}
				if (_amountLeftOver > roundIncrement) {
					_sellValue += (roundIncrement * _price) / 1e18;
					_amountLeftOver -= roundIncrement;
				} else {
					_sellValue += (_amountLeftOver * _price) / 1e18;
					_amountLeftOver = 0;
				}
			}
		}
		return (_sellValue, _price);
	}

	// Buy HMINE with DAI
	function buy(uint256 _amount) external nonReentrant isRunning(true)
	{
		require(_amount > 0, "Invalid amount");

		(uint256 _hmineValue, uint256 _price) = _getBuyValue(_amount);

		// Used to send funds to the appropriate wallets and update global data
		_buyInternal(msg.sender, _amount, _hmineValue, _price);

		emit Buy(msg.sender, _hmineValue, _price);
	}

	// Used to send funds to the appropriate wallets and update global data
	// The buy and compound function calls this internal function.
	function _buyInternal(address _sender, uint256 _amount, uint256 _hmineValue, uint256 _price) internal
	{
		// Checks to make sure supply is not exeeded.
		require(totalSold + _hmineValue <= maxSupply, "Exceeded supply");

		// Sends 7.5% / 4 to Loft, Ghost, Mike, Miko
		uint256 _managementAmount = ((_amount * 75) / 1000) / 4;

		// Sends 2.5% to SafeHolders
		uint256 _safeHoldersAmount = (_amount * 25) / 1000;

		// Sends 80% to bankroll
		uint256 _bankrollAmount = (_amount * 80) / 100;

		// Sends or keeps 10% to/in the contract for divs
		uint256 _amountToStakers = _amount - (4 * _managementAmount + _safeHoldersAmount + _bankrollAmount);

		if (_sender == address(this)) {
			for (uint256 _i = 0; _i < 4; _i++) {
				IERC20(currencyToken).safeTransfer(management[_i], _managementAmount);
			}
			IERC20(currencyToken).safeTransfer(safeHolders, _safeHoldersAmount);
			IERC20(currencyToken).safeTransfer(bankroll, _bankrollAmount);
		} else {
			for (uint256 _i = 0; _i < 4; _i++) {
				IERC20(currencyToken).safeTransferFrom(_sender, management[_i], _managementAmount);
			}
			IERC20(currencyToken).safeTransferFrom(_sender, safeHolders, _safeHoldersAmount);
			IERC20(currencyToken).safeTransferFrom(_sender, bankroll, _bankrollAmount);
			IERC20(currencyToken).safeTransferFrom(_sender, address(this), _amountToStakers);
		}

		_distributeRewards(_amountToStakers);

		// Update user's stake entry.
		uint256 _index = _assignUserIndex(msg.sender);
		users[_index].user = msg.sender; // just in case it was not yet initialized
		_collectsUserRewardAndUpdatesBalance(users[_index], int256(_hmineValue));

		// Update global values.
		totalSold += _hmineValue;
		totalStaked += _hmineValue;
		currentPrice = _price;
		rewardTotal += _amountToStakers;
	}

	// Sell HMINE for DAI
	function sell(uint256 _amount) external nonReentrant isRunning(true)
	{
		require(_amount > 0, "Invalid amount");

		(uint256 _sellValue, uint256 _price) = _getSellValue(_amount);

		// Sends HMINE to contract
		IERC20(hmineToken).safeTransferFrom(msg.sender, address(this), _amount);

		uint256 _60percent = (_sellValue * 60) / 100;

		// Checks to make sure there is enough dai on contract to fullfill the swap.
		uint256 _balance = IERC20(currencyToken).balanceOf(address(this));
		uint256 _available = _balance - rewardTotal;
		require(_60percent <= _available, "Insufficient DAI on Contract");

		// Send DAI to user.  User only get's 60% of the selling price.
		IERC20(currencyToken).safeTransfer(msg.sender, _60percent);

		// Update global values.
		totalSold -= _amount;
		currentPrice = _price;

		emit Sell(msg.sender, _amount, _price);
	}

	// Stake HMINE
	function stake(uint256 _amount) external nonReentrant isRunning(true)
	{
		require(_amount > 0, "Invalid amount");
		uint256 _index = _assignUserIndex(msg.sender);
		users[_index].user = msg.sender; // just in case it was not yet initialized

		// User sends HMINE to the contract to stake
		IERC20(hmineToken).safeTransferFrom(msg.sender, address(this), _amount);

		// Update user's staking amount
		_collectsUserRewardAndUpdatesBalance(users[_index], int256(_amount));
		// Update total staking amount
		totalStaked += _amount;
	}

	// Unstake HMINE
	function unstake(uint256 _amount) external nonReentrant isRunning(true)
	{
		require(_amount > 0, "Invalid amount");
		uint256 _index = userIndex[msg.sender];
		require(_index != 0, "Not staked yet");
		require(users[_index].amount >= _amount, "Inefficient stake balance");

		uint256 _10percent = (_amount * 10) / 100;
		uint256 _80percent = _amount - 2 * _10percent;

		// Goes to burn address
		IERC20(hmineToken).safeTransfer(FURNACE, _10percent);
		// Goes to bankroll
		IERC20(hmineToken).safeTransfer(bankroll, _10percent);
		// User only gets 80% HMINE
		IERC20(hmineToken).safeTransfer(msg.sender, _80percent);

		// Update user's staking amount
		_collectsUserRewardAndUpdatesBalance(users[_index], -int256(_amount));
		// Update total staking amount
		totalStaked -= _amount;
	}

	// Adds a nickname to the user.
	function updateNickname(string memory _nickname) external
	{
		uint256 _index = userIndex[msg.sender];
		require(index != 0, "User does not exist");
		users[_index].nickname = _nickname;
	}

	// Claim DIV as DAI
	function claim() external nonReentrant
	{
		uint256 _index = userIndex[msg.sender];
		require(index != 0, "User does not exist");
		_collectsUserRewardAndUpdatesBalance(users[_index], 0);
		uint256 _claimAmount = users[_index].reward;
		require(_claimAmount > 0, "No rewards to claim");
		rewardTotal -= _claimAmount;
		users[_index].reward = 0;
		IERC20(currencyToken).safeTransfer(msg.sender, _claimAmount);
	}

	// Compound the divs.
	// Uses the div to buy more HMINE internally by calling the _buyInternal.
	function compound() external nonReentrant isRunning(true)
	{
		uint256 _index = userIndex[msg.sender];
		require(index != 0, "User does not exist");
		_collectsUserRewardAndUpdatesBalance(users[_index], 0);
		uint256 _claimAmount = users[_index].reward;
		require(_claimAmount > 0, "No rewards to claim");
		// Removes the the claim amount from total divs for tracing purposes.
		rewardTotal -= _claimAmount;
		// remove the div from the users reward pool.
		users[_index].reward = 0;

		(uint256 _hmineValue, uint256 _price) = _getBuyValue(_claimAmount);

		_buyInternal(address(this), _claimAmount, _hmineValue, _price);

		emit Compound(msg.sender, _hmineValue, _price);
	}

	// Reward giver sends bonus DIV to top 20 holders
	function sendBonusDiv(uint256 _amount, address[] memory _topTen, address[] memory _topTwenty) external onlyRewardGiver nonReentrant isRunning(true)
	{
		require(_amount > 0, "Invalid amount");

		// Admin sends div to the contract
		IERC20(currencyToken).safeTransferFrom(msg.sender, address(this), _amount);

		require(_topTen.length == 10 && _topTwenty.length == 10, "Invalid arrays");

		// 75% split between topTen
		uint256 _topTenAmount = ((_amount * 75) / 100) / 10;
		// 25% split between topTwenty
		uint256 _topTwentyAmount = ((_amount * 25) / 100) / 10;

		for (uint256 _i = 0; _i < 10; _i++) {
			uint256 _index = userIndex[_topTen[_i]];
			require(_index != 0, "A user doesn't exist");
			users[_index].reward += _topTenAmount;
		}

		for (uint256 _i = 0; _i < 10; _i++) {
			uint256 _index = userIndex[_topTwenty[_i]];
			require(_index != 0, "A user doesn't exist");
			users[_index].reward += _topTwentyAmount;
		}

		uint256 _leftOver = _amount - 10 * (_topTenAmount + _topTwentyAmount);
		users[userIndex[_topTen[0]]].reward += _leftOver;

		rewardTotal += _amount;

		emit BonusReward(_amount);
	}

	// Reward giver sends daily divs to all holders
	function sendDailyDiv(uint256 _amount) external onlyRewardGiver nonReentrant isRunning(true)
	{
		require(_amount > 0, "Invalid amount");

		// Admin sends div to the contract
		IERC20(currencyToken).safeTransferFrom(msg.sender, address(this), _amount);

		_distributeRewards(_amount);

		rewardTotal += _amount;
	}

	// Calculates actual user reward balance
	function userRewardBalance(address _userAddress) external view returns (uint256 _reward)
	{
		User storage _user = users[userIndex[_userAddress]];
		// The difference is the user's share of rewards distributed since the last collection
		uint256 _newReward = (_user.amount * accRewardPerShare) / 1e12 - userRewardDebt[_user.user];
		return _user.reward + _newReward;
	}

	// Distributes reward amount to all users propotionally to their stake.
	function _distributeRewards(uint256 _amount) internal
	{
		accRewardPerShare += (_amount * 1e12) / totalStaked;
	}

	// Collects pending rewards and updates user balance.
	function _collectsUserRewardAndUpdatesBalance(User storage _user, int256 _amountDelta) internal
	{
		// The difference is the user's share of rewards distributed since the last collection/reset
		uint256 _newReward = (_user.amount * accRewardPerShare) / 1e12 - userRewardDebt[_user.user];
		_user.reward += _newReward;
		if (_amountDelta >= 0) {
			_user.amount += uint256(_amountDelta);
		} else {
			_user.amount -= uint256(-_amountDelta);
		}
		// Resets user's reward debt so that the difference is zero
		userRewardDebt[_user.user] = (_user.amount * accRewardPerShare) / 1e12;
	}

	// Show user by address
	function getUserByAddress(address _userAddress) external view returns (User memory _user)
	{
		return users[userIndex[_userAddress]];
	}

	// Show user by index
	function getUserByIndex(uint256 _index) external view returns (User memory _user)
	{
		return users[_index];
	}

	// Takes in a user address and finds an existing index that is corelated to the user.
	// If index not found (ZERO) then it assigns an index to the user.
	function _assignUserIndex(address _user) internal returns (uint256 _index)
	{
		if (userIndex[_user] == 0) userIndex[_user] = ++index;
		return userIndex[_user];
	}

	// Updates the management and reward giver address.
	function updateStateAddresses(address _rewardGiver, address _bankRoll) external onlyOwner
	{
		require(_bankRoll != address(0) && _bankRoll != address(this), "Invalid address");
		require(_rewardGiver != address(0) && _rewardGiver != address(this), "Invalid address");
		bankroll = _bankRoll;
		rewardGiver = _rewardGiver;
	}

	// Updates the management.
	function updateManagement(address _management, uint256 _i) external onlyOwner
	{
		require(_management != address(0) && _management != address(this), "Invalid address");
		require(_i < 4, "Invalid entry");
		management[_i] = _management;
	}

	event Buy(address indexed _user, uint256 _amount, uint256 _price);
	event Sell(address indexed _user, uint256 _amount, uint256 _price);
	event Compound(address indexed _user, uint256 _amount, uint256 _price);
	event BonusReward(uint256 _amount);
}


// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]



pragma solidity ^0.8.0;

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}


// File @openzeppelin/contracts/token/ERC20/[email protected]



pragma solidity ^0.8.0;



/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


// File contracts/HmineToken.sol


pragma solidity 0.8.9;

contract HmineToken is ERC20("xHYPERMINE Token", "xHMINE")
{
	constructor()
	{
		_mint(msg.sender, 200_000e18);
	}

	function airdrop(address[] calldata _accounts, uint256[] calldata _amounts) external
	{
		require(_accounts.length == _amounts.length, "lenght mismatch");
		for (uint256 _i = 0; _i < _accounts.length; _i++) {
		        _transfer(msg.sender, _accounts[_i], _amounts[_i]);
		}
	}
}


// File contracts/YieldToken.sol


pragma solidity 0.8.9;

contract YieldToken is ERC20("xYIELD Token", "xYIELD")
{
	constructor()
	{
		_mint(msg.sender, 111_000_000e18);
	}

	function airdrop(address[] calldata _accounts, uint256[] calldata _amounts) external
	{
		require(_accounts.length == _amounts.length, "lenght mismatch");
		for (uint256 _i = 0; _i < _accounts.length; _i++) {
		        _transfer(msg.sender, _accounts[_i], _amounts[_i]);
		}
	}
}