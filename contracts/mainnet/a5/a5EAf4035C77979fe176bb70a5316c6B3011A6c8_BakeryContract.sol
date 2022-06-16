/**
 *Submitted for verification at BscScan.com on 2022-06-16
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

pragma solidity 0.8.9;

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

contract BakeryContract is Context, Ownable {
    using SafeMath for uint256;

    uint256 private DOUGH_TO_HATCH_1MINERS = 1080000;
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private devFeeVal = 4;
    uint256 private refFeeVal = 8;
    bool private initialized = false;
    address payable private destAddr1;
    address payable private destAddr2;
    address payable private defaultReferrer;
    mapping (address => uint256) private ovenMiners;
    mapping (address => uint256) private claimedDough;
    mapping (address => uint256) private lastKnead;
    mapping (address => address) private referrals;
    uint256 private marketDough;

    constructor(address _addr1, address _addr2, address _defaultReferrer) {
	require(!isContract(_addr1) && !isContract(_addr2));
        destAddr1 = payable(_addr1);
	destAddr2 = payable(_addr2);
	defaultReferrer = payable(_defaultReferrer);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }


    function kneadDough(address ref) public {
        require(initialized);

        if(ref == msg.sender) {
            ref = address(0);
        }

	if (referrals[msg.sender] == address(0)) {
          if (ref != msg.sender && ref != address(0)) {
            referrals[msg.sender] = ref;
          } else {
           referrals[msg.sender] = defaultReferrer;
          }
        }

        uint256 doughUsed = getMyDough(msg.sender);
        uint256 newMiners = SafeMath.div(doughUsed,DOUGH_TO_HATCH_1MINERS);
        ovenMiners[msg.sender] = SafeMath.add(ovenMiners[msg.sender],newMiners);
        claimedDough[msg.sender] = 0;
        lastKnead[msg.sender] = block.timestamp;

        //send referral dough
        claimedDough[referrals[msg.sender]] = SafeMath.add(claimedDough[referrals[msg.sender]],SafeMath.div(doughUsed,8));

        //boost market to nerf miners hoarding
        marketDough=SafeMath.add(marketDough,SafeMath.div(doughUsed,5));
    }

    function sellDough() public {
        require(initialized);
        uint256 hasDough = getMyDough(msg.sender);
        uint256 doughValue = calculateDoughSell(hasDough);
        uint256 devFees = calculateDevFee(doughValue);
        claimedDough[msg.sender] = 0;
        lastKnead[msg.sender] = block.timestamp;
        marketDough = SafeMath.add(marketDough,hasDough);
        splitDevFees(devFees);
        payable (msg.sender).transfer(SafeMath.sub(doughValue,devFees));
    }

    function beanRewards(address adr) public view returns(uint256) {
        uint256 hasDough = getMyDough(adr);
        uint256 doughValue = calculateDoughSell(hasDough);
        return doughValue;
    }

    function splitDevFees(uint256 fees) public payable {
	destAddr1.transfer(SafeMath.div(fees, 2));
	destAddr2.transfer(SafeMath.div(fees, 2));
    }

    function buyDough(address ref) public payable {
        require(initialized);
        uint256 doughBought = calculateDoughBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        doughBought = SafeMath.sub(doughBought,calculateDevFee(doughBought));
        uint256 devFees = calculateDevFee(msg.value);
	uint256 refFee = calculateRefFee(msg.value);
        splitDevFees(devFees);

        if (ref != msg.sender && ref != address(0)) {
          payable(ref).transfer(refFee);
        } else {
          defaultReferrer.transfer(refFee);
        }

        claimedDough[msg.sender] = SafeMath.add(claimedDough[msg.sender],doughBought);
        kneadDough(ref);
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }

    function calculateDoughSell(uint256 dough) public view returns(uint256) {
        return calculateTrade(dough,marketDough,address(this).balance);
    }

    function calculateDoughBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketDough);
    }

    function calculateDoughBuySimple(uint256 eth) public view returns(uint256) {
        return calculateDoughBuy(eth,address(this).balance);
    }

    function calculateDevFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,devFeeVal),100);
    }

    function calculateRefFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,refFeeVal),100);
    }

    function seedMarket() public payable onlyOwner {
        require(marketDough == 0);
        initialized = true;
        marketDough = 108000000000;
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function getMyMiners(address adr) public view returns(uint256) {
        return ovenMiners[adr];
    }

    function getMyDough(address adr) public view returns(uint256) {
        return SafeMath.add(claimedDough[adr],getDoughSinceLastBake(adr));
    }

    function getDoughSinceLastBake(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(DOUGH_TO_HATCH_1MINERS,SafeMath.sub(block.timestamp,lastKnead[adr]));
        return SafeMath.mul(secondsPassed,ovenMiners[adr]);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}