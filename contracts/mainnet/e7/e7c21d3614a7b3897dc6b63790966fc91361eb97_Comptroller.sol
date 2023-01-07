// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import { ComptrollerInterface } from "./ComptrollerInterface.sol";
import { InterestRateModel } from "./InterestRateModel.sol";

contract CTokenAdminStorage {
  /*
   * Administrator for Fuse
   */
  address payable public fuseAdmin;

  /**
   * @dev LEGACY USE ONLY: Administrator for this contract
   */
  address payable internal __admin;

  /**
   * @dev LEGACY USE ONLY: Whether or not the Fuse admin has admin rights
   */
  bool internal __fuseAdminHasRights;

  /**
   * @dev LEGACY USE ONLY: Whether or not the admin has admin rights
   */
  bool internal __adminHasRights;
}

contract CTokenStorage is CTokenAdminStorage {
  /**
   * @dev Guard variable for re-entrancy checks
   */
  bool internal _notEntered;

  /**
   * @notice EIP-20 token name for this token
   */
  string public name;

  /**
   * @notice EIP-20 token symbol for this token
   */
  string public symbol;

  /**
   * @notice EIP-20 token decimals for this token
   */
  uint8 public decimals;

  /*
   * Maximum borrow rate that can ever be applied (.0005% / block)
   */
  uint256 internal constant borrowRateMaxMantissa = 0.0005e16;

  /*
   * Maximum fraction of interest that can be set aside for reserves + fees
   */
  uint256 internal constant reserveFactorPlusFeesMaxMantissa = 1e18;

  /*
   * LEGACY USE ONLY: Pending administrator for this contract
   */
  address payable private __pendingAdmin;

  /**
   * @notice Contract which oversees inter-cToken operations
   */
  ComptrollerInterface public comptroller;

  /**
   * @notice Model which tells what the current interest rate should be
   */
  InterestRateModel public interestRateModel;

  /*
   * Initial exchange rate used when minting the first CTokens (used when totalSupply = 0)
   */
  uint256 internal initialExchangeRateMantissa;

  /**
   * @notice Fraction of interest currently set aside for admin fees
   */
  uint256 public adminFeeMantissa;

  /**
   * @notice Fraction of interest currently set aside for Fuse fees
   */
  uint256 public fuseFeeMantissa;

  /**
   * @notice Fraction of interest currently set aside for reserves
   */
  uint256 public reserveFactorMantissa;

  /**
   * @notice Block number that interest was last accrued at
   */
  uint256 public accrualBlockNumber;

  /**
   * @notice Accumulator of the total earned interest rate since the opening of the market
   */
  uint256 public borrowIndex;

  /**
   * @notice Total amount of outstanding borrows of the underlying in this market
   */
  uint256 public totalBorrows;

  /**
   * @notice Total amount of reserves of the underlying held in this market
   */
  uint256 public totalReserves;

  /**
   * @notice Total amount of admin fees of the underlying held in this market
   */
  uint256 public totalAdminFees;

  /**
   * @notice Total amount of Fuse fees of the underlying held in this market
   */
  uint256 public totalFuseFees;

  /**
   * @notice Total number of tokens in circulation
   */
  uint256 public totalSupply;

  /*
   * Official record of token balances for each account
   */
  mapping(address => uint256) internal accountTokens;

  /*
   * Approved token transfer amounts on behalf of others
   */
  mapping(address => mapping(address => uint256)) internal transferAllowances;

  /**
   * @notice Container for borrow balance information
   * @member principal Total balance (with accrued interest), after applying the most recent balance-changing action
   * @member interestIndex Global borrowIndex as of the most recent balance-changing action
   */
  struct BorrowSnapshot {
    uint256 principal;
    uint256 interestIndex;
  }

  /*
   * Mapping of account addresses to outstanding borrow balances
   */
  mapping(address => BorrowSnapshot) internal accountBorrows;

  /*
   * Share of seized collateral that is added to reserves
   */
  uint256 public constant protocolSeizeShareMantissa = 2.8e16; //2.8%

  /*
   * Share of seized collateral taken as fees
   */
  uint256 public constant feeSeizeShareMantissa = 1e17; //10%
}

abstract contract CTokenBaseInterface is CTokenStorage {
  /* ERC20 */

  /**
   * @notice EIP20 Transfer event
   */
  event Transfer(address indexed from, address indexed to, uint256 amount);

  /*** Admin Events ***/

  /**
   * @notice Event emitted when interestRateModel is changed
   */
  event NewMarketInterestRateModel(InterestRateModel oldInterestRateModel, InterestRateModel newInterestRateModel);

  /**
   * @notice Event emitted when the reserve factor is changed
   */
  event NewReserveFactor(uint256 oldReserveFactorMantissa, uint256 newReserveFactorMantissa);

  /**
   * @notice Event emitted when the admin fee is changed
   */
  event NewAdminFee(uint256 oldAdminFeeMantissa, uint256 newAdminFeeMantissa);

  /**
   * @notice Event emitted when the Fuse fee is changed
   */
  event NewFuseFee(uint256 oldFuseFeeMantissa, uint256 newFuseFeeMantissa);

  /**
   * @notice EIP20 Approval event
   */
  event Approval(address indexed owner, address indexed spender, uint256 amount);

  /**
   * @notice Event emitted when interest is accrued
   */
  event AccrueInterest(uint256 cashPrior, uint256 interestAccumulated, uint256 borrowIndex, uint256 totalBorrows);
}

abstract contract CTokenExtensionInterface is CTokenBaseInterface {
  /*** User Interface ***/

  function transfer(address dst, uint256 amount) external virtual returns (bool);

  function transferFrom(
    address src,
    address dst,
    uint256 amount
  ) external virtual returns (bool);

  function approve(address spender, uint256 amount) external virtual returns (bool);

  function allowance(address owner, address spender) external view virtual returns (uint256);

  function balanceOf(address owner) external view virtual returns (uint256);

  /*** Admin Functions ***/

  function _setReserveFactor(uint256 newReserveFactorMantissa) external virtual returns (uint256);

  function _setAdminFee(uint256 newAdminFeeMantissa) external virtual returns (uint256);

  function _setInterestRateModel(InterestRateModel newInterestRateModel) external virtual returns (uint256);

  function borrowRatePerBlock() external view virtual returns (uint256);

  function supplyRatePerBlock() external view virtual returns (uint256);

  function exchangeRateCurrent() public virtual returns (uint256);

  function exchangeRateStored() public view virtual returns (uint256);

  function accrueInterest() public virtual returns (uint256);

  function totalBorrowsCurrent() external virtual returns (uint256);

  function balanceOfUnderlying(address owner) external virtual returns (uint256);

  function multicall(bytes[] calldata data) external payable virtual returns (bytes[] memory results);
}

abstract contract CTokenInterface is CTokenBaseInterface {
  function asCTokenExtensionInterface() public view returns (CTokenExtensionInterface) {
    return CTokenExtensionInterface(address(this));
  }

  /**
   * @notice Indicator that this is a CToken contract (for inspection)
   */
  function isCToken() external virtual returns (bool) {
    return true;
  }

  /**
   * @notice Indicator that this is or is not a CEther contract (for inspection)
   */
  function isCEther() external virtual returns (bool) {
    return false;
  }

  /*** Market Events ***/

  /**
   * @notice Event emitted when tokens are minted
   */
  event Mint(address minter, uint256 mintAmount, uint256 mintTokens);

  /**
   * @notice Event emitted when tokens are redeemed
   */
  event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemTokens);

  /**
   * @notice Event emitted when underlying is borrowed
   */
  event Borrow(address borrower, uint256 borrowAmount, uint256 accountBorrows, uint256 totalBorrows);

  /**
   * @notice Event emitted when a borrow is repaid
   */
  event RepayBorrow(address payer, address borrower, uint256 repayAmount, uint256 accountBorrows, uint256 totalBorrows);

  /**
   * @notice Event emitted when a borrow is liquidated
   */
  event LiquidateBorrow(
    address liquidator,
    address borrower,
    uint256 repayAmount,
    address cTokenCollateral,
    uint256 seizeTokens
  );

  /**
   * @notice Event emitted when the reserves are added
   */
  event ReservesAdded(address benefactor, uint256 addAmount, uint256 newTotalReserves);

  /**
   * @notice Event emitted when the reserves are reduced
   */
  event ReservesReduced(address admin, uint256 reduceAmount, uint256 newTotalReserves);

  function getAccountSnapshot(address account)
    external
    view
    virtual
    returns (
      uint256,
      uint256,
      uint256,
      uint256
    );

  function borrowBalanceCurrent(address account) external virtual returns (uint256);

  function borrowBalanceStored(address account) public view virtual returns (uint256);

  function getCash() external view virtual returns (uint256);

  function seize(
    address liquidator,
    address borrower,
    uint256 seizeTokens
  ) external virtual returns (uint256);

  /*** Admin Functions ***/

  function _withdrawAdminFees(uint256 withdrawAmount) external virtual returns (uint256);

  function _withdrawFuseFees(uint256 withdrawAmount) external virtual returns (uint256);
}

contract CErc20Storage is CTokenStorage {
  /**
   * @notice Underlying asset for this CToken
   */
  address public underlying;
}

abstract contract CErc20Interface is CTokenInterface, CErc20Storage {
  /*** User Interface ***/

  function mint(uint256 mintAmount) external virtual returns (uint256);

  function redeem(uint256 redeemTokens) external virtual returns (uint256);

  function redeemUnderlying(uint256 redeemAmount) external virtual returns (uint256);

  function borrow(uint256 borrowAmount) external virtual returns (uint256);

  function repayBorrow(uint256 repayAmount) external virtual returns (uint256);

  function repayBorrowBehalf(address borrower, uint256 repayAmount) external virtual returns (uint256);

  function liquidateBorrow(
    address borrower,
    uint256 repayAmount,
    CTokenInterface cTokenCollateral
  ) external virtual returns (uint256);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

/**
 * @title Careful Math
 * @author Compound
 * @notice Derived from OpenZeppelin's SafeMath library
 *         https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol
 */
contract CarefulMath {
  /**
   * @dev Possible error codes that we can return
   */
  enum MathError {
    NO_ERROR,
    DIVISION_BY_ZERO,
    INTEGER_OVERFLOW,
    INTEGER_UNDERFLOW
  }

  /**
   * @dev Multiplies two numbers, returns an error on overflow.
   */
  function mulUInt(uint256 a, uint256 b) internal pure returns (MathError, uint256) {
    if (a == 0) {
      return (MathError.NO_ERROR, 0);
    }

    uint256 c;
    unchecked {
      c = a * b;
    }

    if (c / a != b) {
      return (MathError.INTEGER_OVERFLOW, 0);
    } else {
      return (MathError.NO_ERROR, c);
    }
  }

  /**
   * @dev Integer division of two numbers, truncating the quotient.
   */
  function divUInt(uint256 a, uint256 b) internal pure returns (MathError, uint256) {
    if (b == 0) {
      return (MathError.DIVISION_BY_ZERO, 0);
    }

    return (MathError.NO_ERROR, a / b);
  }

  /**
   * @dev Subtracts two numbers, returns an error on overflow (i.e. if subtrahend is greater than minuend).
   */
  function subUInt(uint256 a, uint256 b) internal pure returns (MathError, uint256) {
    if (b <= a) {
      return (MathError.NO_ERROR, a - b);
    } else {
      return (MathError.INTEGER_UNDERFLOW, 0);
    }
  }

  /**
   * @dev Adds two numbers, returns an error on overflow.
   */
  function addUInt(uint256 a, uint256 b) internal pure returns (MathError, uint256) {
    uint256 c;
    unchecked {
      c = a + b;
    }

    if (c >= a) {
      return (MathError.NO_ERROR, c);
    } else {
      return (MathError.INTEGER_OVERFLOW, 0);
    }
  }

  /**
   * @dev add a and b and then subtract c
   */
  function addThenSubUInt(
    uint256 a,
    uint256 b,
    uint256 c
  ) internal pure returns (MathError, uint256) {
    (MathError err0, uint256 sum) = addUInt(a, b);

    if (err0 != MathError.NO_ERROR) {
      return (err0, 0);
    }

    return subUInt(sum, c);
  }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import { CTokenInterface, CErc20Interface } from "./CTokenInterfaces.sol";
import { ComptrollerErrorReporter } from "./ErrorReporter.sol";
import { Exponential } from "./Exponential.sol";
import { PriceOracle } from "./PriceOracle.sol";
import { ComptrollerInterface } from "./ComptrollerInterface.sol";
import { ComptrollerV3Storage } from "./ComptrollerStorage.sol";
import { Unitroller } from "./Unitroller.sol";
import { IFuseFeeDistributor } from "./IFuseFeeDistributor.sol";
import { IMidasFlywheel } from "../midas/strategies/flywheel/IMidasFlywheel.sol";
import { DiamondExtension, DiamondBase, LibDiamond } from "../midas/DiamondExtension.sol";
import { ComptrollerFirstExtension } from "../compound/ComptrollerFirstExtension.sol";

/**
 * @title Compound's Comptroller Contract
 * @author Compound
 * @dev This contract should not to be deployed alone; instead, deploy `Unitroller` (proxy contract) on top of this `Comptroller` (logic/implementation contract).
 */
contract Comptroller is ComptrollerV3Storage, ComptrollerInterface, ComptrollerErrorReporter, Exponential, DiamondBase {
  /// @notice Emitted when an admin supports a market
  event MarketListed(CTokenInterface cToken);

  /// @notice Emitted when an account enters a market
  event MarketEntered(CTokenInterface cToken, address account);

  /// @notice Emitted when an account exits a market
  event MarketExited(CTokenInterface cToken, address account);

  /// @notice Emitted when close factor is changed by admin
  event NewCloseFactor(uint256 oldCloseFactorMantissa, uint256 newCloseFactorMantissa);

  /// @notice Emitted when a collateral factor is changed by admin
  event NewCollateralFactor(
    CTokenInterface cToken,
    uint256 oldCollateralFactorMantissa,
    uint256 newCollateralFactorMantissa
  );

  /// @notice Emitted when liquidation incentive is changed by admin
  event NewLiquidationIncentive(uint256 oldLiquidationIncentiveMantissa, uint256 newLiquidationIncentiveMantissa);

  /// @notice Emitted when price oracle is changed
  event NewPriceOracle(PriceOracle oldPriceOracle, PriceOracle newPriceOracle);

  /// @notice Emitted when the whitelist enforcement is changed
  event WhitelistEnforcementChanged(bool enforce);

  /// @notice Emitted when auto implementations are toggled
  event AutoImplementationsToggled(bool enabled);

  /// @notice Emitted when a new RewardsDistributor contract is added to hooks
  event AddedRewardsDistributor(address rewardsDistributor);

  // closeFactorMantissa must be strictly greater than this value
  uint256 internal constant closeFactorMinMantissa = 0.05e18; // 0.05

  // closeFactorMantissa must not exceed this value
  uint256 internal constant closeFactorMaxMantissa = 0.9e18; // 0.9

  // No collateralFactorMantissa may exceed this value
  uint256 internal constant collateralFactorMaxMantissa = 0.9e18; // 0.9

  // liquidationIncentiveMantissa must be no less than this value
  uint256 internal constant liquidationIncentiveMinMantissa = 1.0e18; // 1.0

  // liquidationIncentiveMantissa must be no greater than this value
  uint256 internal constant liquidationIncentiveMaxMantissa = 1.5e18; // 1.5

  constructor(address payable _fuseAdmin) {
    fuseAdmin = _fuseAdmin;
  }

  /*** Assets You Are In ***/

  /**
   * @notice Returns the assets an account has entered
   * @param account The address of the account to pull assets for
   * @return A dynamic list with the assets the account has entered
   */
  function getAssetsIn(address account) external view returns (CTokenInterface[] memory) {
    CTokenInterface[] memory assetsIn = accountAssets[account];

    return assetsIn;
  }

  /**
   * @notice Returns whether the given account is entered in the given asset
   * @param account The address of the account to check
   * @param cToken The cToken to check
   * @return True if the account is in the asset, otherwise false.
   */
  function checkMembership(address account, CTokenInterface cToken) external view returns (bool) {
    return markets[address(cToken)].accountMembership[account];
  }

  /**
   * @notice Add assets to be included in account liquidity calculation
   * @param cTokens The list of addresses of the cToken markets to be enabled
   * @return Success indicator for whether each corresponding market was entered
   */
  function enterMarkets(address[] memory cTokens) public override returns (uint256[] memory) {
    uint256 len = cTokens.length;

    uint256[] memory results = new uint256[](len);
    for (uint256 i = 0; i < len; i++) {
      CTokenInterface cToken = CTokenInterface(cTokens[i]);

      results[i] = uint256(addToMarketInternal(cToken, msg.sender));
    }

    return results;
  }

  /**
   * @notice Add the market to the borrower's "assets in" for liquidity calculations
   * @param cToken The market to enter
   * @param borrower The address of the account to modify
   * @return Success indicator for whether the market was entered
   */
  function addToMarketInternal(CTokenInterface cToken, address borrower) internal returns (Error) {
    Market storage marketToJoin = markets[address(cToken)];

    if (!marketToJoin.isListed) {
      // market is not listed, cannot join
      return Error.MARKET_NOT_LISTED;
    }

    if (marketToJoin.accountMembership[borrower] == true) {
      // already joined
      return Error.NO_ERROR;
    }

    // survived the gauntlet, add to list
    // NOTE: we store these somewhat redundantly as a significant optimization
    //  this avoids having to iterate through the list for the most common use cases
    //  that is, only when we need to perform liquidity checks
    //  and not whenever we want to check if an account is in a particular market
    marketToJoin.accountMembership[borrower] = true;
    accountAssets[borrower].push(cToken);

    // Add to allBorrowers
    if (!borrowers[borrower]) {
      allBorrowers.push(borrower);
      borrowers[borrower] = true;
      borrowerIndexes[borrower] = allBorrowers.length - 1;
    }

    emit MarketEntered(cToken, borrower);

    return Error.NO_ERROR;
  }

  /**
   * @notice Removes asset from sender's account liquidity calculation
   * @dev Sender must not have an outstanding borrow balance in the asset,
   *  or be providing necessary collateral for an outstanding borrow.
   * @param cTokenAddress The address of the asset to be removed
   * @return Whether or not the account successfully exited the market
   */
  function exitMarket(address cTokenAddress) external override returns (uint256) {
    CTokenInterface cToken = CTokenInterface(cTokenAddress);
    /* Get sender tokensHeld and amountOwed underlying from the cToken */
    (uint256 oErr, uint256 tokensHeld, uint256 amountOwed, ) = cToken.getAccountSnapshot(msg.sender);
    require(oErr == 0, "!exitMarket"); // semi-opaque error code

    /* Fail if the sender has a borrow balance */
    if (amountOwed != 0) {
      return fail(Error.NONZERO_BORROW_BALANCE, FailureInfo.EXIT_MARKET_BALANCE_OWED);
    }

    /* Fail if the sender is not permitted to redeem all of their tokens */
    uint256 allowed = redeemAllowedInternal(cTokenAddress, msg.sender, tokensHeld);
    if (allowed != 0) {
      return failOpaque(Error.REJECTION, FailureInfo.EXIT_MARKET_REJECTION, allowed);
    }

    Market storage marketToExit = markets[address(cToken)];

    /* Return true if the sender is not already ‘in’ the market */
    if (!marketToExit.accountMembership[msg.sender]) {
      return uint256(Error.NO_ERROR);
    }

    /* Set cToken account membership to false */
    delete marketToExit.accountMembership[msg.sender];

    /* Delete cToken from the account’s list of assets */
    // load into memory for faster iteration
    CTokenInterface[] memory userAssetList = accountAssets[msg.sender];
    uint256 len = userAssetList.length;
    uint256 assetIndex = len;
    for (uint256 i = 0; i < len; i++) {
      if (userAssetList[i] == cToken) {
        assetIndex = i;
        break;
      }
    }

    // We *must* have found the asset in the list or our redundant data structure is broken
    assert(assetIndex < len);

    // copy last item in list to location of item to be removed, reduce length by 1
    CTokenInterface[] storage storedList = accountAssets[msg.sender];
    storedList[assetIndex] = storedList[storedList.length - 1];
    storedList.pop();

    // If the user has exited all markets, remove them from the `allBorrowers` array
    if (storedList.length == 0) {
      allBorrowers[borrowerIndexes[msg.sender]] = allBorrowers[allBorrowers.length - 1]; // Copy last item in list to location of item to be removed
      allBorrowers.pop(); // Reduce length by 1
      borrowerIndexes[allBorrowers[borrowerIndexes[msg.sender]]] = borrowerIndexes[msg.sender]; // Set borrower index of moved item to correct index
      borrowerIndexes[msg.sender] = 0; // Reset sender borrower index to 0 for a gas refund
      borrowers[msg.sender] = false; // Tell the contract that the sender is no longer a borrower (so it knows to add the borrower back if they enter a market in the future)
    }

    emit MarketExited(cToken, msg.sender);

    return uint256(Error.NO_ERROR);
  }

  /*** Policy Hooks ***/

  /**
   * @notice Checks if the account should be allowed to mint tokens in the given market
   * @param cToken The market to verify the mint against
   * @param minter The account which would get the minted tokens
   * @param mintAmount The amount of underlying being supplied to the market in exchange for tokens
   * @return 0 if the mint is allowed, otherwise a semi-opaque error code (See ErrorReporter.sol)
   */
  function mintAllowed(
    address cToken,
    address minter,
    uint256 mintAmount
  ) external override returns (uint256) {
    // Pausing is a very serious situation - we revert to sound the alarms
    require(!mintGuardianPaused[cToken], "!mint:paused");

    // Shh - currently unused
    minter;
    mintAmount;

    // Make sure market is listed
    if (!markets[cToken].isListed) {
      return uint256(Error.MARKET_NOT_LISTED);
    }

    // Make sure minter is whitelisted
    if (enforceWhitelist && !whitelist[minter]) {
      return uint256(Error.SUPPLIER_NOT_WHITELISTED);
    }

    // Check supply cap
    uint256 supplyCap = supplyCaps[cToken];
    // Supply cap of 0 corresponds to unlimited supplying
    if (supplyCap != 0) {
      uint256 totalCash = CTokenInterface(cToken).getCash();
      uint256 totalBorrows = CTokenInterface(cToken).totalBorrows();
      uint256 totalReserves = CTokenInterface(cToken).totalReserves();
      uint256 totalFuseFees = CTokenInterface(cToken).totalFuseFees();
      uint256 totalAdminFees = CTokenInterface(cToken).totalAdminFees();

      // totalUnderlyingSupply = totalCash + totalBorrows - (totalReserves + totalFuseFees + totalAdminFees)
      (MathError mathErr, uint256 totalUnderlyingSupply) = addThenSubUInt(
        totalCash,
        totalBorrows,
        add_(add_(totalReserves, totalFuseFees), totalAdminFees)
      );
      if (mathErr != MathError.NO_ERROR) return uint256(Error.MATH_ERROR);

      uint256 nextTotalUnderlyingSupply;
      (mathErr, nextTotalUnderlyingSupply) = addUInt(totalUnderlyingSupply, mintAmount);
      if (mathErr != MathError.NO_ERROR) return uint256(Error.MATH_ERROR);

      require(nextTotalUnderlyingSupply < supplyCap, "!supply cap");
    }

    // Keep the flywheel moving
    flywheelPreSupplierAction(cToken, minter);

    return uint256(Error.NO_ERROR);
  }

  /**
   * @notice Checks if the account should be allowed to redeem tokens in the given market
   * @param cToken The market to verify the redeem against
   * @param redeemer The account which would redeem the tokens
   * @param redeemTokens The number of cTokens to exchange for the underlying asset in the market
   * @return 0 if the redeem is allowed, otherwise a semi-opaque error code (See ErrorReporter.sol)
   */
  function redeemAllowed(
    address cToken,
    address redeemer,
    uint256 redeemTokens
  ) external override returns (uint256) {
    uint256 allowed = redeemAllowedInternal(cToken, redeemer, redeemTokens);
    if (allowed != uint256(Error.NO_ERROR)) {
      return allowed;
    }

    // Keep the flywheel moving
    flywheelPreSupplierAction(cToken, redeemer);

    return uint256(Error.NO_ERROR);
  }

  function redeemAllowedInternal(
    address cToken,
    address redeemer,
    uint256 redeemTokens
  ) internal view returns (uint256) {
    if (!markets[cToken].isListed) {
      return uint256(Error.MARKET_NOT_LISTED);
    }

    /* If the redeemer is not 'in' the market, then we can bypass the liquidity check */
    if (!markets[cToken].accountMembership[redeemer]) {
      return uint256(Error.NO_ERROR);
    }

    /* Otherwise, perform a hypothetical liquidity check to guard against shortfall */
    (Error err, , uint256 shortfall) = getHypotheticalAccountLiquidityInternal(
      redeemer,
      CTokenInterface(cToken),
      redeemTokens,
      0
    );
    if (err != Error.NO_ERROR) {
      return uint256(err);
    }
    if (shortfall > 0) {
      return uint256(Error.INSUFFICIENT_LIQUIDITY);
    }

    return uint256(Error.NO_ERROR);
  }

  /**
   * @notice Validates redeem and reverts on rejection. May emit logs.
   * @param cToken Asset being redeemed
   * @param redeemer The address redeeming the tokens
   * @param redeemAmount The amount of the underlying asset being redeemed
   * @param redeemTokens The number of tokens being redeemed
   */
  function redeemVerify(
    address cToken,
    address redeemer,
    uint256 redeemAmount,
    uint256 redeemTokens
  ) external override {
    // Shh - currently unused
    cToken;
    redeemer;

    // Require tokens is zero or amount is also zero
    if (redeemTokens == 0 && redeemAmount > 0) {
      revert("!zero");
    }
  }

  function getMaxRedeemOrBorrow(
    address account,
    address cToken,
    bool isBorrow
  ) external override returns (uint256) {
    CTokenInterface cTokenModify = CTokenInterface(cToken);
    // Accrue interest
    uint256 balanceOfUnderlying = cTokenModify.asCTokenExtensionInterface().balanceOfUnderlying(account);

    // Get account liquidity
    (Error err, uint256 liquidity, uint256 shortfall) = getHypotheticalAccountLiquidityInternal(
      account,
      isBorrow ? cTokenModify : CTokenInterface(address(0)),
      0,
      0
    );
    require(err == Error.NO_ERROR, "!liquidity");
    if (shortfall > 0) return 0; // Shortfall, so no more borrow/redeem

    // Get max borrow/redeem
    uint256 maxBorrowOrRedeemAmount;

    if (!isBorrow && !markets[cToken].accountMembership[account]) {
      // Max redeem = balance of underlying if not used as collateral
      maxBorrowOrRedeemAmount = balanceOfUnderlying;
    } else {
      // Avoid "stack too deep" error by separating this logic
      maxBorrowOrRedeemAmount = _getMaxRedeemOrBorrow(liquidity, cTokenModify, isBorrow);

      // Redeem only: max out at underlying balance
      if (!isBorrow && balanceOfUnderlying < maxBorrowOrRedeemAmount) maxBorrowOrRedeemAmount = balanceOfUnderlying;
    }

    // Get max borrow or redeem considering cToken liquidity
    uint256 cTokenLiquidity = cTokenModify.getCash();

    // Return the minimum of the two maximums
    return maxBorrowOrRedeemAmount <= cTokenLiquidity ? maxBorrowOrRedeemAmount : cTokenLiquidity;
  }

  /**
   * @dev Portion of the logic in `getMaxRedeemOrBorrow` above separated to avoid "stack too deep" errors.
   */
  function _getMaxRedeemOrBorrow(
    uint256 liquidity,
    CTokenInterface cTokenModify,
    bool isBorrow
  ) internal view returns (uint256) {
    if (liquidity == 0) return 0; // No available account liquidity, so no more borrow/redeem

    // Get the normalized price of the asset
    uint256 conversionFactor = oracle.getUnderlyingPrice(cTokenModify);
    require(conversionFactor > 0, "!oracle");

    // Pre-compute a conversion factor from tokens -> ether (normalized price value)
    if (!isBorrow) {
      uint256 collateralFactorMantissa = markets[address(cTokenModify)].collateralFactorMantissa;
      conversionFactor = (collateralFactorMantissa * conversionFactor) / 1e18;
    }

    // Get max borrow or redeem considering excess account liquidity
    return (liquidity * 1e18) / conversionFactor;
  }

  /**
   * @notice Checks if the account should be allowed to borrow the underlying asset of the given market
   * @param cToken The market to verify the borrow against
   * @param borrower The account which would borrow the asset
   * @param borrowAmount The amount of underlying the account would borrow
   * @return 0 if the borrow is allowed, otherwise a semi-opaque error code (See ErrorReporter.sol)
   */
  function borrowAllowed(
    address cToken,
    address borrower,
    uint256 borrowAmount
  ) external override returns (uint256) {
    // Pausing is a very serious situation - we revert to sound the alarms
    require(!borrowGuardianPaused[cToken], "!borrow:paused");

    // Make sure market is listed
    if (!markets[cToken].isListed) {
      return uint256(Error.MARKET_NOT_LISTED);
    }

    if (!markets[cToken].accountMembership[borrower]) {
      // only cTokens may call borrowAllowed if borrower not in market
      require(msg.sender == cToken, "!ctoken");

      // attempt to add borrower to the market
      Error err = addToMarketInternal(CTokenInterface(msg.sender), borrower);
      if (err != Error.NO_ERROR) {
        return uint256(err);
      }

      // it should be impossible to break the important invariant
      assert(markets[cToken].accountMembership[borrower]);
    }

    // Make sure oracle price is available
    if (oracle.getUnderlyingPrice(CTokenInterface(cToken)) == 0) {
      return uint256(Error.PRICE_ERROR);
    }

    // Make sure borrower is whitelisted
    if (enforceWhitelist && !whitelist[borrower]) {
      return uint256(Error.SUPPLIER_NOT_WHITELISTED);
    }

    // Check borrow cap
    uint256 borrowCap = borrowCaps[cToken];
    // Borrow cap of 0 corresponds to unlimited borrowing
    if (borrowCap != 0) {
      uint256 totalBorrows = CTokenInterface(cToken).totalBorrows();
      (MathError mathErr, uint256 nextTotalBorrows) = addUInt(totalBorrows, borrowAmount);
      if (mathErr != MathError.NO_ERROR) return uint256(Error.MATH_ERROR);
      require(nextTotalBorrows < borrowCap, "!borrow:cap");
    }

    // Keep the flywheel moving
    flywheelPreBorrowerAction(cToken, borrower);

    // Perform a hypothetical liquidity check to guard against shortfall
    (Error err, , uint256 shortfall) = getHypotheticalAccountLiquidityInternal(
      borrower,
      CTokenInterface(cToken),
      0,
      borrowAmount
    );
    if (err != Error.NO_ERROR) {
      return uint256(err);
    }
    if (shortfall > 0) {
      return uint256(Error.INSUFFICIENT_LIQUIDITY);
    }

    return uint256(Error.NO_ERROR);
  }

  /**
   * @notice Checks if the account should be allowed to borrow the underlying asset of the given market
   * @param cToken Asset whose underlying is being borrowed
   * @param accountBorrowsNew The user's new borrow balance of the underlying asset
   */
  function borrowWithinLimits(address cToken, uint256 accountBorrowsNew) external view override returns (uint256) {
    // Check if min borrow exists
    uint256 minBorrowEth = IFuseFeeDistributor(fuseAdmin).minBorrowEth();

    if (minBorrowEth > 0) {
      // Get new underlying borrow balance of account for this cToken
      uint256 oraclePriceMantissa = oracle.getUnderlyingPrice(CTokenInterface(cToken));
      if (oraclePriceMantissa == 0) return uint256(Error.PRICE_ERROR);
      (MathError mathErr, uint256 borrowBalanceEth) = mulScalarTruncate(
        Exp({ mantissa: oraclePriceMantissa }),
        accountBorrowsNew
      );
      if (mathErr != MathError.NO_ERROR) return uint256(Error.MATH_ERROR);

      // Check against min borrow
      if (borrowBalanceEth < minBorrowEth) return uint256(Error.BORROW_BELOW_MIN);
    }

    // Return no error
    return uint256(Error.NO_ERROR);
  }

  /**
   * @notice Checks if the account should be allowed to repay a borrow in the given market
   * @param cToken The market to verify the repay against
   * @param payer The account which would repay the asset
   * @param borrower The account which would borrowed the asset
   * @param repayAmount The amount of the underlying asset the account would repay
   * @return 0 if the repay is allowed, otherwise a semi-opaque error code (See ErrorReporter.sol)
   */
  function repayBorrowAllowed(
    address cToken,
    address payer,
    address borrower,
    uint256 repayAmount
  ) external override returns (uint256) {
    // Shh - currently unused
    payer;
    borrower;
    repayAmount;

    // Make sure market is listed
    if (!markets[cToken].isListed) {
      return uint256(Error.MARKET_NOT_LISTED);
    }

    // Keep the flywheel moving
    flywheelPreBorrowerAction(cToken, borrower);

    return uint256(Error.NO_ERROR);
  }

  /**
   * @notice Checks if the liquidation should be allowed to occur
   * @param cTokenBorrowed Asset which was borrowed by the borrower
   * @param cTokenCollateral Asset which was used as collateral and will be seized
   * @param liquidator The address repaying the borrow and seizing the collateral
   * @param borrower The address of the borrower
   * @param repayAmount The amount of underlying being repaid
   */
  function liquidateBorrowAllowed(
    address cTokenBorrowed,
    address cTokenCollateral,
    address liquidator,
    address borrower,
    uint256 repayAmount
  ) external override returns (uint256) {
    // Shh - currently unused
    liquidator;

    // Make sure markets are listed
    if (!markets[cTokenBorrowed].isListed || !markets[cTokenCollateral].isListed) {
      return uint256(Error.MARKET_NOT_LISTED);
    }

    // Get borrowers's underlying borrow balance
    uint256 borrowBalance = CTokenInterface(cTokenBorrowed).borrowBalanceStored(borrower);

    /* allow accounts to be liquidated if the market is deprecated */
    if (isDeprecated(CTokenInterface(cTokenBorrowed))) {
      require(borrowBalance >= repayAmount, "!borrow>repay");
    } else {
      /* The borrower must have shortfall in order to be liquidatable */
      (Error err, , uint256 shortfall) = getHypotheticalAccountLiquidityInternal(
        borrower,
        CTokenInterface(address(0)),
        0,
        0
      );
      if (err != Error.NO_ERROR) {
        return uint256(err);
      }

      if (shortfall == 0) {
        return uint256(Error.INSUFFICIENT_SHORTFALL);
      }

      /* The liquidator may not repay more than what is allowed by the closeFactor */
      uint256 maxClose = mul_ScalarTruncate(Exp({ mantissa: closeFactorMantissa }), borrowBalance);
      if (repayAmount > maxClose) {
        return uint256(Error.TOO_MUCH_REPAY);
      }
    }

    return uint256(Error.NO_ERROR);
  }

  /**
   * @notice Checks if the seizing of assets should be allowed to occur
   * @param cTokenCollateral Asset which was used as collateral and will be seized
   * @param cTokenBorrowed Asset which was borrowed by the borrower
   * @param liquidator The address repaying the borrow and seizing the collateral
   * @param borrower The address of the borrower
   * @param seizeTokens The number of collateral tokens to seize
   */
  function seizeAllowed(
    address cTokenCollateral,
    address cTokenBorrowed,
    address liquidator,
    address borrower,
    uint256 seizeTokens
  ) external override returns (uint256) {
    // Pausing is a very serious situation - we revert to sound the alarms
    require(!seizeGuardianPaused, "!seize:paused");

    // Shh - currently unused
    liquidator;
    borrower;
    seizeTokens;

    // Make sure markets are listed
    if (!markets[cTokenCollateral].isListed || !markets[cTokenBorrowed].isListed) {
      return uint256(Error.MARKET_NOT_LISTED);
    }

    // Make sure cToken Comptrollers are identical
    if (CTokenInterface(cTokenCollateral).comptroller() != CTokenInterface(cTokenBorrowed).comptroller()) {
      return uint256(Error.COMPTROLLER_MISMATCH);
    }

    // Keep the flywheel moving
    flywheelPreTransferAction(cTokenCollateral, borrower, liquidator);

    return uint256(Error.NO_ERROR);
  }

  /**
   * @notice Checks if the account should be allowed to transfer tokens in the given market
   * @param cToken The market to verify the transfer against
   * @param src The account which sources the tokens
   * @param dst The account which receives the tokens
   * @param transferTokens The number of cTokens to transfer
   * @return 0 if the transfer is allowed, otherwise a semi-opaque error code (See ErrorReporter.sol)
   */
  function transferAllowed(
    address cToken,
    address src,
    address dst,
    uint256 transferTokens
  ) external override returns (uint256) {
    // Pausing is a very serious situation - we revert to sound the alarms
    require(!transferGuardianPaused, "!transfer:paused");

    // Currently the only consideration is whether or not
    //  the src is allowed to redeem this many tokens
    uint256 allowed = redeemAllowedInternal(cToken, src, transferTokens);
    if (allowed != uint256(Error.NO_ERROR)) {
      return allowed;
    }

    // Keep the flywheel moving
    flywheelPreTransferAction(cToken, src, dst);

    return uint256(Error.NO_ERROR);
  }

  /*** Flywheel Hooks ***/

  /**
   * @notice Keeps the flywheel moving pre-mint and pre-redeem
   * @param cToken The relevant market
   * @param supplier The minter/redeemer
   */
  function flywheelPreSupplierAction(address cToken, address supplier) internal {
    for (uint256 i = 0; i < rewardsDistributors.length; i++)
      IMidasFlywheel(rewardsDistributors[i]).flywheelPreSupplierAction(cToken, supplier);
  }

  /**
   * @notice Keeps the flywheel moving pre-borrow and pre-repay
   * @param cToken The relevant market
   * @param borrower The borrower
   */
  function flywheelPreBorrowerAction(address cToken, address borrower) internal {
    for (uint256 i = 0; i < rewardsDistributors.length; i++)
      IMidasFlywheel(rewardsDistributors[i]).flywheelPreBorrowerAction(cToken, borrower);
  }

  /**
   * @notice Keeps the flywheel moving pre-transfer and pre-seize
   * @param cToken The relevant market
   * @param src The account which sources the tokens
   * @param dst The account which receives the tokens
   */
  function flywheelPreTransferAction(
    address cToken,
    address src,
    address dst
  ) internal {
    for (uint256 i = 0; i < rewardsDistributors.length; i++)
      IMidasFlywheel(rewardsDistributors[i]).flywheelPreTransferAction(cToken, src, dst);
  }

  /*** Liquidity/Liquidation Calculations ***/

  /**
   * @dev Local vars for avoiding stack-depth limits in calculating account liquidity.
   *  Note that `cTokenBalance` is the number of cTokens the account owns in the market,
   *  whereas `borrowBalance` is the amount of underlying that the account has borrowed.
   */
  struct AccountLiquidityLocalVars {
    uint256 sumCollateral;
    uint256 sumBorrowPlusEffects;
    uint256 cTokenBalance;
    uint256 borrowBalance;
    uint256 exchangeRateMantissa;
    uint256 oraclePriceMantissa;
    Exp collateralFactor;
    Exp exchangeRate;
    Exp oraclePrice;
    Exp tokensToDenom;
    uint256 totalBorrowCapForCollateral;
    uint256 totalBorrowsBefore;
    uint256 borrowedAssetPrice;
  }

  function getAccountLiquidity(address account)
    public
    view
    override
    returns (
      uint256,
      uint256,
      uint256
    )
  {
    (Error err, uint256 liquidity, uint256 shortfall) = getHypotheticalAccountLiquidityInternal(
      account,
      CTokenInterface(address(0)),
      0,
      0
    );
    return (uint256(err), liquidity, shortfall);
  }

  /**
     * @notice Determine what the account liquidity would be if the given amounts were redeemed/borrowed
     * @param cTokenModify The market to hypothetically redeem/borrow in
     * @param account The account to determine liquidity for
     * @param redeemTokens The number of tokens to hypothetically redeem
     * @param borrowAmount The amount of underlying to hypothetically borrow
     * @return (possible error code (semi-opaque),
                hypothetical account liquidity in excess of collateral requirements,
     *          hypothetical account shortfall below collateral requirements)
     */
  function getHypotheticalAccountLiquidity(
    address account,
    address cTokenModify,
    uint256 redeemTokens,
    uint256 borrowAmount
  )
    public
    view
    returns (
      uint256,
      uint256,
      uint256
    )
  {
    (Error err, uint256 liquidity, uint256 shortfall) = getHypotheticalAccountLiquidityInternal(
      account,
      CTokenInterface(cTokenModify),
      redeemTokens,
      borrowAmount
    );
    return (uint256(err), liquidity, shortfall);
  }

  /**
     * @notice Determine what the account liquidity would be if the given amounts were redeemed/borrowed
     * @param cTokenModify The market to hypothetically redeem/borrow in
     * @param account The account to determine liquidity for
     * @param redeemTokens The number of tokens to hypothetically redeem
     * @param borrowAmount The amount of underlying to hypothetically borrow
     * @dev Note that we calculate the exchangeRateStored for each collateral cToken using stored data,
     *  without calculating accumulated interest.
     * @return (possible error code,
                hypothetical account liquidity in excess of collateral requirements,
     *          hypothetical account shortfall below collateral requirements)
     */
  function getHypotheticalAccountLiquidityInternal(
    address account,
    CTokenInterface cTokenModify,
    uint256 redeemTokens,
    uint256 borrowAmount
  )
    internal
    view
    returns (
      Error,
      uint256,
      uint256
    )
  {
    AccountLiquidityLocalVars memory vars; // Holds all our calculation results
    uint256 oErr;

    if (address(cTokenModify) != address(0)) {
      vars.totalBorrowsBefore = cTokenModify.totalBorrows();
      vars.borrowedAssetPrice = oracle.getUnderlyingPrice(cTokenModify);
    }

    // For each asset the account is in
    CTokenInterface[] memory assets = accountAssets[account];
    for (uint256 i = 0; i < assets.length; i++) {
      CTokenInterface asset = assets[i];

      // Read the balances and exchange rate from the cToken
      (oErr, vars.cTokenBalance, vars.borrowBalance, vars.exchangeRateMantissa) = asset.getAccountSnapshot(account);
      if (oErr != 0) {
        // semi-opaque error code, we assume NO_ERROR == 0 is invariant between upgrades
        return (Error.SNAPSHOT_ERROR, 0, 0);
      }
      vars.collateralFactor = Exp({ mantissa: markets[address(asset)].collateralFactorMantissa });
      vars.exchangeRate = Exp({ mantissa: vars.exchangeRateMantissa });

      // Get the normalized price of the asset
      vars.oraclePriceMantissa = oracle.getUnderlyingPrice(asset);
      if (vars.oraclePriceMantissa == 0) {
        return (Error.PRICE_ERROR, 0, 0);
      }
      vars.oraclePrice = Exp({ mantissa: vars.oraclePriceMantissa });

      // Pre-compute a conversion factor from tokens -> ether (normalized price value)
      vars.tokensToDenom = mul_(mul_(vars.collateralFactor, vars.exchangeRate), vars.oraclePrice);

      uint256 assetAsCollateralValueCap = type(uint256).max;
      // Exclude the asset-to-be-borrowed from the liquidity, except for when redeeming
      if (address(asset) != address(cTokenModify) || redeemTokens > 0) {
        // if the borrowed asset is capped against this collateral
        if (address(cTokenModify) != address(0)) {
          bool blacklisted = borrowingAgainstCollateralBlacklist[address(cTokenModify)][address(asset)];
          if (blacklisted) {
            assetAsCollateralValueCap = 0;
          } else {
            // the value of the collateral is capped regardless if any amount is to be borrowed
            vars.totalBorrowCapForCollateral = borrowCapForAssetForCollateral[address(cTokenModify)][address(asset)];
            // check if set to any value
            if (vars.totalBorrowCapForCollateral != 0) {
              // check for underflow
              if (vars.totalBorrowCapForCollateral >= vars.totalBorrowsBefore) {
                uint256 borrowAmountCap = vars.totalBorrowCapForCollateral - vars.totalBorrowsBefore;
                assetAsCollateralValueCap = (borrowAmountCap * vars.borrowedAssetPrice) / 1e18;
              } else {
                // should never happen, but better to not revert on this underflow
                assetAsCollateralValueCap = 0;
              }
            }
          }
        }

        // accumulate the collateral value to sumCollateral
        uint256 assetCollateralValue = mul_ScalarTruncate(vars.tokensToDenom, vars.cTokenBalance);
        if (assetCollateralValue > assetAsCollateralValueCap) assetCollateralValue = assetAsCollateralValueCap;
        vars.sumCollateral += assetCollateralValue;
      }

      // sumBorrowPlusEffects += oraclePrice * borrowBalance
      vars.sumBorrowPlusEffects = mul_ScalarTruncateAddUInt(
        vars.oraclePrice,
        vars.borrowBalance,
        vars.sumBorrowPlusEffects
      );

      // Calculate effects of interacting with cTokenModify
      if (asset == cTokenModify) {
        // redeem effect
        // sumBorrowPlusEffects += tokensToDenom * redeemTokens
        vars.sumBorrowPlusEffects = mul_ScalarTruncateAddUInt(
          vars.tokensToDenom,
          redeemTokens,
          vars.sumBorrowPlusEffects
        );

        // borrow effect
        // sumBorrowPlusEffects += oraclePrice * borrowAmount
        vars.sumBorrowPlusEffects = mul_ScalarTruncateAddUInt(
          vars.oraclePrice,
          borrowAmount,
          vars.sumBorrowPlusEffects
        );
      }
    }

    // These are safe, as the underflow condition is checked first
    if (vars.sumCollateral > vars.sumBorrowPlusEffects) {
      return (Error.NO_ERROR, vars.sumCollateral - vars.sumBorrowPlusEffects, 0);
    } else {
      return (Error.NO_ERROR, 0, vars.sumBorrowPlusEffects - vars.sumCollateral);
    }
  }

  /**
   * @notice Calculate number of tokens of collateral asset to seize given an underlying amount
   * @dev Used in liquidation (called in cToken.liquidateBorrowFresh)
   * @param cTokenBorrowed The address of the borrowed cToken
   * @param cTokenCollateral The address of the collateral cToken
   * @param actualRepayAmount The amount of cTokenBorrowed underlying to convert into cTokenCollateral tokens
   * @return (errorCode, number of cTokenCollateral tokens to be seized in a liquidation)
   */
  function liquidateCalculateSeizeTokens(
    address cTokenBorrowed,
    address cTokenCollateral,
    uint256 actualRepayAmount
  ) external view override returns (uint256, uint256) {
    /* Read oracle prices for borrowed and collateral markets */
    uint256 priceBorrowedMantissa = oracle.getUnderlyingPrice(CTokenInterface(cTokenBorrowed));
    uint256 priceCollateralMantissa = oracle.getUnderlyingPrice(CTokenInterface(cTokenCollateral));
    if (priceBorrowedMantissa == 0 || priceCollateralMantissa == 0) {
      return (uint256(Error.PRICE_ERROR), 0);
    }

    /*
     * Get the exchange rate and calculate the number of collateral tokens to seize:
     *  seizeAmount = actualRepayAmount * liquidationIncentive * priceBorrowed / priceCollateral
     *  seizeTokens = seizeAmount / exchangeRate
     *   = actualRepayAmount * (liquidationIncentive * priceBorrowed) / (priceCollateral * exchangeRate)
     */
    CTokenInterface collateralCToken = CTokenInterface(cTokenCollateral);
    uint256 exchangeRateMantissa = collateralCToken.asCTokenExtensionInterface().exchangeRateStored(); // Note: reverts on error
    uint256 seizeTokens;
    Exp memory numerator;
    Exp memory denominator;
    Exp memory ratio;

    uint256 protocolSeizeShareMantissa = collateralCToken.protocolSeizeShareMantissa();
    uint256 feeSeizeShareMantissa = collateralCToken.feeSeizeShareMantissa();

    /*
     * The liquidation penalty includes
     * - the liquidator incentive
     * - the protocol fees (fuse admin fees)
     * - the market fee
     */
    Exp memory totalPenaltyMantissa = add_(
      add_(Exp({ mantissa: liquidationIncentiveMantissa }), Exp({ mantissa: protocolSeizeShareMantissa })),
      Exp({ mantissa: feeSeizeShareMantissa })
    );

    numerator = mul_(totalPenaltyMantissa, Exp({ mantissa: priceBorrowedMantissa }));
    denominator = mul_(Exp({ mantissa: priceCollateralMantissa }), Exp({ mantissa: exchangeRateMantissa }));
    ratio = div_(numerator, denominator);

    seizeTokens = mul_ScalarTruncate(ratio, actualRepayAmount);
    return (uint256(Error.NO_ERROR), seizeTokens);
  }

  /*** Admin Functions ***/

  /**
   * @notice Add a RewardsDistributor contracts.
   * @dev Admin function to add a RewardsDistributor contract
   * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
   */
  function _addRewardsDistributor(address distributor) external returns (uint256) {
    // Check caller is admin
    if (!hasAdminRights()) {
      return fail(Error.UNAUTHORIZED, FailureInfo.ADD_REWARDS_DISTRIBUTOR_OWNER_CHECK);
    }

    // Check marker method
    require(IMidasFlywheel(distributor).isRewardsDistributor(), "!isRewardsDistributor");

    // Check for existing RewardsDistributor
    for (uint256 i = 0; i < rewardsDistributors.length; i++) require(distributor != rewardsDistributors[i], "!added");

    // Add RewardsDistributor to array
    rewardsDistributors.push(distributor);
    emit AddedRewardsDistributor(distributor);

    return uint256(Error.NO_ERROR);
  }

  /**
   * @notice Sets the whitelist enforcement for the comptroller
   * @dev Admin function to set a new whitelist enforcement boolean
   * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
   */
  function _setWhitelistEnforcement(bool enforce) external returns (uint256) {
    // Check caller is admin
    if (!hasAdminRights()) {
      return fail(Error.UNAUTHORIZED, FailureInfo.SET_WHITELIST_ENFORCEMENT_OWNER_CHECK);
    }

    // Check if `enforceWhitelist` already equals `enforce`
    if (enforceWhitelist == enforce) {
      return uint256(Error.NO_ERROR);
    }

    // Set comptroller's `enforceWhitelist` to `enforce`
    enforceWhitelist = enforce;

    // Emit WhitelistEnforcementChanged(bool enforce);
    emit WhitelistEnforcementChanged(enforce);

    return uint256(Error.NO_ERROR);
  }

  /**
   * @notice Sets the whitelist `statuses` for `suppliers`
   * @dev Admin function to set the whitelist `statuses` for `suppliers`
   * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
   */
  function _setWhitelistStatuses(address[] calldata suppliers, bool[] calldata statuses) external returns (uint256) {
    // Check caller is admin
    if (!hasAdminRights()) {
      return fail(Error.UNAUTHORIZED, FailureInfo.SET_WHITELIST_STATUS_OWNER_CHECK);
    }

    // Set whitelist statuses for suppliers
    for (uint256 i = 0; i < suppliers.length; i++) {
      address supplier = suppliers[i];

      if (statuses[i]) {
        // If not already whitelisted, add to whitelist
        if (!whitelist[supplier]) {
          whitelist[supplier] = true;
          whitelistArray.push(supplier);
          whitelistIndexes[supplier] = whitelistArray.length - 1;
        }
      } else {
        // If whitelisted, remove from whitelist
        if (whitelist[supplier]) {
          whitelistArray[whitelistIndexes[supplier]] = whitelistArray[whitelistArray.length - 1]; // Copy last item in list to location of item to be removed
          whitelistArray.pop(); // Reduce length by 1
          whitelistIndexes[whitelistArray[whitelistIndexes[supplier]]] = whitelistIndexes[supplier]; // Set whitelist index of moved item to correct index
          whitelistIndexes[supplier] = 0; // Reset supplier whitelist index to 0 for a gas refund
          whitelist[supplier] = false; // Tell the contract that the supplier is no longer whitelisted
        }
      }
    }

    return uint256(Error.NO_ERROR);
  }

  /**
   * @notice Sets a new price oracle for the comptroller
   * @dev Admin function to set a new price oracle
   * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
   */
  function _setPriceOracle(PriceOracle newOracle) public returns (uint256) {
    // Check caller is admin
    if (!hasAdminRights()) {
      return fail(Error.UNAUTHORIZED, FailureInfo.SET_PRICE_ORACLE_OWNER_CHECK);
    }

    // Track the old oracle for the comptroller
    PriceOracle oldOracle = oracle;

    // Set comptroller's oracle to newOracle
    oracle = newOracle;

    // Emit NewPriceOracle(oldOracle, newOracle)
    emit NewPriceOracle(oldOracle, newOracle);

    return uint256(Error.NO_ERROR);
  }

  /**
   * @notice Sets the closeFactor used when liquidating borrows
   * @dev Admin function to set closeFactor
   * @param newCloseFactorMantissa New close factor, scaled by 1e18
   * @return uint 0=success, otherwise a failure. (See ErrorReporter for details)
   */
  function _setCloseFactor(uint256 newCloseFactorMantissa) external returns (uint256) {
    // Check caller is admin
    if (!hasAdminRights()) {
      return fail(Error.UNAUTHORIZED, FailureInfo.SET_CLOSE_FACTOR_OWNER_CHECK);
    }

    // Check limits
    Exp memory newCloseFactorExp = Exp({ mantissa: newCloseFactorMantissa });
    Exp memory lowLimit = Exp({ mantissa: closeFactorMinMantissa });
    if (lessThanOrEqualExp(newCloseFactorExp, lowLimit)) {
      return fail(Error.INVALID_CLOSE_FACTOR, FailureInfo.SET_CLOSE_FACTOR_VALIDATION);
    }

    Exp memory highLimit = Exp({ mantissa: closeFactorMaxMantissa });
    if (lessThanExp(highLimit, newCloseFactorExp)) {
      return fail(Error.INVALID_CLOSE_FACTOR, FailureInfo.SET_CLOSE_FACTOR_VALIDATION);
    }

    // Set pool close factor to new close factor, remember old value
    uint256 oldCloseFactorMantissa = closeFactorMantissa;
    closeFactorMantissa = newCloseFactorMantissa;

    // Emit event
    emit NewCloseFactor(oldCloseFactorMantissa, closeFactorMantissa);

    return uint256(Error.NO_ERROR);
  }

  /**
   * @notice Sets the collateralFactor for a market
   * @dev Admin function to set per-market collateralFactor
   * @param cToken The market to set the factor on
   * @param newCollateralFactorMantissa The new collateral factor, scaled by 1e18
   * @return uint 0=success, otherwise a failure. (See ErrorReporter for details)
   */
  function _setCollateralFactor(CTokenInterface cToken, uint256 newCollateralFactorMantissa) public returns (uint256) {
    // Check caller is admin
    if (!hasAdminRights()) {
      return fail(Error.UNAUTHORIZED, FailureInfo.SET_COLLATERAL_FACTOR_OWNER_CHECK);
    }

    // Verify market is listed
    Market storage market = markets[address(cToken)];
    if (!market.isListed) {
      return fail(Error.MARKET_NOT_LISTED, FailureInfo.SET_COLLATERAL_FACTOR_NO_EXISTS);
    }

    Exp memory newCollateralFactorExp = Exp({ mantissa: newCollateralFactorMantissa });

    // Check collateral factor <= 0.9
    Exp memory highLimit = Exp({ mantissa: collateralFactorMaxMantissa });
    if (lessThanExp(highLimit, newCollateralFactorExp)) {
      return fail(Error.INVALID_COLLATERAL_FACTOR, FailureInfo.SET_COLLATERAL_FACTOR_VALIDATION);
    }

    // If collateral factor != 0, fail if price == 0
    if (newCollateralFactorMantissa != 0 && oracle.getUnderlyingPrice(cToken) == 0) {
      return fail(Error.PRICE_ERROR, FailureInfo.SET_COLLATERAL_FACTOR_WITHOUT_PRICE);
    }

    // Set market's collateral factor to new collateral factor, remember old value
    uint256 oldCollateralFactorMantissa = market.collateralFactorMantissa;
    market.collateralFactorMantissa = newCollateralFactorMantissa;

    // Emit event with asset, old collateral factor, and new collateral factor
    emit NewCollateralFactor(cToken, oldCollateralFactorMantissa, newCollateralFactorMantissa);

    return uint256(Error.NO_ERROR);
  }

  /**
   * @notice Sets liquidationIncentive
   * @dev Admin function to set liquidationIncentive
   * @param newLiquidationIncentiveMantissa New liquidationIncentive scaled by 1e18
   * @return uint 0=success, otherwise a failure. (See ErrorReporter for details)
   */
  function _setLiquidationIncentive(uint256 newLiquidationIncentiveMantissa) external returns (uint256) {
    // Check caller is admin
    if (!hasAdminRights()) {
      return fail(Error.UNAUTHORIZED, FailureInfo.SET_LIQUIDATION_INCENTIVE_OWNER_CHECK);
    }

    // Check de-scaled min <= newLiquidationIncentive <= max
    Exp memory newLiquidationIncentive = Exp({ mantissa: newLiquidationIncentiveMantissa });
    Exp memory minLiquidationIncentive = Exp({ mantissa: liquidationIncentiveMinMantissa });
    if (lessThanExp(newLiquidationIncentive, minLiquidationIncentive)) {
      return fail(Error.INVALID_LIQUIDATION_INCENTIVE, FailureInfo.SET_LIQUIDATION_INCENTIVE_VALIDATION);
    }

    Exp memory maxLiquidationIncentive = Exp({ mantissa: liquidationIncentiveMaxMantissa });
    if (lessThanExp(maxLiquidationIncentive, newLiquidationIncentive)) {
      return fail(Error.INVALID_LIQUIDATION_INCENTIVE, FailureInfo.SET_LIQUIDATION_INCENTIVE_VALIDATION);
    }

    // Save current value for use in log
    uint256 oldLiquidationIncentiveMantissa = liquidationIncentiveMantissa;

    // Set liquidation incentive to new incentive
    liquidationIncentiveMantissa = newLiquidationIncentiveMantissa;

    // Emit event with old incentive, new incentive
    emit NewLiquidationIncentive(oldLiquidationIncentiveMantissa, newLiquidationIncentiveMantissa);

    return uint256(Error.NO_ERROR);
  }

  /**
   * @notice Add the market to the markets mapping and set it as listed
   * @dev Admin function to set isListed and add support for the market
   * @param cToken The address of the market (token) to list
   * @return uint 0=success, otherwise a failure. (See enum Error for details)
   */
  function _supportMarket(CTokenInterface cToken) internal returns (uint256) {
    // Check caller is admin
    if (!hasAdminRights()) {
      return fail(Error.UNAUTHORIZED, FailureInfo.SUPPORT_MARKET_OWNER_CHECK);
    }

    // Is market already listed?
    if (markets[address(cToken)].isListed) {
      return fail(Error.MARKET_ALREADY_LISTED, FailureInfo.SUPPORT_MARKET_EXISTS);
    }
    // Sanity check to make sure its really a CToken
    require(cToken.isCToken(), "!market:isctoken");

    // Check cToken.comptroller == this
    require(address(cToken.comptroller()) == address(this), "!comptroller");

    // Make sure market is not already listed
    address underlying = CErc20Interface(address(cToken)).underlying();

    if (address(cTokensByUnderlying[underlying]) != address(0)) {
      return fail(Error.MARKET_ALREADY_LISTED, FailureInfo.SUPPORT_MARKET_EXISTS);
    }

    // List market and emit event
    Market storage market = markets[address(cToken)];
    market.isListed = true;
    market.collateralFactorMantissa = 0;
    allMarkets.push(cToken);
    cTokensByUnderlying[underlying] = cToken;
    emit MarketListed(cToken);

    return uint256(Error.NO_ERROR);
  }

  /**
   * @notice Deploy cToken, add the market to the markets mapping, and set it as listed and set the collateral factor
   * @dev Admin function to deploy cToken, set isListed, and add support for the market and set the collateral factor
   * @return uint 0=success, otherwise a failure. (See enum Error for details)
   */
  function _deployMarket(
    bool isCEther,
    bytes calldata constructorData,
    uint256 collateralFactorMantissa
  ) external returns (uint256) {
    // Check caller is admin
    if (!hasAdminRights()) {
      return fail(Error.UNAUTHORIZED, FailureInfo.SUPPORT_MARKET_OWNER_CHECK);
    }

    // Temporarily enable Fuse admin rights for asset deployment (storing the original value)
    bool oldFuseAdminHasRights = fuseAdminHasRights;
    fuseAdminHasRights = true;

    // Deploy via Fuse admin
    CTokenInterface cToken = CTokenInterface(IFuseFeeDistributor(fuseAdmin).deployCErc20(constructorData));
    // Reset Fuse admin rights to the original value
    fuseAdminHasRights = oldFuseAdminHasRights;
    // Support market here in the Comptroller
    uint256 err = _supportMarket(cToken);

    // Set collateral factor
    return err == uint256(Error.NO_ERROR) ? _setCollateralFactor(cToken, collateralFactorMantissa) : err;
  }

  /**
   * @notice Toggles the auto-implementation feature
   * @param enabled If the feature is to be enabled
   * @return uint 0=success, otherwise a failure. (See enum Error for details)
   */
  function _toggleAutoImplementations(bool enabled) public returns (uint256) {
    if (!hasAdminRights()) {
      return fail(Error.UNAUTHORIZED, FailureInfo.TOGGLE_AUTO_IMPLEMENTATIONS_ENABLED_OWNER_CHECK);
    }

    // Return no error if already set to the desired value
    if (autoImplementation == enabled) return uint256(Error.NO_ERROR);

    // Store autoImplementation with value enabled
    autoImplementation = enabled;

    // Emit AutoImplementationsToggled(enabled)
    emit AutoImplementationsToggled(enabled);

    return uint256(Error.NO_ERROR);
  }

  function _become(Unitroller unitroller) public {
    require(
      (msg.sender == address(fuseAdmin) && unitroller.fuseAdminHasRights()) ||
        (msg.sender == unitroller.admin() && unitroller.adminHasRights()),
      "!admin"
    );

    uint256 changeStatus = unitroller._acceptImplementation();
    require(changeStatus == 0, "!unauthorized - not pending impl");

    Comptroller(payable(address(unitroller)))._becomeImplementation();
  }

  function _becomeImplementation() external {
    require(msg.sender == comptrollerImplementation, "!implementation");

    address[] memory currentExtensions = LibDiamond.listExtensions();
    for (uint256 i = 0; i < currentExtensions.length; i++) {
      LibDiamond.removeExtension(DiamondExtension(currentExtensions[i]));
    }

    address[] memory latestExtensions = IFuseFeeDistributor(fuseAdmin).getComptrollerExtensions(
      comptrollerImplementation
    );
    for (uint256 i = 0; i < latestExtensions.length; i++) {
      LibDiamond.addExtension(DiamondExtension(latestExtensions[i]));
    }

    if (!_notEnteredInitialized) {
      _notEntered = true;
      _notEnteredInitialized = true;
    }
  }

  /**
   * @dev register a logic extension
   * @param extensionToAdd the extension whose functions are to be added
   * @param extensionToReplace the extension whose functions are to be removed/replaced
   */
  function _registerExtension(DiamondExtension extensionToAdd, DiamondExtension extensionToReplace) external override {
    require(msg.sender == address(fuseAdmin) && fuseAdminHasRights, "!unauthorized - no admin rights");
    LibDiamond.registerExtension(extensionToAdd, extensionToReplace);
  }

  /*** Helper Functions ***/

  /**
   * @notice Returns true if the given cToken market has been deprecated
   * @dev All borrows in a deprecated cToken market can be immediately liquidated
   * @param cToken The market to check if deprecated
   */
  function isDeprecated(CTokenInterface cToken) public view returns (bool) {
    return
      markets[address(cToken)].collateralFactorMantissa == 0 &&
      borrowGuardianPaused[address(cToken)] == true &&
      add_(add_(cToken.reserveFactorMantissa(), cToken.adminFeeMantissa()), cToken.fuseFeeMantissa()) == 1e18;
  }

  function asComptrollerFirstExtension() public view returns (ComptrollerFirstExtension) {
    return ComptrollerFirstExtension(address(this));
  }

  /*** Pool-Wide/Cross-Asset Reentrancy Prevention ***/

  /**
   * @dev Called by cTokens before a non-reentrant function for pool-wide reentrancy prevention.
   * Prevents pool-wide/cross-asset reentrancy exploits like AMP on Cream.
   */
  function _beforeNonReentrant() external override {
    require(markets[msg.sender].isListed, "!Comptroller:_beforeNonReentrant");
    require(_notEntered, "!reentered");
    _notEntered = false;
  }

  /**
   * @dev Called by cTokens after a non-reentrant function for pool-wide reentrancy prevention.
   * Prevents pool-wide/cross-asset reentrancy exploits like AMP on Cream.
   */
  function _afterNonReentrant() external override {
    require(markets[msg.sender].isListed, "!Comptroller:_afterNonReentrant");
    _notEntered = true; // get a gas-refund post-Istanbul
  }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import { DiamondExtension } from "../midas/DiamondExtension.sol";
import { ComptrollerErrorReporter } from "../compound/ErrorReporter.sol";
import { CTokenInterface, CErc20Interface } from "./CTokenInterfaces.sol";
import { ComptrollerV3Storage } from "./ComptrollerStorage.sol";

contract ComptrollerFirstExtension is DiamondExtension, ComptrollerV3Storage, ComptrollerErrorReporter {
  /// @notice Emitted when supply cap for a cToken is changed
  event NewSupplyCap(CTokenInterface indexed cToken, uint256 newSupplyCap);

  /// @notice Emitted when borrow cap for a cToken is changed
  event NewBorrowCap(CTokenInterface indexed cToken, uint256 newBorrowCap);

  /// @notice Emitted when borrow cap guardian is changed
  event NewBorrowCapGuardian(address oldBorrowCapGuardian, address newBorrowCapGuardian);

  /// @notice Emitted when pause guardian is changed
  event NewPauseGuardian(address oldPauseGuardian, address newPauseGuardian);

  /// @notice Emitted when an action is paused globally
  event ActionPaused(string action, bool pauseState);

  /// @notice Emitted when an action is paused on a market
  event MarketActionPaused(CTokenInterface cToken, string action, bool pauseState);

  /// @notice Emitted when an admin unsupports a market
  event MarketUnlisted(CTokenInterface cToken);

  /**
   * @notice Returns true if the accruing flyhwheel was found and replaced
   * @dev Adds a flywheel to the non-accruing list and if already in the accruing, removes it from that list
   * @param flywheelAddress The address of the flywheel to add to the non-accruing
   */
  function addNonAccruingFlywheel(address flywheelAddress) external returns (bool) {
    require(hasAdminRights(), "!admin");
    require(flywheelAddress != address(0), "!flywheel");

    for (uint256 i = 0; i < nonAccruingRewardsDistributors.length; i++) {
      require(flywheelAddress != nonAccruingRewardsDistributors[i], "!alreadyadded");
    }

    // add it to the non-accruing
    nonAccruingRewardsDistributors.push(flywheelAddress);

    // remove it from the accruing
    for (uint256 i = 0; i < rewardsDistributors.length; i++) {
      if (flywheelAddress == rewardsDistributors[i]) {
        rewardsDistributors[i] = rewardsDistributors[rewardsDistributors.length - 1];
        rewardsDistributors.pop();
        return true;
      }
    }

    return false;
  }

  /**
   * @notice Set the given supply caps for the given cToken markets. Supplying that brings total underlying supply to or above supply cap will revert.
   * @dev Admin or borrowCapGuardian function to set the supply caps. A supply cap of 0 corresponds to unlimited supplying.
   * @param cTokens The addresses of the markets (tokens) to change the supply caps for
   * @param newSupplyCaps The new supply cap values in underlying to be set. A value of 0 corresponds to unlimited supplying.
   */
  function _setMarketSupplyCaps(CTokenInterface[] calldata cTokens, uint256[] calldata newSupplyCaps) external {
    require(msg.sender == admin || msg.sender == borrowCapGuardian, "!admin");

    uint256 numMarkets = cTokens.length;
    uint256 numSupplyCaps = newSupplyCaps.length;

    require(numMarkets != 0 && numMarkets == numSupplyCaps, "!input");

    for (uint256 i = 0; i < numMarkets; i++) {
      supplyCaps[address(cTokens[i])] = newSupplyCaps[i];
      emit NewSupplyCap(cTokens[i], newSupplyCaps[i]);
    }
  }

  /**
   * @notice Set the given borrow caps for the given cToken markets. Borrowing that brings total borrows to or above borrow cap will revert.
   * @dev Admin or borrowCapGuardian function to set the borrow caps. A borrow cap of 0 corresponds to unlimited borrowing.
   * @param cTokens The addresses of the markets (tokens) to change the borrow caps for
   * @param newBorrowCaps The new borrow cap values in underlying to be set. A value of 0 corresponds to unlimited borrowing.
   */
  function _setMarketBorrowCaps(CTokenInterface[] calldata cTokens, uint256[] calldata newBorrowCaps) external {
    require(msg.sender == admin || msg.sender == borrowCapGuardian, "!admin");

    uint256 numMarkets = cTokens.length;
    uint256 numBorrowCaps = newBorrowCaps.length;

    require(numMarkets != 0 && numMarkets == numBorrowCaps, "!input");

    for (uint256 i = 0; i < numMarkets; i++) {
      borrowCaps[address(cTokens[i])] = newBorrowCaps[i];
      emit NewBorrowCap(cTokens[i], newBorrowCaps[i]);
    }
  }

  /**
   * @notice Admin function to change the Borrow Cap Guardian
   * @param newBorrowCapGuardian The address of the new Borrow Cap Guardian
   */
  function _setBorrowCapGuardian(address newBorrowCapGuardian) external {
    require(msg.sender == admin, "!admin");

    // Save current value for inclusion in log
    address oldBorrowCapGuardian = borrowCapGuardian;

    // Store borrowCapGuardian with value newBorrowCapGuardian
    borrowCapGuardian = newBorrowCapGuardian;

    // Emit NewBorrowCapGuardian(OldBorrowCapGuardian, NewBorrowCapGuardian)
    emit NewBorrowCapGuardian(oldBorrowCapGuardian, newBorrowCapGuardian);
  }

  /**
   * @notice Admin function to change the Pause Guardian
   * @param newPauseGuardian The address of the new Pause Guardian
   * @return uint 0=success, otherwise a failure. (See enum Error for details)
   */
  function _setPauseGuardian(address newPauseGuardian) public returns (uint256) {
    if (!hasAdminRights()) {
      return fail(Error.UNAUTHORIZED, FailureInfo.SET_PAUSE_GUARDIAN_OWNER_CHECK);
    }

    // Save current value for inclusion in log
    address oldPauseGuardian = pauseGuardian;

    // Store pauseGuardian with value newPauseGuardian
    pauseGuardian = newPauseGuardian;

    // Emit NewPauseGuardian(OldPauseGuardian, NewPauseGuardian)
    emit NewPauseGuardian(oldPauseGuardian, pauseGuardian);

    return uint256(Error.NO_ERROR);
  }

  function _setMintPaused(CTokenInterface cToken, bool state) public returns (bool) {
    require(markets[address(cToken)].isListed, "!market");
    require(msg.sender == pauseGuardian || hasAdminRights(), "!gaurdian");
    require(hasAdminRights() || state == true, "!admin");

    mintGuardianPaused[address(cToken)] = state;
    emit MarketActionPaused(cToken, "Mint", state);
    return state;
  }

  function _setBorrowPaused(CTokenInterface cToken, bool state) public returns (bool) {
    require(markets[address(cToken)].isListed, "!market");
    require(msg.sender == pauseGuardian || hasAdminRights(), "!guardian");
    require(hasAdminRights() || state == true, "!admin");

    borrowGuardianPaused[address(cToken)] = state;
    emit MarketActionPaused(cToken, "Borrow", state);
    return state;
  }

  function _setTransferPaused(bool state) public returns (bool) {
    require(msg.sender == pauseGuardian || hasAdminRights(), "!guardian");
    require(hasAdminRights() || state == true, "!admin");

    transferGuardianPaused = state;
    emit ActionPaused("Transfer", state);
    return state;
  }

  function _setSeizePaused(bool state) public returns (bool) {
    require(msg.sender == pauseGuardian || hasAdminRights(), "!guardian");
    require(hasAdminRights() || state == true, "!admin");

    seizeGuardianPaused = state;
    emit ActionPaused("Seize", state);
    return state;
  }

  /**
   * @notice Removed a market from the markets mapping and sets it as unlisted
   * @dev Admin function unset isListed and collateralFactorMantissa and unadd support for the market
   * @param cToken The address of the market (token) to unlist
   * @return uint 0=success, otherwise a failure. (See enum Error for details)
   */
  function _unsupportMarket(CTokenInterface cToken) external returns (uint256) {
    // Check admin rights
    if (!hasAdminRights()) return fail(Error.UNAUTHORIZED, FailureInfo.UNSUPPORT_MARKET_OWNER_CHECK);

    // Check if market is already unlisted
    if (!markets[address(cToken)].isListed)
      return fail(Error.MARKET_NOT_LISTED, FailureInfo.UNSUPPORT_MARKET_DOES_NOT_EXIST);

    // Check if market is in use
    if (cToken.totalSupply() > 0) return fail(Error.NONZERO_TOTAL_SUPPLY, FailureInfo.UNSUPPORT_MARKET_IN_USE);

    // Unlist market
    delete markets[address(cToken)];

    /* Delete cToken from allMarkets */
    // load into memory for faster iteration
    CTokenInterface[] memory _allMarkets = allMarkets;
    uint256 len = _allMarkets.length;
    uint256 assetIndex = len;
    for (uint256 i = 0; i < len; i++) {
      if (_allMarkets[i] == cToken) {
        assetIndex = i;
        break;
      }
    }

    // We *must* have found the asset in the list or our redundant data structure is broken
    assert(assetIndex < len);

    // copy last item in list to location of item to be removed, reduce length by 1
    allMarkets[assetIndex] = allMarkets[allMarkets.length - 1];
    allMarkets.pop();

    cTokensByUnderlying[CErc20Interface(address(cToken)).underlying()] = CTokenInterface(address(0));
    emit MarketUnlisted(cToken);

    return uint256(Error.NO_ERROR);
  }

  function _setBorrowCapForAssetForCollateral(
    address cTokenBorrow,
    address cTokenCollateral,
    uint256 borrowCap
  ) public {
    require(hasAdminRights(), "!admin");
    borrowCapForAssetForCollateral[cTokenBorrow][cTokenCollateral] = borrowCap;
  }

  function _blacklistBorrowingAgainstCollateral(
    address cTokenBorrow,
    address cTokenCollateral,
    bool blacklisted
  ) public {
    require(hasAdminRights(), "!admin");
    borrowingAgainstCollateralBlacklist[cTokenBorrow][cTokenCollateral] = blacklisted;
    borrowCapForAssetForCollateral[cTokenBorrow][cTokenCollateral] = 0;
  }

  function _getExtensionFunctions() external view virtual override returns (bytes4[] memory) {
    uint8 fnsCount = 19;
    bytes4[] memory functionSelectors = new bytes4[](fnsCount);
    functionSelectors[--fnsCount] = this.addNonAccruingFlywheel.selector;
    functionSelectors[--fnsCount] = this._setMarketSupplyCaps.selector;
    functionSelectors[--fnsCount] = this._setMarketBorrowCaps.selector;
    functionSelectors[--fnsCount] = this._setBorrowCapGuardian.selector;
    functionSelectors[--fnsCount] = this._setPauseGuardian.selector;
    functionSelectors[--fnsCount] = this._setMintPaused.selector;
    functionSelectors[--fnsCount] = this._setBorrowPaused.selector;
    functionSelectors[--fnsCount] = this._setTransferPaused.selector;
    functionSelectors[--fnsCount] = this._setSeizePaused.selector;
    functionSelectors[--fnsCount] = this._unsupportMarket.selector;
    functionSelectors[--fnsCount] = this.getAllMarkets.selector;
    functionSelectors[--fnsCount] = this.getAllBorrowers.selector;
    functionSelectors[--fnsCount] = this.getWhitelist.selector;
    functionSelectors[--fnsCount] = this.getRewardsDistributors.selector;
    functionSelectors[--fnsCount] = this.isUserOfPool.selector;
    functionSelectors[--fnsCount] = this.getAccruingFlywheels.selector;
    functionSelectors[--fnsCount] = this._removeFlywheel.selector;
    functionSelectors[--fnsCount] = this._setBorrowCapForAssetForCollateral.selector;
    functionSelectors[--fnsCount] = this._blacklistBorrowingAgainstCollateral.selector;
    require(fnsCount == 0, "use the correct array length");
    return functionSelectors;
  }

  /**
   * @notice Return all of the markets
   * @dev The automatic getter may be used to access an individual market.
   * @return The list of market addresses
   */
  function getAllMarkets() public view returns (CTokenInterface[] memory) {
    return allMarkets;
  }

  /**
   * @notice Return all of the borrowers
   * @dev The automatic getter may be used to access an individual borrower.
   * @return The list of borrower account addresses
   */
  function getAllBorrowers() public view returns (address[] memory) {
    return allBorrowers;
  }

  /**
   * @notice Return all of the whitelist
   * @dev The automatic getter may be used to access an individual whitelist status.
   * @return The list of borrower account addresses
   */
  function getWhitelist() external view returns (address[] memory) {
    return whitelistArray;
  }

  /**
   * @notice Returns an array of all accruing and non-accruing flywheels
   */
  function getRewardsDistributors() external view returns (address[] memory) {
    address[] memory allFlywheels = new address[](rewardsDistributors.length + nonAccruingRewardsDistributors.length);

    uint8 i = 0;
    while (i < rewardsDistributors.length) {
      allFlywheels[i] = rewardsDistributors[i];
      i++;
    }
    uint8 j = 0;
    while (j < nonAccruingRewardsDistributors.length) {
      allFlywheels[i + j] = nonAccruingRewardsDistributors[j];
      j++;
    }

    return allFlywheels;
  }

  function getAccruingFlywheels() external view returns (address[] memory) {
    return rewardsDistributors;
  }

  /**
   * @dev Removes a flywheel from the accruing or non-accruing array
   * @param flywheelAddress The address of the flywheel to remove from the accruing or non-accruing array
   * @return true if the flywheel was found and removed
   */
  function _removeFlywheel(address flywheelAddress) external returns (bool) {
    require(hasAdminRights(), "!admin");
    require(flywheelAddress != address(0), "!flywheel");

    // remove it from the accruing
    for (uint256 i = 0; i < rewardsDistributors.length; i++) {
      if (flywheelAddress == rewardsDistributors[i]) {
        rewardsDistributors[i] = rewardsDistributors[rewardsDistributors.length - 1];
        rewardsDistributors.pop();
        return true;
      }
    }

    // or remove it from the non-accruing
    for (uint256 i = 0; i < nonAccruingRewardsDistributors.length; i++) {
      if (flywheelAddress == nonAccruingRewardsDistributors[i]) {
        nonAccruingRewardsDistributors[i] = nonAccruingRewardsDistributors[nonAccruingRewardsDistributors.length - 1];
        nonAccruingRewardsDistributors.pop();
        return true;
      }
    }

    return false;
  }

  function isUserOfPool(address user) external view returns (bool) {
    for (uint256 i = 0; i < allMarkets.length; i++) {
      address marketAddress = address(allMarkets[i]);
      if (markets[marketAddress].accountMembership[user]) {
        return true;
      }
    }

    return false;
  }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

abstract contract ComptrollerInterface {
  /// @notice Indicator that this is a Comptroller contract (for inspection)
  bool public constant isComptroller = true;

  function getMaxRedeemOrBorrow(
    address account,
    address cToken,
    bool isBorrow
  ) external virtual returns (uint256);

  /*** Assets You Are In ***/

  function enterMarkets(address[] calldata cTokens) external virtual returns (uint256[] memory);

  function exitMarket(address cToken) external virtual returns (uint256);

  /*** Policy Hooks ***/

  function mintAllowed(
    address cToken,
    address minter,
    uint256 mintAmount
  ) external virtual returns (uint256);

  function redeemAllowed(
    address cToken,
    address redeemer,
    uint256 redeemTokens
  ) external virtual returns (uint256);

  function redeemVerify(
    address cToken,
    address redeemer,
    uint256 redeemAmount,
    uint256 redeemTokens
  ) external virtual;

  function borrowAllowed(
    address cToken,
    address borrower,
    uint256 borrowAmount
  ) external virtual returns (uint256);

  function borrowWithinLimits(address cToken, uint256 accountBorrowsNew) external view virtual returns (uint256);

  function repayBorrowAllowed(
    address cToken,
    address payer,
    address borrower,
    uint256 repayAmount
  ) external virtual returns (uint256);

  function liquidateBorrowAllowed(
    address cTokenBorrowed,
    address cTokenCollateral,
    address liquidator,
    address borrower,
    uint256 repayAmount
  ) external virtual returns (uint256);

  function seizeAllowed(
    address cTokenCollateral,
    address cTokenBorrowed,
    address liquidator,
    address borrower,
    uint256 seizeTokens
  ) external virtual returns (uint256);

  function transferAllowed(
    address cToken,
    address src,
    address dst,
    uint256 transferTokens
  ) external virtual returns (uint256);

  /*** Liquidity/Liquidation Calculations ***/

  function getAccountLiquidity(address account)
    external
    view
    virtual
    returns (
      uint256,
      uint256,
      uint256
    );

  function liquidateCalculateSeizeTokens(
    address cTokenBorrowed,
    address cTokenCollateral,
    uint256 repayAmount
  ) external view virtual returns (uint256, uint256);

  /*** Pool-Wide/Cross-Asset Reentrancy Prevention ***/

  function _beforeNonReentrant() external virtual;

  function _afterNonReentrant() external virtual;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "./IFuseFeeDistributor.sol";
import "./PriceOracle.sol";

contract UnitrollerAdminStorage {
  /*
   * Administrator for Fuse
   */
  address payable public fuseAdmin;

  /**
   * @notice Administrator for this contract
   */
  address public admin;

  /**
   * @notice Pending administrator for this contract
   */
  address public pendingAdmin;

  /**
   * @notice Whether or not the Fuse admin has admin rights
   */
  bool public fuseAdminHasRights = true;

  /**
   * @notice Whether or not the admin has admin rights
   */
  bool public adminHasRights = true;

  /**
   * @notice Returns a boolean indicating if the sender has admin rights
   */
  function hasAdminRights() internal view returns (bool) {
    return (msg.sender == admin && adminHasRights) || (msg.sender == address(fuseAdmin) && fuseAdminHasRights);
  }

  /**
   * @notice Active brains of Unitroller
   */
  address public comptrollerImplementation;

  /**
   * @notice Pending brains of Unitroller
   */
  address public pendingComptrollerImplementation;
}

contract ComptrollerV1Storage is UnitrollerAdminStorage {
  /**
   * @notice Oracle which gives the price of any given asset
   */
  PriceOracle public oracle;

  /**
   * @notice Multiplier used to calculate the maximum repayAmount when liquidating a borrow
   */
  uint256 public closeFactorMantissa;

  /**
   * @notice Multiplier representing the discount on collateral that a liquidator receives
   */
  uint256 public liquidationIncentiveMantissa;

  /*
   * UNUSED AFTER UPGRADE: Max number of assets a single account can participate in (borrow or use as collateral)
   */
  uint256 internal maxAssets;

  /**
   * @notice Per-account mapping of "assets you are in", capped by maxAssets
   */
  mapping(address => CTokenInterface[]) public accountAssets;
}

contract ComptrollerV2Storage is ComptrollerV1Storage {
  struct Market {
    // Whether or not this market is listed
    bool isListed;
    // Multiplier representing the most one can borrow against their collateral in this market.
    // For instance, 0.9 to allow borrowing 90% of collateral value.
    // Must be between 0 and 1, and stored as a mantissa.
    uint256 collateralFactorMantissa;
    // Per-market mapping of "accounts in this asset"
    mapping(address => bool) accountMembership;
  }

  /**
   * @notice Official mapping of cTokens -> Market metadata
   * @dev Used e.g. to determine if a market is supported
   */
  mapping(address => Market) public markets;

  /// @notice A list of all markets
  CTokenInterface[] public allMarkets;

  /**
   * @dev Maps borrowers to booleans indicating if they have entered any markets
   */
  mapping(address => bool) internal borrowers;

  /// @notice A list of all borrowers who have entered markets
  address[] public allBorrowers;

  // Indexes of borrower account addresses in the `allBorrowers` array
  mapping(address => uint256) internal borrowerIndexes;

  /**
   * @dev Maps suppliers to booleans indicating if they have ever supplied to any markets
   */
  mapping(address => bool) public suppliers;

  /// @notice All cTokens addresses mapped by their underlying token addresses
  mapping(address => CTokenInterface) public cTokensByUnderlying;

  /// @notice Whether or not the supplier whitelist is enforced
  bool public enforceWhitelist;

  /// @notice Maps addresses to booleans indicating if they are allowed to supply assets (i.e., mint cTokens)
  mapping(address => bool) public whitelist;

  /// @notice An array of all whitelisted accounts
  address[] public whitelistArray;

  // Indexes of account addresses in the `whitelistArray` array
  mapping(address => uint256) internal whitelistIndexes;

  /**
   * @notice The Pause Guardian can pause certain actions as a safety mechanism.
   *  Actions which allow users to remove their own assets cannot be paused.
   *  Liquidation / seizing / transfer can only be paused globally, not by market.
   */
  address public pauseGuardian;
  bool public _mintGuardianPaused;
  bool public _borrowGuardianPaused;
  bool public transferGuardianPaused;
  bool public seizeGuardianPaused;
  mapping(address => bool) public mintGuardianPaused;
  mapping(address => bool) public borrowGuardianPaused;
}

contract ComptrollerV3Storage is ComptrollerV2Storage {
  /**
   * @dev Whether or not the implementation should be auto-upgraded.
   */
  bool public autoImplementation;

  /// @notice The borrowCapGuardian can set borrowCaps to any number for any market. Lowering the borrow cap could disable borrowing on the given market.
  address public borrowCapGuardian;

  /// @notice Borrow caps enforced by borrowAllowed for each cToken address. Defaults to zero which corresponds to unlimited borrowing.
  mapping(address => uint256) public borrowCaps;

  /// @notice Supply caps enforced by mintAllowed for each cToken address. Defaults to zero which corresponds to unlimited supplying.
  mapping(address => uint256) public supplyCaps;

  /// @notice RewardsDistributor contracts to notify of flywheel changes.
  address[] public rewardsDistributors;

  /// @dev Guard variable for pool-wide/cross-asset re-entrancy checks
  bool internal _notEntered;

  /// @dev Whether or not _notEntered has been initialized
  bool internal _notEnteredInitialized;

  /// @notice RewardsDistributor to list for claiming, but not to notify of flywheel changes.
  address[] public nonAccruingRewardsDistributors;

  /// @dev caps for the total borrows against specific assets
  mapping(address => mapping(address => uint256)) public borrowCapForAssetForCollateral;

  /// @dev blacklist to disallow the borrowing of an asset against specific collateral
  mapping(address => mapping(address => bool)) public borrowingAgainstCollateralBlacklist;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

contract ComptrollerErrorReporter {
  enum Error {
    NO_ERROR,
    UNAUTHORIZED,
    COMPTROLLER_MISMATCH,
    INSUFFICIENT_SHORTFALL,
    INSUFFICIENT_LIQUIDITY,
    INVALID_CLOSE_FACTOR,
    INVALID_COLLATERAL_FACTOR,
    INVALID_LIQUIDATION_INCENTIVE,
    MARKET_NOT_LISTED,
    MARKET_ALREADY_LISTED,
    MATH_ERROR,
    NONZERO_BORROW_BALANCE,
    PRICE_ERROR,
    REJECTION,
    SNAPSHOT_ERROR,
    TOO_MANY_ASSETS,
    TOO_MUCH_REPAY,
    SUPPLIER_NOT_WHITELISTED,
    BORROW_BELOW_MIN,
    SUPPLY_ABOVE_MAX,
    NONZERO_TOTAL_SUPPLY
  }

  enum FailureInfo {
    ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
    ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK,
    ADD_REWARDS_DISTRIBUTOR_OWNER_CHECK,
    EXIT_MARKET_BALANCE_OWED,
    EXIT_MARKET_REJECTION,
    TOGGLE_ADMIN_RIGHTS_OWNER_CHECK,
    TOGGLE_AUTO_IMPLEMENTATIONS_ENABLED_OWNER_CHECK,
    SET_CLOSE_FACTOR_OWNER_CHECK,
    SET_CLOSE_FACTOR_VALIDATION,
    SET_COLLATERAL_FACTOR_OWNER_CHECK,
    SET_COLLATERAL_FACTOR_NO_EXISTS,
    SET_COLLATERAL_FACTOR_VALIDATION,
    SET_COLLATERAL_FACTOR_WITHOUT_PRICE,
    SET_LIQUIDATION_INCENTIVE_OWNER_CHECK,
    SET_LIQUIDATION_INCENTIVE_VALIDATION,
    SET_PENDING_ADMIN_OWNER_CHECK,
    SET_PENDING_IMPLEMENTATION_CONTRACT_CHECK,
    SET_PENDING_IMPLEMENTATION_OWNER_CHECK,
    SET_PRICE_ORACLE_OWNER_CHECK,
    SET_WHITELIST_ENFORCEMENT_OWNER_CHECK,
    SET_WHITELIST_STATUS_OWNER_CHECK,
    SUPPORT_MARKET_EXISTS,
    SUPPORT_MARKET_OWNER_CHECK,
    SET_PAUSE_GUARDIAN_OWNER_CHECK,
    UNSUPPORT_MARKET_OWNER_CHECK,
    UNSUPPORT_MARKET_DOES_NOT_EXIST,
    UNSUPPORT_MARKET_IN_USE
  }

  /**
   * @dev `error` corresponds to enum Error; `info` corresponds to enum FailureInfo, and `detail` is an arbitrary
   * contract-specific code that enables us to report opaque error codes from upgradeable contracts.
   **/
  event Failure(uint256 error, uint256 info, uint256 detail);

  /**
   * @dev use this when reporting a known error from the money market or a non-upgradeable collaborator
   */
  function fail(Error err, FailureInfo info) internal returns (uint256) {
    emit Failure(uint256(err), uint256(info), 0);

    return uint256(err);
  }

  /**
   * @dev use this when reporting an opaque error from an upgradeable collaborator contract
   */
  function failOpaque(
    Error err,
    FailureInfo info,
    uint256 opaqueError
  ) internal returns (uint256) {
    emit Failure(uint256(err), uint256(info), opaqueError);

    return uint256(err);
  }
}

contract TokenErrorReporter {
  enum Error {
    NO_ERROR,
    UNAUTHORIZED,
    BAD_INPUT,
    COMPTROLLER_REJECTION,
    COMPTROLLER_CALCULATION_ERROR,
    INTEREST_RATE_MODEL_ERROR,
    INVALID_ACCOUNT_PAIR,
    INVALID_CLOSE_AMOUNT_REQUESTED,
    INVALID_COLLATERAL_FACTOR,
    MATH_ERROR,
    MARKET_NOT_FRESH,
    MARKET_NOT_LISTED,
    TOKEN_INSUFFICIENT_ALLOWANCE,
    TOKEN_INSUFFICIENT_BALANCE,
    TOKEN_INSUFFICIENT_CASH,
    TOKEN_TRANSFER_IN_FAILED,
    TOKEN_TRANSFER_OUT_FAILED,
    UTILIZATION_ABOVE_MAX
  }

  /*
   * Note: FailureInfo (but not Error) is kept in alphabetical order
   *       This is because FailureInfo grows significantly faster, and
   *       the order of Error has some meaning, while the order of FailureInfo
   *       is entirely arbitrary.
   */
  enum FailureInfo {
    ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
    ACCRUE_INTEREST_ACCUMULATED_INTEREST_CALCULATION_FAILED,
    ACCRUE_INTEREST_BORROW_RATE_CALCULATION_FAILED,
    ACCRUE_INTEREST_NEW_BORROW_INDEX_CALCULATION_FAILED,
    ACCRUE_INTEREST_NEW_TOTAL_BORROWS_CALCULATION_FAILED,
    ACCRUE_INTEREST_NEW_TOTAL_RESERVES_CALCULATION_FAILED,
    ACCRUE_INTEREST_NEW_TOTAL_FUSE_FEES_CALCULATION_FAILED,
    ACCRUE_INTEREST_NEW_TOTAL_ADMIN_FEES_CALCULATION_FAILED,
    ACCRUE_INTEREST_SIMPLE_INTEREST_FACTOR_CALCULATION_FAILED,
    BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
    BORROW_ACCRUE_INTEREST_FAILED,
    BORROW_CASH_NOT_AVAILABLE,
    BORROW_FRESHNESS_CHECK,
    BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
    BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED,
    BORROW_MARKET_NOT_LISTED,
    BORROW_COMPTROLLER_REJECTION,
    LIQUIDATE_ACCRUE_BORROW_INTEREST_FAILED,
    LIQUIDATE_ACCRUE_COLLATERAL_INTEREST_FAILED,
    LIQUIDATE_COLLATERAL_FRESHNESS_CHECK,
    LIQUIDATE_COMPTROLLER_REJECTION,
    LIQUIDATE_COMPTROLLER_CALCULATE_AMOUNT_SEIZE_FAILED,
    LIQUIDATE_CLOSE_AMOUNT_IS_UINT_MAX,
    LIQUIDATE_CLOSE_AMOUNT_IS_ZERO,
    LIQUIDATE_FRESHNESS_CHECK,
    LIQUIDATE_LIQUIDATOR_IS_BORROWER,
    LIQUIDATE_REPAY_BORROW_FRESH_FAILED,
    LIQUIDATE_SEIZE_BALANCE_INCREMENT_FAILED,
    LIQUIDATE_SEIZE_BALANCE_DECREMENT_FAILED,
    LIQUIDATE_SEIZE_COMPTROLLER_REJECTION,
    LIQUIDATE_SEIZE_LIQUIDATOR_IS_BORROWER,
    LIQUIDATE_SEIZE_TOO_MUCH,
    MINT_ACCRUE_INTEREST_FAILED,
    MINT_COMPTROLLER_REJECTION,
    MINT_EXCHANGE_CALCULATION_FAILED,
    MINT_EXCHANGE_RATE_READ_FAILED,
    MINT_FRESHNESS_CHECK,
    MINT_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED,
    MINT_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
    MINT_TRANSFER_IN_FAILED,
    MINT_TRANSFER_IN_NOT_POSSIBLE,
    NEW_UTILIZATION_RATE_ABOVE_MAX,
    REDEEM_ACCRUE_INTEREST_FAILED,
    REDEEM_COMPTROLLER_REJECTION,
    REDEEM_EXCHANGE_TOKENS_CALCULATION_FAILED,
    REDEEM_EXCHANGE_AMOUNT_CALCULATION_FAILED,
    REDEEM_EXCHANGE_RATE_READ_FAILED,
    REDEEM_FRESHNESS_CHECK,
    REDEEM_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED,
    REDEEM_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
    REDEEM_TRANSFER_OUT_NOT_POSSIBLE,
    WITHDRAW_FUSE_FEES_ACCRUE_INTEREST_FAILED,
    WITHDRAW_FUSE_FEES_CASH_NOT_AVAILABLE,
    WITHDRAW_FUSE_FEES_FRESH_CHECK,
    WITHDRAW_FUSE_FEES_VALIDATION,
    WITHDRAW_ADMIN_FEES_ACCRUE_INTEREST_FAILED,
    WITHDRAW_ADMIN_FEES_CASH_NOT_AVAILABLE,
    WITHDRAW_ADMIN_FEES_FRESH_CHECK,
    WITHDRAW_ADMIN_FEES_VALIDATION,
    REDUCE_RESERVES_ACCRUE_INTEREST_FAILED,
    REDUCE_RESERVES_ADMIN_CHECK,
    REDUCE_RESERVES_CASH_NOT_AVAILABLE,
    REDUCE_RESERVES_FRESH_CHECK,
    REDUCE_RESERVES_VALIDATION,
    REPAY_BEHALF_ACCRUE_INTEREST_FAILED,
    REPAY_BORROW_ACCRUE_INTEREST_FAILED,
    REPAY_BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
    REPAY_BORROW_COMPTROLLER_REJECTION,
    REPAY_BORROW_FRESHNESS_CHECK,
    REPAY_BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED,
    REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
    REPAY_BORROW_TRANSFER_IN_NOT_POSSIBLE,
    SET_COLLATERAL_FACTOR_OWNER_CHECK,
    SET_COLLATERAL_FACTOR_VALIDATION,
    SET_COMPTROLLER_OWNER_CHECK,
    SET_INTEREST_RATE_MODEL_ACCRUE_INTEREST_FAILED,
    SET_INTEREST_RATE_MODEL_FRESH_CHECK,
    SET_INTEREST_RATE_MODEL_OWNER_CHECK,
    TOGGLE_ADMIN_RIGHTS_OWNER_CHECK,
    SET_PENDING_ADMIN_OWNER_CHECK,
    SET_ADMIN_FEE_ACCRUE_INTEREST_FAILED,
    SET_ADMIN_FEE_ADMIN_CHECK,
    SET_ADMIN_FEE_FRESH_CHECK,
    SET_ADMIN_FEE_BOUNDS_CHECK,
    SET_FUSE_FEE_ACCRUE_INTEREST_FAILED,
    SET_FUSE_FEE_FRESH_CHECK,
    SET_FUSE_FEE_BOUNDS_CHECK,
    SET_RESERVE_FACTOR_ACCRUE_INTEREST_FAILED,
    SET_RESERVE_FACTOR_ADMIN_CHECK,
    SET_RESERVE_FACTOR_FRESH_CHECK,
    SET_RESERVE_FACTOR_BOUNDS_CHECK,
    TRANSFER_COMPTROLLER_REJECTION,
    TRANSFER_NOT_ALLOWED,
    TRANSFER_NOT_ENOUGH,
    TRANSFER_TOO_MUCH,
    ADD_RESERVES_ACCRUE_INTEREST_FAILED,
    ADD_RESERVES_FRESH_CHECK,
    ADD_RESERVES_TRANSFER_IN_NOT_POSSIBLE
  }

  /**
   * @dev `error` corresponds to enum Error; `info` corresponds to enum FailureInfo, and `detail` is an arbitrary
   * contract-specific code that enables us to report opaque error codes from upgradeable contracts.
   **/
  event Failure(uint256 error, uint256 info, uint256 detail);

  /**
   * @dev use this when reporting a known error from the money market or a non-upgradeable collaborator
   */
  function fail(Error err, FailureInfo info) internal returns (uint256) {
    emit Failure(uint256(err), uint256(info), 0);

    return uint256(err);
  }

  /**
   * @dev use this when reporting an opaque error from an upgradeable collaborator contract
   */
  function failOpaque(
    Error err,
    FailureInfo info,
    uint256 opaqueError
  ) internal returns (uint256) {
    emit Failure(uint256(err), uint256(info), opaqueError);

    return err == Error.COMPTROLLER_REJECTION ? 1000 + opaqueError : uint256(err);
  }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "./CarefulMath.sol";
import "./ExponentialNoError.sol";

/**
 * @title Exponential module for storing fixed-precision decimals
 * @author Compound
 * @dev Legacy contract for compatibility reasons with existing contracts that still use MathError
 * @notice Exp is a struct which stores decimals with a fixed precision of 18 decimal places.
 *         Thus, if we wanted to store the 5.1, mantissa would store 5.1e18. That is:
 *         `Exp({mantissa: 5100000000000000000})`.
 */
contract Exponential is CarefulMath, ExponentialNoError {
  /**
   * @dev Creates an exponential from numerator and denominator values.
   *      Note: Returns an error if (`num` * 10e18) > MAX_INT,
   *            or if `denom` is zero.
   */
  function getExp(uint256 num, uint256 denom) internal pure returns (MathError, Exp memory) {
    (MathError err0, uint256 scaledNumerator) = mulUInt(num, expScale);
    if (err0 != MathError.NO_ERROR) {
      return (err0, Exp({ mantissa: 0 }));
    }

    (MathError err1, uint256 rational) = divUInt(scaledNumerator, denom);
    if (err1 != MathError.NO_ERROR) {
      return (err1, Exp({ mantissa: 0 }));
    }

    return (MathError.NO_ERROR, Exp({ mantissa: rational }));
  }

  /**
   * @dev Adds two exponentials, returning a new exponential.
   */
  function addExp(Exp memory a, Exp memory b) internal pure returns (MathError, Exp memory) {
    (MathError error, uint256 result) = addUInt(a.mantissa, b.mantissa);

    return (error, Exp({ mantissa: result }));
  }

  /**
   * @dev Subtracts two exponentials, returning a new exponential.
   */
  function subExp(Exp memory a, Exp memory b) internal pure returns (MathError, Exp memory) {
    (MathError error, uint256 result) = subUInt(a.mantissa, b.mantissa);

    return (error, Exp({ mantissa: result }));
  }

  /**
   * @dev Multiply an Exp by a scalar, returning a new Exp.
   */
  function mulScalar(Exp memory a, uint256 scalar) internal pure returns (MathError, Exp memory) {
    (MathError err0, uint256 scaledMantissa) = mulUInt(a.mantissa, scalar);
    if (err0 != MathError.NO_ERROR) {
      return (err0, Exp({ mantissa: 0 }));
    }

    return (MathError.NO_ERROR, Exp({ mantissa: scaledMantissa }));
  }

  /**
   * @dev Multiply an Exp by a scalar, then truncate to return an unsigned integer.
   */
  function mulScalarTruncate(Exp memory a, uint256 scalar) internal pure returns (MathError, uint256) {
    (MathError err, Exp memory product) = mulScalar(a, scalar);
    if (err != MathError.NO_ERROR) {
      return (err, 0);
    }

    return (MathError.NO_ERROR, truncate(product));
  }

  /**
   * @dev Divide an Exp by a scalar, returning a new Exp.
   */
  function divScalar(Exp memory a, uint256 scalar) internal pure returns (MathError, Exp memory) {
    (MathError err0, uint256 descaledMantissa) = divUInt(a.mantissa, scalar);
    if (err0 != MathError.NO_ERROR) {
      return (err0, Exp({ mantissa: 0 }));
    }

    return (MathError.NO_ERROR, Exp({ mantissa: descaledMantissa }));
  }

  /**
   * @dev Divide a scalar by an Exp, returning a new Exp.
   */
  function divScalarByExp(uint256 scalar, Exp memory divisor) internal pure returns (MathError, Exp memory) {
    /*
          We are doing this as:
          getExp(mulUInt(expScale, scalar), divisor.mantissa)

          How it works:
          Exp = a / b;
          Scalar = s;
          `s / (a / b)` = `b * s / a` and since for an Exp `a = mantissa, b = expScale`
        */
    (MathError err0, uint256 numerator) = mulUInt(expScale, scalar);
    if (err0 != MathError.NO_ERROR) {
      return (err0, Exp({ mantissa: 0 }));
    }
    return getExp(numerator, divisor.mantissa);
  }

  /**
   * @dev Divide a scalar by an Exp, then truncate to return an unsigned integer.
   */
  function divScalarByExpTruncate(uint256 scalar, Exp memory divisor) internal pure returns (MathError, uint256) {
    (MathError err, Exp memory fraction) = divScalarByExp(scalar, divisor);
    if (err != MathError.NO_ERROR) {
      return (err, 0);
    }

    return (MathError.NO_ERROR, truncate(fraction));
  }

  /**
   * @dev Multiplies two exponentials, returning a new exponential.
   */
  function mulExp(Exp memory a, Exp memory b) internal pure returns (MathError, Exp memory) {
    (MathError err0, uint256 doubleScaledProduct) = mulUInt(a.mantissa, b.mantissa);
    if (err0 != MathError.NO_ERROR) {
      return (err0, Exp({ mantissa: 0 }));
    }

    // We add half the scale before dividing so that we get rounding instead of truncation.
    //  See "Listing 6" and text above it at https://accu.org/index.php/journals/1717
    // Without this change, a result like 6.6...e-19 will be truncated to 0 instead of being rounded to 1e-18.
    (MathError err1, uint256 doubleScaledProductWithHalfScale) = addUInt(halfExpScale, doubleScaledProduct);
    if (err1 != MathError.NO_ERROR) {
      return (err1, Exp({ mantissa: 0 }));
    }

    (MathError err2, uint256 product) = divUInt(doubleScaledProductWithHalfScale, expScale);
    // The only error `div` can return is MathError.DIVISION_BY_ZERO but we control `expScale` and it is not zero.
    assert(err2 == MathError.NO_ERROR);

    return (MathError.NO_ERROR, Exp({ mantissa: product }));
  }

  /**
   * @dev Multiplies two exponentials given their mantissas, returning a new exponential.
   */
  function mulExp(uint256 a, uint256 b) internal pure returns (MathError, Exp memory) {
    return mulExp(Exp({ mantissa: a }), Exp({ mantissa: b }));
  }

  /**
   * @dev Multiplies three exponentials, returning a new exponential.
   */
  function mulExp3(
    Exp memory a,
    Exp memory b,
    Exp memory c
  ) internal pure returns (MathError, Exp memory) {
    (MathError err, Exp memory ab) = mulExp(a, b);
    if (err != MathError.NO_ERROR) {
      return (err, ab);
    }
    return mulExp(ab, c);
  }

  /**
   * @dev Divides two exponentials, returning a new exponential.
   *     (a/scale) / (b/scale) = (a/scale) * (scale/b) = a/b,
   *  which we can scale as an Exp by calling getExp(a.mantissa, b.mantissa)
   */
  function divExp(Exp memory a, Exp memory b) internal pure returns (MathError, Exp memory) {
    return getExp(a.mantissa, b.mantissa);
  }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

/**
 * @title Exponential module for storing fixed-precision decimals
 * @author Compound
 * @notice Exp is a struct which stores decimals with a fixed precision of 18 decimal places.
 *         Thus, if we wanted to store the 5.1, mantissa would store 5.1e18. That is:
 *         `Exp({mantissa: 5100000000000000000})`.
 */
contract ExponentialNoError {
  uint256 constant expScale = 1e18;
  uint256 constant doubleScale = 1e36;
  uint256 constant halfExpScale = expScale / 2;
  uint256 constant mantissaOne = expScale;

  struct Exp {
    uint256 mantissa;
  }

  struct Double {
    uint256 mantissa;
  }

  /**
   * @dev Truncates the given exp to a whole number value.
   *      For example, truncate(Exp{mantissa: 15 * expScale}) = 15
   */
  function truncate(Exp memory exp) internal pure returns (uint256) {
    // Note: We are not using careful math here as we're performing a division that cannot fail
    return exp.mantissa / expScale;
  }

  /**
   * @dev Multiply an Exp by a scalar, then truncate to return an unsigned integer.
   */
  function mul_ScalarTruncate(Exp memory a, uint256 scalar) internal pure returns (uint256) {
    Exp memory product = mul_(a, scalar);
    return truncate(product);
  }

  /**
   * @dev Multiply an Exp by a scalar, truncate, then add an to an unsigned integer, returning an unsigned integer.
   */
  function mul_ScalarTruncateAddUInt(
    Exp memory a,
    uint256 scalar,
    uint256 addend
  ) internal pure returns (uint256) {
    Exp memory product = mul_(a, scalar);
    return add_(truncate(product), addend);
  }

  /**
   * @dev Checks if first Exp is less than second Exp.
   */
  function lessThanExp(Exp memory left, Exp memory right) internal pure returns (bool) {
    return left.mantissa < right.mantissa;
  }

  /**
   * @dev Checks if left Exp <= right Exp.
   */
  function lessThanOrEqualExp(Exp memory left, Exp memory right) internal pure returns (bool) {
    return left.mantissa <= right.mantissa;
  }

  /**
   * @dev Checks if left Exp > right Exp.
   */
  function greaterThanExp(Exp memory left, Exp memory right) internal pure returns (bool) {
    return left.mantissa > right.mantissa;
  }

  /**
   * @dev returns true if Exp is exactly zero
   */
  function isZeroExp(Exp memory value) internal pure returns (bool) {
    return value.mantissa == 0;
  }

  function safe224(uint256 n, string memory errorMessage) internal pure returns (uint224) {
    require(n < 2**224, errorMessage);
    return uint224(n);
  }

  function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {
    require(n < 2**32, errorMessage);
    return uint32(n);
  }

  function add_(Exp memory a, Exp memory b) internal pure returns (Exp memory) {
    return Exp({ mantissa: add_(a.mantissa, b.mantissa) });
  }

  function add_(Double memory a, Double memory b) internal pure returns (Double memory) {
    return Double({ mantissa: add_(a.mantissa, b.mantissa) });
  }

  function add_(uint256 a, uint256 b) internal pure returns (uint256) {
    return add_(a, b, "addition overflow");
  }

  function add_(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, errorMessage);
    return c;
  }

  function sub_(Exp memory a, Exp memory b) internal pure returns (Exp memory) {
    return Exp({ mantissa: sub_(a.mantissa, b.mantissa) });
  }

  function sub_(Double memory a, Double memory b) internal pure returns (Double memory) {
    return Double({ mantissa: sub_(a.mantissa, b.mantissa) });
  }

  function sub_(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub_(a, b, "subtraction underflow");
  }

  function sub_(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    return a - b;
  }

  function mul_(Exp memory a, Exp memory b) internal pure returns (Exp memory) {
    return Exp({ mantissa: mul_(a.mantissa, b.mantissa) / expScale });
  }

  function mul_(Exp memory a, uint256 b) internal pure returns (Exp memory) {
    return Exp({ mantissa: mul_(a.mantissa, b) });
  }

  function mul_(uint256 a, Exp memory b) internal pure returns (uint256) {
    return mul_(a, b.mantissa) / expScale;
  }

  function mul_(Double memory a, Double memory b) internal pure returns (Double memory) {
    return Double({ mantissa: mul_(a.mantissa, b.mantissa) / doubleScale });
  }

  function mul_(Double memory a, uint256 b) internal pure returns (Double memory) {
    return Double({ mantissa: mul_(a.mantissa, b) });
  }

  function mul_(uint256 a, Double memory b) internal pure returns (uint256) {
    return mul_(a, b.mantissa) / doubleScale;
  }

  function mul_(uint256 a, uint256 b) internal pure returns (uint256) {
    return mul_(a, b, "multiplication overflow");
  }

  function mul_(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    if (a == 0 || b == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b, errorMessage);
    return c;
  }

  function div_(Exp memory a, Exp memory b) internal pure returns (Exp memory) {
    return Exp({ mantissa: div_(mul_(a.mantissa, expScale), b.mantissa) });
  }

  function div_(Exp memory a, uint256 b) internal pure returns (Exp memory) {
    return Exp({ mantissa: div_(a.mantissa, b) });
  }

  function div_(uint256 a, Exp memory b) internal pure returns (uint256) {
    return div_(mul_(a, expScale), b.mantissa);
  }

  function div_(Double memory a, Double memory b) internal pure returns (Double memory) {
    return Double({ mantissa: div_(mul_(a.mantissa, doubleScale), b.mantissa) });
  }

  function div_(Double memory a, uint256 b) internal pure returns (Double memory) {
    return Double({ mantissa: div_(a.mantissa, b) });
  }

  function div_(uint256 a, Double memory b) internal pure returns (uint256) {
    return div_(mul_(a, doubleScale), b.mantissa);
  }

  function div_(uint256 a, uint256 b) internal pure returns (uint256) {
    return div_(a, b, "divide by zero");
  }

  function div_(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    return a / b;
  }

  function fraction(uint256 a, uint256 b) internal pure returns (Double memory) {
    return Double({ mantissa: div_(mul_(a, doubleScale), b) });
  }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

interface IFuseFeeDistributor {
  function minBorrowEth() external view returns (uint256);

  function maxSupplyEth() external view returns (uint256);

  function maxUtilizationRate() external view returns (uint256);

  function interestFeeRate() external view returns (uint256);

  function comptrollerImplementationWhitelist(address oldImplementation, address newImplementation)
    external
    view
    returns (bool);

  function pluginImplementationWhitelist(address oldImplementation, address newImplementation)
    external
    view
    returns (bool);

  function cErc20DelegateWhitelist(
    address oldImplementation,
    address newImplementation,
    bool allowResign
  ) external view returns (bool);

  function latestComptrollerImplementation(address oldImplementation) external view returns (address);

  function latestCErc20Delegate(address oldImplementation)
    external
    view
    returns (
      address cErc20Delegate,
      bool allowResign,
      bytes memory becomeImplementationData
    );

  function latestPluginImplementation(address oldImplementation) external view returns (address);

  function getComptrollerExtensions(address comptroller) external view returns (address[] memory);

  function getCErc20DelegateExtensions(address cErc20Delegate) external view returns (address[] memory);

  function deployCErc20(bytes calldata constructorData) external returns (address);

  fallback() external payable;

  receive() external payable;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

/**
 * @title Compound's InterestRateModel Interface
 * @author Compound
 */
abstract contract InterestRateModel {
  /// @notice Indicator that this is an InterestRateModel contract (for inspection)
  bool public constant isInterestRateModel = true;

  /**
   * @notice Calculates the current borrow interest rate per block
   * @param cash The total amount of cash the market has
   * @param borrows The total amount of borrows the market has outstanding
   * @param reserves The total amount of reserves the market has
   * @return The borrow rate per block (as a percentage, and scaled by 1e18)
   */
  function getBorrowRate(
    uint256 cash,
    uint256 borrows,
    uint256 reserves
  ) public view virtual returns (uint256);

  /**
   * @notice Calculates the current supply interest rate per block
   * @param cash The total amount of cash the market has
   * @param borrows The total amount of borrows the market has outstanding
   * @param reserves The total amount of reserves the market has
   * @param reserveFactorMantissa The current reserve factor the market has
   * @return The supply rate per block (as a percentage, and scaled by 1e18)
   */
  function getSupplyRate(
    uint256 cash,
    uint256 borrows,
    uint256 reserves,
    uint256 reserveFactorMantissa
  ) public view virtual returns (uint256);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "./CTokenInterfaces.sol";

abstract contract PriceOracle {
  /// @notice Indicator that this is a PriceOracle contract (for inspection)
  bool public constant isPriceOracle = true;

  /**
   * @notice Get the underlying price of a cToken asset
   * @param cToken The cToken to get the underlying price of
   * @return The underlying asset price mantissa (scaled by 1e18).
   *  Zero means the price is unavailable.
   */
  function getUnderlyingPrice(CTokenInterface cToken) external view virtual returns (uint256);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "./ErrorReporter.sol";
import "./ComptrollerStorage.sol";
import "./Comptroller.sol";

/**
 * @title Unitroller
 * @dev Storage for the comptroller is at this address, while execution is delegated to the `comptrollerImplementation`.
 * CTokens should reference this contract as their comptroller.
 */
contract Unitroller is UnitrollerAdminStorage, ComptrollerErrorReporter {
  /**
   * @notice Emitted when pendingComptrollerImplementation is changed
   */
  event NewPendingImplementation(address oldPendingImplementation, address newPendingImplementation);

  /**
   * @notice Emitted when pendingComptrollerImplementation is accepted, which means comptroller implementation is updated
   */
  event NewImplementation(address oldImplementation, address newImplementation);

  /**
   * @notice Event emitted when the Fuse admin rights are changed
   */
  event FuseAdminRightsToggled(bool hasRights);

  /**
   * @notice Event emitted when the admin rights are changed
   */
  event AdminRightsToggled(bool hasRights);

  /**
   * @notice Emitted when pendingAdmin is changed
   */
  event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

  /**
   * @notice Emitted when pendingAdmin is accepted, which means admin is updated
   */
  event NewAdmin(address oldAdmin, address newAdmin);

  constructor(address payable _fuseAdmin) {
    // Set admin to caller
    admin = msg.sender;
    fuseAdmin = _fuseAdmin;
  }

  /*** Admin Functions ***/

  function _setPendingImplementation(address newPendingImplementation) public returns (uint256) {
    if (!hasAdminRights()) {
      return fail(Error.UNAUTHORIZED, FailureInfo.SET_PENDING_IMPLEMENTATION_OWNER_CHECK);
    }
    if (
      !IFuseFeeDistributor(fuseAdmin).comptrollerImplementationWhitelist(
        comptrollerImplementation,
        newPendingImplementation
      )
    ) {
      return fail(Error.UNAUTHORIZED, FailureInfo.SET_PENDING_IMPLEMENTATION_CONTRACT_CHECK);
    }
    //require(Comptroller(newPendingImplementation).fuseAdmin() == fuseAdmin, "fuseAdmin not matching");

    address oldPendingImplementation = pendingComptrollerImplementation;
    pendingComptrollerImplementation = newPendingImplementation;
    emit NewPendingImplementation(oldPendingImplementation, pendingComptrollerImplementation);

    return uint256(Error.NO_ERROR);
  }

  /**
   * @notice Accepts new implementation of comptroller. msg.sender must be pendingImplementation
   * @dev Admin function for new implementation to accept it's role as implementation
   * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
   */
  function _acceptImplementation() public returns (uint256) {
    // Check caller is pendingImplementation and pendingImplementation ≠ address(0)
    if (msg.sender != pendingComptrollerImplementation || pendingComptrollerImplementation == address(0)) {
      return fail(Error.UNAUTHORIZED, FailureInfo.ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK);
    }

    // Save current values for inclusion in log
    address oldImplementation = comptrollerImplementation;
    address oldPendingImplementation = pendingComptrollerImplementation;

    comptrollerImplementation = pendingComptrollerImplementation;

    pendingComptrollerImplementation = address(0);

    emit NewImplementation(oldImplementation, comptrollerImplementation);
    emit NewPendingImplementation(oldPendingImplementation, pendingComptrollerImplementation);

    return uint256(Error.NO_ERROR);
  }

  /**
   * @notice Toggles admin rights.
   * @param hasRights Boolean indicating if the admin is to have rights.
   * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
   */
  function _toggleAdminRights(bool hasRights) external returns (uint256) {
    // Check caller = admin
    if (!hasAdminRights()) {
      return fail(Error.UNAUTHORIZED, FailureInfo.TOGGLE_ADMIN_RIGHTS_OWNER_CHECK);
    }

    // Check that rights have not already been set to the desired value
    if (adminHasRights == hasRights) return uint256(Error.NO_ERROR);

    // Set adminHasRights
    adminHasRights = hasRights;

    // Emit AdminRightsToggled()
    emit AdminRightsToggled(hasRights);

    return uint256(Error.NO_ERROR);
  }

  /**
   * @notice Begins transfer of admin rights. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
   * @dev Admin function to begin change of admin. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
   * @param newPendingAdmin New pending admin.
   * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
   */
  function _setPendingAdmin(address newPendingAdmin) public returns (uint256) {
    // Check caller = admin
    if (!hasAdminRights()) {
      return fail(Error.UNAUTHORIZED, FailureInfo.SET_PENDING_ADMIN_OWNER_CHECK);
    }

    // Save current value, if any, for inclusion in log
    address oldPendingAdmin = pendingAdmin;

    // Store pendingAdmin with value newPendingAdmin
    pendingAdmin = newPendingAdmin;

    // Emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin)
    emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);

    return uint256(Error.NO_ERROR);
  }

  /**
   * @notice Accepts transfer of admin rights. msg.sender must be pendingAdmin
   * @dev Admin function for pending admin to accept role and update admin
   * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
   */
  function _acceptAdmin() public returns (uint256) {
    // Check caller is pendingAdmin and pendingAdmin ≠ address(0)
    if (msg.sender != pendingAdmin || msg.sender == address(0)) {
      return fail(Error.UNAUTHORIZED, FailureInfo.ACCEPT_ADMIN_PENDING_ADMIN_CHECK);
    }

    // Save current values for inclusion in log
    address oldAdmin = admin;
    address oldPendingAdmin = pendingAdmin;

    // Store admin with value pendingAdmin
    admin = pendingAdmin;

    // Clear the pending value
    pendingAdmin = address(0);

    emit NewAdmin(oldAdmin, admin);
    emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);

    return uint256(Error.NO_ERROR);
  }

  /**
   * @dev Delegates execution to an implementation contract.
   * It returns to the external caller whatever the implementation returns
   * or forwards reverts.
   */
  fallback() external payable {
    // Check for automatic implementation
    if (msg.sender != address(this)) {
      (bool callSuccess, bytes memory data) = address(this).staticcall(abi.encodeWithSignature("autoImplementation()"));
      bool autoImplementation;
      if (callSuccess) (autoImplementation) = abi.decode(data, (bool));

      if (autoImplementation) {
        address latestComptrollerImplementation = IFuseFeeDistributor(fuseAdmin).latestComptrollerImplementation(
          comptrollerImplementation
        );

        if (comptrollerImplementation != latestComptrollerImplementation) {
          address oldImplementation = comptrollerImplementation; // Save current value for inclusion in log
          comptrollerImplementation = latestComptrollerImplementation;
          emit NewImplementation(oldImplementation, comptrollerImplementation);
        }
      }
    }

    // delegate all other functions to current implementation
    (bool success, ) = comptrollerImplementation.delegatecall(msg.data);

    assembly {
      let free_mem_ptr := mload(0x40)
      returndatacopy(free_mem_ptr, 0, returndatasize())

      switch success
      case 0 {
        revert(free_mem_ptr, returndatasize())
      }
      default {
        return(free_mem_ptr, returndatasize())
      }
    }
  }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

/**
 * @notice a base contract for logic extensions that use the diamond pattern storage
 * to map the functions when looking up the extension contract to delegate to.
 */
abstract contract DiamondExtension {
  /**
   * @return a list of all the function selectors that this logic extension exposes
   */
  function _getExtensionFunctions() external view virtual returns (bytes4[] memory);
}

// When no function exists for function called
error FunctionNotFound(bytes4 _functionSelector);

// When no extension exists for function called
error ExtensionNotFound(bytes4 _functionSelector);

// When the function is already added
error FunctionAlreadyAdded(bytes4 _functionSelector, address _currentImpl);

abstract contract DiamondBase {
  /**
   * @dev register a logic extension
   * @param extensionToAdd the extension whose functions are to be added
   * @param extensionToReplace the extension whose functions are to be removed/replaced
   */
  function _registerExtension(DiamondExtension extensionToAdd, DiamondExtension extensionToReplace) external virtual;

  function _listExtensions() public view returns (address[] memory) {
    return LibDiamond.listExtensions();
  }

  fallback() external {
    address extension = LibDiamond.getExtensionForFunction(msg.sig);
    if (extension == address(0)) revert FunctionNotFound(msg.sig);
    // Execute external function from extension using delegatecall and return any value.
    assembly {
      // copy function selector and any arguments
      calldatacopy(0, 0, calldatasize())
      // execute function call using the extension
      let result := delegatecall(gas(), extension, 0, calldatasize(), 0, 0)
      // get any return value
      returndatacopy(0, 0, returndatasize())
      // return any return value or error back to the caller
      switch result
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    }
  }
}

/**
 * @notice a library to use in a contract, whose logic is extended with diamond extension
 */
library LibDiamond {
  bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

  struct Function {
    address implementation;
    uint16 index; // used to remove functions without looping
  }

  struct LogicStorage {
    mapping(bytes4 => Function) functions;
    bytes4[] selectorAtIndex;
    address[] extensions;
  }

  function getExtensionForFunction(bytes4 msgSig) internal view returns (address) {
    LibDiamond.LogicStorage storage ds = diamondStorage();
    address extension = ds.functions[msgSig].implementation;
    if (extension == address(0)) revert ExtensionNotFound(msgSig);
    return extension;
  }

  function diamondStorage() internal pure returns (LogicStorage storage ds) {
    bytes32 position = DIAMOND_STORAGE_POSITION;
    assembly {
      ds.slot := position
    }
  }

  function listExtensions() internal view returns (address[] memory) {
    return diamondStorage().extensions;
  }

  function registerExtension(DiamondExtension extensionToAdd, DiamondExtension extensionToReplace) internal {
    if (address(extensionToReplace) != address(0)) {
      removeExtension(extensionToReplace);
    }
    addExtension(extensionToAdd);
  }

  function removeExtension(DiamondExtension extension) internal {
    LogicStorage storage ds = diamondStorage();
    // remove all functions of the extension to replace
    removeExtensionFunctions(extension);
    for (uint8 i = 0; i < ds.extensions.length; i++) {
      if (ds.extensions[i] == address(extension)) {
        ds.extensions[i] = ds.extensions[ds.extensions.length - 1];
        ds.extensions.pop();
      }
    }
  }

  function addExtension(DiamondExtension extension) internal {
    LogicStorage storage ds = diamondStorage();
    for (uint8 i = 0; i < ds.extensions.length; i++) {
      require(ds.extensions[i] != address(extension), "extension already added");
    }
    addExtensionFunctions(extension);
    ds.extensions.push(address(extension));
  }

  function removeExtensionFunctions(DiamondExtension extension) internal {
    bytes4[] memory fnsToRemove = extension._getExtensionFunctions();
    LogicStorage storage ds = diamondStorage();
    for (uint16 i = 0; i < fnsToRemove.length; i++) {
      bytes4 selectorToRemove = fnsToRemove[i];
      // must never fail
      assert(address(extension) == ds.functions[selectorToRemove].implementation);
      // swap with the last element in the selectorAtIndex array and remove the last element
      uint16 indexToKeep = ds.functions[selectorToRemove].index;
      ds.selectorAtIndex[indexToKeep] = ds.selectorAtIndex[ds.selectorAtIndex.length - 1];
      ds.functions[ds.selectorAtIndex[indexToKeep]].index = indexToKeep;
      ds.selectorAtIndex.pop();
      delete ds.functions[selectorToRemove];
    }
  }

  function addExtensionFunctions(DiamondExtension extension) internal {
    bytes4[] memory fnsToAdd = extension._getExtensionFunctions();
    LogicStorage storage ds = diamondStorage();
    uint16 selectorCount = uint16(ds.selectorAtIndex.length);
    for (uint256 selectorIndex = 0; selectorIndex < fnsToAdd.length; selectorIndex++) {
      bytes4 selector = fnsToAdd[selectorIndex];
      address oldImplementation = ds.functions[selector].implementation;
      if (oldImplementation != address(0)) revert FunctionAlreadyAdded(selector, oldImplementation);
      ds.functions[selector] = Function(address(extension), selectorCount);
      ds.selectorAtIndex.push(selector);
      selectorCount++;
    }
  }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import { ERC20 } from "solmate/tokens/ERC20.sol";

interface IMidasFlywheel {
  function isRewardsDistributor() external returns (bool);

  function isFlywheel() external returns (bool);

  function flywheelPreSupplierAction(address market, address supplier) external;

  function flywheelPreBorrowerAction(address market, address borrower) external;

  function flywheelPreTransferAction(
    address market,
    address src,
    address dst
  ) external;

  function compAccrued(address user) external view returns (uint256);

  function addMarketForRewards(ERC20 strategy) external;

  function marketState(ERC20 strategy) external view returns (uint224 index, uint32 lastUpdatedTimestamp);
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}