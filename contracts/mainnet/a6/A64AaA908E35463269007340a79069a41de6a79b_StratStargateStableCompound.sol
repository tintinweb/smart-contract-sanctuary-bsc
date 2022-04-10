// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

import '../../../interfaces/Alpaca/IAlpacaVault.sol';
import '../../../interfaces/Alpaca/IFairLaunch.sol';
import '../../../interfaces/PancakeSwap/IPancakeRouter.sol';
import '../../../interfaces/IWooAccessManager.sol';
import '../../../interfaces/IStrategy.sol';
import '../../../interfaces/IWETH.sol';
import '../BaseStrategy.sol';

contract StrategyAlpaca is BaseStrategy {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    /* ----- State Variables ----- */

    address public alpacaVault;
    address public fairLaunch;
    uint256 public immutable pid;

    address[] public rewardToWantRoute;

    /* ----- Constant Variables ----- */

    address public constant wrappedEther = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address public constant reward = address(0x8F0528cE5eF7B51152A59745bEfDD91D97091d2F);
    address public constant uniRouter = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    constructor(
        address initVault,
        address initAccessManager,
        address initAlpacaVault,
        address initFairLaunch,
        uint256 initPid,
        address[] memory initRewardToWantRoute
    ) public BaseStrategy(initVault, initAccessManager) {
        (address stakeToken, , , , ) = IFairLaunch(initFairLaunch).poolInfo(initPid);
        require(stakeToken == initAlpacaVault, 'StrategyAlpaca: wrong_initPid');
        alpacaVault = initAlpacaVault;
        fairLaunch = initFairLaunch;
        pid = initPid;
        rewardToWantRoute = initRewardToWantRoute;

        _giveAllowances();
    }

    /* ----- Public Functions ----- */

    function harvest() public override whenNotPaused {
        require(msg.sender == tx.origin || msg.sender == address(vault), 'StrategyAlpaca: EOA_or_vault');

        (uint256 amount, , , ) = IFairLaunch(fairLaunch).userInfo(pid, address(this));
        if (amount > 0) {
            IFairLaunch(fairLaunch).harvest(pid);
        }

        uint256 rewardBalance = IERC20(reward).balanceOf(address(this));
        if (rewardBalance > 0) {
            uint256 wantBalBefore = IERC20(want).balanceOf(address(this));
            IPancakeRouter(uniRouter).swapExactTokensForTokens(
                rewardBalance,
                0,
                rewardToWantRoute,
                address(this),
                now.add(600)
            );
            uint256 wantBalAfter = IERC20(want).balanceOf(address(this));
            uint256 perfAmount = wantBalAfter.sub(wantBalBefore);
            chargePerformanceFee(perfAmount);
        }

        deposit();
    }

    function deposit() public override whenNotPaused nonReentrant {
        uint256 wantBalance = IERC20(want).balanceOf(address(this));

        if (wantBalance > 0) {
            if (want == wrappedEther) {
                IWETH(wrappedEther).withdraw(wantBalance);
                IAlpacaVault(alpacaVault).deposit{value: wantBalance}(wantBalance);
            } else {
                IAlpacaVault(alpacaVault).deposit(wantBalance);
            }
            IFairLaunch(fairLaunch).deposit(address(this), pid, IAlpacaVault(alpacaVault).balanceOf(address(this)));
        }
    }

    function withdraw(uint256 amount) public override nonReentrant {
        require(msg.sender == address(vault), 'StrategyAlpaca: not_vault');
        require(amount > 0, 'StrategyAlpaca: amount_ZERO');

        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance < amount) {
            uint256 ibAmount = amount.mul(IAlpacaVault(alpacaVault).totalSupply()).div(
                IAlpacaVault(alpacaVault).totalToken()
            );
            IFairLaunch(fairLaunch).withdraw(address(this), pid, ibAmount);
            IAlpacaVault(alpacaVault).withdraw(IERC20(alpacaVault).balanceOf(address(this)));
            if (want == wrappedEther) {
                _wrapEther();
            }
            wantBalance = IERC20(want).balanceOf(address(this));
        }

        // just in case the decimal precision for the very left staking amount
        uint256 withdrawAmount = amount < wantBalance ? amount : wantBalance;

        uint256 fee = chargeWithdrawalFee(withdrawAmount);
        if (withdrawAmount > fee) {
            TransferHelper.safeTransfer(want, vault, withdrawAmount.sub(fee));
        }
    }

    function balanceOfPool() public view override returns (uint256) {
        (uint256 amount, , , ) = IFairLaunch(fairLaunch).userInfo(pid, address(this));

        return amount.mul(IAlpacaVault(alpacaVault).totalToken()).div(IAlpacaVault(alpacaVault).totalSupply());
    }

    /* ----- Private Functions ----- */

    function _giveAllowances() internal override {
        TransferHelper.safeApprove(reward, uniRouter, 0);
        TransferHelper.safeApprove(reward, uniRouter, uint256(-1));
        TransferHelper.safeApprove(want, alpacaVault, 0);
        TransferHelper.safeApprove(want, alpacaVault, uint256(-1));
        TransferHelper.safeApprove(alpacaVault, fairLaunch, 0);
        TransferHelper.safeApprove(alpacaVault, fairLaunch, uint256(-1));
    }

    function _removeAllowances() internal override {
        TransferHelper.safeApprove(reward, uniRouter, 0);
        TransferHelper.safeApprove(want, alpacaVault, 0);
        TransferHelper.safeApprove(alpacaVault, fairLaunch, 0);
    }

    function _withdrawAll() private {
        uint256 amount = balanceOfPool();
        uint256 ibAmount = amount.mul(IAlpacaVault(alpacaVault).totalSupply()).div(
            IAlpacaVault(alpacaVault).totalToken()
        );
        IFairLaunch(fairLaunch).withdraw(address(this), pid, ibAmount);
        IAlpacaVault(alpacaVault).withdraw(IERC20(alpacaVault).balanceOf(address(this)));
        if (want == wrappedEther) {
            _wrapEther();
        }
    }

    function _wrapEther() private {
        // NOTE: alpaca vault withdrawal returns the native BNB token; so wrapEther is required.
        uint256 etherBalance = address(this).balance;
        if (etherBalance > 0) {
            IWETH(wrappedEther).deposit{value: etherBalance}();
        }
    }

    /* ----- Admin Functions ----- */

    function retireStrat() external override {
        require(msg.sender == vault, '!vault');
        _withdrawAll();
        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance > 0) {
            TransferHelper.safeTransfer(want, vault, wantBalance);
        }
    }

    function emergencyExit() external override onlyAdmin {
        _withdrawAll();
        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance > 0) {
            TransferHelper.safeTransfer(want, vault, wantBalance);
        }
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./Context.sol";

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
    constructor () internal {
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

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IAlpacaVault {
    function balanceOf(address account) external view returns (uint256);

    function totalToken() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function deposit(uint256 amountToken) external payable;

    function withdraw(uint256 share) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IFairLaunch {
    function deposit(
        address _for,
        uint256 pid,
        uint256 _amount
    ) external; // staking

    function withdraw(
        address _for,
        uint256 _pid,
        uint256 _amount
    ) external; // unstaking

    function harvest(uint256 _pid) external;

    function pendingAlpaca(uint256 _pid, address _user) external returns (uint256);

    function userInfo(uint256, address)
        external
        view
        returns (
            uint256 amount,
            uint256 rewardDebt,
            uint256 bonusDebt,
            uint256 fundedBy
        );

    function poolInfo(uint256)
        external
        view
        returns (
            address stakeToken,
            uint256 allocPoint,
            uint256 lastRewardBlock,
            uint256 accAlpacaPerShare,
            uint256 accAlpacaPerShareTilBonusEnd
        );
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IPancakeRouter {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/// @title Reward manager interface for WooFi Swap.
/// @notice this is for swap rebate or potential incentive program
interface IWooAccessManager {
    /* ----- Events ----- */

    event FeeAdminUpdated(address indexed feeAdmin, bool flag);

    event VaultAdminUpdated(address indexed vaultAdmin, bool flag);

    event RebateAdminUpdated(address indexed rebateAdmin, bool flag);

    event ZeroFeeVaultUpdated(address indexed vault, bool flag);

    /* ----- External Functions ----- */

    function isFeeAdmin(address feeAdmin) external returns (bool);

    function isVaultAdmin(address vaultAdmin) external returns (bool);

    function isRebateAdmin(address rebateAdmin) external returns (bool);

    function isZeroFeeVault(address vault) external returns (bool);

    /* ----- Admin Functions ----- */

    /// @notice Sets feeAdmin
    function setFeeAdmin(address feeAdmin, bool flag) external;

    /// @notice Batch sets feeAdmin
    function batchSetFeeAdmin(address[] calldata feeAdmins, bool[] calldata flags) external;

    /// @notice Sets vaultAdmin
    function setVaultAdmin(address vaultAdmin, bool flag) external;

    /// @notice Batch sets vaultAdmin
    function batchSetVaultAdmin(address[] calldata vaultAdmins, bool[] calldata flags) external;

    /// @notice Sets rebateAdmin
    function setRebateAdmin(address rebateAdmin, bool flag) external;

    /// @notice Batch sets rebateAdmin
    function batchSetRebateAdmin(address[] calldata rebateAdmins, bool[] calldata flags) external;

    /// @notice Sets zeroFeeVault
    function setZeroFeeVault(address vault, bool flag) external;

    /// @notice Batch sets zeroFeeVault
    function batchSetZeroFeeVault(address[] calldata vaults, bool[] calldata flags) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
interface IStrategy {
    function vault() external view returns (address);

    function want() external view returns (address);

    function beforeDeposit() external;

    function beforeWithdraw() external;

    function deposit() external;

    function withdraw(uint256) external;

    function balanceOf() external view returns (uint256);

    function balanceOfWant() external view returns (uint256);

    function balanceOfPool() external view returns (uint256);

    function harvest() external;

    function retireStrat() external;

    function emergencyExit() external;

    function paused() external view returns (bool);

    function inCaseTokensGetStuck(address stuckToken) external;
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

/// @title Wrapped ETH.
/// BSC: https://bscscan.com/address/0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c#code
interface IWETH {
    /// @dev Deposit ETH into WETH
    function deposit() external payable;

    /// @dev Transfer WETH to receiver
    /// @param to address of WETH receiver
    /// @param value amount of WETH to transfer
    /// @return get true when succeed, else false
    function transfer(address to, uint256 value) external returns (bool);

    /// @dev Withdraw WETH to ETH
    function withdraw(uint256) external;
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

import '../../interfaces/IWooAccessManager.sol';
import '../../interfaces/IStrategy.sol';
import '../../interfaces/IVault.sol';
import '../../interfaces/IVaultV2.sol';

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/**
 * Base strategy abstract contract for:
 *  - vault and access manager setup
 *  - fees management
 *  - pause / unpause
 */
abstract contract BaseStrategy is Ownable, Pausable, IStrategy, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    /* ----- State Variables ----- */

    address public override want;
    address public immutable override vault;

    // Default them to 'true' to make the system more fair, but cost a bit more gas.
    bool public harvestOnDeposit = true;
    bool public harvestOnWithdraw = true;

    /* ----- Constant Variables ----- */

    uint256 public constant FEE_MAX = 10000;
    uint256 public performanceFee = 300; // 1 in 10000th: 100: 1%, 300: 3%
    uint256 public withdrawalFee = 0; // 1 in 10000th: 1: 0.01%, 10: 0.1%
    address public performanceTreasury = address(0x4094D7A17a387795838c7aba4687387B0d32BCf3);
    address public withdrawalTreasury = address(0x4094D7A17a387795838c7aba4687387B0d32BCf3);

    IWooAccessManager public accessManager;

    event PerformanceFeeUpdated(uint256 newFee);
    event WithdrawalFeeUpdated(uint256 newFee);

    constructor(address initVault, address initAccessManager) public {
        require(initVault != address(0), 'BaseStrategy: initVault_ZERO_ADDR');
        require(initAccessManager != address(0), 'BaseStrategy: initAccessManager_ZERO_ADDR');
        vault = initVault;
        accessManager = IWooAccessManager(initAccessManager);
        want = IVault(initVault).want();
    }

    modifier onlyAdmin() {
        require(owner() == _msgSender() || accessManager.isVaultAdmin(msg.sender), 'BaseStrategy: NOT_ADMIN');
        _;
    }

    /* ----- Public Functions ----- */

    function beforeDeposit() public virtual override {
        require(msg.sender == address(vault), 'BaseStrategy: NOT_VAULT');
        if (harvestOnDeposit) {
            harvest();
        }
    }

    function beforeWithdraw() public virtual override {
        require(msg.sender == address(vault), 'BaseStrategy: NOT_VAULT');
        if (harvestOnWithdraw) {
            harvest();
        }
    }

    function balanceOf() public view override returns (uint256) {
        return balanceOfWant().add(balanceOfPool());
    }

    function balanceOfWant() public view override returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    /* ----- Internal Functions ----- */

    function chargePerformanceFee(uint256 amount) internal returns (uint256) {
        uint256 fee = amount.mul(performanceFee).div(FEE_MAX);
        if (fee > 0) {
            TransferHelper.safeTransfer(want, performanceTreasury, fee);
        }
        return fee;
    }

    function chargeWithdrawalFee(uint256 amount) internal returns (uint256) {
        uint256 fee = amount.mul(withdrawalFee).div(FEE_MAX);
        if (fee > 0) {
            TransferHelper.safeTransfer(want, withdrawalTreasury, fee);
        }
        return fee;
    }

    /* ----- Abstract Method ----- */

    function balanceOfPool() public view virtual override returns (uint256);

    function deposit() public virtual override;

    function withdraw(uint256 amount) external virtual override;

    function harvest() public virtual override;

    function retireStrat() external virtual override;

    function emergencyExit() external virtual override;

    function _giveAllowances() internal virtual;

    function _removeAllowances() internal virtual;

    /* ----- Admin Functions ----- */

    function setPerformanceFee(uint256 fee) external onlyAdmin {
        require(fee <= FEE_MAX, 'BaseStrategy: fee_EXCCEEDS_MAX');
        performanceFee = fee;
        emit PerformanceFeeUpdated(fee);
    }

    function setWithdrawalFee(uint256 fee) external onlyAdmin {
        require(fee <= FEE_MAX, 'BaseStrategy: fee_EXCCEEDS_MAX');
        require(fee <= 500, 'BaseStrategy: fee_EXCCEEDS_5%'); // less than 5%
        withdrawalFee = fee;
        emit WithdrawalFeeUpdated(fee);
    }

    function setPerformanceTreasury(address treasury) external onlyAdmin {
        require(treasury != address(0), 'BaseStrategy: treasury_ZERO_ADDR');
        performanceTreasury = treasury;
    }

    function setWithdrawalTreasury(address treasury) external onlyAdmin {
        require(treasury != address(0), 'BaseStrategy: treasury_ZERO_ADDR');
        withdrawalTreasury = treasury;
    }

    function setHarvestOnDeposit(bool newHarvestOnDeposit) external onlyAdmin {
        harvestOnDeposit = newHarvestOnDeposit;
    }

    function setHarvestOnWithdraw(bool newHarvestOnWithdraw) external onlyAdmin {
        harvestOnWithdraw = newHarvestOnWithdraw;
    }

    function pause() public onlyAdmin {
        _pause();
        _removeAllowances();
    }

    function unpause() external onlyAdmin {
        _unpause();
        _giveAllowances();
        deposit();
    }

    function paused() public view override(IStrategy, Pausable) returns (bool) {
        return Pausable.paused();
    }

    function inCaseTokensGetStuck(address stuckToken) external override onlyAdmin {
        require(stuckToken != address(0), 'BaseStrategy: stuckToken_ZERO_ADDR');

        uint256 amount = IERC20(stuckToken).balanceOf(address(this));
        if (amount > 0) {
            TransferHelper.safeTransfer(stuckToken, msg.sender, amount);
        }
    }

    function inCaseNativeTokensGetStuck() external onlyAdmin {
        // NOTE: vault never needs native tokens to do the yield farming;
        // This native token balance indicates a user's incorrect transfer.
        if (address(this).balance > 0) {
            TransferHelper.safeTransferETH(msg.sender, address(this).balance);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

    constructor () internal {
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
pragma solidity 0.6.12;

interface IVault {
    function want() external view returns (address);

    function deposit(uint256 amount) external payable;

    function withdraw(uint256 shares) external;

    function earn() external;

    function available() external view returns (uint256);

    function balance() external view returns (uint256);

    function getPricePerFullShare() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IVaultV2 {
    function want() external view returns (address);

    function weth() external view returns (address);

    function deposit(uint256 amount) external payable;

    function withdraw(uint256 shares) external;

    function earn() external;

    function available() external view returns (uint256);

    function balance() external view returns (uint256);

    function getPricePerFullShare() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

import './BaseStrategy.sol';

contract VoidStrategy is BaseStrategy {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    constructor(address initVault, address initAccessManager) public BaseStrategy(initVault, initAccessManager) {
        _giveAllowances();
    }

    /* ----- External Functions ----- */

    function withdraw(uint256 amount) external override nonReentrant {
        require(msg.sender == vault, 'VoidStrategy: NOT_VAULT');

        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        uint256 withdrawAmount = amount < wantBalance ? amount : wantBalance;

        uint256 fee = chargeWithdrawalFee(withdrawAmount);
        if (withdrawAmount > fee) {
            TransferHelper.safeTransfer(want, vault, withdrawAmount.sub(fee));
        }
    }

    function harvest() public override whenNotPaused {
        require(msg.sender == tx.origin || msg.sender == vault, 'VoidStrategy: EOA_OR_VAULT');
        deposit();
    }

    function deposit() public override whenNotPaused nonReentrant {}

    function balanceOfPool() public view override returns (uint256) {
        return 0;
    }

    /* ----- Private Functions ----- */

    function _giveAllowances() internal override {}

    function _removeAllowances() internal override {}

    function retireStrat() external override {
        require(msg.sender == vault, '!vault');
        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance > 0) {
            TransferHelper.safeTransfer(want, vault, wantBalance);
        }
    }

    function emergencyExit() external override onlyAdmin {
        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance > 0) {
            TransferHelper.safeTransfer(want, vault, wantBalance);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import './libraries/InitializableOwnable.sol';
import './libraries/DecimalMath.sol';
import './interfaces/IWooracle.sol';
import './interfaces/IWooVaultManager.sol';
import './interfaces/IWooGuardian.sol';
import './interfaces/AggregatorV3Interface.sol';
import './interfaces/IWooAccessManager.sol';

import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/utils/EnumerableSet.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

contract WooVaultManager is InitializableOwnable, ReentrancyGuard, IWooVaultManager {
    using SafeMath for uint256;
    using DecimalMath for uint256;
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(address => uint256) public override vaultWeight;
    uint256 public totalWeight;

    IWooPP private wooPP;

    address public immutable override quoteToken; // USDT
    address public immutable rewardToken; // WOO

    EnumerableSet.AddressSet private vaultSet;

    IWooAccessManager public accessManager;

    /* ----- Modifiers ----- */

    modifier onlyAdmin() {
        require(msg.sender == _OWNER_ || accessManager.isVaultAdmin(msg.sender), 'WooVaultManager: NOT_ADMIN');
        _;
    }

    constructor(
        address newQuoteToken,
        address newRewardToken,
        address newAccessManager
    ) public {
        require(newQuoteToken != address(0), 'WooVaultManager: INVALID_QUOTE');
        require(newRewardToken != address(0), 'WooVaultManager: INVALID_RAWARD_TOKEN');
        initOwner(msg.sender);
        quoteToken = newQuoteToken;
        rewardToken = newRewardToken;
        accessManager = IWooAccessManager(newAccessManager);
    }

    function allVaults() external view override returns (address[] memory) {
        address[] memory vaults = new address[](vaultSet.length());
        for (uint256 i = 0; i < vaultSet.length(); ++i) {
            vaults[i] = vaultSet.at(i);
        }
        return vaults;
    }

    function addReward(uint256 amount) external override nonReentrant {
        if (amount == 0) {
            return;
        }

        uint256 balanceBefore = IERC20(quoteToken).balanceOf(address(this));
        TransferHelper.safeTransferFrom(quoteToken, msg.sender, address(this), amount);
        uint256 balanceAfter = IERC20(quoteToken).balanceOf(address(this));
        require(balanceAfter.sub(balanceBefore) >= amount, 'WooVaultManager: amount INSUFF');
    }

    function pendingReward(address vaultAddr) external view override returns (uint256) {
        require(vaultAddr != address(0), 'WooVaultManager: vaultAddr_ZERO_ADDR');
        uint256 totalReward = IERC20(quoteToken).balanceOf(address(this));
        return totalReward.mul(vaultWeight[vaultAddr]).div(totalWeight);
    }

    function pendingAllReward() external view override returns (uint256) {
        return IERC20(quoteToken).balanceOf(address(this));
    }

    // ----------- Admin Functions ------------- //

    function setVaultWeight(address vaultAddr, uint256 weight) external override onlyAdmin {
        require(vaultAddr != address(0), 'WooVaultManager: vaultAddr_ZERO_ADDR');

        // NOTE: First clear all the pending reward if > 100u to keep the things fair
        if (IERC20(quoteToken).balanceOf(address(this)) >= 1e20) {
            distributeAllReward();
        }

        uint256 prevWeight = vaultWeight[vaultAddr];
        vaultWeight[vaultAddr] = weight;
        totalWeight = totalWeight.add(weight).sub(prevWeight);

        if (weight == 0) {
            vaultSet.remove(vaultAddr);
        } else {
            vaultSet.add(vaultAddr);
        }

        emit VaultWeightUpdated(vaultAddr, weight);
    }

    function distributeAllReward() public override onlyAdmin {
        uint256 totalRewardInQuote = IERC20(quoteToken).balanceOf(address(this));
        if (totalRewardInQuote == 0 || totalWeight == 0) {
            return;
        }

        uint256 balanceBefore = IERC20(rewardToken).balanceOf(address(this));
        TransferHelper.safeApprove(quoteToken, address(wooPP), totalRewardInQuote);
        uint256 wooAmount = IWooPP(wooPP).sellQuote(rewardToken, totalRewardInQuote, 0, address(this), address(0));
        uint256 balanceAfter = IERC20(rewardToken).balanceOf(address(this));
        require(balanceAfter.sub(balanceBefore) >= wooAmount, 'WooVaultManager: woo amount INSUFF');

        for (uint256 i = 0; i < vaultSet.length(); ++i) {
            address vaultAddr = vaultSet.at(i);
            uint256 vaultAmount = wooAmount.mul(vaultWeight[vaultAddr]).div(totalWeight);
            if (vaultAmount > 0) {
                TransferHelper.safeTransfer(rewardToken, vaultAddr, vaultAmount);
            }
            emit RewardDistributed(vaultAddr, vaultAmount);
        }
    }

    function setWooPP(address newWooPP) external onlyAdmin {
        require(newWooPP != address(0), 'WooVaultManager: newWooPP_ZERO_ADDR');
        wooPP = IWooPP(newWooPP);
        require(wooPP.quoteToken() == quoteToken, 'WooVaultManager: wooPP_quote_token_INVALID');
    }

    function setAccessManager(address newAccessManager) external onlyOwner {
        require(newAccessManager != address(0), 'WooVaultManager: newAccessManager_ZERO_ADDR');
        accessManager = IWooAccessManager(newAccessManager);
    }

    function emergencyWithdraw(address token, address to) public onlyOwner {
        require(token != address(0), 'WooVaultManager: token_ZERO_ADDR');
        require(to != address(0), 'WooVaultManager: to_ZERO_ADDR');
        TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

/**
 * @title Ownable initializable contract.
 *
 * @notice Ownership related functions
 */
contract InitializableOwnable {
    address public _OWNER_;
    address public _NEW_OWNER_;
    bool internal _INITIALIZED_;

    // ============ Events ============

    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // ============ Modifiers ============

    modifier notInitialized() {
        require(!_INITIALIZED_, 'InitializableOwnable: SHOULD_NOT_BE_INITIALIZED');
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == _OWNER_, 'InitializableOwnable: NOT_OWNER');
        _;
    }

    // ============ Functions ============

    /// @dev Init _OWNER_ from newOwner and set _INITIALIZED_ as true
    /// @param newOwner new owner address
    function initOwner(address newOwner) public notInitialized {
        _INITIALIZED_ = true;
        _OWNER_ = newOwner;
    }

    /// @dev Set _NEW_OWNER_ from newOwner
    /// @param newOwner new owner address
    function transferOwnership(address newOwner) public onlyOwner {
        emit OwnershipTransferPrepared(_OWNER_, newOwner);
        _NEW_OWNER_ = newOwner;
    }

    /// @dev Set _OWNER_ from _NEW_OWNER_ and set _NEW_OWNER_ equal zero address
    function claimOwnership() public {
        require(msg.sender == _NEW_OWNER_, 'InitializableOwnable: INVALID_CLAIM');
        emit OwnershipTransferred(_OWNER_, _NEW_OWNER_);
        _OWNER_ = _NEW_OWNER_;
        _NEW_OWNER_ = address(0);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/math/SafeMath.sol';

/**
 * @title DecimalMath
 *
 * @notice Functions for fixed point number with 18 decimals
 */
library DecimalMath {
    using SafeMath for uint256;

    uint256 internal constant ONE = 10**18;
    uint256 internal constant TWO = 2 * 10**18;
    uint256 internal constant ONE2 = 10**36;

    function mulFloor(uint256 target, uint256 d) internal pure returns (uint256) {
        return target.mul(d) / (10**18);
    }

    function mulCeil(uint256 target, uint256 d) internal pure returns (uint256) {
        return _divCeil(target.mul(d), 10**18);
    }

    function divFloor(uint256 target, uint256 d) internal pure returns (uint256) {
        return target.mul(10**18).div(d);
    }

    function divCeil(uint256 target, uint256 d) internal pure returns (uint256) {
        return _divCeil(target.mul(10**18), d);
    }

    function reciprocalFloor(uint256 target) internal pure returns (uint256) {
        return uint256(10**36).div(target);
    }

    function reciprocalCeil(uint256 target) internal pure returns (uint256) {
        return _divCeil(uint256(10**36), target);
    }

    function _divCeil(uint256 a, uint256 b) private pure returns (uint256) {
        uint256 quotient = a.div(b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/// @title The oracle interface by Woo.Network.
/// @notice update and posted the latest price info by Woo.
interface IWooracle {
    /// @dev the quote token for Wooracle's pricing.
    /// @return the quote token
    function quoteToken() external view returns (address);

    /// @dev the price for the given base token
    /// @param base baseToken address
    /// @return priceNow the current price of base token
    /// @return feasible whether the current price is feasible and valid
    function price(address base) external view returns (uint256 priceNow, bool feasible);

    function getPrice(address base) external view returns (uint256);

    function getSpread(address base) external view returns (uint256);

    function getCoeff(address base) external view returns (uint256);

    /// @dev returns the state for the given base token.
    /// @param base baseToken address
    /// @return priceNow the current price of base token
    /// @return spreadNow the current spread of base token
    /// @return coeffNow the slippage coefficient of base token
    /// @return feasible whether the current state is feasible and valid
    function state(address base)
        external
        view
        returns (
            uint256 priceNow,
            uint256 spreadNow,
            uint256 coeffNow,
            bool feasible
        );

    /// @dev returns the last updated timestamp
    /// @return the last updated timestamp
    function timestamp() external view returns (uint256);

    /// @dev returns whether the base token price is valid.
    /// @param base baseToken address
    /// @return whether the base token price is valid.
    function isFeasible(address base) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/// @title Vault reward manager interface for WooFi Swap.
interface IWooVaultManager {
    event VaultWeightUpdated(address indexed vaultAddr, uint256 weight);
    event RewardDistributed(address indexed vaultAddr, uint256 amount);

    /// @dev Gets the reward weight for the given vault.
    /// @param vaultAddr the vault address
    /// @return The weight of the given vault.
    function vaultWeight(address vaultAddr) external view returns (uint256);

    /// @dev Sets the reward weight for the given vault.
    /// @param vaultAddr the vault address
    /// @param weight the vault weight
    function setVaultWeight(address vaultAddr, uint256 weight) external;

    /// @dev Adds the reward quote amount.
    /// Note: The reward will be stored in this manager contract for
    ///       further weight adjusted distribution.
    /// @param quoteAmount the reward amount in quote token.
    function addReward(uint256 quoteAmount) external;

    /// @dev Pending amount in quote token for the given vault.
    /// @param vaultAddr the vault address
    function pendingReward(address vaultAddr) external view returns (uint256);

    /// @dev All pending amount in quote token.
    /// @return the total pending reward
    function pendingAllReward() external view returns (uint256);

    /// @dev Distributes the reward to all the vaults based on the weights.
    function distributeAllReward() external;

    /// @dev All the vaults
    /// @return the vault address array
    function allVaults() external view returns (address[] memory);

    /// @dev get the quote token address
    /// @return address of quote token
    function quoteToken() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import '../interfaces/IWooPP.sol';

/// @title Guardian interface to ensure the trading price and volume correct
interface IWooGuardian {
    event ChainlinkRefOracleUpdated(address indexed token, address indexed chainlinkRefOracle);

    /* ----- Main check APIs ----- */

    function checkSwapPrice(
        uint256 price,
        address fromToken,
        address toToken
    ) external view;

    function checkInputAmount(address token, uint256 inputAmount) external view;

    function checkSwapAmount(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 toAmount
    ) external view;
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    /// getRoundData and latestRoundData should both raise "No data present"
    /// if they do not have data to report, instead of returning unset values
    /// which could be misinterpreted as actual reported values.
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../../utils/Context.sol";
import "./IERC20.sol";
import "../../math/SafeMath.sol";

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
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
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
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
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

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/// @title Woo private pool for swap.
/// @notice Use this contract to directly interfact with woo's synthetic proactive
///         marketing making pool.
/// @author woo.network
interface IWooPP {
    /* ----- Type declarations ----- */

    /// @dev struct info to store the token info
    struct TokenInfo {
        uint112 reserve; // Token balance
        uint112 threshold; // Threshold for reserve update
        uint32 lastResetTimestamp; // Timestamp for last param update
        uint64 R; // Rebalance coefficient [0, 1]
        uint112 target; // Targeted balance for pricing
        bool isValid; // is this token info valid
    }

    /* ----- Events ----- */

    event StrategistUpdated(address indexed strategist, bool flag);
    event FeeManagerUpdated(address indexed newFeeManager);
    event RewardManagerUpdated(address indexed newRewardManager);
    event WooracleUpdated(address indexed newWooracle);
    event WooGuardianUpdated(address indexed newWooGuardian);
    event ParametersUpdated(address indexed baseToken, uint256 newThreshold, uint256 newR);
    event Withdraw(address indexed token, address indexed to, uint256 amount);
    event WooSwap(
        address indexed fromToken,
        address indexed toToken,
        uint256 fromAmount,
        uint256 toAmount,
        address from,
        address indexed to,
        address rebateTo
    );

    /* ----- External Functions ----- */

    /// @dev Swap baseToken into quoteToken
    /// @param baseToken the base token
    /// @param baseAmount amount of baseToken that user want to swap
    /// @param minQuoteAmount minimum amount of quoteToken that user accept to receive
    /// @param to quoteToken receiver address
    /// @param rebateTo the wallet address for rebate
    /// @return quoteAmount the swapped amount of quote token
    function sellBase(
        address baseToken,
        uint256 baseAmount,
        uint256 minQuoteAmount,
        address to,
        address rebateTo
    ) external returns (uint256 quoteAmount);

    /// @dev Swap quoteToken into baseToken
    /// @param baseToken the base token
    /// @param quoteAmount amount of quoteToken that user want to swap
    /// @param minBaseAmount minimum amount of baseToken that user accept to receive
    /// @param to baseToken receiver address
    /// @param rebateTo the wallet address for rebate
    /// @return baseAmount the swapped amount of base token
    function sellQuote(
        address baseToken,
        uint256 quoteAmount,
        uint256 minBaseAmount,
        address to,
        address rebateTo
    ) external returns (uint256 baseAmount);

    /// @dev Query the amount for selling the base token amount.
    /// @param baseToken the base token to sell
    /// @param baseAmount the amount to sell
    /// @return quoteAmount the swapped quote amount
    function querySellBase(address baseToken, uint256 baseAmount) external view returns (uint256 quoteAmount);

    /// @dev Query the amount for selling the quote token.
    /// @param baseToken the base token to receive (buy)
    /// @param quoteAmount the amount to sell
    /// @return baseAmount the swapped base token amount
    function querySellQuote(address baseToken, uint256 quoteAmount) external view returns (uint256 baseAmount);

    /// @dev get the quote token address
    /// @return address of quote token
    function quoteToken() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

import './libraries/DecimalMath.sol';
import './interfaces/IWooAccessManager.sol';

contract WooStakingVault is ERC20, Ownable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using DecimalMath for uint256;

    struct UserInfo {
        uint256 reserveAmount; // amount of stakedToken user reverseWithdraw
        uint256 lastReserveWithdrawTime; // keeps track of reverseWithdraw time for potential penalty
    }

    /* ----- Events ----- */

    event Deposit(address indexed user, uint256 depositAmount, uint256 mintShares);
    event ReserveWithdraw(address indexed user, uint256 reserveAmount, uint256 burnShares);
    event Withdraw(address indexed user, uint256 withdrawAmount, uint256 withdrawFee);
    event InstantWithdraw(address indexed user, uint256 withdrawAmount, uint256 withdrawFee);
    event RewardAdded(
        address indexed sender,
        uint256 balanceBefore,
        uint256 sharePriceBefore,
        uint256 balanceAfter,
        uint256 sharePriceAfter
    );

    /* ----- State variables ----- */

    IERC20 public immutable stakedToken;
    mapping(address => uint256) public costSharePrice;
    mapping(address => UserInfo) public userInfo;

    uint256 public totalReserveAmount = 0; // affected by reserveWithdraw and withdraw
    uint256 public withdrawFeePeriod = 7 days;
    uint256 public withdrawFee = 500; // 5% (10000 as denominator)

    address public treasury;
    IWooAccessManager public wooAccessManager;

    /* ----- Constant variables ----- */

    uint256 public constant MAX_WITHDRAW_FEE_PERIOD = 7 days;
    uint256 public constant MAX_WITHDRAW_FEE = 500; // 5% (10000 as denominator)

    constructor(
        address initialStakedToken,
        address initialTreasury,
        address initialWooAccessManager
    )
        public
        ERC20(
            string(abi.encodePacked('Interest Bearing ', ERC20(initialStakedToken).name())),
            string(abi.encodePacked('x', ERC20(initialStakedToken).symbol()))
        )
    {
        require(initialStakedToken != address(0), 'WooStakingVault: initialStakedToken_ZERO_ADDR');
        require(initialTreasury != address(0), 'WooStakingVault: initialTreasury_ZERO_ADDR');
        require(initialWooAccessManager != address(0), 'WooStakingVault: initialWooAccessManager_ZERO_ADDR');

        stakedToken = IERC20(initialStakedToken);
        treasury = initialTreasury;
        wooAccessManager = IWooAccessManager(initialWooAccessManager);
    }

    /* ----- External Functions ----- */

    function deposit(uint256 amount) external nonReentrant whenNotPaused {
        require(amount > 0, 'WooStakingVault: amount_CAN_NOT_BE_ZERO');

        uint256 balanceBefore = balance();
        TransferHelper.safeTransferFrom(address(stakedToken), msg.sender, address(this), amount);
        uint256 balanceAfter = balance();
        amount = balanceAfter.sub(balanceBefore);

        uint256 xTotalSupply = totalSupply();
        uint256 shares = xTotalSupply == 0 ? amount : amount.mul(xTotalSupply).div(balanceBefore);

        // must be executed before _mint
        _updateCostSharePrice(amount, shares);

        _mint(msg.sender, shares);

        emit Deposit(msg.sender, amount, shares);
    }

    function reserveWithdraw(uint256 shares) external nonReentrant {
        require(shares > 0, 'WooStakingVault: shares_CAN_NOT_BE_ZERO');
        require(shares <= balanceOf(msg.sender), 'WooStakingVault: shares exceed balance');

        uint256 currentReserveAmount = shares.mulFloor(getPricePerFullShare()); // calculate reserveAmount before _burn
        uint256 poolBalance = balance();
        if (poolBalance < currentReserveAmount) {
            // in case reserve amount exceeds pool balance
            currentReserveAmount = poolBalance;
        }
        _burn(msg.sender, shares);

        totalReserveAmount = totalReserveAmount.add(currentReserveAmount);

        UserInfo storage user = userInfo[msg.sender];
        user.reserveAmount = user.reserveAmount.add(currentReserveAmount);
        user.lastReserveWithdrawTime = block.timestamp;

        emit ReserveWithdraw(msg.sender, currentReserveAmount, shares);
    }

    function withdraw() external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];

        uint256 withdrawAmount = user.reserveAmount;
        require(withdrawAmount > 0, 'WooStakingVault: withdrawAmount_CAN_NOT_BE_ZERO');

        uint256 fee = 0;
        if (block.timestamp < user.lastReserveWithdrawTime.add(withdrawFeePeriod)) {
            fee = withdrawAmount.mul(withdrawFee).div(10000);
            if (fee > 0) {
                TransferHelper.safeTransfer(address(stakedToken), treasury, fee);
            }
        }
        uint256 withdrawAmountAfterFee = withdrawAmount.sub(fee);

        user.reserveAmount = 0;
        totalReserveAmount = totalReserveAmount.sub(withdrawAmount);
        TransferHelper.safeTransfer(address(stakedToken), msg.sender, withdrawAmountAfterFee);

        emit Withdraw(msg.sender, withdrawAmount, fee);
    }

    function instantWithdraw(uint256 shares) external nonReentrant {
        require(shares > 0, 'WooStakingVault: shares_CAN_NOT_BE_ZERO');
        require(shares <= balanceOf(msg.sender), 'WooStakingVault: shares exceed balance');

        uint256 withdrawAmount = shares.mulFloor(getPricePerFullShare());

        uint256 poolBalance = balance();
        if (poolBalance < withdrawAmount) {
            withdrawAmount = poolBalance;
        }

        _burn(msg.sender, shares);

        uint256 fee = wooAccessManager.isZeroFeeVault(msg.sender) ? 0 : withdrawAmount.mul(withdrawFee).div(10000);
        if (fee > 0) {
            TransferHelper.safeTransfer(address(stakedToken), treasury, fee);
        }
        uint256 withdrawAmountAfterFee = withdrawAmount.sub(fee);

        TransferHelper.safeTransfer(address(stakedToken), msg.sender, withdrawAmountAfterFee);

        emit InstantWithdraw(msg.sender, withdrawAmount, fee);
    }

    function addReward(uint256 amount) external whenNotPaused {
        // Note: this method is only for adding Woo reward. Users may not call this method to deposit woo token.
        require(amount > 0, 'WooStakingVault: amount_CAN_NOT_BE_ZERO');
        uint256 balanceBefore = balance();
        uint256 sharePriceBefore = getPricePerFullShare();
        TransferHelper.safeTransferFrom(address(stakedToken), msg.sender, address(this), amount);
        uint256 balanceAfter = balance();
        uint256 sharePriceAfter = getPricePerFullShare();

        emit RewardAdded(msg.sender, balanceBefore, sharePriceBefore, balanceAfter, sharePriceAfter);
    }

    /* ----- Public Functions ----- */

    function getPricePerFullShare() public view returns (uint256) {
        if (totalSupply() == 0) {
            return 1e18;
        }
        return balance().divFloor(totalSupply());
    }

    function balance() public view returns (uint256) {
        return stakedToken.balanceOf(address(this)).sub(totalReserveAmount);
    }

    /* ----- Private Functions ----- */

    function _updateCostSharePrice(uint256 amount, uint256 shares) private {
        uint256 sharesBefore = balanceOf(msg.sender);
        uint256 costBefore = costSharePrice[msg.sender];
        uint256 costAfter = (sharesBefore.mul(costBefore).add(amount.mul(1e18))).div(sharesBefore.add(shares));

        costSharePrice[msg.sender] = costAfter;
    }

    /* ----- Admin Functions ----- */

    /// @notice Sets withdraw fee period
    /// @dev Only callable by the contract owner.
    function setWithdrawFeePeriod(uint256 newWithdrawFeePeriod) external onlyOwner {
        require(
            newWithdrawFeePeriod <= MAX_WITHDRAW_FEE_PERIOD,
            'WooStakingVault: newWithdrawFeePeriod>MAX_WITHDRAW_FEE_PERIOD'
        );
        withdrawFeePeriod = newWithdrawFeePeriod;
    }

    /// @notice Sets withdraw fee
    /// @dev Only callable by the contract owner.
    function setWithdrawFee(uint256 newWithdrawFee) external onlyOwner {
        require(newWithdrawFee <= MAX_WITHDRAW_FEE, 'WooStakingVault: newWithdrawFee>MAX_WITHDRAW_FEE');
        withdrawFee = newWithdrawFee;
    }

    /// @notice Sets treasury address
    /// @dev Only callable by the contract owner.
    function setTreasury(address newTreasury) external onlyOwner {
        require(newTreasury != address(0), 'WooStakingVault: newTreasury_ZERO_ADDR');
        treasury = newTreasury;
    }

    /// @notice Sets WooAccessManager
    /// @dev Only callable by the contract owner.
    function setWooAccessManager(address newWooAccessManager) external onlyOwner {
        require(newWooAccessManager != address(0), 'WooStakingVault: newWooAccessManager_ZERO_ADDR');
        wooAccessManager = IWooAccessManager(newWooAccessManager);
    }

    /**
        @notice Rescues random funds stuck.
        This method only saves the irrelevant tokens just in case users deposited in mistake.
        It cannot transfer any of user staked tokens.
    */
    function inCaseTokensGetStuck(address stuckToken) external onlyOwner {
        require(stuckToken != address(0), 'WooStakingVault: stuckToken_ZERO_ADDR');
        require(stuckToken != address(stakedToken), 'WooStakingVault: stuckToken_CAN_NOT_BE_stakedToken');

        uint256 amount = IERC20(stuckToken).balanceOf(address(this));
        TransferHelper.safeTransfer(stuckToken, msg.sender, amount);
    }

    /// @notice Pause the contract.
    function pause() external onlyOwner {
        super._pause();
    }

    /// @notice Restart the contract.
    function unpause() external onlyOwner {
        super._unpause();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import './libraries/InitializableOwnable.sol';
import './libraries/DecimalMath.sol';
import './interfaces/IWooracle.sol';
import './interfaces/IWooRebateManager.sol';
import './interfaces/IWooGuardian.sol';
import './interfaces/AggregatorV3Interface.sol';
import './interfaces/IWooAccessManager.sol';

import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

contract WooRebateManager is InitializableOwnable, ReentrancyGuard, IWooRebateManager {
    using SafeMath for uint256;
    using DecimalMath for uint256;
    using SafeERC20 for IERC20;

    // Note: this is the percent rate of the total swap fee (not the swap volume)
    // decimal: 18; 1e16 = 1%, 1e15 = 0.1%, 1e14 = 0.01%
    //
    // e.g. suppose:
    //   rebateRate = 1e17 (10%), so the rebate amount is total_swap_fee * 10%.
    mapping(address => uint256) public override rebateRate;

    // pending rebate amount in quote token
    mapping(address => uint256) public pendingRebate;

    IWooPP private wooPP;

    address public immutable override quoteToken; // USDT
    address public immutable rewardToken; // WOO

    IWooAccessManager public accessManager;

    /* ----- Modifiers ----- */

    modifier onlyAdmin() {
        require(msg.sender == _OWNER_ || accessManager.isRebateAdmin(msg.sender), 'WooRebateManager: NOT_ADMIN');
        _;
    }

    constructor(
        address newQuoteToken,
        address newRewardToken,
        address newAccessManager
    ) public {
        require(newQuoteToken != address(0), 'WooRebateManager: INVALID_QUOTE');
        require(newRewardToken != address(0), 'WooRebateManager: INVALID_REWARD_TOKEN');
        initOwner(msg.sender);
        quoteToken = newQuoteToken;
        rewardToken = newRewardToken;
        accessManager = IWooAccessManager(newAccessManager);
    }

    function pendingRebateInUSDT(address brokerAddr) external view override returns (uint256) {
        require(brokerAddr != address(0), 'WooRebateManager: zero_brokerAddr');
        return pendingRebate[brokerAddr];
    }

    function pendingRebateInWOO(address brokerAddr) external view override returns (uint256) {
        require(brokerAddr != address(0), 'WooRebateManager: zero_brokerAddr');
        return wooPP.querySellQuote(rewardToken, pendingRebate[brokerAddr]);
    }

    function claimRebate() external override nonReentrant {
        require(pendingRebate[msg.sender] > 0, 'WooRebateManager: NO_pending_rebate');

        uint256 quoteAmount = pendingRebate[msg.sender];
        // Note: set the pending rebate early to make external interactions safe.
        pendingRebate[msg.sender] = 0;

        uint256 balanceBefore = IERC20(rewardToken).balanceOf(address(this));
        TransferHelper.safeApprove(quoteToken, address(wooPP), quoteAmount);
        uint256 wooAmount = wooPP.sellQuote(rewardToken, quoteAmount, 0, address(this), address(0));
        uint256 balanceAfter = IERC20(rewardToken).balanceOf(address(this));
        require(balanceAfter.sub(balanceBefore) >= wooAmount, 'WooRebateManager: woo amount INSUFF');

        if (wooAmount > 0) {
            TransferHelper.safeTransfer(rewardToken, msg.sender, wooAmount);
        }

        emit ClaimReward(msg.sender, wooAmount);
    }

    /* ----- Admin Functions ----- */

    function addRebate(address brokerAddr, uint256 amountInUSDT) external override nonReentrant onlyAdmin {
        if (brokerAddr == address(0)) {
            return;
        }
        pendingRebate[brokerAddr] = amountInUSDT.add(pendingRebate[brokerAddr]);
    }

    function setRebateRate(address brokerAddr, uint256 rate) external override onlyAdmin {
        require(brokerAddr != address(0), 'WooRebateManager: brokerAddr_ZERO_ADDR');
        require(rate <= 1e18, 'WooRebateManager: INVALID_USER_REWARD_RATE'); // rate <= 100%
        rebateRate[brokerAddr] = rate;
        emit RebateRateUpdated(brokerAddr, rate);
    }

    function setWooPP(address newWooPP) external onlyAdmin {
        require(newWooPP != address(0), 'WooRebateManager: wooPP_ZERO_ADDR');
        wooPP = IWooPP(newWooPP);
        require(wooPP.quoteToken() == quoteToken, 'WooRebateManager: wooPP_quote_token_INVALID');
    }

    function setAccessManager(address newAccessManager) external onlyOwner {
        require(newAccessManager != address(0), 'WooRebateManager: newAccessManager_ZERO_ADDR');
        accessManager = IWooAccessManager(newAccessManager);
    }

    function emergencyWithdraw(address token, address to) public onlyOwner {
        require(token != address(0), 'WooRebateManager: token_ZERO_ADDR');
        require(to != address(0), 'WooRebateManager: to_ZERO_ADDR');
        uint256 amount = IERC20(token).balanceOf(address(this));
        TransferHelper.safeTransfer(token, to, amount);
        emit Withdraw(token, to, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/// @title Rebate manager interface for WooFi Swap.
/// @notice this is for swap rebate or potential incentive program

interface IWooRebateManager {
    event Withdraw(address indexed token, address indexed to, uint256 amount);
    event RebateRateUpdated(address indexed brokerAddr, uint256 rate);
    event ClaimReward(address indexed brokerAddr, uint256 amount);

    /// @dev Gets the rebate rate for the given broker.
    /// Note: decimal: 18;  1e16 = 1%, 1e15 = 0.1%, 1e14 = 0.01%
    /// @param brokerAddr the address for rebate
    /// @return The rebate rate (decimal: 18; 1e16 = 1%, 1e15 = 0.1%, 1e14 = 0.01%)
    function rebateRate(address brokerAddr) external view returns (uint256);

    /// @dev set the rebate rate
    /// @param brokerAddr the rebate address
    /// @param rate the rebate rate
    function setRebateRate(address brokerAddr, uint256 rate) external;

    /// @dev adds the pending reward for the given user.
    /// @param brokerAddr the address for rebate
    /// @param amountInUSD the pending reward amount
    function addRebate(address brokerAddr, uint256 amountInUSD) external;

    /// @dev Pending amount in $woo.
    /// @param brokerAddr the address for rebate
    function pendingRebateInWOO(address brokerAddr) external view returns (uint256);

    /// @dev Pending amount in $woo.
    /// @param brokerAddr the address for rebate
    function pendingRebateInUSDT(address brokerAddr) external view returns (uint256);

    /// @dev Claims the reward ($woo token will be distributed)
    function claimRebate() external;

    /// @dev get the quote token address
    /// @return address of quote token
    function quoteToken() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import './interfaces/IWooPP.sol';
import './interfaces/IWETH.sol';
import './interfaces/IWooRouterV2.sol';

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

/// @title Woo Router implementation.
/// @notice Router for stateless execution of swaps against Woo private pool.
contract WooRouterV2 is IWooRouterV2, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ----- Constant variables ----- */

    // Erc20 placeholder address for native tokens (e.g. eth, bnb, matic, etc)
    address constant ETH_PLACEHOLDER_ADDR = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /* ----- State variables ----- */

    // Wrapper for native tokens (e.g. eth, bnb, matic, etc)
    // BSC WBNB: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    address public immutable override WETH;

    IWooPP public override wooPool;

    mapping(address => bool) public isWhitelisted;

    address public quoteToken;

    /* ----- Callback Function ----- */

    receive() external payable {
        // only accept ETH from WETH or whitelisted external swaps.
        assert(msg.sender == WETH || isWhitelisted[msg.sender]);
    }

    /* ----- Query & swap APIs ----- */

    constructor(address _weth, address _pool) public {
        require(_weth != address(0), 'WooRouter: weth_ZERO_ADDR');
        WETH = _weth;
        setPool(_pool);
    }

    /// @inheritdoc IWooRouterV2
    function querySwap(
        address fromToken,
        address toToken,
        uint256 fromAmount
    ) external view override returns (uint256 toAmount) {
        require(fromToken != address(0), 'WooRouter: fromToken_ADDR_ZERO');
        require(toToken != address(0), 'WooRouter: toToken_ADDR_ZERO');
        fromToken = (fromToken == ETH_PLACEHOLDER_ADDR) ? WETH : fromToken;
        toToken = (toToken == ETH_PLACEHOLDER_ADDR) ? WETH : toToken;
        if (fromToken == quoteToken) {
            toAmount = wooPool.querySellQuote(toToken, fromAmount);
        } else if (toToken == quoteToken) {
            toAmount = wooPool.querySellBase(fromToken, fromAmount);
        } else {
            uint256 quoteAmount = wooPool.querySellBase(fromToken, fromAmount);
            toAmount = wooPool.querySellQuote(toToken, quoteAmount);
        }
    }

    /// @inheritdoc IWooRouterV2
    function swap(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minToAmount,
        address payable to,
        address rebateTo
    ) external payable override nonReentrant returns (uint256 realToAmount) {
        require(fromToken != address(0), 'WooRouter: fromToken_ADDR_ZERO');
        require(toToken != address(0), 'WooRouter: toToken_ADDR_ZERO');
        require(to != address(0), 'WooRouter: to_ADDR_ZERO');

        bool isFromETH = fromToken == ETH_PLACEHOLDER_ADDR;
        bool isToETH = toToken == ETH_PLACEHOLDER_ADDR;
        fromToken = isFromETH ? WETH : fromToken;
        toToken = isToETH ? WETH : toToken;

        // Step 1: transfer the source tokens to WooRouter
        if (isFromETH) {
            require(fromAmount <= msg.value, 'WooRouter: fromAmount_INVALID');
            IWETH(WETH).deposit{value: msg.value}();
        } else {
            TransferHelper.safeTransferFrom(fromToken, msg.sender, address(this), fromAmount);
        }

        // Step 2: swap and transfer
        TransferHelper.safeApprove(fromToken, address(wooPool), fromAmount);
        if (fromToken == quoteToken) {
            // case 1: quoteToken --> baseToken
            realToAmount = _sellQuoteAndTransfer(isToETH, toToken, fromAmount, minToAmount, to, rebateTo);
        } else if (toToken == quoteToken) {
            // case 2: fromToken --> quoteToken
            realToAmount = wooPool.sellBase(fromToken, fromAmount, minToAmount, to, rebateTo);
        } else {
            // case 3: fromToken --> quoteToken --> toToken
            uint256 quoteAmount = wooPool.sellBase(fromToken, fromAmount, 0, address(this), rebateTo);
            TransferHelper.safeApprove(quoteToken, address(wooPool), quoteAmount);
            realToAmount = _sellQuoteAndTransfer(isToETH, toToken, quoteAmount, minToAmount, to, rebateTo);
        }

        // Step 3: firing event
        emit WooRouterSwap(
            SwapType.WooSwap,
            isFromETH ? ETH_PLACEHOLDER_ADDR : fromToken,
            isToETH ? ETH_PLACEHOLDER_ADDR : toToken,
            fromAmount,
            realToAmount,
            msg.sender,
            to,
            rebateTo
        );
    }

    /// @inheritdoc IWooRouterV2
    function externalSwap(
        address approveTarget,
        address swapTarget,
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minToAmount,
        address payable to,
        bytes calldata data
    ) public payable override nonReentrant returns (uint256 realToAmount) {
        require(approveTarget != address(0), 'WooRouter: approveTarget_ADDR_ZERO');
        require(swapTarget != address(0), 'WooRouter: swapTarget_ADDR_ZERO');
        require(fromToken != address(0), 'WooRouter: fromToken_ADDR_ZERO');
        require(toToken != address(0), 'WooRouter: toToken_ADDR_ZERO');
        require(to != address(0), 'WooRouter: to_ADDR_ZERO');
        require(isWhitelisted[approveTarget], 'WooRouter: APPROVE_TARGET_NOT_ALLOWED');
        require(isWhitelisted[swapTarget], 'WooRouter: SWAP_TARGET_NOT_ALLOWED');

        uint256 preBalance = _generalBalanceOf(toToken, address(this));
        _internalFallbackSwap(approveTarget, swapTarget, fromToken, fromAmount, data);
        uint256 postBalance = _generalBalanceOf(toToken, address(this));

        require(preBalance <= postBalance, 'WooRouter: balance_ERROR');
        realToAmount = postBalance.sub(preBalance);
        require(realToAmount >= minToAmount && realToAmount > 0, 'WooRouter: realToAmount_NOT_ENOUGH');
        _generalTransfer(toToken, to, realToAmount);

        emit WooRouterSwap(SwapType.DodoSwap, fromToken, toToken, fromAmount, realToAmount, msg.sender, to, address(0));
    }

    /* ----- External Functions ---- */

    /// @dev query the swap price for baseToken -> quoteToken.
    /// @param baseToken the base token to sell
    /// @param baseAmount the amout of base token to sell
    /// @return quoteAmount the amount of swapped quote token
    function querySellBase(address baseToken, uint256 baseAmount) external view returns (uint256 quoteAmount) {
        require(baseToken != address(0), 'WooRouter: baseToken_ADDR_ZERO');
        baseToken = (baseToken == ETH_PLACEHOLDER_ADDR) ? WETH : baseToken;
        quoteAmount = wooPool.querySellBase(baseToken, baseAmount);
    }

    /// @dev query the swap price for quoteToken -> baseToken.
    /// @param baseToken the base token to swap
    /// @param quoteAmount the amount of quote token to swap
    /// @return baseAmount the amount of base token after swap
    function querySellQuote(address baseToken, uint256 quoteAmount) external view returns (uint256 baseAmount) {
        require(baseToken != address(0), 'WooRouter: baseToken_ADDR_ZERO');
        baseToken = (baseToken == ETH_PLACEHOLDER_ADDR) ? WETH : baseToken;
        baseAmount = wooPool.querySellQuote(baseToken, quoteAmount);
    }

    /// @dev swap baseToken -> quoteToken
    /// @param baseToken the base token
    /// @param baseAmount the amount of base token to sell
    /// @param minQuoteAmount the minimum quote amount to receive
    /// @param to the destination address
    /// @param rebateTo the rebate address
    /// @return realQuoteAmount the exact received amount of quote token
    function sellBase(
        address baseToken,
        uint256 baseAmount,
        uint256 minQuoteAmount,
        address to,
        address rebateTo
    ) external nonReentrant returns (uint256 realQuoteAmount) {
        require(baseToken != address(0), 'WooRouter: baseToken_ADDR_ZERO');
        require(to != address(0), 'WooRouter: to_ADDR_ZERO');
        TransferHelper.safeTransferFrom(baseToken, msg.sender, address(this), baseAmount);
        TransferHelper.safeApprove(baseToken, address(wooPool), baseAmount);
        realQuoteAmount = wooPool.sellBase(baseToken, baseAmount, minQuoteAmount, to, rebateTo);
        emit WooRouterSwap(
            SwapType.WooSwap,
            baseToken,
            quoteToken,
            baseAmount,
            realQuoteAmount,
            msg.sender,
            to,
            rebateTo
        );
    }

    /// @dev swap quoteToken -> baseToken
    /// @param baseToken the base token to receive
    /// @param quoteAmount the amount of quote token to sell
    /// @param minBaseAmount the minimum amount of base token for swap
    /// @param to the destination address
    /// @param rebateTo the address for the rebate
    /// @return realBaseAmount the exact received amount of base token to receive
    function sellQuote(
        address baseToken,
        uint256 quoteAmount,
        uint256 minBaseAmount,
        address to,
        address rebateTo
    ) external nonReentrant returns (uint256 realBaseAmount) {
        require(baseToken != address(0), 'WooRouter: baseToken_ADDR_ZERO');
        require(to != address(0), 'WooRouter: to_ADDR_ZERO');
        TransferHelper.safeTransferFrom(quoteToken, msg.sender, address(this), quoteAmount);
        TransferHelper.safeApprove(quoteToken, address(wooPool), quoteAmount);
        realBaseAmount = wooPool.sellQuote(baseToken, quoteAmount, minBaseAmount, to, rebateTo);
        emit WooRouterSwap(
            SwapType.WooSwap,
            quoteToken,
            baseToken,
            quoteAmount,
            realBaseAmount,
            msg.sender,
            to,
            rebateTo
        );
    }

    /* ----- Admin functions ----- */

    /// @dev Rescue the specified funds when stuck happen
    /// @param token token address
    /// @param amount amount of token to rescue
    function rescueFunds(address token, uint256 amount) external nonReentrant onlyOwner {
        require(token != address(0), 'WooRouter: token_ADDR_ZERO');
        TransferHelper.safeTransfer(token, msg.sender, amount);
    }

    /// @dev Rescue the native token funds when stuck happen
    function rescueNativeFunds() external nonReentrant onlyOwner {
        TransferHelper.safeTransferETH(msg.sender, address(this).balance);
    }

    /// @dev Set wooPool from newPool
    /// @param newPool Wooracle address
    function setPool(address newPool) public nonReentrant onlyOwner {
        require(newPool != address(0), 'WooRouter: newPool_ADDR_ZERO');
        wooPool = IWooPP(newPool);
        quoteToken = wooPool.quoteToken();
        require(quoteToken != address(0), 'WooRouter: quoteToken_ADDR_ZERO');
        emit WooPoolChanged(newPool);
    }

    /// @dev Add target address into whitelist
    /// @param target address that approved by WooRouter
    /// @param whitelisted approve to using WooRouter or not
    function setWhitelisted(address target, bool whitelisted) external nonReentrant onlyOwner {
        require(target != address(0), 'WooRouter: target_ADDR_ZERO');
        isWhitelisted[target] = whitelisted;
    }

    /* ----- Private Function ----- */

    function _sellQuoteAndTransfer(
        bool isToETH,
        address toToken,
        uint256 quoteAmount,
        uint256 minToAmount,
        address payable to,
        address rebateTo
    ) private returns (uint256 realToAmount) {
        if (isToETH) {
            realToAmount = wooPool.sellQuote(toToken, quoteAmount, minToAmount, address(this), rebateTo);
            IWETH(WETH).withdraw(realToAmount);
            require(to != address(0), 'WooRouter: to_ZERO_ADDR');
            TransferHelper.safeTransferETH(to, realToAmount);
        } else {
            realToAmount = wooPool.sellQuote(toToken, quoteAmount, minToAmount, to, rebateTo);
        }
    }

    function _internalFallbackSwap(
        address approveTarget,
        address swapTarget,
        address fromToken,
        uint256 fromAmount,
        bytes calldata data
    ) private {
        require(isWhitelisted[approveTarget], 'WooRouter: APPROVE_TARGET_NOT_ALLOWED');
        require(isWhitelisted[swapTarget], 'WooRouter: SWAP_TARGET_NOT_ALLOWED');

        if (fromToken != ETH_PLACEHOLDER_ADDR) {
            TransferHelper.safeTransferFrom(fromToken, msg.sender, address(this), fromAmount);
            TransferHelper.safeApprove(fromToken, approveTarget, fromAmount);
        } else {
            require(fromAmount <= msg.value, 'WooRouter: fromAmount_INVALID');
        }

        (bool success, ) = swapTarget.call{value: fromToken == ETH_PLACEHOLDER_ADDR ? fromAmount : 0}(data);
        require(success, 'WooRouter: FALLBACK_SWAP_FAILED');
    }

    function _generalTransfer(
        address token,
        address payable to,
        uint256 amount
    ) private {
        if (amount > 0) {
            if (token == ETH_PLACEHOLDER_ADDR) {
                TransferHelper.safeTransferETH(to, amount);
            } else {
                TransferHelper.safeTransfer(token, to, amount);
            }
        }
    }

    function _generalBalanceOf(address token, address who) private view returns (uint256) {
        return token == ETH_PLACEHOLDER_ADDR ? who.balance : IERC20(token).balanceOf(who);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import '../interfaces/IWooPP.sol';

/// @title Woo router interface
/// @notice functions to interface with WooFi swap
interface IWooRouterV2 {
    /* ----- Type declarations ----- */

    enum SwapType {
        WooSwap,
        DodoSwap
    }

    /* ----- Events ----- */

    event WooRouterSwap(
        SwapType swapType,
        address indexed fromToken,
        address indexed toToken,
        uint256 fromAmount,
        uint256 toAmount,
        address from,
        address indexed to,
        address rebateTo
    );

    event WooPoolChanged(address newPool);

    /* ----- Router properties ----- */

    function WETH() external pure returns (address);

    function wooPool() external pure returns (IWooPP);

    /* ----- Main query & swap APIs ----- */

    /// @dev query the amount to swap fromToken -> toToken
    /// @param fromToken the from token
    /// @param toToken the to token
    /// @param fromAmount the amount of fromToken to swap
    /// @return toAmount the predicted amount to receive
    function querySwap(
        address fromToken,
        address toToken,
        uint256 fromAmount
    ) external view returns (uint256 toAmount);

    /// @dev swap fromToken -> toToken
    /// @param fromToken the from token
    /// @param toToken the to token
    /// @param fromAmount the amount of fromToken to swap
    /// @param minToAmount the amount of fromToken to swap
    /// @param to the destination address
    /// @param rebateTo the rebate address (optional, can be 0)
    /// @return realToAmount the amount of toToken to receive
    function swap(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minToAmount,
        address payable to,
        address rebateTo
    ) external payable returns (uint256 realToAmount);

    /* ----- 3rd party DEX swap ----- */

    /// @dev swap fromToken -> toToken via an external 3rd swap
    /// @param approveTarget the contract address for token transfer approval
    /// @param swapTarget the contract address for swap
    /// @param fromToken the from token
    /// @param toToken the to token
    /// @param fromAmount the amount of fromToken to swap
    /// @param minToAmount the min amount of swapped toToken
    /// @param to the destination address
    /// @param data call data for external call
    function externalSwap(
        address approveTarget,
        address swapTarget,
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minToAmount,
        address payable to,
        bytes calldata data
    ) external payable returns (uint256 realToAmount);
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import './interfaces/IWooPP.sol';
import './interfaces/IWETH.sol';
import './interfaces/IWooRouter.sol';

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

/// @title Woo Router implementation.
/// @notice Router for stateless execution of swaps against Woo private pool.
contract WooRouter is IWooRouter, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ----- Constant variables ----- */

    // Erc20 placeholder address for native tokens (e.g. eth, bnb, matic, etc)
    address constant ETH_PLACEHOLDER_ADDR = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /* ----- State variables ----- */

    // Wrapper for native tokens (e.g. eth, bnb, matic, etc)
    // BSC WBNB: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    address public immutable override WETH;

    IWooPP public override wooPool;

    mapping(address => bool) public isWhitelisted;

    address public quoteToken;

    /* ----- Callback Function ----- */

    receive() external payable {
        // only accept ETH from WETH or whitelisted external swaps.
        assert(msg.sender == WETH || isWhitelisted[msg.sender]);
    }

    /* ----- Query & swap APIs ----- */

    constructor(address weth, address newPool) public {
        require(weth != address(0), 'WooRouter: weth_ZERO_ADDR');
        WETH = weth;
        setPool(newPool);
    }

    /// @inheritdoc IWooRouter
    function querySwap(
        address fromToken,
        address toToken,
        uint256 fromAmount
    ) external view override returns (uint256 toAmount) {
        require(fromToken != address(0), 'WooRouter: fromToken_ADDR_ZERO');
        require(toToken != address(0), 'WooRouter: toToken_ADDR_ZERO');
        fromToken = (fromToken == ETH_PLACEHOLDER_ADDR) ? WETH : fromToken;
        toToken = (toToken == ETH_PLACEHOLDER_ADDR) ? WETH : toToken;
        if (fromToken == quoteToken) {
            toAmount = wooPool.querySellQuote(toToken, fromAmount);
        } else if (toToken == quoteToken) {
            toAmount = wooPool.querySellBase(fromToken, fromAmount);
        } else {
            uint256 quoteAmount = wooPool.querySellBase(fromToken, fromAmount);
            toAmount = wooPool.querySellQuote(toToken, quoteAmount);
        }
    }

    /// @inheritdoc IWooRouter
    function swap(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minToAmount,
        address payable to,
        address rebateTo
    ) external payable override nonReentrant returns (uint256 realToAmount) {
        require(fromToken != address(0), 'WooRouter: fromToken_ADDR_ZERO');
        require(toToken != address(0), 'WooRouter: toToken_ADDR_ZERO');
        require(to != address(0), 'WooRouter: to_ADDR_ZERO');

        bool isFromETH = fromToken == ETH_PLACEHOLDER_ADDR;
        bool isToETH = toToken == ETH_PLACEHOLDER_ADDR;
        fromToken = isFromETH ? WETH : fromToken;
        toToken = isToETH ? WETH : toToken;

        // Step 1: transfer the source tokens to WooRouter
        if (isFromETH) {
            require(fromAmount <= msg.value, 'WooRouter: fromAmount_INVALID');
            IWETH(WETH).deposit{value: msg.value}();
        } else {
            TransferHelper.safeTransferFrom(fromToken, msg.sender, address(this), fromAmount);
        }

        // Step 2: swap and transfer
        TransferHelper.safeApprove(fromToken, address(wooPool), fromAmount);
        if (fromToken == quoteToken) {
            // case 1: quoteToken --> baseToken
            realToAmount = _sellQuoteAndTransfer(isToETH, toToken, fromAmount, minToAmount, to, rebateTo);
        } else if (toToken == quoteToken) {
            // case 2: fromToken --> quoteToken
            realToAmount = wooPool.sellBase(fromToken, fromAmount, minToAmount, to, rebateTo);
        } else {
            // case 3: fromToken --> quoteToken --> toToken
            uint256 quoteAmount = wooPool.sellBase(fromToken, fromAmount, 0, address(this), rebateTo);
            TransferHelper.safeApprove(quoteToken, address(wooPool), quoteAmount);
            realToAmount = _sellQuoteAndTransfer(isToETH, toToken, quoteAmount, minToAmount, to, rebateTo);
        }

        // Step 3: firing event
        emit WooRouterSwap(
            SwapType.WooSwap,
            isFromETH ? ETH_PLACEHOLDER_ADDR : fromToken,
            isToETH ? ETH_PLACEHOLDER_ADDR : toToken,
            fromAmount,
            realToAmount,
            msg.sender,
            to,
            rebateTo
        );
    }

    /// @inheritdoc IWooRouter
    function externalSwap(
        address approveTarget,
        address swapTarget,
        address fromToken,
        address toToken,
        uint256 fromAmount,
        address payable to,
        bytes calldata data
    ) external payable override {
        externalSwap(approveTarget, swapTarget, fromToken, toToken, fromAmount, 0, to, data);
    }

    /// @inheritdoc IWooRouter
    function externalSwap(
        address approveTarget,
        address swapTarget,
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minToAmount,
        address payable to,
        bytes calldata data
    ) public payable override nonReentrant returns (uint256 realToAmount) {
        require(approveTarget != address(0), 'WooRouter: approveTarget_ADDR_ZERO');
        require(swapTarget != address(0), 'WooRouter: swapTarget_ADDR_ZERO');
        require(fromToken != address(0), 'WooRouter: fromToken_ADDR_ZERO');
        require(toToken != address(0), 'WooRouter: toToken_ADDR_ZERO');
        require(to != address(0), 'WooRouter: to_ADDR_ZERO');
        require(isWhitelisted[approveTarget], 'WooRouter: APPROVE_TARGET_NOT_ALLOWED');
        require(isWhitelisted[swapTarget], 'WooRouter: SWAP_TARGET_NOT_ALLOWED');

        uint256 preBalance = _generalBalanceOf(toToken, address(this));
        _internalFallbackSwap(approveTarget, swapTarget, fromToken, fromAmount, data);
        uint256 postBalance = _generalBalanceOf(toToken, address(this));

        require(preBalance <= postBalance, 'WooRouter: balance_ERROR');
        realToAmount = postBalance.sub(preBalance);
        require(realToAmount >= minToAmount && realToAmount > 0, 'WooRouter: realToAmount_NOT_ENOUGH');
        _generalTransfer(toToken, to, realToAmount);

        emit WooRouterSwap(SwapType.DodoSwap, fromToken, toToken, fromAmount, realToAmount, msg.sender, to, address(0));
    }

    /* ----- External Functions ---- */

    /// @dev query the swap price for baseToken -> quoteToken.
    /// @param baseToken the base token to sell
    /// @param baseAmount the amout of base token to sell
    /// @return quoteAmount the amount of swapped quote token
    function querySellBase(address baseToken, uint256 baseAmount) external view returns (uint256 quoteAmount) {
        require(baseToken != address(0), 'WooRouter: baseToken_ADDR_ZERO');
        baseToken = (baseToken == ETH_PLACEHOLDER_ADDR) ? WETH : baseToken;
        quoteAmount = wooPool.querySellBase(baseToken, baseAmount);
    }

    /// @dev query the swap price for quoteToken -> baseToken.
    /// @param baseToken the base token to swap
    /// @param quoteAmount the amount of quote token to swap
    /// @return baseAmount the amount of base token after swap
    function querySellQuote(address baseToken, uint256 quoteAmount) external view returns (uint256 baseAmount) {
        require(baseToken != address(0), 'WooRouter: baseToken_ADDR_ZERO');
        baseToken = (baseToken == ETH_PLACEHOLDER_ADDR) ? WETH : baseToken;
        baseAmount = wooPool.querySellQuote(baseToken, quoteAmount);
    }

    /// @dev swap baseToken -> quoteToken
    /// @param baseToken the base token
    /// @param baseAmount the amount of base token to sell
    /// @param minQuoteAmount the minimum quote amount to receive
    /// @param to the destination address
    /// @param rebateTo the rebate address
    /// @return realQuoteAmount the exact received amount of quote token
    function sellBase(
        address baseToken,
        uint256 baseAmount,
        uint256 minQuoteAmount,
        address to,
        address rebateTo
    ) external nonReentrant returns (uint256 realQuoteAmount) {
        require(baseToken != address(0), 'WooRouter: baseToken_ADDR_ZERO');
        require(to != address(0), 'WooRouter: to_ADDR_ZERO');
        TransferHelper.safeTransferFrom(baseToken, msg.sender, address(this), baseAmount);
        TransferHelper.safeApprove(baseToken, address(wooPool), baseAmount);
        realQuoteAmount = wooPool.sellBase(baseToken, baseAmount, minQuoteAmount, to, rebateTo);
        emit WooRouterSwap(
            SwapType.WooSwap,
            baseToken,
            quoteToken,
            baseAmount,
            realQuoteAmount,
            msg.sender,
            to,
            rebateTo
        );
    }

    /// @dev swap quoteToken -> baseToken
    /// @param baseToken the base token to receive
    /// @param quoteAmount the amount of quote token to sell
    /// @param minBaseAmount the minimum amount of base token for swap
    /// @param to the destination address
    /// @param rebateTo the address for the rebate
    /// @return realBaseAmount the exact received amount of base token to receive
    function sellQuote(
        address baseToken,
        uint256 quoteAmount,
        uint256 minBaseAmount,
        address to,
        address rebateTo
    ) external nonReentrant returns (uint256 realBaseAmount) {
        require(baseToken != address(0), 'WooRouter: baseToken_ADDR_ZERO');
        require(to != address(0), 'WooRouter: to_ADDR_ZERO');
        TransferHelper.safeTransferFrom(quoteToken, msg.sender, address(this), quoteAmount);
        TransferHelper.safeApprove(quoteToken, address(wooPool), quoteAmount);
        realBaseAmount = wooPool.sellQuote(baseToken, quoteAmount, minBaseAmount, to, rebateTo);
        emit WooRouterSwap(
            SwapType.WooSwap,
            quoteToken,
            baseToken,
            quoteAmount,
            realBaseAmount,
            msg.sender,
            to,
            rebateTo
        );
    }

    /* ----- Admin functions ----- */

    /// @dev Rescue the specified funds when stuck happen
    /// @param token token address
    /// @param amount amount of token to rescue
    function rescueFunds(address token, uint256 amount) external nonReentrant onlyOwner {
        require(token != address(0), 'WooRouter: token_ADDR_ZERO');
        TransferHelper.safeTransfer(token, msg.sender, amount);
    }

    /// @dev Set wooPool from newPool
    /// @param newPool Wooracle address
    function setPool(address newPool) public nonReentrant onlyOwner {
        require(newPool != address(0), 'WooRouter: newPool_ADDR_ZERO');
        wooPool = IWooPP(newPool);
        quoteToken = wooPool.quoteToken();
        require(quoteToken != address(0), 'WooRouter: quoteToken_ADDR_ZERO');
        emit WooPoolChanged(newPool);
    }

    /// @dev Add target address into whitelist
    /// @param target address that approved by WooRouter
    /// @param whitelisted approve to using WooRouter or not
    function setWhitelisted(address target, bool whitelisted) external nonReentrant onlyOwner {
        require(target != address(0), 'WooRouter: target_ADDR_ZERO');
        isWhitelisted[target] = whitelisted;
    }

    /* ----- Private Function ----- */

    function _sellQuoteAndTransfer(
        bool isToETH,
        address toToken,
        uint256 quoteAmount,
        uint256 minToAmount,
        address payable to,
        address rebateTo
    ) private returns (uint256 realToAmount) {
        if (isToETH) {
            realToAmount = wooPool.sellQuote(toToken, quoteAmount, minToAmount, address(this), rebateTo);
            IWETH(WETH).withdraw(realToAmount);
            require(to != address(0), 'WooRouter: to_ZERO_ADDR');
            TransferHelper.safeTransferETH(to, realToAmount);
        } else {
            realToAmount = wooPool.sellQuote(toToken, quoteAmount, minToAmount, to, rebateTo);
        }
    }

    function _internalFallbackSwap(
        address approveTarget,
        address swapTarget,
        address fromToken,
        uint256 fromAmount,
        bytes calldata data
    ) private {
        require(isWhitelisted[approveTarget], 'WooRouter: APPROVE_TARGET_NOT_ALLOWED');
        require(isWhitelisted[swapTarget], 'WooRouter: SWAP_TARGET_NOT_ALLOWED');

        if (fromToken != ETH_PLACEHOLDER_ADDR) {
            TransferHelper.safeTransferFrom(fromToken, msg.sender, address(this), fromAmount);
            TransferHelper.safeApprove(fromToken, approveTarget, fromAmount);
        } else {
            require(fromAmount <= msg.value, 'WooRouter: fromAmount_INVALID');
        }

        (bool success, ) = swapTarget.call{value: fromToken == ETH_PLACEHOLDER_ADDR ? fromAmount : 0}(data);
        require(success, 'WooRouter: FALLBACK_SWAP_FAILED');
    }

    function _generalTransfer(
        address token,
        address payable to,
        uint256 amount
    ) private {
        if (amount > 0) {
            if (token == ETH_PLACEHOLDER_ADDR) {
                TransferHelper.safeTransferETH(to, amount);
            } else {
                TransferHelper.safeTransfer(token, to, amount);
            }
        }
    }

    function _generalBalanceOf(address token, address who) private view returns (uint256) {
        return token == ETH_PLACEHOLDER_ADDR ? who.balance : IERC20(token).balanceOf(who);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import '../interfaces/IWooPP.sol';

/// @title Woo router interface
/// @notice functions to interface with WooFi swap
interface IWooRouter {
    /* ----- Type declarations ----- */

    enum SwapType {
        WooSwap,
        DodoSwap
    }

    /* ----- Events ----- */

    event WooRouterSwap(
        SwapType swapType,
        address indexed fromToken,
        address indexed toToken,
        uint256 fromAmount,
        uint256 toAmount,
        address from,
        address indexed to,
        address rebateTo
    );

    event WooPoolChanged(address newPool);

    /* ----- Router properties ----- */

    function WETH() external pure returns (address);

    function wooPool() external pure returns (IWooPP);

    /* ----- Main query & swap APIs ----- */

    /// @dev query the amount to swap fromToken -> toToken
    /// @param fromToken the from token
    /// @param toToken the to token
    /// @param fromAmount the amount of fromToken to swap
    /// @return toAmount the predicted amount to receive
    function querySwap(
        address fromToken,
        address toToken,
        uint256 fromAmount
    ) external view returns (uint256 toAmount);

    /// @dev swap fromToken -> toToken
    /// @param fromToken the from token
    /// @param toToken the to token
    /// @param fromAmount the amount of fromToken to swap
    /// @param minToAmount the amount of fromToken to swap
    /// @param to the destination address
    /// @param rebateTo the rebate address (optional, can be 0)
    /// @return realToAmount the amount of toToken to receive
    function swap(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minToAmount,
        address payable to,
        address rebateTo
    ) external payable returns (uint256 realToAmount);

    /* ----- 3rd party DEX swap ----- */

    /// @dev swap fromToken -> toToken via an external 3rd swap
    /// @param approveTarget the contract address for token transfer approval
    /// @param swapTarget the contract address for swap
    /// @param fromToken the from token
    /// @param toToken the to token
    /// @param fromAmount the amount of fromToken to swap
    /// @param to the destination address
    /// @param data call data for external call
    function externalSwap(
        address approveTarget,
        address swapTarget,
        address fromToken,
        address toToken,
        uint256 fromAmount,
        address payable to,
        bytes calldata data
    ) external payable;

    /// @dev swap fromToken -> toToken via an external 3rd swap
    /// @param approveTarget the contract address for token transfer approval
    /// @param swapTarget the contract address for swap
    /// @param fromToken the from token
    /// @param toToken the to token
    /// @param fromAmount the amount of fromToken to swap
    /// @param minToAmount the min amount of swapped toToken
    /// @param to the destination address
    /// @param data call data for external call
    function externalSwap(
        address approveTarget,
        address swapTarget,
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minToAmount,
        address payable to,
        bytes calldata data
    ) external payable returns (uint256 realToAmount);
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import './libraries/InitializableOwnable.sol';
import './interfaces/IWooracle.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';

/// @title Wooracle implementation in BSC
/// @notice Will be maintained and updated periodically by Woo.network in multichains.
contract Wooracle is InitializableOwnable, IWooracle {
    /* ----- State variables ----- */

    // 128 + 64 + 64 = 256 bits (slot size)
    struct TokenInfo {
        uint128 price; // 18 - base_decimal + quote_decimal
        uint64 coeff; // 18. coeff <= 1e18    (2^64 = 1.84e19)
        uint64 spread; // 18. spread <= 2e18   (2^64 = 1.84e19)
    }

    mapping(address => TokenInfo) public infos;

    address public override quoteToken;
    uint256 public override timestamp;

    uint256 public staleDuration;

    constructor() public {
        initOwner(msg.sender);
        staleDuration = uint256(300);
    }

    /* ----- External Functions ----- */

    /// @dev Set the quote token address.
    /// @param newQuoteToken token address
    function setQuoteToken(address newQuoteToken) external onlyOwner {
        quoteToken = newQuoteToken;
    }

    /// @dev Set the staleDuration.
    /// @param newStaleDuration the new stale duration
    function setStaleDuration(uint256 newStaleDuration) external onlyOwner {
        staleDuration = newStaleDuration;
    }

    /// @dev Update the base token prices.
    /// @param base the baseToken address
    /// @param newPrice the new prices for the base token
    function postPrice(address base, uint128 newPrice) external onlyOwner {
        infos[base].price = newPrice;
        timestamp = block.timestamp;
    }

    /// @dev batch update baseTokens prices
    /// @param bases list of baseToken address
    /// @param newPrices the updated prices list
    function postPriceList(address[] calldata bases, uint128[] calldata newPrices) external onlyOwner {
        uint256 length = bases.length;
        require(length == newPrices.length, 'Wooracle: length_INVALID');

        for (uint256 i = 0; i < length; i++) {
            infos[bases[i]].price = newPrices[i];
        }

        timestamp = block.timestamp;
    }

    /// @dev update the spreads info.
    /// @param base baseToken address
    /// @param newSpread the new spreads
    function postSpread(address base, uint64 newSpread) external onlyOwner {
        infos[base].spread = newSpread;
        timestamp = block.timestamp;
    }

    /// @dev batch update the spreads info.
    /// @param bases list of baseToken address
    /// @param newSpreads list of spreads info
    function postSpreadList(address[] calldata bases, uint64[] calldata newSpreads) external onlyOwner {
        uint256 length = bases.length;
        require(length == newSpreads.length, 'Wooracle: length_INVALID');

        for (uint256 i = 0; i < length; i++) {
            infos[bases[i]].spread = newSpreads[i];
        }

        timestamp = block.timestamp;
    }

    /// @dev update the state of the given base token.
    /// @param base baseToken address
    /// @param newPrice the new prices
    /// @param newSpread the new spreads
    /// @param newCoeff the new slippage coefficent
    function postState(
        address base,
        uint128 newPrice,
        uint64 newSpread,
        uint64 newCoeff
    ) external onlyOwner {
        _setState(base, newPrice, newSpread, newCoeff);
        timestamp = block.timestamp;
    }

    /// @dev batch update the prices, spreads and slipagge coeffs info.
    /// @param bases list of baseToken address
    /// @param newPrices the prices list
    /// @param newSpreads the spreads list
    /// @param newCoeffs the slippage coefficent list
    function postStateList(
        address[] calldata bases,
        uint128[] calldata newPrices,
        uint64[] calldata newSpreads,
        uint64[] calldata newCoeffs
    ) external onlyOwner {
        uint256 length = bases.length;
        require(
            length == newPrices.length && length == newSpreads.length && length == newCoeffs.length,
            'Wooracle: length_INVALID'
        );

        for (uint256 i = 0; i < length; i++) {
            _setState(bases[i], newPrices[i], newSpreads[i], newCoeffs[i]);
        }
        timestamp = block.timestamp;
    }

    /// @inheritdoc IWooracle
    function price(address base) external view override returns (uint256 priceNow, bool feasible) {
        priceNow = uint256(infos[base].price);
        feasible = priceNow != 0 && block.timestamp <= (timestamp + staleDuration * 1 seconds);
    }

    function getPrice(address base) external view override returns (uint256) {
        return uint256(infos[base].price);
    }

    function getSpread(address base) external view override returns (uint256) {
        return uint256(infos[base].spread);
    }

    function getCoeff(address base) external view override returns (uint256) {
        return uint256(infos[base].coeff);
    }

    /// @inheritdoc IWooracle
    function state(address base)
        external
        view
        override
        returns (
            uint256 priceNow,
            uint256 spreadNow,
            uint256 coeffNow,
            bool feasible
        )
    {
        TokenInfo storage info = infos[base];
        priceNow = uint256(info.price);
        spreadNow = uint256(info.spread);
        coeffNow = uint256(info.coeff);
        feasible = priceNow != 0 && block.timestamp <= (timestamp + staleDuration * 1 seconds);
    }

    function isFeasible(address base) public view override returns (bool) {
        return infos[base].price != 0 && block.timestamp <= (timestamp + staleDuration * 1 seconds);
    }

    /* ----- Private Functions ----- */

    function _setState(
        address base,
        uint128 newPrice,
        uint64 newSpread,
        uint64 newCoeff
    ) private {
        TokenInfo storage info = infos[base];
        info.price = newPrice;
        info.spread = newSpread;
        info.coeff = newCoeff;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import './libraries/InitializableOwnable.sol';
import './interfaces/IWooracle.sol';

/// @title Wooracle implementation in Fantom and Avalanche chain.
/// @notice Will be maintained and updated periodically by Woo.network in multichains.
contract Wooracle is InitializableOwnable, IWooracle {
    /* ----- State variables ----- */

    struct TokenInfo {
        uint256 price; // 18 - base_decimal + quote_decimal
        uint256 coeff; // 36 - quote
        uint256 spread; // 18
    }

    mapping(address => TokenInfo) public infos;

    address public override quoteToken;
    uint256 public override timestamp;

    uint256 public staleDuration;

    constructor() public {
        initOwner(msg.sender);
        staleDuration = uint256(300);
    }

    /* ----- External Functions ----- */

    /// @dev Set the quote token address.
    /// @param newQuoteToken token address
    function setQuoteToken(address newQuoteToken) external onlyOwner {
        quoteToken = newQuoteToken;
    }

    /// @dev Set the staleDuration.
    /// @param newStaleDuration the new stale duration
    function setStaleDuration(uint256 newStaleDuration) external onlyOwner {
        staleDuration = newStaleDuration;
    }

    /// @dev Update the base token prices.
    /// @param base the baseToken address
    /// @param newPrice the new prices for the base token
    function postPrice(address base, uint256 newPrice) external onlyOwner {
        infos[base].price = newPrice;
        timestamp = block.timestamp;
    }

    /// @dev batch update baseTokens prices
    /// @param bases list of baseToken address
    /// @param newPrices the updated prices list
    function postPriceList(address[] calldata bases, uint256[] calldata newPrices) external onlyOwner {
        uint256 length = bases.length;
        require(length == newPrices.length, 'Wooracle: length_INVALID');

        for (uint256 i = 0; i < length; i++) {
            infos[bases[i]].price = newPrices[i];
        }

        timestamp = block.timestamp;
    }

    /// @dev update the spreads info.
    /// @param base baseToken address
    /// @param newSpread the new spreads
    function postSpread(address base, uint256 newSpread) external onlyOwner {
        infos[base].spread = newSpread;
        timestamp = block.timestamp;
    }

    /// @dev batch update the spreads info.
    /// @param bases list of baseToken address
    /// @param newSpreads list of spreads info
    function postSpreadList(address[] calldata bases, uint256[] calldata newSpreads) external onlyOwner {
        uint256 length = bases.length;
        require(length == newSpreads.length, 'Wooracle: length_INVALID');

        for (uint256 i = 0; i < length; i++) {
            infos[bases[i]].spread = newSpreads[i];
        }

        timestamp = block.timestamp;
    }

    /// @dev update the state of the given base token.
    /// @param base baseToken address
    /// @param newPrice the new prices
    /// @param newSpread the new spreads
    /// @param newCoeff the new slippage coefficent
    function postState(
        address base,
        uint256 newPrice,
        uint256 newSpread,
        uint256 newCoeff
    ) external onlyOwner {
        _setState(base, newPrice, newSpread, newCoeff);
        timestamp = block.timestamp;
    }

    /// @dev batch update the prices, spreads and slipagge coeffs info.
    /// @param bases list of baseToken address
    /// @param newPrices the prices list
    /// @param newSpreads the spreads list
    /// @param newCoeffs the slippage coefficent list
    function postStateList(
        address[] calldata bases,
        uint256[] calldata newPrices,
        uint256[] calldata newSpreads,
        uint256[] calldata newCoeffs
    ) external onlyOwner {
        uint256 length = bases.length;
        require(
            length == newPrices.length && length == newSpreads.length && length == newCoeffs.length,
            'Wooracle: length_INVALID'
        );

        for (uint256 i = 0; i < length; i++) {
            _setState(bases[i], newPrices[i], newSpreads[i], newCoeffs[i]);
        }
        timestamp = block.timestamp;
    }

    /// @inheritdoc IWooracle
    function price(address base) external view override returns (uint256 priceNow, bool feasible) {
        priceNow = infos[base].price;
        feasible = priceNow != 0 && block.timestamp <= (timestamp + staleDuration * 1 seconds);
    }

    function getPrice(address base) external view override returns (uint256) {
        return infos[base].price;
    }

    function getSpread(address base) external view override returns (uint256) {
        return infos[base].spread;
    }

    function getCoeff(address base) external view override returns (uint256) {
        return infos[base].coeff;
    }

    /// @inheritdoc IWooracle
    function state(address base)
        external
        view
        override
        returns (
            uint256 priceNow,
            uint256 spreadNow,
            uint256 coeffNow,
            bool feasible
        )
    {
        TokenInfo storage info = infos[base];
        priceNow = info.price;
        spreadNow = info.spread;
        coeffNow = info.coeff;
        feasible = priceNow != 0 && block.timestamp <= (timestamp + staleDuration * 1 seconds);
    }

    function isFeasible(address base) public view override returns (bool) {
        return infos[base].price != 0 && block.timestamp <= (timestamp + staleDuration * 1 seconds);
    }

    /* ----- Private Functions ----- */

    function _setState(
        address base,
        uint256 newPrice,
        uint256 newSpread,
        uint256 newCoeff
    ) private {
        TokenInfo storage info = infos[base];
        info.price = newPrice;
        info.spread = newSpread;
        info.coeff = newCoeff;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import './libraries/InitializableOwnable.sol';
import './libraries/DecimalMath.sol';
import './interfaces/IWooracle.sol';
import './interfaces/IWooPP.sol';
import './interfaces/IWooFeeManager.sol';
import './interfaces/IWooGuardian.sol';
import './interfaces/AggregatorV3Interface.sol';

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

/// @title Woo private pool for swaping.
/// @notice the implementation class for interface IWooPP, mainly for query and swap tokens.
contract WooPP is InitializableOwnable, ReentrancyGuard, Pausable, IWooPP {
    /* ----- Type declarations ----- */

    using SafeMath for uint256;
    using DecimalMath for uint256;
    using SafeERC20 for IERC20;

    /* ----- State variables ----- */

    mapping(address => TokenInfo) public tokenInfo;
    mapping(address => bool) public isStrategist;

    /// @inheritdoc IWooPP
    address public immutable override quoteToken;
    address public wooracle;
    IWooGuardian public wooGuardian;
    IWooFeeManager public feeManager;
    string public pairsInfo; // e.g. BNB/ETH/BTCB/WOO-USDT

    /* ----- Modifiers ----- */

    modifier onlyStrategist() {
        require(msg.sender == _OWNER_ || isStrategist[msg.sender], 'WooPP: NOT_STRATEGIST');
        _;
    }

    constructor(
        address newQuoteToken,
        address newWooracle,
        address newFeeManager,
        address newWooGuardian
    ) public {
        require(newQuoteToken != address(0), 'WooPP: INVALID_QUOTE');
        require(newWooracle != address(0), 'WooPP: newWooracle_ZERO_ADDR');
        require(newFeeManager != address(0), 'WooPP: newFeeManager_ZERO_ADDR');
        require(newWooGuardian != address(0), 'WooPP: newWooGuardian_ZERO_ADDR');

        initOwner(msg.sender);
        quoteToken = newQuoteToken;
        wooracle = newWooracle;
        feeManager = IWooFeeManager(newFeeManager);
        require(feeManager.quoteToken() == newQuoteToken, 'WooPP: feeManager_quoteToken_INVALID');
        wooGuardian = IWooGuardian(newWooGuardian);

        TokenInfo storage quoteInfo = tokenInfo[newQuoteToken];
        quoteInfo.isValid = true;
    }

    /* ----- External Functions ----- */

    /// @inheritdoc IWooPP
    function querySellBase(address baseToken, uint256 baseAmount)
        external
        view
        override
        whenNotPaused
        returns (uint256 quoteAmount)
    {
        require(baseToken != address(0), 'WooPP: baseToken_ZERO_ADDR');
        require(baseToken != quoteToken, 'WooPP: baseToken==quoteToken');
        wooGuardian.checkInputAmount(baseToken, baseAmount);

        TokenInfo memory baseInfo = tokenInfo[baseToken];
        require(baseInfo.isValid, 'WooPP: TOKEN_DOES_NOT_EXIST');
        TokenInfo memory quoteInfo = tokenInfo[quoteToken];
        _autoUpdate(baseToken, baseInfo, quoteInfo);

        quoteAmount = getQuoteAmountSellBase(baseToken, baseAmount, baseInfo, quoteInfo);
        wooGuardian.checkSwapAmount(baseToken, quoteToken, baseAmount, quoteAmount);
        uint256 lpFee = quoteAmount.mulCeil(feeManager.feeRate(baseToken));
        quoteAmount = quoteAmount.sub(lpFee);

        require(quoteAmount <= IERC20(quoteToken).balanceOf(address(this)), 'WooPP: INSUFF_QUOTE');
    }

    /// @inheritdoc IWooPP
    function querySellQuote(address baseToken, uint256 quoteAmount)
        external
        view
        override
        whenNotPaused
        returns (uint256 baseAmount)
    {
        require(baseToken != address(0), 'WooPP: baseToken_ZERO_ADDR');
        require(baseToken != quoteToken, 'WooPP: baseToken==quoteToken');
        wooGuardian.checkInputAmount(quoteToken, quoteAmount);

        TokenInfo memory baseInfo = tokenInfo[baseToken];
        require(baseInfo.isValid, 'WooPP: TOKEN_DOES_NOT_EXIST');
        TokenInfo memory quoteInfo = tokenInfo[quoteToken];
        _autoUpdate(baseToken, baseInfo, quoteInfo);

        uint256 lpFee = quoteAmount.mulCeil(feeManager.feeRate(baseToken));
        quoteAmount = quoteAmount.sub(lpFee);
        baseAmount = getBaseAmountSellQuote(baseToken, quoteAmount, baseInfo, quoteInfo);
        wooGuardian.checkSwapAmount(quoteToken, baseToken, quoteAmount, baseAmount);

        require(baseAmount <= IERC20(baseToken).balanceOf(address(this)), 'WooPP: INSUFF_BASE');
    }

    /// @inheritdoc IWooPP
    function sellBase(
        address baseToken,
        uint256 baseAmount,
        uint256 minQuoteAmount,
        address to,
        address rebateTo
    ) external override nonReentrant whenNotPaused returns (uint256 quoteAmount) {
        require(baseToken != address(0), 'WooPP: baseToken_ZERO_ADDR');
        require(to != address(0), 'WooPP: to_ZERO_ADDR');
        require(baseToken != quoteToken, 'WooPP: baseToken==quoteToken');
        wooGuardian.checkInputAmount(baseToken, baseAmount);

        address from = msg.sender;
        TokenInfo memory baseInfo = tokenInfo[baseToken];
        require(baseInfo.isValid, 'WooPP: TOKEN_DOES_NOT_EXIST');
        TokenInfo memory quoteInfo = tokenInfo[quoteToken];
        _autoUpdate(baseToken, baseInfo, quoteInfo);

        TransferHelper.safeTransferFrom(baseToken, from, address(this), baseAmount);

        quoteAmount = getQuoteAmountSellBase(baseToken, baseAmount, baseInfo, quoteInfo);
        wooGuardian.checkSwapAmount(baseToken, quoteToken, baseAmount, quoteAmount);

        uint256 lpFee = quoteAmount.mulCeil(feeManager.feeRate(baseToken));
        quoteAmount = quoteAmount.sub(lpFee);
        require(quoteAmount >= minQuoteAmount, 'WooPP: quoteAmount<minQuoteAmount');

        TransferHelper.safeApprove(quoteToken, address(feeManager), lpFee);
        feeManager.collectFee(lpFee, rebateTo);

        uint256 balanceBefore = IERC20(quoteToken).balanceOf(to);
        TransferHelper.safeTransfer(quoteToken, to, quoteAmount);
        require(IERC20(quoteToken).balanceOf(to).sub(balanceBefore) >= minQuoteAmount, 'WooPP: INSUFF_OUTPUT_AMOUNT');

        _updateReserve(baseToken, baseInfo, quoteInfo);

        tokenInfo[baseToken] = baseInfo;
        tokenInfo[quoteToken] = quoteInfo;

        emit WooSwap(baseToken, quoteToken, baseAmount, quoteAmount, from, to, rebateTo);
    }

    /// @inheritdoc IWooPP
    function sellQuote(
        address baseToken,
        uint256 quoteAmount,
        uint256 minBaseAmount,
        address to,
        address rebateTo
    ) external override nonReentrant whenNotPaused returns (uint256 baseAmount) {
        require(baseToken != address(0), 'WooPP: baseToken_ZERO_ADDR');
        require(to != address(0), 'WooPP: to_ZERO_ADDR');
        require(baseToken != quoteToken, 'WooPP: baseToken==quoteToken');
        wooGuardian.checkInputAmount(quoteToken, quoteAmount);

        address from = msg.sender;
        TokenInfo memory baseInfo = tokenInfo[baseToken];
        require(baseInfo.isValid, 'WooPP: TOKEN_DOES_NOT_EXIST');
        TokenInfo memory quoteInfo = tokenInfo[quoteToken];
        _autoUpdate(baseToken, baseInfo, quoteInfo);

        TransferHelper.safeTransferFrom(quoteToken, from, address(this), quoteAmount);

        uint256 lpFee = quoteAmount.mulCeil(feeManager.feeRate(baseToken));
        quoteAmount = quoteAmount.sub(lpFee);
        baseAmount = getBaseAmountSellQuote(baseToken, quoteAmount, baseInfo, quoteInfo);
        require(baseAmount >= minBaseAmount, 'WooPP: baseAmount<minBaseAmount');

        TransferHelper.safeApprove(quoteToken, address(feeManager), lpFee);
        feeManager.collectFee(lpFee, rebateTo);

        wooGuardian.checkSwapAmount(quoteToken, baseToken, quoteAmount, baseAmount);

        uint256 balanceBefore = IERC20(baseToken).balanceOf(to);
        TransferHelper.safeTransfer(baseToken, to, baseAmount);
        require(IERC20(baseToken).balanceOf(to).sub(balanceBefore) >= minBaseAmount, 'WooPP: INSUFF_OUTPUT_AMOUNT');

        _updateReserve(baseToken, baseInfo, quoteInfo);

        tokenInfo[baseToken] = baseInfo;
        tokenInfo[quoteToken] = quoteInfo;

        emit WooSwap(quoteToken, baseToken, quoteAmount.add(lpFee), baseAmount, from, to, rebateTo);
    }

    /// @dev Set the pairsInfo
    /// @param newPairsInfo the pairs info to set
    function setPairsInfo(string calldata newPairsInfo) external nonReentrant onlyStrategist {
        pairsInfo = newPairsInfo;
    }

    /// @dev Get the pool's balance of token
    /// @param token the token pool to query
    function poolSize(address token) external view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    /// @dev Set wooracle from newWooracle
    /// @param newWooracle Wooracle address
    function setWooracle(address newWooracle) external nonReentrant onlyStrategist {
        require(newWooracle != address(0), 'WooPP: newWooracle_ZERO_ADDR');
        wooracle = newWooracle;
        emit WooracleUpdated(newWooracle);
    }

    /// @dev Set wooGuardian from newWooGuardian
    /// @param newWooGuardian WooGuardian address
    function setWooGuardian(address newWooGuardian) external nonReentrant onlyStrategist {
        require(newWooGuardian != address(0), 'WooPP: newWooGuardian_ZERO_ADDR');
        wooGuardian = IWooGuardian(newWooGuardian);
        emit WooGuardianUpdated(newWooGuardian);
    }

    /// @dev Set the feeManager.
    /// @param newFeeManager the fee manager
    function setFeeManager(address newFeeManager) external nonReentrant onlyStrategist {
        require(newFeeManager != address(0), 'WooPP: newFeeManager_ZERO_ADDR');
        feeManager = IWooFeeManager(newFeeManager);
        require(feeManager.quoteToken() == quoteToken, 'WooPP: feeManager_quoteToken_INVALID');
        emit FeeManagerUpdated(newFeeManager);
    }

    /// @dev Add the base token for swap
    /// @param baseToken the base token
    /// @param threshold the balance threshold info
    /// @param R the rebalance refactor
    function addBaseToken(
        address baseToken,
        uint256 threshold,
        uint256 R
    ) external nonReentrant onlyStrategist {
        require(baseToken != address(0), 'WooPP: BASE_TOKEN_ZERO_ADDR');
        require(baseToken != quoteToken, 'WooPP: baseToken==quoteToken');
        require(threshold <= type(uint112).max, 'WooPP: THRESHOLD_OUT_OF_RANGE');
        require(R <= 1e18, 'WooPP: R_OUT_OF_RANGE');

        TokenInfo memory info = tokenInfo[baseToken];
        require(!info.isValid, 'WooPP: TOKEN_ALREADY_EXISTS');

        info.threshold = uint112(threshold);
        info.R = uint64(R);
        info.target = max(info.threshold, info.target);
        info.isValid = true;

        tokenInfo[baseToken] = info;

        emit ParametersUpdated(baseToken, threshold, R);
    }

    /// @dev Remove the base token
    /// @param baseToken the base token
    function removeBaseToken(address baseToken) external nonReentrant onlyStrategist {
        require(baseToken != address(0), 'WooPP: BASE_TOKEN_ZERO_ADDR');
        require(tokenInfo[baseToken].isValid, 'WooPP: TOKEN_DOES_NOT_EXIST');
        delete tokenInfo[baseToken];
        emit ParametersUpdated(baseToken, 0, 0);
    }

    /// @dev Tune the token params
    /// @param token the token to tune
    /// @param newThreshold the new balance threshold info
    /// @param newR the new rebalance refactor
    function tuneParameters(
        address token,
        uint256 newThreshold,
        uint256 newR
    ) external nonReentrant onlyStrategist {
        require(token != address(0), 'WooPP: token_ZERO_ADDR');
        require(newThreshold <= type(uint112).max, 'WooPP: THRESHOLD_OUT_OF_RANGE');
        require(newR <= 1e18, 'WooPP: R>1');

        TokenInfo memory info = tokenInfo[token];
        require(info.isValid, 'WooPP: TOKEN_DOES_NOT_EXIST');

        info.threshold = uint112(newThreshold);
        info.R = uint64(newR);
        info.target = max(info.threshold, info.target);

        tokenInfo[token] = info;
        emit ParametersUpdated(token, newThreshold, newR);
    }

    /* ----- Admin Functions ----- */

    /// @dev Pause the contract.
    function pause() external onlyStrategist {
        super._pause();
    }

    /// @dev Restart the contract.
    function unpause() external onlyStrategist {
        super._unpause();
    }

    /// @dev Update the strategist info.
    /// @param strategist the strategist to set
    /// @param flag true or false
    function setStrategist(address strategist, bool flag) external nonReentrant onlyStrategist {
        require(strategist != address(0), 'WooPP: strategist_ZERO_ADDR');
        isStrategist[strategist] = flag;
        emit StrategistUpdated(strategist, flag);
    }

    /// @dev Withdraw the token.
    /// @param token the token to withdraw
    /// @param to the destination address
    /// @param amount the amount to withdraw
    function withdraw(
        address token,
        address to,
        uint256 amount
    ) public nonReentrant onlyOwner {
        require(token != address(0), 'WooPP: token_ZERO_ADDR');
        require(to != address(0), 'WooPP: to_ZERO_ADDR');
        TransferHelper.safeTransfer(token, to, amount);
        emit Withdraw(token, to, amount);
    }

    function withdrawAll(address token, address to) external onlyOwner {
        withdraw(token, to, IERC20(token).balanceOf(address(this)));
    }

    /// @dev Withdraw the token to the OWNER address
    /// @param token the token
    function withdrawAllToOwner(address token) external nonReentrant onlyStrategist {
        require(token != address(0), 'WooPP: token_ZERO_ADDR');
        uint256 amount = IERC20(token).balanceOf(address(this));
        TransferHelper.safeTransfer(token, _OWNER_, amount);
        emit Withdraw(token, _OWNER_, amount);
    }

    /* ----- Private Functions ----- */

    function _autoUpdate(
        address baseToken,
        TokenInfo memory baseInfo,
        TokenInfo memory quoteInfo
    ) private view {
        require(baseToken != address(0), 'WooPP: BASETOKEN_ZERO_ADDR');
        _updateReserve(baseToken, baseInfo, quoteInfo);

        // NOTE: only consider the least 32 bigs integer number is good engouh
        uint32 priceTimestamp = uint32(IWooracle(wooracle).timestamp());
        if (priceTimestamp != baseInfo.lastResetTimestamp) {
            baseInfo.target = max(baseInfo.threshold, baseInfo.reserve);
            baseInfo.lastResetTimestamp = priceTimestamp;
        }
        if (priceTimestamp != quoteInfo.lastResetTimestamp) {
            quoteInfo.target = max(quoteInfo.threshold, quoteInfo.reserve);
            quoteInfo.lastResetTimestamp = priceTimestamp;
        }
    }

    function _updateReserve(
        address baseToken,
        TokenInfo memory baseInfo,
        TokenInfo memory quoteInfo
    ) private view {
        uint256 baseReserve = IERC20(baseToken).balanceOf(address(this));
        uint256 quoteReserve = IERC20(quoteToken).balanceOf(address(this));
        require(baseReserve <= type(uint112).max);
        require(quoteReserve <= type(uint112).max);
        baseInfo.reserve = uint112(baseReserve);
        quoteInfo.reserve = uint112(quoteReserve);
    }

    // When baseSold >= 0 , users sold the base token
    function getQuoteAmountLowQuoteSide(
        uint256 p,
        uint256 k,
        uint256 r,
        uint256 baseAmount
    ) private pure returns (uint256) {
        // priceFactor = 1 + k * baseAmount * p * r;
        uint256 priceFactor = DecimalMath.ONE.add(k.mulCeil(baseAmount).mulCeil(p).mulCeil(r));
        // return baseAmount * p / priceFactor;
        return baseAmount.mulFloor(p).divFloor(priceFactor); // round down
    }

    // When baseSold >= 0
    function getBaseAmountLowQuoteSide(
        uint256 p,
        uint256 k,
        uint256 r,
        uint256 quoteAmount
    ) private pure returns (uint256) {
        // priceFactor = (1 - k * quoteAmount * r);
        uint256 priceFactor = DecimalMath.ONE.sub(k.mulFloor(quoteAmount).mulFloor(r));
        // return quoteAmount / p / priceFactor;
        return quoteAmount.divFloor(p).divFloor(priceFactor);
    }

    // When quoteSold >= 0
    function getBaseAmountLowBaseSide(
        uint256 p,
        uint256 k,
        uint256 r,
        uint256 quoteAmount
    ) private pure returns (uint256) {
        // priceFactor = 1 + k * quoteAmount * r;
        uint256 priceFactor = DecimalMath.ONE.add(k.mulCeil(quoteAmount).mulCeil(r));
        // return quoteAmount / p / priceFactor;
        return quoteAmount.divFloor(p).divFloor(priceFactor); // round down
    }

    // When quoteSold >= 0
    function getQuoteAmountLowBaseSide(
        uint256 p,
        uint256 k,
        uint256 r,
        uint256 baseAmount
    ) private pure returns (uint256) {
        // priceFactor = 1 - k * baseAmount * p * r;
        uint256 priceFactor = DecimalMath.ONE.sub(k.mulFloor(baseAmount).mulFloor(p).mulFloor(r));
        // return baseAmount * p / priceFactor;
        return baseAmount.mulFloor(p).divFloor(priceFactor); // round down
    }

    function getBoughtAmount(
        TokenInfo memory baseInfo,
        TokenInfo memory quoteInfo,
        uint256 p,
        uint256 k,
        bool isSellBase
    ) private pure returns (uint256 baseBought, uint256 quoteBought) {
        uint256 baseSold = 0;
        if (baseInfo.reserve < baseInfo.target) {
            baseBought = uint256(baseInfo.target).sub(uint256(baseInfo.reserve));
        } else {
            baseSold = uint256(baseInfo.reserve).sub(uint256(baseInfo.target));
        }
        uint256 quoteSold = 0;
        if (quoteInfo.reserve < quoteInfo.target) {
            quoteBought = uint256(quoteInfo.target).sub(uint256(quoteInfo.reserve));
        } else {
            quoteSold = uint256(quoteInfo.reserve).sub(uint256(quoteInfo.target));
        }

        if (baseSold.mulCeil(p) > quoteSold) {
            baseSold = baseSold.sub(quoteSold.divFloor(p));
            quoteSold = 0;
        } else {
            quoteSold = quoteSold.sub(baseSold.mulCeil(p));
            baseSold = 0;
        }

        uint256 virtualBaseBought = getBaseAmountLowBaseSide(p, k, DecimalMath.ONE, quoteSold);
        if (isSellBase == (virtualBaseBought < baseBought)) {
            baseBought = virtualBaseBought;
        }
        uint256 virtualQuoteBought = getQuoteAmountLowQuoteSide(p, k, DecimalMath.ONE, baseSold);
        if (isSellBase == (virtualQuoteBought > quoteBought)) {
            quoteBought = virtualQuoteBought;
        }
    }

    function getQuoteAmountSellBase(
        address baseToken,
        uint256 baseAmount,
        TokenInfo memory baseInfo,
        TokenInfo memory quoteInfo
    ) private view returns (uint256 quoteAmount) {
        uint256 p;
        uint256 s;
        uint256 k;
        bool isFeasible;
        (p, s, k, isFeasible) = IWooracle(wooracle).state(baseToken);
        require(isFeasible, 'WooPP: ORACLE_PRICE_NOT_FEASIBLE');

        wooGuardian.checkSwapPrice(p, baseToken, quoteToken);

        // price: p * (1 - s / 2)
        p = p.mulFloor(DecimalMath.ONE.sub(s.divCeil(DecimalMath.TWO)));

        uint256 baseBought;
        uint256 quoteBought;
        (baseBought, quoteBought) = getBoughtAmount(baseInfo, quoteInfo, p, k, true);

        if (baseBought > 0) {
            uint256 quoteSold = getQuoteAmountLowBaseSide(p, k, baseInfo.R, baseBought);
            if (baseAmount > baseBought) {
                uint256 newBaseSold = baseAmount.sub(baseBought);
                quoteAmount = quoteSold.add(getQuoteAmountLowQuoteSide(p, k, DecimalMath.ONE, newBaseSold));
            } else {
                uint256 newBaseBought = baseBought.sub(baseAmount);
                quoteAmount = quoteSold.sub(getQuoteAmountLowBaseSide(p, k, baseInfo.R, newBaseBought));
            }
        } else {
            uint256 baseSold = getBaseAmountLowQuoteSide(p, k, DecimalMath.ONE, quoteBought);
            uint256 newBaseSold = baseAmount.add(baseSold);
            uint256 newQuoteBought = getQuoteAmountLowQuoteSide(p, k, DecimalMath.ONE, newBaseSold);
            quoteAmount = newQuoteBought > quoteBought ? newQuoteBought.sub(quoteBought) : 0;
        }
    }

    function getBaseAmountSellQuote(
        address baseToken,
        uint256 quoteAmount,
        TokenInfo memory baseInfo,
        TokenInfo memory quoteInfo
    ) private view returns (uint256 baseAmount) {
        uint256 p;
        uint256 s;
        uint256 k;
        bool isFeasible;
        (p, s, k, isFeasible) = IWooracle(wooracle).state(baseToken);
        require(isFeasible, 'WooPP: ORACLE_PRICE_NOT_FEASIBLE');

        wooGuardian.checkSwapPrice(p, baseToken, quoteToken);

        // price: p * (1 + s / 2)
        p = p.mulCeil(DecimalMath.ONE.add(s.divCeil(DecimalMath.TWO)));

        uint256 baseBought;
        uint256 quoteBought;
        (baseBought, quoteBought) = getBoughtAmount(baseInfo, quoteInfo, p, k, false);

        if (quoteBought > 0) {
            uint256 baseSold = getBaseAmountLowQuoteSide(p, k, baseInfo.R, quoteBought);
            if (quoteAmount > quoteBought) {
                uint256 newQuoteSold = quoteAmount.sub(quoteBought);
                baseAmount = baseSold.add(getBaseAmountLowBaseSide(p, k, DecimalMath.ONE, newQuoteSold));
            } else {
                uint256 newQuoteBought = quoteBought.sub(quoteAmount);
                baseAmount = baseSold.sub(getBaseAmountLowQuoteSide(p, k, baseInfo.R, newQuoteBought));
            }
        } else {
            uint256 quoteSold = getQuoteAmountLowBaseSide(p, k, DecimalMath.ONE, baseBought);
            uint256 newQuoteSold = quoteAmount.add(quoteSold);
            uint256 newBaseBought = getBaseAmountLowBaseSide(p, k, DecimalMath.ONE, newQuoteSold);
            baseAmount = newBaseBought > baseBought ? newBaseBought.sub(baseBought) : 0;
        }
    }

    function max(uint112 a, uint112 b) private pure returns (uint112) {
        return a >= b ? a : b;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/// @title Contract to collect transaction fee of Woo private pool.
interface IWooFeeManager {
    /* ----- Events ----- */

    event FeeRateUpdated(address indexed token, uint256 newFeeRate);
    event Withdraw(address indexed token, address indexed to, uint256 amount);

    /* ----- External Functions ----- */

    /// @dev fee rate for the given base token:
    /// NOTE: fee rate decimal 18: 1e16 = 1%, 1e15 = 0.1%, 1e14 = 0.01%
    /// @param token the base token
    /// @return the fee rate
    function feeRate(address token) external view returns (uint256);

    /// @dev Sets the fee rate for the given token
    /// @param token the base token
    /// @param newFeeRate the new fee rate
    function setFeeRate(address token, uint256 newFeeRate) external;

    /// @dev Collects the swap fee to the given brokder address.
    /// @param amount the swap fee amount
    /// @param brokerAddr the broker address to rebate to
    function collectFee(uint256 amount, address brokerAddr) external;

    /// @dev get the quote token address
    /// @return address of quote token
    function quoteToken() external view returns (address);

    /// @dev Collects the fee and distribute to rebate and vault managers.
    function distributeFees() external;
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import './libraries/InitializableOwnable.sol';
import './libraries/DecimalMath.sol';
import './interfaces/IWooPP.sol';
import './interfaces/IWooRebateManager.sol';
import './interfaces/IWooFeeManager.sol';
import './interfaces/IWooVaultManager.sol';
import './interfaces/IWooAccessManager.sol';

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

/// @title Contract to collect transaction fee of Woo private pool.
contract WooFeeManager is InitializableOwnable, ReentrancyGuard, IWooFeeManager {
    /* ----- Type declarations ----- */

    using SafeMath for uint256;
    using DecimalMath for uint256;
    using SafeERC20 for IERC20;

    /* ----- State variables ----- */

    mapping(address => uint256) public override feeRate; // decimal: 18; 1e16 = 1%, 1e15 = 0.1%, 1e14 = 0.01%
    uint256 public vaultRewardRate; // decimal: 18; 1e16 = 1%, 1e15 = 0.1%, 1e14 = 0.01%

    uint256 public rebateAmount;

    address public immutable override quoteToken;
    IWooRebateManager public rebateManager;
    IWooVaultManager public vaultManager;
    IWooAccessManager public accessManager;

    address public treasury;

    /* ----- Modifiers ----- */

    modifier onlyAdmin() {
        require(msg.sender == _OWNER_ || accessManager.isFeeAdmin(msg.sender), 'WooFeeManager: NOT_ADMIN');
        _;
    }

    constructor(
        address newQuoteToken,
        address newRebateManager,
        address newVaultManager,
        address newAccessManager,
        address newTreasury
    ) public {
        require(newQuoteToken != address(0), 'WooFeeManager: quoteToken_ZERO_ADDR');
        initOwner(msg.sender);
        quoteToken = newQuoteToken;
        rebateManager = IWooRebateManager(newRebateManager);
        vaultManager = IWooVaultManager(newVaultManager);
        vaultRewardRate = 1e18;
        accessManager = IWooAccessManager(newAccessManager);
        treasury = newTreasury;
    }

    /* ----- Public Functions ----- */

    function collectFee(uint256 amount, address brokerAddr) external override nonReentrant {
        TransferHelper.safeTransferFrom(quoteToken, msg.sender, address(this), amount);
        uint256 rebateRate = rebateManager.rebateRate(brokerAddr);
        if (rebateRate > 0) {
            uint256 curRebateAmount = amount.mulFloor(rebateRate);
            rebateManager.addRebate(brokerAddr, curRebateAmount);
            rebateAmount = rebateAmount.add(curRebateAmount);
        }
    }

    /* ----- Admin Functions ----- */

    function distributeFees() external override nonReentrant onlyAdmin {
        uint256 balance = IERC20(quoteToken).balanceOf(address(this));
        require(balance > 0, 'WooFeeManager: balance_ZERO');

        // Step 1: distribute the rebate balance
        if (rebateAmount > 0) {
            TransferHelper.safeApprove(quoteToken, address(rebateManager), rebateAmount);
            TransferHelper.safeTransfer(quoteToken, address(rebateManager), rebateAmount);

            balance = balance.sub(rebateAmount);
            rebateAmount = 0;
        }

        // Step 2: distribute the vault balance
        uint256 vaultAmount = balance.mulFloor(vaultRewardRate);
        if (vaultAmount > 0) {
            TransferHelper.safeApprove(quoteToken, address(vaultManager), vaultAmount);
            TransferHelper.safeTransfer(quoteToken, address(vaultManager), vaultAmount);
            balance = balance.sub(vaultAmount);
        }

        // Step 3: balance left for treasury
        if (balance > 0) {
            TransferHelper.safeApprove(quoteToken, treasury, balance);
            TransferHelper.safeTransfer(quoteToken, treasury, balance);
        }
    }

    function setFeeRate(address token, uint256 newFeeRate) external override onlyAdmin {
        require(newFeeRate <= 1e16, 'WooFeeManager: FEE_RATE>1%');
        feeRate[token] = newFeeRate;
        emit FeeRateUpdated(token, newFeeRate);
    }

    function setRebateManager(address newRebateManager) external onlyAdmin {
        require(newRebateManager != address(0), 'WooFeeManager: rebateManager_ZERO_ADDR');
        rebateManager = IWooRebateManager(newRebateManager);
    }

    function setVaultManager(address newVaultManager) external onlyAdmin {
        require(newVaultManager != address(0), 'WooFeeManager: newVaultManager_ZERO_ADDR');
        vaultManager = IWooVaultManager(newVaultManager);
    }

    function setVaultRewardRate(uint256 newVaultRewardRate) external onlyAdmin {
        require(newVaultRewardRate <= 1e18, 'WooFeeManager: vaultRewardRate_INVALID');
        vaultRewardRate = newVaultRewardRate;
    }

    function setAccessManager(address newAccessManager) external onlyOwner {
        require(newAccessManager != address(0), 'WooFeeManager: newAccessManager_ZERO_ADDR');
        accessManager = IWooAccessManager(newAccessManager);
    }

    function setTreasury(address newTreasury) external onlyOwner {
        require(newTreasury != address(0), 'WooFeeManager: newTreasury_ZERO_ADDR');
        treasury = newTreasury;
    }

    function emergencyWithdraw(address token, address to) external onlyOwner {
        require(token != address(0), 'WooFeeManager: token_ZERO_ADDR');
        require(to != address(0), 'WooFeeManager: to_ZERO_ADDR');
        uint256 amount = IERC20(token).balanceOf(address(this));
        TransferHelper.safeTransfer(token, to, amount);
        emit Withdraw(token, to, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;


import './interfaces/IWooPP.sol';
import './interfaces/IWETH.sol';
import './interfaces/IWooRouter.sol';

import './interfaces/Stargate/IStargateRouter.sol';
import './interfaces/Stargate/IStargateReceiver.sol';

import './libraries/InitializableOwnable.sol';

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

/// @title Woo Router implementation.
/// @notice Router for stateless execution of swaps against Woo private pool.
contract WooCrossChainRouter is IStargateReceiver, InitializableOwnable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // TODO:
    event SendFromSource(address token, uint qty);
    event ReceivedOnDestination(address token, uint qty);

    address constant ETH_PLACEHOLDER_ADDR = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    IWooPP public wooPool;
    address public quoteToken;
    address public WETH;
    IStargateRouter public stargateRouter;

    mapping(uint16 => address) public wooCrossRouters; // dstChainId => woo router
    mapping(uint16 => address) public stargateRouters; // dstChainId => stargate router
    // mapping(uint16 => mapping(address => uint256)) public poolIds; // (dstChainId, token) => poolId

    receive() payable external {}

    constructor() public {
        initOwner(msg.sender);
    }

    /*
    https://stargateprotocol.gitbook.io/stargate/developers/contract-addresses/mainnet
    - Chain ID : Chain -
    1: Ether
    2: BSC (BNB Chain)
    6: Avalanche
    9: Polygon
    10: Arbitrum
    11: Optimism
    12: Fantom
    */
    function setWooCrossChainRouter(uint16 chainId, address wooCrossRouter) external onlyOwner {
        require(wooCrossRouter != address(0), 'WooCrossChainRouter: !wooCrossRouter');
        wooCrossRouters[chainId] = wooCrossRouter;
    }

    function setStargateRouters(uint16 chainId, address stargateRouter) external onlyOwner {
        require(stargateRouter != address(0), 'WooCrossChainRouter: !stargateRouter');
        stargateRouters[chainId] = stargateRouter;
    }

    // function setPoolId(uint16 chainId, address token, uint256 poolId) external onlyOwner {
    //     require(token != address(0), 'WooCrossChainRouter: !token');
    //     poolIds[chainId][token] = poolId;
    // }

    function init(
        address _weth,
        address _wooPool,
        address _stargateRouter
    ) external onlyOwner {
        WETH = _weth;
        wooPool = IWooPP(_wooPool);
        quoteToken = wooPool.quoteToken();
        stargateRouter = IStargateRouter(_stargateRouter);
    }

    function localSwapAndBridge(
        address fromToken,
        uint256 fromAmount,
        address toToken,
        uint256 minToAmount,
        uint16  dstChainID,
        uint256 srcPoolID,
        uint256 dstPoolID,
        address payable to) public payable {

        require(fromToken != address(0), 'WooCrossChainRouter: !fromToken');
        require(toToken != address(0), 'WooCrossChainRouter: !toToken');
        require(to != address(0), 'WooCrossChainRouter: !to');

        bool isFromETH = fromToken == ETH_PLACEHOLDER_ADDR;
        bool isToETH = toToken == ETH_PLACEHOLDER_ADDR;
        fromToken = isFromETH ? WETH : fromToken;
        toToken = isToETH ? WETH : toToken;
        uint256 gasValue = msg.value;

        // Step 1: transfer
        if (isFromETH) {
            require(fromAmount <= msg.value, 'WooCrossChainRouter: !fromAmount');
            IWETH(WETH).deposit{value: fromAmount}();
            gasValue -= fromAmount;
        } else {
            TransferHelper.safeTransferFrom(fromToken, msg.sender, address(this), fromAmount);
        }

        // Step 2: local transfer
        uint256 bridgeAmount;
        {
            if (fromToken != quoteToken) {
                TransferHelper.safeApprove(fromToken, address(wooPool), fromAmount);
                bridgeAmount = wooPool.sellBase(
                    fromToken,
                    fromAmount,
                    minToAmount,
                    address(this),  // to address
                    address(0)      // rebateTo address
                );
            } else {
                bridgeAmount = fromAmount;
            }
        }

        // Step 3: send to stargate
        require(bridgeAmount <= IERC20(quoteToken).balanceOf(address(this)), '!bridgeAmount');
        TransferHelper.safeApprove(quoteToken, address(stargateRouter), bridgeAmount);

        bytes memory toAddr;
        {
            toAddr = abi.encodePacked(to);
        }

        uint256 minToAmountMem = minToAmount;

        IStargateRouter.lzTxObj memory txObj;
        {
            txObj = IStargateRouter.lzTxObj(0, 0, "0x");
        }


        // Step 4: just bridge via stargate router on both chains
        IStargateRouter(stargateRouter).swap{value: gasValue}(
            dstChainID,
            srcPoolID,
            dstPoolID,
            payable(msg.sender),
            bridgeAmount,
            minToAmountMem,
            txObj,
            toAddr,
            bytes("")
        );
    }


    function crossSwap(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minToAmount,
        uint16  dstChainID,
        uint256 srcPoolID,
        uint256 dstPoolID,
        address payable to) public payable {

        require(fromToken != address(0), 'WooCrossChainRouter: !fromToken');
        require(toToken != address(0), 'WooCrossChainRouter: !toToken');
        require(to != address(0), 'WooCrossChainRouter: !to');

        bool isFromETH = fromToken == ETH_PLACEHOLDER_ADDR;
        bool isToETH = toToken == ETH_PLACEHOLDER_ADDR;
        fromToken = isFromETH ? WETH : fromToken;
        toToken = isToETH ? WETH : toToken;
        address rebateTo = address(0);
        uint256 gasValue = msg.value;

        // Step 1: transfer
        if (isFromETH) {
            require(fromAmount <= msg.value, 'WooCrossChainRouter: !fromAmount');
            IWETH(WETH).deposit{value: fromAmount}();
            gasValue -= fromAmount;
        } else {
            TransferHelper.safeTransferFrom(fromToken, msg.sender, address(this), fromAmount);
        }

        // Step 2: local transfer
        uint256 bridgeAmount;
        if (fromToken != quoteToken) {
            TransferHelper.safeApprove(fromToken, address(wooPool), fromAmount);
            bridgeAmount = wooPool.sellBase(fromToken, fromAmount, minToAmount, to, rebateTo);
        } else {
            bridgeAmount = fromAmount;
        }

        // Step 3: send to stargate
        require(bridgeAmount <= IERC20(quoteToken).balanceOf(address(this)), '!bridgeAmount');
        TransferHelper.safeApprove(quoteToken, address(stargateRouter), bridgeAmount);

        bytes memory payloadData;
        {
            payloadData = abi.encode(
                toToken,        // to token
                now.add(600),   // deadline for tx
                minToAmount,    // minToAmount on destination chain
                to              // to address
            );
        }

        bytes memory dstWooCrossRouter;
        {
            dstWooCrossRouter = abi.encodePacked(wooCrossRouters[dstChainID]);
        }

        IStargateRouter(stargateRouter).swap{value: gasValue}(
            dstChainID,
            srcPoolID,
            dstPoolID,
            payable(msg.sender),
            bridgeAmount,
            bridgeAmount.mul(999).div(1000),
            IStargateRouter.lzTxObj(
                500000, // TODO: how come this gas limit ?
                0,
                "0x"
            ),
            dstWooCrossRouter,
            payloadData
        );
    }

    function sgReceive(
        uint16 _chainId,
        bytes memory _srcAddress,
        uint _nonce,
        address _token,
        uint amountLD,
        bytes memory payload
    ) override external {
        require(msg.sender == address(stargateRouter), "only stargate router can call sgReceive!");

        (
            address toToken,
            uint deadline,
            uint minToAmount,
            address to
        ) = abi.decode(payload, (address, uint, uint, address));

        require(to != address(0), 'WooRouter: to_ZERO_ADDR');
        TransferHelper.safeApprove(_token, address(wooPool), amountLD);

        require(wooPool.quoteToken() == _token, '_token_INVALID');
        uint256 quoteAmount = amountLD;

        if (toToken == ETH_PLACEHOLDER_ADDR) {
            // swap to native token
            try wooPool.sellQuote(
                    toToken, quoteAmount, minToAmount, address(this), address(0)
                ) returns (uint realToAmount) {
                IWETH(WETH).withdraw(realToAmount);
                TransferHelper.safeTransferETH(to, realToAmount);
                emit ReceivedOnDestination(toToken, amountLD);
            } catch {
                // transfer _token/amountLD to msg.sender because the swap failed for some reason.
                // this is not the ideal scenario, but the contract needs to deliver them eth or USDC.
                TransferHelper.safeTransfer(_token, to, amountLD);
                emit ReceivedOnDestination(_token, amountLD);
            }
        } else {
            if (_token == toToken) {
                TransferHelper.safeTransfer(toToken, to, amountLD);
                emit ReceivedOnDestination(toToken, amountLD);
            } else {
                // swap the ERC20 token
                try wooPool.sellQuote(
                        toToken, quoteAmount, minToAmount, to, address(0)
                    ) returns (uint realToAmount) {
                    emit ReceivedOnDestination(toToken, realToAmount);
                } catch {
                    TransferHelper.safeTransfer(_token, to, amountLD);
                    emit ReceivedOnDestination(_token, amountLD);
                }
            }

        }
    }

    /// @dev Rescue the specified funds when stuck happen
    /// @param token token address
    /// @param amount amount of token to rescue
    function rescueFunds(address token, uint256 amount) external nonReentrant onlyOwner {
        require(token != address(0), 'WooRouter: token_ADDR_ZERO');
        TransferHelper.safeTransfer(token, msg.sender, amount);
    }

    /// @dev Rescue the native token funds when stuck happen
    function rescueNativeFunds() external nonReentrant onlyOwner {
        TransferHelper.safeTransferETH(msg.sender, address(this).balance);
    }

    function _generalTransfer(
        address token,
        address payable to,
        uint256 amount
    ) private {
        if (amount > 0) {
            if (token == ETH_PLACEHOLDER_ADDR) {
                TransferHelper.safeTransferETH(to, amount);
            } else {
                TransferHelper.safeTransfer(token, to, amount);
            }
        }
    }

    function _generalBalanceOf(address token, address who) private view returns (uint256) {
        return token == ETH_PLACEHOLDER_ADDR ? who.balance : IERC20(token).balanceOf(who);
    }

}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

interface IStargateRouter {
    struct lzTxObj {
        uint256 dstGasForCall;
        uint256 dstNativeAmount;
        bytes dstNativeAddr;
    }

    function addLiquidity(
        uint256 _poolId,
        uint256 _amountLD,
        address _to
    ) external;

    function swap(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLD,
        uint256 _minAmountLD,
        lzTxObj memory _lzTxParams,
        bytes calldata _to,
        bytes calldata _payload
    ) external payable;

    function redeemRemote(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLP,
        uint256 _minAmountLD,
        bytes calldata _to,
        lzTxObj memory _lzTxParams
    ) external payable;

    function instantRedeemLocal(
        uint16 _srcPoolId,
        uint256 _amountLP,
        address _to
    ) external returns (uint256);

    function redeemLocal(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLP,
        bytes calldata _to,
        lzTxObj memory _lzTxParams
    ) external payable;

    function sendCredits(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress
    ) external payable;

    function quoteLayerZeroFee(
        uint16 _dstChainId,
        uint8 _functionType,
        bytes calldata _toAddress,
        bytes calldata _transferAndCallPayload,
        lzTxObj memory _lzTxParams
    ) external view returns (uint256, uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;


interface IStargateReceiver {
    function sgReceive(
        uint16 _chainId,
        bytes memory _srcAddress,
        uint256 _nonce,
        address _token,
        uint256 amountLD,
        bytes memory payload
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import './interfaces/IWooAccessManager.sol';

contract WooAccessManager is IWooAccessManager, Ownable, Pausable {
    /* ----- State variables ----- */

    mapping(address => bool) public override isFeeAdmin;
    mapping(address => bool) public override isVaultAdmin;
    mapping(address => bool) public override isRebateAdmin;
    mapping(address => bool) public override isZeroFeeVault;

    /* ----- Admin Functions ----- */

    /// @inheritdoc IWooAccessManager
    function setFeeAdmin(address feeAdmin, bool flag) external override onlyOwner whenNotPaused {
        require(feeAdmin != address(0), 'WooAccessManager: feeAdmin_ZERO_ADDR');
        isFeeAdmin[feeAdmin] = flag;
        emit FeeAdminUpdated(feeAdmin, flag);
    }

    /// @inheritdoc IWooAccessManager
    function batchSetFeeAdmin(address[] calldata feeAdmins, bool[] calldata flags)
        external
        override
        onlyOwner
        whenNotPaused
    {
        require(feeAdmins.length == flags.length, 'WooAccessManager: length_INVALID');

        for (uint256 i = 0; i < feeAdmins.length; i++) {
            require(feeAdmins[i] != address(0), 'WooAccessManager: feeAdmin_ZERO_ADDR');
            isFeeAdmin[feeAdmins[i]] = flags[i];
            emit FeeAdminUpdated(feeAdmins[i], flags[i]);
        }
    }

    /// @inheritdoc IWooAccessManager
    function setVaultAdmin(address vaultAdmin, bool flag) external override onlyOwner whenNotPaused {
        require(vaultAdmin != address(0), 'WooAccessManager: vaultAdmin_ZERO_ADDR');
        isVaultAdmin[vaultAdmin] = flag;
        emit VaultAdminUpdated(vaultAdmin, flag);
    }

    /// @inheritdoc IWooAccessManager
    function batchSetVaultAdmin(address[] calldata vaultAdmins, bool[] calldata flags)
        external
        override
        onlyOwner
        whenNotPaused
    {
        require(vaultAdmins.length == flags.length, 'WooAccessManager: length_INVALID');

        for (uint256 i = 0; i < vaultAdmins.length; i++) {
            require(vaultAdmins[i] != address(0), 'WooAccessManager: vaultAdmin_ZERO_ADDR');
            isVaultAdmin[vaultAdmins[i]] = flags[i];
            emit VaultAdminUpdated(vaultAdmins[i], flags[i]);
        }
    }

    /// @inheritdoc IWooAccessManager
    function setRebateAdmin(address rebateAdmin, bool flag) external override onlyOwner whenNotPaused {
        require(rebateAdmin != address(0), 'WooAccessManager: rebateAdmin_ZERO_ADDR');
        isRebateAdmin[rebateAdmin] = flag;
        emit RebateAdminUpdated(rebateAdmin, flag);
    }

    /// @inheritdoc IWooAccessManager
    function batchSetRebateAdmin(address[] calldata rebateAdmins, bool[] calldata flags)
        external
        override
        onlyOwner
        whenNotPaused
    {
        require(rebateAdmins.length == flags.length, 'WooAccessManager: length_INVALID');

        for (uint256 i = 0; i < rebateAdmins.length; i++) {
            require(rebateAdmins[i] != address(0), 'WooAccessManager: rebateAdmin_ZERO_ADDR');
            isRebateAdmin[rebateAdmins[i]] = flags[i];
            emit RebateAdminUpdated(rebateAdmins[i], flags[i]);
        }
    }

    /// @inheritdoc IWooAccessManager
    function setZeroFeeVault(address vault, bool flag) external override onlyOwner whenNotPaused {
        require(vault != address(0), 'WooAccessManager: vault_ZERO_ADDR');
        isZeroFeeVault[vault] = flag;
        emit ZeroFeeVaultUpdated(vault, flag);
    }

    /// @inheritdoc IWooAccessManager
    function batchSetZeroFeeVault(address[] calldata vaults, bool[] calldata flags)
        external
        override
        onlyOwner
        whenNotPaused
    {
        require(vaults.length == flags.length, 'WooAccessManager: length_INVALID');

        for (uint256 i = 0; i < vaults.length; i++) {
            require(vaults[i] != address(0), 'WooAccessManager: vault_ZERO_ADDR');
            isZeroFeeVault[vaults[i]] = flags[i];
            emit ZeroFeeVaultUpdated(vaults[i], flags[i]);
        }
    }

    /// @notice Pause the contract.
    function pause() external onlyOwner {
        super._pause();
    }

    /// @notice Restart the contract.
    function unpause() external onlyOwner {
        super._unpause();
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.6.12;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract TestToken is ERC20('TestToken', 'TT'), Ownable {
    using SafeMath for uint256;

    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

import '../interfaces/IStrategy.sol';
import '../interfaces/IWETH.sol';
import '../interfaces/IWooAccessManager.sol';
import '../interfaces/IVaultV2.sol';

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
contract WOOFiVaultV2 is IVaultV2, ERC20, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct StratCandidate {
        address implementation;
        uint256 proposedTime;
    }

    /* ----- State Variables ----- */

    address public immutable override want;

    IWooAccessManager public immutable accessManager;

    IStrategy public strategy;
    StratCandidate public stratCandidate;

    uint256 public approvalDelay = 48 hours;

    mapping(address => uint256) public costSharePrice;

    event NewStratCandidate(address indexed implementation);
    event UpgradeStrat(address indexed implementation);

    /* ----- Constant Variables ----- */

    // WBNB: https://bscscan.com/token/0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c
    // WAVAX: https://snowtrace.io/address/0xb31f66aa3c1e785363f0875a1b74e27b85fd66c7
    address public immutable override weth;

    constructor(
        address _weth,
        address _want,
        address _accessManager
    )
        public
        ERC20(
            string(abi.encodePacked('WOOFi Earn ', ERC20(_want).name())),
            string(abi.encodePacked('we', ERC20(_want).symbol()))
        )
    {
        require(_weth != address(0), 'WOOFiVaultV2: weth_ZERO_ADDR');
        require(_want != address(0), 'WOOFiVaultV2: want_ZERO_ADDR');
        require(_accessManager != address(0), 'WOOFiVaultV2: accessManager_ZERO_ADDR');

        weth = _weth;
        want = _want;
        accessManager = IWooAccessManager(_accessManager);
    }

    modifier onlyAdmin() {
        require(owner() == msg.sender || accessManager.isVaultAdmin(msg.sender), 'WOOFiVaultV2: NOT_ADMIN');
        _;
    }

    /* ----- External Functions ----- */

    function deposit(uint256 amount) public payable override nonReentrant {
        require(amount > 0, 'WOOFiVaultV2: amount_CAN_NOT_BE_ZERO');

        if (want == weth) {
            require(msg.value == amount, 'WOOFiVaultV2: msg.value_INSUFFICIENT');
        } else {
            require(msg.value == 0, 'WOOFiVaultV2: msg.value_INVALID');
        }

        if (address(strategy) != address(0)) {
            require(!strategy.paused(), 'WOOFiVaultV2: strat_paused');
            strategy.beforeDeposit();
        }

        uint256 balanceBefore = balance();
        if (want == weth) {
            IWETH(weth).deposit{value: msg.value}();
        } else {
            TransferHelper.safeTransferFrom(want, msg.sender, address(this), amount);
        }
        uint256 balanceAfter = balance();
        require(amount <= balanceAfter.sub(balanceBefore), 'WOOFiVaultV2: amount_NOT_ENOUGH');

        uint256 shares = totalSupply() == 0 ? amount : amount.mul(totalSupply()).div(balanceBefore);
        uint256 sharesBefore = balanceOf(msg.sender);
        uint256 costBefore = costSharePrice[msg.sender];
        uint256 costAfter = (sharesBefore.mul(costBefore).add(amount.mul(1e18))).div(sharesBefore.add(shares));
        costSharePrice[msg.sender] = costAfter;

        _mint(msg.sender, shares);

        earn();
    }

    function withdraw(uint256 shares) public override nonReentrant {
        require(shares > 0, 'WOOFiVaultV2: shares_ZERO');
        require(shares <= balanceOf(msg.sender), 'WOOFiVaultV2: shares_NOT_ENOUGH');

        if (address(strategy) != address(0)) {
            strategy.beforeWithdraw();
        }

        uint256 withdrawAmount = shares.mul(balance()).div(totalSupply());
        _burn(msg.sender, shares);

        uint256 balanceBefore = IERC20(want).balanceOf(address(this));
        if (balanceBefore < withdrawAmount) {
            uint256 balanceToWithdraw = withdrawAmount.sub(balanceBefore);
            require(_isStratActive(), 'WOOFiVaultV2: STRAT_INACTIVE');
            strategy.withdraw(balanceToWithdraw);
            uint256 balanceAfter = IERC20(want).balanceOf(address(this));
            if (withdrawAmount > balanceAfter) {
                // NOTE: in case a small amount not counted in, due to the decimal precision.
                withdrawAmount = balanceAfter;
            }
        }

        if (want == weth) {
            IWETH(weth).withdraw(withdrawAmount);
            TransferHelper.safeTransferETH(msg.sender, withdrawAmount);
        } else {
            TransferHelper.safeTransfer(want, msg.sender, withdrawAmount);
        }
    }

    function earn() public override {
        if (_isStratActive()) {
            uint256 balanceAvail = available();
            TransferHelper.safeTransfer(want, address(strategy), balanceAvail);
            strategy.deposit();
        }
    }

    function available() public view override returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    function balance() public view override returns (uint256) {
        return address(strategy) != address(0) ? available().add(strategy.balanceOf()) : available();
    }

    function getPricePerFullShare() public view override returns (uint256) {
        return totalSupply() == 0 ? 1e18 : balance().mul(1e18).div(totalSupply());
    }

    function _isStratActive() internal view returns (bool) {
        return address(strategy) != address(0) && !strategy.paused();
    }

    /* ----- Admin Functions ----- */

    function setupStrat(address _strat) public onlyAdmin {
        require(_strat != address(0), 'WOOFiVaultV2: STRAT_ZERO_ADDR');
        require(address(strategy) == address(0), 'WOOFiVaultV2: STRAT_ALREADY_SET');
        require(address(this) == IStrategy(_strat).vault(), 'WOOFiVaultV2: STRAT_VAULT_INVALID');
        require(want == IStrategy(_strat).want(), 'WOOFiVaultV2: STRAT_WANT_INVALID');
        strategy = IStrategy(_strat);

        emit UpgradeStrat(_strat);
    }

    function proposeStrat(address _implementation) public onlyAdmin {
        require(address(this) == IStrategy(_implementation).vault(), 'WOOFiVaultV2: STRAT_VAULT_INVALID');
        require(want == IStrategy(_implementation).want(), 'WOOFiVaultV2: STRAT_WANT_INVALID');
        stratCandidate = StratCandidate({implementation: _implementation, proposedTime: block.timestamp});

        emit NewStratCandidate(_implementation);
    }

    function upgradeStrat() public onlyAdmin {
        require(stratCandidate.implementation != address(0), 'WOOFiVaultV2: NO_CANDIDATE');
        require(stratCandidate.proposedTime.add(approvalDelay) < block.timestamp, 'WOOFiVaultV2: TIME_INVALID');

        emit UpgradeStrat(stratCandidate.implementation);

        strategy.retireStrat();
        strategy = IStrategy(stratCandidate.implementation);
        stratCandidate.implementation = address(0);
        stratCandidate.proposedTime = 5000000000; // 100+ years to ensure proposedTime check

        earn();
    }

    function setApprovalDelay(uint256 _approvalDelay) external onlyAdmin {
        require(_approvalDelay > 0, 'WOOFiVaultV2: approvalDelay_ZERO');
        approvalDelay = _approvalDelay;
    }

    function inCaseTokensGetStuck(address stuckToken) external onlyAdmin {
        require(stuckToken != want, 'WOOFiVaultV2: stuckToken_NOT_WANT');
        require(stuckToken != address(0), 'WOOFiVaultV2: stuckToken_ZERO_ADDR');
        uint256 amount = IERC20(stuckToken).balanceOf(address(this));
        if (amount > 0) {
            TransferHelper.safeTransfer(stuckToken, msg.sender, amount);
        }
    }

    function inCaseNativeTokensGetStuck() external onlyAdmin {
        // NOTE: vault never needs native tokens to do the yield farming;
        // This native token balance indicates a user's incorrect transfer.
        if (address(this).balance > 0) {
            TransferHelper.safeTransferETH(msg.sender, address(this).balance);
        }
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

import '../interfaces/IStrategy.sol';
import '../interfaces/IWETH.sol';
import '../interfaces/IWooAccessManager.sol';
import '../interfaces/IVault.sol';

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
contract WOOFiVaultV2Vector is IVault, ERC20, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct StratCandidate {
        address implementation;
        uint256 proposedTime;
    }

    /* ----- State Variables ----- */

    address public immutable override want;

    IWooAccessManager public immutable accessManager;

    IStrategy public strategy;
    StratCandidate public stratCandidate;

    uint256 public approvalDelay = 48 hours;
    uint256 public earnThreshold = 3000;

    mapping(address => uint256) public costSharePrice;

    event NewStratCandidate(address indexed implementation);
    event UpgradeStrat(address indexed implementation);

    /* ----- Constant Variables ----- */

    // WBNB: https://bscscan.com/token/0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c
    // WAVAX: https://snowtrace.io/address/0xb31f66aa3c1e785363f0875a1b74e27b85fd66c7
    address public immutable weth;

    constructor(
        address _weth,
        address _want,
        address _accessManager
    )
        public
        ERC20(
            string(abi.encodePacked('WOOFi Earn ', ERC20(_want).name())),
            string(abi.encodePacked('we', ERC20(_want).symbol()))
        )
    {
        require(_weth != address(0), 'WOOFiVaultV2: weth_ZERO_ADDR');
        require(_want != address(0), 'WOOFiVaultV2: want_ZERO_ADDR');
        require(_accessManager != address(0), 'WOOFiVaultV2: accessManager_ZERO_ADDR');

        weth = _weth;
        want = _want;
        accessManager = IWooAccessManager(_accessManager);
    }

    modifier onlyAdmin() {
        require(owner() == msg.sender || accessManager.isVaultAdmin(msg.sender), 'WOOFiVaultV2: NOT_ADMIN');
        _;
    }

    /* ----- External Functions ----- */

    function deposit(uint256 amount) public payable override nonReentrant {
        require(amount > 0, 'WOOFiVaultV2: amount_CAN_NOT_BE_ZERO');

        if (want == weth) {
            require(msg.value == amount, 'WOOFiVaultV2: msg.value_INSUFFICIENT');
        } else {
            require(msg.value == 0, 'WOOFiVaultV2: msg.value_INVALID');
        }

        if (address(strategy) != address(0)) {
            require(!strategy.paused(), 'WOOFiVaultV2: strat_paused');
            strategy.beforeDeposit();
        }

        uint256 balanceBefore = balance();
        if (want == weth) {
            IWETH(weth).deposit{value: msg.value}();
        } else {
            TransferHelper.safeTransferFrom(want, msg.sender, address(this), amount);
        }
        uint256 balanceAfter = balance();
        require(amount <= balanceAfter.sub(balanceBefore), 'WOOFiVaultV2: amount_NOT_ENOUGH');

        uint256 shares = totalSupply() == 0 ? amount : amount.mul(totalSupply()).div(balanceBefore);
        uint256 sharesBefore = balanceOf(msg.sender);
        uint256 costBefore = costSharePrice[msg.sender];
        uint256 costAfter = (sharesBefore.mul(costBefore).add(amount.mul(1e18))).div(sharesBefore.add(shares));
        costSharePrice[msg.sender] = costAfter;

        _mint(msg.sender, shares);

        if (amount >= earnThreshold * (10**uint256(ERC20(want).decimals()))) {
            earn();
        }
    }

    function withdraw(uint256 shares) public override nonReentrant {
        require(shares > 0, 'WOOFiVaultV2: shares_ZERO');
        require(shares <= balanceOf(msg.sender), 'WOOFiVaultV2: shares_NOT_ENOUGH');

        if (address(strategy) != address(0)) {
            strategy.beforeWithdraw();
        }

        uint256 withdrawAmount = shares.mul(balance()).div(totalSupply());
        _burn(msg.sender, shares);

        uint256 balanceBefore = IERC20(want).balanceOf(address(this));
        if (balanceBefore < withdrawAmount) {
            uint256 balanceToWithdraw = withdrawAmount.sub(balanceBefore);
            require(_isStratActive(), 'WOOFiVaultV2: STRAT_INACTIVE');
            strategy.withdraw(balanceToWithdraw);
            uint256 balanceAfter = IERC20(want).balanceOf(address(this));
            if (withdrawAmount > balanceAfter) {
                // NOTE: in case a small amount not counted in, due to the decimal precision.
                withdrawAmount = balanceAfter;
            }
        }

        if (want == weth) {
            IWETH(weth).withdraw(withdrawAmount);
            TransferHelper.safeTransferETH(msg.sender, withdrawAmount);
        } else {
            TransferHelper.safeTransfer(want, msg.sender, withdrawAmount);
        }
    }

    function earn() public override {
        if (_isStratActive()) {
            uint256 balanceAvail = available();
            TransferHelper.safeTransfer(want, address(strategy), balanceAvail);
            strategy.deposit();
        }
    }

    function available() public view override returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    function balance() public view override returns (uint256) {
        return address(strategy) != address(0) ? available().add(strategy.balanceOf()) : available();
    }

    function getPricePerFullShare() public view override returns (uint256) {
        return totalSupply() == 0 ? 1e18 : balance().mul(1e18).div(totalSupply());
    }

    function _isStratActive() internal view returns (bool) {
        return address(strategy) != address(0) && !strategy.paused();
    }

    /* ----- Admin Functions ----- */

    function setupStrat(address _strat) public onlyAdmin {
        require(_strat != address(0), 'WOOFiVaultV2: STRAT_ZERO_ADDR');
        require(address(strategy) == address(0), 'WOOFiVaultV2: STRAT_ALREADY_SET');
        require(address(this) == IStrategy(_strat).vault(), 'WOOFiVaultV2: STRAT_VAULT_INVALID');
        require(want == IStrategy(_strat).want(), 'WOOFiVaultV2: STRAT_WANT_INVALID');
        strategy = IStrategy(_strat);

        emit UpgradeStrat(_strat);
    }

    function proposeStrat(address _implementation) public onlyAdmin {
        require(address(this) == IStrategy(_implementation).vault(), 'WOOFiVaultV2: STRAT_VAULT_INVALID');
        require(want == IStrategy(_implementation).want(), 'WOOFiVaultV2: STRAT_WANT_INVALID');
        stratCandidate = StratCandidate({implementation: _implementation, proposedTime: block.timestamp});

        emit NewStratCandidate(_implementation);
    }

    function upgradeStrat() public onlyAdmin {
        require(stratCandidate.implementation != address(0), 'WOOFiVaultV2: NO_CANDIDATE');
        require(stratCandidate.proposedTime.add(approvalDelay) < block.timestamp, 'WOOFiVaultV2: TIME_INVALID');

        emit UpgradeStrat(stratCandidate.implementation);

        strategy.retireStrat();
        strategy = IStrategy(stratCandidate.implementation);
        stratCandidate.implementation = address(0);
        stratCandidate.proposedTime = 5000000000; // 100+ years to ensure proposedTime check

        earn();
    }

    function setApprovalDelay(uint256 _approvalDelay) external onlyAdmin {
        require(_approvalDelay > 0, 'WOOFiVaultV2: approvalDelay_ZERO');
        approvalDelay = _approvalDelay;
    }

    function setEarnThreshold(uint256 _earnThreshold) external onlyAdmin {
        earnThreshold = _earnThreshold;
    }

    function inCaseTokensGetStuck(address stuckToken) external onlyAdmin {
        require(stuckToken != want, 'WOOFiVaultV2: stuckToken_NOT_WANT');
        require(stuckToken != address(0), 'WOOFiVaultV2: stuckToken_ZERO_ADDR');
        uint256 amount = IERC20(stuckToken).balanceOf(address(this));
        if (amount > 0) {
            TransferHelper.safeTransfer(stuckToken, msg.sender, amount);
        }
    }

    function inCaseNativeTokensGetStuck() external onlyAdmin {
        // NOTE: vault never needs native tokens to do the yield farming;
        // This native token balance indicates a user's incorrect transfer.
        if (address(this).balance > 0) {
            TransferHelper.safeTransferETH(msg.sender, address(this).balance);
        }
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

import '../interfaces/IStrategy.sol';
import '../interfaces/IWETH.sol';
import '../interfaces/IWooAccessManager.sol';
import '../interfaces/IVault.sol';

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

contract VaultErc20 is IVault, ERC20, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct StratCandidate {
        address implementation;
        uint256 proposedTime;
    }

    /* ----- State Variables ----- */

    address public immutable override want;

    IWooAccessManager public immutable accessManager;

    IStrategy public strategy;
    StratCandidate public stratCandidate;

    uint256 public approvalDelay = 48 hours;

    mapping(address => uint256) public costSharePrice;

    event NewStratCandidate(address indexed implementation);
    event UpgradeStrat(address indexed implementation);

    constructor(address initWant, address initAccessManager)
        public
        ERC20(
            string(abi.encodePacked('WOOFi Earn ', ERC20(initWant).name())),
            string(abi.encodePacked('we', ERC20(initWant).symbol()))
        )
    {
        require(initWant != address(0), 'Vault: initWant_ZERO_ADDR');
        require(initAccessManager != address(0), 'Vault: initAccessManager_ZERO_ADDR');

        want = initWant;
        accessManager = IWooAccessManager(initAccessManager);
    }

    modifier onlyAdmin() {
        require(owner() == _msgSender() || accessManager.isVaultAdmin(msg.sender), 'Vault: NOT_ADMIN');
        _;
    }

    /* ----- External Functions ----- */

    function deposit(uint256 amount) public payable override nonReentrant {
        require(amount > 0, 'Vault: amount_CAN_NOT_BE_ZERO');

        // STEP 0: strategy's routing work before deposit.
        if (address(strategy) != address(0)) {
            require(!strategy.paused(), 'Vault: strat_paused');
            strategy.beforeDeposit();
        }

        // STEP 1: check the deposit amount
        uint256 balanceBefore = balance();
        TransferHelper.safeTransferFrom(want, msg.sender, address(this), amount);
        uint256 balanceAfter = balance();
        require(amount <= balanceAfter.sub(balanceBefore), 'Vault: amount_NOT_ENOUGH');

        // STEP 2: issues the shares and update the cost basis
        uint256 shares = totalSupply() == 0 ? amount : amount.mul(totalSupply()).div(balanceBefore);
        uint256 sharesBefore = balanceOf(msg.sender);
        uint256 costBefore = costSharePrice[msg.sender];
        uint256 costAfter = (sharesBefore.mul(costBefore).add(amount.mul(1e18))).div(sharesBefore.add(shares));
        costSharePrice[msg.sender] = costAfter;
        _mint(msg.sender, shares);

        // STEP 3
        earn();
    }

    function withdraw(uint256 shares) public override nonReentrant {
        require(shares > 0, 'Vault: shares_ZERO');
        require(shares <= balanceOf(msg.sender), 'Vault: shares_NOT_ENOUGH');

        // STEP 0: burn the user's shares to start the withdrawal process.
        uint256 withdrawAmount = shares.mul(balance()).div(totalSupply());
        _burn(msg.sender, shares);

        // STEP 1: withdraw the token from strategy if needed
        uint256 balanceBefore = IERC20(want).balanceOf(address(this));
        if (balanceBefore < withdrawAmount) {
            uint256 balanceToWithdraw = withdrawAmount.sub(balanceBefore);
            require(_isStratActive(), 'Vault: STRAT_INACTIVE');
            strategy.withdraw(balanceToWithdraw);
            uint256 balanceAfter = IERC20(want).balanceOf(address(this));
            require(balanceAfter.sub(balanceBefore) > 0, 'Vault: Strat_WITHDRAW_ERROR');
            if (withdrawAmount > balanceAfter) {
                // NOTE: Tiny diff is accepted due to the decimal precision.
                withdrawAmount = balanceAfter;
            }
        }

        // STEP 3
        TransferHelper.safeTransfer(want, msg.sender, withdrawAmount);
    }

    function earn() public override {
        if (_isStratActive()) {
            uint256 balanceAvail = available();
            if (balanceAvail > 0) {
                TransferHelper.safeTransfer(want, address(strategy), balanceAvail);
                strategy.deposit();
            }
        }
    }

    function available() public view override returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    function balance() public view override returns (uint256) {
        return address(strategy) != address(0) ? available().add(strategy.balanceOf()) : available();
    }

    function getPricePerFullShare() public view override returns (uint256) {
        return totalSupply() == 0 ? 1e18 : balance().mul(1e18).div(totalSupply());
    }

    function _isStratActive() internal view returns (bool) {
        return address(strategy) != address(0) && !strategy.paused();
    }

    /* ----- Admin Functions ----- */

    function setupStrat(address _strat) public onlyAdmin {
        require(_strat != address(0), 'Vault: STRAT_ZERO_ADDR');
        require(address(strategy) == address(0), 'Vault: STRAT_ALREADY_SET');
        require(address(this) == IStrategy(_strat).vault(), 'Vault: STRAT_VAULT_INVALID');
        require(want == IStrategy(_strat).want(), 'Vault: STRAT_WANT_INVALID');
        strategy = IStrategy(_strat);

        emit UpgradeStrat(_strat);
    }

    function proposeStrat(address _implementation) public onlyAdmin {
        require(address(this) == IStrategy(_implementation).vault(), 'Vault: STRAT_VAULT_INVALID');
        require(want == IStrategy(_implementation).want(), 'Vault: STRAT_WANT_INVALID');
        stratCandidate = StratCandidate({implementation: _implementation, proposedTime: block.timestamp});

        emit NewStratCandidate(_implementation);
    }

    function upgradeStrat() public onlyAdmin {
        require(stratCandidate.implementation != address(0), 'Vault: NO_CANDIDATE');
        require(stratCandidate.proposedTime.add(approvalDelay) < block.timestamp, 'Vault: TIME_INVALID');

        emit UpgradeStrat(stratCandidate.implementation);

        strategy.retireStrat();
        strategy = IStrategy(stratCandidate.implementation);
        stratCandidate.implementation = address(0);
        stratCandidate.proposedTime = 5000000000; // 100+ years to ensure proposedTime check

        earn();
    }

    function setApprovalDelay(uint256 newApprovalDelay) external onlyAdmin {
        require(newApprovalDelay > 0, 'Vault: newApprovalDelay_ZERO');
        approvalDelay = newApprovalDelay;
    }

    function inCaseTokensGetStuck(address stuckToken) external onlyAdmin {
        // NOTE: vault never allowed to access users' `want` token
        require(stuckToken != want, 'Vault: stuckToken_NOT_WANT');
        require(stuckToken != address(0), 'Vault: stuckToken_ZERO_ADDR');
        uint256 amount = IERC20(stuckToken).balanceOf(address(this));
        if (amount > 0) {
            TransferHelper.safeTransfer(stuckToken, msg.sender, amount);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

import '../interfaces/IStrategy.sol';
import '../interfaces/IWETH.sol';
import '../interfaces/IWooAccessManager.sol';
import '../interfaces/IVault.sol';

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
contract Vault is IVault, ERC20, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct StratCandidate {
        address implementation;
        uint256 proposedTime;
    }

    /* ----- State Variables ----- */

    address public immutable override want;

    IWooAccessManager public immutable accessManager;

    IStrategy public strategy;
    StratCandidate public stratCandidate;

    uint256 public approvalDelay = 48 hours;

    mapping(address => uint256) public costSharePrice;

    event NewStratCandidate(address indexed implementation);
    event UpgradeStrat(address indexed implementation);

    /* ----- Constant Variables ----- */

    // WBNB: https://bscscan.com/token/0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c
    address public constant wrappedEther = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    constructor(address initWant, address initAccessManager)
        public
        ERC20(
            string(abi.encodePacked('WOOFi Earn ', ERC20(initWant).name())),
            string(abi.encodePacked('we', ERC20(initWant).symbol()))
        )
    {
        require(initWant != address(0), 'Vault: initWant_ZERO_ADDR');
        require(initAccessManager != address(0), 'Vault: initAccessManager_ZERO_ADDR');

        want = initWant;
        accessManager = IWooAccessManager(initAccessManager);
    }

    modifier onlyAdmin() {
        require(owner() == _msgSender() || accessManager.isVaultAdmin(msg.sender), 'Vault: NOT_ADMIN');
        _;
    }

    /* ----- External Functions ----- */

    function deposit(uint256 amount) public payable override nonReentrant {
        require(amount > 0, 'Vault: amount_CAN_NOT_BE_ZERO');

        if (want == wrappedEther) {
            require(msg.value == amount, 'Vault: msg.value_INSUFFICIENT');
        } else {
            require(msg.value == 0, 'Vault: msg.value_INVALID');
        }

        if (address(strategy) != address(0)) {
            require(!strategy.paused(), 'Vault: strat_paused');
            strategy.beforeDeposit();
        }

        uint256 balanceBefore = balance();
        if (want == wrappedEther) {
            IWETH(wrappedEther).deposit{value: msg.value}();
        } else {
            TransferHelper.safeTransferFrom(want, msg.sender, address(this), amount);
        }
        uint256 balanceAfter = balance();
        require(amount <= balanceAfter.sub(balanceBefore), 'Vault: amount_NOT_ENOUGH');

        uint256 shares = totalSupply() == 0 ? amount : amount.mul(totalSupply()).div(balanceBefore);
        uint256 sharesBefore = balanceOf(msg.sender);
        uint256 costBefore = costSharePrice[msg.sender];
        uint256 costAfter = (sharesBefore.mul(costBefore).add(amount.mul(1e18))).div(sharesBefore.add(shares));
        costSharePrice[msg.sender] = costAfter;

        _mint(msg.sender, shares);

        earn();
    }

    function withdraw(uint256 shares) public override nonReentrant {
        require(shares > 0, 'Vault: shares_ZERO');
        require(shares <= balanceOf(msg.sender), 'Vault: shares_NOT_ENOUGH');

        uint256 withdrawAmount = shares.mul(balance()).div(totalSupply());
        _burn(msg.sender, shares);

        uint256 balanceBefore = IERC20(want).balanceOf(address(this));
        if (balanceBefore < withdrawAmount) {
            uint256 balanceToWithdraw = withdrawAmount.sub(balanceBefore);
            require(_isStratActive(), 'Vault: STRAT_INACTIVE');
            strategy.withdraw(balanceToWithdraw);
            uint256 balanceAfter = IERC20(want).balanceOf(address(this));
            if (withdrawAmount > balanceAfter) {
                // NOTE: in case a small amount not counted in, due to the decimal precision.
                withdrawAmount = balanceAfter;
            }
        }

        if (want == wrappedEther) {
            IWETH(wrappedEther).withdraw(withdrawAmount);
            TransferHelper.safeTransferETH(msg.sender, withdrawAmount);
        } else {
            TransferHelper.safeTransfer(want, msg.sender, withdrawAmount);
        }
    }

    function earn() public override {
        if (_isStratActive()) {
            uint256 balanceAvail = available();
            TransferHelper.safeTransfer(want, address(strategy), balanceAvail);
            strategy.deposit();
        }
    }

    function available() public view override returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    function balance() public view override returns (uint256) {
        return address(strategy) != address(0) ? available().add(strategy.balanceOf()) : available();
    }

    function getPricePerFullShare() public view override returns (uint256) {
        return totalSupply() == 0 ? 1e18 : balance().mul(1e18).div(totalSupply());
    }

    function _isStratActive() internal view returns (bool) {
        return address(strategy) != address(0) && !strategy.paused();
    }

    /* ----- Admin Functions ----- */

    function setupStrat(address _strat) public onlyAdmin {
        require(_strat != address(0), 'Vault: STRAT_ZERO_ADDR');
        require(address(strategy) == address(0), 'Vault: STRAT_ALREADY_SET');
        require(address(this) == IStrategy(_strat).vault(), 'Vault: STRAT_VAULT_INVALID');
        require(want == IStrategy(_strat).want(), 'Vault: STRAT_WANT_INVALID');
        strategy = IStrategy(_strat);

        emit UpgradeStrat(_strat);
    }

    function proposeStrat(address _implementation) public onlyAdmin {
        require(address(this) == IStrategy(_implementation).vault(), 'Vault: STRAT_VAULT_INVALID');
        require(want == IStrategy(_implementation).want(), 'Vault: STRAT_WANT_INVALID');
        stratCandidate = StratCandidate({implementation: _implementation, proposedTime: block.timestamp});

        emit NewStratCandidate(_implementation);
    }

    function upgradeStrat() public onlyAdmin {
        require(stratCandidate.implementation != address(0), 'Vault: NO_CANDIDATE');
        require(stratCandidate.proposedTime.add(approvalDelay) < block.timestamp, 'Vault: TIME_INVALID');

        emit UpgradeStrat(stratCandidate.implementation);

        strategy.retireStrat();
        strategy = IStrategy(stratCandidate.implementation);
        stratCandidate.implementation = address(0);
        stratCandidate.proposedTime = 5000000000; // 100+ years to ensure proposedTime check

        earn();
    }

    function setApprovalDelay(uint256 newApprovalDelay) external onlyAdmin {
        require(newApprovalDelay > 0, 'Vault: newApprovalDelay_ZERO');
        approvalDelay = newApprovalDelay;
    }

    function inCaseTokensGetStuck(address stuckToken) external onlyAdmin {
        require(stuckToken != want, 'Vault: stuckToken_NOT_WANT');
        require(stuckToken != address(0), 'Vault: stuckToken_ZERO_ADDR');
        uint256 amount = IERC20(stuckToken).balanceOf(address(this));
        if (amount > 0) {
            TransferHelper.safeTransfer(stuckToken, msg.sender, amount);
        }
    }

    function inCaseNativeTokensGetStuck() external onlyAdmin {
        // NOTE: vault never needs native tokens to do the yield farming;
        // This native token balance indicates a user's incorrect transfer.
        if (address(this).balance > 0) {
            TransferHelper.safeTransferETH(msg.sender, address(this).balance);
        }
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

import '../../../interfaces/PancakeSwap/IMasterChef.sol';
import '../../../interfaces/TraderJoe/IUniswapPair.sol';
import '../../../interfaces/TraderJoe/IUniswapRouter.sol';
import '../../../interfaces/IWooAccessManager.sol';
import '../../../interfaces/IStrategy.sol';

import '../BaseStrategy.sol';

contract StrategyTraderJoeLP is BaseStrategy {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    /* ----- State Variables ----- */

    uint256 public immutable pid;

    address[] public rewardToLP0Route;
    address[] public rewardToLP1Route;

    address public lpToken0;
    address public lpToken1;

    address public constant reward = address(0x6e84a6216eA6dACC71eE8E6b0a5B7322EEbC0fDd);
    address public constant uniRouter = address(0x60aE616a2155Ee3d9A68541Ba4544862310933d4);
    address public constant masterChef = address(0xd6a4F121CA35509aF06A0Be99093d08462f53052);

    constructor(
        address initVault,
        address initAccessManager,
        uint256 initPid,
        address[] memory initRewardToLP0Route,
        address[] memory initRewardToLP1Route
    ) public BaseStrategy(initVault, initAccessManager) {
        pid = initPid;
        rewardToLP0Route = initRewardToLP0Route;
        rewardToLP1Route = initRewardToLP1Route;

        if (initRewardToLP0Route.length == 0) {
            lpToken0 = reward;
        } else {
            require(initRewardToLP0Route[0] == reward);
            lpToken0 = initRewardToLP0Route[initRewardToLP0Route.length - 1];
        }
        if (initRewardToLP1Route.length == 0) {
            lpToken1 = reward;
        } else {
            require(initRewardToLP1Route[0] == reward);
            lpToken1 = initRewardToLP1Route[initRewardToLP1Route.length - 1];
        }

        require(
            IUniswapV2Pair(want).token0() == lpToken0 || IUniswapV2Pair(want).token0() == lpToken1,
            'StrategyLP: LP_token0_INVALID'
        );
        require(
            IUniswapV2Pair(want).token1() == lpToken0 || IUniswapV2Pair(want).token1() == lpToken1,
            'StrategyLP: LP_token1_INVALID'
        );

        (address lpToken, , , ) = IMasterChef(masterChef).poolInfo(initPid);
        require(lpToken == want, 'StrategyLP: wrong_initPid');

        _giveAllowances();
    }

    /* ----- External Functions ----- */

    function withdraw(uint256 amount) external override nonReentrant {
        require(msg.sender == vault, 'StrategyLP: NOT_VAULT');

        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance < amount) {
            IMasterChef(masterChef).withdraw(pid, amount.sub(wantBalance));
            wantBalance = IERC20(want).balanceOf(address(this));
        }

        // just in case the decimal precision for the very left staking amount
        uint256 withdrawAmount = amount < wantBalance ? amount : wantBalance;

        uint256 fee = chargeWithdrawalFee(withdrawAmount);
        if (withdrawAmount > fee) {
            TransferHelper.safeTransfer(want, vault, withdrawAmount.sub(fee));
        }
    }

    function harvest() public override whenNotPaused {
        require(msg.sender == tx.origin || msg.sender == vault, 'StrategyLP: EOA_OR_VAULT');

        IMasterChef(masterChef).deposit(pid, 0);
        uint256 rewardAmount = IERC20(reward).balanceOf(address(this));
        if (rewardAmount > 0) {
            uint256 wantBefore = IERC20(want).balanceOf(address(this));
            _addLiquidity();
            uint256 wantAfter = IERC20(want).balanceOf(address(this));
            uint256 perfAmount = wantAfter.sub(wantBefore);
            chargePerformanceFee(perfAmount);
        }
        deposit();
    }

    function deposit() public override whenNotPaused nonReentrant {
        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance > 0) {
            IMasterChef(masterChef).deposit(pid, wantBalance);
        }
    }

    function balanceOfPool() public view override returns (uint256) {
        (uint256 amount, ) = IMasterChef(masterChef).userInfo(pid, address(this));
        return amount;
    }

    /* ----- Private Functions ----- */

    function _giveAllowances() internal override {
        TransferHelper.safeApprove(want, masterChef, 0);
        TransferHelper.safeApprove(want, masterChef, uint256(-1));

        TransferHelper.safeApprove(reward, uniRouter, 0);
        TransferHelper.safeApprove(reward, uniRouter, uint256(-1));

        TransferHelper.safeApprove(lpToken0, uniRouter, 0);
        TransferHelper.safeApprove(lpToken0, uniRouter, uint256(-1));

        TransferHelper.safeApprove(lpToken1, uniRouter, 0);
        TransferHelper.safeApprove(lpToken1, uniRouter, uint256(-1));
    }

    function _removeAllowances() internal override {
        TransferHelper.safeApprove(want, masterChef, 0);
        TransferHelper.safeApprove(reward, uniRouter, 0);
        TransferHelper.safeApprove(lpToken0, uniRouter, 0);
        TransferHelper.safeApprove(lpToken1, uniRouter, 0);
    }

    function _addLiquidity() private {
        uint256 rewardHalf = IERC20(reward).balanceOf(address(this)).div(2);

        if (lpToken0 != reward) {
            IUniswapRouter(uniRouter).swapExactTokensForTokens(rewardHalf, 0, rewardToLP0Route, address(this), now);
        }

        if (lpToken1 != reward) {
            IUniswapRouter(uniRouter).swapExactTokensForTokens(rewardHalf, 0, rewardToLP1Route, address(this), now);
        }

        uint256 lp0Balance = IERC20(lpToken0).balanceOf(address(this));
        uint256 lp1Balance = IERC20(lpToken1).balanceOf(address(this));
        IUniswapRouter(uniRouter).addLiquidity(lpToken0, lpToken1, lp0Balance, lp1Balance, 0, 0, address(this), now);
    }

    function retireStrat() external override {
        require(msg.sender == vault, '!vault');
        IMasterChef(masterChef).emergencyWithdraw(pid);
        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance > 0) {
            TransferHelper.safeTransfer(want, vault, wantBalance);
        }
    }

    function emergencyExit() external override onlyAdmin {
        IMasterChef(masterChef).emergencyWithdraw(pid);
        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance > 0) {
            TransferHelper.safeTransfer(want, vault, wantBalance);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IMasterChef {
    function deposit(uint256 pid, uint256 amount) external;

    function withdraw(uint256 pid, uint256 amount) external;

    function enterStaking(uint256 amount) external;

    function leaveStaking(uint256 amount) external;

    function emergencyWithdraw(uint256 pid) external;

    function pendingCake(uint256 pid, address user) external view returns (uint256);

    function poolInfo(uint256 pid)
        external
        view
        returns (
            address,
            uint256,
            uint256,
            uint256
        );

    function userInfo(uint256 pid, address user) external view returns (uint256, uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IUniswapV2Pair {
    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IUniswapRouter {
    function factory() external pure returns (address);

    function WBNB() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityBNB(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountBNB,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityBNB(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountBNB);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityBNBWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountBNB);

    function removeLiquidityBNBSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountBNB);

    function removeLiquidityBNBWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountBNB);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactBNBForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForBNBSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactBNBForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactBNB(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForBNB(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapBNBForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

import '../../../interfaces/PancakeSwap/IMasterChef.sol';
import '../../../interfaces/TraderJoe/IUniswapPair.sol';
import '../../../interfaces/TraderJoe/IUniswapRouter.sol';
import '../../../interfaces/IWooAccessManager.sol';
import '../../../interfaces/IStrategy.sol';

import '../BaseStrategy.sol';

contract StrategyTraderJoeDualLP is BaseStrategy {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    /* ----- State Variables ----- */

    uint256 public immutable pid;

    address[] public rewardToLP0Route;
    address[] public rewardToLP1Route;
    address[] public secondRewardToLP0Route;
    address[] public secondRewardToLP1Route;

    address public lpToken0;
    address public lpToken1;

    address public constant reward = address(0x6e84a6216eA6dACC71eE8E6b0a5B7322EEbC0fDd); // JOE
    address public constant secondReward = address(0x8729438EB15e2C8B576fCc6AeCdA6A148776C0F5); // QI
    address public constant uniRouter = address(0x60aE616a2155Ee3d9A68541Ba4544862310933d4);
    address public constant masterChef = address(0x188bED1968b795d5c9022F6a0bb5931Ac4c18F00);

    constructor(
        address initVault,
        address initAccessManager,
        uint256 initPid,
        address[] memory initRewardToLP0Route,
        address[] memory initRewardToLP1Route,
        address[] memory initSecondRewardToLP0Route,
        address[] memory initSecondRewardToLP1Route
    ) public BaseStrategy(initVault, initAccessManager) {
        pid = initPid;
        rewardToLP0Route = initRewardToLP0Route;
        rewardToLP1Route = initRewardToLP1Route;
        secondRewardToLP0Route = initSecondRewardToLP0Route;
        secondRewardToLP1Route = initSecondRewardToLP1Route;

        if (initRewardToLP0Route.length == 0) {
            lpToken0 = reward;
        } else {
            require(initRewardToLP0Route[0] == reward);
            lpToken0 = initRewardToLP0Route[initRewardToLP0Route.length - 1];
        }
        if (initRewardToLP1Route.length == 0) {
            lpToken1 = reward;
        } else {
            require(initRewardToLP1Route[0] == reward);
            lpToken1 = initRewardToLP1Route[initRewardToLP1Route.length - 1];
        }
        require(initSecondRewardToLP0Route[0] == secondReward);
        require(initSecondRewardToLP1Route[0] == secondReward);

        require(
            IUniswapV2Pair(want).token0() == lpToken0 || IUniswapV2Pair(want).token0() == lpToken1,
            'StrategyLP: LP_token0_INVALID'
        );
        require(
            IUniswapV2Pair(want).token1() == lpToken0 || IUniswapV2Pair(want).token1() == lpToken1,
            'StrategyLP: LP_token1_INVALID'
        );

        (address lpToken, , , ) = IMasterChef(masterChef).poolInfo(initPid);
        require(lpToken == want, 'StrategyLP: wrong_initPid');

        _giveAllowances();
    }

    /* ----- External Functions ----- */

    function withdraw(uint256 amount) external override nonReentrant {
        require(msg.sender == vault, 'StrategyLP: NOT_VAULT');

        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance < amount) {
            IMasterChef(masterChef).withdraw(pid, amount.sub(wantBalance));
            wantBalance = IERC20(want).balanceOf(address(this));
        }

        // just in case the decimal precision for the very left staking amount
        uint256 withdrawAmount = amount < wantBalance ? amount : wantBalance;

        uint256 fee = chargeWithdrawalFee(withdrawAmount);
        if (withdrawAmount > fee) {
            TransferHelper.safeTransfer(want, vault, withdrawAmount.sub(fee));
        }
    }

    function harvest() public override whenNotPaused {
        require(msg.sender == tx.origin || msg.sender == vault, 'StrategyLP: EOA_OR_VAULT');

        IMasterChef(masterChef).deposit(pid, 0);
        uint256 rewardAmount = IERC20(reward).balanceOf(address(this));
        uint256 secondRewardAmount = IERC20(secondReward).balanceOf(address(this));
        if (rewardAmount > 0 || secondRewardAmount > 0) {
            uint256 wantBefore = IERC20(want).balanceOf(address(this));
            _addLiquidity();
            uint256 wantAfter = IERC20(want).balanceOf(address(this));
            uint256 perfAmount = wantAfter.sub(wantBefore);
            chargePerformanceFee(perfAmount);
        }
        deposit();
    }

    function deposit() public override whenNotPaused nonReentrant {
        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance > 0) {
            IMasterChef(masterChef).deposit(pid, wantBalance);
        }
    }

    function balanceOfPool() public view override returns (uint256) {
        (uint256 amount, ) = IMasterChef(masterChef).userInfo(pid, address(this));
        return amount;
    }

    /* ----- Private Functions ----- */

    function _giveAllowances() internal override {
        TransferHelper.safeApprove(want, masterChef, 0);
        TransferHelper.safeApprove(want, masterChef, uint256(-1));

        TransferHelper.safeApprove(reward, uniRouter, 0);
        TransferHelper.safeApprove(reward, uniRouter, uint256(-1));

        TransferHelper.safeApprove(secondReward, uniRouter, 0);
        TransferHelper.safeApprove(secondReward, uniRouter, uint256(-1));

        TransferHelper.safeApprove(lpToken0, uniRouter, 0);
        TransferHelper.safeApprove(lpToken0, uniRouter, uint256(-1));

        TransferHelper.safeApprove(lpToken1, uniRouter, 0);
        TransferHelper.safeApprove(lpToken1, uniRouter, uint256(-1));
    }

    function _removeAllowances() internal override {
        TransferHelper.safeApprove(want, masterChef, 0);
        TransferHelper.safeApprove(reward, uniRouter, 0);
        TransferHelper.safeApprove(secondReward, uniRouter, 0);
        TransferHelper.safeApprove(lpToken0, uniRouter, 0);
        TransferHelper.safeApprove(lpToken1, uniRouter, 0);
    }

    function _addLiquidity() private {
        uint256 rewardHalf = IERC20(reward).balanceOf(address(this)).div(2);
        uint256 secondRewardHalf = IERC20(secondReward).balanceOf(address(this)).div(2);

        if (lpToken0 != reward) {
            IUniswapRouter(uniRouter).swapExactTokensForTokens(rewardHalf, 0, rewardToLP0Route, address(this), now);
        }

        if (lpToken1 != reward) {
            IUniswapRouter(uniRouter).swapExactTokensForTokens(rewardHalf, 0, rewardToLP1Route, address(this), now);
        }

        if (lpToken0 != secondReward) {
            IUniswapRouter(uniRouter).swapExactTokensForTokens(
                secondRewardHalf,
                0,
                secondRewardToLP0Route,
                address(this),
                now
            );
        }

        if (lpToken1 != secondReward) {
            IUniswapRouter(uniRouter).swapExactTokensForTokens(
                secondRewardHalf,
                0,
                secondRewardToLP1Route,
                address(this),
                now
            );
        }

        uint256 lp0Balance = IERC20(lpToken0).balanceOf(address(this));
        uint256 lp1Balance = IERC20(lpToken1).balanceOf(address(this));
        IUniswapRouter(uniRouter).addLiquidity(lpToken0, lpToken1, lp0Balance, lp1Balance, 0, 0, address(this), now);
    }

    function retireStrat() external override {
        require(msg.sender == vault, '!vault');
        IMasterChef(masterChef).emergencyWithdraw(pid);
        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance > 0) {
            TransferHelper.safeTransfer(want, vault, wantBalance);
        }
    }

    function emergencyExit() external override onlyAdmin {
        IMasterChef(masterChef).emergencyWithdraw(pid);
        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance > 0) {
            TransferHelper.safeTransfer(want, vault, wantBalance);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

import '../../../interfaces/PancakeSwap/IMasterChef.sol';
import '../../../interfaces/PancakeSwap/IPancakePair.sol';
import '../../../interfaces/PancakeSwap/IPancakeRouter.sol';
import '../../../interfaces/IWooAccessManager.sol';
import '../../../interfaces/IStrategy.sol';

import '../BaseStrategy.sol';

contract StrategySpookySwapLP is BaseStrategy {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    /* ----- State Variables ----- */

    uint256 public immutable pid;

    address[] public rewardToLP0Route;
    address[] public rewardToLP1Route;

    address public lpToken0;
    address public lpToken1;

    address public constant reward = address(0x841FAD6EAe12c286d1Fd18d1d525DFfA75C7EFFE); // BOO
    address public constant uniRouter = address(0xF491e7B69E4244ad4002BC14e878a34207E38c29);
    address public constant masterChef = address(0x2b2929E785374c651a81A63878Ab22742656DcDd);

    constructor(
        address initVault,
        address initAccessManager,
        uint256 initPid,
        address[] memory initRewardToLP0Route,
        address[] memory initRewardToLP1Route
    ) public BaseStrategy(initVault, initAccessManager) {
        pid = initPid;
        rewardToLP0Route = initRewardToLP0Route;
        rewardToLP1Route = initRewardToLP1Route;

        if (initRewardToLP0Route.length == 0) {
            lpToken0 = reward;
        } else {
            require(initRewardToLP0Route[0] == reward);
            lpToken0 = initRewardToLP0Route[initRewardToLP0Route.length - 1];
        }
        if (initRewardToLP1Route.length == 0) {
            lpToken1 = reward;
        } else {
            require(initRewardToLP1Route[0] == reward);
            lpToken1 = initRewardToLP1Route[initRewardToLP1Route.length - 1];
        }

        require(
            IPancakePair(want).token0() == lpToken0 || IPancakePair(want).token0() == lpToken1,
            'StrategySpookySwapLP: LP_token0_INVALID'
        );
        require(
            IPancakePair(want).token1() == lpToken0 || IPancakePair(want).token1() == lpToken1,
            'StrategySpookySwapLP: LP_token1_INVALID'
        );

        (address lpToken, , , ) = IMasterChef(masterChef).poolInfo(initPid);
        require(lpToken == want, 'StrategySpookySwapLP: wrong_initPid');

        _giveAllowances();
    }

    /* ----- External Functions ----- */

    function withdraw(uint256 amount) external override nonReentrant {
        require(msg.sender == vault, 'StrategySpookySwapLP: NOT_VAULT');

        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance < amount) {
            IMasterChef(masterChef).withdraw(pid, amount.sub(wantBalance));
            wantBalance = IERC20(want).balanceOf(address(this));
        }

        // just in case the decimal precision for the very left staking amount
        uint256 withdrawAmount = amount < wantBalance ? amount : wantBalance;

        uint256 fee = chargeWithdrawalFee(withdrawAmount);
        if (withdrawAmount > fee) {
            TransferHelper.safeTransfer(want, vault, withdrawAmount.sub(fee));
        }
    }

    function harvest() public override whenNotPaused {
        require(msg.sender == tx.origin || msg.sender == vault, 'StrategySpookySwapLP: EOA_OR_VAULT');

        IMasterChef(masterChef).deposit(pid, 0);
        uint256 rewardAmount = IERC20(reward).balanceOf(address(this));
        if (rewardAmount > 0) {
            uint256 wantBefore = IERC20(want).balanceOf(address(this));
            _addLiquidity();
            uint256 wantAfter = IERC20(want).balanceOf(address(this));
            uint256 perfAmount = wantAfter.sub(wantBefore);
            chargePerformanceFee(perfAmount);
        }
        deposit();
    }

    function deposit() public override whenNotPaused nonReentrant {
        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance > 0) {
            IMasterChef(masterChef).deposit(pid, wantBalance);
        }
    }

    function balanceOfPool() public view override returns (uint256) {
        (uint256 amount, ) = IMasterChef(masterChef).userInfo(pid, address(this));
        return amount;
    }

    /* ----- Private Functions ----- */

    function _giveAllowances() internal override {
        TransferHelper.safeApprove(want, masterChef, 0);
        TransferHelper.safeApprove(want, masterChef, uint256(-1));

        TransferHelper.safeApprove(reward, uniRouter, 0);
        TransferHelper.safeApprove(reward, uniRouter, uint256(-1));

        TransferHelper.safeApprove(lpToken0, uniRouter, 0);
        TransferHelper.safeApprove(lpToken0, uniRouter, uint256(-1));

        TransferHelper.safeApprove(lpToken1, uniRouter, 0);
        TransferHelper.safeApprove(lpToken1, uniRouter, uint256(-1));
    }

    function _removeAllowances() internal override {
        TransferHelper.safeApprove(want, masterChef, 0);
        TransferHelper.safeApprove(reward, uniRouter, 0);
        TransferHelper.safeApprove(lpToken0, uniRouter, 0);
        TransferHelper.safeApprove(lpToken1, uniRouter, 0);
    }

    function _addLiquidity() private {
        uint256 rewardHalf = IERC20(reward).balanceOf(address(this)).div(2);

        if (lpToken0 != reward) {
            IPancakeRouter(uniRouter).swapExactTokensForTokens(rewardHalf, 0, rewardToLP0Route, address(this), now);
        }

        if (lpToken1 != reward) {
            IPancakeRouter(uniRouter).swapExactTokensForTokens(rewardHalf, 0, rewardToLP1Route, address(this), now);
        }

        uint256 lp0Balance = IERC20(lpToken0).balanceOf(address(this));
        uint256 lp1Balance = IERC20(lpToken1).balanceOf(address(this));
        IPancakeRouter(uniRouter).addLiquidity(lpToken0, lpToken1, lp0Balance, lp1Balance, 0, 0, address(this), now);
    }

    function retireStrat() external override {
        require(msg.sender == vault, '!vault');
        IMasterChef(masterChef).emergencyWithdraw(pid);
        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance > 0) {
            TransferHelper.safeTransfer(want, vault, wantBalance);
        }
    }

    function emergencyExit() external override onlyAdmin {
        IMasterChef(masterChef).emergencyWithdraw(pid);
        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance > 0) {
            TransferHelper.safeTransfer(want, vault, wantBalance);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

import '../../../interfaces/PancakeSwap/IMasterChef.sol';
import '../../../interfaces/PancakeSwap/IPancakePair.sol';
import '../../../interfaces/PancakeSwap/IPancakeRouter.sol';
import '../../../interfaces/IWooAccessManager.sol';
import '../../../interfaces/IStrategy.sol';

import '../BaseStrategy.sol';

contract StrategyLP is BaseStrategy {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    /* ----- State Variables ----- */

    uint256 public immutable pid;

    address[] public rewardToLP0Route;
    address[] public rewardToLP1Route;

    address public lpToken0;
    address public lpToken1;

    address public constant reward = address(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);
    address public constant uniRouter = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public constant masterChef = address(0x73feaa1eE314F8c655E354234017bE2193C9E24E);

    constructor(
        address initVault,
        address initAccessManager,
        uint256 initPid,
        address[] memory initRewardToLP0Route,
        address[] memory initRewardToLP1Route
    ) public BaseStrategy(initVault, initAccessManager) {
        pid = initPid;
        rewardToLP0Route = initRewardToLP0Route;
        rewardToLP1Route = initRewardToLP1Route;

        if (initRewardToLP0Route.length == 0) {
            lpToken0 = reward;
        } else {
            require(initRewardToLP0Route[0] == reward);
            lpToken0 = initRewardToLP0Route[initRewardToLP0Route.length - 1];
        }
        if (initRewardToLP1Route.length == 0) {
            lpToken1 = reward;
        } else {
            require(initRewardToLP1Route[0] == reward);
            lpToken1 = initRewardToLP1Route[initRewardToLP1Route.length - 1];
        }

        require(
            IPancakePair(want).token0() == lpToken0 || IPancakePair(want).token0() == lpToken1,
            'StrategyLP: LP_token0_INVALID'
        );
        require(
            IPancakePair(want).token1() == lpToken0 || IPancakePair(want).token1() == lpToken1,
            'StrategyLP: LP_token1_INVALID'
        );

        (address lpToken, , , ) = IMasterChef(masterChef).poolInfo(initPid);
        require(lpToken == want, 'StrategyLP: wrong_initPid');

        _giveAllowances();
    }

    /* ----- External Functions ----- */

    function withdraw(uint256 amount) external override nonReentrant {
        require(msg.sender == vault, 'StrategyLP: NOT_VAULT');

        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance < amount) {
            IMasterChef(masterChef).withdraw(pid, amount.sub(wantBalance));
            wantBalance = IERC20(want).balanceOf(address(this));
        }

        // just in case the decimal precision for the very left staking amount
        uint256 withdrawAmount = amount < wantBalance ? amount : wantBalance;

        uint256 fee = chargeWithdrawalFee(withdrawAmount);
        if (withdrawAmount > fee) {
            TransferHelper.safeTransfer(want, vault, withdrawAmount.sub(fee));
        }
    }

    function harvest() public override whenNotPaused {
        require(msg.sender == tx.origin || msg.sender == vault, 'StrategyLP: EOA_OR_VAULT');

        IMasterChef(masterChef).deposit(pid, 0);
        uint256 rewardAmount = IERC20(reward).balanceOf(address(this));
        if (rewardAmount > 0) {
            uint256 wantBefore = IERC20(want).balanceOf(address(this));
            _addLiquidity();
            uint256 wantAfter = IERC20(want).balanceOf(address(this));
            uint256 perfAmount = wantAfter.sub(wantBefore);
            chargePerformanceFee(perfAmount);
        }
        deposit();
    }

    function deposit() public override whenNotPaused nonReentrant {
        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance > 0) {
            IMasterChef(masterChef).deposit(pid, wantBalance);
        }
    }

    function balanceOfPool() public view override returns (uint256) {
        (uint256 amount, ) = IMasterChef(masterChef).userInfo(pid, address(this));
        return amount;
    }

    /* ----- Private Functions ----- */

    function _giveAllowances() internal override {
        TransferHelper.safeApprove(want, masterChef, 0);
        TransferHelper.safeApprove(want, masterChef, uint256(-1));

        TransferHelper.safeApprove(reward, uniRouter, 0);
        TransferHelper.safeApprove(reward, uniRouter, uint256(-1));

        TransferHelper.safeApprove(lpToken0, uniRouter, 0);
        TransferHelper.safeApprove(lpToken0, uniRouter, uint256(-1));

        TransferHelper.safeApprove(lpToken1, uniRouter, 0);
        TransferHelper.safeApprove(lpToken1, uniRouter, uint256(-1));
    }

    function _removeAllowances() internal override {
        TransferHelper.safeApprove(want, masterChef, 0);
        TransferHelper.safeApprove(reward, uniRouter, 0);
        TransferHelper.safeApprove(lpToken0, uniRouter, 0);
        TransferHelper.safeApprove(lpToken1, uniRouter, 0);
    }

    function _addLiquidity() private {
        uint256 rewardHalf = IERC20(reward).balanceOf(address(this)).div(2);

        if (lpToken0 != reward) {
            IPancakeRouter(uniRouter).swapExactTokensForTokens(rewardHalf, 0, rewardToLP0Route, address(this), now);
        }

        if (lpToken1 != reward) {
            IPancakeRouter(uniRouter).swapExactTokensForTokens(rewardHalf, 0, rewardToLP1Route, address(this), now);
        }

        uint256 lp0Balance = IERC20(lpToken0).balanceOf(address(this));
        uint256 lp1Balance = IERC20(lpToken1).balanceOf(address(this));
        IPancakeRouter(uniRouter).addLiquidity(lpToken0, lpToken1, lp0Balance, lp1Balance, 0, 0, address(this), now);
    }

    function retireStrat() external override {
        require(msg.sender == vault, '!vault');
        IMasterChef(masterChef).emergencyWithdraw(pid);
        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance > 0) {
            TransferHelper.safeTransfer(want, vault, wantBalance);
        }
    }

    function emergencyExit() external override onlyAdmin {
        IMasterChef(masterChef).emergencyWithdraw(pid);
        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance > 0) {
            TransferHelper.safeTransfer(want, vault, wantBalance);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

import '../../../interfaces/PancakeSwap/IMasterChef.sol';
import '../../../interfaces/PancakeSwap/IPancakePair.sol';
import '../../../interfaces/PancakeSwap/IPancakeRouter.sol';
import '../../../interfaces/IWooAccessManager.sol';
import '../../../interfaces/IStrategy.sol';

import '../BaseStrategy.sol';

contract StrategyBiswapLP is BaseStrategy {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    /* ----- State Variables ----- */

    uint256 public immutable pid;

    address[] public rewardToLP0Route;
    address[] public rewardToLP1Route;

    address public lpToken0;
    address public lpToken1;

    address public constant reward = address(0x965F527D9159dCe6288a2219DB51fc6Eef120dD1);
    address public constant uniRouter = address(0x3a6d8cA21D1CF76F653A67577FA0D27453350dD8);
    address public constant masterChef = address(0xDbc1A13490deeF9c3C12b44FE77b503c1B061739);

    constructor(
        address initVault,
        address initAccessManager,
        uint256 initPid,
        address[] memory initRewardToLP0Route,
        address[] memory initRewardToLP1Route
    ) public BaseStrategy(initVault, initAccessManager) {
        pid = initPid;
        rewardToLP0Route = initRewardToLP0Route;
        rewardToLP1Route = initRewardToLP1Route;

        if (initRewardToLP0Route.length == 0) {
            lpToken0 = reward;
        } else {
            require(initRewardToLP0Route[0] == reward);
            lpToken0 = initRewardToLP0Route[initRewardToLP0Route.length - 1];
        }
        if (initRewardToLP1Route.length == 0) {
            lpToken1 = reward;
        } else {
            require(initRewardToLP1Route[0] == reward);
            lpToken1 = initRewardToLP1Route[initRewardToLP1Route.length - 1];
        }

        require(
            IPancakePair(want).token0() == lpToken0 || IPancakePair(want).token0() == lpToken1,
            'StrategyLP: LP_token0_INVALID'
        );
        require(
            IPancakePair(want).token1() == lpToken0 || IPancakePair(want).token1() == lpToken1,
            'StrategyLP: LP_token1_INVALID'
        );

        (address lpToken, , , ) = IMasterChef(masterChef).poolInfo(initPid);
        require(lpToken == want, 'StrategyLP: wrong_initPid');

        _giveAllowances();
    }

    /* ----- External Functions ----- */

    function withdraw(uint256 amount) external override nonReentrant {
        require(msg.sender == vault, 'StrategyLP: NOT_VAULT');

        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance < amount) {
            IMasterChef(masterChef).withdraw(pid, amount.sub(wantBalance));
            wantBalance = IERC20(want).balanceOf(address(this));
        }

        // just in case the decimal precision for the very left staking amount
        uint256 withdrawAmount = amount < wantBalance ? amount : wantBalance;

        uint256 fee = chargeWithdrawalFee(withdrawAmount);
        if (withdrawAmount > fee) {
            TransferHelper.safeTransfer(want, vault, withdrawAmount.sub(fee));
        }
    }

    function harvest() public override whenNotPaused {
        require(msg.sender == tx.origin || msg.sender == vault, 'StrategyLP: EOA_OR_VAULT');

        IMasterChef(masterChef).deposit(pid, 0);
        uint256 rewardAmount = IERC20(reward).balanceOf(address(this));
        if (rewardAmount > 0) {
            uint256 wantBefore = IERC20(want).balanceOf(address(this));
            _addLiquidity();
            uint256 wantAfter = IERC20(want).balanceOf(address(this));
            uint256 perfAmount = wantAfter.sub(wantBefore);
            chargePerformanceFee(perfAmount);
        }
        deposit();
    }

    function deposit() public override whenNotPaused nonReentrant {
        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance > 0) {
            IMasterChef(masterChef).deposit(pid, wantBalance);
        }
    }

    function balanceOfPool() public view override returns (uint256) {
        (uint256 amount, ) = IMasterChef(masterChef).userInfo(pid, address(this));
        return amount;
    }

    /* ----- Private Functions ----- */

    function _giveAllowances() internal override {
        TransferHelper.safeApprove(want, masterChef, 0);
        TransferHelper.safeApprove(want, masterChef, uint256(-1));

        TransferHelper.safeApprove(reward, uniRouter, 0);
        TransferHelper.safeApprove(reward, uniRouter, uint256(-1));

        TransferHelper.safeApprove(lpToken0, uniRouter, 0);
        TransferHelper.safeApprove(lpToken0, uniRouter, uint256(-1));

        TransferHelper.safeApprove(lpToken1, uniRouter, 0);
        TransferHelper.safeApprove(lpToken1, uniRouter, uint256(-1));
    }

    function _removeAllowances() internal override {
        TransferHelper.safeApprove(want, masterChef, 0);
        TransferHelper.safeApprove(reward, uniRouter, 0);
        TransferHelper.safeApprove(lpToken0, uniRouter, 0);
        TransferHelper.safeApprove(lpToken1, uniRouter, 0);
    }

    function _addLiquidity() private {
        uint256 rewardHalf = IERC20(reward).balanceOf(address(this)).div(2);

        if (lpToken0 != reward) {
            IPancakeRouter(uniRouter).swapExactTokensForTokens(rewardHalf, 0, rewardToLP0Route, address(this), now);
        }

        if (lpToken1 != reward) {
            IPancakeRouter(uniRouter).swapExactTokensForTokens(rewardHalf, 0, rewardToLP1Route, address(this), now);
        }

        uint256 lp0Balance = IERC20(lpToken0).balanceOf(address(this));
        uint256 lp1Balance = IERC20(lpToken1).balanceOf(address(this));
        IPancakeRouter(uniRouter).addLiquidity(lpToken0, lpToken1, lp0Balance, lp1Balance, 0, 0, address(this), now);
    }

    function retireStrat() external override {
        require(msg.sender == vault, '!vault');
        IMasterChef(masterChef).emergencyWithdraw(pid);
        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance > 0) {
            TransferHelper.safeTransfer(want, vault, wantBalance);
        }
    }

    function emergencyExit() external override onlyAdmin {
        IMasterChef(masterChef).emergencyWithdraw(pid);
        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance > 0) {
            TransferHelper.safeTransfer(want, vault, wantBalance);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

import '../../../interfaces/PancakeSwap/IMasterChef.sol';
import '../BaseStrategy.sol';

contract StrategyCake is BaseStrategy {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    /* ----- Constant Variables ----- */

    address public constant masterChef = address(0x73feaa1eE314F8c655E354234017bE2193C9E24E);

    constructor(address initVault, address initAccessManager) public BaseStrategy(initVault, initAccessManager) {
        _giveAllowances();
    }

    /* ----- External Functions ----- */

    function withdraw(uint256 amount) external override nonReentrant {
        require(msg.sender == address(vault), 'StrategyCake: NOT_VAULT');

        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance < amount) {
            IMasterChef(masterChef).leaveStaking(amount.sub(wantBalance));
            wantBalance = IERC20(want).balanceOf(address(this));
        }

        // just in case the decimal precision for the very left staking amount
        uint256 withdrawAmount = amount < wantBalance ? amount : wantBalance;

        uint256 fee = chargeWithdrawalFee(withdrawAmount);
        if (withdrawAmount > fee) {
            TransferHelper.safeTransfer(want, vault, withdrawAmount.sub(fee));
        }
    }

    function harvest() public override whenNotPaused {
        require(msg.sender == tx.origin || msg.sender == address(vault), 'StrategyCake: EOA_or_vault');

        uint256 balanceBefore = IERC20(want).balanceOf(address(this));
        IMasterChef(masterChef).leaveStaking(0);
        uint256 balanceAfter = IERC20(want).balanceOf(address(this));

        uint256 perfAmount = balanceAfter.sub(balanceBefore);
        chargePerformanceFee(perfAmount);
        deposit();
    }

    function deposit() public override whenNotPaused nonReentrant {
        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance > 0) {
            IMasterChef(masterChef).enterStaking(wantBalance);
        }
    }

    function balanceOfPool() public view override returns (uint256) {
        (uint256 amount, ) = IMasterChef(masterChef).userInfo(0, address(this));
        return amount;
    }

    function _giveAllowances() internal override {
        TransferHelper.safeApprove(want, masterChef, 0);
        TransferHelper.safeApprove(want, masterChef, uint256(-1));
    }

    function _removeAllowances() internal override {
        TransferHelper.safeApprove(want, masterChef, 0);
    }

    /* ----- Admin Functions ----- */

    function retireStrat() external override {
        require(msg.sender == vault, '!vault');
        IMasterChef(masterChef).emergencyWithdraw(0);
        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance > 0) {
            TransferHelper.safeTransfer(want, vault, wantBalance);
        }
    }

    function emergencyExit() external override onlyAdmin {
        IMasterChef(masterChef).emergencyWithdraw(0);
        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance > 0) {
            TransferHelper.safeTransfer(want, vault, wantBalance);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

import '../../../interfaces/TraderJoe/IUniswapRouter.sol';
import '../../../interfaces/Scream/IVToken.sol';
import '../../../interfaces/Scream/IComptroller.sol';
import '../../../interfaces/IWooAccessManager.sol';
import '../../../interfaces/IWETH.sol';
import '../BaseStrategy.sol';

contract StrategyScream is BaseStrategy {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    /* ----- State Variables ----- */

    // scFUSDT: https://ftmscan.com/address/0x02224765bc8d54c21bb51b0951c80315e1c263f9
    address public iToken;
    address[] public rewardToWantRoute;
    uint256 public lastHarvest;
    uint256 public supplyBal;

    /* ----- Constant Variables ----- */

    address public constant wrappedEther = address(0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83); // WFTM
    address public constant reward = address(0xe0654C8e6fd4D733349ac7E09f6f23DA256bF475); // SCREAM
    address public constant uniRouter = address(0xF491e7B69E4244ad4002BC14e878a34207E38c29); // SpookySwapRouter
    address public constant comptroller = address(0x260E596DAbE3AFc463e75B6CC05d8c46aCAcFB09); // Unitroller that implement Comptroller

    /* ----- Events ----- */

    event StratHarvest(address indexed harvester, uint256 wantHarvested, uint256 tvl);
    event Deposit(uint256 tvl);
    event Withdraw(uint256 tvl);

    constructor(
        address _vault,
        address _accessManager,
        address _iToken,
        address[] memory _rewardToWantRoute
    ) public BaseStrategy(_vault, _accessManager) {
        iToken = _iToken;
        rewardToWantRoute = _rewardToWantRoute;

        _giveAllowances();
    }

    /* ----- External Functions ----- */

    function beforeDeposit() public override {
        super.beforeDeposit();
        updateSupplyBal();
    }

    function rewardToWant() external view returns (address[] memory) {
        return rewardToWantRoute;
    }

    /* ----- Public Functions ----- */

    function harvest() public override whenNotPaused {
        require(msg.sender == tx.origin || msg.sender == address(vault), 'StrategyScream: EOA_or_vault');

        // When pendingImplementation not zero address, means there is a new implement ready to replace.
        if (IComptroller(comptroller).pendingComptrollerImplementation() == address(0)) {
            uint256 beforeBal = balanceOfWant();

            _harvestAndSwap(rewardToWantRoute);

            uint256 wantHarvested = balanceOfWant().sub(beforeBal);
            uint256 fee = chargePerformanceFee(wantHarvested);
            deposit();

            lastHarvest = block.timestamp;
            emit StratHarvest(msg.sender, wantHarvested.sub(fee), balanceOf());
        } else {
            _withdrawAll();
            pause();
        }
    }

    function deposit() public override whenNotPaused nonReentrant {
        uint256 wantBal = balanceOfWant();

        if (wantBal > 0) {
            IVToken(iToken).mint(wantBal);
            updateSupplyBal();
            emit Deposit(balanceOf());
        }
    }

    function withdraw(uint256 amount) public override nonReentrant {
        require(msg.sender == vault, 'StrategyScream: !vault');
        require(amount > 0, 'StrategyScream: !amount');

        uint256 wantBal = balanceOfWant();

        if (wantBal < amount) {
            IVToken(iToken).redeemUnderlying(amount.sub(wantBal));
            updateSupplyBal();
            uint256 newWantBal = IERC20(want).balanceOf(address(this));
            require(newWantBal > wantBal, 'StrategyScream: !newWantBal');
            wantBal = newWantBal;
        }

        uint256 withdrawAmt = amount < wantBal ? amount : wantBal;

        uint256 fee = chargeWithdrawalFee(withdrawAmt);
        if (withdrawAmt > fee) {
            TransferHelper.safeTransfer(want, vault, withdrawAmt.sub(fee));
        }
        emit Withdraw(balanceOf());
    }

    function updateSupplyBal() public {
        supplyBal = IVToken(iToken).balanceOfUnderlying(address(this));
    }

    function balanceOfPool() public view override returns (uint256) {
        return supplyBal;
    }

    /* ----- Internal Functions ----- */

    function _giveAllowances() internal override {
        TransferHelper.safeApprove(want, iToken, 0);
        TransferHelper.safeApprove(want, iToken, uint256(-1));
        TransferHelper.safeApprove(reward, uniRouter, 0);
        TransferHelper.safeApprove(reward, uniRouter, uint256(-1));
        TransferHelper.safeApprove(wrappedEther, uniRouter, 0);
        TransferHelper.safeApprove(wrappedEther, uniRouter, uint256(-1));
    }

    function _removeAllowances() internal override {
        TransferHelper.safeApprove(want, iToken, 0);
        TransferHelper.safeApprove(reward, uniRouter, 0);
        TransferHelper.safeApprove(wrappedEther, uniRouter, 0);
    }

    function _withdrawAll() internal {
        uint256 iTokenBal = IERC20(iToken).balanceOf(address(this));
        if (iTokenBal > 0) {
            IVToken(iToken).redeem(iTokenBal);
        }
        updateSupplyBal();
    }

    /* ----- Private Functions ----- */

    function _harvestAndSwap(address[] memory _route) private {
        address[] memory markets = new address[](1);
        markets[0] = iToken;
        IComptroller(comptroller).claimComp(address(this), markets);

        // in case of reward token is native token (ETH/BNB/AVAX/FTM)
        uint256 toWrapBal = address(this).balance;
        if (toWrapBal > 0) {
            IWETH(wrappedEther).deposit{value: toWrapBal}();
        }

        uint256 rewardBal = IERC20(reward).balanceOf(address(this));

        // rewardBal == 0: means the current token reward ended
        // reward == want: no need to swap
        if (rewardBal > 0 && reward != want) {
            require(_route.length > 0, 'StrategyScream: SWAP_ROUTE_INVALID');
            IUniswapRouter(uniRouter).swapExactTokensForTokens(rewardBal, 0, _route, address(this), now);
        }
    }

    /* ----- Admin Functions ----- */

    function retireStrat() external override {
        require(msg.sender == vault, 'StrategyScream: !vault');
        _withdrawAll();
        uint256 wantBal = IERC20(want).balanceOf(address(this));
        if (wantBal > 0) {
            TransferHelper.safeTransfer(want, vault, wantBal);
        }
    }

    function emergencyExit() external override onlyAdmin {
        _withdrawAll();
        uint256 wantBal = IERC20(want).balanceOf(address(this));
        if (wantBal > 0) {
            TransferHelper.safeTransfer(want, vault, wantBal);
        }
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IVToken is IERC20 {
    function underlying() external returns (address);

    function mint(uint256 mintAmount) external returns (uint256);

    function redeem(uint256 redeemTokens) external returns (uint256);

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

    function borrow(uint256 borrowAmount) external returns (uint256);

    function repayBorrow(uint256 repayAmount) external returns (uint256);

    function balanceOfUnderlying(address owner) external returns (uint256);

    function borrowBalanceCurrent(address account) external returns (uint256);

    function comptroller() external returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IComptroller {
    function claimComp(address holder, address[] calldata _iTokens) external;

    function claimComp(address holder) external;

    function enterMarkets(address[] memory _iTokens) external;

    function pendingComptrollerImplementation() external view returns (address implementation);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

import '../../../interfaces/TraderJoe/IUniswapRouter.sol';
import '../../../interfaces/Geist/IDataProvider.sol';
import '../../../interfaces/Geist/IIncentivesController.sol';
import '../../../interfaces/Geist/ILendingPool.sol';
import '../../../interfaces/Geist/IMultiFeeDistribution.sol';
import '../../../interfaces/IWooAccessManager.sol';
import '../../../interfaces/IWETH.sol';
import '../BaseStrategy.sol';

contract StrategyGeist is BaseStrategy {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct TokenAddresses {
        address token; // Deposit Token
        address gToken; // Token that minted by lend
    }

    /* ----- State Variables ----- */

    TokenAddresses public wantToken;
    TokenAddresses[] public rewards;

    address[] public rewardToWNativeRoute;
    address[] public wNativeToWantRoute;
    address[][] public extraRewardToWNativeRoutes;

    uint256 public lastHarvest;

    /* ----- Constant Variables ----- */

    address public constant wNative = address(0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83); // WFTM
    address public constant reward = address(0xd8321AA83Fb0a4ECd6348D4577431310A6E0814d); // GEIST
    address public constant uniRouter = address(0xF491e7B69E4244ad4002BC14e878a34207E38c29); // SpookySwapRouter

    address public dataProvider = address(0xf3B0611e2E4D2cd6aB4bb3e01aDe211c3f42A8C3);
    address public lendingPool = address(0x9FAD24f572045c7869117160A571B2e50b10d068);
    address public multiFeeDistribution = address(0x49c93a95dbcc9A6A4D8f77E59c038ce5020e82f8);
    address public incentivesController = address(0x297FddC5c33Ef988dd03bd13e162aE084ea1fE57);

    /* ----- Events ----- */

    event StratHarvest(address indexed harvester, uint256 wantHarvested, uint256 tvl);
    event Deposit(uint256 tvl);
    event Withdraw(uint256 tvl);

    constructor(
        address _vault,
        address _accessManager,
        address _want,
        address[] memory _rewardToWNativeRoute,
        address[] memory _wNativeToWantRoute,
        address[][] memory _extraRewardToWNativeRoutes
    ) public BaseStrategy(_vault, _accessManager) {
        (address gToken, , ) = IDataProvider(dataProvider).getReserveTokensAddresses(_want);
        wantToken = TokenAddresses(_want, gToken);

        rewardToWNativeRoute = _rewardToWNativeRoute;
        wNativeToWantRoute = _wNativeToWantRoute;
        extraRewardToWNativeRoutes = _extraRewardToWNativeRoutes;

        for (uint256 i; i < extraRewardToWNativeRoutes.length; i++) {
            address _token = extraRewardToWNativeRoutes[i][0];
            (address _gToken, , ) = IDataProvider(dataProvider).getReserveTokensAddresses(_token);
            rewards.push(TokenAddresses(_token, _gToken));
        }

        _giveAllowances();
    }

    /* ----- External Functions ----- */

    function rewardToWNative() external view returns (address[] memory) {
        return rewardToWNativeRoute;
    }

    /* ----- Public Functions ----- */

    function harvest() public override whenNotPaused {
        require(msg.sender == tx.origin || msg.sender == address(vault), 'StrategyGeist: EOA_or_vault');

        uint256 reserveWantGTokenBal = IERC20(wantToken.gToken).balanceOf(address(this));
        address[] memory tokens = new address[](1);
        tokens[0] = wantToken.gToken;
        // Claim pending rewards for one or more pools.
        // Rewards are not received directly, they are minted by the rewardMinter.
        IIncentivesController(incentivesController).claim(address(this), tokens);
        // Withdraw full unlocked balance and claim pending rewards
        IMultiFeeDistribution(multiFeeDistribution).exit();

        uint256 rewardBal = IERC20(reward).balanceOf(address(this));
        if (rewardBal > 0) {
            uint256 beforeBal = balanceOfWant();
            _swapRewards(reserveWantGTokenBal);
            uint256 wantHarvested = balanceOfWant().sub(beforeBal);
            uint256 fee = chargePerformanceFee(wantHarvested);
            deposit();

            lastHarvest = block.timestamp;
            emit StratHarvest(msg.sender, wantHarvested.sub(fee), balanceOf());
        }

        uint256 wantGTokenBalAfter = IERC20(wantToken.gToken).balanceOf(address(this));
        require(wantGTokenBalAfter >= reserveWantGTokenBal, 'StrategyGeist: gTokenBalError');
    }

    function deposit() public override whenNotPaused nonReentrant {
        uint256 wantBal = balanceOfWant();

        if (wantBal > 0) {
            ILendingPool(lendingPool).deposit(want, wantBal, address(this), 0);
            emit Deposit(balanceOf());
        }
    }

    function withdraw(uint256 amount) public override nonReentrant {
        require(msg.sender == vault, 'StrategyGeist: !vault');
        require(amount > 0, 'StrategyGeist: !amount');

        uint256 wantBal = balanceOfWant();

        if (wantBal < amount) {
            ILendingPool(lendingPool).withdraw(want, amount.sub(wantBal), address(this));
            uint256 newWantBal = IERC20(want).balanceOf(address(this));
            require(newWantBal > wantBal, 'StrategyGeist: !newWantBal');
            wantBal = newWantBal;
        }

        uint256 withdrawAmt = amount < wantBal ? amount : wantBal;

        uint256 fee = chargeWithdrawalFee(withdrawAmt);
        if (withdrawAmt > fee) {
            TransferHelper.safeTransfer(want, vault, withdrawAmt.sub(fee));
        }
        emit Withdraw(balanceOf());
    }

    function userReserves() public view returns (uint256, uint256) {
        (uint256 supplyBal, , uint256 borrowBal, , , , , , ) = IDataProvider(dataProvider).getUserReserveData(
            want,
            address(this)
        );
        return (supplyBal, borrowBal);
    }

    function balanceOfPool() public view override returns (uint256) {
        (uint256 supplyBal, uint256 borrowBal) = userReserves();
        return supplyBal.sub(borrowBal);
    }

    /* ----- Internal Functions ----- */

    function _giveAllowances() internal override {
        TransferHelper.safeApprove(want, lendingPool, uint256(-1));

        TransferHelper.safeApprove(reward, uniRouter, uint256(-1));
        for (uint256 i; i < rewards.length; i++) {
            TransferHelper.safeApprove(rewards[i].token, uniRouter, uint256(-1));
        }
    }

    function _removeAllowances() internal override {
        TransferHelper.safeApprove(want, lendingPool, 0);

        TransferHelper.safeApprove(reward, uniRouter, 0);
        for (uint256 i; i < rewards.length; i++) {
            TransferHelper.safeApprove(rewards[i].token, uniRouter, 0);
        }
    }

    /* ----- Private Functions ----- */

    function _swapRewards(uint256 reserveWantGTokenBal) private {
        // reward to wNative
        uint256 rewardBal = IERC20(reward).balanceOf(address(this));
        IUniswapRouter(uniRouter).swapExactTokensForTokens(rewardBal, 0, rewardToWNativeRoute, address(this), now);

        for (uint256 i; i < rewards.length; i++) {
            uint256 gTokenToWithdraw = IERC20(rewards[i].gToken).balanceOf(address(this));

            // if reward is wantToken, we have to substrate the reserved gToken balance.
            if (rewards[i].gToken == wantToken.gToken) {
                gTokenToWithdraw = gTokenToWithdraw.sub(reserveWantGTokenBal);
            }

            if (gTokenToWithdraw > 0) {
                // gToken to the underlying asset
                ILendingPool(lendingPool).withdraw(rewards[i].token, gTokenToWithdraw, address(this));

                if (rewards[i].token != wNative && rewards[i].token != wantToken.token) {
                    uint256 tokenToSwap = IERC20(rewards[i].token).balanceOf(address(this));
                    IUniswapRouter(uniRouter).swapExactTokensForTokens(
                        tokenToSwap,
                        0,
                        extraRewardToWNativeRoutes[i],
                        address(this),
                        now
                    );
                }
            }
        }

        uint256 wNativeBal = IERC20(wNative).balanceOf(address(this));
        if (wNative != want && wNativeBal > 0) {
            IUniswapRouter(uniRouter).swapExactTokensForTokens(wNativeBal, 0, wNativeToWantRoute, address(this), now);
        }
    }

    /* ----- Admin Functions ----- */

    function addRewardToNativeRoute(address[] memory _rewardToWNativeRoute) external onlyAdmin {
        address _token = _rewardToWNativeRoute[0];
        (address _gToken, , ) = IDataProvider(dataProvider).getReserveTokensAddresses(_token);

        rewards.push(TokenAddresses(_token, _gToken));
        extraRewardToWNativeRoutes.push(_rewardToWNativeRoute);

        TransferHelper.safeApprove(_token, uniRouter, uint256(-1));
    }

    function removeRewardToWNativeRoute() external onlyAdmin {
        IERC20(rewards[rewards.length - 1].token).safeApprove(uniRouter, 0);

        rewards.pop();
        extraRewardToWNativeRoutes.pop();
    }

    function retireStrat() external override {
        require(msg.sender == vault, 'StrategyGeist: !vault');
        ILendingPool(lendingPool).withdraw(want, type(uint256).max, address(this));
        uint256 wantBal = IERC20(want).balanceOf(address(this));
        if (wantBal > 0) {
            TransferHelper.safeTransfer(want, vault, wantBal);
        }
    }

    function emergencyExit() external override onlyAdmin {
        ILendingPool(lendingPool).withdraw(want, type(uint256).max, address(this));
        uint256 wantBal = IERC20(want).balanceOf(address(this));
        if (wantBal > 0) {
            TransferHelper.safeTransfer(want, vault, wantBal);
        }
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IDataProvider {
    function getReserveTokensAddresses(address asset)
        external
        view
        returns (
            address aTokenAddress,
            address stableDebtTokenAddress,
            address variableDebtTokenAddress
        );

    function getUserReserveData(address asset, address user)
        external
        view
        returns (
            uint256 currentATokenBalance,
            uint256 currentStableDebt,
            uint256 currentVariableDebt,
            uint256 principalStableDebt,
            uint256 scaledVariableDebt,
            uint256 stableBorrowRate,
            uint256 liquidityRate,
            uint40 stableRateLastUpdated,
            bool usageAsCollateralEnabled
        );
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IIncentivesController {
    function claimableReward(address _user, address[] calldata _tokens) external view returns (uint256[] memory);

    function claim(address _user, address[] calldata _tokens) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface ILendingPool {
    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;

    function repay(
        address asset,
        uint256 amount,
        uint256 rateMode,
        address onBehalfOf
    ) external returns (uint256);

    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);

    function getUserAccountData(address user)
        external
        view
        returns (
            uint256 totalCollateralETH,
            uint256 totalDebtETH,
            uint256 availableBorrowsETH,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        );
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

interface IMultiFeeDistribution {
    struct RewardData {
        address token;
        uint256 amount;
    }

    function claimableRewards(address account) external view returns (RewardData[] memory rewards);

    function exit() external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

import '../../../interfaces/TraderJoe/IUniswapRouter.sol';
import '../../../interfaces/Curve/ICurveSwap.sol';
import '../../../interfaces/Curve/IRewardsGauge.sol';
import '../BaseStrategy.sol';

contract StrategyCurveLP is BaseStrategy {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    /* ----- State Variables ----- */

    // Tokens used
    address public crv;
    address public coReward; // cooperation reward
    address public wNative; // wrapped native
    address public depositToken;

    // Third party contracts
    address public rewardsGauge;
    address public pool;
    uint256 public immutable poolSize;
    uint256 public depositIndex;
    bool public useUnderlying;

    // Routes
    address[] public crvToWNativeRoute;
    address[] public coRewardToWNativeRoute;
    address[] public wNativeToDepositRoute;

    address public crvRouter;
    address public uniRouter;

    uint256 public lastHarvest;

    /* ----- Events ----- */

    event StratHarvest(address indexed harvester, uint256 wantHarvested, uint256 tvl);
    event Deposit(uint256 tvl);
    event Withdraw(uint256 tvl);

    constructor(
        address initVault,
        address initAccessManager,
        address initRewardsGauge,
        address initPool,
        uint256 initPoolSize,
        uint256 initDepositIndex,
        bool initUseUnderLying,
        address[] memory initCrvToWNativeRoute,
        address[] memory initCoRewardToWNativeRoute,
        address[] memory initWNativeToDepositRoute,
        address initUniRouter
    ) public BaseStrategy(initVault, initAccessManager) {
        rewardsGauge = initRewardsGauge;
        pool = initPool;
        poolSize = initPoolSize;
        depositIndex = initDepositIndex;
        useUnderlying = initUseUnderLying;

        crv = initCrvToWNativeRoute[0];
        coReward = initCoRewardToWNativeRoute[0];
        wNative = initCrvToWNativeRoute[initCrvToWNativeRoute.length - 1];
        crvToWNativeRoute = initCrvToWNativeRoute;
        coRewardToWNativeRoute = initCoRewardToWNativeRoute;
        crvRouter = initUniRouter;

        require(initWNativeToDepositRoute[0] == wNative, 'StrategyCurveLP: initWNativeToDepositRoute[0] != wNative');
        depositToken = initWNativeToDepositRoute[initWNativeToDepositRoute.length - 1];
        wNativeToDepositRoute = initWNativeToDepositRoute;
        uniRouter = initUniRouter;

        _giveAllowances();
    }

    /* ----- External Functions ----- */

    function crvToWNative() external view returns (address[] memory) {
        return crvToWNativeRoute;
    }

    function coRewardToWNative() external view returns (address[] memory) {
        return coRewardToWNativeRoute;
    }

    function wNativeToDeposit() external view returns (address[] memory) {
        return wNativeToDepositRoute;
    }

    /* ----- Public Functions ----- */

    function harvest() public override whenNotPaused {
        require(msg.sender == tx.origin || msg.sender == vault, 'StrategyCurveLP: !EOA or !Vault');

        IRewardsGauge(rewardsGauge).claim_rewards(address(this));
        uint256 crvBal = IERC20(crv).balanceOf(address(this));
        uint256 coRewardBal = 0;
        if (coReward != address(0)) {
            coRewardBal = IERC20(coReward).balanceOf(address(this));
        }
        uint256 wNativeBal = IERC20(wNative).balanceOf(address(this));
        if (wNativeBal > 0 || crvBal > 0 || coRewardBal > 0) {
            uint256 beforeBal = balanceOfWant();
            _addLiquidity();
            uint256 wantHarvested = balanceOfWant().sub(beforeBal);
            uint256 fee = chargePerformanceFee(wantHarvested);
            deposit();
            lastHarvest = block.timestamp;
            emit StratHarvest(msg.sender, wantHarvested.sub(fee), balanceOf());
        }
    }

    function deposit() public override whenNotPaused nonReentrant {
        uint256 wantBal = balanceOfWant();

        if (wantBal > 0) {
            IRewardsGauge(rewardsGauge).deposit(wantBal);
            emit Deposit(balanceOf());
        }
    }

    function withdraw(uint256 amount) public override nonReentrant {
        require(msg.sender == vault, 'StrategyCurveLP: !Vault');
        require(amount > 0, 'StrategyCurveLP: !amount');

        uint256 wantBal = balanceOfWant();

        if (wantBal < amount) {
            IRewardsGauge(rewardsGauge).withdraw(amount.sub(wantBal));
            wantBal = IERC20(want).balanceOf(address(this));
        }

        uint256 withdrawAmt = amount < wantBal ? amount : wantBal;

        uint256 fee = chargeWithdrawalFee(withdrawAmt);
        if (withdrawAmt > fee) {
            TransferHelper.safeTransfer(want, vault, withdrawAmt.sub(fee));
        }
        emit Withdraw(balanceOf());
    }

    function balanceOfPool() public view override returns (uint256) {
        return IRewardsGauge(rewardsGauge).balanceOf(address(this));
    }

    /* ----- Internal Functions ----- */

    function _giveAllowances() internal override {
        TransferHelper.safeApprove(want, rewardsGauge, 0);
        TransferHelper.safeApprove(want, rewardsGauge, uint256(-1));
        TransferHelper.safeApprove(crv, crvRouter, 0);
        TransferHelper.safeApprove(crv, crvRouter, uint256(-1));
        if (coReward != address(0)) {
            TransferHelper.safeApprove(coReward, uniRouter, 0);
            TransferHelper.safeApprove(coReward, uniRouter, uint256(-1));
        }
        TransferHelper.safeApprove(wNative, uniRouter, 0);
        TransferHelper.safeApprove(wNative, uniRouter, uint256(-1));
        TransferHelper.safeApprove(depositToken, pool, 0);
        TransferHelper.safeApprove(depositToken, pool, uint256(-1));
    }

    function _removeAllowances() internal override {
        TransferHelper.safeApprove(want, rewardsGauge, 0);
        if (coReward != address(0)) {
            TransferHelper.safeApprove(coReward, uniRouter, 0);
        }
        TransferHelper.safeApprove(wNative, uniRouter, 0);
        TransferHelper.safeApprove(crv, crvRouter, 0);
        TransferHelper.safeApprove(depositToken, pool, 0);
    }

    function _addLiquidity() internal {
        uint256 crvBal = IERC20(crv).balanceOf(address(this));
        if (crvBal > 0) {
            IUniswapRouter(crvRouter).swapExactTokensForTokens(
                crvBal,
                0,
                crvToWNativeRoute,
                address(this),
                block.timestamp
            );
        }

        if (coReward != address(0)) {
            uint256 coRewardBal = IERC20(coReward).balanceOf(address(this));
            if (coRewardBal > 0) {
                IUniswapRouter(uniRouter).swapExactTokensForTokens(
                    coRewardBal,
                    0,
                    coRewardToWNativeRoute,
                    address(this),
                    block.timestamp
                );
            }
        }

        uint256 wNativeBal = IERC20(wNative).balanceOf(address(this));
        if (depositToken != wNative) {
            IUniswapRouter(uniRouter).swapExactTokensForTokens(
                wNativeBal,
                0,
                wNativeToDepositRoute,
                address(this),
                block.timestamp
            );
        }

        uint256 depositBal = IERC20(depositToken).balanceOf(address(this));

        if (poolSize == 2) {
            uint256[2] memory amounts;
            amounts[depositIndex] = depositBal;
            if (useUnderlying) ICurveSwap2(pool).add_liquidity(amounts, 0, true);
            else ICurveSwap2(pool).add_liquidity(amounts, 0);
        } else if (poolSize == 3) {
            uint256[3] memory amounts;
            amounts[depositIndex] = depositBal;
            if (useUnderlying) ICurveSwap3(pool).add_liquidity(amounts, 0, true);
            else ICurveSwap3(pool).add_liquidity(amounts, 0);
        } else if (poolSize == 4) {
            uint256[4] memory amounts;
            amounts[depositIndex] = depositBal;
            ICurveSwap4(pool).add_liquidity(amounts, 0);
        } else if (poolSize == 5) {
            uint256[5] memory amounts;
            amounts[depositIndex] = depositBal;
            ICurveSwap5(pool).add_liquidity(amounts, 0);
        }
    }

    /* ----- Admin Functions ----- */

    function setCrvRoute(address newCrvRouter, address[] memory newCrvToWNativeRoute) external onlyAdmin {
        require(newCrvToWNativeRoute[0] == crv, 'StrategyCurveLP: !crv');
        require(newCrvToWNativeRoute[newCrvToWNativeRoute.length - 1] == wNative, 'StrategyCurveLP: !wNative');

        _removeAllowances();
        crvToWNativeRoute = newCrvToWNativeRoute;
        crvRouter = newCrvRouter;
        _giveAllowances();
    }

    function retireStrat() external override {
        require(msg.sender == vault, 'StrategyCurveLP: !Vault');
        IRewardsGauge(rewardsGauge).withdraw(balanceOfPool());
        uint256 wantBal = IERC20(want).balanceOf(address(this));
        if (wantBal > 0) {
            TransferHelper.safeTransfer(want, vault, wantBal);
        }
    }

    function emergencyExit() external override onlyAdmin {
        IRewardsGauge(rewardsGauge).withdraw(balanceOfPool());
        uint256 wantBal = IERC20(want).balanceOf(address(this));
        if (wantBal > 0) {
            TransferHelper.safeTransfer(want, vault, wantBal);
        }
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface ICurveSwap2 {
    function add_liquidity(uint256[2] memory amounts, uint256 min_mint_amount) external;

    function add_liquidity(
        uint256[2] memory amounts,
        uint256 min_mint_amount,
        bool _use_underlying
    ) external;
}

interface ICurveSwap3 {
    function add_liquidity(uint256[3] memory amounts, uint256 min_mint_amount) external;

    function add_liquidity(
        uint256[3] memory amounts,
        uint256 min_mint_amount,
        bool _use_underlying
    ) external;
}

interface ICurveSwap4 {
    function add_liquidity(uint256[4] memory amounts, uint256 min_mint_amount) external;
}

interface ICurveSwap5 {
    function add_liquidity(uint256[5] memory amounts, uint256 min_mint_amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IRewardsGauge {
    function balanceOf(address account) external view returns (uint256);

    function claimable_reward(address user, address token) external view returns (uint256);

    function claim_rewards(address user) external;

    function deposit(uint256 value) external;

    function withdraw(uint256 value) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

import '../../../interfaces/BankerJoe/IJoeRouter.sol';
import '../../../interfaces/BankerJoe/IVToken.sol';
import '../../../interfaces/BankerJoe/IComptroller.sol';
import '../../../interfaces/IWooAccessManager.sol';
import '../../../interfaces/IWETH.sol';
import '../BaseStrategy.sol';

contract StrategyBenqi is BaseStrategy {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    /* ----- State Variables ----- */

    // list of benqi markets
    // qiAvax:  0x5C0401e81Bc07Ca70fAD469b451682c0d747Ef1c  https://snowtrace.io/address/0x5c0401e81bc07ca70fad469b451682c0d747ef1c
    // qiBTC:   0xe194c4c5aC32a3C9ffDb358d9Bfd523a0B6d1568  https://snowtrace.io/address/0xe194c4c5ac32a3c9ffdb358d9bfd523a0b6d1568
    // qiETH:   0x334AD834Cd4481BB02d09615E7c11a00579A7909  https://snowtrace.io/address/0x334ad834cd4481bb02d09615e7c11a00579a7909
    // qiUSDT:  0xc9e5999b8e75C3fEB117F6f73E664b9f3C8ca65C  https://snowtrace.io/address/0xc9e5999b8e75c3feb117f6f73e664b9f3c8ca65c
    // qiLink:  0x4e9f683A27a6BdAD3FC2764003759277e93696e6  https://snowtrace.io/address/0x4e9f683a27a6bdad3fc2764003759277e93696e6
    // qiDai:   0x835866d37AFB8CB8F8334dCCdaf66cf01832Ff5D  https://snowtrace.io/address/0x835866d37AFB8CB8F8334dCCdaf66cf01832Ff5D
    // qiUSDC:  0xBEb5d47A3f720Ec0a390d04b4d41ED7d9688bC7F  https://snowtrace.io/address/0xbeb5d47a3f720ec0a390d04b4d41ed7d9688bc7f
    // qiQi:    0x35Bd6aedA81a7E5FC7A7832490e71F757b0cD9Ce  https://snowtrace.io/address/0x35bd6aeda81a7e5fc7a7832490e71f757b0cd9ce
    address public qiToken;

    address[] public reward1ToWantRoute;
    address[] public reward2ToWantRoute;
    uint256 public lastHarvest;
    uint256 public supplyBal;

    /* ----- Constant Variables ----- */

    address public constant wrappedEther = address(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7); // WAVAX
    address public constant reward1 = address(0x8729438EB15e2C8B576fCc6AeCdA6A148776C0F5); // Qi token
    address public constant reward2 = wrappedEther; // Wavax token
    address public constant uniRouter = address(0x60aE616a2155Ee3d9A68541Ba4544862310933d4); // JoeRouter
    address public constant comptroller = address(0x486Af39519B4Dc9a7fCcd318217352830E8AD9b4); // to claim reward

    /* ----- Events ----- */

    event StratHarvest(address indexed harvester, uint256 wantHarvested, uint256 tvl);
    event Deposit(uint256 tvl);
    event Withdraw(uint256 tvl);

    constructor(
        address initVault,
        address initAccessManager,
        address initQiToken,
        address[] memory initReward1ToWantRoute,
        address[] memory initReward2ToWantRoute
    ) public BaseStrategy(initVault, initAccessManager) {
        qiToken = initQiToken;
        reward1ToWantRoute = initReward1ToWantRoute;
        reward2ToWantRoute = initReward2ToWantRoute;

        _giveAllowances();
    }

    /* ----- External Functions ----- */

    function beforeDeposit() public override {
        super.beforeDeposit();
        updateSupplyBal();
    }

    function reward1ToWant() external view returns (address[] memory) {
        return reward1ToWantRoute;
    }

    function reward2ToWant() external view returns (address[] memory) {
        return reward2ToWantRoute;
    }

    /* ----- Public Functions ----- */

    function harvest() public override whenNotPaused {
        require(msg.sender == tx.origin || msg.sender == address(vault), 'StrategyBenqi: EOA_or_vault');

        // When pendingImplementation not zero address, means there is a new implement ready to replace.
        if (IComptroller(comptroller).pendingComptrollerImplementation() == address(0)) {
            uint256 beforeBal = balanceOfWant();

            _harvestAndSwap(0, reward1, reward1ToWantRoute);
            _harvestAndSwap(1, reward2, reward2ToWantRoute);

            uint256 wantHarvested = balanceOfWant().sub(beforeBal);
            uint256 fee = chargePerformanceFee(wantHarvested);
            deposit();

            lastHarvest = block.timestamp;
            emit StratHarvest(msg.sender, wantHarvested.sub(fee), balanceOf());
        } else {
            _withdrawAll();
            pause();
        }
    }

    function _harvestAndSwap(
        uint8 index,
        address reward,
        address[] memory route
    ) private {
        address[] memory markets = new address[](1);
        markets[0] = qiToken;
        IComptroller(comptroller).claimReward(index, address(this), markets);

        // in case of reward token is native token (ETH/BNB/Avax)
        uint256 toWrapBal = address(this).balance;
        if (toWrapBal > 0) {
            IWETH(wrappedEther).deposit{value: toWrapBal}();
        }

        uint256 rewardBal = IERC20(reward).balanceOf(address(this));

        // rewardBal == 0: means the current token reward ended
        // reward == want: no need to swap
        if (rewardBal > 0 && reward != want) {
            require(route.length > 0, 'StrategyBenqi: SWAP_ROUTE_INVALID');
            IJoeRouter(uniRouter).swapExactTokensForTokens(rewardBal, 0, route, address(this), now);
        }
    }

    function deposit() public override whenNotPaused nonReentrant {
        uint256 wantBal = balanceOfWant();

        if (wantBal > 0) {
            IVToken(qiToken).mint(wantBal);
            updateSupplyBal();
            emit Deposit(balanceOf());
        }
    }

    function withdraw(uint256 amount) public override nonReentrant {
        require(msg.sender == vault, 'StrategyBenqi: !vault');
        require(amount > 0, 'StrategyBenqi: !amount');

        uint256 wantBal = balanceOfWant();

        if (wantBal < amount) {
            IVToken(qiToken).redeemUnderlying(amount.sub(wantBal));
            updateSupplyBal();
            uint256 newWantBal = IERC20(want).balanceOf(address(this));
            require(newWantBal > wantBal, 'StrategyBenqi: !newWantBal');
            wantBal = newWantBal;
        }

        uint256 withdrawAmt = amount < wantBal ? amount : wantBal;

        uint256 fee = chargeWithdrawalFee(withdrawAmt);
        if (withdrawAmt > fee) {
            TransferHelper.safeTransfer(want, vault, withdrawAmt.sub(fee));
        }
        emit Withdraw(balanceOf());
    }

    function updateSupplyBal() public {
        supplyBal = IVToken(qiToken).balanceOfUnderlying(address(this));
    }

    function balanceOfPool() public view override returns (uint256) {
        return supplyBal;
    }

    /* ----- Internal Functions ----- */

    function _giveAllowances() internal override {
        TransferHelper.safeApprove(want, qiToken, 0);
        TransferHelper.safeApprove(want, qiToken, uint256(-1));
        TransferHelper.safeApprove(reward1, uniRouter, 0);
        TransferHelper.safeApprove(reward1, uniRouter, uint256(-1));
        TransferHelper.safeApprove(reward2, uniRouter, 0);
        TransferHelper.safeApprove(reward2, uniRouter, uint256(-1));
        TransferHelper.safeApprove(wrappedEther, uniRouter, 0);
        TransferHelper.safeApprove(wrappedEther, uniRouter, uint256(-1));
    }

    function _removeAllowances() internal override {
        TransferHelper.safeApprove(want, qiToken, 0);
        TransferHelper.safeApprove(reward1, uniRouter, 0);
        TransferHelper.safeApprove(reward2, uniRouter, 0);
        TransferHelper.safeApprove(wrappedEther, uniRouter, 0);
    }

    function _withdrawAll() internal {
        uint256 qiTokenBal = IERC20(qiToken).balanceOf(address(this));
        if (qiTokenBal > 0) {
            IVToken(qiToken).redeem(qiTokenBal);
        }
        updateSupplyBal();
    }

    /* ----- Admin Functions ----- */

    function retireStrat() external override {
        require(msg.sender == vault, 'StrategyBenqi: !vault');
        _withdrawAll();
        uint256 wantBal = IERC20(want).balanceOf(address(this));
        if (wantBal > 0) {
            TransferHelper.safeTransfer(want, vault, wantBal);
        }
    }

    function emergencyExit() external override onlyAdmin {
        _withdrawAll();
        uint256 wantBal = IERC20(want).balanceOf(address(this));
        if (wantBal > 0) {
            TransferHelper.safeTransfer(want, vault, wantBal);
        }
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IJoeRouter {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IVToken is IERC20 {
    function underlying() external returns (address);

    function mint(uint256 mintAmount) external returns (uint256);

    function redeem(uint256 redeemTokens) external returns (uint256);

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

    function borrow(uint256 borrowAmount) external returns (uint256);

    function repayBorrow(uint256 repayAmount) external returns (uint256);

    function balanceOfUnderlying(address owner) external returns (uint256);

    function borrowBalanceCurrent(address account) external returns (uint256);

    function comptroller() external returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IComptroller {
    function claimComp(address holder, address[] calldata _iTokens) external;

    function claimComp(address holder) external;

    function compAccrued(address holder) external view returns (uint256 comp);

    function enterMarkets(address[] memory _iTokens) external;

    function pendingImplementation() external view returns (address implementation);

    function claimReward(uint8 rewardType, address payable holder) external;

    function claimReward(
        uint8 rewardType,
        address payable holder,
        address[] memory _iTokens
    ) external;

    // Benqi comptroller admin method
    function pendingComptrollerImplementation() external view returns (address implementation);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

import '../../../interfaces/BankerJoe/IJoeRouter.sol';
import '../../../interfaces/BankerJoe/IVToken.sol';
import '../../../interfaces/BankerJoe/IComptroller.sol';
import '../../../interfaces/IWooAccessManager.sol';
import '../../../interfaces/IWETH.sol';
import '../BaseStrategy.sol';

contract StrategyBankerJoe is BaseStrategy {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    /* ----- State Variables ----- */

    address public iToken;
    address[] public reward1ToWantRoute;
    address[] public reward2ToWantRoute;
    uint256 public lastHarvest;
    uint256 public supplyBal;

    /* ----- Constant Variables ----- */

    address public constant wrappedEther = address(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7); // WAVAX
    address public constant reward1 = address(0x6e84a6216eA6dACC71eE8E6b0a5B7322EEbC0fDd); // JOE
    address public constant reward2 = wrappedEther; // WAVAX
    address public constant uniRouter = address(0x60aE616a2155Ee3d9A68541Ba4544862310933d4); // JoeRouter
    address public constant comptroller = address(0xdc13687554205E5b89Ac783db14bb5bba4A1eDaC);

    /* ----- Events ----- */

    event StratHarvest(address indexed harvester, uint256 wantHarvested, uint256 tvl);
    event Deposit(uint256 tvl);
    event Withdraw(uint256 tvl);

    constructor(
        address initVault,
        address initAccessManager,
        address initIToken,
        address[] memory initReward1ToWantRoute,
        address[] memory initReward2ToWantRoute
    ) public BaseStrategy(initVault, initAccessManager) {
        iToken = initIToken;
        reward1ToWantRoute = initReward1ToWantRoute;
        reward2ToWantRoute = initReward2ToWantRoute;

        _giveAllowances();
    }

    /* ----- External Functions ----- */

    function beforeDeposit() public override {
        super.beforeDeposit();
        updateSupplyBal();
    }

    function reward1ToWant() external view returns (address[] memory) {
        return reward1ToWantRoute;
    }

    function reward2ToWant() external view returns (address[] memory) {
        return reward2ToWantRoute;
    }

    /* ----- Public Functions ----- */

    function harvest() public override whenNotPaused {
        require(msg.sender == tx.origin || msg.sender == address(vault), 'StrategyBankerJoe: EOA_or_vault');

        // When pendingImplementation not zero address, means there is a new implement ready to replace.
        if (IComptroller(comptroller).pendingImplementation() == address(0)) {
            uint256 beforeBal = balanceOfWant();

            _harvestAndSwap(0, reward1, reward1ToWantRoute);
            _harvestAndSwap(1, reward2, reward2ToWantRoute);

            uint256 wantHarvested = balanceOfWant().sub(beforeBal);
            uint256 fee = chargePerformanceFee(wantHarvested);
            deposit();

            lastHarvest = block.timestamp;
            emit StratHarvest(msg.sender, wantHarvested.sub(fee), balanceOf());
        } else {
            _withdrawAll();
            pause();
        }
    }

    function deposit() public override whenNotPaused nonReentrant {
        uint256 wantBal = balanceOfWant();

        if (wantBal > 0) {
            IVToken(iToken).mint(wantBal);
            updateSupplyBal();
            emit Deposit(balanceOf());
        }
    }

    function withdraw(uint256 amount) public override nonReentrant {
        require(msg.sender == vault, 'StrategyBankerJoe: !vault');
        require(amount > 0, 'StrategyBankerJoe: !amount');

        uint256 wantBal = balanceOfWant();

        if (wantBal < amount) {
            IVToken(iToken).redeemUnderlying(amount.sub(wantBal));
            updateSupplyBal();
            uint256 newWantBal = IERC20(want).balanceOf(address(this));
            require(newWantBal > wantBal, 'StrategyBankerJoe: !newWantBal');
            wantBal = newWantBal;
        }

        uint256 withdrawAmt = amount < wantBal ? amount : wantBal;

        uint256 fee = chargeWithdrawalFee(withdrawAmt);
        if (withdrawAmt > fee) {
            TransferHelper.safeTransfer(want, vault, withdrawAmt.sub(fee));
        }
        emit Withdraw(balanceOf());
    }

    function updateSupplyBal() public {
        supplyBal = IVToken(iToken).balanceOfUnderlying(address(this));
    }

    function balanceOfPool() public view override returns (uint256) {
        return supplyBal;
    }

    /* ----- Internal Functions ----- */

    function _giveAllowances() internal override {
        TransferHelper.safeApprove(want, iToken, 0);
        TransferHelper.safeApprove(want, iToken, uint256(-1));
        TransferHelper.safeApprove(reward1, uniRouter, 0);
        TransferHelper.safeApprove(reward1, uniRouter, uint256(-1));
        TransferHelper.safeApprove(reward2, uniRouter, 0);
        TransferHelper.safeApprove(reward2, uniRouter, uint256(-1));
        TransferHelper.safeApprove(wrappedEther, uniRouter, 0);
        TransferHelper.safeApprove(wrappedEther, uniRouter, uint256(-1));
    }

    function _removeAllowances() internal override {
        TransferHelper.safeApprove(want, iToken, 0);
        TransferHelper.safeApprove(reward1, uniRouter, 0);
        TransferHelper.safeApprove(reward2, uniRouter, 0);
        TransferHelper.safeApprove(wrappedEther, uniRouter, 0);
    }

    function _withdrawAll() internal {
        uint256 iTokenBal = IERC20(iToken).balanceOf(address(this));
        if (iTokenBal > 0) {
            IVToken(iToken).redeem(iTokenBal);
        }
        updateSupplyBal();
    }

    /* ----- Private Functions ----- */

    function _harvestAndSwap(
        uint8 index,
        address reward,
        address[] memory route
    ) private {
        address[] memory markets = new address[](1);
        markets[0] = iToken;
        IComptroller(comptroller).claimReward(index, address(this), markets);

        // in case of reward token is native token (ETH/BNB/AVAX)
        uint256 toWrapBal = address(this).balance;
        if (toWrapBal > 0) {
            IWETH(wrappedEther).deposit{value: toWrapBal}();
        }

        uint256 rewardBal = IERC20(reward).balanceOf(address(this));

        // rewardBal == 0: means the current token reward ended
        // reward == want: no need to swap
        if (rewardBal > 0 && reward != want) {
            require(route.length > 0, 'StrategyBenqi: SWAP_ROUTE_INVALID');
            IJoeRouter(uniRouter).swapExactTokensForTokens(rewardBal, 0, route, address(this), now);
        }
    }

    /* ----- Admin Functions ----- */

    function retireStrat() external override {
        require(msg.sender == vault, 'StrategyBankerJoe: !vault');
        _withdrawAll();
        uint256 wantBal = IERC20(want).balanceOf(address(this));
        if (wantBal > 0) {
            TransferHelper.safeTransfer(want, vault, wantBal);
        }
    }

    function emergencyExit() external override onlyAdmin {
        _withdrawAll();
        uint256 wantBal = IERC20(want).balanceOf(address(this));
        if (wantBal > 0) {
            TransferHelper.safeTransfer(want, vault, wantBal);
        }
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

import '../../../interfaces/Stargate/ILPStaking.sol';
import '../../../interfaces/Stargate/IStargateRouter.sol';
import '../../../interfaces/Stargate/IStargatePool.sol';
import '../../../interfaces/BankerJoe/IJoeRouter.sol';
import '../BaseStrategy.sol';

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
contract StratStargateStableCompoundV2 is BaseStrategy {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    /* ----- State Variables ----- */

    address public wrappedEther;
    address public uniRouter;

    // DepositPool list:
    // usdc.e pool helper: 0x257D69AA678e0A8DA6DFDA6A16CdF2052A460b45
    IStargateRouter public router;

    uint256 public stakingPid;

    uint8 public balanceSafeRate = 5;

    IStargatePool public pool;

    // Stake LP token to earn $STG
    // BNB chain: https://bscscan.com/address/0x3052a0f6ab15b4ae1df39962d5ddefaca86dab47#code
    ILPStaking public staking;

    address public wantLPToken; // S*BUSD:  deposit busd into pool to get S*BUSD LP token, then further stakes this LP token into LPRouter to get $STG reward

    address public reward; // STG

    address[] public rewardToWantRoute;

    uint256 public lastHarvest;

    uint16 public dstChainId;
    uint256 public srcPoolId;
    uint256 public dstPoolId;
    bool public instantRedeemOnly = true;

    /* ----- Events ----- */

    event StratHarvest(address indexed harvester, uint256 wantHarvested, uint256 tvl);
    event Deposit(uint256 tvl);
    event Withdraw(uint256 tvl);

    constructor(
        address _vault,
        address _accessManager,
        address _uniRouter, // swap router
        address _pool, // pool
        address _staking, // lp staking - Masterchef
        uint256 _stakingPid, // _pid for staking
        address _reward, // $stg
        address[] memory _rewardToWantRoute // $stg -> xxx -> want
    ) public BaseStrategy(_vault, _accessManager) {
        wrappedEther = IVaultV2(_vault).weth();
        uniRouter = _uniRouter;
        pool = IStargatePool(_pool);
        wantLPToken = _pool; // NOTE: pool is LPErc20Token for staking
        router = IStargateRouter(IStargatePool(_pool).router());
        staking = ILPStaking(_staking);
        stakingPid = _stakingPid;
        reward = _reward;
        rewardToWantRoute = _rewardToWantRoute;

        require(pool.token() == want, 'StratStargateStableCompound: !pool_token');

        require(
            rewardToWantRoute.length > 0 &&
                rewardToWantRoute[0] == reward &&
                rewardToWantRoute[rewardToWantRoute.length - 1] == want,
            'StratStargateStableCompound: !route'
        );

        _giveAllowances();
    }

    /* ----- External Functions ----- */

    function rewardToWant() external view returns (address[] memory) {
        return rewardToWantRoute;
    }

    /* ----- Public Functions ----- */

    function harvest() public override whenNotPaused {
        require(msg.sender == tx.origin || msg.sender == address(vault), 'StratStargateStableCompound: EOA_or_vault');

        // NOTE: pool's local available balance
        if (IERC20(want).balanceOf(address(pool)) < balanceOfPool().mul(balanceSafeRate)) {
            _withdrawAll();
            pause();
            return;
        }

        uint256 beforeBal = balanceOfWant();

        staking.deposit(stakingPid, 0); // harvest STG token

        uint256 rewardBal = IERC20(reward).balanceOf(address(this));
        if (rewardBal > 0 && reward != want) {
            IJoeRouter(uniRouter).swapExactTokensForTokens(rewardBal, 0, rewardToWantRoute, address(this), now);
        }

        uint256 wantHarvested = balanceOfWant().sub(beforeBal);
        uint256 fee = chargePerformanceFee(wantHarvested);
        deposit();

        lastHarvest = block.timestamp;
        emit StratHarvest(msg.sender, wantHarvested.sub(fee), balanceOf());
    }

    function deposit() public override whenNotPaused nonReentrant {
        uint256 wantBal = balanceOfWant();
        if (wantBal > 0) {
            router.addLiquidity(pool.poolId(), wantBal, address(this));
            staking.deposit(stakingPid, IERC20(wantLPToken).balanceOf(address(this)));
            emit Deposit(balanceOf());
        }
    }

    function withdraw(uint256 amount) public override nonReentrant {
        require(msg.sender == vault, 'StratStargateStableCompound: !vault');
        require(amount > 0, 'StratStargateStableCompound: !amount');

        uint256 wantBal = balanceOfWant();

        if (wantBal < amount) {
            // local amount usd converted to LP token amount
            uint256 lptokenAmountToWithdraw = _amountLDtoLP(amount.sub(wantBal));

            // lp token unstaked from LPStaking, and then parked here in this strat
            staking.withdraw(stakingPid, lptokenAmountToWithdraw);

            // redeem all the want LP tokens out
            _redeemLocalWantLP();

            uint256 newWantBal = IERC20(want).balanceOf(address(this));
            require(newWantBal > wantBal, 'StratStargateStableCompound: !newWantBal');
            wantBal = newWantBal;
        }

        require(wantBal >= amount.mul(9999).div(10000), 'StratStargateStableCompound: !withdraw');
        uint256 withdrawAmt = amount < wantBal ? amount : wantBal;
        uint256 fee = chargeWithdrawalFee(withdrawAmt);
        if (withdrawAmt > fee) {
            TransferHelper.safeTransfer(want, vault, withdrawAmt.sub(fee));
        }

        emit Withdraw(balanceOf());
    }

    function _redeemLocalWantLP() internal {
        address thisAddr = address(this);
        uint256 lpAmount = IERC20(wantLPToken).balanceOf(thisAddr);

        if (instantRedeemOnly) {
            router.instantRedeemLocal(uint16(pool.poolId()), lpAmount, thisAddr);
            return;
        }

        uint256 capLpAmount = _amountSDtoLP(pool.deltaCredit());
        // check the redeemed amount with the capped local instant redeem amount
        if (lpAmount <= capLpAmount) {
            // NOTE: this means capable of local instant redemption
            router.instantRedeemLocal(uint16(pool.poolId()), lpAmount, thisAddr);
        } else {
            bytes memory to = abi.encodePacked(thisAddr);
            router.redeemLocal(
                dstChainId,
                srcPoolId,
                dstPoolId,
                payable(thisAddr),
                lpAmount,
                to,
                IStargateRouter.lzTxObj(0, 0, to)
            );
        }
    }

    function balanceOfPool() public view override returns (uint256) {
        (uint256 lpAmount, ) = staking.userInfo(stakingPid, address(this));
        return _amountLPtoLD(lpAmount); // lp token amount -> usd local decimal amount
    }

    function maxInstantRedeemLpAmount() public view returns (uint256) {
        return _amountSDtoLP(pool.deltaCredit());
    }

    function canInstantRedeemLocalNow() external view returns (bool) {
        (uint256 lpStakeAmount, ) = staking.userInfo(stakingPid, address(this));
        uint256 capLpAmount = maxInstantRedeemLpAmount();
        return lpStakeAmount <= capLpAmount;
    }

    /* ----- Internal Functions ----- */

    // NOTE: convert from LD (local decimal) to LP token.
    // Follows the logic here: https://bscscan.com/address/0x98a5737749490856b401db5dc27f522fc314a4e1#code
    function _amountLDtoLP(uint256 _amountLD) internal view returns (uint256 amountLP) {
        uint256 totalLiquidity = pool.totalLiquidity();
        uint256 totalSupply = pool.totalSupply();
        require(totalLiquidity > 0, 'Stargate: totalLiquidity_ZERO');
        uint256 amountSD = _amountLD.div(pool.convertRate());
        amountLP = amountSD.mul(totalSupply).div(totalLiquidity); // amountSD / (totalLiquidity / totalSupply)
    }

    function _amountLPtoLD(uint256 _amountLP) internal view returns (uint256 amountLD) {
        uint256 totalLiquidity = pool.totalLiquidity();
        uint256 totalSupply = pool.totalSupply();
        require(totalLiquidity > 0, 'Stargate: cant convert LPtoSD when totalSupply == 0');
        uint256 amountSD = _amountLP.mul(totalLiquidity).div(totalSupply);
        amountLD = amountSD.mul(pool.convertRate());
    }

    function _amountSDtoLP(uint256 _amountSD) internal view returns (uint256) {
        uint256 totalLiquidity = pool.totalLiquidity();
        uint256 totalSupply = pool.totalSupply();
        require(totalLiquidity > 0, 'Stargate: cant convert SDtoLP when totalLiq == 0');
        return _amountSD.mul(totalSupply).div(totalLiquidity);
    }

    function _amountLDtoSD(uint256 _amountLD) internal view returns (uint256 amountSD) {
        amountSD = _amountLD.div(pool.convertRate());
    }

    function _amountSDtoLD(uint256 _amountSD) internal view returns (uint256 amountLD) {
        amountLD = _amountSD.mul(pool.convertRate());
    }

    function _giveAllowances() internal override {
        TransferHelper.safeApprove(want, address(router), 0);
        TransferHelper.safeApprove(want, address(router), uint256(-1));
        TransferHelper.safeApprove(wantLPToken, address(staking), 0);
        TransferHelper.safeApprove(wantLPToken, address(staking), uint256(-1));
        TransferHelper.safeApprove(reward, uniRouter, 0);
        TransferHelper.safeApprove(reward, uniRouter, uint256(-1));
    }

    function _removeAllowances() internal override {
        TransferHelper.safeApprove(want, address(router), 0);
        TransferHelper.safeApprove(wantLPToken, address(staking), 0);
        TransferHelper.safeApprove(reward, uniRouter, 0);
    }

    function _withdrawAll() internal {
        (uint256 lpStakeAmount, ) = staking.userInfo(stakingPid, address(this));
        if (lpStakeAmount > 0) {
            // unstake the LP token from LPStaking to this strat
            staking.withdraw(stakingPid, lpStakeAmount);
            // redeem out all the LP tokens
            _redeemLocalWantLP();
        }
        emit Withdraw(balanceOf());
    }

    /* ----- Admin Functions ----- */

    function setRedeemParams(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId
    ) external onlyAdmin {
        dstChainId = _dstChainId;
        srcPoolId = _srcPoolId;
        dstPoolId = _dstPoolId;
    }

    function setInstantRedeemOnly(bool _instantRedeemOnly) external onlyAdmin {
        instantRedeemOnly = _instantRedeemOnly;
    }

    function setBalanceSafeRate(uint8 _balanceSafeRate) external onlyAdmin {
        balanceSafeRate = _balanceSafeRate;
    }

    function setRewardToWantRoute(address[] calldata _rewardToWantRoute) external onlyAdmin {
        rewardToWantRoute = _rewardToWantRoute;
    }

    function setUniRouter(address _uniRouter) external onlyAdmin {
        uniRouter = _uniRouter;
    }

    function retireStrat() external override {
        require(msg.sender == vault, 'StratStargateStableCompound: !vault');
        // call harvest explicitly if needed
        _withdrawAll();
        uint256 wantBal = IERC20(want).balanceOf(address(this));
        if (wantBal > 0) {
            TransferHelper.safeTransfer(want, vault, wantBal);
        }
    }

    function emergencyExit() external override onlyAdmin {
        _withdrawAll();
        uint256 wantBal = IERC20(want).balanceOf(address(this));
        if (wantBal > 0) {
            TransferHelper.safeTransfer(want, vault, wantBal);
        }
    }

    function emergencyExit1(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        bytes calldata _to,
        IStargateRouter.lzTxObj memory _lzTxParams
    ) external onlyAdmin {
        (uint256 lpStakeAmount, ) = staking.userInfo(stakingPid, address(this));
        staking.withdraw(stakingPid, lpStakeAmount);
        uint256 wantLPAmount = IERC20(wantLPToken).balanceOf(address(this));
        router.redeemLocal(
            _dstChainId, // dstChainId
            _srcPoolId, // srcPoolId
            _dstPoolId, // dstPoolId
            payable(vault), // refund address
            wantLPAmount, // lp token amount
            _to,
            _lzTxParams
        );
    }

    function emergencyExit2(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        bytes calldata _to,
        IStargateRouter.lzTxObj memory _lzTxParams
    ) external onlyAdmin {
        (uint256 lpStakeAmount, ) = staking.userInfo(stakingPid, address(this));
        staking.withdraw(stakingPid, lpStakeAmount);
        uint256 wantLPAmount = IERC20(wantLPToken).balanceOf(address(this));
        router.redeemLocal(
            _dstChainId, // dstChainId
            _srcPoolId, // srcPoolId
            _dstPoolId, // dstPoolId
            payable(address(this)), // refund address
            wantLPAmount, // lp amount
            _to,
            _lzTxParams
        );
        TransferHelper.safeTransfer(want, vault, IERC20(want).balanceOf(address(this)));
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface ILPStaking {
    function deposit(uint256 pid, uint256 amount) external;

    function withdraw(uint256 pid, uint256 amount) external;

    function enterStaking(uint256 amount) external;

    function leaveStaking(uint256 amount) external;

    function emergencyWithdraw(uint256 pid) external;

    function pendingStargate(uint256 _pid, address _user) external view returns (uint256);

    function poolInfo(uint256 pid)
        external
        view
        returns (
            address,
            uint256,
            uint256,
            uint256
        );

    function userInfo(uint256 pid, address user) external view returns (uint256, uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;

interface IStargatePool {
    /**
     * @dev shared id between chains to represent same pool.
     */
    function poolId() external view returns (uint256);

    /**
     * @dev the shared decimals (lowest common decimals between chains);
     *   e.g. typically, decimal = 6
     */
    function sharedDecimals() external view returns (uint256);

    /**
     * @dev the decimals for the underlying asset token (e.g. busd, usdt, usdt.e, usdc, etc)
     */
    function localDecimals() external view returns (uint256);

    /**
     * @dev the token for the pool.
     */
    function token() external view returns (address);

    /**
     * @dev the router for the pool.
     */
    function router() external view returns (address);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev the total amount of tokens added on this side of the chain (fees + deposits - withdrawals)
     */
    function totalLiquidity() external view returns (uint256);

    /**
     * @dev convertRate = 10 ^ (localDecimals - sharedDecimals)
     */
    function convertRate() external view returns (uint256);

    /**
     * @dev total weight for pool percentages
     */
    function totalWeight() external view returns (uint256);

    /**
     * @dev credits accumulated from txn
     */
    function deltaCredit() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

import '../../../interfaces/Stargate/ILPStaking.sol';
import '../../../interfaces/Stargate/IStargateRouter.sol';
import '../../../interfaces/Stargate/IStargatePool.sol';
import '../../../interfaces/BankerJoe/IJoeRouter.sol';
import '../BaseStrategy.sol';

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
contract StratStargateStableCompound is BaseStrategy {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    /* ----- State Variables ----- */

    address public wrappedEther;
    address public uniRouter;

    // DepositPool list:
    // usdc.e pool helper: 0x257D69AA678e0A8DA6DFDA6A16CdF2052A460b45
    IStargateRouter public router;

    uint256 public stakingPid;

    uint8 public balanceSafeRate = 5;

    IStargatePool public pool;

    // Stake LP token to earn $STG
    // BNB chain: https://bscscan.com/address/0x3052a0f6ab15b4ae1df39962d5ddefaca86dab47#code
    ILPStaking public staking;

    address public wantLPToken; // S*BUSD:  deposit busd into pool to get S*BUSD LP token, then further stakes this LP token into LPRouter to get $STG reward

    address public reward;      // STG

    address[] public rewardToWantRoute;

    uint256 public lastHarvest;

    /* ----- Events ----- */

    event StratHarvest(address indexed harvester, uint256 wantHarvested, uint256 tvl);
    event Deposit(uint256 tvl);
    event Withdraw(uint256 tvl);

    constructor(
        address _vault,
        address _accessManager,
        address _uniRouter,     // swap router
        address _pool,          // pool
        address _staking,       // lp staking - Masterchef
        uint256 _stakingPid,    // _pid for staking
        address _reward,        // $stg
        address[] memory _rewardToWantRoute // $stg -> xxx -> want
    ) public BaseStrategy(_vault, _accessManager) {
        wrappedEther = IVaultV2(_vault).weth();
        uniRouter = _uniRouter;
        pool = IStargatePool(_pool);
        wantLPToken = _pool;    // NOTE: pool is LPErc20Token for staking
        router = IStargateRouter(IStargatePool(_pool).router());
        staking = ILPStaking(_staking);
        stakingPid = _stakingPid;
        reward = _reward;
        rewardToWantRoute = _rewardToWantRoute;

        require(
            pool.token() == want,
            'StratStargateStableCompound: !pool_token'
        );

        require(
            rewardToWantRoute.length > 0 &&
            rewardToWantRoute[0] == reward &&
            rewardToWantRoute[rewardToWantRoute.length - 1] == want,
            'StratStargateStableCompound: !route'
        );

        _giveAllowances();
    }

    /* ----- External Functions ----- */

    function rewardToWant() external view returns (address[] memory) {
        return rewardToWantRoute;
    }

    /* ----- Public Functions ----- */

    function harvest() public override whenNotPaused {
        require(msg.sender == tx.origin || msg.sender == address(vault), 'StratStargateStableCompound: EOA_or_vault');

        // NOTE: pool's local available balance
        if (IERC20(want).balanceOf(address(pool)) < balanceOfPool().mul(balanceSafeRate)) {
            _withdrawAll();
            pause();
            return;
        }

        uint256 beforeBal = balanceOfWant();

        staking.deposit(stakingPid, 0); // harvest STG token

        uint256 rewardBal = IERC20(reward).balanceOf(address(this));
        if (rewardBal > 0 && reward != want) {
            IJoeRouter(uniRouter).swapExactTokensForTokens(
                rewardBal, 0, rewardToWantRoute, address(this), now);
        }

        uint256 wantHarvested = balanceOfWant().sub(beforeBal);
        uint256 fee = chargePerformanceFee(wantHarvested);
        deposit();

        lastHarvest = block.timestamp;
        emit StratHarvest(msg.sender, wantHarvested.sub(fee), balanceOf());
    }

    function deposit() public override whenNotPaused nonReentrant {
        uint256 wantBal = balanceOfWant();
        if (wantBal > 0) {
            router.addLiquidity(pool.poolId(), wantBal, address(this));
            staking.deposit(stakingPid, IERC20(wantLPToken).balanceOf(address(this)));
            emit Deposit(balanceOf());
        }
    }

    function withdraw(uint256 amount) public override nonReentrant {
        require(msg.sender == vault, 'StratStargateStableCompound: !vault');
        require(amount > 0, 'StratStargateStableCompound: !amount');

        uint256 wantBal = balanceOfWant();

        if (wantBal < amount) {
            // local amount usd converted to LP token amount
            uint256 lptokenAmountToWithdraw = _amountLDtoLP(amount.sub(wantBal));
            staking.withdraw(stakingPid, lptokenAmountToWithdraw);

            // NOTE: check the redeemed amount
            router.instantRedeemLocal(uint16(pool.poolId()), IERC20(wantLPToken).balanceOf(address(this)), address(this));

            uint256 newWantBal = IERC20(want).balanceOf(address(this));
            require(newWantBal > wantBal, 'StratStargateStableCompound: !newWantBal');
            wantBal = newWantBal;
        }

        require(wantBal >= amount.mul(9999).div(10000), 'StratStargateStableCompound: !withdraw');
        uint256 withdrawAmt = amount < wantBal ? amount : wantBal;
        uint256 fee = chargeWithdrawalFee(withdrawAmt);
        if (withdrawAmt > fee) {
            TransferHelper.safeTransfer(want, vault, withdrawAmt.sub(fee));
        }

        emit Withdraw(balanceOf());
    }

    function balanceOfPool() public view override returns (uint256) {
        (uint256 lpAmount, ) = staking.userInfo(stakingPid, address(this));
        return _amountLPtoLD(lpAmount); // lp token amount -> usd local decimal amount
    }

    /* ----- Internal Functions ----- */

    // NOTE: convert from LD (local decimal) to LP token.
    // Follows the logic here: https://bscscan.com/address/0x98a5737749490856b401db5dc27f522fc314a4e1#code
    function _amountLDtoLP(uint256 _amountLD) internal view returns (uint256 amountLP) {
        uint256 totalLiquidity = pool.totalLiquidity();
        uint256 totalSupply = pool.totalSupply();
        require(totalLiquidity > 0, "Stargate: totalLiquidity_ZERO");
        uint256 amountSD = _amountLD.div(pool.convertRate());
        amountLP = amountSD.mul(totalSupply).div(totalLiquidity); // amountSD / (totalLiquidity / totalSupply)
    }

    function _amountLPtoLD(uint256 _amountLP) internal view returns (uint256 amountLD) {
        uint256 totalLiquidity = pool.totalLiquidity();
        uint256 totalSupply = pool.totalSupply();
        require(totalLiquidity > 0, "Stargate: cant convert LPtoSD when totalSupply == 0");
        uint256 amountSD = _amountLP.mul(totalLiquidity).div(totalSupply);
        amountLD = amountSD.mul(pool.convertRate());
    }

    function _amountLDtoSD(uint256 _amountLD) internal view returns (uint256 amountSD) {
        amountSD = _amountLD.div(pool.convertRate());
    }

    function _amountSDtoLD(uint256 _amountSD) internal view returns (uint256 amountLD) {
        amountLD = _amountSD.mul(pool.convertRate());
    }

    function _giveAllowances() internal override {
        TransferHelper.safeApprove(want, address(router), 0);
        TransferHelper.safeApprove(want, address(router), uint256(-1));
        TransferHelper.safeApprove(wantLPToken, address(staking), 0);
        TransferHelper.safeApprove(wantLPToken, address(staking), uint256(-1));
        TransferHelper.safeApprove(reward, uniRouter, 0);
        TransferHelper.safeApprove(reward, uniRouter, uint256(-1));
    }

    function _removeAllowances() internal override {
        TransferHelper.safeApprove(want, address(router), 0);
        TransferHelper.safeApprove(wantLPToken, address(staking), 0);
        TransferHelper.safeApprove(reward, uniRouter, 0);
    }

    function _withdrawAll() internal {
        (uint256 lpStakeAmount, ) = staking.userInfo(stakingPid, address(this));
        if (lpStakeAmount > 0) {
            staking.withdraw(stakingPid, lpStakeAmount);

            // NOTE: TODO check the redeemed amount
            router.instantRedeemLocal(
                uint16(pool.poolId()), IERC20(wantLPToken).balanceOf(address(this)), address(this));
        }
        emit Withdraw(balanceOf());
    }

    /* ----- Admin Functions ----- */

    function setBalanceSafeRate(uint8 _balanceSafeRate) external onlyAdmin {
        balanceSafeRate = _balanceSafeRate;
    }

    function retireStrat() external override {
        require(msg.sender == vault, 'StratStargateStableCompound: !vault');
        // call harvest explicitly if needed
        _withdrawAll();
        uint256 wantBal = IERC20(want).balanceOf(address(this));
        if (wantBal > 0) {
            TransferHelper.safeTransfer(want, vault, wantBal);
        }
    }

    function emergencyExit() external override onlyAdmin {
        _withdrawAll();
        uint256 wantBal = IERC20(want).balanceOf(address(this));
        if (wantBal > 0) {
            TransferHelper.safeTransfer(want, vault, wantBal);
        }
    }

    function emergencyExit1(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        bytes calldata _to,
        IStargateRouter.lzTxObj memory _lzTxParams
    ) external payable onlyAdmin {
        (uint256 lpStakeAmount, ) = staking.userInfo(stakingPid, address(this));
        staking.withdraw(stakingPid, lpStakeAmount);
        uint256 wantLPAmount = IERC20(wantLPToken).balanceOf(address(this));
        router.redeemLocal(
            _dstChainId,        // dstChainId
            _srcPoolId,         // srcPoolId
            _dstPoolId,         // dstPoolId
            payable(vault),     // refund address
            wantLPAmount,       // lp token amount
            _to,
            _lzTxParams
        );
    }

    function emergencyExit2(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        bytes calldata _to,
        IStargateRouter.lzTxObj memory _lzTxParams
    ) external payable onlyAdmin {
        (uint256 lpStakeAmount, ) = staking.userInfo(stakingPid, address(this));
        staking.withdraw(stakingPid, lpStakeAmount);
        uint256 wantLPAmount = IERC20(wantLPToken).balanceOf(address(this));
        router.redeemLocal(
            _dstChainId,        // dstChainId
            _srcPoolId,         // srcPoolId
            _dstPoolId,         // dstPoolId
            payable(address(this)), // refund address
            wantLPAmount,           // lp amount
            _to,
            _lzTxParams
        );
        TransferHelper.safeTransfer(want, vault, IERC20(want).balanceOf(address(this)));
    }


    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

import '../../../interfaces/VectorFinance/IPoolHelper.sol';
import '../../../interfaces/VectorFinance/IMainStaking.sol';
import '../../../interfaces/BankerJoe/IJoeRouter.sol';
import '../BaseStrategy.sol';

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
contract StrategyPlatypusVector is BaseStrategy {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    /* ----- State Variables ----- */

    // DepositPool list:
    // usdc.e pool helper: 0x257D69AA678e0A8DA6DFDA6A16CdF2052A460b45
    IPoolHelper public poolHelper;
    address public mainStaking = address(0x8B3d9F0017FA369cD8C164D0Cc078bf4cA588aE5);

    address[] public reward1ToWantRoute;
    address[] public reward2ToWantRoute;
    uint256 public lastHarvest;
    uint256 public slippage = 10; // 100 = 1%; 10 = 0.1%; 1 = 0.01%; default: 0.1%

    /* ----- Constant Variables ----- */

    address public constant wrappedEther = address(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7); // WAVAX
    address public constant reward1 = address(0xe6E7e03b60c0F8DaAE5Db98B03831610A60FfE1B); // VTX
    address public constant reward2 = address(0x22d4002028f537599bE9f666d1c4Fa138522f9c8); // PTP
    address public constant uniRouter = address(0x60aE616a2155Ee3d9A68541Ba4544862310933d4); // JoeRouter02

    /* ----- Events ----- */

    event StratHarvest(address indexed harvester, uint256 wantHarvested, uint256 tvl);
    event Deposit(uint256 tvl);
    event Withdraw(uint256 tvl);

    constructor(
        address _vault,
        address _accessManager,
        address _poolHelper,
        address[] memory _reward1ToWantRoute,
        address[] memory _reward2ToWantRoute
    ) public BaseStrategy(_vault, _accessManager) {
        poolHelper = IPoolHelper(_poolHelper);
        reward1ToWantRoute = _reward1ToWantRoute;
        reward2ToWantRoute = _reward2ToWantRoute;

        require(IVault(_vault).want() == poolHelper.depositToken(), 'StrategyPlatypusVector: !poolHelper');
        require(
            reward1ToWantRoute.length > 0 && reward1ToWantRoute[reward1ToWantRoute.length - 1] == want,
            'StrategyPlatypusVector: !route'
        );
        require(
            reward2ToWantRoute.length > 0 && reward2ToWantRoute[reward2ToWantRoute.length - 1] == want,
            'StrategyPlatypusVector: !route'
        );

        _giveAllowances();
    }

    /* ----- External Functions ----- */

    function reward1ToWant() external view returns (address[] memory) {
        return reward1ToWantRoute;
    }

    function reward2ToWant() external view returns (address[] memory) {
        return reward2ToWantRoute;
    }

    /* ----- Public Functions ----- */

    function harvest() public override whenNotPaused {
        require(msg.sender == tx.origin || msg.sender == address(vault), 'StrategyPlatypusVector: EOA_or_vault');

        // NOTE: in case of upgrading, withdraw all the funds and pause the strategy.
        if (IMainStaking(mainStaking).nextImplementation() != address(0)) {
            _withdrawAll();
            pause();
            return;
        }

        uint256 beforeBal = balanceOfWant();

        poolHelper.getReward(); // Harvest VTX and PTP rewards

        _swapRewardToWant(reward1, reward1ToWantRoute);
        _swapRewardToWant(reward2, reward2ToWantRoute);

        uint256 wantHarvested = balanceOfWant().sub(beforeBal);
        uint256 fee = chargePerformanceFee(wantHarvested);
        deposit();

        lastHarvest = block.timestamp;
        emit StratHarvest(msg.sender, wantHarvested.sub(fee), balanceOf());
    }

    function _swapRewardToWant(address reward, address[] memory route) private {
        uint256 rewardBal = IERC20(reward).balanceOf(address(this));

        // rewardBal == 0: means the current token reward ended
        // reward == want: no need to swap
        if (rewardBal > 0 && reward != want) {
            require(route.length > 0, 'StrategyPlatypusVector: SWAP_ROUTE_INVALID');
            IJoeRouter(uniRouter).swapExactTokensForTokens(rewardBal, 0, route, address(this), now);
        }
    }

    function deposit() public override whenNotPaused nonReentrant {
        uint256 wantBal = balanceOfWant();
        if (wantBal > 0) {
            poolHelper.deposit(wantBal);
            emit Deposit(balanceOf());
        }
    }

    function withdraw(uint256 amount) public override nonReentrant {
        require(msg.sender == vault, 'StrategyPlatypusVector: !vault');
        require(amount > 0, 'StrategyPlatypusVector: !amount');

        uint256 wantBal = balanceOfWant();

        if (wantBal < amount) {
            uint256 amountToWithdraw = amount.sub(wantBal);
            // minAmount with slippage
            uint256 minAmount = amountToWithdraw.mul(uint256(10000).sub(slippage)).div(10000);
            poolHelper.withdraw(amountToWithdraw, minAmount);
            uint256 newWantBal = IERC20(want).balanceOf(address(this));
            require(newWantBal > wantBal, 'StrategyPlatypusVector: !newWantBal');
            wantBal = newWantBal;
        }

        uint256 withdrawAmt = amount < wantBal ? amount : wantBal;
        uint256 fee = chargeWithdrawalFee(withdrawAmt);
        if (withdrawAmt > fee) {
            TransferHelper.safeTransfer(want, vault, withdrawAmt.sub(fee));
        }

        emit Withdraw(balanceOf());
    }

    function balanceOfPool() public view override returns (uint256) {
        return poolHelper.depositTokenBalance();
    }

    /* ----- Internal Functions ----- */

    function _giveAllowances() internal override {
        TransferHelper.safeApprove(want, mainStaking, 0);
        TransferHelper.safeApprove(want, mainStaking, uint256(-1));
        TransferHelper.safeApprove(reward1, uniRouter, 0);
        TransferHelper.safeApprove(reward1, uniRouter, uint256(-1));
        TransferHelper.safeApprove(reward2, uniRouter, 0);
        TransferHelper.safeApprove(reward2, uniRouter, uint256(-1));
        TransferHelper.safeApprove(wrappedEther, uniRouter, 0);
        TransferHelper.safeApprove(wrappedEther, uniRouter, uint256(-1));
    }

    function _removeAllowances() internal override {
        TransferHelper.safeApprove(want, mainStaking, 0);
        TransferHelper.safeApprove(reward1, uniRouter, 0);
        TransferHelper.safeApprove(reward2, uniRouter, 0);
        TransferHelper.safeApprove(wrappedEther, uniRouter, 0);
    }

    function _withdrawAll() internal {
        uint256 stakingBal = balanceOfPool();
        if (stakingBal > 0) {
            // minAmount with slippage
            uint256 minAmount = stakingBal.mul(uint256(10000).sub(slippage)).div(10000);
            poolHelper.withdraw(stakingBal, minAmount);
        }
    }

    /* ----- Admin Functions ----- */

    function setPoolHelper(address newPoolHelper) external onlyAdmin {
        require(newPoolHelper != address(0), 'StrategyPlatypusVector: !newPoolHelper');
        poolHelper = IPoolHelper(newPoolHelper);
    }

    function setSlippage(uint256 newSlippage) external onlyAdmin {
        slippage = newSlippage;
    }

    function retireStrat() external override {
        require(msg.sender == vault, 'StrategyPlatypusVector: !vault');
        // call harvest explicitly if needed
        _withdrawAll();
        uint256 wantBal = IERC20(want).balanceOf(address(this));
        if (wantBal > 0) {
            TransferHelper.safeTransfer(want, vault, wantBal);
        }
    }

    function emergencyExit() external override onlyAdmin {
        _withdrawAll();
        uint256 wantBal = IERC20(want).balanceOf(address(this));
        if (wantBal > 0) {
            TransferHelper.safeTransfer(want, vault, wantBal);
        }
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IPoolHelper {
    function balance(address _address) external view returns (uint256);

    function depositToken() external view returns (address);

    function depositTokenBalance() external view returns (uint256);

    function rewardPerToken(address token) external view returns (uint256);

    function update() external;

    function deposit(uint256 amount) external;

    function stake(uint256 _amount) external;

    function withdraw(uint256 amount, uint256 minAmount) external;

    /// @notice Harvest VTX and PTP rewards for msg.sender
    function getReward() external;

    function mainStaking() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IMainStaking {
    function setXPTP(address _xPTP) external;

    function addFee(
        uint256 max,
        uint256 min,
        uint256 value,
        address to,
        bool isPTP,
        bool isAddress
    ) external;

    function setFee(uint256 index, uint256 value) external;

    function setCallerFee(uint256 value) external;

    function deposit(
        address token,
        uint256 amount,
        address sender
    ) external;

    function harvest(address token, bool isUser) external;

    function withdraw(
        address token,
        uint256 _amount,
        uint256 _slippage,
        address sender
    ) external;

    function stakePTP(uint256 amount) external;

    function stakeAllPtp() external;

    function claimVePTP() external;

    function getStakedPtp() external;

    function getVePtp() external;

    function unstakePTP() external;

    function pendingPtpForPool(address _token) external view returns (uint256 pendingPtp);

    function masterPlatypus() external view returns (address);

    function getLPTokensForShares(uint256 amount, address token) external view returns (uint256);

    function getSharesForDepositTokens(uint256 amount, address token) external view returns (uint256);

    function getDepositTokensForShares(uint256 amount, address token) external view returns (uint256);

    function registerPool(
        uint256 _pid,
        address _token,
        address _lpAddress,
        string memory receiptName,
        string memory receiptSymbol,
        uint256 allocpoints
    ) external;

    function getPoolInfo(address _address)
        external
        view
        returns (
            uint256 pid,
            bool isActive,
            address token,
            address lp,
            uint256 sizeLp,
            address receipt,
            uint256 size,
            address rewards_addr,
            address helper
        );

    function removePool(address token) external;

    function nextImplementation() external view returns (address);

    function timelockLength() external view returns (uint256);

    function timelockEndForUpgrade() external view returns (uint256);

    function timelockEndForTimelock() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import './libraries/InitializableOwnable.sol';
import './libraries/DecimalMath.sol';
import './interfaces/IWooGuardian.sol';
import './interfaces/AggregatorV3Interface.sol';

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';

/// @title Woo guardian implementation.
contract WooGuardian is IWooGuardian, InitializableOwnable {
    using SafeMath for uint256;
    using DecimalMath for uint256;

    /* ----- Type declarations ----- */

    struct RefInfo {
        address chainlinkRefOracle; // chainlink oracle for price checking
        uint96 refPriceFixCoeff; // chainlink price fix coeff
        uint96 minInputAmount;
        uint96 maxInputAmount;
        uint64 bound;
    }

    /* ----- Events declarations ----- */
    event InputBoundUpdated(address indexed token, uint96 minInputAmount, uint96 maxInputAmount);

    /* ----- State variables ----- */

    uint96 constant MIN_INPUT_DEFAULT = 1e16; // 0.01 xToken

    uint96 constant MAX_INPUT_DEFAULT = 1e20; //  100 xToken

    mapping(address => RefInfo) public refInfo;

    // the bound for checking the price:
    // 1e18 = 100%, 1e17 = 10%, 1e16 = 1%, 1e15 = 0.1%, etc
    // NOTE:
    // globalBound <= 1e18 (100%)
    uint64 public globalBound;

    constructor() public {
        initOwner(msg.sender);
    }

    /* ----- External APIs ----- */

    function checkSwapPrice(
        uint256 price,
        address fromToken,
        address toToken
    ) external view override {
        require(fromToken != address(0), 'WooGuardian: fromToken_ZERO_ADDR');
        require(toToken != address(0), 'WooGuardian: toToken_ZERO_ADDR');

        if (refInfo[fromToken].chainlinkRefOracle == address(0) ||
            refInfo[toToken].chainlinkRefOracle == address(0)) {
            return;
        }

        uint256 refPrice = _refPrice(fromToken, toToken);
        uint64 bound = _boundForTokens(fromToken, toToken);
        require(
            refPrice.mulFloor(1e18 - bound) <= price && price <= refPrice.mulCeil(1e18 + bound),
            'WooGuardian: PRICE_UNRELIABLE'
        );
    }

    function checkInputAmount(address token, uint256 inputAmount) external view override {
        require(token != address(0), 'WooGuardian: token_ZERO_ADDR');
        require(inputAmount < type(uint96).max, 'WooGuardian: inputAmount_uint96_OVERFLOW');
        RefInfo storage info = refInfo[token];
        uint96 minInputAmount = info.minInputAmount != 0 ? info.minInputAmount : MIN_INPUT_DEFAULT;
        uint96 maxInputAmount = info.maxInputAmount != 0 ? info.maxInputAmount : MAX_INPUT_DEFAULT;
        require(uint96(inputAmount) >= minInputAmount, 'WooGuardian: inputAmount_LTM');
        require(uint96(inputAmount) <= maxInputAmount, 'WooGuardian: inputAmount_GTM');
    }

    function checkSwapAmount(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 toAmount
    ) external view override {
        require(fromToken != address(0), 'WooGuardian: fromToken_ZERO_ADDR');
        require(toToken != address(0), 'WooGuardian: toToken_ZERO_ADDR');

        if (refInfo[fromToken].chainlinkRefOracle == address(0) ||
            refInfo[toToken].chainlinkRefOracle == address(0)) {
            return;
        }

        uint256 refPrice = _refPrice(fromToken, toToken);
        uint256 refToAmount = fromAmount.mulFloor(refPrice);
        uint64 bound = _boundForTokens(fromToken, toToken);
        require(
            refToAmount.mulFloor(1e18 - bound) <= toAmount && toAmount <= refToAmount.mulCeil(1e18 + bound),
            'WooGuardian: TO_AMOUNT_UNRELIABLE'
        );
    }

    function setToken(
        address token,
        address chainlinkRefOracle,
        uint96 minInputAmount,
        uint96 maxInputAmount
    ) external onlyOwner {
        require(token != address(0), 'WooGuardian: token_ZERO_ADDR');

        setInputBound(token, minInputAmount, maxInputAmount);

        RefInfo storage info = refInfo[token];
        info.chainlinkRefOracle = chainlinkRefOracle;
        info.refPriceFixCoeff = _refPriceFixCoeff(token, chainlinkRefOracle);
        emit ChainlinkRefOracleUpdated(token, chainlinkRefOracle);
    }

    function setInputBound(
        address token,
        uint96 minInputAmount,
        uint96 maxInputAmount
    ) public onlyOwner {
        require(token != address(0), 'WooGuardian: token_ZERO_ADDR');
        require(minInputAmount < maxInputAmount, 'WooGuardian: min_max_INVALID');
        RefInfo storage info = refInfo[token];
        info.minInputAmount = minInputAmount;
        info.maxInputAmount = maxInputAmount;
        emit InputBoundUpdated(token, minInputAmount, maxInputAmount);
    }

    function setGlobalBound(uint64 newBound) external onlyOwner {
        require(newBound <= 1e18, 'WooGuardian: newBound out of range');
        globalBound = newBound;
    }

    function setTokenBound(address token, uint64 newBound) external onlyOwner {
        require(token != address(0), 'WooGuardian: token_ZERO_ADDR');
        require(newBound <= 1e18, 'WooGuardian: newBound out of range');
        RefInfo storage info = refInfo[token];
        info.bound = newBound;
    }

    /* ----- Private Methods ----- */

    function _refPriceFixCoeff(address token, address chainlink) private view returns (uint96) {
        if (chainlink == address(0)) {
            return 0;
        }

        // About decimals:
        // For a sell base trade, we have quoteSize = baseSize * price
        // For calculation convenience, the decimals of price is 18-base.decimals+quote.decimals
        // If we have price = basePrice / quotePrice, then decimals of tokenPrice should be 36-token.decimals()
        // We use chainlink oracle price as token reference price, which decimals is chainlinkPrice.decimals()
        // We should multiply it by 10e(36-(token.decimals+chainlinkPrice.decimals)), which is refPriceFixCoeff
        uint256 decimalsToFix = uint256(ERC20(token).decimals()).add(
            uint256(AggregatorV3Interface(chainlink).decimals())
        );
        uint256 refPriceFixCoeff = 10**(uint256(36).sub(decimalsToFix));
        require(refPriceFixCoeff <= type(uint96).max);
        return uint96(refPriceFixCoeff);
    }

    function _refPrice(
        address fromToken,
        address toToken
    ) private view returns (uint256) {
        RefInfo memory baseInfo = refInfo[fromToken];
        RefInfo memory quoteInfo = refInfo[toToken];

        require(baseInfo.chainlinkRefOracle != address(0), 'WooGuardian: fromToken_RefOracle_INVALID');
        require(quoteInfo.chainlinkRefOracle != address(0), 'WooGuardian: toToken_RefOracle_INVALID');

        (, int256 rawBaseRefPrice, , , ) = AggregatorV3Interface(baseInfo.chainlinkRefOracle).latestRoundData();
        require(rawBaseRefPrice >= 0, 'WooGuardian: INVALID_CHAINLINK_PRICE');
        (, int256 rawQuoteRefPrice, , , ) = AggregatorV3Interface(quoteInfo.chainlinkRefOracle).latestRoundData();
        require(rawQuoteRefPrice >= 0, 'WooGuardian: INVALID_CHAINLINK_QUOTE_PRICE');
        uint256 baseRefPrice = uint256(rawBaseRefPrice).mul(uint256(baseInfo.refPriceFixCoeff));
        uint256 quoteRefPrice = uint256(rawQuoteRefPrice).mul(uint256(quoteInfo.refPriceFixCoeff));

        return baseRefPrice.divFloor(quoteRefPrice);
    }

    function _boundForTokens(address token1, address token2) private view returns (uint64) {
        RefInfo storage info1 = refInfo[token1];
        uint64 bound1 = info1.bound != 0 ? info1.bound : globalBound;

        RefInfo storage info2 = refInfo[token2];
        uint64 bound2 = info2.bound != 0 ? info2.bound : globalBound;

        return bound1 > bound2 ? bound1 : bound2;
    }

    function boundForTokensForTest(address token1, address token2) external view returns (uint64) {
        return _boundForTokens(token1, token2);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.6.12;

import '../libraries/DecimalMath.sol';

contract DecimalMathTest {
    function mulFloor(uint256 target, uint256 d) external pure returns (uint256) {
        return DecimalMath.mulFloor(target, d);
    }

    function mulCeil(uint256 target, uint256 d) external pure returns (uint256) {
        return DecimalMath.mulCeil(target, d);
    }

    function divFloor(uint256 target, uint256 d) external pure returns (uint256) {
        return DecimalMath.divFloor(target, d);
    }

    function divCeil(uint256 target, uint256 d) external pure returns (uint256) {
        return DecimalMath.divCeil(target, d);
    }

    function reciprocalFloor(uint256 target) external pure returns (uint256) {
        return DecimalMath.reciprocalFloor(target);
    }

    function reciprocalCeil(uint256 target) external pure returns (uint256) {
        return DecimalMath.reciprocalCeil(target);
    }
}