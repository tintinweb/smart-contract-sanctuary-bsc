// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/utils/AddressUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/token/ERC20/IERC20Upgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/token/ERC20/utils/SafeERC20Upgradeable.sol";

import "./liquidators/IRedemptionStrategy.sol";
import "./liquidators/IFundsConversionStrategy.sol";
import "./liquidators/JarvisLiquidatorFunder.sol";

import "./external/compound/ICToken.sol";

import "./external/compound/ICErc20.sol";
import "./external/compound/ICEther.sol";

import "./utils/IW_NATIVE.sol";

import "./external/uniswap/IUniswapV2Router02.sol";
import "./external/uniswap/IUniswapV2Callee.sol";
import "./external/uniswap/IUniswapV2Pair.sol";
import "./external/uniswap/IUniswapV2Factory.sol";
import "./external/uniswap/UniswapV2Library.sol";
import "./external/compound/IComptroller.sol";

/**
 * @title FuseSafeLiquidator
 * @author David Lucid <[email protected]> (https://github.com/davidlucid)
 * @notice FuseSafeLiquidator safely liquidates unhealthy borrowers (with flashloan support).
 * @dev Do not transfer NATIVE or tokens directly to this address. Only send NATIVE here when using a method, and only approve tokens for transfer to here when using a method. Direct NATIVE transfers will be rejected and direct token transfers will be lost.
 */
contract FuseSafeLiquidator is OwnableUpgradeable, IUniswapV2Callee {
  using AddressUpgradeable for address payable;
  using SafeERC20Upgradeable for IERC20Upgradeable;

  /**
   * @dev W_NATIVE contract address.
   */
  address public W_NATIVE_ADDRESS;

  /**
   * @dev W_NATIVE contract object.
   */
  IW_NATIVE public W_NATIVE;

  /**
   * @dev UniswapV2Router02 contract address.
   */
  address public UNISWAP_V2_ROUTER_02_ADDRESS;

  /**
   * @dev Stable token to use for flash loans
   */
  address public STABLE_TOKEN;

  /**
   * @dev Wrapped BTC token to use for flash loans
   */
  address public BTC_TOKEN;

  /**
   * @dev Hash code of the pair used by `UNISWAP_V2_ROUTER_02`
   */
  bytes PAIR_INIT_HASH_CODE;

  /**
   * @dev UniswapV2Router02 contract object. (Is interchangable with any UniV2 forks)
   */
  IUniswapV2Router02 public UNISWAP_V2_ROUTER_02;

  /**
   * @dev Cached liquidator profit exchange source.
   * ERC20 token address or the zero address for NATIVE.
   * For use in `safeLiquidateToTokensWithFlashLoan` after it is set by `postFlashLoanTokens`.
   */
  address private _liquidatorProfitExchangeSource;

  mapping(address => bool) public redemptionStrategiesWhitelist;

  /**
   * @dev Cached flash swap amount.
   * For use in `repayTokenFlashLoan` after it is set by `safeLiquidateToTokensWithFlashLoan`.
   */
  uint256 private _flashSwapAmount;

  /**
   * @dev Cached flash swap token.
   * For use in `repayTokenFlashLoan` after it is set by `safeLiquidateToTokensWithFlashLoan`.
   */
  address private _flashSwapToken;

  /**
   * @dev Percentage of the flash swap fee, measured in basis points.
   */
  uint8 public flashSwapFee;

  function initialize(
    address _wtoken,
    address _uniswapV2router,
    address _stableToken,
    address _btcToken,
    bytes memory _uniswapPairInitHashCode,
    uint8 _flashSwapFee
  ) external initializer {
    __Ownable_init();

    require(_uniswapV2router != address(0), "UniswapV2Factory not defined.");
    W_NATIVE_ADDRESS = _wtoken;
    UNISWAP_V2_ROUTER_02_ADDRESS = _uniswapV2router;
    STABLE_TOKEN = _stableToken;
    BTC_TOKEN = _btcToken;
    W_NATIVE = IW_NATIVE(W_NATIVE_ADDRESS);
    UNISWAP_V2_ROUTER_02 = IUniswapV2Router02(UNISWAP_V2_ROUTER_02_ADDRESS);
    PAIR_INIT_HASH_CODE = _uniswapPairInitHashCode;
    flashSwapFee = _flashSwapFee;
  }

  function _becomeImplementation(bytes calldata data) external {
    uint8 _flashSwapFee = abi.decode(data, (uint8));
    if (_flashSwapFee != 0) {
      flashSwapFee = _flashSwapFee;
    } else {
      flashSwapFee = 30;
    }
  }

  /**
   * @dev Internal function to approve unlimited tokens of `erc20Contract` to `to`.
   */
  function safeApprove(
    IERC20Upgradeable token,
    address to,
    uint256 minAmount
  ) private {
    uint256 allowance = token.allowance(address(this), to);

    if (allowance < minAmount) {
      if (allowance > 0) token.safeApprove(to, 0);
      token.safeApprove(to, type(uint256).max);
    }
  }

  /**
   * @dev Internal function to approve
   */
  function justApprove(
    IERC20Upgradeable token,
    address to,
    uint256 amount
  ) private {
    token.approve(to, amount);
  }

  /**
   * @dev Internal function to exchange the entire balance of `from` to at least `minOutputAmount` of `to`.
   * @param from The input ERC20 token address (or the zero address if NATIVE) to exchange from.
   * @param to The output ERC20 token address (or the zero address if NATIVE) to exchange to.
   * @param minOutputAmount The minimum output amount of `to` necessary to complete the exchange without reversion.
   * @param uniswapV2Router The UniswapV2Router02 to use. (Is interchangable with any UniV2 forks)
   */
  function exchangeAllWethOrTokens(
    address from,
    address to,
    uint256 minOutputAmount,
    IUniswapV2Router02 uniswapV2Router
  ) private {
    if (to == address(0)) to = W_NATIVE_ADDRESS; // we want W_NATIVE instead of NATIVE
    if (to == from) return;

    // From NATIVE, W_NATIVE, or something else?
    if (from == address(0)) {
      if (to == W_NATIVE_ADDRESS) {
        // Deposit all NATIVE to W_NATIVE
        W_NATIVE.deposit{ value: address(this).balance }();
      } else {
        // Exchange from NATIVE to tokens
        uniswapV2Router.swapExactETHForTokens{ value: address(this).balance }(
          minOutputAmount,
          array(W_NATIVE_ADDRESS, to),
          address(this),
          block.timestamp
        );
      }
    } else {
      // Approve input tokens
      IERC20Upgradeable fromToken = IERC20Upgradeable(from);
      uint256 inputBalance = fromToken.balanceOf(address(this));
      justApprove(fromToken, address(uniswapV2Router), inputBalance);

      // TODO check if redemption strategies make this obsolete
      // Exchange from tokens to tokens
      uniswapV2Router.swapExactTokensForTokens(
        inputBalance,
        minOutputAmount,
        from == W_NATIVE_ADDRESS || to == W_NATIVE_ADDRESS ? array(from, to) : array(from, W_NATIVE_ADDRESS, to),
        address(this),
        block.timestamp
      ); // Put W_NATIVE in the middle of the path if not already a part of the path
    }
  }

  /**
   * @dev Internal function to exchange the entire balance of `from` to at least `minOutputAmount` of `to`.
   * @param from The input ERC20 token address (or the zero address if NATIVE) to exchange from.
   * @param outputAmount The output amount of NATIVE.
   * @param uniswapV2Router The UniswapV2Router02 to use. (Is interchangable with any UniV2 forks)
   */
  function exchangeToExactEth(
    address from,
    uint256 outputAmount,
    IUniswapV2Router02 uniswapV2Router
  ) private {
    if (from == address(0)) return;

    // From W_NATIVE something else?
    if (from == W_NATIVE_ADDRESS) {
      // Withdraw W_NATIVE to NATIVE
      W_NATIVE.withdraw(outputAmount);
    } else {
      // Approve input tokens
      IERC20Upgradeable fromToken = IERC20Upgradeable(from);
      uint256 inputBalance = fromToken.balanceOf(address(this));
      justApprove(fromToken, address(uniswapV2Router), inputBalance);

      // Exchange from tokens to NATIVE
      uniswapV2Router.swapTokensForExactETH(
        outputAmount,
        inputBalance,
        array(from, W_NATIVE_ADDRESS),
        address(this),
        block.timestamp
      );
    }
  }

  /**
   * @notice Safely liquidate an unhealthy loan (using capital from the sender), confirming that at least `minOutputAmount` in collateral is seized (or outputted by exchange if applicable).
   * @param borrower The borrower's Ethereum address.
   * @param repayAmount The amount to repay to liquidate the unhealthy loan.
   * @param cErc20 The borrowed cErc20 to repay.
   * @param cTokenCollateral The cToken collateral to be liquidated.
   * @param minOutputAmount The minimum amount of collateral to seize (or the minimum exchange output if applicable) required for execution. Reverts if this condition is not met.
   * @param exchangeSeizedTo If set to an address other than `cTokenCollateral`, exchange seized collateral to this ERC20 token contract address (or the zero address for NATIVE).
   * @param uniswapV2Router The UniswapV2Router to use to convert the seized underlying collateral. (Is interchangable with any UniV2 forks)
   * @param redemptionStrategies The IRedemptionStrategy contracts to use, if any, to redeem "special" collateral tokens (before swapping the output for borrowed tokens to be repaid via Uniswap).
   * @param strategyData The data for the chosen IRedemptionStrategy contracts, if any.
   */
  function safeLiquidate(
    address borrower,
    uint256 repayAmount,
    ICErc20 cErc20,
    ICToken cTokenCollateral,
    uint256 minOutputAmount,
    address exchangeSeizedTo,
    IUniswapV2Router02 uniswapV2Router,
    IRedemptionStrategy[] memory redemptionStrategies,
    bytes[] memory strategyData
  ) external returns (uint256) {
    // Transfer tokens in, approve to cErc20, and liquidate borrow
    require(repayAmount > 0, "Repay amount (transaction value) must be greater than 0.");
    IERC20Upgradeable underlying = IERC20Upgradeable(cErc20.underlying());
    underlying.safeTransferFrom(msg.sender, address(this), repayAmount);
    justApprove(underlying, address(cErc20), repayAmount);
    require(cErc20.liquidateBorrow(borrower, repayAmount, cTokenCollateral) == 0, "Liquidation failed.");

    // Redeem seized cToken collateral if necessary
    if (exchangeSeizedTo != address(cTokenCollateral)) {
      uint256 seizedCTokenAmount = cTokenCollateral.balanceOf(address(this));

      if (seizedCTokenAmount > 0) {
        uint256 redeemResult = cTokenCollateral.redeem(seizedCTokenAmount);
        require(redeemResult == 0, "Error calling redeeming seized cToken: error code not equal to 0");

        // If cTokenCollateral is CEther
        if (cTokenCollateral.isCEther()) {
          revert("not used anymore");
        } else {
          // Redeem custom collateral if liquidation strategy is set
          IERC20Upgradeable underlyingCollateral = IERC20Upgradeable(ICErc20(address(cTokenCollateral)).underlying());

          if (redemptionStrategies.length > 0) {
            require(
              redemptionStrategies.length == strategyData.length,
              "IRedemptionStrategy contract array and strategy data bytes array must be the same length."
            );
            uint256 underlyingCollateralSeized = underlyingCollateral.balanceOf(address(this));
            for (uint256 i = 0; i < redemptionStrategies.length; i++)
              (underlyingCollateral, underlyingCollateralSeized) = redeemCustomCollateral(
                underlyingCollateral,
                underlyingCollateralSeized,
                redemptionStrategies[i],
                strategyData[i]
              );
          }

          // Exchange redeemed token collateral if necessary
          exchangeAllWethOrTokens(address(underlyingCollateral), exchangeSeizedTo, minOutputAmount, uniswapV2Router);
        }
      }
    }

    // Transfer seized amount to sender
    return transferSeizedFunds(exchangeSeizedTo, minOutputAmount);
  }

  function safeLiquidate(
    address borrower,
    ICEther cEther,
    ICErc20 cErc20Collateral,
    uint256 minOutputAmount,
    address exchangeSeizedTo,
    IUniswapV2Router02 uniswapV2Router,
    IRedemptionStrategy[] memory redemptionStrategies,
    bytes[] memory strategyData
  ) external payable returns (uint256) {
    revert("not used anymore");
  }

  /**
   * @dev Transfers seized funds to the sender.
   * @param erc20Contract The address of the token to transfer.
   * @param minOutputAmount The minimum amount to transfer.
   */
  function transferSeizedFunds(address erc20Contract, uint256 minOutputAmount) internal returns (uint256) {
    IERC20Upgradeable token = IERC20Upgradeable(erc20Contract);
    uint256 seizedOutputAmount = token.balanceOf(address(this));
    require(seizedOutputAmount >= minOutputAmount, "Minimum token output amount not satified.");
    if (seizedOutputAmount > 0) token.safeTransfer(msg.sender, seizedOutputAmount);

    return seizedOutputAmount;
  }

  /**
   * borrower The borrower's Ethereum address.
   * repayAmount The amount to repay to liquidate the unhealthy loan.
   * cErc20 The borrowed CErc20 contract to repay.
   * cTokenCollateral The cToken collateral contract to be liquidated.
   * minProfitAmount The minimum amount of profit required for execution (in terms of `exchangeProfitTo`). Reverts if this condition is not met.
   * exchangeProfitTo If set to an address other than `cTokenCollateral`, exchange seized collateral to this ERC20 token contract address (or the zero address for NATIVE).
   * uniswapV2RouterForBorrow The UniswapV2Router to use to convert the NATIVE to the underlying borrow (and flashloan the underlying borrow for NATIVE). (Is interchangable with any UniV2 forks)
   * uniswapV2RouterForCollateral The UniswapV2Router to use to convert the underlying collateral to NATIVE. (Is interchangable with any UniV2 forks)
   * redemptionStrategies The IRedemptionStrategy contracts to use, if any, to redeem "special" collateral tokens (before swapping the output for borrowed tokens to be repaid via Uniswap).
   * strategyData The data for the chosen IRedemptionStrategy contracts, if any.
   */
  struct LiquidateToTokensWithFlashSwapVars {
    address borrower;
    uint256 repayAmount;
    ICErc20 cErc20;
    ICToken cTokenCollateral;
    IUniswapV2Pair flashSwapPair;
    uint256 minProfitAmount;
    address exchangeProfitTo;
    IUniswapV2Router02 uniswapV2RouterForBorrow;
    IUniswapV2Router02 uniswapV2RouterForCollateral;
    IRedemptionStrategy[] redemptionStrategies;
    bytes[] strategyData;
    uint256 ethToCoinbase;
    IFundsConversionStrategy[] debtFundingStrategies;
    bytes[] debtFundingStrategiesData;
  }

  /**
   * @notice Safely liquidate an unhealthy loan, confirming that at least `minProfitAmount` in NATIVE profit is seized.
   * @param vars @see LiquidateToTokensWithFlashSwapVars.
   */
  function safeLiquidateToTokensWithFlashLoan(LiquidateToTokensWithFlashSwapVars calldata vars)
    external
    returns (uint256)
  {
    // Input validation
    require(vars.repayAmount > 0, "Repay amount must be greater than 0.");

    // we want to calculate the needed flashSwapAmount on-chain to
    // avoid errors due to changing market conditions
    // between the time of calculating and including the tx in a block
    uint256 flashSwapAmount = vars.repayAmount;
    IERC20Upgradeable flashSwapFundingToken = IERC20Upgradeable(ICErc20(address(vars.cErc20)).underlying());
    if (vars.debtFundingStrategies.length > 0) {
      require(
        vars.debtFundingStrategies.length == vars.debtFundingStrategiesData.length,
        "Funding IFundsConversionStrategy contract array and strategy data bytes array must be the same length."
      );
      // loop backwards to estimate the initial input from the final expected output
      for (uint256 i = vars.debtFundingStrategies.length; i > 0; i--) {
        bytes memory strategyData = vars.debtFundingStrategiesData[i - 1];
        IFundsConversionStrategy fcs = vars.debtFundingStrategies[i - 1];
        (flashSwapFundingToken, flashSwapAmount) = fcs.estimateInputAmount(flashSwapAmount, strategyData);
      }
    }

    _flashSwapAmount = flashSwapAmount;
    _flashSwapToken = address(flashSwapFundingToken);

    bool token0IsFlashSwapFundingToken = vars.flashSwapPair.token0() == address(flashSwapFundingToken);
    vars.flashSwapPair.swap(
      token0IsFlashSwapFundingToken ? flashSwapAmount : 0,
      !token0IsFlashSwapFundingToken ? flashSwapAmount : 0,
      address(this),
      msg.data
    );

    // Exchange profit, send NATIVE to coinbase if necessary, and transfer seized funds
    return distributeProfit(vars.exchangeProfitTo, vars.minProfitAmount, vars.ethToCoinbase);
  }

  function safeLiquidateToEthWithFlashLoan(
    address borrower,
    uint256 repayAmount,
    ICEther cEther,
    ICErc20 cErc20Collateral,
    uint256 minProfitAmount,
    address exchangeProfitTo,
    IUniswapV2Router02 uniswapV2RouterForCollateral,
    IRedemptionStrategy[] memory redemptionStrategies,
    bytes[] memory strategyData,
    uint256 ethToCoinbase
  ) external returns (uint256) {
    revert("not used anymore");
  }

  /**
   * Exchange profit, send NATIVE to coinbase if necessary, and transfer seized funds to sender.
   */
  function distributeProfit(
    address exchangeProfitTo,
    uint256 minProfitAmount,
    uint256 ethToCoinbase
  ) private returns (uint256) {
    if (exchangeProfitTo == address(0)) exchangeProfitTo = W_NATIVE_ADDRESS;

    // Transfer NATIVE to block.coinbase if requested
    if (ethToCoinbase > 0) {
      uint256 currentBalance = address(this).balance;
      if (ethToCoinbase > currentBalance) {
        exchangeToExactEth(_liquidatorProfitExchangeSource, ethToCoinbase - currentBalance, UNISWAP_V2_ROUTER_02);
      }
      block.coinbase.call{ value: ethToCoinbase }("");
    }

    // Exchange profit if necessary
    exchangeAllWethOrTokens(_liquidatorProfitExchangeSource, exchangeProfitTo, minProfitAmount, UNISWAP_V2_ROUTER_02);

    // Transfer profit to msg.sender
    return transferSeizedFunds(exchangeProfitTo, minProfitAmount);
  }

  /**
   * @dev Receives NATIVE from liquidations and flashloans.
   * Requires that `msg.sender` is W_NATIVE, a CToken, or a Uniswap V2 Router, or another contract.
   */
  receive() external payable {
    require(payable(msg.sender).isContract(), "Sender is not a contract.");
  }

  /**
   * @dev Callback function for Uniswap flashloans.
   */
  function uniswapV2Call(
    address sender,
    uint256 amount0,
    uint256 amount1,
    bytes calldata data
  ) public override {
    address cToken = abi.decode(data[100:132], (address));

    // Liquidate unhealthy borrow, exchange seized collateral, return flashloaned funds, and exchange profit
    if (ICToken(cToken).isCEther()) {
      revert("not used anymore");
    } else {
      // Decode params
      LiquidateToTokensWithFlashSwapVars memory vars = abi.decode(data[4:], (LiquidateToTokensWithFlashSwapVars));

      // Post token flashloan
      // Cache liquidation profit token (or the zero address for NATIVE) for use as source for exchange later
      _liquidatorProfitExchangeSource = postFlashLoanTokens(vars);
    }
  }

  /**
   * @dev Callback function for PCS flashloans.
   */
  function pancakeCall(
    address sender,
    uint256 amount0,
    uint256 amount1,
    bytes calldata data
  ) external override {
    uniswapV2Call(sender, amount0, amount1, data);
  }

  /**
   * @dev Callback function for BeamSwap flashloans.
   */
  function BeamSwapCall(
    address sender,
    uint256 amount0,
    uint256 amount1,
    bytes calldata data
  ) external {
    uniswapV2Call(sender, amount0, amount1, data);
  }

  function moraswapCall(
    address sender,
    uint256 amount0,
    uint256 amount1,
    bytes calldata data
  ) external {
    uniswapV2Call(sender, amount0, amount1, data);
  }

  /**
   * @dev Liquidate unhealthy token borrow, exchange seized collateral, return flashloaned funds, and exchange profit.
   */
  function postFlashLoanTokens(LiquidateToTokensWithFlashSwapVars memory vars) private returns (address) {
    IERC20Upgradeable debtRepaymentToken = IERC20Upgradeable(_flashSwapToken);
    uint256 debtRepaymentAmount = debtRepaymentToken.balanceOf(address(this));

    if (vars.debtFundingStrategies.length > 0) {
      for (uint256 i = 0; i < vars.debtFundingStrategies.length; i++)
        (debtRepaymentToken, debtRepaymentAmount) = convertCustomFunds(
          debtRepaymentToken,
          debtRepaymentAmount,
          vars.debtFundingStrategies[i],
          vars.debtFundingStrategiesData[i]
        );
    }

    // Approve the debt repayment transfer, liquidate and redeem the seized collateral
    {
      address underlyingBorrow = vars.cErc20.underlying();
      require(
        address(debtRepaymentToken) == underlyingBorrow,
        "the debt repayment funds should be converted to the underlying debt token"
      );
      require(debtRepaymentAmount >= vars.repayAmount, "debt repayment amount not enough");
      // Approve repayAmount to cErc20
      justApprove(IERC20Upgradeable(underlyingBorrow), address(vars.cErc20), vars.repayAmount);

      // Liquidate borrow
      require(
        vars.cErc20.liquidateBorrow(vars.borrower, vars.repayAmount, vars.cTokenCollateral) == 0,
        "Liquidation failed."
      );

      // Redeem seized cTokens for underlying asset
      uint256 seizedCTokenAmount = vars.cTokenCollateral.balanceOf(address(this));
      require(seizedCTokenAmount > 0, "No cTokens seized.");
      uint256 redeemResult = vars.cTokenCollateral.redeem(seizedCTokenAmount);
      require(redeemResult == 0, "Error calling redeeming seized cToken: error code not equal to 0");
    }

    // Repay flashloan
    return
      repayTokenFlashLoan(
        vars.cTokenCollateral,
        vars.exchangeProfitTo,
        vars.uniswapV2RouterForBorrow,
        vars.uniswapV2RouterForCollateral,
        vars.redemptionStrategies,
        vars.strategyData
      );
  }

  /**
   * @dev Repays token flashloans.
   */
  function repayTokenFlashLoan(
    ICToken cTokenCollateral,
    address exchangeProfitTo,
    IUniswapV2Router02 uniswapV2RouterForBorrow,
    IUniswapV2Router02 uniswapV2RouterForCollateral,
    IRedemptionStrategy[] memory redemptionStrategies,
    bytes[] memory strategyData
  ) private returns (address) {
    // Calculate flashloan return amount
    uint256 flashSwapReturnAmount = (_flashSwapAmount * 10000) / (10000 - flashSwapFee);
    if ((_flashSwapAmount * 10000) % (10000 - flashSwapFee) > 0) flashSwapReturnAmount++; // Round up if division resulted in a remainder

    // Swap cTokenCollateral for cErc20 via Uniswap
    if (cTokenCollateral.isCEther()) {
      revert("not used anymore");
    }

    // Check underlying collateral seized
    IERC20Upgradeable underlyingCollateral = IERC20Upgradeable(ICErc20(address(cTokenCollateral)).underlying());
    uint256 underlyingCollateralSeized = underlyingCollateral.balanceOf(address(this));

    // Redeem custom collateral if liquidation strategy is set
    if (redemptionStrategies.length > 0) {
      require(
        redemptionStrategies.length == strategyData.length,
        "IRedemptionStrategy contract array and strategy data bytes array mnust the the same length."
      );
      for (uint256 i = 0; i < redemptionStrategies.length; i++)
        (underlyingCollateral, underlyingCollateralSeized) = redeemCustomCollateral(
          underlyingCollateral,
          underlyingCollateralSeized,
          redemptionStrategies[i],
          strategyData[i]
        );
    }

    IUniswapV2Pair pair = IUniswapV2Pair(msg.sender);

    // Check if we can repay directly one of the sides with collateral
    if (address(underlyingCollateral) == pair.token0() || address(underlyingCollateral) == pair.token1()) {
      // Repay flashloan directly with collateral
      uint256 collateralRequired;
      if (address(underlyingCollateral) == _flashSwapToken) {
        // repay amount for the borrow side
        collateralRequired = flashSwapReturnAmount;
      } else {
        // repay amount for the non-borrow side
        collateralRequired = UniswapV2Library.getAmountsIn(
          uniswapV2RouterForBorrow.factory(),
          _flashSwapAmount, //flashSwapReturnAmount,
          array(address(underlyingCollateral), _flashSwapToken),
          flashSwapFee
        )[0];
      }

      // Repay flashloan
      require(
        collateralRequired <= underlyingCollateralSeized,
        "Token flashloan return amount greater than seized collateral."
      );
      require(
        underlyingCollateral.transfer(msg.sender, collateralRequired),
        "Failed to repay token flashloan on borrow side."
      );

      return address(underlyingCollateral);
    } else {
      // exchange the collateral to W_NATIVE to repay the borrow side
      uint256 wethRequired;
      if (_flashSwapToken == W_NATIVE_ADDRESS) {
        wethRequired = flashSwapReturnAmount;
      } else {
        // Get W_NATIVE required to repay flashloan
        wethRequired = UniswapV2Library.getAmountsIn(
          uniswapV2RouterForBorrow.factory(),
          flashSwapReturnAmount,
          array(W_NATIVE_ADDRESS, _flashSwapToken),
          flashSwapFee
        )[0];
      }

      if (address(underlyingCollateral) != W_NATIVE_ADDRESS) {
        // Approve to Uniswap router
        justApprove(underlyingCollateral, address(uniswapV2RouterForCollateral), underlyingCollateralSeized);

        // Swap collateral tokens for W_NATIVE to be repaid via Uniswap router
        if (exchangeProfitTo == address(underlyingCollateral))
          uniswapV2RouterForCollateral.swapTokensForExactTokens(
            wethRequired,
            underlyingCollateralSeized,
            array(address(underlyingCollateral), W_NATIVE_ADDRESS),
            address(this),
            block.timestamp
          );
        else
          uniswapV2RouterForCollateral.swapExactTokensForTokens(
            underlyingCollateralSeized,
            wethRequired,
            array(address(underlyingCollateral), W_NATIVE_ADDRESS),
            address(this),
            block.timestamp
          );
      }

      // Repay flashloan
      require(
        wethRequired <= IERC20Upgradeable(W_NATIVE_ADDRESS).balanceOf(address(this)),
        "Not enough W_NATIVE exchanged from seized collateral to repay flashloan."
      );
      require(
        W_NATIVE.transfer(msg.sender, wethRequired),
        "Failed to repay Uniswap flashloan with W_NATIVE exchanged from seized collateral."
      );

      // Return the profited token (underlying collateral if same as exchangeProfitTo; otherwise, W_NATIVE)
      return exchangeProfitTo == address(underlyingCollateral) ? address(underlyingCollateral) : W_NATIVE_ADDRESS;
    }
  }

  /**
   * @dev for security reasons only whitelisted redemption strategies may be used.
   * Each whitelisted redemption strategy has to be checked to not be able to
   * call `selfdestruct` with the `delegatecall` call in `redeemCustomCollateral`
   */
  function _whitelistRedemptionStrategy(IRedemptionStrategy strategy, bool whitelisted) external onlyOwner {
    redemptionStrategiesWhitelist[address(strategy)] = whitelisted;
  }

  /**
   * @dev for security reasons only whitelisted redemption strategies may be used.
   * Each whitelisted redemption strategy has to be checked to not be able to
   * call `selfdestruct` with the `delegatecall` call in `redeemCustomCollateral`
   */
  function _whitelistRedemptionStrategies(IRedemptionStrategy[] calldata strategies, bool[] calldata whitelisted)
    external
    onlyOwner
  {
    require(
      strategies.length > 0 && strategies.length == whitelisted.length,
      "list of strategies empty or whitelist does not match its length"
    );

    for (uint256 i = 0; i < strategies.length; i++) {
      redemptionStrategiesWhitelist[address(strategies[i])] = whitelisted[i];
    }
  }

  /**
   * @dev Redeem "special" collateral tokens (before swapping the output for borrowed tokens to be repaid via Uniswap).
   * Public visibility because we have to call this function externally if called from a payable FuseSafeLiquidator function (for some reason delegatecall fails when called with msg.value > 0).
   */
  function redeemCustomCollateral(
    IERC20Upgradeable underlyingCollateral,
    uint256 underlyingCollateralSeized,
    IRedemptionStrategy strategy,
    bytes memory strategyData
  ) public returns (IERC20Upgradeable, uint256) {
    require(redemptionStrategiesWhitelist[address(strategy)], "only whitelisted redemption strategies can be used");

    bytes memory returndata = _functionDelegateCall(
      address(strategy),
      abi.encodeWithSelector(strategy.redeem.selector, underlyingCollateral, underlyingCollateralSeized, strategyData)
    );
    return abi.decode(returndata, (IERC20Upgradeable, uint256));
  }

  function convertCustomFunds(
    IERC20Upgradeable inputToken,
    uint256 inputAmount,
    IFundsConversionStrategy strategy,
    bytes memory strategyData
  ) public returns (IERC20Upgradeable, uint256) {
    require(redemptionStrategiesWhitelist[address(strategy)], "only whitelisted redemption strategies can be used");

    bytes memory returndata = _functionDelegateCall(
      address(strategy),
      abi.encodeWithSelector(strategy.convert.selector, inputToken, inputAmount, strategyData)
    );
    return abi.decode(returndata, (IERC20Upgradeable, uint256));
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`], but performing a delegate call.
   * Copied from https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/contracts/blob/cb4774ace1cb84f2662fa47c573780aab937628b/contracts/utils/MulticallUpgradeable.sol#L37
   */
  function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
    require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.delegatecall(data);
    return _verifyCallResult(success, returndata, "Address: low-level delegate call failed");
  }

  /**
   * @dev Used by `_functionDelegateCall` to verify the result of a delegate call.
   * Copied from https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/contracts/blob/cb4774ace1cb84f2662fa47c573780aab937628b/contracts/utils/MulticallUpgradeable.sol#L45
   */
  function _verifyCallResult(
    bool success,
    bytes memory returndata,
    string memory errorMessage
  ) private pure returns (bytes memory) {
    if (success) {
      return returndata;
    } else {
      // Look for revert reason and bubble it up if present
      if (returndata.length > 0) {
        // The easiest way to bubble the revert reason is using memory via assembly

        // solhint-disable-next-line no-inline-assembly
        assembly {
          let returndata_size := mload(returndata)
          revert(add(32, returndata), returndata_size)
        }
      } else {
        revert(errorMessage);
      }
    }
  }

  /**
   * @dev Returns an array containing the parameters supplied.
   */
  function array(uint256 a) private pure returns (uint256[] memory) {
    uint256[] memory arr = new uint256[](1);
    arr[0] = a;
    return arr;
  }

  /**
   * @dev Returns an array containing the parameters supplied.
   */
  function array(address a) private pure returns (address[] memory) {
    address[] memory arr = new address[](1);
    arr[0] = a;
    return arr;
  }

  /**
   * @dev Returns an array containing the parameters supplied.
   */
  function array(address a, address b) private pure returns (address[] memory) {
    address[] memory arr = new address[](2);
    arr[0] = a;
    arr[1] = b;
    return arr;
  }

  /**
   * @dev Returns an array containing the parameters supplied.
   */
  function array(
    address a,
    address b,
    address c
  ) private pure returns (address[] memory) {
    address[] memory arr = new address[](3);
    arr[0] = a;
    arr[1] = b;
    arr[2] = c;
    return arr;
  }
}

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity >=0.8.0;

import "./ICToken.sol";

/**
 * @title Compound's CErc20 Contract
 * @notice CTokens which wrap an EIP-20 underlying
 * @author Compound
 */
interface ICErc20 is ICToken {
  function underlying() external view returns (address);

  function liquidateBorrow(
    address borrower,
    uint256 repayAmount,
    ICToken cTokenCollateral
  ) external returns (uint256);
}

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity >=0.8.0;

import "./ICToken.sol";

/**
 * @title Compound's CEther Contract
 * @notice CTokens which wrap an EIP-20 underlying
 * @author Compound
 */
interface ICEther is ICToken {
  function liquidateBorrow(address borrower, ICToken cTokenCollateral) external payable;
}

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity >=0.8.0;

/**
 * @title Compound's CToken Contract
 * @notice Abstract base for CTokens
 * @author Compound
 */
interface ICToken {
  function admin() external view returns (address);

  function adminHasRights() external view returns (bool);

  function fuseAdminHasRights() external view returns (bool);

  function symbol() external view returns (string memory);

  function comptroller() external view returns (address);

  function adminFeeMantissa() external view returns (uint256);

  function fuseFeeMantissa() external view returns (uint256);

  function reserveFactorMantissa() external view returns (uint256);

  function totalReserves() external view returns (uint256);

  function totalAdminFees() external view returns (uint256);

  function totalFuseFees() external view returns (uint256);

  function isCToken() external view returns (bool);

  function isCEther() external view returns (bool);

  function balanceOf(address owner) external view returns (uint256);

  function balanceOfUnderlying(address owner) external returns (uint256);

  function borrowRatePerBlock() external view returns (uint256);

  function supplyRatePerBlock() external view returns (uint256);

  function totalBorrowsCurrent() external returns (uint256);

  function borrowBalanceStored(address account) external view returns (uint256);

  function exchangeRateCurrent() external view returns (uint256);

  function exchangeRateStored() external view returns (uint256);

  function getCash() external view returns (uint256);

  function mint(uint256 mintAmount) external returns (uint256);

  function redeem(uint256 redeemTokens) external returns (uint256);

  function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

  function protocolSeizeShareMantissa() external view returns (uint256);

  function feeSeizeShareMantissa() external view returns (uint256);
}

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity >=0.8.0;

import "./IPriceOracle.sol";
import "./ICToken.sol";
import "./IUnitroller.sol";
import "./IRewardsDistributor.sol";

/**
 * @title Compound's Comptroller Contract
 * @author Compound
 */
interface IComptroller {
  function admin() external view returns (address);

  function adminHasRights() external view returns (bool);

  function fuseAdminHasRights() external view returns (bool);

  function oracle() external view returns (IPriceOracle);

  function closeFactorMantissa() external view returns (uint256);

  function liquidationIncentiveMantissa() external view returns (uint256);

  function markets(address cToken) external view returns (bool, uint256);

  function getAssetsIn(address account) external view returns (ICToken[] memory);

  function checkMembership(address account, ICToken cToken) external view returns (bool);

  function getHypotheticalAccountLiquidity(
    address account,
    address cTokenModify,
    uint256 redeemTokens,
    uint256 borrowAmount
  )
    external
    view
    returns (
      uint256,
      uint256,
      uint256
    );

  function _setPriceOracle(IPriceOracle newOracle) external returns (uint256);

  function _setCloseFactor(uint256 newCloseFactorMantissa) external returns (uint256);

  function _setLiquidationIncentive(uint256 newLiquidationIncentiveMantissa) external returns (uint256);

  function _become(IUnitroller unitroller) external;

  function borrowGuardianPaused(address cToken) external view returns (bool);

  function mintGuardianPaused(address cToken) external view returns (bool);

  function getRewardsDistributors() external view returns (IRewardsDistributor[] memory);

  function getAllMarkets() external view returns (ICToken[] memory);

  function getAllBorrowers() external view returns (address[] memory);

  function suppliers(address account) external view returns (bool);

  function enforceWhitelist() external view returns (bool);

  function isUserOfPool(address user) external view returns (bool);

  function whitelist(address account) external view returns (bool);

  function _setWhitelistEnforcement(bool enforce) external returns (uint256);

  function _setWhitelistStatuses(address[] calldata _suppliers, bool[] calldata statuses) external returns (uint256);

  function _toggleAutoImplementations(bool enabled) external returns (uint256);

  function _deployMarket(
    bool isCEther,
    bytes memory constructorData,
    uint256 collateralFactorMantissa
  ) external returns (uint256);

  function getMaxRedeemOrBorrow(
    address account,
    ICToken cTokenModify,
    bool isBorrow
  ) external returns (uint256);
}

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity >=0.8.0;

import "./ICToken.sol";

interface IPriceOracle {
  /**
   * @notice Get the underlying price of a cToken asset
   * @param cToken The cToken to get the underlying price of
   * @return The underlying asset price mantissa (scaled by 1e18).
   *  Zero means the price is unavailable.
   */
  function getUnderlyingPrice(ICToken cToken) external view returns (uint256);
}

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity >=0.8.0;

import "./ICToken.sol";

/**
 * @title RewardsDistributor
 * @author Compound
 */
interface IRewardsDistributor {
  /// @dev The token to reward (i.e., COMP)
  function rewardToken() external view returns (address);

  /// @notice The portion of compRate that each market currently receives
  function compSupplySpeeds(address) external view returns (uint256);

  /// @notice The portion of compRate that each market currently receives
  function compBorrowSpeeds(address) external view returns (uint256);

  /// @notice The COMP accrued but not yet transferred to each user
  function compAccrued(address) external view returns (uint256);

  /**
   * @notice Keeps the flywheel moving pre-mint and pre-redeem
   * @dev Called by the Comptroller
   * @param cToken The relevant market
   * @param supplier The minter/redeemer
   */
  function flywheelPreSupplierAction(address cToken, address supplier) external;

  /**
   * @notice Keeps the flywheel moving pre-borrow and pre-repay
   * @dev Called by the Comptroller
   * @param cToken The relevant market
   * @param borrower The borrower
   */
  function flywheelPreBorrowerAction(address cToken, address borrower) external;

  /**
   * @notice Returns an array of all markets.
   */
  function getAllMarkets() external view returns (ICToken[] memory);
}

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity >=0.8.0;

/**
 * @title ComptrollerCore
 * @dev Storage for the comptroller is at this address, while execution is delegated to the `comptrollerImplementation`.
 * CTokens should reference this contract as their comptroller.
 */
interface IUnitroller {
  function _setPendingImplementation(address newPendingImplementation) external returns (uint256);

  function _setPendingAdmin(address newPendingAdmin) external returns (uint256);
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.4;

import { IERC20Upgradeable } from "openzeppelin-contracts-upgradeable/contracts/token/ERC20/IERC20Upgradeable.sol";
import "./ISynthereumFinder.sol";

/**
 * @title Interface that a pool MUST have in order to be included in the deployer
 */
interface ISynthereumDeployment {
  /**
   * @notice Get Synthereum finder of the pool/self-minting derivative
   * @return finder Returns finder contract
   */
  function synthereumFinder() external view returns (ISynthereumFinder finder);

  /**
   * @notice Get Synthereum version
   * @return poolVersion Returns the version of this pool/self-minting derivative
   */
  function version() external view returns (uint8 poolVersion);

  /**
   * @notice Get the collateral token of this pool/self-minting derivative
   * @return collateralCurrency The ERC20 collateral token
   */
  function collateralToken() external view returns (IERC20Upgradeable collateralCurrency);

  /**
   * @notice Get the synthetic token associated to this pool/self-minting derivative
   * @return syntheticCurrency The ERC20 synthetic token
   */
  function syntheticToken() external view returns (IERC20Upgradeable syntheticCurrency);

  /**
   * @notice Get the synthetic token symbol associated to this pool/self-minting derivative
   * @return symbol The ERC20 synthetic token symbol
   */
  function syntheticTokenSymbol() external view returns (string memory symbol);
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.4;

/**
 * @title Provides addresses of the contracts implementing certain interfaces.
 */
interface ISynthereumFinder {
  /**
   * @notice Updates the address of the contract that implements `interfaceName`.
   * @param interfaceName bytes32 encoding of the interface name that is either changed or registered.
   * @param implementationAddress address of the deployed contract that implements the interface.
   */
  function changeImplementationAddress(bytes32 interfaceName, address implementationAddress) external;

  /**
   * @notice Gets the address of the contract that implements the given `interfaceName`.
   * @param interfaceName queried interface.
   * @return implementationAddress Address of the deployed contract that implements the interface.
   */
  function getImplementationAddress(bytes32 interfaceName) external view returns (address);
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.4;

import "./ISynthereumLiquidityPoolGeneral.sol";

//import {
//IEmergencyShutdown
//} from '../../../common/interfaces/IEmergencyShutdown.sol';
//import {ISynthereumLiquidityPoolGeneral} from './ILiquidityPoolGeneral.sol';
//import {ISynthereumLiquidityPoolStorage} from './ILiquidityPoolStorage.sol';
//import {ITypology} from '../../../common/interfaces/ITypology.sol';

/**
 * @title Token Issuer Contract Interface
 */
//ITypology,
//IEmergencyShutdown,
interface ISynthereumLiquidityPool is ISynthereumLiquidityPoolGeneral {
  struct MintParams {
    // Minimum amount of synthetic tokens that a user wants to mint using collateral (anti-slippage)
    uint256 minNumTokens;
    // Amount of collateral that a user wants to spend for minting
    uint256 collateralAmount;
    // Expiration time of the transaction
    uint256 expiration;
    // Address to which send synthetic tokens minted
    address recipient;
  }

  struct RedeemParams {
    // Amount of synthetic tokens that user wants to use for redeeming
    uint256 numTokens;
    // Minimium amount of collateral that user wants to redeem (anti-slippage)
    uint256 minCollateral;
    // Expiration time of the transaction
    uint256 expiration;
    // Address to which send collateral tokens redeemed
    address recipient;
  }

  //  struct ExchangeParams {
  //    // Destination pool
  //    ISynthereumLiquidityPoolGeneral destPool;
  //    // Amount of source synthetic tokens that user wants to use for exchanging
  //    uint256 numTokens;
  //    // Minimum Amount of destination synthetic tokens that user wants to receive (anti-slippage)
  //    uint256 minDestNumTokens;
  //    // Expiration time of the transaction
  //    uint256 expiration;
  //    // Address to which send synthetic tokens exchanged
  //    address recipient;
  //  }

  /**
   * @notice Mint synthetic tokens using fixed amount of collateral
   * @notice This calculate the price using on chain price feed
   * @notice User must approve collateral transfer for the mint request to succeed
   * @param mintParams Input parameters for minting (see MintParams struct)
   * @return syntheticTokensMinted Amount of synthetic tokens minted by a user
   * @return feePaid Amount of collateral paid by the user as fee
   */
  function mint(MintParams calldata mintParams) external returns (uint256 syntheticTokensMinted, uint256 feePaid);

  /**
   * @notice Redeem amount of collateral using fixed number of synthetic token
   * @notice This calculate the price using on chain price feed
   * @notice User must approve synthetic token transfer for the redeem request to succeed
   * @param redeemParams Input parameters for redeeming (see RedeemParams struct)
   * @return collateralRedeemed Amount of collateral redeem by user
   * @return feePaid Amount of collateral paid by user as fee
   */
  function redeem(RedeemParams calldata redeemParams) external returns (uint256 collateralRedeemed, uint256 feePaid);

  //  /**
  //   * @notice Exchange a fixed amount of synthetic token of this pool, with an amount of synthetic tokens of an another pool
  //   * @notice This calculate the price using on chain price feed
  //   * @notice User must approve synthetic token transfer for the redeem request to succeed
  //   * @param exchangeParams Input parameters for exchanging (see ExchangeParams struct)
  //   * @return destNumTokensMinted Amount of collateral redeem by user
  //   * @return feePaid Amount of collateral paid by user as fee
  //   */
  //  function exchange(ExchangeParams calldata exchangeParams)
  //  external
  //  returns (uint256 destNumTokensMinted, uint256 feePaid);

  /**
   * @notice Withdraw unused deposited collateral by the LP
   * @notice Only a sender with LP role can call this function
   * @param collateralAmount Collateral to be withdrawn
   * @return remainingLiquidity Remaining unused collateral in the pool
   */
  function withdrawLiquidity(uint256 collateralAmount) external returns (uint256 remainingLiquidity);

  /**
   * @notice Increase collaterallization of Lp position
   * @notice Only a sender with LP role can call this function
   * @param collateralToTransfer Collateral to be transferred before increase collateral in the position
   * @param collateralToIncrease Collateral to be added to the position
   * @return newTotalCollateral New total collateral amount
   */
  function increaseCollateral(uint256 collateralToTransfer, uint256 collateralToIncrease)
    external
    returns (uint256 newTotalCollateral);

  /**
   * @notice Decrease collaterallization of Lp position
   * @notice Check that final poosition is not undercollateralized
   * @notice Only a sender with LP role can call this function
   * @param collateralToDecrease Collateral to decreased from the position
   * @param collateralToWithdraw Collateral to be transferred to the LP
   * @return newTotalCollateral New total collateral amount
   */
  function decreaseCollateral(uint256 collateralToDecrease, uint256 collateralToWithdraw)
    external
    returns (uint256 newTotalCollateral);

  /**
   * @notice Withdraw fees gained by the sender
   * @return feeClaimed Amount of fee claimed
   */
  function claimFee() external returns (uint256 feeClaimed);

  /**
   * @notice Liquidate Lp position for an amount of synthetic tokens undercollateralized
   * @notice Revert if position is not undercollateralized
   * @param numSynthTokens Number of synthetic tokens that user wants to liquidate
   * @return synthTokensLiquidated Amount of synthetic tokens liquidated
   * @return collateralReceived Amount of received collateral equal to the value of tokens liquidated
   * @return rewardAmount Amount of received collateral as reward for the liquidation
   */
  function liquidate(uint256 numSynthTokens)
    external
    returns (
      uint256 synthTokensLiquidated,
      uint256 collateralReceived,
      uint256 rewardAmount
    );

  /**
   * @notice Redeem tokens after emergency shutdown
   * @return synthTokensSettled Amount of synthetic tokens liquidated
   * @return collateralSettled Amount of collateral withdrawn after emergency shutdown
   */
  function settleEmergencyShutdown() external returns (uint256 synthTokensSettled, uint256 collateralSettled);

  //  /**
  //   * @notice Update the fee percentage, recipients and recipient proportions
  //   * @notice Only the maintainer can call this function
  //   * @param _feeData Fee info (percentage + recipients + weigths)
  //   */
  //  function setFee(ISynthereumLiquidityPoolStorage.FeeData calldata _feeData)
  //  external;

  /**
   * @notice Update the fee percentage
   * @notice Only the maintainer can call this function
   * @param _feePercentage The new fee percentage
   */
  function setFeePercentage(uint256 _feePercentage) external;

  /**
   * @notice Update the addresses of recipients for generated fees and proportions of fees each address will receive
   * @notice Only the maintainer can call this function
   * @param feeRecipients An array of the addresses of recipients that will receive generated fees
   * @param feeProportions An array of the proportions of fees generated each recipient will receive
   */
  function setFeeRecipients(address[] calldata feeRecipients, uint32[] calldata feeProportions) external;

  /**
   * @notice Update the overcollateralization percentage
   * @notice Only the maintainer can call this function
   * @param _overCollateralization Overcollateralization percentage
   */
  function setOverCollateralization(uint256 _overCollateralization) external;

  /**
   * @notice Update the liquidation reward percentage
   * @notice Only the maintainer can call this function
   * @param _liquidationReward Percentage of reward for correct liquidation by a liquidator
   */
  function setLiquidationReward(uint256 _liquidationReward) external;

  /**
   * @notice Returns fee percentage set by the maintainer
   * @return Fee percentage
   */
  function feePercentage() external view returns (uint256);

  /**
   * @notice Returns fee recipients info
   * @return Addresses, weigths and total of weigths
   */
  function feeRecipientsInfo()
    external
    view
    returns (
      address[] memory,
      uint32[] memory,
      uint256
    );

  /**
   * @notice Returns total number of synthetic tokens generated by this pool
   * @return Number of synthetic tokens
   */
  function totalSyntheticTokens() external view returns (uint256);

  /**
   * @notice Returns the total amount of collateral used for collateralizing tokens (users + LP)
   * @return Total collateral amount
   */
  function totalCollateralAmount() external view returns (uint256);

  /**
   * @notice Returns the total amount of fees to be withdrawn
   * @return Total fee amount
   */
  function totalFeeAmount() external view returns (uint256);

  /**
   * @notice Returns the user's fee to be withdrawn
   * @param user User's address
   * @return User's fee
   */
  function userFee(address user) external view returns (uint256);

  /**
   * @notice Returns the percentage of overcollateralization to which a liquidation can triggered
   * @return Percentage of overcollateralization
   */
  function collateralRequirement() external view returns (uint256);

  /**
   * @notice Returns the percentage of reward for correct liquidation by a liquidator
   * @return Percentage of reward
   */
  function liquidationReward() external view returns (uint256);

  /**
   * @notice Returns the price of the pair at the moment of the shutdown
   * @return Price of the pair
   */
  function emergencyShutdownPrice() external view returns (uint256);

  /**
   * @notice Returns the timestamp (unix time) at the moment of the shutdown
   * @return Timestamp
   */
  function emergencyShutdownTimestamp() external view returns (uint256);

  /**
   * @notice Returns if position is overcollateralized and thepercentage of coverage of the collateral according to the last price
   * @return True if position is overcollaterlized, otherwise false + percentage of coverage (totalCollateralAmount / (price * tokensCollateralized))
   */
  function collateralCoverage() external returns (bool, uint256);

  /**
   * @notice Returns the synthetic tokens will be received and fees will be paid in exchange for an input collateral amount
   * @notice This function is only trading-informative, it doesn't check liquidity and collateralization conditions
   * @param inputCollateral Input collateral amount to be exchanged
   * @return synthTokensReceived Synthetic tokens will be minted
   * @return feePaid Collateral fee will be paid
   */
  function getMintTradeInfo(uint256 inputCollateral)
    external
    view
    returns (uint256 synthTokensReceived, uint256 feePaid);

  /**
   * @notice Returns the collateral amount will be received and fees will be paid in exchange for an input amount of synthetic tokens
   * @notice This function is only trading-informative, it doesn't check liquidity and collateralization conditions
   * @param  syntheticTokens Amount of synthetic tokens to be exchanged
   * @return collateralAmountReceived Collateral amount will be received by the user
   * @return feePaid Collateral fee will be paid
   */
  function getRedeemTradeInfo(uint256 syntheticTokens)
    external
    view
    returns (uint256 collateralAmountReceived, uint256 feePaid);

  //  /**
  //   * @notice Returns the destination synthetic tokens amount will be received and fees will be paid in exchange for an input amount of synthetic tokens
  //   * @notice This function is only trading-informative, it doesn't check liquidity and collateralization conditions
  //   * @param  syntheticTokens Amount of synthetic tokens to be exchanged
  //   * @param  destinationPool Pool in which mint the destination synthetic token
  //   * @return destSyntheticTokensReceived Synthetic tokens will be received from destination pool
  //   * @return feePaid Collateral fee will be paid
  //   */
  //  function getExchangeTradeInfo(
  //    uint256 syntheticTokens,
  //    ISynthereumLiquidityPoolGeneral destinationPool
  //  )
  //  external
  //  view
  //  returns (uint256 destSyntheticTokensReceived, uint256 feePaid);
  /**
   * @notice Shutdown the pool or self-minting-derivative in case of emergency
   * @notice Only Synthereum manager contract can call this function
   * @return timestamp Timestamp of emergency shutdown transaction
   * @return price Price of the pair at the moment of shutdown execution
   */
  function emergencyShutdown() external returns (uint256 timestamp, uint256 price);
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.4;

import "./ISynthereumDeployment.sol";

interface ISynthereumLiquidityPoolGeneral is
  ISynthereumDeployment
  //,
  //ISynthereumLiquidityPoolInteraction
{}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.0;

interface IUniswapV2Callee {
  function uniswapV2Call(
    address sender,
    uint256 amount0,
    uint256 amount1,
    bytes calldata data
  ) external;

  function pancakeCall(
    address sender,
    uint256 amount0,
    uint256 amount1,
    bytes calldata data
  ) external;
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.0;

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

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.0;

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

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.0;

interface IUniswapV2Router01 {
  function factory() external pure returns (address);

  function WETH() external pure returns (address);

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

  function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.0;

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

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.0;

import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";

library UniswapV2Library {
  // returns sorted token addresses, used to handle return values from pairs sorted in this order
  function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
    require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
    (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
  }

  function pairFor(
    address factory,
    address tokenA,
    address tokenB
  ) internal view returns (address pair) {
    return IUniswapV2Factory(factory).getPair(tokenA, tokenB);
  }

  // fetches and sorts the reserves for a pair
  function getReserves(
    address factory,
    address tokenA,
    address tokenB
  ) internal view returns (uint256 reserveA, uint256 reserveB) {
    (address token0, ) = sortTokens(tokenA, tokenB);
    (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
    (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
  }

  // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
  function quote(
    uint256 amountA,
    uint256 reserveA,
    uint256 reserveB
  ) internal pure returns (uint256 amountB) {
    require(amountA > 0, "UniswapV2Library: INSUFFICIENT_AMOUNT");
    require(reserveA > 0 && reserveB > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
    amountB = (amountA * reserveB) / reserveA;
  }

  // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut,
    uint8 flashSwapFee
  ) internal pure returns (uint256 amountOut) {
    require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
    require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
    uint256 amountInWithFee = amountIn * (10000 - flashSwapFee);
    uint256 numerator = amountInWithFee * reserveOut;
    uint256 denominator = reserveIn * 10000 + amountInWithFee;
    amountOut = numerator / denominator;
  }

  // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
    uint256 reserveOut,
    uint8 flashSwapFee
  ) internal pure returns (uint256 amountIn) {
    require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
    require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
    uint256 numerator = reserveIn * amountOut * 10000;
    uint256 denominator = (reserveOut - amountOut) * (10000 - flashSwapFee);
    amountIn = numerator / denominator + 1;
  }

  // performs chained getAmountOut calculations on any number of pairs
  function getAmountsOut(
    address factory,
    uint256 amountIn,
    address[] memory path,
    uint8 flashSwapFee
  ) internal view returns (uint256[] memory amounts) {
    require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
    amounts = new uint256[](path.length);
    amounts[0] = amountIn;
    for (uint256 i; i < path.length - 1; i++) {
      (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i], path[i + 1]);
      amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut, flashSwapFee);
    }
  }

  // performs chained getAmountIn calculations on any number of pairs
  function getAmountsIn(
    address factory,
    uint256 amountOut,
    address[] memory path,
    uint8 flashSwapFee
  ) internal view returns (uint256[] memory amounts) {
    require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
    amounts = new uint256[](path.length);
    amounts[amounts.length - 1] = amountOut;
    for (uint256 i = path.length - 1; i > 0; i--) {
      (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i - 1], path[i]);
      amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut, flashSwapFee);
    }
  }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "./IRedemptionStrategy.sol";
import "openzeppelin-contracts-upgradeable/contracts/token/ERC20/IERC20Upgradeable.sol";

interface IFundsConversionStrategy is IRedemptionStrategy {
  function convert(
    IERC20Upgradeable inputToken,
    uint256 inputAmount,
    bytes memory strategyData
  ) external returns (IERC20Upgradeable outputToken, uint256 outputAmount);

  function estimateInputAmount(uint256 outputAmount, bytes memory strategyData)
    external
    view
    returns (IERC20Upgradeable inputToken, uint256 inputAmount);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "openzeppelin-contracts-upgradeable/contracts/token/ERC20/IERC20Upgradeable.sol";

/**
 * @title IRedemptionStrategy
 * @notice Redeems seized wrapped token collateral for an underlying token for use as a step in a liquidation.
 * @author David Lucid <[email protected]> (https://github.com/davidlucid)
 */
interface IRedemptionStrategy {
  /**
   * @notice Redeems custom collateral `token` for an underlying token.
   * @param inputToken The input wrapped token to be redeemed for an underlying token.
   * @param inputAmount The amount of the input wrapped token to be redeemed for an underlying token.
   * @param strategyData The ABI-encoded data to be used in the redemption strategy logic.
   * @return outputToken The underlying ERC20 token outputted.
   * @return outputAmount The quantity of underlying tokens outputted.
   */
  function redeem(
    IERC20Upgradeable inputToken,
    uint256 inputAmount,
    bytes memory strategyData
  ) external returns (IERC20Upgradeable outputToken, uint256 outputAmount);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import { IERC20Upgradeable } from "openzeppelin-contracts-upgradeable/contracts/token/ERC20/IERC20Upgradeable.sol";
import { IERC20MetadataUpgradeable } from "openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import { FixedPointMathLib } from "../utils/FixedPointMathLib.sol";
import { IFundsConversionStrategy } from "./IFundsConversionStrategy.sol";
import { ISynthereumLiquidityPool } from "../external/jarvis/ISynthereumLiquidityPool.sol";

contract JarvisLiquidatorFunder is IFundsConversionStrategy {
  using FixedPointMathLib for uint256;

  /**
   * @dev Redeems `inputToken` for `outputToken` where `inputAmount` < `outputAmount`
   * @param inputToken Address of the token
   * @param inputAmount input amount
   * @param strategyData context specific data like input token, pool address and tx expiratio period
   */
  function redeem(
    IERC20Upgradeable inputToken,
    uint256 inputAmount,
    bytes memory strategyData
  ) external override returns (IERC20Upgradeable outputToken, uint256 outputAmount) {
    return _convert(inputToken, inputAmount, strategyData);
  }

  function convert(
    IERC20Upgradeable inputToken,
    uint256 inputAmount,
    bytes memory strategyData
  ) external override returns (IERC20Upgradeable outputToken, uint256 outputAmount) {
    return _convert(inputToken, inputAmount, strategyData);
  }

  function _convert(
    IERC20Upgradeable inputToken,
    uint256 inputAmount,
    bytes memory strategyData
  ) internal returns (IERC20Upgradeable outputToken, uint256 outputAmount) {
    (, address poolAddress, uint256 txExpirationPeriod) = abi.decode(strategyData, (address, address, uint256));
    ISynthereumLiquidityPool pool = ISynthereumLiquidityPool(poolAddress);

    // approve so the pool can pull out the input tokens
    inputToken.approve(address(pool), inputAmount);

    if (inputToken == pool.syntheticToken()) {
      outputToken = IERC20Upgradeable(address(pool.collateralToken()));

      uint256 shutdownPrice = 0;
      // TODO figure out why this method was removed and what to use instead
      try pool.emergencyShutdownPrice() returns (uint256 price) {
        shutdownPrice = price;
      } catch {}

      if (shutdownPrice > 0) {
        // emergency shutdowns cannot be reverted, so this corner case must be covered
        (, uint256 collateralSettled) = pool.settleEmergencyShutdown();
        outputAmount = collateralSettled;
        outputToken = IERC20Upgradeable(address(pool.collateralToken()));
      } else {
        // redeem the underlying BUSD
        // fetch the estimated redeemable collateral in BUSD, less the fee paid
        (uint256 redeemableCollateralAmount, ) = pool.getRedeemTradeInfo(inputAmount);

        // Expiration time of the transaction
        uint256 expirationTime = block.timestamp + txExpirationPeriod;

        (uint256 collateralAmountReceived, uint256 feePaid) = pool.redeem(
          ISynthereumLiquidityPool.RedeemParams(inputAmount, redeemableCollateralAmount, expirationTime, address(this))
        );

        outputAmount = collateralAmountReceived;
      }
    } else if (inputToken == pool.collateralToken()) {
      outputToken = IERC20Upgradeable(address(pool.syntheticToken()));

      // mint jBRL from the supplied bUSD
      (uint256 synthTokensReceived, ) = pool.getMintTradeInfo(inputAmount);
      // Expiration time of the transaction
      uint256 expirationTime = block.timestamp + txExpirationPeriod;

      (uint256 syntheticTokensMinted, uint256 feePaid) = pool.mint(
        ISynthereumLiquidityPool.MintParams(synthTokensReceived, inputAmount, expirationTime, address(this))
      );

      outputAmount = syntheticTokensMinted;
    } else {
      revert("unknown input token");
    }
  }

  /**
   * @dev Estimates the needed input amount of the input token for the conversion to return the desired output amount.
   * @param outputAmount the desired output amount
   * @param strategyData the input token
   */
  function estimateInputAmount(uint256 outputAmount, bytes memory strategyData)
    external
    view
    returns (IERC20Upgradeable inputToken, uint256 inputAmount)
  {
    (address inputTokenAddress, address poolAddress, ) = abi.decode(strategyData, (address, address, uint256));

    inputToken = IERC20Upgradeable(inputTokenAddress);

    uint8 decimals = 18;
    try IERC20MetadataUpgradeable(inputTokenAddress).decimals() returns (uint8 dec) {
      decimals = dec;
    } catch {}
    uint256 ONE = 10**decimals;

    ISynthereumLiquidityPool pool = ISynthereumLiquidityPool(poolAddress);
    if (inputToken == pool.syntheticToken()) {
      // collateralAmountReceived / ONE = outputAmount / inputAmount
      // => inputAmount = (ONE * outputAmount) / collateralAmountReceived
      (uint256 collateralAmountReceived, ) = ISynthereumLiquidityPool(poolAddress).getRedeemTradeInfo(ONE);
      inputAmount = ONE.mulDivUp(outputAmount, collateralAmountReceived);
    } else if (inputToken == pool.collateralToken()) {
      // synthTokensReceived / ONE = outputAmount / inputAmount
      // => inputAmount = (ONE * outputAmount) / synthTokensReceived
      (uint256 synthTokensReceived, ) = ISynthereumLiquidityPool(poolAddress).getMintTradeInfo(ONE);
      inputAmount = ONE.mulDivUp(outputAmount, synthTokensReceived);
    } else {
      revert("unknown input token");
    }
  }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Arithmetic library with operations for fixed-point numbers.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/FixedPointMathLib.sol)
/// @author Inspired by USM (https://github.com/usmfum/USM/blob/master/contracts/WadMath.sol)
library FixedPointMathLib {
  /*///////////////////////////////////////////////////////////////
                    SIMPLIFIED FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

  uint256 internal constant WAD = 1e18; // The scalar of ETH and most ERC20s.

  function mulWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
    return mulDivDown(x, y, WAD); // Equivalent to (x * y) / WAD rounded down.
  }

  function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
    return mulDivUp(x, y, WAD); // Equivalent to (x * y) / WAD rounded up.
  }

  function divWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
    return mulDivDown(x, WAD, y); // Equivalent to (x * WAD) / y rounded down.
  }

  function divWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
    return mulDivUp(x, WAD, y); // Equivalent to (x * WAD) / y rounded up.
  }

  /*///////////////////////////////////////////////////////////////
                    LOW LEVEL FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

  function mulDivDown(
    uint256 x,
    uint256 y,
    uint256 denominator
  ) internal pure returns (uint256 z) {
    assembly {
      // Store x * y in z for now.
      z := mul(x, y)

      // Equivalent to require(denominator != 0 && (x == 0 || (x * y) / x == y))
      if iszero(and(iszero(iszero(denominator)), or(iszero(x), eq(div(z, x), y)))) {
        revert(0, 0)
      }

      // Divide z by the denominator.
      z := div(z, denominator)
    }
  }

  function mulDivUp(
    uint256 x,
    uint256 y,
    uint256 denominator
  ) internal pure returns (uint256 z) {
    assembly {
      // Store x * y in z for now.
      z := mul(x, y)

      // Equivalent to require(denominator != 0 && (x == 0 || (x * y) / x == y))
      if iszero(and(iszero(iszero(denominator)), or(iszero(x), eq(div(z, x), y)))) {
        revert(0, 0)
      }

      // First, divide z - 1 by the denominator and add 1.
      // We allow z - 1 to underflow is z is 0, because we multiply the
      // end result by 0 if z is zero, ensuring we return 0 if z is zero.
      z := mul(iszero(iszero(z)), add(div(sub(z, 1), denominator), 1))
    }
  }

  function rpow(
    uint256 x,
    uint256 n,
    uint256 scalar
  ) internal pure returns (uint256 z) {
    assembly {
      switch x
      case 0 {
        switch n
        case 0 {
          // 0 ** 0 = 1
          z := scalar
        }
        default {
          // 0 ** n = 0
          z := 0
        }
      }
      default {
        switch mod(n, 2)
        case 0 {
          // If n is even, store scalar in z for now.
          z := scalar
        }
        default {
          // If n is odd, store x in z for now.
          z := x
        }

        // Shifting right by 1 is like dividing by 2.
        let half := shr(1, scalar)

        for {
          // Shift n right by 1 before looping to halve it.
          n := shr(1, n)
        } n {
          // Shift n right by 1 each iteration to halve it.
          n := shr(1, n)
        } {
          // Revert immediately if x ** 2 would overflow.
          // Equivalent to iszero(eq(div(xx, x), x)) here.
          if shr(128, x) {
            revert(0, 0)
          }

          // Store x squared.
          let xx := mul(x, x)

          // Round to the nearest number.
          let xxRound := add(xx, half)

          // Revert if xx + half overflowed.
          if lt(xxRound, xx) {
            revert(0, 0)
          }

          // Set x to scaled xxRound.
          x := div(xxRound, scalar)

          // If n is even:
          if mod(n, 2) {
            // Compute z * x.
            let zx := mul(z, x)

            // If z * x overflowed:
            if iszero(eq(div(zx, x), z)) {
              // Revert if x is non-zero.
              if iszero(iszero(x)) {
                revert(0, 0)
              }
            }

            // Round to the nearest number.
            let zxRound := add(zx, half)

            // Revert if zx + half overflowed.
            if lt(zxRound, zx) {
              revert(0, 0)
            }

            // Return properly scaled zxRound.
            z := div(zxRound, scalar)
          }
        }
      }
    }
  }

  /*///////////////////////////////////////////////////////////////
                        GENERAL NUMBER UTILITIES
    //////////////////////////////////////////////////////////////*/

  function sqrt(uint256 x) internal pure returns (uint256 z) {
    assembly {
      // Start off with z at 1.
      z := 1

      // Used below to help find a nearby power of 2.
      let y := x

      // Find the lowest power of 2 that is at least sqrt(x).
      if iszero(lt(y, 0x100000000000000000000000000000000)) {
        y := shr(128, y) // Like dividing by 2 ** 128.
        z := shl(64, z)
      }
      if iszero(lt(y, 0x10000000000000000)) {
        y := shr(64, y) // Like dividing by 2 ** 64.
        z := shl(32, z)
      }
      if iszero(lt(y, 0x100000000)) {
        y := shr(32, y) // Like dividing by 2 ** 32.
        z := shl(16, z)
      }
      if iszero(lt(y, 0x10000)) {
        y := shr(16, y) // Like dividing by 2 ** 16.
        z := shl(8, z)
      }
      if iszero(lt(y, 0x100)) {
        y := shr(8, y) // Like dividing by 2 ** 8.
        z := shl(4, z)
      }
      if iszero(lt(y, 0x10)) {
        y := shr(4, y) // Like dividing by 2 ** 4.
        z := shl(2, z)
      }
      if iszero(lt(y, 0x8)) {
        // Equivalent to 2 ** z.
        z := shl(1, z)
      }

      // Shifting right by 1 is like dividing by 2.
      z := shr(1, add(z, div(x, z)))
      z := shr(1, add(z, div(x, z)))
      z := shr(1, add(z, div(x, z)))
      z := shr(1, add(z, div(x, z)))
      z := shr(1, add(z, div(x, z)))
      z := shr(1, add(z, div(x, z)))
      z := shr(1, add(z, div(x, z)))

      // Compute a rounded down version of z.
      let zRoundDown := div(x, z)

      // If zRoundDown is smaller, use it.
      if lt(zRoundDown, z) {
        z := zRoundDown
      }
    }
  }
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity >=0.8.0;

interface IW_NATIVE {
  function deposit() external payable;

  function withdraw(uint256 amount) external;

  function approve(address spender, uint256 amount) external returns (bool);

  function transfer(address to, uint256 amount) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) external returns (bool);

  function balanceOf(address) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/draft-IERC20PermitUpgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}