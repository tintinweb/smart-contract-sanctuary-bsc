// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Address.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.9;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";

contract CasinoVault is Ownable
{
	using Address for address payable;

	struct AccountInfo {
		bool exists;
		uint256 amount;
		uint256 locked;
	}

	uint256 public usersAmount;
	uint256 public houseAmount;

	address[] public accountIndex;
	mapping(address => AccountInfo) public accountInfo;

	mapping(address => bool) public operators;

	modifier onlyOperator()
	{
		require(operators[msg.sender], "access denied");
		_;
	}

	function accountIndexLength() external view returns (uint256 _length)
	{
		return accountIndex.length;
	}

	function getAccountByIndex(uint256 _index) external view returns (AccountInfo memory _accountInfo)
	{
		return accountInfo[accountIndex[_index]];
	}

	function updateOperators(address[] memory _accounts, bool _enabled) external onlyOwner
	{
		for (uint256 _i = 0; _i < _accounts.length; _i++) {
			operators[_accounts[_i]] = _enabled;
		}
	}

	function fund() external payable
	{
		houseAmount += msg.value;
		emit Fund(msg.value);
	}

	function defund(address payable _account, uint256 _amount) external onlyOwner
	{
		require(_amount <= houseAmount, "exceeds balance");
		houseAmount -= _amount;
		emit Defund(_account, _amount);
		_account.sendValue(_amount);
	}

	function deposit(address _account) external payable
	{
		AccountInfo storage _accountInfo = accountInfo[_account];
		if (!_accountInfo.exists) {
			_accountInfo.exists = true;
			accountIndex.push(_account);
		}
		usersAmount += msg.value;
		_accountInfo.amount += msg.value;
		emit Deposit(_account, msg.value);
	}

	function withdraw(address payable _account, uint256 _amount) external
	{
		AccountInfo storage _accountInfo = accountInfo[msg.sender];
		require(_amount <= _accountInfo.amount, "exceeds balance");
		_accountInfo.amount -= _amount;
		usersAmount -= _amount;
		emit Withdraw(_account, _amount);
		_account.sendValue(_amount);
	}

	function lock(address _account, uint256 _amount) external onlyOperator
	{
		AccountInfo storage _accountInfo = accountInfo[_account];
		require(_amount <= _accountInfo.amount, "exceeds balance");
		_accountInfo.amount -= _amount;
		_accountInfo.locked += _amount;
		emit Lock(_account, _amount);
	}

	function free(address _account, uint256 _amount) external onlyOperator
	{
		AccountInfo storage _accountInfo = accountInfo[_account];
		require(_amount <= _accountInfo.locked, "exceeds balance");
		_accountInfo.locked -= _amount;
		_accountInfo.amount += _amount;
		emit Free(_account, _amount);
	}

	function seize(address _account, uint256 _amount) external onlyOperator
	{
		AccountInfo storage _accountInfo = accountInfo[_account];
		require(_amount <= _accountInfo.locked, "exceeds balance");
		_accountInfo.locked -= _amount;
		usersAmount -= _amount;
		houseAmount += _amount;
		emit Seize(_account, _amount);
	}

	function payout(address _account, uint256 _amount) external onlyOperator
	{
		require(_amount <= houseAmount, "exceeds balance");
		AccountInfo storage _accountInfo = accountInfo[_account];
		if (!_accountInfo.exists) {
			_accountInfo.exists = true;
			accountIndex.push(_account);
		}
		houseAmount -= _amount;
		usersAmount += _amount;
		_accountInfo.amount += _amount;
		emit Payout(_account, _amount);
	}

	event Fund(uint256 _amount);
	event Defund(address indexed _account, uint256 _amount);
	event Deposit(address indexed _account, uint256 _amount);
	event Withdraw(address indexed _account, uint256 _amount);
	event Lock(address indexed _account, uint256 _amount);
	event Free(address indexed _account, uint256 _amount);
	event Seize(address indexed _account, uint256 _amount);
	event Payout(address indexed _account, uint256 _amount);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.9;

import { CasinoVault } from "./CasinoVault.sol";
import { RandomnessBeacon } from "./RandomnessBeacon.sol";

contract DiceGame
{
	struct BetInfo {
		uint256 timestamp;
		address account;
		uint256 low;
		uint256 high;
		uint256 amount;
		uint256 payout;
		uint256 epoch;
		uint256 choice;
	}

	address public casinoVault;
	address public randomnessBeacon;

	BetInfo[] public bets;
	uint256 public last;

	constructor(address _casinoVault, address _randomnessBeacon)
	{
		casinoVault = _casinoVault;
		randomnessBeacon = _randomnessBeacon;
	}

	function calcBetMultiplier(uint256 _low, uint256 _high) public pure returns (uint256 _multiplier)
	{
		return 99.02e18 / (_high - _low);
	}

	function bet(uint256 _low, uint256 _high, uint256 _amount) external
	{
		require(_low < _high && _high - _low <= 95 && _high <= 100 && (_low == 0 || _high == 100), "invalid range");
		CasinoVault(casinoVault).lock(msg.sender, _amount);
		uint256 _epoch = processBets();
		require(bets.length - last < 100, "limit reached");
		uint256 _payout = _amount * calcBetMultiplier(_low, _high) / 1e18;
		uint256 _betId = bets.length;
		bets.push(BetInfo({
			timestamp: block.timestamp,
			account: msg.sender,
			low: _low,
			high: _high,
			amount: _amount,
			payout: _payout,
			epoch: _epoch,
			choice: 0
		}));
		emit Bet(msg.sender, _betId, _amount, _payout);
	}

	function processBets() public returns (uint256 _epoch)
	{
		_epoch = RandomnessBeacon(randomnessBeacon).requestRandom();
		while (last < bets.length) {
			uint256 _betId = last;
			BetInfo storage _bet = bets[_betId];
			(bool _ready, uint256 _randomValue) = RandomnessBeacon(randomnessBeacon).checkRandom(_bet.epoch);
			if (!_ready) break;
			_bet.choice = 1 + uint256(keccak256(abi.encodePacked(_randomValue, last))) % 100;
			if (_bet.low < _bet.choice && _bet.choice <= _bet.high) {
				CasinoVault(casinoVault).free(_bet.account, _bet.amount);
				CasinoVault(casinoVault).payout(_bet.account, _bet.payout);
				emit Outcome(_bet.account, _betId, _bet.amount, _bet.payout, true);
			} else {
				CasinoVault(casinoVault).seize(_bet.account, _bet.amount);
				emit Outcome(_bet.account, _betId, _bet.amount, _bet.payout, false);
			}
			last++;
		}
		return _epoch;
	}

	event Bet(address indexed _account, uint256 indexed betId, uint256 _amount, uint256 _payout);
	event Outcome(address indexed _account, uint256 indexed betId, uint256 _amount, uint256 _payout, bool indexed _won);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.9;

contract RandomnessBeacon
{
	struct RandomInfo
	{
		uint256 futureBlock;
		uint256 randomValue;
	}

	uint256 public currentEpoch;
	mapping(uint256 => RandomInfo) public entries;

	constructor()
	{
		currentEpoch = 0;
		entries[currentEpoch] = RandomInfo({
			futureBlock: block.number + 5,
			randomValue: block.difficulty
		});
		emit Epoch(currentEpoch);
	}

	function checkRandom(uint256 _epoch) external view returns (bool _ready, uint256 _randomValue)
	{
		return (currentEpoch > _epoch, entries[_epoch].randomValue);
	}

	function resolveRandom(uint256 _epoch) external returns (uint256 _randomValue)
	{
		requestRandom();
		require(currentEpoch > _epoch, "unavailable");
		return entries[_epoch].randomValue;
	}

	function requestRandom() public returns (uint256 _epoch)
	{
		uint256 _futureBlock = entries[currentEpoch].futureBlock;
		if (_futureBlock >= block.number) {
			return currentEpoch;
		}
		if (block.number - 256 > _futureBlock - 5) {
			entries[currentEpoch] = RandomInfo({
				futureBlock: block.number + 5,
				randomValue: block.difficulty
			});
			return currentEpoch;
		}
		entries[currentEpoch].randomValue = uint256(keccak256(abi.encodePacked(
			entries[currentEpoch].randomValue,
			blockhash(_futureBlock),
			blockhash(_futureBlock - 1),
			blockhash(_futureBlock - 2),
			blockhash(_futureBlock - 3),
			blockhash(_futureBlock - 4),
			blockhash(_futureBlock - 5)
		)));
		currentEpoch++;
		entries[currentEpoch] = RandomInfo({
			futureBlock: block.number + 5,
			randomValue: block.difficulty
		});
		emit Epoch(currentEpoch);
		return currentEpoch;
	}

	event Epoch(uint256 indexed _epoch);
}