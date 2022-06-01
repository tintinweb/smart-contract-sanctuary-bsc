/**
 *Submitted for verification at BscScan.com on 2022-06-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

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

contract DoughnutFinance {
    using SafeMath for uint256;

    //uint256 DOUGHNUTS_PER_MINERS_PER_SECOND = 1;
    uint256 public DOUGHNUTS_TO_HATCH_1MINERS = 864000; //for final version should be seconds in a day
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    
    bool public initialized = false;
    address public ceoAddress;

    mapping (address => uint256) public hatcheryMiners;
    mapping (address => uint256) public claimedDoughnuts;
    mapping (address => uint256) public lastHatch;
    mapping (address => address) public referrals;

    uint256 public marketDoughnuts;

    modifier onlyCEO() {
        require(ceoAddress == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyInitialized() {
        require(initialized, "Not initialized");
        _;
    }

    constructor() {
        ceoAddress = msg.sender;
    }

    function openKitchen() public payable onlyCEO {
        require(marketDoughnuts == 0);
        initialized = true;
        marketDoughnuts = 86400000000;
    }
    
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    function getMyMiners() public view returns(uint256){
        return hatcheryMiners[msg.sender];
    }

    function getMyDoughnuts() public view returns(uint256){
        return claimedDoughnuts[msg.sender].add(getDoughnutsSinceLastHatch(msg.sender));
    }

    function getDoughnutsSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsPassed = min(DOUGHNUTS_TO_HATCH_1MINERS, block.timestamp.sub(lastHatch[adr]));
        return secondsPassed.mul(hatcheryMiners[adr]);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function devFee(uint256 amount) public pure returns(uint256){
        return amount.mul(5).div(100); // 5%
    }

    //magic trade balancing algorithm
    function calculateTrade(uint256 rt, uint256 rs, uint256 bs) public view returns(uint256) {
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateDoughnutSell(uint256 doughnuts) public view returns(uint256) {
        return calculateTrade(doughnuts, marketDoughnuts, address(this).balance);
    }
    function calculateDoughnutBuy(uint256 eth, uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth, contractBalance, marketDoughnuts);
    }
    function calculateDoughnutBuySimple(uint256 eth) public view returns(uint256){
        return calculateDoughnutBuy(eth, address(this).balance);
    }

    function rebakeDoughnut(address ref) public onlyInitialized {
        if(ref == msg.sender || ref == address(0) || hatcheryMiners[ref] == 0) {
            ref = ceoAddress;
        }

        if(referrals[msg.sender] == address(0)) {
            referrals[msg.sender] = ref;
        }

        uint256 doughnutsUsed=getMyDoughnuts();
        uint256 newMiners=SafeMath.div(doughnutsUsed,DOUGHNUTS_TO_HATCH_1MINERS);

        hatcheryMiners[msg.sender]=SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedDoughnuts[msg.sender]=0;
        lastHatch[msg.sender]=block.timestamp;

        //send referral doughnuts
        claimedDoughnuts[referrals[msg.sender]]=SafeMath.add(claimedDoughnuts[referrals[msg.sender]],SafeMath.div(SafeMath.mul(doughnutsUsed,15),100));

        //boost market to nerf miners hoarding
        marketDoughnuts=SafeMath.add(marketDoughnuts,SafeMath.div(doughnutsUsed,5));
    }

    function eatDoughnut() public onlyInitialized {
        uint256 hasDoughnuts=getMyDoughnuts();
        uint256 doughnutValue=calculateDoughnutSell(hasDoughnuts);
        uint256 fee=devFee(doughnutValue);
        claimedDoughnuts[msg.sender]=0;
        lastHatch[msg.sender]=block.timestamp;
        marketDoughnuts=SafeMath.add(marketDoughnuts,hasDoughnuts);
        (bool success, ) = payable(ceoAddress).call{
            value: fee
        }("");
        require(success, "Failed to send fee");
        (success, ) = payable(msg.sender).call{
            value: SafeMath.sub(doughnutValue,fee)
        }("");
        require(success, "Failed to send value");
    }

    function bakeDoughnut(address ref) public payable onlyInitialized {
        uint256 doughnutsBought=calculateDoughnutBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        doughnutsBought=SafeMath.sub(doughnutsBought,devFee(doughnutsBought));
        uint256 fee=devFee(msg.value);
        (bool success, ) = payable(ceoAddress).call{
            value: fee
        }("");
        require(success, "Failed to send fee");
        claimedDoughnuts[msg.sender]=SafeMath.add(claimedDoughnuts[msg.sender],doughnutsBought);
        rebakeDoughnut(ref);
    }
}