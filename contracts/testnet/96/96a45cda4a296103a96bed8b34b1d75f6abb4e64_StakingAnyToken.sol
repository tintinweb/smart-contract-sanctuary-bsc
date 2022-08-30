/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

// Sources flattened with hardhat v2.9.9 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]

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


// File @openzeppelin/contracts/access/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/token/ERC20/[email protected]

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


// File @openzeppelin/contracts/security/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/utils/math/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. It the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`.
        // We also know that `k`, the position of the most significant bit, is such that `msb(a) = 2**k`.
        // This gives `2**k < a <= 2**(k+1)` → `2**(k/2) <= sqrt(a) < 2 ** (k/2+1)`.
        // Using an algorithm similar to the msb conmputation, we are able to compute `result = 2**(k/2)` which is a
        // good first aproximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1;
        uint256 x = a;
        if (x >> 128 > 0) {
            x >>= 128;
            result <<= 64;
        }
        if (x >> 64 > 0) {
            x >>= 64;
            result <<= 32;
        }
        if (x >> 32 > 0) {
            x >>= 32;
            result <<= 16;
        }
        if (x >> 16 > 0) {
            x >>= 16;
            result <<= 8;
        }
        if (x >> 8 > 0) {
            x >>= 8;
            result <<= 4;
        }
        if (x >> 4 > 0) {
            x >>= 4;
            result <<= 2;
        }
        if (x >> 2 > 0) {
            result <<= 1;
        }

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        uint256 result = sqrt(a);
        if (rounding == Rounding.Up && result * result < a) {
            result += 1;
        }
        return result;
    }
}


// File contracts/StakingAnyToken/StakingAnyToken.sol

pragma solidity 0.8.9;
/**
 * @dev Staking Contract 
 *  - Stake any token and get Interest in XYZ  
 *  - Set Penalty function 
 *  - Number of days option for staking 
 *  - different token have different interest rate.  
 */
contract StakingAnyToken is Ownable, Pausable {

    uint32 public currentVersion;

    // minimum stake time in seconds, if the user withdraws before this time a penalty will be charged
    uint256 public minimumStakeTime;

    // the penalty, a number between 0 and 100
    uint8 public penalty;

    // token award, AwardToken
    IERC20 public token;

    // lock to prevent withdraw staking
    bool public withdrawLocked;

    // the Stake
    struct Stake {
        // version of this stake
        uint32 version;
        // the staking token
        address token;
        // opening timestamp
        uint64 startTimestamp;
        // amount staked
        uint256 amount;
        // interest accrued, this will be available only after closing stake
        uint256 interest;
        // penalty charged, if any
        uint256 penalty;
        // last time the interest was withdrawn
        uint64 lastWithdrawalTimestamp;
        // closing timestamp, if 0 then stake is still open
        uint64 finishedTimestamp;
        // the version on closing
        uint32 finishedVersion;
    }
    
    struct StakeView {
        // stake index
        uint32 index;
        // version of this stake
        uint32 version;
        // the staking token
        address token;
        // opening timestamp
        uint64 startTimestamp;
        // amount staked
        uint256 amount;
        // interest accrued, this will be available only after closing stake
        uint256 interest;
        // penalty charged, if any
        uint256 penalty;
        // last time the interest was withdrawn
        uint64 lastWithdrawalTimestamp;
        // closing timestamp, if 0 then stake is still open
        uint64 finishedTimestamp;
        // the version on closing
        uint32 finishedVersion;
        // interest realtime
        uint256 interestRealTime;
        // decimals of apy
        int8 apyDecimals;
        // Annual Percentage Yield. Interest(AwardToken) = stakedAmount(StakeToken) * (APY * 10^apyDecimals / stakedTime)
        uint32 apy;
    }

    struct TokenAPY {
        // the lower bound of the token apy
        uint256 lowerBoundAmount;
        // Annual Percentage Yield. Interest(AwardToken) = stakedAmount(StakeToken) * (APY * 10^apyDecimals / stakedTime)
        uint32 apy;
    }

    struct StakeTokenInfo {
        bool hasAdded;
        bool enabled;
        // minimum amount of tokens to create a stake
        uint256 minimum;
        int8 apyDecimals;
        TokenAPY[] tokenAPYs;
        // penalties are collected and stored by the contract
        uint256 collectedPenalty;
        // current left stake amount
        uint256 stakingAmount;
    }

    // stakes that the owner have    
    mapping(address => Stake[]) public stakesOfOwner;
    mapping(address => uint32) public validStakesCountOfOwner;
    
    // all accounts that have or have had stakes, this for the owner to be able to query stakes
    address[] public ownersAccounts;

    // count of owner who have stakes now
    uint64 public stakingOwnerCount;

    // all supported Stake Token Infos
    mapping(address => StakeTokenInfo) public supportedStakeTokenInfos;
    // all supported Stake Token addresses
    address[] public supportedStakeTokens;
    
    event ObsoleteVersion(uint32 version);
    event StakeCreated(address indexed user, uint32 indexed index, address indexed token, uint256 amount);
    event Withdraw(address indexed user, uint32 indexed index, uint64 interestSeconds, uint256 interest);
    event WithdrawInterest(address indexed user, uint32 indexed index, uint64 interestSeconds, uint256 interest);
    event EmergencyWithdraw(address indexed user, uint32 indexed index, uint64 interestSeconds, uint256 interest, uint256 penalty);
    event WithdrawObsoleteStaking(address indexed user, uint32 indexed index);


    event StakeTokenInfoAdded(address indexed token, uint256 minimum, int8 apyDecimals, TokenAPY[] tokenAPYs);
    event StakeTokenInfoChanged(address indexed token, bool enable, uint256 minimum, int8 apyDecimals, TokenAPY[] tokenAPYs);

    struct TokenAmountPair {
        address token;
        uint256 amount;
    }

    struct Summary {
        uint64 stakingOwnerCount;
        TokenAmountPair[] leftStakingAmounts;
    }

    struct AddressStakesData {
        address user;
        Stake[] stakes;
    }

    struct StakeResult {
        AddressStakesData[] userStakes;
        bool hasEnded;
    }

    // @param _token: the ERC20 token to be used
    // @param _minimumStakeTimeSeconds: minimum stake time in seconds
    // @param _penalty: the penalty percentage 0 to 100
    // @param _minimum: minimum stake amount
    constructor(IERC20 _token, uint256 _minimumStakeTimeSeconds, uint8 _penalty) {
        require(_penalty<=100, "Penalty must be less than 100");
        token = _token;
        minimumStakeTime = _minimumStakeTimeSeconds;
        penalty = _penalty;
        currentVersion = 1;
    }
    
    function stakesOfOwnerLength(address _account) public view returns (uint256) {
        return stakesOfOwner[_account].length;
    }
    
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function lockWithdraw() public onlyOwner {
        require(!withdrawLocked, "Withdraw is already locked");
        withdrawLocked = true;
    }

    function unlockWithdraw() public onlyOwner {
        require(withdrawLocked, "Withdraw is not locked");
        withdrawLocked = false;
    }

    modifier whenWithdrawNotLocked {
        require(!withdrawLocked, "Withdraw is locked");
        _;
    }

    function modifyMinimumStakeTime(uint256 _newVal) external onlyOwner {
        minimumStakeTime = _newVal;
    }
    function modifyPenalty(uint8 _newVal) external onlyOwner {
        penalty = _newVal;
    }

    // give back all staking, user can withdraw all staking by calling withdrawObsoleteStake
    function obsoleteVersion() external onlyOwner {
        currentVersion += 1;
        emit ObsoleteVersion(currentVersion - 1);
    }


    // query all stake accounts holders
    function queryOwnersAccounts() external view returns (address[] memory) {
        return ownersAccounts;
    }

    // query all stake accounts holders paginated
    function queryOwnersAccountsPaginated(uint64 _startInx, uint32 _length) external view returns (address[] memory) {
        uint256 realLength = Math.max(0, Math.min(_length, ownersAccounts.length - _startInx));
        address[] memory result = new address[](realLength);
        for (uint256 i = 0; i < realLength; i++) {
            result[i] = ownersAccounts[_startInx + i];
        }
        return result;
    }

    // query all stake accounts holders length
    function ownersAccountsLength() external view returns (uint256) {
        return ownersAccounts.length;
    }

    // query all supported staking token length
    function supportedStakeTokensLength() public view returns (uint256) {
        return supportedStakeTokens.length;
    }

    // query supported staking token apy info length
    function stakeTokenApyLength(address _token) public view returns (uint256) {
        return supportedStakeTokenInfos[_token].tokenAPYs.length;
    }

    // query supported staking token apy info by index
    function stakeTokenAPY(address _token, uint256 _index) public view returns (TokenAPY memory) {
        require(_index < supportedStakeTokenInfos[_token].tokenAPYs.length, "Index is out of bounds");
        return supportedStakeTokenInfos[_token].tokenAPYs[_index];
    }

    function querySupportedStakeTokenInfo(address _token) external view returns (StakeTokenInfo memory) {
        StakeTokenInfo storage info = supportedStakeTokenInfos[_token];
        require(info.hasAdded, "token is not supported");
        return info;
    }

    function querySupportedStakeTokenInfosPaginated(uint32 _startInx, uint32 _length) external view returns (StakeTokenInfo[] memory) {
        uint256 realLength = Math.max(0, Math.min(_length, supportedStakeTokens.length - _startInx));
        StakeTokenInfo[] memory result = new StakeTokenInfo[](realLength);
        for (uint256 i = 0; i < realLength; i++) {
            StakeTokenInfo storage info = supportedStakeTokenInfos[supportedStakeTokens[_startInx + i]];
            result[i] = info;
        }
        return result;
    }

    // query staking summary, get staking owner count, and all staking amount of each token
    function querySummary() public view returns (Summary memory) {
        Summary memory summary = Summary(stakingOwnerCount, new TokenAmountPair[](supportedStakeTokens.length));
        for (uint256 i = 0; i < supportedStakeTokens.length; i++) {
            address t = supportedStakeTokens[i];
            uint256 amount = supportedStakeTokenInfos[t].stakingAmount;
            summary.leftStakingAmounts[i] = TokenAmountPair(t, amount);
        }
        return summary;
    }
    
    function queryUserStakeSummary(address _user, address _token) public view returns (uint256 historyTotal, uint256 validWithObsoleted, uint256 validTotal) {
        Stake[] storage userStakes = stakesOfOwner[_user];
        for (uint256 i = 0; i < userStakes.length; i++) {
            Stake storage stake = userStakes[i];
            if (stake.token != _token) {
                continue;
            }
            historyTotal += stake.amount;
            if (stake.finishedTimestamp == 0) {
                validWithObsoleted += stake.amount;
                if (stake.version == currentVersion) {
                    validTotal += stake.amount;
                }
            }
        }
    }

    function queryUserStake(address _user, bool _skipFinished) public view returns (StakeView[] memory) {
        Stake[] storage userStakes = stakesOfOwner[_user];
        StakeView[] memory ret = new StakeView[](_skipFinished ? validStakesCountOfOwner[_user] : userStakes.length);
        uint32 retStakeInx = 0;
        for (uint32 i = 0; retStakeInx < ret.length ; i++) {
            Stake storage stake = userStakes[i];
            uint256 interestRealTime = 0;
            uint32 apy;
            int8 apyDecimals; 
            if (stake.finishedTimestamp != 0) {
                if (_skipFinished) {
                    continue;
                }

                (,,, apy, apyDecimals) = calculateInterestByStake(stake, block.timestamp - stake.startTimestamp < minimumStakeTime);
            } else {
                (interestRealTime,,, apy, apyDecimals) = calculateInterestByStake(stake, block.timestamp - stake.startTimestamp < minimumStakeTime);
            }

            ret[retStakeInx] = StakeView({
                index: i,
                version: stake.version,
                token: stake.token,
                startTimestamp: stake.startTimestamp,
                amount: stake.amount,
                interest: stake.interest,
                penalty: stake.penalty,
                lastWithdrawalTimestamp: stake.lastWithdrawalTimestamp,
                finishedTimestamp: stake.finishedTimestamp,
                finishedVersion: stake.finishedVersion,
                interestRealTime: interestRealTime,
                apy: apy,
                apyDecimals: apyDecimals
            });
            retStakeInx += 1;
        }
        return ret;
    }

    function queryAllStakePaginated(bool _skipFinished, uint64 _startInx, uint32 _length) public view returns (StakeResult memory) {
        uint256 realLength = Math.max(0, Math.min(_length, ownersAccounts.length - _startInx));
        StakeResult memory result = StakeResult(new AddressStakesData[](realLength), _startInx + realLength >= ownersAccounts.length);
        for (uint256 i = 0; i < realLength; i++) {
            address userAddress = ownersAccounts[_startInx + i];
            Stake[] storage userStakes = stakesOfOwner[userAddress];
            AddressStakesData memory retUserStake = AddressStakesData(userAddress, new Stake[](_skipFinished ? validStakesCountOfOwner[userAddress] : userStakes.length));
            {
                uint32 retStakeInx = 0;
                for (uint256 j = 0; retStakeInx < retUserStake.stakes.length ; j++) {
                    Stake storage stake = userStakes[j];
                    if (_skipFinished && stake.finishedTimestamp != 0) {
                        continue;
                    }
                    retUserStake.stakes[retStakeInx] = stake;
                    retStakeInx += 1;
                }
            }
            result.userStakes[i] = retUserStake;
        }
        return result;
    }

    // add a new stake token
    function addSupportedStakeToken(address _token, uint256 _minimum, int8 _apyDecimals, TokenAPY[] memory _tokenAPYs) external onlyOwner {
        require(!supportedStakeTokenInfos[_token].hasAdded, "Token already supported");
        supportedStakeTokens.push(_token);
        StakeTokenInfo storage info = supportedStakeTokenInfos[_token];
        info.hasAdded = true;
        info.enabled = true;
        info.minimum = _minimum;
        info.apyDecimals = _apyDecimals;

        for(uint256 i = 0; i < _tokenAPYs.length; i++) {
            if (i > 0) {
                require(
                    _tokenAPYs[i].lowerBoundAmount > _tokenAPYs[i - 1].lowerBoundAmount,
                    "APY low bound must asc");
            }
            supportedStakeTokenInfos[_token].tokenAPYs.push(TokenAPY(_tokenAPYs[i].lowerBoundAmount, _tokenAPYs[i].apy));
        }
        emit StakeTokenInfoAdded(_token, _minimum, _apyDecimals, _tokenAPYs);
    }

    // update the supported stake token info
    function updateSupportedStakeToken(address _token, bool _enabled, uint256 _minimum, int8 _apyDecimals, TokenAPY[] memory _tokenAPYs) external onlyOwner {
        StakeTokenInfo storage info = supportedStakeTokenInfos[_token];
        require(info.hasAdded, "Token not supported");
        info.enabled = _enabled;
        info.minimum = _minimum;
        info.apyDecimals = _apyDecimals;
        delete supportedStakeTokenInfos[_token].tokenAPYs;
        for(uint256 i = 0; i < _tokenAPYs.length; i++) {
            if (i > 0) {
                require(
                    _tokenAPYs[i].lowerBoundAmount > _tokenAPYs[i - 1].lowerBoundAmount,
                    "APY low bound must asc");
            }
            supportedStakeTokenInfos[_token].tokenAPYs.push(TokenAPY(_tokenAPYs[i].lowerBoundAmount, _tokenAPYs[i].apy));
        }
        emit StakeTokenInfoChanged(_token, true, _minimum, _apyDecimals, _tokenAPYs);
    }


    function isObsoleteStake(address _user, uint32 _index) public view returns (bool) {
        require(_index < stakesOfOwner[_user].length, "Index is out of bounds");
        return stakesOfOwner[_user][_index].version != currentVersion;
    }
    
    // anyone can create a stake
    function createStake(address stakeTokenAddress, uint256 amount) external whenNotPaused {
        StakeTokenInfo storage stakeTokenInfo = supportedStakeTokenInfos[stakeTokenAddress];
        require(stakeTokenInfo.enabled, "Stake token is not enabled");
        require(amount >= stakeTokenInfo.minimum, "The amount is too low");

        IERC20 stakeToken = IERC20(stakeTokenAddress);

        // store the tokens of the user in the contract
        // requires approve
        uint256 realAmount = stakeToken.balanceOf(address(this)); // we need to calculate real amount because of reflection
		stakeToken.transferFrom(msg.sender, address(this), amount);
        realAmount = stakeToken.balanceOf(address(this)) - realAmount; // realAmount is the final balance received

        // store the account of the staker in ownersAccounts if it doesnt exists
		if(stakesOfOwner[msg.sender].length == 0){
            ownersAccounts.push(msg.sender);
		}

        // create the stake
        stakesOfOwner[msg.sender].push(Stake({
            version: currentVersion,
            token: stakeTokenAddress,
            startTimestamp: uint64(block.timestamp),
            amount: realAmount,
            interest: 0,
            penalty: 0,
            lastWithdrawalTimestamp: 0,
            finishedTimestamp: 0,
            finishedVersion: 0
        }));
        if (validStakesCountOfOwner[msg.sender] == 0) {
            stakingOwnerCount++;
        }
        validStakesCountOfOwner[msg.sender]++;
        stakeTokenInfo.stakingAmount += realAmount;
        emit StakeCreated(msg.sender, uint32(stakesOfOwner[msg.sender].length - 1), stakeTokenAddress, realAmount);
    }

    // withdraw obsoleted stakes
    // _arrayIndex: is the id of the stake to be finalized
    function withdrawObsoleteStake(uint32 _arrayIndex) external {

        // Stake should exists and opened
        require(_arrayIndex < stakesOfOwner[msg.sender].length, "Stake does not exist");
        Stake storage stake = stakesOfOwner[msg.sender][_arrayIndex];
        require(stake.finishedTimestamp == 0, "This stake is closed");
        require(stake.version != currentVersion, "This stake is not obsolete");

        StakeTokenInfo storage stakeTokenInfo = supportedStakeTokenInfos[stake.token];
        stakeTokenInfo.stakingAmount -= stake.amount;
        validStakesCountOfOwner[msg.sender]--;
        if (validStakesCountOfOwner[msg.sender] == 0) {
            stakingOwnerCount--;
        }


        IERC20 stakeToken = IERC20(stake.token);
        // transfer the amount from the contract itself
        stakeToken.transfer(msg.sender, stake.amount);
        // record the transaction
        stake.finishedTimestamp = uint64(block.timestamp);
        stake.finishedVersion = currentVersion;
        emit WithdrawObsoleteStaking(msg.sender, _arrayIndex);
    }

    function calculateInterest(address _ownerAccount, uint32 _inx) private view returns (uint256 retInterest) {

        Stake storage stake = stakesOfOwner[_ownerAccount][_inx];
        (retInterest,,,,) = calculateInterestByStake(stake, block.timestamp - stake.startTimestamp < minimumStakeTime);
    }

    
    function calculateInterestByStake(Stake storage _stake, bool _processPenalty) private view returns (uint256 retInterest, uint256 retPenalty, uint64 retInterestSeconds, uint32 apy, int8 apyDecimals) {
        apy = 0;
        StakeTokenInfo storage stakeTokenInfo = supportedStakeTokenInfos[address(_stake.token)];
        for (uint i=stakeTokenInfo.tokenAPYs.length - 1; i>=0; i--) {
            if (_stake.amount >= stakeTokenInfo.tokenAPYs[i].lowerBoundAmount) {
                apy = stakeTokenInfo.tokenAPYs[i].apy;
                break;
            }
        }

        apyDecimals = stakeTokenInfo.apyDecimals;

        // APY per year = amount * APY * 10^apyDecimal / seconds of the year
        uint256 interestPerYear = _stake.amount * apy;
        if (apyDecimals > 0) {
            interestPerYear = interestPerYear * (10 ** uint8(apyDecimals));
        } else if (apyDecimals < 0) {
            interestPerYear = interestPerYear / (10 ** uint8(-apyDecimals));
        }

        // number of seconds since opening date
        retInterestSeconds = uint64(block.timestamp - _stake.startTimestamp);

        // calculate interest by a rule of three
        //  seconds of the year: 31536000 = 365*24*60*60
        //  interestPerYear   -   31536000
        //  interest            -   num_seconds
        //  interest = num_seconds * interestPerYear / 31536000
        retInterest = retInterestSeconds * interestPerYear / 31536000;

        // calculate penalty = interest * penalty / 100
        if (_processPenalty) {
            retPenalty = retInterest * penalty / 100;
            retInterest -= retPenalty;
        }
    }

    // finalize the stake
    // _arrayIndex: is the id of the stake to be finalized
    function withdrawStake(uint32 _arrayIndex) external whenWithdrawNotLocked {
        // Stake should exists and opened
        require(_arrayIndex < stakesOfOwner[msg.sender].length, "Stake does not exist");
        Stake storage stake = stakesOfOwner[msg.sender][_arrayIndex];
        require(stake.finishedTimestamp == 0, "This stake is closed");
        require(stake.version == currentVersion, "This stake is obsolete");
        require(block.timestamp - stake.startTimestamp >= minimumStakeTime, "The stake is too short");
        
        StakeTokenInfo storage stakeTokenInfo = supportedStakeTokenInfos[stake.token];
        stakeTokenInfo.stakingAmount -= stake.amount;
        validStakesCountOfOwner[msg.sender]--;
        if (validStakesCountOfOwner[msg.sender] == 0) {
            stakingOwnerCount--;
        }
        
        // get the interest
        (uint256 interest,, uint64 interestSeconds,,) = calculateInterestByStake(stake, false);
        // record the transaction
        stake.finishedTimestamp = uint64(block.timestamp);
        stake.finishedVersion = currentVersion;
        stake.interest += interest;

        if (interest > 0) {
            // transfer the interest amount from the contract owner
            token.transferFrom(owner(), msg.sender, interest);
        }

        IERC20(stake.token).transfer(msg.sender, stake.amount);

        // transfer the amount from the contract itself
        emit Withdraw(msg.sender, _arrayIndex, interestSeconds, interest);
    }
    
    function withdrawStakeInterest(uint32 _arrayIndex) external whenWithdrawNotLocked {
        // Stake should exists and opened
        require(_arrayIndex < stakesOfOwner[msg.sender].length, "Stake does not exist");
        Stake storage stake = stakesOfOwner[msg.sender][_arrayIndex];
        require(stake.finishedTimestamp == 0, "This stake is closed");
        require(stake.version == currentVersion, "This stake is obsolete");
        require(block.timestamp - stake.startTimestamp >= minimumStakeTime, "The stake is too short");
        
        
        // get the interest
        (uint256 interest,, uint64 interestSeconds,,) = calculateInterestByStake(stake, false);
        
        require(interest > 0, "No interest to withdraw");

        // record the transaction
        stake.lastWithdrawalTimestamp = uint64(block.timestamp);
        stake.interest += interest;

        // transfer the interest amount from the contract owner
        token.transferFrom(owner(), msg.sender, interest);

        emit WithdrawInterest(msg.sender, _arrayIndex, interestSeconds, interest);
    }

    // finalize the stake before the minimum stake time
    // _arrayIndex: is the id of the stake to be finalized
    function emergencyWithdrawStake(uint32 _arrayIndex) external whenWithdrawNotLocked {

        // Stake should exists and opened
        require(_arrayIndex < stakesOfOwner[msg.sender].length, "Stake does not exist");
        Stake storage stake = stakesOfOwner[msg.sender][_arrayIndex];
        require(stake.finishedTimestamp == 0, "This stake is closed");
        require(stake.version == currentVersion, "This stake is obsolete");
        require(block.timestamp - stake.startTimestamp < minimumStakeTime, "This stake can be withdrawn normally");
        StakeTokenInfo storage stakeTokenInfo = supportedStakeTokenInfos[stake.token];
        
        stakeTokenInfo.stakingAmount -= stake.amount;
        validStakesCountOfOwner[msg.sender]--;
        if (validStakesCountOfOwner[msg.sender] == 0) {
            stakingOwnerCount--;
        }
    
        // get the interest
        (uint256 interest, uint256 thePenalty, uint64 interestSeconds,,) = calculateInterestByStake(stake, true);

        // record the transaction
        stake.finishedTimestamp = uint64(block.timestamp);
        stake.finishedVersion = currentVersion;
        stake.interest += interest;
        stake.penalty += thePenalty;

        // penalty funds are hold by the contract, but keep the account of how much is it here
        stakeTokenInfo.collectedPenalty += thePenalty;

        if (interest > 0) {
            // transfer the interest amount from the contract owner
            token.transferFrom(owner(), msg.sender, interest);
        }

        // transfer remaining
        IERC20(stake.token).transfer(msg.sender, stake.amount);
        emit EmergencyWithdraw(msg.sender, _arrayIndex, interestSeconds, interest, thePenalty);
    }
}