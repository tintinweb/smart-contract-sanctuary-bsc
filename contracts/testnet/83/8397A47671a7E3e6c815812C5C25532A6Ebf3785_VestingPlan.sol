/**
 *Submitted for verification at BscScan.com on 2022-06-21
*/

pragma solidity 0.5.4;

library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    require(c / a == b, "SafeMath: multiplication overflow");

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
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
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
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
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
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
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
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract VestingPlan{
    using SafeMath for *;

    struct Account{
        uint256 id;
        uint256 cycleAmount;
        uint256 cycleStarted;
        uint256 totalCycle;
        uint256 cycleEnd;
        uint256 cycleClaimed; 
        bool is_blocked;
    } 

    mapping(address => Account) public accounts;
    mapping(uint => address) public idToAddress;
    uint256 public lastUserId = 1;

    address payable public owner;  
    uint256 private constant INTEREST_CYCLE = 30 days;    


    constructor(address payable _owner) public 
    {       
        owner = _owner;  
    }

    function setAddress(address payable []  memory  _address, uint256[] memory monthlyAmt, uint256[] memory totalCycle) public payable
    {
      require(msg.sender==owner,"Only Owner");    
      require(_address.length>0,"Invalid Input!");
      uint256 i;
      for(i=0;i<_address.length;i++)
      {
        if(accounts[_address[i]].id==0)
        {
            Account memory user = Account({
              id:lastUserId,
              cycleAmount:monthlyAmt[i],
              cycleStarted:block.timestamp,
              totalCycle:totalCycle[i],
              cycleEnd:block.timestamp+(totalCycle[i]*INTEREST_CYCLE),
              cycleClaimed:block.timestamp,
              is_blocked:false               
            });
            accounts[_address[i]] = user;

            idToAddress[lastUserId]=_address[i];
            lastUserId++;
            (_address[i]).transfer(monthlyAmt[i]);
        }
      }
    }
    
    function claim() public 
    {
      require(accounts[msg.sender].id>0 && !accounts[msg.sender].is_blocked);
      (uint256 amount,uint256 _gap)=getReleaseAmount(msg.sender);
      if(amount>0)
      {
        msg.sender.transfer(amount);
        accounts[msg.sender].cycleClaimed=accounts[msg.sender].cycleClaimed.add(_gap.mul(INTEREST_CYCLE));
      }
    }


    function getReleaseAmount(address _user) public view returns(uint256,uint256)
    {
        if(accounts[_user].id>0 && accounts[_user].cycleClaimed<accounts[_user].cycleEnd && block.timestamp>accounts[_user].cycleClaimed)
        {
          uint256 _gap;
       
          if(block.timestamp>accounts[_user].cycleEnd)
          _gap=(accounts[_user].cycleEnd.sub(accounts[_user].cycleClaimed)).div(INTEREST_CYCLE);
          else
          _gap=(block.timestamp.sub(accounts[_user].cycleClaimed)).div(INTEREST_CYCLE);

          return (_gap.mul(accounts[_user].cycleAmount),_gap);
        }
        else
        return (0,0);
    }

    function sendToken(address payable _wallet,uint256 amount) public
    {
        require(msg.sender==owner,"Only Owner!");
        _wallet.transfer(amount);
    }

    function suspendAccount(address _wallet) public
    {
        require(msg.sender==owner,"Only Owner!");
        require(accounts[_wallet].id>0,"Account not exist!");
        accounts[_wallet].is_blocked=true;
    }

    function activeAccount(address _wallet) public
    {
        require(msg.sender==owner,"Only Owner!");
        require(accounts[_wallet].id>0,"Account not exist!");
        accounts[_wallet].is_blocked=false;
    }
}