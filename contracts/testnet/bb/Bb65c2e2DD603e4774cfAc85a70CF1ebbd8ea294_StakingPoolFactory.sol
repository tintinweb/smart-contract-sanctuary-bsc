// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingPoolFactory is Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private poolId;

    struct Stake {
        uint256 id;
        address payable owner;
        uint256 amount;
        uint256 period;
        uint256 createdTime;
        bool isUnstaked;
    }

    struct Pool {
        uint256 id;
        address payable owner;
        address stakingToken;
        address rewardsToken;
        uint256 totalRewards;
        uint256 totalStaked;
        uint256 totalPoint;
        uint256 totalUnstaked;
        uint256 stakesNumber;
        mapping(uint256 => Stake) stakes;
    }

    struct PoolForExport {
        uint256 id;
        address payable owner;
        address stakingToken;
        address rewardsToken;
        uint256 totalRewards;
        uint256 totalStaked;
        uint256 totalPoint;
        uint256 totalUnstaked;
        uint256 stakesNumber;
    }

    mapping(uint256 => Pool) public pools;

    constructor() {}

    function createPool(
        address _stakingToken,
        address _rewardsToken,
        uint _totalRewards
    ) external returns (uint256) {
        uint256 _id = poolId.current();
        checkIsERC20(_stakingToken);
        checkIsERC20(_rewardsToken);
        require(
            IERC20(_rewardsToken).balanceOf(msg.sender) >= _totalRewards,
            "createPool::insufficient rewards balance"
        );
        Pool storage _pool = pools[_id];
        IERC20 rewardsToken = IERC20(_rewardsToken);
        rewardsToken.transferFrom(
            payable(msg.sender),
            address(this),
            _totalRewards
        );
        _pool.id = _id;
        _pool.owner = payable(msg.sender);
        _pool.stakingToken = _stakingToken;
        _pool.rewardsToken = _rewardsToken;
        _pool.totalRewards = _totalRewards;
        poolId.increment();
        return _id;
    }

    function stake(
        uint256 _poolId,
        uint256 _amount,
        uint256 _period
    ) external {
        Pool storage _pool = pools[_poolId];
        IERC20 stakingToken = IERC20(_pool.stakingToken);
        require(
            stakingToken.balanceOf(msg.sender) >= _amount,
            "stake::insufficient balance"
        );
        stakingToken.transferFrom(payable(msg.sender), address(this), _amount);
        uint256 _id = _pool.stakesNumber;
        Stake storage _stake = pools[_poolId].stakes[_id];
        _stake.id = _id;
        _stake.owner = payable(msg.sender);
        _stake.amount = _amount;
        _stake.period = _period;
        _stake.createdTime = block.timestamp;
        _pool.totalStaked = _pool.totalStaked + _amount;
        _pool.totalPoint = _pool.totalPoint + _amount * _period;
        _pool.stakesNumber = _pool.stakesNumber + 1;
    }

    function unstake(uint256 _poolId, uint256 _stakeId) external {
        // Stake storage _stake = pools[_poolId].stakes[_stakeId];
        Pool storage _pool = pools[_poolId];
        require(msg.sender == _pool.stakes[_stakeId].owner, "unstake::not owner");
        require(
            _pool.stakes[_stakeId].createdTime + _pool.stakes[_stakeId].period < block.timestamp,
            "unstake::time is not up"
        );
        uint256 _rewardsAmount;
        (, _rewardsAmount) = calculateRewards(_poolId, _stakeId); // get rewards amount
        IERC20 rewardsToken = IERC20(_pool.rewardsToken);
        rewardsToken.transfer(msg.sender, _rewardsAmount);
        _pool.stakes[_stakeId].isUnstaked = true;
        _pool.totalPoint = _pool.totalPoint - _pool.stakes[_stakeId].amount * _pool.stakes[_stakeId].period;
        _pool.totalUnstaked = _pool.totalUnstaked - _rewardsAmount;
    }

    function checkIsERC20(address _token) internal view {
        IERC20 _tokenContract = IERC20(_token);
        require(
            _tokenContract.totalSupply() > 0,
            "checkIsERC20::wrong ERC20 address"
        );
    }

    function calculateRewards(uint256 _poolId, uint256 _stakeId)
        public
        view
        returns (uint256, uint256)
    {
        Pool storage _pool = pools[_poolId];
        uint256 _point = _pool.stakes[_stakeId].amount *
            _pool.stakes[_stakeId].period;
        uint256 _poolShare = (_point * 10000) / _pool.totalPoint; // 100 times of real value
        uint256 _rewardsAmount = (_point * _pool.totalRewards) /
            _pool.totalPoint;
        return (_poolShare, _rewardsAmount);
    }

    function estimateRewards(
        uint256 _poolId,
        uint256 _amount,
        uint256 _period
    ) public view returns (uint256, uint256) {
        Pool storage _pool = pools[_poolId];
        uint256 _point = _amount * _period;
        uint256 _poolShare = (_point * 10000) / (_pool.totalPoint + _point); // 100 times of real value
        uint256 _rewardsAmount = (_point * _pool.totalRewards) /
            (_pool.totalPoint + _point);
        return (_poolShare, _rewardsAmount);
    }

    function getPool(uint _poolId)
        external
        view
        returns (PoolForExport memory)
    {
        PoolForExport memory _pool;
        _pool.id = pools[_poolId].id;
        _pool.owner = pools[_poolId].owner;
        _pool.stakingToken = pools[_poolId].stakingToken;
        _pool.rewardsToken = pools[_poolId].rewardsToken;
        _pool.totalRewards = pools[_poolId].totalRewards;
        _pool.totalStaked = pools[_poolId].totalStaked;
        _pool.totalPoint = pools[_poolId].totalPoint;
        _pool.totalUnstaked = pools[_poolId].totalUnstaked;
        _pool.stakesNumber = pools[_poolId].stakesNumber;
        return _pool;
    }

    function getStake(uint _poolId, uint _stakeId)
        external
        view
        returns (
            uint256,
            address,
            uint256,
            uint256,
            uint256,
            bool
        )
    {
        Stake storage _stake = pools[_poolId].stakes[_stakeId];
        return (
            _stake.id,
            _stake.owner,
            _stake.amount,
            _stake.period,
            _stake.createdTime,
            _stake.isUnstaked
        );
    }

    function getPools() external view returns (PoolForExport[] memory) {
        PoolForExport[] memory _pools = new PoolForExport[](poolId.current());
        for (uint i = 0; i < poolId.current(); i++) {
            Pool storage _pool = pools[i];
            _pools[i].id = _pool.id;
            _pools[i].owner = _pool.owner;
            _pools[i].stakingToken = _pool.stakingToken;
            _pools[i].rewardsToken = _pool.rewardsToken;
            _pools[i].totalRewards = _pool.totalRewards;
            _pools[i].totalStaked = _pool.totalStaked;
            _pools[i].totalPoint = _pool.totalPoint;
            _pools[i].totalUnstaked = _pool.totalUnstaked;
            _pools[i].stakesNumber = _pool.stakesNumber;
        }
        return _pools;
    }

    function getPoolsByOwner(address _owner)
        external
        view
        returns (PoolForExport[] memory)
    {
        PoolForExport[] memory _pools = new PoolForExport[](poolId.current());
        uint256 _counter = 0;
        for (uint i = 0; i < poolId.current(); i++) {
            Pool storage _pool = pools[i];
            if (_pool.owner == _owner) {
                _pools[_counter].id = _pool.id;
                _pools[_counter].owner = _pool.owner;
                _pools[_counter].stakingToken = _pool.stakingToken;
                _pools[_counter].rewardsToken = _pool.rewardsToken;
                _pools[_counter].totalRewards = _pool.totalRewards;
                _pools[_counter].totalStaked = _pool.totalStaked;
                _pools[_counter].totalPoint = _pool.totalPoint;
                _pools[_counter].totalUnstaked = _pool.totalUnstaked;
                _pools[_counter].stakesNumber = _pool.stakesNumber;
                _counter++;
            }
        }
        return _pools;
    }

    function getStakesByOwner(uint _poolId, address _owner)
        external
        view
        returns (Stake[] memory)
    {
        Pool storage _pool = pools[_poolId];
        Stake[] memory _stakes = new Stake[](_pool.stakesNumber);
        uint256 _counter = 0;
        for (uint i = 0; i < _pool.stakesNumber; i++) {
            Stake storage _stake = pools[_poolId].stakes[i];
            if (_stake.owner == _owner) {
                _stakes[_counter].id = _stake.id;
                _stakes[_counter].owner = _stake.owner;
                _stakes[_counter].amount = _stake.amount;
                _stakes[_counter].period = _stake.period;
                _stakes[_counter].createdTime = _stake.createdTime;
                _stakes[_counter].isUnstaked = _stake.isUnstaked;
                _counter++;
            }
        }
        return _stakes;
    }

    receive() external payable {}
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