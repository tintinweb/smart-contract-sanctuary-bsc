// SPDX-License-Identifier: PROTECTED
pragma solidity ^0.8.0;

import "./IHiVpn.sol";
import "./Plan.sol";
import "./User.sol";

contract HiVpn is IHiVpn, User, Plan {
  using Math for uint256;

  constructor(address[] memory tokens, address[] memory feeds) {
    owner = _msgSender();
    admin = _msgSender();
    setPriceFeeds(tokens, feeds);
  }

  function toToken(
    address token,
    uint256 value
  ) external view override returns (uint256) {
    (uint256 price, uint256 decimals) = tokenDetails(token);

    return value.mulDecimals(decimals).div(price);
  }

  function toUSD(address token, uint256 value) public view override returns (uint256) {
    (uint256 price, uint256 decimals) = tokenDetails(token);

    return value.mul(price).divDecimals(decimals);
  }

  function findPlan(uint256 value) public view override returns (uint8 plan) {
    uint less = value.mul(LESS.add(100)).div(100);
    uint more = value.mul(100).div(MORE.add(100));

    for (uint8 i = 1; i < PLAN_PRICE.length; i++) {
      if (less >= PLAN_PRICE[i] && more <= PLAN_PRICE[i]) plan = i;
    }
  }

  // Pay function
  function Pay(
    uint256 id,
    uint256 index,
    uint256 value,
    address token,
    address referrer
  ) public payable override {
    require(index > 0, "SLP");
    require(payments[id].time == 0, "PAY");
    require(index < PLAN_PRICE.length, "SLP");
    require(priceFeed[token] != address(0), "TOK");

    if (token == address(0)) require(msg.value == value, "BNB");
    else require(tokenAllowance(_msgSender(), token) >= value, "APR");

    uint256 usdValue = toUSD(token, value);

    uint8 planIndex = findPlan(usdValue);

    require(planIndex == index, "PLA");

    payments[id] = Payment({
      token: token,
      amount: usdValue,
      tokenAmount: value,
      user: _msgSender(),
      time: block.timestamp,
      planId: PLAN_ID[planIndex]
    });

    uint256 fee = value.mul(FEE).div(100);
    uint256 adminValue = value.sub(fee);

    if (token != address(0)) {
      transferFrom(token, _msgSender(), admin, adminValue);
      transferFrom(token, _msgSender(), address(this), fee);
    } else payable(admin).transfer(adminValue);

    users[_msgSender()].push(id);

    paymentsList.push(id);

    emit NewPayment(_msgSender(), referrer, id, usdValue);
  }
}

// SPDX-License-Identifier: PROTECTED
pragma solidity ^0.8.0;

import "./Secure.sol";
import "./Math.sol";

abstract contract Plan is Secure {
  uint256 public FEE = 5;
  uint256 public MORE = 5;
  uint256 public LESS = 1;

  uint256[8] public PLAN_PRICE = [
    0,
    6_00000000,
    11_00000000,
    21_00000000,
    34_00000000,
    55_00000000
  ];

  uint256[8] public PLAN_ID = [0, 51, 5, 31, 32, 47];

  // View functions --------------------------------------------------------
  function getPlanIds() external view returns (uint256[8] memory) {
    return PLAN_ID;
  }

  function getPlanPrices() external view returns (uint256[8] memory) {
    return PLAN_PRICE;
  }

  // Modify functions ----------------------------------------------------------
  function changePrice(uint8 index, uint40 price) external onlyOwner {
    PLAN_PRICE[index] = price;
  }

  function changePlanId(uint8 index, uint40 id) external onlyOwner {
    PLAN_ID[index] = id;
  }

  function changePercentMore(uint8 value) external onlyOwner {
    MORE = value;
  }

  function changePercentLess(uint8 value) external onlyOwner {
    LESS = value;
  }

  function changeFee(uint256 value) public onlyOwner {
    FEE = value;
  }
}

// SPDX-License-Identifier: PROTECTED
pragma solidity ^0.8.0;

interface IHiVpn {
  function toToken(address token, uint256 value) external view returns (uint256);

  function toUSD(address token, uint256 value) external view returns (uint256);

  function findPlan(uint256 value) external view returns (uint8);

  function Pay(
    uint256 pay_id,
    uint256 plan,
    uint256 value,
    address token,
    address referrer
  ) external payable;
}

// SPDX-License-Identifier: PROTECTED
pragma solidity ^0.8.0;

import "./IUser.sol";
import "./Token.sol";
import "./Payment.sol";

abstract contract User is IUser, Payment, Token {
  mapping(address => uint256[]) public users;

  // View functions ------------------------------------------------------------
  function tokenBalance(
    address user,
    address token
  ) public view override returns (uint256) {
    return IERC20(token).balanceOf(user);
  }

  function tokenBalances(address user) external view override returns (uint256[] memory) {
    uint256[] memory balances = new uint256[](tokenList.length);

    balances[0] = user.balance;

    for (uint256 i = 1; i < tokenList.length; i++) {
      balances[i] = tokenBalance(user, tokenList[i]);
    }

    return balances;
  }

  function tokenAllowance(
    address user,
    address token
  ) public view override returns (uint256) {
    return IERC20(token).allowance(user, address(this));
  }

  function tokenAllowances(
    address user
  ) external view override returns (uint256[] memory) {
    uint256[] memory allowances = new uint256[](tokenList.length);

    for (uint256 i = 0; i < tokenList.length; i++) {
      allowances[i] = tokenAllowance(user, tokenList[i]);
    }

    return allowances;
  }

  function paymentDetailByUser(
    address user
  ) external view override returns (Payment[] memory) {
    uint256[] memory ids = users[user];
    Payment[] memory details = new Payment[](ids.length);

    for (uint256 i = 0; i < ids.length; i++) {
      details[i] = payments[ids[i]];
    }

    return details;
  }

  function paymentDetailByUserIndex(
    address user,
    uint256 index
  ) external view override returns (Payment memory) {
    uint id = users[user][index];
    return payments[id];
  }

  // Modify functions ------------------------------------------------------------
  function changeUserBuy(address user, uint256 index, uint256 id) external onlyAdmin {
    users[user][index] = id;
  }

  function resetUser(address user) external onlyAdmin {
    delete users[user];
  }
}

// SPDX-License-Identifier: PROTECTED
pragma solidity ^0.8.0;

abstract contract Secure {
  address public owner;
  address public admin;

  // Modifiers -----------------------------------------------------------------
  modifier onlyOwner() {
    require(_msgSender() == owner, "OWN");
    _;
  }

  modifier onlyAdmin() {
    require(_msgSender() == admin || _msgSender() == owner, "ADM");
    _;
  }

  // View functions ----------------------------------------------------------------
  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  // Modify functions ------------------------------------------------------------
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

// SPDX-License-Identifier: PROTECTED
pragma solidity ^0.8.0;

interface IUser {
  function tokenBalance(address user, address token) external view returns (uint256);

  function tokenBalances(address user) external view returns (uint256[] memory);

  function tokenAllowance(address user, address token) external view returns (uint256);

  function tokenAllowances(address user) external view returns (uint256[] memory);
}

// SPDX-License-Identifier: PROTECTED
pragma solidity ^0.8.0;

import "./IPayment.sol";
import "./Secure.sol";
import "./Math.sol";

abstract contract Payment is IPayment, Secure {
  mapping(uint256 => Payment) public payments;

  uint256[] public paymentsList;

  // Payment API Functions
  function paymentDetailById(
    uint256 id
  ) external view override returns (address user, uint amount, uint planId) {
    Payment memory details = payments[id];
    return (details.user, details.amount, details.planId);
  }

  function paymentDetails() external view override returns (Payment[] memory) {
    Payment[] memory details = new Payment[](paymentsList.length);

    for (uint256 i = 0; i < paymentsList.length; i++) {
      details[i] = payments[paymentsList[i]];
    }

    return details;
  }

  function paymentListIds() external view override returns (uint256[] memory) {
    return paymentsList;
  }

  function paymentDetailByIndex(
    uint256 index
  ) external view override returns (Payment memory) {
    return payments[paymentsList[index]];
  }

  // Modify Payment
  function changePayment(uint256 id, Payment memory details) external onlyAdmin {
    payments[id] = details;
  }

  function changePaymentAmount(uint256 id, uint256 value) external onlyAdmin {
    payments[id].amount = value;
  }

  function changePaymentTokenAmount(uint256 id, uint256 value) external onlyAdmin {
    payments[id].tokenAmount = value;
  }

  function changePaymentTime(uint256 id, uint256 value) external onlyAdmin {
    payments[id].time = value;
  }

  function changePaymentUser(uint256 id, address user) external onlyAdmin {
    payments[id].user = user;
  }
}

// SPDX-License-Identifier: PROTECTED
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Secure.sol";
import "./IToken.sol";
import "./IAggregator.sol";

abstract contract Token is IToken, Secure {
  mapping(address => address) public priceFeed;
  address[] public tokenList;

  // View functions ------------------------------------------------------------
  function getPrice(address feed) public view override returns (uint256) {
    (, int256 price, , , ) = IAggregator(feed).latestRoundData();
    return uint256(price);
  }

  function tokenPrice(address token) public view override returns (uint256) {
    return getPrice(priceFeed[token]);
  }

  function tokenPrices() external view override returns (uint256[] memory) {
    uint256[] memory prices = new uint256[](tokenList.length);
    for (uint256 i = 0; i < tokenList.length; i++) {
      prices[i] = tokenPrice(tokenList[i]);
    }
    return prices;
  }

  function priceFeeds() external view override returns (address[] memory) {
    address[] memory feeds = new address[](tokenList.length);
    for (uint256 i = 0; i < tokenList.length; i++) {
      address token = tokenList[i];
      if (feedExists(token)) feeds[i] = priceFeed[token];
    }
    return feeds;
  }

  function tokenDetails(
    address token
  ) public view override returns (uint256 price, uint8 decimals) {
    price = tokenPrice(token);
    decimals = IERC20(token).decimals();
  }

  // Modify functions ------------------------------------------------------------
  function setPriceFeed(address token, address feed) external onlyOwner {
    if (!feedExists(token)) tokenList.push(token);

    priceFeed[token] = feed;
  }

  function setPriceFeeds(
    address[] memory tokens,
    address[] memory feeds
  ) public onlyOwner {
    require(tokens.length == feeds.length, "LNG");
    for (uint256 i = 0; i < tokens.length; i++) {
      address token = tokens[i];
      if (!feedExists(token)) tokenList.push(token);
      priceFeed[token] = feeds[i];
    }
  }

  function removePriceFeeds(address[] memory tokens) external onlyOwner {
    for (uint256 i = 0; i < tokens.length; i++) {
      delete priceFeed[tokens[i]];
    }
  }

  // Other functions --------------------------------------------------------
  function transferFrom(address token, address from, address to, uint256 value) internal {
    IERC20(token).transferFrom(from, to, value);
  }

  function feedExists(address token) internal view returns (bool) {
    return priceFeed[token] != address(0);
  }

  function withdrawToken(address token, uint256 value) external onlyOwner {
    IERC20(token).transfer(owner, value);
  }
}

// SPDX-License-Identifier: PROTECTED
pragma solidity ^0.8.0;

interface IPayment {
  event NewPayment(
    address indexed user,
    address indexed referrer,
    uint256 planId,
    uint256 value
  );

  struct Payment {
    address user;
    uint256 time;
    address token;
    uint256 amount;
    uint256 planId;
    uint256 tokenAmount;
  }

  function paymentDetails() external view returns (Payment[] memory);

  function paymentListIds() external view returns (uint256[] memory);

  function paymentDetailByIndex(uint256 index) external view returns (Payment memory);

  function paymentDetailById(
    uint256 id
  ) external view returns (address user, uint amount, uint planId);

  function paymentDetailByUser(address user) external view returns (Payment[] memory);

  function paymentDetailByUserIndex(
    address user,
    uint256 index
  ) external view returns (Payment memory);
}

// SPDX-License-Identifier: PROTECTED
pragma solidity ^0.8.0;

interface IToken {
  function getPrice(address feed) external view returns (uint256);

  function tokenPrice(address token) external view returns (uint256);

  function tokenPrices() external view returns (uint256[] memory);

  function priceFeeds() external view returns (address[] memory);

  function tokenDetails(
    address token
  ) external view returns (uint256 price, uint8 decimals);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
  function decimals() external view returns (uint8);

  function balanceOf(address account) external view returns (uint256);

  function allowance(address owner, address spender) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAggregator {
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