// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "../libraries/math/SafeMath.sol";
import "../libraries/access/Ownable.sol";
import "../libraries/utils/ReentrancyGuard.sol";
import "../libraries/utils/Address.sol";
import "../libraries/utils/Pausable.sol";
import "../libraries/token/IERC20.sol";
import "../libraries/token/SafeERC20.sol";
import "../core/interfaces/IJlpManager.sol";
import "../tokens/interfaces/IWETH.sol";

/**
 * @title JlpPool
 * @notice Distribute exchange profits among JLP holders.
 */
contract JlpPool is ReentrancyGuard, Pausable, Ownable {
    //---------- Libraries ----------//
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address payable;

    //---------- Contracts ----------//
    IERC20 public immutable JLP; // JLP token contract.
    IJlpManager public immutable jlpManager; // JlpManager token contract.
    IWETH public immutable WETH; // JlpManager token contract.

    //---------- Variables ----------//
    uint256 public constant cooldownDuration = 15 minutes; // Duration to be elapsed beetwen stake and unstake.
    uint256 public totalHolders; // Total wallets in pool.
    uint256 public totalDistributed; // Total BNB distributed to holders.
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
        // Date in timestamp.
        uint256 lastAddedAt;
        // shared points.
        uint256 tokenPoints;
        // pending rewards.
        uint256 pendingTokenbal;
    }

    mapping(address => Wallet) private stakeHolders; // Struct map of wallets in pool.
    mapping(address => bool) private cooldownExcluded; // Exclusions for cooldown duration.

    //---------- Events -----------//
    event Deposit(uint256 amount, uint256 totalStaked);
    event Withdrawn(address indexed payee, uint256 amount);
    event AddedPoints(address indexed wallet, uint256 amount);
    event RemovedPoints(address indexed wallet, uint256 amount);

    event AddLiquidity(
        address account,
        address token,
        uint256 amountIn,
        uint256 amountOut
    );

    event RemoveLiquidity(
        address account,
        address token,
        uint256 amountIn,
        uint256 amountOut
    );

    //---------- Constructor ----------//
    constructor(
        address weth_,
        address jlp_,
        address jlpManager_
    ) public {
        WETH = IWETH(weth_);
        JLP = IERC20(jlp_);
        jlpManager = IJlpManager(jlpManager_);
        initialBLock = block.number;
        lastBlock = block.number;
    }

    //----------- Internal Functions -----------//
    /**
     * @notice Check the reward amount.
     * @param wallet_ Address of the wallet to check.
     * @return Amount of reward.
     */
    function _getRewards(address wallet_) private view returns (uint256) {
        uint256 newTokenPoints = pointsXtoken.sub(
            stakeHolders[wallet_].tokenPoints
        );
        return (stakeHolders[wallet_].stakedBal.mul(newTokenPoints)).div(10e18);
    }

    /**
     * @dev Process pending rewards from a wallet.
     * @param wallet_ address of the wallet to be processed.
     */
    function _processRewards(address wallet_) private {
        uint256 rewards = _getRewards(wallet_);
        if (rewards > 0) {
            unclaimedTokens = unclaimedTokens.sub(rewards);
            processedTokens = processedTokens.add(rewards);
            stakeHolders[wallet_].tokenPoints = pointsXtoken;
            stakeHolders[wallet_].pendingTokenbal = stakeHolders[wallet_]
                .pendingTokenbal
                .add(rewards);
        }
    }

    /**
     * @dev Withdraw pending rewards from a wallet.
     * @param _wallet address of the wallet to withdraw.
     */
    function _harvest(address payable _wallet) private {
        _processRewards(_wallet);
        uint256 amount = stakeHolders[_wallet].pendingTokenbal;
        if (amount > 0) {
            stakeHolders[_wallet].pendingTokenbal = 0;
            processedTokens = processedTokens.sub(amount);
            _wallet.sendValue(amount);
            emit Withdrawn(_wallet, amount);
        }
    }

    /**
     * @dev Compund pending rewards from a wallet.
     * @param _wallet address of the wallet to make compound.
     */
    function _compound(address payable _wallet) private {
        _processRewards(_wallet);
        uint256 amount = stakeHolders[_wallet].pendingTokenbal;
        if (amount > 0) {
            stakeHolders[_wallet].pendingTokenbal = 0;
            processedTokens = processedTokens.sub(amount);
            WETH.deposit{value: amount}();
            IERC20(address(WETH)).approve(address(jlpManager), amount);
            uint256 jlpAmount = jlpManager.addLiquidityForAccount(
                address(this),
                address(this),
                address(WETH),
                amount,
                0,
                0
            );
            stakeHolders[_wallet].stakedBal = stakeHolders[_wallet]
                .stakedBal
                .add(jlpAmount);
            totalStaked = totalStaked.add(jlpAmount);
            emit AddedPoints(_wallet, jlpAmount);            
            emit AddLiquidity(_wallet, address(WETH), amount, jlpAmount);
        }
    }

    /**
     * @dev Add a wallet to stake for the first time.
     * @param wallet_ address of the wallet to add.
     * @param amount_ amount to add.
     */
    function _initStake(address wallet_, uint256 amount_) private {
        Wallet storage w = stakeHolders[wallet_];
        w.tokenPoints = pointsXtoken;
        w.lastAddedAt = block.timestamp;
        w.stakedBal = amount_;
        totalStaked = totalStaked.add(amount_);
        totalHolders = totalHolders.add(1);
    }

    /**
     * @dev Add more tokens to stake from an existing wallet.
     * @param wallet_ address of the wallet.
     * @param amount_ amount to add.
     */
    function _addStake(address wallet_, uint256 amount_) private {
        _processRewards(wallet_);
        stakeHolders[wallet_].stakedBal = stakeHolders[wallet_].stakedBal.add(
            amount_
        );
        stakeHolders[wallet_].lastAddedAt = block.timestamp;
        totalStaked = totalStaked.add(amount_);
    }

    /**
     * @dev Check the reward amount of a specific token plus the processed balance.
     * @param wallet_ Address of the wallet to check.
     * @return Amount of reward plus the processed for that token.
     */
    function _getPendingBal(address wallet_) private view returns (uint256) {
        uint256 newTokenPoints = pointsXtoken.sub(
            stakeHolders[wallet_].tokenPoints
        );
        uint256 pending = stakeHolders[wallet_].pendingTokenbal;
        return
            (stakeHolders[wallet_].stakedBal.mul(newTokenPoints))
                .div(10e18)
                .add(pending);
    }

    function _validateCooldown(address _wallet) private view returns (bool) {
        if (cooldownExcluded[_wallet]) {
            return true;
        }
        return
            stakeHolders[_wallet].lastAddedAt.add(cooldownDuration) <=
            block.timestamp;
    }

    //----------- External Functions -----------//
    /**
     * @dev Disallows direct send by setting a default function without the `payable` flag.
     */
    fallback() external {}

    receive() external payable {
        require(msg.sender == address(WETH), "JlpPool: invalid sender");
    }

    /**
     * @dev Deposit BNB.
     */
    function deposit() external payable nonReentrant {
        uint256 amount = msg.value;
        require(totalStaked > 0 && amount >= 1000000, "Invalid deposit");
        pointsXtoken = pointsXtoken.add(amount.mul(10e18).div(totalStaked));
        unclaimedTokens = unclaimedTokens.add(amount);
        totalDistributed = totalDistributed.add(amount);
        lastBlock = block.number;
        emit Deposit(amount, totalStaked);
    }

    /**
     * @notice Check if a wallet address is in stake.
     * @return Boolean if in stake or not.
     */
    function isInPool(address wallet_) public view returns (bool) {
        return stakeHolders[wallet_].stakedBal > 0;
    }

    /**
     * @notice Check amount of BNB per block for APY calculation.
     * @return uint256 amount of BNB per block.
     */
    function getRewardsXblock() public view returns (uint256) {
        if (initialBLock == lastBlock) return 0;
        uint256 elapsedBlocks = lastBlock.sub(initialBLock);
        return totalDistributed.div(elapsedBlocks);
    }

    /**
     * @dev Check the reward amount plus the processed balance.
     * @param wallet_ Address of the wallet to check.
     * @return Amount of reward plus the processed for that token.
     */
    function getPendingBal(address wallet_) public view returns (uint256) {
        uint256 newTokenPoints = pointsXtoken.sub(
            stakeHolders[wallet_].tokenPoints
        );
        uint256 pending = stakeHolders[wallet_].pendingTokenbal;
        return
            (stakeHolders[wallet_].stakedBal.mul(newTokenPoints))
                .div(10e18)
                .add(pending);
    }

    /**
     * @notice Check the info of stake for a wallet.
     * @param wallet_ Address of the wallet to check.
     * @return stakedBal amount of tokens staked.
     * @return lastAddedAt date in timestamp of the last deposit.
     * @return rewards amount of rewards plus the processed.
     */
    function getWalletInfo(address wallet_)
        external
        view
        returns (
            uint256 stakedBal,
            uint256 lastAddedAt,
            uint256 rewards
        )
    {
        Wallet storage w = stakeHolders[wallet_];
        return (w.stakedBal, w.lastAddedAt, getPendingBal(wallet_));
    }

    /**
     * @notice Stake tokens to receive rewards.
     * @param _token token to deposit.
     * @param _amount Amount of tokens to deposit.
     * @param _minUsdj Min value of USDJ.
     * @param _minJlp  Min value of JLP.
     */
    function stake(
        address _token,
        uint256 _amount,
        uint256 _minUsdj,
        uint256 _minJlp
    ) external whenNotPaused nonReentrant {
        require(_amount > 0, "Zero amount");
        address account = _msgSender();
        uint256 jlpAmount = jlpManager.addLiquidityForAccount(
            account,
            address(this),
            _token,
            _amount,
            _minUsdj,
            _minJlp
        );
        require(jlpAmount >= 1 gwei, "JLP too low");
        if (isInPool(account)) {
            _addStake(account, jlpAmount);
        } else {
            _initStake(account, jlpAmount);
        }
        emit AddedPoints(account, jlpAmount);
        emit AddLiquidity(account, _token, _amount, jlpAmount);
    }

    /**
     * @notice Stake tokens to receive rewards.
     * @param _minUsdj Min value of USDJ.
     * @param _minJlp  Min value of JLP.
     */
    function stakeETH(uint256 _minUsdj, uint256 _minJlp)
        external
        payable
        whenNotPaused
        nonReentrant
    {
        uint256 amount = msg.value;
        require(amount > 0, "Zero amount");

        WETH.deposit{value: amount}();
        IERC20(address(WETH)).approve(address(jlpManager), amount);

        address account = _msgSender();
        uint256 jlpAmount = jlpManager.addLiquidityForAccount(
            address(this),
            address(this),
            address(WETH),
            amount,
            _minUsdj,
            _minJlp
        );
        require(jlpAmount >= 1 gwei, "JLP too low");
        if (isInPool(account)) {
            _addStake(account, jlpAmount);
        } else {
            _initStake(account, jlpAmount);
        }
        emit AddedPoints(account, jlpAmount);
        emit AddLiquidity(account, address(WETH), amount, jlpAmount);
    }

    /**
     * @notice Withdraw rewards.
     */
    function harvest() external nonReentrant {
        require(isInPool(_msgSender()), "Not in pool");
        _harvest(_msgSender());
    }

    /**
     * @notice Compound rewards.
     */
    function compound() external nonReentrant {
        require(isInPool(_msgSender()), "Not in pool");
        _compound(_msgSender());
    }

    /**
     * @notice Withdraw tokens from pool.
     */
    function withdrawn(
        address _tokenOut,
        uint256 _flpAmount,
        uint256 _minOut,
        address _receiver
    ) external nonReentrant returns (uint256) {
        address payable account = _msgSender();
        uint256 amount = _flpAmount;
        require(isInPool(account), "Not in pool");
        require(amount > 0, "Zero amount");
        require(_validateCooldown(account), "Cooldown duration not yet passed");
        _harvest(account);
        uint256 stakedBal = stakeHolders[account].stakedBal;
        bool unStake = amount >= stakedBal;
        amount = unStake ? stakedBal : amount;
        if (unStake) {
            delete stakeHolders[account];
            totalHolders = totalHolders.sub(1);
        } else {
            stakeHolders[account].stakedBal = stakeHolders[account]
                .stakedBal
                .sub(amount);
        }
        uint256 amountOut = jlpManager.removeLiquidityForAccount(
            address(this),
            _tokenOut,
            _flpAmount,
            _minOut,
            _receiver
        );
        totalStaked = totalStaked.sub(amount);
        emit RemovedPoints(account, amount);
        emit RemoveLiquidity(account, _tokenOut, amount, amountOut);
        return amountOut;
    }

    /**
     * @notice Withdraw ETH from pool.
     */
    function withdrawnETH(
        uint256 _jlpAmount,
        uint256 _minOut,
        address payable _receiver
    ) external nonReentrant returns (uint256) {
        address payable account = _msgSender();
        uint256 amount = _jlpAmount;
        require(isInPool(account), "Not in pool");
        require(amount > 0, "Zero amount");
        require(_validateCooldown(account), "Cooldown duration not yet passed");
        _harvest(account);
        uint256 stakedBal = stakeHolders[account].stakedBal;
        bool unStake = amount >= stakedBal;
        amount = unStake ? stakedBal : amount;
        if (unStake) {
            delete stakeHolders[account];
            totalHolders = totalHolders.sub(1);
        } else {
            stakeHolders[account].stakedBal = stakeHolders[account]
                .stakedBal
                .sub(amount);
        }
        totalStaked = totalStaked.sub(amount);
        uint256 amountOut = jlpManager.removeLiquidityForAccount(
            address(this),
            address(WETH),
            amount,
            _minOut,
            address(this)
        );
        WETH.withdraw(amountOut);
        _receiver.sendValue(amountOut);
        emit RemovedPoints(account, amount);
        emit RemoveLiquidity(account, address(WETH), amount, amountOut);
        return amountOut;
    }

    /**
     * @notice Withdraw tokens from pool without rewards.
     */
    function emergencyWithdrawn() external whenPaused nonReentrant {
        address payable account = _msgSender();
        require(isInPool(account), "Not in pool");
        uint256 stakedBal = stakeHolders[account].stakedBal;
        delete stakeHolders[account];
        totalHolders = totalHolders.sub(1);
        JLP.safeTransfer(account, stakedBal);
        totalStaked = totalStaked.sub(stakedBal);
        emit RemovedPoints(account, stakedBal);
    }

    /**
     * @notice Get invalid tokens and send to Governor.
     * @param token_ address of token to send.
     */
    function getInvalidTokens(address to_, address token_) external onlyOwner {
        require(to_ != address(0x0) && token_ != address(0x0), "Zero address");
        require(token_ != address(JLP), "Invalid token");
        uint256 balance = IERC20(token_).balanceOf(address(this));
        IERC20(token_).safeTransfer(to_, balance);
    }

    /**
     * @notice Function set cooldown exclusions.
     */
    function setCooldownExclusion(address _wallet, bool _set)
        external
        onlyOwner
    {
        require(_wallet != address(0), "Invalid address");
        cooldownExcluded[_wallet] = _set;
    }

    /**
     * @notice Function for pause and unpause the contract.
     */
    function togglePause() external onlyOwner {
        paused() ? _unpause() : _pause();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "../GSN/Context.sol";
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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

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
contract ReentrancyGuard {
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

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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

pragma solidity 0.6.12;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "../GSN/Context.sol";

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
    constructor() public {
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

pragma solidity 0.6.12;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./IERC20.sol";
import "../math/SafeMath.sol";
import "../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.3._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.3._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

pragma solidity 0.6.12;

interface IJlpManager {
    function usdj() external view returns (address);

    function cooldownDuration() external returns (uint256);

    function getAumInUsdj(bool maximise) external view returns (uint256);

    function lastAddedAt(address _account) external returns (uint256);

    function addLiquidity(
        address _token,
        uint256 _amount,
        uint256 _minUsdj,
        uint256 _minJlp
    ) external returns (uint256);

    function addLiquidityForAccount(
        address _fundingAccount,
        address _account,
        address _token,
        uint256 _amount,
        uint256 _minUsdj,
        uint256 _minJlp
    ) external returns (uint256);

    function removeLiquidity(
        address _tokenOut,
        uint256 _jlpAmount,
        uint256 _minOut,
        address _receiver
    ) external returns (uint256);

    function removeLiquidityForAccount(
        address _account,
        address _tokenOut,
        uint256 _jlpAmount,
        uint256 _minOut,
        address _receiver
    ) external returns (uint256);

    function setShortsTrackerAveragePriceWeight(
        uint256 _shortsTrackerAveragePriceWeight
    ) external;

    function setCooldownDuration(uint256 _cooldownDuration) external;
}

//SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}