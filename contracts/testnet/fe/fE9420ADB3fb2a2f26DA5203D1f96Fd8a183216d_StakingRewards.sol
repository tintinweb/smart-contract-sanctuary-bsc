// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingRewards is Ownable {
    IERC20 public stakingToken;

    uint256 public totalStaked;
    uint256 public minStaking = 10000000000000000;
    uint256 public maxStaking = 3000000000000000000;

    mapping(address => uint) public date;
    mapping(address => uint) public amount;
    mapping(address => uint) public expired;
    mapping(address => uint) public lastReward;
    mapping(address => uint) public rewardPersecond;

    constructor(address _stakingToken) {
        stakingToken = IERC20(_stakingToken);
    }

    function addStaking(uint256 amount_, uint256 rewardRate_) public returns(bool) {

        bool sendUserTokenBalance = stakingToken.transferFrom(msg.sender, address(this), amount_);
        require(sendUserTokenBalance,"Failed to send token");    

        uint256 percentAmount = 0;
        if(rewardRate_ == 35){
            percentAmount = 48;
        } else if (rewardRate_ == 50){
            percentAmount = 96;
        } else if (rewardRate_ == 90){
            percentAmount = 180;
        }

        require(percentAmount > 0, "Failed to get packages");
        date[msg.sender] = block.timestamp;
        amount[msg.sender] = amount_;
        expired[msg.sender] = block.timestamp + (86400 * rewardRate_);
        lastReward[msg.sender] = block.timestamp;
        rewardPersecond[msg.sender] = (( percentAmount / 100 ) * amount_) * rewardRate_;
        totalStaked += amount_;
        return true;
    }

    function stakedAmount(address user_address_) public view returns(uint256){
        return amount[user_address_];
    }

    function getDate(address user_address_) public view returns(uint256){
        return date[user_address_];
    }
    
    function getExpired(address user_address_) public view returns(uint256){
        return expired[user_address_];
    }
        
    function getLastReward(address user_address_) public view returns(uint256){
        return lastReward[user_address_];
    }
        
    function psReward(address user_address_) public view returns(uint256){
        return rewardPersecond[user_address_];
    }

    function close_staking() public returns(bool){
        require(amount[msg.sender] > 0, "Staking amount is empty");
        require(expired[msg.sender] < block.timestamp, "Staking status not expired");

       uint256 amount_ = amount[msg.sender];
        bool sendUserTokenBalance = stakingToken.transferFrom(
            address(this), 
            msg.sender, 
            amount_);

        require(sendUserTokenBalance,"Failed to send token");    
        totalStaked -= amount_;
        amount[msg.sender] = 0;
        return true;
    }

    function claim_reward() public returns(bool){
        require(lastReward[msg.sender] + 86400 < block.timestamp, "Reward can only claimed every 24H");
        uint256 reward_amount = (block.timestamp - lastReward[msg.sender]) * rewardPersecond[msg.sender];
        bool sendUserTokenBalance = stakingToken.transferFrom(
            address(this), 
            msg.sender, 
            reward_amount);

        require(sendUserTokenBalance,"Failed to send token");    
        lastReward[msg.sender] = block.timestamp;
        return true;
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