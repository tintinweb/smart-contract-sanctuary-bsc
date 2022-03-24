// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./ISmartInvest04.sol";
import "./ISmartInvest03.sol";
import "./ISmartWorld.sol";
import "./Secure.sol";

contract SmartInvest04 is ISmartInvest04, Secure {
  using SafeMath for uint256;

  struct Invest {
    uint256 period;
    uint256 reward;
    uint256 startTime;
  }

  struct UserStruct {
    Invest[] invest;
    address referrer;
    uint256 refEndTime;
    uint256 refAmounts;
    uint256 refPercent;
    uint256 totalAmount;
    uint256 latestWithdraw;
  }

  ISmartInvest03 internal Invest03 =
    ISmartInvest03(0x15dA682a2e9de3E0E2946F0f0D40675Da16DB4AE);

  uint256 private MINIMUM_PERCENT = 1000;
  uint256 private REWARDS_PERCENT = 5000;
  uint256 private MAXIMUM_PERCENT = 14000;
  uint256 private HUNDRED_PERCENT = 100000;
  uint256 private MINIMUM_AMOUNTS = 10000000000;
  uint256 private REFERRAL_PERIOD = 10285 hours;

  mapping(address => UserStruct) public users;

  constructor(address[] memory blackAddresses) {
    owner = _msgSender();
    migrateByUser();

    for (uint256 i = 0; i < blackAddresses.length; i++) {
      address addr = blackAddresses[i];
      blacklist[addr] = true;
    }
  }

  function totalReward(uint256 value) public pure override returns (uint256) {
    return value.mul(2);
  }

  function calcPercent(uint256 value) internal view returns (uint256) {
    return value.mul(MINIMUM_PERCENT).div(MINIMUM_AMOUNTS);
  }

  function maxPercent() public view override returns (uint256) {
    return MAXIMUM_PERCENT;
  }

  function rewardPercent(uint256 value) public view override returns (uint256) {
    if (value < MINIMUM_AMOUNTS) return value.mul(REWARDS_PERCENT).div(MINIMUM_AMOUNTS);
    uint256 percent = REWARDS_PERCENT.add(calcPercent(value.sub(MINIMUM_AMOUNTS)));
    return percent > MAXIMUM_PERCENT ? MAXIMUM_PERCENT : percent;
  }

  function monthlyReward(uint256 value) public view override returns (uint256) {
    return value.mul(rewardPercent(value)).div(HUNDRED_PERCENT);
  }

  function hourlyReward(uint256 value) public view override returns (uint256) {
    return monthlyReward(value).div(MONTH);
  }

  function rewardPeriod(uint256 value) public view override returns (uint256) {
    return totalReward(value).div(hourlyReward(value));
  }

  function bnbToUSD(uint256 value) public view override returns (uint256) {
    return Invest03.bnbToUSD(value);
  }

  function bnbToUSDPrice() public view override returns (uint256) {
    return bnbToUSD(10**18);
  }

  function USDToBnb(uint256 value) public view override returns (uint256) {
    return value.mul(10**18).div(bnbToUSDPrice());
  }

  function rewardInfo(uint256 value)
    public
    view
    override
    returns (
      uint256 period,
      uint256 reward,
      uint256 startTime
    )
  {
    period = rewardPeriod(value);
    reward = hourlyReward(value);
    startTime = block.timestamp;
  }

  function referralPercent(uint256 value) public view returns (uint256) {
    uint256 ref = value < 100000000000 ? value / 100000000 : value < 2100000000000
      ? 1000 + (value - 100000000000) / 2000000000
      : value < 6100000000000
      ? 2000 + (value - 2100000000000) / 4000000000
      : value < 14100000000000
      ? 3000 + (value - 6100000000000) / 8000000000
      : 4000;
    return ref.mul(PERCENT).div(100);
  }

  function referralInfo(address user, uint256 value)
    public
    view
    override
    returns (uint256 totalAmount, uint256 refPercent)
  {
    totalAmount = users[user].totalAmount.add(value);
    refPercent = referralPercent(totalAmount);
  }

  function hoursBetween(uint256 time1, uint256 time2) internal pure returns (uint256) {
    return time1.sub(time2).div(1 hours);
  }

  function migrateByAdmin(address user) public override onlyOwner returns (bool) {
    require(users[user].referrer == address(0), "Error::SmartInvest03, User exist!");
    return migration(user);
  }

  function migrateByUser() public override returns (bool) {
    require(users[_msgSender()].referrer == address(0), "Error::SmartInvest03, User exist!");
    return migration(_msgSender());
  }

  function migration(address user) internal returns (bool) {
    (
      address referrer,
      uint256 refEndTime,
      uint256 refAmounts,
      uint256 refPercent,
      uint256 totalAmount,
      uint256 latestWithdraw
    ) = Invest03.users(user);

    uint256 depositNumber = Invest03.userDepositNumber(user);

    for (uint256 i = 0; i < depositNumber; i++) {
      (, uint256 period, uint256 reward, uint256 startTime, ) = Invest03.userDepositDetails(
        user,
        i
      );
      users[user].invest.push(Invest(period, reward, startTime));
    }

    users[user].referrer = referrer;
    users[user].refEndTime = refEndTime;
    users[user].refAmounts = refAmounts;
    users[user].refPercent = refPercent;
    users[user].totalAmount = totalAmount;
    users[user].latestWithdraw = latestWithdraw;

    emit Migration(user, referrer, totalAmount);
    return true;
  }

  function invest(address referrer) public payable override notBlackListed returns (bool) {
    uint256 usd = bnbToUSD(msg.value);
    require(usd >= MINIMUM_AMOUNTS, "Error::SmartInvest03, Incorrect Value!");

    bool notExist = users[_msgSender()].referrer == address(0);

    if (notExist) {
      uint256 depositNumber = Invest03.userDepositNumber(_msgSender());
      if (depositNumber > 0) {
        migration(_msgSender());
        return userExpired(_msgSender()) ? refreshUser(usd) : depositUser(address(0), usd);
      }
      require(
        users[referrer].referrer != address(0),
        "Error::SmartInvest02, Referrer does not exist!"
      );
      return depositUser(referrer, usd);
    }
    return userExpired(_msgSender()) ? refreshUser(usd) : depositUser(address(0), usd);
  }

  function depositUser(address referrer, uint256 value) internal returns (bool) {
    (uint256 period, uint256 reward, uint256 startTime) = rewardInfo(value);
    (uint256 totalAmount, uint256 refPercent) = referralInfo(_msgSender(), value);
    users[_msgSender()].invest.push(Invest(period, reward, startTime));
    users[_msgSender()].totalAmount = totalAmount;
    users[_msgSender()].refPercent = refPercent;
    if (referrer != address(0)) {
      users[_msgSender()].referrer = referrer;
      users[_msgSender()].latestWithdraw = block.timestamp;
      users[_msgSender()].refEndTime = block.timestamp.add(REFERRAL_PERIOD);
      payReferrer(_msgSender(), value);
      emit RegisterUser(_msgSender(), referrer, value);
    } else {
      payReferrer(_msgSender(), value);
      emit UpdateUser(_msgSender(), value);
    }
    return true;
  }

  function refreshUser(uint256 value) internal returns (bool) {
    (uint256 period, uint256 reward, uint256 startTime) = rewardInfo(value);
    users[_msgSender()].invest.push(Invest(period, reward, startTime));
    users[_msgSender()].totalAmount = value;
    users[_msgSender()].refPercent = referralPercent(value);
    users[_msgSender()].refEndTime = block.timestamp.add(REFERRAL_PERIOD);
    payReferrer(_msgSender(), value);
    emit RefreshUser(_msgSender(), value);
    return true;
  }

  function payReferrer(address lastRef, uint256 value) private {
    for (uint256 i = 0; i < LEVEL; i++) {
      address refParent = users[lastRef].referrer;
      if (refParent == address(0)) break;
      if (!userExpired(refParent)) {
        uint256 userReward = value.mul(users[refParent].refPercent).div(HUNDRED_PERCENT);
        users[refParent].refAmounts = users[refParent].refAmounts.add(userReward);
      }
      lastRef = refParent;
    }
  }

  function withdrawInterest() public override notBlackListed returns (bool) {
    (uint256 hourly, uint256 referrals, uint256 savedTime) = calculateInterest(_msgSender());

    uint256 bnbAmount = USDToBnb(hourly.add(referrals));

    _safeTransferBNB(_msgSender(), bnbAmount);

    users[_msgSender()].refAmounts = 0;
    users[_msgSender()].latestWithdraw = savedTime;

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
    require(users[user].referrer != address(0), "Error::SmartInvest03, User not exist!");
    requestTime = block.timestamp;

    referral = users[user].refAmounts;

    if (users[user].latestWithdraw.add(1 hours) <= requestTime)
      hourly = calculateHourly(user, requestTime);

    return (hourly, referral, requestTime);
  }

  function calculateHourly(address sender, uint256 time)
    public
    view
    override
    returns (uint256 hourly)
  {
    for (uint16 i; i < users[sender].invest.length; i++) {
      uint256 period = users[sender].invest[i].period;
      uint256 reward = users[sender].invest[i].reward;
      uint256 startTime = users[sender].invest[i].startTime;
      uint256 endTime = startTime.add(period.mul(1 hours));
      uint256 latestWithdraw = users[sender].latestWithdraw;
      if (latestWithdraw < endTime) {
        if (startTime > latestWithdraw) latestWithdraw = startTime;
        uint256 lastAmount = 0;
        uint256 userHours = hoursBetween(time, startTime);
        if (userHours > period) userHours = period;
        if (latestWithdraw > startTime.add(1 hours))
          lastAmount = hoursBetween(latestWithdraw, startTime).mul(reward);
        hourly = hourly.add(userHours.mul(reward).sub(lastAmount));
      }
    }
  }

  function userDepositNumber(address user) public view override returns (uint256) {
    return users[user].invest.length;
  }

  function userDepositDetails(address user, uint256 index)
    public
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
    period = users[user].invest[index].period;
    reward = users[user].invest[index].reward;
    amount = reward.mul(period).div(2);
    startTime = users[user].invest[index].startTime;
    endTime = startTime.add(period.mul(1 hours));
  }

  function userExpired(address user) public view override returns (bool) {
    return users[user].refEndTime >= block.timestamp ? false : true;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISmartInvest04 {
  event UpdateUser(address indexed user, uint256 value);
  event RefreshUser(address indexed user, uint256 value);
  event Migration(address indexed user, address indexed referrer, uint256 value);
  event WithdrawInterest(address indexed user, uint256 hourly, uint256 referrals);
  event RegisterUser(address indexed user, address indexed referrer, uint256 value);

  function maxPercent() external view returns (uint256);

  function totalReward(uint256 value) external view returns (uint256);

  function rewardPercent(uint256 value) external view returns (uint256);

  function monthlyReward(uint256 value) external view returns (uint256);

  function hourlyReward(uint256 value) external view returns (uint256);

  function rewardPeriod(uint256 value) external view returns (uint256);

  function rewardInfo(uint256 value)
    external
    view
    returns (
      uint256 period,
      uint256 reward,
      uint256 endTime
    );

  function bnbToUSD(uint256 value) external view returns (uint256);

  function USDToBnb(uint256 value) external view returns (uint256);

  function bnbToUSDPrice() external view returns (uint256);

  function referralInfo(address user, uint256 value)
    external
    view
    returns (uint256 totalAmount, uint256 refPercent);

  function migrateByAdmin(address user) external returns (bool);

  function migrateByUser() external returns (bool);

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
    returns (uint256 hourly);

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

  function userExpired(address user) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISmartInvest03 {
  function users(address user)
    external
    view
    returns (
      address referrer,
      uint256 refEndTime,
      uint256 refAmounts,
      uint256 refPercent,
      uint256 totalAmount,
      uint256 latestWithdraw
    );

  function blacklist(address user) external view returns (bool);

  function maxPercent() external view returns (uint256);

  function totalReward(uint256 value) external view returns (uint256);

  function rewardPercent(uint256 value) external view returns (uint256);

  function monthlyReward(uint256 value) external view returns (uint256);

  function hourlyReward(uint256 value) external view returns (uint256);

  function rewardPeriod(uint256 value) external view returns (uint256);

  function rewardInfo(uint256 value)
    external
    view
    returns (
      uint256 period,
      uint256 reward,
      uint256 endTime
    );

  function bnbToUSDPrice() external view returns (uint256);

  function bnbToUSD(uint256 value) external view returns (uint256);

  function referralInfo(address user, uint256 value)
    external
    view
    returns (uint256 totalAmount, uint256 refPercent);

  function migrateByAdmin(address user) external returns (bool);

  function migrateByUser() external returns (bool);

  function investBnb(address referrer) external payable returns (bool);

  function updateBnb() external payable returns (bool);

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
    returns (uint256 hourly);

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

  function userExpired(address user) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISmartWorld {
  function sttPrice() external view returns (uint256);

  function STTS() external view returns (address);

  function BTCB() external view returns (address);

  function totalSupply() external view returns (uint256);

  function totalSatoshi()
    external
    view
    returns (
      uint256 stts,
      uint256 btc,
      uint256 bnb
    );

  function totalBalances()
    external
    view
    returns (
      uint256 stts,
      uint256 btc,
      uint256 bnb
    );

  function btcToSatoshi(uint256 value_) external view returns (uint256);

  function bnbToSatoshi(uint256 value_) external view returns (uint256);

  function sttsToSatoshi(uint256 value_) external view returns (uint256);

  function btcToBnbPrice() external view returns (uint256);

  function sttsToBnb(uint256 value_) external view returns (uint256);

  function sttsToBnbPrice() external view returns (uint256);

  function userBalances(address user_, address contract_)
    external
    view
    returns (
      bool isActive,
      uint256 bnb,
      uint256 satoshi
    );

  function userTokens(
    address token_,
    address user_,
    address contract_
  ) external view returns (uint256);

  function activation(address sender_, uint256 airDrop_) external returns (bool);

  function deposit(address sender_, uint256 value_) external payable returns (bool);

  function withdraw(address payable reciever_, uint256 interest_) external returns (bool);

  function depositToken(
    address token_,
    address spender_,
    uint256 value_
  ) external returns (bool);

  function withdrawToken(
    address token_,
    address reciever_,
    uint256 interest_
  ) external returns (bool);

  function payWithStt(address reciever_, uint256 interest_) external returns (bool);

  function burnWithStt(address from_, uint256 amount_) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

abstract contract Secure is Context {
  address public owner;
  uint256 public LEVEL = 80;
  uint256 public MONTH = 720;
  uint256 public PERCENT = 100;

  event AddedBlackList(address user);
  event RemovedBlackList(address user);

  modifier onlyOwner() {
    require(_msgSender() == owner, "Error::SmartInvest02, Only from owner!");
    _;
  }

  modifier notBlackListed() {
    require(!blacklist[_msgSender()], "Error::SmartInvest02, User blacklisted!");
    _;
  }

  mapping(address => bool) public blacklist;

  function _safeTransferBNB(address to, uint256 value) internal {
    (bool success, ) = to.call{gas: 23000, value: value}("");

    require(success, "Error::SmartPool02: BNB Transfer Failed");
  }

  function changeMonth(uint256 month) public onlyOwner {
    MONTH = month;
  }

  function changeLevel(uint256 level) public onlyOwner {
    LEVEL = level;
  }

  function changePercent(uint256 percent) public onlyOwner {
    PERCENT = percent;
  }

  function addBlackList(address user) public onlyOwner {
    blacklist[user] = true;
    emit AddedBlackList(user);
  }

  function removeBlackList(address user) public onlyOwner {
    blacklist[user] = false;
    emit RemovedBlackList(user);
  }

  function withdrawBnb(uint256 value) public onlyOwner {
    payable(owner).transfer(value);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
        return msg.data;
    }
}