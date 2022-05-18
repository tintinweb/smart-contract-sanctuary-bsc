// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "IERC20.sol";
import "Address.sol";
import "IUniswapV2Router02.sol";

import "ExchangePoolProcessor.sol";
import "LenientReentrancyGuard.sol";
import "ITreasuryHandler.sol";

/**
 * @title Treasury handler alpha contract
 * @dev Sells tokens that have accumulated through taxes and sends the resulting ETH to the treasury. If
 * `liquidityBasisPoints` has been set to a non-zero value, then that percentage will instead be added to the designated
 * liquidity pool.
 */
contract TreasuryHandlerAlpha is ITreasuryHandler, LenientReentrancyGuard, ExchangePoolProcessor {
    using Address for address payable;
    using EnumerableSet for EnumerableSet.AddressSet;

    /// @notice The treasury address.
    address payable public treasury;

    /// @notice The token that accumulates through taxes. This will be sold for ETH.
    IERC20 public token;

    /// @notice The basis points of tokens to sell and add as liquidity to the pool.
    uint256 public liquidityBasisPoints;

    /// @notice The maximum price impact the sell (initiated from this contract) may have.
    uint256 public priceImpactBasisPoints;

    /// @notice The Uniswap router that handles the sell and liquidity operations.
    IUniswapV2Router02 public router;

    /// @notice Emitted when the basis points value of tokens to add as liquidity is updated.
    event LiquidityBasisPointsUpdated(uint256 oldBasisPoints, uint256 newBasisPoints);

    /// @notice Emitted when the maximum price impact basis points value is updated.
    event PriceImpactBasisPointsUpdated(uint256 oldBasisPoints, uint256 newBasisPoints);

    /// @notice Emitted when the treasury address is updated.
    event TreasuryAddressUpdated(address oldTreasuryAddress, address newTreasuryAddress);

    /**
     * @param treasuryAddress Address of treasury to use.
     * @param tokenAddress Address of token to accumulate and sell.
     * @param routerAddress Address of Uniswap router for sell and liquidity operations.
     * @param initialLiquidityBasisPoints Initial basis points value of swap to add to liquidity.
     * @param initialPriceImpactBasisPoints Initial basis points value of price impact to account for during swaps.
     */
    constructor(
        address treasuryAddress,
        address tokenAddress,
        address routerAddress,
        uint256 initialLiquidityBasisPoints,
        uint256 initialPriceImpactBasisPoints
    ) {
        treasury = payable(treasuryAddress);
        token = IERC20(tokenAddress);
        router = IUniswapV2Router02(routerAddress);
        liquidityBasisPoints = initialLiquidityBasisPoints;
        priceImpactBasisPoints = initialPriceImpactBasisPoints;
    }

    /**
     * @notice Perform operations before a sell action (or a liquidity addition) is executed. The accumulated tokens are
     * then sold for ETH. In case the number of accumulated tokens exceeds the price impact percentage threshold, then
     * the number will be adjusted to stay within the threshold. If a non-zero percentage is set for liquidity, then
     * that percentage will be added to the primary liquidity pool instead of being sold for ETH and sent to the
     * treasury.
     * @param benefactor Address of the benefactor.
     * @param beneficiary Address of the beneficiary.
     * @param amount Number of tokens in the transfer.
     */
    function beforeTransferHandler(
        address benefactor,
        address beneficiary,
        uint256 amount
    ) external nonReentrant {
        // Silence a few warnings. This will be optimized out by the compiler.
        benefactor;
        amount;

        // No actions are done on transfers other than sells.
        if (!_exchangePools.contains(beneficiary)) {
            return;
        }

        uint256 contractTokenBalance = token.balanceOf(address(this));
        if (contractTokenBalance > 0) {
            uint256 primaryPoolBalance = token.balanceOf(primaryPool);
            uint256 maxPriceImpactSale = (primaryPoolBalance * priceImpactBasisPoints) / 10000;

            // Ensure the price impact is within reasonable bounds.
            if (contractTokenBalance > maxPriceImpactSale) {
                contractTokenBalance = maxPriceImpactSale;
            }

            // The number of tokens to sell for liquidity purposes. This is calculated as follows:
            //
            //      B     P
            //  L = - * -----
            //      2   10000
            //
            // Where:
            //  L = tokens to sell for liquidity
            //  B = available token balance
            //  P = basis points of tokens to use for liquidity
            //
            // The number is divided by two to preserve the token side of the token/WETH pool.
            uint256 tokensForLiquidity = (contractTokenBalance * liquidityBasisPoints) / 20000;
            uint256 tokensForSwap = contractTokenBalance - tokensForLiquidity;

            uint256 currentWeiBalance = address(this).balance;
            _swapTokensForEth(tokensForSwap);
            uint256 weiEarned = address(this).balance - currentWeiBalance;

            // No need to divide this number, because that was only to have enough tokens remaining to pair with this
            // ETH value.
            uint256 weiForLiquidity = (weiEarned * liquidityBasisPoints) / 10000;

            if (tokensForLiquidity > 0) {
                _addLiquidity(tokensForLiquidity, weiForLiquidity);
            }

            // It's cheaper to get the active balance rather than calculating based off of the `currentWeiBalance` and
            // `weiForLiquidity` numbers.
            uint256 remainingWeiBalance = address(this).balance;
            if (remainingWeiBalance > 0) {
                treasury.sendValue(remainingWeiBalance);
            }
        }
    }

    /**
     * @notice Perform post-transfer operations. This contract ignores those operations, hence nothing happens.
     * @param benefactor Address of the benefactor.
     * @param beneficiary Address of the beneficiary.
     * @param amount Number of tokens in the transfer.
     */
    function afterTransferHandler(
        address benefactor,
        address beneficiary,
        uint256 amount
    ) external nonReentrant {
        // Silence a few warnings. This will be optimized out by the compiler.
        benefactor;
        beneficiary;
        amount;

        return;
    }

    /**
     * @notice Set new liquidity basis points value.
     * @param newBasisPoints New liquidity basis points value. Cannot exceed 10,000 (i.e., 100%) as that would break the
     * calculation.
     */
    function setLiquidityBasisPoints(uint256 newBasisPoints) external onlyOwner {
        require(
            newBasisPoints <= 10000,
            "TreasuryHandlerAlpha:setLiquidityPercentage:INVALID_PERCENTAGE: Cannot set more than 10,000 basis points."
        );
        uint256 oldBasisPoints = liquidityBasisPoints;
        liquidityBasisPoints = newBasisPoints;

        emit LiquidityBasisPointsUpdated(oldBasisPoints, newBasisPoints);
    }

    /**
     * @notice Set new price impact basis points value.
     * @param newBasisPoints New price impact basis points value.
     */
    function setPriceImpactBasisPoints(uint256 newBasisPoints) external onlyOwner {
        require(
            newBasisPoints < 1500,
            "TreasuryHandlerAlpha:setPriceImpactBasisPoints:OUT_OF_BOUNDS: Cannot set price impact too high."
        );

        uint256 oldBasisPoints = priceImpactBasisPoints;
        priceImpactBasisPoints = newBasisPoints;

        emit PriceImpactBasisPointsUpdated(oldBasisPoints, newBasisPoints);
    }

    /**
     * @notice Set new treasury address.
     * @param newTreasuryAddress New treasury address.
     */
    function setTreasury(address newTreasuryAddress) external onlyOwner {
        require(
            newTreasuryAddress != address(0),
            "TreasuryHandlerAlpha:setTreasury:ZERO_TREASURY: Cannot set zero address as treasury."
        );

        address oldTreasuryAddress = address(treasury);
        treasury = payable(newTreasuryAddress);

        emit TreasuryAddressUpdated(oldTreasuryAddress, newTreasuryAddress);
    }

    /**
     * @notice Withdraw any tokens or ETH stuck in the treasury handler.
     * @param tokenAddress Address of the token to withdraw. If set to the zero address, ETH will be withdrawn.
     * @param amount The number of tokens to withdraw.
     */
    function withdraw(address tokenAddress, uint256 amount) external onlyOwner {
        require(
            tokenAddress != address(token),
            "TreasuryHandlerAlpha:withdraw:INVALID_TOKEN: Not allowed to withdraw token required for swaps."
        );

        if (tokenAddress == address(0)) {
            treasury.sendValue(amount);
        } else {
            IERC20(tokenAddress).transferFrom(address(this), address(treasury), amount);
        }
    }

    /**
     * @dev Swap accumulated tokens for ETH.
     * @param tokenAmount Number of tokens to swap for ETH.
     */
    function _swapTokensForEth(uint256 tokenAmount) private {
        // The ETH/token pool is the primary pool. It always exists.
        address[] memory path = new address[](2);
        path[0] = address(token);
        path[1] = router.WETH();

        // Ensure the router can perform the swap for the designated number of tokens.
        token.approve(address(router), tokenAmount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }

    /**
     * @dev Add liquidity to primary pool.
     * @param tokenAmount Number of tokens to add as liquidity.
     * @param weiAmount ETH value to pair with the tokens.
     */
    function _addLiquidity(uint256 tokenAmount, uint256 weiAmount) private {
        // Ensure the router can perform the transfer for the designated number of tokens.
        token.approve(address(router), tokenAmount);

        // Both minimum values are set to zero to allow for any form of slippage.
        router.addLiquidityETH{ value: weiAmount }(
            address(token),
            tokenAmount,
            0,
            0,
            address(treasury),
            block.timestamp
        );
    }

    /**
     * @notice Allow contract to accept ETH.
     */
    receive() external payable {}
}