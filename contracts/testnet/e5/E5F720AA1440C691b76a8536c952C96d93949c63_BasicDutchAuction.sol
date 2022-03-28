// Inspired by https://github.com/deepyr/DutchSwap
// Inspired by https://github.com/sushiswap/miso
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// ---------------------------------------------------------------------
// SPDX-License-Identifier: GPL-3.0-or-later
// ---------------------------------------------------------------------

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "../interfaces/IERC20Extended.sol";
import "../interfaces/IVoucherToken.sol";

contract BasicDutchAuction is ReentrancyGuard, Initializable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bytes32 public constant __TAG = keccak256("BasicDutchAuction");

    event WithdrawTokens(
        address indexed sender,
        address indexed token,
        uint256 amount,
        uint256 time
    );
    event DepositTokens(
        address indexed sender,
        address indexed token,
        uint256 amount,
        uint256 time
    );
    event DepositCollaterals(
        address indexed sender,
        address indexed token,
        uint256 amount,
        uint256 time
    );
    event WithdrawCollaterals(
        address indexed sender,
        address indexed token,
        uint256 amount,
        uint256 time
    );
    event WithdrawPayments(
        address indexed sender,
        address indexed token,
        uint256 amount,
        uint256 time
    );
    event AddedCommitment(address addr, uint256 commitment, uint256 time);

    uint256 public startTime;
    uint256 public endTime;
    uint256 public totalAmount;
    uint256 public targetAmount;
    uint256 public initialPrice;
    uint256 public reservePrice;
    address public paymentToken;
    uint256 public minimumLimit;
    uint256 public maximumLimit;
    uint256 public depositExpired;
    address public funder;

    bool public isCollateralsDeposited;
    bool public isCollateralsWithdrawn;
    bool public isTokensDeposited;
    bool public isTokensWithdrawn;

    uint256 public totalCommitments;
    mapping(address => uint256) public commitments;
    mapping(address => uint256) public claimed;

    address public auctionToken;
    address public feeReceiver;
    address public penaltyReceiver;
    uint256 public penaltyFee;
    uint256 public funderFee;
    uint256 public committerFee;
    address public depositToken;
    uint256 public depositAmount;

    function _initAuction(bytes memory _data) internal {
        (
            address _paymentToken,
            uint256 _totalAmount,
            uint256 _targetAmount,
            uint256 _minimumLimit,
            uint256 _maximumLimit,
            uint256 _startTime,
            uint256 _endTime,
            uint256 _initialPrice,
            uint256 _reservePrice,
            uint256 _depositExpired,
            address _funder
        ) = abi.decode(
                _data,
                (
                    address,
                    uint256,
                    uint256,
                    uint256,
                    uint256,
                    uint256,
                    uint256,
                    uint256,
                    uint256,
                    uint256,
                    address
                )
            );

        require(_startTime >= block.timestamp, "Start time is before current time");
        require(_endTime > _startTime, "End time must be older than start price");
        require(_totalAmount > 0, "Total tokens must be greater than zero");
        require(_initialPrice > _reservePrice, "Start price must be higher than minimum price");
        require(_reservePrice > 0, "Minimum price must be greater than 0");

        paymentToken = _paymentToken;
        totalAmount = _totalAmount;
        targetAmount = _targetAmount;
        minimumLimit = _minimumLimit;
        maximumLimit = _maximumLimit;
        startTime = _startTime;
        endTime = _endTime;
        initialPrice = _initialPrice;
        reservePrice = _reservePrice;
        depositExpired = _depositExpired;
        funder = _funder;
    }

    modifier onlyFunder() {
        require(msg.sender == funder, "only funder");
        _;
    }

    function priceDrop() public view returns (uint256) {
        uint256 numerator = initialPrice.sub(reservePrice);
        uint256 denominator = endTime.sub(startTime);
        return numerator.div(denominator);
    }

    function tokenPrice() public view returns (uint256) {
        return totalCommitments.mul(1e18).div(totalAmount);
    }

    function currentPrice() public view returns (uint256) {
        if (block.timestamp <= startTime) return initialPrice;
        if (block.timestamp >= endTime) return reservePrice;
        return
            initialPrice.sub(block.timestamp.sub(startTime).mul(priceDrop()));
    }

    function clearingPrice() public view returns (uint256) {
        return Math.max(tokenPrice(), currentPrice());
    }

    function commitEther() external payable nonReentrant {
        require(isActive(), "auction is closed");
        require(paymentToken == address(0), "payment token should be ether");
        require(msg.value >= minimumLimit.mul(clearingPrice()).div(1e18) || minimumLimit == 0, "commitments below the minimum limit");
        uint256 ethToTransfer = calculateCommitment(msg.value);
        require(ethToTransfer > 0, "auction filled");
        uint256 ethToRefund = msg.value.sub(ethToTransfer);
        uint256 fee = ethToTransfer.mul(committerFee).div(1e18);
        _addCommitment(msg.sender, ethToTransfer.sub(fee));
        _transfer(address(0), feeReceiver, fee);
        if (ethToRefund > 0) {
            _transfer(address(0), msg.sender, ethToRefund);
        }
    }

    function commitTokens(uint256 _amount) external nonReentrant {
        require(isActive(), "auction is closed");
        require(paymentToken != address(0), "payment token cannot be ether");
        require(_amount >= minimumLimit.mul(clearingPrice()).div(1e18) 
            || minimumLimit == 0, "commitments below the minimum limit");
        uint256 tokensToTransfer = calculateCommitment(_amount);
        require(tokensToTransfer > 0, "auction filled");
        uint256 fee = tokensToTransfer.mul(committerFee).div(1e18);
        _addCommitment(msg.sender, tokensToTransfer.sub(fee));
        IERC20(paymentToken).safeTransferFrom(
            msg.sender,
            address(this),
            tokensToTransfer
        );
        _transfer(paymentToken, feeReceiver, fee);
    }

    function _addCommitment(address account, uint256 amount) internal {
        commitments[account] = commitments[account].add(amount);
        require(
            maximumLimit.mul(clearingPrice()).div(1e18) >=
                commitments[account] ||
                maximumLimit == 0,
            "commitments over the maximum limit"
        );
        totalCommitments = totalCommitments.add(amount);
        emit AddedCommitment(account, amount, block.timestamp);
    }

    function calculateCommitment(uint256 commitment)
        public
        view
        returns (uint256 committed)
    {
        uint256 maxCommitment = totalAmount.mul(clearingPrice()).div(1e18);
        if (totalCommitments.add(commitment) > maxCommitment)
            return maxCommitment.sub(totalCommitments);
        return commitment;
    }

    function tokensClaimable(address account)
        public
        view
        returns (uint256 claimerCommitment)
    {
        if (commitments[account] == 0) return 0;
        uint256 unclaimedTokens = IERC20(auctionToken).balanceOf(address(this));
        claimerCommitment = commitments[account]
            .mul(totalTokensCommitted())
            .div(totalCommitments);
        claimerCommitment = claimerCommitment.sub(claimed[account]);
        if (claimerCommitment > unclaimedTokens) {
            claimerCommitment = unclaimedTokens;
        }
    }

    function totalTokensCommitted() public view returns (uint256) {
        //Handling oversold
        return
            Math.min(
                totalCommitments.mul(1e18).div(clearingPrice()),
                totalAmount
            );
    }

    function isActive() public view returns (bool) {
        return
            block.timestamp >= startTime &&
            block.timestamp <= endTime &&
            isCollateralsDeposited;
    }

    function successful() public view returns (bool) {
        return
            tokenPrice() >= clearingPrice() ||
            (block.timestamp > endTime &&
                totalCommitments >=
                targetAmount.mul(clearingPrice()).div(1e18));
    }

    function depositTokens() external onlyFunder {
        require(successful(), "auction unsuccessful");
        require(!isTokensDeposited, "vouchers have been deposited");
        require(block.timestamp <= depositExpired, "deposit vouchers expired");
        isTokensDeposited = true;
        uint256 tokensToDeposit = totalTokensCommitted();
        IVoucherToken(auctionToken).mint(address(this), tokensToDeposit);
        emit DepositTokens(
            msg.sender,
            auctionToken,
            tokensToDeposit,
            block.timestamp
        );
    }

    function withdrawPayments() external nonReentrant onlyFunder {
        require(successful(), "auction unsuccessful");
        require(isTokensDeposited, "vouchers have not been deposited");
        require(!isTokensWithdrawn, "payments have been withdrawn");
        isTokensWithdrawn = true;
        uint256 fee = totalCommitments.mul(funderFee).div(1e18);
        _transfer(paymentToken, feeReceiver, fee);
        _transfer(paymentToken, msg.sender, totalCommitments.sub(fee));
        emit WithdrawPayments(
            msg.sender,
            paymentToken,
            totalCommitments,
            block.timestamp
        );
    }

    function withdrawTokens() external nonReentrant {
        if (isTokensDeposited) {
            uint256 tokensToClaim = tokensClaimable(msg.sender);
            require(tokensToClaim > 0, "no tokens to claim");
            claimed[msg.sender] = claimed[msg.sender].add(tokensToClaim);
            _transfer(auctionToken, msg.sender, tokensToClaim);
            emit WithdrawTokens(
                msg.sender,
                auctionToken,
                tokensToClaim,
                block.timestamp
            );
        } else {
            require(
                block.timestamp > depositExpired || !successful(),
                "auction successful and waiting for deposit vouchers"
            );
            uint256 fundsCommitted = commitments[msg.sender];
            commitments[msg.sender] = 0;
            _transfer(paymentToken, msg.sender, fundsCommitted);
            emit WithdrawTokens(
                msg.sender,
                paymentToken,
                fundsCommitted,
                block.timestamp
            );
        }
    }

    function depositCollaterals() external onlyFunder {
        require(block.timestamp < startTime, "deposit collaterals expired");
        require(!isCollateralsDeposited, "collaterals have been deposited");
        isCollateralsDeposited = true;
        IERC20(depositToken).safeTransferFrom(
            msg.sender,
            address(this),
            depositAmount
        );
        emit DepositCollaterals(
            msg.sender,
            depositToken,
            depositAmount,
            block.timestamp
        );
    }

    function withdrawCollaterals() external onlyFunder {
        require(isCollateralsDeposited, "collaterals have not been deposited");
        require(!isCollateralsWithdrawn, "collaterals have been withdrawn");
        isCollateralsWithdrawn = true;
        uint256 collateralsToWithdraw = depositAmount;
        if (successful()) {
            if (!isTokensDeposited) {
                require(block.timestamp > depositExpired, "waiting for deposit vouchers");
                uint256 penaltyAmount = depositAmount.mul(penaltyFee).div(1e18);
                collateralsToWithdraw = depositAmount.sub(penaltyAmount);
                _transfer(depositToken, penaltyReceiver, penaltyAmount);
            }
        } else {
            require(block.timestamp > endTime, "auction is not closed");
        }
        _transfer(depositToken, msg.sender, collateralsToWithdraw);
        emit WithdrawCollaterals(
            msg.sender,
            depositToken,
            collateralsToWithdraw,
            block.timestamp
        );
    }

    function _transfer(
        address token,
        address to,
        uint256 amount
    ) internal {
        if (token == address(0)) {
            (bool success, ) = payable(to).call{value: amount}(new bytes(0));
            require(success, "ETH_TRANSFER_FAILED");
        } else {
            IERC20(token).safeTransfer(to, amount);
        }
    }

    function initialize(
        address _voucherToken,
        address _feeReceiver,
        address _penaltyReceiver,
        uint256 _penaltyFee,
        uint256 _funderFee,
        uint256 _committerFee,
        address _depositToken,
        uint256 _depositAmount,
        bytes calldata _data
    ) external initializer {
        require(_voucherToken != address(0), "voucherToken cannot be address(0)");
        require(_feeReceiver != address(0), "feeReceiver cannot be address(0)");
        require(_penaltyReceiver != address(0), "penaltyReceiver cannot be address(0)");
        require(_penaltyFee <= 1e18, "invalid penalty fee");
        require(_funderFee <= 1e18, "invalid funder fee");
        require(_committerFee <= 1e18, "invalid committer fee");

        auctionToken = _voucherToken;
        feeReceiver = _feeReceiver;
        penaltyReceiver = _penaltyReceiver;
        penaltyFee = _penaltyFee;
        funderFee = _funderFee;
        committerFee = _committerFee;
        depositToken = _depositToken;
        depositAmount = _depositAmount;

        _initAuction(_data);
    }

    receive() external payable {
        revert("receive disabled");
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

    constructor() {
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

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IERC20Extended {
	function decimals() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IVoucherToken {
    function burnFrom(address account, uint256 amount) external;
    function claimable(address account) external view returns(uint256);
    function release(uint256 amount) external;
    function claimed(address account) external view returns(uint256);
    function totalClaimed() external view returns(uint256);
    function totalRelease() external view returns(uint256);
    function totalSupply() external view returns(uint256);
    function totalUnclaimed() external view returns(uint256);
    function mint(address to, uint256 amount) external;
}

// SPDX-License-Identifier: MIT

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
    function transferFrom(
        address sender,
        address recipient,
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

pragma solidity ^0.8.0;

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
        assembly {
            size := extcodesize(account)
        }
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

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
    function transferFrom(
        address sender,
        address recipient,
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