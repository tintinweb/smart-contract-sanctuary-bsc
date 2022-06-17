/**
 *Submitted for verification at BscScan.com on 2022-06-17
*/

/**
* Submitted for verification at BscScan.com on 2022-05-26
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IBEP20 {
   
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

contract BlackLkisted is Ownable {
    mapping(address=>bool) isBlacklisted;

    function blackList(address _user) public onlyOwner {
        require(!isBlacklisted[_user], "user already blacklisted");
        isBlacklisted[_user] = true;
        // emit events as well
    }
    
    function removeFromBlacklist(address _user) public onlyOwner {
        require(isBlacklisted[_user], "user already whitelisted");
        isBlacklisted[_user] = false;
        // emit events as well
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
contract Whitelist is BlackLkisted {
    mapping(address => bool) whitelist;
    event AddedToWhitelist(address indexed account);
    event RemovedFromWhitelist(address indexed account);

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender));
        _;
    }

    function addToWhiteList(address _address) public onlyOwner {
        whitelist[_address] = true;
        emit AddedToWhitelist(_address);
    }

    function removeToWhiteList(address _address) public onlyOwner {
        whitelist[_address] = false;
        emit RemovedFromWhitelist(_address);
    }

    function isWhitelisted(address _address) public view returns(bool) {
        return whitelist[_address];
    }
}

contract MOLSwap is Context, Whitelist {
    using SafeMath for uint256;
  
    uint256 private _burnToken = 0;
    bool private hasStart=true;
    mapping(address=>address) public priceFeedAddressOfCurrency;
    address[]  private _useraddress;
    IBEP20 public tokenForSale;
    uint256 public tokenPerUsd;
    uint256 public tokenPerUsdwhiteListed;
    AggregatorV3Interface public priceFeedBNB;

    constructor()  {
        tokenForSale=IBEP20(0x88ae9c39B1e994E5E46259216F87D840d656aCb6);
        tokenPerUsd = 3;
        tokenPerUsdwhiteListed=10;
        priceFeedBNB = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
    }

    // ===== Public functions =====
   function buyToken() public payable{
        require(hasStart==true,"Sale is not started");
        require(!isBlacklisted[msg.sender], "caller is backlisted");

        uint256 _exchangeRateForUser = exchangeRateForUser(address(priceFeedBNB), isWhitelisted(msg.sender));

        uint256 _toTokenAmount = msg.value.mul(_exchangeRateForUser);

        tokenForSale.transfer(msg.sender, _toTokenAmount);
        payable(owner()).transfer(msg.value);
   }
   
   function swapTokens(address _purchaseToken, uint256 _fromTokenAmount) public {
        require(hasStart==true,"Sale is not started");
        require(priceFeedAddressOfCurrency[_purchaseToken] != address(0),"Invalid purchase currency!");
        require(!isBlacklisted[msg.sender], "caller is backlisted");

        uint256 _exchangeRateForUser = exchangeRateForUser(priceFeedAddressOfCurrency[_purchaseToken], isWhitelisted(msg.sender));

        uint256 _toTokenAmount = _fromTokenAmount.mul(_exchangeRateForUser);

        IBEP20(_purchaseToken).transferFrom(msg.sender, owner(), _fromTokenAmount);

        tokenForSale.transfer(msg.sender, _toTokenAmount);
   }
    
    // ===== Getters =====
    function exchangeRateForUser(address _priceFeedAddress, bool _isWhiteListed) public view returns(uint256) {
        uint256 _tokenPerUsd = _isWhiteListed ? tokenPerUsdwhiteListed : tokenPerUsd;
        uint256 priceInUSDOfCurrency = getLatestPriceOfCurrency(_priceFeedAddress);
        return priceInUSDOfCurrency.mul(_tokenPerUsd);
    }

    function getLatestPriceOfCurrency(address _priceFeedAddress) public view returns (uint256) {
        AggregatorV3Interface _priceFeed = AggregatorV3Interface(_priceFeedAddress);
        (,int price,,,) = _priceFeed.latestRoundData();
        return uint256(price).div(1e8);
    }

    // ===== Admin Functions =====
    function addCurrenicies(address currencies,address _add) public onlyOwner{
        require(priceFeedAddressOfCurrency[currencies] == address(0),"Currency Alreday Added");
        require(_add != address(0), "Price feed address must not be the address zero.");
        priceFeedAddressOfCurrency[currencies] = _add;
    }

    function changeTokenForSale(IBEP20 _newToken) public onlyOwner {
        require(_newToken != tokenForSale, "unchanged");
        tokenForSale = _newToken;
    }

    function updatepriceFeedBNB(AggregatorV3Interface _newPriceFeedAddress) public onlyOwner {
        priceFeedBNB = _newPriceFeedAddress;
    }
    
    function updatePriceFeedAddressOfCurrency(address currencies,address _add) public onlyOwner{
        require(priceFeedAddressOfCurrency[_add]!=address(0),"Currency Not Added, First Add the Currency");
        require(_add!=address(0),"Price Must be Greater Than 0");
        priceFeedAddressOfCurrency[currencies]=_add;
    }

    function deleteCurrenicies(address currencies) public onlyOwner{
        require(priceFeedAddressOfCurrency[currencies]!=address(0),"Currency Not Added, First Add the Currency");
        priceFeedAddressOfCurrency[currencies]=address(0);
    }

    function changePriceToken(uint256 _tokenPerUsd,uint256 _tokenPerUsdWhiteListed) external onlyOwner {
        tokenPerUsd = _tokenPerUsd;
        tokenPerUsdwhiteListed = _tokenPerUsdWhiteListed;
    }
    
    function startSale() external onlyOwner returns (bool){
        hasStart=true;
        return true;
    }

   function pauseSale() external onlyOwner returns (bool){
        hasStart=false;
        return true;
    }

    // Revert tokens which are received by contract
    function withdrwal(address _tokenToWithdraw, uint _amount, address _to) onlyOwner() external {
        if(_tokenToWithdraw == address(0)) {
            payable(_to).transfer(_amount);
        } else {
            IBEP20(_tokenToWithdraw).transfer(_to, _amount);
        }
    }

    receive() external payable {}
}