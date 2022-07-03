/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// SPDX-License-Identifier: MIT

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

contract DirtySockMachine is Context, Ownable {
    event SetTimer(uint256 indexed timer);

    using SafeMath for uint256;

    uint256 private SOCKS_TO_HATCH_1MACHINE = 1080000;
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private sellTimer = 86400;
    uint256 private devFeeVal = 3;
    bool private initialized = false;
    mapping (address => uint256) private machineCollector;
    mapping (address => uint256) private claimedSocks;
    mapping (address => uint256) private lastCollection;
    mapping (address => uint256) private referralsCount;
    mapping (address => uint256) private washCount;
    mapping (address => uint256) private buyCount;
    mapping (address => uint256) private sellCount;
    mapping (address => uint256) private lastSell;
    uint256 private marketSocks;
    address payable private businessOwner;
    address payable private contestWallet;

    constructor() {
        businessOwner = payable(msg.sender);
        contestWallet = payable(0x4A20ADB6E4624A015B19Cf2417dFf940c8e0cE87);
    }

    function washSocks(address ref) public {
        require(initialized);

        if(ref == msg.sender || ref == address(0)){
            ref = contestWallet;
        }

        referralsCount[ref] += 1;

        uint256 socksUsed = getMySocks(msg.sender);
        uint256 newMachines = SafeMath.div(socksUsed,SOCKS_TO_HATCH_1MACHINE);
        machineCollector[msg.sender] = SafeMath.add(machineCollector[msg.sender],newMachines);
        claimedSocks[msg.sender] = 0;
        lastCollection[msg.sender] = block.timestamp;
        washCount[msg.sender] += 1;

        //send referral socks
        claimedSocks[ref] = SafeMath.add(claimedSocks[ref],SafeMath.div(socksUsed,8));

        //boost market to nerf machines hoarding
        marketSocks = SafeMath.add(marketSocks,SafeMath.div(socksUsed,5));
    }

    function sellSocks() public {
        require(initialized);
        require((lastSell[msg.sender] - block.timestamp) > sellTimer, "You cannot sell before timer has passed");
        uint256 hasSocks = getMySocks(msg.sender);
        uint256 sockValue = calculateSockSell(hasSocks);
        uint256 fee = devFee(sockValue);
        claimedSocks[msg.sender] = 0;
        lastCollection[msg.sender] = block.timestamp;
        marketSocks = SafeMath.add(marketSocks,hasSocks);
        businessOwner.transfer(fee);
        sellCount[msg.sender] += 1;
        payable (msg.sender).transfer(SafeMath.sub(sockValue,fee));
    }

    function buySocks(address ref) public payable {
        require(initialized);
        uint256 socksBought = calculateSockBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        socksBought = SafeMath.sub(socksBought,devFee(socksBought));
        uint256 fee = devFee(msg.value);
        businessOwner.transfer(fee);
        claimedSocks[msg.sender] = SafeMath.add(claimedSocks[msg.sender],socksBought);
        buyCount[msg.sender] += 1;
        if(lastSell[msg.sender] == 0){
            lastSell[msg.sender] = block.timestamp;
        }
        washSocks(ref);
    }

    function sockRewards(address adr) public view returns(uint256) {
        uint256 hasSocks = getMySocks(adr);
        uint256 sockValue = calculateSockSell(hasSocks);
        return sockValue;
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }

    function calculateSockSell(uint256 socks) public view returns(uint256) {
        return calculateTrade(socks,marketSocks,address(this).balance);
    }

    function calculateSockBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketSocks);
    }

    function calculateSockBuySimple(uint256 eth) public view returns(uint256) {
        return calculateSockBuy(eth,address(this).balance);
    }

    function devFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,devFeeVal),100);
    }

    function startBusiness() public payable onlyOwner {
        require(marketSocks == 0);
        initialized = true;
        marketSocks = 108000000000;
    }

    function setSellTimer(uint256 timer) public onlyOwner {
        require(timer <= 86400, "Timer cannot be higher then 1 day (86400 seconds)");
        sellTimer = timer;
        emit SetTimer(timer);
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function getReferralsCount(address adr) public view returns(uint) {
        return referralsCount[adr];
    }

    function getWashCount(address adr) public view returns(uint) {
        return washCount[adr];
    }

    function getSellCount(address adr) public view returns(uint) {
        return sellCount[adr];
    }

    function getBuyCount(address adr) public view returns(uint) {
        return buyCount[adr];
    }

    function getMyMachines(address adr) public view returns(uint256) {
        return machineCollector[adr];
    }

    function getMySocks(address adr) public view returns(uint256) {
        return SafeMath.add(claimedSocks[adr],getSocksSinceLastHatch(adr));
    }

    function getSocksSinceLastHatch(address adr) public view returns(uint256) {
        uint256 secondsPassed = min(SOCKS_TO_HATCH_1MACHINE,SafeMath.sub(block.timestamp,lastCollection[adr]));
        return SafeMath.mul(secondsPassed,machineCollector[adr]);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}