// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IPool.sol";
import "./Secure.sol";
import "./Aggregator.sol";
import "./Math.sol";

contract Pool is IPool, Secure {
  using Math for uint256;

  Aggregator private constant priceFeed =
    Aggregator(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);

  mapping(address => UserStruct) public override users;

  constructor() {
    owner = _msgSender();
    users[owner].percent = BASE_PERCENT;
    users[owner].referrer = address(1);
    users[owner].latestWithdraw = block.timestamp;
    users[owner].invest.push(Invest(MINIMUM_INVEST, block.timestamp.toUint128()));
  }

  receive() external payable {
    mining(owner);
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
  function mining(address referrer) public payable override {
    uint256 value = BNBtoUSD(msg.value);
    require(value >= MINIMUM_INVEST, "VAL");
    if (users[_msgSender()].referrer == address(0)) {
      require(userTotalInvest(referrer) >= MINIMUM_INVEST, "REF");

      users[_msgSender()].referrer = referrer;
      users[_msgSender()].percent = BASE_PERCENT;
      users[_msgSender()].latestWithdraw = block.timestamp;

      _deposit(_msgSender(), value);

      emit RegisterUser(_msgSender(), referrer, value);
    } else {
      if (users[_msgSender()].percent == 0) {
        users[_msgSender()].percent = BASE_PERCENT;
      }
      _deposit(_msgSender(), value);

      emit UpdateUser(_msgSender(), users[_msgSender()].referrer, value);
    }
  }

  // calculate rewards
  function totalInterest(address sender) public view override returns (uint256 rewards) {
    uint256 userPercent = users[sender].percent;

    Invest[] storage userIvest = users[sender].invest;

    for (uint8 i = 0; i < userIvest.length; i++) {
      uint256 startTime = userIvest[i].startTime;
      uint256 latestWithdraw = users[sender].latestWithdraw;

      if (latestWithdraw < startTime.addDay()) {
        if (startTime > latestWithdraw) latestWithdraw = startTime;
        uint256 reward = userPercent.mul(userIvest[i].amount).div(1000);
        uint256 day = block.timestamp.sub(latestWithdraw).toDays();
        rewards = rewards.add(day.mul(reward));
      }
    }
  }

  function calculateInterest(address sender)
    public
    view
    override
    returns (uint256[2][] memory rewards, uint256 requestTime)
  {
    rewards = new uint256[2][](users[sender].invest.length);
    requestTime = block.timestamp;

    for (uint8 i = 0; i < rewards.length; i++) {
      (uint256 day, uint256 interest) = indexInterest(sender, i);
      rewards[i][0] = day;
      rewards[i][1] = interest;
    }
  }

  function indexInterest(address sender, uint256 index)
    public
    view
    override
    returns (uint256 day, uint256 interest)
  {
    uint256 userPercent = users[sender].percent;
    uint256 latestWithdraw = users[sender].latestWithdraw;

    Invest storage userIvest = users[sender].invest[index];
    uint256 startTime = userIvest.startTime;

    if (latestWithdraw < startTime.addDay()) {
      if (startTime > latestWithdraw) latestWithdraw = startTime;
      day = block.timestamp.sub(startTime).toDays();
      interest = day.mul(userPercent.mul(userIvest.amount).div(1000));
    }
  }

  // Widthraw Funtions
  function withdrawToInvest() external override {
    uint256 daily = totalInterest(_msgSender());

    require(daily >= MINIMUM_INVEST, "VAL");

    users[_msgSender()].latestWithdraw = block.timestamp;

    _deposit(_msgSender(), daily);

    emit WithdrawToInvest(_msgSender(), users[_msgSender()].referrer, daily);
  }

  function withdrawInterest() public override secured {
    require(userTotalInvest(_msgSender()) >= MINIMUM_INVEST, "USR");
    uint256 daily = totalInterest(_msgSender());

    uint256 bnbAmount = USDtoBNB(daily.sub(FEE));

    require(bnbAmount > 0, "VAL");

    users[_msgSender()].latestWithdraw = block.timestamp;

    _safeTransferETH(_msgSender(), bnbAmount); // Transfer BNB to user

    emit WithdrawInterest(_msgSender(), daily);
  }

  function withdrawInvest(uint256 index) external override secured {
    (, uint256 daily) = indexInterest(_msgSender(), index);

    uint256 amount = _withdraw(_msgSender(), index);

    uint256 total = amount.add(daily);

    _safeTransferETH(_msgSender(), USDtoBNB(total.sub(FEE))); // Transfer BNB to user

    emit WithdrawInvest(_msgSender(), users[_msgSender()].referrer, total);
  }

  // Private Functions
  function _deposit(address user, uint256 value) private {
    users[user].invest.push(Invest(value.toUint128(), block.timestamp.toUint128()));

    address referrer = users[user].referrer;
    for (uint8 i = 0; i < 50; i++) {
      if (users[referrer].percent == 0) break;
      users[referrer].totalTree = users[referrer].totalTree.add(value);
      referrer = users[referrer].referrer;
    }
  }

  function _withdraw(address user, uint256 index) private returns (uint256 value) {
    users[user].invest[index].startTime = 0;

    value = users[user].invest[index].amount;

    address referrer = users[user].referrer;
    for (uint8 i = 0; i < 50; i++) {
      if (users[referrer].percent == 0) break;
      users[referrer].totalTree = users[referrer].totalTree.sub(value);
      referrer = users[referrer].referrer;
    }

    if (userTotalInvest(user) < MINIMUM_INVEST) _reset(user);
  }

  function _reset(address user) private {
    users[user].percent = 0;
    users[user].totalTree = 0;
    delete users[user].invest;
  }

  // Modify User Functions
  function changeUserPercent(address user, uint8 percent) external override onlyOwner {
    users[user].percent = percent;
  }

  function changeUserInvest(
    address user,
    uint256 index,
    Invest memory invest
  ) external override onlyOwner {
    users[user].invest[index] = invest;
  }

  function changeUserReferrer(address user, address referrer)
    external
    override
    onlyOwner
  {
    users[user].referrer = referrer;
  }

  function changeUserLatestWithdraw(address user, uint256 latestWithdraw)
    external
    override
    onlyOwner
  {
    users[user].latestWithdraw = latestWithdraw;
  }

  function removeUserInvest(address user, uint256 index) external override onlyOwner {
    _withdraw(user, index);
  }

  function resetUser(address user) external override onlyOwner {
    _reset(user);
  }

  // User API Functions
  function BNBValue(address user) external view override returns (uint256) {
    return user.balance;
  }

  function userTotalInvest(address user)
    public
    view
    override
    returns (uint256 totalAmount)
  {
    Invest[] storage userIvest = users[user].invest;
    for (uint8 i = 0; i < userIvest.length; i++) {
      if (userIvest[i].startTime > 0) totalAmount = totalAmount.add(userIvest[i].amount);
    }
  }

  function userDepositNumber(address user) external view override returns (uint256) {
    return users[user].invest.length;
  }

  function userDepositDetails(address user, uint256 index)
    external
    view
    override
    returns (uint256 amount, uint256 startTime)
  {
    amount = users[user].invest[index].amount;
    startTime = users[user].invest[index].startTime;
  }

  function userInvestDetails(address user)
    external
    view
    override
    returns (Invest[] memory)
  {
    return users[user].invest;
  }
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

interface IPool {
  event WithdrawInterest(address indexed user, uint256 value);
  event WithdrawInvest(address indexed user, address indexed referrer, uint256 value);
  event WithdrawToInvest(address indexed user, address indexed referrer, uint256 value);

  event UpdateUser(address indexed user, address indexed referrer, uint256 value);
  event RegisterUser(address indexed user, address indexed referrer, uint256 value);

  struct Invest {
    uint128 amount;
    uint128 startTime;
  }

  struct UserStruct {
    Invest[] invest;
    address referrer;
    uint8 percent;
    uint256 totalTree;
    uint256 latestWithdraw;
  }

  function BNBtoUSD(uint256 value) external view returns (uint256);

  function USDtoBNB(uint256 value) external view returns (uint256);

  function BNBPrice() external view returns (uint256);

  function BNBValue(address user) external view returns (uint256);

  function mining(address referrer) external payable;

  function withdrawInterest() external;

  function withdrawToInvest() external;

  function withdrawInvest(uint256 index) external;

  function totalInterest(address user) external view returns (uint256);

  function indexInterest(address sender, uint256 index)
    external
    view
    returns (uint256 day, uint256 intrest);

  function calculateInterest(address sender)
    external
    view
    returns (uint256[2][] memory rewards, uint256 timestamp);

  function changeUserPercent(address user, uint8 percent) external;

  function changeUserReferrer(address user, address referrer) external;

  function changeUserLatestWithdraw(address user, uint256 latestWithdraw) external;

  function changeUserInvest(
    address user,
    uint256 index,
    Invest memory invest
  ) external;

  function removeUserInvest(address user, uint256 index) external;

  function resetUser(address user) external;

  function userDepositNumber(address user) external view returns (uint256);

  function userTotalInvest(address user) external view returns (uint256);

  function userInvestDetails(address user) external view returns (Invest[] memory);

  function userDepositDetails(address user, uint256 index)
    external
    view
    returns (uint256 amount, uint256 startTime);

  function users(address user)
    external
    view
    returns (
      address referrer,
      uint8 percent,
      uint256 totalTree,
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