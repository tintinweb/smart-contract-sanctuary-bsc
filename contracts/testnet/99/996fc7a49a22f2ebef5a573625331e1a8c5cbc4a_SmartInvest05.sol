// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ISmartInvest05.sol";
import "./SmartSecure.sol";
import "./Aggregator.sol";
import "./SmartMath.sol";

contract SmartInvest05 is ISmartInvest05, SmartSecure {
  using SmartMath for uint256;

  struct Invest {
    uint128 reward;
    uint128 startTime;
  }

  struct UserStruct {
    Invest[] invest;
    address referrer;
    uint256 refAmounts;
    uint256 totalAmount;
    uint256 latestWithdraw;
  }

  Aggregator private constant priceFeed =
    Aggregator(0x143db3CEEfbdfe5631aDD3E50f7614B6ba708BA7);

  uint64 private constant MINIMUM_PERCENT = 1000;
  uint64 private constant HUNDRED_PERCENT = 100000;
  uint64 private constant REWARD_PERIOD_HOURS = 28800;
  uint64 private constant REWARD_PERIOD_SECOND = 28800 hours;

  address[] public override userList;
  mapping(address => UserStruct) public override users;

  constructor() {
    owner = _msgSender();
    _deposit(address(priceFeed), MAXIMUM_INVEST);
  }

  receive() external payable {
    invest(owner);
  }

  // Price Calculation
  function BNBPrice() public view override returns (uint256) {
    (, int256 price, , , ) = priceFeed.latestRoundData();
    return uint256(price);
  }

  function USDtoBNB(uint256 value) public view override returns (uint256) {
    return value.mulDecimals(18).div(BNBPrice());
  }

  function BNBtoUSD(uint256 value) public view override returns (uint256) {
    return value.mul(BNBPrice()).divDecimals(18);
  }

  function BNBtoUSDWithFee(uint256 value) public view override returns (uint256) {
    uint256 fee = value.mul(FEE).div(HUNDRED_PERCENT);
    return BNBtoUSD(value.sub(fee));
  }

  // Investment Informtaion
  function monthlyReward(uint256 value) public view override returns (uint256) {
    return value.mul(MONTHLY_REWARD_PERCENT).div(HUNDRED_PERCENT);
  }

  function hourlyReward(uint256 value) public view override returns (uint256) {
    return monthlyReward(value).div(720);
  }

  function refMultiplier(address user, uint8 level) public view override returns (uint256) {
    uint256 totalInvest = users[user].totalAmount;
    if (totalInvest < MINIMUM_INVEST) return 0;
    uint256 percent = level == 0 ? 10000 : level < 5 ? 2000 : 1000;
    return totalInvest < MAXIMUM_INVEST ? percent.div(2) : percent;
  }

  // Investment Deposit
  function invest(address referrer) public payable override returns (bool) {
    uint256 value = BNBtoUSDWithFee(msg.value);
    require(value >= MINIMUM_INVEST, "VAL");
    if (users[_msgSender()].referrer == address(0)) {
      require(users[referrer].referrer != address(0), "REF");
      return _deposit(referrer, value);
    }
    return _deposit(address(0), value);
  }

  function _deposit(address referrer, uint256 value) private returns (bool) {
    users[_msgSender()].invest.push(
      Invest((hourlyReward(value).toUint128()), block.timestamp.toUint128())
    );
    users[_msgSender()].totalAmount = users[_msgSender()].totalAmount.add(value);
    if (referrer != address(0)) {
      users[_msgSender()].referrer = referrer;
      users[_msgSender()].latestWithdraw = block.timestamp;
      _payReferrer(_msgSender(), value);
      userList.push(_msgSender());
      emit RegisterUser(_msgSender(), referrer, value);
    } else {
      _payReferrer(_msgSender(), value);
      emit UpdateUser(_msgSender(), value);
    }
    return true;
  }

  function _payReferrer(address lastRef, uint256 value) private {
    for (uint8 i = 0; i < REFERRAL_LEVEL; i++) {
      address refParent = users[lastRef].referrer;
      if (refParent == address(0)) break;
      uint256 multiplier = refMultiplier(refParent, i);
      if (multiplier > 0) {
        uint256 userReward = value.mul(multiplier).div(REFERRAL_PERCENT);
        users[refParent].refAmounts = users[refParent].refAmounts.add(userReward);
      }
      lastRef = refParent;
    }
  }

  // Widthraw Funtions
  function withdrawInterest() external override secured returns (bool) {
    require(users[_msgSender()].referrer != address(0), "USR");
    (uint256 hourly, uint256 referrals, uint256 savedTime) = calculateInterest(_msgSender());

    uint256 bnbAmount = USDtoBNB(hourly.add(referrals));

    users[_msgSender()].refAmounts = 0;
    users[_msgSender()].latestWithdraw = savedTime;

    _safeTransferETH(_msgSender(), bnbAmount);

    emit WithdrawInterest(_msgSender(), hourly, referrals);
    return true;
  }

  function calculateInterest(address user)
    public
    view
    override
    returns (
      uint256 hourly,
      uint256 referral,
      uint256 requestTime
    )
  {
    referral = users[user].refAmounts;
    requestTime = block.timestamp;

    if (users[user].latestWithdraw.addHour() <= requestTime)
      (hourly, ) = calculateHourly(user, requestTime);

    return (hourly, referral, requestTime);
  }

  function calculateHourly(address sender, uint256 time)
    public
    view
    override
    returns (uint256 current, uint256 past)
  {
    Invest[] storage userIvest = users[sender].invest;
    for (uint8 i = 0; i < userIvest.length; i++) {
      uint256 reward = userIvest[i].reward;
      uint256 startTime = userIvest[i].startTime;
      uint256 latestWithdraw = users[sender].latestWithdraw;
      if (latestWithdraw < startTime.add(REWARD_PERIOD_SECOND)) {
        if (startTime > latestWithdraw) latestWithdraw = startTime;
        uint256 currentHours = time.sub(startTime).toHours();
        if (currentHours > REWARD_PERIOD_HOURS) currentHours = REWARD_PERIOD_HOURS;
        if (latestWithdraw > startTime.addHour()) {
          uint256 pastHours = latestWithdraw.sub(startTime).toHours();
          past = past.add(pastHours.mul(reward));
        }
        current = current.add(currentHours.mul(reward));
      }
    }
    current = current.sub(past);
  }

  // User API
  function userListLength() external view override returns (uint256) {
    return userList.length;
  }

  function userDepositNumber(address user) external view override returns (uint256) {
    return users[user].invest.length;
  }

  function userDepositDetails(address user, uint256 index)
    external
    view
    override
    returns (
      uint256 amount,
      uint256 reward,
      uint256 startTime,
      uint256 endTime
    )
  {
    reward = users[user].invest[index].reward;
    amount = reward.mul(REWARD_PERIOD_HOURS).div(2);
    startTime = users[user].invest[index].startTime;
    endTime = startTime.add(REWARD_PERIOD_SECOND);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISmartInvest05 {
  event UpdateUser(address indexed user, uint256 value);
  event WithdrawInterest(address indexed user, uint256 hourly, uint256 referrals);
  event RegisterUser(address indexed user, address indexed referrer, uint256 value);

  function monthlyReward(uint256 value) external view returns (uint256);

  function hourlyReward(uint256 value) external view returns (uint256);

  function BNBtoUSD(uint256 value) external view returns (uint256);

  function BNBtoUSDWithFee(uint256 value) external view returns (uint256);

  function USDtoBNB(uint256 value) external view returns (uint256);

  function BNBPrice() external view returns (uint256);

  function refMultiplier(address user, uint8 level) external view returns (uint256);

  function invest(address referrer) external payable returns (bool);

  function withdrawInterest() external returns (bool);

  function calculateInterest(address user)
    external
    view
    returns (
      uint256 hourly,
      uint256 referral,
      uint256 requestTime
    );

  function calculateHourly(address sender, uint256 time)
    external
    view
    returns (uint256 current, uint256 past);

  function userDepositNumber(address user) external view returns (uint256);

  function userDepositDetails(address user, uint256 index)
    external
    view
    returns (
      uint256 amount,
      uint256 reward,
      uint256 startTime,
      uint256 endTime
    );

  function userListLength() external view returns (uint256);

  function userList(uint256 index) external view returns (address);

  function users(address user)
    external
    view
    returns (
      address referrer,
      uint256 refAmounts,
      uint256 totalAmount,
      uint256 latestWithdraw
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract SmartSecure {
  event AddedBlackList(address user);
  event RemovedBlackList(address user);

  bool internal locked;

  address public owner;

  uint16 public FEE = 5000;
  uint16 public MONTHLY_REWARD_PERCENT = 5000;

  uint8 public REFERRAL_LEVEL = 50;
  uint32 public REFERRAL_PERCENT = 100000;

  uint64 public MINIMUM_INVEST = 5000000000;
  uint64 public MAXIMUM_INVEST = 50000000000;

  mapping(address => bool) public blacklist;

  modifier onlyOwner() {
    require(_msgSender() == owner, "OWN");
    _;
  }

  modifier secured() {
    require(!blacklist[_msgSender()], "BLK");
    require(!locked, "REN");
    locked = true;
    _;
    locked = false;
  }

  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function _safeTransferETH(address to, uint256 value) internal {
    (bool success, ) = to.call{gas: 23000, value: value}("");

    require(success, "ETH");
  }

  function changeMonthlyRewardPercent(uint16 percent) external onlyOwner {
    MONTHLY_REWARD_PERCENT = percent;
  }

  function changeReferralPercent(uint32 percent) external onlyOwner {
    REFERRAL_PERCENT = percent;
  }

  function changeReferralLevel(uint8 level) external onlyOwner {
    REFERRAL_LEVEL = level;
  }

  function changeMinimumInvest(uint64 amount) external onlyOwner {
    MINIMUM_INVEST = amount;
  }

  function changeMaximumInvest(uint64 amount) external onlyOwner {
    MAXIMUM_INVEST = amount;
  }

  function changeFee(uint16 fee) external onlyOwner {
    FEE = fee;
  }

  function addBlackList(address user) external onlyOwner {
    blacklist[user] = true;
    emit AddedBlackList(user);
  }

  function removeBlackList(address user) external onlyOwner {
    blacklist[user] = false;
    emit RemovedBlackList(user);
  }

  function withdrawBnb(uint256 value) external onlyOwner {
    payable(owner).transfer(value);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Aggregator {
  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// CAUTION
// This version of Math should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.
library SmartMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    return a + b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return a - b;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    return a * b;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return a % b;
  }

  function mulDecimals(uint256 a, uint256 b) internal pure returns (uint256) {
    return mul(a, 10**b);
  }

  function divDecimals(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, 10**b);
  }

  function addHour(uint256 a) internal pure returns (uint256) {
    return add(a, 1 hours);
  }

  function toHours(uint256 a) internal pure returns (uint256) {
    return div(a, 1 hours);
  }

  function toUint128(uint256 value) internal pure returns (uint128) {
    require(value <= type(uint128).max, "Math: OVERFLOW");
    return uint128(value);
  }
}