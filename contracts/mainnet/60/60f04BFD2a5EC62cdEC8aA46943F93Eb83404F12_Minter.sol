/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

// File: contracts/libs/Ownable.sol

/**
 * SPDX-License-Identifier: MIT
 * Submitted for verification at Etherscan.io on 2021-01-02
 */
pragma solidity 0.5.12;

contract Ownable {
  address internal _owner;

  constructor() public {
    _owner = msg.sender;
  }

  modifier onlySafe() {
    require(msg.sender == _owner);
    _;
  }

  function transferOwnership(address newOwner) public onlySafe {
    _owner = newOwner;
  }
}

// File: contracts/libs/SafeMath.sol

/**
 * SPDX-License-Identifier: MIT
 * Submitted for verification at Etherscan.io on 2021-01-02
 */
pragma solidity 0.5.12;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0 || b == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    assert(a == b * c + (a % b)); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b != 0);
    return a % b;
  }
}

// File: contracts/libs/IBEP20.sol

pragma solidity 0.5.12;

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

// File: contracts/Minter.sol

pragma solidity 0.5.12;



contract BaseDFA is IBEP20 {
  function userMint(address uid, uint256 amount) public returns (bool);
}

contract Minter is Ownable {
  using SafeMath for uint256;

  uint256 internal _datetime;

  BaseDFA internal _DFA;
  address internal _pools;
  address internal _invite;

  struct Order {
    uint256 amount;
    bool isWithdraw;
    uint256 pledge;
    uint256 time;
  }

  struct Invite {
    address uid;
    uint256 time;
  }

  struct User {
    address uid;
    address pid;
    uint256 time;
  }

  mapping(address => Order[]) internal _orders;
  mapping(address => Invite[]) internal _invites;
  mapping(address => User) internal _users;
  mapping(address => mapping(uint256 => uint256)) internal _mintPools;
  mapping(address => uint256) internal _settmentTime;
  mapping(address => uint256) internal _mintTotal;
  mapping(address => uint256) internal _pledgeTotal;
  mapping(address => uint256) internal _bonusTotal;
  mapping(address => uint256) internal _userBonus;
  mapping(uint256 => uint256) internal _interest;

  constructor(
    address dfa,
    address pools,
    address invite,
    uint256 time
  ) public {
    require(dfa != address(0));
    require(pools != address(0));
    require(invite != address(0));
    require(time > 0 && time.add(8 hours).mod(1 days) == 0);

    _register(msg.sender, address(0));
    _register(invite, msg.sender);

    _DFA = BaseDFA(dfa);
    _pools = pools;
    _datetime = time;

    _interest[30] = 15;
    _interest[90] = 20;
    _interest[180] = 30;
    _interest[360] = 40;
  }

  function _register(address uid, address pid) internal {
    _users[uid] = User(uid, pid, block.timestamp);
    _invites[pid].push(Invite(uid, block.timestamp));
  }

  function register(address uid, address pid) public {
    require(!isUser(uid));
    require(isUser(pid));
    _register(uid, pid);
  }

  function register(address pid) public {
    require(!isUser(msg.sender));
    require(isUser(pid));
    _register(msg.sender, pid);
  }

  function isUser(address uid) public view returns (bool) {
    return _users[uid].uid != address(0);
  }

  function getInvite(address uid) public view returns (address) {
    return _users[uid].pid;
  }

  function getUser(address u)
    public
    view
    returns (
      address uid,
      address pid,
      uint256 time
    )
  {
    uid = _users[u].uid;
    pid = _users[u].pid;
    time = _users[u].time;
  }

  function transfer(
    address token,
    address recipient,
    uint256 amount
  ) public onlySafe {
    IBEP20(token).transfer(recipient, amount);
  }

  function pledgeToken(uint256 amount, uint256 day) public {
    _mint();
    address uid = msg.sender;
    require(isUser(uid));
    require(
      amount >= 1e17 && amount <= 100e18,
      "the pledge amount is between 0.1-100"
    );
    require(_DFA.transferFrom(uid, address(this), amount), "transfer fail");
    require(
      day == 30 || day == 90 || day == 180 || day == 360,
      "the pledge date must be one of 30, 90, 180, 360"
    );
    require(_DFA.balanceOf(address(_DFA)) >= 1e18, "insufficient pool amount");

    _mintPools[uid][day] = _mintPools[uid][day].add(amount);
    _orders[uid].push(Order(amount, false, day, _datetime));
    _pledgeTotal[uid] = _pledgeTotal[uid].add(amount);
    if (_settmentTime[uid] == 0) {
      _settmentTime[uid] = _datetime;
    }
  }

  function withdrawToken(uint256 key) public {
    _mint();
    address uid = msg.sender;
    Order memory _order = _orders[uid][key];
    uint256 _days = _order.pledge;

    require(_order.isWithdraw == false);

    if (_DFA.balanceOf(address(_DFA)) > 0) {
      require(_datetime >= _order.time.add(_days.mul(1 days)));
    }

    uint256 _amount = _order.amount;
    require(_DFA.transfer(uid, _amount), "transfer fail");

    _orders[uid][key].isWithdraw = true;
    _mintPools[uid][_days] = _mintPools[uid][_days].sub(_amount);
    _pledgeTotal[uid] = _pledgeTotal[uid].sub(_amount);
  }

  function _mint() internal {
    setDatetime();
    address uid = msg.sender;
    if (_settmentTime[uid] > _datetime) return;

    uint256 _mintAmount = getMintAmount(uid);
    if (_mintAmount == 0) return;

    mint();
  }

  function mint() public {
    setDatetime();
    address uid = msg.sender;
    require(_settmentTime[uid] < _datetime, "not yet settlement time");

    uint256 _mintAmount = getMintAmount(uid);
    require(_mintAmount > 0, "no settlement amount");

    uint256 _mintPool = _DFA.balanceOf(address(_DFA));
    require(_mintPool > 0, "insufficient pool amount");
    if (_mintAmount > _mintPool) {
      _mintAmount = _mintPool;
    }

    uint256 _inviteBonus = _mintAmount.mul(30).div(100);
    _mintAmount = _mintAmount.sub(_inviteBonus);

    _DFA.userMint(uid, _mintAmount);
    _settmentTime[uid] = _datetime;

    _mintTotal[uid] = _mintTotal[uid].add(_mintAmount);

    uint256 _level = 1;
    uint256 _poolBonus;
    uint256 _inviteAmount = _inviteBonus.div(10);
    do {
      uid = getInvite(uid);
      if (uid != address(0)) {
        uint256 _balance = _DFA.balanceOf(uid);
        if (_balance >= 1e18) {
          _DFA.userMint(uid, _inviteAmount);
          _bonusTotal[uid] = _bonusTotal[uid].add(_inviteAmount);
        } else if (uid == _invite) {
          _DFA.userMint(uid, _inviteAmount);
          _bonusTotal[uid] = _bonusTotal[uid].add(_inviteAmount);
        } else {
          _poolBonus = _poolBonus.add(_inviteAmount);
        }
      } else {
        _poolBonus = _poolBonus.add(_inviteAmount);
      }
      _level++;
    } while (_level <= 10);

    if (_poolBonus > 0) {
      _DFA.userMint(_pools, _poolBonus);
    }
  }

  function getMintAmount(address uid) public view returns (uint256) {
    if (_pledgeTotal[uid] == 0) return 0;
    if (_DFA.balanceOf(address(_DFA)) == 0) return 0;
    uint256 _days = _datetime.sub(_settmentTime[uid]).div(1 days);
    uint256 _mintAmount;
    _mintAmount += _mintPools[uid][30].mul(_interest[30]).div(100).div(30).mul(
      _days
    );
    _mintAmount += _mintPools[uid][90].mul(_interest[90]).div(100).div(30).mul(
      _days
    );
    _mintAmount += _mintPools[uid][180]
      .mul(_interest[180])
      .div(100)
      .div(30)
      .mul(_days);
    _mintAmount += _mintPools[uid][360]
      .mul(_interest[360])
      .div(100)
      .div(30)
      .mul(_days);

    return _mintAmount;
  }

  function setDatetime() public {
    uint256 _time = _datetime;
    if (_time.add(1 days) < block.timestamp) {
      do {
        _time = _time.add(1 days);
      } while (_time.add(1 days) < block.timestamp);
      _datetime = _time;
    }
  }

  function setInterest(uint256 day, uint256 rate) public onlySafe {
    require(day == 30 || day == 90 || day == 180 || day == 360);
    require(rate > 0 && rate < 100);
    _interest[day] = rate;
  }

  function getOrders(address uid, uint256 key)
    external
    view
    returns (
      uint256 index,
      uint256 amount,
      bool isWithdraw,
      bool hasWithdraw,
      uint256 pledge,
      uint256 time,
      uint256 total
    )
  {
    total = _orders[uid].length;
    if (total > 0 && key <= total) {
      key = total.sub(key);
      Order memory _order = _orders[uid][key];
      if (total > 0 && total > 0) {
        _order = _orders[uid][key];
      }
      index = key;
      amount = _order.amount;
      isWithdraw = _order.isWithdraw;
      pledge = _order.pledge;
      time = _order.time;

      hasWithdraw =
        _datetime >= _order.time.add(_order.pledge.mul(1 days)) &&
        !isWithdraw;
      if (_DFA.balanceOf(address(_DFA)) <= 1e10) {
        hasWithdraw = true;
      }
    }
  }

  function getSummary(address uid)
    external
    view
    returns (
      uint256 mintAmount,
      uint256 mintTotal,
      uint256 bonusTotal,
      uint256 pledgeTotal,
      uint256 settleTime,
      uint256 datetime,
      uint256 mintDays,
      uint256 mintPools,
      uint256 inviteNum
    )
  {
    mintAmount = getMintAmount(uid);
    mintTotal = _mintTotal[uid];
    bonusTotal = _bonusTotal[uid];
    pledgeTotal = _pledgeTotal[uid];
    settleTime = _settmentTime[uid];
    datetime = _datetime;
    mintPools = _DFA.balanceOf(address(_DFA));
    inviteNum = _invites[uid].length;
    if (_pledgeTotal[uid] > 0) {
      mintDays = _datetime.sub(_settmentTime[uid]).div(1 days);
    }
  }

  function inviteList(address u, uint256 k)
    external
    view
    returns (
      uint256 key,
      address uid,
      uint256 pledge,
      uint256 time,
      uint256 total
    )
  {
    total = _invites[u].length;
    if (total > 0 && key <= total) {
      key = total.sub(k);
      Invite memory invite = _invites[u][key];
      uid = invite.uid;
      pledge = _pledgeTotal[uid];
      time = invite.time;
    }
  }
}