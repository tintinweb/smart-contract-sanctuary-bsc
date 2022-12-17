// SPDX-License-Identifier: PROTECTED
// [email protected]
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
    batchSetPriceFeeds(tokens, feeds);
  }

  function toToken(
    address token,
    uint256 value
  ) external view override returns (uint256) {
    (uint256 price, uint256 decimals) = _tokenDetails(token);

    return value.mulDecimals(decimals).div(price);
  }

  function toUSD(address token, uint256 value) public view override returns (uint256) {
    (uint256 price, uint256 decimals) = _tokenDetails(token);

    return value.mul(price).divDecimals(decimals);
  }

  function findPlan(uint256 value) public view override returns (uint8 plan) {
    uint lessValue = value.mul(_less.add(100)).div(100);
    uint moreValue = value.mul(100).div(_more.add(100));

    for (uint8 i = 1; i < _planPrices.length; i++) {
      if (lessValue >= _planPrices[i] && moreValue <= _planPrices[i]) plan = i;
    }
  }

  // Payment function
  function pay(
    uint256 id,
    uint256 plan,
    address token,
    uint256 amount,
    address referrer
  ) public payable override {
    require(feedExists(token), "TOK");
    require(payments[id].time == 0, "PAY");
    require(plan > 0 && plan < _planPrices.length, "SLP");

    if (token == address(0)) {
      require(msg.value == amount, "BNB");
    } else {
      require(userTokenAllowance(_msgSender(), token) >= amount, "APR");
    }

    uint256 value = toUSD(token, amount);
    uint8 planIndex = findPlan(value);
    require(planIndex == plan, "PLA");

    uint256 feeValue = amount.mul(_fee).div(100);
    uint256 adminValue = amount.sub(feeValue);

    if (token == address(0)) {
      payable(admin).transfer(adminValue);
    } else {
      bool adminTx = IERC20(token).transferFrom(_msgSender(), admin, adminValue);
      bool ownerTx = IERC20(token).transferFrom(_msgSender(), address(this), feeValue);
      require(adminTx && ownerTx, "TRF");
    }

    payments[id] = Payment({
      token: token,
      value: value,
      amount: amount,
      user: _msgSender(),
      time: block.timestamp,
      planId: _planIds[planIndex]
    });

    paymentList.push(id);

    emit NewPayment(_msgSender(), referrer, id, value);
  }
}

// SPDX-License-Identifier: PROTECTED
// [email protected]
pragma solidity ^0.8.0;

import "./IAggregator.sol";
import "./ITokenized.sol";
import "./Secured.sol";
import "./IERC20.sol";

abstract contract Tokenized is ITokenized, Secured {
  mapping(address => address) public priceFeeds;
  address[] public tokenList;

  // Internal functions ----------------------------------------------------------
  function _tokenDetails(
    address token
  ) internal view returns (uint256 price, uint256 decimals) {
    price = tokenPrice(token);
    decimals = _tokenDecimals(token);
  }

  function _tokenSymbol(address token) internal view returns (string memory) {
    if (token == address(0)) return "BNB";
    return IERC20(token).symbol();
  }

  function _tokenDecimals(address token) internal view returns (uint256) {
    if (token == address(0)) return 18;
    return IERC20(token).decimals();
  }

  // View functions ------------------------------------------------------------
  function feedExists(address token) public view returns (bool) {
    return priceFeeds[token] != address(0);
  }

  function feedPrice(address feed) public view override returns (uint256) {
    (, int256 price, , , ) = IAggregator(feed).latestRoundData();
    return uint256(price);
  }

  function tokenPrice(address token) public view override returns (uint256) {
    return feedPrice(priceFeeds[token]);
  }

  function allTokens() external view override returns (address[] memory) {
    return tokenList;
  }

  function allPriceFeeds() external view override returns (address[] memory) {
    address[] memory feeds = new address[](tokenList.length);
    for (uint256 i = 0; i < tokenList.length; i++) {
      address token = tokenList[i];
      if (feedExists(token)) feeds[i] = priceFeeds[token];
    }
    return feeds;
  }

  function allTokensDetails()
    external
    view
    override
    returns (
      address[] memory addresses,
      string[] memory symbols,
      uint256[] memory decimals,
      uint256[] memory prices
    )
  {
    symbols = new string[](tokenList.length);
    decimals = new uint256[](tokenList.length);
    prices = new uint256[](tokenList.length);
    addresses = new address[](tokenList.length);
    for (uint256 i = 0; i < tokenList.length; i++) {
      address token = tokenList[i];
      prices[i] = tokenPrice(token);
      symbols[i] = _tokenSymbol(token);
      decimals[i] = _tokenDecimals(token);
      addresses[i] = token;
    }
  }

  function userTokenBalance(
    address user,
    address token
  ) public view override returns (uint256) {
    if (token == address(0)) return user.balance;
    return IERC20(token).balanceOf(user);
  }

  function userTokenAllowance(
    address user,
    address token
  ) public view override returns (uint256) {
    if (token == address(0)) return 1e25;
    return IERC20(token).allowance(user, address(this));
  }

  function userTokensDetails(
    address user
  )
    external
    view
    override
    returns (
      string[] memory symbols,
      uint256[] memory balances,
      uint256[] memory allowances
    )
  {
    symbols = new string[](tokenList.length);
    balances = new uint256[](tokenList.length);
    allowances = new uint256[](tokenList.length);
    for (uint256 i = 0; i < tokenList.length; i++) {
      address token = tokenList[i];
      symbols[i] = _tokenSymbol(token);
      balances[i] = userTokenBalance(user, token);
      allowances[i] = userTokenAllowance(user, token);
    }
  }

  // Modify functions ------------------------------------------------------------
  function setPriceFeeds(address token, address feed) public onlyOwner {
    if (!feedExists(token)) tokenList.push(token);

    priceFeeds[token] = feed;
  }

  function batchSetPriceFeeds(
    address[] memory tokens,
    address[] memory feeds
  ) public onlyOwner {
    require(tokens.length == feeds.length, "LNG");
    for (uint256 i = 0; i < tokens.length; i++) {
      setPriceFeeds(tokens[i], feeds[i]);
    }
  }

  function batchRemovePriceFeeds(address[] memory tokens) external onlyOwner {
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
  function withdrawToken(address token, uint256 value) external onlyOwner {
    IERC20(token).transfer(owner, value);
  }

  function withdrawBnb(uint256 value) external onlyOwner {
    payable(owner).transfer(value);
  }
}

// SPDX-License-Identifier: PROTECTED
// [email protected]
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

  function paymentCount() external view override returns (uint256) {
    return paymentList.length;
  }

  function allPayments() external view override returns (uint256[] memory) {
    return paymentList;
  }

  // Modify functions ------------------------------------------------------------
  function changePaymentDetail(uint256 id, Payment memory detail) external onlyAdmin {
    payments[id] = detail;
  }
}

// SPDX-License-Identifier: PROTECTED
// [email protected]
pragma solidity ^0.8.0;

import "./IPlaned.sol";
import "./Secured.sol";
import "./Math.sol";

abstract contract Planed is IPlaned, Secured {
  uint256 internal _fee = 5;
  uint256 internal _more = 5;
  uint256 internal _less = 1;

  uint256[8] internal _planPrices = [
    0,
    6_00000000,
    11_00000000,
    21_00000000,
    34_00000000,
    55_00000000
  ];

  uint256[8] internal _planIds = [0, 51, 5, 31, 32, 47];

  // View functions --------------------------------------------------------
  function allOptions()
    external
    view
    override
    returns (
      uint256 fee,
      uint256 more,
      uint256 less,
      uint256[8] memory planIds,
      uint256[8] memory planPrices
    )
  {
    return (_fee, _more, _less, _planIds, _planPrices);
  }

  // Modify functions ----------------------------------------------------------
  function changePrice(uint8 index, uint40 price) external onlyAdmin {
    _planPrices[index] = price;
  }

  function changePlanId(uint8 index, uint40 id) external onlyAdmin {
    _planIds[index] = id;
  }

  function changePercentMore(uint8 value) external onlyAdmin {
    _more = value;
  }

  function changePercentLess(uint8 value) external onlyAdmin {
    _less = value;
  }

  function changeFee(uint256 value) public onlyOwner {
    _fee = value;
  }
}

// SPDX-License-Identifier: PROTECTED
// [email protected]
pragma solidity ^0.8.0;

interface IHiVPN {
  function toToken(address token, uint256 value) external view returns (uint256);

  function toUSD(address token, uint256 value) external view returns (uint256);

  function findPlan(uint256 value) external view returns (uint8);

  function pay(
    uint256 id,
    uint256 plan,
    address token,
    uint256 amount,
    address referrer
  ) external payable;
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

// SPDX-License-Identifier: PROTECTED
// [email protected]
pragma solidity ^0.8.0;

interface ITokenized {
  function feedPrice(address feed) external view returns (uint256);

  function tokenPrice(address token) external view returns (uint256);

  function allPriceFeeds() external view returns (address[] memory);

  function allTokens() external view returns (address[] memory);

  function allTokensDetails()
    external
    view
    returns (
      address[] memory addresses,
      string[] memory symbols,
      uint256[] memory decimals,
      uint256[] memory prices
    );

  function userTokenBalance(address user, address token) external view returns (uint256);

  function userTokenAllowance(
    address user,
    address token
  ) external view returns (uint256);

  function userTokensDetails(
    address user
  )
    external
    view
    returns (
      string[] memory symbols,
      uint256[] memory balances,
      uint256[] memory allowances
    );
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

// SPDX-License-Identifier: PROTECTED
// [email protected]
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

  // Internal functions ----------------------------------------------------------------
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
// [email protected]
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

  function allPayments() external view returns (uint256[] memory);

  function paymentCount() external view returns (uint256);
}

// SPDX-License-Identifier: PROTECTED
// [email protected]
pragma solidity ^0.8.0;

import "./Secured.sol";
import "./Math.sol";

interface IPlaned {
  function allOptions()
    external
    view
    returns (
      uint256 fee,
      uint256 more,
      uint256 less,
      uint256[8] memory planIds,
      uint256[8] memory planPrices
    );
}