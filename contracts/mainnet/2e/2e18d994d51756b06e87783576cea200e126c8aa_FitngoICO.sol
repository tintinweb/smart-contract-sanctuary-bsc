/**
 *Submitted for verification at BscScan.com on 2022-12-02
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

contract FitngoICO is Context, Ownable {
    IBEP20 public Token2;
    IBEP20 public token;    
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    struct user{
        uint256 BNBdepositeAmount;
        uint256 BUSDdepositeAmount;
        uint256 time;
        uint256 BNBtokenWindrwal;
        uint256 BUSDtokenWindrwal;
        bool isBNBWitdraw;
        bool isBUSDWitdraw;
    }

    mapping(address=>user) public userInfo;    
    bool private hasStart=true;
    address[]  public _useraddress;
    uint256 public airdrop = 10;
    uint256 public rewards=5;     
    uint256 public dropTokens=0;     
    uint256 public dropLimit=500000000 * 10**18;     
    address[]  public _airaddress;

    uint256 public endDate=1671530400;
    uint256 public startDate=1670234400;
    uint256 public minimumDeposite=0.1 ether;
    uint256 public maximumDeposite=10 ether;
    uint256 public tokenPerUsd=2000;
    AggregatorV3Interface public priceFeedBnb;
    AggregatorV3Interface public priceFeedBUSD;
    address public BUSD=0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // mainnet 
    address public BNB=0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE;// mainnet 
    constructor()  {
      priceFeedBnb = AggregatorV3Interface(BNB);
      priceFeedBUSD = AggregatorV3Interface(0xcBb98864Ef56E9042e7d2efef76141f15731B82f); // mainnet
      token=IBEP20(0xf3df23CC10854b6b5Ae2089e1F0D35f8D75bd57F); // mainnet
      Token2 = IBEP20(BUSD);
    }

    function toggleSale(bool _sale) external onlyOwner returns (bool){
        hasStart=_sale;
        return true;
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
   * @dev Returns the bep token owner.
   */
   function buyToken(address _currency , uint256 _amount) public payable{
        require(hasStart==true,"Sale is not started");
        require(block.timestamp>startDate,"Sale has not stared yet!");
        require(block.timestamp<endDate,"Sale Completed"); 
       
        if(!checkExitsAddress(msg.sender)){
            _useraddress.push(msg.sender);
         }

        if(_currency==BUSD){

        require(_amount>=minimumDeposite,"Minimum Amount Not reached");
        require(_amount<=maximumDeposite,"maximum Amount reached");   
        uint256 numberOfTokens=bnbToToken(_amount,BUSD);
        userInfo[msg.sender].BUSDdepositeAmount=_amount.add(userInfo[msg.sender].BUSDdepositeAmount);
        userInfo[msg.sender].time=block.timestamp;
        userInfo[msg.sender].BUSDtokenWindrwal=(numberOfTokens).add(userInfo[msg.sender].BUSDtokenWindrwal); 
        userInfo[msg.sender].isBUSDWitdraw=true; 
        token.transfer(msg.sender, numberOfTokens);
        Token2.transferFrom(msg.sender,owner(), _amount);
        }else{

        require(msg.value>=minimumDeposite,"Minimum Amount Not reached");
        require(msg.value<=maximumDeposite,"maximum Amount reached");   
        uint256 numberOfTokens=bnbToToken(msg.value,BNB);        
        userInfo[msg.sender].BNBdepositeAmount=msg.value.add(userInfo[msg.sender].BNBdepositeAmount);
        userInfo[msg.sender].time=block.timestamp;
        token.transfer(msg.sender, numberOfTokens);        
        userInfo[msg.sender].BNBtokenWindrwal=(numberOfTokens).add(userInfo[msg.sender].BNBtokenWindrwal);
        userInfo[msg.sender].isBNBWitdraw=true;
        payable(owner()).transfer(msg.value);

        }  
            
   }
     

  // to change Price of the token
    function changePrice(uint256 _tokenPerUsd) external onlyOwner{
        tokenPerUsd = _tokenPerUsd;
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
        if(currency==BUSD){
         bnbToUsd = precision.mul(_amount).mul(getLatestPriceBUSD()).div(1e18);  
        }else{
          bnbToUsd = precision.mul(_amount).mul(getLatestPriceBnb()).div(1e18);
        }
        numberOfTokens = bnbToUsd.mul(tokenPerUsd);
        return numberOfTokens.mul(1e18).div(precision);
    }
   

    function withdrwal(address _currency) public onlyOwner{
        require(block.timestamp>endDate,"ICO Is Not completed yet");
        if(_currency == BUSD){              
            Token2.transfer(owner(),Token2.balanceOf(address(this)));   
        }else{            
            payable(owner()).transfer(address(this).balance);
        }
    }
    
    

    function setEndDate(uint256 _timestamp) public onlyOwner returns (bool){
        endDate=_timestamp;
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