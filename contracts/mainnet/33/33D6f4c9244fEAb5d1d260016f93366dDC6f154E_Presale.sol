// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IPillManager.sol";
import "./interfaces/IBoostManager.sol";


contract Presale is Ownable {
	using SafeERC20 for IERC20;

	uint public constant OFFER_NB = 3;

	struct Datas {
		uint[OFFER_NB] pricesWhitelist;
		uint[OFFER_NB] pricesPublic;
		uint[OFFER_NB] iBoost;
		uint[OFFER_NB] amountForBoost;
	}

	struct Purchase {
		uint[OFFER_NB] types;
		uint[OFFER_NB] boosts;
	}

	IPillManager public immutable pillManager;
	IBoostManager public immutable boostManager;
	IERC20 public immutable stable;
	address public immutable treasury;

	bool public openPurchaseWhitelist;
	bool public openPurchasePublic;
	bool public openCreate;

	Datas private datas;

	mapping(address => Purchase) private purchases;
	mapping(address => bool) public isWhitelisted;

	constructor(
		address _pillManager,
		address _boostManager,
		address _stable,
		address _treasury,
		uint[] memory _pricesWhitelist,
		uint[] memory _pricesPublic,
		uint[] memory _iBoost,
		uint[] memory _amountForBoost
	) 
	{
		pillManager = IPillManager(_pillManager);
		boostManager = IBoostManager(_boostManager);
		stable = IERC20(_stable);
		treasury = _treasury;

		require(
			OFFER_NB == _pricesWhitelist.length &&
			OFFER_NB == _pricesPublic.length &&
			OFFER_NB == _iBoost.length &&
			OFFER_NB == _amountForBoost.length, 
			"length"
		);
		for (uint i; i < OFFER_NB; i++) {
			datas.pricesWhitelist[i] = _pricesWhitelist[i];
			datas.pricesPublic[i] = _pricesPublic[i];
			datas.iBoost[i] = _iBoost[i];
			datas.amountForBoost[i] = _amountForBoost[i];
		}
	}
	
	// HELPERS
	function _ensureIndex(uint i) private pure {
		require(i < OFFER_NB, "Index too high");
	}	

	function _ensureSender(address user) private view {
		require(user == msg.sender || msg.sender == owner(), "Not you");
	}	

	// PURCHASE
	function purchase(uint i, uint amount) external {
		require(!openCreate, "Presale is over");
		require(amount > 0, "nothing to purchase");
		_ensureIndex(i);
		if (openPurchaseWhitelist)
			_purchaseWhitelist(i, amount);
		else if (openPurchasePublic) 
			_purchasePublic(i, amount);
		else 
			revert("Presale not started");
	}

	function _purchaseWhitelist(uint i, uint amount) private {
		require(isWhitelisted[msg.sender], "Not whitelisted");
		uint price = datas.pricesWhitelist[i] * amount;
		stable.safeTransferFrom(msg.sender, treasury, price);
		_setPurchase(i, amount);
	}

	function _purchasePublic(uint i, uint amount) private {
		uint price = datas.pricesPublic[i] * amount;
		stable.safeTransferFrom(msg.sender, treasury, price);
		_setPurchase(i, amount);
	}

	function _setPurchase(uint i, uint amount) private {
		Purchase storage _purchase = purchases[msg.sender];
		_purchase.types[i] += amount;
		_purchase.boosts[i] += amount;
	}

	// CREATE
	function create(address user, uint i, uint amount) external {
		require(openCreate, "Presale not over");
		_ensureIndex(i);
		_ensureSender(user);
		Purchase storage _purchase = purchases[user];
		require(_purchase.types[i] >= amount && amount > 0, "Nope");
		_purchase.types[i] -= amount;
		pillManager.createManagedAirDrop(i, user, amount);
	}

	// BOOST
	function boost(address user, uint j, uint[] calldata tokenIds) external {
		require(openCreate, "Presale not over");
		_ensureIndex(j);
		_ensureSender(user);
		Purchase storage _purchase = purchases[user];
		uint amountForBoost = datas.amountForBoost[j];
		uint boostNb = _purchase.boosts[j] / amountForBoost;
		require(tokenIds.length <= boostNb && tokenIds.length > 0, "Nope");
		_purchase.boosts[j] -= tokenIds.length * amountForBoost;
		boostManager.boostAirDropWithClaim(msg.sender, datas.iBoost[j], j, tokenIds);
	}

	// GETTERS
	function viewPurchase(
		address user
	) 
		external 
		view 
		returns (
			uint[OFFER_NB] memory,
			uint[OFFER_NB] memory
		)
	{
		Purchase storage _purchase = purchases[user];
		return (
			_purchase.types, 
			_purchase.boosts
		);
	}
	
	function viewDatas(
	) 
		external 
		view 
		returns (
			uint[OFFER_NB] memory,
			uint[OFFER_NB] memory,
			uint[OFFER_NB] memory,
			uint[OFFER_NB] memory
		)
	{
		return (
			datas.pricesWhitelist,
			datas.pricesPublic,
			datas.iBoost,
			datas.amountForBoost
		);
	}

	// SETTERS
	function setOpenPurchaseWhitelist(bool _openPurchaseWhitelist) external onlyOwner {
		openPurchaseWhitelist = _openPurchaseWhitelist;
		openPurchasePublic = false;
		openCreate = false;
	}
	
	function setOpenPurchasePublic(bool _openPurchasePublic) external onlyOwner {
		openPurchaseWhitelist = false;
		openPurchasePublic = _openPurchasePublic;
		openCreate = false;
	}
	
	function setOpenCreate(bool _openCreate) external onlyOwner {
		openPurchaseWhitelist = false;
		openPurchasePublic = false;
		openCreate = _openCreate;
	}

	function setPriceWhitelist(uint i, uint priceWhitelist) external onlyOwner {
		assert(i < OFFER_NB);
		datas.pricesWhitelist[i] = priceWhitelist;
	}
	
	function setPricePublic(uint i, uint pricePublic) external onlyOwner {
		assert(i < OFFER_NB);
		datas.pricesPublic[i] = pricePublic;
	}
	
	function setIBoost(uint i, uint iBoost) external onlyOwner {
		datas.iBoost[i] = iBoost;
	}
	
	function setAmountForBoost(uint i, uint amountForBoost) external onlyOwner {
		datas.amountForBoost[i] = amountForBoost;
	}

	function setIsWhitelisted(address[] calldata addrs, bool value) external onlyOwner {
		for (uint i; i < addrs.length; i++)
			isWhitelisted[addrs[i]] = value;
	}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IPillManager {
	function ownerOf(uint i, uint tokenId) external view returns (address);

	function createManagedAirDrop(
		uint i,
		address to,
		uint amount
	) external;

	function createWithPending(
		address from,
		uint[] calldata iData,
		uint[][] calldata tokenIds
	) external returns (uint);
	
	function claimReset(
		address from,
		uint i,
		uint[] calldata tokenIds
	) external returns (uint);

	function setManagedData(
		address from,
		uint i,
		uint[] calldata tokenIds,
		uint iManagedData,
		uint value
	) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IBoostManager {
	function boostAirDropWithClaim(
		address from,
		uint i,
		uint j,
		uint[] calldata tokenIds
	) external;
}

// SPDX-License-Identifier: MIT
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

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