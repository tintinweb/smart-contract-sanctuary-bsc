// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Staking is ReentrancyGuard {
    IERC20 public token;

    struct UserInfo {
        uint256 amount;
        uint256 since;
        uint256 rewardDebt;
        uint256 depositeTime;
    }

    address owner;
    address factoryContract;

    uint256 public rewards;
    uint256 public decimals;
    uint256 public _totalSupply;
    uint256 public rewardsDuration;

    bool pause;

    mapping(address => UserInfo) userInfo;

    modifier updateReward(address account) {
        userInfo[account].rewardDebt = earned(account);
        _;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Caller is not a owner");
        _;
    }

    modifier paused() {
        require(!pause, "contract is paused");
        _;
    }

    event Staked(address user, uint256 amount);
    event Withdrawn(address user, uint256 amount);
    event RewardPaid(address user, uint256 reward);
    event updateOwner(address oldOwner, address newOlder);

    constructor(
        address _token,
        address _owner,
        address _factoryContract,
        uint256 _rewards,
        uint256 _decimals,
        uint256 _rewardsDuration
    ) {
        owner = _owner;
        token = IERC20(_token);
        factoryContract = _factoryContract;
        rewards = _rewards;
        decimals = _decimals;
        rewardsDuration = _rewardsDuration;
    }

    function setOwner(address _owner) external nonReentrant paused {
        require(msg.sender == owner, "not owner");
        owner = _owner;
        emit updateOwner(msg.sender, _owner);
    }

    function stake(uint256 _amount)
        external
        nonReentrant
        paused
        updateReward(msg.sender)
    {
        _totalSupply += _amount;
        userInfo[msg.sender].amount += _amount;
        userInfo[msg.sender].since = block.timestamp;

        if (userInfo[msg.sender].amount == 0) {
            userInfo[msg.sender].depositeTime = block.timestamp;
        }

        token.transferFrom(msg.sender, address(this), _amount);

        emit Staked(msg.sender, _amount);
    }

    function withdraw(uint256 _amount)
        public
        nonReentrant
        paused
        updateReward(msg.sender)
    {
        require(userInfo[msg.sender].amount > 0, "token not stake");
        require(
            (block.timestamp - userInfo[msg.sender].depositeTime) >=
                rewardsDuration,
            "not lockingtime"
        );
        _totalSupply = _totalSupply - _amount;
        userInfo[msg.sender].amount = userInfo[msg.sender].amount - _amount;
        userInfo[msg.sender].since = block.timestamp;
        token.transfer(msg.sender, _amount);
        emit Withdrawn(msg.sender, _amount);
    }

    function getReward(address _user)
        public
        nonReentrant
        paused
        returns (uint256)
    {
        require(userInfo[_user].amount > 0, "token not stake");
        require(factoryContract == msg.sender, "not factory contract");
        uint256 reward = earned(_user);
        userInfo[_user].rewardDebt = 0;
        userInfo[_user].since = block.timestamp;

        emit RewardPaid(_user, reward);
        return reward;
    }

    function pausedContract(bool _status) external nonReentrant onlyOwner {
        pause = _status;
    }

    function earned(address _account) public view returns (uint256) {
        return
            userInfo[_account].rewardDebt +
            (((block.timestamp - userInfo[_account].since) *
                userInfo[_account].amount *
                rewards) / (rewardsDuration * decimals));
    }

    function getUpdateReward(address _account) public view returns (uint256) {
        return userInfo[_account].rewardDebt;
    }

    function getEarned(address _account) public view returns (uint256) {
        return (((block.timestamp - userInfo[_account].since) *
            userInfo[_account].amount *
            rewards) / (rewardsDuration * decimals));
    }

    function stakeBalanceOfUser(address _user) external view returns (uint256) {
        return userInfo[_user].amount;
    }

    function getUserDetails(address _user)
        external
        view
        returns (UserInfo memory)
    {
        return userInfo[_user];
    }
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