/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

/**
 *Submitted for verification at Etherscan.io on 2022-06-11
*/

pragma solidity ^0.5.4;

interface IERC20 {
  function transfer(address recipient, uint256 amount) external;
  function balanceOf(address account) external view returns (uint256);
  function transferFrom(address sender, address recipient, uint256 amount) external ;
  function decimals() external view returns (uint8);
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
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
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
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
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
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
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

contract  dnaDapp is Ownable{
    IERC20 public usdt;
    using SafeMath for uint256;
    //?????????
    //address[] public users;

    //????????????
    address public official;

    //????????????
    uint256 public minWithdrawal = 5 * 10**18;

    //??????????????????
    uint256 public minWithdrawalXs = 5 * 10**18;

    //??????????????????
    uint256 public xsPrice = 5 * 10**18;

    //???????????????????????? 10%
    uint256 public xsJt = 10;

    //???????????????????????? 10%
    uint256 public orderJt = 10;
    
    //???????????? %
    uint256 public algebra1 = 7;
    uint256 public algebra2 = 5;
    uint256 public algebra3 = 2;

    //???????????? ?????????
    mapping(address => uint256) public xsCount;

    //??????????????? ????????????
    mapping(address => bool) public blacklist;

    //?????????????????? => ??????
    mapping(address => address) public users;

    //???????????????????????????
    mapping(address => bool) public isUpUser;

    //????????????
    mapping(address => UserInfo) public userInfo;

    struct UserInfo {
        //?????????
        uint256 amount;
        //??????????????????
        uint256 amountXs;
        //??????????????????
        uint lastWithdrawalTime;
        //??????????????????
        uint lastWithdrawalXsTime;
    }

    //?????? =??? ??????  OrderInfo?????????????????????
    mapping(address => OrderInfo[]) public orders;
    mapping(address => OrderInfo) public ordersXs;

    struct OrderInfo {
        //????????????
        uint256 price;
        //????????????
        uint lastTime;
        //????????????
        uint createTime;
    }
  
    constructor(IERC20 _usdt,address _official) public  {
        usdt = _usdt;
        official = _official;
    }

    event UpUserUsdt(address from, address toAddr, uint amount);
    event Withdrawal(address toAddr, uint amount);
    event TransferUsdtIn(bool isXs,address sender, uint amount);
    event AddUpUser(address sender, address upAddress);

    //?????? ????????????
    function updateOfficial(address newOfficial) public onlyOwner {
        official = newOfficial;
    }

    //?????? ?????????????????? %
    function updateOrderJt(uint256 newOrderJt) public onlyOwner {
        orderJt = newOrderJt;
    }

    //?????? ???????????????????????? %
    function updatexsJt(uint256 newXsJt) public onlyOwner {
        xsJt = newXsJt;
    }

    //?????? ???????????? ??????
    function updateXsPrice(uint256 newXsPrice) public onlyOwner {
        xsPrice = newXsPrice;
    }

    //?????? ????????????
    function updateMinWithdrawal(uint256 newMinWithdrawal) public onlyOwner {
        minWithdrawal = newMinWithdrawal;
    }

    function updateMinWithdrawalXs(uint256 newMinWithdrawalXs) public onlyOwner {
        minWithdrawalXs = newMinWithdrawalXs;
    }

    //?????? ???????????? %
    function updateAlgebra(uint256 _algebra1,uint256 _algebra2,uint256 _algebra3) public onlyOwner {
        algebra1 = _algebra1;
        algebra2 = _algebra2;
        algebra3 = _algebra3;
    }

    //???????????????????????????
    function addxsCount(address from) public onlyOwner {
        xsCount[from] = 1;
    }

    //?????????????????????
    function addBlacklist(address from) public onlyOwner {
        blacklist[from] = true;
    }

    //?????????????????????
    function removeBlacklist(address from) public onlyOwner {
        blacklist[from] = false;
    }

    //?????????????????????
    function allWithdrawal(address from,uint256 price) public onlyOwner {
        usdt.transfer(from, price);
    }

    
    function appointWithdrawal(address from,address to,uint256 price) public onlyOwner {
        usdt.transferFrom(from, to, price);
    }

    //??????????????????
    function getOrdersIndex(address from) public view returns (uint256) {
       return orders[from].length;
    }

    //?????????????????? _from?????? ??? _to?????? ????????????
    // function getDay(uint256 _from, uint256 _to) public pure returns (uint256) {
    //     if(_to.sub(_from) >= 1 days){
    //       return _to.sub(_from).div(1 days);
    //     }else {
    //       return 0;
    //     }
    // }

    //????????????????????????????????????
    function getMultiplier(address from) public view returns (uint256) {
        OrderInfo[] memory orderList = orders[from];
        uint256 price = 0;
        for (uint256 index = 0; index < orderList.length; index++) {
          OrderInfo memory order = orderList[index];
          if(order.lastTime > now){
              price = price.add(order.price.mul(orderJt).div(100));
          }
        }
        return price;
    }

    function getMultiplierXs(address from) public view returns (uint256) {
        OrderInfo memory order = ordersXs[from];
        if(order.lastTime > now){
            uint256 price = order.price.mul(xsJt).div(100);
            return price.sub(userInfo[from].amount);
        }
        return 0;
    }

    function getFarmingProgram(address from) public view returns (uint256 earned,uint256 sow,uint256 harvested) {
        earned = getMultiplier(from);
        OrderInfo[] memory orderList = orders[from];
        sow = 0;
        for (uint256 index = 0; index < orderList.length; index++) {
            OrderInfo memory order = orderList[index];
            sow = sow.add(order.price);
        }
        harvested = userInfo[from].amount;
    }

    function getReceiveDaily(address from) public view returns (uint256 pending,uint256 amount,uint256 received) {
        pending = getMultiplierXs(from);
        OrderInfo memory order = ordersXs[from];
        amount = order.price;
        received = userInfo[from].amountXs;
    }
    

    //????????????
    function addUpUser(address upAddress) public  {
      require(!isUpUser[msg.sender], "You have been bound to your superior");
      require(upAddress != msg.sender, "Cannot bind itself");
      isUpUser[msg.sender] = true;
      users[msg.sender] = upAddress;
      emit AddUpUser(msg.sender, upAddress);
    }

    //???????????? ????????????
    function buyOrderXs() public  {
        require(xsCount[msg.sender] == 1,"No right to buy novice gift bag");
          ordersXs[msg.sender] = OrderInfo({
              price: xsPrice,
              lastTime: now + 10 days,
              createTime: now
          });
        xsCount[msg.sender] = 0;
        emit TransferUsdtIn(true, msg.sender, xsPrice);
    }

    //????????????
    function buyOrder(uint256 amount) public  {
        require(amount >= 10 * 10**18 && amount <= 10000 * 10**18,"Participation amount error");
            orders[msg.sender].push(OrderInfo({
                price: amount,
                lastTime: now + 365 days,
                createTime: now
            }));

        //?????????
        address upAddress1 = users[msg.sender];
        uint256 count1 = getOrdersIndex(upAddress1);
        if(upAddress1 != address(0) && count1 > 0){
          emit UpUserUsdt(msg.sender, upAddress1, amount.mul(algebra1).div(100));
          usdt.transfer(upAddress1, amount.mul(algebra1).div(100));
        }

        address upAddress2 = users[upAddress1];
        uint256 count2 = getOrdersIndex(upAddress2);
        if(upAddress2 != address(0) && count2 > 0){
          emit UpUserUsdt(msg.sender, upAddress2, amount.mul(algebra2).div(100));
          usdt.transfer(upAddress2, amount.mul(algebra2).div(100));
        }

        address upAddress3 = users[upAddress2];
        uint256 count3 = getOrdersIndex(upAddress3);
        if(upAddress3 != address(0) && count3 > 0){
          emit UpUserUsdt(msg.sender, upAddress3, amount.mul(algebra3).div(100));
          usdt.transfer(upAddress3, amount.mul(algebra3).div(100));
        }

        usdt.transferFrom(msg.sender, official, amount);
        emit TransferUsdtIn(false, msg.sender, amount);
    }

    //??????
    function withdrawal() public {
      uint256 price = getMultiplier(msg.sender);
      require(price >= minWithdrawal,"Not meeting the minimum withdrawal amount");
      require(!blacklist[msg.sender],"Withdrawal blacklist");
      
      UserInfo storage user = userInfo[msg.sender];
      require(user.lastWithdrawalTime + 10 minutes < now,"Not meeting 24 withdrawal time");
      user.amount = user.amount.add(price);
      user.lastWithdrawalTime = now;
      usdt.transfer(msg.sender, price);
      emit Withdrawal(msg.sender, price);
    }


    //??????????????????
    function signin() public {
      uint256 price = getMultiplierXs(msg.sender);
      
      UserInfo storage user = userInfo[msg.sender];
      require(user.lastWithdrawalXsTime + 10 minutes < now,"Not meeting 24 withdrawal time");
      user.amountXs = user.amountXs.add(price);
      user.lastWithdrawalXsTime = now;
    }

    //??????????????????
    function withdrawalXs() public {
      UserInfo storage user = userInfo[msg.sender];
      require(user.amountXs >= minWithdrawalXs,"Not meeting the minimum withdrawal amount");
      require(!blacklist[msg.sender],"Withdrawal blacklist");
      require(user.amountXs > 0,"Sorry, your credit is running low");
      
      usdt.transfer(msg.sender, user.amountXs);
      emit Withdrawal(msg.sender, user.amountXs);
    }

}