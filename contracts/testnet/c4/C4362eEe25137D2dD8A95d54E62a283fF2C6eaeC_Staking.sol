// SPDX-License-Identifier: No License

pragma solidity 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staking is Ownable {
    
    IERC20 public udiToken;
    uint256 public lockTime = 120;
    uint256 public stakeSize = 25 * (10 ** 18);
    uint256 public fee = 9;
    uint256 public tvl;

    // Rewards processing
    uint256 rewardsPool;

    //Info of each user
    struct UserInfo {
        uint256 stakeAmount;       // User staked amount in the pool
        uint256 stakeTimestamp;    // User staked amount in the pool
        uint256 unstakeTimestamp;    // User staked amount in the pool
        uint256 lastClaimTimestamp;   // User last harvest timestamp 
        uint256 pendingRewards;
        uint256 claimedRewards;
    }

    // Info of each user that stakes LP tokens.
    mapping (address => UserInfo) public userInfo;

    address[] public stakeList;

    constructor(address _udiToken) {
        udiToken = IERC20(_udiToken);
    }

    receive() external payable {}

    function stake() external {  

        UserInfo storage _userInfo = userInfo[msg.sender];

        require(_userInfo.stakeAmount == 0, "stake : Already staking in this pool");
        require(udiToken.balanceOf(msg.sender) >= stakeSize, "stake : Insufficient token");
        
        udiToken.transferFrom(msg.sender, address(this), stakeSize);

        // Push user address to stakeList if the address never stake before
        if(_userInfo.unstakeTimestamp == 0) {
            stakeList.push(msg.sender);
        }

        uint256 _newAmount = stakeSize - (stakeSize * fee / 100);
        // Update user staking info
        _userInfo.stakeAmount = _newAmount;
        _userInfo.stakeTimestamp = block.timestamp;

        // Update tvl
        tvl += _newAmount; 
        
        emit Staked(msg.sender, block.timestamp, _newAmount);
    }

    function unstake() external {
        UserInfo storage _userInfo = userInfo[msg.sender];

        require(_userInfo.stakeAmount > 0, "You dont have stake");
        require(block.timestamp > _userInfo.stakeTimestamp + lockTime, "Stake is not unlocked yed");
        require(udiToken.balanceOf(address(this)) >= _userInfo.stakeAmount, "Contract doesnt have enough token, please contact admin");

        uint256 _amount = _userInfo.stakeAmount;

        // Update userinfo
        _userInfo.stakeAmount = 0;
        _userInfo.unstakeTimestamp = block.timestamp;

        // Update tvl
        tvl -= _amount;    

        // Transfer DECA token back to the owner
        udiToken.transfer(msg.sender, _amount); 

        emit Unstake(msg.sender, _amount);
    }

    function claim() external {

        UserInfo storage _userInfo = userInfo[msg.sender];

        require(_userInfo.stakeAmount > 0, "No stake records found");
        require(_userInfo.pendingRewards > 0, "No pending rewards found");
        require(address(this).balance >= _userInfo.pendingRewards, "Insufficient balance in contract");

        uint256 _pendingRewards = _userInfo.pendingRewards;

        // update user info
        _userInfo.pendingRewards = 0;
        _userInfo.claimedRewards += _pendingRewards;
        _userInfo.lastClaimTimestamp = block.timestamp;

        // update rewardsPool
        rewardsPool -= _pendingRewards;

        payable(msg.sender).transfer(_pendingRewards);

        emit Claim(msg.sender, _pendingRewards);
    }

    function processRewards() external {
        uint256 contractBalance = address(this).balance;
        uint256 newBalance = contractBalance - rewardsPool;
        uint256 totalActiveStaker = getTotalActiveStaker();

        require(address(this).balance > rewardsPool, "Contract balance must be larger than rewards pool");
        require(totalActiveStaker > 0, "No active staker found");

        // Calculate allocation
        uint256 allocation = newBalance / totalActiveStaker;

        // Distribute allocation to all active stakers
        for(uint i=0; i<stakeList.length; i++) {
            UserInfo storage _userInfo = userInfo[stakeList[i]];

            if(_userInfo.stakeAmount > 0) {
                _userInfo.pendingRewards += allocation;
            }
        }
        
        // Update rewardsPool with new balance
        rewardsPool = contractBalance;
    }

    function getTotalActiveStaker() public view returns(uint256) {
        uint256 totalActiveStaker;

        for(uint i=0; i<stakeList.length; i++) {
            UserInfo storage _userInfo = userInfo[stakeList[i]];

            if(_userInfo.stakeAmount > 0)
                totalActiveStaker++;
        }

        return totalActiveStaker;
    }

    function setStakeSize(uint256 _amount) external onlyOwner {
        stakeSize = _amount;

        emit SetStakeSize(_amount);
    }

    function setLockTime(uint256 _amount) external onlyOwner {
        lockTime = _amount;

        emit SetLockTime(_amount);
    }

    function setFee(uint256 _amount) external onlyOwner {
        fee = _amount;

        emit SetFee(_amount);
    }

    function clearStuckBalance() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    event Staked(address indexed account, uint256 startTime, uint256 amount);
    event Unstake(address indexed account, uint256 amount);
    event Claim(address indexed account, uint256 value);
    event SetStakeSize(uint256 amount);
    event SetLockTime(uint256 amount);
    event SetFee(uint256 amount);
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