/**
 *Submitted for verification at BscScan.com on 2022-03-08
*/

/**
 *Submitted for verification at polygonscan.com on 2021-10-07
 */

/**
 *Submitted for verification at polygonscan.com on 2021-09-14
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
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
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
} 

abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor() {
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

interface IERC20 {
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
  // function name() external view returns (string memory);
  // function totalSupply() external view returns (uint);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
  function balanceOf(address owner) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 value) external returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool); // check allowance
  function permit(address owner, address spender, uint256 rawAmount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
}

contract BscPool is Ownable {
  using SafeMath for uint256;
  // address public token; //Token address (TOKENS)
  address public gift_token;
  address public walletAddress;
  
  // margin percentage
  uint256 private margin_int = 0;
  uint256 private margin_decimals = 1;
  
  // list of token addresses
  address[] private tokenAddresses;

  uint256 private _gift_amount_nominator = 5;
  uint256 private _gift_amount_denominator = 1;

  //Events
  event ContractInstantiation(address instantiation, address token);
  event Deposit(
    address indexed from,
    address indexed to,
    uint256 value,
    string orderId
  );
  event Gift(
    address indexed from,
    address indexed to,
    uint256 value,
    string orderId
  );
  event Withdraw(
    address indexed from,
    address indexed to,
    address token_address,
    uint256 value
  );

  constructor() {
    //the wallet for withdraw money
    walletAddress = msg.sender; 
  }

  function getGiftToken() public view returns (address addr) {
    return gift_token;
  }

  function setGiftToken(address giftTokenAddress) public onlyOwner {
    gift_token = giftTokenAddress;
  }

  // update walletaddress from the owner
  function updateWalletAddress(address altWalletAddress) public onlyOwner {
    walletAddress = altWalletAddress;
  }

  // get the tokens that supports
  function getSupportedTokenAddresses() public view returns (address[] memory) {
    address[] memory supportedTokenAddresses = new address[](tokenAddresses.length);
    for (uint256 i = 0; i < tokenAddresses.length; i++) {
      supportedTokenAddresses[i] = tokenAddresses[i];
    }
    return supportedTokenAddresses;
  }

  function setSupportedTokenAddresses(address[] memory _tokenAddresses) public onlyOwner{
    // Replaced by newarray 
    tokenAddresses = _tokenAddresses;
  }

  function checkTokenAddressExists(address token_address)
    internal
    view
    returns (bool)
  {
    bool exists = false;
    for (uint256 i = 0; i < tokenAddresses.length; i++) {
      if (tokenAddresses[i] == token_address) {
        exists = true;
      }
    }
    return exists;
  }

  function _sendGiftToken(
    uint256 amount,
    address sender,
    string memory orderId
  ) private {
    uint256 _gift_amount = amount.mul(_gift_amount_nominator).div(
      _gift_amount_denominator
    );

    uint256 _gift_balance = IERC20(gift_token).balanceOf(address(this));
    require(_gift_balance >= _gift_amount, "Pool: INSUFFICIENT GIFT TOKEN");
    IERC20(gift_token).transfer(sender, _gift_amount);

    //give user Bite for free
    emit Gift(sender, address(this), _gift_amount, orderId); //from, to, amount, orderId
  }

  function _sendGiftTokenV2(uint256 amount, string memory orderId) private {
    uint256 _gift_amount = amount.mul(_gift_amount_nominator).div(
      _gift_amount_denominator
    );
    // check exisit gt balance in pool
    uint256 _gift_balance = IERC20(gift_token).balanceOf(address(this));
    require(_gift_balance >= _gift_amount, "Pool: INSUFFICIENT GIFT TOKEN");
    IERC20(gift_token).transfer(msg.sender, _gift_amount);
    //Send gift_token to sender in $amount)

    //Send user gift_token for free
    emit Gift(msg.sender, address(this), _gift_amount, orderId); 
  }

  function depositForTokenV2(
    address token,
    uint256 amount,
    string memory orderId
  ) public {    
    // To check whether token is accepted
    for (uint i = 0; i< tokenAddresses.length; i++){
      address token_address = token;
      bool isSupported = checkTokenAddressExists(token_address);
      require(isSupported == true, "Pool: NOT SUPPORTED TOKEN FOR PAYMENT");
    }

    // get token balance
    uint256 balance = IERC20(token).balanceOf(msg.sender); // check user token balance
    require(balance >= amount, "Pool: INSUFFICIENT_INPUT_AMOUNT");

    // get token allowance
    uint256 allowance = IERC20(token).allowance(
      address(msg.sender),
      address(this)
    ); //owner, spender this: POOL
    require(allowance >= amount, "INSUFFICIENT_ALLOWANCE");

    // check gift_token balance + transfer gift_token from contract to sender
    _sendGiftTokenV2(amount, orderId);

    // compute exchange amount
    // computeExchangeAmount(eInfo, token, amount);

    IERC20(token).transferFrom(msg.sender, address(walletAddress), amount); 

    // emit Events
    emit Deposit(msg.sender, address(walletAddress), amount, orderId);
  }

  // function depositForNativeTokenV2(
  //   uint256 amount,
  //   uint256 orderId
  // ) public payable {
    
  //   // valid amount 
  //   require(msg.value >= amount, "Pool: INSUFFICIENT_AMOUNT_INPUT");
    
  //   // transfer gift_token from contract to sender
  //   _sendGiftToken(amount, msg.sender, orderId);

  //   // transfer token from sender to contract
  //   payable(walletAddress).transfer(amount);

  //   emit Deposit(msg.sender, address(this), amount, orderId);
  // }

  function setGiftTokenPercent(uint256 nominator, uint256 denominator)
    public
    onlyOwner
  {
    _gift_amount_nominator = nominator;
    _gift_amount_denominator = denominator;
  }

  function getGiftTokenPercent()
    public
    view
    onlyOwner
    returns (uint256, uint256)
  {
    return (_gift_amount_nominator, _gift_amount_denominator);
  }

  // Withdraw token from address(this) to new wallet address
  function withdrawBaseToken(address baseToken) public payable onlyOwner {
    uint256 balance = 0;
    if (baseToken == address(0)) {
      // Get token balance 
      balance = address(this).balance;
      payable(walletAddress).transfer(balance);
    } else {
      // Get baseToken balance 
      balance = IERC20(baseToken).balanceOf(address(this));

      IERC20(baseToken).transfer(walletAddress, balance);
    }
    emit Withdraw(address(this), walletAddress, baseToken, balance);
  }

  function withdrawGiftToken() public {
    uint256 balance = IERC20(gift_token).balanceOf(address(this));
    IERC20(gift_token).transfer(walletAddress, balance);
    emit Withdraw(address(this), walletAddress, gift_token, balance);
  }

  // Get Ether balance of this contract
  function balanceOfNativeToken() public view returns (uint256 amount) {
    uint256 balance = address(this).balance;
    return balance;
  }

  // Get specific token balance in this contract
  function balanceOfToken(address token) public view returns (uint256 amount) {
    uint256 balance = IERC20(token).balanceOf(address(this)); //this: Pool contract
    return balance;
  }

  function balanceOfGiftToken() public view returns (uint256 amount) {
    uint256 balance = IERC20(gift_token).balanceOf(address(this));
    return balance;
  }
}