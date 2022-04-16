/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

/*
* Contract written by Obsidium Team
* Name  - Obsidium Miner
* Daily Return  - 8%
* APR  - 2,920%
* Obsidium Fee  - 5%
*/

// SPDX-License-Identifier: MIT
library SafeMath {
    /**
     * Obsidium Returns the addition of two unsigned integers, with an overflow flag.
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
     * Obsidium Returns the substraction of two unsigned integers, with an overflow flag.
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
     * Obsidium Returns the multiplication of two unsigned integers, with an overflow flag.
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
     * Obsidium Returns the division of two unsigned integers, with a division by zero flag.
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
     * Obsidium Returns the remainder of dividing two unsigned integers, with a division by zero flag.
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
     * Obsidium Returns the addition of two unsigned integers, reverting on
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
     * Obsidium Returns the subtraction of two unsigned integers, reverting on
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
     * Obsidium Returns the multiplication of two unsigned integers, reverting on
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
     * Obsidium Returns the integer division of two unsigned integers, reverting on
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
     * Obsidium Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
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
     * Obsidium Returns the subtraction of two unsigned integers, reverting with custom message on
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
     * Obsidium Returns the integer division of two unsigned integers, reverting with custom message on
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
     * Obsidium Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
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
 * Obsidium Provides information about the current execution context, including the
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
    * Obsidium Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * Obsidium Returns the address of the current owner.
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

interface ERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract ObsidiumMiner is Context, Ownable {
    using SafeMath for uint256;

    address obs = 0xc6F509274FcC1F485644167CB911fd0C61545E6c;
    address public obsAddress;
    uint256 private CRYSTALS_TO_HATCH_1MINERS = 1080000; //for final version should be seconds in a day
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private obsFeeVal = 5;
    bool private initialized = false;
    mapping (address => uint256) private hatcheryMiners;
    mapping (address => uint256) private claimedCrystals;
    mapping (address => uint256) private lastHatch;
    mapping (address => address) private referrals;
    uint256 private marketCrystals;
    
    constructor() {
        obsAddress=msg.sender;
    }
    
    function hatchCrystals(address ref) public {
        require(initialized);
        
        if(ref == msg.sender) {
            ref = address(0);
        }
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }
        
        uint256 crystalsUsed = getMyCrystals(msg.sender);
        uint256 newMiners = SafeMath.div(crystalsUsed,CRYSTALS_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender] = SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedCrystals[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        
        //send referral crystals
        claimedCrystals[referrals[msg.sender]] = SafeMath.add(claimedCrystals[referrals[msg.sender]],SafeMath.div(crystalsUsed,8));
        
        //boost market to nerf miners hoarding
        marketCrystals=SafeMath.add(marketCrystals,SafeMath.div(crystalsUsed,5));
    }
    
    function sellCrystals() public {
        require(initialized);
        uint256 hasCrystals = getMyCrystals(msg.sender);
        uint256 crystalValue = calculateCrystalSell(hasCrystals);
        uint256 fee = obsFee(crystalValue);
        claimedCrystals[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        marketCrystals = SafeMath.add(marketCrystals,hasCrystals);
        ERC20(obs).transfer(obsAddress, fee);
        ERC20(obs).transfer(address(msg.sender), SafeMath.sub(crystalValue,fee));
    }
    
    function obsidiumRewards(address adr) public view returns(uint256) {
        uint256 hasCrystals = getMyCrystals(adr);
        uint256 crystalValue = calculateCrystalSell(hasCrystals);
        return crystalValue;
    }
    
    function buyCrystals(address ref, uint256 amount) public {
        require(initialized);

        ERC20(obs).transferFrom(address(msg.sender), address(this), amount);
        uint256 balance = ERC20(obs).balanceOf(address(this));
        uint256 crystalsBought=calculateCrystalBuy(amount,SafeMath.sub(balance,amount));
        crystalsBought = SafeMath.sub(crystalsBought,obsFee(crystalsBought));
        uint256 fee = obsFee(amount);
        ERC20(obs).transfer(obsAddress, fee);
        claimedCrystals[msg.sender] = SafeMath.add(claimedCrystals[msg.sender],crystalsBought);
        hatchCrystals(ref);
    }
    
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    
    function calculateCrystalSell(uint256 crystals) public view returns(uint256) {
        return calculateTrade(crystals,marketCrystals,ERC20(obs).balanceOf(address(this)));
    }
    
    function calculateCrystalBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketCrystals);
    }
    
    function calculateCrystalBuySimple(uint256 eth) public view returns(uint256){
        return calculateCrystalBuy(eth,ERC20(obs).balanceOf(address(this)));
    }
    
    function obsFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,obsFeeVal),100);
    }
    
    function seedMarket(uint256 amount) public {
        ERC20(obs).transferFrom(address(msg.sender), address(this), amount);
        require(marketCrystals==0);
        initialized=true;
        marketCrystals=108000000000;
    }
    
    function getBalance() public view returns(uint256) {
        return ERC20(obs).balanceOf(address(this));
    }
    
    function getMyMiners(address adr) public view returns(uint256) {
        return hatcheryMiners[adr];
    }
    
    function getMyCrystals(address adr) public view returns(uint256) {
        return SafeMath.add(claimedCrystals[adr],getCrystalsSinceLastHatch(adr));
    }
    
    function getCrystalsSinceLastHatch(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(CRYSTALS_TO_HATCH_1MINERS,SafeMath.sub(block.timestamp,lastHatch[adr]));
        return SafeMath.mul(secondsPassed,hatcheryMiners[adr]);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}