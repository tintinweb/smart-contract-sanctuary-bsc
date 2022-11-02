// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title ShibaWorldCupPool
 * @notice Distribute betting profits among SWC holders.
 */
contract ShibaWorldCupPool is ReentrancyGuard, Pausable, Ownable {
    //---------- Libraries ----------//
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    //---------- Contracts ----------//
    IERC20 private SWC; // ShibaWorldCup token contract.

    //---------- Variables ----------//
    Counters.Counter public totalHolders; // Total wallets in pool.
    uint256 public totalDistributed; // Total BNBs distributed to holders.
    uint256 public totalStaked; // Total balance in stake.
    uint256 private pointsXtoken; // Shared points per token.
    uint256 private unclaimedTokens; // Tokens not claimed.
    uint256 private processedTokens; // Store the processed tokens.
    uint256 private initialBLock; // Initial block for calculate rewards per block.
    uint256 private lastBlock; // Last block distribution for calculate rewards per block.

    //---------- Storage -----------//
    struct Wallet {
        // Tokens amount staked.
        uint256 stakedBal;
        // Date in timestamp of the stake started.
        uint256 startTime;
        // shared points.
        uint256 tokenPoints;
        // pending rewards.
        uint256 pendingTokenbal;
    }

    mapping(address => Wallet) private stakeHolders; // Struct map of wallets in pool.

    //---------- Events -----------//
    event Deposit(uint256 amount, uint256 totalStaked);
    event Withdrawn(address indexed payee, uint256 amount);
    event AddedPoints(address indexed wallet, uint256 amount);
    event RemovedPoints(address indexed wallet, uint256 amount);
    event WalletMigrated(address indexed oldWallet, address indexed newWallet);

    //---------- Constructor ----------//
    constructor(address swc_) {
        SWC = IERC20(swc_);
        initialBLock = block.number;
        lastBlock = block.number;
    }

    //----------- Internal Functions -----------//
    /**
     * @dev Distribute BNBs.
     * @param amount_ amount of BNBs to distribute.
     */
    function _deposit(uint256 amount_) internal {
        if (totalStaked > 0 && amount_ >= 1000000) {
            pointsXtoken += (amount_.mul(10e18)).div(totalStaked);
            unclaimedTokens += amount_;
            totalDistributed += amount_;
            lastBlock = block.number;
            emit Deposit(amount_, totalStaked);
        }
    }

    /**
     * @dev Calculates the BNBs pending distribution and distributes them if there is an undistributed amount.
     */
    function _recalculateBalances() internal virtual {
        uint256 balance = address(this).balance;
        uint256 processed = unclaimedTokens.add(processedTokens);
        if (balance > processed) {
            uint256 pending = balance.sub(processed);
            if (pending > 1000000) {
                _deposit(pending);
            }
        }
    }

    /**
     * @notice Check the reward amount of a specific token.
     * @param wallet_ Address of the wallet to check.
     * @return Amount of reward for that token.
     */
    function _getRewards(address wallet_) internal view returns (uint256) {
        uint256 newTokenPoints = pointsXtoken.sub(
            stakeHolders[wallet_].tokenPoints
        );
        return (stakeHolders[wallet_].stakedBal.mul(newTokenPoints)).div(10e18);
    }

    /**
     * @dev Process pending rewards from a wallet in a particular token.
     * @param wallet_ address of the wallet to be processed.
     */
    function _processRewards(address wallet_) internal virtual {
        uint256 rewards = _getRewards(wallet_);
        if (rewards > 0) {
            unclaimedTokens -= rewards;
            processedTokens += rewards;
            stakeHolders[wallet_].tokenPoints = pointsXtoken;
            stakeHolders[wallet_].pendingTokenbal = stakeHolders[wallet_]
                .pendingTokenbal
                .add(rewards);
        }
    }

    /**
     * @dev Withdraw pending rewards of a specific token from a wallet.
     * @param wallet_ address of the wallet to withdraw.
     */
    function _harvest(address wallet_) internal virtual {
        _processRewards(wallet_);
        uint256 amount = stakeHolders[wallet_].pendingTokenbal;
        if (amount > 0) {
            stakeHolders[wallet_].pendingTokenbal = 0;
            processedTokens -= amount;
            (bool success, ) = wallet_.call{value: amount, gas: 35000}("");
            require(success, "Whitdrawn error");
            emit Withdrawn(wallet_, amount);
        }
    }

    /**
     * @dev Initialize a wallet joined with the current participation points.
     * @param wallet_ address of the wallet to initialize.
     */
    function _initWalletPoints(address wallet_) internal virtual {
        Wallet storage w = stakeHolders[wallet_];
        w.tokenPoints = pointsXtoken;
    }

    /**
     * @dev Add a wallet to stake for the first time.
     * @param wallet_ address of the wallet to add.
     * @param amount_ amount to add.
     */
    function _initStake(address wallet_, uint256 amount_) internal virtual {
        _recalculateBalances();
        bool success = SWC.transferFrom(wallet_, address(this), amount_);
        require(success, "Transfer from mistake");
        _initWalletPoints(wallet_);
        stakeHolders[wallet_].startTime = block.timestamp;
        stakeHolders[wallet_].stakedBal = amount_;
        totalStaked += amount_;
        totalHolders.increment();
    }

    /**
     * @dev Add more tokens to stake from an existing wallet.
     * @param wallet_ address of the wallet.
     * @param amount_ amount to add.
     */
    function _addStake(address wallet_, uint256 amount_) internal virtual {
        _recalculateBalances();
        _processRewards(wallet_);
        bool success = SWC.transferFrom(wallet_, address(this), amount_);
        require(success, "Transfer from mistake");
        stakeHolders[wallet_].stakedBal += amount_;
        totalStaked += amount_;
    }

    /**
     * @dev Check the reward amount of a specific token plus the processed balance.
     * @param wallet_ Address of the wallet to check.
     * @return Amount of reward plus the processed for that token.
     */
    function _getPendingBal(address wallet_) internal view returns (uint256) {
        uint256 newTokenPoints = pointsXtoken.sub(
            stakeHolders[wallet_].tokenPoints
        );
        uint256 pending = stakeHolders[wallet_].pendingTokenbal;
        return
            (stakeHolders[wallet_].stakedBal.mul(newTokenPoints))
                .div(10e18)
                .add(pending);
    }

    function _depositWrap(uint256 amount_) internal nonReentrant {
        _deposit(amount_);
    }

    //----------- External Functions -----------//
    /**
     * @notice Process the received BNBs.
     */
    receive() external payable {
        _depositWrap(msg.value);
    }

    /**
     * @notice Check if a wallet address is in stake.
     * @return Boolean if in stake or not.
     */
    function isInPool(address wallet_) public view returns (bool) {
        return stakeHolders[wallet_].stakedBal > 0;
    }

    /**
     * @notice Check amount of BNBs per block for APY calculation.
     * @return uint256 amount of BNBs per block.
     */
    function getRewardsXblock() public view returns (uint256) {
        if (initialBLock == lastBlock) return 0;
        uint256 elapsedBlocks = lastBlock.sub(initialBLock);
        return totalDistributed.div(elapsedBlocks);
    }

    /**
     * @notice Check the reward amount of a specific token plus the processed balance and pending update.
     * @param wallet_ Address of the wallet to check.
     * @return Amount of reward plus the processed for that token.
     */
    function getPendingBal(address wallet_) external view returns (uint256) {
        uint256 processedBal = _getPendingBal(wallet_);
        uint256 balance = address(this).balance;
        uint256 processed = unclaimedTokens.add(processedTokens);
        if (balance > processed) {
            uint256 pending = balance.sub(processed);
            {
                if (pending > 1000000) {
                    address holder = wallet_;
                    uint256 oldTokenPoints = pointsXtoken.add(
                        (pending.mul(10e18)).div(totalStaked)
                    );
                    uint256 newTokenPoints = oldTokenPoints.sub(
                        stakeHolders[holder].tokenPoints
                    );
                    uint256 pendingBal = stakeHolders[wallet_].pendingTokenbal;
                    uint256 unprocessedBal = (
                        stakeHolders[holder].stakedBal.mul(newTokenPoints)
                    ).div(10e18);
                    return unprocessedBal.add(pendingBal);
                }
            }
        }
        return processedBal;
    }

    /**
     * @notice Check the info of stake for a wallet.
     * @param wallet_ Address of the wallet to check.
     * @return stakedBal amount of tokens staked.
     * @return startTime date in timestamp of the stake started.
     */
    function getWalletInfo(address wallet_)
        external
        view
        returns (uint256 stakedBal, uint256 startTime)
    {
        Wallet storage w = stakeHolders[wallet_];
        return (w.stakedBal, w.startTime);
    }

    /**
     * @notice Stake tokens to receive rewards.
     * @param amount_ Amount of tokens to deposit.
     */
    function stake(uint256 amount_) external whenNotPaused nonReentrant {
        require(amount_ > 0, "Zero amount");
        if (isInPool(_msgSender())) {
            _addStake(_msgSender(), amount_);
        } else {
            _initStake(_msgSender(), amount_);
        }
        emit AddedPoints(_msgSender(), amount_);
    }

    /**
     * @notice Change wallet to new wallet.
     * @param _newAcount Address of new wallet.
     */
    function migrateWallet(address _newAcount)
        external
        whenNotPaused
        nonReentrant
    {
        require(isInPool(_msgSender()), "Vault: Not in pool");
        require(_newAcount != address(0), "Vault: zero address");
        _recalculateBalances();
        _harvest(_msgSender());
        Wallet memory w = stakeHolders[_msgSender()];
        delete stakeHolders[_msgSender()];
        stakeHolders[_newAcount] = w;
        emit WalletMigrated(_msgSender(), _newAcount);
    }

    /**
     * @notice Withdraw rewards.
     */
    function harvest() external nonReentrant {
        require(isInPool(_msgSender()), "Not in pool");
        _recalculateBalances();
        _harvest(_msgSender());
    }

    /**
     * @notice Remove tokens from pool.
     */
    function removeStake() external nonReentrant {
        require(isInPool(_msgSender()), "Not in pool");
        _harvest(_msgSender());
        uint256 stakedBal = stakeHolders[_msgSender()].stakedBal;
        totalStaked -= stakedBal;
        delete stakeHolders[_msgSender()];
        SWC.transfer(_msgSender(), stakedBal);
        totalHolders.decrement();
        emit RemovedPoints(_msgSender(), stakedBal);
    }

    /**
     * @notice Get invalid tokens and send to Governor.
     * @param token_ address of token to send.
     */
    function getInvalidTokens(address to_, address token_) external onlyOwner {
        require(to_ != address(0x0) && token_ != address(0x0), "Zero address");
        require(token_ != address(SWC), "Invalid token");
        uint256 balance = IERC20(token_).balanceOf(address(this));
        IERC20(token_).transfer(to_, balance);
    }

    /**
     * @notice Function for pause and unpause the contract.
     */
    function togglePause() external onlyOwner {
        paused() ? _unpause() : _pause();
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