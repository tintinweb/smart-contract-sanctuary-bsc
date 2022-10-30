//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {TransferDeferrer} from "./abstract/TransferDeferrer.sol";
import {FlexibleInterest} from "./abstract/FlexibleInterest.sol";
import {PRBMathUD60x18Typed as Math, PRBMath} from "prb-math/contracts/PRBMathUD60x18Typed.sol";
import {Calendar} from "./lib/Calendar.sol";
import {Sorter} from "./lib/Sorter.sol";

import {IImeStakingCore} from "./IImeStakingCore.sol";
import {IImeStakingManageable} from "./IImeStakingManageable.sol";
import {ImeStakingAccessControl} from "./ImeStakingAccessControl.sol";

/**
    @title ImeStaking
    @author iMe Group

    @notice Implementation of iMe staking version 1
 */
contract ImeStaking is
    FlexibleInterest,
    TransferDeferrer,
    IImeStakingCore,
    IImeStakingManageable,
    ImeStakingAccessControl
{
    /**
        @notice Available withdrawal modes

        "Safe" strategy is used for safe withdrawals, with deferred token transfer
        Premature withdrawal is used for non-safe withdrawals before staking finish
        Immediate withdrawal is used for withdrawals after staking finish
        Also, force withdrawal using Immediate withdrawal mode.
     */
    enum WithdrawalMode {
        Safe,
        Premature,
        Immediate
    }

    uint64 private _startsAt;
    uint64 private _endsAt;
    uint64 private _incomePeriod;
    uint64 private _safeWithdrawalDuration;
    bool private _depositsAllowed = true;
    bool private _withdrawalsAllowed = true;
    string private _name;
    string private _author;
    PRBMath.UD60x18 private _percent;
    uint256 private _compoundAccrualThreshold;
    mapping(WithdrawalMode => PRBMath.UD60x18) private _fees;
    IERC20 private _token;

    constructor(
        string memory stakingName,
        string memory stakingAuthor,
        address tokenAddress,
        uint256 start,
        uint256 end,
        uint256 apy,
        uint256 accrualPeriod,
        uint256 prematureWithdrawalFeeBy1e9,
        uint256 safeWithdrawalFeeBy1e9,
        uint256 tokensToEnableCompoundAccrual,
        uint256 withdrawnTokensLockDuration
    ) FlexibleInterest(start) {
        _name = stakingName;
        _author = stakingAuthor;
        _token = IERC20(tokenAddress);

        _percent = Math.sub(
            Math.pow(
                Math.add(
                    Math.div(Math.fromUint(apy), Math.fromUint(100)),
                    Math.fromUint(1)
                ),
                Math.inv(Math.fromUint((1 days * 365) / accrualPeriod))
            ),
            Math.fromUint(1)
        );
        _incomePeriod = uint64(accrualPeriod);

        if (start > end) revert StakingLifespanInvalid();

        _startsAt = uint64(start);
        _endsAt = uint64(end);

        _fees[WithdrawalMode.Premature] = Math.div(
            Math.fromUint(prematureWithdrawalFeeBy1e9),
            Math.fromUint(1e9)
        );
        _fees[WithdrawalMode.Safe] = Math.div(
            Math.fromUint(safeWithdrawalFeeBy1e9),
            Math.fromUint(1e9)
        );

        _safeWithdrawalDuration = uint64(withdrawnTokensLockDuration);
        _compoundAccrualThreshold = tokensToEnableCompoundAccrual;
    }

    /*
        Implementation of IImeStakingV1Core
     */

    function name() external view override returns (string memory) {
        return _name;
    }

    function author() external view override returns (string memory) {
        return _author;
    }

    function version() external pure override returns (string memory) {
        return "1";
    }

    function token() external view override returns (address) {
        return address(_token);
    }

    function feeToken() external view override returns (address) {
        return address(_token);
    }

    function startsAt() external view override returns (uint256) {
        return _startsAt;
    }

    function endsAt() external view override returns (uint256) {
        return _endsAt;
    }

    function income() external view override returns (uint256) {
        return Math.toUint(Math.mul(Math.fromUint(1e9), _percent));
    }

    function incomePeriod() external view override returns (uint256) {
        return _incomePeriod;
    }

    function prematureWithdrawalFee() external view override returns (uint256) {
        PRBMath.UD60x18 memory fee = _fees[WithdrawalMode.Premature];
        return Math.toUint(Math.mul(Math.fromUint(1e9), fee));
    }

    function safeWithdrawalFee() external view override returns (uint256) {
        PRBMath.UD60x18 memory fee = _fees[WithdrawalMode.Safe];
        return Math.toUint(Math.mul(Math.fromUint(1e9), fee));
    }

    function safeWithdrawalDuration() external view override returns (uint256) {
        return _safeWithdrawalDuration;
    }

    function compoundAccrualThreshold()
        external
        view
        override
        returns (uint256)
    {
        return _compoundAccrualThreshold;
    }

    function debtOf(address account) external view override returns (uint256) {
        return _debtOf(account, _accrualNow());
    }

    function impactOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return _impactOf(account);
    }

    function safelyWithdrawnTokensOf(address account)
        external
        view
        override
        returns (uint256 pending, uint256 ready)
    {
        return _deferredTokensOf(account);
    }

    function estimateSolvency(uint256 at)
        external
        view
        override
        returns (uint256 lack, uint256 excess)
    {
        uint256 balance = _token.balanceOf(address(this));
        uint256 tokensToGive = _totalDebt(Sorter.min(_endsAt, at)) +
            _overallDeferredTokens();

        if (tokensToGive > balance) {
            lack = tokensToGive - balance;
        } else if (tokensToGive < balance) {
            excess = balance - tokensToGive;
        }
    }

    function stake(uint256 amount) external override {
        if (!_depositsAllowed) revert DepositDisabled();

        if (_now() < _startsAt) revert DepositTooEarly(_now(), _startsAt);

        if (_now() > _endsAt) revert DepositTooLate(_now(), _endsAt);

        _deposit(_msgSender(), amount, _accrualNow());
        emit Deposit(_msgSender(), amount);
        _safe(_token.transferFrom(_msgSender(), address(this), amount));
    }

    function withdraw(uint256 amount, bool safe) external override {
        if (!_withdrawalsAllowed) {
            revert WithdrawalDisabled();
        }

        uint256 debt = _debtOf(_msgSender(), _accrualNow());
        if (amount > debt) {
            revert WithdrawalOverLimit(amount, debt);
        }

        WithdrawalMode mode;

        if (_now() >= _endsAt) {
            mode = WithdrawalMode.Immediate;
        } else {
            mode = safe ? WithdrawalMode.Safe : WithdrawalMode.Premature;
        }

        _withdraw(_msgSender(), amount, mode);
    }

    function claim() external override {
        _claim(_msgSender());
    }

    function manageDeposits(bool allowed)
        external
        override
        onlyRole(STAKING_MANAGER_ROLE)
    {
        _depositsAllowed = allowed;
    }

    /*
        Implementation of IImeStakingV1Manageable
     */

    function manageWithdrawals(bool allowed)
        external
        override
        onlyRole(STAKING_MANAGER_ROLE)
    {
        _withdrawalsAllowed = allowed;
    }

    function setLifespan(uint256 start, uint256 end)
        external
        override
        onlyRole(STAKING_MANAGER_ROLE)
    {
        if (start > end) revert StakingLifespanInvalid();
        if (end < _now()) revert StakingLifespanInvalid();
        if (start != _startsAt) _startsAt = uint64(start);
        if (end != _endsAt) _endsAt = uint64(end);
    }

    function setWithdrawalFee(bool safe, uint256 fee)
        external
        override
        onlyRole(STAKING_MANAGER_ROLE)
    {
        if (safe)
            _fees[WithdrawalMode.Safe] = Math.div(
                Math.fromUint(fee),
                Math.fromUint(1e9)
            );
        else
            _fees[WithdrawalMode.Premature] = Math.div(
                Math.fromUint(fee),
                Math.fromUint(1e9)
            );
    }

    function rescueFunds(uint256 amount, address to)
        external
        override
        onlyRole(STAKING_BANKER_ROLE)
    {
        _rescueFunds(amount, to);
    }

    function rescueFunds(address to)
        external
        override
        onlyRole(STAKING_BANKER_ROLE)
    {
        _rescueFunds(_freeTokens(), to);
    }

    function forceWithdrawal(address to)
        external
        override
        onlyRole(STAKING_MANAGER_ROLE)
    {
        if (_now() < _endsAt) revert ForceWithdrawalTooEarly(_endsAt);

        _withdraw(to, _debtOf(to, _accrualNow()), WithdrawalMode.Immediate);
    }

    function _accrualNow() internal view returns (uint256) {
        // After _endsAt, time stops
        return Sorter.min(_now(), _endsAt);
    }

    function _accrualPeriod() internal view override returns (uint256) {
        return _incomePeriod;
    }

    function _accrualPercent()
        internal
        view
        override
        returns (PRBMath.UD60x18 memory)
    {
        return _percent;
    }

    function _flexibleThreshold() internal view override returns (uint256) {
        return _compoundAccrualThreshold;
    }

    function _freeTokens() internal view returns (uint256) {
        return
            _token.balanceOf(address(this)) -
            _overallImpact() -
            _overallDeferredTokens();
    }

    function _fee(uint256 amount, WithdrawalMode mode)
        internal
        view
        returns (uint256)
    {
        if (_fees[mode].value == 0) return 0;
        else return Math.toUint(Math.mul(Math.fromUint(amount), _fees[mode]));
    }

    function _withdraw(
        address user,
        uint256 amount,
        WithdrawalMode mode
    ) internal {
        _withdrawal(user, amount, _accrualNow());

        uint256 fee = _fee(amount, mode);
        emit Withdrawal(user, amount, fee);

        if (mode == WithdrawalMode.Safe) {
            _deferTransfer(
                user,
                amount - fee,
                _now() + _safeWithdrawalDuration
            );
        } else {
            _safe(_token.transfer(user, amount - fee));
        }
    }

    function _claim(address to) internal {
        uint256 claimed = _finalizeDeferredTransfers(to);

        if (claimed == 0) {
            return;
        }

        emit Claim(to, claimed);

        _safe(_token.transfer(to, claimed));
    }

    function _rescueFunds(uint256 amount, address to) internal {
        uint256 available = _freeTokens();

        if (amount > available) {
            revert RescueOverFreeTokens(amount, available);
        }

        _safe(_token.transfer(to, amount));
    }

    /**
         @dev Handle a safe token transfer
     */
    function _safe(bool transfer) internal pure {
        require(transfer, "Token transfer failed");
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

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TimeContext} from "./TimeContext.sol";
import {Sorter} from "../lib/Sorter.sol";

/**
    @title TransferDeferrer
    @author iMe Group
    @notice Contract fragment, responsible for token transfer deferral
 */
abstract contract TransferDeferrer is TimeContext {
    struct DeferredTransfer {
        uint256 amount;
        uint256 notBefore;
    }

    struct TransferQueue {
        mapping(uint32 => DeferredTransfer) transfers;
        uint32 start;
        uint32 end;
    }

    mapping(address => TransferQueue) private _queues;
    uint256 private _totalDeferredTokens = 0;

    /**
        @notice Defer a token transfer
        
        @param to Transfer recipient
        @param amount Amount of tokens to transfer
        @param notBefore Earliest timestamp for actual transfer
     */
    function _deferTransfer(
        address to,
        uint256 amount,
        uint256 notBefore
    ) internal {
        if (amount == 0) {
            return;
        }

        _queues[to].transfers[_queues[to].end] = DeferredTransfer(
            amount,
            notBefore
        );
        _queues[to].end++;

        _totalDeferredTokens += amount;
    }

    /**
        @notice Finalize transfers, which are ready, for certain user.
        Be sure to perform a real transfer of `amount` tokens!

        @return amount Amount of tokens to transfer
     */
    function _finalizeDeferredTransfers(address to)
        internal
        returns (uint256 amount)
    {
        uint32 finalizedTransfers = 0;

        uint32 iQueueStart = _queues[to].start;
        uint32 iQueueEnd = _queues[to].end;

        for (
            uint32 i = iQueueStart;
            i < iQueueEnd && _now() >= _queues[to].transfers[i].notBefore;
            i++
        ) {
            finalizedTransfers++;
            amount += _queues[to].transfers[i].amount;
            delete _queues[to].transfers[i];
        }

        if (finalizedTransfers == 0) {
            return 0;
        }

        if (iQueueStart + finalizedTransfers == iQueueEnd) {
            _queues[to].start = 0;
            _queues[to].end = 0;
            // _queues[to].transfers = 0 // Already nullified
        } else {
            _queues[to].start = iQueueStart + finalizedTransfers;
        }

        _totalDeferredTokens -= amount;
        return amount;
    }

    /**
        @notice Yields amount of deferred tokens for a certain user

        @return pending Amount of tokens, which cannot be transferred yet
        @return ready Amount of tokens, ready to be transferred
     */
    function _deferredTokensOf(address to)
        internal
        view
        returns (uint256 pending, uint256 ready)
    {
        for (uint32 i = _queues[to].start; i < _queues[to].end; i++) {
            DeferredTransfer memory transfer = _queues[to].transfers[i];

            if (_now() >= transfer.notBefore) {
                ready += transfer.amount;
            } else {
                pending += transfer.amount;
            }
        }
    }

    /**
        @notice Yields total amount of deferred tokens
     */
    function _overallDeferredTokens() internal view returns (uint256) {
        return _totalDeferredTokens;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TimeContext} from "./TimeContext.sol";
import {Calendar} from "../lib/Calendar.sol";
import {PRBMathUD60x18Typed as Math, PRBMath} from "prb-math/contracts/PRBMathUD60x18Typed.sol";
import {SimpleInterest} from "./SimpleInterest.sol";
import {CompoundInterest} from "./CompoundInterest.sol";
import {Sorter} from "../lib/Sorter.sol";

/**
    @title FlexibleInterest
    @author iMe Group

    @notice Contract fragment, implementing flexible interest accrual.
    "Flexible" means actual accrual strategy of an investor may change.
 */
abstract contract FlexibleInterest is SimpleInterest, CompoundInterest {
    constructor(uint256 anchor)
        SimpleInterest(anchor)
        CompoundInterest(anchor)
    {}

    enum AccrualStrategy {
        Simple,
        Compound
    }

    mapping(address => uint256) private _impacts;
    uint256 private _totalImpact;

    /**
        @dev Yields personal impact of a participant
     */
    function _impactOf(address participant) internal view returns (uint256) {
        return _impacts[participant];
    }

    /**
        @dev Yields summary impact across all participants
     */
    function _overallImpact() internal view returns (uint256) {
        return _totalImpact;
    }

    /**
        @dev Yields accrual strategy of an investor
     */
    function _accrualStrategyOf(address investor)
        internal
        view
        returns (AccrualStrategy)
    {
        return
            _impactOf(investor) >= _flexibleThreshold()
                ? AccrualStrategy.Compound
                : AccrualStrategy.Simple;
    }

    /**
        @dev Minimal impact needed for compound accrual
    */
    function _flexibleThreshold() internal view virtual returns (uint256);

    function _deposit(
        address investor,
        uint256 amount,
        uint256 at
    ) internal override(SimpleInterest, CompoundInterest) {
        AccrualStrategy currentStrategy = _accrualStrategyOf(investor);

        _impacts[investor] += amount;
        _totalImpact += amount;

        if (currentStrategy == AccrualStrategy.Compound) {
            CompoundInterest._deposit(investor, amount, at);
        }
        /* (currentStrategy == AccrualStrategy.Simple) */
        else {
            AccrualStrategy desiredStrategy = _accrualStrategyOf(investor);

            if (desiredStrategy == AccrualStrategy.Simple) {
                SimpleInterest._deposit(investor, amount, at);
            }
            /* (desiredStrategy == AccrualStrategy.Compound) */
            else {
                uint256 debt = SimpleInterest._debtOf(investor, at);
                SimpleInterest._withdrawal(investor, debt, at);
                CompoundInterest._deposit(investor, debt + amount, at);
            }
        }
    }

    function _withdrawal(
        address investor,
        uint256 amount,
        uint256 at
    ) internal override(SimpleInterest, CompoundInterest) {
        AccrualStrategy currentStrategy = _accrualStrategyOf(investor);

        uint256 impactDecrease = Sorter.min(_impacts[investor], amount);
        _impacts[investor] -= impactDecrease;
        _totalImpact -= impactDecrease;

        if (currentStrategy == AccrualStrategy.Simple) {
            SimpleInterest._withdrawal(investor, amount, at);
        }
        /* (currentStrategy == AccrualStrategy.Compound) */
        else {
            AccrualStrategy desiredStrategy = _accrualStrategyOf(investor);

            if (desiredStrategy == AccrualStrategy.Compound) {
                CompoundInterest._withdrawal(investor, amount, at);
            }
            /* (desiredStrategy == AccrualStrategy.Simple) */
            else {
                uint256 debt = CompoundInterest._debtOf(investor, at);
                CompoundInterest._withdrawal(investor, debt, at);
                SimpleInterest._deposit(investor, debt - amount, at);
            }
        }
    }

    function _debtOf(address investor, uint256 at)
        internal
        view
        override(SimpleInterest, CompoundInterest)
        returns (uint256)
    {
        return
            SimpleInterest._debtOf(investor, at) +
            CompoundInterest._debtOf(investor, at);
    }

    function _totalDebt(uint256 at)
        internal
        view
        override(SimpleInterest, CompoundInterest)
        returns (uint256)
    {
        return SimpleInterest._totalDebt(at) + CompoundInterest._totalDebt(at);
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.4;

import "./PRBMath.sol";

/// @title PRBMathUD60x18Typed
/// @author Paul Razvan Berg
/// @notice Smart contract library for advanced fixed-point math that works with uint256 numbers considered to have 18
/// trailing decimals. We call this number representation unsigned 60.18-decimal fixed-point, since there can be up to 60
/// digits in the integer part and up to 18 decimals in the fractional part. The numbers are bound by the minimum and the
/// maximum values permitted by the Solidity type uint256.
/// @dev This is the same as PRBMathUD59x18, except that it works with structs instead of raw uint256s.
library PRBMathUD60x18Typed {
    /// STORAGE ///

    /// @dev Half the SCALE number.
    uint256 internal constant HALF_SCALE = 5e17;

    /// @dev log2(e) as an unsigned 60.18-decimal fixed-point number.
    uint256 internal constant LOG2_E = 1_442695040888963407;

    /// @dev The maximum value an unsigned 60.18-decimal fixed-point number can have.
    uint256 internal constant MAX_UD60x18 =
        115792089237316195423570985008687907853269984665640564039457_584007913129639935;

    /// @dev The maximum whole value an unsigned 60.18-decimal fixed-point number can have.
    uint256 internal constant MAX_WHOLE_UD60x18 =
        115792089237316195423570985008687907853269984665640564039457_000000000000000000;

    /// @dev How many trailing decimals can be represented.
    uint256 internal constant SCALE = 1e18;

    /// @notice Adds two unsigned 60.18-decimal fixed-point numbers together, returning a new unsigned 60.18-decimal
    /// fixed-point number.
    /// @param x The first summand as an unsigned 60.18-decimal fixed-point number.
    /// @param y The second summand as an unsigned 60.18-decimal fixed-point number.
    /// @param result The sum as an unsigned 59.18 decimal fixed-point number.
    function add(PRBMath.UD60x18 memory x, PRBMath.UD60x18 memory y)
        internal
        pure
        returns (PRBMath.UD60x18 memory result)
    {
        unchecked {
            uint256 rValue = x.value + y.value;
            if (rValue < x.value) {
                revert PRBMathUD60x18__AddOverflow(x.value, y.value);
            }
            result = PRBMath.UD60x18({ value: rValue });
        }
    }

    /// @notice Calculates the arithmetic average of x and y, rounding down.
    /// @param x The first operand as an unsigned 60.18-decimal fixed-point number.
    /// @param y The second operand as an unsigned 60.18-decimal fixed-point number.
    /// @return result The arithmetic average as an unsigned 60.18-decimal fixed-point number.
    function avg(PRBMath.UD60x18 memory x, PRBMath.UD60x18 memory y)
        internal
        pure
        returns (PRBMath.UD60x18 memory result)
    {
        // The operations can never overflow.
        unchecked {
            // The last operand checks if both x and y are odd and if that is the case, we add 1 to the result. We need
            // to do this because if both numbers are odd, the 0.5 remainder gets truncated twice.
            uint256 rValue = (x.value >> 1) + (y.value >> 1) + (x.value & y.value & 1);
            result = PRBMath.UD60x18({ value: rValue });
        }
    }

    /// @notice Yields the least unsigned 60.18 decimal fixed-point number greater than or equal to x.
    ///
    /// @dev Optimized for fractional value inputs, because for every whole value there are (1e18 - 1) fractional counterparts.
    /// See https://en.wikipedia.org/wiki/Floor_and_ceiling_functions.
    ///
    /// Requirements:
    /// - x must be less than or equal to MAX_WHOLE_UD60x18.
    ///
    /// @param x The unsigned 60.18-decimal fixed-point number to ceil.
    /// @param result The least integer greater than or equal to x, as an unsigned 60.18-decimal fixed-point number.
    function ceil(PRBMath.UD60x18 memory x) internal pure returns (PRBMath.UD60x18 memory result) {
        uint256 xValue = x.value;
        if (xValue > MAX_WHOLE_UD60x18) {
            revert PRBMathUD60x18__CeilOverflow(xValue);
        }

        uint256 rValue;
        assembly {
            // Equivalent to "x % SCALE" but faster.
            let remainder := mod(xValue, SCALE)

            // Equivalent to "SCALE - remainder" but faster.
            let delta := sub(SCALE, remainder)

            // Equivalent to "x + delta * (remainder > 0 ? 1 : 0)" but faster.
            rValue := add(xValue, mul(delta, gt(remainder, 0)))
        }
        result = PRBMath.UD60x18({ value: rValue });
    }

    /// @notice Divides two unsigned 60.18-decimal fixed-point numbers, returning a new unsigned 60.18-decimal fixed-point number.
    ///
    /// @dev Uses mulDiv to enable overflow-safe multiplication and division.
    ///
    /// Requirements:
    /// - The denominator cannot be zero.
    ///
    /// @param x The numerator as an unsigned 60.18-decimal fixed-point number.
    /// @param y The denominator as an unsigned 60.18-decimal fixed-point number.
    /// @param result The quotient as an unsigned 60.18-decimal fixed-point number.
    function div(PRBMath.UD60x18 memory x, PRBMath.UD60x18 memory y)
        internal
        pure
        returns (PRBMath.UD60x18 memory result)
    {
        result = PRBMath.UD60x18({ value: PRBMath.mulDiv(x.value, SCALE, y.value) });
    }

    /// @notice Returns Euler's number as an unsigned 60.18-decimal fixed-point number.
    /// @dev See https://en.wikipedia.org/wiki/E_(mathematical_constant).
    function e() internal pure returns (PRBMath.UD60x18 memory result) {
        result = PRBMath.UD60x18({ value: 2_718281828459045235 });
    }

    /// @notice Calculates the natural exponent of x.
    ///
    /// @dev Based on the insight that e^x = 2^(x * log2(e)).
    ///
    /// Requirements:
    /// - All from "log2".
    /// - x must be less than 88.722839111672999628.
    ///
    /// @param x The exponent as an unsigned 60.18-decimal fixed-point number.
    /// @return result The result as an unsigned 60.18-decimal fixed-point number.
    function exp(PRBMath.UD60x18 memory x) internal pure returns (PRBMath.UD60x18 memory result) {
        uint256 xValue = x.value;

        // Without this check, the value passed to "exp2" would be greater than 192.
        if (xValue >= 133_084258667509499441) {
            revert PRBMathUD60x18__ExpInputTooBig(xValue);
        }

        // Do the fixed-point multiplication inline to save gas.
        unchecked {
            uint256 doubleScaleProduct = x.value * LOG2_E;
            PRBMath.UD60x18 memory exponent = PRBMath.UD60x18({ value: (doubleScaleProduct + HALF_SCALE) / SCALE });
            result = exp2(exponent);
        }
    }

    /// @notice Calculates the binary exponent of x using the binary fraction method.
    ///
    /// @dev See https://ethereum.stackexchange.com/q/79903/24693.
    ///
    /// Requirements:
    /// - x must be 192 or less.
    /// - The result must fit within MAX_UD60x18.
    ///
    /// @param x The exponent as an unsigned 60.18-decimal fixed-point number.
    /// @return result The result as an unsigned 60.18-decimal fixed-point number.
    function exp2(PRBMath.UD60x18 memory x) internal pure returns (PRBMath.UD60x18 memory result) {
        // 2^192 doesn't fit within the 192.64-bit format used internally in this function.
        if (x.value >= 192e18) {
            revert PRBMathUD60x18__Exp2InputTooBig(x.value);
        }

        unchecked {
            // Convert x to the 192.64-bit fixed-point format.
            uint256 x192x64 = (x.value << 64) / SCALE;

            // Pass x to the PRBMath.exp2 function, which uses the 192.64-bit fixed-point number representation.
            result = PRBMath.UD60x18({ value: PRBMath.exp2(x192x64) });
        }
    }

    /// @notice Yields the greatest unsigned 60.18 decimal fixed-point number less than or equal to x.
    /// @dev Optimized for fractional value inputs, because for every whole value there are (1e18 - 1) fractional counterparts.
    /// See https://en.wikipedia.org/wiki/Floor_and_ceiling_functions.
    /// @param x The unsigned 60.18-decimal fixed-point number to floor.
    /// @param result The greatest integer less than or equal to x, as an unsigned 60.18-decimal fixed-point number.
    function floor(PRBMath.UD60x18 memory x) internal pure returns (PRBMath.UD60x18 memory result) {
        uint256 xValue = x.value;
        uint256 rValue;
        assembly {
            // Equivalent to "x % SCALE" but faster.
            let remainder := mod(xValue, SCALE)

            // Equivalent to "x - remainder * (remainder > 0 ? 1 : 0)" but faster.
            rValue := sub(xValue, mul(remainder, gt(remainder, 0)))
        }
        result = PRBMath.UD60x18({ value: rValue });
    }

    /// @notice Yields the excess beyond the floor of x.
    /// @dev Based on the odd function definition https://en.wikipedia.org/wiki/Fractional_part.
    /// @param x The unsigned 60.18-decimal fixed-point number to get the fractional part of.
    /// @param result The fractional part of x as an unsigned 60.18-decimal fixed-point number.
    function frac(PRBMath.UD60x18 memory x) internal pure returns (PRBMath.UD60x18 memory result) {
        uint256 xValue = x.value;
        uint256 rValue;
        assembly {
            rValue := mod(xValue, SCALE)
        }
        result = PRBMath.UD60x18({ value: rValue });
    }

    /// @notice Converts a number from basic integer form to unsigned 60.18-decimal fixed-point representation.
    ///
    /// @dev Requirements:
    /// - x must be less than or equal to MAX_UD60x18 divided by SCALE.
    ///
    /// @param x The basic integer to convert.
    /// @param result The same number in unsigned 60.18-decimal fixed-point representation.
    function fromUint(uint256 x) internal pure returns (PRBMath.UD60x18 memory result) {
        unchecked {
            if (x > MAX_UD60x18 / SCALE) {
                revert PRBMathUD60x18__FromUintOverflow(x);
            }
            result = PRBMath.UD60x18({ value: x * SCALE });
        }
    }

    /// @notice Calculates geometric mean of x and y, i.e. sqrt(x * y), rounding down.
    ///
    /// @dev Requirements:
    /// - x * y must fit within MAX_UD60x18, lest it overflows.
    ///
    /// @param x The first operand as an unsigned 60.18-decimal fixed-point number.
    /// @param y The second operand as an unsigned 60.18-decimal fixed-point number.
    /// @return result The result as an unsigned 60.18-decimal fixed-point number.
    function gm(PRBMath.UD60x18 memory x, PRBMath.UD60x18 memory y)
        internal
        pure
        returns (PRBMath.UD60x18 memory result)
    {
        if (x.value == 0) {
            return PRBMath.UD60x18({ value: 0 });
        }

        unchecked {
            // Checking for overflow this way is faster than letting Solidity do it.
            uint256 xy = x.value * y.value;
            if (xy / x.value != y.value) {
                revert PRBMathUD60x18__GmOverflow(x.value, y.value);
            }

            // We don't need to multiply by the SCALE here because the x*y product had already picked up a factor of SCALE
            // during multiplication. See the comments within the "sqrt" function.
            result = PRBMath.UD60x18({ value: PRBMath.sqrt(xy) });
        }
    }

    /// @notice Calculates 1 / x, rounding toward zero.
    ///
    /// @dev Requirements:
    /// - x cannot be zero.
    ///
    /// @param x The unsigned 60.18-decimal fixed-point number for which to calculate the inverse.
    /// @return result The inverse as an unsigned 60.18-decimal fixed-point number.
    function inv(PRBMath.UD60x18 memory x) internal pure returns (PRBMath.UD60x18 memory result) {
        unchecked {
            // 1e36 is SCALE * SCALE.
            result = PRBMath.UD60x18({ value: 1e36 / x.value });
        }
    }

    /// @notice Calculates the natural logarithm of x.
    ///
    /// @dev Based on the insight that ln(x) = log2(x) / log2(e).
    ///
    /// Requirements:
    /// - All from "log2".
    ///
    /// Caveats:
    /// - All from "log2".
    /// - This doesn't return exactly 1 for 2.718281828459045235, for that we would need more fine-grained precision.
    ///
    /// @param x The unsigned 60.18-decimal fixed-point number for which to calculate the natural logarithm.
    /// @return result The natural logarithm as an unsigned 60.18-decimal fixed-point number.
    function ln(PRBMath.UD60x18 memory x) internal pure returns (PRBMath.UD60x18 memory result) {
        // Do the fixed-point multiplication inline to save gas. This is overflow-safe because the maximum value that log2(x)
        // can return is 196205294292027477728.
        unchecked {
            uint256 rValue = (log2(x).value * SCALE) / LOG2_E;
            result = PRBMath.UD60x18({ value: rValue });
        }
    }

    /// @notice Calculates the common logarithm of x.
    ///
    /// @dev First checks if x is an exact power of ten and it stops if yes. If it's not, calculates the common
    /// logarithm based on the insight that log10(x) = log2(x) / log2(10).
    ///
    /// Requirements:
    /// - All from "log2".
    ///
    /// Caveats:
    /// - All from "log2".
    ///
    /// @param x The unsigned 60.18-decimal fixed-point number for which to calculate the common logarithm.
    /// @return result The common logarithm as an unsigned 60.18-decimal fixed-point number.
    function log10(PRBMath.UD60x18 memory x) internal pure returns (PRBMath.UD60x18 memory result) {
        uint256 xValue = x.value;
        if (xValue < SCALE) {
            revert PRBMathUD60x18__LogInputTooSmall(xValue);
        }

        // Note that the "mul" in this block is the assembly multiplication operation, not the "mul" function defined
        // in this contract.
        uint256 rValue;

        // prettier-ignore
        assembly {
            switch xValue
            case 1 { rValue := mul(SCALE, sub(0, 18)) }
            case 10 { rValue := mul(SCALE, sub(1, 18)) }
            case 100 { rValue := mul(SCALE, sub(2, 18)) }
            case 1000 { rValue := mul(SCALE, sub(3, 18)) }
            case 10000 { rValue := mul(SCALE, sub(4, 18)) }
            case 100000 { rValue := mul(SCALE, sub(5, 18)) }
            case 1000000 { rValue := mul(SCALE, sub(6, 18)) }
            case 10000000 { rValue := mul(SCALE, sub(7, 18)) }
            case 100000000 { rValue := mul(SCALE, sub(8, 18)) }
            case 1000000000 { rValue := mul(SCALE, sub(9, 18)) }
            case 10000000000 { rValue := mul(SCALE, sub(10, 18)) }
            case 100000000000 { rValue := mul(SCALE, sub(11, 18)) }
            case 1000000000000 { rValue := mul(SCALE, sub(12, 18)) }
            case 10000000000000 { rValue := mul(SCALE, sub(13, 18)) }
            case 100000000000000 { rValue := mul(SCALE, sub(14, 18)) }
            case 1000000000000000 { rValue := mul(SCALE, sub(15, 18)) }
            case 10000000000000000 { rValue := mul(SCALE, sub(16, 18)) }
            case 100000000000000000 { rValue := mul(SCALE, sub(17, 18)) }
            case 1000000000000000000 { rValue := 0 }
            case 10000000000000000000 { rValue := SCALE }
            case 100000000000000000000 { rValue := mul(SCALE, 2) }
            case 1000000000000000000000 { rValue := mul(SCALE, 3) }
            case 10000000000000000000000 { rValue := mul(SCALE, 4) }
            case 100000000000000000000000 { rValue := mul(SCALE, 5) }
            case 1000000000000000000000000 { rValue := mul(SCALE, 6) }
            case 10000000000000000000000000 { rValue := mul(SCALE, 7) }
            case 100000000000000000000000000 { rValue := mul(SCALE, 8) }
            case 1000000000000000000000000000 { rValue := mul(SCALE, 9) }
            case 10000000000000000000000000000 { rValue := mul(SCALE, 10) }
            case 100000000000000000000000000000 { rValue := mul(SCALE, 11) }
            case 1000000000000000000000000000000 { rValue := mul(SCALE, 12) }
            case 10000000000000000000000000000000 { rValue := mul(SCALE, 13) }
            case 100000000000000000000000000000000 { rValue := mul(SCALE, 14) }
            case 1000000000000000000000000000000000 { rValue := mul(SCALE, 15) }
            case 10000000000000000000000000000000000 { rValue := mul(SCALE, 16) }
            case 100000000000000000000000000000000000 { rValue := mul(SCALE, 17) }
            case 1000000000000000000000000000000000000 { rValue := mul(SCALE, 18) }
            case 10000000000000000000000000000000000000 { rValue := mul(SCALE, 19) }
            case 100000000000000000000000000000000000000 { rValue := mul(SCALE, 20) }
            case 1000000000000000000000000000000000000000 { rValue := mul(SCALE, 21) }
            case 10000000000000000000000000000000000000000 { rValue := mul(SCALE, 22) }
            case 100000000000000000000000000000000000000000 { rValue := mul(SCALE, 23) }
            case 1000000000000000000000000000000000000000000 { rValue := mul(SCALE, 24) }
            case 10000000000000000000000000000000000000000000 { rValue := mul(SCALE, 25) }
            case 100000000000000000000000000000000000000000000 { rValue := mul(SCALE, 26) }
            case 1000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 27) }
            case 10000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 28) }
            case 100000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 29) }
            case 1000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 30) }
            case 10000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 31) }
            case 100000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 32) }
            case 1000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 33) }
            case 10000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 34) }
            case 100000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 35) }
            case 1000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 36) }
            case 10000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 37) }
            case 100000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 38) }
            case 1000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 39) }
            case 10000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 40) }
            case 100000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 41) }
            case 1000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 42) }
            case 10000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 43) }
            case 100000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 44) }
            case 1000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 45) }
            case 10000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 46) }
            case 100000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 47) }
            case 1000000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 48) }
            case 10000000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 49) }
            case 100000000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 50) }
            case 1000000000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 51) }
            case 10000000000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 52) }
            case 100000000000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 53) }
            case 1000000000000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 54) }
            case 10000000000000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 55) }
            case 100000000000000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 56) }
            case 1000000000000000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 57) }
            case 10000000000000000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 58) }
            case 100000000000000000000000000000000000000000000000000000000000000000000000000000 { rValue := mul(SCALE, 59) }
            default {
                rValue := MAX_UD60x18
            }
        }

        if (rValue != MAX_UD60x18) {
            result = PRBMath.UD60x18({ value: rValue });
        } else {
            // Do the fixed-point division inline to save gas. The denominator is log2(10).
            unchecked {
                rValue = (log2(x).value * SCALE) / 3_321928094887362347;
                result = PRBMath.UD60x18({ value: rValue });
            }
        }
    }

    /// @notice Calculates the binary logarithm of x.
    ///
    /// @dev Based on the iterative approximation algorithm.
    /// https://en.wikipedia.org/wiki/Binary_logarithm#Iterative_approximation
    ///
    /// Requirements:
    /// - x must be greater than or equal to SCALE, otherwise the result would be negative.
    ///
    /// Caveats:
    /// - The results are nor perfectly accurate to the last decimal, due to the lossy precision of the iterative approximation.
    ///
    /// @param x The unsigned 60.18-decimal fixed-point number for which to calculate the binary logarithm.
    /// @return result The binary logarithm as an unsigned 60.18-decimal fixed-point number.
    function log2(PRBMath.UD60x18 memory x) internal pure returns (PRBMath.UD60x18 memory result) {
        uint256 xValue = x.value;
        if (xValue < SCALE) {
            revert PRBMathUD60x18__LogInputTooSmall(xValue);
        }
        unchecked {
            // Calculate the integer part of the logarithm and add it to the result and finally calculate y = x * 2^(-n).
            uint256 n = PRBMath.mostSignificantBit(xValue / SCALE);

            // The integer part of the logarithm as an unsigned 60.18-decimal fixed-point number. The operation can't overflow
            // because n is maximum 255 and SCALE is 1e18.
            uint256 rValue = n * SCALE;

            // This is y = x * 2^(-n).
            uint256 y = xValue >> n;

            // If y = 1, the fractional part is zero.
            if (y == SCALE) {
                return PRBMath.UD60x18({ value: rValue });
            }

            // Calculate the fractional part via the iterative approximation.
            // The "delta >>= 1" part is equivalent to "delta /= 2", but shifting bits is faster.
            for (uint256 delta = HALF_SCALE; delta > 0; delta >>= 1) {
                y = (y * y) / SCALE;

                // Is y^2 > 2 and so in the range [2,4)?
                if (y >= 2 * SCALE) {
                    // Add the 2^(-m) factor to the logarithm.
                    rValue += delta;

                    // Corresponds to z/2 on Wikipedia.
                    y >>= 1;
                }
            }
            result = PRBMath.UD60x18({ value: rValue });
        }
    }

    /// @notice Multiplies two unsigned 60.18-decimal fixed-point numbers together, returning a new unsigned 60.18-decimal
    /// fixed-point number.
    /// @dev See the documentation for the "PRBMath.mulDivFixedPoint" function.
    /// @param x The multiplicand as an unsigned 60.18-decimal fixed-point number.
    /// @param y The multiplier as an unsigned 60.18-decimal fixed-point number.
    /// @return result The product as an unsigned 60.18-decimal fixed-point number.
    function mul(PRBMath.UD60x18 memory x, PRBMath.UD60x18 memory y)
        internal
        pure
        returns (PRBMath.UD60x18 memory result)
    {
        result = PRBMath.UD60x18({ value: PRBMath.mulDivFixedPoint(x.value, y.value) });
    }

    /// @notice Returns PI as an unsigned 60.18-decimal fixed-point number.
    function pi() internal pure returns (PRBMath.UD60x18 memory result) {
        result = PRBMath.UD60x18({ value: 3_141592653589793238 });
    }

    /// @notice Raises x to the power of y.
    ///
    /// @dev Based on the insight that x^y = 2^(log2(x) * y).
    ///
    /// Requirements:
    /// - All from "exp2", "log2" and "mul".
    ///
    /// Caveats:
    /// - All from "exp2", "log2" and "mul".
    /// - Assumes 0^0 is 1.
    ///
    /// @param x Number to raise to given power y, as an unsigned 60.18-decimal fixed-point number.
    /// @param y Exponent to raise x to, as an unsigned 60.18-decimal fixed-point number.
    /// @return result x raised to power y, as an unsigned 60.18-decimal fixed-point number.
    function pow(PRBMath.UD60x18 memory x, PRBMath.UD60x18 memory y)
        internal
        pure
        returns (PRBMath.UD60x18 memory result)
    {
        if (x.value == 0) {
            return PRBMath.UD60x18({ value: y.value == 0 ? SCALE : uint256(0) });
        } else {
            result = exp2(mul(log2(x), y));
        }
    }

    /// @notice Raises x (unsigned 60.18-decimal fixed-point number) to the power of y (basic unsigned integer) using the
    /// famous algorithm "exponentiation by squaring".
    ///
    /// @dev See https://en.wikipedia.org/wiki/Exponentiation_by_squaring
    ///
    /// Requirements:
    /// - The result must fit within MAX_UD60x18.
    ///
    /// Caveats:
    /// - All from "mul".
    /// - Assumes 0^0 is 1.
    ///
    /// @param x The base as an unsigned 60.18-decimal fixed-point number.
    /// @param y The exponent as an uint256.
    /// @return result The result as an unsigned 60.18-decimal fixed-point number.
    function powu(PRBMath.UD60x18 memory x, uint256 y) internal pure returns (PRBMath.UD60x18 memory result) {
        // Calculate the first iteration of the loop in advance.
        uint256 xValue = x.value;
        uint256 rValue = y & 1 > 0 ? xValue : SCALE;

        // Equivalent to "for(y /= 2; y > 0; y /= 2)" but faster.
        for (y >>= 1; y > 0; y >>= 1) {
            xValue = PRBMath.mulDivFixedPoint(xValue, xValue);

            // Equivalent to "y % 2 == 1" but faster.
            if (y & 1 > 0) {
                rValue = PRBMath.mulDivFixedPoint(rValue, xValue);
            }
        }
        result = PRBMath.UD60x18({ value: rValue });
    }

    /// @notice Returns 1 as an unsigned 60.18-decimal fixed-point number.
    function scale() internal pure returns (PRBMath.UD60x18 memory result) {
        result = PRBMath.UD60x18({ value: SCALE });
    }

    /// @notice Calculates the square root of x, rounding down.
    /// @dev Uses the Babylonian method https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
    ///
    /// Requirements:
    /// - x must be less than MAX_UD60x18 / SCALE.
    ///
    /// @param x The unsigned 60.18-decimal fixed-point number for which to calculate the square root.
    /// @return result The result as an unsigned 60.18-decimal fixed-point .
    function sqrt(PRBMath.UD60x18 memory x) internal pure returns (PRBMath.UD60x18 memory result) {
        unchecked {
            if (x.value > MAX_UD60x18 / SCALE) {
                revert PRBMathUD60x18__SqrtOverflow(x.value);
            }
            // Multiply x by the SCALE to account for the factor of SCALE that is picked up when multiplying two unsigned
            // 60.18-decimal fixed-point numbers together (in this case, those two numbers are both the square root).
            result = PRBMath.UD60x18({ value: PRBMath.sqrt(x.value * SCALE) });
        }
    }

    /// @notice Subtracts one unsigned 60.18-decimal fixed-point number from another one, returning a new unsigned 60.18-decimal
    /// fixed-point number.
    /// @param x The minuend as an unsigned 60.18-decimal fixed-point number.
    /// @param y The subtrahend as an unsigned 60.18-decimal fixed-point number.
    /// @param result The difference as an unsigned 60.18 decimal fixed-point number.
    function sub(PRBMath.UD60x18 memory x, PRBMath.UD60x18 memory y)
        internal
        pure
        returns (PRBMath.UD60x18 memory result)
    {
        unchecked {
            if (x.value < y.value) {
                revert PRBMathUD60x18__SubUnderflow(x.value, y.value);
            }
            result = PRBMath.UD60x18({ value: x.value - y.value });
        }
    }

    /// @notice Converts a unsigned 60.18-decimal fixed-point number to basic integer form, rounding down in the process.
    /// @param x The unsigned 60.18-decimal fixed-point number to convert.
    /// @return result The same number in basic integer form.
    function toUint(PRBMath.UD60x18 memory x) internal pure returns (uint256 result) {
        unchecked {
            result = x.value / SCALE;
        }
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
    @title Calendar
    @author iMe Group
    @notice Small date and time library
 */
library Calendar {
    /**
        @notice Count round periods over time interval
        
        @dev Example case, where function should return 3:
        
         duration = |-----|
        
             start              end
               |                 |
               V                 V
        -----|-----|-----|-----|-----|-----|---
    
        @param start Interval start
        @param end Interval end
        @param duration Period duration
     */
    function countPeriods(
        uint256 start,
        uint256 end,
        uint256 duration
    ) internal pure returns (uint256) {
        if (end <= start) return 0;

        return
            ((end - start) / duration) +
            (start % duration > end % duration ? 1 : 0);
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
    @title Sorter
    @author iMe Group
    @notice Small sorting library
 */
library Sorter {
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
    @title IImeStakingCore
    @author iMe Group
    @notice Interface for general staking functionality.
 */
interface IImeStakingCore {
    /**
        @notice Yields staking name

        @return name Human-readable staking name. As example, "LIME Polygon v1"
     */
    function name() external view returns (string memory);

    /**
        @notice Yields human-readable staking author.

        @return author Identifier of staking author. As example, "iMe Lab", "Tether ltd"
     */
    function author() external view returns (string memory);

    /**
        @notice Yields staking version

        @return version Staking version
     */
    function version() external view returns (string memory);

    /**
        @notice Yields staking erc20-token address
     */
    function token() external view returns (address);

    /**
        @notice Yields erc20-token for fees
     */
    function feeToken() external view returns (address);

    /**
        @notice Yields staking start timestamp
        Participants can't make deposits before this moment
     */
    function startsAt() external view returns (uint256);

    /**
        @notice Yields staking finish timestamp
        Participants can't make deposits after this moment
     */
    function endsAt() external view returns (uint256);

    /**
        @notice Yields one-time profit for deposit of 1e9 tokens
     */
    function income() external view returns (uint256);

    /**
        @notice Yields income period

        @return period Income period in seconds
     */
    function incomePeriod() external view returns (uint256 period);

    /**
        @notice Yields fee for premature withdrawals

        @return fee Fee amount, taken from 1e9 withdrawn tokens
     */
    function prematureWithdrawalFee() external view returns (uint256 fee);

    /**
        @notice Yields fee for safe withdrawals

        @return fee Fee amount, taken from 1e9 withdrawn tokens
     */
    function safeWithdrawalFee() external view returns (uint256 fee);

    /**
        @notice Yields duration of safe withdrawal
     */
    function safeWithdrawalDuration() external view returns (uint256);

    /**
        @notice Yields minimal amount of impact, needed to enable
        compound interest accrual
     */
    function compoundAccrualThreshold() external view returns (uint256);

    /**
        @notice Yields staking's debt for certain participant, for present moment
     */
    function debtOf(address account) external view returns (uint256);

    /**
        @notice Yields certain account's impact in this staking
     */
    function impactOf(address account) external view returns (uint256);

    /**
        @notice Yields certain account's safely withdrawn tokens status for present moment
     */
    function safelyWithdrawnTokensOf(address account)
        external
        view
        returns (uint256 pending, uint256 ready);

    /**
        @notice Estimates solvency status by the time of staking finish

        @return lack Amount of tokens, needed to cover a debt
        @return excess Redundant tokens in contract balance, which may be rescued
     */
    function estimateSolvency(uint256 at)
        external
        view
        returns (uint256 lack, uint256 excess);

    /**
        @notice Stake tokens
    
        @param amount Deposit amount

        @dev
        Reverts with **DepositTooEarly** on attempt of deposit before staking start
        Reverts with **DepositTooLate** on attempt of deposit after staking finish
        Reverts with **DepositDisabled** of deposits are disabled at the moment
        Emits **Deposit** on successful deposit
     */
    function stake(uint256 amount) external;

    error DepositTooEarly(uint256 at, uint256 minimalTime);
    error DepositTooLate(uint256 at, uint256 maximalTime);
    error DepositDisabled();
    event Deposit(address indexed from, uint256 amount);

    /**
        @notice Withdraw tokens
    
        @param amount Withdrawn tokens amount
        @param safe Use safe withdrawal or not

        @dev
        Reverts with **WithdrawalOverLimit** on attempt to withdraw over withdrawal limit
        Reverts with **WithdrawalDisabled** if withdrawals are disabled at the moment
        Emits **Withdrawal** event on successful withdrawal
     */
    function withdraw(uint256 amount, bool safe) external;

    error WithdrawalOverLimit(uint256 requested, uint256 available);
    error WithdrawalDisabled();
    event Withdrawal(address indexed to, uint256 amount, uint256 fee);

    /**
        @notice Claim safely withdrawn tokens

        @dev
        Emits **Claim** event on successful claim
     */
    function claim() external;

    event Claim(address indexed to, uint256 amount);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
    @title IImeStakingManageable
    @author iMe Group
    @notice Interface for management iMe Staking functionality
 */
interface IImeStakingManageable {
    /**
        @notice Change deposit-ability
     */
    function manageDeposits(bool allowed) external;

    /**
        @notice Change withdrawal-ability
     */
    function manageWithdrawals(bool allowed) external;

    /**
        @notice Set staking lifespan
        
        @dev Reverts with StakingLifespanInvalid if its invalid.
        Also, reverts with StakingLifespanInvalid on attempt to set endsAt to past.
     */
    function setLifespan(uint256 start, uint256 end) external;

    error StakingLifespanInvalid();

    /**
        @notice Set withdrawal fee amount
    
        @param safe Manage safe withdrawal fee or not
        @param fee Fee taken from 10e9
     */
    function setWithdrawalFee(bool safe, uint256 fee) external;

    /**
        @notice Withdraw free tokens from contract balance
        
        @param amount Amount to rescue
        @param to Withdrawn tokens destination

        @dev Reverts with RescueOverFreeTokens if requested too much
     */
    function rescueFunds(uint256 amount, address to) external;

    error RescueOverFreeTokens(uint256 requested, uint256 available);

    /**
        @notice Withdraw all free tokens from contract balance
    
        @param to Withdrawn tokens destination
     */
    function rescueFunds(address to) external;

    /**
        @notice Perform withdrawal for certain investor

        @dev Should throw ForceWithdrawalTooEarly on
        force withdrawal before staking finish
     */
    function forceWithdrawal(address to) external;

    error ForceWithdrawalTooEarly(uint256 notBefore);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/**
    @title ImeStakingAccessControl
    @author iMe Group
    @notice Contract, implementing access control for iMe Staking v1

    @dev
                         ======================
                   ------| DEFAULT_ADMIN_ROLE | -----
                   |     ======================     |
                   |     - Manages other roles      |
                   |                                |
                   V                                V
      ========================          =======================
      | STAKING_MANAGER_ROLE |          | STAKING_BANKER_ROLE |
      ========================          =======================
      - Configures staking              - Can withdraw free tokens
      - Suitable for staking            - Suitable for staking partners
        maintainers
 */
contract ImeStakingAccessControl is AccessControl {
    /**
        @dev Role for staking management operations
     */
    bytes32 public constant STAKING_MANAGER_ROLE =
        keccak256("STAKING_MANAGER_ROLE");

    /**
        @dev Role for staking balance management
     */
    bytes32 public constant STAKING_BANKER_ROLE =
        keccak256("STAKING_BANKER_ROLE");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
    @title TimeContext
    @author iMe Group
    @notice Contract fragment, providing context of present moment
    Inspired by openzeppelin/context and should be used in the same way.
 */
abstract contract TimeContext {
    /**
        @notice Get present moment timestamp
        
        @dev It should be overridden in mock contracts
        Any implementation of this function should follow a rule:
        sequential calls of _now() should give non-decreasing sequence of numbers.
        It's forbidden to travel back in time.
     */
    function _now() internal view virtual returns (uint256) {
        // solhint-disable-next-line not-rely-on-time
        return block.timestamp;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CommonInterest} from "./CommonInterest.sol";
import {Calendar} from "../lib/Calendar.sol";
import {Sorter} from "../lib/Sorter.sol";
import {PRBMathUD60x18Typed as Math, PRBMath} from "prb-math/contracts/PRBMathUD60x18Typed.sol";

/**
    @title SimpleInterest
    @author iMe Group

    @notice Contract, implementing simple interest accrual.
    Implements only logical accrual, without actual token transfer
 */
abstract contract SimpleInterest is CommonInterest {
    mapping(address => uint256) private _simpleDeposits;
    uint256 private _totalSimpleDeposit = 0;
    uint256 private _simpleAnchor;

    constructor(uint256 anchor) {
        _simpleAnchor = anchor;
    }

    function _deposit(
        address investor,
        uint256 amount,
        uint256 at
    ) internal virtual override {
        uint256 increase = _simpleConverge(amount, at, _simpleAnchor);

        _simpleDeposits[investor] += increase;
        _totalSimpleDeposit += increase;
    }

    function _withdrawal(
        address investor,
        uint256 amount,
        uint256 at
    ) internal virtual override {
        uint256 deposit = _simpleDeposits[investor];
        uint256 available = _simpleConverge(deposit, _simpleAnchor, at);

        if (amount < available) {
            uint256 decrease = _simpleConverge(amount, at, _simpleAnchor);

            decrease = Sorter.min(decrease, deposit);

            _totalSimpleDeposit -= decrease;
            _simpleDeposits[investor] -= decrease;
        } else if (amount == available) {
            _totalSimpleDeposit -= deposit;
            delete _simpleDeposits[investor];
        } else {
            revert("Not enough tokens for withdrawal");
        }
    }

    function _debtOf(address investor, uint256 at)
        internal
        view
        virtual
        override
        returns (uint256)
    {
        return _simpleConverge(_simpleDeposits[investor], _simpleAnchor, at);
    }

    function _totalDebt(uint256 at)
        internal
        view
        virtual
        override
        returns (uint256)
    {
        return _simpleConverge(_totalSimpleDeposit, _simpleAnchor, at);
    }

    function _simpleConverge(
        uint256 sum,
        uint256 from,
        uint256 to
    ) private view returns (uint256) {
        bool backwards = to < from;
        (from, to) = (Sorter.min(from, to), Sorter.max(from, to));

        PRBMath.UD60x18 memory m = Math.add(
            Math.fromUint(1),
            Math.mul(
                _accrualPercent(),
                Math.fromUint(Calendar.countPeriods(from, to, _accrualPeriod()))
            )
        );

        if (backwards) {
            return Math.toUint(Math.div(Math.fromUint(sum), m));
        } else {
            return Math.toUint(Math.mul(Math.fromUint(sum), m));
        }
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CommonInterest} from "./CommonInterest.sol";
import {Calendar} from "../lib/Calendar.sol";
import {Sorter} from "../lib/Sorter.sol";
import {PRBMathUD60x18Typed as Math, PRBMath} from "prb-math/contracts/PRBMathUD60x18Typed.sol";

/**
    @title CompoundInterest
    @author iMe Group

    @notice Contract, implementing interest accrual via compound strategy
 */
abstract contract CompoundInterest is CommonInterest {
    mapping(address => uint256) private _compoundDeposits;
    uint256 private _totalCompoundDeposit;
    uint256 private _compoundAnchor;

    constructor(uint256 anchor) {
        _compoundAnchor = anchor;
    }

    function _deposit(
        address investor,
        uint256 amount,
        uint256 at
    ) internal virtual override {
        uint256 increase = _compoundConverge(amount, at, _compoundAnchor);

        _compoundDeposits[investor] += increase;
        _totalCompoundDeposit += increase;
    }

    function _withdrawal(
        address investor,
        uint256 amount,
        uint256 at
    ) internal virtual override {
        uint256 deposit = _compoundDeposits[investor];
        uint256 available = _compoundConverge(deposit, _compoundAnchor, at);

        if (amount < available) {
            uint256 decrease = _compoundConverge(amount, at, _compoundAnchor);

            decrease = Sorter.min(decrease, deposit);

            _totalCompoundDeposit -= decrease;
            _compoundDeposits[investor] -= decrease;
        } else if (amount == available) {
            _totalCompoundDeposit -= deposit;
            delete _compoundDeposits[investor];
        } else {
            revert("Not enough tokens for withdrawal");
        }
    }

    function _debtOf(address investor, uint256 at)
        internal
        view
        virtual
        override
        returns (uint256)
    {
        return
            _compoundConverge(_compoundDeposits[investor], _compoundAnchor, at);
    }

    function _totalDebt(uint256 at)
        internal
        view
        virtual
        override
        returns (uint256)
    {
        return _compoundConverge(_totalCompoundDeposit, _compoundAnchor, at);
    }

    function _compoundConverge(
        uint256 sum,
        uint256 from,
        uint256 to
    ) private view returns (uint256) {
        bool backwards = from > to;
        (from, to) = (Sorter.min(from, to), Sorter.max(from, to));

        PRBMath.UD60x18 memory m = Math.powu(
            Math.add(Math.fromUint(1), _accrualPercent()),
            Calendar.countPeriods(from, to, _accrualPeriod())
        );

        if (backwards) {
            return Math.toUint(Math.div(Math.fromUint(sum), m));
        } else {
            return Math.toUint(Math.mul(Math.fromUint(sum), m));
        }
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.4;

/// @notice Emitted when the result overflows uint256.
error PRBMath__MulDivFixedPointOverflow(uint256 prod1);

/// @notice Emitted when the result overflows uint256.
error PRBMath__MulDivOverflow(uint256 prod1, uint256 denominator);

/// @notice Emitted when one of the inputs is type(int256).min.
error PRBMath__MulDivSignedInputTooSmall();

/// @notice Emitted when the intermediary absolute result overflows int256.
error PRBMath__MulDivSignedOverflow(uint256 rAbs);

/// @notice Emitted when the input is MIN_SD59x18.
error PRBMathSD59x18__AbsInputTooSmall();

/// @notice Emitted when ceiling a number overflows SD59x18.
error PRBMathSD59x18__CeilOverflow(int256 x);

/// @notice Emitted when one of the inputs is MIN_SD59x18.
error PRBMathSD59x18__DivInputTooSmall();

/// @notice Emitted when one of the intermediary unsigned results overflows SD59x18.
error PRBMathSD59x18__DivOverflow(uint256 rAbs);

/// @notice Emitted when the input is greater than 133.084258667509499441.
error PRBMathSD59x18__ExpInputTooBig(int256 x);

/// @notice Emitted when the input is greater than 192.
error PRBMathSD59x18__Exp2InputTooBig(int256 x);

/// @notice Emitted when flooring a number underflows SD59x18.
error PRBMathSD59x18__FloorUnderflow(int256 x);

/// @notice Emitted when converting a basic integer to the fixed-point format overflows SD59x18.
error PRBMathSD59x18__FromIntOverflow(int256 x);

/// @notice Emitted when converting a basic integer to the fixed-point format underflows SD59x18.
error PRBMathSD59x18__FromIntUnderflow(int256 x);

/// @notice Emitted when the product of the inputs is negative.
error PRBMathSD59x18__GmNegativeProduct(int256 x, int256 y);

/// @notice Emitted when multiplying the inputs overflows SD59x18.
error PRBMathSD59x18__GmOverflow(int256 x, int256 y);

/// @notice Emitted when the input is less than or equal to zero.
error PRBMathSD59x18__LogInputTooSmall(int256 x);

/// @notice Emitted when one of the inputs is MIN_SD59x18.
error PRBMathSD59x18__MulInputTooSmall();

/// @notice Emitted when the intermediary absolute result overflows SD59x18.
error PRBMathSD59x18__MulOverflow(uint256 rAbs);

/// @notice Emitted when the intermediary absolute result overflows SD59x18.
error PRBMathSD59x18__PowuOverflow(uint256 rAbs);

/// @notice Emitted when the input is negative.
error PRBMathSD59x18__SqrtNegativeInput(int256 x);

/// @notice Emitted when the calculating the square root overflows SD59x18.
error PRBMathSD59x18__SqrtOverflow(int256 x);

/// @notice Emitted when addition overflows UD60x18.
error PRBMathUD60x18__AddOverflow(uint256 x, uint256 y);

/// @notice Emitted when ceiling a number overflows UD60x18.
error PRBMathUD60x18__CeilOverflow(uint256 x);

/// @notice Emitted when the input is greater than 133.084258667509499441.
error PRBMathUD60x18__ExpInputTooBig(uint256 x);

/// @notice Emitted when the input is greater than 192.
error PRBMathUD60x18__Exp2InputTooBig(uint256 x);

/// @notice Emitted when converting a basic integer to the fixed-point format format overflows UD60x18.
error PRBMathUD60x18__FromUintOverflow(uint256 x);

/// @notice Emitted when multiplying the inputs overflows UD60x18.
error PRBMathUD60x18__GmOverflow(uint256 x, uint256 y);

/// @notice Emitted when the input is less than 1.
error PRBMathUD60x18__LogInputTooSmall(uint256 x);

/// @notice Emitted when the calculating the square root overflows UD60x18.
error PRBMathUD60x18__SqrtOverflow(uint256 x);

/// @notice Emitted when subtraction underflows UD60x18.
error PRBMathUD60x18__SubUnderflow(uint256 x, uint256 y);

/// @dev Common mathematical functions used in both PRBMathSD59x18 and PRBMathUD60x18. Note that this shared library
/// does not always assume the signed 59.18-decimal fixed-point or the unsigned 60.18-decimal fixed-point
/// representation. When it does not, it is explicitly mentioned in the NatSpec documentation.
library PRBMath {
    /// STRUCTS ///

    struct SD59x18 {
        int256 value;
    }

    struct UD60x18 {
        uint256 value;
    }

    /// STORAGE ///

    /// @dev How many trailing decimals can be represented.
    uint256 internal constant SCALE = 1e18;

    /// @dev Largest power of two divisor of SCALE.
    uint256 internal constant SCALE_LPOTD = 262144;

    /// @dev SCALE inverted mod 2^256.
    uint256 internal constant SCALE_INVERSE =
        78156646155174841979727994598816262306175212592076161876661_508869554232690281;

    /// FUNCTIONS ///

    /// @notice Calculates the binary exponent of x using the binary fraction method.
    /// @dev Has to use 192.64-bit fixed-point numbers.
    /// See https://ethereum.stackexchange.com/a/96594/24693.
    /// @param x The exponent as an unsigned 192.64-bit fixed-point number.
    /// @return result The result as an unsigned 60.18-decimal fixed-point number.
    function exp2(uint256 x) internal pure returns (uint256 result) {
        unchecked {
            // Start from 0.5 in the 192.64-bit fixed-point format.
            result = 0x800000000000000000000000000000000000000000000000;

            // Multiply the result by root(2, 2^-i) when the bit at position i is 1. None of the intermediary results overflows
            // because the initial result is 2^191 and all magic factors are less than 2^65.
            if (x & 0x8000000000000000 > 0) {
                result = (result * 0x16A09E667F3BCC909) >> 64;
            }
            if (x & 0x4000000000000000 > 0) {
                result = (result * 0x1306FE0A31B7152DF) >> 64;
            }
            if (x & 0x2000000000000000 > 0) {
                result = (result * 0x1172B83C7D517ADCE) >> 64;
            }
            if (x & 0x1000000000000000 > 0) {
                result = (result * 0x10B5586CF9890F62A) >> 64;
            }
            if (x & 0x800000000000000 > 0) {
                result = (result * 0x1059B0D31585743AE) >> 64;
            }
            if (x & 0x400000000000000 > 0) {
                result = (result * 0x102C9A3E778060EE7) >> 64;
            }
            if (x & 0x200000000000000 > 0) {
                result = (result * 0x10163DA9FB33356D8) >> 64;
            }
            if (x & 0x100000000000000 > 0) {
                result = (result * 0x100B1AFA5ABCBED61) >> 64;
            }
            if (x & 0x80000000000000 > 0) {
                result = (result * 0x10058C86DA1C09EA2) >> 64;
            }
            if (x & 0x40000000000000 > 0) {
                result = (result * 0x1002C605E2E8CEC50) >> 64;
            }
            if (x & 0x20000000000000 > 0) {
                result = (result * 0x100162F3904051FA1) >> 64;
            }
            if (x & 0x10000000000000 > 0) {
                result = (result * 0x1000B175EFFDC76BA) >> 64;
            }
            if (x & 0x8000000000000 > 0) {
                result = (result * 0x100058BA01FB9F96D) >> 64;
            }
            if (x & 0x4000000000000 > 0) {
                result = (result * 0x10002C5CC37DA9492) >> 64;
            }
            if (x & 0x2000000000000 > 0) {
                result = (result * 0x1000162E525EE0547) >> 64;
            }
            if (x & 0x1000000000000 > 0) {
                result = (result * 0x10000B17255775C04) >> 64;
            }
            if (x & 0x800000000000 > 0) {
                result = (result * 0x1000058B91B5BC9AE) >> 64;
            }
            if (x & 0x400000000000 > 0) {
                result = (result * 0x100002C5C89D5EC6D) >> 64;
            }
            if (x & 0x200000000000 > 0) {
                result = (result * 0x10000162E43F4F831) >> 64;
            }
            if (x & 0x100000000000 > 0) {
                result = (result * 0x100000B1721BCFC9A) >> 64;
            }
            if (x & 0x80000000000 > 0) {
                result = (result * 0x10000058B90CF1E6E) >> 64;
            }
            if (x & 0x40000000000 > 0) {
                result = (result * 0x1000002C5C863B73F) >> 64;
            }
            if (x & 0x20000000000 > 0) {
                result = (result * 0x100000162E430E5A2) >> 64;
            }
            if (x & 0x10000000000 > 0) {
                result = (result * 0x1000000B172183551) >> 64;
            }
            if (x & 0x8000000000 > 0) {
                result = (result * 0x100000058B90C0B49) >> 64;
            }
            if (x & 0x4000000000 > 0) {
                result = (result * 0x10000002C5C8601CC) >> 64;
            }
            if (x & 0x2000000000 > 0) {
                result = (result * 0x1000000162E42FFF0) >> 64;
            }
            if (x & 0x1000000000 > 0) {
                result = (result * 0x10000000B17217FBB) >> 64;
            }
            if (x & 0x800000000 > 0) {
                result = (result * 0x1000000058B90BFCE) >> 64;
            }
            if (x & 0x400000000 > 0) {
                result = (result * 0x100000002C5C85FE3) >> 64;
            }
            if (x & 0x200000000 > 0) {
                result = (result * 0x10000000162E42FF1) >> 64;
            }
            if (x & 0x100000000 > 0) {
                result = (result * 0x100000000B17217F8) >> 64;
            }
            if (x & 0x80000000 > 0) {
                result = (result * 0x10000000058B90BFC) >> 64;
            }
            if (x & 0x40000000 > 0) {
                result = (result * 0x1000000002C5C85FE) >> 64;
            }
            if (x & 0x20000000 > 0) {
                result = (result * 0x100000000162E42FF) >> 64;
            }
            if (x & 0x10000000 > 0) {
                result = (result * 0x1000000000B17217F) >> 64;
            }
            if (x & 0x8000000 > 0) {
                result = (result * 0x100000000058B90C0) >> 64;
            }
            if (x & 0x4000000 > 0) {
                result = (result * 0x10000000002C5C860) >> 64;
            }
            if (x & 0x2000000 > 0) {
                result = (result * 0x1000000000162E430) >> 64;
            }
            if (x & 0x1000000 > 0) {
                result = (result * 0x10000000000B17218) >> 64;
            }
            if (x & 0x800000 > 0) {
                result = (result * 0x1000000000058B90C) >> 64;
            }
            if (x & 0x400000 > 0) {
                result = (result * 0x100000000002C5C86) >> 64;
            }
            if (x & 0x200000 > 0) {
                result = (result * 0x10000000000162E43) >> 64;
            }
            if (x & 0x100000 > 0) {
                result = (result * 0x100000000000B1721) >> 64;
            }
            if (x & 0x80000 > 0) {
                result = (result * 0x10000000000058B91) >> 64;
            }
            if (x & 0x40000 > 0) {
                result = (result * 0x1000000000002C5C8) >> 64;
            }
            if (x & 0x20000 > 0) {
                result = (result * 0x100000000000162E4) >> 64;
            }
            if (x & 0x10000 > 0) {
                result = (result * 0x1000000000000B172) >> 64;
            }
            if (x & 0x8000 > 0) {
                result = (result * 0x100000000000058B9) >> 64;
            }
            if (x & 0x4000 > 0) {
                result = (result * 0x10000000000002C5D) >> 64;
            }
            if (x & 0x2000 > 0) {
                result = (result * 0x1000000000000162E) >> 64;
            }
            if (x & 0x1000 > 0) {
                result = (result * 0x10000000000000B17) >> 64;
            }
            if (x & 0x800 > 0) {
                result = (result * 0x1000000000000058C) >> 64;
            }
            if (x & 0x400 > 0) {
                result = (result * 0x100000000000002C6) >> 64;
            }
            if (x & 0x200 > 0) {
                result = (result * 0x10000000000000163) >> 64;
            }
            if (x & 0x100 > 0) {
                result = (result * 0x100000000000000B1) >> 64;
            }
            if (x & 0x80 > 0) {
                result = (result * 0x10000000000000059) >> 64;
            }
            if (x & 0x40 > 0) {
                result = (result * 0x1000000000000002C) >> 64;
            }
            if (x & 0x20 > 0) {
                result = (result * 0x10000000000000016) >> 64;
            }
            if (x & 0x10 > 0) {
                result = (result * 0x1000000000000000B) >> 64;
            }
            if (x & 0x8 > 0) {
                result = (result * 0x10000000000000006) >> 64;
            }
            if (x & 0x4 > 0) {
                result = (result * 0x10000000000000003) >> 64;
            }
            if (x & 0x2 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }
            if (x & 0x1 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }

            // We're doing two things at the same time:
            //
            //   1. Multiply the result by 2^n + 1, where "2^n" is the integer part and the one is added to account for
            //      the fact that we initially set the result to 0.5. This is accomplished by subtracting from 191
            //      rather than 192.
            //   2. Convert the result to the unsigned 60.18-decimal fixed-point format.
            //
            // This works because 2^(191-ip) = 2^ip / 2^191, where "ip" is the integer part "2^n".
            result *= SCALE;
            result >>= (191 - (x >> 64));
        }
    }

    /// @notice Finds the zero-based index of the first one in the binary representation of x.
    /// @dev See the note on msb in the "Find First Set" Wikipedia article https://en.wikipedia.org/wiki/Find_first_set
    /// @param x The uint256 number for which to find the index of the most significant bit.
    /// @return msb The index of the most significant bit as an uint256.
    function mostSignificantBit(uint256 x) internal pure returns (uint256 msb) {
        if (x >= 2**128) {
            x >>= 128;
            msb += 128;
        }
        if (x >= 2**64) {
            x >>= 64;
            msb += 64;
        }
        if (x >= 2**32) {
            x >>= 32;
            msb += 32;
        }
        if (x >= 2**16) {
            x >>= 16;
            msb += 16;
        }
        if (x >= 2**8) {
            x >>= 8;
            msb += 8;
        }
        if (x >= 2**4) {
            x >>= 4;
            msb += 4;
        }
        if (x >= 2**2) {
            x >>= 2;
            msb += 2;
        }
        if (x >= 2**1) {
            // No need to shift x any more.
            msb += 1;
        }
    }

    /// @notice Calculates floor(x*y÷denominator) with full precision.
    ///
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv.
    ///
    /// Requirements:
    /// - The denominator cannot be zero.
    /// - The result must fit within uint256.
    ///
    /// Caveats:
    /// - This function does not work with fixed-point numbers.
    ///
    /// @param x The multiplicand as an uint256.
    /// @param y The multiplier as an uint256.
    /// @param denominator The divisor as an uint256.
    /// @return result The result as an uint256.
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
        // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2^256 + prod0.
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(x, y, not(0))
            prod0 := mul(x, y)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        // Handle non-overflow cases, 256 by 256 division.
        if (prod1 == 0) {
            unchecked {
                result = prod0 / denominator;
            }
            return result;
        }

        // Make sure the result is less than 2^256. Also prevents denominator == 0.
        if (prod1 >= denominator) {
            revert PRBMath__MulDivOverflow(prod1, denominator);
        }

        ///////////////////////////////////////////////
        // 512 by 256 division.
        ///////////////////////////////////////////////

        // Make division exact by subtracting the remainder from [prod1 prod0].
        uint256 remainder;
        assembly {
            // Compute remainder using mulmod.
            remainder := mulmod(x, y, denominator)

            // Subtract 256 bit number from 512 bit number.
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
        // See https://cs.stackexchange.com/q/138556/92363.
        unchecked {
            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 lpotdod = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by lpotdod.
                denominator := div(denominator, lpotdod)

                // Divide [prod1 prod0] by lpotdod.
                prod0 := div(prod0, lpotdod)

                // Flip lpotdod such that it is 2^256 / lpotdod. If lpotdod is zero, then it becomes one.
                lpotdod := add(div(sub(0, lpotdod), lpotdod), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * lpotdod;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /// @notice Calculates floor(x*y÷1e18) with full precision.
    ///
    /// @dev Variant of "mulDiv" with constant folding, i.e. in which the denominator is always 1e18. Before returning the
    /// final result, we add 1 if (x * y) % SCALE >= HALF_SCALE. Without this, 6.6e-19 would be truncated to 0 instead of
    /// being rounded to 1e-18.  See "Listing 6" and text above it at https://accu.org/index.php/journals/1717.
    ///
    /// Requirements:
    /// - The result must fit within uint256.
    ///
    /// Caveats:
    /// - The body is purposely left uncommented; see the NatSpec comments in "PRBMath.mulDiv" to understand how this works.
    /// - It is assumed that the result can never be type(uint256).max when x and y solve the following two equations:
    ///     1. x * y = type(uint256).max * SCALE
    ///     2. (x * y) % SCALE >= SCALE / 2
    ///
    /// @param x The multiplicand as an unsigned 60.18-decimal fixed-point number.
    /// @param y The multiplier as an unsigned 60.18-decimal fixed-point number.
    /// @return result The result as an unsigned 60.18-decimal fixed-point number.
    function mulDivFixedPoint(uint256 x, uint256 y) internal pure returns (uint256 result) {
        uint256 prod0;
        uint256 prod1;
        assembly {
            let mm := mulmod(x, y, not(0))
            prod0 := mul(x, y)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        if (prod1 >= SCALE) {
            revert PRBMath__MulDivFixedPointOverflow(prod1);
        }

        uint256 remainder;
        uint256 roundUpUnit;
        assembly {
            remainder := mulmod(x, y, SCALE)
            roundUpUnit := gt(remainder, 499999999999999999)
        }

        if (prod1 == 0) {
            unchecked {
                result = (prod0 / SCALE) + roundUpUnit;
                return result;
            }
        }

        assembly {
            result := add(
                mul(
                    or(
                        div(sub(prod0, remainder), SCALE_LPOTD),
                        mul(sub(prod1, gt(remainder, prod0)), add(div(sub(0, SCALE_LPOTD), SCALE_LPOTD), 1))
                    ),
                    SCALE_INVERSE
                ),
                roundUpUnit
            )
        }
    }

    /// @notice Calculates floor(x*y÷denominator) with full precision.
    ///
    /// @dev An extension of "mulDiv" for signed numbers. Works by computing the signs and the absolute values separately.
    ///
    /// Requirements:
    /// - None of the inputs can be type(int256).min.
    /// - The result must fit within int256.
    ///
    /// @param x The multiplicand as an int256.
    /// @param y The multiplier as an int256.
    /// @param denominator The divisor as an int256.
    /// @return result The result as an int256.
    function mulDivSigned(
        int256 x,
        int256 y,
        int256 denominator
    ) internal pure returns (int256 result) {
        if (x == type(int256).min || y == type(int256).min || denominator == type(int256).min) {
            revert PRBMath__MulDivSignedInputTooSmall();
        }

        // Get hold of the absolute values of x, y and the denominator.
        uint256 ax;
        uint256 ay;
        uint256 ad;
        unchecked {
            ax = x < 0 ? uint256(-x) : uint256(x);
            ay = y < 0 ? uint256(-y) : uint256(y);
            ad = denominator < 0 ? uint256(-denominator) : uint256(denominator);
        }

        // Compute the absolute value of (x*y)÷denominator. The result must fit within int256.
        uint256 rAbs = mulDiv(ax, ay, ad);
        if (rAbs > uint256(type(int256).max)) {
            revert PRBMath__MulDivSignedOverflow(rAbs);
        }

        // Get the signs of x, y and the denominator.
        uint256 sx;
        uint256 sy;
        uint256 sd;
        assembly {
            sx := sgt(x, sub(0, 1))
            sy := sgt(y, sub(0, 1))
            sd := sgt(denominator, sub(0, 1))
        }

        // XOR over sx, sy and sd. This is checking whether there are one or three negative signs in the inputs.
        // If yes, the result should be negative.
        result = sx ^ sy ^ sd == 0 ? -int256(rAbs) : int256(rAbs);
    }

    /// @notice Calculates the square root of x, rounding down.
    /// @dev Uses the Babylonian method https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
    ///
    /// Caveats:
    /// - This function does not work with fixed-point numbers.
    ///
    /// @param x The uint256 number for which to calculate the square root.
    /// @return result The result as an uint256.
    function sqrt(uint256 x) internal pure returns (uint256 result) {
        if (x == 0) {
            return 0;
        }

        // Set the initial guess to the least power of two that is greater than or equal to sqrt(x).
        uint256 xAux = uint256(x);
        result = 1;
        if (xAux >= 0x100000000000000000000000000000000) {
            xAux >>= 128;
            result <<= 64;
        }
        if (xAux >= 0x10000000000000000) {
            xAux >>= 64;
            result <<= 32;
        }
        if (xAux >= 0x100000000) {
            xAux >>= 32;
            result <<= 16;
        }
        if (xAux >= 0x10000) {
            xAux >>= 16;
            result <<= 8;
        }
        if (xAux >= 0x100) {
            xAux >>= 8;
            result <<= 4;
        }
        if (xAux >= 0x10) {
            xAux >>= 4;
            result <<= 2;
        }
        if (xAux >= 0x8) {
            result <<= 1;
        }

        // The operations can never overflow because the result is max 2^127 when it enters this block.
        unchecked {
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1; // Seven iterations should be enough
            uint256 roundedDownResult = x / result;
            return result >= roundedDownResult ? roundedDownResult : result;
        }
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {PRBMathUD60x18Typed as Math, PRBMath} from "prb-math/contracts/PRBMathUD60x18Typed.sol";

/**
    @title CommonInterest
    @author iMe Group
    @notice Base contract for interest accrual
 */
abstract contract CommonInterest {
    /**
        @dev Accrual period. As ex,. 1 days or 1 week
     */
    function _accrualPeriod() internal view virtual returns (uint256);

    /**
        @dev Accrual percent per one period, as decimal.
        As example, for 3% there should be 0.03
     */
    function _accrualPercent()
        internal
        view
        virtual
        returns (PRBMath.UD60x18 memory);

    /**
        @dev Take a deposit
     */
    function _deposit(
        address investor,
        uint256 amount,
        uint256 at
    ) internal virtual;

    /**
        @dev Take a withdrawal
        Should revert with WithdrawalOverDebt on withdrawal over debt
     */
    function _withdrawal(
        address investor,
        uint256 amount,
        uint256 at
    ) internal virtual;

    /**
        @dev Yields debt for an investor
     */
    function _debtOf(address investor, uint256 at)
        internal
        view
        virtual
        returns (uint256);

    /**
        @dev Yields debt across all investors
     */
    function _totalDebt(uint256 at) internal view virtual returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}