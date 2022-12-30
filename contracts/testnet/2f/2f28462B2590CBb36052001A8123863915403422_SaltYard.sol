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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";



contract SaltYard is Ownable {

    IERC20 public  SALTS;

    uint256 public totalStaked; // total SALTS staked on this contract
    
    uint256 public stake_duration; // 30 days / 90 days 
    
    // charges for early unstake before 7 days (early unstake tax)
    uint public interestRate ;

    constructor(address _tokenAddress)  {
        SALTS = IERC20(_tokenAddress);        
    } 


    struct  StakeInfo {   
        uint256 amount; // total staked amount
        uint[] stakes; // tracks every stake
        uint[] min_lockin; // minimum lockin period  
        uint256 rewards;
        uint256 claimed; // tracks interest withdrawn
        bool staked; // default false, true for stakers
    }

    function viewMyRewards() public view returns(uint256 rewards) {
       return stakeInfos[msg.sender].rewards;
    }

    // mapping(address => uint256) rewards;
    mapping (address => StakeInfo) public stakeInfos;

    address[] public stakedAddresses ;

    event Staked(address indexed user, uint256 thisStake, uint256 totalStaked, uint256 timestamp );
    event UnStaked(address indexed user, uint256 unstakedAmount, uint256 remainingStake, uint256 timestamp);


    function Stake(uint256 _amount) external {
        require(SALTS.transferFrom(msg.sender, address(this), _amount));
        StakeInfo storage _stakeInfo = stakeInfos[msg.sender];
        _stakeInfo.stakes.push(_amount);
        _stakeInfo.min_lockin.push(block.timestamp + 7 days);

        if(!_stakeInfo.staked){
            stakedAddresses.push(msg.sender);
        }
        _stakeInfo.staked = true;
        _stakeInfo.amount += _amount;
        totalStaked += _amount; 

        emit Staked(msg.sender, _amount, stakeInfos[msg.sender].amount, block.timestamp);

    }


    // helps in calculating early unstake tax
    struct Unstake_stats {
        uint unstakable; // passed 7 days
        uint taxable; // behind 7 days
    }

    mapping (address => Unstake_stats) stats;

    function UnStake(uint256 _amount) external {
        require(_amount <= stakeInfos[msg.sender].amount, "invalid amount");
        StakeInfo storage _stake = stakeInfos[msg.sender];
       
        for (uint i = 0; i < _stake.stakes.length; i ++) {
            if(_stake.min_lockin[i] <= block.timestamp) {
                stats[msg.sender].unstakable += _stake.stakes[i];
            } else {
                stats[msg.sender].taxable += _stake.stakes[i];
            }
        }

        uint totalTokens;
        if (_amount <= stats[msg.sender].unstakable) {
            totalTokens = _amount ;
        } else {
            uint remaining = _amount - stats[msg.sender].unstakable;
            uint amt_with_tax = remaining - (remaining * interestRate / 100);
            totalTokens = stats[msg.sender].unstakable + amt_with_tax ;
        }
        SALTS.transfer(msg.sender, totalTokens);

        totalStaked -= totalTokens ;
        _stake.amount -= totalTokens;

        emit UnStaked(msg.sender, _amount, stakeInfos[msg.sender].amount, block.timestamp);
    }


    //  Update all the staker's rewards in this method.

    function UpdateRewards() public onlyOwner {
        for (uint i = 0 ; i <= stakedAddresses.length - 1 ; i ++) {
            address account = stakedAddresses[i];
            uint256 amount = stakeInfos[account].amount;
            uint256 reward_per_token = totalRewards() / totalStaked * ((stake_duration * 24 * 60));
            uint256 _rewards = amount * reward_per_token;
            stakeInfos[account].rewards += _rewards;
        }       
    }


    function claimRewards() public {
        uint amount = stakeInfos[msg.sender].rewards;
        SALTS.transfer(msg.sender, amount);
        stakeInfos[msg.sender].rewards -= amount ;
        stakeInfos[msg.sender].claimed += amount ;
    }

    // TODO: Need oracle here
    // send request 
    // pay link
    // receive data 
    // check "amount" with the received data 
    // allow the transfer 
    // function claimRewards(uint amount) public {
    //     //
    //     SALTS.transfer(msg.sender, amount);
    //     stakeInfos[msg.sender].claimed += amount;
    // }

    // function calculateRewards(address user) internal view returns(uint256) {
    //     uint256 amount = stakeInfos[user].amount;
    //     uint256 reward_per_token = totalRewards() / totalStaked * (stake_duration * 24 * 60);
    //     uint256 rewards = amount * reward_per_token;
    //     return rewards;
    // }
    
    function set_stake_duration(uint _days) public onlyOwner {
        stake_duration = _days;
    }

    // Note: If interest rate is 0.1% then a = 1 & b = 10 ; interest rate is 0.1%
    // If interst rate is 1% then a = 1, b = 1 ; interestRate 1%
    function set_interest_rate(uint a, uint b) public onlyOwner {
        interestRate = a/b;
    }
    
    //////////////// View Functions ///////////////
    
    function lockinperiod(uint i) external view returns (uint256) {
        StakeInfo storage myStake = stakeInfos[msg.sender];
        return myStake.min_lockin[i];
    }
    
    // tracks total rewards sent to pool from marketplace 
    function totalRewards() internal view returns(uint256) {
        return SALTS.balanceOf(address(this));
    }

    // returns the total amount of salts being staked 
    function stakedSalts() public view returns(uint256) {
        return totalStaked;
    }

    // returns the total number of stakers
    function totalStakers() public view returns(uint256) {
        return stakedAddresses.length;
    }

    // user stats

    // returns total rewards earned by a user 
    // function myTotalRewards() public view {
    //     calculateRewards(msg.sender);
    // }

    // returns total amount of saltz staked by a user
    function myStakedSaltz() public view returns(uint256) {
        return stakeInfos[msg.sender].amount;
    }

    // returns rewards of a user by index of address array
    // function rewardsPerAddress(uint i) internal view {
    //     address user = stakedAddresses[i];
    //     calculateRewards(user);
    // }

    // function updateRewards() public view {
    //     for (uint i = 0; i <= stakedAddresses.length; i++){
    //         rewardsPerAddress(i);
    //     }
    // }

}