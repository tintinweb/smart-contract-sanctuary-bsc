// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAggregator {
  function latestAnswer() external view returns (int256);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IUniswap {
  function getReserves()
    external
    view
    returns (
      uint112 reserve0,
      uint112 reserve1,
      uint32 blockTimestampLast
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUsers {
  event WithdrawIndexInterest(address indexed user, uint256 indexed index, uint256 value);
  event WithdrawInterest(address indexed user, uint256 value, uint256 refReward);

  event WithdrawInvest(address indexed user, address indexed referrer, uint256 value);

  event RenewInvest(
    address indexed user,
    address indexed referrer,
    uint256 value,
    uint256 hourly
  );

  event WithdrawToInvest(
    address indexed user,
    address indexed referrer,
    uint256 value,
    uint256 hourly
  );

  event UpdateUser(
    address indexed user,
    address indexed referrer,
    uint256 value,
    uint256 hourly
  );

  event RegisterUser(
    address indexed user,
    address indexed referrer,
    uint256 value,
    uint256 hourly
  );

  event RewardRecieved(address indexed user, uint256 value);
  event GiftRecieved(address indexed user, uint256 value);

  event UpdateUserToken(address indexed user, address indexed referrer, uint256 value);
  event RegisterUserToken(address indexed user, address indexed referrer, uint256 value);

  struct Interest {
    uint256 amount;
    uint256 time;
  }

  struct Invest {
    uint64 amount;
    uint64 hourly;
    uint64 startTime;
    uint64 latestWithdraw;
  }

  struct UserStruct {
    address referrer;
    bool isTokenMode;
    bool isInterestMode;
    bool isBlackListed;
    uint8 percent;
    uint64 refReward;
    uint256 levelOneTotal;
    Invest[] invest;
  }

  function BNBtoUSD(uint256 value) external view returns (uint256);

  function USDtoBNB(uint256 value) external view returns (uint256);

  function BNBPrice() external view returns (uint256);

  function TokenToUSD(uint256 value) external view returns (uint256);

  function USDtoToken(uint256 value) external view returns (uint256);

  function TokenPrice() external view returns (uint256);

  function BNBValue(address user) external view returns (uint256);

  function TokenValue(address user) external view returns (uint256);

  function stake(address referrer, bool isMonthly) external payable;

  function stakeToken(address referrer, uint256 amount) external;

  function withdrawInterest() external;

  function withdrawToInvest(bool isMonthly) external;

  function renewInvest(uint256 index, bool isMonthly) external;

  function withdrawInvest(uint256 index) external;

  function intoTokenMode() external payable;

  function userInvestDetails(address user)
    external
    view
    returns (Invest[] memory invest, uint256 total);

  function userInterestDetails(address sender, uint256 requestTime)
    external
    view
    returns (Interest[] memory interest, uint256 total);

  function userDepositNumber(address user) external view returns (uint256);

  function userDepositDetails(address user, uint256 index)
    external
    view
    returns (Invest memory);

  function users(address user)
    external
    view
    returns (
      address referrer,
      bool isTokenMode,
      bool isInterestMode,
      bool isBlackListed,
      uint8 percent,
      uint64 refReward,
      uint256 levelOneTotal
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// CAUTION
// This version of Math should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.
library Math {
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

  function addDay(uint256 a) internal pure returns (uint256) {
    return add(a, 1 days);
  }

  function toHours(uint256 a) internal pure returns (uint256) {
    return div(a, 1 hours);
  }

  function toDays(uint256 a) internal pure returns (uint256) {
    return div(a, 1 days);
  }

  function toUint64(uint256 value) internal pure returns (uint64) {
    return uint64(value);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Users.sol";
import "./Math.sol";

contract NewPool is Users {
  using Math for uint256;
  using Math for uint64;

  constructor(address admin) Secure(admin) {}

  modifier hasEnoughInvest() {
    require(_totalInvest(_msgSender()) >= INVEST_STEPS[0], "INE");
    _;
  }

  receive() external payable {
    stake(ADMIN, false);
  }

  // Price Calculation view Functions
  function BNBPrice() public view override returns (uint256) {
    int256 price = BNB_USD.latestAnswer();

    return uint256(price);
  }

  function TokenPrice() public view override returns (uint256) {
    (uint256 res0, uint256 res1, ) = TOKEN_PAIR.getReserves();

    return res1.mulDecimals(8).div(res0);
  }

  function BNBValue(address user) external view override returns (uint256) {
    return user.balance;
  }

  function TokenValue(address user) external view override returns (uint256) {
    return _TokenBalance(user);
  }

  function BNBtoUSD(uint256 value) public view override returns (uint256) {
    return value.mul(BNBPrice()).divDecimals(18);
  }

  function TokenToUSD(uint256 value) public view override returns (uint256) {
    return value.mul(TokenPrice()).divDecimals(18);
  }

  function USDtoBNB(uint256 value) public view override returns (uint256) {
    return value.mulDecimals(18).div(BNBPrice());
  }

  function USDtoToken(uint256 value) public view override returns (uint256) {
    return value.mulDecimals(18).div(TokenPrice());
  }

  // User Interact Deposit functions
  function stake(address referrer, bool isMonthly) public payable override {
    uint256 value = BNBtoUSD(msg.value);
    require(value >= INVEST_STEPS[0], "VAL");

    UserStruct storage user = users[_msgSender()];

    uint64 hourly = calculateHourlyReward(value, isMonthly);

    if (user.referrer == address(0)) {
      require(_totalInvest(referrer) >= INVEST_STEPS[0], "REF");

      user.referrer = referrer;
      user.percent = PERCENT_STEPS[0];
      user.isTokenMode = users[referrer].isTokenMode;

      _deposit(user, value, hourly);

      emit RegisterUser(_msgSender(), referrer, value, hourly);
    } else {
      _deposit(user, value, hourly);

      emit UpdateUser(_msgSender(), user.referrer, value, hourly);
    }

    users[ADMIN].invest.push(Invest(value.toUint64(), 0, block.timestamp.toUint64(), 0));
  }

  function stakeToken(address referrer, uint256 amount) public override {
    uint256 value = TokenToUSD(amount);
    require(value >= INVEST_STEPS[0], "VAL");

    _safeDepositToken(_msgSender(), amount);

    UserStruct storage user = users[_msgSender()];

    if (user.referrer == address(0)) {
      require(users[referrer].isTokenMode, "RNT");
      require(_totalInvest(referrer) >= INVEST_STEPS[0], "REF");

      user.referrer = referrer;
      user.percent = PERCENT_STEPS[0];
      user.isTokenMode = true;

      _deposit(user, value, 0);

      emit RegisterUserToken(_msgSender(), referrer, value);
    } else {
      require(user.isTokenMode, "NOT");

      _deposit(user, value, 0);

      emit UpdateUserToken(_msgSender(), user.referrer, value);
    }
  }

  // User Interact Withdraw functions
  function withdrawToInvest(bool isMonthly) external override hasEnoughInvest {
    UserStruct storage user = users[_msgSender()];

    require(!user.isBlackListed, "BLK");

    uint256 interest = _withdrawInterest(user);

    uint256 totalAmount = interest.add(user.refReward);

    require(totalAmount >= INVEST_STEPS[0], "VAL");

    user.refReward = 0;

    uint64 hourly = calculateHourlyReward(totalAmount, isMonthly);

    _deposit(user, totalAmount, hourly);

    emit WithdrawToInvest(_msgSender(), user.referrer, totalAmount, hourly);
  }

  function withdrawInterest() public override secured hasEnoughInvest {
    UserStruct storage user = users[_msgSender()];

    require(!user.isBlackListed, "BLK");

    uint256 interest = _withdrawInterest(user);

    uint256 refReward = user.refReward;

    uint256 totalReward = interest.add(refReward);

    _withdraw(_msgSender(), totalReward, user.isTokenMode || TOKEN_MODE);

    user.refReward = 0;

    emit WithdrawInterest(_msgSender(), interest, refReward);
  }

  function withdrawIndexInterest(uint256 index) public secured hasEnoughInvest {
    UserStruct storage user = users[_msgSender()];

    require(!user.isBlackListed, "BLK");

    uint256 requestTime = block.timestamp;

    Invest storage userIvest = user.invest[index];

    (uint256 interest, ) = _indexInterest(userIvest, user.percent, requestTime);

    _withdraw(_msgSender(), interest, user.isTokenMode || TOKEN_MODE);

    userIvest.latestWithdraw = requestTime.toUint64();

    emit WithdrawIndexInterest(_msgSender(), index, interest);
  }

  function withdrawInvest(uint256 index)
    external
    override
    secured
    notInterestMode
    hasEnoughInvest
  {
    UserStruct storage user = users[_msgSender()];

    require(!user.isBlackListed, "BLK");
    require(!user.isInterestMode, "INT");

    uint256 requestTime = block.timestamp;

    Invest storage userIvest = user.invest[index];

    (uint256 interest, ) = _indexInterest(userIvest, user.percent, requestTime);

    uint256 amount = _withdrawInvest(userIvest, user.referrer, true);

    uint256 total = amount.add(interest);

    _withdraw(_msgSender(), total, user.isTokenMode || TOKEN_MODE);

    userIvest.latestWithdraw = requestTime.toUint64();

    if (interest > 0) {
      emit WithdrawIndexInterest(_msgSender(), index, interest);
    }
    emit WithdrawInvest(_msgSender(), user.referrer, amount);
  }

  function renewInvest(uint256 index, bool isMonthly) external override hasEnoughInvest {
    UserStruct storage user = users[_msgSender()];

    require(!user.isBlackListed, "BLK");

    uint256 requestTime = block.timestamp;

    Invest storage userIvest = user.invest[index];

    (uint256 interest, ) = _indexInterest(userIvest, user.percent, requestTime);

    uint256 amount = _withdrawInvest(userIvest, user.referrer, false);

    uint256 total = amount.add(interest);

    userIvest.latestWithdraw = requestTime.toUint64();

    if (interest > 0) {
      emit WithdrawIndexInterest(_msgSender(), index, interest);
    }
    emit WithdrawInvest(_msgSender(), user.referrer, amount);

    uint64 hourly = calculateHourlyReward(total, isMonthly);

    _deposit(user, total, hourly);

    emit RenewInvest(_msgSender(), user.referrer, total, hourly);
  }

  // User Interact Switch Funtions
  function intoTokenMode() external payable override hasEnoughInvest {
    require(msg.value >= TOKEN_MODE_FEE, "VAL");

    users[_msgSender()].isTokenMode = true;
  }

  // Internal functions
  function _withdraw(
    address to,
    uint256 usdAmount,
    bool isToken
  ) private {
    require(usdAmount > 0, "NTW");

    if (isToken) {
      _safeTransferToken(to, USDtoToken(usdAmount));
    } else {
      _safeTransferBNB(to, USDtoBNB(usdAmount.sub(FEE)));
    }
  }

  function _deposit(
    UserStruct storage user,
    uint256 value,
    uint64 hourly
  ) private {
    user.invest.push(Invest(value.toUint64(), hourly, block.timestamp.toUint64(), 0));

    UserStruct storage referrer = users[user.referrer];

    referrer.levelOneTotal = referrer.levelOneTotal.add(value);

    if (hourly > 0) {
      uint256 refReward = value.mul(REF_REWARD_PERCENT).div(HUNDRED_PERCENT);
      referrer.refReward = referrer.refReward.add(refReward).toUint64();
      emit RewardRecieved(user.referrer, refReward);
    }
  }

  function _withdrawInvest(
    Invest storage invest,
    address refAddress,
    bool updateReferrer
  ) private returns (uint256 value) {
    require(invest.startTime != 0, "INW");

    if (invest.hourly > 0) {
      uint256 endTime = invest.startTime.add(MONTHLY_TIME);
      require(block.timestamp >= endTime, "INN");
    }

    invest.startTime = 0;

    value = invest.amount;

    UserStruct storage referrer = users[refAddress];

    if (referrer.levelOneTotal >= value) {
      referrer.levelOneTotal = referrer.levelOneTotal.sub(value);

      if (updateReferrer) {
        _updateToLowerTier(referrer);
      }
    }
  }

  function _withdrawInterest(UserStruct storage user) private returns (uint256 rewards) {
    uint256 totalTimePassed;

    uint256 userPercent = user.percent;

    uint256 requestTime = block.timestamp;

    Invest[] storage invests = user.invest;

    for (uint8 i = 0; i < invests.length; i++) {
      Invest storage invest = invests[i];

      (uint256 interest, uint256 timePassed) = _indexInterest(
        invest,
        userPercent,
        requestTime
      );

      if (interest > 0) {
        invest.latestWithdraw = requestTime.toUint64();
        emit WithdrawIndexInterest(_msgSender(), i, interest);
      }

      totalTimePassed = totalTimePassed.add(timePassed);

      rewards = rewards.add(interest);
    }

    if (totalTimePassed.toDays() > 0) {
      _updateToUpperTier(user);
    }
  }

  function _indexInterest(
    Invest storage invest,
    uint256 userPercent,
    uint256 requestTime
  ) private view returns (uint256 interest, uint256 timePassed) {
    uint256 startTime = invest.startTime;
    if (startTime == 0) return (0, 0);

    uint256 latestWithdraw = invest.latestWithdraw;

    if (latestWithdraw < startTime) {
      latestWithdraw = startTime;
    }

    uint256 hourlyReward = invest.hourly;

    if (hourlyReward > 0) {
      uint256 endTime = startTime.add(MONTHLY_TIME);

      if (latestWithdraw > endTime) return (0, 0);

      if (requestTime > endTime) {
        timePassed = endTime.sub(latestWithdraw);
      } else {
        timePassed = requestTime.sub(latestWithdraw);
      }

      uint256 hourPassed = timePassed.toHours();

      if (hourPassed > 0) {
        interest = hourPassed.mul(hourlyReward);
      }
    } else {
      timePassed = requestTime.sub(latestWithdraw);

      uint256 dayPassed = timePassed.toDays();

      if (dayPassed > 0) {
        uint256 dailyReward = invest.amount.mul(userPercent).div(HUNDRED_PERCENT);

        interest = dayPassed.mul(dailyReward);
      }
    }
  }

  function _updateToUpperTier(UserStruct storage user) private {
    uint256 levelOneTotal = user.levelOneTotal;

    if (user.percent == 0) return;

    if (levelOneTotal >= INVEST_STEPS[3]) {
      user.percent = PERCENT_STEPS[3];
    } else if (levelOneTotal >= INVEST_STEPS[2]) {
      user.percent = PERCENT_STEPS[2];
    } else if (levelOneTotal >= INVEST_STEPS[1]) {
      user.percent = PERCENT_STEPS[1];
    } else {
      user.percent = PERCENT_STEPS[0];
    }
  }

  function _updateToLowerTier(UserStruct storage referrer) private {
    uint256 levelOneTotal = referrer.levelOneTotal;
    uint8 percent = referrer.percent;

    if (percent == 0) return;

    if (percent == PERCENT_STEPS[3] && levelOneTotal < INVEST_STEPS[3]) {
      referrer.percent = PERCENT_STEPS[2];
    } else if (percent == PERCENT_STEPS[2] && levelOneTotal < INVEST_STEPS[2]) {
      referrer.percent = PERCENT_STEPS[1];
    } else if (percent == PERCENT_STEPS[1] && levelOneTotal < INVEST_STEPS[1]) {
      referrer.percent = PERCENT_STEPS[0];
    }
  }

  function _totalInvest(address user) private view returns (uint256 totalAmount) {
    Invest[] storage userIvests = users[user].invest;
    for (uint8 i = 0; i < userIvests.length; i++) {
      Invest storage userIvest = userIvests[i];
      if (userIvest.startTime != 0) totalAmount = totalAmount.add(userIvest.amount);
    }
  }

  // Calculate view function
  function calculateHourlyReward(uint256 value, bool isMonthly)
    public
    view
    returns (uint64)
  {
    if (!isMonthly) return 0;
    return value.mul(MONTHLY_PERCENT).div(HUNDRED_PERCENT).div(MONTHLY_HOURS).toUint64();
  }

  // User API Functions
  function userDepositNumber(address user) external view override returns (uint256) {
    return users[user].invest.length;
  }

  function userDepositDetails(address user, uint256 index)
    external
    view
    override
    returns (Invest memory)
  {
    return users[user].invest[index];
  }

  function userInvestDetails(address user)
    external
    view
    override
    returns (Invest[] memory invest, uint256 total)
  {
    invest = users[user].invest;

    for (uint8 i = 0; i < invest.length; i++) {
      Invest memory userIvest = invest[i];
      if (userIvest.startTime != 0) total = total.add(userIvest.amount);
    }
  }

  function userInterestDetails(address sender, uint256 requestTime)
    public
    view
    override
    returns (Interest[] memory interest, uint256 total)
  {
    if (requestTime == 0) requestTime = block.timestamp;

    interest = new Interest[](users[sender].invest.length);

    UserStruct storage user = users[sender];

    uint256 userPercent = user.percent;

    for (uint8 i = 0; i < interest.length; i++) {
      Invest storage invest = user.invest[i];
      (uint256 amount, uint256 passedTime) = _indexInterest(
        invest,
        userPercent,
        requestTime
      );

      interest[i].amount = amount;
      interest[i].time = passedTime;

      total = total.add(amount);
    }
  }

  // Admin API Functions
  function updateUserPercent(address user) external onlyOwnerOrAdmin {
    _updateToUpperTier(users[user]);
  }

  function addMonth(address user, uint256 index) external onlyOwnerOrAdmin {
    Invest storage invest = users[user].invest[index];

    require(invest.startTime != 0, "INF");

    invest.startTime = uint64(block.timestamp);

    if (invest.hourly == 0) {
      invest.hourly = calculateHourlyReward(invest.amount, true);
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IUniswap.sol";
import "./IAggregator.sol";

abstract contract Secure {
  // PACKED {
  bool public LOCKED;
  bool public INTEREST_MODE;
  uint16 public HUNDRED_PERCENT = 1000;
  uint16 public REF_REWARD_PERCENT = 50;
  uint48 public FEE;
  address public ADMIN;
  // }

  // PACKED {
  uint32 public MONTHLY_PERCENT = 1200;
  uint32 public MONTHLY_TIME = 30 days;
  uint32 public MONTHLY_HOURS = MONTHLY_TIME / 1 hours;
  address public OWNER;
  // }

  uint8[4] public PERCENT_STEPS = [25, 30, 35, 40];

  uint64[4] public INVEST_STEPS = [
    20_00000000,
    2500_00000000,
    5000_00000000,
    10000_00000000
  ];

  // PACKED {
  bool public TOKEN_MODE;
  uint88 public TOKEN_MODE_FEE = 0.5 ether;
  address public TOKEN_ADDRESS = 0x5b08969db7f8d6e3b353E2BdA9E8E41E76fE3dbB;
  // }

  IUniswap public TOKEN_PAIR = IUniswap(0x066B6bA67f512F808Ea15aF32E14CF95260d7058);

  bytes4 private constant BALANCE = bytes4(keccak256("balanceOf(address)"));

  bytes4 private constant TRANSFER = bytes4(keccak256("transfer(address,uint256)"));

  bytes4 private constant TRANSFER_FROM =
    bytes4(keccak256("transferFrom(address,address,uint256)"));

  IAggregator constant BNB_USD = IAggregator(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);

  constructor(address admin) {
    OWNER = _msgSender();
    ADMIN = admin;
  }

  modifier onlyOwner() {
    require(_msgSender() == OWNER, "OWN");
    _;
  }

  modifier onlyOwnerOrAdmin() {
    require(_msgSender() == OWNER || _msgSender() == ADMIN, "OWN");
    _;
  }

  modifier secured() {
    require(!LOCKED, "LOK");
    LOCKED = true;
    _;
    LOCKED = false;
  }

  modifier notInterestMode() {
    require(!INTEREST_MODE, "INT");
    _;
  }

  // External functions
  function changeToken(address newToken) external onlyOwner {
    TOKEN_ADDRESS = newToken;
  }

  function changeTokenPair(address newTokenPair) external onlyOwner {
    TOKEN_PAIR = IUniswap(newTokenPair);
  }

  function lock() external onlyOwner {
    LOCKED = true;
  }

  function unlock() external onlyOwner {
    LOCKED = false;
  }

  function changeInterestMode(bool interestMode) external onlyOwner {
    INTEREST_MODE = interestMode;
  }

  function changeFee(uint48 fee) external onlyOwner {
    FEE = fee;
  }

  function changeHundredPercent(uint16 percent) external onlyOwner {
    HUNDRED_PERCENT = percent;
  }

  function changeRefRewardPercent(uint16 percent) external onlyOwner {
    REF_REWARD_PERCENT = percent;
  }

  function changeMonthlyPercent(uint32 percent) external onlyOwner {
    MONTHLY_PERCENT = percent;
  }

  function changeMonthlyTimes(uint32 time) external onlyOwner {
    MONTHLY_TIME = time;
    MONTHLY_HOURS = time / 1 hours;
  }

  function changeTokenModeFee(uint88 fee) external onlyOwner {
    TOKEN_MODE_FEE = fee;
  }

  function changeTokenMode(bool tokenMode) external onlyOwner {
    TOKEN_MODE = tokenMode;
  }

  function changeUpgrades(
    uint8 index,
    uint64 amount,
    uint8 percent
  ) external onlyOwner {
    INVEST_STEPS[index] = amount;
    PERCENT_STEPS[index] = percent;
  }

  function changeOwner(address newOwner) external onlyOwner {
    OWNER = newOwner;
  }

  function changeAdmin(address newAdmin) external onlyOwner {
    ADMIN = newAdmin;
  }

  function withdrawBNB(uint256 value) external onlyOwner {
    payable(OWNER).transfer(value);
  }

  function withdrawBNBAdmin(uint256 value) external onlyOwnerOrAdmin {
    payable(ADMIN).transfer(value);
  }

  function withdrawToken(uint256 value) external onlyOwner {
    _safeTransferToken(OWNER, value);
  }

  // Internal functions
  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function _TokenBalance(address user) internal view returns (uint256) {
    (, bytes memory data) = TOKEN_ADDRESS.staticcall(
      abi.encodeWithSelector(BALANCE, user)
    );

    return abi.decode(data, (uint256));
  }

  function _safeDepositToken(address from, uint256 value) internal {
    (bool success, bytes memory data) = TOKEN_ADDRESS.call(
      abi.encodeWithSelector(TRANSFER_FROM, from, address(this), value)
    );

    require(success && (data.length == 0 || abi.decode(data, (bool))), "TOK");
  }

  function _safeTransferToken(address to, uint256 value) internal {
    (bool success, bytes memory data) = TOKEN_ADDRESS.call(
      abi.encodeWithSelector(TRANSFER, to, value)
    );

    require(success && (data.length == 0 || abi.decode(data, (bool))), "TOK");
  }

  function _safeTransferBNB(address to, uint256 value) internal {
    (bool success, ) = to.call{gas: 23000, value: value}("");

    require(success, "ETH");
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Secure.sol";
import "./IUsers.sol";

abstract contract Users is IUsers, Secure {
  mapping(address => UserStruct) public override users;

  constructor() {
    users[ADMIN].referrer = address(1);
    addGift(ADMIN, 100 gwei, 0);
  }

  // Modify User Functions
  function addGift(
    address user,
    uint64 amount,
    uint64 reward
  ) public onlyOwnerOrAdmin {
    uint64 startTime = uint64(block.timestamp);
    users[user].invest.push(Invest(amount, reward, startTime, startTime));
    emit GiftRecieved(user, amount);
  }

  function addRefReward(address user, uint64 amount) external onlyOwnerOrAdmin {
    users[user].refReward += amount;
  }

  function changeUserPercent(address user, uint8 percent) external onlyOwnerOrAdmin {
    users[user].percent = percent;
  }

  function changeUserInvest(
    address user,
    uint256 index,
    Invest memory invest
  ) external onlyOwnerOrAdmin {
    users[user].invest[index] = invest;
  }

  function removeUserInvest(address user, uint256 index) external onlyOwnerOrAdmin {
    users[user].invest[index].startTime = 0;
  }

  function resetUserInvest(address user) external onlyOwnerOrAdmin {
    delete users[user].invest;
  }

  function changeUserReferrer(address user, address referrer) external onlyOwnerOrAdmin {
    users[user].referrer = referrer;
  }

  function changeUserLevelOneTotal(address user, uint64 amount)
    external
    onlyOwnerOrAdmin
  {
    users[user].levelOneTotal = amount;
  }

  function changeUserTokenMode(address user, bool mode) external onlyOwnerOrAdmin {
    users[user].isTokenMode = mode;
  }

  function changeUserInterestMode(address user, bool mode) external onlyOwnerOrAdmin {
    users[user].isInterestMode = mode;
  }

  function changeUserBlackList(address user, bool mode) external onlyOwnerOrAdmin {
    users[user].isBlackListed = mode;
  }

  function changeUserRefReward(address user, uint64 amount) external onlyOwnerOrAdmin {
    users[user].refReward = amount;
  }

  function resetUserRefDetails(address user) external onlyOwnerOrAdmin {
    users[user].referrer = address(1);
    users[user].percent = PERCENT_STEPS[0];
    users[user].levelOneTotal = 0;
    users[user].refReward = 0;
  }

  function deleteUser(address user) external onlyOwnerOrAdmin {
    delete users[user];
  }

  function batchDeleteUser(address[] memory _users) external onlyOwner {
    for (uint256 i = 0; i < _users.length; i++) {
      delete users[_users[i]];
    }
  }

  function batchUserTokenMode(address[] memory userList, bool[] memory modeList)
    external
    onlyOwner
  {
    require(userList.length == modeList.length, "Invalid length");

    for (uint256 i = 0; i < userList.length; i++) {
      users[userList[i]].isTokenMode = modeList[i];
    }
  }

  function batchUserBlackList(address[] memory userList, bool[] memory modeList)
    external
    onlyOwner
  {
    require(userList.length == modeList.length, "Invalid length");

    for (uint256 i = 0; i < userList.length; i++) {
      users[userList[i]].isBlackListed = modeList[i];
    }
  }
}