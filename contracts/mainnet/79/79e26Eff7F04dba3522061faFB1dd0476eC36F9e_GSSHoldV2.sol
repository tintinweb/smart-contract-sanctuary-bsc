// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/IERC20.sol";
import "./libraries/Ownable.sol";
import "./security/ReentrancyGuard.sol";
import "./GSSHold.sol";

contract GSSHoldV2 is Ownable, ReentrancyGuard {

    address public GSSToken;
    address public GSSHoldAddress;

    uint256 public totalReward;
    uint256 public maxReward = 200000 * 1e18;
    uint256 public constant ACC_TOKEN_PRECISION = 1e18;
    // The amount of allocation points assigned to the token.
    uint256 public constant ALLOC_REWARD = 19290123456800000;
    // Accumulated Tokens per share.
    uint256 public tokenPerShare = 0;
    // Last block number that token update action is executed.
    uint256 public lastRewardBlock = 0;

    uint256 public differ = 3800000 * 1e18;

    /// @notice Info of each Pledge user.
    /// `amount` token amount the user has provided.
    /// `rewardDebt` Used to calculate the correct amount of rewards. See explanation below.
    /// `pending` Pending Rewards.
    /// `depositTime` Last pledge time
    ///
    /// We do some fancy math here. Basically, any point in time, the amount of Tokens
    /// entitled to a user but is pending to be distributed is:
    ///
    ///   pending reward = (user share * tokenPerShare) - user.rewardDebt
    ///
    ///   Whenever a user deposits or withdraws LP tokens. Here's what happens:
    ///   1. The `tokenPerShare` (and `lastRewardBlock`) gets updated.
    ///   2. User receives the pending reward sent to his/her address.
    ///   3. User's `amount` gets updated. `totalBoostedShare` gets updated.
    ///   4. User's `rewardDebt` gets updated.
    struct UserInfo {
        uint256 rewardDebt;
        uint256 pending;
        uint256 total;
        uint256 depositTime;
    }

    /// @notice Info of user.
    mapping(address => UserInfo) public userInfo;

    event Update(uint256 lastRewardBlock, uint256 tokenSupply, uint256 tokenPerShare);
    event WithdrawPending(address indexed user, uint256 pending, uint256 time);

    constructor(address _GSSHoldAddress) {
        lastRewardBlock = block.number;
        GSSHoldAddress = _GSSHoldAddress;
        tokenPerShare = GSSHold(_GSSHoldAddress).tokenPerShare();
    }

    /// @notice View function for checking pending Token rewards.
    /// @param _user Address of the user.
    function pendingToken(address _user) external view returns (uint256) {
    
        uint256 amount;
        uint256 rewardDebt;
        (amount,rewardDebt,,,) = GSSHold(GSSHoldAddress).userInfo(_user);
        UserInfo memory user = userInfo[_user];
        uint256 _tokenPerShare = tokenPerShare;
        uint256 tokenSupply = GSSHold(GSSHoldAddress).totalBoostedShare() - differ;

        if (block.number > lastRewardBlock && tokenSupply != 0) {
            uint256 multiplier = block.number - lastRewardBlock;

            uint256 tokenReward = multiplier * ALLOC_REWARD;
            tokenReward = totalReward + tokenReward > maxReward ? maxReward - totalReward : tokenReward;

            _tokenPerShare = _tokenPerShare + tokenReward * ACC_TOKEN_PRECISION / tokenSupply;
        }

        uint256 _rewardDebt = user.rewardDebt;
        if (_rewardDebt == 0) {
            _rewardDebt = rewardDebt;
        }
        uint256 boostedAmount = amount * _tokenPerShare / ACC_TOKEN_PRECISION;
        boostedAmount = boostedAmount > _rewardDebt ? boostedAmount - _rewardDebt : 0;

        return boostedAmount;
    }

    /// @notice Update reward variables for the given.
    function update() public {
        if (block.number > lastRewardBlock) {
            uint256 tokenSupply = GSSHold(GSSHoldAddress).totalBoostedShare() - differ;
            if (tokenSupply > 0) {
                uint256 multiplier = block.number - lastRewardBlock;
                uint256 tokenReward = multiplier * ALLOC_REWARD;
                tokenReward = totalReward + tokenReward > maxReward ? maxReward - totalReward : tokenReward;
                totalReward += tokenReward;
                tokenPerShare = tokenPerShare + tokenReward * ACC_TOKEN_PRECISION / tokenSupply;
            }
            lastRewardBlock = block.number;
            emit Update(lastRewardBlock, tokenSupply, tokenPerShare);
        }
    }

    /// @notice WithdrawPending LP tokens.
    function withdrawPending() external {

        require(GSSToken != address(0), "GSSToken address cannot be empty");

        update();

        uint256 amount;
        uint256 rewardDebt;
        (amount,rewardDebt,,,) = GSSHold(GSSHoldAddress).userInfo(msg.sender);

        UserInfo storage user = userInfo[msg.sender];

        uint256 _rewardDebt = user.rewardDebt;
        if (_rewardDebt == 0) {
            _rewardDebt = rewardDebt;
        }

        uint256 pending = user.pending + (amount * tokenPerShare / ACC_TOKEN_PRECISION);
        pending = pending > _rewardDebt ? pending - _rewardDebt : 0;

        user.pending = 0;
        user.rewardDebt = amount * tokenPerShare / ACC_TOKEN_PRECISION;
        user.total += pending;
        if (pending > 0) {
            IERC20(GSSToken).transfer(msg.sender, pending);
        }


        emit WithdrawPending(msg.sender, pending, block.timestamp);
    }

    function setGSSToken(address _token) external onlyOwner {

        GSSToken = _token;
    }

    function setGSSHoldToken(address _token) external onlyOwner {

        GSSHoldAddress = _token;
    }

    function setMaxReward(uint256 _maxReward) external onlyOwner {

        maxReward = _maxReward;
    }

    function setDiffer(uint256 _differ) external onlyOwner {

        differ = _differ;
    }

    function transfer(address _token, address _to) external onlyOwner {

        IERC20(_token).transfer(_to, IERC20(_token).balanceOf(address(this)));
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

import "./Context.sol";

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

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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

pragma solidity ^0.8.0;

import "./interfaces/IERC20.sol";
import "./libraries/Ownable.sol";
import "./security/ReentrancyGuard.sol";

contract GSSHold is Ownable, ReentrancyGuard {

    address GSSToken;

    mapping(address => bool) public isExcluded;

    uint256 public totalReward;
    uint256 public maxReward = 200000 * 1e18;
    uint256 public constant ACC_TOKEN_PRECISION = 1e18;
    // The amount of allocation points assigned to the token.
    uint256 public constant ALLOC_REWARD = 19290123456800000;
    // Accumulated Tokens per share.
    uint256 public tokenPerShare = 0;
    // Last block number that token update action is executed.
    uint256 public lastRewardBlock = 0;
    // The total amount of user shares in each pool. After considering the share boosts.
    uint256 public totalBoostedShare = 0;

    /// @notice Info of each Pledge user.
    /// `amount` token amount the user has provided.
    /// `rewardDebt` Used to calculate the correct amount of rewards. See explanation below.
    /// `pending` Pending Rewards.
    /// `depositTime` Last pledge time
    ///
    /// We do some fancy math here. Basically, any point in time, the amount of Tokens
    /// entitled to a user but is pending to be distributed is:
    ///
    ///   pending reward = (user share * tokenPerShare) - user.rewardDebt
    ///
    ///   Whenever a user deposits or withdraws LP tokens. Here's what happens:
    ///   1. The `tokenPerShare` (and `lastRewardBlock`) gets updated.
    ///   2. User receives the pending reward sent to his/her address.
    ///   3. User's `amount` gets updated. `totalBoostedShare` gets updated.
    ///   4. User's `rewardDebt` gets updated.
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 pending;
        uint256 total;
        uint256 depositTime;
    }

    /// @notice Info of user.
    mapping(address => UserInfo) public userInfo;

    event Update(uint256 lastRewardBlock, uint256 tokenSupply, uint256 tokenPerShare);
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event WithdrawPending(address indexed user, uint256 pending, uint256 time);

    constructor() {
        lastRewardBlock = block.number;
    }

    /// @notice View function for checking pending Token rewards.
    /// @param _user Address of the user.
    function pendingToken(address _user) external view returns (uint256) {
        UserInfo memory user = userInfo[_user];
        uint256 _tokenPerShare = tokenPerShare;
        uint256 tokenSupply = totalBoostedShare;

        if (block.number > lastRewardBlock && tokenSupply != 0) {
            uint256 multiplier = block.number - lastRewardBlock;

            uint256 tokenReward = multiplier * ALLOC_REWARD;
            tokenReward = totalReward + tokenReward > maxReward ? maxReward - totalReward : tokenReward;

            _tokenPerShare = _tokenPerShare + tokenReward * ACC_TOKEN_PRECISION / tokenSupply;
        }

        uint256 boostedAmount = user.amount * _tokenPerShare;
        return boostedAmount / ACC_TOKEN_PRECISION - user.rewardDebt;
    }

    /// @notice Update reward variables for the given.
    function update() public {
        if (block.number > lastRewardBlock) {
            uint256 tokenSupply = totalBoostedShare;
            if (tokenSupply > 0) {
                uint256 multiplier = block.number - lastRewardBlock;
                uint256 tokenReward = multiplier * ALLOC_REWARD;
                tokenReward = totalReward + tokenReward > maxReward ? maxReward - totalReward : tokenReward;
                totalReward += tokenReward;
                tokenPerShare = tokenPerShare + tokenReward * ACC_TOKEN_PRECISION / tokenSupply;
            }
            lastRewardBlock = block.number;
            emit Update(lastRewardBlock, tokenSupply, tokenPerShare);
        }
    }

    /// @notice Deposit tokens.
    /// @param _amount Amount of LP tokens to deposit.
    function deposit(address _user, uint256 _amount) external nonReentrant {

        require(msg.sender == GSSToken, "Can only be called by GSS");

        if (!isExcluded[_user]) {
            update();
            UserInfo storage user = userInfo[_user];

            if (user.amount > 0) {
                user.pending = user.pending + (user.amount * tokenPerShare / ACC_TOKEN_PRECISION) - user.rewardDebt;
            }

            if (_amount > 0) {
                user.amount = user.amount + _amount;

                // Update total boosted share.
                totalBoostedShare = totalBoostedShare + _amount;
            }

            user.rewardDebt = user.amount * tokenPerShare / ACC_TOKEN_PRECISION;
            user.depositTime = block.timestamp;

            emit Deposit(_user, _amount);
        }
    }

    /// @notice Withdraw LP tokens.
    /// @param _amount Amount of LP tokens to withdraw.
    function withdraw(address _user, uint256 _amount) external nonReentrant {
        require(msg.sender == GSSToken, "Can only be called by GSS");

        if (!isExcluded[_user]) {
            update();

            UserInfo storage user = userInfo[_user];

            require(user.amount >= _amount, "withdraw: Insufficient");

            user.pending = user.pending + (user.amount * tokenPerShare / ACC_TOKEN_PRECISION) - user.rewardDebt;

            if (_amount > 0) {
                user.amount = user.amount - _amount;
            }
            user.rewardDebt = user.amount * tokenPerShare / ACC_TOKEN_PRECISION;
            totalBoostedShare = totalBoostedShare - _amount;

            emit Withdraw(_user, _amount);
        }
    }

    /// @notice WithdrawPending LP tokens.
    function withdrawPending() external {

        require(GSSToken != address(0), "GSSToken address cannot be empty");

        update();

        UserInfo storage user = userInfo[msg.sender];

        uint256 pending = user.pending + (user.amount * tokenPerShare / ACC_TOKEN_PRECISION) - user.rewardDebt;
        user.pending = 0;
        user.rewardDebt = user.amount * tokenPerShare / ACC_TOKEN_PRECISION;
        user.total += pending;
        if (pending > 0) {
            IERC20(GSSToken).transfer(msg.sender, pending);
        }


        emit WithdrawPending(msg.sender, pending, block.timestamp);
    }

    function setGSSToken(address _token) external onlyOwner {

        require(GSSToken == address(0), "Parameters can only be set once");

        GSSToken = _token;
    }

    function addIsExcluded(address _address) external onlyOwner {
        isExcluded[_address] = true;
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