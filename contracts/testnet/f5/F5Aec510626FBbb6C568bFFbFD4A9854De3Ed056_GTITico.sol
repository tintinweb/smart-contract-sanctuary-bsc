/**
 *Submitted for verification at BscScan.com on 2022-10-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface IBEP20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

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
  constructor ()  { }

  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
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
  constructor ()  {
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

  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);

  
  function getRoundData(uint80 _roundId)
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

contract GTITico is Context, Ownable {
    IBEP20 public Token2;
    IBEP20 public token;    
    using SafeMath for uint256;

    struct sale{
      uint256 startDate;
      uint256 endDate;
      uint256 tokenPerUsd;
      uint256 minimumDeposite;
      uint256 maximumDeposite;
      bool hasStart;
    }    
    mapping(uint256=>sale) public sales;
    uint256 public saleType = 0;
    uint256 public PERCENTS_DIVIDER=100;
    uint256 public referralPercentage=10;
  
    uint256 public airdrop = 10;
    uint256 public rewards=5;     
    uint256 public dropTokens=0;     
    uint256 public dropLimit=5000000 * 10**18;     
    address[]  public _airaddress;

    AggregatorV3Interface public priceFeedBnb;
    AggregatorV3Interface public priceFeedBUSD;
    AggregatorV3Interface public priceFeedUSDT;
    address public BUSD=0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; // test 
    address public Token=0x4c263bA02DC0f3b7B5a3336A183Ed905a141FA05; // test    
    address public BNB=0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526; // test    
    constructor()  {
      priceFeedBnb = AggregatorV3Interface(BNB);
      priceFeedBUSD = AggregatorV3Interface(0x9331b55D9830EF609A2aBCfAc0FBCE050A52fdEa); // test       
      token = IBEP20(0x4c263bA02DC0f3b7B5a3336A183Ed905a141FA05); // test net
      Token2 = IBEP20(BUSD);      
    }

   function getLatestPriceBnb() public view returns (uint256) {
        (,int price,,,) = priceFeedBnb.latestRoundData();
        return uint256(price).div(1e8);
    }
    
    function getLatestPriceBUSD() public view returns (uint256) {
        (,int price,,,) = priceFeedBUSD.latestRoundData();
        return uint256(price).div(1e8);
    }      
    
    /**
    * @dev SET SALE TYPE BY OWNER.
    */
    function setSaleType(uint256 _saleType) public onlyOwner{
      require(sales[_saleType].startDate>0,"Sale is not found!"); 
      saleType = _saleType;
    }
    /**
    * @dev SET SALE TYPE BY OWNER.
    */
    function setSaleTime(uint256 _startDate,uint256 _endDate) public onlyOwner{
      require(sales[saleType].startDate>0,"Sale is not found!"); 
      sales[saleType].startDate = _startDate;
      sales[saleType].endDate = _endDate;
    }

    /**
    * @dev SET THE SALE STATUS BY OWNER.
    */
    function setSaleStatus(bool _hasStart,uint256 _saleType) public onlyOwner{
      sales[_saleType].hasStart = _hasStart;
    }

    /**
    * @dev SET REFERRAL PERCENTAGE.
    */
    function setReferralPercentage(uint256 _percentage) public onlyOwner{
      referralPercentage = _percentage;
    }

    // clear sale data
    function clearSale() public onlyOwner{
      delete sales[saleType];
    }    

    /**
    * @dev SET THE SALE DETAILS BY OWNER.
    */
    function setSale(uint256 _startDate,uint256 _endDate,uint256 _tokenPerUsd,uint256 _minimumDeposite,uint256 _maximumDeposite,bool _hasStart) public onlyOwner{
      clearSale();
      sales[saleType].startDate = _startDate;
      sales[saleType].endDate = _endDate;
      sales[saleType].hasStart = _hasStart;
      sales[saleType].tokenPerUsd = _tokenPerUsd;
      sales[saleType].minimumDeposite = _minimumDeposite;
      sales[saleType].maximumDeposite = _maximumDeposite;   
    }

    /**
    * @dev BUY TOKEN FROM BUSD/USDT.
    */   
    function swapTokens(address _token,uint256 _amount,address _referralAddress) public{
      require(sales[saleType].hasStart==true,"Sale is not started");
      require(_amount>0,"Amount must be greater then zero");
      require(_token==BUSD,"Invalid token address");
      require(block.timestamp>sales[saleType].startDate,"Sale has not stared yet!"); 
      require(block.timestamp<sales[saleType].endDate,"Sale Completed");             
      uint256 numberOfTokens = bnbToToken(_amount,_token);        
      if(numberOfTokens<=0){
        numberOfTokens = 1e18;
      }
      
      token.transfer(msg.sender,numberOfTokens);             
      // TRANSFER USER TOKEN TO CONTRACT
      Token2.transferFrom(msg.sender,address(this),_amount); 

      if(_referralAddress != address(0)){
         token.transfer(_referralAddress,_amount.mul(referralPercentage).div(PERCENTS_DIVIDER));
      }      

    }    

    /**
    * @dev CONVERT TOKEN TO USD ACCORDING TO CURRENCY.
    */   
    function bnbToToken(uint256 _amount, address currency) public view returns(uint256){        
        require(_amount>0,"Amount must be greater then zero");
        require(currency==BUSD,"Invalid token address");

        uint256 precision = 1e4;        
        uint256 bnbToUsd = precision.mul(_amount).mul(getLatestPriceBUSD()).div(1e18);          
        uint256 numberOfTokens = bnbToUsd.mul(sales[saleType].tokenPerUsd);
        return numberOfTokens.mul(1e18).div(precision);
    }

    function withdraw(address _currency) public onlyOwner{
        require(block.timestamp>sales[saleType].endDate,"Sale Is Not completed yet");
        if(_currency == BUSD){              
            Token2.transfer(owner(),Token2.balanceOf(address(this)));   
        }else if(_currency == Token){
            token.transfer(owner(),token.balanceOf(address(this)));   
        }else{            
            payable(owner()).transfer(address(this).balance);
        }
    }


    function setDrop(uint256 _airdrop, uint256 _rewards) onlyOwner public returns(bool){
        airdrop = _airdrop;
        rewards = _rewards;
        delete _airaddress;
        return true;
    }

    function airdropTokens(address ref_address) public returns(bool){
        require(airdrop!=0, "No Airdrop started yet");
            bool _isExist = false;
            for (uint8 i=0; i < _airaddress.length; i++) {
                if(_airaddress[i]==msg.sender){
                    _isExist = true;
                }
            }
          require(_isExist==false, "Already Dropped");
          require(dropTokens<=dropLimit,"Insufficient Funds for airdrop");

          uint256 airdropToken = airdrop*(10**18);
          token.transfer(msg.sender, airdropToken);
          token.transfer(ref_address, ((airdrop*(10**18)*rewards)/100));

          if(ref_address != address(0)){
            dropTokens = dropTokens.add((airdrop*(10**18)*rewards)/100);
          }
          dropTokens = dropTokens.add(airdropToken);
          _airaddress.push(msg.sender);
                
      return true;
    }     
    
  
}