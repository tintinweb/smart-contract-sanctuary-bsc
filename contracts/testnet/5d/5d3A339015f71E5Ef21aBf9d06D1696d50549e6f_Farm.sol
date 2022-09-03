// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import {IRouter} from "./interfaces/IRouter.sol";
import {IPair} from "./interfaces/IPair.sol";
import {IUser} from "./interfaces/IUser.sol";
import {ICommission} from "./interfaces/ICommission.sol";

contract Farm is Ownable, Pausable {
    using SafeMath for uint256;

    struct Package {
        IERC20 lpToken;
        IERC20 quoteToken;
        uint256 quoteRateUSD;
        uint256 apy;
        uint256 min;
        uint256 max;
        bool enable;
    }

    struct UserInfo {
        uint256 amount;
        uint256 amountUSD;
        uint256 latestClaimTime;
    }

    Package[] public packageInfo;

    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    IERC20 public tokenReward = IERC20(0x2F6c6cE689C0231919713c5556213cF3895Fed3B);
    ICommission public commissionContract;
    address public userContract = 0xEA523f0776576e89C618F2b9a381B57B7b14b734;

    uint256[] public refReward = [10, 5, 5];
    uint256 public rewardTokenRateUSD = 100000000000000; // $0.0001

    event Harvest(address indexed user, uint256 amount, uint256 pid, uint256 timestamp);
    event Deposit(address indexed user, uint256 amount, uint256 pid, uint256 timestamp);
    event Remove(address indexed user, uint256 amount, uint256 pid, uint256 timestamp);
    event EmergencyWithdraw(address indexed user, uint256 amount, uint256 pid, uint256 timestamp);

    function harvest(uint256 _pid) public whenNotPaused {
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 pending = pendingReward(_pid, msg.sender);

        require(pending > 0, 'Staking: can not harvest');
        require(tokenReward.balanceOf(address(this)) >= pending, 'Staking: contract not enough balance to send reward');

        tokenReward.transfer(msg.sender, pending);
        user.latestClaimTime = block.timestamp;

        emit Harvest(msg.sender, pending, _pid, block.timestamp);
    }

    function emergencyWithdraw(uint256 _pid) public {
        Package memory package = packageInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount > 0, "Staking: can not emergency withdraw");
        require(package.lpToken.balanceOf(address(this)) >= user.amount, "Staking: contract not enough token");

        package.lpToken.transfer(msg.sender, user.amount);

        user.amount = 0;
        user.amountUSD = 0;
        user.latestClaimTime = block.timestamp;

        emit EmergencyWithdraw(msg.sender, user.amount, _pid, block.timestamp);
    }

    function remove(uint256 _pid, uint256 _amount) public whenNotPaused {
        Package memory package = packageInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount > 0 && user.amount >= _amount, "Staking: can not remove staking");
        uint256 pending = pendingReward(_pid, msg.sender);

        if (pending > 0) {
            require(tokenReward.balanceOf(address(this)) >= pending, 'Staking: contract not enough balance to send reward');
            tokenReward.transfer(msg.sender, pending);
            emit Harvest(msg.sender, pending, _pid, block.timestamp);
        }

        package.lpToken.transfer(msg.sender, _amount);

        uint256 totalSupplyLP = IPair(address(package.lpToken)).totalSupply();
        uint256 ratioLP = _amount.mul(1e18).div(totalSupplyLP);
        uint256 totalAmountQuoteToken = package.quoteToken.balanceOf(address(package.lpToken));
        uint256 amountQuoteTokenShare = totalAmountQuoteToken.mul(ratioLP).div(1e18);

        user.amount = user.amount.sub(_amount);
        user.amountUSD = user.amountUSD.sub(amountQuoteTokenShare.mul(package.quoteRateUSD).div(1e18));
        user.latestClaimTime = block.timestamp;

        emit Remove(msg.sender, _amount, _pid, block.timestamp);
    }

    function deposit(uint256 _pid, uint256 _amount) public whenNotPaused {
        Package memory package = packageInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 totalSupplyLP = IPair(address(package.lpToken)).totalSupply();
        uint256 ratioLP = _amount.mul(1e18).div(totalSupplyLP);
        uint256 totalAmountQuoteToken = package.quoteToken.balanceOf(address(package.lpToken));
        uint256 amountQuoteTokenShare = totalAmountQuoteToken.mul(ratioLP).div(1e18);
        require(package.enable, "Staking: package is not available");
        require(_amount > 0, "Staking: amount greater than zero");
        require(user.amountUSD.add(amountQuoteTokenShare.mul(package.quoteRateUSD).div(1e18)) >= package.min, "Staking: token deposit to small");
        require(user.amountUSD.add(amountQuoteTokenShare.mul(package.quoteRateUSD).div(1e18)) <= package.max, "Staking: limit staking this package");
        require(package.lpToken.balanceOf(msg.sender) >= _amount, "Staking: your balance not enough to staking");

        // transfer pending reward token if add more token deposit
        uint256 pending = pendingReward(_pid, msg.sender);
        if (pending > 0) {
            require(tokenReward.balanceOf(address(this)) >= pending, 'Staking: contract not enough balance to send reward');
            tokenReward.transfer(msg.sender, pending);
        }

        // reward ref
        sendRewardRef(amountQuoteTokenShare.mul(package.quoteRateUSD).div(1e18));

        package.lpToken.transferFrom(msg.sender, address(this), _amount);

        // update deposit package
        user.amount = user.amount.add(_amount);
        user.amountUSD = user.amountUSD.add(amountQuoteTokenShare.mul(package.quoteRateUSD).div(1e18));
        user.latestClaimTime = block.timestamp;
        emit Deposit(msg.sender, _amount, _pid, block.timestamp);
    }

    function sendRewardRef(uint256 _totalUSDDeposit) private {
        address _ref = IUser(userContract).getRef(address(msg.sender));
        if (_ref != address(0)) {
            // transfer reward f0
            commissionContract.add(_ref, _totalUSDDeposit.mul(refReward[0]).div(100).mul(1e18).div(rewardTokenRateUSD));
            address ref = IUser(userContract).getRef(_ref);
            for (uint256 i = 1; i < refReward.length; i++) {
                if (ref != address(0)) {
                    // transfer reward to Fn
                    commissionContract.add(ref, _totalUSDDeposit.mul(refReward[i]).div(100).mul(1e18).div(rewardTokenRateUSD));
                    ref = IUser(userContract).getRef(ref);
                }
            }
        }
    }

    function pendingReward(uint256 _pid, address _user) public view returns (uint256) {
        UserInfo memory user = userInfo[_pid][_user];
        Package memory package = packageInfo[_pid];
        if (!package.enable) {
            return 0;
        }
        if (user.amount == 0) {
            return 0;
        }
        uint256 apyYear = user.amountUSD.mul(package.apy).div(100);

        // usd per minutes
        uint256 usdPerMinute = apyYear.div(365).div(24).div(60);
        uint256 mi = block.timestamp.sub(user.latestClaimTime).div(60);
        uint256 totalUSDInMinutes = usdPerMinute.mul(mi).mul(1e18);

        // reverse usd to token
        return totalUSDInMinutes.div(rewardTokenRateUSD);
    }

    function add(IERC20 lpToken, IERC20 quoteToken, uint256 _quoteRateUSD, uint256 _apy, uint256 _min, uint256 _max) public onlyOwner {
        packageInfo.push(
            Package(lpToken, quoteToken, _quoteRateUSD, _apy, _min, _max, true)
        );
    }

    function set(uint256 _pid, IERC20 _lpToken, IERC20 _quoteToken, uint256 _quoteRateUSD, uint256 _apy, uint256 _min, uint256 _max, bool _enable) public onlyOwner {
        Package storage p = packageInfo[_pid];
        p.lpToken = _lpToken;
        p.quoteToken = _quoteToken;
        p.quoteRateUSD = _quoteRateUSD;
        p.apy = _apy;
        p.min = _min;
        p.max = _max;
        p.enable = _enable;
    }

    function packageLength() public view returns (uint256){
        return packageInfo.length;
    }

    function setTokenReward(IERC20 _token) public onlyOwner {
        tokenReward = _token;
    }

    // Clear unknown token
    function clearUnknownToken(address _tokenAddress) public onlyOwner {
        uint256 contractBalance = IERC20(_tokenAddress).balanceOf(address(this));
        IERC20(_tokenAddress).transfer(address(msg.sender), contractBalance);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setRefReward(uint256[] memory _refReward) public onlyOwner {
        refReward = _refReward;
    }

    function setUserContract(address _userContract) public onlyOwner {
        userContract = _userContract;
    }

    function setRewardTokenRateUSD(uint256 _rate) public onlyOwner {
        rewardTokenRateUSD = _rate;
    }

    function setCommissionContract(address _commission) public onlyOwner {
        commissionContract = ICommission(_commission);
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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

pragma solidity ^0.8.0;

interface IRouter {
	function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);

	function getAmountsIn(uint amountOut, address[] memory path) external view returns (uint[] memory amounts);
}

pragma solidity ^0.8.0;

interface IPair {
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IUser {
    function getRef(address account) external view returns (address);
}

pragma solidity ^0.8.0;

interface ICommission {
    function add(address _address, uint256 _amount) external;
    function minus(address _address, uint256 _amount) external;
    function set(address _address, uint256 _amount) external;
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