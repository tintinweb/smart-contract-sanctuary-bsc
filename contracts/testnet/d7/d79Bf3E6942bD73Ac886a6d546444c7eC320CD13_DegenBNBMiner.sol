/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

//SPDX-License-Identifier: UNLICENSED

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

pragma solidity 0.8.9;

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

contract DegenBNBMiner is Context, Ownable {
    using SafeMath for uint256;

    uint256 private COINS_TO_NEW_DEGEN_MINER = 1080000;
    uint256 private OFFSET_TOP = 10000; //Offsets used in trade calculation
    uint256 private OFFSET_BOTTOM = 5000;
    bool private initialized = false;
    mapping (address => uint256) private degenMiners;
    mapping (address => uint256) private claimedCoins;
    mapping (address => uint256) private lastHarvest;
    mapping (address => address) private referrals;
    uint256 private marketCoins = 108000000000;
    
    constructor() {}
	
/*
 *The only functionality of the owner, starts the contract by turning 'initialized' to true. 
 *Ownership is renounced here as well.	
*/
    function startTheDegenMachine() public payable onlyOwner {
        require(initialized == false, "Contract already live for purchasing.");
        initialized = true;
		buyCoins(address(0)); //Seed the contract
		renounceOwnership();
    }
    
//Basis for buying/selling
    function calculateTrade(uint256 rt, uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(OFFSET_TOP,bs),SafeMath.add(OFFSET_BOTTOM,SafeMath.div(SafeMath.add(SafeMath.mul(OFFSET_TOP,rs),SafeMath.mul(OFFSET_BOTTOM,rt)),rt)));
    }	
	
//BUYING
    function buyCoins(address ref) public payable {
        require(initialized);
        uint256 coinsBought = calculateCoinBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));

        claimedCoins[msg.sender] = SafeMath.add(claimedCoins[msg.sender], coinsBought);
        buyDegenMinersWithCoin(ref);
    }
	
    function calculateCoinBuy(uint256 input, uint256 contractBalance) internal view returns(uint256) {
        return calculateTrade(input, contractBalance, marketCoins);
    }

//COMPOUND REWARDS -> MORE DEGEN MINERS
    function buyDegenMinersWithCoin(address ref) public {
        require(initialized);
        
        if(ref == msg.sender) {
            ref = address(0);
        }
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }
        
        uint256 coinsUsed = getMyCoins(msg.sender);
        uint256 newMiners = SafeMath.div(coinsUsed, COINS_TO_NEW_DEGEN_MINER);
        degenMiners[msg.sender] = SafeMath.add(degenMiners[msg.sender],newMiners);
        claimedCoins[msg.sender] = 0;
        lastHarvest[msg.sender] = block.timestamp;
        
        //send referral coins
        claimedCoins[referrals[msg.sender]] = SafeMath.add(claimedCoins[referrals[msg.sender]], SafeMath.div(coinsUsed, 10)); //10% referral coins to upline
        
        //boost market to nerf miners hoarding
        marketCoins=SafeMath.add(marketCoins,SafeMath.div(coinsUsed, 5));
    }
    
//SELLING
    function sellCoins() public {
        require(initialized);
        uint256 hasCoins = getMyCoins(msg.sender);
        uint256 coinValue = calculateCoinSell(hasCoins);
		
        claimedCoins[msg.sender] = 0;
        lastHarvest[msg.sender] = block.timestamp;
        marketCoins = SafeMath.add(marketCoins, hasCoins);
		
		uint256 taxedSellValue = SafeMath.div( SafeMath.mul(coinValue, 9), 10); //10% tax on selling, no taxes on reinvesting with 'buyDegenMinersWithCoin' function.
        payable (msg.sender).transfer(taxedSellValue);
    }
	
    function getMyCoins(address adr) public view returns(uint256) {
        return SafeMath.add(claimedCoins[adr], getCoinsSinceLastHarvest(adr));
    }
		
    function getCoinsSinceLastHarvest(address adr) public view returns(uint256) {
        uint256 secondsPassed = min(COINS_TO_NEW_DEGEN_MINER, SafeMath.sub(block.timestamp, lastHarvest[adr]));
        return SafeMath.mul(secondsPassed, degenMiners[adr]);
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
	
    function calculateCoinSell(uint256 coins) public view returns(uint256) {
        return calculateTrade(coins, marketCoins, address(this).balance);
    }
    
//Simple Getter Functions
    function coinRewards(address adr) public view returns(uint256) {
        uint256 hasCoins = getMyCoins(adr);
        uint256 coinValue = calculateCoinSell(hasCoins);
        return coinValue;
    }
        
    function calculateCoinBuySimple(uint256 input) public view returns(uint256) {
        return calculateCoinBuy(input, address(this).balance);
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function getMyMiners(address adr) public view returns(uint256) {
        return degenMiners[adr];
    }
	
    function buyMinerPreviewAmount(address adr) public view returns(uint256) {
        uint256 coinsUsed = getMyCoins(adr);
        return SafeMath.div(coinsUsed, COINS_TO_NEW_DEGEN_MINER);
    }
		
	function isLive() public view returns(bool){
		return initialized;
	}
	
}