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

  mapping(uint256 => Payment) public payment;
  mapping(address => uint256[]) public users;

  constructor() {
    owner = _msgSender();
    admin = _msgSender();
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
    uint256 lessValue = value.mul(LESS.add(100)).div(100);
    uint256 moreValue = value.mul(100).div(MORE.add(100));

    for (uint8 i = 1; i < PLAN.length; i++) {
      if (lessValue >= PLAN[i] && moreValue <= PLAN[i]) {
        return i;
      }
    }
    return 0;
  }

  // Pay function
  function Pay(uint pay_id, uint256 plan, address referrer) public payable override {
    require(payment[pay_id].time == 0, "PAY");
    require(plan > 0, "SLP");

    uint256 value = BNBtoUSD(msg.value);
    uint8 planValue = findPlan(value);

    require(planValue == plan, "PLA");

    // check the value
    payment[pay_id] = Payment({
      time: block.timestamp,
      amount: value,
      bnbAmount: msg.value,
      user: _msgSender()
    });

    // save FEE and send remaining to admin
    uint256 fee = msg.value.mul(FEE).div(100);
    payable(admin).transfer(msg.value.sub(fee));

    emit NewPayment(_msgSender(), referrer, value);
  }

  // Modify Payment
  function changePayment(uint256 pay_id, Payment memory details) external onlyOwner {
    payment[pay_id] = details;
  }

  function changePaymentAmount(uint256 pay_id, uint256 value) external onlyOwner {
    payment[pay_id].amount = value;
  }

  function changePaymentBnbAmount(uint256 pay_id, uint256 value) external onlyOwner {
    payment[pay_id].bnbAmount = value;
  }

  function changePaymentTime(uint256 pay_id, uint256 value) external onlyOwner {
    payment[pay_id].time = value;
  }

  function changePaymentUser(uint256 pay_id, address user) external onlyOwner {
    payment[pay_id].user = user;
  }

  // Modify User
  function changeUserBuy(
    address user,
    uint256 index,
    uint256 pay_id
  ) external override onlyOwner {
    users[user][index] = pay_id;
  }

  function resetUser(address user) external override onlyOwner {
    delete users[user];
  }

  // User API Functions
  function userBalance(address user) external view override returns (uint256) {
    return user.balance;
  }

  function userPaymentDetails(
    address user,
    uint256 index
  ) external view override returns (Payment memory) {
    uint pay_id = users[user][index];
    return payment[pay_id];
  }

  function userPaymentsDetails(
    address user
  ) external view override returns (Payment[] memory) {
    uint256[] memory pay_ids = users[user];
    Payment[] memory details = new Payment[](pay_ids.length);

    for (uint256 i = 0; i < pay_ids.length; i++) {
      details[i] = payment[pay_ids[i]];
    }

    return details;
  }

  function userPayments(address user) external view override returns (uint256[] memory) {
    return users[user];
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IHiVpn {
  event NewPayment(address indexed user, address indexed referrer, uint256 value);

  struct Payment {
    address user;
    uint256 time;
    uint256 amount;
    uint256 bnbAmount;
  }

  function BNBtoUSD(uint256 value) external view returns (uint256);

  function USDtoBNB(uint256 value) external view returns (uint256);

  function BNBPrice() external view returns (uint256);

  function userBalance(address user) external view returns (uint256);

  function findPlan(uint256 value) external view returns (uint8);

  function Pay(uint pay_id, uint256 plan, address referrer) external payable;

  function changeUserBuy(address user, uint256 index, uint256 pay_id) external;

  function resetUser(address user) external;

  function userPaymentDetails(
    address user,
    uint256 index
  ) external view returns (Payment memory);

  function userPaymentsDetails(address user) external view returns (Payment[] memory);

  function userPayments(address user) external view returns (uint256[] memory);
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
    return mul(a, 10 ** b);
  }

  function divDecimals(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, 10 ** b);
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

abstract contract Secure {
  address public owner;
  address public admin;

  uint256 public FEE = 5;
  uint256 public MORE = 5;
  uint256 public LESS = 1;

  uint256[6] public PLAN = [
    0,
    6_00000000,
    11_00000000,
    21_00000000,
    34_00000000,
    55_00000000
  ];

  modifier onlyOwner() {
    require(_msgSender() == owner, "OWN");
    _;
  }

  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function changeFee(uint256 value) public onlyOwner {
    FEE = value;
  }

  function changePrice(uint8 index, uint40 plan) external onlyOwner {
    PLAN[index] = plan;
  }

  function changePercentMore(uint8 value) external onlyOwner {
    MORE = value;
  }

  function changePercentLess(uint8 value) external onlyOwner {
    LESS = value;
  }

  function changeOwner(address newOwner) external onlyOwner {
    owner = newOwner;
  }

  function changeAdmin(address newAdmin) public onlyOwner {
    admin = newAdmin;
  }

  function withdrawBnb(uint256 value) external onlyOwner {
    payable(owner).transfer(value);
  }
}