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

pragma solidity ^0.8.2;
// SPDX-License-Identifier: MIT

import "./interfaces/IERC20.sol";

contract Claimable {

    modifier validAddress(address _to) {
        require(_to != address(0));
        _;
    }
    function _claimValues(address token_, address to_) internal validAddress(to_) {
        if (token_ == address(0)) {
            _claimNativeCoins(to_);
        } else {
            _claimErc20Tokens(token_, to_);
        }
    }

    function _claimNativeCoins(address to_) internal {
        uint256 value = address(this).balance;
        _sendValue(payable(to_), value);
    }

    function _claimErc20Tokens(address token_, address to_) internal {
        IERC20 _ERC20 = IERC20(token_);
        uint256 balance = _ERC20.balanceOf(address(this));
        _ERC20.transfer(to_, balance);
    }

    function _sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success,) = recipient.call{value : amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

pragma solidity ^0.8.2;
// SPDX-License-Identifier: MIT

interface IERC20 {
    function decimals() external view returns (uint8);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);
}

// contracts/TokenTimeLock.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./Claimable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title TokenTimeLock
 */
contract TokenTimeLock is Claimable {
    using SafeMath for uint256;
    address[] private _beneficiaryList;
    uint256 private _start;
    uint256 private _stages;
    uint256 private _interval;
    uint256 private _released;
    address private  _token;
    address private _owner;

    event Released(uint256 amount);

    fallback() external payable {

    }

    receive() external payable {

    }

    constructor(
        address[]memory beneficiaryList_,
        uint256 start_,
        uint256 stages_,
        uint256 interval_,
        address token_
    ){
        require(beneficiaryList_.length > 0, "beneficiaryList is empty");
        _beneficiaryList = beneficiaryList_;
        _start = start_;
        _stages = stages_;
        _interval = interval_;
        _token = token_;
        _owner = msg.sender;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function token() public view virtual returns (address) {
        return _token;
    }

    function start() public view virtual returns (uint256) {
        return _start;
    }

    function stages() public view virtual returns (uint256) {
        return _stages;
    }

    function interval() public view virtual returns (uint256) {
        return _interval;
    }

    function beneficiaryList() public view virtual returns (address[] memory) {
        return _beneficiaryList;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "caller is not the owner");
        _;
    }

    function releasableAmount() public view returns (uint256) {
        uint256 currentBalance = IERC20(_token).balanceOf(address(this));
        if (block.timestamp < _start) {
            return 0;
        } else if (block.timestamp >= _start.add(_stages.mul(_interval))) {
            return currentBalance;
        } else {
            uint256 totalBalance = currentBalance.add(_released);
            uint256 amountTmp = totalBalance
            .mul(block.timestamp.sub(_start).div(_interval))
            .div(_stages);
            return amountTmp.sub(_released);
        }
    }

    function release() public virtual {
        uint256 unreleased = releasableAmount();
        require(unreleased > 0, "TokenTimeLock: no to release");
        _released = _released.add(unreleased);
        uint256 averageAmount = unreleased.div(_beneficiaryList.length);
        uint256 diff = unreleased.sub(averageAmount.mul(_beneficiaryList.length));
        uint256 randomIndex = 0;
        if (diff > 0) {
            randomIndex = _random(_beneficiaryList.length);
        }
        for (uint256 i = 0; i < _beneficiaryList.length; i++) {
            uint256 amount = averageAmount;
            if (diff > 0 && i == randomIndex) {
                amount = amount.add(diff);
            }
            if (amount > 0) {
                IERC20(_token).transfer(_beneficiaryList[i], amount);
            }
        }
        emit Released(unreleased);
    }

    function _random(uint256 count_) public view returns (uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        return random % count_;
    }

    function claimValues(address token_, address to_) public virtual onlyOwner {
        require(token_ != _token, "token is error");
        _claimValues(token_, to_);
    }
}