// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./interfaces/IVestingMaster.sol";
import "./interfaces/ICore.sol";

interface IAccessControl {
    function hasRole(bytes32 role, address account)
        external
        view
        returns (bool);
}

interface ICoreCopy is ICore, IAccessControl {}

abstract contract CoreRefCopy {
    event CoreUpdate(address indexed _core);
    bytes32 public constant FARMS_ROLE = keccak256("FARMS_ROLE");

    ICoreCopy private _core;

    /// @notice CoreRef constructor
    /// @param core_ USDM Core to reference
    constructor(address core_) {
        _core = ICoreCopy(core_);
    }

    modifier onlyGovernor() {
        require(
            _core.isGovernor(msg.sender),
            "CoreRef::onlyGovernor: Caller is not a governor"
        );
        _;
    }

    modifier onlyFarms() {
        require(
            _core.hasRole(FARMS_ROLE, msg.sender),
            "xxx::xxx: Caller is not a farms"
        );
        _;
    }

    /// @notice Set new Core reference address
    /// @param core_ The new core address
    function setCore(address core_) external onlyGovernor {
        _core = ICoreCopy(core_);
        emit CoreUpdate(core_);
    }

    /// @notice Address of the Core contract referenced
    /// @return ICore implementation address
    function core() public view returns (ICore) {
        return _core;
    }
}

// VestingMaster,
contract VestingMaster is IVestingMaster, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // XMS token, or may be other token
    IERC20 public override vestingToken;

    mapping(address => LockedReward[]) public override userLockedRewards;

    uint256 public immutable override period;

    uint256 public immutable override lockedPeriodAmount;

    uint256 public override totalLockedRewards;

    constructor(
        // address _core,
        uint256 _period,
        uint256 _lockedPeriodAmount,
        address _vestingToken
    ) {  //CoreRefCopy(_core) 
        require(
            _vestingToken != address(0),
            "VestingMaster::constructor: Zero address"
        );
        require(_period > 0, "VestingMaster::constructor: Period zero");
        require(
            _lockedPeriodAmount > 0,
            "VestingMaster::constructor: Period amount zero"
        );
        vestingToken = IERC20(_vestingToken);
        period = _period;
        lockedPeriodAmount = _lockedPeriodAmount;
    }

    function lockTest(uint256 amount) external {
        address account = msg.sender;
        lock(account, amount);
    }

    function lock(address account,uint256 amount) public override {
        vestingToken.safeTransferFrom(account, address(this), amount);
        LockedReward[] memory oldLockedRewards = userLockedRewards[account];
        uint256 currentTimestamp = block.timestamp;
        LockedReward memory lockedReward;
        uint256 claimableAmount;
        for (uint256 i = 0; i < oldLockedRewards.length; i++) {
            lockedReward = oldLockedRewards[i];
            if (
                lockedReward.locked > 0 &&
                currentTimestamp >= lockedReward.timestamp
            ) {
                claimableAmount = claimableAmount.add(lockedReward.locked);
                delete oldLockedRewards[i];
            }
        }

        uint256 newStartTimestamp = (currentTimestamp / period) * period;
        uint256 newTimestamp;
        LockedReward memory newLockedReward;
        uint256 jj = 0;
        delete userLockedRewards[account];
        if (claimableAmount > 0) {
            userLockedRewards[account].push(
                LockedReward({
                    locked: claimableAmount,
                    timestamp: newStartTimestamp
                })
            );
        }
        for (uint256 i = 0; i < lockedPeriodAmount; i++) {
            newTimestamp = newStartTimestamp.add((i + 1) * period);
            newLockedReward = LockedReward({
                locked: amount / lockedPeriodAmount,
                timestamp: newTimestamp
            });
            for (uint256 j = jj; j < oldLockedRewards.length; j++) {
                lockedReward = oldLockedRewards[j];
                if (lockedReward.timestamp == newTimestamp) {
                    newLockedReward.locked = newLockedReward.locked.add(
                        lockedReward.locked
                    );
                    jj = j + 1;
                    break;
                }
            }
            userLockedRewards[account].push(newLockedReward);
        }
        totalLockedRewards = totalLockedRewards.add(amount);
        emit Lock(account, amount);
    }

    function claim() public override {
        LockedReward[] storage lockedRewards = userLockedRewards[msg.sender];
        uint256 currentTimestamp = block.timestamp;
        LockedReward memory lockedReward;
        uint256 claimableAmount;
        for (uint256 i = 0; i < lockedRewards.length; i++) {
            lockedReward = lockedRewards[i];
            if (
                lockedReward.locked > 0 &&
                currentTimestamp > lockedReward.timestamp
            ) {
                claimableAmount = claimableAmount.add(lockedReward.locked);
                delete lockedRewards[i];
            }
        }
        totalLockedRewards = totalLockedRewards.sub(claimableAmount);
        vestingToken.safeTransfer(msg.sender, claimableAmount);
        emit Claim(msg.sender, claimableAmount);
    }

    function getVestingAmount()
        public
        view
        override
        returns (uint256 lockedAmount, uint256 claimableAmount)
    {
        LockedReward[] memory lockedRewards = userLockedRewards[msg.sender];
        uint256 currentTimestamp = block.timestamp;
        LockedReward memory lockedReward;
        for (uint256 i = 0; i < lockedRewards.length; i++) {
            lockedReward = lockedRewards[i];
            if (currentTimestamp > lockedReward.timestamp) {
                claimableAmount = claimableAmount.add(lockedReward.locked);
            } else {
                lockedAmount = lockedAmount.add(lockedReward.locked);
            }
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

pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IVestingMaster {
    struct LockedReward {
        uint256 locked;
        uint256 timestamp;
    }
    // ----------- Events -----------

    event Lock(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 amount);

    // ----------- Farms only State changing api -----------

    function lock(address, uint256) external;

    // ----------- state changing API -----------

    function claim() external;

    // ----------- Getters -----------

    function period() external view returns (uint256);

    function lockedPeriodAmount() external view returns (uint256);

    function vestingToken() external view returns (IERC20);

    function userLockedRewards(address account, uint256 idx)
        external
        view
        returns (uint256, uint256);

    function totalLockedRewards() external view returns (uint256);

    function getVestingAmount() external view returns (uint256, uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "./IPermissions.sol";
import "../interfaces/IXMSToken.sol";
import "../interfaces/IUSDMToken.sol";

/// @title Core Interface
/// @author USDM Protocol
interface ICore is IPermissions {
    // ----------- Events -----------

    event XMSSupportRatioUpdate(uint256 _xmsSupportRatio);
    event USDMUpdate(address indexed _usdm);
    event XMSUpdate(address indexed _xms);
    event GenesisGroupUpdate(address indexed _genesisGroup);
    event TokenAllocation(address indexed _to, uint256 _amount);
    event TokenApprove(address indexed _to, uint256 _amount);
    event GenesisPeriodComplete(uint256 _timestamp);

    // ----------- Governor only state changing api -----------

    function setXMSSupportRatio(uint256 _xmsSupportRatio) external;

    function setUSDM(address token) external;

    function setXMS(address token) external;

    function setGenesisGroup(address _genesisGroup) external;

    function allocateXMS(address to, uint256 amount) external;

    function allocateToken(
        address token,
        address to,
        uint256 amount
    ) external;

    function approveXMS(address to, uint256 amount) external;

    function approveToken(
        address token,
        address to,
        uint256 amount
    ) external;

    function setApprovedPairAndContract(address _pair, address _contract)
        external;

    function removeApprovedPairAndContract(address _pair, address _contract)
        external;

    // ----------- Genesis Group only state changing api -----------

    function completeGenesisGroup() external;

    // ----------- Getters -----------

    function getApprovedPairsLength() external view returns (uint256);

    function getApprovedContractsLength(address _pair)
        external
        view
        returns (uint256);

    function approvedPairs(uint256 idx) external view returns (address);

    function approvedPairExisted(address pair) external view returns (bool);

    function approvedContracts(address pair, uint256 idx)
        external
        view
        returns (address);

    function approvedContractExisted(address pair, address _contract)
        external
        view
        returns (bool);

    function xmsSupportRatio() external view returns (uint256);

    function xmsSupportRatioPrecision() external view returns (uint256);

    function usdm() external view returns (IUSDMToken);

    function xms() external view returns (IXMSToken);

    function genesisGroup() external view returns (address);

    function hasGenesisGroupCompleted() external view returns (bool);
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

pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

/// @title Permissions interface
/// @author USDM Protocol
interface IPermissions {
    // ----------- Governor only state changing api -----------

    function createRole(bytes32 role, bytes32 adminRole) external;

    function grantMinter(address minter) external;

    function grantBurner(address burner) external;

    function grantPCVController(address pcvController) external;

    function grantGovernor(address governor) external;

    function grantGuardian(address guardian) external;

    function revokeMinter(address minter) external;

    function revokeBurner(address burner) external;

    function revokePCVController(address pcvController) external;

    function revokeGovernor(address governor) external;

    function revokeGuardian(address guardian) external;

    // ----------- Revoker only state changing api -----------

    function revokeOverride(bytes32 role, address account) external;

    // ----------- Getters -----------

    function isBurner(address _address) external view returns (bool);

    function isMinter(address _address) external view returns (bool);

    function isGovernor(address _address) external view returns (bool);

    function isGuardian(address _address) external view returns (bool);

    function isPCVController(address _address) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IXMSToken is IERC20 {
    struct Checkpoint {
        uint32 fromBlock;
        uint96 votes;
    }

    // ----------- Events -----------

    /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(
        address indexed delegator,
        address indexed fromDelegate,
        address indexed toDelegate
    );

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(
        address indexed delegate,
        uint256 previousBalance,
        uint256 newBalance
    );

    // ----------- Minter State changing api -----------

    function mint(address _to, uint256 _amount) external;

    // ----------- State changing api -----------

    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function delegates(address delegator) external view returns (address);

    function delegate(address delegatee) external;

    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    // ----------- Getters -----------

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function getCurrentVotes(address account) external view returns (uint96);

    function getPriorVotes(address account, uint256 blockNumber)
        external
        view
        returns (uint96);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IUSDMToken is IERC20 {
    // ----------- Minter State changing api -----------

    function mint(address _to, uint256 _amount) external;

    // ----------- Burner State changing api -----------

    // ----------- State changing api -----------

    function burn(uint256 _amount) external;

    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}