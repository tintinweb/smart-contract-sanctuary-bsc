// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "Ownable.sol";
import "IERC20.sol";

contract SubscriptionSimplifiedC is Ownable {
	IERC20 public token;

	uint256 public currentRound;
	uint256 public roundCost;

	mapping (address => uint256) private _balance;
	mapping (address => uint256) private _userLastUpdated;

	mapping (uint256 => address) private _stakers;
	mapping (address => bool) private _isStaker;
	uint256 private _numStakers;

	event Stake(address user, uint256 amount);
	event Unstake(address user, uint256 amount);

	constructor(address paymentToken, uint256 costPerRound) {
		token = IERC20(paymentToken);
		roundCost = costPerRound;
	}

	function _userUpdate(address user, uint256 toRound) internal {
		uint256 feesAccumulated = roundCost * (toRound - _userLastUpdated[user]);
		if (feesAccumulated > _balance[user])
			_balance[user] = _balance[user] % roundCost;
		else
			_balance[user] -= feesAccumulated;
		_userLastUpdated[user] = toRound;
	}

	function balanceOf(address user) public view returns (uint256) {
		uint256 feesAccumulated = roundCost * (currentRound - _userLastUpdated[user]);
		if (feesAccumulated > _balance[user])
			return _balance[user] % roundCost;
		else
			return _balance[user] - feesAccumulated;
	}

	// rewardList() will fail if there is too much calculation required. In
	// that case, break the list into pieces (0-100, 100-200, etc.), ending at
	// rewardListMaxLength(), sending those to getRewardListSection(). If
	// that function also fails, then start and end values for those pieces
	// likely need to be made closer together.
	// The list of addressed returned by both functions may contain trailing
	// zero addresses.

	function rewardListMaxLength() public view returns (uint256) {
		return _numStakers;
	}

	function rewardList() public view returns (address[] memory) {
		return rewardListSection(0, _numStakers);
	}

	function rewardListSection(uint256 start, uint256 end) public view returns (address[] memory) {
		address[] memory arr = new address[](end - start);
		uint256 arrayIndex = 0;
		for (uint256 stakerIndex = start; stakerIndex < end; stakerIndex++) {
			address user = _stakers[stakerIndex];
			if (balanceOf(user) >= roundCost) {
				arr[arrayIndex] = user;
				arrayIndex++;
			}
		}
		return arr;
	}

	// chargeFee() should be called immediately after rewardList()
	function chargeFee() public onlyOwner {
		currentRound++;
	}

	function stake(uint256 amount) public {
		address user = _msgSender();
		if (_isStaker[user])
			_userUpdate(user, currentRound);
		else
		{
			_stakers[_numStakers] = user;
			_numStakers++;
			_isStaker[user] = true;
			_userLastUpdated[user] = currentRound;
		}
		token.transferFrom(user, address(this), amount);
		_balance[user] += amount;
		emit Stake(user, amount);
	}

	function unstake(uint256 amount) public {
		address user = _msgSender();
		_userUpdate(user, currentRound);
		require(amount <= _balance[user]);
		token.transfer(user, amount);
		_balance[user] -= amount;
		emit Unstake(user, amount);
	}

	// This function exists, but gas can likely be saved by calling balanceOf
	// manually and then calling unstake with the result.
	function unstakeAll() public {
		unstake(balanceOf(_msgSender()));
	}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "Context.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

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