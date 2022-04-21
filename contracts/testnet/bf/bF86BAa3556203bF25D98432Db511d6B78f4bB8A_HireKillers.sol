/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
interface ERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  event Transfer(address indexed from,address indexed to,uint256 value);
  event Approval(address indexed owner,address indexed spender,uint256 value);
}

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

contract HireKillers is Context, Ownable {
    using SafeMath for uint256;

    address busd = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; //testnet
    //address busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //mainnet

    uint256 private KILLERS_TO_HIRE_1MINERS = 1;//for testnet version
    //uint256 private KILLERS_TO_HIRE_1MINERS = 1080000;//for final version should be seconds in a day

    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 devFeeNumerator = 30;
    uint256 devFeeDenominator = 1000;
    bool private initialized = false;
    address private recAdd;
    mapping (address => uint256) private hireMiners;
    mapping (address => uint256) private claimedKillers;
    mapping (address => uint256) private lastHire;
    mapping (address => address) private referrals;
    uint256 private marketKillers;
    
    constructor() {
        recAdd = msg.sender;
    }
    
    function hireMoreKillers(address ref) public {
        require(initialized);
        
        if(ref == msg.sender) {
            ref = address(0);
        }
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }
        
        uint256 killersUsed = getMyKillers(msg.sender);
        uint256 newMiners = SafeMath.div(killersUsed,KILLERS_TO_HIRE_1MINERS);
        hireMiners[msg.sender] = SafeMath.add(hireMiners[msg.sender],newMiners);
        claimedKillers[msg.sender] = 0;
        lastHire[msg.sender] = block.timestamp;
        
        //send referral killers
        claimedKillers[referrals[msg.sender]] = SafeMath.add(claimedKillers[referrals[msg.sender]],SafeMath.div(killersUsed,8));
        
        //boost market to nerf miners hoarding
        marketKillers=SafeMath.add(marketKillers,SafeMath.div(killersUsed,5));
    }
    
    function sellKillers() public {
        require(initialized);
        uint256 hasKillers = getMyKillers(msg.sender);
        uint256 killValue = calculateKillerSell(hasKillers);
        uint256 fee = devFee(killValue);
        claimedKillers[msg.sender] = 0;
        lastHire[msg.sender] = block.timestamp;
        marketKillers = SafeMath.add(marketKillers,hasKillers);
        
        ERC20(busd).transfer(recAdd, fee);
        ERC20(busd).transfer(msg.sender,SafeMath.sub(killValue,fee));
    }
    
    function killersRewards(address adr) public view returns(uint256) {
        uint256 hasKillers = getMyKillers(adr);
        uint256 killerValue = calculateKillerSell(hasKillers);
        return killerValue;
    }
    
    function buyKillers(address ref, uint256 amount) public {
        require(initialized);
        
        ERC20(busd).transferFrom(address(msg.sender), address(this), amount); //transfer the BUSD amount from user to contract
        uint256 balance = ERC20(busd).balanceOf(address(this));

		uint256 killersBought = calculateKillerBuy(amount,SafeMath.sub(balance,amount));
        killersBought = SafeMath.sub(killersBought,devFee(killersBought));

        uint256 fee = devFee(amount);
        ERC20(busd).transfer(recAdd, fee); //transfer the dev fee to wallet recAdd when initializing  
              
        claimedKillers[msg.sender] = SafeMath.add(claimedKillers[msg.sender],killersBought);
        hireMoreKillers(ref);
    }
    
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    
    function calculateKillerSell(uint256 killers) public view returns(uint256) {
        return calculateTrade(killers,marketKillers,ERC20(busd).balanceOf(address(this)));
    }
    
    function calculateKillerBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketKillers);
    }
    
    function calculateKillerBuySimple(uint256 eth) public view returns(uint256) {
        return calculateKillerBuy(eth,ERC20(busd).balanceOf(address(this)));
    }
    
    function devFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,devFeeNumerator),devFeeDenominator);
    }
    
    function seedMarket(uint256 amount) public onlyOwner {
        ERC20(busd).transferFrom(address(msg.sender), address(this), amount);
        require(marketKillers == 0);
        initialized = true;
        marketKillers = 108000000000;
    }
    
    function getBalance() public view returns(uint256) {
        return ERC20(busd).balanceOf(address(this));
    }
    
    function getMyHired(address adr) public view returns(uint256) {
        return hireMiners[adr];
    }
    
    function getMyKillers(address adr) public view returns(uint256) {
        return SafeMath.add(claimedKillers[adr],getKillersSinceLastHire(adr));
    }
    
    function getKillersSinceLastHire(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(KILLERS_TO_HIRE_1MINERS,SafeMath.sub(block.timestamp,lastHire[adr]));
        return SafeMath.mul(secondsPassed,hireMiners[adr]);
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}