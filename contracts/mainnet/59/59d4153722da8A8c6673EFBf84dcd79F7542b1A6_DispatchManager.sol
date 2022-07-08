// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./utils/CheckerManaged.sol";
import "./interfaces/ITransferManager.sol";
import "./interfaces/ILiquidityManager.sol";


contract DispatchManager is CheckerManaged, ReentrancyGuard {
	ITransferManager public transferManager;

	address public token;

	address public rewards;
	address public treasury;
	address public liquidityManager;
	address public team;

	uint public rewardsRate;
	uint public treasuryRate;
	uint public liquidityManagerRateStable;
	uint public liquidityManagerRateToken;

	uint private constant REF = 10000;

	uint public minAmountSwap;

	function init(
		address _owner,
		address _transferManager,
		address _token,
		address[] calldata _addrs,
		uint[] calldata _rates
	) external {
		initCheckerManaged(_owner);

		transferManager = ITransferManager(_transferManager);

		token = _token;
		IERC20(token).approve(_transferManager, type(uint).max);
		
		require(_addrs.length == 4);
		rewards = _addrs[0];
		treasury = _addrs[1];
		liquidityManager = _addrs[2];
		team = _addrs[3];

		require(_rates.length == 4);
		rewardsRate = _rates[0];
		treasuryRate = _rates[1];
		liquidityManagerRateStable = _rates[2];
		liquidityManagerRateToken = _rates[3];
		
		minAmountSwap = 4 * 10**18;
	}

	function approve() external onlyOwner {
		IERC20(token).approve(address(transferManager), type(uint).max);
	}
	
	function setTransferManager(ITransferManager _transferManager) external onlyOwner {
		transferManager = _transferManager;
	}
	
	function setToken(address _token) external onlyOwner {
		token = _token;
	}

	function setRewards(address _rewards) external onlyOwner {
		rewards = _rewards;
	}
	
	function setTreasury(address _treasury) external onlyOwner {
		treasury = _treasury;
	}
	
	function setLiquidityManager(address _liquidityManager) external onlyOwner {
		liquidityManager = _liquidityManager;
	}
	
	function setTeam(address _team) external onlyOwner {
		team = _team;
	}
	
	function setRewardsRate(uint _rewardsRate) external onlyOwner {
		rewardsRate = _rewardsRate;
	}
	
	function setTreasuryRate(uint _treasuryRate) external onlyOwner {
		treasuryRate = _treasuryRate;
	}
	
	function setLiquidityManagerRateStable(uint _liquidityManagerRateStable) external onlyOwner {
		liquidityManagerRateStable = _liquidityManagerRateStable;
	}
	
	function setLiquidityManagerRateToken(uint _liquidityManagerRateToken) external onlyOwner {
		liquidityManagerRateToken = _liquidityManagerRateToken;
	}
	
	function setMinAmountSwap(uint _minAmountSwap) external onlyOwner {
		minAmountSwap = _minAmountSwap;
	}

	function claim(
		address to, 
		uint amount
	) 
		external
		canManage(msg.sender)
		nonReentrant
	{
		if (amount > 0) {
			transferManager.safeTransferFrom(
				token,
				rewards,
				to,
				amount
			);
		}
	}

	function create(
		address from,
		uint amount
	) 
		external
		canManage(msg.sender)
		nonReentrant
	{
		transferManager.safeTransferFrom(
			token,
			from,
			address(this),
			amount
		);

		uint balance = IERC20(token).balanceOf(address(this));
		if (balance < minAmountSwap)
			return;

		uint rewardsAmount = balance * rewardsRate / REF;
		if (rewardsAmount > 0) {
			transferManager.safeTransferFrom(
				token,
				address(this),
				rewards,
				rewardsAmount
			);
		}

		uint treasuryAmount = balance * treasuryRate / REF;
		if (treasuryAmount > 0) {
			ILiquidityManager(liquidityManager).swapTokenForStableFromDispatch(
				treasury, 
				treasuryAmount
			);
		}
		
		uint liquidityManagerStableAmount = balance * liquidityManagerRateStable / REF;
		if (liquidityManagerStableAmount > 0) {
			ILiquidityManager(liquidityManager).swapTokenForStableFromDispatch(
				liquidityManager, 
				liquidityManagerStableAmount
			);
		}

		uint liquidityManagerTokenAmount = balance * liquidityManagerRateToken / REF;
		if (liquidityManagerTokenAmount > 0) {
			transferManager.safeTransferFrom(
				token,
				address(this),
				liquidityManager,
				liquidityManagerTokenAmount
			);
		}

		uint teamAmount = balance - 
			rewardsAmount - 
			treasuryAmount - 
			liquidityManagerStableAmount -
			liquidityManagerTokenAmount;
		if (teamAmount > 0) {
			ILiquidityManager(liquidityManager).swapTokenForStableFromDispatch(
				team, 
				teamAmount
			);
		}
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
     * by making the `nonReentrant` function external, and making it call a
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "./Proxied.sol";

contract CheckerManaged is Proxied {
	// STORAGE
	mapping(address => bool) public isManager;
	bool public onlyHuman;

	function initCheckerManaged(address _owner) internal {
		initProxied(_owner);
		onlyHuman = true;
	}

	// MODIFIERS
	modifier canManage(address addr) {
		require(isManager[addr] || addr == owner, "Not manager");
		_;
	}

	modifier isNotContract(address addr) {
		if (onlyHuman && Address.isContract(addr))
			require(isManager[addr], "Contract");
		_;
	}

	// SETTERS
	function setIsManager(address addr, bool value) external onlyOwner {
		isManager[addr] = value;
	}
	
	function setOnlyHuman(bool _onlyHuman) external onlyOwner {
		onlyHuman = _onlyHuman;
	}

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface ITransferManager {
	function safeTransferFrom(
		address token,
		address from,
		address to,
		uint value
	) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface ILiquidityManager {
	function swapTokenForStableFromDispatch(address to, uint amountIn) external;
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract Proxied {
	address public owner;

	modifier onlyOwner() {
		require(msg.sender == owner, "OnlyOwner");
		_;
	}

	function initProxied(address _owner) internal {
		require(owner == address(0), "proxy init");
		owner = _owner;
	}

	function setOwner(address _owner) external onlyOwner {
		require(_owner != address(0), "owner != address(0)");
		owner = _owner;
	}
}