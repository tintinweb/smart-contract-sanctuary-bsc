// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "Ownable.sol";
import "IERC20.sol";
import "ReentrancyGuard.sol";
import "Pausable.sol";

// Inheritance
import "ITokenStake.sol";

contract TokenStake is Ownable, ReentrancyGuard, Pausable, ITokenStake {
    /* ========== STATE VARIABLES ========== */
    mapping(address => uint256[]) public stakingBalances;
    mapping(address => uint256[]) public startStakingTimes;
    mapping(address => uint256[]) public rewards;

    IERC20 public rewardToken;
    IERC20 public stakedToken;

    uint256 public rewardRate;
    uint256 public atLeastStakingDuration;

    uint256 public totalContractSupply;
    uint256 public totalStakingBalance;
    uint256 public totalRewards;

    /* ========== CONSTRUCTOR ========== */
    constructor(
        address _rewardToken,
        address _stakedToken,
        uint256 _rewardRate,
        uint256 _atLeastStakingDuration
    ) {
        rewardToken = IERC20(_rewardToken);
        stakedToken = IERC20(_stakedToken);
        rewardRate = _rewardRate;
        atLeastStakingDuration = _atLeastStakingDuration;
    }

    /* ========== VIEWS ========== */
    function totalSupply() external view override returns (uint256) {
        return totalContractSupply;
    }

    function balanceOf(address _account)
        external
        view
        override
        returns (uint256[] memory)
    {
        return stakingBalances[_account];
    }

    function isStaking(address _account) external view override returns (bool) {
        uint256[] memory balances = stakingBalances[_account];

        for (uint256 index = 0; index < balances.length; index++) {
            if (balances[index] > 0) return true;
        }

        return false;
    }

    function getStakingDuration(address _account, uint256 stakingOrder)
        public
        view
        override
        returns (uint256)
    {
        if (startStakingTimes[_account][stakingOrder] == 0) return 0;

        uint256 stakingDuration = block.timestamp -
            startStakingTimes[_account][stakingOrder];

        if (stakingDuration > atLeastStakingDuration)
            return atLeastStakingDuration;
        else return stakingDuration;
    }

    function earning(address _account, uint256 stakingOrder)
        public
        view
        override
        returns (uint256)
    {
        uint256[] memory balances = stakingBalances[_account];
        for (uint256 index = 0; index < balances.length; index++) {
            if (index == stakingOrder) {
                return
                    uint256(
                        ((balances[index] * rewardRate) /
                            100 /
                            atLeastStakingDuration) *
                            getStakingDuration(_account, stakingOrder)
                    );
            }
        }
        return 0;
    }

    function totalEarnSession(address _account, uint256 stakingOrder)
        public
        view
        override
        returns (uint256)
    {
        uint256[] memory balances = stakingBalances[_account];
        for (uint256 index = 0; index < balances.length; index++) {
            if (index == stakingOrder) {
                return uint256(((balances[index] * rewardRate) / 100));
            }
        }
        return 0;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */
    function stake(uint256 _amount) public override nonReentrant whenNotPaused {
        require(_amount > 0, "Amount must be more than 0");
        totalContractSupply = totalContractSupply + _amount;
        totalStakingBalance = totalStakingBalance + _amount;
        createNewStakingSession(_amount);
        stakedToken.transferFrom(msg.sender, address(this), _amount);

        emit Staked(msg.sender, _amount);
    }

    function withdrawImmediately(uint256 _amount, uint256 stakingOrder)
        public
        override
        nonReentrant
    {
        require(_amount > 0, "Cannot withdraw 0");

        uint256 accountBalance = stakingBalances[msg.sender][stakingOrder];

        require(_amount <= accountBalance, "Insufficient balance");

        uint256 remainAccountBalance = accountBalance - _amount;

        totalContractSupply = totalContractSupply - _amount;
        totalStakingBalance = totalStakingBalance - _amount;

        // Clear the old session
        stakingBalances[msg.sender][stakingOrder] = 0;
        updateReward(msg.sender, stakingOrder, false);

        // Create new session if not withdraw all
        if (_amount < accountBalance)
            createNewStakingSession(remainAccountBalance);

        stakedToken.transfer(msg.sender, _amount);
        emit WithdrawImmediately(msg.sender, _amount);
    }

    function getReward(bool continueStake, uint256 stakingOrder)
        public
        override
        nonReentrant
    {
        require(
            getStakingDuration(msg.sender, stakingOrder) >=
                atLeastStakingDuration,
            "Must wait for enough required time duration"
        );

        uint256 reward = rewards[msg.sender][stakingOrder];
        updateReward(msg.sender, stakingOrder, false);

        require(reward > 0, "Insufficient reward");
        require(reward <= totalContractSupply, "Insufficient contract balance");

        totalContractSupply = totalContractSupply - reward;
        rewardToken.transfer(msg.sender, reward);

        if (continueStake) {
            // Create new staking session
            createNewStakingSession(stakingBalances[msg.sender][stakingOrder]);

            // Clear old session
            startStakingTimes[msg.sender][stakingOrder] = 0;
            stakingBalances[msg.sender][stakingOrder] = 0;
        }
        // Withdraw all balance of session
        else withdraw(stakingBalances[msg.sender][stakingOrder], stakingOrder);

        emit RewardPaid(msg.sender, reward);
    }

    function exit(uint256 stakingOrder) external override {
        getReward(false, stakingOrder);
    }

    /* ========== OWNER FUNCTIONS ========== */
    function fundContractBalance(uint256 _amount) external onlyOwner {
        require(_amount > 0, "Invalid fund");

        totalContractSupply = totalContractSupply + _amount;
        rewardToken.transferFrom(msg.sender, address(this), _amount);
    }

    function checkRemainContractBalance()
        external
        view
        onlyOwner
        returns (uint256)
    {
        uint256 remain = totalContractSupply -
            (totalRewards + totalStakingBalance);

        return remain;
    }

    /* ========== INTERNAL FUNCTIONS ========== */
    function createNewStakingSession(uint256 _amount) internal {
        stakingBalances[msg.sender].push(_amount);
        startStakingTimes[msg.sender].push(block.timestamp);
        updateReward(msg.sender, stakingBalances[msg.sender].length - 1, true);
    }

    function withdraw(uint256 _amount, uint256 stakingOrder) internal {
        require(_amount > 0, "Cannot withdraw 0");
        require(
            getStakingDuration(msg.sender, stakingOrder) >=
                atLeastStakingDuration,
            "Must wait for enough required time duration"
        );

        uint256 accountBalance = stakingBalances[msg.sender][stakingOrder];

        require(_amount <= accountBalance, "Insufficient balance");

        totalContractSupply = totalContractSupply - _amount;
        totalStakingBalance = totalStakingBalance - _amount;
        stakingBalances[msg.sender][stakingOrder] = accountBalance - _amount;

        // Clear reward
        if (_amount == accountBalance)
            updateReward(msg.sender, stakingOrder, false);

        stakedToken.transfer(msg.sender, _amount);
    }

    function updateReward(
        address _account,
        uint256 stakingOrder,
        bool newSession
    ) internal {
        if (_account != address(0)) {
            uint256 currentReward = totalEarnSession(_account, stakingOrder);
            if (newSession) {
                rewards[_account].push(currentReward);
                totalRewards = totalRewards + currentReward;
            } else {
                totalRewards = totalRewards - rewards[_account][stakingOrder];
                rewards[_account][stakingOrder] = 0;
            }
        }
    }

    /* ========== EVENTS ========== */

    event Staked(address indexed user, uint256 amount);
    event WithdrawImmediately(address indexed user, uint256 amount);
    event RewardRate(uint256 rate);
    event RewardPaid(address indexed user, uint256 reward);
    event AtLeastStakingDuration(uint256 newDuration);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "Context.sol";

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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "Context.sol";

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
pragma solidity ^0.8.0;

// https://docs.synthetix.io/contracts/source/interfaces/istakingrewards
interface ITokenStake {
    // Views

    function balanceOf(address _account)
        external
        view
        returns (uint256[] memory);

    function isStaking(address _account) external view returns (bool);

    function earning(address _account, uint256 stakingOrder)
        external
        view
        returns (uint256);

    function totalEarnSession(address _account, uint256 stakingOrder)
        external
        view
        returns (uint256);

    function totalSupply() external view returns (uint256);

    function getStakingDuration(address _account, uint256 stakingOrder)
        external
        view
        returns (uint256);

    // Mutative
    function stake(uint256 _amount) external;

    function getReward(bool continueStake, uint256 stakingOrder) external;

    function withdrawImmediately(uint256 _amount, uint256 stakingOrder)
        external;

    function exit(uint256 stakingOrder) external;
}