/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;


// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


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

// File: contracts/Bank.sol

/* SPDX-License-Identifier: UNLICENSED */

pragma solidity ^0.8.7;



abstract contract Manageable is Ownable {
    mapping(address => bool) private _managers;

    event ManagerRemoved(address indexed manager_);
    event ManagerAdded(address indexed manager_);

    constructor() {}

    function managers(address manager_) public view virtual returns (bool) {
        return _managers[manager_];
    }

    modifier onlyManager() {
        require(_managers[_msgSender()], "Manageable: caller is not the owner");
        _;
    }

    function removeManager(address manager_) public virtual onlyOwner {
        _managers[manager_] = false;
        emit ManagerRemoved(manager_);
    }

    function addManager(address manager_) public virtual onlyOwner {
        require(
            manager_ != address(0),
            "Manageable: new owner is the zero address"
        );
        _managers[manager_] = true;
        emit ManagerAdded(manager_);
    }
}

interface IBandit is IERC20 {
    function liquidityPair() external view returns (address);
}

contract BankHeist is Ownable, Manageable {
    IERC20 public LP;
    address public BANK;

    struct LockupTier {
        uint256 duration;
        uint256 allocation;
    }

    LockupTier[] public lockupTiers;

    uint256[] public totalLocked;

    struct Rewards {
        uint256 timestamp;
        uint256[] totalLocked;
        address token;
        uint256 amount;
    }

    Rewards[] public rewards;

    mapping(address => uint256[]) public lockupTiers_s;
    mapping(address => uint256[]) public totalDeposit_s;
    mapping(address => uint256[]) public timestamp_s;
    mapping(address => uint256[]) public claimTimestamp_s;

    constructor(address token, address bank) {
        LP = IERC20(IBandit(token).liquidityPair());
        BANK = bank;
    }

    function getLockupTiers() public view returns (LockupTier[] memory) {
        return lockupTiers;
    }

    function getTotalLocked() public view returns (uint256[] memory) {
        return totalLocked;
    }

    function getRewards() public view returns (Rewards[] memory) {
        return rewards;
    }

    function getStakings(address user) public view returns (uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory) {
        return (lockupTiers_s[user], totalDeposit_s[user], timestamp_s[user], claimTimestamp_s[user]);
    }

    function updateLp(address lp) public onlyOwner {
        LP = IERC20(lp);
    }

    function updateBank(address bank) public onlyOwner {
        BANK = bank;
    }

    function addRewards(address token, uint256 amount) public onlyManager {
        rewards.push(
            Rewards({
                timestamp: block.timestamp,
                totalLocked: totalLocked,
                token: token,
                amount: amount
            })
        );
    }

    function addRewardsOwner(address token, uint256 amount) public onlyOwner {
        rewards.push(
            Rewards({
                timestamp: block.timestamp,
                totalLocked: totalLocked,
                token: token,
                amount: amount
            })
        );
    }

    function addLockupTier(uint256 duration, uint256 allocation)
        public
        onlyOwner
    {
        lockupTiers.push(
            LockupTier({duration: duration, allocation: allocation})
        );
        totalLocked.push(0);
    }

    function stake(uint256 quantity, uint256 tier) public {
        uint256[] memory lockupTiers_ = lockupTiers_s[_msgSender()];
        require(tier < lockupTiers.length, "STAKE: Invalid tier");
        require(quantity > 0, "STAKE: Invalid quantity");
        LP.transferFrom(_msgSender(), BANK, quantity);
        for (uint256 i = 0; i < lockupTiers_.length; i++) {
            if (lockupTiers_[i] == tier) {
                claim();
            }
            lockupTiers_s[_msgSender()][i] = tier;
            totalDeposit_s[_msgSender()][i] += quantity;
            timestamp_s[_msgSender()][i] = block.timestamp;
            claimTimestamp_s[_msgSender()][i] = block.timestamp;
            totalLocked[tier] += quantity;
        }
    }

    function unstake(uint256 tier) public {
        uint256[] memory lockupTiers_ = lockupTiers_s[_msgSender()];
        require(tier < lockupTiers.length, "UNSTAKE: Invalid tier");
        for (uint256 i = 0; i < lockupTiers_.length; i++) {
            if (lockupTiers_[i] == tier) {
                require(
                    timestamp_s[_msgSender()][i] + lockupTiers[tier].duration >=
                        block.timestamp,
                    "UNSTAKE: Too soon."
                );
                uint256 tempTotalDeposit = totalDeposit_s[_msgSender()][i];
                delete lockupTiers_s[_msgSender()][i];
                delete totalDeposit_s[_msgSender()][i];
                delete timestamp_s[_msgSender()][i];
                delete claimTimestamp_s[_msgSender()][i];
                LP.transferFrom(BANK, _msgSender(), tempTotalDeposit);
            }
        }
    }

    function claim() public {
        uint256[] memory lockupTiers_ = lockupTiers_s[_msgSender()];
        for (uint256 i = 0; i < lockupTiers_.length; i++) {
            for (uint256 j = 0; j < rewards.length; j++) {
                if (rewards[j].timestamp >= timestamp_s[_msgSender()][i]) {
                    uint256 tempTimestamp = claimTimestamp_s[_msgSender()][i];
                    claimTimestamp_s[_msgSender()][i] = block.timestamp;
                    if (rewards[j].timestamp >= tempTimestamp) {
                        uint256 ratioOfPool = (totalDeposit_s[_msgSender()][i] * 100) /
                            rewards[j].totalLocked[lockupTiers_s[_msgSender()][i]];
                        uint256 totalRewards = (((rewards[j].amount * 100) /
                            lockupTiers[lockupTiers_s[_msgSender()][i]].allocation) *
                            ratioOfPool) / 100;
                        IERC20(rewards[j].token).transferFrom(
                            BANK,
                            _msgSender(),
                            totalRewards
                        );
                    }
                }
            }
        }
    }
}