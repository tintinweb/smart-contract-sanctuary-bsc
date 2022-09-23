// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../swap/IBonfireFactory.sol";
import "../swap/IBonfirePair.sol";
import "../swap/BonfireSwapHelper.sol";
import "../token/IBonfireTokenWrapper.sol";
import "../token/IBonfireTokenTracker.sol";
import "../token/IBonfireProxyToken.sol";
import "../utils/BonfireTokenHelper.sol";

library BonfireRouterPaths {
    address public constant wrapper =
        address(0xBFbb27219f18d7463dD91BB4721D445244F5d22D);
    address public constant tracker =
        address(0xBFac04803249F4C14f5d96427DA22a814063A5E1);

    error BadUse(uint256 location);
    error BadValues(uint256 v1, uint256 v2);
    error BadAccounts(uint256 location, address a1, address a2);

    function getBestPath(
        address token0,
        address token1,
        uint256 amountIn,
        address to,
        address[] calldata uniswapFactories,
        address[] calldata intermediateTokens
    )
        external
        view
        returns (
            uint256 value,
            address[] memory poolPath,
            address[] memory tokenPath
        )
    {
        tokenPath = new address[](2);
        tokenPath[0] = token0;
        tokenPath[1] = token1;
        if (
            _proxySourceMatch(token0, token1) ||
            _proxySourceMatch(token1, token0) ||
            (BonfireSwapHelper.isProxy(token0) &&
                BonfireSwapHelper.isProxy(token1) &&
                IBonfireProxyToken(token0).sourceToken() ==
                IBonfireProxyToken(token1).sourceToken() &&
                IBonfireProxyToken(token0).chainid() ==
                IBonfireProxyToken(token1).chainid())
        ) {
            /*
             * Cases where we simply want to wrap/unwrap/convert
             * chainid is correct
             * 1. both proxy of same sourceToken
             * 2/3. one proxy of the other
             */
            address wrapper0 = BonfireTokenHelper.getWrapper(token0);
            address wrapper1 = BonfireTokenHelper.getWrapper(token1);
            if (wrapper0 == address(0)) {
                //wrap
                value = _wrapperQuote(token0, token1, amountIn);
                poolPath = new address[](1);
                poolPath[0] = wrapper1;
            } else if (wrapper1 == address(0) || wrapper1 == wrapper0) {
                //unwrap or convert
                value = _wrapperQuote(token0, token1, amountIn);
                poolPath = new address[](1);
                poolPath[0] = wrapper0;
            } else {
                /*
                 * This special case is unwrapping in one TokenWrapper and
                 * wrapping in another.
                 */
                poolPath = new address[](2);
                poolPath[0] = wrapper0;
                poolPath[1] = wrapper1;
                tokenPath = new address[](3);
                tokenPath[0] = token0;
                tokenPath[1] = IBonfireProxyToken(token0).sourceToken();
                tokenPath[2] = token1;
                value = _wrapperQuote(tokenPath[0], tokenPath[1], amountIn);
                value = _wrapperQuote(tokenPath[1], tokenPath[2], value);
            }
            value = emulateTax(token1, value, IERC20(token1).balanceOf(to));
        }
        {
            //regular swap checks
            address[] memory t;
            address[] memory p;
            uint256 v;
            (p, t, v) = _getBestPath(
                token0,
                token1,
                amountIn,
                to,
                uniswapFactories,
                intermediateTokens
            );
            if (v > value) {
                tokenPath = t;
                poolPath = p;
                value = v;
            }
            //folowing three additional checks for proxy paths
            if (
                BonfireSwapHelper.isProxy(token0) &&
                BonfireSwapHelper.isProxy(token1) &&
                IBonfireProxyToken(token0).chainid() == block.chainid &&
                IBonfireProxyToken(token1).chainid() == block.chainid &&
                IBonfireProxyToken(token0).sourceToken() !=
                IBonfireProxyToken(token1).sourceToken()
            ) {
                //also try additional unwrapping of token0 and wrapping of token1
                (p, t, v) = _getBestUnwrapSwapWrapPath(
                    token0,
                    token1,
                    amountIn,
                    uniswapFactories,
                    intermediateTokens
                );
                if (v > value) {
                    poolPath = p;
                    tokenPath = t;
                    poolPath = new address[](p.length + 2);
                    tokenPath = new address[](t.length + 2);
                    for (uint256 x = 0; x < p.length; x++) {
                        poolPath[x + 1] = p[x];
                    }
                    for (uint256 x = 0; x < t.length; x++) {
                        tokenPath[x + 1] = t[x];
                    }
                    poolPath[0] = wrapper;
                    poolPath[poolPath.length - 1] = wrapper;
                    tokenPath[0] = token0;
                    tokenPath[tokenPath.length - 1] = token1;
                    value = v;
                }
            }
            if (
                BonfireSwapHelper.isProxy(token0) &&
                IBonfireProxyToken(token0).chainid() == block.chainid &&
                IBonfireProxyToken(token0).sourceToken() != token1
            ) {
                //also try additional unwrapping of token0
                (p, t, v) = _getBestUnwrapSwapPath(
                    token0,
                    token1,
                    amountIn,
                    to,
                    uniswapFactories,
                    intermediateTokens
                );
                if (v > value) {
                    poolPath = new address[](p.length + 1);
                    tokenPath = new address[](t.length + 1);
                    for (uint256 x = 0; x < p.length; x++) {
                        poolPath[x + 1] = p[x];
                    }
                    for (uint256 x = 0; x < t.length; x++) {
                        tokenPath[x + 1] = t[x];
                    }
                    poolPath[0] = wrapper;
                    tokenPath[0] = token0;
                    value = v;
                }
            }
            if (
                BonfireSwapHelper.isProxy(token1) &&
                IBonfireProxyToken(token1).chainid() == block.chainid &&
                IBonfireProxyToken(token1).sourceToken() != token0
            ) {
                //also try additional wrapping of token1
                (p, t, v) = _getBestSwapWrapPath(
                    token0,
                    token1,
                    amountIn,
                    uniswapFactories,
                    intermediateTokens
                );
                if (v > value) {
                    poolPath = new address[](p.length + 1);
                    tokenPath = new address[](t.length + 1);
                    for (uint256 x = 0; x < p.length; x++) {
                        poolPath[x] = p[x];
                    }
                    for (uint256 x = 0; x < t.length; x++) {
                        tokenPath[x] = t[x];
                    }
                    poolPath[poolPath.length - 1] = wrapper;
                    tokenPath[tokenPath.length - 1] = token1;
                    value = v;
                }
            }
        }
    }

    function _getBestUnwrapSwapWrapPath(
        address token0,
        address token1,
        uint256 amount,
        address[] calldata uniswapFactories,
        address[] calldata intermediateTokens
    )
        private
        view
        returns (
            address[] memory,
            address[] memory,
            uint256
        )
    {
        address[] memory poolPath;
        address[] memory tokenPath;
        amount = emulateTax(token0, amount, uint256(0));
        amount = IBonfireTokenWrapper(wrapper).sharesToToken(
            IBonfireProxyToken(token0).sourceToken(),
            IBonfireProxyToken(token0).tokenToShares(amount)
        );
        (poolPath, tokenPath, amount) = _getBestPath(
            IBonfireProxyToken(token0).sourceToken(),
            IBonfireProxyToken(token1).sourceToken(),
            amount,
            address(0),
            uniswapFactories,
            intermediateTokens
        );
        amount = IBonfireProxyToken(token1).sharesToToken(
            IBonfireTokenWrapper(wrapper).tokenToShares(
                IBonfireProxyToken(token1).sourceToken(),
                amount
            )
        );
        amount = emulateTax(token1, amount, uint256(0));
        return (poolPath, tokenPath, amount);
    }

    function _getBestUnwrapSwapPath(
        address token0,
        address token1,
        uint256 amount,
        address to,
        address[] calldata uniswapFactories,
        address[] calldata intermediateTokens
    )
        private
        view
        returns (
            address[] memory,
            address[] memory,
            uint256
        )
    {
        address[] memory poolPath;
        address[] memory tokenPath;
        amount = emulateTax(token0, amount, uint256(0));
        amount = IBonfireTokenWrapper(wrapper).sharesToToken(
            IBonfireProxyToken(token0).sourceToken(),
            IBonfireProxyToken(token0).tokenToShares(amount)
        );
        (poolPath, tokenPath, amount) = _getBestPath(
            IBonfireProxyToken(token0).sourceToken(),
            token1,
            amount,
            to,
            uniswapFactories,
            intermediateTokens
        );
        return (poolPath, tokenPath, amount);
    }

    function _getBestSwapWrapPath(
        address token0,
        address token1,
        uint256 amount,
        address[] calldata uniswapFactories,
        address[] calldata intermediateTokens
    )
        private
        view
        returns (
            address[] memory,
            address[] memory,
            uint256
        )
    {
        address[] memory poolPath;
        address[] memory tokenPath;
        (poolPath, tokenPath, amount) = _getBestPath(
            token0,
            IBonfireProxyToken(token1).sourceToken(),
            amount,
            address(0),
            uniswapFactories,
            intermediateTokens
        );
        amount = IBonfireProxyToken(token1).sharesToToken(
            IBonfireTokenWrapper(wrapper).tokenToShares(
                IBonfireProxyToken(token1).sourceToken(),
                amount
            )
        );
        amount = emulateTax(token1, amount, uint256(0));
        return (poolPath, tokenPath, amount);
    }

    /*
     * this function internally calls  quote
     */
    function _getBestPath(
        address token0,
        address token1,
        uint256 amountIn,
        address to,
        address[] calldata uniswapFactories,
        address[] calldata intermediateTokens
    )
        private
        view
        returns (
            address[] memory poolPath,
            address[] memory tokenPath,
            uint256 amountOut
        )
    {
        tokenPath = new address[](2);
        tokenPath[0] = token0;
        tokenPath[1] = token1;
        poolPath = new address[](1);
        (poolPath[0], amountOut) = getBestPool(
            token0,
            token1,
            amountIn,
            to,
            uniswapFactories
        );
        // use intermediate tokens
        tokenPath = new address[](3);
        tokenPath[0] = token0;
        tokenPath[2] = token1;
        address tokenI = address(0);
        for (uint256 i = 0; i < intermediateTokens.length; i++) {
            tokenPath[1] = intermediateTokens[i];
            if (tokenPath[1] == token0 || tokenPath[1] == token1) continue;
            (address[] memory p, uint256 v) = getBestTwoPoolPath(
                tokenPath,
                amountIn,
                to,
                uniswapFactories
            );
            if (v > amountOut) {
                poolPath = p;
                amountOut = v;
                tokenI = tokenPath[1];
            }
        }
        if (tokenI != address(0)) {
            tokenPath[1] = tokenI;
        } else {
            tokenPath = new address[](2);
            tokenPath[0] = token0;
            tokenPath[1] = token1;
        }
    }

    function getBestPool(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        address to,
        address[] calldata uniswapFactories
    ) public view returns (address pool, uint256 amountOut) {
        for (uint256 i = 0; i < uniswapFactories.length; i++) {
            address p = IBonfireFactory(uniswapFactories[i]).getPair(
                tokenIn,
                tokenOut
            );
            if (p == address(0)) continue;
            uint256 v = _swapQuote(p, tokenIn, tokenOut, amountIn);
            if (v > amountOut) {
                pool = p;
                amountOut = v;
            }
        }
        amountOut = emulateTax(
            tokenOut,
            amountOut,
            IERC20(tokenOut).balanceOf(to)
        );
    }

    function getBestTwoPoolPath(
        address[] memory tokenPath,
        uint256 amountIn,
        address to,
        address[] calldata uniswapFactories
    ) public view returns (address[] memory poolPath, uint256 amountOut) {
        poolPath = new address[](2);
        address[] memory p = new address[](2);
        uint256 value = amountIn;
        for (uint256 j = 0; j < uniswapFactories.length; j++) {
            p[0] = IBonfireFactory(uniswapFactories[j]).getPair(
                tokenPath[0],
                tokenPath[1]
            );
            if (p[0] == address(0)) continue;
            value = _swapQuote(p[0], tokenPath[0], tokenPath[1], amountIn);
            for (uint256 k = 0; k < uniswapFactories.length; k++) {
                p[1] = IBonfireFactory(uniswapFactories[k]).getPair(
                    tokenPath[1],
                    tokenPath[2]
                );
                if (p[1] == address(0)) continue;
                uint256 v = _swapQuote(p[1], tokenPath[1], tokenPath[2], value);
                if (v > amountOut) {
                    poolPath = new address[](p.length);
                    for (uint256 x = 0; x < p.length; x++) {
                        poolPath[x] = p[x];
                    }
                    amountOut = v;
                }
            }
        }
        amountOut = emulateTax(
            tokenPath[2],
            amountOut,
            IERC20(tokenPath[2]).balanceOf(to)
        );
    }

    function _proxySourceMatch(address tokenP, address tokenS)
        private
        view
        returns (bool)
    {
        return (BonfireSwapHelper.isProxy(tokenP) &&
            IBonfireProxyToken(tokenP).chainid() == block.chainid &&
            IBonfireProxyToken(tokenP).sourceToken() == tokenS);
    }

    function emulateTax(
        address token,
        uint256 incomingAmount,
        uint256 targetBalance
    ) public view returns (uint256 expectedAmount) {
        uint256 totalTaxP = IBonfireTokenTracker(tracker).getTotalTaxP(token);
        if (totalTaxP == 0) {
            expectedAmount = incomingAmount;
        } else {
            uint256 reflectionTaxP = IBonfireTokenTracker(tracker)
                .getReflectionTaxP(token);
            uint256 taxQ = IBonfireTokenTracker(tracker).getTaxQ(token);
            uint256 includedSupply = IBonfireTokenTracker(tracker)
                .includedSupply(token);
            uint256 tax = (incomingAmount * totalTaxP) / taxQ;
            uint256 reflection = (incomingAmount * reflectionTaxP) / taxQ;
            if (includedSupply > tax) {
                reflection =
                    (reflection * (targetBalance + incomingAmount - tax)) /
                    (includedSupply - tax);
            } else {
                reflection = 0;
            }
            expectedAmount = incomingAmount - tax + reflection;
        }
    }

    function _swapQuote(
        address pool,
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) private view returns (uint256 amountOut) {
        //no wrapper interaction!
        amountIn = emulateTax(
            tokenIn,
            amountIn,
            IERC20(tokenIn).balanceOf(pool)
        );
        uint256 projectedBalanceB;
        uint256 reserveB;
        (amountOut, reserveB, projectedBalanceB) = BonfireSwapHelper
            .getAmountOutFromPool(amountIn, tokenOut, pool);
        if (IBonfireTokenTracker(tracker).getReflectionTaxP(tokenOut) > 0) {
            amountOut = BonfireSwapHelper.reflectionAdjustment(
                tokenOut,
                pool,
                amountOut,
                projectedBalanceB
            );
        }
        if (amountOut > reserveB)
            //amountB exceeds current reserve, problem with Uniswap even if balanceB justifies that value, return max
            amountOut = reserveB - 1;
    }

    function _wrapperQuote(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) private view returns (uint256 amountOut) {
        //wrapper interaction
        address t0 = BonfireTokenHelper.getSourceToken(tokenIn);
        address t1 = BonfireTokenHelper.getSourceToken(tokenOut);
        address _wrapper = BonfireTokenHelper.getWrapper(tokenIn);
        if (_wrapper != address(0)) {
            address w2 = BonfireTokenHelper.getWrapper(tokenOut);
            if (w2 != address(0)) {
                if (_wrapper != w2) {
                    revert BadAccounts(0, _wrapper, w2); //Wrapper mismatch
                }
                //convert
                amountOut = IBonfireProxyToken(tokenOut).sharesToToken(
                    IBonfireProxyToken(tokenIn).tokenToShares(amountIn)
                );
            } else {
                //unwrap
                if (t0 != tokenOut) {
                    revert BadAccounts(1, t0, t1); //proxy/source mismatch
                }
                amountOut = IBonfireTokenWrapper(_wrapper).sharesToToken(
                    tokenOut,
                    IBonfireProxyToken(tokenIn).tokenToShares(amountIn)
                );
            }
        } else {
            _wrapper = BonfireTokenHelper.getWrapper(tokenOut);
            if (_wrapper == address(0)) {
                revert BadAccounts(2, t0, t1); //no wrapped token
            }
            //wrap
            if (t1 != tokenIn) {
                revert BadAccounts(3, t0, t1); //proxy/source mismatch
            }
            amountIn = emulateTax(tokenIn, amountIn, 0);
            amountOut = IBonfireProxyToken(tokenOut).sharesToToken(
                IBonfireTokenWrapper(_wrapper).tokenToShares(tokenIn, amountIn)
            );
        }
    }

    function wrapperQuote(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        address to
    ) external view returns (uint256 amountOut) {
        amountOut = _wrapperQuote(tokenIn, tokenOut, amountIn);
        amountOut = emulateTax(
            tokenOut,
            amountOut,
            IERC20(tokenOut).balanceOf(to)
        );
    }

    function quote(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amount,
        address to
    ) external view returns (uint256 amountOut) {
        if (tokenPath.length != poolPath.length + 1) {
            revert BadValues(tokenPath.length, poolPath.length); //poolPath and tokenPath lengths do not match
        }
        for (uint256 i = 0; i < tokenPath.length; i++) {
            if (tokenPath[i] == address(0)) {
                revert BadUse(i); //malformed tokenPath
            }
        }
        for (uint256 i = 0; i < poolPath.length; i++) {
            if (poolPath[i] == address(0)) {
                revert BadUse(i); //malformed poolPath
            }
        }
        for (uint256 i = 0; i < poolPath.length; i++) {
            if (BonfireSwapHelper.isWrapper(poolPath[i])) {
                amount = _wrapperQuote(tokenPath[i], tokenPath[i + 1], amount);
            } else {
                amount = _swapQuote(
                    poolPath[i],
                    tokenPath[i],
                    tokenPath[i + 1],
                    amount
                );
            }
        }
        //remove tax but add reflection as applicable
        amountOut = emulateTax(
            tokenPath[tokenPath.length - 1],
            amount,
            IERC20(tokenPath[tokenPath.length - 1]).balanceOf(to)
        );
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IBonfireFactory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IBonfirePair {
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blickTimestampLast
        );

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

import "../swap/IBonfirePair.sol";
import "../swap/ISwapFactoryRegistry.sol";
import "../token/IBonfireTokenTracker.sol";

library BonfireSwapHelper {
    using ERC165Checker for address;

    address public constant tracker =
        address(0xBFac04803249F4C14f5d96427DA22a814063A5E1);
    address public constant factoryRegistry =
        address(0xBF57511A971278FCb1f8D376D68078762Ae957C4);

    bytes4 public constant WRAPPER_INTERFACE_ID = 0x5d674982; //type(IBonfireTokenWrapper).interfaceId;
    bytes4 public constant PROXYTOKEN_INTERFACE_ID = 0xb4718ac4; //type(IBonfireTokenWrapper).interfaceId;

    function isWrapper(address pool) external view returns (bool) {
        return pool.supportsInterface(WRAPPER_INTERFACE_ID);
    }

    function isProxy(address token) external view returns (bool) {
        return token.supportsInterface(PROXYTOKEN_INTERFACE_ID);
    }

    function getAmountOutFromPool(
        uint256 amountIn,
        address tokenB,
        address pool
    )
        external
        view
        returns (
            uint256 amountOut,
            uint256 reserveB,
            uint256 projectedBalanceB
        )
    {
        uint256 remainderP;
        uint256 remainderQ;
        {
            address factory = IBonfirePair(pool).factory();
            remainderP = ISwapFactoryRegistry(factoryRegistry).factoryRemainder(
                    factory
                );
            remainderQ = ISwapFactoryRegistry(factoryRegistry)
                .factoryDenominator(factory);
        }
        uint256 reserveA;
        (reserveA, reserveB, ) = IBonfirePair(pool).getReserves();
        (reserveA, reserveB) = IBonfirePair(pool).token1() == tokenB
            ? (reserveA, reserveB)
            : (reserveB, reserveA);
        uint256 balanceB = IERC20(tokenB).balanceOf(pool);
        amountOut = getAmountOut(
            amountIn,
            reserveA,
            reserveB,
            remainderP,
            remainderQ
        );
        amountOut = balanceB > reserveB
            ? amountOut + (((balanceB - reserveB) * remainderP) / remainderQ)
            : amountOut;
        projectedBalanceB = balanceB - amountOut;
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveA,
        uint256 reserveB,
        uint256 remainderP,
        uint256 remainderQ
    ) public pure returns (uint256 amountOut) {
        uint256 amountInWithFee = amountIn * remainderP;
        uint256 numerator = amountInWithFee * reserveB;
        uint256 denominator = (reserveA * remainderQ) + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function computeAdjustment(
        uint256 amount,
        uint256 projectedBalance,
        uint256 supply,
        uint256 reflectionP,
        uint256 reflectionQ,
        uint256 feeP,
        uint256 feeQ
    ) public pure returns (uint256 adjustedAmount) {
        adjustedAmount =
            amount +
            ((((((amount * reflectionP) / reflectionQ) * projectedBalance) /
                (supply - ((amount * reflectionP) / reflectionQ))) *
                (feeQ - feeP)) / feeQ);
    }

    function reflectionAdjustment(
        address token,
        address pool,
        uint256 amount,
        uint256 projectedBalance
    ) external view returns (uint256 adjustedAmount) {
        address factory = IBonfirePair(pool).factory();
        adjustedAmount = computeAdjustment(
            amount,
            projectedBalance,
            IBonfireTokenTracker(tracker).includedSupply(token),
            IBonfireTokenTracker(tracker).getReflectionTaxP(token),
            IBonfireTokenTracker(tracker).getTaxQ(token),
            ISwapFactoryRegistry(factoryRegistry).factoryFee(factory),
            ISwapFactoryRegistry(factoryRegistry).factoryDenominator(factory)
        );
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IBonfireTokenWrapper is IERC1155 {
    event SecureBridgeUpdate(address bridge, bool enabled);
    event BridgeUpdate(
        address bridge,
        address proxyToken,
        address sourceToken,
        uint256 sourceChain,
        uint256 allowanceShares
    );
    event FactoryUpdate(address factory, bool enabled);
    event MultichainTokenUpdate(address token, bool enabled);

    function factory(address account) external view returns (bool approved);

    function multichainToken(address account)
        external
        view
        returns (bool verified);

    function tokenid(address token, uint256 chain)
        external
        pure
        returns (uint256);

    function addMultichainToken(address target) external;

    function reportMint(address bridge, uint256 shares) external;

    function reportBurn(address bridge, uint256 shares) external;

    function tokenBalanceOf(address sourceToken, address account)
        external
        view
        returns (uint256 tokenAmount);

    function sharesBalanceOf(uint256 sourceTokenId, address account)
        external
        view
        returns (uint256 sharesAmount);

    function lockedTokenTotal(address sourceToken)
        external
        view
        returns (uint256);

    function tokenToShares(address sourceToken, uint256 tokenAmount)
        external
        view
        returns (uint256 sharesAmount);

    function sharesToToken(address sourceToken, uint256 sharesAmount)
        external
        view
        returns (uint256 tokenAmount);

    function moveShares(
        address oldProxy,
        address newProxy,
        uint256 sharesAmountIn,
        address from,
        address to
    ) external returns (uint256 tokenAmountOut, uint256 sharesAmountOut);

    function depositToken(
        address proxyToken,
        address to,
        uint256 amount
    ) external returns (uint256 tokenAmount, uint256 sharesAmount);

    function announceDeposit(address sourceToken) external;

    function executeDeposit(address proxyToken, address to)
        external
        returns (uint256 tokenAmount, uint256 sharesAmount);

    function currentDeposit() external view returns (address sourceToken);

    function withdrawShares(
        address proxyToken,
        address to,
        uint256 amount
    ) external returns (uint256 tokenAmount, uint256 sharesAmount);

    function withdrawSharesFrom(
        address proxyToken,
        address from,
        address to,
        uint256 amount
    ) external returns (uint256 tokenAmount, uint256 sharesAmount);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IBonfireTokenTracker {
    function getObserver(address token) external view returns (address o);

    function getTotalTaxP(address token) external view returns (uint256 p);

    function getReflectionTaxP(address token) external view returns (uint256 p);

    function getTaxQ(address token) external view returns (uint256 q);

    function reflectingSupply(address token, uint256 transferAmount)
        external
        view
        returns (uint256 amount);

    function includedSupply(address token)
        external
        view
        returns (uint256 amount);

    function excludedSupply(address token)
        external
        view
        returns (uint256 amount);

    function storeTokenReference(address token, uint256 chainid) external;

    function tokenid(address token, uint256 chainid)
        external
        pure
        returns (uint256);

    function getURI(uint256 _tokenid) external view returns (string memory);

    function getProperties(address token)
        external
        view
        returns (string memory properties);

    function registerToken(address proxy) external;

    function registeredTokens(uint256 index)
        external
        view
        returns (uint256 tokenid);

    function registeredProxyTokens(uint256 sourceTokenid, uint256 index)
        external
        view
        returns (address);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "../token/IBonfireTokenWrapper.sol";

interface IBonfireProxyToken is IERC20, IERC1155Receiver {
    function sourceToken() external view returns (address);

    function chainid() external view returns (uint256);

    function wrapper() external view returns (address);

    function circulatingSupply() external view returns (uint256);

    function transferShares(address to, uint256 amount) external returns (bool);

    function transferSharesFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function mintShares(address to, uint256 shares) external;

    function burnShares(
        address from,
        uint256 shares,
        address burner
    ) external;

    function tokenToShares(uint256 amount) external view returns (uint256);

    function sharesToToken(uint256 amount) external view returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

library BonfireTokenHelper {
    string constant _totalSupply = "totalSupply()";
    string constant _circulatingSupply = "circulatingSupply()";
    string constant _token = "sourceToken()";
    string constant _wrapper = "wrapper()";
    bytes constant SUPPLY = abi.encodeWithSignature(_totalSupply);
    bytes constant CIRCULATING = abi.encodeWithSignature(_circulatingSupply);
    bytes constant TOKEN = abi.encodeWithSignature(_token);
    bytes constant WRAPPER = abi.encodeWithSignature(_wrapper);

    function circulatingSupply(address token)
        external
        view
        returns (uint256 supply)
    {
        (bool _success, bytes memory data) = token.staticcall(CIRCULATING);
        if (!_success) {
            (_success, data) = token.staticcall(SUPPLY);
        }
        if (_success) {
            supply = abi.decode(data, (uint256));
        }
    }

    function getSourceToken(address proxyToken)
        external
        view
        returns (address sourceToken)
    {
        (bool _success, bytes memory data) = proxyToken.staticcall(TOKEN);
        if (_success) {
            sourceToken = abi.decode(data, (address));
        }
    }

    function getWrapper(address proxyToken)
        external
        view
        returns (address wrapper)
    {
        (bool _success, bytes memory data) = proxyToken.staticcall(WRAPPER);
        if (_success) {
            wrapper = abi.decode(data, (address));
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.2) (utils/introspection/ERC165Checker.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165Checker {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface,
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            _supportsERC165Interface(account, type(IERC165).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    /**
     * @dev Returns true if `account` supports the interface defined by
     * `interfaceId`. Support for {IERC165} itself is queried automatically.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        // query support of both ERC165 as per the spec and support of _interfaceId
        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    /**
     * @dev Returns a boolean array where each value corresponds to the
     * interfaces passed in and whether they're supported or not. This allows
     * you to batch check interfaces for a contract where your expectation
     * is that some interfaces may not be supported.
     *
     * See {IERC165-supportsInterface}.
     *
     * _Available since v3.4._
     */
    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {
        // an array of booleans corresponding to interfaceIds and whether they're supported or not
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        // query support of ERC165 itself
        if (supportsERC165(account)) {
            // query support of each interface in interfaceIds
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    /**
     * @dev Returns true if `account` supports all the interfaces defined in
     * `interfaceIds`. Support for {IERC165} itself is queried automatically.
     *
     * Batch-querying can lead to gas savings by skipping repeated checks for
     * {IERC165} support.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        // query support of ERC165 itself
        if (!supportsERC165(account)) {
            return false;
        }

        // query support of each interface in _interfaceIds
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        // all interfaces supported
        return true;
    }

    /**
     * @notice Query if a contract implements an interface, does not check ERC165 support
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return true if the contract at account indicates support of the interface with
     * identifier interfaceId, false otherwise
     * @dev Assumes that account contains a contract that supports ERC165, otherwise
     * the behavior of this method is undefined. This precondition can be checked
     * with {supportsERC165}.
     * Interface identification is specified in ERC-165.
     */
    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {
        // prepare call
        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);

        // perform static call
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly {
            success := staticcall(30000, account, add(encodedParams, 0x20), mload(encodedParams), 0x00, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0x00)
        }

        return success && returnSize >= 0x20 && returnValue > 0;
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface ISwapFactoryRegistry {
    function getWETHEquivalent(address token, uint256 wethAmount)
        external
        view
        returns (uint256 tokenAmount);

    function getBiggestWETHPool(address token)
        external
        view
        returns (address pool);

    function getUniswapFactories()
        external
        view
        returns (address[] memory factories);

    function factoryDescription(address factory)
        external
        view
        returns (bytes32 description);

    function factoryFee(address factory) external view returns (uint256 feeP);

    function factoryRemainder(address factory)
        external
        view
        returns (uint256 remainderP);

    function factoryDenominator(address factory)
        external
        view
        returns (uint256 denominator);

    function enabled(address factory) external view returns (bool);
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}