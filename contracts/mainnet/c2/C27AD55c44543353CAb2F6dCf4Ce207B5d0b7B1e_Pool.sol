// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./utils/Ownable.sol";
import "./utils/SafeERC20.sol";
import "./utils/IERC20.sol";
import "./utils/SafeMath.sol";
import "./DAPP.sol";


contract Pool is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 rewardTotal;
        uint256 tokenRewardDebt;
        uint256 tokenRewardTotal;
    }

    struct PoolInfo {
        IERC20 rewardToken;
        IERC20 lpToken;
        uint256 startBlock;
        uint256 bonusEndBlock;
        uint256 lastRewardBlock;
        uint256 accRewardPerShare;
        uint256 rewardPerBlock;

        uint256 accTokenRewardPerShare;
        uint256 rewardTokenPerBlock;

        uint256 totalReward;
        uint256 totalTokenReward;
        uint256 lpSupply;
    }

    uint256 public constant BONUS_MULTIPLIER = 1;


    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;


    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Claim(address indexed user, uint256 indexed pid, uint256 amount);


    address public dapp;
    address public invite;

    constructor(
        address payable _dapp,
        address payable _invite,
        IERC20 _lpToken,
        IERC20 _rewardToken,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        uint256 _rewardPerBlock,
        uint256 _rewardTokenPerBlock
    ) {

        dapp = _dapp;
        invite = _invite;

        require(_startBlock >= block.number, "startBlock must be in the future");

        require(
            _bonusEndBlock >= _startBlock,
            "bonusEndBlock must be greater than startBlock"
        );

        uint256 lastRewardBlock =
        block.number > _startBlock ? block.number : _startBlock;

        poolInfo.push(
            PoolInfo({
        rewardToken : _rewardToken,
        lpToken : _lpToken,
        startBlock : _startBlock,
        bonusEndBlock : _bonusEndBlock,
        lastRewardBlock : lastRewardBlock,
        accRewardPerShare : 0,
        rewardPerBlock : _rewardPerBlock,
        accTokenRewardPerShare : 0,
        rewardTokenPerBlock : _rewardTokenPerBlock,
        totalReward : 0,
        totalTokenReward : 0,
        lpSupply : 0
        })
        );

    }

    function setDAPP(address payable _dapp) public onlyOwner {
        dapp = _dapp;
    }

    function setInvite(address payable _invite) public onlyOwner {
        invite = _invite;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function editPool(
        address _lpToken,
        address _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _bonusEndBlock,
        uint256 _rewardTokenPerBlock
    ) public onlyOwner {
        updatePool(0);
        poolInfo[0].lpToken = IERC20(_lpToken);
        poolInfo[0].rewardToken = IERC20(_rewardToken);
        poolInfo[0].rewardTokenPerBlock = _rewardTokenPerBlock;
        poolInfo[0].rewardPerBlock = _rewardPerBlock;
        poolInfo[0].bonusEndBlock = _bonusEndBlock;
    }


    function getMultiplier(
        uint256 _from,
        uint256 _to,
        uint256 _pid
    ) public view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        if (_to <= pool.bonusEndBlock) {
            return _to.sub(_from).mul(BONUS_MULTIPLIER);
        } else if (_from >= pool.bonusEndBlock) {
            return _to.sub(_from);
        } else {
            return
            pool.bonusEndBlock.sub(_from).mul(BONUS_MULTIPLIER).add(
                _to.sub(pool.bonusEndBlock)
            );
        }
    }

    function pendingInfo(uint256 _pid, address _user)
    external
    view
    returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;
        uint256 lpSupply = pool.lpSupply;
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(
                pool.lastRewardBlock,
                block.number,
                _pid
            );
            uint256 reward = multiplier.mul(pool.rewardPerBlock);
            accRewardPerShare = accRewardPerShare.add(
                reward.mul(1e12).div(lpSupply)
            );
        }
        return
        user.amount.mul(accRewardPerShare).div(1e12).sub(user.rewardDebt);
    }

    // Update reward vairables for all pools. Be careful of gas spending!
    //更新所有矿池信息
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    //更新某个矿池信息
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpSupply;
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = getMultiplier(
            pool.lastRewardBlock,
            block.number,
            _pid
        );

        uint256 reward = multiplier.mul(pool.rewardPerBlock);
        uint256 tokenReward = multiplier.mul(pool.rewardTokenPerBlock);

        pool.accRewardPerShare = pool.accRewardPerShare.add(
            reward.mul(1e12).div(lpSupply)
        );
        pool.accTokenRewardPerShare = pool.accTokenRewardPerShare.add(
            tokenReward.mul(1e12).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _amount, address _parent) public {

        if (_parent != address(0) && Invite(invite).getParent(_msgSender()) == address(0)) {
            Invite(invite).setParentBySettingRole(_msgSender(), _parent);
        }

        uint256 _pid = 0;
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user
            .amount
            .mul(pool.accRewardPerShare)
            .div(1e12)
            .sub(user.rewardDebt);
            user.rewardTotal = user.rewardTotal.add(pending);

            uint256 pendingToken = user
            .amount
            .mul(pool.accTokenRewardPerShare)
            .div(1e12)
            .sub(user.tokenRewardDebt);
            user.tokenRewardTotal = user.tokenRewardTotal.add(pendingToken);


            DAPP(dapp).setTokenBalance(_msgSender(), DAPP(dapp).tokenBalance(_msgSender()).add(pendingToken));
            pool.rewardToken.safeTransfer(msg.sender, pending);

            pool.totalReward = pool.totalReward.add(pending);
            pool.totalTokenReward = pool.totalTokenReward.add(pendingToken);
        }
        pool.lpToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        user.amount = user.amount.add(_amount);

        user.tokenRewardDebt = user.amount.mul(pool.accTokenRewardPerShare).div(1e12);
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
        pool.lpSupply = pool.lpSupply.add(_amount);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _amount) public {
        uint256 _pid = 0;
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accRewardPerShare).div(1e12).sub(
            user.rewardDebt
        );
        user.rewardTotal = user.rewardTotal.add(pending);

        uint256 pendingToken = user
        .amount
        .mul(pool.accTokenRewardPerShare)
        .div(1e12)
        .sub(user.tokenRewardDebt);
        user.tokenRewardTotal = user.tokenRewardTotal.add(pendingToken);

        DAPP(dapp).setTokenBalance(_msgSender(), DAPP(dapp).tokenBalance(_msgSender()).add(pendingToken));
        pool.rewardToken.safeTransfer(msg.sender, pending);

        pool.totalReward = pool.totalReward.add(pending);
        pool.totalTokenReward = pool.totalTokenReward.add(pendingToken);

        user.amount = user.amount.sub(_amount);
        user.tokenRewardDebt = user.amount.mul(pool.accTokenRewardPerShare).div(1e12);
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);

        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        pool.lpSupply = pool.lpSupply.sub(_amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function claim() public {
        uint256 _pid = 0;
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accRewardPerShare).div(1e12).sub(
            user.rewardDebt
        );
        user.rewardTotal = user.rewardTotal.add(pending);

        uint256 pendingToken = user
        .amount
        .mul(pool.accTokenRewardPerShare)
        .div(1e12)
        .sub(user.tokenRewardDebt);
        user.tokenRewardTotal = user.tokenRewardTotal.add(pendingToken);

        DAPP(dapp).setTokenBalance(_msgSender(), DAPP(dapp).tokenBalance(_msgSender()).add(pendingToken));
        pool.rewardToken.safeTransfer(msg.sender, pending);

        pool.totalReward = pool.totalReward.add(pending);
        pool.totalTokenReward = pool.totalTokenReward.add(pendingToken);

        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
        user.tokenRewardDebt = user.amount.mul(pool.accTokenRewardPerShare).div(1e12);
        emit Claim(msg.sender, _pid, pending);
    }


    function rescueToken(address tokenAddress, uint256 tokens)
    public
    onlyOwner
    returns (bool success)
    {
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }

    function rescueBNB(address payable _recipient) public onlyOwner {
        _recipient.transfer(address(this).balance);
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./utils/Ownable.sol";
import "./utils/Context.sol";
import "./utils/SafeMath.sol";
import "./utils/IERC20.sol";

contract Invite is Ownable {

    using SafeMath for uint256;

    address public rootAddress;
    mapping(address => address)  public parents;
    mapping(address => address[]) public children;
    mapping(address => uint256) public groupCount;
    mapping(address => bool) public settingRole;

    constructor(address _rootAddress) {
        rootAddress = _rootAddress;
    }

    function setRootAddress(address _rootAddress) public onlyOwner {
        rootAddress = _rootAddress;
    }

    function getChildren(address _address) external view returns (address[] memory) {
        return children[_address];
    }

    function getParent(address _address) external view returns (address) {
        return parents[_address];
    }

    function setSettingRole(address _address, bool _role) external onlyOwner {
        settingRole[_address] = _role;
    }

    function setParentBySettingRole(address _address, address _parent) external {
        require(settingRole[_msgSender()], "not allowed");
        require(parents[_address] == address(0), "has parent");
        require(_parent != _address, "no self");
        require(
            parents[_parent] != address(0) || _parent == rootAddress,
            "parent must have parent or owner"
        );
        parents[_address] = _parent;
        children[_parent].push(_address);
        setGroupCount(_address);
    }

    function setParent(address _parent) public {
        require(parents[_msgSender()] == address(0), "has parent");
        require(_parent != _msgSender(), "no self");
        require(
            parents[_parent] != address(0) || _parent == rootAddress,
            "parent must have parent or owner"
        );
        parents[_msgSender()] = _parent;
        children[_parent].push(_msgSender());
        setGroupCount(_msgSender());
    }

    function setGroupCount(address _address) private {
        address parent = parents[_address];
        for (uint256 i = 0; i < 3; i++) {
            if (parent == address(0)) {
                break;
            }
            groupCount[parent]++;
            parent = parents[parent];
        }
    }

    function getTradeInviteAmounts(
        uint256 amount,
        uint256 rate,
        uint256[3] memory rates
    ) public pure returns (uint256[3] memory) {
        uint256[3] memory amounts;
        for (uint i = 0; i < 3; i++) {
            amounts[i] = amount.mul(rate).div(10000).mul(rates[i]).div(10000);
        }
        return amounts;
    }

    function getParentsByLevel(address _address, uint256 level)
    public
    view
    returns (address[] memory)
    {
        address[] memory p = new address[](level);
        address parent = parents[_address];
        for (uint256 i = 0; i < level; i++) {
            p[i] = parent;
            parent = parents[parent];
        }
        return p;
    }

    function rescueToken(address tokenAddress, uint256 tokens)
    public
    onlyOwner
    returns (bool success)
    {
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }

    function rescueBNB(address payable _recipient) public onlyOwner {
        _recipient.transfer(address(this).balance);
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./utils/SafeERC20.sol";
import "./utils/IERC20.sol";
import "./utils/Ownable.sol";
import "./utils/SafeMath.sol";
import "./Invite.sol";

contract DAPP is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public immutable deadAddress =
    0x000000000000000000000000000000000000dEaD;

    address public invite;
    address public token;

    uint256 public rewardInviteRate;
    uint256[3] public inviteRates;
    uint256 public totalReward;

    mapping(address => uint256) public tokenBalance;
    mapping(address => bool) public tokenRole;

    struct Product {
        uint256 price;
        uint256 amount;
        uint256 cycle;
        uint256 tokenUse;
    }

    struct Order {
        address user;
        uint256 price;
        uint256 amount;
        uint256 startBlock;
        uint256 endBlock;
        uint256 lastRewardBlock;
        uint256 perBlockReward;
        uint256 rewardDebt;
    }


    Product[] public products;
    mapping(address => Order[]) public orders;

    constructor(address _invite, address _token) {
        token = _token;
        invite = _invite;
        rewardInviteRate = 500;
        inviteRates = [5000, 3000, 2000];
    }

    function setRate(uint256 _rewardInviteRate, uint256[3] memory _inviteRates) public onlyOwner {
        rewardInviteRate = _rewardInviteRate;
        inviteRates = _inviteRates;
    }

    function getProducts() external view returns (Product[] memory) {
        return products;
    }

    function getOrders(address _user) external view returns (Order[] memory) {
        return orders[_user];
    }

    function setAddresses(address _invite, address _token) public onlyOwner {
        invite = _invite;
        token = _token;
    }

    function addProduct(
        uint256 _price,
        uint256 _amount,
        uint256 _cycle,
        uint256 _tokenUse
    ) public onlyOwner {
        products.push(Product(_price, _amount, _cycle, _tokenUse));
    }

    function removeProduct(uint256 _pid) public onlyOwner {
        for (uint i = _pid; i < products.length - 1; i++) {
            products[i] = products[i + 1];
        }
        products.pop();
    }

    function updateProduct(
        uint256 _pid,
        uint256 _price,
        uint256 _amount,
        uint256 _cycle,
        uint256 _tokenUse
    ) public onlyOwner {
        products[_pid].price = _price;
        products[_pid].amount = _amount;
        products[_pid].cycle = _cycle;
        products[_pid].tokenUse = _tokenUse;
    }

    function getMultiplier(
        uint256 _from,
        uint256 _to,
        address _user,
        uint256 _oid
    ) public view returns (uint256) {
        Order storage order = orders[_user][_oid];
        if (_to <= order.endBlock) {
            return _to.sub(_from);
        } else if (_from >= order.endBlock) {
            return _to.sub(_from);
        } else {
            return
            order.endBlock.sub(_from).add(
                _to.sub(order.endBlock)
            );
        }
    }

    function pendingInfo(address _user, uint256 _oid)
    external
    view
    returns (uint256)
    {
        Order storage order = orders[_user][_oid];
        if (block.number > order.lastRewardBlock) {
            uint256 multiplier = getMultiplier(
                order.lastRewardBlock,
                block.number,
                _user,
                _oid
            );
            uint256 reward = multiplier.mul(order.perBlockReward);
            return reward;
        } else {
            return 0;
        }
    }

    function claim(uint256 _oid) external {
        address _user = _msgSender();
        Order storage order = orders[_user][_oid];
        uint256 multiplier = getMultiplier(
            order.lastRewardBlock,
            block.number,
            _user,
            _oid
        );
        uint256 reward = multiplier.mul(order.perBlockReward);
        order.rewardDebt = order.rewardDebt.add(reward);

        uint256[3] memory amounts = Invite(invite).getTradeInviteAmounts(reward, rewardInviteRate, inviteRates);
        address[] memory invites = Invite(invite).getParentsByLevel(_user, 3);
        address root = Invite(invite).rootAddress();

        for (uint256 i = 0; i < invites.length; i++) {
            if (invites[i] != address(0)) {
                IERC20(token).safeTransfer(invites[i], amounts[i]);
            } else {
                IERC20(token).safeTransfer(root, amounts[i]);
            }
            reward = reward.sub(amounts[i]);
        }

        totalReward = totalReward.add(reward);
        IERC20(token).safeTransfer(_user, reward);
        order.lastRewardBlock = block.number;
        if (block.number > order.endBlock) {
            removeOrder(_user, _oid);
        }
    }

    function removeOrder(address _user, uint256 _oid) private {
        for (uint i = _oid; i < orders[_user].length - 1; i++) {
            orders[_user][i] = orders[_user][i + 1];
        }
        orders[_user].pop();
    }

    function buyProduct(uint256 _pid, address _parent) external {

        if (_parent != address(0) && Invite(invite).getParent(_msgSender()) == address(0)) {
            Invite(invite).setParentBySettingRole(_msgSender(), _parent);
        }

        Product memory product = products[_pid];

        require(tokenBalance[_msgSender()] >= product.tokenUse, "not enough token");
        tokenBalance[_msgSender()] = tokenBalance[_msgSender()].sub(product.tokenUse);

        IERC20(token).safeTransferFrom(_msgSender(), address(this), product.price);
        IERC20(token).safeTransfer(deadAddress, product.price);

        Order memory order = Order(_msgSender(),
            product.price,
            product.amount,
            block.number,
            block.number.add(product.cycle),
            block.number,
            product.amount.div(product.cycle),
            0);

        orders[_msgSender()].push(order);
    }

    function setTokenRole(address _address, bool _role) external onlyOwner {
        tokenRole[_address] = _role;
    }

    function setTokenBalance(address _address, uint256 _amount) external {
        require(tokenRole[_msgSender()], "not allowed");
        tokenBalance[_address] = _amount;
    }

    function rescueToken(address tokenAddress, uint256 tokens)
    public
    onlyOwner
    returns (bool success)
    {
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }

    function rescueBNB(address payable _recipient) public onlyOwner {
        _recipient.transfer(address(this).balance);
    }

}