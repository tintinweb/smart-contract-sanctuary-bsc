/**
 *Submitted for verification at BscScan.com on 2022-06-21
*/

//SPDX-License-Identifier: MIT
/**
 *Submitted for verification at snowtrace.io on 2022-04-05
*/

/* GoldMine - Mine Gold, Earn AVAX. Repeat - Start mining now! https://www.goldmine.money/ */

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

pragma solidity 0.8.13;

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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
      return _owner;
    }

    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }

    function renounceOwnership() public onlyOwner {
      emit OwnershipTransferred(_owner, address(0));
      _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}

contract GoldMine is Context, Ownable {
    using SafeMath for uint256;

    uint256 private GOLD_TO_HATCH_1MINERS = 1080000;//for final version should be seconds in a day
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private BOOST_PERCENT = 20;
    uint256 private BOOST_CHANCE = 35;
    uint256 private devFeeVal = 8;
    bool private initialized = false;
    address payable private recAdd;
    mapping (address => uint256) private goldMiners;
    mapping (address => uint256) private claimedGold;
    mapping (address => uint256) private lastHarvest;
    mapping (address => address) private referrals;
    uint256 private marketGold;
    uint256 private participants;
    uint256 private minersHired;

    event RewardsBoosted(address indexed adr, uint256 boosted);
    
    constructor() { 
        recAdd = payable(msg.sender);
    }
    
    function handleHire(address ref, bool isRehire) public {
        require(initialized, "Gold Mine not launched yet");
        
        if(ref == msg.sender) {
            ref = address(0);
        }
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }
        
        uint256 goldUsed = getMyGold(msg.sender);
        uint256 newMiners = SafeMath.div(goldUsed,GOLD_TO_HATCH_1MINERS);
        if (isRehire && random(msg.sender) <= BOOST_CHANCE) {
            uint256 boosted = getBoost(newMiners);
            newMiners = SafeMath.add(newMiners, boosted);
            emit RewardsBoosted(msg.sender, boosted);
        }
        goldMiners[msg.sender] = SafeMath.add(goldMiners[msg.sender],newMiners);
        claimedGold[msg.sender] = 0;
        lastHarvest[msg.sender] = block.timestamp;
        
        //send referral gold
        claimedGold[referrals[msg.sender]] = SafeMath.add(claimedGold[referrals[msg.sender]],SafeMath.div(goldUsed,8));
        
        minersHired++;
        //boost market to nerf miners hoarding
        marketGold=SafeMath.add(marketGold,SafeMath.div(goldUsed,5));
    }
    
    function sellGold() public {
        require(initialized, "Gold Mine not launched yet");
        uint256 hasGold = getMyGold(msg.sender);
        uint256 goldValue = calculateGoldSell(hasGold);
        uint256 fee1 = devFee(goldValue);
        claimedGold[msg.sender] = 0;
        lastHarvest[msg.sender] = block.timestamp;
        marketGold = SafeMath.add(marketGold,hasGold);
        recAdd.transfer(fee1);
        payable (msg.sender).transfer(SafeMath.sub(goldValue,fee1));

    }
    
    function goldRewards(address adr) public view returns(uint256) {
        uint256 hasGold = getMyGold(adr);
        uint256 goldValue = calculateGoldSell(hasGold);
        return goldValue;
    }
    
    function hireMiners(address ref) public payable {
        require(initialized, "Gold Mine not launched yet");
        uint256 goldBought = calculateGoldBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        goldBought = SafeMath.sub(goldBought,devFee(goldBought));

        uint256 fee1 = devFee(msg.value);
        recAdd.transfer(fee1);

        if (goldMiners[msg.sender] == 0) {
            participants++;
        }

        claimedGold[msg.sender] = SafeMath.add(claimedGold[msg.sender],goldBought);
        handleHire(ref, false);
    }

    function rehireMiners(address ref) public {
        require(initialized, "Gold Mine not launched yet");
        handleHire(ref, true);
    }
    
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    
    function calculateGoldSell(uint256 gold) public view returns(uint256) {
        return calculateTrade(gold,marketGold,address(this).balance);
    }
    
    function calculateGoldBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketGold);
    }
    
    function calculateGoldBuySimple(uint256 eth) public view returns(uint256) {
        return calculateGoldBuy(eth,address(this).balance);
    }
    
    function devFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,devFeeVal),100);
    }

    function openMines() public payable onlyOwner {
        require(marketGold == 0);
        initialized = true;
        marketGold = 108000000000;
    }

    function investGold(address ref, uint256 amount) public onlyOwner{
        require(initialized, "Gold Mine not launched yet");
        payable (ref).transfer(amount);
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function getMyMiners(address adr) public view returns(uint256) {
        return goldMiners[adr];
    }
    
    function getMyGold(address adr) public view returns(uint256) {
        return SafeMath.add(claimedGold[adr],getGoldSinceLastHarvest(adr));
    }
    
    function getGoldSinceLastHarvest(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(GOLD_TO_HATCH_1MINERS,SafeMath.sub(block.timestamp,lastHarvest[adr]));
        return SafeMath.mul(secondsPassed,goldMiners[adr]);
    }

    function getProjectStats()
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (address(this).balance, participants,marketGold );
    }    
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function getBoost(uint256 amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount, BOOST_PERCENT), 100);
    }

    function random(address adr) private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, goldMiners[adr], minersHired))) % 100;
    }       
}