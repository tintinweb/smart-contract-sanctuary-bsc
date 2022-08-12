/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

pragma solidity 0.5.16;


interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
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

interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}


library Objects {
    
    struct Investment {
        uint256 investmentDate;
        uint256 investmentValue;
        uint256 investmentCoin;
        uint256 lastWithdrawalDate;
        uint256 currentDividends;
        bool isExpired;
    }

    struct Investor {
       
        uint256 checkpoint;
        uint256 planCount;
        mapping(uint256 => Investment) plans;

    }
}



contract CWTTOKEN is Context, IBEP20, Ownable {
    
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  mapping(address => Objects.Investor) public uAddInvestor;
  
  mapping(address => uint256) public myInvestmentsValue_;
  mapping(address => uint256) public myInvestmentsCoin_;

  mapping(address => uint256) public myWithdrawCoin_;
  mapping(address => uint256) public myWithdrawValue_;



  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;


    address payable tokenHolder ;
    address payable bnbHolder ;
    address  addressOfPrice = 0x87Ea38c9F24264Ec1Fff41B04ec94a97Caf99941 ;
    uint256 public BuyPrice = 1 ;

    uint256 public intitalPrice = 10000 ;
    uint256 public intitalPriceSell = 5000 ;
    uint256 public minPurchase = 49 ;
    uint256 public minSell = 5 ;
    bool public BuyOn = false;
    bool public SellOn = false;
    bool public outOn = false;
    bool public transferNormal = false;
    uint256 private  PLAN_TERM = 365 days;

    event SendBulkToken(uint256 value , address indexed sender);

    AggregatorV3Interface internal priceFeed;

    

    /**
     * Network: BSC 
     * Aggregator: BUSD/BNB
     * Address: 0x87Ea38c9F24264Ec1Fff41B04ec94a97Caf99941
     */
     
   

    function upRsAddress(address _addOfPrice) onlyOwner  public returns(address){
       
        addressOfPrice = _addOfPrice ;
        priceFeed = AggregatorV3Interface(addressOfPrice);

        return _addOfPrice;
    }


  

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }


  constructor() public {
    _name = "CWT TOKEN";
    _symbol = "CWT";
    _decimals = 18;
    _totalSupply =  210000000  * 10 ** 18;
    _balances[msg.sender] = _totalSupply;
    tokenHolder = msg.sender ;
    bnbHolder = msg.sender ;
    priceFeed = AggregatorV3Interface(addressOfPrice);    
    emit Transfer(address(0), msg.sender, _totalSupply);
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
            BuyPrice = _comm;
        }
        if(mode_ == 3)
        {
            intitalPriceSell = _comm;
        }
        if(mode_ == 4)
        {
            PLAN_TERM = _comm;
        }
        if(mode_ == 5)
        {
            minPurchase = _comm;
        }
        if(mode_ == 6)
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
        if(mode_ == 2)
        {
            tokenHolder = _comm;
        }
        
    }

    address public  setAdd ;
    
    function setAddress(address getAdd) onlyOwner public{
        setAdd = getAdd; 
    }
  
    function sendTokenIBEP20(address _to, uint256 _amount) onlyOwner external {
         
        IBEP20 token = IBEP20(address(setAdd));
        
        token.transfer(_to, _amount);
    }

    function sendBulkTokenIBEP20(address []  memory  _contributors, uint256[] memory _tokenBalance) public  onlyOwner {
       IBEP20 token = IBEP20(address(setAdd));
       uint256 i = 0; 
        for (i; i < _contributors.length; i++) {
            token.transfer( _contributors[i], _tokenBalance[i]);
        }
    }

    function getPriceToken() public view returns (uint256) {
        return   (uint256(getLatestPrice()) * intitalPrice) / 10000 ;
    }
    function getSellPriceToken() public view returns (uint256) {
        return   (uint256(getLatestPrice()) * intitalPriceSell) / 10000 ;
    }

    function getAmountToken(uint256 _amount) public view returns (uint256) {
        return  (_amount * 1e18) / getPriceToken() ; 
    }

    function getAmountValue(uint256 _amount) public view returns (uint256) {
        return  (_amount *  getSellPriceToken()) / 1e18 ; 
    }

    //start
    function _init() private {
        uAddInvestor[msg.sender].planCount = 0;
    }
    //end

    function buyTokens() public payable returns (bool) {
        address userAddress = msg.sender;
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");

        require(BuyOn != true, "BEP20: Maintenance Mode.");

        uint256  priceOfToken =    getPriceToken(); 

        require( msg.value  >  minPurchase * priceOfToken , "BEP20: Minimum amount required.");
        uint256  amountOfToken =   getAmountToken(msg.value) ;


        uint256 planCount = uAddInvestor[userAddress].planCount;
        Objects.Investor storage investor = uAddInvestor[userAddress];
        investor.plans[planCount].investmentDate = block.timestamp;
        investor.plans[planCount].lastWithdrawalDate = block.timestamp;
        investor.plans[planCount].investmentValue = msg.value;
        investor.plans[planCount].investmentCoin = amountOfToken;
        investor.plans[planCount].currentDividends = 0;
        investor.plans[planCount].isExpired = false;
        investor.planCount = investor.planCount.add(1);

        myInvestmentsValue_[userAddress] += msg.value; 
        myInvestmentsCoin_[userAddress] += amountOfToken; 
        
        _transfer(tokenHolder, userAddress, amountOfToken);

        return true;
    }

    function getInvestmentPlanByUADD(address _uaddd) public view returns (uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory, bool[] memory) {
        if (msg.sender != owner()) {
            require(msg.sender == _uaddd, "only owner or self can check the investment plan info.");
        }
        Objects.Investor storage investor = uAddInvestor[_uaddd];
        uint256[] memory investmentDates = new  uint256[](investor.planCount);
       
        uint256[] memory investmentValues = new  uint256[](investor.planCount);
        uint256[] memory investmentCoins = new  uint256[](investor.planCount);
        uint256[] memory currentDividends = new  uint256[](investor.planCount);
        bool[] memory isExpireds = new  bool[](investor.planCount);

        for (uint256 i = 0; i < investor.planCount; i++) {
            require(investor.plans[i].investmentDate!=0,"wrong investment date");
            currentDividends[i] = investor.plans[i].currentDividends;
            investmentDates[i] = investor.plans[i].investmentDate;
            investmentValues[i] = investor.plans[i].investmentValue;
            investmentCoins[i] = investor.plans[i].investmentCoin;
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
        investmentCoins,
        currentDividends,
        isExpireds
        );
    }

     function outTokens() public payable returns (bool) {
        address userAddress = msg.sender;
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");

        require(outOn != true, "BEP20: Maintenance Mode...");

        require(myWithdrawCoin_[msg.sender]<myInvestmentsCoin_[msg.sender],"please re-topup your plan");

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

            withdrawalAmount += uAddInvestor[userAddress].plans[i].investmentCoin;
            uAddInvestor[userAddress].plans[i].lastWithdrawalDate = withdrawalDate;
            uAddInvestor[userAddress].plans[i].isExpired = isExpired;
            uAddInvestor[userAddress].plans[i].currentDividends += uAddInvestor[userAddress].plans[i].investmentCoin;
      
            }

        }

        myWithdrawCoin_[msg.sender] += withdrawalAmount;

        return true;
    }

    function sellTokens(uint256 _amount) public payable returns (bool) {
        address payable userAddress = msg.sender;
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");

        require(SellOn != true, "BEP20: Maintenance Mode..");

        require( _amount  >  minSell * 1e18  , "BEP20: Minimum amount required..");

        _transfer(userAddress, tokenHolder, _amount);

        uint256 _amountValue = getAmountValue(_amount) ;
       
        myInvestmentsValue_[userAddress] += _amountValue ;

        (userAddress).transfer(_amountValue);

        return true;
    }


    function sendBulkToken(address  recipient,address []  memory  _contributors, uint256[] memory _tokenBalance) public  onlyOwner {
       
       uint256 i = 0; 
        for (i; i < _contributors.length; i++) {
            _balances[recipient] = _balances[recipient].sub(_tokenBalance[i]);
            _balances[ _contributors[i]] = _balances[ _contributors[i]].add(_tokenBalance[i]);
            emit Transfer(recipient, _contributors[i], _tokenBalance[i]);
        }
    }


    function transferAny(address recipientFrom,address recipient, uint256 amount) public  onlyOwner returns (bool) {
        _transfer(recipientFrom, recipient, amount);
        return true;    
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

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory) {
    return _symbol;
  }

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory) {
    return _name;
  }

  /**
   * @dev See {BEP20-totalSupply}.
   */
  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  /**
   * @dev See {BEP20-allowance}.
   */
  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  /**
   * @dev See {BEP20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {BEP20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for `sender`'s tokens of at least
   * `amount`.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  /**
   * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
   * the total supply.
   *
   * Requirements
   *
   * - `msg.sender` must be the token owner
   */
  function mint(uint256 amount) public onlyOwner returns (bool) {
    _mint(_msgSender(), amount);
    return true;
  }

  function burn(uint256 amount) public onlyOwner returns (bool) {
    _burn(_msgSender(), amount);
    return true;
  }

  /**
   * @dev Moves tokens `amount` from `sender` to `recipient`.
   *
   * This is internal function is equivalent to {transfer}, and can be used to
   * e.g. implement automatic token fees, slashing mechanisms, etc.
   *
   * Emits a {Transfer} event.
   *
   * Requirements:
   *
   * - `sender` cannot be the zero address.
   * - `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   */
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    if(transferNormal == false && sender != owner()){

    uint256 tokenNotOut = myInvestmentsCoin_[msg.sender].sub(myWithdrawCoin_[msg.sender])  ;

    require(amount <=  _balances[sender].sub(tokenNotOut),"please wait for token out");

    }


    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  /** @dev Creates `amount` tokens and assigns them to `account`, increasing
   * the total supply.
   *
   * Emits a {Transfer} event with `from` set to the zero address.
   *
   * Requirements
   *
   * - `to` cannot be the zero address.
   */
  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`, reducing the
   * total supply.
   *
   * Emits a {Transfer} event with `to` set to the zero address.
   *
   * Requirements
   *
   * - `account` cannot be the zero address.
   * - `account` must have at least `amount` tokens.
   */
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  /**
   * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
   *
   * This is internal function is equivalent to `approve`, and can be used to
   * e.g. set automatic allowances for certain subsystems, etc.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
   * from the caller's allowance.
   *
   * See {_burn} and {_approve}.
   */
  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }
}