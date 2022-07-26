// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LotteryStaking is Ownable {
    struct StakingPool {
        uint256 period;
        uint256 amountPerTicket;
        uint256 maximumStake;
        uint256 totalStaked;
        uint256 endDate;
    }

    struct Stake {
        uint256 poolId;
        uint256 amount;
        uint256 timestamp;
        address staker;
    }

    address tokenAddress;
    uint256 poolCount;

    event PoolCreated(uint256 poolId, uint256 amountPerTicket, uint256 timestamp, uint256 blockNumber, uint256 endDate);
    event StakeAdded(address staker, uint256 poolId, uint256 amount, uint256 timestamp, uint256 totalStaked, uint256 totalTickets);
    event StakeRemoved(address staker, uint256 poolId, uint256 amount, uint256 timestamp, uint256 totalStaked, uint256 totalTickets);
    event StakeRefunded(address staker, uint256 poolId, uint256 amount, uint256 timestamp);
    event ContractCreated(uint256 timestamp, uint256 blockNumber);

    mapping(uint256 => StakingPool) stakingPools;
    mapping(address => mapping(uint256 => Stake)) stakes;

    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;

        emit ContractCreated(block.timestamp, block.number);
    }

    function setTokenAddress(address _tokenAddress) onlyOwner public {
        tokenAddress = _tokenAddress;
    }

    function addStakingPool(uint256 _poolId, uint256 _period, uint256 _amountPerTicket, uint256 _maximumStake, uint256 _endDate) onlyOwner public {
        require(_amountPerTicket > 0, "Amount per ticket must be greater than zero!");
        require(_period > 0, "Lock period must be greater than zero!");

        if (stakingPools[_poolId].period != 0 && stakingPools[_poolId].amountPerTicket != 0) {
            poolCount++;
        }

        stakingPools[_poolId] = StakingPool(_period, _amountPerTicket, _maximumStake, 0, _endDate);

        emit PoolCreated(_poolId, _amountPerTicket, block.timestamp, block.number, _endDate);
    }

    function stakeTokens(uint256 poolId, uint256 amount) public {
        Stake memory stake = stakes[msg.sender][poolId];

        require(stakingPools[poolId].endDate > block.timestamp, "Pool is not active!");

        stake.timestamp = block.timestamp;
        stake.amount += amount;
        stake.staker = msg.sender;
        stake.poolId = poolId;

        stakingPools[poolId].totalStaked += amount;

        require(stakingPools[poolId].totalStaked <= stakingPools[poolId].maximumStake, "Stake amount exceeds maximum stake amount!");

        require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount), "Failed to transfer tokens!");

        stakes[msg.sender][poolId] = stake;

        emit StakeAdded(msg.sender, poolId, amount, stake.timestamp, stake.amount, stake.amount / stakingPools[poolId].amountPerTicket);
    }

    function withdrawTokens(uint256 poolId, uint256 amount) public {
        Stake memory stake = stakes[msg.sender][poolId];

        require(stake.amount > 0, "You have no tokens to withdraw!");
        require(stake.amount >= amount, "You dont have that many tokens to withdraw!");
        require(stake.timestamp + stakingPools[poolId].period < block.timestamp, "You can't withdraw your tokens yet!");

        require(IERC20(tokenAddress).transfer(msg.sender, amount), "Could not send tokens!");

        stake.amount -= amount;
        stakingPools[poolId].totalStaked -= amount;

        stakes[msg.sender][poolId] = stake;

        emit StakeRemoved(msg.sender, poolId, amount, stake.timestamp, stake.amount, stake.amount / stakingPools[poolId].amountPerTicket);
    }

    function refundTokens(address staker, uint256 poolId) onlyOwner public {
        Stake memory stake = stakes[staker][poolId];

        require(stake.amount > 0, "You have no tokens to refund!");

        require(IERC20(tokenAddress).transfer(staker, stake.amount), "Could not send tokens!");

        stakingPools[poolId].totalStaked -= stake.amount;
        stake.amount = 0;

        stakes[staker][poolId] = stake;

        emit StakeRefunded(staker, poolId, stake.amount, block.timestamp);
    }

    function getStake(address staker, uint256 poolId) public view returns (Stake memory) {
        Stake memory stake = stakes[staker][poolId];

        return stake;
    }

    function getStakes(address staker) public view returns (Stake[] memory) {
        Stake[] memory _stakes = new Stake[](poolCount);

        for (uint256 i = 0; i < poolCount; i++) {
            _stakes[i] = stakes[staker][i];
        }

        return _stakes;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

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
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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