// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./parts/Withdrawable.sol";

contract Royalty is Withdrawable {
    using SafeMath for uint256;

    address private _contractOwner;
    IERC20 private _wbnbCoin;

    bool public secondStageActive = false;

    uint256 private _transitFee = 80;
    uint256 private _teamFee = 10;
    uint256 private _marketingFee = 10;
    uint256 private _devFee = 10;
    uint256 private _treasureFee = 20;

    constructor(IERC20 _wbnbAddress) {
        _contractOwner = msg.sender;
        _wbnbCoin = _wbnbAddress;
    }

    modifier onlyOwner() {
        require(msg.sender == _contractOwner, "Not allowed for this action");
        _;
    }

    function activateSecondStage() public {
        _transitFee = 50;
        _marketingFee = 15;
        _teamFee = 15;
        secondStageActive = true;
    }

    function _withdraw(address _address, uint256 _amount) private {
        if (_amount > 0) {
            (bool success,) = _address.call{value : _amount}("");
            require(success, "Withdraw failed");
        }
    }

    function _withdrawWbnb(address _address, uint256 _amount) private {
        if (_amount > 0) {
            _wbnbCoin.transfer(_address, _amount);
        }
    }

    function teamFee() public view returns (uint256) {
        return _teamFee;
    }

    function setTeamFee(uint256 fee_) public onlyOwner {
        require(fee_ <= 100 && fee_ >= 0, "Not valid fee value.");
        _teamFee = fee_;
    }

    function setMarketingFee(uint256 fee_) public onlyOwner {
        require(fee_ <= 100 && fee_ >= 0, "Not valid fee value.");
        _marketingFee = fee_;
    }

    function setDevFee(uint256 fee_) public onlyOwner {
        require(fee_ <= 100 && fee_ >= 0, "Not valid fee value.");
        _devFee = fee_;
    }

    function marketingFee() public view returns (uint256) {
        return _marketingFee;
    }

    function devFee() public view returns (uint256) {
        return _devFee;
    }

    function withdrawWBNB() public {
        uint256 balance = _wbnbCoin.balanceOf(address(this));
        require(balance > 0);

        uint256 percent = balance.div(100);

        uint256 teamTotal = percent.mul(_teamFee);
        uint256 devFeeValue = teamTotal.div(100).mul(_devFee);
        uint256 teamFeeValue = teamTotal.sub(devFeeValue);

        _withdrawWbnb(teamAddress, teamFeeValue);
        _withdrawWbnb(devAddress, devFeeValue);
        _withdrawWbnb(marketingAddress, percent.mul(_marketingFee));
        if (secondStageActive) {
            _withdrawWbnb(treasureAddress, percent.mul(_treasureFee));
        }
        _withdrawWbnb(transitAddress, address(this).balance);
    }

    receive() external payable {
        uint256 balance = msg.value;

        if (balance > 0) {
            uint256 percent = balance.div(100);
            uint256 teamTotal = percent.mul(_teamFee);
            uint256 devFeeValue = teamTotal.div(100).mul(_devFee);
            uint256 teamFeeValue = teamTotal.sub(devFeeValue);

            _withdraw(teamAddress, teamFeeValue);
            _withdraw(devAddress, devFeeValue);
            _withdraw(marketingAddress, percent.mul(_marketingFee));
            if (secondStageActive) {
                _withdraw(treasureAddress, percent.mul(_treasureFee));
            }
            _withdraw(transitAddress, address(this).balance);
        }
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

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Distributable.sol";

contract Withdrawable is Distributable {

    address internal constant withdrawWalletAddress = 0x69e07DbffFDDF108da0B24b0351a11f383a11E9b;

    function withdrawCoins(IERC20 coinAddress) public onlyAllowed {
        IERC20 coin = coinAddress;
        uint256 balance = coin.balanceOf(address(this));

        if (balance > 0) {
            coin.transfer(withdrawWalletAddress, balance);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

contract Distributable {

    address public constant teamAddress = 0x02DCe9c40968F6CB627Bd295e13a5c994e8a4a48;
    address public constant devAddress = 0xb386aBd1795A2D70F186989ef4C39d0d4E9BD658;
    address public constant marketingAddress = 0x0E5158FC2E69b691fbcFdbBa81064FEFF0C7F850;
    address public constant transitAddress = 0x2386D4318DA517b93D2E5cf902121F44162Fd48F;
    address public constant treasureAddress = 0xf9EC2F8733C828FC490A105Ea2B1767D804e6588;

    modifier onlyAllowed() {
        require(allowedForWithdraw(msg.sender), "Not allowed for withdraw");
        _;
    }

    function allowedForWithdraw(address operator) public pure virtual returns (bool) {
        return operator == teamAddress ||
        operator == devAddress ||
        operator == transitAddress ||
        operator == marketingAddress;
    }
}