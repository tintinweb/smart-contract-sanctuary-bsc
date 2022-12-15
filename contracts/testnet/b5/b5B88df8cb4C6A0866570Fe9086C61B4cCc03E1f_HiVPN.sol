// SPDX-License-Identifier: PROTECTED - [email protected]
pragma solidity ^0.8.0;

import "./Tokenized.sol";
import "./Payable.sol";
import "./Planed.sol";
import "./IHiVPN.sol";

contract HiVPN is IHiVPN, Payable, Tokenized, Planed {
  using Math for uint256;

  constructor(address[] memory tokens, address[] memory feeds) {
    admin = msg.sender;
    owner = msg.sender;
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

  // Payment function
  function payment(
    uint256 id,
    uint256 plan,
    address token,
    uint256 amount,
    address referrer
  ) public payable override {
    require(feedExists(token), "TOK");
    require(payments[id].time == 0, "PAY");
    require(plan > 0 && plan < PLAN_PRICE.length, "SLP");

    if (token == address(0)) require(msg.value == amount, "BNB");
    else require(tokenAllowance(_msgSender(), token) >= amount, "APR");

    uint256 value = toUSD(token, amount);

    uint8 planIndex = findPlan(value);

    require(planIndex == plan, "PLA");

    payments[id] = Payment({
      token: token,
      value: value,
      amount: amount,
      user: _msgSender(),
      time: block.timestamp,
      planId: PLAN_ID[planIndex]
    });

    uint256 fee = amount.mul(FEE).div(100);
    uint256 adminValue = amount.sub(fee);

    if (token != address(0)) {
      transferFrom(token, _msgSender(), admin, adminValue);
      transferFrom(token, _msgSender(), address(this), fee);
    } else payable(admin).transfer(adminValue);

    paymentList.push(id);

    emit NewPayment(_msgSender(), referrer, id, value);
  }
}

// SPDX-License-Identifier: PROTECTED - [email protected]
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Secured.sol";
import "./ITokenized.sol";
import "./IAggregator.sol";

abstract contract Tokenized is ITokenized, Secured {
  mapping(address => address) public priceFeeds;
  address[] public tokenList;

  // View functions ------------------------------------------------------------
  function feedPrice(address feed) public view override returns (uint256) {
    (, int256 price, , , ) = IAggregator(feed).latestRoundData();
    return uint256(price);
  }

  function tokenPrice(address token) public view override returns (uint256) {
    return feedPrice(priceFeeds[token]);
  }

  function tokenBalance(
    address user,
    address token
  ) public view override returns (uint256) {
    if (token == address(0)) return user.balance;
    return IERC20(token).balanceOf(user);
  }

  function tokenSymbol(address token) public view override returns (string memory) {
    if (token == address(0)) return "BNB";
    return IERC20(token).symbol();
  }

  function tokenDecimals(address token) public view override returns (uint256) {
    if (token == address(0)) return 18;
    return IERC20(token).decimals();
  }

  function tokenAllowance(
    address user,
    address token
  ) public view override returns (uint256) {
    if (token == address(0)) return 1e25;
    return IERC20(token).allowance(user, address(this));
  }

  function tokenDetails(
    address token
  ) public view override returns (uint256 price, uint256 decimals) {
    price = tokenPrice(token);
    decimals = tokenDecimals(token);
  }

  function allTokensBalances(
    address user
  ) external view override returns (uint256[] memory) {
    uint256[] memory balances = new uint256[](tokenList.length);

    balances[0] = user.balance;

    for (uint256 i = 0; i < tokenList.length; i++) {
      balances[i] = tokenBalance(user, tokenList[i]);
    }

    return balances;
  }

  function allTokensAllowances(
    address user
  ) external view override returns (uint256[] memory) {
    uint256[] memory allowances = new uint256[](tokenList.length);

    for (uint256 i = 0; i < tokenList.length; i++) {
      allowances[i] = tokenAllowance(user, tokenList[i]);
    }

    return allowances;
  }

  function allTokens() external view override returns (address[] memory) {
    return tokenList;
  }

  function allTokensDetails()
    external
    view
    override
    returns (string[] memory symbols, uint256[] memory decimals, uint256[] memory prices)
  {
    symbols = new string[](tokenList.length);
    decimals = new uint256[](tokenList.length);
    prices = new uint256[](tokenList.length);
    for (uint256 i = 0; i < tokenList.length; i++) {
      address token = tokenList[i];
      prices[i] = tokenPrice(token);
      symbols[i] = tokenSymbol(token);
      decimals[i] = tokenDecimals(token);
    }
  }

  function allTokensPrices() external view override returns (uint256[] memory) {
    uint256[] memory prices = new uint256[](tokenList.length);
    for (uint256 i = 0; i < tokenList.length; i++) {
      prices[i] = tokenPrice(tokenList[i]);
    }
    return prices;
  }

  function allPriceFeeds() external view override returns (address[] memory) {
    address[] memory feeds = new address[](tokenList.length);
    for (uint256 i = 0; i < tokenList.length; i++) {
      address token = tokenList[i];
      if (feedExists(token)) feeds[i] = priceFeeds[token];
    }
    return feeds;
  }

  function feedExists(address token) public view returns (bool) {
    return priceFeeds[token] != address(0);
  }

  // Modify functions ------------------------------------------------------------
  function setPriceFeeds(address token, address feed) external onlyOwner {
    if (!feedExists(token)) tokenList.push(token);

    priceFeeds[token] = feed;
  }

  function setPriceFeeds(
    address[] memory tokens,
    address[] memory feeds
  ) public onlyOwner {
    require(tokens.length == feeds.length, "LNG");
    for (uint256 i = 0; i < tokens.length; i++) {
      address token = tokens[i];
      if (!feedExists(token)) tokenList.push(token);
      priceFeeds[token] = feeds[i];
    }
  }

  function removePriceFeeds(address[] memory tokens) external onlyOwner {
    for (uint256 i = 0; i < tokens.length; i++) {
      delete priceFeeds[tokens[i]];
    }
    cleanTokenList();
  }

  function cleanTokenList() public onlyOwner {
    for (uint256 i = 0; i < tokenList.length; i++) {
      if (!feedExists(tokenList[i])) {
        tokenList[i] = tokenList[tokenList.length - 1];
        tokenList.pop();
      }
    }
  }

  // Transfer functions --------------------------------------------------------
  function transferFrom(address token, address from, address to, uint256 value) internal {
    IERC20(token).transferFrom(from, to, value);
  }

  function withdrawToken(address token, uint256 value) external onlyOwner {
    IERC20(token).transfer(owner, value);
  }

  function withdrawBnb(uint256 value) external onlyOwner {
    payable(owner).transfer(value);
  }
}

// SPDX-License-Identifier: PROTECTED - [email protected]
pragma solidity ^0.8.0;

import "./IPlaned.sol";
import "./Secured.sol";
import "./Math.sol";

abstract contract Planed is IPlaned, Secured {
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
  function getPlanPrices() external view override returns (uint256[8] memory) {
    return PLAN_PRICE;
  }

  function getPlanIds() external view override returns (uint256[8] memory) {
    return PLAN_ID;
  }

  // Modify functions ----------------------------------------------------------
  function changePrice(uint8 index, uint40 price) external onlyAdmin {
    PLAN_PRICE[index] = price;
  }

  function changePlanId(uint8 index, uint40 id) external onlyAdmin {
    PLAN_ID[index] = id;
  }

  function changePercentMore(uint8 value) external onlyAdmin {
    MORE = value;
  }

  function changePercentLess(uint8 value) external onlyAdmin {
    LESS = value;
  }

  function changeFee(uint256 value) public onlyOwner {
    FEE = value;
  }
}

// SPDX-License-Identifier: PROTECTED - [email protected]
pragma solidity ^0.8.0;

interface IHiVPN {
  function toToken(address token, uint256 value) external view returns (uint256);

  function toUSD(address token, uint256 value) external view returns (uint256);

  function findPlan(uint256 value) external view returns (uint8);

  function payment(
    uint256 id,
    uint256 plan,
    address token,
    uint256 amount,
    address referrer
  ) external payable;
}

// SPDX-License-Identifier: PROTECTED - [email protected]
pragma solidity ^0.8.0;

import "./Math.sol";
import "./Secured.sol";
import "./IPayable.sol";

abstract contract Payable is IPayable, Secured {
  mapping(uint256 => Payment) public payments;
  uint256[] public paymentList;

  // View functions ------------------------------------------------------------
  function paymentDetails(
    uint256 id
  ) external view override returns (address user, uint amount, uint planId) {
    Payment memory details = payments[id];
    return (details.user, details.value, details.planId);
  }

  function paymentDetailByIndex(
    uint256 index
  ) public view override returns (Payment memory) {
    return payments[paymentList[index]];
  }

  function allPayments() external view override returns (uint256[] memory) {
    return paymentList;
  }

  function allPaymentDetails() external view override returns (Payment[] memory) {
    Payment[] memory details = new Payment[](paymentList.length);

    for (uint256 i = 0; i < paymentList.length; i++) {
      details[i] = paymentDetailByIndex(i);
    }

    return details;
  }

  // Modify functions ------------------------------------------------------------
  function changePaymentDetail(uint256 id, Payment memory detail) external onlyAdmin {
    payments[id] = detail;
  }

  function changePaymentTokenAmount(uint256 id, uint256 amount) external onlyAdmin {
    payments[id].value = amount;
  }

  function changePaymentAmount(uint256 id, uint256 value) external onlyAdmin {
    payments[id].value = value;
  }

  function changePaymentPlanId(uint256 id, uint256 planId) external onlyAdmin {
    payments[id].planId = planId;
  }

  function changePaymentToken(uint256 id, address token) external onlyAdmin {
    payments[id].token = token;
  }

  function changePaymentTime(uint256 id, uint256 time) external onlyAdmin {
    payments[id].time = time;
  }

  function changePaymentUser(uint256 id, address user) external onlyAdmin {
    payments[id].user = user;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function balanceOf(address account) external view returns (uint256);

  function allowance(address owner, address spender) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);
}

// SPDX-License-Identifier: PROTECTED - [email protected]
pragma solidity ^0.8.0;

abstract contract Secured {
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
  function changeOwner(address newOwner) public onlyOwner {
    owner = newOwner;
  }

  function changeAdmin(address newAdmin) public onlyOwner {
    admin = newAdmin;
  }
}

// SPDX-License-Identifier: PROTECTED - [email protected]
pragma solidity ^0.8.0;

interface ITokenized {
  // Single functions
  function tokenBalance(address user, address token) external view returns (uint256);

  function tokenSymbol(address token) external view returns (string memory);

  function tokenDecimals(address token) external view returns (uint256);

  function feedPrice(address feed) external view returns (uint256);

  function tokenPrice(address token) external view returns (uint256);

  function tokenDetails(
    address token
  ) external view returns (uint256 price, uint256 decimals);

  function tokenAllowance(address user, address token) external view returns (uint256);

  // Batch functions
  function allPriceFeeds() external view returns (address[] memory);

  function allTokens() external view returns (address[] memory);

  function allTokensBalances(address user) external view returns (uint256[] memory);

  function allTokensAllowances(address user) external view returns (uint256[] memory);

  function allTokensPrices() external view returns (uint256[] memory);

  function allTokensDetails()
    external
    view
    returns (string[] memory symbols, uint256[] memory decimals, uint256[] memory prices);
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

// SPDX-License-Identifier: PROTECTED - [email protected]
pragma solidity ^0.8.0;

import "./Secured.sol";
import "./Math.sol";

interface IPlaned {
  function getPlanIds() external view returns (uint256[8] memory);

  function getPlanPrices() external view returns (uint256[8] memory);
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

// SPDX-License-Identifier: PROTECTED - [email protected]
pragma solidity ^0.8.0;

interface IPayable {
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
    uint256 value;
    uint256 planId;
    uint256 amount;
  }

  function paymentDetails(
    uint256 id
  ) external view returns (address user, uint value, uint planId);

  function paymentDetailByIndex(uint256 index) external view returns (Payment memory);

  function allPaymentDetails() external view returns (Payment[] memory);

  function allPayments() external view returns (uint256[] memory);
}