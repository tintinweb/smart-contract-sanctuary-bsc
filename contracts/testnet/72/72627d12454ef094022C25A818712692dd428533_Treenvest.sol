// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Math.sol";
import "./Plan.sol";
import "./IUserData.sol";
import "./ITreenvest.sol";
import "./Aggregator.sol";

contract Treenvest is ITreenvest, Plan {
  using Math for uint256;
  using Math for uint64;

  Aggregator private constant priceFeed =
    Aggregator(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);

  IUserData private constant userData =
    IUserData(0x9E0B4f271456FDf03E96980DDb0648c6C5C9DE76);

  receive() external payable {
    investDaily();
  }

  // Price Calculation
  function BNBPrice() public view override returns (uint256) {
    (, int256 price, , , ) = priceFeed.latestRoundData();
    return uint256(price * 10);
  }

  function USDtoBNB(uint256 value) public view override returns (uint256) {
    return value.mulDecimals(18).div(BNBPrice());
  }

  function BNBtoUSD(uint256 value) public view override returns (uint256) {
    return value.mul(BNBPrice()).divDecimals(18);
  }

  function BNBtoUSDWithFee(uint256 value)
    public
    view
    override
    returns (uint64)
  {
    uint256 fee = value.mul(FEE).div(1000);
    return BNBtoUSD(value.sub(fee)).toUint64();
  }

  function valueWithReward(uint256 value)
    public
    view
    override
    returns (uint64)
  {
    return value.add(value.mul(INVEST_BONUS_PERCENT).div(100)).toUint64();
  }

  // Investment Informtaion
  function calcPercent(uint256 value) public view override returns (uint256) {
    if (value < MINIMUM_INVEST) return 0;
    uint8 index = 0;
    uint256 val = value.divDecimals(8);
    for (uint8 i = 0; i < FIAT.length; i++) {
      if (val >= FIAT[i]) index = i;
    }
    return PERCENTAGE[index];
  }

  function monthlyReward(uint256 value) public view override returns (uint256) {
    uint256 percent = calcPercent(value);
    return value.mul(percent).div(REWARD_MULTIPLIER);
  }

  function hourlyReward(uint256 value) public view override returns (uint256) {
    return monthlyReward(value).div(720);
  }

  function dailyInvestDailyReward(uint256 value)
    public
    view
    override
    returns (uint256)
  {
    return value.mul(DAILY_REWARD_PERCENT).div(REWARD_MULTIPLIER);
  }

  function dailyInvestHourlyReward(uint256 value)
    public
    view
    override
    returns (uint64)
  {
    return dailyInvestDailyReward(value).div(24).toUint64();
  }

  function calcFirstRefValue(address user, uint256 value)
    public
    view
    override
    returns (uint64)
  {
    uint256 refPercent = userData.maxPeriod(user) == REWARD_PERIOD
      ? 10000
      : 5000;
    return value.mul(refPercent).div(REFERRAL_MULTIPLIER).toUint64();
  }

  function calcRefValue(uint256 value) public view override returns (uint64) {
    return value.mul(REFERRAL_PERCENT).div(REFERRAL_MULTIPLIER).toUint64();
  }

  // Investment Deposit
  function investDaily() public payable override returns (uint256) {
    uint256 value = BNBtoUSDWithFee(msg.value);
    require(value >= MINIMUM_INVEST, "TREE::VAL");
    require(
      userData.investment(
        _msgSender(),
        IUserData.Invest(
          value.toUint64(),
          0,
          dailyInvestHourlyReward(value),
          block.timestamp.toUint64()
        )
      ),
      "TREE::INF"
    );
    emit InvestDaily(_msgSender(), value);
    return value;
  }

  function invest3Month(address referrer, uint256 gift)
    public
    payable
    override
    returns (uint256)
  {
    uint256 value = _deposit(referrer, msg.value, REWARD_PERIOD / 2, gift);
    emit Invest3Month(_msgSender(), referrer, value);
    return value;
  }

  function invest6Month(address referrer, uint256 gift)
    public
    payable
    override
    returns (uint256)
  {
    uint256 value = _deposit(referrer, msg.value, REWARD_PERIOD, gift);
    emit Invest6Month(_msgSender(), referrer, value);
    return value;
  }

  function upgradeToMonthly(
    uint256 index,
    uint256 gift,
    bool six
  ) external override returns (bool) {
    (uint256 amount, , , uint256 startTime, uint256 endTime) = userData
      .depositDetail(_msgSender(), index);

    require(endTime <= block.timestamp, "TREE::NEX");

    userData.deleteUserInvestIndex(_msgSender(), index);

    require(
      userData.investment(
        _msgSender(),
        IUserData.Invest(
          amount.toUint64(),
          six ? REWARD_PERIOD : REWARD_PERIOD / 2,
          hourlyReward(amount).toUint64(),
          startTime.toUint64()
        )
      ),
      "TREE::INF"
    );

    if (!userData.exist(_msgSender()))
      userData.register(_msgSender(), owner(), gift);

    emit UpgradeToMonthly(_msgSender(), amount);
    return true;
  }

  function _deposit(
    address _referrer,
    uint256 _value,
    uint32 _period,
    uint256 _gift
  ) private returns (uint64) {
    uint64 value = BNBtoUSDWithFee(_value);
    require(value >= MINIMUM_INVEST, "TREE::VAL");
    require(
      userData.investment(
        _msgSender(),
        IUserData.Invest(
          value,
          _period,
          hourlyReward(value).toUint64(),
          block.timestamp.toUint64()
        )
      ),
      "TREE::INF"
    );
    if (!userData.exist(_msgSender()))
      userData.register(_msgSender(), _referrer, _gift);

    require(_payReferrer(_msgSender(), value), "TREE::FAI");
    return value;
  }

  function _payReferrer(address lastRef, uint64 value) private returns (bool) {
    address refParent = userData.referrer(lastRef);
    if (refParent != address(0)) {
      uint256 levelOneValue = calcFirstRefValue(refParent, value);
      userData.addRefAmount(refParent, levelOneValue);
      uint64 otherLevelValue = calcRefValue(value);
      return userData.payReferrer(refParent, otherLevelValue, REFERRAL_LEVEL);
    }
    return true;
  }

  // Widthraw Funtions
  function withdrawInvest(uint256 index)
    external
    override
    nonReentrant
    returns (bool)
  {
    (uint256 amount, , , , uint256 endTime) = userData.depositDetail(
      _msgSender(),
      index
    );

    require(endTime <= block.timestamp, "TREE::NEX");

    uint256 interest = withdrawInterest();

    userData.deleteUserInvestIndex(_msgSender(), index);

    _safeTransferETH(_msgSender(), USDtoBNB(amount));

    emit WithdrawInvest(_msgSender(), interest, amount);
    return true;
  }

  function withdrawInterest() public override nonReentrant returns (uint256) {
    (
      uint256 hourly,
      uint256 referrals,
      uint256 gift,
      uint256 savedTime
    ) = calculateInterest(_msgSender());
    uint256 rewards = hourly.add(referrals).add(gift);

    userData.changeUserData(_msgSender(), 0, 0, savedTime);

    if (rewards > 0) _safeTransferETH(_msgSender(), USDtoBNB(rewards));

    emit WithdrawInterest(_msgSender(), hourly, referrals, gift);
    return rewards;
  }

  function withdrawToInvest(bool six, uint256 gift)
    external
    override
    nonReentrant
    returns (bool)
  {
    (
      uint256 _hourly,
      uint256 _referrals,
      uint256 _gift,
      uint256 _savedTime
    ) = calculateInterest(_msgSender());
    uint256 rewards = _hourly.add(_referrals).add(_gift);

    userData.changeUserData(_msgSender(), 0, 0, _savedTime);

    _deposit(
      _msgSender(),
      valueWithReward(rewards),
      six ? REWARD_PERIOD : REWARD_PERIOD / 2,
      gift
    );

    emit WithdrawToInvest(_msgSender(), _hourly, _referrals, _gift);
    return true;
  }

  function calculateInterest(address user)
    public
    view
    override
    returns (
      uint256 hourly,
      uint256 referral,
      uint256 gift,
      uint256 requestTime
    )
  {
    uint256 latestWithdraw;
    (, referral, gift, , latestWithdraw) = userData.users(user);

    referral = userData.refAmount(user);
    gift = userData.giftAmount(user);
    requestTime = block.timestamp;

    if (latestWithdraw.addHour() <= requestTime)
      hourly = userData.calculateHourly(user, requestTime);

    return (hourly, referral, gift, requestTime);
  }

  // User API
  function users(address user)
    external
    view
    override
    returns (
      address referrer,
      uint256 refAmount,
      uint256 giftAmount,
      uint256 totalAmount,
      uint256 latestWithdraw
    )
  {
    return userData.users(user);
  }

  function userDepositNumber(address user)
    external
    view
    override
    returns (uint256)
  {
    return userData.depositNumber(user);
  }

  function userDepositDetails(address user, uint256 index)
    external
    view
    override
    returns (
      uint256 amount,
      uint256 period,
      uint256 reward,
      uint256 startTime,
      uint256 endTime
    )
  {
    return userData.depositDetail(user, index);
  }

  function userInvestExpired(address user, uint256 index)
    public
    view
    override
    returns (bool)
  {
    return userData.investIsExpired(user, index);
  }

  function userMaxMonth(address user) public view override returns (uint256) {
    return userData.maxPeriod(user).div(30 days);
  }

  function userExpired(address user) public view override returns (bool) {
    return userData.isExpired(user);
  }

  modifier nonReentrant() {
    require(!userData.blacklist(_msgSender()), "TREE::BLK");
    require(!locked, "TREE::LCK");
    locked = true;
    _;
    locked = false;
  }
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

  function toHours(uint256 a) internal pure returns (uint256) {
    return div(a, 1 hours);
  }

  function toUint64(uint256 value) internal pure returns (uint64) {
    require(value <= type(uint64).max, "Math: OVERFLOW");
    return uint64(value);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Secure.sol";

abstract contract Plan is Secure {
  uint8 public FEE = 0;
  uint8 public REFERRAL_LEVEL = 50;
  uint8 public DAILY_REWARD_PERCENT = 200;
  uint8 public INVEST_BONUS_PERCENT = 10;

  uint16 public REFERRAL_PERCENT = 200;
  uint24 public REWARD_MULTIPLIER = 100000;
  uint24 public REFERRAL_MULTIPLIER = 100000;

  uint32 public REWARD_PERIOD = 180 days;

  uint64 public MINIMUM_INVEST = 50 * 10**8;

  uint24[20] public FIAT = [
    50,
    2000,
    5000,
    10_000,
    15_000,
    20_000,
    30_000,
    40_000,
    50_000,
    65_000,
    80_000,
    100_000,
    150_000,
    200_000,
    300_000,
    400_000,
    500_000,
    650_000,
    800_000,
    1_000_000
  ];

  uint16[20] public PERCENTAGE = [
    20000,
    25000,
    30000,
    35000,
    40000,
    42500,
    45000,
    47500,
    50000,
    52000,
    54000,
    56000,
    57500,
    59000,
    60000,
    61000,
    62000,
    63000,
    64000,
    65000
  ];

  // Modifier functions
  function changeInvestBonusPercent(uint8 percent) external onlyOwner {
    INVEST_BONUS_PERCENT = percent;
  }

  function changeDailyRewardPercent(uint8 percent) external onlyOwner {
    DAILY_REWARD_PERCENT = percent;
  }

  function changeRewardMultiplier(uint24 percent) external onlyOwner {
    REWARD_MULTIPLIER = percent;
  }

  function changeReferralMultiplier(uint24 percent) external onlyOwner {
    REFERRAL_MULTIPLIER = percent;
  }

  function changeReferralPercent(uint16 percent) external onlyOwner {
    REFERRAL_PERCENT = percent;
  }

  function changeMinimumInvest(uint64 amount) external onlyOwner {
    MINIMUM_INVEST = amount;
  }

  function changeFiat(uint24[20] memory fiat) external onlyOwner {
    FIAT = fiat;
  }

  function changeReferralLevel(uint8 level) external onlyOwner {
    REFERRAL_LEVEL = level;
  }

  function changeRewardPeriod(uint32 period) external onlyOwner {
    REWARD_PERIOD = period;
  }

  function changeFee(uint8 fee) external onlyOwner {
    FEE = fee;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUserData {
  struct Invest {
    uint64 amount;
    uint64 period;
    uint64 reward;
    uint64 startTime;
  }

  // Registeration functions ----------------------------------------------------------
  function registerAndInvest(
    address user,
    address referrer,
    uint256 gift,
    Invest memory invest
  ) external returns (bool);

  function register(
    address user,
    address referrer,
    uint256 gift
  ) external returns (bool);

  function investment(address user, Invest memory invest)
    external
    returns (bool);

  function payReferrer(
    address lastRef,
    uint64 value,
    uint8 level
  ) external returns (bool);

  // Modifier functions ----------------------------------------------------------
  function changeLatestWithdraw(address user, uint256 latestWithdraw) external;

  function changeReferrer(address user, address referrer) external;

  function changeTotalAmount(address user, uint256 value) external;

  function changeGiftAmount(address user, uint256 value) external;

  function changeRefAmount(address user, uint256 value) external;

  function subTotalAmount(address user, uint256 value) external;

  function addTotalAmount(address user, uint256 value) external;

  function addGiftAmount(address user, uint256 value) external;

  function addRefAmount(address user, uint256 value) external;

  function changeUserData(
    address user,
    uint256 ref,
    uint256 gift,
    uint256 lw
  ) external;

  function deleteUserInvestIndex(address user, uint256 index) external;

  function deleteUserInvest(address user) external;

  function deleteUser(address user) external;

  // User Details ----------------------------------------------------------
  function users(address user)
    external
    view
    returns (
      address referrer,
      uint64 refAmount,
      uint64 giftAmount,
      uint64 totalAmount,
      uint64 latestWithdraw
    );

  function calculateHourly(address user, uint256 time)
    external
    view
    returns (uint256 rewards);

  function userList(uint256 index) external view returns (address);

  function exist(address user) external view returns (bool);

  function referrer(address user) external view returns (address);

  function refAmount(address user) external view returns (uint256);

  function totalAmount(address user) external view returns (uint256);

  function giftAmount(address user) external view returns (uint256);

  function latestWithdraw(address user) external view returns (uint256);

  function depositNumber(address user) external view returns (uint256);

  function depositDetail(address user, uint256 index)
    external
    view
    returns (
      uint256 amount,
      uint256 period,
      uint256 reward,
      uint256 startTime,
      uint256 endTime
    );

  function maxPeriod(address user) external view returns (uint256);

  function investExpireTime(address user, uint256 index)
    external
    view
    returns (uint256);

  function investIsExpired(address user, uint256 index)
    external
    view
    returns (bool);

  function expireTime(address user) external view returns (uint256);

  function isExpired(address user) external view returns (bool);

  function userListLength() external view returns (uint256);

  function getUserList() external view returns (address[] memory);

  function blacklist(address user) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITreenvest {
  event WithdrawInterest(
    address indexed user,
    uint256 hourly,
    uint256 referrals,
    uint256 gift
  );
  event WithdrawInvest(address indexed user, uint256 interest, uint256 value);

  event WithdrawToInvest(
    address indexed user,
    uint256 hourly,
    uint256 referrals,
    uint256 gift
  );

  event InvestDaily(address indexed user, uint256 value);

  event Invest3Month(
    address indexed user,
    address indexed referrer,
    uint256 value
  );

  event Invest6Month(
    address indexed user,
    address indexed referrer,
    uint256 value
  );

  event UpgradeToMonthly(address indexed user, uint256 value);

  function calcPercent(uint256 value) external view returns (uint256);

  function monthlyReward(uint256 value) external view returns (uint256);

  function hourlyReward(uint256 value) external view returns (uint256);

  function dailyInvestDailyReward(uint256 value)
    external
    view
    returns (uint256);

  function dailyInvestHourlyReward(uint256 value)
    external
    view
    returns (uint64);

  function BNBtoUSD(uint256 value) external view returns (uint256);

  function BNBtoUSDWithFee(uint256 value) external view returns (uint64);

  function valueWithReward(uint256 value) external view returns (uint64);

  function USDtoBNB(uint256 value) external view returns (uint256);

  function BNBPrice() external view returns (uint256);

  function calcFirstRefValue(address user, uint256 value)
    external
    view
    returns (uint64);

  function calcRefValue(uint256 value) external view returns (uint64);

  function investDaily() external payable returns (uint256);

  function invest3Month(address referrer, uint256 gift)
    external
    payable
    returns (uint256);

  function invest6Month(address referrer, uint256 gift)
    external
    payable
    returns (uint256);

  function upgradeToMonthly(
    uint256 index,
    uint256 gift,
    bool six
  ) external returns (bool);

  function withdrawInvest(uint256 index) external returns (bool);

  function withdrawInterest() external returns (uint256);

  function withdrawToInvest(bool six, uint256 gift) external returns (bool);

  function calculateInterest(address user)
    external
    view
    returns (
      uint256 hourly,
      uint256 referral,
      uint256 gift,
      uint256 requestTime
    );

  function userDepositNumber(address user) external view returns (uint256);

  function userDepositDetails(address user, uint256 index)
    external
    view
    returns (
      uint256 amount,
      uint256 period,
      uint256 reward,
      uint256 startTime,
      uint256 endTime
    );

  function userInvestExpired(address user, uint256 index)
    external
    returns (bool);

  function userMaxMonth(address user) external view returns (uint256);

  function userExpired(address user) external view returns (bool);

  function users(address user)
    external
    view
    returns (
      address referrer,
      uint256 refAmount,
      uint256 giftAmount,
      uint256 totalAmount,
      uint256 latestWithdraw
    );
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

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract Secure is Ownable {
  event AddedBlackList(address indexed user);
  event RemovedBlackList(address indexed user);

  bool internal locked;

  bytes4 private constant TRANSFER =
    bytes4(keccak256(bytes("transfer(address,uint256)")));

  function _safeTransferETH(address to, uint256 value) internal {
    (bool success, ) = to.call{ gas: 23000, value: value }("");

    require(success, "TREE::ETH");
  }

  function _safeTransfer(
    address token,
    address to,
    uint256 value
  ) internal {
    (bool success, bytes memory data) = token.call(
      abi.encodeWithSelector(TRANSFER, to, value)
    );
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "TREE::TTF"
    );
  }

  function pause() external onlyOwner {
    require(!locked);
    locked = true;
  }

  function unpause() external onlyOwner {
    require(locked);
    locked = false;
  }

  function withdrawBnb(uint256 value) external onlyOwner {
    payable(owner()).transfer(value);
  }

  function withdrawToken(address token, uint256 value) external onlyOwner {
    _safeTransfer(token, owner(), value);
  }

  function getBalance() external view returns (uint256) {
    return _msgSender().balance;
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
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
        return msg.data;
    }
}