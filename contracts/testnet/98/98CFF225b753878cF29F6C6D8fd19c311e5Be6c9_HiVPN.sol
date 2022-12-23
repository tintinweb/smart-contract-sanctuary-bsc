// SPDX-License-Identifier: PROTECTED
// [email protected]
pragma solidity ^0.8.0;

import "./Tokenized.sol";
import "./Payable.sol";
import "./IHiVPN.sol";

contract HiVPN is IHiVPN, Payable, Tokenized {
  using Math for uint256;

  constructor() {
    admin = msg.sender;
    owner = msg.sender;
    paymentList.push(0);
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

  function isEnough(uint256 usdValue, uint value) public view override returns (bool) {
    uint lessValue = value.mul(less.add(100)).div(100);

    return (lessValue >= usdValue);
  }

  // Payment function
  function pay(
    uint256 id,
    uint256 usd,
    address token,
    uint256 amount,
    address referrer
  ) public payable override {
    require(feedExists(token), "TOK");
    require(payments[id].time == 0, "PAY");

    if (token == address(0)) {
      require(msg.value == amount, "ETH");
    } else {
      require(userTokenAllowance(_msgSender(), token) >= amount, "APR");
    }

    uint256 value = toUSD(token, amount);

    require(isEnough(value, usd), "PLN");

    emit NewPayment(_msgSender(), referrer, id, value);

    uint256 feeValue = amount.mul(fee).div(100);
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
      time: block.timestamp
    });

    paymentList.push(id);
  }

  receive() external payable {
    uint256 id = paymentList[0];
    uint usd = toUSD(address(0), msg.value);

    pay(id, usd, address(0), msg.value, address(0));

    paymentList[0] = id.add(1);
  }
}

// SPDX-License-Identifier: PROTECTED
// [email protected]
pragma solidity ^0.8.0;

import "./Math.sol";
import "./IPayable.sol";

abstract contract Payable is IPayable {
  mapping(uint256 => Payment) public payments;
  uint256[] public paymentList;

  // View functions ------------------------------------------------------------
  function paymentDetails(
    uint256 id
  ) external view override returns (address user, uint amount) {
    Payment memory details = payments[id];
    return (details.user, details.value);
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
}

// SPDX-License-Identifier: PROTECTED
// [email protected]
pragma solidity ^0.8.0;

interface IHiVPN {
  function toToken(address token, uint256 value) external view returns (uint256);

  function toUSD(address token, uint256 value) external view returns (uint256);

  function isEnough(uint256 usdValue, uint value) external view returns (bool);

  function pay(
    uint256 id,
    uint256 usd,
    address token,
    uint256 amount,
    address referrer
  ) external payable;
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
    if (token == address(0)) return "TRX";
    return IERC20(token).symbol();
  }

  function _tokenDecimals(address token) internal view returns (uint256) {
    if (token == address(0)) return 6;
    return IERC20(token).decimals();
  }

  // View functions ------------------------------------------------------------
  function feedExists(address token) public view returns (bool) {
    return priceFeeds[token] != address(0);
  }

  function feedPrice(address feed) public view override returns (uint256) {
    int256 price = IAggregator(feed).latestAnswer();
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
    if (token == address(0)) return 1e12;
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
    uint256 amount;
  }

  function paymentDetails(uint256 id) external view returns (address user, uint value);

  function paymentDetailByIndex(uint256 index) external view returns (Payment memory);

  function allPayments() external view returns (uint256[] memory);

  function paymentCount() external view returns (uint256);
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

  uint256 public fee = 5;
  uint256 public less = 1;

  // Modifiers ----------------------------------------------------
  modifier onlyOwner() {
    require(_msgSender() == owner, "OWN");
    _;
  }

  modifier onlyAdmin() {
    require(_msgSender() == admin || _msgSender() == owner, "ADM");
    _;
  }

  // Internal functions -------------------------------------------
  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  // Modify functions ---------------------------------------------
  function changePercentLess(uint8 value) external onlyAdmin {
    less = value;
  }

  function changeFee(uint256 value) external onlyOwner {
    fee = value;
  }

  function changeOwner(address newOwner) external onlyOwner {
    owner = newOwner;
  }

  function changeAdmin(address newAdmin) external onlyOwner {
    admin = newAdmin;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAggregator {
  function latestAnswer() external view returns (int256);
}