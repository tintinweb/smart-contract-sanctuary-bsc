// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import {IBigexInterface} from "./interfaces/BigexInterfaceToken.sol";

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
	mapping(address => address) public referrers;

	address public otherInvestmentContract;

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

	function setReferrer(address _wallet, address _ref) public onlyOwner {
		referrers[_wallet] = _ref;
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

	function buyToken(uint256 _paymentAmount, address _ref) public whenNotPaused {
		require(activeBuyToken, "PrivateSale: function is not active");
		require(msg.sender != _ref, "PrivateSale: can not ref myself");

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

		if (referrers[msg.sender] == address(0)) {
			referrers[msg.sender] = _ref;
		} else {
			_ref = referrers[msg.sender];
		}

		uint256 remains = _paymentAmount;
		if (_ref != address(0)) {
			// transfer reward f0
			paymentToken.transferFrom(msg.sender, _ref, _paymentAmount.mul(refReward[0]).div(100));
			remains = remains.sub(_paymentAmount.mul(refReward[0]).div(100));
			address ref = referrers[_ref];
			for (uint256 i = 1; i < refReward.length; i++) {
				if (ref != address(0)) {
					// transfer reward to Fn
					paymentToken.transferFrom(msg.sender, ref, _paymentAmount.mul(refReward[i]).div(100));
					remains = remains.sub(_paymentAmount.mul(refReward[i]).div(100));
					ref = referrers[ref];
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

	function buyTokenBNB(address _ref) public payable whenNotPaused {
		require(activeBuyBNB, "PrivateSale: function is not active");
		require(msg.sender != _ref, "PrivateSale: can not ref myself");

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

		if (referrers[msg.sender] == address(0)) {
			referrers[msg.sender] = _ref;
		} else {
			_ref = referrers[msg.sender];
		}

		if (_ref != address(0)) {
			// transfer reward f0
			payable(_ref).transfer(_paymentBnb.mul(refReward[0]).div(100));
			remains = remains.sub(_paymentBnb.mul(refReward[0]).div(100));
			address ref = referrers[_ref];
			for (uint256 i = 1; i < refReward.length; i++) {
				if (ref != address(0)) {
					// transfer reward to Fn
					payable(ref).transfer(_paymentBnb.mul(refReward[i]).div(100));
					remains = remains.sub(_paymentBnb.mul(refReward[i]).div(100));
					ref = referrers[ref];
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
pragma solidity ^0.8.0;
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IBigexInterface {
	function getITransferInvestment(address account) external view returns (uint256);
	function getITransferAidrop(address account) external view returns (uint256);
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