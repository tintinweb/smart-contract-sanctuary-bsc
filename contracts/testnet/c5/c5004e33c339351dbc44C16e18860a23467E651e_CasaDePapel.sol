// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@interest-protocol/tokens/interfaces/InterestTokenInterface.sol";
import "@interest-protocol/library/MathLib.sol";
import "@interest-protocol/library/SafeTransferErrors.sol";
import "@interest-protocol/library/SafeTransferLib.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "./errors/CasaDePapelErrors.sol";
import "./interfaces/ICasaDePapel.sol";

import "./DataTypes.sol";

contract CasaDePapel is ICasaDePapel, Ownable, SafeTransferErrors {
    /*///////////////////////////////////////////////////////////////
                            LIBRARIES
    //////////////////////////////////////////////////////////////*/

    using SafeTransferLib for address;
    using MathLib for uint256;

    /*///////////////////////////////////////////////////////////////
                                STATE
    //////////////////////////////////////////////////////////////*/

    // Time when the minting of INT starts
    uint256 public immutable START_BLOCK;

    InterestTokenInterface private immutable INTEREST_TOKEN;

    // How many {InterestToken} to be minted per block.
    uint256 public interestTokenPerBlock;

    // Devs will receive 10% of all minted {InterestToken}.
    address public treasury;

    uint256 public treasuryBalance;

    Pool[] public pools;

    // PoolId -> User -> UserInfo.
    mapping(uint256 => mapping(address => User)) public userInfo;

    // Check if the token has a pool.
    mapping(address => bool) public hasPool;

    // Token => Id
    mapping(address => uint256) public getPoolId;

    // Total allocation points to know how much to allocate to a new pool.
    uint256 public totalAllocationPoints;

    /*///////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        address _interestToken,
        address _treasury,
        uint256 _interestTokenPerBlock,
        uint256 _startBlock
    ) {
        INTEREST_TOKEN = InterestTokenInterface(_interestToken);
        START_BLOCK = _startBlock;
        interestTokenPerBlock = _interestTokenPerBlock;
        treasury = _treasury;

        hasPool[_interestToken] = true;
        getPoolId[_interestToken] = 0;

        // Setup the first pool. Stake {InterestToken} to get {InterestToken}.
        pools.push(
            Pool({
                stakingToken: _interestToken,
                allocationPoints: 1000,
                lastRewardBlock: _startBlock,
                accruedIntPerShare: 0,
                totalSupply: 0
            })
        );

        // Update the total points allocated
        totalAllocationPoints = 1000;
    }

    /*///////////////////////////////////////////////////////////////
                            MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev It updates the current rewards accrued in all pools. It is an optional feature in many functions. If the caller wishes to do.
     *
     * @notice This is a O(n) operation, which can cost a lot of gas.
     *
     * @param update bool value representing if the `msg.sender` wishes to update all pools.
     */
    modifier updatePools(bool update) {
        if (update) {
            updateAllPools();
        }
        _;
    }

    /*///////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev It returns the total number of pools in this contract.
     *
     * @return uint256 The total number of pools
     */
    function getPoolsLength() external view returns (uint256) {
        return pools.length;
    }

    /**
     * @dev This function will help the front-end know how many rewards the user has in the pool at any given block.
     *
     * @param poolId The id of the pool we wish to find the rewards for `_user`
     * @param _user The address of the user we wish to find his/her rewards
     */
    function getUserPendingRewards(uint256 poolId, address _user)
        external
        view
        returns (uint256)
    {
        // Save global state in memory.
        Pool memory pool = pools[poolId];
        User memory user = userInfo[poolId][_user];

        uint256 accruedIntPerShare = pool.accruedIntPerShare;
        uint256 totalSupply = pool.totalSupply;

        // If there are no tokens in the pool or if the user does not have any staked tokens. We return 0.
        // Remember that rewards are always paid in withdraws.
        if (totalSupply == 0 || user.amount == 0) return 0;

        // Need to run the same logic inside the {updatePool} function to be up to date to the last block.
        // This is a view function so we cannot actually update the pool.
        if (block.number > pool.lastRewardBlock) {
            uint256 blocksElaped = block.number - pool.lastRewardBlock;
            uint256 intReward = (blocksElaped * interestTokenPerBlock).mulDiv(
                pool.allocationPoints,
                totalAllocationPoints
            );
            accruedIntPerShare =
                accruedIntPerShare +
                intReward.fdiv(totalSupply);
        }
        return user.amount.fmul(accruedIntPerShare) - user.rewardsPaid;
    }

    /*///////////////////////////////////////////////////////////////
                            MUTATIVE FUNCTION
    //////////////////////////////////////////////////////////////*/

    function mintTreasuryRewards() external {
        uint256 amount = treasuryBalance;

        treasuryBalance = 0;

        INTEREST_TOKEN.mint(treasury, amount);
    }

    /**
     * @dev This function updates the rewards for the pool with id `poolId` and mints tokens for the {devAccount}.
     *
     * @param poolId The id of the pool to be updated.
     */
    function updatePool(uint256 poolId) external {
        uint256 intReward = _updatePool(poolId);

        // There is no point to mint 0 tokens.
        if (intReward > 0) {
            // We mint an additional 10% to the devAccount.

            unchecked {
                treasuryBalance += intReward.fmul(0.1e18);
            }
        }
    }

    /**
     * @dev It updates the current rewards accrued in all pools. It is an optional feature in many functions. If the caller wishes to do.
     *
     * @notice This is a O(n) operation, which can cost a lot of gas.
     */
    function updateAllPools() public {
        uint256 length = pools.length;
        uint256 totalRewards;

        unchecked {
            for (uint256 i; i < length; i++) {
                totalRewards += _updatePool(i);
            }

            treasuryBalance += totalRewards;
        }
    }

    /**
     * @dev This function allows the `msg.sender` to deposit {INTEREST_TOKEN} and start earning more {INTEREST_TOKENS}.
     * We have a different function for this tokens because it gives a receipt token.
     *
     * @notice It also gives a receipt token {STAKED_INTEREST_TOKEN}. The receipt token will be needed to withdraw the tokens!
     *
     * @param poolId The id of the pool to stake
     * @param amount The number of {INTEREST_TOKEN} the `msg.sender` wishes to stake
     */
    function stake(uint256 poolId, uint256 amount) external {
        // Update the pool to correctly calculate the rewards in this pool.
        uint256 intReward = _updatePool(poolId);

        // Save relevant state in memory.
        Pool memory pool = pools[poolId];
        User memory user = userInfo[poolId][msg.sender];

        // Variable to store the rewards the user is entitled to get.
        uint256 pendingRewards;

        unchecked {
            // If the user does not have any staked tokens in the pool. We do not need to calculate the pending rewards.
            if (user.amount > 0) {
                // Note the base unit of {pool.accruedIntPerShare}.
                pendingRewards =
                    user.amount.fmul(pool.accruedIntPerShare) -
                    user.rewardsPaid;
            }
        }

        // Similarly to the {deposit} function, the user can simply harvest the rewards.
        if (amount > 0) {
            // Get {INTEREST_TOKEN} from the `msg.sender`.
            pool.stakingToken.safeTransferFrom(
                msg.sender,
                address(this),
                amount
            );
            pool.totalSupply += amount;
            unchecked {
                // Update the relevant state if he is depositing tokens.
                user.amount += amount;
            }
        }

        // Update the state to indicate that the user has been paid all the rewards up to this block.
        user.rewardsPaid = user.amount.fmul(pool.accruedIntPerShare);

        // Update the global state.
        pools[poolId] = pool;
        userInfo[poolId][msg.sender] = user;

        // If the user has any pending rewards. We send it to him.
        if (pendingRewards > 0) {
            INTEREST_TOKEN.mint(msg.sender, pendingRewards);
        }

        // There is no point to mint 0 tokens.
        if (intReward > 0) {
            unchecked {
                // We mint an additional 10% to the devAccount.
                treasuryBalance += intReward.fmul(0.1e18);
            }
        }

        emit Stake(msg.sender, poolId, amount);
    }

    /**
     * @dev This function is to withdraw the {INTEREST_TOKEN} from the pool.
     *
     * @notice The user must have an equivalent `amount` of {STAKED_INTEREST_TOKEN} to withdraw.
     * @notice A different user with maxed allowance and enough {STAKED_INTEREST_TOKEN} can withdraw in behalf of the `account`.
     * @notice We use Open Zeppelin version 4.5.0-rc.0 that has a {transferFrom} function that does not decrease the allowance if is the maximum uint256.
     *
     * @param poolId The id of the pool to stake
     * @param amount The number of {INTEREST_TOKEN} to withdraw to the `msg.sender`
     */
    function unstake(uint256 poolId, uint256 amount) external {
        User memory user = userInfo[poolId][msg.sender];

        if (amount > user.amount) revert CasaDePapel__UnstakeAmountTooHigh();

        // Update the pool first to properly calculate the rewards.
        uint256 intReward = _updatePool(poolId);

        // Save relevant state in memory.
        Pool memory pool = pools[poolId];

        // Calculate the pending rewards.
        uint256 pendingRewards = user.amount.fmul(pool.accruedIntPerShare) -
            user.rewardsPaid;

        // The user can opt to simply get the rewards, if he passes an `amount` of 0.
        if (amount > 0) {
            // `recipient` must have enough receipt tokens. As {STAKED_INTEREST_TOKEN}
            // totalSupply must always be equal to the `pool.totalSupply` of {INTEREST_TOKEN}.
            user.amount -= amount;
            unchecked {
                pool.totalSupply -= amount;
            }
        }

        // Update `account` rewardsPaid. `Account` has been  paid in full amount up to this block.
        user.rewardsPaid = user.amount.fmul(pool.accruedIntPerShare);
        // Update the global state.
        pools[poolId] = pool;
        userInfo[poolId][msg.sender] = user;

        if (amount > 0) {
            pool.stakingToken.safeTransfer(msg.sender, amount);
        }

        // If there are any pending rewards we {mint} for the `recipient`.
        if (pendingRewards > 0) {
            INTEREST_TOKEN.mint(msg.sender, pendingRewards);
        }

        // There is no point to mint 0 tokens.
        if (intReward > 0) {
            unchecked {
                // We mint an additional 10% to the treasury.
                treasuryBalance += intReward.fmul(0.1e18);
            }
        }

        emit Unstake(msg.sender, poolId, amount);
    }

    /**
     * @dev It allows the user to withdraw his tokens from a pool without calculating the rewards.
     *
     * @notice  This function should only be called during urgent situations. The user will lose all pending rewards.
     * @notice To withdraw {INTEREST_TOKEN}, the user still needs the equivalent `amount` in {STAKTED_INTEREST_TOKEN}.
     * @notice One single function for all tokens and {INTEREST_TOKEN}.
     *
     * @param poolId the pool that the user wishes to completely exit.
     */
    function emergencyWithdraw(uint256 poolId) external {
        // No need to save gas on an urgent function
        Pool storage pool = pools[poolId];
        User storage user = userInfo[poolId][msg.sender];

        uint256 amount = user.amount;

        // Clean user history
        user.amount = 0;
        user.rewardsPaid = 0;

        // Update the pool total supply
        pool.totalSupply -= amount;

        pool.stakingToken.safeTransfer(msg.sender, amount);

        emit EmergencyWithdraw(msg.sender, poolId, amount);
    }

    /*///////////////////////////////////////////////////////////////
                            PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev This function updates the rewards for the pool with id `poolId`.
     *
     * @param poolId The id of the pool to be updated.
     */
    function _updatePool(uint256 poolId) private returns (uint256) {
        // Save storage in memory to save gas.
        Pool memory pool = pools[poolId];

        // If the rewards have been updated up to this block. We do not need to do anything.
        if (block.number == pool.lastRewardBlock) return 0;

        // Total amount of tokens in the pool.
        uint256 amountOfStakedTokens = pool.totalSupply;

        // If the pool is empty. We simply  need to update the last block the pool was updated.
        if (amountOfStakedTokens == 0) {
            pools[poolId].lastRewardBlock = block.number;
            return 0;
        }

        // Calculate how many blocks has passed since the last block.
        uint256 blocksElapsed = block.number.uSub(pool.lastRewardBlock);

        // We calculate how many {InterestToken} this pool is rewarded up to this block.
        uint256 intReward = (blocksElapsed * interestTokenPerBlock).mulDiv(
            pool.allocationPoints,
            totalAllocationPoints
        );

        // This value stores all rewards the pool ever got.
        // Note: this variable i already per share as we divide by the `amountOfStakedTokens`.
        pool.accruedIntPerShare += intReward.fdiv(amountOfStakedTokens);

        pool.lastRewardBlock = block.number;

        // Update global state
        pools[poolId] = pool;

        emit UpdatePool(poolId, block.number, pool.accruedIntPerShare);

        return intReward;
    }

    /**
     * @dev This function updates the allocation points of the {INTEREST_TOKEN} pool rewards based on the allocation of all other pools
     */
    function _updateStakingPool() private {
        // Save global state in memory.
        uint256 _totalAllocationPoints = totalAllocationPoints;

        // Get the allocation of all pools - the {INTEREST_TOKEN} pool.
        uint256 allOtherPoolsPoints = _totalAllocationPoints -
            pools[0].allocationPoints;

        // {INTEREST_TOKEN} pool allocation points is always equal to 1/3 of all the other pools.
        // We reuse the same variable to save memory. Even though, it says allOtherPoolsPoints. At this point is the pool 0 points.
        allOtherPoolsPoints = allOtherPoolsPoints / 3;

        // Update the total allocation pools.
        _totalAllocationPoints -= pools[0].allocationPoints;
        _totalAllocationPoints += allOtherPoolsPoints;

        // Update the global state
        totalAllocationPoints = _totalAllocationPoints;
        pools[0].allocationPoints = allOtherPoolsPoints;
    }

    /*///////////////////////////////////////////////////////////////
                        ONLY OWNER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev This function allows the {owner} to update the global minting of {INTEREST_TOKEN} per block.
     *
     * @param _interestTokenPerBlock how many {INTEREST_TOKEN} tokens to be minted per block.
     *
     * Requirements:
     *
     * - The `msg.sender` must be the {owner}. As we will have a documented scheduling for {INTEREST_TOKEN} emission.
     *
     */
    function setIPXPerBlock(uint256 _interestTokenPerBlock)
        external
        onlyOwner
        updatePools(true)
    {
        interestTokenPerBlock = _interestTokenPerBlock;
        emit NewInterestTokenRatePerBlock(_interestTokenPerBlock);
    }

    /**
     * @dev It allows the {owner} to update the {treasury} address
     *
     * @param _treasury the new treasury address
     */
    function setNewTreasury(address _treasury) external onlyOwner {
        treasury = _treasury;
        emit NewTreasury(treasury);
    }

    /**
     * @dev This function adds a new pool. At the end of this function, we update the pool 0 allocation.
     *
     * @param allocationPoints How many {INTEREST_TOKEN} rewards should be allocated to this pool in relation to others.
     * @param token The address of the staking token the pool will accept.
     * @param update If the caller wishes to update all pools. Care for gas cost.
     *
     * Requirements:
     *
     * - Only supported tokens by the protocol should be allowed for the health of the ecosystem.
     *
     */
    function addPool(
        uint256 allocationPoints,
        address token,
        bool update
    ) external onlyOwner updatePools(update) {
        // Prevent the owner from adding the same token twice, which will cause a rewards problems.
        if (hasPool[token]) revert CasaDePapel__PoolAlreadyAdded();

        // If the pool is added before the start block. The last rewardBlock is the startBlock
        uint256 lastRewardBlock = block.number > START_BLOCK
            ? block.number
            : START_BLOCK;

        // Register the `token` to prevent registering the same `token` twice.
        hasPool[token] = true;

        // Update the global total allocation points
        totalAllocationPoints += allocationPoints;

        // Add the pool
        pools.push(
            Pool({
                stakingToken: token,
                allocationPoints: allocationPoints,
                lastRewardBlock: lastRewardBlock,
                accruedIntPerShare: 0,
                totalSupply: 0
            })
        );

        // Update the pool 0.
        _updateStakingPool();

        uint256 id = pools.length.uSub(1);

        getPoolId[token] = id;

        emit AddPool(token, id, allocationPoints);
    }

    /**
     * @dev This function updates the allocation points of a pool. At the end this function updates the pool 0 allocation points.
     *
     * @param poolId The index of the pool to be updated.
     * @param allocationPoints The new value for the allocation points for the pool with `poolId`.
     * @param update Option to update all pools. Care for gas cost.
     *
     * Requirements:
     *
     * - This can be used to discontinue or incentivize different pools. We need to restrict this for the health of the ecosystem.
     *
     */
    function setAllocationPoints(
        uint256 poolId,
        uint256 allocationPoints,
        bool update
    ) external onlyOwner updatePools(update) {
        uint256 prevAllocationPoints = pools[poolId].allocationPoints;

        // No need to update if the new allocation point is the same as the previous one.
        if (prevAllocationPoints == allocationPoints) return;

        // Update the allocation points
        pools[poolId].allocationPoints = allocationPoints;

        uint256 _totalAllocationPoints = totalAllocationPoints;

        // Update the state
        _totalAllocationPoints -= prevAllocationPoints;
        _totalAllocationPoints += allocationPoints;

        // Update the global state.
        totalAllocationPoints = _totalAllocationPoints;

        // update the pool 0.
        _updateStakingPool();

        emit UpdatePoolAllocationPoint(poolId, allocationPoints);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-IERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface InterestTokenInterface is IERC20PermitUpgradeable, IERC20Upgradeable {
    function MINTER_ROLE() external view returns (bytes32);

    function DEVELOPER_ROLE() external view returns (bytes32);

    function mint(address account, uint256 amount) external;

    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title Set of utility functions to perform mathematical operations.
 */
library MathLib {
    /// @notice The decimal houses of most ERC20 tokens and native tokens.
    uint256 private constant SCALAR = 1e18;

    /**
     * @notice It multiplies two fixed point numbers.
     * @dev It assumes the arguments are fixed point numbers with 18 decimal houses. It reverts if the result overflows 2**256-1. Source: https://twitter.com/transmissions11/status/1451129626432978944/photo/1
     * @param x First operand
     * @param y The second operand
     * @return z The result of multiplying x and y
     */
    function fmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// We use assembly to optimize gas consumption.
        assembly {
            if iszero(or(iszero(x), eq(div(mul(x, y), x), y))) {
                revert(0, 0)
            }

            z := div(mul(x, y), SCALAR)
        }
    }

    /**
     * @notice It divides two fixed point numbers.
     * @dev It assumes the arguments are fixed point numbers with 18 decimal houses. It reverts if the result overflows 2**256-1. It does not guard against underflows because the EVM div opcode cannot underflow. Source: https://twitter.com/transmissions11/status/1451129626432978944/photo/1
     * @param x First operand
     * @param y The second operand
     * @return z The result of multiplying x and y
     */
    function fdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// We use assembly to optimize gas consumption.
        assembly {
            if or(
                iszero(y),
                iszero(or(iszero(x), eq(div(mul(x, SCALAR), x), SCALAR)))
            ) {
                revert(0, 0)
            }
            z := div(mul(x, SCALAR), y)
        }
    }

    /**
     * @notice It returns a version of the first argument with 18 decimals.
     * @dev This function protects against shadow integer overflow.
     * @param x Number that will be manipulated to have 18 decimals.
     * @param decimals The current decimal houses of the first argument
     * @return z A version of the first argument with 18 decimals.
     */
    function adjust(uint256 x, uint8 decimals) internal pure returns (uint256) {
        /// If the number has 18 decimals, we do not need to do anything.
        /// Since {mulDiv} protects against shadow overflow, we can first add 18 decimal houses and then remove the current decimal houses.
        return decimals == 18 ? x : mulDiv(x, SCALAR, 10**decimals);
    }

    /**
     * @notice It adds two numbers.
     * @dev This function has no protection against integer overflow to optimize gas consumption. It must only be used when we are 100% certain it will not overflow. E.g., to calculate the number of blocks elapsed.
     * @param x First operand.
     * @param y The second operand.
     * @return z The result of adding x and y.
     */
    function uAdd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            z := add(x, y)
        }
    }

    /**
     * @notice It subtracts two numbers.
     * @dev This function has no protection against integer underflow to optimize gas consumption. It must only be used when we are 100% certain it will not underflow. E.g., to calculate the number of blocks elapsed.
     * @param x First operand.
     * @param y The second operand.
     * @return z The result of adding x and y.
     */
    function uSub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            z := sub(x, y)
        }
    }

    /// @notice Calculates floor(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // Handle division by zero
        require(denominator > 0);

        // 512-bit multiply [prod1 prod0] = a * b
        // Compute the product mod 2**256 and mod 2**256 - 1
        // then use the Chinese Remiander Theorem to reconstruct
        // the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2**256 + prod0
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        // Short circuit 256 by 256 division
        // This saves gas when a * b is small, at the cost of making the
        // large case a bit more expensive. Depending on your use case you
        // may want to remove this short circuit and always go through the
        // 512 bit path.
        if (prod1 == 0) {
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        ///////////////////////////////////////////////
        // 512 by 256 division.
        ///////////////////////////////////////////////

        // Handle overflow, the result must be < 2**256
        require(prod1 < denominator);

        // Make division exact by subtracting the remainder from [prod1 prod0]
        // Compute remainder using mulmod
        // Note mulmod(_, _, 0) == 0
        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        // Subtract 256 bit number from 512 bit number
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        // Factor powers of two out of denominator
        // Compute largest power of two divisor of denominator.
        // Always >= 1 unless denominator is zero, then twos is zero.
        uint256 twos = denominator & (~denominator + 1);
        // Divide denominator by power of two
        assembly {
            denominator := div(denominator, twos)
        }

        // Divide [prod1 prod0] by the factors of two
        assembly {
            prod0 := div(prod0, twos)
        }
        // Shift in bits from prod1 into prod0. For this we need
        // to flip `twos` such that it is 2**256 / twos.
        // If twos is zero, then it becomes one
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;

        // Invert denominator mod 2**256
        // Now that denominator is an odd number, it has an inverse
        // modulo 2**256 such that denominator * inv = 1 mod 2**256.
        // Compute the inverse by starting with a seed that is correct
        // correct for four bits. That is, denominator * inv = 1 mod 2**4
        // If denominator is zero the inverse starts with 2
        uint256 inv = (3 * denominator) ^ 2;
        // Now use Newton-Raphson itteration to improve the precision.
        // Thanks to Hensel's lifting lemma, this also works in modular
        // arithmetic, doubling the correct bits in each step.
        inv *= 2 - denominator * inv; // inverse mod 2**8
        inv *= 2 - denominator * inv; // inverse mod 2**16
        inv *= 2 - denominator * inv; // inverse mod 2**32
        inv *= 2 - denominator * inv; // inverse mod 2**64
        inv *= 2 - denominator * inv; // inverse mod 2**128
        inv *= 2 - denominator * inv; // inverse mod 2**256
        // If denominator is zero, inv is now 128

        // Because the division is now exact we can divide by multiplying
        // with the modular inverse of denominator. This will give us the
        // correct result modulo 2**256. Since the precoditions guarantee
        // that the outcome is less than 2**256, this is the final result.
        // We don't need to compute the high bits of the result and prod1
        // is no longer required.
        result = prod0 * inv;
        return result;
    }

    /**
     * @notice This function finds the square root of a number.
     * @dev It was taken from https://github.com/transmissions11/solmate/blob/main/src/utils/FixedPointMathLib.sol.
     * @param x This function will find the square root of this number.
     * @return The square root of x.
     */
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        uint256 xx = x;
        uint256 r = 1;

        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }
        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x8) {
            r <<= 1;
        }

        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint256 r1 = x / r;
        return (r < r1 ? r : r1);
    }

    /**
     * @notice It returns the smaller number between the two arguments.
     * @param x Any uint256 number.
     * @param y Any uint256 number.
     * @return It returns whichever is smaller between x and y.
     */
    function min(uint256 x, uint256 y) internal pure returns (uint256) {
        return x > y ? y : x;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title The errors thrown by the {SafeERC20} library.
 * @dev Contracts that use the {SafeERC20} library should inherit this contract.
 */
contract SafeTransferErrors {
    error NativeTokenTransferFailed(); // function selector - keccak-256 0x3022f2e4

    error TransferFromFailed(); // function selector - keccak-256 0x7939f424

    error TransferFailed(); // function selector - keccak-256 0x90b8ec18

    error ApproveFailed(); // function selector - keccak-256 0x3e3f8f73
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title A set of utility functions to guarantee the finality of the ERC20 {transfer}, {transferFrom} and {approve} functions.
 * @author Jose Cerqueira <[email protected]>
 * @dev These functions do not check that the recipient has any code, and they will revert with custom errors available in the {SafeERC20Errors}. We also leave dirty bits in the scratch space of the memory 0x00 to 0x3f.
 */
library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                          NATIVE TOKEN OPERATIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice This function sends native tokens from the {msg.sender} to an address.
     * @param to The recipient of the `amount` of native tokens.
     * @param amount The number of native tokens to send to the `to` address.
     */
    function safeTransferNativeToken(address to, uint256 amount) internal {
        assembly {
            /// Pass no calldata only value in wei
            /// We do not save any data in memory.
            /// Returns 1, if successful
            if iszero(call(gas(), to, amount, 0x00, 0x00, 0x00, 0x00)) {
                // Save the function identifier in slot 0x00
                mstore(
                    0x00,
                    0x3022f2e400000000000000000000000000000000000000000000000000000000
                )
                /// Grab the first 4 bytes in slot 0x00 and revert with {NativeTokenTransferFailed()}
                revert(0x00, 0x04)
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice It transfers {ERC20} tokens from {msg.sender} to an address.
     * @param token The address of the {ERC20} token.
     * @param to The address of the recipient.
     * @param amount The number of tokens to send.
     */
    function safeTransfer(
        address token,
        address to,
        uint256 amount
    ) internal {
        assembly {
            /// Keep the pointer in memory to restore it later.
            let freeMemoryPointer := mload(0x40)

            /// Save the arguments in memory to pass to {call} later.
            /// IMPORTANT: We will override the free memory pointer, but we will restore it later.

            /// keccak-256 transfer(address,uint256) first 4 bytes 0xa9059cbb
            mstore(
                0x00,
                0xa9059cbb00000000000000000000000000000000000000000000000000000000
            )
            mstore(0x04, to) // save address after first 4 bytes
            mstore(0x24, amount) // save amount after 36 bytes

            // First, we call the {token} with 68 bytes of data starting from slot 0x00 to slot 0x44.
            // We save the returned data on slot 0x00.
            // If the {call} returns 0, it fails.
            // If the data returned from {call} does not equal to 1 or is not empty, this transaction will revert.
            if iszero(
                and(
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x00, 0x44, 0x00, 0x20)
                )
            ) {
                // Save the function identifier for {TransferFailed()} on slot 0x00.
                mstore(
                    0x00,
                    0x90b8ec1800000000000000000000000000000000000000000000000000000000
                )
                // Select first 4 bytes on slot 0x00 and revert.
                revert(0x00, 0x04)
            }

            // Restore the free memory pointer value on slot 0x40.
            mstore(0x40, freeMemoryPointer)
        }
    }

    /**
     * @notice It transfers {ERC20} tokens from a third party address to another address.
     * @dev This function requires the {msg.sender} to have an allowance equal to or higher than the number of tokens being transferred.
     * @param token The address of the {ERC20} token.
     * @param from The address that will have its tokens transferred.
     * @param to The address of the recipient.
     * @param amount The number of tokens being transferred.
     */
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    ) internal {
        assembly {
            /// Keep the pointer in memory to restore it later.
            let freeMemoryPointer := mload(0x40)

            /// Save the arguments in memory to pass to {call} later.
            /// IMPORTANT: We will override the zero slot and free memory pointer, BUT we will restore it after.

            /// Save the first 4 bytes 0x23b872dd of the keccak-256 transferFrom(address,address,uint256) on slot 0x00.
            mstore(
                0x00,
                0x23b872dd00000000000000000000000000000000000000000000000000000000
            )
            mstore(0x04, from) // save address after first 4 bytes
            mstore(0x24, to) // save address after 36 bytes
            mstore(0x44, amount) // save amount after 68 bytes

            // First we call the {token} with 100 bytes of data starting from slot 0x00.
            // We save the returned data on slot 0x00.
            // If the {call} returns 0, this transaction will revert.
            // If the data returned from {call} does not equal to 1 or is not empty, this transaction will revert.
            if iszero(
                and(
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x00, 0x64, 0x00, 0x20)
                )
            ) {
                // Save function identifier for {TransferFromFailed()} on slot 0x00.
                mstore(
                    0x00,
                    0x7939f42400000000000000000000000000000000000000000000000000000000
                )
                // Select first 4 bytes on slot 0x00 and revert.
                revert(0x00, 0x04)
            }

            // Clean up memory
            mstore(0x40, freeMemoryPointer) // restore the free memory pointer
            mstore(
                0x60,
                0x0000000000000000000000000000000000000000000000000000000000000000
            ) // restore the slot zero
        }
    }

    /**
     * @notice It allows the {msg.sender} to update the allowance of an address.
     * @dev Developers have to keep in mind that this transaction can be front-run.
     * @param token The address of the {ERC20} token.
     * @param to The address that will have its allowance updated.
     * @param amount The new allowance.
     */
    function safeApprove(
        address token,
        address to,
        uint256 amount
    ) internal {
        assembly {
            // Keep the pointer in memory to restore it later.
            let freeMemoryPointer := mload(0x40)

            // Save the arguments in memory to pass to {call} later.
            // We will override the free memory pointer, but we will restore it later.

            // Save the first 4 bytes (0x095ea7b3) of the keccak-256 approve(address,uint256) function on slot 0x00.
            mstore(
                0x00,
                0x095ea7b300000000000000000000000000000000000000000000000000000000
            )
            mstore(0x04, to) // save the address after 4 bytes
            mstore(0x24, amount) // save the amount after 36 bytes

            // First we call the {token} with 68 bytes of data starting from slot 0x00.
            // We save the returned data on slot 0x00.
            // If the {call} returns 0, this transaction will revert.
            // If the data returned from {call} does not equal to 1 or is not empty, this transaction will revert.
            if iszero(
                and(
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x00, 0x44, 0x00, 0x20)
                )
            ) {
                // Save the first 4 bytes of the keccak-256 of {ApproveFailed()}
                mstore(
                    0x00,
                    0x3e3f8f7300000000000000000000000000000000000000000000000000000000
                )
                // Select first 4 bytes on slot 0x00 and return
                revert(0x00, 0x04)
            }

            // restore the free memory pointer
            mstore(0x40, freeMemoryPointer)
        }
    }
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
pragma solidity 0.8.16;

error CasaDePapel__UnstakeAmountTooHigh();

error CasaDePapel__PoolAlreadyAdded();

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

interface ICasaDePapel {
    /*///////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    event Stake(address indexed user, uint256 indexed poolId, uint256 amount);

    event Unstake(address indexed user, uint256 indexed poolId, uint256 amount);

    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed poolId,
        uint256 amount
    );

    event Liquidate(
        address indexed liquidator,
        address indexed debtor,
        uint256 amount
    );

    event UpdatePool(
        uint256 indexed poolId,
        uint256 blockNumber,
        uint256 accruedIntPerShare
    );

    event UpdatePoolAllocationPoint(
        uint256 indexed poolId,
        uint256 allocationPoints
    );

    event AddPool(
        address indexed token,
        uint256 indexed poolId,
        uint256 allocationPoints
    );

    event NewInterestTokenRatePerBlock(uint256 rate);

    event NewTreasury(address indexed treasury);

    function START_BLOCK() external view returns (uint256);

    function interestTokenPerBlock() external view returns (uint256);

    function treasury() external view returns (address);

    function treasuryBalance() external view returns (uint256);

    function pools(uint256 index)
        external
        view
        returns (
            address stakingToken,
            uint256 allocationPoints,
            uint256 lastRewardBlock,
            uint256 accruedIntPerShare,
            uint256 totalSupply
        );

    function userInfo(uint256 poolId, address account)
        external
        view
        returns (uint256 amount, uint256 rewardsPaid);

    function hasPool(address token) external view returns (bool);

    function getPoolId(address token) external view returns (uint256);

    function totalAllocationPoints() external view returns (uint256);

    function getPoolsLength() external view returns (uint256);

    function getUserPendingRewards(uint256 poolId, address _user)
        external
        view
        returns (uint256);

    function mintTreasuryRewards() external;

    function updatePool(uint256 poolId) external;

    function updateAllPools() external;

    function stake(uint256 poolId, uint256 amount) external;

    function unstake(uint256 poolId, uint256 amount) external;

    function emergencyWithdraw(uint256 poolId) external;
}

// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.8.9;

struct User {
    uint256 amount; // How many {StakingToken} the user has in a specific pool.
    uint256 rewardsPaid; // How many rewards the user has been paid so far.
}

struct Pool {
    address stakingToken; // The underlying token that is "farming" {InterestToken} rewards.
    uint256 allocationPoints; // These points determine how many {InterestToken} tokens the pool will get per block.
    uint256 lastRewardBlock; // The last block the pool has distributed rewards to properly calculate new rewards.
    uint256 accruedIntPerShare; // Total of accrued {InterestToken} tokens per share.
    uint256 totalSupply; // Total number of {StakingToken} the pool has in it.
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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