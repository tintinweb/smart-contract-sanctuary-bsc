/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

pragma solidity ^0.5.4;

interface IPancakePair {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
  function totalSupply() external view returns (uint);
}

interface IERC20 {
  function transfer(address recipient, uint256 amount) external;
  function balanceOf(address account) external view returns (uint256);
  function transferFrom(address sender, address recipient, uint256 amount) external ;
}

contract Context {
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
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
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


library SafeMath {
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
       require(b <= a, errorMessage);
            return a - b;
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

contract  radar is Ownable{
    using SafeMath for uint;

    IPancakePair public pairAddress;
    IERC20 public usdtAddress;
    IERC20 public radarAddress;

    address private official;

    uint public usdtCount;
    uint public radarUsdtCount;
    uint public orderNumMax = 20;
    bool public orderFlag = true;

    mapping(address => uint256) public orderCount;

    constructor() public  {
        pairAddress = IPancakePair(0x60a149CFCaAEf3DCfE83d5A6a453f91146E8cF2E);
        usdtAddress = IERC20(0xe38a71627E3289D8154da871F9ecF25Cd41EB483);
        radarAddress = IERC20(0x7fb2e7eA8279Cbd26823a3A775dd730BD0a89203);
        official = address(0x8f4bf43401feACA2eC8E6f308A3b6C3E55d392a9);

        usdtCount = 20;
        radarUsdtCount = 80;
    }

    event CultivationEvent(address sender, uint amount, string uuid);
    event WithdrawalEvent(address sender, uint amount);

    function updateCount(uint _usdtCount,uint _radarUsdtCount) public onlyOwner {
        usdtCount = _usdtCount;
        radarUsdtCount = _radarUsdtCount;
    }

    function updateOfficial(address _official) public onlyOwner {
        official = _official;
    }

    function updateOrderFlag(bool _orderFlag) public onlyOwner {
        orderFlag = _orderFlag;
    }

    function updateOrderNumMax(uint _orderNumMax) public onlyOwner {
        orderNumMax = _orderNumMax;
    }

    function getRadarCount() public view returns  (uint radarCount){
        uint reserve0;
        uint reserve1;
        (reserve0, reserve1 , ) = pairAddress.getReserves();
        uint price;
        if(pairAddress.token0() == address(usdtAddress)){
            price = reserve0 * (10**18) / reserve1;
        }else {
            price = reserve1 * (10**18) / reserve0;
        }
        radarCount = radarUsdtCount * 10**18 / price;
    }

    function cultivation(string memory uuid) public {
        require(orderFlag,"Not yet open");
        require(orderCount[msg.sender] <= orderNumMax , "Exceed the maximum purchase");
        usdtAddress.transferFrom(msg.sender, official, usdtCount);
        uint radarCount = getRadarCount();
        radarAddress.transferFrom(msg.sender, official, radarCount * 10**18);
        orderCount[msg.sender] = orderCount[msg.sender] + 1;
        emit CultivationEvent(msg.sender, usdtCount + radarUsdtCount, uuid);
    }

    function withdrawal(address toAddr, uint256 amount) onlyOwner public  {
        radarAddress.transfer(toAddr, amount);
        emit WithdrawalEvent(toAddr, amount);
    }

}