pragma solidity ^0.8.6;

import "./utils/Governance.sol";
import "./utils/Context.sol";
import "./utils/SafeMath.sol";
import "./utils/IERC20.sol";
import "./utils/ERC20.sol";
import "./utils/SafeERC20.sol";
import "./utils/IPancakePair.sol";
import "./utils/IPancakeRouter01.sol";
import "./DAPP.sol";
import "./Pool.sol";

contract NewPool is Governance, Context {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    mapping(address => bool) public effects;
    mapping(address => bool) public nodes;
    mapping(address => bool) public isRenew;

    address public usdt;
    address public router;
    address public snto;
    address payable public dapp;
    address public pool;


    uint256 public nodeNumber;
    uint256 public effectAmount;

    struct UserInfo {
        uint256 amount;
        uint256 amountTotal;
        uint256 rewardDebt;
        uint256 rewardTotal;
    }

    struct PoolInfo {
        string name;
        bool isLp;
        IERC20 rewardToken;
        IERC20 lpToken;

        uint256 accRewardPerShare;
        uint256 lpSupply;
        uint256 reward;
        uint256 lastReward;
    }

    address private rootAddress;
    PoolInfo[] public pools;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Claim(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(address _snto, address payable _dapp, address _pair, address _usdt, address _router, address _pool) {
        nodeNumber = 5;
        effectAmount = 100 * 10 ** 18;

        snto = _snto;
        usdt = _usdt;
        router = _router;
        dapp = _dapp;
        pool = _pool;

        for (uint i = 0; i < 3; i++) {
            (string memory name,
            bool isLp,
            IERC20 rewardToken,
            IERC20 lpToken,

            uint256 accRewardPerShare,
            uint256 lpSupply,
            uint256 reward,
            uint256 lastReward) = Pool(pool).pools(i);
            pools.push(PoolInfo(name, isLp, rewardToken, lpToken, accRewardPerShare, lpSupply, reward, lastReward));
        }
        setGovernance(dapp);
    }

    function renew(address _address) public {
        require(!isRenew[_address], "renew: already");
        isRenew[_address] = true;
        for (uint i = 0; i < 3; i++) {
            (
            uint256 amount,
            uint256 amountTotal,
            uint256 rewardDebt,
            uint256 rewardTotal
            ) = Pool(pool).userInfo(i, _address);
            UserInfo memory user = UserInfo(amount, amountTotal, rewardDebt, rewardTotal);
            userInfo[i][_address] = user;
        }
        effects[_address] = Pool(pool).effects(_address);
        nodes[_address] = Pool(pool).nodes(_address);
    }

    function getUserInfo(uint256 _pid, address _user) public view returns (UserInfo memory) {
        if (!isRenew[_user]) {
            (
            uint256 amount,
            uint256 amountTotal,
            uint256 rewardDebt,
            uint256 rewardTotal
            ) = Pool(pool).userInfo(_pid, _user);
            UserInfo memory user = UserInfo(amount, amountTotal, rewardDebt, rewardTotal);
            return user;
        }
        return userInfo[_pid][_user];
    }

    function setEffectAmount(uint256 _amount) public onlyGovernance {
        effectAmount = _amount;
    }

    function setNodeNumber(uint256 _number) public onlyGovernance {
        nodeNumber = _number;
    }

    function setAddresses(address payable _dapp) public onlyGovernance {
        dapp = _dapp;
    }

    function poolAddReward(uint256 _pid, uint256 _amount) external onlyGovernance {
        updatePool(_pid);
        PoolInfo storage pool = pools[_pid];
        pool.reward = pool.reward.add(_amount);
    }

    function InviteAddAmount(address _user, uint256 _amount) external onlyGovernance {
        if (!isRenew[_user]) {
            renew(_user);
        }
        UserInfo storage user = userInfo[2][_user];
        user.amount = user.amount.add(_amount);
        user.amountTotal = user.amountTotal.add(_amount);
    }

    function inviteWithdraw(uint256 _amount) public {
        if (!isRenew[_msgSender()]) {
            renew(_msgSender());
        }
        uint _pid = 2;
        PoolInfo storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        user.amount = user.amount.sub(_amount);
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }


    function getPool(uint256 _pid) public view returns (PoolInfo memory) {
        return pools[_pid];
    }

    function addPoolReward(uint256 _amount) external onlyGovernance {
        updatePool(0);
        PoolInfo storage pool = pools[0];
        pool.reward = pool.reward.add(_amount);
    }

    function addNodeReward(uint256 _amount) external onlyGovernance {
        updatePool(1);
        PoolInfo storage pool = pools[1];
        pool.reward = pool.reward.add(_amount);
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = pools[_pid];
        uint256 lpSupply = pool.lpSupply;
        if (lpSupply == 0) {
            return;
        }
        if (pool.reward <= pool.lastReward) {
            return;
        }

        uint256 reward = pool.reward - pool.lastReward;
        pool.accRewardPerShare = pool.accRewardPerShare.add(reward.mul(1e12).div(lpSupply));
        pool.lastReward = pool.reward;
    }


    function pendingReward(uint256 _pid, address _user) public view returns (uint256) {
        PoolInfo memory pool = pools[_pid];
        UserInfo memory user = getUserInfo(_pid, _user);
        uint256 accRewardPerShare = pool.accRewardPerShare;
        uint256 lpSupply = pool.lpSupply;
        if (pool.reward > pool.lastReward && lpSupply != 0) {
            uint256 reward = pool.reward - pool.lastReward;
            accRewardPerShare = accRewardPerShare.add(
                reward.mul(1e12).div(lpSupply)
            );
        }
        return
        user.amount.mul(accRewardPerShare).div(1e12).sub(user.rewardDebt);
    }


    function massUpdatePools() public {
        uint256 length = pools.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }


    function withdraw(uint256 _amount) public {
        if (!isRenew[_msgSender()]) {
            renew(_msgSender());
        }
        uint _pid = 0;
        PoolInfo storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        require(pool.isLp, "not lp");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accRewardPerShare).div(1e12).sub(
            user.rewardDebt
        );
        user.rewardTotal = user.rewardTotal.add(pending);
        pool.rewardToken.safeTransfer(msg.sender, pending);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        pool.lpSupply = pool.lpSupply.sub(_amount);
        emit Withdraw(msg.sender, _pid, _amount);
        checkEffect(msg.sender);
    }


    function claim(uint256 _pid, address _parent) public {
        if (!isRenew[_msgSender()]) {
            renew(_msgSender());
        }

        if (DAPP(dapp).parents(_msgSender()) == address(0) && _parent != address(0)) {
            DAPP(dapp).setParentByGovernance(_msgSender(), _parent);
        }

        PoolInfo storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accRewardPerShare).div(1e12).sub(
            user.rewardDebt
        );
        user.rewardTotal = user.rewardTotal.add(pending);
        pool.rewardToken.safeTransfer(msg.sender, pending);
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
        emit Claim(msg.sender, _pid, pending);
    }

    function nodeChangeEffect(address _user, uint256 _count) private {
        if (!isRenew[_user]) {
            renew(_user);
        }
        uint _pid = 1;
        PoolInfo storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user
            .amount
            .mul(pool.accRewardPerShare)
            .div(1e12)
            .sub(user.rewardDebt);
            user.rewardTotal = user.rewardTotal.add(pending);
            pool.rewardToken.safeTransfer(_user, pending);
        }
        if (user.amount > _count) {
            uint256 change = user.amount.sub(_count);
            user.amount = user.amount.sub(change);
            pool.lpSupply = pool.lpSupply.sub(change);
        } else {
            uint256 change = _count.sub(user.amount);
            user.amount = user.amount.add(change);
            pool.lpSupply = pool.lpSupply.add(change);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
    }

    function deposit(uint256 _amount, address _parent) public {
        if (!isRenew[_msgSender()]) {
            renew(_msgSender());
        }

        if (DAPP(dapp).parents(_msgSender()) == address(0) && _parent != address(0)) {
            DAPP(dapp).setParentByGovernance(_msgSender(), _parent);
        }

        uint _pid = 0;
        PoolInfo storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(pool.isLp, "not lp");
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user
            .amount
            .mul(pool.accRewardPerShare)
            .div(1e12)
            .sub(user.rewardDebt);
            user.rewardTotal = user.rewardTotal.add(pending);
            pool.rewardToken.safeTransfer(msg.sender, pending);
        }
        pool.lpToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
        pool.lpSupply = pool.lpSupply.add(_amount);
        emit Deposit(msg.sender, _pid, _amount);
        checkEffect(msg.sender);
    }

    function getLpUSDTPrice(address _lpToken) public view returns (uint256) {
        address token0 = IPancakePair(_lpToken).token0();
        address token1 = IPancakePair(_lpToken).token1();
        uint256 totalSupply = IPancakePair(_lpToken).totalSupply();
        uint256 reserve0 = IERC20(token0).balanceOf(_lpToken);
        uint256 reserve1 = IERC20(token1).balanceOf(_lpToken);
        uint256 price0;
        uint256 price1;
        if (token0 == address(usdt)) {
            price0 = 1e18;
        } else {
            price0 = getUSDTPrice(token0);
        }
        if (token1 == address(usdt)) {
            price1 = 1e18;
        } else {
            price1 = getUSDTPrice(token1);
        }
        uint256 lpPrice = price0.mul(reserve0).add(price1.mul(reserve1)).div(totalSupply);
        return lpPrice;
    }

    function getUSDTPrice(address _token) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = _token;
        path[1] = address(usdt);
        uint256[] memory amounts = IPancakeRouter01(router).getAmountsOut(1e18, path);
        return amounts[1];
    }

    function isNode(address _user) external view returns (bool) {
        return nodes[_user];
    }

    function isEffect(address _user) external view returns (bool) {
        return effects[_user];
    }

    function getEffectCount(address parent) public view returns (uint256) {
        address[] memory children = DAPP(payable(dapp)).getChildren(parent);
        uint count = 0;
        for (uint256 i = 0; i < children.length; i++) {
            if (effects[children[i]]) {
                count++;
            }
        }
        return count;
    }

    function checkNode(address parent) public {
        if (!isRenew[parent]) {
            renew(parent);
        }
        (uint256 amount, uint count) = getChildrenAmountAndEffectCount(parent);
        if (count >= nodeNumber) {
            nodes[parent] = true;
            nodeChangeEffect(parent, amount);
        } else {
            nodes[parent] = false;
            nodeChangeEffect(parent, 0);
        }
    }

    function getChildrenAmountAndEffectCount(address parent) public view returns (uint256, uint){
        uint256 _pid = 0;
        address[] memory children = DAPP(payable(dapp)).getChildren(parent);
        uint count = 0;
        uint256 amount;
        for (uint256 i = 0; i < children.length; i++) {
            UserInfo memory child = getUserInfo(_pid, children[i]);
            amount = amount.add(child.amount);
            if (effects[children[i]]) {
                count++;
            }
        }
        return (amount, count);
    }

    function checkEffect(address _user) public {
        if (!isRenew[_msgSender()]) {
            renew(_msgSender());
        }
        uint256 _pid = 0;
        PoolInfo storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 price = getLpUSDTPrice(address(pool.lpToken));
        if (price.mul(user.amount).div(1e18) >= effectAmount) {
            effects[_user] = true;
        } else {
            effects[_user] = false;
        }
        address parent = DAPP(payable(dapp)).parents(_user);
        if (parent != address(0)) {
            checkNode(parent);
        }
    }

    function rescueToken(address tokenAddress, uint256 tokens)
    public
    onlyGovernance
    returns (bool success)
    {
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }

    function rescueBNB(address payable _recipient) public onlyGovernance {
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

pragma solidity >=0.6.2;

import './IPancakeRouter01.sol';

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity >=0.6.2;

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

pragma solidity >=0.5.0;

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

pragma solidity >=0.5.0;

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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

pragma solidity ^0.8.0;

contract Governance {
    mapping(address => bool) public _governance;

    constructor() {
        _governance[tx.origin] = true;
    }

    modifier onlyGovernance {
        require(_governance[msg.sender], "not governance");
        _;
    }

    function setGovernance(address governance) public onlyGovernance {
        require(governance != address(0), "new governance the zero address");
        _governance[governance] = true;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;

import "./utils/Ownable.sol";
import "./utils/SafeERC20.sol";
import "./utils/IERC20.sol";
import "./utils/ERC20.sol";
import "./utils/IPancakeRouter02.sol";
import "./utils/IPancakeFactory.sol";
import "./utils/IPancakePair.sol";
import "./utils/SafeMath.sol";
import "./utils/Address.sol";

contract SNTO is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    receive() external payable {}

    string private _name;
    string private _symbol;
    uint8 private _decimals = 18;

    address public marketingAddress;
    address public usdtAddress;

    uint256 public sellFeeRate;
    uint256 public buyFeeRate;
    uint256 public transFeeRate;

    uint256 public removeRate;
    uint256 public removeLPBurnRate;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) public isMarketPair;
    mapping(address => bool) public isBlackList;
    mapping(address => bool) public isExcludedFromFee;

    uint256 public startTime;
    uint256 public removeLPFeeDuration;

    bool public takeFeeDisabled;
    bool public allowSell;
    bool public allowBuy;
    bool public addLiquidityEnabled;
    bool public feeConvertEnabled;

    address public immutable deadAddress =
    0x000000000000000000000000000000000000dEaD;
    uint256 private _totalSupply = 10000000000 * 10 ** _decimals;
    address public router;
    address public pairAddress;
    bool inSwapAndLiquify;

    constructor(
        address _marketing,
        address _routerAddress,
        address _usdtAddress
    ) {
        _name = "Santosa Bank";
        _symbol = "SNTO";

        router = _routerAddress;
        marketingAddress = _marketing;


        sellFeeRate = 600;
        buyFeeRate = 600;
        transFeeRate = 600;

        removeLPBurnRate = 5000;
        removeRate = 600;
        removeLPFeeDuration = 30 days;

        startTime = block.timestamp;
        usdtAddress = _usdtAddress;

        pairAddress = IPancakeFactory(IPancakeRouter01(router).factory())
        .createPair(address(this), _usdtAddress);

        isExcludedFromFee[_marketing] = true;
        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;
        isMarketPair[address(pairAddress)] = true;

        addLiquidityEnabled = false;
        allowSell = false;
        allowBuy = false;
        takeFeeDisabled = false;
        feeConvertEnabled = false;

        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function setExcludedFromFee(address _address, bool _excluded) public onlyOwner {
        isExcludedFromFee[_address] = _excluded;
    }

    function setRates(uint256 _sell, uint256 _buy, uint256 _trans, uint256 _removeBurn, uint256 _remove) public onlyOwner {
        sellFeeRate = _sell;
        buyFeeRate = _buy;
        transFeeRate = _trans;
        removeLPBurnRate = _removeBurn;
        removeRate = _remove;
    }

    function setRemoveLPFeeDuration(uint256 _duration) public onlyOwner {
        removeLPFeeDuration = _duration;
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

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender)
    public
    view
    override
    returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function approve(address spender, uint256 amount)
    public
    override
    returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setMarketPairStatus(address account, bool newValue)
    public
    onlyOwner
    {
        isMarketPair[account] = newValue;
    }

    function setFeeConvertEnabled(bool _value) public onlyOwner {
        feeConvertEnabled = _value;
    }

    function setTakeFeeDisabled(bool _value) public onlyOwner {
        takeFeeDisabled = _value;
    }

    function setTradeEnabled(bool _buy, bool _sell) public onlyOwner {
        allowBuy = _buy;
        allowSell = _sell;
    }

    function setAddLiquidityEnabled(bool _value) public onlyOwner {
        addLiquidityEnabled = _value;
    }

    function setIsBlackList(address account, bool newValue) public onlyOwner {
        isBlackList[account] = newValue;
    }

    function setAddress(address _marketing) external onlyOwner {
        marketingAddress = _marketing;
        isExcludedFromFee[marketingAddress] = true;
    }

    function transfer(address recipient, uint256 amount)
    public
    override
    returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if (inSwapAndLiquify) {
            _basicTransfer(sender, recipient, amount);
        } else {
            require(
                !isBlackList[sender] && !isBlackList[recipient],
                "address is black"
            );
            if (amount == 0) {
                _balances[recipient] = _balances[recipient].add(amount);
                return;
            }

            _balances[sender] = _balances[sender].sub(
                amount,
                "Insufficient Balance"
            );

            bool needTakeFee;
            bool isRemoveLP;
            bool isAdd;

            if (!isExcludedFromFee[sender] && !isExcludedFromFee[recipient]) {
                needTakeFee = true;
                if (isMarketPair[recipient]) {
                    isAdd = _isAddLiquidity();
                    if (isAdd) {
                        require(addLiquidityEnabled, "add liquidity is disabled");
                        needTakeFee = false;
                    }
                } else {
                    isRemoveLP = _isRemoveLiquidity();
                }
            }


            if (
                feeConvertEnabled &&
                isMarketPair[recipient] &&
                balanceOf(address(this)) > 0
            ) {
                swapTokensForUSDT(balanceOf(address(this)), marketingAddress);
            }

            uint256 finalAmount = (isExcludedFromFee[sender] ||
            isExcludedFromFee[recipient]) ||
            takeFeeDisabled ||
            !needTakeFee
            ? amount
            : takeFee(sender, recipient, amount, isRemoveLP);

            _balances[recipient] = _balances[recipient].add(finalAmount);

            emit Transfer(sender, recipient, finalAmount);
        }
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapTokensForUSDT(uint256 tokenAmount, address to)
    private
    lockTheSwap
    {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = 0x55d398326f99059fF775485246999027B3197955;

        _approve(address(this), address(router), tokenAmount);

        IPancakeRouter02(router)
        .swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     */
    function rescueTokens(address _tokenAddress) external onlyOwner {
        require(_tokenAddress != address(this), "cannot be this token");
        IERC20(_tokenAddress).safeTransfer(
            address(msg.sender),
            IERC20(_tokenAddress).balanceOf(address(this))
        );
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 amount,
        bool isRemoveLP
    ) internal returns (uint256) {
        uint256 feeAmount = 0;
        address _sender = sender;
        uint256 _amount = amount;


        if (isMarketPair[sender] || isMarketPair[recipient]) {
            uint256 removeAmount = 0;
            uint256 removeBurnAmount = 0;
            uint256 sellAmount = 0;
            uint256 buyAmount = 0;
            if (isRemoveLP) {
                if (block.timestamp < startTime + removeLPFeeDuration) {
                    removeBurnAmount = _amount.mul(removeLPBurnRate).div(10000);
                }
                removeAmount = _amount.mul(removeRate).div(10000);
            } else {
                if (isMarketPair[sender]) {
                    //buy
                    require(allowBuy, "buy closed");
                    buyAmount = _amount.mul(buyFeeRate).div(10000);
                }
                if (isMarketPair[recipient]) {
                    //sell
                    require(allowSell, "sell closed");
                    sellAmount = _amount.mul(sellFeeRate).div(10000);
                }
            }

            if (removeBurnAmount > 0) {
                _balances[marketingAddress] = _balances[marketingAddress].add(
                    removeBurnAmount
                );
                emit Transfer(_sender, marketingAddress, removeBurnAmount);
            }

            if (removeAmount > 0) {
                _balances[address(this)] = _balances[address(this)].add(
                    removeAmount
                );
                emit Transfer(_sender, address(this), removeAmount);
            }
            if (sellAmount > 0) {
                _balances[address(this)] = _balances[address(this)].add(
                    sellAmount
                );
                emit Transfer(_sender, address(this), sellAmount);
            }
            if (buyAmount > 0) {
                _balances[address(this)] = _balances[address(this)].add(
                    buyAmount
                );
                emit Transfer(_sender, address(this), buyAmount);
            }
            feeAmount = removeBurnAmount.add(removeAmount).add(sellAmount).add(buyAmount);
        } else {
            //transfer
            uint256 transAmount = _amount.mul(transFeeRate).div(10000);
            if (transAmount > 0) {
                _balances[address(this)] = _balances[address(this)].add(
                    transAmount
                );
                emit Transfer(_sender, address(this), transAmount);
            }
            feeAmount = transAmount;
        }
        return _amount.sub(feeAmount);
    }

    function _isAddLiquidity() internal view returns (bool isAdd) {
        IPancakePair mainPair = IPancakePair(pairAddress);
        (uint256 r0, uint256 r1,) = mainPair.getReserves();
        address tokenOther = usdtAddress;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }

        uint256 bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isAdd = bal > r;
    }

    function _isRemoveLiquidity() internal view returns (bool isRemove) {
        IPancakePair mainPair = IPancakePair(pairAddress);
        (uint256 r0, uint256 r1,) = mainPair.getReserves();
        address tokenOther = usdtAddress;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0;
        } else {
            r = r1;
        }
        uint256 bal = IERC20(tokenOther).balanceOf(address(mainPair));
        isRemove = r >= bal;
    }
}

pragma solidity ^0.8.6;

import "./utils/Governance.sol";
import "./utils/Context.sol";
import "./utils/SafeMath.sol";
import "./utils/IERC20.sol";
import "./utils/ERC20.sol";
import "./utils/SafeERC20.sol";
import "./utils/IPancakePair.sol";
import "./utils/IPancakeRouter01.sol";
import "./DAPP.sol";

contract Pool is Governance, Context {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    mapping(address => bool) public effects;
    mapping(address => bool) public nodes;

    address public usdt;
    address public router;
    address public snto;
    address payable public dapp;


    uint256 public nodeNumber;
    uint256 public effectAmount;

    struct UserInfo {
        uint256 amount;
        uint256 amountTotal;
        uint256 rewardDebt;
        uint256 rewardTotal;
    }

    struct PoolInfo {
        string name;
        bool isLp;
        IERC20 rewardToken;
        IERC20 lpToken;

        uint256 accRewardPerShare;
        uint256 lpSupply;
        uint256 reward;
        uint256 lastReward;
    }

    address private rootAddress;
    PoolInfo[] public pools;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Claim(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(address _snto, address payable _dapp, address _pair, address _usdt, address _router) {
        nodeNumber = 5;
        effectAmount = 100 * 10 ** 18;

        snto = _snto;
        usdt = _usdt;
        router = _router;
        dapp = _dapp;

        addPool("SNTO LP", true, IERC20(snto), IERC20(_pair));
        addPool("Node", false, IERC20(snto), IERC20(snto));
        addPool("Invite", false, IERC20(snto), IERC20(snto));

        setGovernance(dapp);
    }

    function setEffectAmount(uint256 _amount) public onlyGovernance {
        effectAmount = _amount;
    }

    function setNodeNumber(uint256 _number) public onlyGovernance {
        nodeNumber = _number;
    }

    function setAddresses(address payable _dapp) public onlyGovernance {
        dapp = _dapp;
    }

    function poolAddReward(uint256 _pid, uint256 _amount) external onlyGovernance {
        updatePool(_pid);
        PoolInfo storage pool = pools[_pid];
        pool.reward = pool.reward.add(_amount);
    }

    function InviteAddAmount(address _user, uint256 _amount) external onlyGovernance {
        UserInfo storage user = userInfo[2][_user];
        user.amount = user.amount.add(_amount);
        user.amountTotal = user.amountTotal.add(_amount);
    }

    function inviteWithdraw(uint256 _amount) public {
        uint _pid = 2;
        PoolInfo storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        user.amount = user.amount.sub(_amount);
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function addPool(
        string memory _name,
        bool _isLp,
        IERC20 _rewardToken,
        IERC20 _lpToken
    ) private {
        pools.push(
            PoolInfo({
        name : _name,
        isLp : _isLp,
        rewardToken : _rewardToken,
        lpToken : _lpToken,
        accRewardPerShare : 0,
        lpSupply : 0,
        reward : 0,
        lastReward : 0
        })
        );
    }

    function getPool(uint256 _pid) public view returns (PoolInfo memory) {
        return pools[_pid];
    }

    function addPoolReward(uint256 _amount) external onlyGovernance {
        updatePool(0);
        PoolInfo storage pool = pools[0];
        pool.reward = pool.reward.add(_amount);
    }

    function addNodeReward(uint256 _amount) external onlyGovernance {
        updatePool(1);
        PoolInfo storage pool = pools[1];
        pool.reward = pool.reward.add(_amount);
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = pools[_pid];
        uint256 lpSupply = pool.lpSupply;
        if (lpSupply == 0) {
            return;
        }
        if (pool.reward <= pool.lastReward) {
            return;
        }

        uint256 reward = pool.reward - pool.lastReward;
        pool.accRewardPerShare = pool.accRewardPerShare.add(reward.mul(1e12).div(lpSupply));
        pool.lastReward = pool.reward;
    }

    function pendingReward(uint256 _pid, address _user) public view returns (uint256) {
        PoolInfo storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;
        uint256 lpSupply = pool.lpSupply;
        if (pool.reward > pool.lastReward && lpSupply != 0) {
            uint256 reward = pool.reward - pool.lastReward;
            accRewardPerShare = accRewardPerShare.add(
                reward.mul(1e12).div(lpSupply)
            );
        }
        return
        user.amount.mul(accRewardPerShare).div(1e12).sub(user.rewardDebt);
    }

    function massUpdatePools() public {
        uint256 length = pools.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }




    function withdraw(uint256 _amount) public {
        uint _pid = 0;
        PoolInfo storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        require(pool.isLp, "not lp");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accRewardPerShare).div(1e12).sub(
            user.rewardDebt
        );
        user.rewardTotal = user.rewardTotal.add(pending);
        pool.rewardToken.safeTransfer(msg.sender, pending);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        pool.lpSupply = pool.lpSupply.sub(_amount);
        emit Withdraw(msg.sender, _pid, _amount);
        checkEffect(msg.sender);
    }


    function claim(uint256 _pid, address _parent) public {

        if (DAPP(dapp).parents(_msgSender()) == address(0) && _parent != address(0)) {
            DAPP(dapp).setParentByGovernance(_msgSender(), _parent);
        }

        PoolInfo storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accRewardPerShare).div(1e12).sub(
            user.rewardDebt
        );
        user.rewardTotal = user.rewardTotal.add(pending);
        pool.rewardToken.safeTransfer(msg.sender, pending);
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
        emit Claim(msg.sender, _pid, pending);
    }

    function nodeChangeEffect(address _user, uint256 _count) private {
        uint _pid = 1;
        PoolInfo storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user
            .amount
            .mul(pool.accRewardPerShare)
            .div(1e12)
            .sub(user.rewardDebt);
            user.rewardTotal = user.rewardTotal.add(pending);
            pool.rewardToken.safeTransfer(msg.sender, pending);
        }
        if (user.amount > _count) {
            uint256 change = user.amount.sub(_count);
            user.amount = user.amount.sub(change);
            pool.lpSupply = pool.lpSupply.sub(change);
        } else {
            uint256 change = _count.sub(user.amount);
            user.amount = user.amount.add(change);
            pool.lpSupply = pool.lpSupply.add(change);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
    }
    function deposit(uint256 _amount, address _parent) public {

        if (DAPP(dapp).parents(_msgSender()) == address(0) && _parent != address(0)) {
            DAPP(dapp).setParentByGovernance(_msgSender(), _parent);
        }

        uint _pid = 0;
        PoolInfo storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(pool.isLp, "not lp");
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user
            .amount
            .mul(pool.accRewardPerShare)
            .div(1e12)
            .sub(user.rewardDebt);
            user.rewardTotal = user.rewardTotal.add(pending);
            pool.rewardToken.safeTransfer(msg.sender, pending);
        }
        pool.lpToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
        pool.lpSupply = pool.lpSupply.add(_amount);
        emit Deposit(msg.sender, _pid, _amount);
        checkEffect(msg.sender);
    }

    function getLpUSDTPrice(address _lpToken) public view returns (uint256) {
        address token0 = IPancakePair(_lpToken).token0();
        address token1 = IPancakePair(_lpToken).token1();
        uint256 totalSupply = IPancakePair(_lpToken).totalSupply();
        uint256 reserve0 = IERC20(token0).balanceOf(_lpToken);
        uint256 reserve1 = IERC20(token1).balanceOf(_lpToken);
        uint256 price0;
        uint256 price1;
        if (token0 == address(usdt)) {
            price0 = 1e18;
        } else {
            price0 = getUSDTPrice(token0);
        }
        if (token1 == address(usdt)) {
            price1 = 1e18;
        } else {
            price1 = getUSDTPrice(token1);
        }
        uint256 lpPrice = price0.mul(reserve0).add(price1.mul(reserve1)).div(totalSupply);
        return lpPrice;
    }

    function getUSDTPrice(address _token) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = _token;
        path[1] = address(usdt);
        uint256[] memory amounts = IPancakeRouter01(router).getAmountsOut(1e18, path);
        return amounts[1];
    }

    function isNode(address _user) external view returns (bool) {
        return nodes[_user];
    }

    function isEffect(address _user) external view returns (bool) {
        return effects[_user];
    }

    function getEffectCount(address parent) public view returns (uint256) {
        address[] memory children = DAPP(payable(dapp)).getChildren(parent);
        uint count = 0;
        for (uint256 i = 0; i < children.length; i++) {
            if (effects[children[i]]) {
                count++;
            }
        }
        return count;
    }

    function checkNode(address parent) public {
        (uint256 amount, uint count) = getChildrenAmountAndEffectCount(parent);
        if (count >= nodeNumber) {
            nodes[parent] = true;
            nodeChangeEffect(parent, amount);
        } else {
            nodes[parent] = false;
            nodeChangeEffect(parent, 0);
        }
    }

    function getChildrenAmountAndEffectCount(address parent) public view returns (uint256, uint){
        uint256 _pid = 0;
        address[] memory children = DAPP(payable(dapp)).getChildren(parent);
        uint count = 0;
        uint256 amount;
        for (uint256 i = 0; i < children.length; i++) {
            UserInfo storage child = userInfo[_pid][children[i]];
            amount = amount.add(child.amount);
            if (effects[children[i]]) {
                count++;
            }
        }
        return (amount, count);
    }

    function checkEffect(address _user) public {
        uint256 _pid = 0;
        PoolInfo storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 price = getLpUSDTPrice(address(pool.lpToken));
        if (price.mul(user.amount).div(1e18) >= effectAmount) {
            effects[_user] = true;
        } else {
            effects[_user] = false;
        }
        address parent = DAPP(payable(dapp)).parents(_user);
        if (parent != address(0)) {
            checkNode(parent);
        }
    }

    function rescueToken(address tokenAddress, uint256 tokens)
    public
    onlyGovernance
    returns (bool success)
    {
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }

    function rescueBNB(address payable _recipient) public onlyGovernance {
        _recipient.transfer(address(this).balance);
    }

}

pragma solidity ^0.8.6;

import "./utils/Ownable.sol";
import "./SNTO.sol";
import "./utils/IPancakeRouter01.sol";
import "./utils/IERC20.sol";
import "./utils/Governance.sol";
import "./Pool.sol";

contract DAPP is Governance, Context {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    receive() external payable {}

    mapping(address => address) public parents;
    mapping(address => address[]) private children;
    mapping(address => uint) public groupCount;

    address public router;
    address public usdt;
    address public snto;
    address public pool;
    address public pair;
    address public root;

    address private marketingAddress;

    uint256 superTradeLPRate;
    uint256 superTradeNodeRate;
    uint256 superRemoveRate;

    uint256 tradeLPRate;
    uint256 tradeNodeRate;
    uint256 removeRate;
    uint256[5] public rate;


    bool public enable;

    constructor(
        address _snto,
        address _pair,
        address _pool,
        address _router,
        address _usdt,
        address _marketingAddress
    ) {
        snto = _snto;
        pool = _pool;
        pair = _pair;
        router = _router;
        usdt = _usdt;
        marketingAddress = _marketingAddress;
        rate = [200, 25, 25, 25, 25];

        superTradeLPRate = 0;
        superTradeNodeRate = 100;
        superRemoveRate = 100;

        tradeLPRate = 200;
        tradeNodeRate = 100;
        removeRate = 600;

        enable = false;
    }

    function setRate(
        uint256 _superTradeLPRate,
        uint256 _superTradeNodeRate,
        uint256 _superRemoveRate,
        uint256 _tradeLPRate,
        uint256 _tradeNodeRate,
        uint256 _removeRate
    ) public onlyGovernance {
        superTradeLPRate = _superTradeLPRate;
        superTradeNodeRate = _superTradeNodeRate;
        superRemoveRate = _superRemoveRate;
        tradeLPRate = _tradeLPRate;
        tradeNodeRate = _tradeNodeRate;
        removeRate = _removeRate;
    }


    function setAddresses(
        address _marketingAddress,
        address _root,
        address _pool
    ) public onlyGovernance {
        marketingAddress = _marketingAddress;
        root = _root;
        pool = _pool;
    }

    function setRates(uint256[5] memory _rate) public onlyGovernance {
        rate = _rate;
    }

    function setEnable(bool _enable) public onlyGovernance {
        enable = _enable;
    }

    function removeLiquidity(uint256 _amount, address _parent) public {
        require(enable, "not enable");


        if (parents[_msgSender()] == address(0) && _parent != address(0)) {
            setParent(_parent);
        }

        IERC20(pair).transferFrom(_msgSender(), address(this), _amount);
        IERC20(pair).approve(router, _amount);
        IPancakeRouter01(router).removeLiquidity(
            usdt,
            address(snto),
            _amount,
            0,
            0,
            address(this),
            block.timestamp
        );

        uint256 _removeRate;
        uint256[5] memory _inviteAmounts;
        uint256 _tradeLPRate;
        uint256 _tradeNodeRate;

        bool isNode = Pool(pool).isNode(_msgSender());
        if (isNode) {
            _tradeLPRate = superTradeLPRate;
            _tradeNodeRate = superTradeNodeRate;
            _removeRate = superRemoveRate;
        } else {
            _inviteAmounts = getAmounts(_amount);
            _tradeLPRate = tradeLPRate;
            _tradeNodeRate = tradeNodeRate;
            _removeRate = removeRate;
        }

        uint256 usdtAmount = IERC20(usdt).balanceOf(address(this));
        uint256 sntoAmount = IERC20(snto).balanceOf(address(this));

        address[] memory sellSNTOPath = new address[](2);
        sellSNTOPath[0] = address(snto);
        sellSNTOPath[1] = usdt;

        if (_removeRate > 0) {
            uint256 removeSNTOAmount = sntoAmount.mul(_removeRate).div(10000);
            uint256 removeFeeAmount = usdtAmount.mul(_removeRate).div(10000);
            IERC20(snto).approve(router, removeSNTOAmount);
            IPancakeRouter01(router).swapExactTokensForTokens(
                removeSNTOAmount,
                0,
                sellSNTOPath,
                address(this),
                block.timestamp
            );
            uint256 removeFeeUSDT = IERC20(usdt).balanceOf(address(this)).sub(
                usdtAmount
            );
            uint256 fee = removeFeeAmount.add(removeFeeUSDT);
            IERC20(usdt).transfer(marketingAddress, fee);
        }

        uint256 SNTOBalance = IERC20(snto).balanceOf(address(this));

        uint256 tradeInviteAmount;
        uint256 tradeLpAmount;
        uint256 tradeNodeAmount;

        for (uint256 i = 0; i < _inviteAmounts.length; i++) {
            tradeInviteAmount = tradeInviteAmount.add(_inviteAmounts[i]);
        }

        tradeLpAmount = SNTOBalance.mul(_tradeLPRate).div(10000);
        tradeNodeAmount = SNTOBalance.mul(_tradeNodeRate).div(10000);

        if (tradeInviteAmount > 0) {
            IERC20(snto).transfer(address(pool), tradeInviteAmount);
            address[] memory invites = getParentsByLevel(_msgSender(), 5);
            for (uint256 i = 0; i < invites.length; i++) {
                if (invites[i] != address(0)) {
                    Pool(pool).InviteAddAmount(invites[i], _inviteAmounts[i]);
                } else {
                    Pool(pool).InviteAddAmount(root, _inviteAmounts[i]);
                }
            }
        }

        IERC20(snto).approve(router, IERC20(snto).balanceOf(address(this)));
        IPancakeRouter01(router).swapExactTokensForTokens(
            IERC20(snto).balanceOf(address(this)),
            0,
            sellSNTOPath,
            address(this),
            block.timestamp
        );

        IERC20(usdt).transfer(
            _msgSender(),
            IERC20(usdt).balanceOf(address(this))
        );
    }

    function addLiquidity(uint256 _amount, address _parent) external {
        require(enable, "not enable");

        if (parents[_msgSender()] == address(0) && _parent != address(0)) {
           setParent(_parent);
        }

        IERC20(usdt).transferFrom(_msgSender(), address(this), _amount);
        uint256 buyAmount = _amount.div(2);
        uint256 liquidityAmount = _amount.sub(buyAmount);

        address[] memory path = new address[](2);
        path[0] = usdt;
        path[1] = address(snto);

        IERC20(usdt).approve(router, buyAmount);
        IPancakeRouter01(router).swapExactTokensForTokens(
            buyAmount,
            0,
            path,
            address(this),
            block.timestamp
        );


        bool isNode = Pool(pool).isNode(_msgSender());

        uint256[5] memory _inviteAmounts;
        uint256 _tradeLPRate;
        uint256 _tradeNodeRate;

        if (isNode) {
            _tradeLPRate = superTradeLPRate;
            _tradeNodeRate = superTradeNodeRate;
        } else {
            _inviteAmounts = getAmounts(_amount);
            _tradeLPRate = tradeLPRate;
            _tradeNodeRate = tradeNodeRate;
        }

        uint256 tradeInviteAmount;
        uint256 tradeLpAmount;
        uint256 tradeNodeAmount;

        for (uint256 i = 0; i < _inviteAmounts.length; i++) {
            tradeInviteAmount = tradeInviteAmount.add(_inviteAmounts[i]);
        }

        tradeLpAmount = _amount.mul(_tradeLPRate).div(10000);
        tradeNodeAmount = _amount.mul(_tradeNodeRate).div(10000);
        if (tradeInviteAmount > 0) {
            IERC20(snto).transfer(address(pool), tradeInviteAmount);
            address[] memory invites = getParentsByLevel(_msgSender(), 5);
            for (uint256 i = 0; i < invites.length; i++) {
                if (invites[i] != address(0)) {
                    Pool(pool).InviteAddAmount(invites[i], _inviteAmounts[i]);
                } else {
                    Pool(pool).InviteAddAmount(root, _inviteAmounts[i]);
                }
            }
        }

        if (tradeLpAmount > 0) {
            IERC20(snto).transfer(address(pool), tradeLpAmount);
            Pool(pool).addPoolReward(tradeLpAmount);
        }

        if (tradeNodeAmount > 0) {
            IERC20(snto).transfer(address(pool), tradeNodeAmount);
            Pool(pool).addNodeReward(tradeNodeAmount);
        }

        IERC20(usdt).approve(router, liquidityAmount);
        IERC20(snto).approve(router, IERC20(snto).balanceOf(address(this)));
        IPancakeRouter01(router).addLiquidity(
            usdt,
            address(snto),
            liquidityAmount,
            IERC20(snto).balanceOf(address(this)),
            0,
            0,
            _msgSender(),
            block.timestamp
        );

        if (IERC20(usdt).balanceOf(address(this)) > 0) {
            IERC20(usdt).transfer(
                _msgSender(),
                IERC20(usdt).balanceOf(address(this))
            );
        }

        if (IERC20(snto).balanceOf(address(this)) > 0) {
            IERC20(snto).transfer(
                _msgSender(),
                IERC20(snto).balanceOf(address(this))
            );
        }
    }

    function setParent(address parent) public {
        require(parents[_msgSender()] == address(0), "parent exist");
        require(parent != _msgSender(), "parent can not be self");
        parents[_msgSender()] = parent;
        children[parent].push(_msgSender());
        setGroupCount(_msgSender());
    }

    function setParentByGovernance(address _address, address parent) public onlyGovernance {
        require(parents[_address] == address(0), "parent exist");
        require(parent != _address, "parent can not be self");
        parents[_address] = parent;
        children[parent].push(_address);
        setGroupCount(_address);
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

    function getChildrenLength(address _address) public view returns (uint256) {
        return children[_address].length;
    }

    function getChildren(address _address)
    public
    view
    returns (address[] memory)
    {
        return children[_address];
    }

    function getAmounts(uint256 _amount)
    public
    view
    returns (uint256[5] memory)
    {
        uint256[5] memory amounts;
        for (uint256 i = 0; i < 5; i++) {
            amounts[i] = _amount.mul(rate[i]).div(10000);
        }
        return amounts;
    }

    function setGroupCount(address _address) private {
        address parent = parents[_address];
        for (uint256 i = 0; i < 5; i++) {
            if (parent == address(0)) {
                break;
            }
            groupCount[parent]++;
            parent = parents[parent];
        }
    }

    function rescueToken(address tokenAddress, uint256 tokens)
    public
    onlyGovernance
    returns (bool success)
    {
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }

    function rescueBNB(address payable _recipient) public onlyGovernance {
        _recipient.transfer(address(this).balance);
    }
}