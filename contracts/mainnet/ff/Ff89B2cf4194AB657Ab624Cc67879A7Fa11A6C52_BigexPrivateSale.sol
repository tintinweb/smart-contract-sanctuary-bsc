// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BigexAirdrop is Ownable, Pausable {
	using SafeMath for uint256;

	struct LockAirdropRef {
		uint256 amount;
		uint256 timestamp;
	}

	uint256 public amountAirdrop;
	uint256 public amountRefAirdrop;
	uint256 public unlockPercent;
	uint256 public timePeriod = 2592000; // 30 days
	uint256 public startTimeRelease;
	uint256 public totalUser;

	mapping(address => uint256) public userAirdropAmount;
	mapping(address => LockAirdropRef[]) public refAirdropAmount;
	mapping(address => address) public referrers;
	mapping(address => uint256) public users;
	mapping(address => uint256) public userRefCount;

	address public TOKEN;

	bool isStop = false;

	event NewReferral(address indexed user, address indexed ref, uint8 indexed level);
	event UpdateRefUser(address indexed account, address indexed newRefaccount);
	event Airdrop(address indexed user, address indexed ref, uint256 amount);

	constructor() {
		amountAirdrop = 3000000000000000000000;
		amountRefAirdrop = 600000000000000000000;
		TOKEN = 0x2F6c6cE689C0231919713c5556213cF3895Fed3B;
		unlockPercent = 5;
		startTimeRelease = block.timestamp + (2592000 * 3);
	}

	function updateAmountAirdrop(uint256 _amount) public onlyOwner {
		amountAirdrop = _amount;
	}

	function updateAmountRefAirdrop(uint256 _amount) public onlyOwner {
		amountRefAirdrop = _amount;
	}

	function updateIsStop(bool _result) public onlyOwner {
		isStop = _result;
	}

	function updateStartTimeRelease(uint256 _newTime) public onlyOwner {
		startTimeRelease = _newTime;
	}

	function updateTimePeriod(uint256 _newTime) public onlyOwner {
		timePeriod = _newTime;
	}

	function updateTokenContract(address _token) public onlyOwner {
		TOKEN = _token;
	}

	function updateUnlockPercent(uint256 _unlockPercent) public onlyOwner {
		unlockPercent = _unlockPercent;
	}

	function claim(address _ref) public whenNotPaused {
		require(_ref != msg.sender, "can't introduce myself");
		require(!isStop, "airdrop is stop");
		require(userAirdropAmount[msg.sender] == 0, "wallet can not claim again");
		userAirdropAmount[msg.sender] = amountAirdrop;
		IERC20(TOKEN).transfer(msg.sender, amountAirdrop);

		if (isRegister(msg.sender) == false) {
			register(_ref);
		}

		if (_ref != address(0)) {
			refAirdropAmount[_ref].push(
				LockAirdropRef(
					amountRefAirdrop,
					block.timestamp
				)
			);
			IERC20(TOKEN).transfer(_ref, amountRefAirdrop);
			userRefCount[_ref]++;
		}
	}

	function sendAirdrop(address[] calldata _list) public whenNotPaused onlyOwner {
		require(!isStop, "airdrop is stop");
		for (uint256 i = 0; i < _list.length; i++) {
			require(userAirdropAmount[_list[i]] == 0, "wallet can not claim again");
		}
		for (uint256 i = 0; i < _list.length; i++) {
			userAirdropAmount[_list[i]] = amountAirdrop;
			IERC20(TOKEN).transfer(_list[i], amountAirdrop);
		}
	}

	function register(address _referrer) public {
		if (referrers[msg.sender] == address(0)
		&& _referrer != address(0)
		&& msg.sender != _referrer
			&& msg.sender != referrers[_referrer]) {
			referrers[msg.sender] = _referrer;
			emit NewReferral(_referrer, msg.sender, 1);
			if (referrers[_referrer] != address(0)) {
				emit NewReferral(referrers[_referrer], msg.sender, 2);
			}
		}
		users[msg.sender] = block.timestamp;
		totalUser = totalUser.add(1);
	}

	function updateUserStatus(address account, uint256 _status) public onlyOwner whenNotPaused {
		users[account] = _status;
	}

	function updateRefUser(address account, address newRefAccount) public onlyOwner whenNotPaused {
		referrers[account] = newRefAccount;
		emit UpdateRefUser(account, newRefAccount);
	}

	function getRef(address account) public view returns (address){
		return referrers[account];
	}

	function getRefAirdropAmountByIndex(address _address, uint256 _index) public view returns (LockAirdropRef memory) {
		return refAirdropAmount[_address][_index];
	}

	function getRefAirdropAmountLength(address _address) public view returns (uint256) {
		return refAirdropAmount[_address].length;
	}

	function isRegister(address account) public view returns (bool){
		if (users[account] > 0) {
			return true;
		} else {
			return false;
		}
	}

	function getITransferAidrop(address _wallet) external view returns (uint256) {
		if (userAirdropAmount[_wallet] == 0 && refAirdropAmount[_wallet].length == 0) {
			return 0;
		}
		uint256 refAirdropLockAmount = 0;
		uint256 totalLock = 0;
		if (refAirdropAmount[_wallet].length > 0) {
			for (uint256 i = 0; i < refAirdropAmount[_wallet].length; i++) {
				LockAirdropRef memory lar = refAirdropAmount[_wallet][i];
				if (block.timestamp.sub(lar.timestamp).div(timePeriod) == 0) {
					refAirdropLockAmount += lar.amount;
				} else {
					refAirdropLockAmount += lar.amount.sub(
						lar.amount.mul(unlockPercent).div(100).mul(
							block.timestamp.sub(lar.timestamp).div(timePeriod)
						)
					);
				}
			}
			totalLock += refAirdropLockAmount;
		}
		if (
			block.timestamp > startTimeRelease &&
			block.timestamp.sub(startTimeRelease).div(timePeriod) > 0
		) {
			uint256 unlockClaimedAmount = 0;
			if (userAirdropAmount[_wallet] > 0) {
				unlockClaimedAmount = userAirdropAmount[_wallet].mul(unlockPercent).div(100).mul(
					block.timestamp.sub(startTimeRelease).div(timePeriod)
				);
			}
			if (userAirdropAmount[_wallet] > unlockClaimedAmount) {
				totalLock += userAirdropAmount[_wallet].sub(unlockClaimedAmount);
			}
		} else {
			totalLock += userAirdropAmount[_wallet];
		}
		return totalLock;
	}

	/**
	Clear unknown token
	*/
	function clearUnknownToken(address _tokenAddress) public onlyOwner {
		uint256 contractBalance = IERC20(_tokenAddress).balanceOf(address(this));
		IERC20(_tokenAddress).transfer(address(msg.sender), contractBalance);
	}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract USDT is ERC20, Ownable {
	constructor() ERC20("USDT", "USDT") {
		mint(msg.sender, 10000000000 * 10 ** 18);
	}

	function mint(address to, uint256 amount) public onlyOwner {
		_mint(to, amount);
	}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
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
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./supports/BigexSupportToken.sol";

contract BIGEXToken is ERC20, Ownable, BigexSupportToken {

	constructor() ERC20("BIGEX INVESTMENT", "BIGEX")
	{
		_mint(msg.sender, 99000000000 * 10 ** decimals());
	}

	function _beforeTokenTransfer(address from, address to, uint256 amount)
	internal
	override
	{
		if (enableWhiteListBot) {
			if (isContract(from) && !whiteListAddressBot[from]) {
				revert("BEP20: contract from is not whitelist");
			}
			if (isContract(to) && !whiteListAddressBot[to]) {
				revert("BEP20: contract to is not whitelist");
			}
		}
		require(amount > 0, "BEP20: require amount greater than 0");
		require(blackListWallet[from] == false, "BEP20: address from is blacklist");
		require(blackListWallet[to] == false, "BEP20: address to is blacklist");
		if (isEnable == true && from != address(0)) {
			uint256 amountIn = checkIBigexTransfer(from);
			if (balanceOf(from) < amountIn + amount) {
				revert("BIGEX: Some available balance has been unlock gradually");
			}
		}
		super._beforeTokenTransfer(from, to, amount);
	}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import {IBigexInterface} from "../interfaces/BigexInterfaceToken.sol";

abstract contract BigexSupportToken is Ownable {

	mapping(address => bool) public blackListWallet;
	mapping(address => bool) public whiteListAddressBot;

	bool public enableWhiteListBot = false;
	bool public isEnable = true;
	address public bigexInvestmentContract;
	address public bigexAirdropContract;

	event SetInvestmentContract(address newAddress, address oldAddress);
	event SetAirdropContract(address newAddress, address oldAddress);

	/**
	Set enable whitelist bot
	*/
	function setEnableWhiteListBot(bool _result) public onlyOwner() {
		enableWhiteListBot = _result;
	}

	/**
	Set enable check Investment , Airdrop contract
	*/
	function setEnable(bool _result) public onlyOwner() {
		isEnable = _result;
	}

	/**
	Set blacklist wallet can not transfer token
	*/
	function setBlackListWallet(address[] memory _address, bool result) public onlyOwner () {
		for (uint i = 0; i < _address.length; i++) {
			blackListWallet[_address[i]] = result;
		}
	}

	/**
	Set whitelist bot can transfer token
	*/
	function setWhiteListAddressBot(address[] memory _address, bool result) public onlyOwner () {
		for (uint i = 0; i < _address.length; i++) {
			whiteListAddressBot[_address[i]] = result;
		}
	}

	/**
	Clear unknown token
	*/
	function clearUnknownToken(address _tokenAddress) public onlyOwner {
		uint256 contractBalance = IERC20(_tokenAddress).balanceOf(address(this));
		IERC20(_tokenAddress).transfer(address(msg.sender), contractBalance);
	}

	/**
	Check address is contract
	*/
	function isContract(address account) internal view returns (bool) {
		return Address.isContract(account);
	}

	/**
	set is investment contract
	*/
	function setInvestmentContract(address _investmentContract) public onlyOwner {
		emit SetInvestmentContract(_investmentContract, bigexInvestmentContract);
		bigexInvestmentContract = _investmentContract;
	}

	/**
	set is airdrop contract
	*/
	function setAirdropContract(address _airdropContract) public onlyOwner {
		emit SetAirdropContract(_airdropContract, bigexAirdropContract);
		bigexAirdropContract = _airdropContract;
	}

	/**
    * @dev Withdraw Token to an address, revert if it fails.
    * @param recipient recipient of the transfer
    */
	function clearToken(address recipient, address token, uint256 amount) public onlyOwner {
		IERC20(token).transfer(recipient, amount);
	}

	function checkIBigexTransfer(address account) public view returns (uint256) {
		uint256 amount = 0;
		if (bigexInvestmentContract != address(0))
		{
			amount += IBigexInterface(bigexInvestmentContract).getITransferInvestment(account);
		}
		if (bigexAirdropContract != address(0))
		{
			amount += IBigexInterface(bigexAirdropContract).getITransferAidrop(account);
		}
		return amount;
	}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
                /// @solidity memory-safe-assembly
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
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IBigexInterface {
	function getITransferInvestment(address account) external view returns (uint256);
	function getITransferAidrop(address account) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import {IBigexInterface} from "./interfaces/BigexInterfaceToken.sol";
import {IBigexAirdrop} from "./interfaces/IBigexAirdrop.sol";

contract BigexSeedSale is Ownable, Pausable {
    using SafeMath for uint256;

    IERC20 public bigexToken;
    IERC20 public paymentToken;

    uint256 public timeTGE;
    uint256 public timeBeginUnlock;
    uint256 public timePeriod;
    uint256 public receivePercentage;
    uint256 public minBuy;
    uint256 public maxBuy;
    uint256 public minBuyBnb;
    uint256 public maxBuyBnb;
    uint256 public tokenPriceRate;
    uint256 public tokenPriceRateBnb;
    uint256 public rateBnbToUsd;
    uint256[] public refReward = [10, 5, 5];

    mapping(address => uint256[]) public userLockDetail;
    mapping(address => uint256) public userTotalPayment;
    mapping(address => uint256) public userTotalPaymentBnb;
    mapping(address => address) public referrers;

    address public otherInvestmentContract;
    address public airDropContract;

    bool public activeBuyBNB = true;
    bool public activeBuyToken = true;

    event BuyToken(address user, address paymentToken, uint256 amountToken, uint256 amountPayment, uint256 timestamp);
    event BuyTokenBnb(address user, uint256 amountToken, uint256 amountPayment, uint256 timestamp);

    constructor (
        address _addressBigexToken,
        address _paymentToken,
        uint256 _timePeriod,
        uint256 _receivePercentage,
        uint256 _minBuy,
        uint256 _maxBuy,
        uint256 _tokenPriceRate
    ){
        bigexToken = IERC20(_addressBigexToken);
        paymentToken = IERC20(_paymentToken);
        timePeriod = _timePeriod;
        timeTGE = block.timestamp;
        receivePercentage = _receivePercentage;
        minBuy = _minBuy;
        maxBuy = _maxBuy;
        tokenPriceRate = _tokenPriceRate;
    }

    receive() external payable {}

    function setAirDropContract(address _airDropContract) public onlyOwner {
        airDropContract = _airDropContract;
    }

    function setRefReward(uint256[] memory _refReward) public onlyOwner {
        refReward = _refReward;
    }

    function setRateBnbToUsd(uint256 _rate) public onlyOwner {
        rateBnbToUsd = _rate;
    }

    function setActiveBuyBNB(bool _result) public onlyOwner {
        activeBuyBNB = _result;
    }

    function setActiveBuyToken(bool _result) public onlyOwner {
        activeBuyToken = _result;
    }

    function setMinMaxBuy(uint256 _minBuy, uint256 _maxBuy) public onlyOwner {
        minBuy = _minBuy;
        maxBuy = _maxBuy;
    }

    function setMinMaxBuyBnb(uint256 _minBuy, uint256 _maxBuy) public onlyOwner {
        minBuyBnb = _minBuy;
        maxBuyBnb = _maxBuy;
    }

    function setTokenPriceRate(uint256 _tokenPriceRate) public onlyOwner {
        tokenPriceRate = _tokenPriceRate;
    }

    function setTokenPriceRateBnb(uint256 _tokenPriceRate) public onlyOwner {
        tokenPriceRateBnb = _tokenPriceRate;
    }

    function setPaymentToken(address _paymentToken) public onlyOwner {
        paymentToken = IERC20(_paymentToken);
    }

    function setBigexToken(address _bigexToken) public onlyOwner {
        bigexToken = IERC20(_bigexToken);
    }

    function setOtherInvestmentContract(address _otherInvestmentContract) public onlyOwner {
        otherInvestmentContract = _otherInvestmentContract;
    }

    function getITransferInvestment(address _wallet) external view returns (uint256){
        uint256 totalLock = 0;
        if (otherInvestmentContract != address(0)) {
            totalLock = totalLock.add(IBigexInterface(otherInvestmentContract).getITransferInvestment(_wallet));
        }
        for (uint256 i = 0; i < userLockDetail[_wallet].length; i++) {
            totalLock = totalLock.add(userLockDetail[_wallet][i]);
            if (timeBeginUnlock > 0 && block.timestamp > timeBeginUnlock) {
                uint256 unlockAmount = userLockDetail[_wallet][i].mul(receivePercentage).div(100).mul(
                    block.timestamp.sub(timeBeginUnlock).div(timePeriod)
                );
                if (unlockAmount > 0) {
                    if (unlockAmount >= userLockDetail[_wallet][i]) {
                        totalLock = totalLock.sub(userLockDetail[_wallet][i]);
                    } else {
                        totalLock = totalLock.sub(unlockAmount);
                    }
                }
            }
        }
        return totalLock;
    }

    function totalBuy(address _wallet) public view returns (uint256){
        return userTotalPayment[_wallet];
    }

    function totalBuyBnb(address _wallet) public view returns (uint256){
        return userTotalPaymentBnb[_wallet];
    }

    function usdToBNB(uint256 _paymentUsd) public view returns (uint256) {
        return _paymentUsd.mul(10e18).div(100).div(rateBnbToUsd).mul(10);
    }

    function bnbToUSD(uint256 _paymentBnb) public view returns (uint256) {
        uint256 usd = _paymentBnb.mul(rateBnbToUsd) / 10 ** 18;
        return usd;
    }

    function buyToken(uint256 _paymentAmount) public whenNotPaused {
        require(activeBuyToken, "SeedSale: function is not active");

        require(minBuy <= _paymentAmount && _paymentAmount <= maxBuy, "SeedSale: min max buy is not valid");
        require(totalBuy(msg.sender) + _paymentAmount <= maxBuy, "SeedSale: limit buy token");
        require(totalBuyBnb(msg.sender) + usdToBNB(_paymentAmount) <= maxBuyBnb, "SeedSale: limit buy token");

        // check allowance
        require(paymentToken.allowance(msg.sender, address(this)) >= _paymentAmount, "SeedSale: insufficient allowance");

        // check balance payment token before buy token
        require(paymentToken.balanceOf(msg.sender) >= _paymentAmount, "SeedSale: balance not enough");

        uint256 totalToken = _paymentAmount.div(tokenPriceRate).mul(10 ** 18);

        // check balance token contract
        require(bigexToken.balanceOf(address(this)) >= totalToken, "SeedSale: contract not enough balance");

        address _ref = IBigexAirdrop(airDropContract).getRef(msg.sender);
        uint256 remains = _paymentAmount;

        if (_ref != address(0)) {
            // transfer reward f0
            paymentToken.transferFrom(msg.sender, _ref, _paymentAmount.mul(refReward[0]).div(100));
            remains = remains.sub(_paymentAmount.mul(refReward[0]).div(100));
            address ref = IBigexAirdrop(airDropContract).getRef(_ref);
            for (uint256 i = 1; i < refReward.length; i++) {
                if (ref != address(0)) {
                    // transfer reward to Fn
                    paymentToken.transferFrom(msg.sender, ref, _paymentAmount.mul(refReward[i]).div(100));
                    remains = remains.sub(_paymentAmount.mul(refReward[i]).div(100));
                    ref = IBigexAirdrop(airDropContract).getRef(ref);
                }
            }
        }

        // get token from user to contract
        paymentToken.transferFrom(msg.sender, address(this), remains);

        // transfer token to wallet
        bigexToken.transfer(msg.sender, totalToken);

        // update lock detail
        userLockDetail[msg.sender].push(totalToken);

        // update total payment amount
        userTotalPayment[msg.sender] = userTotalPayment[msg.sender].add(_paymentAmount);
        userTotalPaymentBnb[msg.sender] = userTotalPaymentBnb[msg.sender].add(usdToBNB(_paymentAmount));

        emit BuyToken(msg.sender, address(paymentToken), totalToken, _paymentAmount, block.timestamp);
    }

    function buyTokenBNB() public payable whenNotPaused {
        require(activeBuyBNB, "SeedSale: function is not active");

        uint256 _paymentBnb = msg.value;
        uint256 remains = _paymentBnb;
        uint256 _paymentAmount = bnbToUSD(_paymentBnb);

        require(minBuyBnb <= _paymentBnb && _paymentBnb <= maxBuyBnb, "SeedSale: min max buy is not valid");
        require(totalBuy(msg.sender) + _paymentAmount <= maxBuy, "SeedSale: limit buy token");
        require(totalBuyBnb(msg.sender) + _paymentBnb <= maxBuyBnb, "SeedSale: limit buy token");

        // check balance payment token before buy token
        require(address(msg.sender).balance >= _paymentBnb, "SeedSale: balance not enough");

        uint256 totalToken = _paymentBnb.div(tokenPriceRateBnb) * 10 ** 18;

        // check balance token contract
        require(bigexToken.balanceOf(address(this)) >= totalToken, "SeedSale: contract not enough balance");

        address _ref = IBigexAirdrop(airDropContract).getRef(msg.sender);

        if (_ref != address(0)) {
            // transfer reward f0
            payable(_ref).transfer(_paymentBnb.mul(refReward[0]).div(100));
            remains = remains.sub(_paymentBnb.mul(refReward[0]).div(100));
            address ref = IBigexAirdrop(airDropContract).getRef(_ref);
            for (uint256 i = 1; i < refReward.length; i++) {
                if (ref != address(0)) {
                    // transfer reward to Fn
                    payable(ref).transfer(_paymentBnb.mul(refReward[i]).div(100));
                    remains = remains.sub(_paymentBnb.mul(refReward[i]).div(100));
                    ref = IBigexAirdrop(airDropContract).getRef(ref);
                }
            }
        }
        payable(address(this)).transfer(remains);

        // transfer token to wallet
        bigexToken.transfer(msg.sender, totalToken);

        // update lock detail
        userLockDetail[msg.sender].push(totalToken);

        // update total payment amount
        userTotalPaymentBnb[msg.sender] = userTotalPaymentBnb[msg.sender].add(_paymentBnb);
        userTotalPayment[msg.sender] = userTotalPayment[msg.sender].add(_paymentAmount);

        emit BuyTokenBnb(msg.sender, totalToken, _paymentAmount, block.timestamp);
    }

    function updateNewTimeTGEAndTimePeriod(uint256 _newTimeTGE, uint256 _newTimePeriod, uint256 _timeBeginUnlock) public onlyOwner {
        require(_timeBeginUnlock > block.timestamp && _newTimeTGE > block.timestamp, "SeedSale: request time greater than current time");
        timeTGE = _newTimeTGE;
        timePeriod = _newTimePeriod;
        timeBeginUnlock = _timeBeginUnlock;
    }

    /**
    Clear unknow token
    */
    function clearUnknownToken(address _tokenAddress) public onlyOwner {
        uint256 contractBalance = IERC20(_tokenAddress).balanceOf(address(this));
        IERC20(_tokenAddress).transfer(address(msg.sender), contractBalance);
    }

    /**
    Withdraw bnb
    */
    function withdraw(address _to) public onlyOwner {
        require(_to != address(0), "SeedSale: wrong address withdraw");
        uint256 amount = address(this).balance;
        payable(_to).transfer(amount);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IBigexAirdrop {
    function getRef(address account) external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import {IBigexInterface} from "./interfaces/BigexInterfaceToken.sol";
import {IBigexAirdrop} from "./interfaces/IBigexAirdrop.sol";

contract BigexPrivateSale is Ownable, Pausable {
	using SafeMath for uint256;

	IERC20 public bigexToken;
	IERC20 public paymentToken;

	uint256 public timeTGE;
	uint256 public timeBeginUnlock;
	uint256 public timePeriod;
	uint256 public receivePercentage;
	uint256 public minBuy;
	uint256 public maxBuy;
	uint256 public minBuyBnb;
	uint256 public maxBuyBnb;
	uint256 public tokenPriceRate;
	uint256 public tokenPriceRateBnb;
	uint256 public rateBnbToUsd;
	uint256[] public refReward = [10, 5, 5];

	mapping(address => uint256[]) public userLockDetail;
	mapping(address => uint256) public userTotalPayment;
	mapping(address => uint256) public userTotalPaymentBnb;

	address public otherInvestmentContract;
	address public airDropContract;

	bool public activeBuyBNB = true;
	bool public activeBuyToken = true;

	event BuyToken(address user, address paymentToken, uint256 amountToken, uint256 amountPayment, uint256 timestamp);
	event BuyTokenBnb(address user, uint256 amountToken, uint256 amountPayment, uint256 timestamp);

	constructor (
		address _addressBigexToken,
		address _paymentToken,
		uint256 _timePeriod,
		uint256 _receivePercentage,
		uint256 _minBuy,
		uint256 _maxBuy,
		uint256 _tokenPriceRate
	){
		bigexToken = IERC20(_addressBigexToken);
		paymentToken = IERC20(_paymentToken);
		timePeriod = _timePeriod;
		timeTGE = block.timestamp;
		receivePercentage = _receivePercentage;
		minBuy = _minBuy;
		maxBuy = _maxBuy;
		tokenPriceRate = _tokenPriceRate;
	}

	receive() external payable {}

	function setAirDropContract(address _airDropContract) public onlyOwner {
		airDropContract = _airDropContract;
	}

	function setRefReward(uint256[] memory _refReward) public onlyOwner {
		refReward = _refReward;
	}

	function setRateBnbToUsd(uint256 _rate) public onlyOwner {
		rateBnbToUsd = _rate;
	}

	function setActiveBuyBNB(bool _result) public onlyOwner {
		activeBuyBNB = _result;
	}

	function setActiveBuyToken(bool _result) public onlyOwner {
		activeBuyToken = _result;
	}

	function setMinMaxBuy(uint256 _minBuy, uint256 _maxBuy) public onlyOwner {
		minBuy = _minBuy;
		maxBuy = _maxBuy;
	}

	function setMinMaxBuyBnb(uint256 _minBuy, uint256 _maxBuy) public onlyOwner {
		minBuyBnb = _minBuy;
		maxBuyBnb = _maxBuy;
	}

	function setTokenPriceRate(uint256 _tokenPriceRate) public onlyOwner {
		tokenPriceRate = _tokenPriceRate;
	}

	function setTokenPriceRateBnb(uint256 _tokenPriceRate) public onlyOwner {
		tokenPriceRateBnb = _tokenPriceRate;
	}

	function setPaymentToken(address _paymentToken) public onlyOwner {
		paymentToken = IERC20(_paymentToken);
	}

	function setBigexToken(address _bigexToken) public onlyOwner {
		bigexToken = IERC20(_bigexToken);
	}

	function setOtherInvestmentContract(address _otherInvestmentContract) public onlyOwner {
		otherInvestmentContract = _otherInvestmentContract;
	}

	function getITransferInvestment(address _wallet) external view returns (uint256){
		uint256 totalLock = 0;
		if (otherInvestmentContract != address(0)) {
			totalLock = totalLock.add(IBigexInterface(otherInvestmentContract).getITransferInvestment(_wallet));
		}
		for (uint256 i = 0; i < userLockDetail[_wallet].length; i++) {
			totalLock = totalLock.add(userLockDetail[_wallet][i]);
			if (timeBeginUnlock > 0 && block.timestamp > timeBeginUnlock) {
				uint256 unlockAmount = userLockDetail[_wallet][i].mul(receivePercentage).div(100).mul(
					block.timestamp.sub(timeBeginUnlock).div(timePeriod)
				);
				if (unlockAmount > 0) {
					if (unlockAmount >= userLockDetail[_wallet][i]) {
						totalLock = totalLock.sub(userLockDetail[_wallet][i]);
					} else {
						totalLock = totalLock.sub(unlockAmount);
					}
				}
			}
		}
		return totalLock;
	}

	function totalBuy(address _wallet) public view returns (uint256){
		return userTotalPayment[_wallet];
	}

	function totalBuyBnb(address _wallet) public view returns (uint256){
		return userTotalPaymentBnb[_wallet];
	}

	function usdToBNB(uint256 _paymentUsd) public view returns (uint256) {
		return _paymentUsd.mul(10e18).div(100).div(rateBnbToUsd).mul(10);
	}

	function bnbToUSD(uint256 _paymentBnb) public view returns (uint256) {
		uint256 usd = _paymentBnb.mul(rateBnbToUsd) / 10 ** 18;
		return usd;
	}

	function buyToken(uint256 _paymentAmount) public whenNotPaused {
		require(activeBuyToken, "PrivateSale: function is not active");

		require(minBuy <= _paymentAmount && _paymentAmount <= maxBuy, "PrivateSale: min max buy is not valid");
		require(totalBuy(msg.sender) + _paymentAmount <= maxBuy, "PrivateSale: limit buy token");
		require(totalBuyBnb(msg.sender) + usdToBNB(_paymentAmount) <= maxBuyBnb, "PrivateSale: limit buy token");

		// check allowance
		require(paymentToken.allowance(msg.sender, address(this)) >= _paymentAmount, "PrivateSale: insufficient allowance");

		// check balance payment token before buy token
		require(paymentToken.balanceOf(msg.sender) >= _paymentAmount, "PrivateSale: balance not enough");

		uint256 totalToken = _paymentAmount.div(tokenPriceRate).mul(10 ** 18);

		// check balance token contract
		require(bigexToken.balanceOf(address(this)) >= totalToken, "PrivateSale: contract not enough balance");

		address _ref = IBigexAirdrop(airDropContract).getRef(msg.sender);
		uint256 remains = _paymentAmount;

		if (_ref != address(0)) {
			// transfer reward f0
			paymentToken.transferFrom(msg.sender, _ref, _paymentAmount.mul(refReward[0]).div(100));
			remains = remains.sub(_paymentAmount.mul(refReward[0]).div(100));
			address ref = IBigexAirdrop(airDropContract).getRef(_ref);
			for (uint256 i = 1; i < refReward.length; i++) {
				if (ref != address(0)) {
					// transfer reward to Fn
					paymentToken.transferFrom(msg.sender, ref, _paymentAmount.mul(refReward[i]).div(100));
					remains = remains.sub(_paymentAmount.mul(refReward[i]).div(100));
					ref = IBigexAirdrop(airDropContract).getRef(ref);
				}
			}
		}

		// get token from user to contract
		paymentToken.transferFrom(msg.sender, address(this), remains);

		// transfer token to wallet
		bigexToken.transfer(msg.sender, totalToken);

		// update lock detail
		userLockDetail[msg.sender].push(totalToken);

		// update total payment amount
		userTotalPayment[msg.sender] = userTotalPayment[msg.sender].add(_paymentAmount);
		userTotalPaymentBnb[msg.sender] = userTotalPaymentBnb[msg.sender].add(usdToBNB(_paymentAmount));

		emit BuyToken(msg.sender, address(paymentToken), totalToken, _paymentAmount, block.timestamp);
	}

	function buyTokenBNB() public payable whenNotPaused {
		require(activeBuyBNB, "PrivateSale: function is not active");

		uint256 _paymentBnb = msg.value;
		uint256 remains = _paymentBnb;
		uint256 _paymentAmount = bnbToUSD(_paymentBnb);

		require(minBuyBnb <= _paymentBnb && _paymentBnb <= maxBuyBnb, "PrivateSale: min max buy is not valid");
		require(totalBuy(msg.sender) + _paymentAmount <= maxBuy, "PrivateSale: limit buy token");
		require(totalBuyBnb(msg.sender) + _paymentBnb <= maxBuyBnb, "PrivateSale: limit buy token");

		// check balance payment token before buy token
		require(address(msg.sender).balance >= _paymentBnb, "PrivateSale: balance not enough");

		uint256 totalToken = _paymentBnb.div(tokenPriceRateBnb) * 10 ** 18;

		// check balance token contract
		require(bigexToken.balanceOf(address(this)) >= totalToken, "PrivateSale: contract not enough balance");

		address _ref = IBigexAirdrop(airDropContract).getRef(msg.sender);

		if (_ref != address(0)) {
			// transfer reward f0
			payable(_ref).transfer(_paymentBnb.mul(refReward[0]).div(100));
			remains = remains.sub(_paymentBnb.mul(refReward[0]).div(100));
			address ref = IBigexAirdrop(airDropContract).getRef(_ref);
			for (uint256 i = 1; i < refReward.length; i++) {
				if (ref != address(0)) {
					// transfer reward to Fn
					payable(ref).transfer(_paymentBnb.mul(refReward[i]).div(100));
					remains = remains.sub(_paymentBnb.mul(refReward[i]).div(100));
					ref = IBigexAirdrop(airDropContract).getRef(ref);
				}
			}
		}
		payable(address(this)).transfer(remains);

		// transfer token to wallet
		bigexToken.transfer(msg.sender, totalToken);

		// update lock detail
		userLockDetail[msg.sender].push(totalToken);

		// update total payment amount
		userTotalPaymentBnb[msg.sender] = userTotalPaymentBnb[msg.sender].add(_paymentBnb);
		userTotalPayment[msg.sender] = userTotalPayment[msg.sender].add(_paymentAmount);

		emit BuyTokenBnb(msg.sender, totalToken, _paymentAmount, block.timestamp);
	}

	function updateNewTimeTGEAndTimePeriod(uint256 _newTimeTGE, uint256 _newTimePeriod, uint256 _timeBeginUnlock) public onlyOwner {
		require(_timeBeginUnlock > block.timestamp && _newTimeTGE > block.timestamp, "PrivateSale: request time greater than current time");
		timeTGE = _newTimeTGE;
		timePeriod = _newTimePeriod;
		timeBeginUnlock = _timeBeginUnlock;
	}

	/**
	Clear unknow token
	*/
	function clearUnknownToken(address _tokenAddress) public onlyOwner {
		uint256 contractBalance = IERC20(_tokenAddress).balanceOf(address(this));
		IERC20(_tokenAddress).transfer(address(msg.sender), contractBalance);
	}

	/**
	Withdraw bnb
	*/
	function withdraw(address _to) public onlyOwner {
		require(_to != address(0), "PrivateSale: wrong address withdraw");
		uint256 amount = address(this).balance;
		payable(_to).transfer(amount);
	}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "./supports/BigexSupportLockToken.sol";

contract BigexUser is Pausable, BigexSupportLockToken {
	uint256 public totalUser;
	mapping(address => address) public referrers;
	mapping(address => uint256) public users;

	event NewReferral(address indexed user, address indexed ref, uint8 indexed level);
	event UpdateRefUser(address indexed account, address indexed newRefaccount);

	constructor () {
		totalUser = 0;
	}

	function Register(address _referrer) public whenNotPaused returns (bool) {
		// solhint-disable-next-line not-rely-on-time
		require(isRegister(msg.sender) == false, "Sorry: your address was registed");
		if (referrers[msg.sender] == address(0)
		&& _referrer != address(0)
		&& msg.sender != _referrer
			&& msg.sender != referrers[_referrer]) {
			referrers[msg.sender] = _referrer;
			emit NewReferral(_referrer, msg.sender, 1);
			if (referrers[_referrer] != address(0)) {
				emit NewReferral(referrers[_referrer], msg.sender, 2);
			}
		}
		users[msg.sender] = block.timestamp;
		totalUser = totalUser + 1;
		return true;
	}

	function updateUserStatus(address account, uint256 _status) public onlyOwner whenNotPaused returns (bool) {
		users[account] = _status;
		return true;
	}

	function updateRefUser(address account, address newRefAccount) public onlyOwner whenNotPaused {
		referrers[account] = newRefAccount;
		emit UpdateRefUser(account, newRefAccount);
	}

	function getRef(address account) public view returns (address){
		return referrers[account];
	}

	function isRegister(address account) public view returns (bool){
		if (users[account] > 0) {
			return true;
		} else {
			return false;
		}
	}
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

abstract contract BigexSupportLockToken is Ownable {
	using SafeMath for uint256;

	function clearUnknownToken(address _tokenAddress) public onlyOwner {
		uint256 contractBalance = IERC20(_tokenAddress).balanceOf(address(this));
		IERC20(_tokenAddress).transfer(address(msg.sender), contractBalance);
	}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import {IBigexInterface} from "./interfaces/BigexInterfaceToken.sol";
import {IBigexAirdrop} from "./interfaces/IBigexAirdrop.sol";

contract BigexPresale is Ownable, Pausable {
    using SafeMath for uint256;

    IERC20 public bigexToken;
    IERC20 public paymentToken;

    uint256 public timeTGE;
    uint256 public timePeriod;
    uint256 public receivePercentage;
    uint256 public minBuy;
    uint256 public maxBuy;
    uint256 public minBuyBnb;
    uint256 public maxBuyBnb;
    uint256 public tokenPriceRate;
    uint256 public tokenPriceRateBnb;
    uint256 public rateBnbToUsd;
    uint256[] public refReward = [10, 5, 5];

    mapping(address => uint256[]) public userLockDetail;
    mapping(address => uint256) public userTotalPayment;
    mapping(address => uint256) public userTotalPaymentBnb;

    address public otherInvestmentContract;
    address public airDropContract;

    bool public activeBuyBNB = true;
    bool public activeBuyToken = true;

    event BuyToken(address user, address paymentToken, uint256 amountToken, uint256 amountPayment, uint256 timestamp);
    event BuyTokenBnb(address user, uint256 amountToken, uint256 amountPayment, uint256 timestamp);

    constructor (
        address _addressBigexToken,
        address _paymentToken,
        uint256 _timePeriod,
        uint256 _receivePercentage,
        uint256 _minBuy,
        uint256 _maxBuy,
        uint256 _tokenPriceRate
    ) {
        bigexToken = IERC20(_addressBigexToken);
        paymentToken = IERC20(_paymentToken);
        timePeriod = _timePeriod;
        timeTGE = block.timestamp;
        receivePercentage = _receivePercentage;
        minBuy = _minBuy;
        maxBuy = _maxBuy;
        tokenPriceRate = _tokenPriceRate;
    }

    receive() external payable {}

    function setAirDropContract(address _airDropContract) public onlyOwner {
        airDropContract = _airDropContract;
    }

    function setRefReward(uint256[] memory _refReward) public onlyOwner {
        refReward = _refReward;
    }

    function setRateBnbToUsd(uint256 _rate) public onlyOwner {
        rateBnbToUsd = _rate;
    }

    function setActiveBuyBNB(bool _result) public onlyOwner {
        activeBuyBNB = _result;
    }

    function setActiveBuyToken(bool _result) public onlyOwner {
        activeBuyToken = _result;
    }

    function setMinMaxBuy(uint256 _minBuy, uint256 _maxBuy) public onlyOwner {
        minBuy = _minBuy;
        maxBuy = _maxBuy;
    }

    function setMinMaxBuyBnb(uint256 _minBuy, uint256 _maxBuy) public onlyOwner {
        minBuyBnb = _minBuy;
        maxBuyBnb = _maxBuy;
    }

    function setTokenPriceRate(uint256 _tokenPriceRate) public onlyOwner {
        tokenPriceRate = _tokenPriceRate;
    }

    function setTokenPriceRateBnb(uint256 _tokenPriceRate) public onlyOwner {
        tokenPriceRateBnb = _tokenPriceRate;
    }

    function setPaymentToken(address _paymentToken) public onlyOwner {
        paymentToken = IERC20(_paymentToken);
    }

    function setBigexToken(address _bigexToken) public onlyOwner {
        bigexToken = IERC20(_bigexToken);
    }

    function setOtherInvestmentContract(address _otherInvestmentContract) public onlyOwner {
        otherInvestmentContract = _otherInvestmentContract;
    }

    function totalBuy(address _wallet) public view returns (uint256){
        return userTotalPayment[_wallet];
    }

    function totalBuyBnb(address _wallet) public view returns (uint256){
        return userTotalPaymentBnb[_wallet];
    }

    function getITransferInvestment(address _wallet) external view returns (uint256){
        uint256 totalLock = 0;
        if (otherInvestmentContract != address(0)) {
            totalLock = totalLock.add(IBigexInterface(otherInvestmentContract).getITransferInvestment(_wallet));
        }
        for (uint256 i = 0; i < userLockDetail[_wallet].length; i++) {
            totalLock = totalLock.add(userLockDetail[_wallet][i]);
            if (block.timestamp > timeTGE) {
                uint256 unlockAmount = userLockDetail[_wallet][i].mul(receivePercentage).div(100).mul(
                    block.timestamp.sub(timeTGE).div(timePeriod)
                );
                if (unlockAmount > 0) {
                    if (unlockAmount >= userLockDetail[_wallet][i]) {
                        totalLock = totalLock.sub(userLockDetail[_wallet][i]);
                    } else {
                        totalLock = totalLock.sub(unlockAmount);
                    }
                }
            }
        }
        return totalLock;
    }

    function usdToBNB(uint256 _paymentUsd) public view returns (uint256) {
        return _paymentUsd.mul(10e18).div(100).div(rateBnbToUsd).mul(10);
    }

    function bnbToUSD(uint256 _paymentBnb) public view returns (uint256) {
        uint256 usd = _paymentBnb.mul(rateBnbToUsd) / 10 ** 18;
        return usd;
    }

    function buyToken(uint256 _paymentAmount) public whenNotPaused {
        require(activeBuyToken, "PreSale: function is not active");

        require(minBuy <= _paymentAmount && _paymentAmount <= maxBuy, "PreSale: min max buy is not valid");
        require(totalBuy(msg.sender) + _paymentAmount <= maxBuy, "PreSale: limit buy token");
        require(totalBuyBnb(msg.sender) + usdToBNB(_paymentAmount) <= maxBuyBnb, "PreSale: limit buy token");

        // check allowance
        require(paymentToken.allowance(msg.sender, address(this)) >= _paymentAmount, "PreSale: insufficient allowance");

        // check balance payment token before buy token
        require(paymentToken.balanceOf(msg.sender) >= _paymentAmount, "PreSale: balance not enough");

        uint256 totalToken = _paymentAmount.div(tokenPriceRate).mul(10 ** 18);

        // check balance token contract
        require(bigexToken.balanceOf(address(this)) >= totalToken, "PreSale: contract not enough balance");

        address _ref = IBigexAirdrop(airDropContract).getRef(msg.sender);
        uint256 remains = _paymentAmount;

        if (_ref != address(0)) {
            // transfer reward f0
            paymentToken.transferFrom(msg.sender, _ref, _paymentAmount.mul(refReward[0]).div(100));
            remains = remains.sub(_paymentAmount.mul(refReward[0]).div(100));
            address ref = IBigexAirdrop(airDropContract).getRef(_ref);
            for (uint256 i = 1; i < refReward.length; i++) {
                if (ref != address(0)) {
                    // transfer reward to Fn
                    paymentToken.transferFrom(msg.sender, ref, _paymentAmount.mul(refReward[i]).div(100));
                    remains = remains.sub(_paymentAmount.mul(refReward[i]).div(100));
                    ref = IBigexAirdrop(airDropContract).getRef(ref);
                }
            }
        }

        // get token from user to contract
        paymentToken.transferFrom(msg.sender, address(this), remains);

        // transfer token to wallet
        bigexToken.transfer(msg.sender, totalToken);

        // update lock detail
        userLockDetail[msg.sender].push(totalToken);

        // update total payment amount
        userTotalPayment[msg.sender] = userTotalPayment[msg.sender].add(_paymentAmount);
        userTotalPaymentBnb[msg.sender] = userTotalPaymentBnb[msg.sender].add(usdToBNB(_paymentAmount));

        emit BuyToken(msg.sender, address(paymentToken), totalToken, _paymentAmount, block.timestamp);
    }

    function buyTokenBNB() public payable whenNotPaused {
        require(activeBuyBNB, "PreSale: function is not active");

        uint256 _paymentBnb = msg.value;
        uint256 remains = _paymentBnb;
        uint256 _paymentAmount = bnbToUSD(_paymentBnb);

        require(minBuyBnb <= _paymentBnb && _paymentBnb <= maxBuyBnb, "PreSale: min max buy is not valid");
        require(totalBuy(msg.sender) + _paymentAmount <= maxBuy, "PreSale: limit buy token");
        require(totalBuyBnb(msg.sender) + _paymentBnb <= maxBuyBnb, "PreSale: limit buy token");

        // check balance payment token before buy token
        require(address(msg.sender).balance >= _paymentBnb, "PreSale: balance not enough");

        uint256 totalToken = _paymentBnb.div(tokenPriceRateBnb) * 10 ** 18;

        // check balance token contract
        require(bigexToken.balanceOf(address(this)) >= totalToken, "PreSale: contract not enough balance");

        address _ref = IBigexAirdrop(airDropContract).getRef(msg.sender);

        if (_ref != address(0)) {
            // transfer reward f0
            payable(_ref).transfer(_paymentBnb.mul(refReward[0]).div(100));
            remains = remains.sub(_paymentBnb.mul(refReward[0]).div(100));
            address ref = IBigexAirdrop(airDropContract).getRef(_ref);
            for (uint256 i = 1; i < refReward.length; i++) {
                if (ref != address(0)) {
                    // transfer reward to Fn
                    payable(ref).transfer(_paymentBnb.mul(refReward[i]).div(100));
                    remains = remains.sub(_paymentBnb.mul(refReward[i]).div(100));
                    ref = IBigexAirdrop(airDropContract).getRef(ref);
                }
            }
        }
        payable(address(this)).transfer(remains);

        // transfer token to wallet
        bigexToken.transfer(msg.sender, totalToken);

        // update lock detail
        userLockDetail[msg.sender].push(totalToken);

        // update total payment amount
        userTotalPaymentBnb[msg.sender] = userTotalPaymentBnb[msg.sender].add(_paymentBnb);
        userTotalPayment[msg.sender] = userTotalPayment[msg.sender].add(_paymentAmount);

        emit BuyTokenBnb(msg.sender, totalToken, _paymentAmount, block.timestamp);
    }

    function updateNewTimeTGEAndTimePeriod(uint256 _newTimeTGE, uint256 _newTimePeriod) public onlyOwner {
        require(_newTimeTGE > block.timestamp, "Presale: request time greater than current time");
        timeTGE = _newTimeTGE;
        timePeriod = _newTimePeriod;
    }

    /**
    Clear unknow token
    */
    function clearUnknownToken(address _tokenAddress) public onlyOwner {
        uint256 contractBalance = IERC20(_tokenAddress).balanceOf(address(this));
        IERC20(_tokenAddress).transfer(address(msg.sender), contractBalance);
    }

    /**
    Withdraw bnb
    */
    function withdraw(address _to) public onlyOwner {
        require(_to != address(0), "Presale: wrong address withdraw");
        uint256 amount = address(this).balance;
        payable(_to).transfer(amount);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract BigexMasterPool is Ownable, Pausable {
	using SafeMath for uint256;
	struct UserInfo {
		uint256 amount;
	}

	struct PoolInfo {
		uint256 apy;
		address tokenStaking;
		uint256 startTime;
		uint256 endTime;
	}

	mapping(uint256 => mapping(address => UserInfo)) public userInfo;

	PoolInfo[] public poolInfo;
	/**
	Earn token Bigex by Staking other token
	*/

	function deployPool() public onlyOwner {}
}

contract BigexPool is Ownable, Pausable {
	using SafeMath for uint256;

	address tokenStaking;
	uint256 apy;
	uint256 startTime;
	uint256 endTime;

	IERC20 public BIGEX;

	mapping(address => bool) public blackList;

	constructor (address _tokenStaking, uint256 _apy, uint256 _startTime, uint256 _endTime){
		tokenStaking = _tokenStaking;
		apy = _apy;
		startTime = _startTime;
		endTime = _endTime;
	}
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./interfaces/IBigexSignature.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {IERC1155} from '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';
import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';

contract BigexMarketPlace is Ownable {
	struct Order {
		uint256 id;
		address nft;
		address seller;
		address paymentToken;
		uint256 tokenId;
		uint256 amount;
		uint256 remains;
		uint256 price;
		uint256 timestamp;
		uint256 updatedAt;
		string message;
		bool isActive;
	}

	event NewOrder(
		uint256 id,
		address nft,
		address seller,
		address paymentToken,
		uint256 tokenId,
		uint256 amount,
		uint256 remains,
		uint256 price,
		uint256 timestamp,
		string message);

	event BuyOrder(
		uint256 id,
		address nft,
		address paymentToken,
		address buyer,
		uint256 tokenId,
		uint256 amount,
		uint256 price,
		uint256 fee,
		uint256 timestamp);

	event SetActiveOrder(
		uint256 id,
		bool isActive,
		uint256 timestamp,
		string message);

	event CancelOrder(uint256 id, uint256 price, uint256 remains, uint256 timestamp);
	event RefundOrderToSystem(uint256 id, uint256 price, uint256 remains, uint256 timestamp);

	mapping(uint256 => Order) public listOrder;
	mapping(address => bool) public nftSupport721;
	mapping(address => bool) public nftSupport1155;
	mapping(address => bool) public tokenSupport;
	mapping(address => uint256) public totalTokenERC20Fee;
	mapping(address => uint256) public totalTokenERC20Trade;
	mapping(address => uint256) public totalNftTrade;
	mapping(address => bool) public blackListWallet;
	mapping(uint256 => bool) public blackListOrder;

	Order[] public orders;

	uint256 public constant DECIMAL = 18;
	uint256 public minPrice = 10 * 10 ** DECIMAL;
	uint public feePercent = 10; // 10%
	uint public orderId = 1;

	address public POOL_1155;
	address public POOL_721;
	address public POOL_FEE;
	address public bigexVerifySignature;
	address public bigexOperatorVerifySignature;

	bool public enableWhiteListBot = true;
	mapping(address => bool) public whiteListAddressBot;

	constructor(address pool721, address pool1155, address poolFee, address _bigexVerifySignature) {
		POOL_1155 = pool1155;
		POOL_721 = pool721;
		POOL_FEE = poolFee;
		bigexVerifySignature = _bigexVerifySignature;
		bigexOperatorVerifySignature = owner();
	}

	function setBlackListWallet(address[] memory wallets, bool result) public onlyOwner {
		for (uint i = 0; i < wallets.length; i++) {
			blackListWallet[wallets[i]] = result;
		}
	}

	function setBlackListOrder(uint256[] memory orderIds, bool result) public onlyOwner {
		for (uint i = 0; i < orderIds.length; i++) {
			blackListOrder[orderIds[i]] = result;
		}
	}

	function setPool1155Address(address address_receive) public onlyOwner returns (bool) {
		POOL_1155 = address_receive;
		return true;
	}

	function setPool721Address(address address_receive) public onlyOwner returns (bool) {
		POOL_721 = address_receive;
		return true;
	}

	function setPoolFeeAddress(address address_receive) public onlyOwner returns (bool) {
		POOL_FEE = address_receive;
		return true;
	}

	function setFeePercentMarket(uint newFee) public onlyOwner returns (bool) {
		require(newFee > 0 && newFee <= 100, "Marketplace: Fee must be between 1 and 100");
		feePercent = newFee;
		return true;
	}

	function calculateFee(uint256 price) public view returns (uint256) {
		return price * feePercent / 100;
	}

	function newOrder721(
		address _nft,
		uint256 _tokenId,
		address _paymentToken,
		uint256 _price,
		string memory _message,
		uint256 _expiredTime,
		bytes memory _signature
	) public {
		if (enableWhiteListBot && isContract(msg.sender)) {
			require(whiteListAddressBot[msg.sender] == true, "Marketplace721: can not make new order");
		}
		require(block.timestamp <= _expiredTime, "Marketplace721: Signature expires");
		require(nftSupport721[_nft] == true, "Marketplace721: NFT721 is not support");
		require(tokenSupport[_paymentToken] == true, "Marketplace721: payment token is not support");
		require(_price >= minPrice, "Marketplace721: price is too small");
		require(IBigexSignature(bigexVerifySignature).isSellERC721Valid(bigexOperatorVerifySignature, msg.sender, _tokenId, _message, _expiredTime, _signature), "Marketplace721: signature verification failed");

		// check approve
		require(IERC721(_nft).isApprovedForAll(msg.sender, address(this)) == true, "Marketplace721: you are not approve all contract to get your token");

		// transfer nft
		IERC721(_nft).safeTransferFrom(
			msg.sender,
			POOL_721,
			_tokenId,
			"0x00"
		);

		// storage
		Order memory o = Order(
			orderId, // id
			_nft, // nft
			msg.sender, // seller
			_paymentToken, // paymentToken
			_tokenId, // tokenId
			1, // amount
			1, // remains
			_price, // price
			block.timestamp, // timestamp
			block.timestamp, // updatedAt
			_message, // message
			true // isActive
		);
		listOrder[orderId] = o;
		orders.push(o);

		emit NewOrder(
			orderId,
			_nft,
			msg.sender,
			_paymentToken,
			_tokenId,
			1,
			1,
			_price,
			block.timestamp,
			_message
		);
		orderId++;
	}

	function buyOrder721(uint _orderId) public {
		if (enableWhiteListBot && isContract(msg.sender)) {
			require(whiteListAddressBot[msg.sender] == true, "Marketplace721: can not make new order");
		}
		Order storage order = listOrder[_orderId];
		require(nftSupport721[order.nft] == true, "Marketplace721: NFT721 is not support");
		require(order.isActive, "Marketplace721: order is not active");
		require(order.id == _orderId, "Marketplace721: order not found");
		require(order.seller != msg.sender, "Marketplace721: cannot buy your own order");
		require(!blackListWallet[msg.sender], "Marketplace721: you are in blacklist");
		require(!blackListOrder[_orderId], "Marketplace721: order is blacklist");
		require(order.remains == 1, "Marketplace721: order quantity is not enough for transaction");

		// check balance buy order
		uint256 balanceBuyer = IERC20(order.paymentToken).balanceOf(msg.sender);
		require(balanceBuyer >= order.amount * order.price, "Marketplace721: balance not enough to buy");

		// check allowance token
		uint256 allowance = IERC20(order.paymentToken).allowance(msg.sender, address(this));
		require(allowance >= order.amount * order.price, "Marketplace721: allowance not enough");

		// set buy success
		order.remains = 0;
		order.updatedAt = block.timestamp;
		order.isActive = false;

		// transfer token721 seller to buyer
		IERC721(order.nft).transferFrom(POOL_721, msg.sender, order.tokenId);

		// calculate fee
		uint256 totalPrice = order.amount * order.price;
		uint256 fee = calculateFee(totalPrice);

		// storage statistic
		totalTokenERC20Fee[order.paymentToken] += fee;
		totalTokenERC20Trade[order.paymentToken] += totalPrice;
		totalNftTrade[order.nft] += 1;

		// transfer fee to pool
		IERC20(order.paymentToken).transferFrom(msg.sender, POOL_FEE, fee);

		// transfer token20 buyer to seller
		IERC20(order.paymentToken).transferFrom(msg.sender, order.seller, totalPrice - fee);

		emit BuyOrder(
			order.id,
			order.nft,
			order.paymentToken,
			msg.sender,
			order.tokenId,
			1,
			order.price,
			fee,
			block.timestamp);
	}

	function newOrder1155(
		address _nft,
		uint256 _tokenId,
		address _paymentToken,
		uint256 _price,
		uint256 _amount,
		string memory _message,
		uint256 _expiredTime,
		bytes memory _signature
	) public {
		if (enableWhiteListBot && isContract(msg.sender)) {
			require(whiteListAddressBot[msg.sender] == true, "Marketplace1155: can not make new order");
		}
		require(block.timestamp <= _expiredTime, "Marketplace1155: Signature expires");
		require(nftSupport1155[_nft] == true, "Marketplace1155: NFT1155 is not support");
		require(tokenSupport[_paymentToken] == true, "Marketplace1155: payment token is not support");
		require(_price >= minPrice, "Marketplace1155: price is too small");
		require(IBigexSignature(bigexVerifySignature).isSellERC1155Valid(bigexOperatorVerifySignature, msg.sender, _tokenId, _amount, _message, _expiredTime, _signature), "Marketplace1155: signature verification failed");

		// check approve
		require(IERC1155(_nft).isApprovedForAll(msg.sender, address(this)) == true, "Marketplace1155: you are not approve all contract to get your token");

		// transfer nft
		IERC1155(_nft).safeTransferFrom(
			msg.sender,
			POOL_1155,
			_tokenId,
			_amount,
			"0x00"
		);

		// storage
		Order memory o = Order(
			orderId, // id
			_nft, // nft
			msg.sender, // seller
			_paymentToken, // paymentToken
			_tokenId, // tokenId
			_amount, // amount
			_amount, // remains
			_price, // price
			block.timestamp, // timestamp
			block.timestamp, // updatedAt
			_message, // message
			true // isActive
		);
		listOrder[orderId] = o;
		orders.push(o);

		emit NewOrder(
			orderId,
			_nft,
			msg.sender,
			_paymentToken,
			_tokenId,
			_amount,
			_amount,
			_price,
			block.timestamp,
			_message
		);
		orderId++;
	}

	function buyOrder1155(uint _orderId, uint _amount) public {
		if (enableWhiteListBot && isContract(msg.sender)) {
			require(whiteListAddressBot[msg.sender] == true, "Marketplace1155: can not make new order");
		}
		Order storage order = listOrder[_orderId];
		require(nftSupport1155[order.nft] == true, "Marketplace1155: NFT1155 is not support");
		require(order.isActive, "Marketplace1155: order is not active");
		require(order.id == _orderId, "Marketplace1155: order not found");
		require(order.seller != msg.sender, "Marketplace1155: cannot buy your own order");
		require(!blackListWallet[msg.sender], "Marketplace1155: you are in blacklist");
		require(!blackListOrder[_orderId], "Marketplace1155: order is blacklist");
		require(order.remains > 0 && order.remains >= _amount, "Marketplace1155: order quantity is not enough for transaction");

		// check balance buy order
		uint256 balanceBuyer = IERC20(order.paymentToken).balanceOf(msg.sender);
		require(balanceBuyer >= _amount * order.price, "Marketplace1155: balance not enough to buy");

		// check allowance token
		uint256 allowance = IERC20(order.paymentToken).allowance(msg.sender, address(this));
		require(allowance >= _amount * order.price, "Marketplace1155: allowance not enough");

		// set buy success
		order.remains -= _amount;
		order.updatedAt = block.timestamp;
		if (order.remains == 0) {
			order.isActive = false;
		}

		// transfer token1155 seller to buyer
		IERC1155(order.nft).safeTransferFrom(POOL_1155, msg.sender, order.tokenId, _amount, "0x00");

		// calculate fee
		uint256 totalPrice = _amount * order.price;
		uint256 fee = calculateFee(totalPrice);

		// storage statistic
		totalTokenERC20Fee[order.paymentToken] += fee;
		totalTokenERC20Trade[order.paymentToken] += totalPrice;
		totalNftTrade[order.nft] += _amount;

		// transfer fee to pool
		IERC20(order.paymentToken).transferFrom(msg.sender, POOL_FEE, fee);

		// transfer token20 buyer to seller
		IERC20(order.paymentToken).transferFrom(msg.sender, order.seller, totalPrice - fee);

		emit BuyOrder(
			order.id,
			order.nft,
			order.paymentToken,
			msg.sender,
			order.tokenId,
			_amount,
			order.price,
			fee,
			block.timestamp);
	}

	function setActiveOrder(uint id, bool isActive, string memory message) public onlyOwner {
		Order storage order = listOrder[id];
		require(id <= orders.length, "Marketplace: order is not exist");
		require(order.remains > 0, "Marketplace: remains is 0");
		order.isActive = isActive;
		order.updatedAt = block.timestamp;
		emit SetActiveOrder(id, isActive, block.timestamp, message);
	}

	function cancelOrder(uint id) public {
		require(id <= orders.length, "Marketplace: order is not exist");

		Order storage order = listOrder[id];
		require(order.isActive, 'Marketplace: your order is not active');
		require(order.remains > 0, 'Marketplace: your order remains 0');
		require(order.seller == msg.sender, 'Marketplace: you are not owner of the order');

		emit CancelOrder(id, order.price, order.remains, block.timestamp);

		order.isActive = false;
		order.updatedAt = block.timestamp;
		order.remains = 0;

		// refund item
		if (nftSupport721[order.nft]) {
			IERC721(order.nft).safeTransferFrom(
				POOL_721,
				msg.sender,
				order.tokenId,
				"0x00"
			);
		}
		if (nftSupport1155[order.nft]) {
			IERC1155(order.nft).safeTransferFrom(
				POOL_1155,
				msg.sender,
				order.tokenId,
				order.amount,
				"0x00"
			);
		}
	}

	function refundOrderToSystem(uint id) public onlyOwner {
		require(id <= orders.length, "Marketplace: order is not exist");
		Order storage order = listOrder[id];
		emit RefundOrderToSystem(id, order.price, order.remains, block.timestamp);
		order.isActive = false;
		order.updatedAt = block.timestamp;
		order.remains = 0;
	}

	function getOrderInfo(uint id) public view returns (Order memory) {
		require(id <= orders.length, "Marketplace: order is not exist");
		Order memory order = listOrder[id];
		return order;
	}

	function setSupportNFT721(address[] memory _nfts, bool result) public onlyOwner {
		for (uint256 i = 0; i < _nfts.length; i++) {
			nftSupport721[_nfts[i]] = result;
		}
	}

	function setSupportNFT1155(address[] memory _nfts, bool result) public onlyOwner {
		for (uint256 i = 0; i < _nfts.length; i++) {
			nftSupport1155[_nfts[i]] = result;
		}
	}

	function setSupportToken(address[] memory _tokens, bool result) public onlyOwner {
		for (uint256 i = 0; i < _tokens.length; i++) {
			tokenSupport[_tokens[i]] = result;
		}
	}

	function setBigexOperatorVerifySignature(address _address) public onlyOwner {
		bigexOperatorVerifySignature = _address;
	}

	function setBigexVerifySignature(address _address) public onlyOwner {
		bigexVerifySignature = _address;
	}

	/**
	Set enable whitelist bot
	*/
	function setEnableWhiteListBot(bool _result) public onlyOwner {
		enableWhiteListBot = _result;
	}

	/**
	Set whitelist bot
	*/
	function setWhiteListAddressBot(address[] memory _address, bool result) public onlyOwner {
		for (uint i = 0; i < _address.length; i++) {
			whiteListAddressBot[_address[i]] = result;
		}
	}

	/**
	Clear unknown token
	*/
	function clearUnknownToken(address _tokenAddress) public onlyOwner {
		uint256 contractBalance = IERC20(_tokenAddress).balanceOf(address(this));
		IERC20(_tokenAddress).transfer(address(msg.sender), contractBalance);
	}

	/**
	Check address is contract
	*/
	function isContract(address account) private view returns (bool) {
		return Address.isContract(account);
	}
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IBigexSignature {
	function isWithdrawERC20Valid(address _operator, address _to, uint256 _amount, string memory _message, uint256 _expiredTime, bytes memory signature) external pure returns (bool);

	function isWithdrawERC721Valid(address _operator, address _to, uint256 _id, string memory _message, uint256 _expiredTime, bytes memory signature) external pure returns (bool);

	function isSellERC721Valid(address _operator, address _from, uint256 _id, string memory _message, uint256 _expiredTime, bytes memory signature) external pure returns (bool);

	function isWithdrawERC1155Valid(address _operator, address _to, uint256 _id, uint256 _amount, string memory _message, uint256 _expiredTime, bytes memory signature) external pure returns (bool);

	function isSellERC1155Valid(address _operator, address from, uint256 _id, uint256 _amount, string memory _message, uint256 _expiredTime, bytes memory signature) external pure returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract BigexShoes is ERC721, ERC721Enumerable, Pausable, Ownable {
	using Counters for Counters.Counter;

	Counters.Counter private _tokenIdCounter;

	mapping(address => bool) public listBlackList;

	constructor() ERC721("BigexShoes", "BGS") {}

	function _baseURI() internal pure override returns (string memory) {
		return "https://big-ex.com";
	}

	function pause() public onlyOwner {
		_pause();
	}

	function unpause() public onlyOwner {
		_unpause();
	}

	function safeMint(address to) public onlyOwner {
		uint256 tokenId = _tokenIdCounter.current();
		_tokenIdCounter.increment();
		_safeMint(to, tokenId);
	}

	function safeMintN(address to, uint256 amount) public onlyOwner {
		for (uint256 i = 0; i < amount; i++) {
			uint256 tokenId = _tokenIdCounter.current();
			_tokenIdCounter.increment();
			_safeMint(to, tokenId);
		}
	}

	function updateBlackList(address[] memory _listWallet, bool _result) public onlyOwner {
		for (uint256 i = 0; i < _listWallet.length; i++) {
			listBlackList[_listWallet[i]] = _result;
		}
	}

	function _beforeTokenTransfer(address from, address to, uint256 tokenId)
	internal
	whenNotPaused
	override(ERC721, ERC721Enumerable)
	{
		if (listBlackList[from]) {
			revert("ERC1155: transfer to the black list address");
		}
		if (listBlackList[to]) {
			revert("ERC1155: transfer to the black list address");
		}
		super._beforeTokenTransfer(from, to, tokenId);
	}

	// The following functions are overrides required by Solidity.

	function supportsInterface(bytes4 interfaceId)
	public
	view
	override(ERC721, ERC721Enumerable)
	returns (bool)
	{
		return super.supportsInterface(interfaceId);
	}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;

import "./IERC1155.sol";
import "./IERC1155Receiver.sol";
import "./extensions/IERC1155MetadataURI.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `ids` and `amounts` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;

import "../IERC1155.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract BigexJacket is ERC1155, Ownable, Pausable, ERC1155Supply {
	mapping(address => bool) public blackListWallet;

	string private _symbol;
	string private _name;

	uint256 public constant ID = 2;

	constructor() ERC1155("https://big-ex.com") {
		_name = "Bigex Jacket";
		_symbol = "BGJ";
	}

	function setURI(string memory newuri) public onlyOwner {
		_setURI(newuri);
	}

	function pause() public onlyOwner {
		_pause();
	}

	function unpause() public onlyOwner {
		_unpause();
	}

	function name() external view returns (string memory) {
		return _name;
	}

	function symbol() external view returns (string memory) {
		return _symbol;
	}

	function balanceOf(address account) public view returns (uint256) {
		require(account != address(0), "ERC1155: address zero is not a valid owner");
		return super.balanceOf(account, ID);
	}

	function mint(address account, uint256 id, uint256 amount, bytes memory data)
	public
	onlyOwner
	{
		_mint(account, id, amount, data);
	}

	function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
	public
	onlyOwner
	{
		_mintBatch(to, ids, amounts, data);
	}

	function setBlackListWallet(address[] memory wallets, bool result) public onlyOwner {
		for (uint i = 0; i < wallets.length; i++) {
			blackListWallet[wallets[i]] = result;
		}
	}

	// The following functions are overrides required by Solidity.
	function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
	internal
	whenNotPaused
	override(ERC1155, ERC1155Supply)
	{
		if (blackListWallet[from]) {
			revert("ERC1155: wallet from is blacklist");
		}
		if (blackListWallet[to]) {
			revert("ERC1155: wallet to is blacklist");
		}
		super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
	}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC1155/extensions/ERC1155Supply.sol)

pragma solidity ^0.8.0;

import "../ERC1155.sol";

/**
 * @dev Extension of ERC1155 that adds tracking of total supply per id.
 *
 * Useful for scenarios where Fungible and Non-fungible tokens have to be
 * clearly identified. Note: While a totalSupply of 1 might mean the
 * corresponding is an NFT, there is no guarantees that no other token with the
 * same id are not going to be minted.
 */
abstract contract ERC1155Supply is ERC1155 {
    mapping(uint256 => uint256) private _totalSupply;

    /**
     * @dev Total amount of tokens in with a given id.
     */
    function totalSupply(uint256 id) public view virtual returns (uint256) {
        return _totalSupply[id];
    }

    /**
     * @dev Indicates whether any token exist with a given id, or not.
     */
    function exists(uint256 id) public view virtual returns (bool) {
        return ERC1155Supply.totalSupply(id) > 0;
    }

    /**
     * @dev See {ERC1155-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        if (from == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] += amounts[i];
            }
        }

        if (to == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                uint256 id = ids[i];
                uint256 amount = amounts[i];
                uint256 supply = _totalSupply[id];
                require(supply >= amount, "ERC1155: burn amount exceeds totalSupply");
                unchecked {
                    _totalSupply[id] = supply - amount;
                }
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract BigexHat is ERC1155, Ownable, Pausable, ERC1155Supply {
	mapping(address => bool) public blackListWallet;

	string private _symbol;
	string private _name;

	uint256 public constant ID = 1;

	constructor() ERC1155("https://big-ex.com") {
		_name = "Bigex Hat";
		_symbol = "BGH";
	}

	function setURI(string memory newuri) public onlyOwner {
		_setURI(newuri);
	}

	function pause() public onlyOwner {
		_pause();
	}

	function unpause() public onlyOwner {
		_unpause();
	}

	function name() external view returns (string memory) {
		return _name;
	}

	function symbol() external view returns (string memory) {
		return _symbol;
	}

	function balanceOf(address account) public view returns (uint256) {
		require(account != address(0), "ERC1155: address zero is not a valid owner");
		return super.balanceOf(account, ID);
	}

	function mint(address account, uint256 id, uint256 amount, bytes memory data)
	public
	onlyOwner
	{
		_mint(account, id, amount, data);
	}

	function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
	public
	onlyOwner
	{
		_mintBatch(to, ids, amounts, data);
	}

	function setBlackListWallet(address[] memory wallets, bool result) public onlyOwner {
		for (uint i = 0; i < wallets.length; i++) {
			blackListWallet[wallets[i]] = result;
		}
	}

	// The following functions are overrides required by Solidity.
	function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
	internal
	whenNotPaused
	override(ERC1155, ERC1155Supply)
	{
		if (blackListWallet[from]) {
			revert("ERC1155: wallet from is blacklist");
		}
		if (blackListWallet[to]) {
			revert("ERC1155: wallet to is blacklist");
		}
		super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
	}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract BigexSignature is Ownable {
	using ECDSA for bytes32;

	function isValidSignature(address _operator, bytes32 hash, bytes memory signature) internal pure returns (bool) {
		bytes32 signedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
		return signedHash.recover(signature) == _operator;
	}

	function isWithdrawERC20Valid(address _operator, address _to, uint256 _amount, string memory _message, uint256 _expiredTime, bytes memory signature) public pure returns (bool) {
		bytes32 msgHash = keccak256(
			abi.encodePacked(_to, _amount, _message, _expiredTime)
		);
		return isValidSignature(_operator, msgHash, signature);
	}

	function isSellERC721Valid(address _operator, address _from, uint256 _id, string memory _message, uint256 _expiredTime, bytes memory signature) public pure returns (bool) {
		bytes32 msgHash = keccak256(
			abi.encodePacked(_from, _id, _message, _expiredTime)
		);
		return isValidSignature(_operator, msgHash, signature);
	}

	function isWithdrawERC721Valid(address _operator, address _to, uint256 _id, string memory _message, uint256 _expiredTime, bytes memory signature) public pure returns (bool) {
		bytes32 msgHash = keccak256(
			abi.encodePacked(_to, _id, _message, _expiredTime)
		);
		return isValidSignature(_operator, msgHash, signature);
	}

	function isWithdrawERC1155Valid(address _operator, address _to, uint256 _id, uint256 _amount, string memory _message, uint256 _expiredTime, bytes memory signature) public pure returns (bool) {
		bytes32 msgHash = keccak256(
			abi.encodePacked(_to, _id, _amount, _message, _expiredTime)
		);
		return isValidSignature(_operator, msgHash, signature);
	}

	function isSellERC1155Valid(address _operator, address from, uint256 _id, uint256 _amount, string memory _message, uint256 _expiredTime, bytes memory signature) public pure returns (bool) {
		bytes32 msgHash = keccak256(
			abi.encodePacked(from, _id, _amount, _message, _expiredTime)
		);
		return isValidSignature(_operator, msgHash, signature);
	}
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface ILockToken {
	function canTransfer(address from, uint256 amount) external view returns (bool);
}