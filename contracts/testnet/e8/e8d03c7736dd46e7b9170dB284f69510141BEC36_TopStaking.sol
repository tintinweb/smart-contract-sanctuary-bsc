// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./DataStorage.sol";
import "./Events.sol";
import "./Utils.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TopStaking is ReentrancyGuard, DataStorage, Events, Ownable, Utils, Pausable {
    using SafeMath for uint256;

    /**
     * @dev Constructor function
     */
    constructor(address coldWallet, uint8 usageFee) public {
        // pools[1] = Pool(
        //     1,
        //     1651136038,
        //     1651222438,
        //     0,
        //     0x44d8DF9034F35eeDC972614d489E4E2ABBE5b993,
        //     15000 * 10**18,
        //     18000
        // );
        _coldWallet = coldWallet;
        _usageFee = usageFee;
    }

    function invest(uint8 poolId, uint256 _amount) external nonReentrant whenNotPaused {
        require(_amount > 0, "Invest amount isn't enough");
        require(poolId != 0, "Invalid plan");
        Pool memory pool = pools[poolId];
        require(pool.fromTime <= block.timestamp, "Pool not start");
        require(block.timestamp <= pool.toTime, "Pool stopped");
        require(pool.totalAmount.add(_amount) <= pool.maxCap, "Pool cap full fill");
        require(
            IERC20(pool.tokenAddress).allowance(_msgSender(), address(this)) >=
                _amount,
            "Token allowance too low"
        );
        _invest(poolId, _amount);
    }

    function _invest(uint256 _poolId, uint256 _amount) internal {
        UserInfo storage user = userInfos[_poolId][_msgSender()];
        Pool storage pool = pools[_poolId];
        _safeTransferFrom(
            _msgSender(),
            address(this),
            _amount,
            pool.tokenAddress
        );
        if(user.registerTime == 0) {
            user.registerTime = block.timestamp;
            emit Newbie(_msgSender(), block.timestamp);
        }
        user.lastStake = block.timestamp;
        user.totalAmount = user.totalAmount.add(_amount);
        pool.totalAmount = pool.totalAmount.add(_amount);
        user.deposits.push(Deposit(_poolId, block.timestamp, block.timestamp, _amount, false));
        if(user.registerTime == 0) {
            user.registerTime = block.timestamp;
            totalUser.push(user);
            emit Newbie(_msgSender(), block.timestamp);
        }
        emit NewDeposit(_msgSender(), _poolId, _amount);
    }

    function unStake(uint256 _poolId) external nonReentrant {
        UserInfo storage user = userInfos[_poolId][_msgSender()];
        Pool storage pool = pools[_poolId];

        uint256 totalCurrentDividend = getUserDividends(_msgSender(), _poolId);
        uint256 totalAmount;
        for (uint256 index = 0; index < user.deposits.length; index++) {
            if(!user.deposits[index].isUnstake) {
                user.deposits[index].isUnstake = true;
                totalAmount = totalAmount.add(user.deposits[index].amount);
            }
        }
        user.totalPayout = user.totalPayout.add(totalCurrentDividend);
        user.totalAmount = user.totalAmount.sub(totalAmount);
        pool.totalAmount = pool.totalAmount.sub(totalAmount);

        IERC20(pool.tokenAddress).transfer(_msgSender(), (totalAmount + (totalCurrentDividend - totalAmount) * (DENOMINATOR - _usageFee)/DENOMINATOR));
        IERC20(pool.tokenAddress).transfer(_coldWallet, ((totalCurrentDividend - totalAmount) * _usageFee/DENOMINATOR));
        emit UnStake(_msgSender(), _poolId, (totalAmount + (totalCurrentDividend - totalAmount) * (DENOMINATOR - _usageFee)/DENOMINATOR));
    }

    function harvest(uint256 _poolId) external nonReentrant {
        UserInfo storage user = userInfos[_poolId][_msgSender()];
        Pool memory pool = pools[_poolId];

        uint256 totalCurrentDividend = getUserDividendsHarvest(_msgSender(), _poolId);
        for (uint256 index = 0; index < user.deposits.length; index++) {
            if(!user.deposits[index].isUnstake) {
                user.deposits[index].start = block.timestamp;
            }
        }
        user.totalPayout = user.totalPayout.add(totalCurrentDividend);

        IERC20(pool.tokenAddress).transfer(_msgSender(), totalCurrentDividend.mul(DENOMINATOR - _usageFee).div(DENOMINATOR));
        IERC20(pool.tokenAddress).transfer(_coldWallet, totalCurrentDividend.mul(_usageFee).div(DENOMINATOR));

        emit UnStake(_msgSender(), _poolId, totalCurrentDividend);
    }

    function _safeTransferFrom(
        address _sender,
        address _recipient,
        uint256 _amount,
        address _token
    ) private {
        bool sent = IERC20(_token).transferFrom(_sender, _recipient, _amount);
        require(sent, "Token transfer failed");
    }

    function updatePoolInfo(uint256 poolId, uint256 fromTime, uint256 toTime, address tokenAddress, uint256 maxCap, uint256 rate) external onlyOwner {
        Pool storage pool = pools[poolId];

        require(tokenAddress != address(0), 'Invalid address');
        require(fromTime < toTime, 'Invalid from time and to time');

        if (pool.tokenAddress != address(0)) {
            require(pool.fromTime > block.timestamp, 'Do not allow the start time update for the pool to have taken place');
            require(maxCap > pool.totalAmount, 'Max cap lessthan total amount');
        }
         
        pool.poolId = poolId;
        pool.fromTime = fromTime;
        pool.toTime = toTime;
        pool.tokenAddress = tokenAddress;
        pool.maxCap = maxCap;
        pool.rateTime.push(RateTime(rate, block.timestamp));

        pools[poolId] = pool;
    }

    function handleForfeitedBalance(
        address coinAddress,
        uint256 value,
        address payable to
    ) external onlyOwner {
        if (coinAddress == address(0)) {
            return to.transfer(value);
        }
        IERC20(coinAddress).transfer(to, value);
    }

    function setColdWallet(address coldWallet) external onlyOwner {
        _coldWallet = coldWallet;
    }

    function setUsageFee(uint8 usageFee) external onlyOwner {
        require(usageFee < DENOMINATOR, "Input value must be less than 100");
        _usageFee = usageFee;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

contract DataStorage {

    uint256 SECONDS_IN_A_DAY = 86400;
	uint256 DENOMINATOR = 10000; 
    uint8 public _usageFee;
    address public _coldWallet;

    struct Pool {
		uint256 poolId;
        uint256 fromTime;
        uint256 toTime;
		uint256 totalAmount;
		address tokenAddress;
		uint256 maxCap;
		RateTime[] rateTime;
    }

	struct UserInfo {
		uint256 totalPayout;
		uint256 registerTime;
		uint256 lastStake;
		uint256 poolId;
		uint256 totalAmount;
		Deposit[] deposits;
	}

	struct Deposit {
		uint256 poolId;
        uint256 createdAt;
		uint256 start;
		uint256 amount;
		bool isUnstake;
	}

	struct RateTime {
		uint256 rate;
		uint256 timestamp;
	}

	mapping (uint256 => Pool) public pools;
	mapping (uint256 => mapping(address => UserInfo)) userInfos;

	UserInfo[] internal totalUser;

}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

contract Events {
  event Newbie(address indexed user, uint256 registerTime);
  event NewDeposit(address indexed user, uint256 poolId, uint256 amount);
  event UnStake(address indexed user, uint256 poolId, uint256 amount);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./DataStorage.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Utils is DataStorage {
    using SafeMath for uint256;

    function getUserDividends(address userAddress, uint256 poolId)
        public
        view
        returns (uint256)
    {
        UserInfo memory user = userInfos[poolId][userAddress];
        Pool memory pool = pools[poolId];
        RateTime[] memory rateTime = pool.rateTime;

        uint256 currentDividend;
        for (uint256 index = 0; index < user.deposits.length; index++) {
            if(!user.deposits[index].isUnstake) {
                for (uint256 j = 0; j < rateTime.length; j++) {
                    uint256 fromTime = user.deposits[index].start > rateTime[j].timestamp ? user.deposits[index].start : rateTime[j].timestamp;
                    uint256 toTime;
                    if (pool.toTime > block.timestamp) {
                        if (j < rateTime.length - 1) {
                            toTime = rateTime[j+1].timestamp;
                        } else {
                            toTime = block.timestamp;
                        }
                    } else {
                        toTime = pool.toTime;
                    }
                    uint256 totalTime = toTime.sub(fromTime);
                    currentDividend = currentDividend + user.deposits[index].amount + user.deposits[index].amount * totalTime * rateTime[j].rate / (DENOMINATOR * 365 * SECONDS_IN_A_DAY);
                }
            }
        }


        return currentDividend;          
    }

    function getUserDividendsHarvest(address userAddress, uint256 poolId)
        public
        view
        returns (uint256)
    {
        UserInfo memory user = userInfos[poolId][userAddress];
        Pool memory pool = pools[poolId];
        RateTime[] memory rateTime = pool.rateTime;
        
        uint256 currentDividend;
        for (uint256 index = 0; index < user.deposits.length; index++) {
            if(!user.deposits[index].isUnstake) {
                for (uint256 j = 0; j < rateTime.length; j++) {
                    uint256 fromTime = user.deposits[index].start > rateTime[j].timestamp ? user.deposits[index].start : rateTime[j].timestamp;
                    uint256 toTime;
                    if (pool.toTime > block.timestamp) {
                        if (j < rateTime.length - 1) {
                            toTime = rateTime[j+1].timestamp;
                        } else {
                            toTime = block.timestamp;
                        }
                    } else {
                        toTime = pool.toTime;
                    }
                    uint256 totalTime = toTime.sub(fromTime);
                    currentDividend = currentDividend + user.deposits[index].amount * totalTime * rateTime[j].rate / (DENOMINATOR * 365 * SECONDS_IN_A_DAY);
                }
            }
        }
        return currentDividend;          
    }

    function getUserInfo(address userAddress, uint256 poolId)
        public
        view
        returns (UserInfo memory userInfo)
    {
        userInfo = userInfos[poolId][userAddress];
    }

    function getAllUser(uint256 fromRegisterTime, uint256 toRegisterTime)
        public
        view
        returns (UserInfo[] memory)
    {
        UserInfo[] memory allUser = new UserInfo[](totalUser.length);
        uint256 count = 0;

        for (uint256 index = 0; index < totalUser.length; index++) {
            if (
                totalUser[index].registerTime >= fromRegisterTime &&
                totalUser[index].registerTime <= toRegisterTime
            ) {
                allUser[count] = totalUser[index];
                ++count;
            }
        }
        return allUser;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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