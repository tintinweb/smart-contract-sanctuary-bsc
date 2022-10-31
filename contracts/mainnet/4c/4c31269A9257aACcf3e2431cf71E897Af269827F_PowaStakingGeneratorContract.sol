/**
 *Submitted for verification at BscScan.com on 2022-10-31
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: @openzeppelin/contracts/utils/math/SignedSafeMath.sol


// OpenZeppelin Contracts v4.4.1 (utils/math/SignedSafeMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SignedSafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SignedSafeMath {
    /**
     * @dev Returns the multiplication of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two signed integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        return a / b;
    }

    /**
     * @dev Returns the subtraction of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        return a - b;
    }

    /**
     * @dev Returns the addition of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        return a + b;
    }
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


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

// File: PowaDAP Staking/Powa Staking.sol

/*

PowaDAP - Staking Pool Generator V1

Powabit Ecosystem - Decentralized Services and Apps
https://powabit.com

*/


pragma solidity >=0.8.7 <0.9.0;

interface IERC20 {
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount) external returns (bool);
}

struct Staking {
    address WALLET;
    uint256 STAKING_POOL;
    uint256 START;
    uint256 SLOTS;
    bool    LOCKED;
}

struct Pool {
    uint256 ID;
    address COIN_A;
    address COIN_B;
    uint256 SLOTS;
    uint256 LOCK_DURATION_IN_DAY;
    uint256 QUANTITY_OF_COIN_A_PER_SLOT;
    uint256 QUANTITY_OF_COIN_B_REWARDABLE_PER_SLOT;
    uint256 SLOTS_USED;
    uint256 SLOTS_FINISHED;
    uint256 MAX_NUMBER_OF_SLOTS_PER_STAKER;
    uint256 TSV;
    uint256 TVL;
    uint256 LIQUIDITY;
    bool    ENABLED;
    bool    STAKABLE;
    mapping(address => Staking) _stakers;
    uint256 _stakersCount;
    address OWNER;
    bool BLACKLISTED;
}

struct PoolInformation {
    uint256 ID;
    address COIN_A;
    address COIN_B;
    uint256 SLOTS;
    uint256 LOCK_DURATION_IN_DAY;
    uint256 QUANTITY_OF_COIN_A_PER_SLOT;
    uint256 QUANTITY_OF_COIN_B_REWARDABLE_PER_SLOT;
    uint256 SLOTS_USED;
    uint256 SLOTS_FINISHED;
    uint256 MAX_NUMBER_OF_SLOTS_PER_STAKER;
    uint256 TSV;
    uint256 TVL;
    uint256 LIQUIDITY;
    bool    ENABLED;
    bool    STAKABLE;
    uint256 STACKER_COUNT;
    address OWNER;
    bool BLACKLISTED;
}


contract PowaStakingGeneratorContract is ReentrancyGuard {

    using SafeMath for uint256;
    using SignedSafeMath for int256;


    /*
    ** contract version
    */
    uint256 public constant _version = 1;

    /*
    ** excluded contracts mapping
    */
    mapping(address => bool) private _excludedContracts;

    /*
    ** owner of the contract to add/remove Pools into the staking contract
    */
    address private _owner;

    /*
    ** pool creation service fee receiver
    */
    address public _feeReceiver;

    /*
    ** List of staking pools
    */
    mapping(uint256 => Pool) private _pools;
    uint256 private _poolsCount;

    /*
    ** created pools for user
    */
    mapping(address => uint256[]) private _createdPoolsForUser;

    /*
    ** participating pools for user
    */
    mapping(address => uint256[]) private _participatingHistoryPoolsForUser;

    /*
    ** Pool Creation Cost
    */
    uint256 private _poolCreationServicePrice;

    /*
    ** Stacking Contract Paused for maintenance
    */
    bool public _stakingContractPaused;

    /*
    ** Stacking Creation Allowed
    */
    bool public _stackingCreationAllowed;

    event PoolCreated(uint256 ID, address LOCK_COIN, address EARN_COIN);

    constructor() {
        _owner = msg.sender;
        _feeReceiver = _owner;
        _poolsCount = 1;
        _poolCreationServicePrice = 1 * (10 ** uint256(18)); // Default: 1 BNB
        _stackingCreationAllowed = false;
        _stakingContractPaused = false;
    }


    //MODIFIERS

    /*
    ** @dev Check that the transaction sender is the Contract owner
    */
    modifier onlyContractOwner() {
        require(msg.sender == _owner, "Only owner");
        _;
    }

    /*
    ** @dev Check that the transaction sender is the Contract owner or pool Owner
    */
    modifier onlyPoolOwner(uint256 poolId) {
        Pool storage pool = _pools[poolId];

        require(msg.sender == pool.OWNER || msg.sender == _owner, "Only owner");
        _;
    }

    /*
    ** @dev Check if Staking contract is paused
    */
    modifier isStakingContractPaused() {
        require(_stakingContractPaused == false, "Staking contract paused");
        _;
    }


    //PUBLIC GETTERS ACTIONS

    function getOwner() public view returns (address) {
        return _owner;
    }

    function getPoolsLength() public view returns (uint256) {
        return _poolsCount;
    }

    function getPoolCreationServicePrice() public view returns (uint256) {
        return _poolCreationServicePrice;
    }

    function getPool(uint256 poolId) public view returns (PoolInformation memory) {
        PoolInformation memory result;
        Pool storage pool = _pools[poolId];

        result.ID = pool.ID;
        result.COIN_A = pool.COIN_A;
        result.COIN_B = pool.COIN_B;
        result.SLOTS = pool.SLOTS;
        result.LOCK_DURATION_IN_DAY = pool.LOCK_DURATION_IN_DAY;
        result.QUANTITY_OF_COIN_A_PER_SLOT = pool.QUANTITY_OF_COIN_A_PER_SLOT;
        result.QUANTITY_OF_COIN_B_REWARDABLE_PER_SLOT = pool.QUANTITY_OF_COIN_B_REWARDABLE_PER_SLOT;
        result.SLOTS_USED = pool.SLOTS_USED;
        result.SLOTS_FINISHED = pool.SLOTS_FINISHED;
        result.MAX_NUMBER_OF_SLOTS_PER_STAKER = pool.MAX_NUMBER_OF_SLOTS_PER_STAKER;
        result.TSV = pool.TSV;
        result.TVL = pool.TVL;
        result.LIQUIDITY = pool.LIQUIDITY;
        result.ENABLED = pool.ENABLED;
        result.STAKABLE = pool.STAKABLE;
        result.STACKER_COUNT = pool._stakersCount;
        result.OWNER = pool.OWNER;
        result.BLACKLISTED = pool.BLACKLISTED;

        return result;
    }

    function isExcludedContract(address wallet) public view returns (bool) {
        return _excludedContracts[wallet];
    }

    function getPoolStaker(uint256 poolId, address wallet) public view returns (Staking memory) {
        Staking memory result;
        Pool storage pool = _pools[poolId];
        Staking storage staker = pool._stakers[wallet];

        result.WALLET = staker.WALLET;
        result.STAKING_POOL = staker.STAKING_POOL;
        result.START = staker.START;
        result.SLOTS = staker.SLOTS;
        result.LOCKED = staker.LOCKED;
        return result;
    }

    function getPools(int256 page, int256 pageSize) public view returns (PoolInformation[] memory) {
        uint256 poolLength = getPoolsLength();
        int256 queryStartPoolIndex = int256(poolLength).sub(pageSize.mul(page)).add(pageSize).sub(1);
        require(queryStartPoolIndex >= 0, "Out of bounds");
        int256 queryEndPoolIndex = queryStartPoolIndex.sub(pageSize);
        if (queryEndPoolIndex < 0) {
            queryEndPoolIndex = 0;
        }
        int256 currentPoolIndex = queryStartPoolIndex;
        require(uint256(currentPoolIndex) <= poolLength.sub(1), "Out of bounds");
        PoolInformation[] memory results = new PoolInformation[](uint256(currentPoolIndex - queryEndPoolIndex));
        uint256 index = 0;

        for (currentPoolIndex; currentPoolIndex > queryEndPoolIndex; currentPoolIndex--) {
            uint256 currentVerificationIndexAsUnsigned = uint256(currentPoolIndex);
            if (currentVerificationIndexAsUnsigned <= poolLength.sub(1)) {
                results[index] = getPool(currentVerificationIndexAsUnsigned);
            }
            index++;
        }
        return results;
    }

    function getPoolsOfUserLength(address wallet) public view returns (uint256){
        return _createdPoolsForUser[wallet].length;
    }

    function getPoolsOfUser(address wallet, uint256 arIndex, uint256 arEnd) public view returns (PoolInformation[] memory) {
        uint256 poolLength = _createdPoolsForUser[wallet].length;
        if (arEnd<poolLength){
            poolLength = arEnd;
        }

        PoolInformation[] memory results = new PoolInformation[](uint256(poolLength-arIndex));
        uint256 index = 0;
        uint256 current = arIndex;

        for (current; current < poolLength; current++) {
            uint256 currentVerificationIndexAsUnsigned = _createdPoolsForUser[wallet][current];
            results[index] = getPool(currentVerificationIndexAsUnsigned);
            index++;
        }
        return results;
    }

    function getParticipatingHistoryPoolsOfUserLength(address wallet) public view returns (uint256){
        return _participatingHistoryPoolsForUser[wallet].length;
    }

    function getParticipatingHistoryPoolsOfUser(address wallet, uint256 arIndex, uint256 arEnd) public view returns (PoolInformation[] memory) {
        uint256 poolLength = _participatingHistoryPoolsForUser[wallet].length;
       if (arEnd<poolLength){
            poolLength = arEnd;
        }

        PoolInformation[] memory results = new PoolInformation[](uint256(poolLength-arIndex));
        uint256 index = 0;
        uint256 current = arIndex;

        for (current; current < poolLength; current++) {
            uint256 currentVerificationIndexAsUnsigned = _participatingHistoryPoolsForUser[wallet][current];
            results[index] = getPool(currentVerificationIndexAsUnsigned);
            index++;
        }
        return results;
    }


    //PUBLIC SETTERS ACTIONS

    /*
    ** deposit 100000 POWA (5% in USDT) = ((1000 * 5 / 100) / 365) * lockDurationInDay = (slot rewards when the unlock date is finished in POWA)
    ** createPool(0x, 0x, coinRatio = 1000, slots = 100, lockDurationInDay = 30, 0.03 ** 18);
    */
    function createPool(address coinA, address coinB, uint256 slots, uint256 lockDurationInDay, uint256 quantityOfCoinAPerSlot, uint256 quantityOfCoinBRewardablePerSlot, uint256 maxNumberOfSlotsPerStaker) public payable nonReentrant isStakingContractPaused {

        require(msg.sender == tx.origin || _excludedContracts[msg.sender],
            "Only EOA or Whitelist allowed"
        );

        require(coinA != address(0) && coinB != address(0),
            "Arguments not allowed"
        );

        require(_stackingCreationAllowed || msg.sender == _owner,
            "Staking creation not allowed"
        );

        require(msg.value >= _poolCreationServicePrice || msg.sender == _owner,
            "Cost of pool creation not received"
        );

        require(quantityOfCoinBRewardablePerSlot > 0
            && quantityOfCoinAPerSlot > 0
            && slots > 0,
            "Arguments not allowed"
        );

        require(IERC20(coinA).decimals() == IERC20(coinB).decimals(),
            "Only equals Decimals"
        );

        uint256 quantityOfCoinB = quantityOfCoinBRewardablePerSlot.mul(slots);

        require(IERC20(coinB).transferFrom(msg.sender, address(this), quantityOfCoinB) == true,
            "Balance Coin B empty"
        );

        uint256 index = _poolsCount++;
        Pool storage pool = _pools[index];

        pool.TVL = 0;
        pool.TSV = 0;
        pool.ID = index;
        pool.COIN_A = coinA;
        pool.COIN_B = coinB;
        pool.SLOTS = slots;
        pool.LOCK_DURATION_IN_DAY = lockDurationInDay;
        pool.QUANTITY_OF_COIN_A_PER_SLOT = quantityOfCoinAPerSlot;
        pool.QUANTITY_OF_COIN_B_REWARDABLE_PER_SLOT = quantityOfCoinBRewardablePerSlot;
        pool.SLOTS_USED = 0;
        pool.SLOTS_FINISHED = 0;
        pool.MAX_NUMBER_OF_SLOTS_PER_STAKER = maxNumberOfSlotsPerStaker;
        pool.LIQUIDITY = quantityOfCoinB;
        pool.ENABLED = true;
        pool.STAKABLE = true;
        pool.OWNER = msg.sender;
        pool.BLACKLISTED = false;

        _createdPoolsForUser[msg.sender].push(index);

        if(msg.sender != _owner){
            payable(_feeReceiver).transfer(msg.value);
        }

        emit PoolCreated(pool.ID, pool.COIN_A, pool.COIN_B);
    }

    /*
    ** Stake coins in the staking contract.
    */
    function stake(uint256 poolId, uint256 slots, bool lock) public nonReentrant isStakingContractPaused {
        Pool storage pool = _pools[poolId];

        require(msg.sender == tx.origin || _excludedContracts[msg.sender],
            "Only EOA or Whitelist allowed"
        );

        require(pool.BLACKLISTED == false,
            "Pool blacklisted"
        );

        require(slots > 0,
            "Arguments not allowed"
        );
        require(pool.STAKABLE == true,
            "Pool unstakable"
        );
        require(
            pool.ENABLED == true,
            "Pool disabled"
        );
        require(
            slots <= pool.MAX_NUMBER_OF_SLOTS_PER_STAKER,
            "Slots limit exceeded"
        );
        require(pool.SLOTS_USED.add(pool.SLOTS_FINISHED).add(slots) <= pool.SLOTS,
            "Pool is fully filled"
        );
        require(
            pool._stakers[msg.sender].WALLET != msg.sender,
            "Slot already taken"
        );
        uint256 participationAmount = pool.QUANTITY_OF_COIN_A_PER_SLOT.mul(slots);

        require(IERC20(pool.COIN_A).transferFrom(msg.sender, address(this), participationAmount) == true,
            "Balance Coin A empty"
        );

        if (lock) {
            pool.TVL += participationAmount;
        }
        pool.SLOTS_USED += slots;
        pool.TSV += participationAmount;
        pool._stakersCount += 1;
        pool._stakers[msg.sender].WALLET = msg.sender;
        pool._stakers[msg.sender].SLOTS = slots;
        pool._stakers[msg.sender].START = block.timestamp;
        pool._stakers[msg.sender].LOCKED = lock;

        _participatingHistoryPoolsForUser[msg.sender].push(poolId);
    }

    /*
    ** UnStake coins in the staking contract optionnal claimable.
    */
    function unStake(uint256 poolId, bool claim) public nonReentrant isStakingContractPaused{
        Pool storage pool = _pools[poolId];
        Staking storage staker = pool._stakers[msg.sender];

        require(msg.sender == tx.origin || _excludedContracts[msg.sender],
            "Only EOA or Whitelist allowed"
        );

        require(
            staker.WALLET == msg.sender,
            "No stake"
        );
        bool lockDurationIsExceeded = staker.START.add(86400 * pool.LOCK_DURATION_IN_DAY) <= block.timestamp;

        require(
            staker.LOCKED == false || lockDurationIsExceeded,
            "Stake locked"
        );

        uint256 stakerSlots = staker.SLOTS;

        uint256 stakedAmount = pool.QUANTITY_OF_COIN_A_PER_SLOT.mul(stakerSlots);

        if (staker.LOCKED) {
            staker.LOCKED = false;
            pool.TVL -= stakedAmount;
        }
        pool.TSV -= stakedAmount;
        pool.SLOTS_USED -= staker.SLOTS;
        pool._stakersCount -= 1;
        staker.WALLET = 0x0000000000000000000000000000000000000000;
        staker.START = 0;
        staker.SLOTS = 0;

        require(IERC20(pool.COIN_A).transfer(msg.sender, stakedAmount) == true,
            "Balance Coin A empty"
        );
        if (claim == true && lockDurationIsExceeded && pool.BLACKLISTED == false) {
            uint256 rewardAmount = pool.QUANTITY_OF_COIN_B_REWARDABLE_PER_SLOT.mul(stakerSlots);

            require(IERC20(pool.COIN_B).transfer(msg.sender, rewardAmount) == true,
                "Balance Coin B empty"
            );
            pool.SLOTS_FINISHED += stakerSlots;
            pool.LIQUIDITY -= rewardAmount;
        }

    }


    //POOL MANAGER ACTIONS

    /*
    ** @dev Add pool Slots only for the pool owner.
    */
    function setPoolMaxNumberOfSlotsPerStaker(uint256 poolId, uint256 maxNumberOfSlotsPerStaker) public onlyPoolOwner(poolId) isStakingContractPaused {
        Pool storage pool = _pools[poolId];

        require(pool.BLACKLISTED == false || msg.sender == _owner,
            "Pool blacklisted"
        );

        require(
            pool.ENABLED == true,
            "Pool disabled"
        );
        require(
            maxNumberOfSlotsPerStaker > 0,
            "Arguments not allowed"
        );
        require(
            maxNumberOfSlotsPerStaker <= pool.SLOTS,
            "Slots limit exceeded"
        );
        pool.MAX_NUMBER_OF_SLOTS_PER_STAKER = maxNumberOfSlotsPerStaker;
    }

    /*
    ** @dev Add pool Slots only for the pool owner.
    */
    function addPoolSlots(uint256 poolId, uint256 slots) public onlyPoolOwner(poolId) isStakingContractPaused {
        Pool storage pool = _pools[poolId];

        require(pool.BLACKLISTED == false || msg.sender == _owner,
            "Pool blacklisted"
        );

        require(
            pool.ENABLED == true,
            "Pool disabled"
        );
        require(slots > 0,
            "Arguments not allowed"
        );
        uint256 quantityOfCoinB = pool.QUANTITY_OF_COIN_B_REWARDABLE_PER_SLOT.mul(slots);

        require(IERC20(pool.COIN_B).transferFrom(msg.sender, address(this), quantityOfCoinB) == true,
            "Balance Coin B empty"
        );

        pool.SLOTS += slots;
        pool.LIQUIDITY += quantityOfCoinB;
    }

    /*
    ** @dev Disabling pool if slots is empty only the pool owner can disable.
    */
    function disablePool(uint256 poolId) public onlyPoolOwner(poolId) isStakingContractPaused {
        Pool storage pool = _pools[poolId];

        require(pool.BLACKLISTED == false || msg.sender == _owner,
            "Pool blacklisted"
        );

        require(
            pool.ENABLED == true,
            "Pool disabled"
        );
        pool.ENABLED = false;
        pool.STAKABLE = false;
    }

    /*
    ** @dev Unused tokens recovery function of the pool deactivated.
    ** Can be called by the contract owner, but the funds go only to the pool creator.
    ** The pool must be deactivated beforehand.
    */
    function takeRemainingPool(uint256 poolId) public onlyPoolOwner(poolId) isStakingContractPaused {
        Pool storage pool = _pools[poolId];

        require(pool.BLACKLISTED == false || msg.sender == _owner,
            "Pool blacklisted"
        );

        require(
            pool.ENABLED == false,
            "Pool disabled"
        );
        IERC20 coinB = IERC20(pool.COIN_B);
        uint256 balance = coinB.balanceOf(address(this));
        uint256 poolRemainingSlots = pool.SLOTS.sub(pool.SLOTS_FINISHED).sub(pool.SLOTS_USED);
        uint256 poolRemainingAmount = pool.QUANTITY_OF_COIN_B_REWARDABLE_PER_SLOT.mul(poolRemainingSlots);

        pool.SLOTS = pool.SLOTS_FINISHED.add(pool.SLOTS_USED);
        if (balance >= poolRemainingAmount) {
            require(coinB.transfer(pool.OWNER, poolRemainingAmount) == true, "Error transfer");
            pool.LIQUIDITY -= poolRemainingAmount;
        }
    }

    /*
    ** @dev Enable stakes in pool only for pool owner.
    */
    function enablePoolStakes(uint256 poolId) public onlyPoolOwner(poolId) isStakingContractPaused {
        Pool storage pool = _pools[poolId];

        require(pool.BLACKLISTED == false || msg.sender == _owner,
            "Pool blacklisted"
        );

        require(
            pool.ENABLED == true,
            "Pool disabled"
        );
        require(
            pool.STAKABLE == false,
            "Pool STAKABLE err"
        );

        pool.STAKABLE = true;
    }

    /*
    ** @dev Disable stakes in pool only for pool owner.
    */
    function disablePoolStakes(uint256 poolId) public onlyPoolOwner(poolId) isStakingContractPaused {
        Pool storage pool = _pools[poolId];

        require(pool.BLACKLISTED == false || msg.sender == _owner,
            "Pool blacklisted"
        );

        require(
            pool.ENABLED == true,
            "Pool disabled"
        );
        require(
            pool.STAKABLE == true,
            "Pool STAKABLE err"
        );

        pool.STAKABLE = false;
    }

    /*
    ** @dev Unlock Staker option if necessary.
    */
    function unlockStaker(uint256 poolId, address stakerAddress) public onlyPoolOwner(poolId) isStakingContractPaused {
        Pool storage pool = _pools[poolId];
        Staking storage staker = pool._stakers[stakerAddress];

        require(
            staker.WALLET == stakerAddress,
            "No stake"
        );
        staker.LOCKED = false;
    }


    //CONTRACT ADMIN ACTIONS

    function setStateCreationState(bool state) public onlyContractOwner {
        _stackingCreationAllowed = state;
    }

    function setStakingContractPaused(bool state) public onlyContractOwner {
        _stakingContractPaused = state;
    }

    function setPoolBlacklisted(uint256 poolId, bool state) public onlyContractOwner {
        Pool storage pool = _pools[poolId];
        pool.BLACKLISTED = state;
    }

    function setPoolCreationServicePrice(uint256 cost) public onlyContractOwner {
        _poolCreationServicePrice = cost;
    }

    function setExcludedContract(address addr, bool state) public onlyContractOwner {
        _excludedContracts[addr] = state;
    }

    function changeOwner(address newOwner) public onlyContractOwner {
        _owner = newOwner;
    }

    function setFeeReceiver(address addr) public onlyContractOwner {
        _feeReceiver = addr;
    }

    /*
    ** @dev transfer natives BNB of the contract to the owner of the contract
    */
    function transferBNB(address payable _to, uint _amount) public onlyContractOwner {
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send BNB");
    }
}