// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FlexibleStaking is Ownable {
    IERC20 public fitToken;
    address public cashbackAddr;

    uint256 public rewardPool;
    // About 1000 tokens per day
    uint256 public rewardRate = 11574074074074074;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 public totalValueLocked;
    mapping(address => uint256) balances;

    modifier onlyCashback() {
        require(msg.sender == cashbackAddr);
        _;
    }

    modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;

        uint256 reward = earned(_account);
        rewards[_account] = reward;
        userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        _;
    }

    constructor(address _fitToken, address _cashbackAddr) {
        fitToken = IERC20(_fitToken);
        cashbackAddr = _cashbackAddr;
    }

    function increaseRewardPool(uint256 _amount) external onlyOwner {
        fitToken.transferFrom(msg.sender, address(this), _amount);
        rewardPool += _amount;
    }

    function changeRewardRate(uint256 _amount) external onlyOwner {
        rewardRate = _amount;
    }

    function stake(uint256 _amount) external {
        _stake(msg.sender, _amount, msg.sender);
    }

    function stakeFromCashback(address _user, uint256 _amount)
        external
        onlyCashback
    {
        _stake(_user, _amount, msg.sender);
    }

    function getReward() external updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        require(reward > 0, "Reward should be more than 0");
        require(
            rewardPool >= rewards[msg.sender],
            "Reward pool is less than your reward"
        );
        rewards[msg.sender] = 0;
        rewardPool -= reward;
        fitToken.transfer(msg.sender, reward);
    }

    function withdraw() external updateReward(msg.sender) {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Amount should be more than 0");
        require(
            totalValueLocked >= amount,
            "Total supply is less than amount to withdraw"
        );
        totalValueLocked -= amount;
        balances[msg.sender] = 0;
        fitToken.transfer(msg.sender, amount);
    }

    function userStake(address _account) external view returns (uint256) {
        return balances[_account];
    }

    function getAPYStaked() public view returns (uint256) {
        return (rewardRate * 60 * 60 * 24 * 365 * 100) / totalValueLocked;
    }

    function getAPYNotStaked(uint256 _stake) public view returns (uint256) {
        return (rewardRate * 60 * 60 * 24 * 365 * 100) / (totalValueLocked + _stake);
    }

    function earnedAlready(address _account) external view returns (uint256) {
        uint256 _rewardPerTokenStored = rewardPerToken();
        uint256 _lastUpdateTime = block.timestamp;
        uint256 _rewardPerToken;
        if (totalValueLocked == 0) {
            _rewardPerToken = rewardPerTokenStored;
        } else {
            _rewardPerToken =
                _rewardPerTokenStored +
                (((block.timestamp - _lastUpdateTime) * rewardRate * 1e32) /
                    totalValueLocked);
        }
        uint256 reward = ((balances[_account] *
            (_rewardPerToken - userRewardPerTokenPaid[_account])) / 1e32) +
            rewards[_account];
        return reward;
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalValueLocked == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored +
            (((block.timestamp - lastUpdateTime) * rewardRate * 1e32) /
                totalValueLocked);
    }

    function _stake(
        address _staker,
        uint256 _amount,
        address _payer
    ) internal updateReward(_staker) {
        require(_amount > 0, "Amount should be more than 0");
        totalValueLocked += _amount;
        balances[_staker] += _amount;
        fitToken.transferFrom(_payer, address(this), _amount);
    }

    function earned(address _account) internal view returns (uint256) {
        return
            ((balances[_account] *
                (rewardPerToken() - userRewardPerTokenPaid[_account])) / 1e32) +
            rewards[_account];
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