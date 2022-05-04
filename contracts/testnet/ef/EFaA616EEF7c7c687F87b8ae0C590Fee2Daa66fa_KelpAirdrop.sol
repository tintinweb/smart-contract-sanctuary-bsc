// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Proxyable.sol";

/**
 * @title KELP token initial distribution
 *
 * @dev Distribute purchasers, airdrop, reserve, and founder tokens
 */
contract KelpAirdrop is Proxyable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public kelpToken;

    uint256 private constant decimalFactor = 10**18;
    uint256 public constant INITIAL_SUPPLY = 1000000000 * decimalFactor;
    uint256 public availableTotalSupply = 1000000000 * decimalFactor;
    uint256 public availablePresaleSupply = 230000000 * decimalFactor; // 100% Released at Token Distribution (TD)
    // 33% Released at TD +1 year -> 100% at TD +3 years
    uint256 public availableFounderSupply = 150000000 * decimalFactor;
    uint256 public availableAirdropSupply = 10000000 * decimalFactor; // 100% Released at TD
    uint256 public availableAdvisorSupply = 20000000 * decimalFactor; // 100% Released at TD +7 months
    // 6.8% Released at TD +100 days -> 100% at TD +4 years
    uint256 public availableReserveSupply = 513116658 * decimalFactor;
    uint256 public availableBonus1Supply = 39053330 * decimalFactor; // 100% Released at TD +1 year
    uint256 public availableBonus2Supply = 9354408 * decimalFactor; // 100% Released at TD +2 years
    uint256 public availableBonus3Supply = 28475604 * decimalFactor; // 100% Released at TD +3 years

    uint256 public grandTotalClaimed = 0;
    uint256 public startTime;

    enum AllocationType {
        PRESALE,
        FOUNDER,
        AIRDROP,
        ADVISOR,
        RESERVE,
        BONUS1,
        BONUS2,
        BONUS3
    }

    // Allocation with vesting information
    struct Allocation {
        uint256 allocationSupply; // Type of allocation
        uint256 endCliff; // Tokens are locked until
        uint256 endVesting; // This is when the tokens are fully unvested
        uint256 totalAllocated; // Total tokens allocated
        uint256 amountClaimed; // Total tokens claimed
    }
    mapping(address => Allocation) public allocations;

    // List of admins
    mapping(address => bool) public airdropAdmins;

    // Keeps track of whether or not a 250 KELP airdrop has been made to a particular address
    mapping(address => bool) public airdrops;

    modifier onlyOwnerOrAdmin() {
        require(
            msg.sender == owner() || airdropAdmins[msg.sender],
            "should be owner or admin"
        );
        _;
    }

    event LogNewAllocation(
        address indexed _recipient,
        AllocationType indexed _fromSupply,
        uint256 _totalAllocated,
        uint256 _grandTotalAllocated
    );
    event LogKelpClaimed(
        address indexed _recipient,
        uint256 indexed _fromSupply,
        uint256 _amountClaimed,
        uint256 _totalAllocated,
        uint256 _grandTotalClaimed
    );
    event LogKelpUpdated(address _oldToken, address _newToken);
    event LogStartTimeUpdated(uint256 _startTime);

    /**
     * @dev Constructor function - Set the kelp token address
     * @param _startTime The time when KelpAirdrop goes live
     */
    constructor(
        address _proxy,
        uint256 _startTime,
        IERC20 _kelpToken
    ) Proxyable(payable(_proxy)) {
        startTime = _startTime;
        kelpToken = _kelpToken;
    }

    /**
     * @dev Update Kelp token
     * @param _kelpToken The Token address of new Kelp
     */
    function setKelpToken(address _kelpToken) external optionalProxy_onlyOwner {
        require(_kelpToken != address(0), "invalid Kelp address");

        address oldKelp = address(kelpToken);
        kelpToken = IERC20(_kelpToken);

        emit LogKelpUpdated(oldKelp, _kelpToken);
    }

    /**
     * @dev Update Airdrop start time
     * @param _startTime The Token address of new Kelp
     */
    function setStartTime(uint256 _startTime) external optionalProxy_onlyOwner {
        require(
            _startTime >= block.timestamp,
            "Start time can't be in the past"
        );
        startTime = _startTime;

        emit LogStartTimeUpdated(_startTime);
    }

    /**
     * @dev Allow the owner of the contract to assign a new presale allocation
     * @param _recipient The recipient of the allocation
     * @param _totalAllocated The total amount of KELP available to the receipient (after vesting)
     */
    function setPresaleAllocation(address _recipient, uint256 _totalAllocated)
        external
        optionalProxy_onlyOwner
    {
        require(_totalAllocated > 0, "invalid totalAllocated");
        require(
            allocations[_recipient].totalAllocated == 0,
            "recipient already allocated"
        );
        require(_recipient != address(0), "invalid recipient address");

        availablePresaleSupply = availablePresaleSupply.sub(_totalAllocated);
        allocations[_recipient] = Allocation(
            uint8(AllocationType.PRESALE),
            0,
            0,
            _totalAllocated,
            0
        );

        availableTotalSupply = availableTotalSupply.sub(_totalAllocated);
        emit LogNewAllocation(
            _recipient,
            AllocationType.PRESALE,
            _totalAllocated,
            grandTotalAllocated()
        );
    }

    /**
     * @dev Allow the owner of the contract to assign a new founder allocation
     * @param _recipient The recipient of the allocation
     * @param _totalAllocated The total amount of KELP available to the receipient (after vesting)
     */
    function setFounderAllocation(address _recipient, uint256 _totalAllocated)
        external
        optionalProxy_onlyOwner
    {
        require(_totalAllocated > 0, "invalid totalAllocated");
        require(
            allocations[_recipient].totalAllocated == 0,
            "recipient already allocated"
        );
        require(_recipient != address(0), "invalid recipient address");

        availableFounderSupply = availableFounderSupply.sub(_totalAllocated);
        allocations[_recipient] = Allocation(
            uint8(AllocationType.FOUNDER),
            startTime + 1 * 365 days,
            startTime + 3 * 365 days,
            _totalAllocated,
            0
        );

        availableTotalSupply = availableTotalSupply.sub(_totalAllocated);
        emit LogNewAllocation(
            _recipient,
            AllocationType.FOUNDER,
            _totalAllocated,
            grandTotalAllocated()
        );
    }

    /**
     * @dev Allow the owner of the contract to assign a new advisor allocation
     * @param _recipient The recipient of the allocation
     * @param _totalAllocated The total amount of KELP available to the receipient (after vesting)
     */
    function setAdvisorAllocation(address _recipient, uint256 _totalAllocated)
        external
        optionalProxy_onlyOwner
    {
        require(_totalAllocated > 0, "invalid totalAllocated");
        require(
            allocations[_recipient].totalAllocated == 0,
            "recipient already allocated"
        );
        require(_recipient != address(0), "invalid recipient address");

        availableAdvisorSupply = availableAdvisorSupply.sub(_totalAllocated);
        allocations[_recipient] = Allocation(
            uint8(AllocationType.ADVISOR),
            startTime + 209 days,
            0,
            _totalAllocated,
            0
        );

        availableTotalSupply = availableTotalSupply.sub(_totalAllocated);
        emit LogNewAllocation(
            _recipient,
            AllocationType.ADVISOR,
            _totalAllocated,
            grandTotalAllocated()
        );
    }

    /**
     * @dev Allow the owner of the contract to assign a new reserve allocation
     * @param _recipient The recipient of the allocation
     * @param _totalAllocated The total amount of KELP available to the receipient (after vesting)
     */
    function setReserveAllocation(address _recipient, uint256 _totalAllocated)
        external
        optionalProxy_onlyOwner
    {
        require(_totalAllocated > 0, "invalid totalAllocated");
        require(
            allocations[_recipient].totalAllocated == 0,
            "recipient already allocated"
        );
        require(_recipient != address(0), "invalid recipient address");

        availableReserveSupply = availableReserveSupply.sub(_totalAllocated);
        allocations[_recipient] = Allocation(
            uint8(AllocationType.RESERVE),
            startTime + 100 days,
            startTime + 4 * 365 days,
            _totalAllocated,
            0
        );

        availableTotalSupply = availableTotalSupply.sub(_totalAllocated);
        emit LogNewAllocation(
            _recipient,
            AllocationType.RESERVE,
            _totalAllocated,
            grandTotalAllocated()
        );
    }

    /**
     * @dev Allow the owner of the contract to assign a new bonus1 allocation
     * @param _recipient The recipient of the allocation
     * @param _totalAllocated The total amount of KELP available to the receipient (after vesting)
     */
    function setBonus1Allocation(address _recipient, uint256 _totalAllocated)
        external
        optionalProxy_onlyOwner
    {
        require(_totalAllocated > 0, "invalid totalAllocated");
        require(
            allocations[_recipient].totalAllocated == 0,
            "recipient already allocated"
        );
        require(_recipient != address(0), "invalid recipient address");

        availableBonus1Supply = availableBonus1Supply.sub(_totalAllocated);
        allocations[_recipient] = Allocation(
            uint8(AllocationType.BONUS1),
            startTime + 1 * 365 days,
            startTime + 1 * 365 days,
            _totalAllocated,
            0
        );

        availableTotalSupply = availableTotalSupply.sub(_totalAllocated);
        emit LogNewAllocation(
            _recipient,
            AllocationType.BONUS1,
            _totalAllocated,
            grandTotalAllocated()
        );
    }

    /**
     * @dev Allow the owner of the contract to assign a new bonus2 allocation
     * @param _recipient The recipient of the allocation
     * @param _totalAllocated The total amount of KELP available to the receipient (after vesting)
     */
    function setBonus2Allocation(address _recipient, uint256 _totalAllocated)
        external
        optionalProxy_onlyOwner
    {
        require(_totalAllocated > 0, "invalid totalAllocated");
        require(
            allocations[_recipient].totalAllocated == 0,
            "recipient already allocated"
        );
        require(_recipient != address(0), "invalid recipient address");

        availableBonus2Supply = availableBonus2Supply.sub(_totalAllocated);
        allocations[_recipient] = Allocation(
            uint8(AllocationType.BONUS2),
            startTime + 2 * 365 days,
            startTime + 2 * 365 days,
            _totalAllocated,
            0
        );

        availableTotalSupply = availableTotalSupply.sub(_totalAllocated);
        emit LogNewAllocation(
            _recipient,
            AllocationType.BONUS2,
            _totalAllocated,
            grandTotalAllocated()
        );
    }

    /**
     * @dev Allow the owner of the contract to assign a new bonus3 allocation
     * @param _recipient The recipient of the allocation
     * @param _totalAllocated The total amount of KELP available to the receipient (after vesting)
     */
    function setBonus3Allocation(address _recipient, uint256 _totalAllocated)
        external
        optionalProxy_onlyOwner
    {
        require(_totalAllocated > 0, "invalid totalAllocated");
        require(
            allocations[_recipient].totalAllocated == 0,
            "recipient already allocated"
        );
        require(_recipient != address(0), "invalid recipient address");

        availableBonus3Supply = availableBonus3Supply.sub(_totalAllocated);
        allocations[_recipient] = Allocation(
            uint8(AllocationType.BONUS3),
            startTime + 3 * 365 days,
            startTime + 3 * 365 days,
            _totalAllocated,
            0
        );

        availableTotalSupply = availableTotalSupply.sub(_totalAllocated);
        emit LogNewAllocation(
            _recipient,
            AllocationType.BONUS3,
            _totalAllocated,
            grandTotalAllocated()
        );
    }

    /**
     * @dev Add an airdrop admin
     */
    function setAirdropAdmin(address _admin, bool _isAdmin)
        external
        optionalProxy_onlyOwner
    {
        airdropAdmins[_admin] = _isAdmin;
    }

    /**
     * @dev perform a transfer of allocations
     * @param _recipient is a list of recipients
     */
    function airdropTokens(address[] memory _recipient)
        public
        onlyOwnerOrAdmin
        nonReentrant
    {
        require(block.timestamp >= startTime, "airdrop not started");
        uint256 airdropped;

        availableAirdropSupply = availableAirdropSupply.sub(airdropped);
        availableTotalSupply = availableTotalSupply.sub(airdropped);
        grandTotalClaimed = grandTotalClaimed.add(airdropped);

        for (uint256 i = 0; i < _recipient.length; i++) {
            if (!airdrops[_recipient[i]]) {
                airdrops[_recipient[i]] = true;
                kelpToken.safeTransfer(_recipient[i], 250 * decimalFactor);
                airdropped = airdropped.add(250 * decimalFactor);
            }
        }
    }

    /**
     * @dev Transfer a recipients available allocation to their address
     * @param _recipient The address to withdraw tokens for
     */
    function transferTokens(address _recipient)
        external
        optionalProxy
        nonReentrant
    {
        require(
            allocations[_recipient].amountClaimed <
                allocations[_recipient].totalAllocated,
            "insuffcient amount"
        );
        require(
            block.timestamp >= allocations[_recipient].endCliff,
            "still in lock"
        );
        require(block.timestamp >= startTime, "not started yet");

        uint256 newAmountClaimed;
        if (allocations[_recipient].endVesting > block.timestamp) {
            // Transfer available amount based on vesting schedule and allocation
            newAmountClaimed = allocations[_recipient]
                .totalAllocated
                .mul(block.timestamp.sub(startTime))
                .div(allocations[_recipient].endVesting.sub(startTime));
        } else {
            // Transfer total allocated (minus previously claimed tokens)
            newAmountClaimed = allocations[_recipient].totalAllocated;
        }
        uint256 tokensToTransfer = newAmountClaimed.sub(
            allocations[_recipient].amountClaimed
        );
        allocations[_recipient].amountClaimed = newAmountClaimed;

        grandTotalClaimed = grandTotalClaimed.add(tokensToTransfer);

        kelpToken.safeTransfer(_recipient, tokensToTransfer);

        emit LogKelpClaimed(
            _recipient,
            allocations[_recipient].allocationSupply,
            tokensToTransfer,
            newAmountClaimed,
            grandTotalClaimed
        );
    }

    // Returns the amount of KELP allocated
    function grandTotalAllocated() public view returns (uint256) {
        return INITIAL_SUPPLY - availableTotalSupply;
    }

    // Allow transfer of accidentally sent ERC20 tokens
    function refundTokens(address _recipient, address _token)
        external
        optionalProxy_onlyOwner
    {
        require(_token != address(kelpToken), "invalid token address");
        require(_recipient != address(0), "invalid address");

        IERC20 token = IERC20(_token);
        uint256 balance = token.balanceOf(address(this));
        token.safeTransfer(_recipient, balance);
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

import "../IERC20.sol";
import "../../../utils/Address.sol";

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

/*
-----------------------------------------------------------------
MODULE DESCRIPTION
-----------------------------------------------------------------

A proxyable contract that works hand in hand with the Proxy contract
to allow for anyone to interact with the underlying contract both
directly and through the proxy.

-----------------------------------------------------------------
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Proxy.sol";

// This contract should be treated like an abstract contract
abstract contract Proxyable is Ownable {
    /* The proxy this contract exists behind. */
    Proxy public proxy;

    /* The caller of the proxy, passed through to this contract.
     * Note that every function using this member must apply the onlyProxy or
     * optionalProxy modifiers, otherwise their invocations can use stale values. */
    address public messageSender;

    constructor(address payable _proxy) {
        proxy = Proxy(_proxy);
        emit ProxyUpdated(_proxy);
    }

    function setProxy(address payable _proxy) external onlyOwner {
        proxy = Proxy(_proxy);
        emit ProxyUpdated(_proxy);
    }

    function setMessageSender(address sender) external onlyProxy {
        messageSender = sender;
    }

    modifier onlyProxy() {
        require(
            Proxy(payable(msg.sender)) == proxy,
            "Only the proxy can call this function"
        );
        _;
    }

    modifier optionalProxy() {
        if (Proxy(payable(msg.sender)) != proxy) {
            messageSender = msg.sender;
        }
        _;
    }

    modifier optionalProxy_onlyOwner() {
        if (Proxy(payable(msg.sender)) != proxy) {
            messageSender = msg.sender;
        }
        require(
            messageSender == owner(),
            "This action can only be performed by the owner"
        );
        _;
    }

    event ProxyUpdated(address proxyAddress);
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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

/*
-----------------------------------------------------------------
MODULE DESCRIPTION
-----------------------------------------------------------------

A proxy contract that, if it does not recognise the function
being called on it, passes all value and call data to an
underlying target contract.

This proxy has the capacity to toggle between DELEGATECALL
and CALL style proxy functionality.

The former executes in the proxy's context, and so will preserve
msg.sender and store data at the proxy address. The latter will not.
Therefore, any contract the proxy wraps in the CALL style must
implement the Proxyable interface, in order that it can pass msg.sender
into the underlying contract as the state parameter, messageSender.

-----------------------------------------------------------------
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Proxyable.sol";

contract Proxy is Ownable {
    Proxyable public target;
    bool public useDELEGATECALL;

    function setTarget(Proxyable _target) external onlyOwner {
        target = _target;
        emit TargetUpdated(_target);
    }

    function setUseDELEGATECALL(bool value) external onlyOwner {
        useDELEGATECALL = value;
    }

    function _emit(
        bytes memory callData,
        uint256 numTopics,
        bytes32 topic1,
        bytes32 topic2,
        bytes32 topic3,
        bytes32 topic4
    ) external onlyTarget {
        uint256 size = callData.length;
        bytes memory _callData = callData;

        assembly {
            /* The first 32 bytes of callData contain its length (as specified by the abi).
             * Length is assumed to be a uint256 and therefore maximum of 32 bytes
             * in length. It is also leftpadded to be a multiple of 32 bytes.
             * This means moving call_data across 32 bytes guarantees we correctly access
             * the data itself. */
            switch numTopics
            case 0 {
                log0(add(_callData, 32), size)
            }
            case 1 {
                log1(add(_callData, 32), size, topic1)
            }
            case 2 {
                log2(add(_callData, 32), size, topic1, topic2)
            }
            case 3 {
                log3(add(_callData, 32), size, topic1, topic2, topic3)
            }
            case 4 {
                log4(add(_callData, 32), size, topic1, topic2, topic3, topic4)
            }
        }
    }

    fallback() external payable {
        if (useDELEGATECALL) {
            assembly {
                /* Copy call data into free memory region. */
                let free_ptr := mload(0x40)
                calldatacopy(free_ptr, 0, calldatasize())

                /* Forward all gas and call data to the target contract. */
                let result := delegatecall(
                    gas(),
                    sload(target.slot),
                    free_ptr,
                    calldatasize(),
                    0,
                    0
                )
                returndatacopy(free_ptr, 0, returndatasize())

                /* Revert if the call failed, otherwise return the result. */
                if iszero(result) {
                    revert(free_ptr, returndatasize())
                }
                return(free_ptr, returndatasize())
            }
        } else {
            /* Here we are as above, but must send the messageSender explicitly
             * since we are using CALL rather than DELEGATECALL. */
            target.setMessageSender(msg.sender);
            assembly {
                let free_ptr := mload(0x40)
                calldatacopy(free_ptr, 0, calldatasize())

                /* We must explicitly forward ether to the underlying contract as well. */
                let result := call(
                    gas(),
                    sload(target.slot),
                    callvalue(),
                    free_ptr,
                    calldatasize(),
                    0,
                    0
                )
                returndatacopy(free_ptr, 0, returndatasize())

                if iszero(result) {
                    revert(free_ptr, returndatasize())
                }
                return(free_ptr, returndatasize())
            }
        }
    }

    receive() external payable {
        if (useDELEGATECALL) {
            assembly {
                /* Copy call data into free memory region. */
                let free_ptr := mload(0x40)
                calldatacopy(free_ptr, 0, calldatasize())

                /* Forward all gas and call data to the target contract. */
                let result := delegatecall(
                    gas(),
                    sload(target.slot),
                    free_ptr,
                    calldatasize(),
                    0,
                    0
                )
                returndatacopy(free_ptr, 0, returndatasize())

                /* Revert if the call failed, otherwise return the result. */
                if iszero(result) {
                    revert(free_ptr, returndatasize())
                }
                return(free_ptr, returndatasize())
            }
        } else {
            /* Here we are as above, but must send the messageSender explicitly
             * since we are using CALL rather than DELEGATECALL. */
            target.setMessageSender(msg.sender);
            assembly {
                let free_ptr := mload(0x40)
                calldatacopy(free_ptr, 0, calldatasize())

                /* We must explicitly forward ether to the underlying contract as well. */
                let result := call(
                    gas(),
                    sload(target.slot),
                    callvalue(),
                    free_ptr,
                    calldatasize(),
                    0,
                    0
                )
                returndatacopy(free_ptr, 0, returndatasize())

                if iszero(result) {
                    revert(free_ptr, returndatasize())
                }
                return(free_ptr, returndatasize())
            }
        }
    }

    modifier onlyTarget() {
        require(Proxyable(msg.sender) == target, "Must be proxy target");
        _;
    }

    event TargetUpdated(Proxyable newTarget);
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