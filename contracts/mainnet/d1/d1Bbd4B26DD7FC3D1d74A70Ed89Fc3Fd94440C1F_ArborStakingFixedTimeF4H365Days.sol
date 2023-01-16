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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./ITresuary.sol";
import "./IRewardWallet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";



contract ArborStakingFixedTimeF4H365Days is Ownable , Pausable{

    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public isStaking;
    mapping(address => uint256) public startTime;
    mapping(address => uint256) public userRewards;
    mapping(address => uint256) public userEndTime;
    

    uint256 public constant YEAR_SECOND = 31577600;

    uint256 public rewardRate = 14;
    uint256 public oldRewardRate;
    uint256 public rewardRateUpdatedTime;
    uint256 public lockTime;

    bool public isTresuarySet;
    bool public isRewardWalletSet;

    ITresuary public tresuary;
    IRewardWallet public rewardWallet;
       
    IERC20 public stakingToken;
    IERC20 public rewardsToken;
    

    event Stake(address indexed from, uint256 amount);
    event Unstake(address indexed from, uint256 amount);
    event RewardsWithdrawal(address indexed to, uint256 amount);
    event LogSetRewardRate(uint256 oldRate, uint256 newRate);
    event LogSetTresuary(address newTresuary);
    event LogSetRewardWallet(address newRewardWallet);


    constructor(address _stakingToken, address _rewardsToken, uint256 _lockTime) {
        require(_stakingToken != address(0), "StakingToken Address 0 validation");
        require(_rewardsToken != address(0), "RewardsToken Address 0 validation");

        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
        lockTime = _lockTime;
    }

    
    function stake(uint256 amount) public whenNotPaused{
        require(amount > 0, "Can't be 0");
        require(amount > 0 && stakingToken.balanceOf(msg.sender) >= amount, "Incufficient stakingToken balance");

        if(isStaking[msg.sender] == true){
            uint256 toTransfer = getTotalRewards(msg.sender);
            userRewards[msg.sender] += toTransfer;
        }

        stakingBalance[msg.sender] += amount;
        startTime[msg.sender] = block.timestamp;
        isStaking[msg.sender] = true;
        userEndTime[msg.sender] = block.timestamp + (lockTime * 1 days);

        tresuary.deposit(msg.sender, amount);

        emit Stake(msg.sender, amount);
    }


    function unstake(uint256 amount) public whenNotPaused{
        require(amount > 0, "Can't be 0");
        require(block.timestamp > userEndTime[msg.sender], "Can't unstake yet");
        require(isStaking[msg.sender] = true && stakingBalance[msg.sender] >= amount, "Nothing to unstake");

        uint256 rewards = getTotalRewards(msg.sender);

        startTime[msg.sender] = block.timestamp;
        stakingBalance[msg.sender] -= amount;
        userRewards[msg.sender] += rewards;

        if(stakingBalance[msg.sender] == 0){
            isStaking[msg.sender] = false;
        }

        tresuary.withdraw(msg.sender, amount);

        emit Unstake(msg.sender, amount);
    }


    function getTotalTime(address user) public view returns(uint256){
        uint256 finish = block.timestamp;
        uint256 totalTime = finish - startTime[user];
        return totalTime;
    }


    function getTotalRewards(address user) public view returns(uint256) {
        
        if (stakingBalance[user] > 0) {
             uint256 newRewards = ((block.timestamp - startTime[user]) * stakingBalance[user] * rewardRate) /
             (YEAR_SECOND * 100);
            return newRewards + userRewards[user];
        }
       
    } 

    function getPendingRewards(address user) public view returns (uint256) {
        return userRewards[user];
    }

    function calculateRewards(uint256 _start, uint256 _amount) public view returns (uint256) {
        uint256 newRewards = ((block.timestamp - _start) * _amount * rewardRate) / (YEAR_SECOND * 100);
        return newRewards;
    }

    function calculateDayRewards(uint256 _start, uint256 _amount) public view returns (uint256) {
        uint256 newRewards = ((_start * 1 days) * _amount * rewardRate) / (YEAR_SECOND * 100);
        return newRewards;
    }

    function setRewardRate(uint256 _rewardRate) external onlyOwner {
        require(rewardRate != _rewardRate, "Already set to this value");
        require(_rewardRate != 0, "Can't be 0");

        rewardRateUpdatedTime = block.timestamp;
        oldRewardRate = rewardRate;
        rewardRate = _rewardRate;   

        emit LogSetRewardRate(oldRewardRate, rewardRate);
    }


    function setTresuary(address _tresuary) external onlyOwner {
        require(address(tresuary) != _tresuary, "Already set to this value");
        require(_tresuary != address(0), "Address 0 validation");
        require(isTresuarySet == false, "Tresuary can be set only once");

        isTresuarySet = true;
        tresuary = ITresuary(_tresuary);

        emit LogSetTresuary(_tresuary);
    }

    function setRewardWallet(address _rewardWallet) external onlyOwner {
        require(address(rewardWallet) != _rewardWallet, "Already set to this value");
        require(_rewardWallet != address(0), "Address 0 validation");
        require(isRewardWalletSet == false, "Tresuary can be set only once");

        isRewardWalletSet = true;
        rewardWallet = IRewardWallet(_rewardWallet);

        emit LogSetRewardWallet(_rewardWallet);
    }

    function getRewardRate() external view returns(uint256){
        return rewardRate;
    }

   
    function withdrawRewards() external whenNotPaused{
        uint256 toWithdraw = getTotalRewards(msg.sender);

        require(toWithdraw > 0 || userRewards[msg.sender] > 0, "Incufficient rewards balance");
            
        uint256 oldBalance = userRewards[msg.sender];
        userRewards[msg.sender] = 0;
        toWithdraw += oldBalance;
        
        startTime[msg.sender] = block.timestamp;
        rewardWallet.transfer(msg.sender, toWithdraw);
        emit RewardsWithdrawal(msg.sender, toWithdraw);
    } 

    function setUnpause() external onlyOwner {
        _unpause();
    }

    function setPause() external onlyOwner {
       _pause();
    }

}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IRewardWallet {
    function deposit(address staker, uint256 amount) external ;
    function transfer(address account, uint256 amount) external ;
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface ITresuary {
    function deposit(address staker, uint256 amount) external ;
    function withdraw(address staker, uint256 amount) external ;
}