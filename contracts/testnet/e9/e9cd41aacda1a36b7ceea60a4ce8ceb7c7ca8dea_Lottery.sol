/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

// Sources flattened with hardhat v2.9.3 https://hardhat.org

// File @openzeppelin/contracts-upgradeable/utils/[email protected]

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
	 *
	 * [IMPORTANT]
	 * ====
	 * You shouldn't rely on `isContract` to protect against flash loan attacks!
	 *
	 * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
	 * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
	 * constructor.
	 * ====
	 */
	function isContract(address account) internal view returns (bool) {
		// This method relies on extcodesize/address.code.length, which returns 0
		// for contracts in construction, since the code is only stored at the end
		// of the constructor execution.

		return account.code.length > 0;
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

// File @openzeppelin/contracts-upgradeable/proxy/utils/[email protected]

// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
	/**
	 * @dev Indicates that the contract has been initialized.
	 */
	bool private _initialized;

	/**
	 * @dev Indicates that the contract is in the process of being initialized.
	 */
	bool private _initializing;

	/**
	 * @dev Modifier to protect an initializer function from being invoked twice.
	 */
	modifier initializer() {
		// If the contract is initializing we ignore whether _initialized is set in order to support multiple
		// inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
		// contract may have been reentered.
		require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

		bool isTopLevelCall = !_initializing;
		if (isTopLevelCall) {
			_initializing = true;
			_initialized = true;
		}

		_;

		if (isTopLevelCall) {
			_initializing = false;
		}
	}

	/**
	 * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
	 * {initializer} modifier, directly or indirectly.
	 */
	modifier onlyInitializing() {
		require(_initializing, "Initializable: contract is not initializing");
		_;
	}

	function _isConstructor() private view returns (bool) {
		return !AddressUpgradeable.isContract(address(this));
	}
}

// File @openzeppelin/contracts-upgradeable/token/ERC20/[email protected]

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
	/**
	 * @dev Returns the amount of tokens in existence.
	 */
	function totalSupply() external view returns (uint256);

	/**
	 * @dev Returns the amount of tokens owned by `account`.
	 */
	function balanceOf(address account) external view returns (uint256);

	/**
	 * @dev Moves `amount` tokens from the caller's account to `to`.
	 *
	 * Returns a boolean value indicating whether the operation succeeded.
	 *
	 * Emits a {Transfer} event.
	 */
	function transfer(address to, uint256 amount) external returns (bool);

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
	 * @dev Moves `amount` tokens from `from` to `to` using the
	 * allowance mechanism. `amount` is then deducted from the caller's
	 * allowance.
	 *
	 * Returns a boolean value indicating whether the operation succeeded.
	 *
	 * Emits a {Transfer} event.
	 */
	function transferFrom(
		address from,
		address to,
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

// File @openzeppelin/contracts-upgradeable/utils/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
abstract contract ContextUpgradeable is Initializable {
	function __Context_init() internal onlyInitializing {}

	function __Context_init_unchained() internal onlyInitializing {}

	function _msgSender() internal view virtual returns (address) {
		return msg.sender;
	}

	function _msgData() internal view virtual returns (bytes calldata) {
		return msg.data;
	}

	/**
	 * @dev This empty reserved space is put in place to allow future versions to add new
	 * variables without shifting down storage in the inheritance chain.
	 * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
	 */
	uint256[50] private __gap;
}

// File @openzeppelin/contracts-upgradeable/access/[email protected]

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
	address private _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	/**
	 * @dev Initializes the contract setting the deployer as the initial owner.
	 */
	function __Ownable_init() internal onlyInitializing {
		__Ownable_init_unchained();
	}

	function __Ownable_init_unchained() internal onlyInitializing {
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

	/**
	 * @dev This empty reserved space is put in place to allow future versions to add new
	 * variables without shifting down storage in the inheritance chain.
	 * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
	 */
	uint256[49] private __gap;
}

// File contracts/interfaces/IStakingTicket.sol

pragma solidity ^0.8.9;

/**
 * @dev Required interface of an StaskingTicket compliant contract.
 */
interface IStakingTicket {
	function userTicket(address _add) external;

	function useTicket(uint256 _amount, address _add) external;
}

// File contracts/interfaces/IPrizePool.sol

pragma solidity ^0.8.9;

/**
 * @dev Required interface of an StaskingTicket compliant contract.
 */
interface IPrizePool {
	function updateUserNFTPrize(address user, uint256 randomPrize) external;

	function updateMoneyPrize(address user, uint256 amount) external;
}

// File @openzeppelin/contracts-upgradeable/utils/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
	bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

	/**
	 * @dev Converts a `uint256` to its ASCII `string` decimal representation.
	 */
	function toString(uint256 value) internal pure returns (string memory) {
		// Inspired by OraclizeAPI's implementation - MIT licence
		// https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

		if (value == 0) {
			return "0";
		}
		uint256 temp = value;
		uint256 digits;
		while (temp != 0) {
			digits++;
			temp /= 10;
		}
		bytes memory buffer = new bytes(digits);
		while (value != 0) {
			digits -= 1;
			buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
			value /= 10;
		}
		return string(buffer);
	}

	/**
	 * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
	 */
	function toHexString(uint256 value) internal pure returns (string memory) {
		if (value == 0) {
			return "0x00";
		}
		uint256 temp = value;
		uint256 length = 0;
		while (temp != 0) {
			length++;
			temp >>= 8;
		}
		return toHexString(value, length);
	}

	/**
	 * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
	 */
	function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
		bytes memory buffer = new bytes(2 * length + 2);
		buffer[0] = "0";
		buffer[1] = "x";
		for (uint256 i = 2 * length + 1; i > 1; --i) {
			buffer[i] = _HEX_SYMBOLS[value & 0xf];
			value >>= 4;
		}
		require(value == 0, "Strings: hex length insufficient");
		return string(buffer);
	}
}

// File contracts/utils/Random.sol

pragma solidity ^0.8.0;

contract Random is Initializable, OwnableUpgradeable {
	uint256 randomCounter;
	mapping(address => bool) public whitelistRandom;

	function __Random_init() public initializer {
		__Ownable_init();
	}

	modifier onlyWhitelistRandom() {
		require(whitelistRandom[msg.sender], "Only whitelist");
		_;
	}

	function getRandomSeed() internal view returns (uint256) {
		return
			uint256(
				sha256(
					abi.encodePacked(
						block.coinbase,
						randomCounter,
						blockhash(block.number - 1),
						block.difficulty,
						block.gaslimit,
						block.timestamp,
						gasleft(),
						msg.sender
					)
				)
			);
	}

	function setWhiteList(address _whitelist, bool status) public onlyOwner {
		whitelistRandom[_whitelist] = status;
	}

	// Get random number
	function updateCounter(uint256 addedCounter) public onlyWhitelistRandom {
		unchecked {
			randomCounter += addedCounter;
		}
	}

	// Get random number
	function getRandom(uint256 _rate) public view onlyWhitelistRandom returns (uint256) {
		return (getRandomSeed() % _rate) + 1;
	}
}

// File contracts/Lottery.sol

pragma solidity ^0.8.9;

contract Lottery is Initializable, OwnableUpgradeable {
	/// @dev random contract
	address private random;
	/// @dev staking ticket contract
	address public stakingTicket;
	/// @dev prize pool contract
	address public prizePool;

	/// @dev các loại giải thưởng
	enum PrizeType {
		NFT_MAP,
		PRIZE_ONE,
		PRIZE_TWO,
		PRIZE_THREE,
		PRIZE_FOUR
	}
	/// @dev số lượng giải thưởng
	mapping(PrizeType => uint256) public limitPrize;
	/// @dev số lượng tiền của giải thưởng
	mapping(PrizeType => uint256) public prize;
	/// @dev tỉ lệ quay trúng giải thưởng
	mapping(PrizeType => uint256) public winRate;

	// resultType : 0 - Unlucky , 1 - Get NFT , 2 - Prize 1, 3 - Prize 2, 4 - Prize 3, 5 - Prize 4
	event SpinTicketResult(uint256 indexed resultType, address indexed minter, uint256 indexed amount);

	function __Lottery_init() public initializer {
		__Ownable_init();
		updatePrizeConfig(22, 8, 4, 2, 1);
		updatePrize(1000, 500, 200, 100);
		updateWinRate(61, 22, 11, 6, 3);
	}

	modifier onlyNonContract() {
		require(tx.origin == msg.sender, "Only non-contract call");
		_;
	}

	/// @notice Update số lượng giải thưởng
	/// @param _nftPrizeNumber Số lượng giải thưởng nft
	/// @param _prizeOneNumber Số lượng giải thưởng 1
	/// @param _prizeTwoNumber Số lượng giải thưởng 2
	/// @param _prizeThreeNumber Số lượng giải thưởng 3
	/// @param _prizeFourNumber Số lượng giải thưởng 4
	function updatePrizeConfig(
		uint256 _nftPrizeNumber,
		uint256 _prizeOneNumber,
		uint256 _prizeTwoNumber,
		uint256 _prizeThreeNumber,
		uint256 _prizeFourNumber
	) public onlyOwner {
		limitPrize[PrizeType.NFT_MAP] = _nftPrizeNumber;
		limitPrize[PrizeType.PRIZE_ONE] = _prizeOneNumber;
		limitPrize[PrizeType.PRIZE_TWO] = _prizeTwoNumber;
		limitPrize[PrizeType.PRIZE_THREE] = _prizeThreeNumber;
		limitPrize[PrizeType.PRIZE_FOUR] = _prizeFourNumber;
	}

	/// @notice Update số lượng tiền tương ứng mỗi giải thưởng
	/// @param _amountPrizeOne Số tiền giải thưởng 1
	/// @param _amountPrizeTwo Số tiền giải thưởng 2
	/// @param _amountPrizeThree Số tiền giải thưởng 3
	/// @param _amountPrizeFour Số tiền giải thưởng 4
	function updatePrize(
		uint256 _amountPrizeOne,
		uint256 _amountPrizeTwo,
		uint256 _amountPrizeThree,
		uint256 _amountPrizeFour
	) public onlyOwner {
		prize[PrizeType.PRIZE_ONE] = _amountPrizeOne;
		prize[PrizeType.PRIZE_TWO] = _amountPrizeTwo;
		prize[PrizeType.PRIZE_THREE] = _amountPrizeThree;
		prize[PrizeType.PRIZE_FOUR] = _amountPrizeFour;
	}

	/// @notice Update tỉ lệ quay số trúng mỗi giải
	/// @param _nftPrize Tỉ lệ giải thưởng nft
	/// @param _prizeOne Tỉ lệ giải thưởng 1
	/// @param _prizeTwo Tỉ lệ giải thưởng 2
	/// @param _prizeThree Tỉ lệ giải thưởng 3
	/// @param _prizeFour Tỉ lệ giải thưởng 4
	function updateWinRate(
		uint256 _nftPrize,
		uint256 _prizeOne,
		uint256 _prizeTwo,
		uint256 _prizeThree,
		uint256 _prizeFour
	) public onlyOwner {
		require((_nftPrize + _prizeOne + _prizeTwo + _prizeThree + _prizeFour) < 10000, "Total win rate not valid");
		winRate[PrizeType.NFT_MAP] = _nftPrize;
		winRate[PrizeType.PRIZE_ONE] = winRate[PrizeType.NFT_MAP] + _prizeOne;
		winRate[PrizeType.PRIZE_TWO] = winRate[PrizeType.PRIZE_ONE] + _prizeTwo;
		winRate[PrizeType.PRIZE_THREE] = winRate[PrizeType.PRIZE_TWO] + _prizeThree;
		winRate[PrizeType.PRIZE_FOUR] = winRate[PrizeType.PRIZE_THREE] + _prizeFour;
	}

	/// @notice Update contract address dùng trong contract
	/// @param _random Address contract random dùng để random số
	/// @param _stakingTicket Address contract staking ticket dùng để check số lượng và dùng ticket
	/// @param _prizePool Address contract prize pool dùng để update số lượng giải thưởng nếu quay trúng
	function updateConfig(
		address _random,
		address _stakingTicket,
		address _prizePool
	) public onlyOwner {
		random = _random;
		stakingTicket = _stakingTicket;
		prizePool = _prizePool;
	}

	/// @notice Tính toán và trả về loại giải thưởng và số tiền trúng thưởng
	/// @param _prizeType Loại giải thưởng
	function updateMoneyPrize(PrizeType _prizeType) internal returns (uint256, uint256) {
		uint256 typePrize = 0;
		if (limitPrize[_prizeType] == 0) {
			return (typePrize, 0);
		}
		if (_prizeType == PrizeType.PRIZE_ONE) {
			typePrize = 2;
		} else if (_prizeType == PrizeType.PRIZE_TWO) {
			typePrize = 3;
		} else if (_prizeType == PrizeType.PRIZE_THREE) {
			typePrize = 4;
		} else if (_prizeType == PrizeType.PRIZE_FOUR) {
			typePrize = 5;
		}
		uint256 amount = prize[_prizeType];
		limitPrize[_prizeType] -= 1;
		IPrizePool(prizePool).updateMoneyPrize(msg.sender, amount);
		return (typePrize, amount);
	}

	/// @notice Function quay ticket
	function spinTicketEvent() external onlyNonContract {
		// Check số lượng giải còn lại
		bool prizesLeft = (limitPrize[PrizeType.NFT_MAP] > 0) ||
			(limitPrize[PrizeType.PRIZE_ONE] > 0) ||
			(limitPrize[PrizeType.PRIZE_TWO] > 0) ||
			(limitPrize[PrizeType.PRIZE_THREE] > 0) ||
			(limitPrize[PrizeType.PRIZE_FOUR] > 0);
		require(prizesLeft, "There must be at least one prize for reward");
		IStakingTicket(stakingTicket).useTicket(1, msg.sender);
		// Random 1 số trong khoảng 0 - 10000
		uint256 randomValue = Random(random).getRandom(10000);
		uint256 typePrize = 0;
		uint256 amount = 0;
		// Update giải thường vào prize pool
		if (randomValue <= winRate[PrizeType.NFT_MAP]) {
			if (limitPrize[PrizeType.NFT_MAP] > 0) {
				typePrize = 1;
				amount = 1;
				limitPrize[PrizeType.NFT_MAP] -= 1;
				IPrizePool(prizePool).updateUserNFTPrize(msg.sender, randomValue);
			}
		} else if (randomValue <= winRate[PrizeType.PRIZE_ONE]) {
			(typePrize, amount) = updateMoneyPrize(PrizeType.PRIZE_ONE);
		} else if (randomValue <= winRate[PrizeType.PRIZE_TWO]) {
			(typePrize, amount) = updateMoneyPrize(PrizeType.PRIZE_TWO);
		} else if (randomValue <= winRate[PrizeType.PRIZE_THREE]) {
			(typePrize, amount) = updateMoneyPrize(PrizeType.PRIZE_THREE);
		} else if (randomValue <= winRate[PrizeType.PRIZE_FOUR]) {
			(typePrize, amount) = updateMoneyPrize(PrizeType.PRIZE_FOUR);
		}
		emit SpinTicketResult(typePrize, msg.sender, amount);
	}
}