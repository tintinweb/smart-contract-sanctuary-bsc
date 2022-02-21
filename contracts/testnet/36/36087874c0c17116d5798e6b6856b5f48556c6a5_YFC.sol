/**
 *Submitted for verification at BscScan.com on 2022-02-21
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity ^0.7.6;

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
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

pragma solidity ^0.7.6;
pragma abicoder v2;

contract YFC {
    using SafeMath for uint256;

    // uint256 GOLDS_PER_MINERS_PER_SECOND=1;
    uint256 public GOLDS_TO_MINE_1MINERS = 2592000; // for final version should be seconds in a day

    uint256 PSN = 10000;
    uint256 PSNH = 5000;

    uint256 public totalInvestors = 0;


    bool public initialized = false;

    address public ceoAddress;
    address public ceoAddress2;

    mapping (address => uint256) public workingMiners;
    mapping (address => uint256) public claimedGolds;
    mapping (address => uint256) public lastMined;
    mapping (address => address) public referrals;
    mapping (address => bool) public investors;
    mapping (address => uint256) public investmentMap;

    uint256 public marketGolds;
    
    constructor() {
        ceoAddress = msg.sender;
        ceoAddress2 = 0x9230e88907E978a67F652EB6e09FEF43FC778112;
    }

    function mineGolds(address ref) public {
        require(initialized);

        if (ref == msg.sender) {
            ref = address(0);
        }
        if (referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }

        uint256 goldsUsed = getMyGolds();
        uint256 newMiners = goldsUsed.div(GOLDS_TO_MINE_1MINERS);
        workingMiners[msg.sender] = workingMiners[msg.sender].add(newMiners);
        claimedGolds[msg.sender] = 0;
        lastMined[msg.sender] = block.timestamp;
        
        //send referral golds
        claimedGolds[referrals[msg.sender]] = claimedGolds[referrals[msg.sender]].add(goldsUsed.div(10));
        
        //boost market to nerf miners hoarding
        marketGolds = marketGolds.add(goldsUsed.div(5));
    }

    function sellGolds() public {
        require(initialized);
        uint256 hasGolds = getMyGolds();
        uint256 goldValue = calculateGoldSell(hasGolds);

        uint256 fee = devFee(goldValue);
        uint256 fee2 = fee/2;

        claimedGolds[msg.sender] = 0;
        lastMined[msg.sender] = block.timestamp;
        marketGolds = marketGolds.add(hasGolds);

        payable(ceoAddress).transfer(fee2);
        payable(ceoAddress2).transfer(fee - fee2);
        payable(msg.sender).transfer(goldValue.sub(fee));
    }

    function buyGolds(address ref) public payable {
        require(initialized);

        if (investors[msg.sender] == false) {
            investors[msg.sender] = true;
            totalInvestors++;
        }

        investmentMap[msg.sender] = investmentMap[msg.sender].add(msg.value);

        uint256 goldsBought = calculateGoldBuy(msg.value, address(this).balance.sub(msg.value));
        goldsBought = goldsBought.sub(devFee(goldsBought)); // minus 5%

        uint256 fee = devFee(msg.value);
        uint256 fee2 = fee/2;

        payable(ceoAddress).transfer(fee2);
        payable(ceoAddress2).transfer(fee - fee2);

        claimedGolds[msg.sender] = claimedGolds[msg.sender].add(goldsBought);
        mineGolds(ref);
    }

    // magic trade balancing algorithm
    function calculateTrade(uint256 rt, uint256 rs, uint256 bs) public view returns(uint256) {
        // (PSN * bs) / (PSNH + ((PSN * rs + PSNH * rt) / rt));
        return PSN.mul(bs).div(PSNH.add(PSN.mul(rs).add(PSNH.mul(rt)).div(rt)));
    }

    function calculateGoldSell(uint256 golds) public view returns(uint256) {
        return calculateTrade(golds, marketGolds, address(this).balance);
    }

    function calculateGoldBuy(uint256 bnb, uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(bnb, contractBalance, marketGolds);
    }

    function calculateGoldBuySimple(uint256 bnb) public view returns(uint256) {
        return calculateGoldBuy(bnb, address(this).balance);
    }

    function devFee(uint256 amount) public pure returns(uint256) {
        return amount.mul(5).div(100);
    }

    function seedMarket() public {
        require(marketGolds == 0);
        initialized = true;
        marketGolds = 259200000000;
    }

    function withdrawableAmount() public view returns(uint256) {
        uint256 hasGolds = getMyGolds();
        uint256 goldValue = calculateGoldSell(hasGolds);

        uint256 fee = devFee(goldValue);
        return goldValue.sub(fee);
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function getMyMiners() public view returns(uint256) {
        return workingMiners[msg.sender];
    }

    function getMyGolds() public view returns(uint256) {
        return claimedGolds[msg.sender].add(getGoldsSinceLastMined(msg.sender));
    }

    function getGoldsSinceLastMined(address adr) public view returns(uint256) {
        uint256 secondsPassed = min(GOLDS_TO_MINE_1MINERS, block.timestamp.sub(lastMined[adr]));
        return secondsPassed.mul(workingMiners[adr]);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}