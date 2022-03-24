// SPDX-License-Identifier: MIT

/// @title The KeysToken

pragma solidity ^0.8.12;

import { Operable } from "./extensions/Operable.sol";
import { Pausable } from "@openzeppelin/contracts/security/Pausable.sol";
import { IKeysDescriptor } from "./interfaces/IKeysDescriptor.sol";
import { IKeysToken } from "./interfaces/IKeysToken.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFKeyMinter is Operable, Pausable {
	IKeysDescriptor public immutable descriptor;
	IKeysToken public immutable keysToken;
	uint256 constant MAX_INT = 2**256 - 1;
	uint256 private seed;
	uint256 public maxPerWallet;

	uint256 public maxPerTime;
	uint256 public timeInerval;
	uint256 public inervalStartTime;
	uint256 public minted;

	bool allAccessAllowed;

	constructor(IKeysToken _keysToken, IKeysDescriptor _descriptor) {
		keysToken = _keysToken;
		descriptor = _descriptor;
		setOperator(_msgSender(), true);
		setMaxPerWallet(1);
		setAllAccessAllowed(false);
	}

	function contractData()
		public
		view
		returns (
			IKeysToken _keysToken,
			IKeysDescriptor _descriptor,
			uint256 _maxPerWallet,
			uint256 _maxPerTime,
			uint256 _timeInerval,
			uint256 _inervalStartTime,
			uint256 _minted
		)
	{
		_keysToken = keysToken;
		_descriptor = descriptor;
		_maxPerWallet = maxPerWallet;
		_maxPerTime = maxPerTime;
		_timeInerval = timeInerval;
		_inervalStartTime = inervalStartTime;
		_minted = minted;
	}

	function setMaxPerWallet(uint256 newMaxPerWallet) public onlyOperator {
		maxPerWallet = newMaxPerWallet;
		emit MaxPerWalletSet(maxPerWallet);
	}

	function setAllAccessAllowed(bool state) public onlyOperator {
		allAccessAllowed = state;
		emit AllAccessAllowedSet(allAccessAllowed);
	}

	function setMaxPerTimeInterval(uint256 newMaxPerTime, uint256 newTimeInerval) public onlyOperator {
		maxPerTime = newMaxPerTime;
		timeInerval = newTimeInerval;
		minted = 0;
		if (maxPerTime != 0 && timeInerval != 0) {
			inervalStartTime = (block.timestamp / timeInerval) * timeInerval;
		}

		emit MaxPerTimeIntervalSet(maxPerTime, timeInerval);
	}

	function mint() public whenNotPaused returns (uint256 tokenId) {
		require(_msgSender().code.length == 0, "Only humans");
		if (maxPerWallet != 0) {
			require(keysToken.balanceOf(_msgSender()) <= maxPerWallet, "Too much for one");
		}

		if (maxPerTime != 0 && timeInerval != 0) {
			minted++;

			if (inervalStartTime + timeInerval < block.timestamp) {
				require(minted <= maxPerTime, "Too much for this period");
			} else {
				minted = 1;
				inervalStartTime = (block.timestamp / timeInerval) * timeInerval;
			}
		}

		// prettier-ignore
		uint256 random = uint256(
    		keccak256(abi.encodePacked( 
    		  block.timestamp +
    		  block.gaslimit +    		  
    		  block.number +
    		  seed
    	  ))
    	);
		
    seed ++;

    uint48 backgroundId = uint48(uint48(random) % descriptor.backgroundsCount());	
    uint48 headId = uint48(uint48(random >> 48) % descriptor.layersCount(0));
    uint48 bodyId = uint48(uint48(random >> 96) % descriptor.layersCount(1));    
    uint48 labelId = uint48(uint48(random >> 144) % descriptor.layersCount(2));
    uint48 accessId = uint48(uint48(random >> 192) % descriptor.layersCount(3));

		if (accessId == 0 && !allAccessAllowed) accessId = 1;
		
		tokenId = keysToken.mint(_msgSender(), backgroundId, headId, bodyId, labelId, accessId);
	}

	// Added to support recovering
	function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOperator {
		IERC20(tokenAddress).transfer(_msgSender(), tokenAmount);
	}

	event MaxPerWalletSet(uint256 amount);
	event MaxPerTimeIntervalSet(uint256 maxPerTime, uint256 timeInerval);
	event AllAccessAllowedSet(bool state);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';

abstract contract Operable is Ownable {
	mapping(address => bool) public operators;
	address[] public operatorsList;

	constructor() {
		setOperator(_msgSender(), true);
	}

	function setOperator(address operator, bool state) public onlyOwner {
		operators[operator] = state;
		if (state) {
			operatorsList.push(operator);
		}
		emit OperatorSet(operator, state);
	}

	function operatorsCount() public view returns (uint256) {
		return operatorsList.length;
	}

	modifier onlyOperator() {
		require(operators[_msgSender()] || _msgSender() == owner(), "Sender is not the operator or owner");
		_;
	}
	event OperatorSet(address operator, bool state);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT

/// @title The Keys ERC-721 token

pragma solidity ^0.8.12;

interface IKeysDescriptor {
	struct Key {
		uint48 background;
		uint48 head;
		uint48 body;
		uint48 label;
		uint48 access;
	}

  struct Layer {
		bytes image;
		string name;
    uint256 pair;
    bool label;
  }

	function tokenURI(uint256 tokenId, Key memory key) external view returns (string memory);

	function dataURI(uint256 tokenId, Key memory key) external view returns (string memory);

	function backgroundsCount() external view returns (uint256);

	function layersCount(uint256 layerIdx) external view returns (uint256);	

	function getKeyAccess(Key memory key) external view returns (uint48, string memory);
}

// SPDX-License-Identifier: MIT

/// @title The Keys ERC-721 token

pragma solidity ^0.8.12;

interface IKeysToken {
	function mint(
		address to,
		uint48 background,
		uint48 head,
		uint48 body,
		uint48 accessory,
		uint48 access
	) external returns (uint256);

	function balanceOf(address owner) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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