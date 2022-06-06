/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 
{

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);


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

contract Staking is Ownable {


    IERC20 private ERC20interface;
    address public tokenAdress;

    
    
    uint256 Plan1_Roi = 5;
    uint256 Plan2_Roi = 10;
    uint256 Plan3_Roi = 20;

    struct TimeLock_Six_Month {
      address user_address;
      uint256 amount;
      uint256 start_time;
      uint256 end_time;
      uint256 reinvest;
    }
    struct TimeLock_Nine_Month {
        address user_address;
        uint256 amount;
        uint256 start_time;
        uint256 end_time;
        uint256 reinvest;
    }
    struct TimeLock_Twelve_Month {
        address user_address;
        uint256 amount;
        uint256 start_time;
        uint256 end_time;
        uint256 reinvest;
    }

    mapping(address => TimeLock_Six_Month) public sixMonth;
    mapping(address => TimeLock_Nine_Month) public nineMonth;
    mapping(address => TimeLock_Twelve_Month) public twelveMonth;

    constructor(){
    tokenAdress = 0x40F75eD09c7Bc89Bf596cE0fF6FB2ff8D02aC019; 
    ERC20interface = IERC20(tokenAdress);
                 }


    function Lock_Token(uint256 plan, uint256 _amount) external {
      if(plan == 1) {
          address contractAddress = address(this);
          uint256 currentAmount = sixMonth[msg.sender].amount;
          uint256 total = SafeMath.add(currentAmount,_amount);
          if(sixMonth[msg.sender].reinvest == 0) {
          uint256 startTime = block.timestamp;
          uint256 endTime = block.timestamp + 180 days;
          sixMonth[msg.sender] = TimeLock_Six_Month(msg.sender,total,startTime,endTime,1);
          }
          else {
              uint256 startTime = sixMonth[msg.sender].start_time;
              uint256 endTime = sixMonth[msg.sender].end_time;
              sixMonth[msg.sender] = TimeLock_Six_Month(msg.sender,total,startTime,endTime,1);
          }
          ERC20interface.transferFrom(msg.sender, contractAddress, _amount);
      }
      else if(plan == 2) {
          address contractAddress = address(this);
          uint256 currentAmount = nineMonth[msg.sender].amount;
          uint256 total = SafeMath.add(currentAmount,_amount);
           if(nineMonth[msg.sender].reinvest == 0) {
          uint256 startTime = block.timestamp;
          uint256 endTime = block.timestamp + 270 days;
          nineMonth[msg.sender] = TimeLock_Nine_Month(msg.sender,total,startTime,endTime,1);
           }
           else {
              uint256 startTime = nineMonth[msg.sender].start_time;
              uint256 endTime = nineMonth[msg.sender].end_time;
              nineMonth[msg.sender] = TimeLock_Nine_Month(msg.sender,total,startTime,endTime,1);
           }
          ERC20interface.transferFrom(msg.sender, contractAddress, _amount);
      }
      else if(plan == 3) {
          address contractAddress = address(this);
          uint256 currentAmount = twelveMonth[msg.sender].amount;
          uint256 total = SafeMath.add(currentAmount,_amount);
          if(twelveMonth[msg.sender].reinvest == 0) {
          uint256 startTime = block.timestamp;
          uint256 endTime = block.timestamp + 365 days;
          twelveMonth[msg.sender] = TimeLock_Twelve_Month(msg.sender,total,startTime,endTime,1);
          }
          else {
              uint256 startTime = twelveMonth[msg.sender].start_time;
              uint256 endTime = twelveMonth[msg.sender].end_time;
              twelveMonth[msg.sender] = TimeLock_Twelve_Month(msg.sender,total,startTime,endTime,1);
          }
          ERC20interface.transferFrom(msg.sender, contractAddress, _amount);
      }
    }

    function Reward(address _address , uint256 _plan) public view returns(uint256) {
          if(_plan == 1) {
            require(sixMonth[_address].amount>0 && _plan == 1, "User Didnt Deposit");  
            uint256 _amount = sixMonth[_address].amount;
            uint256 RoiReturn = plan_1_Roi(_amount);
            uint256 total = SafeMath.add(RoiReturn,_amount);
            return total;
          }
          else if(_plan == 2) {
             require(nineMonth[_address].amount>0 && _plan == 2, "User Didnt Deposit");    
            uint256 _amount = nineMonth[_address].amount;  
            uint256 RoiReturn = plan_2_Roi(_amount);
            uint256 total = SafeMath.add(RoiReturn,_amount);
            return total;
          }
          else if(_plan == 3) {
            require(twelveMonth[_address].amount> 0 && _plan == 3, "User Didnt Deposit");  
            uint256 _amount = twelveMonth[_address].amount;  
            uint256 RoiReturn = plan_3_Roi(_amount);
            uint256 total = SafeMath.add(RoiReturn,_amount);
            return total;
          }
          else {
              return 0;
          }
          
    }

    function withdraw(uint256 _plan) public {
        if(_plan == 1) {
        require(block.timestamp >= sixMonth[msg.sender].end_time, "You cant unstake now");
        uint256 roi = sixMonth[msg.sender].amount;
        uint256 RoiReturn = plan_1_Roi(roi);
        uint256 investedAmount = sixMonth[msg.sender].amount;
        uint256 total = SafeMath.add(RoiReturn,investedAmount);
        ERC20interface.transfer(msg.sender, total);

        sixMonth[msg.sender] = TimeLock_Six_Month(msg.sender,0,0,0,0);
         }

        else if(_plan == 2) {
        require(block.timestamp >= nineMonth[msg.sender].end_time, "You cant unstake now");
        uint256 roi = nineMonth[msg.sender].amount;
        uint256 RoiReturn = plan_2_Roi(roi);
        uint256 investedAmount = nineMonth[msg.sender].amount;
        uint256 total = SafeMath.add(RoiReturn,investedAmount);
        ERC20interface.transfer(msg.sender, total);
        nineMonth[msg.sender] = TimeLock_Nine_Month(msg.sender,0,0,0,0);
         }

         else if(_plan == 3) {
        require(block.timestamp >= twelveMonth[msg.sender].end_time, "You cant unstake now");
        uint256 roi = twelveMonth[msg.sender].amount;
        uint256 RoiReturn = plan_3_Roi(roi);
        uint256 investedAmount = twelveMonth[msg.sender].amount;
        uint256 total = SafeMath.add(RoiReturn,investedAmount);
        ERC20interface.transfer(msg.sender, total);

        twelveMonth[msg.sender] = TimeLock_Twelve_Month(msg.sender,0,0,0,0);
         }
    }

    function balance() public view returns(uint256) {
       return ERC20interface.balanceOf(address(this));
    }

    function plan_1_Roi(uint256 _amount) public view returns(uint256){
       return SafeMath.div(SafeMath.mul(_amount,Plan1_Roi),100);
    }

    function plan_2_Roi(uint256 _amount) public view returns(uint256){
       return SafeMath.div(SafeMath.mul(_amount,Plan2_Roi),100);
    }

    function plan_3_Roi(uint256 _amount) public view returns(uint256){
       return SafeMath.div(SafeMath.mul(_amount,Plan3_Roi),100);
    }


}