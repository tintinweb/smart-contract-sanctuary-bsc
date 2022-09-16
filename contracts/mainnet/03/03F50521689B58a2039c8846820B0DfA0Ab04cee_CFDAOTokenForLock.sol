/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

pragma solidity 0.5.8;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
 
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
 
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
 
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
 
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
 
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
 
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
  address public owner;
  address public controler;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier onlyControler() {
    require(msg.sender == controler);
    _;
  }
  
  modifier onlySelf() {
    require(address(msg.sender) == address(tx.origin));
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract CFDAOTokenForLock is Ownable {
    using SafeMath for uint256;

    ERC20 CFDAOToken;
    address public CFDAOTokenAddress;

    constructor(
      
    ) public {
        controler = msg.sender;
    }

    function init(address to) public onlyControler {
        CFDAOTokenAddress = to;
        CFDAOToken = ERC20(CFDAOTokenAddress);
    }

    struct Lock {
        uint256 lockPerDay;
        uint256 startLockDay;
        uint256 lastGetLockDay;
    }

    mapping(address => Lock) public lockBalances;
    function transferLock(address to,uint256 haveMoney,uint256 lockPerDay) public onlyControler{
      lockBalances[to].lockPerDay = lockBalances[to].lockPerDay.add(lockPerDay);
      lockBalances[to].startLockDay = getNowTime().div(86400);
      lockBalances[to].lastGetLockDay = getNowTime().div(86400);

      CFDAOToken.transfer(to,haveMoney);
    }

    uint256 public allDay;
    uint256 public currDay;
    uint256 public nowDay;
    uint256 public day;
    function getLock() public {
      require((lockBalances[msg.sender].lastGetLockDay-lockBalances[msg.sender].startLockDay)<30);

      nowDay = getNowTime().div(86400);

      allDay = nowDay.sub(lockBalances[msg.sender].startLockDay);
      currDay = nowDay.sub(lockBalances[msg.sender].lastGetLockDay);

      day = 0;
      if(allDay>60){
        day = currDay-(allDay-60);
      }else{
        day = currDay;
      }

      require(day>0);

      uint256 changeNum = lockBalances[msg.sender].lockPerDay.mul(day);
      CFDAOToken.transfer(msg.sender,changeNum);

      lockBalances[msg.sender].lastGetLockDay = nowDay;
    }

    uint256 public nowTime = 0;
    // function getNowTime() onlySelf public returns(uint256 _nowTime) {
    //     uint256 timeT = now-startTime;
    //     nowTime = startTime.add(timeT.mul(1440)); //1 minutes == 1day;
    //     return nowTime;
    // }
    function getNowTime() onlySelf public returns(uint256 _nowTime) {
        nowTime = now;
        return nowTime;
    }

    function recoveryToken(uint256 amount) onlyControler public {
        CFDAOToken.transfer(owner,amount);
    }

    //-------------------------------------------------
    function changeControler(address _controler) public onlyOwner onlySelf{
        controler = _controler;
    }
}