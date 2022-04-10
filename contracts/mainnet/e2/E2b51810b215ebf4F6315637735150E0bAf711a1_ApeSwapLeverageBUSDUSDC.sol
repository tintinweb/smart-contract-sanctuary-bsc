// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IEllipsisRouter} from "../../interfaces/IEllipsisRouter.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Wrapper} from "../../interfaces/IERC20Wrapper.sol";
import {IFlashBorrower} from "../../interfaces/IFlashBorrower.sol";
import {IFlashLoan} from "../../interfaces/IFlashLoan.sol";
import {ILeverageStrategy} from "../../interfaces/ILeverageStrategy.sol";
import {IPriceFeed} from "../../interfaces/IPriceFeed.sol";
import {ITroveManager} from "../../interfaces/ITroveManager.sol";
import {IUniswapV2Factory} from "../../interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Router02} from "../../interfaces/IUniswapV2Router02.sol";
import {LeverageAccount, LeverageAccountRegistry} from "../../account/LeverageAccountRegistry.sol";
import {LeverageLibraryBSC} from "../../helpers/LeverageLibraryBSC.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {TroveLibrary} from "../../helpers/TroveLibrary.sol";

contract ApeSwapLeverageBUSDUSDC is IFlashBorrower, ILeverageStrategy {
  using SafeMath for uint256;

  address public borrowerOperations;

  ITroveManager public troveManager;
  IPriceFeed public priceFeed;

  IERC20 public arth;
  IERC20 public busd;
  IERC20 public usdc;
  IERC20 public rewardToken;

  IFlashLoan public flashLoan;
  LeverageAccountRegistry public accountRegistry;

  IERC20 public lp;

  IERC20Wrapper public arthUsd;
  IERC20Wrapper public stakingWrapper;

  IEllipsisRouter public ellipsis;
  IUniswapV2Router02 public apeswapRouter;
  IUniswapV2Factory public apeswapFactory;

  address private me;

  constructor(bytes memory data1, bytes memory data2) {
    (
      address _flashloan,
      address _arth,
      address _usdc,
      address _busd,
      address _rewardToken,
      address _ellipsis,
      address _arthUsd,
      address _uniswapRouter // address _borrowerOperations,
    ) = abi.decode(data1, (address, address, address, address, address, address, address, address));

    (
      address _borrowerOperations,
      address _troveManager,
      address _priceFeed,
      address _stakingWrapper,
      address _accountRegistry
    ) = abi.decode(data2, (address, address, address, address, address));

    ellipsis = IEllipsisRouter(_ellipsis);

    busd = IERC20(_busd);
    arth = IERC20(_arth);
    usdc = IERC20(_usdc);
    rewardToken = IERC20(_rewardToken);
    flashLoan = IFlashLoan(_flashloan);
    arthUsd = IERC20Wrapper(_arthUsd);

    me = address(this);

    apeswapRouter = IUniswapV2Router02(_uniswapRouter);
    apeswapFactory = IUniswapV2Factory(apeswapRouter.factory());
    lp = IERC20(apeswapFactory.getPair(_usdc, _busd));

    borrowerOperations = _borrowerOperations;
    troveManager = ITroveManager(_troveManager);
    priceFeed = IPriceFeed(_priceFeed);
    stakingWrapper = IERC20Wrapper(_stakingWrapper);
    accountRegistry = LeverageAccountRegistry(_accountRegistry);
  }

  function getAccount(address who) public view returns (LeverageAccount) {
    return accountRegistry.accounts(who);
  }

  function openPosition(
    uint256[] memory finalExposure,
    uint256[] memory principalCollateral,
    uint256 minExpectedCollateralRatio,
    uint256 maxBorrowingFee
  ) external override {
    // take the principal
    busd.transferFrom(msg.sender, address(this), principalCollateral[0]);

    // todo swap excess

    // estimate how much we should flashloan based on how much we want to borrow
    uint256 flashloanAmount = ellipsis
      .estimateARTHtoBuy(finalExposure[0].sub(principalCollateral[0]), finalExposure[1], 0)
      .mul(102)
      .div(100);

    bytes memory flashloanData = abi.encode(
      msg.sender,
      uint256(0), // action = 0 -> open loan
      minExpectedCollateralRatio,
      maxBorrowingFee,
      finalExposure,
      principalCollateral
    );

    flashLoan.flashLoan(address(this), flashloanAmount, flashloanData);
    _flush(msg.sender);

    emit PositionOpened(msg.sender, address(stakingWrapper), finalExposure, principalCollateral);
  }

  function closePosition(uint256[] memory minExpectedCollateral) external override {
    bytes memory flashloanData = abi.encode(
      msg.sender,
      uint256(1), // action = 1 -> close loan
      uint256(0),
      uint256(0),
      minExpectedCollateral,
      minExpectedCollateral
    );

    // todo need to make this MEV resistant
    address who = address(getAccount(msg.sender));
    uint256 flashloanAmount = troveManager.getTroveDebt(who);

    emit PositionClosed(
      msg.sender,
      address(stakingWrapper),
      troveManager.getTroveColl(who),
      flashloanAmount
    );

    flashLoan.flashLoan(address(this), flashloanAmount, flashloanData);

    LeverageLibraryBSC.swapExcessARTH(me, msg.sender, 1, ellipsis, arth);
    _flush(msg.sender);
  }

  function onFlashLoan(
    address initiator,
    uint256 flashloanAmount,
    uint256 fee,
    bytes calldata data
  ) external override returns (bytes32) {
    require(msg.sender == address(flashLoan), "untrusted lender");
    require(initiator == address(this), "not contract");

    // decode the data
    (
      address who,
      uint256 action,
      uint256 minExpectedCollateralRatio,
      uint256 maxBorrowingFee,
      uint256[] memory finalExposure,
      uint256[] memory minCollateralOrPrincipalCollateral
    ) = abi.decode(data, (address, uint256, uint256, uint256, uint256[], uint256[]));

    // open or close the loan position
    if (action == 0) {
      _onFlashloanOpenPosition(
        who,
        flashloanAmount,
        finalExposure,
        minCollateralOrPrincipalCollateral,
        minExpectedCollateralRatio,
        maxBorrowingFee
      );
    } else _onFlashloanClosePosition(who, flashloanAmount, minCollateralOrPrincipalCollateral);

    return keccak256("FlashMinter.onFlashLoan");
  }

  function _onFlashloanOpenPosition(
    address who,
    uint256 flashloanAmount,
    uint256[] memory finalExposure,
    uint256[] memory principalCollateral,
    uint256 minExpectedCollateralRatio,
    uint256 maxBorrowingFee
  ) internal {
    LeverageAccount acct = getAccount(who);

    // 1: sell arth for collateral
    arth.approve(address(ellipsis), flashloanAmount);
    ellipsis.sellARTHForExact(
      flashloanAmount,
      finalExposure[0].sub(principalCollateral[0]), // amountBUSDOut,
      finalExposure[1], // amountusdCOut,
      0, // amountUSDTOut,
      me,
      block.timestamp
    );

    // 2. LP all the collateral
    usdc.approve(address(apeswapRouter), usdc.balanceOf(me));
    busd.approve(address(apeswapRouter), busd.balanceOf(me));
    apeswapRouter.addLiquidity(
      address(usdc),
      address(busd),
      usdc.balanceOf(me),
      busd.balanceOf(me),
      0,
      0,
      me,
      block.timestamp
    );

    // 3. Stake and tokenize
    uint256 collateralAmount = lp.balanceOf(me);
    lp.approve(address(stakingWrapper), collateralAmount);
    stakingWrapper.deposit(collateralAmount);

    // 4: send the collateral to the leverage account
    stakingWrapper.transfer(address(acct), collateralAmount);

    // 5: open loan using the collateral
    uint256 debt = flashloanAmount.sub(arth.balanceOf(me));
    TroveLibrary.openLoan(
      acct,
      borrowerOperations,
      maxBorrowingFee, // borrowing fee
      debt, // debt
      collateralAmount, // collateral
      address(0), // upperHint,
      address(0), // lowerHint,
      address(0), // frontEndTag,
      arth,
      stakingWrapper
    );

    // 6. check if we met the min leverage conditions
    require(
      LeverageLibraryBSC.getTroveCR(priceFeed, troveManager, address(acct)) >=
        minExpectedCollateralRatio,
      "min cr not met"
    );

    // 7. payback the loan..
    arth.approve(address(flashLoan), flashloanAmount);
    require(arth.balanceOf(me) >= flashloanAmount, "not enough arth for flashloan");
  }

  function _onFlashloanClosePosition(
    address who,
    uint256 flashloanAmount,
    uint256[] memory minCollateral
  ) internal {
    LeverageAccount acct = getAccount(who);

    // 1. send the flashloaned arth to the account
    arth.transfer(address(acct), flashloanAmount);

    // 2. use the flashloan'd ARTH to payback the debt and close the loan
    TroveLibrary.closeLoan(
      acct,
      address(0),
      borrowerOperations,
      flashloanAmount,
      arth,
      stakingWrapper
    );

    // 3. get the collateral and swap back to arth to back the loan
    // 4. unstake and un-tokenize
    uint256 collateralAmount = stakingWrapper.balanceOf(me);
    stakingWrapper.withdraw(collateralAmount);

    // 5. remove from LP
    lp.approve(address(apeswapRouter), lp.balanceOf(me));
    apeswapRouter.removeLiquidity(
      address(usdc),
      address(busd),
      lp.balanceOf(me),
      0, // amountAMin
      0, // amountBMin
      me,
      block.timestamp
    );

    busd.approve(address(ellipsis), busd.balanceOf(me));
    usdc.approve(address(ellipsis), usdc.balanceOf(me));

    ellipsis.buyARTHForExact(
      busd.balanceOf(me).sub(minCollateral[0]),
      usdc.balanceOf(me),
      0,
      flashloanAmount,
      me,
      block.timestamp
    );

    require(busd.balanceOf(me) >= minCollateral[0], "not enough busd");
    // require(usdc.balanceOf(me) >= minCollateral[1], "not enough usdc");

    // 4. payback the loan..
    arth.approve(address(flashLoan), flashloanAmount);
    require(arth.balanceOf(me) >= flashloanAmount, "not enough for flashload");
  }

  function rewardsEarned(address who) external view override returns (uint256) {
    return LeverageLibraryBSC.rewardsEarned(accountRegistry, troveManager, stakingWrapper, who);
  }

  function underlyingCollateralFromBalance(uint256 bal)
    external
    view
    override
    returns (uint256[2] memory)
  {
    return LeverageLibraryBSC.underlyingCollateralFromBalance(bal, address(lp));
  }

  function _flush(address to) internal {
    if (arth.balanceOf(me) > 0) {
      arth.approve(address(arthUsd), arth.balanceOf(me));
      arthUsd.deposit(arth.balanceOf(me));
    }
    if (arthUsd.balanceOf(me) > 0) arthUsd.transfer(to, arthUsd.balanceOf(me));
    if (usdc.balanceOf(me) > 0) usdc.transfer(to, usdc.balanceOf(me));
    if (busd.balanceOf(me) > 0) busd.transfer(to, busd.balanceOf(me));
    if (rewardToken.balanceOf(me) > 0) rewardToken.transfer(to, rewardToken.balanceOf(me));
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IEllipsisRouter {
  function sellARTHForExact(
    uint256 amountArthInMax,
    uint256 amountBUSDOut,
    uint256 amountUSDCOut,
    uint256 amountUSDTOut,
    address to,
    uint256 deadline
  ) external;

  function buyARTHForExact(
    uint256 amountBUSDIn,
    uint256 amountUSDCIn,
    uint256 amountUSDTIn,
    uint256 amountARTHOutMin,
    address to,
    uint256 deadline
  ) external;

  function sellARTHforToken(
    int128 tokenId, // 1 -> busd, 2 -> usdc, 3 -> usdt
    uint256 amountARTHin,
    address to,
    uint256 deadline
  ) external;

  function sellTokenForToken(
    IERC20 fromToken,
    int128 fromTokenId, // 1 -> busd, 2 -> usdc, 3 -> usdt
    int128 toTokenId, // 1 -> busd, 2 -> usdc, 3 -> usdt
    uint256 amountInMax,
    uint256 amountOutMin,
    address to,
    uint256 deadline
  ) external;

  function estimateARTHtoSell(
    uint256 busdNeeded,
    uint256 usdcNeeded,
    uint256 usdtNeeded
  ) external view returns (uint256);

  function estimateARTHtoBuy(
    uint256 busdToSell,
    uint256 usdtToSell,
    uint256 usdcToSell
  ) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IERC20Wrapper is IERC20 {
  /// @dev Mint ERC20 token
  /// @param amount Token amount to wrap
  function deposit(uint256 amount) external returns (bool);

  /// @dev Burn ERC20 token to redeem LP ERC20 token back plus SUSHI rewards.
  /// @param amount Token amount to burn
  function withdraw(uint256 amount) external returns (bool);

  /// @dev pending rewards
  function accumulatedRewards() external view returns (uint256);

  function accumulatedRewardsFor(address _user) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFlashBorrower {
  /**
   * @dev Receive a flash loan.
   * @param initiator The initiator of the loan.
   * @param amount The amount of tokens lent.
   * @param fee The additional amount of tokens to repay.
   * @param data Arbitrary data structure, intended to contain user-defined parameters.
   * @return The keccak256 hash of "IFlashLender.onFlashLoan"
   */
  function onFlashLoan(
    address initiator,
    uint256 amount,
    uint256 fee,
    bytes calldata data
  ) external returns (bytes32);
}

// SPDX-License-Identifier: agpl-3.0

pragma solidity ^0.8.0;

interface IFlashLoan {
  function flashLoan(
    address receiverAddress,
    uint256 amount,
    bytes calldata params
  ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ILeverageStrategy {
  function openPosition(
    uint256[] memory borrowedCollateral,
    uint256[] memory principalCollateral,
    uint256 minExpectedCollateralRatio,
    uint256 maxBorrowingFee
  ) external;

  function closePosition(uint256[] memory minExpectedCollateral) external;

  function rewardsEarned(address who) external view returns (uint256);

  function underlyingCollateralFromBalance(uint256 bal) external view returns (uint256[2] memory);

  event PositionOpened(
    address indexed who,
    address collateral,
    uint256[] finalExposure,
    uint256[] principalCollateral
  );

  event PositionClosed(
    address indexed who,
    address collateral,
    uint256 collateralRedeemed,
    uint256 debt
  );
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IPriceFeed {
  // --- Function ---
  function fetchPrice() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Common interface for the Trove Manager.
interface ITroveManager {
  function setAddresses(
    address _borrowerOperationsAddress,
    address _activePoolAddress,
    address _defaultPoolAddress,
    address _stabilityPoolAddress,
    address _gasPoolAddress,
    address _collSurplusPoolAddress,
    address _lusdTokenAddress,
    address _sortedTrovesAddress,
    address _governanceAddress,
    address _wethAddress
  ) external;

  function stabilityPool() external view returns (address);

  function lusdToken() external view returns (IERC20);

  function getTroveOwnersCount() external view returns (uint256);

  function getTroveFromTroveOwnersArray(uint256 _index) external view returns (address);

  function getNominalICR(address _borrower) external view returns (uint256);

  function getCurrentICR(address _borrower, uint256 _price) external view returns (uint256);

  function liquidate(address _borrower) external;

  function liquidateTroves(uint256 _n) external;

  function batchLiquidateTroves(address[] calldata _troveArray) external;

  function redeemCollateral(
    uint256 _amount,
    address _firstRedemptionHint,
    address _upperPartialRedemptionHint,
    address _lowerPartialRedemptionHint,
    uint256 _partialRedemptionHintNICR,
    uint256 _maxIterations,
    uint256 _maxFee
  ) external;

  function updateStakeAndTotalStakes(address _borrower) external returns (uint256);

  function updateTroveRewardSnapshots(address _borrower) external;

  function addTroveOwnerToArray(address _borrower) external returns (uint256 index);

  function applyPendingRewards(address _borrower) external;

  function getPendingETHReward(address _borrower) external view returns (uint256);

  function getPendingLUSDDebtReward(address _borrower) external view returns (uint256);

  function hasPendingRewards(address _borrower) external view returns (bool);

  function getEntireDebtAndColl(address _borrower)
    external
    view
    returns (
      uint256 debt,
      uint256 coll,
      uint256 pendingLUSDDebtReward,
      uint256 pendingETHReward
    );

  function closeTrove(address _borrower) external;

  function removeStake(address _borrower) external;

  function getRedemptionRate() external view returns (uint256);

  function getRedemptionRateWithDecay() external view returns (uint256);

  function getRedemptionFeeWithDecay(uint256 ethDrawn) external view returns (uint256);

  function getBorrowingRate() external view returns (uint256);

  function getBorrowingRateWithDecay() external view returns (uint256);

  function getBorrowingFee(uint256 _debt) external view returns (uint256);

  function getBorrowingFeeWithDecay(uint256 _debt) external view returns (uint256);

  function decayBaseRateFromBorrowing() external;

  function getTroveStatus(address _borrower) external view returns (uint256);

  function getTroveStake(address _borrower) external view returns (uint256);

  function getTroveDebt(address _borrower) external view returns (uint256);

  function getTroveFrontEnd(address _borrower) external view returns (address);

  function getTroveColl(address _borrower) external view returns (uint256);

  function setTroveStatus(address _borrower, uint256 num) external;

  function setTroveFrontEndTag(address _borrower, address _frontEndTag) external;

  function increaseTroveColl(address _borrower, uint256 _collIncrease) external returns (uint256);

  function decreaseTroveColl(address _borrower, uint256 _collDecrease) external returns (uint256);

  function increaseTroveDebt(address _borrower, uint256 _debtIncrease) external returns (uint256);

  function decreaseTroveDebt(address _borrower, uint256 _collDecrease) external returns (uint256);

  function getTCR(uint256 _price) external view returns (uint256);

  function checkRecoveryMode(uint256 _price) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IUniswapV2Factory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);

  function getPair(address tokenA, address tokenB) external view returns (address pair);

  function allPairs(uint256) external view returns (address pair);

  function allPairsLength() external view returns (uint256);

  function createPair(address tokenA, address tokenB) external returns (address pair);

  function setFeeTo(address) external;

  function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IUniswapV2Router01.sol";

interface IUniswapV2Router02 is IUniswapV2Router01 {
  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountETH);

  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountETH);

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable;

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import {LeverageAccount, LeverageAccountFactory} from "./LeverageAccountFactory.sol";

// This Registry deploys new proxy instances through LeverageAccountFactory.build(address) and keeps a registry of owner => proxy
contract LeverageAccountRegistry {
  mapping(address => LeverageAccount) public accounts;
  LeverageAccountFactory public factory;

  constructor(address factory_) {
    factory = LeverageAccountFactory(factory_);
  }

  // deploys a new proxy instance
  // sets owner of proxy to caller
  function build() public returns (address payable account) {
    account = build(msg.sender);
  }

  // deploys a new proxy instance
  // sets custom owner of proxy
  function build(address owner) public returns (address payable account) {
    // Not allow new proxy if the user already has one and remains being the owner
    require(
      address(accounts[owner]) == address(LeverageAccount(address(0))) ||
        accounts[owner].canExecute(owner),
      "account exists"
    );

    account = factory.build(owner);
    accounts[owner] = LeverageAccount(account);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IEllipsisRouter} from "../interfaces/IEllipsisRouter.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPriceFeed} from "../interfaces/IPriceFeed.sol";
import {ITroveManager} from "../interfaces/ITroveManager.sol";
import {IUniswapV2Pair} from "../interfaces/IUniswapV2Pair.sol";

import {IERC20Wrapper} from "../interfaces/IERC20Wrapper.sol";
import {LeverageAccount, LeverageAccountRegistry} from "../account/LeverageAccountRegistry.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";

library LeverageLibraryBSC {
  using SafeMath for uint256;

  function getAccount(LeverageAccountRegistry accountRegistry, address who)
    public
    view
    returns (LeverageAccount)
  {
    return accountRegistry.accounts(who);
  }

  function getTroveCR(
    IPriceFeed priceFeed,
    ITroveManager troveManager,
    address who
  ) public view returns (uint256) {
    uint256 price = priceFeed.fetchPrice();
    uint256 debt = troveManager.getTroveDebt(who);
    uint256 coll = troveManager.getTroveColl(who);
    return coll.mul(price).div(debt);
  }

  function rewardsEarned(
    LeverageAccountRegistry accountRegistry,
    ITroveManager troveManager,
    IERC20Wrapper stakingWrapper,
    address who
  ) public view returns (uint256) {
    address acct = address(getAccount(accountRegistry, who));
    uint256 collat = troveManager.getTroveColl(acct);

    uint256 accRewards = stakingWrapper.accumulatedRewards();
    uint256 total = stakingWrapper.totalSupply();
    uint256 perc = collat.mul(1e18).div(total);
    return accRewards.mul(perc).div(1e18);
  }

  function underlyingCollateralFromBalance(uint256 balance, address lp)
    public
    view
    returns (uint256[2] memory)
  {
    IUniswapV2Pair pair = IUniswapV2Pair(lp);

    IERC20 token0 = IERC20(pair.token0());
    IERC20 token1 = IERC20(pair.token1());

    uint256 total = pair.totalSupply();
    uint256 perc = balance.mul(1e18).div(total);

    return [token0.balanceOf(lp).mul(perc).div(1e18), token1.balanceOf(lp).mul(perc).div(1e18)];
  }

  function swapExcessARTH(
    address me,
    address to,
    int128 tokenId, // 1 -> busd, 2 -> usdc, 3 -> usdt
    IEllipsisRouter ellipsis,
    IERC20 arth
  ) public {
    if (arth.balanceOf(me) > 0) {
      arth.approve(address(ellipsis), arth.balanceOf(me));
      ellipsis.sellARTHforToken(tokenId, arth.balanceOf(me), to, block.timestamp);
    }
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
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

import {ITroveManager} from "../interfaces/ITroveManager.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {LeverageAccount} from "../account/LeverageAccount.sol";

library TroveLibrary {
  using SafeMath for uint256;

  bytes4 private constant OPEN_LOAN_SELECTOR =
    bytes4(keccak256("openTrove(uint256,uint256,uint256,address,address,address)"));

  function openLoan(
    LeverageAccount acct,
    address borrowerOperations,
    uint256 maxFee,
    uint256 debt,
    uint256 collateralAmount,
    address upperHint,
    address lowerHint,
    address frontEndTag,
    IERC20 arth,
    IERC20 tokenB
  ) public {
    bytes memory openLoanData = abi.encodeWithSelector(
      OPEN_LOAN_SELECTOR,
      maxFee,
      Math.max(debt, 50 * 1e18),
      collateralAmount,
      upperHint,
      lowerHint,
      frontEndTag
    );

    // approve spending
    approveTokenViaAccount(acct, tokenB, borrowerOperations, collateralAmount);

    // open loan using the user's proxy
    acct.callFn(borrowerOperations, openLoanData);

    // // send the arth back to the flash loan contract to payback the flashloan
    uint256 arthBal = arth.balanceOf(address(acct));
    if (arthBal > 0) transferTokenViaAccount(acct, arth, address(this), arthBal);
  }

  function closeLoan(
    LeverageAccount acct,
    address controller,
    address borrowerOperations,
    uint256 availableARTH,
    IERC20 arth,
    IERC20 tokenB
  ) public {
    bytes memory closeLoanData = abi.encodeWithSignature("closeTrove()");

    // approve spending for controller (if polygon)
    if (controller != address(0)) approveTokenViaAccount(acct, arth, controller, availableARTH);

    // close loan using the user's account
    acct.callFn(borrowerOperations, closeLoanData);

    // send the arth back to the flash loan contract to payback the flashloan
    uint256 arthBal = arth.balanceOf(address(acct));
    if (arthBal > 0) transferTokenViaAccount(acct, arth, address(this), arthBal);

    // send the collateral back to the flash loan contract to payback the flashloan
    uint256 collBal = tokenB.balanceOf(address(acct));
    if (collBal > 0) transferTokenViaAccount(acct, tokenB, address(this), collBal);
  }

  function transferTokenViaAccount(
    LeverageAccount acct,
    IERC20 token,
    address who,
    uint256 amount
  ) internal {
    // send tokens back to the contract
    bytes memory transferData = abi.encodeWithSignature("transfer(address,uint256)", who, amount);
    acct.callFn(address(token), transferData);
  }

  function approveTokenViaAccount(
    LeverageAccount acct,
    IERC20 token,
    address who,
    uint256 amount
  ) internal {
    // send tokens back to the contract
    bytes memory transferData = abi.encodeWithSignature("approve(address,uint256)", who, amount);
    acct.callFn(address(token), transferData);
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IUniswapV2Router01 {
  function factory() external returns (address);

  function WETH() external returns (address);

  function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  )
    external
    returns (
      uint256 amountA,
      uint256 amountB,
      uint256 liquidity
    );

  function addLiquidityETH(
    address token,
    uint256 amountTokenDesired,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
    external
    payable
    returns (
      uint256 amountToken,
      uint256 amountETH,
      uint256 liquidity
    );

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETH(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountToken, uint256 amountETH);

  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETHWithPermit(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountToken, uint256 amountETH);

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactETHForTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function swapTokensForExactETH(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactTokensForETH(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapETHForExactTokens(
    uint256 amountOut,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function quote(
    uint256 amountA,
    uint256 reserveA,
    uint256 reserveB
  ) external pure returns (uint256 amountB);

  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountOut);

  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountIn);

  function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LeverageAccount.sol";

// LeverageAccountFactory
// This factory deploys new proxy instances through build()
// Deployed proxy addresses are logged
contract LeverageAccountFactory {
  event Created(address indexed sender, address indexed owner, address account);
  mapping(address => bool) public isAccount;

  // deploys a new proxy instance
  // sets owner of proxy to caller
  function build() public returns (address payable account) {
    account = build(msg.sender);
  }

  // deploys a new proxy instance
  // sets custom owner of proxy
  function build(address owner) public returns (address payable account) {
    account = payable(address(new LeverageAccount(owner)));
    emit Created(msg.sender, owner, address(account));
    isAccount[account] = true;
  }
}

// SPDX-License-Identifier: GNU-3

pragma solidity ^0.8.0;

import {ILeverageAccount} from "../interfaces/ILeverageAccount.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract LeverageAccount is AccessControl, ILeverageAccount {
  bytes32 public constant STRATEGY_ROLE = keccak256("STRATEGY_ROLE");

  constructor(address owner) {
    _setupRole(DEFAULT_ADMIN_ROLE, owner);
    _setRoleAdmin(STRATEGY_ROLE, DEFAULT_ADMIN_ROLE);
  }

  modifier onlyStrategiesOrAdmin() {
    require(_canExecute(msg.sender), "only strategies or owner.");
    _;
  }

  modifier onlyAdmin() {
    require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "only owner.");
    _;
  }

  function _canExecute(address who) internal view returns (bool) {
    return hasRole(STRATEGY_ROLE, who) || hasRole(DEFAULT_ADMIN_ROLE, who);
  }

  function canExecute(address who) external view override returns (bool) {
    return _canExecute(who);
  }

  function approveStrategy(address strategy) external override onlyAdmin {
    _grantRole(STRATEGY_ROLE, strategy);
  }

  function revokeStrategy(address strategy) external override onlyAdmin {
    _revokeRole(STRATEGY_ROLE, strategy);
  }

  function callFn(address target, bytes memory signature) external override onlyStrategiesOrAdmin {
    (bool success, bytes memory response) = target.call(signature);
    require(success, string(response));
  }
}

// SPDX-License-Identifier: GNU-3

pragma solidity ^0.8.0;

interface ILeverageAccount {
  function approveStrategy(address strategy) external;

  function revokeStrategy(address strategy) external;

  function callFn(address target, bytes memory signature) external;

  function canExecute(address who) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IUniswapV2Pair {
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);

  function name() external pure returns (string memory);

  function symbol() external pure returns (string memory);

  function decimals() external pure returns (uint8);

  function totalSupply() external view returns (uint256);

  function balanceOf(address owner) external view returns (uint256);

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 value) external returns (bool);

  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool);

  function DOMAIN_SEPARATOR() external view returns (bytes32);

  function PERMIT_TYPEHASH() external pure returns (bytes32);

  function nonces(address owner) external view returns (uint256);

  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  event Mint(address indexed sender, uint256 amount0, uint256 amount1);
  event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
  event Swap(
    address indexed sender,
    uint256 amount0In,
    uint256 amount1In,
    uint256 amount0Out,
    uint256 amount1Out,
    address indexed to
  );
  event Sync(uint112 reserve0, uint112 reserve1);

  function MINIMUM_LIQUIDITY() external pure returns (uint256);

  function factory() external view returns (address);

  function token0() external view returns (address);

  function token1() external view returns (address);

  function getReserves()
    external
    view
    returns (
      uint112 reserve0,
      uint112 reserve1,
      uint32 blockTimestampLast
    );

  function price0CumulativeLast() external view returns (uint256);

  function price1CumulativeLast() external view returns (uint256);

  function kLast() external view returns (uint256);

  function mint(address to) external returns (uint256 liquidity);

  function burn(address to) external returns (uint256 amount0, uint256 amount1);

  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;

  function skim(address to) external;

  function sync() external;

  function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}