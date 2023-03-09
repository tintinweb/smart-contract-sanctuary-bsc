/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

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

contract DCSWAP is Context, Ownable {
    IBEP20 public token=IBEP20(0x1572604ed2728f18dFf1c2fC0c12DE4D1509BDbF);    
    using SafeMath for uint256;
    uint256 public totalUSDT=0;
    uint256 public totalBNB=0;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
   
    bool public  hasStart=true;
    address[]  public _useraddress;
    uint256 public airdrop = 10;
    uint256 public rewards=5;     
    uint256 public dropTokens=0;     
    uint256 public dropLimit=500000000 * 10**18;     
    address[]  public _airaddress;

    uint256 public endDate=block.timestamp.add(30 days);
    uint256 public startDate=block.timestamp;
    uint256 public refferalPercentage = 1000;
    uint256 public refferalDivider = 10000;
    uint256 public tokenPerUsdBNB=10;
    uint256 public tokenPerUsdUSDT=20;
    AggregatorV3Interface public priceFeedBnb;
    AggregatorV3Interface public priceFeedUSDT;
    address public USDT = 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd; // TUSD Testnet 
    address public TOKEN = 0x1572604ed2728f18dFf1c2fC0c12DE4D1509BDbF; // TESTNET
    constructor(address _tokenAddress)  {
      TOKEN = _tokenAddress;
      priceFeedBnb = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526); // testnet
      priceFeedUSDT = AggregatorV3Interface(0xEca2605f0BCF2BA5966372C99837b1F182d3D620); // testnet
    }

    function toggleSale(bool _sale) external onlyOwner returns (bool){
        hasStart=_sale;
        return true;
    }


   function getLatestPriceBnb() public view returns (uint256) {
        (,int price,,,) = priceFeedBnb.latestRoundData();
        return uint256(price).div(1e8);
    }
    
    function getLatestPriceUSDT() public view returns (uint256) {
        (,int price,,,) = priceFeedUSDT.latestRoundData();
        return uint256(price).div(1e8);
    }    


  /**
   * @dev Returns the bep token owner.
   */
   function buyToken(address _currency , uint256 _amount,address _refferalAddress) public payable{
        require(hasStart,"Sale is not started");
        require(block.timestamp>startDate,"Sale has not stared yet!");
        require(block.timestamp<endDate,"Sale Completed"); 
       
        if(_currency==USDT){ 
            require(_amount > 0,"Amount must be greater then zero");
            uint256 numberOfTokens=bnbToToken(_amount,USDT);
            if(_refferalAddress != address(0)){
                uint256 refferAmount = numberOfTokens.mul(refferalPercentage).div(refferalDivider);
                token.transfer(_refferalAddress, refferAmount);    
            }
            IBEP20(USDT).transferFrom(msg.sender,owner(), _amount);
            token.transfer(msg.sender, numberOfTokens);
            totalUSDT=totalUSDT.add(_amount);
        }else{  
            require(msg.value > 0,"Amount must be greater then zero");
            uint256 numberOfTokens=bnbToToken(msg.value,address(this));        
            if(_refferalAddress != address(0)){
                uint256 refferAmount = numberOfTokens.mul(refferalPercentage).div(refferalDivider);
                token.transfer(_refferalAddress, refferAmount);    
            }            
            payable(owner()).transfer(msg.value);
            token.transfer(msg.sender, numberOfTokens);
            totalBNB=totalBNB.add(_amount);
        } 
        if(!checkExitsAddress(msg.sender)){
            _useraddress.push(msg.sender);
         }     
   }
     

    // CHANGE REFFERAL PERCENTAGE
    function setRefferalPercentage(uint256 _refferalPercentage) public onlyOwner {
        require(_refferalPercentage>0,"Percentage should be greater then zero");
        require(_refferalPercentage<=refferalDivider,"Percentage should less then current divider");
        refferalPercentage = _refferalPercentage;
    }

  // to change Price of the token
    function changePrice(uint256 _tpsBNB,uint256 _tpsUSDT ) external onlyOwner{
        tokenPerUsdBNB = _tpsBNB;
        tokenPerUsdUSDT=_tpsUSDT;
    }
    
    
    function checkExitsAddress(address _userAdd) private view returns (bool){
       bool found=false;
        for (uint i=0; i<_useraddress.length; i++) {
            if(_useraddress[i]==_userAdd){
                found=true;
                break;
            }
        }
        return found;
    }
    // to check number of token for given BNB
    function bnbToToken(uint256 _amount, address currency) public view returns(uint256){
        uint256 precision = 1e4;
        uint256 numberOfTokens;
        uint256 bnbToUsd;
        if(currency==USDT){
         bnbToUsd = precision.mul(_amount).mul(getLatestPriceUSDT()).div(1e18);  
        numberOfTokens = bnbToUsd.mul(tokenPerUsdUSDT);
        }else{
          bnbToUsd = precision.mul(_amount).mul(getLatestPriceBnb()).div(1e18);
          numberOfTokens = bnbToUsd.mul(tokenPerUsdBNB);
        }
        return numberOfTokens.mul(1e18).div(precision);
    }
   
    function withdrwal(address _currency) public onlyOwner{
        require(block.timestamp>endDate,"ICO Is Not completed yet");
        if(_currency == USDT){              
            IBEP20(USDT).transfer(owner(),IBEP20(USDT).balanceOf(address(this)));   
        }else if(_currency == TOKEN){
            IBEP20(TOKEN).transfer(owner(),IBEP20(TOKEN).balanceOf(address(this)));   
        }else{            
            payable(owner()).transfer(address(this).balance);
        }
    }
    
    function setDate(uint256 _endDate,uint256 _startDate) public onlyOwner returns (bool){
        endDate=_endDate;
        startDate=_startDate;
        return true;
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