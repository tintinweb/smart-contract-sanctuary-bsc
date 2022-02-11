/**
 *Submitted for verification at BscScan.com on 2022-01-18
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath: addition overflow');

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, 'SafeMath: subtraction overflow');
  }

  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, 'SafeMath: multiplication overflow');

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, 'SafeMath: division by zero');
  }

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    return c;
  }
}

library SafeMathInt {
  int256 private constant MIN_INT256 = int256(1) << 255;
  int256 private constant MAX_INT256 = ~(int256(1) << 255);

  function mul(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a * b;

    require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
    require((b == 0) || (c / b == a));
    return c;
  }

  function div(int256 a, int256 b) internal pure returns (int256) {
    require(b != -1 || a != MIN_INT256);

    return a / b;
  }

  function sub(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a - b;
    require((b >= 0 && c <= a) || (b < 0 && c > a));
    return c;
  }

  function add(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a + b;
    require((b >= 0 && c >= a) || (b < 0 && c < a));
    return c;
  }

  function abs(int256 a) internal pure returns (int256) {
    require(a != MIN_INT256);
    return a < 0 ? -a : a;
  }
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
  /**
   * @dev Emitted when the pause is triggered by `account`.
   */
  event Paused(address account);

  /**
   * @dev Emitted when the pause is lifted by `account`.
   */
  event Unpaused(address account);

  bool private _paused;

  /**
   * @dev Initializes the contract in unpaused state.
   */
  constructor() {
    _paused = false;
  }

  /**
   * @dev Returns true if the contract is paused, and false otherwise.
   */
  function paused() public view virtual returns (bool) {
    return _paused;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   *
   * Requirements:
   *
   * - The contract must not be paused.
   */
  modifier whenNotPaused() {
    require(!paused(), 'Pausable: paused');
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   *
   * Requirements:
   *
   * - The contract must be paused.
   */
  modifier whenPaused() {
    require(paused(), 'Pausable: not paused');
    _;
  }

  /**
   * @dev Triggers stopped state.
   *
   * Requirements:
   *
   * - The contract must not be paused.
   */
  function _pause() internal virtual whenNotPaused {
    _paused = true;
    emit Paused(_msgSender());
  }

  /**
   * @dev Returns to normal state.
   *
   * Requirements:
   *
   * - The contract must be paused.
   */
  function _unpause() internal virtual whenPaused {
    _paused = false;
    emit Unpaused(_msgSender());
  }
}

abstract contract Auth {
  address internal owner;
  mapping(address => bool) internal authorizations;

  constructor(address _owner) {
    owner = _owner;
    authorizations[_owner] = true;
  }

  modifier onlyOwner() {
    require(isOwner(msg.sender), '!OWNER');
    _;
  }

  modifier authorized() {
    require(isAuthorized(msg.sender), '!AUTHORIZED');
    _;
  }

  function authorize(address adr) public onlyOwner {
    authorizations[adr] = true;
  }

  function unauthorize(address adr) public onlyOwner {
    authorizations[adr] = false;
  }

  function isOwner(address account) public view returns (bool) {
    return account == owner;
  }

  function isAuthorized(address adr) public view returns (bool) {
    return authorizations[adr];
  }

  function transferOwnership(address payable adr) public onlyOwner {
    owner = adr;
    authorizations[adr] = true;
    emit OwnershipTransferred(adr);
  }

  event OwnershipTransferred(address owner);
}

// abstract contract Whitelist is Pausable {
//   mapping(address => bool) public whitelist;

//   event WhitelistAdded(address indexed _account);
//   event whitelistRemoved(address indexed _account);

//   modifier ifWhitelisted(address _account) {
//     require(_account != address(0));
//     require(whitelist[_account]);
//     _;
//   }

//   function addWhitelist(address _account) external whenNotPaused onlyOwner {
//     require(_account != address(0));

//     if (!whitelist[_account]) {
//       whitelist[_account] = true;

//       emit WhitelistAdded(_account);
//     }
//   }

//   function removeWhitelist(address _account) external whenNotPaused onlyOwner {
//     require(_account != address(0));
//     if (whitelist[_account]) {
//       whitelist[_account] = false;

//       emit whitelistRemoved(_account);
//     }
//   }
// }

contract PrivateSale is Auth {
  using SafeMath for uint256;
  using SafeMathInt for int256;

  IBEP20 public MambaContract;

  uint256 public totalAmountForPrivateSale = 10000000; //10,000,000
  uint256 public rateMAMPperBNB = 100000; //100,000
  uint256 public etherDenominator = 10**18;
  uint256 public mampDenominator = 10**8;

  uint256 public start_time = 1643673600; //1st Feb 2022
  uint256 public end_time = 1643932800; //3th Feb 2022

  uint256 public min_buy_amount_estimate = 0.1 * 10**18;//fix
  uint256 public max_buy_amount_estimate = 2 * 10**18;

  uint256 public depositedBNB = 0;
  mapping(address => uint256) public contributions;

  event joinedPool(address indexed from, uint256 amount);
  event withdrawn(address indexed from, uint256 rewardAmount);

  constructor(address _mambapad) Auth(msg.sender) {
    MambaContract = IBEP20(_mambapad);
    MambaContract.approve(_mambapad, totalAmountForPrivateSale);
  }

  function joinPool() public payable returns (uint256) {
    require(block.timestamp < start_time, "Can't join pool yet");
    require(block.timestamp > end_time, "Can't join pool more");
    require(msg.value >= min_buy_amount_estimate, "Can't be under min_buy_amount");
    require(msg.value <= max_buy_amount_estimate, "Can't be over max_buy_amount");

    uint256 amountToBuy = (msg.value).div(rateMAMPperBNB);
    require(MambaContract.balanceOf(address(this)) > amountToBuy, 'This pool has no enough Mamp than amountToBuy');
    _claimMamp(amountToBuy);

    contributions[msg.sender] = contributions[msg.sender].add(amountToBuy);
    depositedBNB = depositedBNB.add(msg.value);
    emit joinedPool(msg.sender, msg.value);
    return amountToBuy;                    
  }

  function _claimMamp(uint256 amountToBuy) private {
    if (MambaContract.balanceOf(address(this)) > amountToBuy) {
      MambaContract.transfer(msg.sender, amountToBuy);
    } else MambaContract.transfer(msg.sender, MambaContract.balanceOf(address(this)));

  }

  function withdrawBNB(uint256 _amount, address _to) public onlyOwner {
    uint256 ownerBalance = address(this).balance;
    require(ownerBalance > 0, 'No BNB to withdraw');

    (bool sent, ) = _to.call{value: _amount}('');
    require(sent, 'Transfer failed.');
    emit withdrawn(msg.sender, ownerBalance);
  }

  function withdrawMAMP(uint256 _amount, address _to) public onlyOwner {
    uint256 ownerBalance = MambaContract.balanceOf(address(this));
    require(ownerBalance > 0, 'No MAMP to withdraw');

    MambaContract.transfer(_to, _amount);

    emit withdrawn(msg.sender, ownerBalance);
  }

  function getInfo() public view returns(uint256 mampAmountofContract, uint256 bnbAmountDepositedinContract, uint256 startingTime, uint256 endingTime) {
    mampAmountofContract = MambaContract.balanceOf(address(this));
    bnbAmountDepositedinContract = depositedBNB;
    startingTime = start_time;
    endingTime = end_time;
    return (MambaContract.balanceOf(address(this)),depositedBNB, start_time, end_time);
  }

  function getBalanceofContract() public view returns (uint256) {
    return address(this).balance;
  }

  function getContractMampBalance() public view returns (uint256) {
    require(MambaContract.balanceOf(address(this))>0,"balance is 0");
    return MambaContract.balanceOf(address(this));
  }

  function getContribution(address _contributor) public view returns (uint256) {
    return contributions[_contributor];
  }

  function getDepositedBNB() public view returns (uint256) {
    return depositedBNB;
  }

  function addTotalAmountForPrivateSale(uint256 _addingAmount) public onlyOwner {
    totalAmountForPrivateSale = totalAmountForPrivateSale.add(_addingAmount);
  }

  function setStartTime(uint256 _startTime) public onlyOwner {
    start_time = _startTime;
  }

  function setEndTime(uint256 _endTime) public onlyOwner {
    end_time = _endTime;
  }

  function getStartTime() public view returns (uint256) {
    return start_time;
  }

  function getEndTime() public view returns (uint256) {
    return end_time;
  }
}