// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Math.sol";
import "./Secure.sol";
import "./ITreenvest.sol";
import "./Aggregator.sol";
import "../Plan/IPlan.sol";

contract Treenvest is ITreenvest, Secure {
  using Math for uint256;
  using Math for uint64;

  Aggregator private PriceFeed;
  IUserData private UserData;
  IPlan private Plan;

  constructor(
    address priceFeed,
    address userData,
    address plan
  ) {
    PriceFeed = Aggregator(priceFeed);
    UserData = IUserData(userData);
    Plan = IPlan(plan);
  }

  modifier nonReentrant() {
    require(UserData.notBlacklisted(_msgSender()), "TREE::BLK");
    require(!locked, "TREE::LCK");
    locked = true;
    _;
    locked = false;
  }

  receive() external payable {
    investFree();
  }

  // Investment functions
  function investFree() public payable override {
    uint64 usdValue = validateToUSD(msg.value);

    _depositFree(usdValue);
    emit InvestFree(_msgSender(), usdValue);
  }

  function invest3Month(address referrer, uint256 gift)
    external
    payable
    override
  {
    uint64 usdValue = validateToUSD(msg.value);

    _deposit(referrer, usdValue, gift, false);
    emit Invest3Month(_msgSender(), referrer, usdValue);
  }

  function invest6Month(address referrer, uint256 gift)
    external
    payable
    override
  {
    uint64 usdValue = validateToUSD(msg.value);

    _deposit(referrer, usdValue, gift, true);
    emit Invest6Month(_msgSender(), referrer, usdValue);
  }

  function upgradeToMonthly(
    uint256 index,
    uint256 gift,
    bool six
  ) external override {
    (
      uint256 amount,
      uint256 period,
      uint256 reward,
      uint256 startTime,
      uint256 endTime
    ) = UserData.depositDetail(_msgSender(), index);

    require(period == 0 && reward > 0, "TREE::NUP");
    require(endTime <= block.timestamp, "TREE::NEX");

    IUserData.Invest memory invest;
    invest.amount = amount.toUint64();
    invest.period = Plan.calcPeriod(six).toUint64();
    invest.reward = Plan.hourlyReward(amount).toUint64();
    invest.startTime = startTime.toUint64();

    require(
      UserData.changeInvestIndex(_msgSender(), index, invest),
      "TREE::INF"
    );

    if (!UserData.exist(_msgSender())) {
      UserData.register(_msgSender(), owner(), gift);
    }
    emit UpgradeToMonthly(_msgSender(), amount);
  }

  // Widthraw Funtions
  function withdrawInterest() public override nonReentrant {
    (uint256 hourly, uint256 referral, uint256 gift, ) = calculateInterest(
      _msgSender()
    );
    uint256 totalUsdReward = hourly.add(referral).add(gift);

    require(UserData.resetAfterWithdraw(_msgSender()), "TREE::WFA");

    if (totalUsdReward > 0) {
      _safeTransferETH(_msgSender(), USDtoBNB(totalUsdReward));
    }
    emit WithdrawInterest(_msgSender(), hourly, referral, gift);
  }

  // zero gift = free invest but without bonus reward
  function withdrawToInvest(uint256 gift, bool six)
    external
    override
    nonReentrant
  {
    (uint256 _hourly, uint256 _referrals, uint256 _gift, ) = calculateInterest(
      _msgSender()
    );
    uint256 totalUsdReward = _hourly.add(_referrals).add(_gift);

    require(Plan.valueIsEnough(totalUsdReward), "TREE::VAL");
    require(UserData.resetAfterWithdraw(_msgSender()), "TREE::WFA");

    if (gift > 0) {
      uint256 value = Plan.valuePlusBonus(totalUsdReward, six);
      _deposit(owner(), value.toUint64(), gift, six);
    } else {
      _depositFree(totalUsdReward.toUint64());
    }
    emit WithdrawToInvest(_msgSender(), _hourly, _referrals, _gift);
  }

  function withdrawInvest(uint256 index) external override {
    (uint256 amount, , , , uint256 endTime) = UserData.depositDetail(
      _msgSender(),
      index
    );

    require(endTime <= block.timestamp, "TREE::NEX");

    withdrawInterest();

    require(
      UserData.changeInvestIndexReward(_msgSender(), index, 0),
      "TREE::WFA"
    );

    _safeTransferETH(_msgSender(), USDtoBNB(amount));

    emit WithdrawInvest(_msgSender(), amount);
  }

  // Private Functions
  function _depositFree(uint64 _usdValue) private {
    IUserData.Invest memory invest;
    invest.amount = _usdValue;
    invest.period = 0;
    invest.reward = Plan.freeHourlyReward(_usdValue).toUint64();
    invest.startTime = block.timestamp.toUint64();

    require(UserData.investment(_msgSender(), invest), "TREE::INF");
  }

  function _deposit(
    address _referrer,
    uint64 _usdValue,
    uint256 _gift,
    bool _six
  ) private {
    IUserData.Invest memory invest;
    invest.amount = _usdValue;
    invest.period = Plan.calcPeriod(_six).toUint64();
    invest.reward = Plan.hourlyReward(_usdValue).toUint64();
    invest.startTime = block.timestamp.toUint64();

    require(UserData.investment(_msgSender(), invest), "TREE::INF");

    if (!UserData.exist(_msgSender())) {
      UserData.register(_msgSender(), _referrer, _gift);
    }
    address referrer = UserData.referrer(_msgSender());
    if (referrer != address(0)) {
      uint256 refValue = Plan.calcRefValue(
        _usdValue,
        UserData.maxPeriod(referrer)
      );
      UserData.addRefAmount(referrer, refValue);
    }
  }

  // interest calculater
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
    (, referral, gift, latestWithdraw) = UserData.users(user);

    requestTime = block.timestamp;

    if (latestWithdraw.addHour() <= requestTime) {
      hourly = UserData.calculateHourly(user, requestTime);
    }
    return (hourly, referral, gift, requestTime);
  }

  // Price Calculation
  function BNBPrice() public view override returns (uint256) {
    (, int256 price, , , ) = PriceFeed.latestRoundData();
    return uint256(price);
  }

  function USDtoBNB(uint256 value) public view override returns (uint256) {
    return value.mulDecimals(18).div(BNBPrice());
  }

  function BNBtoUSD(uint256 value) public view override returns (uint256) {
    return value.mul(BNBPrice()).divDecimals(18);
  }

  function validateToUSD(uint256 value) public view returns (uint64) {
    uint256 usdValue = BNBtoUSD(Plan.valueMinusFee(value));
    require(Plan.valueIsEnough(usdValue), "TREE::VAL");
    return usdValue.toUint64();
  }

  // User API
  function BNBValue(address user) external view override returns (uint256) {
    return user.balance;
  }

  function users(address user)
    external
    view
    override
    returns (
      address referrer,
      uint256 refAmount,
      uint256 giftAmount,
      uint256 latestWithdraw
    )
  {
    return UserData.users(user);
  }

  function userDepositNumber(address user)
    external
    view
    override
    returns (uint256)
  {
    return UserData.depositNumber(user);
  }

  function userInvestDetails(address user)
    external
    view
    override
    returns (IUserData.Invest[] memory)
  {
    return UserData.investDetails(user);
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
    return UserData.depositDetail(user, index);
  }

  function userInvestExpired(address user, uint256 index)
    external
    view
    override
    returns (bool)
  {
    return UserData.investIsExpired(user, index);
  }

  function userMaxMonth(address user) external view override returns (uint256) {
    return UserData.maxPeriod(user).div(30 days);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

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
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract Secure is Ownable {
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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./IUserData.sol";

interface ITreenvest {
  event WithdrawInterest(
    address indexed user,
    uint256 hourly,
    uint256 referrals,
    uint256 gift
  );

  event WithdrawInvest(address indexed user, uint256 value);

  event WithdrawToInvest(
    address indexed user,
    uint256 hourly,
    uint256 referrals,
    uint256 gift
  );

  event InvestFree(address indexed user, uint256 value);

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

  function investFree() external payable;

  function invest3Month(address referrer, uint256 gift) external payable;

  function invest6Month(address referrer, uint256 gift) external payable;

  function upgradeToMonthly(
    uint256 index,
    uint256 gift,
    bool six
  ) external;

  function withdrawInvest(uint256 index) external;

  function withdrawInterest() external;

  function withdrawToInvest(uint256 gift, bool six) external;

  function calculateInterest(address user)
    external
    view
    returns (
      uint256 hourly,
      uint256 referral,
      uint256 gift,
      uint256 requestTime
    );

  function BNBPrice() external view returns (uint256);

  function BNBtoUSD(uint256 value) external view returns (uint256);

  function USDtoBNB(uint256 value) external view returns (uint256);

  function BNBValue(address user) external view returns (uint256);

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

  function userInvestDetails(address user)
    external
    view
    returns (IUserData.Invest[] memory);

  function userInvestExpired(address user, uint256 index)
    external
    returns (bool);

  function userMaxMonth(address user) external view returns (uint256);

  function users(address user)
    external
    view
    returns (
      address referrer,
      uint256 refAmount,
      uint256 giftAmount,
      uint256 latestWithdraw
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

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
pragma solidity ^0.8.15;

interface IPlan {
  // Calculate functions
  function valueIsEnough(uint256 value) external view returns (bool);

  function valueMinusFee(uint256 value) external view returns (uint256);

  function valuePlusBonus(uint256 value, bool max)
    external
    view
    returns (uint256);

  function calcPeriod(bool six) external view returns (uint256);

  function calcPercent(uint256 value) external view returns (uint256);

  function monthlyReward(uint256 value) external view returns (uint256);

  function hourlyReward(uint256 value) external view returns (uint256);

  function freeDailyReward(uint256 value) external view returns (uint256);

  function freeHourlyReward(uint256 value) external view returns (uint256);

  function calcRefValue(uint256 value, uint256 maxPeriod)
    external
    view
    returns (uint256);
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IUserData {
  struct Invest {
    uint64 amount;
    uint64 period;
    uint64 reward;
    uint64 startTime;
  }

  // Registeration functions ----------------------------------------------------------
  function register(
    address user,
    address referrer,
    uint256 gift
  ) external returns (bool);

  function investment(address user, Invest memory invest)
    external
    returns (bool);

  // Modifier functions ----------------------------------------------------------
  function changeInvestIndex(
    address user,
    uint256 index,
    Invest memory invest
  ) external returns (bool);

  function changeInvestIndexReward(
    address user,
    uint256 index,
    uint256 value
  ) external returns (bool);

  function changeUserData(
    address user,
    uint256 ref,
    uint256 gift,
    uint256 lw
  ) external returns (bool);

  function resetAfterWithdraw(address user) external returns (bool);

  function addRefAmount(address user, uint256 value) external;

  // User Details ----------------------------------------------------------
  function users(address user)
    external
    view
    returns (
      address referrer,
      uint64 refAmount,
      uint64 giftAmount,
      uint64 latestWithdraw
    );

  function calculateHourly(address user, uint256 time)
    external
    view
    returns (uint256 rewards);

  function exist(address user) external view returns (bool);

  function referrer(address user) external view returns (address);

  function depositNumber(address user) external view returns (uint256);

  function investDetails(address user) external view returns (Invest[] memory);

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

  function investIsExpired(address user, uint256 index)
    external
    view
    returns (bool);

  function notBlacklisted(address user) external view returns (bool);
}