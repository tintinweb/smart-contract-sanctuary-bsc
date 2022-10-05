/**
 *Submitted for verification at BscScan.com on 2022-10-04
*/

/**
 * Submitted for verification on 2022-10-04
*/

// USDT Miner Smart Contract
// SPDX-License-Identifier: GPL-3.0-or-later

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

pragma solidity 0.8.17;

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

contract USDTMiner is Context, Ownable {
    using SafeMath for uint256;

    address usdt = 0x55d398326f99059fF775485246999027B3197955; // BSC Mainnet Tether USD (USDT) 
    address public devAddress;
    uint256 private SHARES_FOR_MINER = 8640000; // Profit 1% per day
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private devFeeVal = 3;
    bool private initialized = false;
    mapping (address => uint256) private compoundMiners;
    mapping (address => uint256) private claimedShares;
    mapping (address => uint256) private lastCompound;
    mapping (address => address) private referrals;
    uint256 private marketShares;
    
    constructor() {
        devAddress=msg.sender;
    }

    function buy(address ref, uint256 amount) public {
        require(initialized);

        ERC20(usdt).transferFrom(address(msg.sender), address(this), amount);
        uint256 balance = ERC20(usdt).balanceOf(address(this));
        uint256 sharesBought=calculateShareBuy(amount,SafeMath.sub(balance,amount));
        sharesBought = SafeMath.sub(sharesBought,devFee(sharesBought));
        uint256 fee = devFee(amount);
        ERC20(usdt).transfer(devAddress, fee);
        claimedShares[msg.sender] = SafeMath.add(claimedShares[msg.sender],sharesBought);
        compound(ref);
    }

    function compound(address ref) public {
        require(initialized);
        
        if(ref == msg.sender) {
            ref = address(0);
        }
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }
        
        uint256 sharesUsed = getMyShares(msg.sender);
        uint256 newMiners = SafeMath.div(sharesUsed,SHARES_FOR_MINER);
        compoundMiners[msg.sender] = SafeMath.add(compoundMiners[msg.sender],newMiners);
        claimedShares[msg.sender] = 0;
        lastCompound[msg.sender] = block.timestamp;
        
        // Send referral shares
        claimedShares[referrals[msg.sender]] = SafeMath.add(claimedShares[referrals[msg.sender]],SafeMath.div(sharesUsed,8));
        
        // Boost market to nerf miners hoarding
        marketShares=SafeMath.add(marketShares,SafeMath.div(sharesUsed,5));
    }
    
    function sell() public {
        require(initialized);
        uint256 hasShares = getMyShares(msg.sender);
        uint256 sharesValue = calculateShareSell(hasShares);
        uint256 fee = devFee(sharesValue);
        claimedShares[msg.sender] = 0;
        lastCompound[msg.sender] = block.timestamp;
        marketShares = SafeMath.add(marketShares,hasShares);
        ERC20(usdt).transfer(devAddress, fee);
        ERC20(usdt).transfer(address(msg.sender), SafeMath.sub(sharesValue,fee));
    }
    
    function shareRewards(address adr) public view returns(uint256) {
        uint256 hasShares = getMyShares(adr);
        uint256 sharesValue = calculateShareSell(hasShares);
        return sharesValue;
    }
    
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    
    function calculateShareSell(uint256 shares) public view returns(uint256) {
        return calculateTrade(shares,marketShares,ERC20(usdt).balanceOf(address(this)));
    }
    
    function calculateShareBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketShares);
    }
    
    function calculateShareBuySimple(uint256 eth) public view returns(uint256){
        return calculateShareBuy(eth,ERC20(usdt).balanceOf(address(this)));
    }
        
    function seedMarket(uint256 amount) public {
        ERC20(usdt).transferFrom(address(msg.sender), address(this), amount);
        require(marketShares==0);
        initialized=true;
        marketShares=108000000000;
    }
    
    function getBalance() public view returns(uint256) {
        return ERC20(usdt).balanceOf(address(this));
    }
    
    function getMyMiners(address adr) public view returns(uint256) {
        return compoundMiners[adr];
    }
    
    function getMyShares(address adr) public view returns(uint256) {
        return SafeMath.add(claimedShares[adr],getSharesSinceLastCompound(adr));
    }
    
    function getSharesSinceLastCompound(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(SHARES_FOR_MINER,SafeMath.sub(block.timestamp,lastCompound[adr]));
        return SafeMath.mul(secondsPassed,compoundMiners[adr]);
    }
    
    function setSharesInPool(uint256 shares) public onlyOwner {
        SHARES_FOR_MINER = shares;
    }

    function setDevFee(uint256 fee) public onlyOwner {
        devFeeVal = fee; 
    }

    function devFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,devFeeVal),100);
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}