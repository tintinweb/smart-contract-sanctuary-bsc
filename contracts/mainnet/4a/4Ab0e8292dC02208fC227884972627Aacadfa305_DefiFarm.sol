//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./IPancakeSwapRouter.sol";
import "./IPancakeSwapPair.sol";

contract DefiFarm is Ownable, ReentrancyGuard, Pausable {
    using SafeMath for uint256;

    uint256 public constant ADAY = (1 days);
    uint256 public constant STAKING_FARM_TYPE = 0;
    uint256 public constant YIELD_FARMING_FARM_TYPE = 1;
    uint256 public totalDividends;

    struct FARM {
        IPancakeSwapPair lp;
        IERC20 baseToken;
        uint256 farmType; // 0 = staking, 1 = yield farmimng
    }

    struct POOL {
        uint256 farm;
        uint256 duration;
        uint256 maxSize;
        bool live;
    }

    struct STAKE {
        uint256 startDate;
        uint256 amount;
        bool unstaked;
    }

    struct USER {
        bool activated;
        uint256 round;
        address referrer;
        mapping(uint256 => STAKE[]) stakes;
    }

    mapping(address => USER) stakers;
    address[] accounts;
    FARM[] farms;
    POOL[] pools;

    // table of apy for each poll at specific timestamp
    mapping(uint256 => mapping(uint256 => uint256)) aprs;
    // timestamps at which apy for a pool was updated
    mapping(uint256 => uint256[]) aprCheckpoints;

    modifier validatePool(uint256 _pool) {
        require(_pool < pools.length, "invalid pool id");
        _;
    }

    constructor(address _pcsRouter) Ownable() {}

    function createFarm(
        address lp,
        address _baseToken,
        uint256 _type
    ) external onlyOwner returns (uint256) {
        require(
            lp != address(0) && _baseToken != address(0),
            "invalid address"
        );
        if (_type == YIELD_FARMING_FARM_TYPE) {
            require(lp != _baseToken, "invalid lp or base token address");
        }

        farms.push(FARM(IPancakeSwapPair(lp), IERC20(_baseToken), _type));

        emit FARMCREATED(lp, _baseToken, _type);

        return farms.length - 1;
    }

    function updateFarm(
        uint256 _farm,
        address lp,
        address _baseToken
    ) external onlyOwner returns (uint256) {
        require(
            lp != address(0) && _baseToken != address(0),
            "invalid address"
        );
        farms[_farm].lp = IPancakeSwapPair(lp);
        farms[_farm].baseToken = IERC20(_baseToken);

        emit FARMUPDATED(_farm, lp, _baseToken);

        return farms.length - 1;
    }

    function _isLPFarm(uint256 _farm) internal view returns (bool) {
        require(_farm < farms.length, "invalid farm id");
        return farms[_farm].farmType == YIELD_FARMING_FARM_TYPE;
    }

    function createPool(
        uint256 _farm,
        uint256 _apr,
        uint256 _duration,
        uint256 _maxSize,
        bool _live
    ) external onlyOwner returns (uint256) {
        require(_farm >= 0 && _farm < farms.length, "invalid farm index");
        pools.push(POOL(_farm, _duration, _maxSize, _live));
        aprs[pools.length - 1][block.timestamp] = _apr;
        aprCheckpoints[pools.length - 1].push(block.timestamp);

        emit POOLCREATED(_farm, _apr, _duration, _maxSize, _live);

        return pools.length - 1;
    }

    function changePoolStatus(uint256 _pool, bool _status)
        external
        onlyOwner
        validatePool(_pool)
    {
        pools[_pool].live = _status;
    }

    function changeApr(uint256 _pool, uint256 _apr)
        external
        onlyOwner
        validatePool(_pool)
    {
        require(_apr > 0, "invalid APR");

        aprs[_pool][block.timestamp] = _apr;
        aprCheckpoints[_pool].push(block.timestamp);
    }

    function _getApr(uint256 _pool, uint256 _timestamp)
        internal
        view
        validatePool(_pool)
        returns (uint256)
    {
        uint256 checkpoint = aprCheckpoints[_pool][
            getAprCheckpointIndex(_pool, _timestamp)
        ];
        return aprs[_pool][checkpoint];
    }

    function getAprCheckpointIndex(uint256 _pool, uint256 _timestamp)
        internal
        view
        returns (uint256)
    {
        for (uint256 i = aprCheckpoints[_pool].length - 1; i >= 0; i++) {
            if (aprCheckpoints[_pool][i] <= _timestamp) {
                return i;
            }
        }

        return aprCheckpoints[_pool].length - 1;
    }

    function stake(
        address _referrer,
        uint256 _amount,
        uint256 _pool
    ) external {
        POOL storage pool = pools[_pool];
        FARM storage farm = farms[pool.farm];
        require(pool.live, "pool is not active");
        require(
            farm.lp.balanceOf(msg.sender) >= _amount,
            "insufficient balance"
        );

        if (!stakers[msg.sender].activated) {
            stakers[msg.sender].activated = true;
            if (_referrer != msg.sender && stakers[_referrer].activated) {
                stakers[msg.sender].referrer = _referrer;
            }
            accounts.push(msg.sender);
        }

        if (_isLPFarm(pool.farm)) {
            farm.lp.transferFrom(msg.sender, address(this), _amount);
        } else {
            farm.baseToken.transferFrom(msg.sender, address(this), _amount);
        }
        stakers[msg.sender].stakes[_pool].push(
            STAKE(block.timestamp, _amount, false)
        );
        emit STAKED(msg.sender, _amount, _pool);
    }

    function unstake(uint256 _pool, uint256 _index) external {
        require(
            stakers[msg.sender].stakes[_pool].length > _index,
            "invalid index"
        );
        require(
            !stakers[msg.sender].stakes[_pool][_index].unstaked,
            "unstaked"
        );

        uint256 dueDate = stakers[msg.sender]
            .stakes[_pool][_index]
            .startDate
            .add(pools[_pool].duration.mul(ADAY));

        if (dueDate <= block.timestamp) {
            uint256 profit = _unclaimedReward(msg.sender, _pool, _index);
            farms[pools[_pool].farm].baseToken.transfer(msg.sender, profit);
            if (stakers[msg.sender].referrer != address(0)) {
                farms[pools[_pool].farm].baseToken.transfer(
                    stakers[msg.sender].referrer,
                    profit.div(10)
                );
                emit REFERRALPROFITRECEIVED(stakers[msg.sender].referrer, msg.sender, profit.div(10));
            }

            emit PROFITRECEIVED(msg.sender, _pool, profit);
        }

        POOL storage pool = pools[_pool];
        FARM storage farm = farms[pool.farm];
        uint256 amount = stakers[msg.sender].stakes[_pool][_index].amount;
        stakers[msg.sender].stakes[_pool][_index].unstaked = true;
        farm.lp.transfer(msg.sender, amount);
    }

    function _unclaimedReward(
        address _account,
        uint256 _pool,
        uint256 _index
    ) internal view validatePool(_pool) returns (uint256) {

        if (stakers[_account].stakes[_pool][_index].unstaked) {
            return 0;
        }
        uint256 amountStaked = stakers[_account].stakes[_pool][_index].amount;

        if (_isLPFarm(pools[_pool].farm)) {
            IPancakeSwapPair pair = IPancakeSwapPair(
                farms[pools[_pool].farm].lp
            );
            (uint256 res0, uint256 res1, ) = pair.getReserves();
            if (address(farms[pools[_pool].farm].baseToken) == pair.token0()) {
                amountStaked = amountStaked.mul(res0).mul(2).div(
                    pair.totalSupply()
                );
            } else {
                amountStaked = amountStaked.mul(res1).mul(2).div(
                    pair.totalSupply()
                );
            }
        }

        uint256 start = stakers[_account].stakes[_pool][_index].startDate;
        uint256 end = block.timestamp;
        uint256 gap = end.sub(start);
        uint256 rioPercent = _getApr(_pool, start);
        uint256 returnPerDay = rioPercent.mul(1000).div(356);
        return amountStaked.mul(gap).mul(returnPerDay).div(ADAY.mul(100000));
    }

    function unrealisedProfit(uint256 _pool) external view returns (uint256) {
        uint256 reward;
        for (
            uint256 index = 0;
            index < stakers[msg.sender].stakes[_pool].length;
            index++
        ) {
            reward = reward.add(_unclaimedReward(msg.sender, _pool, index));
        }

        return reward;
    }

    function stakeCount(address _account, uint256 _pool)
        external
        view
        validatePool(_pool)
        returns (uint256)
    {
        return stakers[_account].stakes[_pool].length;
    }

    function stakeInfo(
        address _account,
        uint256 _pool,
        uint256 _index
    )
        external
        view
        validatePool(_pool)
        returns (
            uint256 startDate,
            uint256 amount,
            bool unstaked,
            uint256 apr
        )
    {
        STAKE[] memory stakes = stakers[_account].stakes[_pool];
        require(stakes.length > _index, "invalid index");

        startDate = stakes[_index].startDate;
        amount = stakes[_index].amount;
        unstaked = stakes[_index].unstaked;
        uint256 start = stakers[_account].stakes[_pool][_index].startDate;
        apr = _getApr(_pool, start);
    }

    function farmSize(address _account, uint256 _pool)
        external
        view
        validatePool(_pool)
        returns (uint256 amount)
    {
        for (uint256 i = 0; i < stakers[_account].stakes[_pool].length; i++) {
            if (stakers[_account].stakes[_pool][i].unstaked) {
                continue;
            }
            amount = amount.add(stakers[_account].stakes[_pool][i].amount);
        }
    }

    function farmCount() public view returns (uint256) {
        return farms.length;
    }

    function poolCount() public view returns (uint256) {
        return pools.length;
    }

    function getFarmInfo(uint256 index)
        public
        view
        returns (
            address lp,
            address baseToken,
            bool isLPFarm
        )
    {
        require(index >= 0 && index < farms.length, "invalid farm index");
        lp = address(farms[index].lp);
        baseToken = address(farms[index].baseToken);
        isLPFarm = _isLPFarm(index);
    }

    function getPoolInfo(uint256 index)
        public
        view
        returns (
            uint256 farm,
            uint256 apr,
            uint256 duration,
            uint256 maxSize,
            bool live
        )
    {
        require(index >= 0 && index < pools.length, "invalid pool index");
        farm = pools[index].farm;
        apr = _getApr(index, block.timestamp);
        duration = pools[index].duration;
        maxSize = pools[index].maxSize;
        live = pools[index].live;
    }

    function accountsCount() external view returns(uint256) {
        return accounts.length;
    }

    function getAddress(uint256 _index) external view returns (address) {
        require(_index < accounts.length, 'index out of range');
        return accounts[_index];
    }

    // allow admin to retrieve trapped funds
    function retrieveTrappedFunds(address payable _account, uint256 _amount) onlyOwner public {
        _account.transfer(_amount);
    }
    
    function retrieveTrappedTokens(address payable _account, address _tokenContract, uint256 _amount) onlyOwner public returns (bool) {
        IERC20 token = IERC20(_tokenContract);
        return token.transfer(_account, _amount);
    }

    event FARMCREATED(address lp, address baseToken, uint256 farmType);
    event FARMUPDATED(uint256 farm, address lp, address baseToken);
    event POOLCREATED(
        uint256 indexed farm,
        uint256 apy,
        uint256 duration,
        uint256 maxSize,
        bool live
    );
    event STAKED(address indexed staker, uint256 amount, uint256 pool);
    event UNSTAKED(address indexed staker, uint256 tokens, uint256 pool);
    event PROFITRECEIVED(
        address indexed account,
        uint256 indexed pool,
        uint256 amount
    );
    event REFERRALPROFITRECEIVED(
        address indexed account,
        address from,
        uint256 amount
    );
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

//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.12;

interface IPancakeSwapRouter{
		function factory() external pure returns (address);
		function WETH() external pure returns (address);

		function addLiquidity(
				address tokenA,
				address tokenB,
				uint amountADesired,
				uint amountBDesired,
				uint amountAMin,
				uint amountBMin,
				address to,
				uint deadline
		) external returns (uint amountA, uint amountB, uint liquidity);
		function addLiquidityETH(
				address token,
				uint amountTokenDesired,
				uint amountTokenMin,
				uint amountETHMin,
				address to,
				uint deadline
		) external payable returns (uint amountToken, uint amountETH, uint liquidity);
		function removeLiquidity(
				address tokenA,
				address tokenB,
				uint liquidity,
				uint amountAMin,
				uint amountBMin,
				address to,
				uint deadline
		) external returns (uint amountA, uint amountB);
		function removeLiquidityETH(
				address token,
				uint liquidity,
				uint amountTokenMin,
				uint amountETHMin,
				address to,
				uint deadline
		) external returns (uint amountToken, uint amountETH);
		function removeLiquidityWithPermit(
				address tokenA,
				address tokenB,
				uint liquidity,
				uint amountAMin,
				uint amountBMin,
				address to,
				uint deadline,
				bool approveMax, uint8 v, bytes32 r, bytes32 s
		) external returns (uint amountA, uint amountB);
		function removeLiquidityETHWithPermit(
				address token,
				uint liquidity,
				uint amountTokenMin,
				uint amountETHMin,
				address to,
				uint deadline,
				bool approveMax, uint8 v, bytes32 r, bytes32 s
		) external returns (uint amountToken, uint amountETH);
		function swapExactTokensForTokens(
				uint amountIn,
				uint amountOutMin,
				address[] calldata path,
				address to,
				uint deadline
		) external returns (uint[] memory amounts);
		function swapTokensForExactTokens(
				uint amountOut,
				uint amountInMax,
				address[] calldata path,
				address to,
				uint deadline
		) external returns (uint[] memory amounts);
		function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
				external
				payable
				returns (uint[] memory amounts);
		function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
				external
				returns (uint[] memory amounts);
		function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
				external
				returns (uint[] memory amounts);
		function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
				external
				payable
				returns (uint[] memory amounts);

		function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
		function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
		function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
		function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
		function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
		function removeLiquidityETHSupportingFeeOnTransferTokens(
			address token,
			uint liquidity,
			uint amountTokenMin,
			uint amountETHMin,
			address to,
			uint deadline
		) external returns (uint amountETH);
		function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
			address token,
			uint liquidity,
			uint amountTokenMin,
			uint amountETHMin,
			address to,
			uint deadline,
			bool approveMax, uint8 v, bytes32 r, bytes32 s
		) external returns (uint amountETH);
	
		function swapExactTokensForTokensSupportingFeeOnTransferTokens(
			uint amountIn,
			uint amountOutMin,
			address[] calldata path,
			address to,
			uint deadline
		) external;
		function swapExactETHForTokensSupportingFeeOnTransferTokens(
			uint amountOutMin,
			address[] calldata path,
			address to,
			uint deadline
		) external payable;
		function swapExactTokensForETHSupportingFeeOnTransferTokens(
			uint amountIn,
			uint amountOutMin,
			address[] calldata path,
			address to,
			uint deadline
		) external;
}

//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.12;

interface IPancakeSwapPair {
		event Approval(address indexed owner, address indexed spender, uint value);
		event Transfer(address indexed from, address indexed to, uint value);

		function name() external pure returns (string memory);
		function symbol() external pure returns (string memory);
		function decimals() external pure returns (uint8);
		function totalSupply() external view returns (uint);
		function balanceOf(address owner) external view returns (uint);
		function allowance(address owner, address spender) external view returns (uint);

		function approve(address spender, uint value) external returns (bool);
		function transfer(address to, uint value) external returns (bool);
		function transferFrom(address from, address to, uint value) external returns (bool);

		function DOMAIN_SEPARATOR() external view returns (bytes32);
		function PERMIT_TYPEHASH() external pure returns (bytes32);
		function nonces(address owner) external view returns (uint);

		function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

		event Mint(address indexed sender, uint amount0, uint amount1);
		event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
		event Swap(
				address indexed sender,
				uint amount0In,
				uint amount1In,
				uint amount0Out,
				uint amount1Out,
				address indexed to
		);
		event Sync(uint112 reserve0, uint112 reserve1);

		function MINIMUM_LIQUIDITY() external pure returns (uint);
		function factory() external view returns (address);
		function token0() external view returns (address);
		function token1() external view returns (address);
		function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
		function price0CumulativeLast() external view returns (uint);
		function price1CumulativeLast() external view returns (uint);
		function kLast() external view returns (uint);

		function mint(address to) external returns (uint liquidity);
		function burn(address to) external returns (uint amount0, uint amount1);
		function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
		function skim(address to) external;
		function sync() external;

		function initialize(address, address) external;
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