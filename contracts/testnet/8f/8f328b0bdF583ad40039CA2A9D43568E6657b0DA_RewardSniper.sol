// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract RewardSniper {
    using SafeMath for uint256;

    struct User {
        address adr;
        uint256 totalDeposit;
        uint256 depositedAt;
        uint256 claimedAt;
        uint256 compoundedAt;
        uint256 lastRolledRewards;
        uint256 lastRolledNr;
        uint256 rollAttempts;
    }

    mapping(address => User) public users;
    bool public initialized;

    event Deposited(address indexed user, uint256 amount);
    event Claimed(address indexed user, uint256 amount);
    event Compounded(address indexed user, uint256 amount);
    event RolledRewards(address indexed user, uint256 attempts, uint256 rewards);

    function deposit() public payable {
        require(msg.value > 0, "Value should be greater than 0");
        User storage user = users[tx.origin];
        user.adr = tx.origin;

        user.totalDeposit = user.totalDeposit.add(msg.value);
        user.depositedAt = block.timestamp;

        emit Deposited(tx.origin, msg.value);
    }

    function rollRewards() public payable returns (uint256 attemps, uint256 rewards) {
        User storage user = users[tx.origin];
        require(user.totalDeposit > 0, "No deposit found for user");
        require(user.rollAttempts < 3, "You can only roll 3 times in a row");

        if (user.rollAttempts > 0) {
            uint256 serviceFee = availableRewards(tx.origin).mul(2000000000).div(1000000000000); ///@dev 0.2% of pending rewards
            require(msg.value >= serviceFee, "You must add BNB worth of 0.2% of your rewards");
        }

        user.lastRolledNr = generateRandomNumber(200);
        if (user.lastRolledNr < 50) {
            user.lastRolledNr = 50;
        }
        user.lastRolledRewards = availableRewards(tx.origin).mul(user.lastRolledNr).mul(10000000000).div(1000000000000);
        user.rollAttempts++;

        emit RolledRewards(tx.origin, user.rollAttempts, user.lastRolledRewards);
        return (user.rollAttempts, user.lastRolledRewards);
    }

    function claim() public {
        User storage user = users[tx.origin];
        require(user.totalDeposit > 0, "No deposit found for user");
        require(user.lastRolledNr > 0, "You must have rolled at least once");

        user.totalDeposit = user.totalDeposit.sub(user.lastRolledRewards);
        user.claimedAt = block.timestamp;
        
        if (user.lastRolledNr < 100 && user.lastRolledNr > 0) {
            uint256 toTeam = teamFee(user.adr);
            if (toTeam > 0) {
                payable(0xbab5B268bBa1E1ED488e5C91b6df3966bC8d8EeE).transfer(toTeam);
            }
        }

        user.rollAttempts = 0;
        uint256 rewardsToCollect = user.lastRolledRewards;
        user.lastRolledRewards = 0;
        user.lastRolledNr = 0;

        payable(tx.origin).transfer(rewardsToCollect);

        emit Claimed(tx.origin, rewardsToCollect);
    }

    function compound() public {
        User storage user = users[tx.origin];
        require(user.totalDeposit > 0, "No deposit found for user");
        require(user.lastRolledNr > 0, "You must have rolled at least once");

        user.totalDeposit = user.totalDeposit.add(user.lastRolledRewards);
        user.compoundedAt = block.timestamp;
        
        if (user.lastRolledNr < 100 && user.lastRolledNr > 0) {
            uint256 toTeam = teamFee(user.adr);
            if (toTeam > 0) {
                payable(0xbab5B268bBa1E1ED488e5C91b6df3966bC8d8EeE).transfer(toTeam);
            }
        }

        user.rollAttempts = 0;
        uint256 rewardsToCollect = user.lastRolledRewards;
        user.lastRolledRewards = 0;
        user.lastRolledNr = 0;

        emit Compounded(tx.origin, rewardsToCollect);
    }

    function teamFee(address adr) private view returns (uint256) {
        if (users[adr].lastRolledNr < 100 && users[adr].lastRolledNr > 0) {
            uint256 rewardsIf100Percent = ((10000000000000000 / users[adr].lastRolledNr).mul(users[adr].lastRolledRewards)).div(100000000000000);
            uint256 remaining = rewardsIf100Percent.sub(users[adr].lastRolledRewards);
            uint256 toTeam = remaining.mul(20).div(100); ///@dev 20% of lost rewards goes to team
            return toTeam;
        }
        return 0;
    }

    function availableRewards(address adr) public view returns(uint256) {
        if (users[adr].rollAttempts > 0) {
            return users[adr].lastRolledRewards;
        }
        uint256 timeElapsed = block.timestamp.sub(
            users[adr].depositedAt > users[adr].claimedAt ? users[adr].depositedAt : users[adr].claimedAt
        );
        uint256 daysElapsed = timeElapsed / 86400;

        uint256 earned = users[adr].totalDeposit.mul(daysElapsed).mul(10000000000000000).div(1000000000000000000); ///@dev 1% per day
        return earned;
    }

    function generateRandomNumber(uint256 arrayLength)
        private
        view
        returns (uint256)
    {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp +
                        block.difficulty +
                        ((
                            uint256(keccak256(abi.encodePacked(block.coinbase)))
                        ) / (block.timestamp)) +
                        block.gaslimit +
                        ((uint256(keccak256(abi.encodePacked(tx.origin)))) /
                            (block.timestamp)) +
                        block.number
                )
            )
        );

        return (seed - ((seed / arrayLength) * arrayLength));
    }
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