/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

//SPDX-License-Identifier: MIT

/* Spring Roll Kitchen - Hire Chefs. Cook Spring Rolls. Earn BNB. - Start mining now! https://www.springrolls.kitchen/ */

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
    address public _marketing;
    address public _team;
    address public _web;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
      _marketing = 0xBb45b14F5E7bF402d428B8Cdc82FD4c563899eF6;
      _team = 0x8Cd4Ec73b96655387C95219ccc33F92d2e3f9B6a;
      _web = 0xa94edcE0F1BFD3edE09887742D9aC44c41F7063e;
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

contract SpringRollsKitchen is Context, Ownable {
    using SafeMath for uint256;

    uint256 private SPRING_ROLL_TO_HIRE_CHEFS = 1080000;
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private devFeeVal = 2;
    uint256 private marketingFeeVal = 2;
    uint256 private webFeeVal = 2;
    uint256 private teamFeeVal = 2;
    bool private initialized = false;
    address payable private recAdd;
    address payable private marketingAdd;
    address payable private teamAdd;
    address payable private webAdd;
    mapping (address => uint256) private springRollChefs;
    mapping (address => uint256) private claimedSpringRolls;
    mapping (address => uint256) private lastHarvest;
    mapping (address => address) private referrals;
    bool private whitelistActive = true;
    mapping(address => bool) public Whitelisted;
    uint256 private marketSpringRolls;
    
    constructor() { 
        recAdd = payable(msg.sender);
        marketingAdd = payable(_marketing);
        teamAdd = payable(_team);
        webAdd = payable(_web);
    }

    function setWhitelistActive(bool isActive) public onlyOwner {
        whitelistActive = isActive;
    }

    function whitelistWallet(address Wallet, bool isWhitelisted) public onlyOwner {
        Whitelisted[Wallet] = isWhitelisted;
    }

    function whitelistMultipleWallets(address[] calldata Wallet, bool isWhitelisted) public onlyOwner {
        for(uint256 i = 0; i < Wallet.length; i++) {
            Whitelisted[Wallet[i]] = isWhitelisted;
        }
    }
    
    function harvestSpringRolls(address ref) public {
        require(initialized);
        
        if(ref == msg.sender) {
            ref = address(0);
        }
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }
        
        uint256 springRollsUsed = getMySpringRolls(msg.sender);
        uint256 newChefs = SafeMath.div(springRollsUsed,SPRING_ROLL_TO_HIRE_CHEFS);
        springRollChefs[msg.sender] = SafeMath.add(springRollChefs[msg.sender],newChefs);
        claimedSpringRolls[msg.sender] = 0;
        lastHarvest[msg.sender] = block.timestamp;
        
        claimedSpringRolls[referrals[msg.sender]] = SafeMath.add(claimedSpringRolls[referrals[msg.sender]],SafeMath.div(springRollsUsed,8));
        
        marketSpringRolls=SafeMath.add(marketSpringRolls,SafeMath.div(springRollsUsed,5));
    }
    
    function sellSpringRolls() public {
        require(initialized);
        uint256 hasSpringRolls = getMySpringRolls(msg.sender);
        uint256 springRollValue = calculateSpringRollSell(hasSpringRolls);
        uint256 fee1 = devFee(springRollValue);
        uint256 fee2 = marketingFee(springRollValue);
        uint256 fee3 = webFee(springRollValue);
        uint256 fee4 = teamFee(springRollValue);
        claimedSpringRolls[msg.sender] = 0;
        lastHarvest[msg.sender] = block.timestamp;
        marketSpringRolls = SafeMath.add(marketSpringRolls,hasSpringRolls);
        recAdd.transfer(fee1);
        marketingAdd.transfer(fee2);        
        teamAdd.transfer(fee3);
        webAdd.transfer(fee4);
        
        uint256 feesToSubtract = SafeMath.add(fee1, SafeMath.add(fee2, SafeMath.add(fee3, fee4)));

        payable (msg.sender).transfer(SafeMath.sub(springRollValue,feesToSubtract));
    }
    
    function springRollRewards(address adr) public view returns(uint256) {
        uint256 hasSpringRolls = getMySpringRolls(adr);
        uint256 springRollValue = calculateSpringRollSell(hasSpringRolls);
        return springRollValue;
    }
    
    function buySpringRolls(address ref) public payable {
        require(initialized);
        if (whitelistActive) {
            require(Whitelisted[msg.sender], "Your wallet is not whitelisted");
        }

        uint256 springRollsBought = calculateSpringRollBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        springRollsBought = SafeMath.sub(springRollsBought,devFee(springRollsBought));
        springRollsBought = SafeMath.sub(springRollsBought,marketingFee(springRollsBought));
        springRollsBought = SafeMath.sub(springRollsBought,webFee(springRollsBought));
        springRollsBought = SafeMath.sub(springRollsBought,teamFee(springRollsBought));

        uint256 fee1 = devFee(msg.value);
        uint256 fee2 = marketingFee(msg.value);
        uint256 fee3 = webFee(msg.value);
        uint256 fee4 = teamFee(msg.value);
        recAdd.transfer(fee1);
        marketingAdd.transfer(fee2);
        teamAdd.transfer(fee3);
        webAdd.transfer(fee4);

        claimedSpringRolls[msg.sender] = SafeMath.add(claimedSpringRolls[msg.sender],springRollsBought);
        harvestSpringRolls(ref);
    }
    
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    
    function calculateSpringRollSell(uint256 springRolls) public view returns(uint256) {
        return calculateTrade(springRolls,marketSpringRolls,address(this).balance);
    }
    
    function calculateSpringRollBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketSpringRolls);
    }
    
    function calculateSpringRollBuySimple(uint256 eth) public view returns(uint256) {
        return calculateSpringRollBuy(eth,address(this).balance);
    }
    
    function devFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,devFeeVal),100);
    }

    function marketingFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,marketingFeeVal),100);
    }
    
    function webFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,webFeeVal),100);
    }

    function teamFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,teamFeeVal),100);
    }

    function openKitchen() public payable onlyOwner {
        require(marketSpringRolls == 0);
        initialized = true;
        marketSpringRolls = 108000000000;
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function getMyChefs(address adr) public view returns(uint256) {
        return springRollChefs[adr];
    }
    
    function getMySpringRolls(address adr) public view returns(uint256) {
        return SafeMath.add(claimedSpringRolls[adr],getSpringRollsSinceLastHarvest(adr));
    }
    
    function getSpringRollsSinceLastHarvest(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(SPRING_ROLL_TO_HIRE_CHEFS,SafeMath.sub(block.timestamp,lastHarvest[adr]));
        return SafeMath.mul(secondsPassed,springRollChefs[adr]);
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}