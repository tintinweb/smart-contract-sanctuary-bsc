// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IHiVpn.sol";
import "./Secure.sol";
import "./Aggregator.sol";
import "./Math.sol";

contract HiVpn is IHiVpn, Secure {
  using Math for uint256;

  Aggregator private constant priceFeed =
    Aggregator(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);

  mapping(address => BuyDetail[]) public users;

  constructor() {
    owner = _msgSender();
  }

  receive() external payable {
    buyVpn(owner);
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

  // Deposit function
  function buyVpn(address referrer) public payable override {
    uint256 value = BNBtoUSD(msg.value);
    require(value >= MINIMUM_INVEST, "VAL");

    users[_msgSender()].push(BuyDetail(value.toUint128(), block.timestamp.toUint128()));

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
      if (userIvest[i].startTime > 0) totalAmount = totalAmount.add(userIvest[i].amount);
    }
  }

  function userDepositNumber(address user) external view override returns (uint256) {
    return users[user].length;
  }

  function userDepositDetails(address user, uint256 index)
    external
    view
    override
    returns (uint256 amount, uint256 startTime)
  {
    amount = users[user][index].amount;
    startTime = users[user][index].startTime;
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
  event UpdateUser(address indexed user, address indexed referrer, uint256 value);
  event BuyVpn(address indexed user, address indexed referrer, uint256 value);

  struct BuyDetail {
    uint128 amount;
    uint128 startTime;
  }

  function BNBtoUSD(uint256 value) external view returns (uint256);

  function USDtoBNB(uint256 value) external view returns (uint256);

  function BNBPrice() external view returns (uint256);

  function BNBValue(address user) external view returns (uint256);

  function buyVpn(address referrer) external payable;

  function changeUserBuy(
    address user,
    uint256 index,
    BuyDetail memory detail
  ) external;

  function resetUser(address user) external;

  function userTotalBuys(address user) external view returns (uint256);

  function userDepositNumber(address user) external view returns (uint256);

  function userDepositDetails(address user, uint256 index)
    external
    view
    returns (uint256 amount, uint256 startTime);

  function userBuyDetails(address user) external view returns (BuyDetail[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Secure {
  event AddedBlackList(address indexed user);
  event RemovedBlackList(address indexed user);

  bool internal locked;

  address public owner;

  uint8 public BASE_PERCENT = 30;

  uint32 public FEE = 100000000;

  uint64 public MINIMUM_INVEST = 5000000000;

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

  function lock() external onlyOwner {
    locked = true;
  }

  function unlock() external onlyOwner {
    locked = false;
  }

  function changeFee(uint32 fee) external onlyOwner {
    FEE = fee;
  }

  function changeBasePercent(uint8 percent) external onlyOwner {
    BASE_PERCENT = percent;
  }

  function addBlackList(address user) external onlyOwner {
    blacklist[user] = true;
    emit AddedBlackList(user);
  }

  function removeBlackList(address user) external onlyOwner {
    blacklist[user] = false;
    emit RemovedBlackList(user);
  }

  function changeMinimumInvest(uint64 amount) external onlyOwner {
    MINIMUM_INVEST = amount;
  }

  function changeOwner(address newOwner) external onlyOwner {
    owner = newOwner;
  }

  function withdrawBnb(uint256 value) external onlyOwner {
    payable(owner).transfer(value);
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

  function addDay(uint256 a) internal pure returns (uint256) {
    return add(a, 1 days);
  }

  function toDays(uint256 a) internal pure returns (uint256) {
    return div(a, 1 days);
  }

  function toUint128(uint256 value) internal pure returns (uint128) {
    require(value <= type(uint128).max, "Math: OVERFLOW");
    return uint128(value);
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