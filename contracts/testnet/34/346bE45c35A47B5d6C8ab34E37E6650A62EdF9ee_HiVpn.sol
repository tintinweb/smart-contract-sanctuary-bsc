// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IHiVpn.sol";
import "./Secure.sol";
import "./Aggregator.sol";
import "./Math.sol";

contract HiVpn is IHiVpn, Secure {
  using Math for uint256;

  // main = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
  // test = 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
  Aggregator private constant priceFeed =
    Aggregator(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);

  mapping(address => BuyDetail[]) public users;

  constructor() {
    owner = _msgSender();
  }

  receive() external payable {
    Pay(owner, 0);
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

  function findPlan(uint256 value) public view override returns (uint8) {
    uint256 moreValue = value.mul(TOLERANCE).div(100);
    uint256 lessValue = value.mul(100).div(TOLERANCE);

    for (uint8 i = 0; i < PLAN.length; i++) {
      if (moreValue >= PLAN[i] && lessValue <= PLAN[i]) {
        return i;
      }
    }
    return 0;
  }

  // Deposit function
  function Pay(address referrer, uint256 plan) public payable override {
    uint256 value = BNBtoUSD(msg.value);

    require(plan > 0, "SLP");

    uint8 planValue = findPlan(value);

    require(planValue == plan, "PLA");

    // check the value
    BuyDetail memory detail = BuyDetail({
      time: block.timestamp.toUint64(),
      amount: value.toUint64(),
      duration: TIME[planValue],
      bnbAmount: msg.value.toUint64()
    });

    users[_msgSender()].push(detail);

    emit BuyVpn(_msgSender(), referrer, value);
  }

  // Modify User
  function changeUserBuy(
    address user,
    uint256 index,
    BuyDetail memory detail
  ) external override onlyOwner {
    users[user][index] = detail;
  }

  function resetUser(address user) external override onlyOwner {
    delete users[user];
  }

  // User API Functions
  function BNBValue(address user) external view override returns (uint256) {
    return user.balance;
  }

  function userTotalBuys(address user)
    public
    view
    override
    returns (uint256 totalAmount)
  {
    BuyDetail[] storage userIvest = users[user];
    for (uint8 i = 0; i < userIvest.length; i++) {
      totalAmount = totalAmount.add(userIvest[i].amount);
    }
  }

  function userDepositNumber(address user) external view override returns (uint256) {
    return users[user].length;
  }

  function userBuyDetails(address user)
    external
    view
    override
    returns (BuyDetail[] memory)
  {
    return users[user];
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IHiVpn {
  event BuyVpn(address indexed user, address indexed referrer, uint256 value);

  struct BuyDetail {
    uint64 time;
    uint64 amount;
    uint64 duration;
    uint64 bnbAmount;
  }

  function BNBtoUSD(uint256 value) external view returns (uint256);

  function USDtoBNB(uint256 value) external view returns (uint256);

  function BNBPrice() external view returns (uint256);

  function BNBValue(address user) external view returns (uint256);

  function findPlan(uint256 value) external view returns (uint8);

  function Pay(address referrer, uint256 plan) external payable;

  function changeUserBuy(
    address user,
    uint256 index,
    BuyDetail memory detail
  ) external;

  function resetUser(address user) external;

  function userTotalBuys(address user) external view returns (uint256);

  function userDepositNumber(address user) external view returns (uint256);

  function userBuyDetails(address user) external view returns (BuyDetail[] memory);
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

  function toUint64(uint256 value) internal pure returns (uint64) {
    require(value <= type(uint64).max, "Math: OVERFLOW");
    return uint64(value);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Secure {
  address public owner;

  uint256 public TOLERANCE = 105;

  uint40[6] public PLAN = [
    0,
    6_00000000,
    11_00000000,
    21_00000000,
    34_00000000,
    55_00000000
  ];

  uint40[6] public TIME = [0, 30 days, 102 days, 198 days, 410 days, 790 days];

  modifier onlyOwner() {
    require(_msgSender() == owner, "OWN");
    _;
  }

  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function changePrice(uint8 index, uint40 plan) external onlyOwner {
    PLAN[index] = plan;
  }

  function changeTime(uint8 index, uint40 time) external onlyOwner {
    TIME[index] = time;
  }

  function changeTolerance(uint256 tolerance) external onlyOwner {
    TOLERANCE = tolerance;
  }

  function changeOwner(address newOwner) external onlyOwner {
    owner = newOwner;
  }

  function withdrawBnb(uint256 value) external onlyOwner {
    payable(owner).transfer(value);
  }
}