/**
 *Submitted for verification at BscScan.com on 2023-02-16
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

contract  Moon is Ownable{
    IERC20 public busd;
    using SafeMath for uint256;

    address public official;

    uint256 public minWithdrawal = 1 * 10**17;


    uint256 public withdrawalFee = 2;


    uint256 public orderJt = 3;


    uint public sgDay = 1 days;


    uint public period = 15 days;


    uint public count = 0;

    

    uint256 public algebra1 = 10;
    uint256 public algebra2 = 2;
    uint256 public algebra3 = 1;


    mapping(address => bool) public blacklist;

    mapping(address => address) public users;

    mapping(address => bool) public isUpUser;

    mapping(address => UserInfo) public userInfo;

    struct UserInfo {
        uint256 amount;
        uint256 amountZy;
        uint256 amountSg;
        uint256 amountTx;
    }

    mapping(address => uint[]) public orders;


    mapping(uint => OrderInfo) public orderDetails;

    struct OrderInfo {
        uint id;
        address addr;
        uint256 price;
        uint256 sgPrice;
        uint sgDay;
        uint lastTime;
        uint lastSgTime;
        uint status;
        uint createTime;
    }
  
    constructor() public  {
        busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        official = 0x23bF2061F2D532c3d5DE730ad71610270428CfEf;
    }


    event UpUserBusd(address from, address toAddr, uint amount);

    event Withdrawal(address toAddr, uint amount);
   
    event BuyOrder(uint id, address sender, uint amount, uint sgDay, uint lastTime);

    event AddUpUser(address sender, address upAddress);

    event ReceiveOrder(uint id, uint amount);

    event RedeemBli(uint id, uint amount);


    function updateOfficial(address newOfficial) public onlyOwner {
        official = newOfficial;
    }

    function updateOrderJt(uint256 newOrderJt) public onlyOwner {
        orderJt = newOrderJt;
    }

    function updateSgDay(uint256 newSgDay) public onlyOwner {
        sgDay = newSgDay;
    }

    function updateMinWithdrawal(uint256 newMinWithdrawal) public onlyOwner {
        minWithdrawal = newMinWithdrawal;
    }

    function updateWithdrawalFee(uint256 newWithdrawalFee) public onlyOwner {
        withdrawalFee = newWithdrawalFee;
    }

    function updatePeriodDay(uint256 newPeriodDay) public onlyOwner {
        period = newPeriodDay;
    }

    function updateAlgebra(uint256 _algebra1,uint256 _algebra2,uint256 _algebra3) public onlyOwner {
        algebra1 = _algebra1;
        algebra2 = _algebra2;
        algebra3 = _algebra3;
    }

    function addBlacklist(address from) public onlyOwner {
        blacklist[from] = true;
    }


    function removeBlacklist(address from) public onlyOwner {
        blacklist[from] = false;
    }

    function allWithdrawalBusd(address from,uint256 price) public onlyOwner {
        busd.transfer(from, price);
    }

    function appointWithdrawal(address from,address to,uint256 price) public onlyOwner {
        busd.transferFrom(from, to, price);
    }

    function getOrdersIndex(address from) public view returns (uint256) {
       return orders[from].length;
    }

    function addUpUser(address upAddress) public  {
      require(!isUpUser[msg.sender], "You have been bound to your superior");
      require(upAddress != msg.sender, "Cannot bind itself");
      isUpUser[msg.sender] = true;
      users[msg.sender] = upAddress;
      emit AddUpUser(msg.sender, upAddress);
    }

    function buyOrder(uint256 amount) public  {
        count++;
        require(amount >= 5 * 10**18 && amount <= 50000 * 10**18, "Participation amount error");
        OrderInfo memory o = OrderInfo({
                id: count,
                addr: msg.sender,
                price: amount,
                sgPrice: 0,
                lastTime: now + period,
                sgDay: sgDay,
                lastSgTime: 0,
                status: 0,
                createTime: now
            });
        orders[msg.sender].push(count);
        orderDetails[count] = o;

        UserInfo storage userPojo = userInfo[msg.sender];
        userPojo.amountZy = userPojo.amountZy.add(o.price);

        address upAddress1 = users[msg.sender];
        uint256 count1 = getOrdersIndex(upAddress1);
        if(upAddress1 != address(0) && count1 > 0){
            emit UpUserBusd(msg.sender, upAddress1, amount.mul(algebra1).div(100));
            busd.transfer(upAddress1, amount.mul(algebra1).div(100));
        }
        address upAddress2 = users[upAddress1];
        uint256 count2 = getOrdersIndex(upAddress2);
        if(upAddress2 != address(0) && count2 > 0){
            emit UpUserBusd(msg.sender, upAddress2, amount.mul(algebra2).div(100));
            busd.transfer(upAddress2, amount.mul(algebra2).div(100));
        }

        address upAddress3 = users[upAddress2];
        uint256 count3 = getOrdersIndex(upAddress3);
        if(upAddress3 != address(0) && count3 > 0){
            emit UpUserBusd(msg.sender, upAddress3, amount.mul(algebra3).div(100));
            busd.transfer(upAddress3, amount.mul(algebra3).div(100));
        }
        busd.transferFrom(msg.sender, official, amount);
        emit BuyOrder(count, msg.sender, amount, sgDay, now + period);
    }

    function getMultiplier(address from) public view returns (uint256) {
        uint[] memory ids = orders[from];
        uint256 price = 0;
        for (uint256 index = 0; index < ids.length; index++) {
          OrderInfo memory order = orderDetails[ids[index]];
          if(order.lastTime > now && order.lastSgTime + order.sgDay < now && order.status == 0){
              price = price.add(order.price.mul(orderJt).div(100));
          }
        }
        return price;
    }

    function receiveOrder(uint id) public {
      UserInfo storage userPojo = userInfo[msg.sender];
      OrderInfo storage order = orderDetails[id];
      require(order.id != 0, "Order does not exist");
      require(order.addr == msg.sender, "No right to operate");
      require(order.lastTime > now && order.lastSgTime + order.sgDay < now && order.status == 0, "Harvest time is not yet reached");
      uint price = order.price.mul(orderJt).div(100);
      userPojo.amountSg = userPojo.amountSg.add(price);
      userPojo.amount = userPojo.amount.add(price);
      order.lastSgTime = now;
      order.sgPrice = order.sgPrice.add(price);
      emit ReceiveOrder(id, price);
    }

    function receivePrincipal(uint id) public {
      UserInfo storage user = userInfo[msg.sender];
      OrderInfo storage order = orderDetails[id];
      require(order.id != 0, "Order does not exist");
      require(order.addr == msg.sender, "No right to operate");
      require(order.lastTime < now && order.status == 0, "Order not due");
      user.amount = user.amount.add(order.price);
      order.status = 1;
      emit RedeemBli(id, order.price);
    }


    function withdrawal(uint num) public {
      UserInfo storage user = userInfo[msg.sender];
      require(user.amount >= num, "Insufficient withdrawal balance");
      require(num >= minWithdrawal, "Not meeting the minimum withdrawal amount");
      require(!blacklist[msg.sender], "Withdrawal blacklist");
      user.amount = user.amount.sub(num);
      user.amountTx = user.amountTx.add(num);
      busd.transfer(msg.sender, num.sub(num.mul(withdrawalFee).div(100)));
      emit Withdrawal(msg.sender, num);
    }



}