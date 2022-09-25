/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/math/SafeMath.sol


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

// File: IndexxToken.sol


pragma solidity ^0.8.4;


contract IndexxToken {
    using SafeMath for uint256;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public owner;

    /* This creates an array with all balances */
    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public freezeOf;
    mapping(address => mapping(address => uint256)) public allowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* This notifies clients about the amount burnt */
    event Burn(address indexed from, uint256 value);

    /* This notifies clients about the amount frozen */
    event Freeze(address indexed from, uint256 value);

    /* This notifies clients about the amount unfrozen */
    event Unfreeze(address indexed from, uint256 value);

    /* This notifies clients about the Received funds */
    event Received(address, uint256);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor(
        uint256 initialSupply,
        string memory tokenName,
        uint8 decimalUnits,
        string memory tokenSymbol
    ) {
        balanceOf[msg.sender] = initialSupply; // Give the creator all initial tokens
        totalSupply = initialSupply; // Update total supply
        name = tokenName; // Set the name for display purposes
        symbol = tokenSymbol; // Set the symbol for display purposes
        decimals = decimalUnits; // Amount of decimals for display purposes
        owner = msg.sender;
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) public {
        require(address(_to) != address(0), "Given _to address is invalid"); // Prevent transfer to 0x0 address. Use burn() instead
        require(_value > 0, "Given _value is invalid");
        require(
            balanceOf[msg.sender] >= _value,
            "No Sufficient balance avaliable"
        ); // Check if the sender has enough
        require(
            balanceOf[_to] + _value > balanceOf[_to],
            "Check for overflows"
        ); // Check for overflows
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value); // Subtract from the sender
        balanceOf[_to] = balanceOf[_to].add(_value); // Add the same to the recipient
        emit Transfer(msg.sender, _to, _value); // Notify anyone listening that this transfer took place
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        require(_value > 0, "Given _value is invalid");
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /* A contract attempts to get the coins */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(address(_to) != address(0), "Given _to address is invalid"); // Prevent transfer to 0x0 address. Use burn() instead
        require(_value > 0, "Given _value is invalid");
        require(
            balanceOf[msg.sender] >= _value,
            "No Sufficient balance avaliable"
        ); // Check if the sender has enough
        require(
            balanceOf[_to] + _value > balanceOf[_to],
            "Check for overflows"
        ); // Check for overflows
        require(_value <= allowance[_from][msg.sender], "Check for allowance"); // Check allowance
        balanceOf[_from] = balanceOf[_from].sub(_value); // Subtract from the sender
        balanceOf[_to] = balanceOf[_to].add(_value); // Add the same to the recipient
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function burn(uint256 _value) public returns (bool success) {
        require(_value > 0, "Given _value is invalid");
        require(
            balanceOf[msg.sender] >= _value,
            "No Sufficient balance avaliable"
        ); // Check if the sender has enough
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value); // Subtract from the sender
        totalSupply = totalSupply.sub(_value); // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }

    function freeze(uint256 _value) public returns (bool success) {
        require(_value > 0, "Given _value is invalid");
        require(
            balanceOf[msg.sender] >= _value,
            "No Sufficient balance avaliable"
        ); // Check if the sender has enough
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value); // Subtract from the sender
        freezeOf[msg.sender] = freezeOf[msg.sender].add(_value); // Updates totalSupply
        emit Freeze(msg.sender, _value);
        return true;
    }

    function unfreeze(uint256 _value) public returns (bool success) {
        require(_value > 0, "Given _value is invalid");
        require(
            balanceOf[msg.sender] < _value,
            "No Sufficient balance avaliable"
        );
        freezeOf[msg.sender] = freezeOf[msg.sender].sub(_value); // Subtract from the sender
        balanceOf[msg.sender] = balanceOf[msg.sender].add(_value);
        emit Unfreeze(msg.sender, _value);
        return true;
    }

    // transfer balance to owner
    function withdrawEther(uint256 amount) public {
        require(msg.sender == owner, "Only owner allowed");
        payable(owner).transfer(amount);
    }

    function deposit() payable public {
        emit Received(msg.sender, msg.value);
    }
}