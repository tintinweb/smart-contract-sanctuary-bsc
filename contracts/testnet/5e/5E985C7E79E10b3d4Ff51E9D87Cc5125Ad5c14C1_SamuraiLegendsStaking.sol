// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
     .....................................................                      
    . ...........................................................               
.....................................................................           
..................................................,.................... ....    
......................................##((#..,,,,,,,,......................     
....................................&@@&@%%&&.,,,,,,,.....................      
...........................,.,..,%(@@@@&.&&%##/(,,,......................... .  
........................,,,,...&@@@@#@ [email protected]/##%&@..........................    
.................,....,,,,,,%*@@@@%..,,,,,,,, &&%#%((...........................
................,.,,,,,,,[email protected]@@@@#@ ,,,,,@%@.,,,. @(%%&&&.........................
.............,,,,,,,,,,##@&@&%.,,,,,(%@@@@@#(..... %@@@@/#......................
..............,,,,,,.&&@&@(@.,,,,,@%@@@@ &@@@&@.,,.. &/&&@@@....................
...........,,,,,,,(%&&&@& ,,,,,,@#&&@@,,,, @@@@%&..,... @@&&@((.,,..............
...........,,,,[email protected]@@&@#@.,,,,,@&/,,*@&&&%@(@@@&(..*@@.,,,..&(&&@@@...............
..........,,,(&@@@@@ ,,,,,/@@@@@&@%%@@(@@&/@%#%@%@@@@&#,,,,. @@@@@#(............
[email protected]@@@@&@.,,,,,@&@@@@&%@@@@*,.*@/.,,@@@@#@@@@@&@.,,,..&(@@@@@..........
........%&@@@@&.,,,,,,&@@@%%.,,, @@@@&&,,,@%@@@@.,,,.&*@@@&*,,,.. @@@@@&#.......
.......... @@@@@@&,,,,,[email protected]&@@@@%&@@@&*.,,@*,.*@@@@%&@@@@&@ ,,,..&(@@@@@ .........
.........,,,.&@@@@@@,,,,,,*@@@@@&@@@@@&@@@&@@@@@%@@@@%%,,,,, @@@@@(@............
.........,,,,,, @@@@@@&,,,,, @@*..,@@@@&@%@@@@/,,*@@ ,,,,,&(@@@@@ ..............
........,,,,,,,,,.&@@@@@@,,,,,,.&&@@@@ .,. @@@@&@,,,,,,[email protected]@@@@(@.................
........,,,,,,,,,,,, @&@@@@&,,,,, @&@@@@[email protected]@@@&@ ,,,,.%(@@@@@ ...................
........,,,,,,,,,,,,,,.&@@@@@@,,.,..*&@@@@@&/,,,,,[email protected]@@@@(@......................
.........,,,,,,,,,,,,,,,, @&@@@@&.,,.. @%@.,,,,.#%@@@@& ........................
..........,,,,,,,,,,,,,,,,,.&&&@@@@...,,,,,,,[email protected]@@@&#&...........................
.......,...,,,,,,,,,,,,,,,,,.. &%&&@@&,,,,,%&&&&@% .............................
............,,,,,,,,,,,,,,,,.... &@&&@@&.&@&&&%&................................
.................,,,,,,,,,,........ &%&&@&&&% ..................................
.....................,,,,,.........,,.&&%&@...................................  
..................................,,,,.. ....................................   
..................................,,.......................................     
.........................................................................           
*/  

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Recoverable.sol";
import "./Generatable.sol";
import "./Array.sol";


struct Fee {
    uint128 numerator;
    uint128 denominator;
}

struct PendingPeriod {
    uint128 repeat;
    uint128 period;
}

struct PendingAmount {
    uint32 createdAt;
    uint112 fullAmount;
    uint112 claimedAmount;
    PendingPeriod pendingPeriod;
}

/**
@title Contract that adds auto-compounding staking functionalities
@author Leo
@notice Stake any ERC20 token in a auto-compounding way using this contract
*/
contract SamuraiLegendsStaking is Ownable, Pausable, Generatable, Recoverable {
    using Array for uint[];

    IERC20 private immutable _token;

    uint160 public rewardRate;
    uint32 public rewardDuration = 12 weeks;
    uint32 private _rewardUpdatedAt = uint32(block.timestamp);
    uint32 public rewardFinishedAt;

    uint private _totalStake;
    mapping(address => uint) private _userStake;
    
    uint128 private _rewardPerToken;
    uint128 private _lastRewardPerTokenPaid;
    mapping(address => uint) private _userRewardPerTokenPaid;

    Fee public fee = Fee(0, 1000);

    PendingPeriod public pendingPeriod = PendingPeriod({ repeat: 4, period: 7 days });
    mapping(address => uint[]) private _userPendingIds;
    mapping(address => mapping(uint => PendingAmount)) private _userPending;

    /**
    @param token The ERC20 token address to enable staking for
    */
    constructor(IERC20 token) {
        _token = token;
    }

    /**
    @notice compute the compounded total stake in real-time
    @return totalStake The current compounded total stake
    */
    function totalStake() public view returns (uint) {
        return _totalStake + _earned(_totalStake, _lastRewardPerTokenPaid);
    }

    /**
    @notice compute the compounded user stake in real-time
    @param account The user address to use
    @return userStake The current compounded user stake
    */
    function userStake(address account) public view returns (uint) {
        return _userStake[account] + earned(account);
    }

    /**
    @notice return the user pending amount metadata 
    @param account The user address to use
    @param index The user pending index to use
    @return pendingAmount The user pending amount metadata 
    */
    function userPending(address account, uint index) public view returns (PendingAmount memory) {
        uint id = _userPendingIds[account][index];
        return _userPending[account][id];
    }

    /**
    @notice compute the user claimable pending percentage
    @param account The user address to use
    @param index The user pending index to use
    @dev 18 decimals were used to not lose information
    @return percentage The user claimable pending percentage
    */
    function userClaimablePendingPercentage(address account, uint index) public view returns (uint) {
        PendingAmount memory pendingAmount = userPending(account, index);
        uint n = getClaimablePendingPortion(pendingAmount);
        return n >= pendingAmount.pendingPeriod.repeat ? 100 * 1e9 : (n * 100 * 1e9) / pendingAmount.pendingPeriod.repeat;
    }

    /**
    @notice return the user pending ids
    @param account The user address to use
    @return ids The user pending ids
    */
    function userPendingIds(address account) public view returns (uint[] memory) {
        return _userPendingIds[account];
    }

    /**
    @notice the last time rewards were updated
    @return lastTimeRewardActiveAt A timestamp of the last time the update reward modifier was called
    */
    function lastTimeRewardActiveAt() public view returns (uint) {
        return rewardFinishedAt > block.timestamp ? block.timestamp : rewardFinishedAt;
    }

    /**
    @notice the current reward per token value
    @return rewardPerToken The accumulated reward per token value
    */
    function rewardPerToken() public view returns (uint) {
        if (_totalStake == 0) {
            return _rewardPerToken;
        }

        return _rewardPerToken + ((lastTimeRewardActiveAt() - _rewardUpdatedAt) * rewardRate * 1e9) / _totalStake;
    }

    /**
    @notice the total rewards available
    @return totalDurationReward The total expected rewards for the current reward duration
    */
    function totalDurationReward() public view returns (uint) {
        return rewardRate * rewardDuration;
    }

    /**
    @notice the user earned rewards
    @param account The user address to use
    @return earned The user earned rewards
    */
    function earned(address account) private view returns (uint) {
        return _earned(_userStake[account], _userRewardPerTokenPaid[account]);
    }

    /**
    @notice the accumulated rewards for a given staking amount
    @param stakeAmount The staked token amount
    @param rewardPerTokenPaid The already paid reward per token
    @return _earned The earned rewards based on a staking amount and the reward per token paid
    */
    function _earned(uint stakeAmount, uint rewardPerTokenPaid) internal view returns (uint) {
        uint rewardPerTokenDiff = rewardPerToken() - rewardPerTokenPaid;
        return (stakeAmount * rewardPerTokenDiff) / 1e9;
    }

    /**
    @notice this modifier is used to update the rewards metadata for a specific account
    @notice it is called for every user or owner interaction that changes the staking, the reward pool or the reward duration
    @notice this is an extended modifier version of the Synthetix contract to support auto-compounding
    @notice _rewardPerToken is accumulated every second
    @notice _rewardUpdatedAt is updated for every interaction with this modifier
    @param account The user address to use
    */
    modifier updateReward(address account) {
        _rewardPerToken = uint128(rewardPerToken());
        _rewardUpdatedAt = uint32(lastTimeRewardActiveAt());
        
        // auto-compounding
        if (account != address(0)) {
            uint reward = earned(account);

            _userRewardPerTokenPaid[account] = _rewardPerToken;
            _lastRewardPerTokenPaid = _rewardPerToken;

            _userStake[account] += reward;
            _totalStake += reward;
        }
        _;
    }

    /**
    @notice stake an amount of the ERC20 token
    @param amount The amount to stake
    */
    function stake(uint amount) public whenNotPaused updateReward(msg.sender) {
        // checks
        require(amount > 0, "Invalid input amount.");

        // effects
        _totalStake += amount;
        _userStake[msg.sender] += amount;

        // interactions
        require(_token.transferFrom(msg.sender, address(this), amount), "Transfer failed.");

        emit Staked(msg.sender, amount);
    }

    /**
    @notice create a new pending after withdrawal
    @param amount The amount to create pending for
    */
    function createPending(uint amount) internal {
        uint id = unique();
        _userPendingIds[msg.sender].push(id);
        _userPending[msg.sender][id] = PendingAmount({  
            createdAt: uint32(block.timestamp), 
            fullAmount: uint112(amount), 
            claimedAmount: 0,
            pendingPeriod: pendingPeriod
        });

        emit PendingCreated(msg.sender, block.timestamp, amount);
    }

    /**
    @notice cancel an existing pending
    @param index The pending index to cancel
    */
    function cancelPending(uint index) external whenNotPaused updateReward(msg.sender) {
        PendingAmount memory pendingAmount = userPending(msg.sender, index);
        uint amount = pendingAmount.fullAmount - pendingAmount.claimedAmount;
        deletePending(index);

        // effects
        _totalStake += amount;
        _userStake[msg.sender] += amount;

        emit PendingCanceled(msg.sender, pendingAmount.createdAt, pendingAmount.fullAmount);
    }

    /**
    @notice delete an existing pending
    @param index The pending index to delete
    */
    function deletePending(uint index) internal {
        uint[] storage ids = _userPendingIds[msg.sender];
        uint id = ids[index];
        ids.remove(index);
        delete _userPending[msg.sender][id];
    }

    /**
    @notice withdraw an amount of the ERC20 token
    @notice when you withdraw a pending will be created for that amount
    @notice you will be able to claim the pending for after an exact vesting period
    @param amount The amount to withdraw
    */
    function _withdraw(uint amount) internal {
        // effects
        _totalStake -= amount;
        _userStake[msg.sender] -= amount;

        createPending(amount);

        emit Withdrawn(msg.sender, amount);
    }

    /**
    @notice withdraw an amount of the ERC20 token
    @param amount The amount to withdraw
    */
    function withdraw(uint amount) external updateReward(msg.sender) {
        // checks
        require(_userStake[msg.sender] > 0, "User has no active stake.");
        require(amount > 0 && _userStake[msg.sender] >= amount, "Invalid input amount.");

        // effects
        _withdraw(amount);
    }

    /**
    @notice withdraw the full amount of the ERC20 token
    */
    function withdrawAll() external updateReward(msg.sender) {
        // checks
        require(_userStake[msg.sender] > 0, "User has no active stake.");

        // effects
        _withdraw(_userStake[msg.sender]);
    }

    /**
    @notice get the user claimable pending portion
    @param pendingAmount The pending amount metadata to use
    */
    function getClaimablePendingPortion(PendingAmount memory pendingAmount) private view returns (uint) {
        return (block.timestamp - pendingAmount.createdAt) / pendingAmount.pendingPeriod.period; // 0 1 2 3 4
    }

    /**
    @notice update the claiming fee
    @param numerator The fee numerator
    @param denominator The fee denominator
    */
    function setFee(uint128 numerator, uint128 denominator) external onlyOwner {
        require(denominator != 0, "Denominator must not equal 0.");
        fee = Fee(numerator, denominator);
        emit FeeUpdated(numerator, denominator);
    }

    /**
    @notice user can claim a specific pending by index
    @param index The pending index to claim
    */
    function claim(uint index) external {
        // checks
        uint id = _userPendingIds[msg.sender][index];
        PendingAmount storage pendingAmount = _userPending[msg.sender][id];

        uint n = getClaimablePendingPortion(pendingAmount);
        require(n != 0, "Claim is still pending.");

        uint amount;
        /**
        @notice N is the user claimable pending portion
        @notice checking if user N and the user MAX N are greater than or equal
        @notice that way we know if want to claim the full amount or just part of it
        */
        if (n >= pendingAmount.pendingPeriod.repeat) {
            amount = pendingAmount.fullAmount - pendingAmount.claimedAmount;
        } else {
            uint percentage = (n * 1e9) / pendingAmount.pendingPeriod.repeat;
            amount = (pendingAmount.fullAmount * percentage) / 1e9 - pendingAmount.claimedAmount;
        }
        
        // effects
        /**
        @notice pending is completely done
        @notice we will remove the pending item
        */
        if (n >= pendingAmount.pendingPeriod.repeat) {
            uint createdAt = pendingAmount.createdAt;
            uint fullAmount = pendingAmount.fullAmount;
            deletePending(index);
            emit PendingFinished(msg.sender, createdAt, fullAmount);
        } 
        /**
        @notice pending is partially done
        @notice we will update the pending item
        */
        else {
            pendingAmount.claimedAmount += uint112(amount);
            emit PendingUpdated(msg.sender, pendingAmount.createdAt, pendingAmount.fullAmount);
        }
        
        // interactions
        uint feeAmount = amount * fee.numerator / fee.denominator;
        _token.transfer(msg.sender, amount - feeAmount);

        emit Claimed(msg.sender, amount);
    }

    /**
    @notice owner can add staking rewards
    @param _reward The reward amount to add
    */
    function addReward(uint _reward) external onlyOwner updateReward(address(0)) {
        // checks
        require(_reward > 0, "Invalid input amount.");

        if (block.timestamp > rewardFinishedAt) { // Reward duration finished
            rewardRate = uint160(_reward / rewardDuration);
        } else {
            uint remainingReward = rewardRate * (rewardFinishedAt - block.timestamp);
            rewardRate = uint160((remainingReward + _reward) / rewardDuration);
        }

        // effects
        _rewardUpdatedAt = uint32(block.timestamp);
        rewardFinishedAt = uint32(block.timestamp + rewardDuration);

        // interactions
        require(_token.transferFrom(owner(), address(this), _reward), "Transfer failed.");

        emit RewardAdded(_reward);
    }

    /**
    @notice owner can decrease staking rewards only if the duration isn't finished yet
    @notice decreasing rewards doesn't alter the reward finish time
    @param _reward The reward amount to decrease
    */
    function decreaseReward(uint _reward) external onlyOwner updateReward(address(0)) {
        // checks
        require(_reward > 0, "Invalid input amount.");
        require(block.timestamp <= rewardFinishedAt, "Reward duration finished.");

        uint remainingReward = rewardRate * (rewardFinishedAt - block.timestamp);
        require(remainingReward > _reward, "Invalid input amount.");

        // effects
        rewardRate = uint160((remainingReward - _reward) / (rewardFinishedAt - block.timestamp));
        _rewardUpdatedAt = uint32(block.timestamp);

        // interactions
        _token.transfer(owner(), _reward);

        emit RewardDecreased(_reward);
    }

    /**
    @notice owner can rest all rewards and reward finish time back to 0
    */
    function resetReward() external onlyOwner updateReward(address(0)) {
        if (rewardFinishedAt <= block.timestamp) {
            rewardRate = 0;
            _rewardUpdatedAt = uint32(block.timestamp);
            rewardFinishedAt = uint32(block.timestamp);
        } else  {
            // checks
            uint remainingReward = rewardRate * (rewardFinishedAt - block.timestamp);

            // effects
            rewardRate = 0;
            _rewardUpdatedAt = uint32(block.timestamp);
            rewardFinishedAt = uint32(block.timestamp);

            // interactions
            _token.transfer(owner(), remainingReward);
        }

        emit RewardReseted();
    }

    /**
    @notice owner can update the reward duration
    @notice it can only be updated if the old reward duration is already finished
    @param _rewardDuration The reward _rewardDuration to use
    */
    function updateRewardDuration(uint32 _rewardDuration) external onlyOwner {
        require(block.timestamp > rewardFinishedAt, "Reward duration must be finalized.");

        rewardDuration = _rewardDuration;

        emit RewardDurationUpdated(_rewardDuration);
    }

    /**
    @notice owner can update the pending period
    @notice if we want a vesting period of 28 days 4 times, we can have the repeat as 4 and the period as 7 days
    @param repeat The number of times to keep a withdrawal pending 
    @param period The period between each repeat
    */
    function updatePendingPeriod(uint128 repeat, uint128 period) external onlyOwner {
        pendingPeriod = PendingPeriod(repeat, period);
        emit PendingPeriodUpdated(repeat, period);
    }

    /**
    @notice owner can pause the staking contract
    */
    function pause() external whenNotPaused onlyOwner {
        _pause();
    }

    /**
    @notice owner can resume the staking contract
    */
    function unpause() external whenPaused onlyOwner {
        _unpause();
    }

    event Staked(address indexed account, uint amount);
    event PendingCreated(address indexed account, uint createdAt, uint amount);
    event PendingUpdated(address indexed account, uint createdAt, uint amount);
    event PendingFinished(address indexed account, uint createdAt, uint amount);
    event PendingCanceled(address indexed account, uint createdAt, uint amount);
    event Withdrawn(address indexed account, uint amount);
    event Claimed(address indexed account, uint amount);
    event RewardAdded(uint amount);
    event RewardDecreased(uint amount);
    event RewardReseted();
    event RewardDurationUpdated(uint duration);
    event PendingPeriodUpdated(uint repeat, uint period);
    event FeeUpdated(uint numerator, uint denominator);
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
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
@title Recoverable
@author Leo
@notice Recovers stucked BNB or ERC20 tokens
@dev You can inhertit from this contract to support recovering stucked tokens or BNB
*/
contract Recoverable is Ownable {
    /**
    @notice Recovers stucked ERC20 token in the contract
    @param token An ERC20 token address
    */
    function recoverERC20(address token, uint amount) external onlyOwner {
        IERC20 erc20 = IERC20(token);
        require(erc20.balanceOf(address(this)) >= amount, "Invalid input amount.");

        erc20.transfer(owner(), amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
@title Generatable
@author Leo
@notice Generates a unique id
*/
contract Generatable {
    uint private id;

    /**
    @notice Generates a unique id
    @return id The newly generated id
    */
    function unique() internal returns (uint) {
        id += 1;
        return id;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
@title Array
@author Leo
@notice Adds utility functions to an array of integers
*/
library Array {
    /**
    @notice Removes an array item by index
    @dev This is a O(1) time-complexity algorithm without persiting the order
    @param array A reference value to the array
    @param index An item index to be removed 
    */
    function remove(uint[] storage array, uint index) internal {
        require(index < array.length, "Index out of bound.");
        array[index] = array[array.length - 1];
        array.pop();
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