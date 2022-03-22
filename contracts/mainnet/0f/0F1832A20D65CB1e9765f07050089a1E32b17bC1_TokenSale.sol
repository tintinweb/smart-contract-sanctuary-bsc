// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TokenSale {
    using SafeMath for uint256;

    uint256 private PRIVATE_SALE_TIME_TO_WAIT = 28; // 28 days
    uint256 private PRIVATE_SALE_PRICE = 720000000000; // 0,00000072 BNB
    uint256 private PRIVATE_SALE_MIN_QUANTITY = 1000000000000000000;
    uint256 private PRIVATE_SALE_MAX_QUANTITY = 25000000000000000000;
    uint256 private PRIVATE_RELEASE_PERCENTAGE = 25;

    address payable private owner;
    address private tokenAddress;

    mapping(address => uint256) public timeToWait;
    mapping(address => bool) private whiteList;

    uint256 public privateSaleBalance = 100000000000000000000000000;
    uint256 public advisorBalance = 50000000000000000000000000;
    mapping(address => uint256) public balances;
    mapping(address => uint256) private claimableAmount;

    uint256 public contractDate;

    event TokenTransferred(
        uint256 quantity,
        uint256 userBalance,
        uint256 contractBalance,
        bool boolStatus
    );

    event TokenReleased(
        uint256 releaseAmount,
        uint256 userBalance,
        uint256 time_now,
        uint256 time_var
    );

    constructor() {
        owner = payable(msg.sender);
        contractDate = block.timestamp;
    }

    function walletInWhitelist(address _wallet, bool _in) external {
        require(msg.sender == owner, "you are not the owner");
        require(_wallet != address(0));
        whiteList[_wallet] = _in;
    }

    function buyPrivateSaleTokens() external payable {
        require(whiteList[msg.sender] == true, "not in whitelist");
        require(
            msg.value >= PRIVATE_SALE_MIN_QUANTITY &&
                msg.value <= PRIVATE_SALE_MAX_QUANTITY,
            "value too low or too high"
        );

        uint256 tokens = (msg.value).div(PRIVATE_SALE_PRICE);
        tokens = tokens.mul(10**18);

        balances[msg.sender] = balances[msg.sender].add(tokens);
        privateSaleBalance = privateSaleBalance.sub(tokens);

        whiteList[msg.sender] = false;
        timeToWait[msg.sender] =
            contractDate +
            (1 days * PRIVATE_SALE_TIME_TO_WAIT);

        claimableAmount[msg.sender] = balances[msg.sender]
            .mul(PRIVATE_RELEASE_PERCENTAGE)
            .div(100);

        emit TokenTransferred(
            tokens,
            balances[msg.sender],
            privateSaleBalance,
            whiteList[msg.sender]
        );
    }

    function transferTokens(
        uint256 _amount,
        address _user,
        uint256 _timeToWait,
        uint256 _releasePercentage
    ) external {
        require(_amount > 0, "amount is less than 0");
        require(msg.sender == owner, "you are not the owner");
        require(_user != address(0), "user is a 0 wallet address");
        require(_timeToWait > 0, "time to wait is less than 0");
        require(_releasePercentage > 0, "release percentage is less than 0");
        require(
            advisorBalance.sub(_amount) >= 0,
            "amount is greater than tokenBalance"
        );

        advisorBalance = advisorBalance.sub(_amount);
        balances[_user] = balances[_user].add(_amount);
        timeToWait[_user] = contractDate + (1 days * _timeToWait);

        claimableAmount[_user] = balances[_user].mul(_releasePercentage).div(
            100
        );

        emit TokenTransferred(
            _amount,
            balances[_user],
            advisorBalance,
            whiteList[_user]
        );
    }

    function releaseTokens() external {
        require(balances[msg.sender] > 0, "balance is too low");
        require(
            block.timestamp >= timeToWait[msg.sender],
            "it is not time to withdraw"
        );

        uint256 releaseAmount = claimableAmount[msg.sender];
        require(balances[msg.sender].sub(releaseAmount) >= 0);

        balances[msg.sender] = balances[msg.sender].sub(releaseAmount);
        timeToWait[msg.sender] = timeToWait[msg.sender].add(
            (1 days * PRIVATE_SALE_TIME_TO_WAIT)
        );

        IERC20(tokenAddress).transfer(msg.sender, releaseAmount);
        emit TokenReleased(
            releaseAmount,
            balances[msg.sender],
            block.timestamp,
            timeToWait[msg.sender]
        );
    }

    function withdraw() external {
        require(msg.sender == owner);
        owner.transfer(address(this).balance);
    }

    function setTokenAddress(address _tokenAddress) external {
        require(msg.sender == owner);
        tokenAddress = _tokenAddress;
    }

    function updateContractDate() external {
        require(msg.sender == owner);
        contractDate = block.timestamp;
    }

    function setUpHolder(address _holder, uint256 _value) external {
        require(msg.sender == owner, "not the owner");

        uint256 tokens = (_value).div(PRIVATE_SALE_PRICE);
        tokens = tokens.mul(10**18);

        balances[_holder] = balances[_holder].add(tokens);
        privateSaleBalance = privateSaleBalance.sub(tokens);

        timeToWait[_holder] =
            contractDate +
            (1 days * PRIVATE_SALE_TIME_TO_WAIT);

        claimableAmount[_holder] = balances[_holder]
            .mul(PRIVATE_RELEASE_PERCENTAGE)
            .div(100);

        emit TokenTransferred(
            tokens,
            balances[_holder],
            privateSaleBalance,
            whiteList[_holder]
        );
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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