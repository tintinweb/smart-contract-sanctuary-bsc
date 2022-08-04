/**
 *Submitted for verification at BscScan.com on 2022-08-04
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

    uint public usdtCountSl;
    uint public usdtCount;
    uint public radarUsdtCount;
    uint public algebra1 = 7;
    uint public orderNumSlMax = 1;
    uint public orderNumXhMax = 20;
    bool public orderSlFlag = true;
    bool public orderXhFlag = true;

    mapping(address => uint256) public orderXhCount;
    mapping(address => uint256) public orderSlCount;
    mapping(address => bool) public isOrder;

    mapping(address => address) public users;
    mapping(address => bool) public isUpUser;


    constructor() public  {
        // usdtAddress = IERC20(0x55d398326f99059fF775485246999027B3197955);
        // radarAddress = IERC20(0x853106cd0C1C6e7Af94C03158bAF3A602d8eab00);
        // official = address(0x55229860CCAC725Dea5cF9d12d8290756d6Fa6FC);
        // isUpUser[0x55229860CCAC725Dea5cF9d12d8290756d6Fa6FC] = true;
        usdtAddress = IERC20(0xe38a71627E3289D8154da871F9ecF25Cd41EB483);
        radarAddress = IERC20(0x7fb2e7eA8279Cbd26823a3A775dd730BD0a89203);
        official = address(0x55229860CCAC725Dea5cF9d12d8290756d6Fa6FC);
        isUpUser[0x55229860CCAC725Dea5cF9d12d8290756d6Fa6FC] = true;
        usdtCount = 20;
        radarUsdtCount = 80;
        usdtCountSl = 100;
    }

    event CultivationXhEvent(address sender,uint num, uint usdtCount,uint radarCount, string uuid);
    event CultivationSlEvent(address sender, uint amount,uint upPrice, string uuid);
    event WithdrawalEvent(address sender, uint amount);
    event AddUpUser(address sender, address upAddress);

    function updateUsdtCount(uint _usdtCount) public onlyOwner {
        usdtCount = _usdtCount;
    }
    
    function updatePancakePair(address _pairAddress) public onlyOwner {
        pairAddress = IPancakePair(_pairAddress);
    }

    function updateRadarUsdtCount(uint _radarUsdtCount) public onlyOwner {
        radarUsdtCount = _radarUsdtCount;
    }
    function updateUsdtCountSl(uint _usdtCountSl) public onlyOwner {
        usdtCountSl = _usdtCountSl;
    }
    function updateOfficial(address _official) public onlyOwner {
        official = _official;
    }

    function updateOrderSlFlag(bool _orderSlFlag) public onlyOwner {
        orderSlFlag = _orderSlFlag;
    }

    function updateOrderXhFlag(bool _orderXhFlag) public onlyOwner {
        orderXhFlag = _orderXhFlag;
    }

    function updateOrderNumXhMax(uint _orderNumXhMax) public onlyOwner {
        orderNumXhMax = _orderNumXhMax;
    }
    function updateOrderNumSlMax(uint _orderNumSlMax) public onlyOwner {
        orderNumSlMax = _orderNumSlMax;
    }
    function updateAlgebra(uint256 _algebra1) public onlyOwner {
        algebra1 = _algebra1;
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


    function addUpUser(address upAddress) public  {
      require(!isUpUser[msg.sender], "You have been bound to your superior");
      require(upAddress != msg.sender, "Cannot bind itself");
      require(isUpUser[upAddress], "Cannot bind itself");
      isUpUser[msg.sender] = true;
      users[msg.sender] = upAddress;
      emit AddUpUser(msg.sender, upAddress);
    }

    function cultivationSl(string memory uuid) public {
        require(isUpUser[msg.sender], "Please bind the superior first");
        require(orderSlFlag,"Not yet open");
        require(orderSlCount[msg.sender] < orderNumSlMax , "Exceed the maximum purchase");
        usdtAddress.transferFrom(msg.sender, official, usdtCountSl * 10**18);

        address upAddress1 = users[msg.sender];
        uint upPrice = 0;
        if(upAddress1 != address(0) && isOrder[upAddress1]){
            upPrice = usdtCountSl.mul(10**18).mul(algebra1).div(100);
            usdtAddress.transfer(upAddress1, upPrice);
        }
        isOrder[msg.sender] = true;
        orderSlCount[msg.sender] = orderSlCount[msg.sender] + 1;
        emit CultivationSlEvent(msg.sender, usdtCountSl * 10**18, upPrice, uuid);
    }

    function cultivationXh(uint num, string memory uuid) public {
        require(isUpUser[msg.sender], "Please bind the superior first");
        require(orderXhFlag,"Not yet open");
        require(num > 0,"Exceed the maximum purchase");
        require(orderXhCount[msg.sender] + num <= orderNumXhMax , "Exceed the maximum purchase");
        uint usdtNum = usdtCount * 10**18 * num;
        usdtAddress.transferFrom(msg.sender, official, usdtNum);
        uint radarCount = getRadarCount();
        uint radarNum = radarCount * 10**18 * num;
        radarAddress.transferFrom(msg.sender, 0x000000000000000000000000000000000000dEaD, radarNum);
        orderXhCount[msg.sender] = orderXhCount[msg.sender] + num;
        emit CultivationXhEvent(msg.sender, num, usdtNum, radarNum, uuid);
    }

    function withdrawal(address toAddr, uint256 amount) onlyOwner public  {
        radarAddress.transfer(toAddr, amount);
        emit WithdrawalEvent(toAddr, amount);
    }

    function withdrawalUsdt(address toAddr, uint256 amount) onlyOwner public  {
        usdtAddress.transfer(toAddr, amount);
    }

}